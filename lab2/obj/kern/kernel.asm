
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
f0100058:	e8 14 37 00 00       	call   f0103771 <memset>

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
f010006a:	68 c0 3b 10 f0       	push   $0xf0103bc0
f010006f:	e8 cd 2b 00 00       	call   f0102c41 <cprintf>

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
f01000b0:	68 db 3b 10 f0       	push   $0xf0103bdb
f01000b5:	e8 87 2b 00 00       	call   f0102c41 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 57 2b 00 00       	call   f0102c1b <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 a5 3e 10 f0 	movl   $0xf0103ea5,(%esp)
f01000cb:	e8 71 2b 00 00       	call   f0102c41 <cprintf>
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
f01000f2:	68 f3 3b 10 f0       	push   $0xf0103bf3
f01000f7:	e8 45 2b 00 00       	call   f0102c41 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 13 2b 00 00       	call   f0102c1b <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 a5 3e 10 f0 	movl   $0xf0103ea5,(%esp)
f010010f:	e8 2d 2b 00 00       	call   f0102c41 <cprintf>
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
f01002fd:	e8 b9 34 00 00       	call   f01037bb <memmove>
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
f010039c:	8a 82 40 3c 10 f0    	mov    -0xfefc3c0(%edx),%al
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
f01003d8:	0f b6 82 40 3c 10 f0 	movzbl -0xfefc3c0(%edx),%eax
f01003df:	0b 05 28 e5 11 f0    	or     0xf011e528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 40 3d 10 f0 	movzbl -0xfefc2c0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 e5 11 f0       	mov    %eax,0xf011e528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 40 3e 10 f0 	mov    -0xfefc1c0(,%ecx,4),%ecx
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
f0100430:	68 0d 3c 10 f0       	push   $0xf0103c0d
f0100435:	e8 07 28 00 00       	call   f0102c41 <cprintf>
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
f0100591:	68 19 3c 10 f0       	push   $0xf0103c19
f0100596:	e8 a6 26 00 00       	call   f0102c41 <cprintf>
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
f01005da:	68 50 3e 10 f0       	push   $0xf0103e50
f01005df:	e8 5d 26 00 00       	call   f0102c41 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 38 40 10 f0       	push   $0xf0104038
f01005f1:	e8 4b 26 00 00       	call   f0102c41 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 60 40 10 f0       	push   $0xf0104060
f0100608:	e8 34 26 00 00       	call   f0102c41 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 c0 3b 10 00       	push   $0x103bc0
f0100615:	68 c0 3b 10 f0       	push   $0xf0103bc0
f010061a:	68 84 40 10 f0       	push   $0xf0104084
f010061f:	e8 1d 26 00 00       	call   f0102c41 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 e3 11 00       	push   $0x11e300
f010062c:	68 00 e3 11 f0       	push   $0xf011e300
f0100631:	68 a8 40 10 f0       	push   $0xf01040a8
f0100636:	e8 06 26 00 00       	call   f0102c41 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 e9 11 00       	push   $0x11e950
f0100643:	68 50 e9 11 f0       	push   $0xf011e950
f0100648:	68 cc 40 10 f0       	push   $0xf01040cc
f010064d:	e8 ef 25 00 00       	call   f0102c41 <cprintf>
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
f0100674:	68 f0 40 10 f0       	push   $0xf01040f0
f0100679:	e8 c3 25 00 00       	call   f0102c41 <cprintf>
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
f0100694:	ff b3 44 45 10 f0    	pushl  -0xfefbabc(%ebx)
f010069a:	ff b3 40 45 10 f0    	pushl  -0xfefbac0(%ebx)
f01006a0:	68 69 3e 10 f0       	push   $0xf0103e69
f01006a5:	e8 97 25 00 00       	call   f0102c41 <cprintf>
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
f01006d4:	68 1c 41 10 f0       	push   $0xf010411c
f01006d9:	e8 63 25 00 00       	call   f0102c41 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01006de:	c7 04 24 50 41 10 f0 	movl   $0xf0104150,(%esp)
f01006e5:	e8 57 25 00 00       	call   f0102c41 <cprintf>
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	e9 1a 01 00 00       	jmp    f010080c <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01006f2:	83 ec 04             	sub    $0x4,%esp
f01006f5:	6a 00                	push   $0x0
f01006f7:	6a 00                	push   $0x0
f01006f9:	ff 76 04             	pushl  0x4(%esi)
f01006fc:	e8 a9 31 00 00       	call   f01038aa <strtol>
f0100701:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100703:	83 c4 0c             	add    $0xc,%esp
f0100706:	6a 00                	push   $0x0
f0100708:	6a 00                	push   $0x0
f010070a:	ff 76 08             	pushl  0x8(%esi)
f010070d:	e8 98 31 00 00       	call   f01038aa <strtol>
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
f0100731:	68 72 3e 10 f0       	push   $0xf0103e72
f0100736:	e8 06 25 00 00       	call   f0102c41 <cprintf>
        
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
f0100754:	68 83 3e 10 f0       	push   $0xf0103e83
f0100759:	e8 e3 24 00 00       	call   f0102c41 <cprintf>
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
f0100781:	68 9a 3e 10 f0       	push   $0xf0103e9a
f0100786:	e8 b6 24 00 00       	call   f0102c41 <cprintf>
f010078b:	83 c4 10             	add    $0x10,%esp
f010078e:	eb 74                	jmp    f0100804 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100790:	83 ec 08             	sub    $0x8,%esp
f0100793:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100798:	50                   	push   %eax
f0100799:	68 a7 3e 10 f0       	push   $0xf0103ea7
f010079e:	e8 9e 24 00 00       	call   f0102c41 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007a3:	83 c4 10             	add    $0x10,%esp
f01007a6:	f6 03 04             	testb  $0x4,(%ebx)
f01007a9:	74 12                	je     f01007bd <mon_showmappings+0xfe>
f01007ab:	83 ec 0c             	sub    $0xc,%esp
f01007ae:	68 af 3e 10 f0       	push   $0xf0103eaf
f01007b3:	e8 89 24 00 00       	call   f0102c41 <cprintf>
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	eb 10                	jmp    f01007cd <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007bd:	83 ec 0c             	sub    $0xc,%esp
f01007c0:	68 bc 3e 10 f0       	push   $0xf0103ebc
f01007c5:	e8 77 24 00 00       	call   f0102c41 <cprintf>
f01007ca:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01007cd:	f6 03 02             	testb  $0x2,(%ebx)
f01007d0:	74 12                	je     f01007e4 <mon_showmappings+0x125>
f01007d2:	83 ec 0c             	sub    $0xc,%esp
f01007d5:	68 c9 3e 10 f0       	push   $0xf0103ec9
f01007da:	e8 62 24 00 00       	call   f0102c41 <cprintf>
f01007df:	83 c4 10             	add    $0x10,%esp
f01007e2:	eb 10                	jmp    f01007f4 <mon_showmappings+0x135>
                else cprintf(" R ");
f01007e4:	83 ec 0c             	sub    $0xc,%esp
f01007e7:	68 ce 3e 10 f0       	push   $0xf0103ece
f01007ec:	e8 50 24 00 00       	call   f0102c41 <cprintf>
f01007f1:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01007f4:	83 ec 0c             	sub    $0xc,%esp
f01007f7:	68 a5 3e 10 f0       	push   $0xf0103ea5
f01007fc:	e8 40 24 00 00       	call   f0102c41 <cprintf>
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
f010082e:	68 78 41 10 f0       	push   $0xf0104178
f0100833:	e8 09 24 00 00       	call   f0102c41 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100838:	c7 04 24 c8 41 10 f0 	movl   $0xf01041c8,(%esp)
f010083f:	e8 fd 23 00 00       	call   f0102c41 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	e9 a5 01 00 00       	jmp    f01009f1 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f010084c:	83 ec 04             	sub    $0x4,%esp
f010084f:	6a 00                	push   $0x0
f0100851:	6a 00                	push   $0x0
f0100853:	ff 73 04             	pushl  0x4(%ebx)
f0100856:	e8 4f 30 00 00       	call   f01038aa <strtol>
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
f01008ba:	68 ec 41 10 f0       	push   $0xf01041ec
f01008bf:	e8 7d 23 00 00       	call   f0102c41 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01008c4:	83 c4 10             	add    $0x10,%esp
f01008c7:	f6 03 02             	testb  $0x2,(%ebx)
f01008ca:	74 12                	je     f01008de <mon_setpermission+0xc5>
f01008cc:	83 ec 0c             	sub    $0xc,%esp
f01008cf:	68 d2 3e 10 f0       	push   $0xf0103ed2
f01008d4:	e8 68 23 00 00       	call   f0102c41 <cprintf>
f01008d9:	83 c4 10             	add    $0x10,%esp
f01008dc:	eb 10                	jmp    f01008ee <mon_setpermission+0xd5>
f01008de:	83 ec 0c             	sub    $0xc,%esp
f01008e1:	68 d5 3e 10 f0       	push   $0xf0103ed5
f01008e6:	e8 56 23 00 00       	call   f0102c41 <cprintf>
f01008eb:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01008ee:	f6 03 04             	testb  $0x4,(%ebx)
f01008f1:	74 12                	je     f0100905 <mon_setpermission+0xec>
f01008f3:	83 ec 0c             	sub    $0xc,%esp
f01008f6:	68 a1 4e 10 f0       	push   $0xf0104ea1
f01008fb:	e8 41 23 00 00       	call   f0102c41 <cprintf>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	eb 10                	jmp    f0100915 <mon_setpermission+0xfc>
f0100905:	83 ec 0c             	sub    $0xc,%esp
f0100908:	68 d8 3e 10 f0       	push   $0xf0103ed8
f010090d:	e8 2f 23 00 00       	call   f0102c41 <cprintf>
f0100912:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100915:	f6 03 01             	testb  $0x1,(%ebx)
f0100918:	74 12                	je     f010092c <mon_setpermission+0x113>
f010091a:	83 ec 0c             	sub    $0xc,%esp
f010091d:	68 2d 4f 10 f0       	push   $0xf0104f2d
f0100922:	e8 1a 23 00 00       	call   f0102c41 <cprintf>
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	eb 10                	jmp    f010093c <mon_setpermission+0x123>
f010092c:	83 ec 0c             	sub    $0xc,%esp
f010092f:	68 d6 3e 10 f0       	push   $0xf0103ed6
f0100934:	e8 08 23 00 00       	call   f0102c41 <cprintf>
f0100939:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f010093c:	83 ec 0c             	sub    $0xc,%esp
f010093f:	68 da 3e 10 f0       	push   $0xf0103eda
f0100944:	e8 f8 22 00 00       	call   f0102c41 <cprintf>
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
f0100962:	68 d2 3e 10 f0       	push   $0xf0103ed2
f0100967:	e8 d5 22 00 00       	call   f0102c41 <cprintf>
f010096c:	83 c4 10             	add    $0x10,%esp
f010096f:	eb 10                	jmp    f0100981 <mon_setpermission+0x168>
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	68 d5 3e 10 f0       	push   $0xf0103ed5
f0100979:	e8 c3 22 00 00       	call   f0102c41 <cprintf>
f010097e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100981:	f6 03 04             	testb  $0x4,(%ebx)
f0100984:	74 12                	je     f0100998 <mon_setpermission+0x17f>
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	68 a1 4e 10 f0       	push   $0xf0104ea1
f010098e:	e8 ae 22 00 00       	call   f0102c41 <cprintf>
f0100993:	83 c4 10             	add    $0x10,%esp
f0100996:	eb 10                	jmp    f01009a8 <mon_setpermission+0x18f>
f0100998:	83 ec 0c             	sub    $0xc,%esp
f010099b:	68 d8 3e 10 f0       	push   $0xf0103ed8
f01009a0:	e8 9c 22 00 00       	call   f0102c41 <cprintf>
f01009a5:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009a8:	f6 03 01             	testb  $0x1,(%ebx)
f01009ab:	74 12                	je     f01009bf <mon_setpermission+0x1a6>
f01009ad:	83 ec 0c             	sub    $0xc,%esp
f01009b0:	68 2d 4f 10 f0       	push   $0xf0104f2d
f01009b5:	e8 87 22 00 00       	call   f0102c41 <cprintf>
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	eb 10                	jmp    f01009cf <mon_setpermission+0x1b6>
f01009bf:	83 ec 0c             	sub    $0xc,%esp
f01009c2:	68 d6 3e 10 f0       	push   $0xf0103ed6
f01009c7:	e8 75 22 00 00       	call   f0102c41 <cprintf>
f01009cc:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	68 a5 3e 10 f0       	push   $0xf0103ea5
f01009d7:	e8 65 22 00 00       	call   f0102c41 <cprintf>
f01009dc:	83 c4 10             	add    $0x10,%esp
f01009df:	eb 10                	jmp    f01009f1 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f01009e1:	83 ec 0c             	sub    $0xc,%esp
f01009e4:	68 9a 3e 10 f0       	push   $0xf0103e9a
f01009e9:	e8 53 22 00 00       	call   f0102c41 <cprintf>
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
f0100a0f:	68 10 42 10 f0       	push   $0xf0104210
f0100a14:	e8 28 22 00 00       	call   f0102c41 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a19:	c7 04 24 40 42 10 f0 	movl   $0xf0104240,(%esp)
f0100a20:	e8 1c 22 00 00       	call   f0102c41 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a25:	c7 04 24 60 42 10 f0 	movl   $0xf0104260,(%esp)
f0100a2c:	e8 10 22 00 00       	call   f0102c41 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a31:	c7 04 24 94 42 10 f0 	movl   $0xf0104294,(%esp)
f0100a38:	e8 04 22 00 00       	call   f0102c41 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a3d:	c7 04 24 d8 42 10 f0 	movl   $0xf01042d8,(%esp)
f0100a44:	e8 f8 21 00 00       	call   f0102c41 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a49:	c7 04 24 eb 3e 10 f0 	movl   $0xf0103eeb,(%esp)
f0100a50:	e8 ec 21 00 00       	call   f0102c41 <cprintf>
        cprintf("         set the background color to black\n");
f0100a55:	c7 04 24 1c 43 10 f0 	movl   $0xf010431c,(%esp)
f0100a5c:	e8 e0 21 00 00       	call   f0102c41 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100a61:	c7 04 24 48 43 10 f0 	movl   $0xf0104348,(%esp)
f0100a68:	e8 d4 21 00 00       	call   f0102c41 <cprintf>
f0100a6d:	83 c4 10             	add    $0x10,%esp
f0100a70:	eb 52                	jmp    f0100ac4 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a72:	83 ec 0c             	sub    $0xc,%esp
f0100a75:	ff 73 04             	pushl  0x4(%ebx)
f0100a78:	e8 2b 2b 00 00       	call   f01035a8 <strlen>
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
f0100ab7:	68 7c 43 10 f0       	push   $0xf010437c
f0100abc:	e8 80 21 00 00       	call   f0102c41 <cprintf>
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
f0100af8:	68 a0 43 10 f0       	push   $0xf01043a0
f0100afd:	e8 3f 21 00 00       	call   f0102c41 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b02:	83 c4 18             	add    $0x18,%esp
f0100b05:	57                   	push   %edi
f0100b06:	ff 76 04             	pushl  0x4(%esi)
f0100b09:	e8 6f 22 00 00       	call   f0102d7d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b0e:	83 c4 0c             	add    $0xc,%esp
f0100b11:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b14:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b17:	68 07 3f 10 f0       	push   $0xf0103f07
f0100b1c:	e8 20 21 00 00       	call   f0102c41 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b21:	83 c4 0c             	add    $0xc,%esp
f0100b24:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b27:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b2a:	68 17 3f 10 f0       	push   $0xf0103f17
f0100b2f:	e8 0d 21 00 00       	call   f0102c41 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b34:	83 c4 08             	add    $0x8,%esp
f0100b37:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b3a:	53                   	push   %ebx
f0100b3b:	68 1c 3f 10 f0       	push   $0xf0103f1c
f0100b40:	e8 fc 20 00 00       	call   f0102c41 <cprintf>
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
f0100b77:	68 d8 43 10 f0       	push   $0xf01043d8
f0100b7c:	68 92 00 00 00       	push   $0x92
f0100b81:	68 21 3f 10 f0       	push   $0xf0103f21
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
f0100bbb:	68 d8 43 10 f0       	push   $0xf01043d8
f0100bc0:	68 97 00 00 00       	push   $0x97
f0100bc5:	68 21 3f 10 f0       	push   $0xf0103f21
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
f0100c1d:	68 fc 43 10 f0       	push   $0xf01043fc
f0100c22:	e8 1a 20 00 00       	call   f0102c41 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c27:	c7 04 24 2c 44 10 f0 	movl   $0xf010442c,(%esp)
f0100c2e:	e8 0e 20 00 00       	call   f0102c41 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c33:	c7 04 24 54 44 10 f0 	movl   $0xf0104454,(%esp)
f0100c3a:	e8 02 20 00 00       	call   f0102c41 <cprintf>
f0100c3f:	83 c4 10             	add    $0x10,%esp
f0100c42:	e9 59 01 00 00       	jmp    f0100da0 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c47:	83 ec 04             	sub    $0x4,%esp
f0100c4a:	6a 00                	push   $0x0
f0100c4c:	6a 00                	push   $0x0
f0100c4e:	ff 76 08             	pushl  0x8(%esi)
f0100c51:	e8 54 2c 00 00       	call   f01038aa <strtol>
f0100c56:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c58:	83 c4 0c             	add    $0xc,%esp
f0100c5b:	6a 00                	push   $0x0
f0100c5d:	6a 00                	push   $0x0
f0100c5f:	ff 76 0c             	pushl  0xc(%esi)
f0100c62:	e8 43 2c 00 00       	call   f01038aa <strtol>
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
f0100ca3:	68 a5 3e 10 f0       	push   $0xf0103ea5
f0100ca8:	e8 94 1f 00 00       	call   f0102c41 <cprintf>
f0100cad:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100cb0:	83 ec 08             	sub    $0x8,%esp
f0100cb3:	53                   	push   %ebx
f0100cb4:	68 30 3f 10 f0       	push   $0xf0103f30
f0100cb9:	e8 83 1f 00 00       	call   f0102c41 <cprintf>
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
f0100cea:	68 3a 3f 10 f0       	push   $0xf0103f3a
f0100cef:	e8 4d 1f 00 00       	call   f0102c41 <cprintf>
f0100cf4:	83 c4 10             	add    $0x10,%esp
f0100cf7:	eb 10                	jmp    f0100d09 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100cf9:	83 ec 0c             	sub    $0xc,%esp
f0100cfc:	68 45 3f 10 f0       	push   $0xf0103f45
f0100d01:	e8 3b 1f 00 00       	call   f0102c41 <cprintf>
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
f0100d14:	68 a5 3e 10 f0       	push   $0xf0103ea5
f0100d19:	e8 23 1f 00 00       	call   f0102c41 <cprintf>
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
f0100d34:	68 a5 3e 10 f0       	push   $0xf0103ea5
f0100d39:	e8 03 1f 00 00       	call   f0102c41 <cprintf>
f0100d3e:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d41:	83 ec 08             	sub    $0x8,%esp
f0100d44:	53                   	push   %ebx
f0100d45:	68 30 3f 10 f0       	push   $0xf0103f30
f0100d4a:	e8 f2 1e 00 00       	call   f0102c41 <cprintf>
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
f0100d69:	68 3a 3f 10 f0       	push   $0xf0103f3a
f0100d6e:	e8 ce 1e 00 00       	call   f0102c41 <cprintf>
f0100d73:	83 c4 10             	add    $0x10,%esp
f0100d76:	eb 10                	jmp    f0100d88 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100d78:	83 ec 0c             	sub    $0xc,%esp
f0100d7b:	68 43 3f 10 f0       	push   $0xf0103f43
f0100d80:	e8 bc 1e 00 00       	call   f0102c41 <cprintf>
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
f0100d93:	68 a5 3e 10 f0       	push   $0xf0103ea5
f0100d98:	e8 a4 1e 00 00       	call   f0102c41 <cprintf>
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
f0100db6:	68 98 44 10 f0       	push   $0xf0104498
f0100dbb:	e8 81 1e 00 00       	call   f0102c41 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100dc0:	c7 04 24 bc 44 10 f0 	movl   $0xf01044bc,(%esp)
f0100dc7:	e8 75 1e 00 00       	call   f0102c41 <cprintf>
f0100dcc:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100dcf:	83 ec 0c             	sub    $0xc,%esp
f0100dd2:	68 50 3f 10 f0       	push   $0xf0103f50
f0100dd7:	e8 fc 26 00 00       	call   f01034d8 <readline>
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
f0100e04:	68 54 3f 10 f0       	push   $0xf0103f54
f0100e09:	e8 13 29 00 00       	call   f0103721 <strchr>
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
f0100e24:	68 59 3f 10 f0       	push   $0xf0103f59
f0100e29:	e8 13 1e 00 00       	call   f0102c41 <cprintf>
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
f0100e4e:	68 54 3f 10 f0       	push   $0xf0103f54
f0100e53:	e8 c9 28 00 00       	call   f0103721 <strchr>
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
f0100e71:	bb 40 45 10 f0       	mov    $0xf0104540,%ebx
f0100e76:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e7b:	83 ec 08             	sub    $0x8,%esp
f0100e7e:	ff 33                	pushl  (%ebx)
f0100e80:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e83:	e8 2b 28 00 00       	call   f01036b3 <strcmp>
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
f0100e9d:	ff 97 48 45 10 f0    	call   *-0xfefbab8(%edi)


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
f0100ebe:	68 76 3f 10 f0       	push   $0xf0103f76
f0100ec3:	e8 79 1d 00 00       	call   f0102c41 <cprintf>
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
f0100f34:	68 94 45 10 f0       	push   $0xf0104594
f0100f39:	68 c4 02 00 00       	push   $0x2c4
f0100f3e:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f0100f7c:	e8 5f 1c 00 00       	call   f0102be0 <mc146818_read>
f0100f81:	89 c6                	mov    %eax,%esi
f0100f83:	43                   	inc    %ebx
f0100f84:	89 1c 24             	mov    %ebx,(%esp)
f0100f87:	e8 54 1c 00 00       	call   f0102be0 <mc146818_read>
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
f0100fb9:	68 b8 45 10 f0       	push   $0xf01045b8
f0100fbe:	68 07 02 00 00       	push   $0x207
f0100fc3:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f0101046:	68 94 45 10 f0       	push   $0xf0104594
f010104b:	6a 52                	push   $0x52
f010104d:	68 98 4c 10 f0       	push   $0xf0104c98
f0101052:	e8 34 f0 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101057:	83 ec 04             	sub    $0x4,%esp
f010105a:	68 80 00 00 00       	push   $0x80
f010105f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101064:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101069:	50                   	push   %eax
f010106a:	e8 02 27 00 00       	call   f0103771 <memset>
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
f01010e0:	68 a6 4c 10 f0       	push   $0xf0104ca6
f01010e5:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01010ea:	68 21 02 00 00       	push   $0x221
f01010ef:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01010f4:	e8 92 ef ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f01010f9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010fc:	72 19                	jb     f0101117 <check_page_free_list+0x17f>
f01010fe:	68 c7 4c 10 f0       	push   $0xf0104cc7
f0101103:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101108:	68 22 02 00 00       	push   $0x222
f010110d:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101112:	e8 74 ef ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101117:	89 d0                	mov    %edx,%eax
f0101119:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010111c:	a8 07                	test   $0x7,%al
f010111e:	74 19                	je     f0101139 <check_page_free_list+0x1a1>
f0101120:	68 dc 45 10 f0       	push   $0xf01045dc
f0101125:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010112a:	68 23 02 00 00       	push   $0x223
f010112f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101134:	e8 52 ef ff ff       	call   f010008b <_panic>
f0101139:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010113c:	c1 e0 0c             	shl    $0xc,%eax
f010113f:	75 19                	jne    f010115a <check_page_free_list+0x1c2>
f0101141:	68 db 4c 10 f0       	push   $0xf0104cdb
f0101146:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010114b:	68 26 02 00 00       	push   $0x226
f0101150:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101155:	e8 31 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010115a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010115f:	75 19                	jne    f010117a <check_page_free_list+0x1e2>
f0101161:	68 ec 4c 10 f0       	push   $0xf0104cec
f0101166:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010116b:	68 27 02 00 00       	push   $0x227
f0101170:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101175:	e8 11 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010117a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010117f:	75 19                	jne    f010119a <check_page_free_list+0x202>
f0101181:	68 10 46 10 f0       	push   $0xf0104610
f0101186:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010118b:	68 28 02 00 00       	push   $0x228
f0101190:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101195:	e8 f1 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010119a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010119f:	75 19                	jne    f01011ba <check_page_free_list+0x222>
f01011a1:	68 05 4d 10 f0       	push   $0xf0104d05
f01011a6:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01011ab:	68 29 02 00 00       	push   $0x229
f01011b0:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f01011cc:	68 94 45 10 f0       	push   $0xf0104594
f01011d1:	6a 52                	push   $0x52
f01011d3:	68 98 4c 10 f0       	push   $0xf0104c98
f01011d8:	e8 ae ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01011dd:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01011e3:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01011e6:	76 1c                	jbe    f0101204 <check_page_free_list+0x26c>
f01011e8:	68 34 46 10 f0       	push   $0xf0104634
f01011ed:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01011f2:	68 2a 02 00 00       	push   $0x22a
f01011f7:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f0101213:	68 1f 4d 10 f0       	push   $0xf0104d1f
f0101218:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010121d:	68 32 02 00 00       	push   $0x232
f0101222:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101227:	e8 5f ee ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f010122c:	85 f6                	test   %esi,%esi
f010122e:	7f 19                	jg     f0101249 <check_page_free_list+0x2b1>
f0101230:	68 31 4d 10 f0       	push   $0xf0104d31
f0101235:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010123a:	68 33 02 00 00       	push   $0x233
f010123f:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f0101272:	68 d8 43 10 f0       	push   $0xf01043d8
f0101277:	68 10 01 00 00       	push   $0x110
f010127c:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f0101349:	68 94 45 10 f0       	push   $0xf0104594
f010134e:	6a 52                	push   $0x52
f0101350:	68 98 4c 10 f0       	push   $0xf0104c98
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
f010136a:	e8 02 24 00 00       	call   f0103771 <memset>
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
f0101424:	68 94 45 10 f0       	push   $0xf0104594
f0101429:	68 73 01 00 00       	push   $0x173
f010142e:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
f01014e7:	68 7c 46 10 f0       	push   $0xf010467c
f01014ec:	6a 4b                	push   $0x4b
f01014ee:	68 98 4c 10 f0       	push   $0xf0104c98
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
f0101659:	68 9c 46 10 f0       	push   $0xf010469c
f010165e:	e8 de 15 00 00       	call   f0102c41 <cprintf>
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
f010167d:	e8 ef 20 00 00       	call   f0103771 <memset>
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
f0101692:	68 d8 43 10 f0       	push   $0xf01043d8
f0101697:	68 8d 00 00 00       	push   $0x8d
f010169c:	68 8c 4c 10 f0       	push   $0xf0104c8c
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
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01016c7:	e8 85 fb ff ff       	call   f0101251 <page_init>

	check_page_free_list(1);
f01016cc:	b8 01 00 00 00       	mov    $0x1,%eax
f01016d1:	e8 c2 f8 ff ff       	call   f0100f98 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01016d6:	83 3d 4c e9 11 f0 00 	cmpl   $0x0,0xf011e94c
f01016dd:	75 17                	jne    f01016f6 <mem_init+0x121>
		panic("'pages' is a null pointer!");
f01016df:	83 ec 04             	sub    $0x4,%esp
f01016e2:	68 42 4d 10 f0       	push   $0xf0104d42
f01016e7:	68 44 02 00 00       	push   $0x244
f01016ec:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01016f1:	e8 95 e9 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016f6:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f01016fb:	85 c0                	test   %eax,%eax
f01016fd:	74 0e                	je     f010170d <mem_init+0x138>
f01016ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101704:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101705:	8b 00                	mov    (%eax),%eax
f0101707:	85 c0                	test   %eax,%eax
f0101709:	75 f9                	jne    f0101704 <mem_init+0x12f>
f010170b:	eb 05                	jmp    f0101712 <mem_init+0x13d>
f010170d:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101712:	83 ec 0c             	sub    $0xc,%esp
f0101715:	6a 00                	push   $0x0
f0101717:	e8 e2 fb ff ff       	call   f01012fe <page_alloc>
f010171c:	89 c6                	mov    %eax,%esi
f010171e:	83 c4 10             	add    $0x10,%esp
f0101721:	85 c0                	test   %eax,%eax
f0101723:	75 19                	jne    f010173e <mem_init+0x169>
f0101725:	68 5d 4d 10 f0       	push   $0xf0104d5d
f010172a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010172f:	68 4c 02 00 00       	push   $0x24c
f0101734:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101739:	e8 4d e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010173e:	83 ec 0c             	sub    $0xc,%esp
f0101741:	6a 00                	push   $0x0
f0101743:	e8 b6 fb ff ff       	call   f01012fe <page_alloc>
f0101748:	89 c7                	mov    %eax,%edi
f010174a:	83 c4 10             	add    $0x10,%esp
f010174d:	85 c0                	test   %eax,%eax
f010174f:	75 19                	jne    f010176a <mem_init+0x195>
f0101751:	68 73 4d 10 f0       	push   $0xf0104d73
f0101756:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010175b:	68 4d 02 00 00       	push   $0x24d
f0101760:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101765:	e8 21 e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010176a:	83 ec 0c             	sub    $0xc,%esp
f010176d:	6a 00                	push   $0x0
f010176f:	e8 8a fb ff ff       	call   f01012fe <page_alloc>
f0101774:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101777:	83 c4 10             	add    $0x10,%esp
f010177a:	85 c0                	test   %eax,%eax
f010177c:	75 19                	jne    f0101797 <mem_init+0x1c2>
f010177e:	68 89 4d 10 f0       	push   $0xf0104d89
f0101783:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101788:	68 4e 02 00 00       	push   $0x24e
f010178d:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101792:	e8 f4 e8 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101797:	39 fe                	cmp    %edi,%esi
f0101799:	75 19                	jne    f01017b4 <mem_init+0x1df>
f010179b:	68 9f 4d 10 f0       	push   $0xf0104d9f
f01017a0:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01017a5:	68 51 02 00 00       	push   $0x251
f01017aa:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01017af:	e8 d7 e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017b7:	74 05                	je     f01017be <mem_init+0x1e9>
f01017b9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017bc:	75 19                	jne    f01017d7 <mem_init+0x202>
f01017be:	68 d8 46 10 f0       	push   $0xf01046d8
f01017c3:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01017c8:	68 52 02 00 00       	push   $0x252
f01017cd:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01017d2:	e8 b4 e8 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d7:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017dd:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01017e2:	c1 e0 0c             	shl    $0xc,%eax
f01017e5:	89 f1                	mov    %esi,%ecx
f01017e7:	29 d1                	sub    %edx,%ecx
f01017e9:	c1 f9 03             	sar    $0x3,%ecx
f01017ec:	c1 e1 0c             	shl    $0xc,%ecx
f01017ef:	39 c1                	cmp    %eax,%ecx
f01017f1:	72 19                	jb     f010180c <mem_init+0x237>
f01017f3:	68 b1 4d 10 f0       	push   $0xf0104db1
f01017f8:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01017fd:	68 53 02 00 00       	push   $0x253
f0101802:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101807:	e8 7f e8 ff ff       	call   f010008b <_panic>
f010180c:	89 f9                	mov    %edi,%ecx
f010180e:	29 d1                	sub    %edx,%ecx
f0101810:	c1 f9 03             	sar    $0x3,%ecx
f0101813:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101816:	39 c8                	cmp    %ecx,%eax
f0101818:	77 19                	ja     f0101833 <mem_init+0x25e>
f010181a:	68 ce 4d 10 f0       	push   $0xf0104dce
f010181f:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101824:	68 54 02 00 00       	push   $0x254
f0101829:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010182e:	e8 58 e8 ff ff       	call   f010008b <_panic>
f0101833:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101836:	29 d1                	sub    %edx,%ecx
f0101838:	89 ca                	mov    %ecx,%edx
f010183a:	c1 fa 03             	sar    $0x3,%edx
f010183d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101840:	39 d0                	cmp    %edx,%eax
f0101842:	77 19                	ja     f010185d <mem_init+0x288>
f0101844:	68 eb 4d 10 f0       	push   $0xf0104deb
f0101849:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010184e:	68 55 02 00 00       	push   $0x255
f0101853:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101858:	e8 2e e8 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010185d:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f0101862:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101865:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f010186c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010186f:	83 ec 0c             	sub    $0xc,%esp
f0101872:	6a 00                	push   $0x0
f0101874:	e8 85 fa ff ff       	call   f01012fe <page_alloc>
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	85 c0                	test   %eax,%eax
f010187e:	74 19                	je     f0101899 <mem_init+0x2c4>
f0101880:	68 08 4e 10 f0       	push   $0xf0104e08
f0101885:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010188a:	68 5c 02 00 00       	push   $0x25c
f010188f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101894:	e8 f2 e7 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101899:	83 ec 0c             	sub    $0xc,%esp
f010189c:	56                   	push   %esi
f010189d:	e8 e6 fa ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f01018a2:	89 3c 24             	mov    %edi,(%esp)
f01018a5:	e8 de fa ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f01018aa:	83 c4 04             	add    $0x4,%esp
f01018ad:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018b0:	e8 d3 fa ff ff       	call   f0101388 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018bc:	e8 3d fa ff ff       	call   f01012fe <page_alloc>
f01018c1:	89 c6                	mov    %eax,%esi
f01018c3:	83 c4 10             	add    $0x10,%esp
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	75 19                	jne    f01018e3 <mem_init+0x30e>
f01018ca:	68 5d 4d 10 f0       	push   $0xf0104d5d
f01018cf:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01018d4:	68 63 02 00 00       	push   $0x263
f01018d9:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01018de:	e8 a8 e7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01018e3:	83 ec 0c             	sub    $0xc,%esp
f01018e6:	6a 00                	push   $0x0
f01018e8:	e8 11 fa ff ff       	call   f01012fe <page_alloc>
f01018ed:	89 c7                	mov    %eax,%edi
f01018ef:	83 c4 10             	add    $0x10,%esp
f01018f2:	85 c0                	test   %eax,%eax
f01018f4:	75 19                	jne    f010190f <mem_init+0x33a>
f01018f6:	68 73 4d 10 f0       	push   $0xf0104d73
f01018fb:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101900:	68 64 02 00 00       	push   $0x264
f0101905:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010190a:	e8 7c e7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010190f:	83 ec 0c             	sub    $0xc,%esp
f0101912:	6a 00                	push   $0x0
f0101914:	e8 e5 f9 ff ff       	call   f01012fe <page_alloc>
f0101919:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010191c:	83 c4 10             	add    $0x10,%esp
f010191f:	85 c0                	test   %eax,%eax
f0101921:	75 19                	jne    f010193c <mem_init+0x367>
f0101923:	68 89 4d 10 f0       	push   $0xf0104d89
f0101928:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010192d:	68 65 02 00 00       	push   $0x265
f0101932:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101937:	e8 4f e7 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010193c:	39 fe                	cmp    %edi,%esi
f010193e:	75 19                	jne    f0101959 <mem_init+0x384>
f0101940:	68 9f 4d 10 f0       	push   $0xf0104d9f
f0101945:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010194a:	68 67 02 00 00       	push   $0x267
f010194f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101954:	e8 32 e7 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101959:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010195c:	74 05                	je     f0101963 <mem_init+0x38e>
f010195e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101961:	75 19                	jne    f010197c <mem_init+0x3a7>
f0101963:	68 d8 46 10 f0       	push   $0xf01046d8
f0101968:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010196d:	68 68 02 00 00       	push   $0x268
f0101972:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101977:	e8 0f e7 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010197c:	83 ec 0c             	sub    $0xc,%esp
f010197f:	6a 00                	push   $0x0
f0101981:	e8 78 f9 ff ff       	call   f01012fe <page_alloc>
f0101986:	83 c4 10             	add    $0x10,%esp
f0101989:	85 c0                	test   %eax,%eax
f010198b:	74 19                	je     f01019a6 <mem_init+0x3d1>
f010198d:	68 08 4e 10 f0       	push   $0xf0104e08
f0101992:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101997:	68 69 02 00 00       	push   $0x269
f010199c:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01019a1:	e8 e5 e6 ff ff       	call   f010008b <_panic>
f01019a6:	89 f0                	mov    %esi,%eax
f01019a8:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01019ae:	c1 f8 03             	sar    $0x3,%eax
f01019b1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019b4:	89 c2                	mov    %eax,%edx
f01019b6:	c1 ea 0c             	shr    $0xc,%edx
f01019b9:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01019bf:	72 12                	jb     f01019d3 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019c1:	50                   	push   %eax
f01019c2:	68 94 45 10 f0       	push   $0xf0104594
f01019c7:	6a 52                	push   $0x52
f01019c9:	68 98 4c 10 f0       	push   $0xf0104c98
f01019ce:	e8 b8 e6 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01019d3:	83 ec 04             	sub    $0x4,%esp
f01019d6:	68 00 10 00 00       	push   $0x1000
f01019db:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01019dd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019e2:	50                   	push   %eax
f01019e3:	e8 89 1d 00 00       	call   f0103771 <memset>
	page_free(pp0);
f01019e8:	89 34 24             	mov    %esi,(%esp)
f01019eb:	e8 98 f9 ff ff       	call   f0101388 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019f7:	e8 02 f9 ff ff       	call   f01012fe <page_alloc>
f01019fc:	83 c4 10             	add    $0x10,%esp
f01019ff:	85 c0                	test   %eax,%eax
f0101a01:	75 19                	jne    f0101a1c <mem_init+0x447>
f0101a03:	68 17 4e 10 f0       	push   $0xf0104e17
f0101a08:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101a0d:	68 6e 02 00 00       	push   $0x26e
f0101a12:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101a17:	e8 6f e6 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101a1c:	39 c6                	cmp    %eax,%esi
f0101a1e:	74 19                	je     f0101a39 <mem_init+0x464>
f0101a20:	68 35 4e 10 f0       	push   $0xf0104e35
f0101a25:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101a2a:	68 6f 02 00 00       	push   $0x26f
f0101a2f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101a34:	e8 52 e6 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a39:	89 f2                	mov    %esi,%edx
f0101a3b:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101a41:	c1 fa 03             	sar    $0x3,%edx
f0101a44:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a47:	89 d0                	mov    %edx,%eax
f0101a49:	c1 e8 0c             	shr    $0xc,%eax
f0101a4c:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0101a52:	72 12                	jb     f0101a66 <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a54:	52                   	push   %edx
f0101a55:	68 94 45 10 f0       	push   $0xf0104594
f0101a5a:	6a 52                	push   $0x52
f0101a5c:	68 98 4c 10 f0       	push   $0xf0104c98
f0101a61:	e8 25 e6 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a66:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101a6d:	75 11                	jne    f0101a80 <mem_init+0x4ab>
f0101a6f:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a75:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a7b:	80 38 00             	cmpb   $0x0,(%eax)
f0101a7e:	74 19                	je     f0101a99 <mem_init+0x4c4>
f0101a80:	68 45 4e 10 f0       	push   $0xf0104e45
f0101a85:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101a8a:	68 72 02 00 00       	push   $0x272
f0101a8f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101a94:	e8 f2 e5 ff ff       	call   f010008b <_panic>
f0101a99:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a9a:	39 d0                	cmp    %edx,%eax
f0101a9c:	75 dd                	jne    f0101a7b <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a9e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101aa1:	89 15 2c e5 11 f0    	mov    %edx,0xf011e52c

	// free the pages we took
	page_free(pp0);
f0101aa7:	83 ec 0c             	sub    $0xc,%esp
f0101aaa:	56                   	push   %esi
f0101aab:	e8 d8 f8 ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f0101ab0:	89 3c 24             	mov    %edi,(%esp)
f0101ab3:	e8 d0 f8 ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f0101ab8:	83 c4 04             	add    $0x4,%esp
f0101abb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101abe:	e8 c5 f8 ff ff       	call   f0101388 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ac3:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f0101ac8:	83 c4 10             	add    $0x10,%esp
f0101acb:	85 c0                	test   %eax,%eax
f0101acd:	74 07                	je     f0101ad6 <mem_init+0x501>
		--nfree;
f0101acf:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ad0:	8b 00                	mov    (%eax),%eax
f0101ad2:	85 c0                	test   %eax,%eax
f0101ad4:	75 f9                	jne    f0101acf <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101ad6:	85 db                	test   %ebx,%ebx
f0101ad8:	74 19                	je     f0101af3 <mem_init+0x51e>
f0101ada:	68 4f 4e 10 f0       	push   $0xf0104e4f
f0101adf:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101ae4:	68 7f 02 00 00       	push   $0x27f
f0101ae9:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101aee:	e8 98 e5 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101af3:	83 ec 0c             	sub    $0xc,%esp
f0101af6:	68 f8 46 10 f0       	push   $0xf01046f8
f0101afb:	e8 41 11 00 00       	call   f0102c41 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b07:	e8 f2 f7 ff ff       	call   f01012fe <page_alloc>
f0101b0c:	89 c6                	mov    %eax,%esi
f0101b0e:	83 c4 10             	add    $0x10,%esp
f0101b11:	85 c0                	test   %eax,%eax
f0101b13:	75 19                	jne    f0101b2e <mem_init+0x559>
f0101b15:	68 5d 4d 10 f0       	push   $0xf0104d5d
f0101b1a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101b1f:	68 d8 02 00 00       	push   $0x2d8
f0101b24:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101b29:	e8 5d e5 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101b2e:	83 ec 0c             	sub    $0xc,%esp
f0101b31:	6a 00                	push   $0x0
f0101b33:	e8 c6 f7 ff ff       	call   f01012fe <page_alloc>
f0101b38:	89 c7                	mov    %eax,%edi
f0101b3a:	83 c4 10             	add    $0x10,%esp
f0101b3d:	85 c0                	test   %eax,%eax
f0101b3f:	75 19                	jne    f0101b5a <mem_init+0x585>
f0101b41:	68 73 4d 10 f0       	push   $0xf0104d73
f0101b46:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101b4b:	68 d9 02 00 00       	push   $0x2d9
f0101b50:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101b55:	e8 31 e5 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101b5a:	83 ec 0c             	sub    $0xc,%esp
f0101b5d:	6a 00                	push   $0x0
f0101b5f:	e8 9a f7 ff ff       	call   f01012fe <page_alloc>
f0101b64:	89 c3                	mov    %eax,%ebx
f0101b66:	83 c4 10             	add    $0x10,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	75 19                	jne    f0101b86 <mem_init+0x5b1>
f0101b6d:	68 89 4d 10 f0       	push   $0xf0104d89
f0101b72:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101b77:	68 da 02 00 00       	push   $0x2da
f0101b7c:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101b81:	e8 05 e5 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b86:	39 fe                	cmp    %edi,%esi
f0101b88:	75 19                	jne    f0101ba3 <mem_init+0x5ce>
f0101b8a:	68 9f 4d 10 f0       	push   $0xf0104d9f
f0101b8f:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101b94:	68 dd 02 00 00       	push   $0x2dd
f0101b99:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101b9e:	e8 e8 e4 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ba3:	39 c7                	cmp    %eax,%edi
f0101ba5:	74 04                	je     f0101bab <mem_init+0x5d6>
f0101ba7:	39 c6                	cmp    %eax,%esi
f0101ba9:	75 19                	jne    f0101bc4 <mem_init+0x5ef>
f0101bab:	68 d8 46 10 f0       	push   $0xf01046d8
f0101bb0:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101bb5:	68 de 02 00 00       	push   $0x2de
f0101bba:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101bbf:	e8 c7 e4 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bc4:	8b 0d 2c e5 11 f0    	mov    0xf011e52c,%ecx
f0101bca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101bcd:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f0101bd4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bd7:	83 ec 0c             	sub    $0xc,%esp
f0101bda:	6a 00                	push   $0x0
f0101bdc:	e8 1d f7 ff ff       	call   f01012fe <page_alloc>
f0101be1:	83 c4 10             	add    $0x10,%esp
f0101be4:	85 c0                	test   %eax,%eax
f0101be6:	74 19                	je     f0101c01 <mem_init+0x62c>
f0101be8:	68 08 4e 10 f0       	push   $0xf0104e08
f0101bed:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101bf2:	68 e5 02 00 00       	push   $0x2e5
f0101bf7:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101bfc:	e8 8a e4 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c01:	83 ec 04             	sub    $0x4,%esp
f0101c04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c07:	50                   	push   %eax
f0101c08:	6a 00                	push   $0x0
f0101c0a:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c10:	e8 99 f8 ff ff       	call   f01014ae <page_lookup>
f0101c15:	83 c4 10             	add    $0x10,%esp
f0101c18:	85 c0                	test   %eax,%eax
f0101c1a:	74 19                	je     f0101c35 <mem_init+0x660>
f0101c1c:	68 18 47 10 f0       	push   $0xf0104718
f0101c21:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101c26:	68 e8 02 00 00       	push   $0x2e8
f0101c2b:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101c30:	e8 56 e4 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c35:	6a 02                	push   $0x2
f0101c37:	6a 00                	push   $0x0
f0101c39:	57                   	push   %edi
f0101c3a:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c40:	e8 27 f9 ff ff       	call   f010156c <page_insert>
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	78 19                	js     f0101c65 <mem_init+0x690>
f0101c4c:	68 50 47 10 f0       	push   $0xf0104750
f0101c51:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101c56:	68 eb 02 00 00       	push   $0x2eb
f0101c5b:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101c60:	e8 26 e4 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c65:	83 ec 0c             	sub    $0xc,%esp
f0101c68:	56                   	push   %esi
f0101c69:	e8 1a f7 ff ff       	call   f0101388 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c6e:	6a 02                	push   $0x2
f0101c70:	6a 00                	push   $0x0
f0101c72:	57                   	push   %edi
f0101c73:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c79:	e8 ee f8 ff ff       	call   f010156c <page_insert>
f0101c7e:	83 c4 20             	add    $0x20,%esp
f0101c81:	85 c0                	test   %eax,%eax
f0101c83:	74 19                	je     f0101c9e <mem_init+0x6c9>
f0101c85:	68 80 47 10 f0       	push   $0xf0104780
f0101c8a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101c8f:	68 ef 02 00 00       	push   $0x2ef
f0101c94:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101c99:	e8 ed e3 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c9e:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101ca3:	8b 08                	mov    (%eax),%ecx
f0101ca5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cab:	89 f2                	mov    %esi,%edx
f0101cad:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101cb3:	c1 fa 03             	sar    $0x3,%edx
f0101cb6:	c1 e2 0c             	shl    $0xc,%edx
f0101cb9:	39 d1                	cmp    %edx,%ecx
f0101cbb:	74 19                	je     f0101cd6 <mem_init+0x701>
f0101cbd:	68 b0 47 10 f0       	push   $0xf01047b0
f0101cc2:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101cc7:	68 f0 02 00 00       	push   $0x2f0
f0101ccc:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101cd1:	e8 b5 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cd6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cdb:	e8 2f f2 ff ff       	call   f0100f0f <check_va2pa>
f0101ce0:	89 fa                	mov    %edi,%edx
f0101ce2:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101ce8:	c1 fa 03             	sar    $0x3,%edx
f0101ceb:	c1 e2 0c             	shl    $0xc,%edx
f0101cee:	39 d0                	cmp    %edx,%eax
f0101cf0:	74 19                	je     f0101d0b <mem_init+0x736>
f0101cf2:	68 d8 47 10 f0       	push   $0xf01047d8
f0101cf7:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101cfc:	68 f1 02 00 00       	push   $0x2f1
f0101d01:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101d06:	e8 80 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d0b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d10:	74 19                	je     f0101d2b <mem_init+0x756>
f0101d12:	68 5a 4e 10 f0       	push   $0xf0104e5a
f0101d17:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101d1c:	68 f2 02 00 00       	push   $0x2f2
f0101d21:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101d26:	e8 60 e3 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101d2b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d30:	74 19                	je     f0101d4b <mem_init+0x776>
f0101d32:	68 6b 4e 10 f0       	push   $0xf0104e6b
f0101d37:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101d3c:	68 f3 02 00 00       	push   $0x2f3
f0101d41:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101d46:	e8 40 e3 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d4b:	6a 02                	push   $0x2
f0101d4d:	68 00 10 00 00       	push   $0x1000
f0101d52:	53                   	push   %ebx
f0101d53:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101d59:	e8 0e f8 ff ff       	call   f010156c <page_insert>
f0101d5e:	83 c4 10             	add    $0x10,%esp
f0101d61:	85 c0                	test   %eax,%eax
f0101d63:	74 19                	je     f0101d7e <mem_init+0x7a9>
f0101d65:	68 08 48 10 f0       	push   $0xf0104808
f0101d6a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101d6f:	68 f6 02 00 00       	push   $0x2f6
f0101d74:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101d79:	e8 0d e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d7e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d83:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101d88:	e8 82 f1 ff ff       	call   f0100f0f <check_va2pa>
f0101d8d:	89 da                	mov    %ebx,%edx
f0101d8f:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101d95:	c1 fa 03             	sar    $0x3,%edx
f0101d98:	c1 e2 0c             	shl    $0xc,%edx
f0101d9b:	39 d0                	cmp    %edx,%eax
f0101d9d:	74 19                	je     f0101db8 <mem_init+0x7e3>
f0101d9f:	68 44 48 10 f0       	push   $0xf0104844
f0101da4:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101da9:	68 f7 02 00 00       	push   $0x2f7
f0101dae:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101db3:	e8 d3 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101db8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dbd:	74 19                	je     f0101dd8 <mem_init+0x803>
f0101dbf:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0101dc4:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101dc9:	68 f8 02 00 00       	push   $0x2f8
f0101dce:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101dd3:	e8 b3 e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101dd8:	83 ec 0c             	sub    $0xc,%esp
f0101ddb:	6a 00                	push   $0x0
f0101ddd:	e8 1c f5 ff ff       	call   f01012fe <page_alloc>
f0101de2:	83 c4 10             	add    $0x10,%esp
f0101de5:	85 c0                	test   %eax,%eax
f0101de7:	74 19                	je     f0101e02 <mem_init+0x82d>
f0101de9:	68 08 4e 10 f0       	push   $0xf0104e08
f0101dee:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101df3:	68 fb 02 00 00       	push   $0x2fb
f0101df8:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101dfd:	e8 89 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e02:	6a 02                	push   $0x2
f0101e04:	68 00 10 00 00       	push   $0x1000
f0101e09:	53                   	push   %ebx
f0101e0a:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101e10:	e8 57 f7 ff ff       	call   f010156c <page_insert>
f0101e15:	83 c4 10             	add    $0x10,%esp
f0101e18:	85 c0                	test   %eax,%eax
f0101e1a:	74 19                	je     f0101e35 <mem_init+0x860>
f0101e1c:	68 08 48 10 f0       	push   $0xf0104808
f0101e21:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101e26:	68 fe 02 00 00       	push   $0x2fe
f0101e2b:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101e30:	e8 56 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e35:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e3a:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101e3f:	e8 cb f0 ff ff       	call   f0100f0f <check_va2pa>
f0101e44:	89 da                	mov    %ebx,%edx
f0101e46:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101e4c:	c1 fa 03             	sar    $0x3,%edx
f0101e4f:	c1 e2 0c             	shl    $0xc,%edx
f0101e52:	39 d0                	cmp    %edx,%eax
f0101e54:	74 19                	je     f0101e6f <mem_init+0x89a>
f0101e56:	68 44 48 10 f0       	push   $0xf0104844
f0101e5b:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101e60:	68 ff 02 00 00       	push   $0x2ff
f0101e65:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101e6a:	e8 1c e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e6f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e74:	74 19                	je     f0101e8f <mem_init+0x8ba>
f0101e76:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0101e7b:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101e80:	68 00 03 00 00       	push   $0x300
f0101e85:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101e8a:	e8 fc e1 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e8f:	83 ec 0c             	sub    $0xc,%esp
f0101e92:	6a 00                	push   $0x0
f0101e94:	e8 65 f4 ff ff       	call   f01012fe <page_alloc>
f0101e99:	83 c4 10             	add    $0x10,%esp
f0101e9c:	85 c0                	test   %eax,%eax
f0101e9e:	74 19                	je     f0101eb9 <mem_init+0x8e4>
f0101ea0:	68 08 4e 10 f0       	push   $0xf0104e08
f0101ea5:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101eaa:	68 04 03 00 00       	push   $0x304
f0101eaf:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101eb4:	e8 d2 e1 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101eb9:	8b 15 48 e9 11 f0    	mov    0xf011e948,%edx
f0101ebf:	8b 02                	mov    (%edx),%eax
f0101ec1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ec6:	89 c1                	mov    %eax,%ecx
f0101ec8:	c1 e9 0c             	shr    $0xc,%ecx
f0101ecb:	3b 0d 44 e9 11 f0    	cmp    0xf011e944,%ecx
f0101ed1:	72 15                	jb     f0101ee8 <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ed3:	50                   	push   %eax
f0101ed4:	68 94 45 10 f0       	push   $0xf0104594
f0101ed9:	68 07 03 00 00       	push   $0x307
f0101ede:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101ee3:	e8 a3 e1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101ee8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101eed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ef0:	83 ec 04             	sub    $0x4,%esp
f0101ef3:	6a 00                	push   $0x0
f0101ef5:	68 00 10 00 00       	push   $0x1000
f0101efa:	52                   	push   %edx
f0101efb:	e8 c6 f4 ff ff       	call   f01013c6 <pgdir_walk>
f0101f00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f03:	83 c2 04             	add    $0x4,%edx
f0101f06:	83 c4 10             	add    $0x10,%esp
f0101f09:	39 d0                	cmp    %edx,%eax
f0101f0b:	74 19                	je     f0101f26 <mem_init+0x951>
f0101f0d:	68 74 48 10 f0       	push   $0xf0104874
f0101f12:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101f17:	68 08 03 00 00       	push   $0x308
f0101f1c:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101f21:	e8 65 e1 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f26:	6a 06                	push   $0x6
f0101f28:	68 00 10 00 00       	push   $0x1000
f0101f2d:	53                   	push   %ebx
f0101f2e:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101f34:	e8 33 f6 ff ff       	call   f010156c <page_insert>
f0101f39:	83 c4 10             	add    $0x10,%esp
f0101f3c:	85 c0                	test   %eax,%eax
f0101f3e:	74 19                	je     f0101f59 <mem_init+0x984>
f0101f40:	68 b4 48 10 f0       	push   $0xf01048b4
f0101f45:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101f4a:	68 0b 03 00 00       	push   $0x30b
f0101f4f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101f54:	e8 32 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f59:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f5e:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101f63:	e8 a7 ef ff ff       	call   f0100f0f <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f68:	89 da                	mov    %ebx,%edx
f0101f6a:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101f70:	c1 fa 03             	sar    $0x3,%edx
f0101f73:	c1 e2 0c             	shl    $0xc,%edx
f0101f76:	39 d0                	cmp    %edx,%eax
f0101f78:	74 19                	je     f0101f93 <mem_init+0x9be>
f0101f7a:	68 44 48 10 f0       	push   $0xf0104844
f0101f7f:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101f84:	68 0c 03 00 00       	push   $0x30c
f0101f89:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101f8e:	e8 f8 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101f93:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f98:	74 19                	je     f0101fb3 <mem_init+0x9de>
f0101f9a:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0101f9f:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101fa4:	68 0d 03 00 00       	push   $0x30d
f0101fa9:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101fae:	e8 d8 e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fb3:	83 ec 04             	sub    $0x4,%esp
f0101fb6:	6a 00                	push   $0x0
f0101fb8:	68 00 10 00 00       	push   $0x1000
f0101fbd:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101fc3:	e8 fe f3 ff ff       	call   f01013c6 <pgdir_walk>
f0101fc8:	83 c4 10             	add    $0x10,%esp
f0101fcb:	f6 00 04             	testb  $0x4,(%eax)
f0101fce:	75 19                	jne    f0101fe9 <mem_init+0xa14>
f0101fd0:	68 f4 48 10 f0       	push   $0xf01048f4
f0101fd5:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101fda:	68 0e 03 00 00       	push   $0x30e
f0101fdf:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101fe4:	e8 a2 e0 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fe9:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101fee:	f6 00 04             	testb  $0x4,(%eax)
f0101ff1:	75 19                	jne    f010200c <mem_init+0xa37>
f0101ff3:	68 8d 4e 10 f0       	push   $0xf0104e8d
f0101ff8:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0101ffd:	68 0f 03 00 00       	push   $0x30f
f0102002:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102007:	e8 7f e0 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010200c:	6a 02                	push   $0x2
f010200e:	68 00 10 00 00       	push   $0x1000
f0102013:	53                   	push   %ebx
f0102014:	50                   	push   %eax
f0102015:	e8 52 f5 ff ff       	call   f010156c <page_insert>
f010201a:	83 c4 10             	add    $0x10,%esp
f010201d:	85 c0                	test   %eax,%eax
f010201f:	74 19                	je     f010203a <mem_init+0xa65>
f0102021:	68 08 48 10 f0       	push   $0xf0104808
f0102026:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010202b:	68 12 03 00 00       	push   $0x312
f0102030:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102035:	e8 51 e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010203a:	83 ec 04             	sub    $0x4,%esp
f010203d:	6a 00                	push   $0x0
f010203f:	68 00 10 00 00       	push   $0x1000
f0102044:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010204a:	e8 77 f3 ff ff       	call   f01013c6 <pgdir_walk>
f010204f:	83 c4 10             	add    $0x10,%esp
f0102052:	f6 00 02             	testb  $0x2,(%eax)
f0102055:	75 19                	jne    f0102070 <mem_init+0xa9b>
f0102057:	68 28 49 10 f0       	push   $0xf0104928
f010205c:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102061:	68 13 03 00 00       	push   $0x313
f0102066:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010206b:	e8 1b e0 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102070:	83 ec 04             	sub    $0x4,%esp
f0102073:	6a 00                	push   $0x0
f0102075:	68 00 10 00 00       	push   $0x1000
f010207a:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102080:	e8 41 f3 ff ff       	call   f01013c6 <pgdir_walk>
f0102085:	83 c4 10             	add    $0x10,%esp
f0102088:	f6 00 04             	testb  $0x4,(%eax)
f010208b:	74 19                	je     f01020a6 <mem_init+0xad1>
f010208d:	68 5c 49 10 f0       	push   $0xf010495c
f0102092:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102097:	68 14 03 00 00       	push   $0x314
f010209c:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01020a1:	e8 e5 df ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020a6:	6a 02                	push   $0x2
f01020a8:	68 00 00 40 00       	push   $0x400000
f01020ad:	56                   	push   %esi
f01020ae:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020b4:	e8 b3 f4 ff ff       	call   f010156c <page_insert>
f01020b9:	83 c4 10             	add    $0x10,%esp
f01020bc:	85 c0                	test   %eax,%eax
f01020be:	78 19                	js     f01020d9 <mem_init+0xb04>
f01020c0:	68 94 49 10 f0       	push   $0xf0104994
f01020c5:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01020ca:	68 17 03 00 00       	push   $0x317
f01020cf:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01020d4:	e8 b2 df ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020d9:	6a 02                	push   $0x2
f01020db:	68 00 10 00 00       	push   $0x1000
f01020e0:	57                   	push   %edi
f01020e1:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020e7:	e8 80 f4 ff ff       	call   f010156c <page_insert>
f01020ec:	83 c4 10             	add    $0x10,%esp
f01020ef:	85 c0                	test   %eax,%eax
f01020f1:	74 19                	je     f010210c <mem_init+0xb37>
f01020f3:	68 cc 49 10 f0       	push   $0xf01049cc
f01020f8:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01020fd:	68 1a 03 00 00       	push   $0x31a
f0102102:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102107:	e8 7f df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010210c:	83 ec 04             	sub    $0x4,%esp
f010210f:	6a 00                	push   $0x0
f0102111:	68 00 10 00 00       	push   $0x1000
f0102116:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010211c:	e8 a5 f2 ff ff       	call   f01013c6 <pgdir_walk>
f0102121:	83 c4 10             	add    $0x10,%esp
f0102124:	f6 00 04             	testb  $0x4,(%eax)
f0102127:	74 19                	je     f0102142 <mem_init+0xb6d>
f0102129:	68 5c 49 10 f0       	push   $0xf010495c
f010212e:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102133:	68 1b 03 00 00       	push   $0x31b
f0102138:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010213d:	e8 49 df ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102142:	ba 00 00 00 00       	mov    $0x0,%edx
f0102147:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010214c:	e8 be ed ff ff       	call   f0100f0f <check_va2pa>
f0102151:	89 fa                	mov    %edi,%edx
f0102153:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102159:	c1 fa 03             	sar    $0x3,%edx
f010215c:	c1 e2 0c             	shl    $0xc,%edx
f010215f:	39 d0                	cmp    %edx,%eax
f0102161:	74 19                	je     f010217c <mem_init+0xba7>
f0102163:	68 08 4a 10 f0       	push   $0xf0104a08
f0102168:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010216d:	68 1e 03 00 00       	push   $0x31e
f0102172:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102177:	e8 0f df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010217c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102181:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102186:	e8 84 ed ff ff       	call   f0100f0f <check_va2pa>
f010218b:	89 fa                	mov    %edi,%edx
f010218d:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102193:	c1 fa 03             	sar    $0x3,%edx
f0102196:	c1 e2 0c             	shl    $0xc,%edx
f0102199:	39 d0                	cmp    %edx,%eax
f010219b:	74 19                	je     f01021b6 <mem_init+0xbe1>
f010219d:	68 34 4a 10 f0       	push   $0xf0104a34
f01021a2:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01021a7:	68 1f 03 00 00       	push   $0x31f
f01021ac:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01021b1:	e8 d5 de ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021b6:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01021bb:	74 19                	je     f01021d6 <mem_init+0xc01>
f01021bd:	68 a3 4e 10 f0       	push   $0xf0104ea3
f01021c2:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01021c7:	68 21 03 00 00       	push   $0x321
f01021cc:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01021d1:	e8 b5 de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01021d6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021db:	74 19                	je     f01021f6 <mem_init+0xc21>
f01021dd:	68 b4 4e 10 f0       	push   $0xf0104eb4
f01021e2:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01021e7:	68 22 03 00 00       	push   $0x322
f01021ec:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01021f1:	e8 95 de ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021f6:	83 ec 0c             	sub    $0xc,%esp
f01021f9:	6a 00                	push   $0x0
f01021fb:	e8 fe f0 ff ff       	call   f01012fe <page_alloc>
f0102200:	83 c4 10             	add    $0x10,%esp
f0102203:	85 c0                	test   %eax,%eax
f0102205:	74 04                	je     f010220b <mem_init+0xc36>
f0102207:	39 c3                	cmp    %eax,%ebx
f0102209:	74 19                	je     f0102224 <mem_init+0xc4f>
f010220b:	68 64 4a 10 f0       	push   $0xf0104a64
f0102210:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102215:	68 25 03 00 00       	push   $0x325
f010221a:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010221f:	e8 67 de ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102224:	83 ec 08             	sub    $0x8,%esp
f0102227:	6a 00                	push   $0x0
f0102229:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010222f:	e8 eb f2 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102234:	ba 00 00 00 00       	mov    $0x0,%edx
f0102239:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010223e:	e8 cc ec ff ff       	call   f0100f0f <check_va2pa>
f0102243:	83 c4 10             	add    $0x10,%esp
f0102246:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102249:	74 19                	je     f0102264 <mem_init+0xc8f>
f010224b:	68 88 4a 10 f0       	push   $0xf0104a88
f0102250:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102255:	68 29 03 00 00       	push   $0x329
f010225a:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010225f:	e8 27 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102264:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102269:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010226e:	e8 9c ec ff ff       	call   f0100f0f <check_va2pa>
f0102273:	89 fa                	mov    %edi,%edx
f0102275:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010227b:	c1 fa 03             	sar    $0x3,%edx
f010227e:	c1 e2 0c             	shl    $0xc,%edx
f0102281:	39 d0                	cmp    %edx,%eax
f0102283:	74 19                	je     f010229e <mem_init+0xcc9>
f0102285:	68 34 4a 10 f0       	push   $0xf0104a34
f010228a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010228f:	68 2a 03 00 00       	push   $0x32a
f0102294:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102299:	e8 ed dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010229e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022a3:	74 19                	je     f01022be <mem_init+0xce9>
f01022a5:	68 5a 4e 10 f0       	push   $0xf0104e5a
f01022aa:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01022af:	68 2b 03 00 00       	push   $0x32b
f01022b4:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01022b9:	e8 cd dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01022be:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022c3:	74 19                	je     f01022de <mem_init+0xd09>
f01022c5:	68 b4 4e 10 f0       	push   $0xf0104eb4
f01022ca:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01022cf:	68 2c 03 00 00       	push   $0x32c
f01022d4:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01022d9:	e8 ad dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022de:	83 ec 08             	sub    $0x8,%esp
f01022e1:	68 00 10 00 00       	push   $0x1000
f01022e6:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01022ec:	e8 2e f2 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01022f6:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01022fb:	e8 0f ec ff ff       	call   f0100f0f <check_va2pa>
f0102300:	83 c4 10             	add    $0x10,%esp
f0102303:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102306:	74 19                	je     f0102321 <mem_init+0xd4c>
f0102308:	68 88 4a 10 f0       	push   $0xf0104a88
f010230d:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102312:	68 30 03 00 00       	push   $0x330
f0102317:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010231c:	e8 6a dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102321:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102326:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010232b:	e8 df eb ff ff       	call   f0100f0f <check_va2pa>
f0102330:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102333:	74 19                	je     f010234e <mem_init+0xd79>
f0102335:	68 ac 4a 10 f0       	push   $0xf0104aac
f010233a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010233f:	68 31 03 00 00       	push   $0x331
f0102344:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102349:	e8 3d dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010234e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102353:	74 19                	je     f010236e <mem_init+0xd99>
f0102355:	68 c5 4e 10 f0       	push   $0xf0104ec5
f010235a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010235f:	68 32 03 00 00       	push   $0x332
f0102364:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102369:	e8 1d dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f010236e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102373:	74 19                	je     f010238e <mem_init+0xdb9>
f0102375:	68 b4 4e 10 f0       	push   $0xf0104eb4
f010237a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010237f:	68 33 03 00 00       	push   $0x333
f0102384:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102389:	e8 fd dc ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010238e:	83 ec 0c             	sub    $0xc,%esp
f0102391:	6a 00                	push   $0x0
f0102393:	e8 66 ef ff ff       	call   f01012fe <page_alloc>
f0102398:	83 c4 10             	add    $0x10,%esp
f010239b:	85 c0                	test   %eax,%eax
f010239d:	74 04                	je     f01023a3 <mem_init+0xdce>
f010239f:	39 c7                	cmp    %eax,%edi
f01023a1:	74 19                	je     f01023bc <mem_init+0xde7>
f01023a3:	68 d4 4a 10 f0       	push   $0xf0104ad4
f01023a8:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01023ad:	68 36 03 00 00       	push   $0x336
f01023b2:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01023b7:	e8 cf dc ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023bc:	83 ec 0c             	sub    $0xc,%esp
f01023bf:	6a 00                	push   $0x0
f01023c1:	e8 38 ef ff ff       	call   f01012fe <page_alloc>
f01023c6:	83 c4 10             	add    $0x10,%esp
f01023c9:	85 c0                	test   %eax,%eax
f01023cb:	74 19                	je     f01023e6 <mem_init+0xe11>
f01023cd:	68 08 4e 10 f0       	push   $0xf0104e08
f01023d2:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01023d7:	68 39 03 00 00       	push   $0x339
f01023dc:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01023e1:	e8 a5 dc ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023e6:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01023eb:	8b 08                	mov    (%eax),%ecx
f01023ed:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023f3:	89 f2                	mov    %esi,%edx
f01023f5:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f01023fb:	c1 fa 03             	sar    $0x3,%edx
f01023fe:	c1 e2 0c             	shl    $0xc,%edx
f0102401:	39 d1                	cmp    %edx,%ecx
f0102403:	74 19                	je     f010241e <mem_init+0xe49>
f0102405:	68 b0 47 10 f0       	push   $0xf01047b0
f010240a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010240f:	68 3c 03 00 00       	push   $0x33c
f0102414:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102419:	e8 6d dc ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f010241e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102424:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102429:	74 19                	je     f0102444 <mem_init+0xe6f>
f010242b:	68 6b 4e 10 f0       	push   $0xf0104e6b
f0102430:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102435:	68 3e 03 00 00       	push   $0x33e
f010243a:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010243f:	e8 47 dc ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102444:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010244a:	83 ec 0c             	sub    $0xc,%esp
f010244d:	56                   	push   %esi
f010244e:	e8 35 ef ff ff       	call   f0101388 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102453:	83 c4 0c             	add    $0xc,%esp
f0102456:	6a 01                	push   $0x1
f0102458:	68 00 10 40 00       	push   $0x401000
f010245d:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102463:	e8 5e ef ff ff       	call   f01013c6 <pgdir_walk>
f0102468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010246b:	8b 0d 48 e9 11 f0    	mov    0xf011e948,%ecx
f0102471:	8b 51 04             	mov    0x4(%ecx),%edx
f0102474:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010247a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010247d:	c1 ea 0c             	shr    $0xc,%edx
f0102480:	83 c4 10             	add    $0x10,%esp
f0102483:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102489:	72 17                	jb     f01024a2 <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010248b:	ff 75 c4             	pushl  -0x3c(%ebp)
f010248e:	68 94 45 10 f0       	push   $0xf0104594
f0102493:	68 45 03 00 00       	push   $0x345
f0102498:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010249d:	e8 e9 db ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024a2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01024a5:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01024ab:	39 d0                	cmp    %edx,%eax
f01024ad:	74 19                	je     f01024c8 <mem_init+0xef3>
f01024af:	68 d6 4e 10 f0       	push   $0xf0104ed6
f01024b4:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01024b9:	68 46 03 00 00       	push   $0x346
f01024be:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01024c3:	e8 c3 db ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024c8:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024cf:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024d5:	89 f0                	mov    %esi,%eax
f01024d7:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01024dd:	c1 f8 03             	sar    $0x3,%eax
f01024e0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024e3:	89 c2                	mov    %eax,%edx
f01024e5:	c1 ea 0c             	shr    $0xc,%edx
f01024e8:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01024ee:	72 12                	jb     f0102502 <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024f0:	50                   	push   %eax
f01024f1:	68 94 45 10 f0       	push   $0xf0104594
f01024f6:	6a 52                	push   $0x52
f01024f8:	68 98 4c 10 f0       	push   $0xf0104c98
f01024fd:	e8 89 db ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102502:	83 ec 04             	sub    $0x4,%esp
f0102505:	68 00 10 00 00       	push   $0x1000
f010250a:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010250f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102514:	50                   	push   %eax
f0102515:	e8 57 12 00 00       	call   f0103771 <memset>
	page_free(pp0);
f010251a:	89 34 24             	mov    %esi,(%esp)
f010251d:	e8 66 ee ff ff       	call   f0101388 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102522:	83 c4 0c             	add    $0xc,%esp
f0102525:	6a 01                	push   $0x1
f0102527:	6a 00                	push   $0x0
f0102529:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010252f:	e8 92 ee ff ff       	call   f01013c6 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102534:	89 f2                	mov    %esi,%edx
f0102536:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010253c:	c1 fa 03             	sar    $0x3,%edx
f010253f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102542:	89 d0                	mov    %edx,%eax
f0102544:	c1 e8 0c             	shr    $0xc,%eax
f0102547:	83 c4 10             	add    $0x10,%esp
f010254a:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0102550:	72 12                	jb     f0102564 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102552:	52                   	push   %edx
f0102553:	68 94 45 10 f0       	push   $0xf0104594
f0102558:	6a 52                	push   $0x52
f010255a:	68 98 4c 10 f0       	push   $0xf0104c98
f010255f:	e8 27 db ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102564:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010256a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010256d:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102574:	75 11                	jne    f0102587 <mem_init+0xfb2>
f0102576:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010257c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102582:	f6 00 01             	testb  $0x1,(%eax)
f0102585:	74 19                	je     f01025a0 <mem_init+0xfcb>
f0102587:	68 ee 4e 10 f0       	push   $0xf0104eee
f010258c:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102591:	68 50 03 00 00       	push   $0x350
f0102596:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010259b:	e8 eb da ff ff       	call   f010008b <_panic>
f01025a0:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025a3:	39 d0                	cmp    %edx,%eax
f01025a5:	75 db                	jne    f0102582 <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025a7:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01025ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025b2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01025b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025bb:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c

	// free the pages we took
	page_free(pp0);
f01025c0:	83 ec 0c             	sub    $0xc,%esp
f01025c3:	56                   	push   %esi
f01025c4:	e8 bf ed ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f01025c9:	89 3c 24             	mov    %edi,(%esp)
f01025cc:	e8 b7 ed ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f01025d1:	89 1c 24             	mov    %ebx,(%esp)
f01025d4:	e8 af ed ff ff       	call   f0101388 <page_free>

	cprintf("check_page() succeeded!\n");
f01025d9:	c7 04 24 05 4f 10 f0 	movl   $0xf0104f05,(%esp)
f01025e0:	e8 5c 06 00 00       	call   f0102c41 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025e5:	a1 4c e9 11 f0       	mov    0xf011e94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ea:	83 c4 10             	add    $0x10,%esp
f01025ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025f2:	77 15                	ja     f0102609 <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025f4:	50                   	push   %eax
f01025f5:	68 d8 43 10 f0       	push   $0xf01043d8
f01025fa:	68 b1 00 00 00       	push   $0xb1
f01025ff:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102604:	e8 82 da ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102609:	8b 15 44 e9 11 f0    	mov    0xf011e944,%edx
f010260f:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102616:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102619:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010261f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102621:	05 00 00 00 10       	add    $0x10000000,%eax
f0102626:	50                   	push   %eax
f0102627:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010262c:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102631:	e8 27 ee ff ff       	call   f010145d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102636:	83 c4 10             	add    $0x10,%esp
f0102639:	ba 00 40 11 f0       	mov    $0xf0114000,%edx
f010263e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102644:	77 15                	ja     f010265b <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102646:	52                   	push   %edx
f0102647:	68 d8 43 10 f0       	push   $0xf01043d8
f010264c:	68 c2 00 00 00       	push   $0xc2
f0102651:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102656:	e8 30 da ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010265b:	83 ec 08             	sub    $0x8,%esp
f010265e:	6a 02                	push   $0x2
f0102660:	68 00 40 11 00       	push   $0x114000
f0102665:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010266a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010266f:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102674:	e8 e4 ed ff ff       	call   f010145d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102679:	83 c4 08             	add    $0x8,%esp
f010267c:	6a 02                	push   $0x2
f010267e:	6a 00                	push   $0x0
f0102680:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102685:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010268a:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010268f:	e8 c9 ed ff ff       	call   f010145d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102694:	8b 1d 48 e9 11 f0    	mov    0xf011e948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010269a:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f010269f:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026a6:	83 c4 10             	add    $0x10,%esp
f01026a9:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026af:	74 63                	je     f0102714 <mem_init+0x113f>
f01026b1:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026b6:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026bc:	89 d8                	mov    %ebx,%eax
f01026be:	e8 4c e8 ff ff       	call   f0100f0f <check_va2pa>
f01026c3:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026cf:	77 15                	ja     f01026e6 <mem_init+0x1111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d1:	52                   	push   %edx
f01026d2:	68 d8 43 10 f0       	push   $0xf01043d8
f01026d7:	68 97 02 00 00       	push   $0x297
f01026dc:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01026e1:	e8 a5 d9 ff ff       	call   f010008b <_panic>
f01026e6:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01026ed:	39 d0                	cmp    %edx,%eax
f01026ef:	74 19                	je     f010270a <mem_init+0x1135>
f01026f1:	68 f8 4a 10 f0       	push   $0xf0104af8
f01026f6:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01026fb:	68 97 02 00 00       	push   $0x297
f0102700:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102705:	e8 81 d9 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010270a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102710:	39 f7                	cmp    %esi,%edi
f0102712:	77 a2                	ja     f01026b6 <mem_init+0x10e1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102714:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0102719:	c1 e0 0c             	shl    $0xc,%eax
f010271c:	74 41                	je     f010275f <mem_init+0x118a>
f010271e:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102723:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102729:	89 d8                	mov    %ebx,%eax
f010272b:	e8 df e7 ff ff       	call   f0100f0f <check_va2pa>
f0102730:	39 c6                	cmp    %eax,%esi
f0102732:	74 19                	je     f010274d <mem_init+0x1178>
f0102734:	68 2c 4b 10 f0       	push   $0xf0104b2c
f0102739:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010273e:	68 9c 02 00 00       	push   $0x29c
f0102743:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102748:	e8 3e d9 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010274d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102753:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0102758:	c1 e0 0c             	shl    $0xc,%eax
f010275b:	39 c6                	cmp    %eax,%esi
f010275d:	72 c4                	jb     f0102723 <mem_init+0x114e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010275f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102764:	89 d8                	mov    %ebx,%eax
f0102766:	e8 a4 e7 ff ff       	call   f0100f0f <check_va2pa>
f010276b:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102770:	bf 00 40 11 f0       	mov    $0xf0114000,%edi
f0102775:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010277b:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010277e:	39 d0                	cmp    %edx,%eax
f0102780:	74 19                	je     f010279b <mem_init+0x11c6>
f0102782:	68 54 4b 10 f0       	push   $0xf0104b54
f0102787:	68 b2 4c 10 f0       	push   $0xf0104cb2
f010278c:	68 a0 02 00 00       	push   $0x2a0
f0102791:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102796:	e8 f0 d8 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010279b:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01027a1:	0f 85 25 04 00 00    	jne    f0102bcc <mem_init+0x15f7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01027a7:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01027ac:	89 d8                	mov    %ebx,%eax
f01027ae:	e8 5c e7 ff ff       	call   f0100f0f <check_va2pa>
f01027b3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027b6:	74 19                	je     f01027d1 <mem_init+0x11fc>
f01027b8:	68 9c 4b 10 f0       	push   $0xf0104b9c
f01027bd:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01027c2:	68 a1 02 00 00       	push   $0x2a1
f01027c7:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01027cc:	e8 ba d8 ff ff       	call   f010008b <_panic>
f01027d1:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027d6:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01027db:	72 2d                	jb     f010280a <mem_init+0x1235>
f01027dd:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01027e2:	76 07                	jbe    f01027eb <mem_init+0x1216>
f01027e4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027e9:	75 1f                	jne    f010280a <mem_init+0x1235>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01027eb:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01027ef:	75 7e                	jne    f010286f <mem_init+0x129a>
f01027f1:	68 1e 4f 10 f0       	push   $0xf0104f1e
f01027f6:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01027fb:	68 a9 02 00 00       	push   $0x2a9
f0102800:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102805:	e8 81 d8 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010280a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010280f:	76 3f                	jbe    f0102850 <mem_init+0x127b>
				assert(pgdir[i] & PTE_P);
f0102811:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102814:	f6 c2 01             	test   $0x1,%dl
f0102817:	75 19                	jne    f0102832 <mem_init+0x125d>
f0102819:	68 1e 4f 10 f0       	push   $0xf0104f1e
f010281e:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102823:	68 ad 02 00 00       	push   $0x2ad
f0102828:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010282d:	e8 59 d8 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102832:	f6 c2 02             	test   $0x2,%dl
f0102835:	75 38                	jne    f010286f <mem_init+0x129a>
f0102837:	68 2f 4f 10 f0       	push   $0xf0104f2f
f010283c:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102841:	68 ae 02 00 00       	push   $0x2ae
f0102846:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010284b:	e8 3b d8 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102850:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102854:	74 19                	je     f010286f <mem_init+0x129a>
f0102856:	68 40 4f 10 f0       	push   $0xf0104f40
f010285b:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102860:	68 b0 02 00 00       	push   $0x2b0
f0102865:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010286a:	e8 1c d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010286f:	40                   	inc    %eax
f0102870:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102875:	0f 85 5b ff ff ff    	jne    f01027d6 <mem_init+0x1201>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010287b:	83 ec 0c             	sub    $0xc,%esp
f010287e:	68 cc 4b 10 f0       	push   $0xf0104bcc
f0102883:	e8 b9 03 00 00       	call   f0102c41 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102888:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010288d:	83 c4 10             	add    $0x10,%esp
f0102890:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102895:	77 15                	ja     f01028ac <mem_init+0x12d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102897:	50                   	push   %eax
f0102898:	68 d8 43 10 f0       	push   $0xf01043d8
f010289d:	68 de 00 00 00       	push   $0xde
f01028a2:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01028a7:	e8 df d7 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01028ac:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01028b1:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01028b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01028b9:	e8 da e6 ff ff       	call   f0100f98 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01028be:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01028c1:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01028c6:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01028c9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028cc:	83 ec 0c             	sub    $0xc,%esp
f01028cf:	6a 00                	push   $0x0
f01028d1:	e8 28 ea ff ff       	call   f01012fe <page_alloc>
f01028d6:	89 c6                	mov    %eax,%esi
f01028d8:	83 c4 10             	add    $0x10,%esp
f01028db:	85 c0                	test   %eax,%eax
f01028dd:	75 19                	jne    f01028f8 <mem_init+0x1323>
f01028df:	68 5d 4d 10 f0       	push   $0xf0104d5d
f01028e4:	68 b2 4c 10 f0       	push   $0xf0104cb2
f01028e9:	68 6b 03 00 00       	push   $0x36b
f01028ee:	68 8c 4c 10 f0       	push   $0xf0104c8c
f01028f3:	e8 93 d7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01028f8:	83 ec 0c             	sub    $0xc,%esp
f01028fb:	6a 00                	push   $0x0
f01028fd:	e8 fc e9 ff ff       	call   f01012fe <page_alloc>
f0102902:	89 c7                	mov    %eax,%edi
f0102904:	83 c4 10             	add    $0x10,%esp
f0102907:	85 c0                	test   %eax,%eax
f0102909:	75 19                	jne    f0102924 <mem_init+0x134f>
f010290b:	68 73 4d 10 f0       	push   $0xf0104d73
f0102910:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102915:	68 6c 03 00 00       	push   $0x36c
f010291a:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010291f:	e8 67 d7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102924:	83 ec 0c             	sub    $0xc,%esp
f0102927:	6a 00                	push   $0x0
f0102929:	e8 d0 e9 ff ff       	call   f01012fe <page_alloc>
f010292e:	89 c3                	mov    %eax,%ebx
f0102930:	83 c4 10             	add    $0x10,%esp
f0102933:	85 c0                	test   %eax,%eax
f0102935:	75 19                	jne    f0102950 <mem_init+0x137b>
f0102937:	68 89 4d 10 f0       	push   $0xf0104d89
f010293c:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102941:	68 6d 03 00 00       	push   $0x36d
f0102946:	68 8c 4c 10 f0       	push   $0xf0104c8c
f010294b:	e8 3b d7 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102950:	83 ec 0c             	sub    $0xc,%esp
f0102953:	56                   	push   %esi
f0102954:	e8 2f ea ff ff       	call   f0101388 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102959:	89 f8                	mov    %edi,%eax
f010295b:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102961:	c1 f8 03             	sar    $0x3,%eax
f0102964:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102967:	89 c2                	mov    %eax,%edx
f0102969:	c1 ea 0c             	shr    $0xc,%edx
f010296c:	83 c4 10             	add    $0x10,%esp
f010296f:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102975:	72 12                	jb     f0102989 <mem_init+0x13b4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102977:	50                   	push   %eax
f0102978:	68 94 45 10 f0       	push   $0xf0104594
f010297d:	6a 52                	push   $0x52
f010297f:	68 98 4c 10 f0       	push   $0xf0104c98
f0102984:	e8 02 d7 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102989:	83 ec 04             	sub    $0x4,%esp
f010298c:	68 00 10 00 00       	push   $0x1000
f0102991:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102993:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102998:	50                   	push   %eax
f0102999:	e8 d3 0d 00 00       	call   f0103771 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010299e:	89 d8                	mov    %ebx,%eax
f01029a0:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01029a6:	c1 f8 03             	sar    $0x3,%eax
f01029a9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ac:	89 c2                	mov    %eax,%edx
f01029ae:	c1 ea 0c             	shr    $0xc,%edx
f01029b1:	83 c4 10             	add    $0x10,%esp
f01029b4:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01029ba:	72 12                	jb     f01029ce <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029bc:	50                   	push   %eax
f01029bd:	68 94 45 10 f0       	push   $0xf0104594
f01029c2:	6a 52                	push   $0x52
f01029c4:	68 98 4c 10 f0       	push   $0xf0104c98
f01029c9:	e8 bd d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029ce:	83 ec 04             	sub    $0x4,%esp
f01029d1:	68 00 10 00 00       	push   $0x1000
f01029d6:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01029d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029dd:	50                   	push   %eax
f01029de:	e8 8e 0d 00 00       	call   f0103771 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029e3:	6a 02                	push   $0x2
f01029e5:	68 00 10 00 00       	push   $0x1000
f01029ea:	57                   	push   %edi
f01029eb:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01029f1:	e8 76 eb ff ff       	call   f010156c <page_insert>
	assert(pp1->pp_ref == 1);
f01029f6:	83 c4 20             	add    $0x20,%esp
f01029f9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029fe:	74 19                	je     f0102a19 <mem_init+0x1444>
f0102a00:	68 5a 4e 10 f0       	push   $0xf0104e5a
f0102a05:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102a0a:	68 72 03 00 00       	push   $0x372
f0102a0f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102a14:	e8 72 d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a19:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a20:	01 01 01 
f0102a23:	74 19                	je     f0102a3e <mem_init+0x1469>
f0102a25:	68 ec 4b 10 f0       	push   $0xf0104bec
f0102a2a:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102a2f:	68 73 03 00 00       	push   $0x373
f0102a34:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102a39:	e8 4d d6 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a3e:	6a 02                	push   $0x2
f0102a40:	68 00 10 00 00       	push   $0x1000
f0102a45:	53                   	push   %ebx
f0102a46:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102a4c:	e8 1b eb ff ff       	call   f010156c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a51:	83 c4 10             	add    $0x10,%esp
f0102a54:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a5b:	02 02 02 
f0102a5e:	74 19                	je     f0102a79 <mem_init+0x14a4>
f0102a60:	68 10 4c 10 f0       	push   $0xf0104c10
f0102a65:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102a6a:	68 75 03 00 00       	push   $0x375
f0102a6f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102a74:	e8 12 d6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102a79:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a7e:	74 19                	je     f0102a99 <mem_init+0x14c4>
f0102a80:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0102a85:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102a8a:	68 76 03 00 00       	push   $0x376
f0102a8f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102a94:	e8 f2 d5 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102a99:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a9e:	74 19                	je     f0102ab9 <mem_init+0x14e4>
f0102aa0:	68 c5 4e 10 f0       	push   $0xf0104ec5
f0102aa5:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102aaa:	68 77 03 00 00       	push   $0x377
f0102aaf:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102ab4:	e8 d2 d5 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ab9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ac0:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ac3:	89 d8                	mov    %ebx,%eax
f0102ac5:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102acb:	c1 f8 03             	sar    $0x3,%eax
f0102ace:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ad1:	89 c2                	mov    %eax,%edx
f0102ad3:	c1 ea 0c             	shr    $0xc,%edx
f0102ad6:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102adc:	72 12                	jb     f0102af0 <mem_init+0x151b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ade:	50                   	push   %eax
f0102adf:	68 94 45 10 f0       	push   $0xf0104594
f0102ae4:	6a 52                	push   $0x52
f0102ae6:	68 98 4c 10 f0       	push   $0xf0104c98
f0102aeb:	e8 9b d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102af0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102af7:	03 03 03 
f0102afa:	74 19                	je     f0102b15 <mem_init+0x1540>
f0102afc:	68 34 4c 10 f0       	push   $0xf0104c34
f0102b01:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102b06:	68 79 03 00 00       	push   $0x379
f0102b0b:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102b10:	e8 76 d5 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b15:	83 ec 08             	sub    $0x8,%esp
f0102b18:	68 00 10 00 00       	push   $0x1000
f0102b1d:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102b23:	e8 f7 e9 ff ff       	call   f010151f <page_remove>
	assert(pp2->pp_ref == 0);
f0102b28:	83 c4 10             	add    $0x10,%esp
f0102b2b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b30:	74 19                	je     f0102b4b <mem_init+0x1576>
f0102b32:	68 b4 4e 10 f0       	push   $0xf0104eb4
f0102b37:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102b3c:	68 7b 03 00 00       	push   $0x37b
f0102b41:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102b46:	e8 40 d5 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b4b:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102b50:	8b 08                	mov    (%eax),%ecx
f0102b52:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b58:	89 f2                	mov    %esi,%edx
f0102b5a:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102b60:	c1 fa 03             	sar    $0x3,%edx
f0102b63:	c1 e2 0c             	shl    $0xc,%edx
f0102b66:	39 d1                	cmp    %edx,%ecx
f0102b68:	74 19                	je     f0102b83 <mem_init+0x15ae>
f0102b6a:	68 b0 47 10 f0       	push   $0xf01047b0
f0102b6f:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102b74:	68 7e 03 00 00       	push   $0x37e
f0102b79:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102b7e:	e8 08 d5 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102b83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b89:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b8e:	74 19                	je     f0102ba9 <mem_init+0x15d4>
f0102b90:	68 6b 4e 10 f0       	push   $0xf0104e6b
f0102b95:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0102b9a:	68 80 03 00 00       	push   $0x380
f0102b9f:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0102ba4:	e8 e2 d4 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102ba9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102baf:	83 ec 0c             	sub    $0xc,%esp
f0102bb2:	56                   	push   %esi
f0102bb3:	e8 d0 e7 ff ff       	call   f0101388 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102bb8:	c7 04 24 60 4c 10 f0 	movl   $0xf0104c60,(%esp)
f0102bbf:	e8 7d 00 00 00       	call   f0102c41 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bc7:	5b                   	pop    %ebx
f0102bc8:	5e                   	pop    %esi
f0102bc9:	5f                   	pop    %edi
f0102bca:	c9                   	leave  
f0102bcb:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bcc:	89 f2                	mov    %esi,%edx
f0102bce:	89 d8                	mov    %ebx,%eax
f0102bd0:	e8 3a e3 ff ff       	call   f0100f0f <check_va2pa>
f0102bd5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102bdb:	e9 9b fb ff ff       	jmp    f010277b <mem_init+0x11a6>

f0102be0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102be0:	55                   	push   %ebp
f0102be1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102be3:	ba 70 00 00 00       	mov    $0x70,%edx
f0102be8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102beb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102bec:	b2 71                	mov    $0x71,%dl
f0102bee:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102bef:	0f b6 c0             	movzbl %al,%eax
}
f0102bf2:	c9                   	leave  
f0102bf3:	c3                   	ret    

f0102bf4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
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
f0102c00:	b2 71                	mov    $0x71,%dl
f0102c02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c05:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c06:	c9                   	leave  
f0102c07:	c3                   	ret    

f0102c08 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c08:	55                   	push   %ebp
f0102c09:	89 e5                	mov    %esp,%ebp
f0102c0b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102c0e:	ff 75 08             	pushl  0x8(%ebp)
f0102c11:	e8 90 d9 ff ff       	call   f01005a6 <cputchar>
f0102c16:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102c19:	c9                   	leave  
f0102c1a:	c3                   	ret    

f0102c1b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102c1b:	55                   	push   %ebp
f0102c1c:	89 e5                	mov    %esp,%ebp
f0102c1e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102c21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102c28:	ff 75 0c             	pushl  0xc(%ebp)
f0102c2b:	ff 75 08             	pushl  0x8(%ebp)
f0102c2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102c31:	50                   	push   %eax
f0102c32:	68 08 2c 10 f0       	push   $0xf0102c08
f0102c37:	e8 9d 04 00 00       	call   f01030d9 <vprintfmt>
	return cnt;
}
f0102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c3f:	c9                   	leave  
f0102c40:	c3                   	ret    

f0102c41 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c41:	55                   	push   %ebp
f0102c42:	89 e5                	mov    %esp,%ebp
f0102c44:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102c47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102c4a:	50                   	push   %eax
f0102c4b:	ff 75 08             	pushl  0x8(%ebp)
f0102c4e:	e8 c8 ff ff ff       	call   f0102c1b <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c53:	c9                   	leave  
f0102c54:	c3                   	ret    
f0102c55:	00 00                	add    %al,(%eax)
	...

f0102c58 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102c58:	55                   	push   %ebp
f0102c59:	89 e5                	mov    %esp,%ebp
f0102c5b:	57                   	push   %edi
f0102c5c:	56                   	push   %esi
f0102c5d:	53                   	push   %ebx
f0102c5e:	83 ec 14             	sub    $0x14,%esp
f0102c61:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c64:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102c67:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c6d:	8b 1a                	mov    (%edx),%ebx
f0102c6f:	8b 01                	mov    (%ecx),%eax
f0102c71:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102c74:	39 c3                	cmp    %eax,%ebx
f0102c76:	0f 8f 97 00 00 00    	jg     f0102d13 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102c83:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c86:	01 d8                	add    %ebx,%eax
f0102c88:	89 c7                	mov    %eax,%edi
f0102c8a:	c1 ef 1f             	shr    $0x1f,%edi
f0102c8d:	01 c7                	add    %eax,%edi
f0102c8f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102c91:	39 df                	cmp    %ebx,%edi
f0102c93:	7c 31                	jl     f0102cc6 <stab_binsearch+0x6e>
f0102c95:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102c9b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102ca0:	39 f0                	cmp    %esi,%eax
f0102ca2:	0f 84 b3 00 00 00    	je     f0102d5b <stab_binsearch+0x103>
f0102ca8:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102cac:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102cb0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102cb2:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102cb3:	39 d8                	cmp    %ebx,%eax
f0102cb5:	7c 0f                	jl     f0102cc6 <stab_binsearch+0x6e>
f0102cb7:	0f b6 0a             	movzbl (%edx),%ecx
f0102cba:	83 ea 0c             	sub    $0xc,%edx
f0102cbd:	39 f1                	cmp    %esi,%ecx
f0102cbf:	75 f1                	jne    f0102cb2 <stab_binsearch+0x5a>
f0102cc1:	e9 97 00 00 00       	jmp    f0102d5d <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102cc6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102cc9:	eb 39                	jmp    f0102d04 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102ccb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102cce:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102cd0:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cd3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102cda:	eb 28                	jmp    f0102d04 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102cdc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102cdf:	76 12                	jbe    f0102cf3 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102ce1:	48                   	dec    %eax
f0102ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ce5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ce8:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cea:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102cf1:	eb 11                	jmp    f0102d04 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102cf3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102cf6:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102cf8:	ff 45 0c             	incl   0xc(%ebp)
f0102cfb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cfd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d04:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102d07:	0f 8d 76 ff ff ff    	jge    f0102c83 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d0d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102d11:	75 0d                	jne    f0102d20 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102d13:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d16:	8b 03                	mov    (%ebx),%eax
f0102d18:	48                   	dec    %eax
f0102d19:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d1c:	89 02                	mov    %eax,(%edx)
f0102d1e:	eb 55                	jmp    f0102d75 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d23:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102d25:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d28:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d2a:	39 c1                	cmp    %eax,%ecx
f0102d2c:	7d 26                	jge    f0102d54 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102d2e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102d31:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102d34:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102d39:	39 f2                	cmp    %esi,%edx
f0102d3b:	74 17                	je     f0102d54 <stab_binsearch+0xfc>
f0102d3d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d41:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102d45:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d46:	39 c1                	cmp    %eax,%ecx
f0102d48:	7d 0a                	jge    f0102d54 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102d4a:	0f b6 1a             	movzbl (%edx),%ebx
f0102d4d:	83 ea 0c             	sub    $0xc,%edx
f0102d50:	39 f3                	cmp    %esi,%ebx
f0102d52:	75 f1                	jne    f0102d45 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102d54:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d57:	89 02                	mov    %eax,(%edx)
f0102d59:	eb 1a                	jmp    f0102d75 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d5b:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102d5d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102d60:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102d63:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102d67:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102d6a:	0f 82 5b ff ff ff    	jb     f0102ccb <stab_binsearch+0x73>
f0102d70:	e9 67 ff ff ff       	jmp    f0102cdc <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102d75:	83 c4 14             	add    $0x14,%esp
f0102d78:	5b                   	pop    %ebx
f0102d79:	5e                   	pop    %esi
f0102d7a:	5f                   	pop    %edi
f0102d7b:	c9                   	leave  
f0102d7c:	c3                   	ret    

f0102d7d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102d7d:	55                   	push   %ebp
f0102d7e:	89 e5                	mov    %esp,%ebp
f0102d80:	57                   	push   %edi
f0102d81:	56                   	push   %esi
f0102d82:	53                   	push   %ebx
f0102d83:	83 ec 2c             	sub    $0x2c,%esp
f0102d86:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102d8c:	c7 03 4e 4f 10 f0    	movl   $0xf0104f4e,(%ebx)
	info->eip_line = 0;
f0102d92:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102d99:	c7 43 08 4e 4f 10 f0 	movl   $0xf0104f4e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102da0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102da7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102daa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102db1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102db7:	76 12                	jbe    f0102dcb <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102db9:	b8 09 3e 11 f0       	mov    $0xf0113e09,%eax
f0102dbe:	3d ed c4 10 f0       	cmp    $0xf010c4ed,%eax
f0102dc3:	0f 86 90 01 00 00    	jbe    f0102f59 <debuginfo_eip+0x1dc>
f0102dc9:	eb 14                	jmp    f0102ddf <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102dcb:	83 ec 04             	sub    $0x4,%esp
f0102dce:	68 58 4f 10 f0       	push   $0xf0104f58
f0102dd3:	6a 7f                	push   $0x7f
f0102dd5:	68 65 4f 10 f0       	push   $0xf0104f65
f0102dda:	e8 ac d2 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102de4:	80 3d 08 3e 11 f0 00 	cmpb   $0x0,0xf0113e08
f0102deb:	0f 85 74 01 00 00    	jne    f0102f65 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102df1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102df8:	b8 ec c4 10 f0       	mov    $0xf010c4ec,%eax
f0102dfd:	2d 84 51 10 f0       	sub    $0xf0105184,%eax
f0102e02:	c1 f8 02             	sar    $0x2,%eax
f0102e05:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102e0b:	48                   	dec    %eax
f0102e0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102e0f:	83 ec 08             	sub    $0x8,%esp
f0102e12:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102e15:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102e18:	56                   	push   %esi
f0102e19:	6a 64                	push   $0x64
f0102e1b:	b8 84 51 10 f0       	mov    $0xf0105184,%eax
f0102e20:	e8 33 fe ff ff       	call   f0102c58 <stab_binsearch>
	if (lfile == 0)
f0102e25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102e28:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102e2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102e30:	85 d2                	test   %edx,%edx
f0102e32:	0f 84 2d 01 00 00    	je     f0102f65 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e38:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102e41:	83 ec 08             	sub    $0x8,%esp
f0102e44:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102e47:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102e4a:	56                   	push   %esi
f0102e4b:	6a 24                	push   $0x24
f0102e4d:	b8 84 51 10 f0       	mov    $0xf0105184,%eax
f0102e52:	e8 01 fe ff ff       	call   f0102c58 <stab_binsearch>

	if (lfun <= rfun) {
f0102e57:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102e5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e5d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e60:	83 c4 10             	add    $0x10,%esp
f0102e63:	39 c7                	cmp    %eax,%edi
f0102e65:	7f 32                	jg     f0102e99 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102e67:	89 f9                	mov    %edi,%ecx
f0102e69:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102e6c:	8b 80 84 51 10 f0    	mov    -0xfefae7c(%eax),%eax
f0102e72:	ba 09 3e 11 f0       	mov    $0xf0113e09,%edx
f0102e77:	81 ea ed c4 10 f0    	sub    $0xf010c4ed,%edx
f0102e7d:	39 d0                	cmp    %edx,%eax
f0102e7f:	73 08                	jae    f0102e89 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102e81:	05 ed c4 10 f0       	add    $0xf010c4ed,%eax
f0102e86:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102e89:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102e8c:	8b 81 8c 51 10 f0    	mov    -0xfefae74(%ecx),%eax
f0102e92:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102e95:	29 c6                	sub    %eax,%esi
f0102e97:	eb 0c                	jmp    f0102ea5 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102e99:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102e9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102e9f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102ea2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102ea5:	83 ec 08             	sub    $0x8,%esp
f0102ea8:	6a 3a                	push   $0x3a
f0102eaa:	ff 73 08             	pushl  0x8(%ebx)
f0102ead:	e8 9d 08 00 00       	call   f010374f <strfind>
f0102eb2:	2b 43 08             	sub    0x8(%ebx),%eax
f0102eb5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102eb8:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102ebb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ebe:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102ec1:	83 c4 08             	add    $0x8,%esp
f0102ec4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102ec7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102eca:	56                   	push   %esi
f0102ecb:	6a 44                	push   $0x44
f0102ecd:	b8 84 51 10 f0       	mov    $0xf0105184,%eax
f0102ed2:	e8 81 fd ff ff       	call   f0102c58 <stab_binsearch>
    if (lfun <= rfun) {
f0102ed7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102eda:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102ee2:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102ee5:	7f 7e                	jg     f0102f65 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102ee7:	6b c2 0c             	imul   $0xc,%edx,%eax
f0102eea:	05 84 51 10 f0       	add    $0xf0105184,%eax
f0102eef:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102ef3:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102ef6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102ef9:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102efc:	eb 04                	jmp    f0102f02 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102efe:	4a                   	dec    %edx
f0102eff:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f02:	39 f2                	cmp    %esi,%edx
f0102f04:	7c 1b                	jl     f0102f21 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0102f06:	8a 48 fc             	mov    -0x4(%eax),%cl
f0102f09:	80 f9 84             	cmp    $0x84,%cl
f0102f0c:	74 5f                	je     f0102f6d <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f0e:	80 f9 64             	cmp    $0x64,%cl
f0102f11:	75 eb                	jne    f0102efe <debuginfo_eip+0x181>
f0102f13:	83 38 00             	cmpl   $0x0,(%eax)
f0102f16:	74 e6                	je     f0102efe <debuginfo_eip+0x181>
f0102f18:	eb 53                	jmp    f0102f6d <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102f1a:	05 ed c4 10 f0       	add    $0xf010c4ed,%eax
f0102f1f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f21:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f24:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f27:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f2c:	39 ca                	cmp    %ecx,%edx
f0102f2e:	7d 35                	jge    f0102f65 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0102f30:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102f33:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102f36:	81 c2 88 51 10 f0    	add    $0xf0105188,%edx
f0102f3c:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f3e:	eb 04                	jmp    f0102f44 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102f40:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0102f43:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f44:	39 f0                	cmp    %esi,%eax
f0102f46:	7d 18                	jge    f0102f60 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102f48:	8a 0a                	mov    (%edx),%cl
f0102f4a:	83 c2 0c             	add    $0xc,%edx
f0102f4d:	80 f9 a0             	cmp    $0xa0,%cl
f0102f50:	74 ee                	je     f0102f40 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f52:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f57:	eb 0c                	jmp    f0102f65 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102f59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f5e:	eb 05                	jmp    f0102f65 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f68:	5b                   	pop    %ebx
f0102f69:	5e                   	pop    %esi
f0102f6a:	5f                   	pop    %edi
f0102f6b:	c9                   	leave  
f0102f6c:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102f6d:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102f70:	8b 82 84 51 10 f0    	mov    -0xfefae7c(%edx),%eax
f0102f76:	ba 09 3e 11 f0       	mov    $0xf0113e09,%edx
f0102f7b:	81 ea ed c4 10 f0    	sub    $0xf010c4ed,%edx
f0102f81:	39 d0                	cmp    %edx,%eax
f0102f83:	72 95                	jb     f0102f1a <debuginfo_eip+0x19d>
f0102f85:	eb 9a                	jmp    f0102f21 <debuginfo_eip+0x1a4>
	...

f0102f88 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102f88:	55                   	push   %ebp
f0102f89:	89 e5                	mov    %esp,%ebp
f0102f8b:	57                   	push   %edi
f0102f8c:	56                   	push   %esi
f0102f8d:	53                   	push   %ebx
f0102f8e:	83 ec 2c             	sub    $0x2c,%esp
f0102f91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f94:	89 d6                	mov    %edx,%esi
f0102f96:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f99:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102f9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f9f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102fa2:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fa5:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102fa8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102fab:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102fae:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102fb5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102fb8:	72 0c                	jb     f0102fc6 <printnum+0x3e>
f0102fba:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102fbd:	76 07                	jbe    f0102fc6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102fbf:	4b                   	dec    %ebx
f0102fc0:	85 db                	test   %ebx,%ebx
f0102fc2:	7f 31                	jg     f0102ff5 <printnum+0x6d>
f0102fc4:	eb 3f                	jmp    f0103005 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102fc6:	83 ec 0c             	sub    $0xc,%esp
f0102fc9:	57                   	push   %edi
f0102fca:	4b                   	dec    %ebx
f0102fcb:	53                   	push   %ebx
f0102fcc:	50                   	push   %eax
f0102fcd:	83 ec 08             	sub    $0x8,%esp
f0102fd0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102fd3:	ff 75 d0             	pushl  -0x30(%ebp)
f0102fd6:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fd9:	ff 75 d8             	pushl  -0x28(%ebp)
f0102fdc:	e8 97 09 00 00       	call   f0103978 <__udivdi3>
f0102fe1:	83 c4 18             	add    $0x18,%esp
f0102fe4:	52                   	push   %edx
f0102fe5:	50                   	push   %eax
f0102fe6:	89 f2                	mov    %esi,%edx
f0102fe8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102feb:	e8 98 ff ff ff       	call   f0102f88 <printnum>
f0102ff0:	83 c4 20             	add    $0x20,%esp
f0102ff3:	eb 10                	jmp    f0103005 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102ff5:	83 ec 08             	sub    $0x8,%esp
f0102ff8:	56                   	push   %esi
f0102ff9:	57                   	push   %edi
f0102ffa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102ffd:	4b                   	dec    %ebx
f0102ffe:	83 c4 10             	add    $0x10,%esp
f0103001:	85 db                	test   %ebx,%ebx
f0103003:	7f f0                	jg     f0102ff5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103005:	83 ec 08             	sub    $0x8,%esp
f0103008:	56                   	push   %esi
f0103009:	83 ec 04             	sub    $0x4,%esp
f010300c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010300f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103012:	ff 75 dc             	pushl  -0x24(%ebp)
f0103015:	ff 75 d8             	pushl  -0x28(%ebp)
f0103018:	e8 77 0a 00 00       	call   f0103a94 <__umoddi3>
f010301d:	83 c4 14             	add    $0x14,%esp
f0103020:	0f be 80 73 4f 10 f0 	movsbl -0xfefb08d(%eax),%eax
f0103027:	50                   	push   %eax
f0103028:	ff 55 e4             	call   *-0x1c(%ebp)
f010302b:	83 c4 10             	add    $0x10,%esp
}
f010302e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103031:	5b                   	pop    %ebx
f0103032:	5e                   	pop    %esi
f0103033:	5f                   	pop    %edi
f0103034:	c9                   	leave  
f0103035:	c3                   	ret    

f0103036 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103036:	55                   	push   %ebp
f0103037:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103039:	83 fa 01             	cmp    $0x1,%edx
f010303c:	7e 0e                	jle    f010304c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010303e:	8b 10                	mov    (%eax),%edx
f0103040:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103043:	89 08                	mov    %ecx,(%eax)
f0103045:	8b 02                	mov    (%edx),%eax
f0103047:	8b 52 04             	mov    0x4(%edx),%edx
f010304a:	eb 22                	jmp    f010306e <getuint+0x38>
	else if (lflag)
f010304c:	85 d2                	test   %edx,%edx
f010304e:	74 10                	je     f0103060 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103050:	8b 10                	mov    (%eax),%edx
f0103052:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103055:	89 08                	mov    %ecx,(%eax)
f0103057:	8b 02                	mov    (%edx),%eax
f0103059:	ba 00 00 00 00       	mov    $0x0,%edx
f010305e:	eb 0e                	jmp    f010306e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103060:	8b 10                	mov    (%eax),%edx
f0103062:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103065:	89 08                	mov    %ecx,(%eax)
f0103067:	8b 02                	mov    (%edx),%eax
f0103069:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010306e:	c9                   	leave  
f010306f:	c3                   	ret    

f0103070 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103070:	55                   	push   %ebp
f0103071:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103073:	83 fa 01             	cmp    $0x1,%edx
f0103076:	7e 0e                	jle    f0103086 <getint+0x16>
		return va_arg(*ap, long long);
f0103078:	8b 10                	mov    (%eax),%edx
f010307a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010307d:	89 08                	mov    %ecx,(%eax)
f010307f:	8b 02                	mov    (%edx),%eax
f0103081:	8b 52 04             	mov    0x4(%edx),%edx
f0103084:	eb 1a                	jmp    f01030a0 <getint+0x30>
	else if (lflag)
f0103086:	85 d2                	test   %edx,%edx
f0103088:	74 0c                	je     f0103096 <getint+0x26>
		return va_arg(*ap, long);
f010308a:	8b 10                	mov    (%eax),%edx
f010308c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010308f:	89 08                	mov    %ecx,(%eax)
f0103091:	8b 02                	mov    (%edx),%eax
f0103093:	99                   	cltd   
f0103094:	eb 0a                	jmp    f01030a0 <getint+0x30>
	else
		return va_arg(*ap, int);
f0103096:	8b 10                	mov    (%eax),%edx
f0103098:	8d 4a 04             	lea    0x4(%edx),%ecx
f010309b:	89 08                	mov    %ecx,(%eax)
f010309d:	8b 02                	mov    (%edx),%eax
f010309f:	99                   	cltd   
}
f01030a0:	c9                   	leave  
f01030a1:	c3                   	ret    

f01030a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01030a2:	55                   	push   %ebp
f01030a3:	89 e5                	mov    %esp,%ebp
f01030a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01030a8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01030ab:	8b 10                	mov    (%eax),%edx
f01030ad:	3b 50 04             	cmp    0x4(%eax),%edx
f01030b0:	73 08                	jae    f01030ba <sprintputch+0x18>
		*b->buf++ = ch;
f01030b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030b5:	88 0a                	mov    %cl,(%edx)
f01030b7:	42                   	inc    %edx
f01030b8:	89 10                	mov    %edx,(%eax)
}
f01030ba:	c9                   	leave  
f01030bb:	c3                   	ret    

f01030bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01030bc:	55                   	push   %ebp
f01030bd:	89 e5                	mov    %esp,%ebp
f01030bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01030c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01030c5:	50                   	push   %eax
f01030c6:	ff 75 10             	pushl  0x10(%ebp)
f01030c9:	ff 75 0c             	pushl  0xc(%ebp)
f01030cc:	ff 75 08             	pushl  0x8(%ebp)
f01030cf:	e8 05 00 00 00       	call   f01030d9 <vprintfmt>
	va_end(ap);
f01030d4:	83 c4 10             	add    $0x10,%esp
}
f01030d7:	c9                   	leave  
f01030d8:	c3                   	ret    

f01030d9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01030d9:	55                   	push   %ebp
f01030da:	89 e5                	mov    %esp,%ebp
f01030dc:	57                   	push   %edi
f01030dd:	56                   	push   %esi
f01030de:	53                   	push   %ebx
f01030df:	83 ec 2c             	sub    $0x2c,%esp
f01030e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01030e5:	8b 75 10             	mov    0x10(%ebp),%esi
f01030e8:	eb 13                	jmp    f01030fd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01030ea:	85 c0                	test   %eax,%eax
f01030ec:	0f 84 6d 03 00 00    	je     f010345f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01030f2:	83 ec 08             	sub    $0x8,%esp
f01030f5:	57                   	push   %edi
f01030f6:	50                   	push   %eax
f01030f7:	ff 55 08             	call   *0x8(%ebp)
f01030fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01030fd:	0f b6 06             	movzbl (%esi),%eax
f0103100:	46                   	inc    %esi
f0103101:	83 f8 25             	cmp    $0x25,%eax
f0103104:	75 e4                	jne    f01030ea <vprintfmt+0x11>
f0103106:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010310a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103111:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0103118:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010311f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103124:	eb 28                	jmp    f010314e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103126:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103128:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010312c:	eb 20                	jmp    f010314e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010312e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103130:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0103134:	eb 18                	jmp    f010314e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103136:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103138:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010313f:	eb 0d                	jmp    f010314e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103141:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103144:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103147:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010314e:	8a 06                	mov    (%esi),%al
f0103150:	0f b6 d0             	movzbl %al,%edx
f0103153:	8d 5e 01             	lea    0x1(%esi),%ebx
f0103156:	83 e8 23             	sub    $0x23,%eax
f0103159:	3c 55                	cmp    $0x55,%al
f010315b:	0f 87 e0 02 00 00    	ja     f0103441 <vprintfmt+0x368>
f0103161:	0f b6 c0             	movzbl %al,%eax
f0103164:	ff 24 85 00 50 10 f0 	jmp    *-0xfefb000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010316b:	83 ea 30             	sub    $0x30,%edx
f010316e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103171:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0103174:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103177:	83 fa 09             	cmp    $0x9,%edx
f010317a:	77 44                	ja     f01031c0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010317c:	89 de                	mov    %ebx,%esi
f010317e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103181:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0103182:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103185:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103189:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010318c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010318f:	83 fb 09             	cmp    $0x9,%ebx
f0103192:	76 ed                	jbe    f0103181 <vprintfmt+0xa8>
f0103194:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103197:	eb 29                	jmp    f01031c2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103199:	8b 45 14             	mov    0x14(%ebp),%eax
f010319c:	8d 50 04             	lea    0x4(%eax),%edx
f010319f:	89 55 14             	mov    %edx,0x14(%ebp)
f01031a2:	8b 00                	mov    (%eax),%eax
f01031a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031a7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01031a9:	eb 17                	jmp    f01031c2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01031ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01031af:	78 85                	js     f0103136 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031b1:	89 de                	mov    %ebx,%esi
f01031b3:	eb 99                	jmp    f010314e <vprintfmt+0x75>
f01031b5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01031b7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01031be:	eb 8e                	jmp    f010314e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031c0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01031c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01031c6:	79 86                	jns    f010314e <vprintfmt+0x75>
f01031c8:	e9 74 ff ff ff       	jmp    f0103141 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01031cd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031ce:	89 de                	mov    %ebx,%esi
f01031d0:	e9 79 ff ff ff       	jmp    f010314e <vprintfmt+0x75>
f01031d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01031d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01031db:	8d 50 04             	lea    0x4(%eax),%edx
f01031de:	89 55 14             	mov    %edx,0x14(%ebp)
f01031e1:	83 ec 08             	sub    $0x8,%esp
f01031e4:	57                   	push   %edi
f01031e5:	ff 30                	pushl  (%eax)
f01031e7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01031ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01031f0:	e9 08 ff ff ff       	jmp    f01030fd <vprintfmt+0x24>
f01031f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01031f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01031fb:	8d 50 04             	lea    0x4(%eax),%edx
f01031fe:	89 55 14             	mov    %edx,0x14(%ebp)
f0103201:	8b 00                	mov    (%eax),%eax
f0103203:	85 c0                	test   %eax,%eax
f0103205:	79 02                	jns    f0103209 <vprintfmt+0x130>
f0103207:	f7 d8                	neg    %eax
f0103209:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010320b:	83 f8 06             	cmp    $0x6,%eax
f010320e:	7f 0b                	jg     f010321b <vprintfmt+0x142>
f0103210:	8b 04 85 58 51 10 f0 	mov    -0xfefaea8(,%eax,4),%eax
f0103217:	85 c0                	test   %eax,%eax
f0103219:	75 1a                	jne    f0103235 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010321b:	52                   	push   %edx
f010321c:	68 8b 4f 10 f0       	push   $0xf0104f8b
f0103221:	57                   	push   %edi
f0103222:	ff 75 08             	pushl  0x8(%ebp)
f0103225:	e8 92 fe ff ff       	call   f01030bc <printfmt>
f010322a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010322d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103230:	e9 c8 fe ff ff       	jmp    f01030fd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0103235:	50                   	push   %eax
f0103236:	68 c4 4c 10 f0       	push   $0xf0104cc4
f010323b:	57                   	push   %edi
f010323c:	ff 75 08             	pushl  0x8(%ebp)
f010323f:	e8 78 fe ff ff       	call   f01030bc <printfmt>
f0103244:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103247:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010324a:	e9 ae fe ff ff       	jmp    f01030fd <vprintfmt+0x24>
f010324f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103252:	89 de                	mov    %ebx,%esi
f0103254:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103257:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010325a:	8b 45 14             	mov    0x14(%ebp),%eax
f010325d:	8d 50 04             	lea    0x4(%eax),%edx
f0103260:	89 55 14             	mov    %edx,0x14(%ebp)
f0103263:	8b 00                	mov    (%eax),%eax
f0103265:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103268:	85 c0                	test   %eax,%eax
f010326a:	75 07                	jne    f0103273 <vprintfmt+0x19a>
				p = "(null)";
f010326c:	c7 45 d0 84 4f 10 f0 	movl   $0xf0104f84,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0103273:	85 db                	test   %ebx,%ebx
f0103275:	7e 42                	jle    f01032b9 <vprintfmt+0x1e0>
f0103277:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010327b:	74 3c                	je     f01032b9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010327d:	83 ec 08             	sub    $0x8,%esp
f0103280:	51                   	push   %ecx
f0103281:	ff 75 d0             	pushl  -0x30(%ebp)
f0103284:	e8 3f 03 00 00       	call   f01035c8 <strnlen>
f0103289:	29 c3                	sub    %eax,%ebx
f010328b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010328e:	83 c4 10             	add    $0x10,%esp
f0103291:	85 db                	test   %ebx,%ebx
f0103293:	7e 24                	jle    f01032b9 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0103295:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103299:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010329c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010329f:	83 ec 08             	sub    $0x8,%esp
f01032a2:	57                   	push   %edi
f01032a3:	53                   	push   %ebx
f01032a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01032a7:	4e                   	dec    %esi
f01032a8:	83 c4 10             	add    $0x10,%esp
f01032ab:	85 f6                	test   %esi,%esi
f01032ad:	7f f0                	jg     f010329f <vprintfmt+0x1c6>
f01032af:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01032b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01032bc:	0f be 02             	movsbl (%edx),%eax
f01032bf:	85 c0                	test   %eax,%eax
f01032c1:	75 47                	jne    f010330a <vprintfmt+0x231>
f01032c3:	eb 37                	jmp    f01032fc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01032c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01032c9:	74 16                	je     f01032e1 <vprintfmt+0x208>
f01032cb:	8d 50 e0             	lea    -0x20(%eax),%edx
f01032ce:	83 fa 5e             	cmp    $0x5e,%edx
f01032d1:	76 0e                	jbe    f01032e1 <vprintfmt+0x208>
					putch('?', putdat);
f01032d3:	83 ec 08             	sub    $0x8,%esp
f01032d6:	57                   	push   %edi
f01032d7:	6a 3f                	push   $0x3f
f01032d9:	ff 55 08             	call   *0x8(%ebp)
f01032dc:	83 c4 10             	add    $0x10,%esp
f01032df:	eb 0b                	jmp    f01032ec <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01032e1:	83 ec 08             	sub    $0x8,%esp
f01032e4:	57                   	push   %edi
f01032e5:	50                   	push   %eax
f01032e6:	ff 55 08             	call   *0x8(%ebp)
f01032e9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032ec:	ff 4d e4             	decl   -0x1c(%ebp)
f01032ef:	0f be 03             	movsbl (%ebx),%eax
f01032f2:	85 c0                	test   %eax,%eax
f01032f4:	74 03                	je     f01032f9 <vprintfmt+0x220>
f01032f6:	43                   	inc    %ebx
f01032f7:	eb 1b                	jmp    f0103314 <vprintfmt+0x23b>
f01032f9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01032fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103300:	7f 1e                	jg     f0103320 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103302:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103305:	e9 f3 fd ff ff       	jmp    f01030fd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010330a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010330d:	43                   	inc    %ebx
f010330e:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103311:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103314:	85 f6                	test   %esi,%esi
f0103316:	78 ad                	js     f01032c5 <vprintfmt+0x1ec>
f0103318:	4e                   	dec    %esi
f0103319:	79 aa                	jns    f01032c5 <vprintfmt+0x1ec>
f010331b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010331e:	eb dc                	jmp    f01032fc <vprintfmt+0x223>
f0103320:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103323:	83 ec 08             	sub    $0x8,%esp
f0103326:	57                   	push   %edi
f0103327:	6a 20                	push   $0x20
f0103329:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010332c:	4b                   	dec    %ebx
f010332d:	83 c4 10             	add    $0x10,%esp
f0103330:	85 db                	test   %ebx,%ebx
f0103332:	7f ef                	jg     f0103323 <vprintfmt+0x24a>
f0103334:	e9 c4 fd ff ff       	jmp    f01030fd <vprintfmt+0x24>
f0103339:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010333c:	89 ca                	mov    %ecx,%edx
f010333e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103341:	e8 2a fd ff ff       	call   f0103070 <getint>
f0103346:	89 c3                	mov    %eax,%ebx
f0103348:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010334a:	85 d2                	test   %edx,%edx
f010334c:	78 0a                	js     f0103358 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010334e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103353:	e9 b0 00 00 00       	jmp    f0103408 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103358:	83 ec 08             	sub    $0x8,%esp
f010335b:	57                   	push   %edi
f010335c:	6a 2d                	push   $0x2d
f010335e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103361:	f7 db                	neg    %ebx
f0103363:	83 d6 00             	adc    $0x0,%esi
f0103366:	f7 de                	neg    %esi
f0103368:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010336b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103370:	e9 93 00 00 00       	jmp    f0103408 <vprintfmt+0x32f>
f0103375:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103378:	89 ca                	mov    %ecx,%edx
f010337a:	8d 45 14             	lea    0x14(%ebp),%eax
f010337d:	e8 b4 fc ff ff       	call   f0103036 <getuint>
f0103382:	89 c3                	mov    %eax,%ebx
f0103384:	89 d6                	mov    %edx,%esi
			base = 10;
f0103386:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010338b:	eb 7b                	jmp    f0103408 <vprintfmt+0x32f>
f010338d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103390:	89 ca                	mov    %ecx,%edx
f0103392:	8d 45 14             	lea    0x14(%ebp),%eax
f0103395:	e8 d6 fc ff ff       	call   f0103070 <getint>
f010339a:	89 c3                	mov    %eax,%ebx
f010339c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f010339e:	85 d2                	test   %edx,%edx
f01033a0:	78 07                	js     f01033a9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01033a2:	b8 08 00 00 00       	mov    $0x8,%eax
f01033a7:	eb 5f                	jmp    f0103408 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01033a9:	83 ec 08             	sub    $0x8,%esp
f01033ac:	57                   	push   %edi
f01033ad:	6a 2d                	push   $0x2d
f01033af:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01033b2:	f7 db                	neg    %ebx
f01033b4:	83 d6 00             	adc    $0x0,%esi
f01033b7:	f7 de                	neg    %esi
f01033b9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01033bc:	b8 08 00 00 00       	mov    $0x8,%eax
f01033c1:	eb 45                	jmp    f0103408 <vprintfmt+0x32f>
f01033c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01033c6:	83 ec 08             	sub    $0x8,%esp
f01033c9:	57                   	push   %edi
f01033ca:	6a 30                	push   $0x30
f01033cc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01033cf:	83 c4 08             	add    $0x8,%esp
f01033d2:	57                   	push   %edi
f01033d3:	6a 78                	push   $0x78
f01033d5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01033d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01033db:	8d 50 04             	lea    0x4(%eax),%edx
f01033de:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01033e1:	8b 18                	mov    (%eax),%ebx
f01033e3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01033e8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01033eb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01033f0:	eb 16                	jmp    f0103408 <vprintfmt+0x32f>
f01033f2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01033f5:	89 ca                	mov    %ecx,%edx
f01033f7:	8d 45 14             	lea    0x14(%ebp),%eax
f01033fa:	e8 37 fc ff ff       	call   f0103036 <getuint>
f01033ff:	89 c3                	mov    %eax,%ebx
f0103401:	89 d6                	mov    %edx,%esi
			base = 16;
f0103403:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103408:	83 ec 0c             	sub    $0xc,%esp
f010340b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f010340f:	52                   	push   %edx
f0103410:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103413:	50                   	push   %eax
f0103414:	56                   	push   %esi
f0103415:	53                   	push   %ebx
f0103416:	89 fa                	mov    %edi,%edx
f0103418:	8b 45 08             	mov    0x8(%ebp),%eax
f010341b:	e8 68 fb ff ff       	call   f0102f88 <printnum>
			break;
f0103420:	83 c4 20             	add    $0x20,%esp
f0103423:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103426:	e9 d2 fc ff ff       	jmp    f01030fd <vprintfmt+0x24>
f010342b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010342e:	83 ec 08             	sub    $0x8,%esp
f0103431:	57                   	push   %edi
f0103432:	52                   	push   %edx
f0103433:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103436:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103439:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010343c:	e9 bc fc ff ff       	jmp    f01030fd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103441:	83 ec 08             	sub    $0x8,%esp
f0103444:	57                   	push   %edi
f0103445:	6a 25                	push   $0x25
f0103447:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010344a:	83 c4 10             	add    $0x10,%esp
f010344d:	eb 02                	jmp    f0103451 <vprintfmt+0x378>
f010344f:	89 c6                	mov    %eax,%esi
f0103451:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103454:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103458:	75 f5                	jne    f010344f <vprintfmt+0x376>
f010345a:	e9 9e fc ff ff       	jmp    f01030fd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010345f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103462:	5b                   	pop    %ebx
f0103463:	5e                   	pop    %esi
f0103464:	5f                   	pop    %edi
f0103465:	c9                   	leave  
f0103466:	c3                   	ret    

f0103467 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103467:	55                   	push   %ebp
f0103468:	89 e5                	mov    %esp,%ebp
f010346a:	83 ec 18             	sub    $0x18,%esp
f010346d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103470:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103473:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103476:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010347a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010347d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103484:	85 c0                	test   %eax,%eax
f0103486:	74 26                	je     f01034ae <vsnprintf+0x47>
f0103488:	85 d2                	test   %edx,%edx
f010348a:	7e 29                	jle    f01034b5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010348c:	ff 75 14             	pushl  0x14(%ebp)
f010348f:	ff 75 10             	pushl  0x10(%ebp)
f0103492:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103495:	50                   	push   %eax
f0103496:	68 a2 30 10 f0       	push   $0xf01030a2
f010349b:	e8 39 fc ff ff       	call   f01030d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01034a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01034a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034a9:	83 c4 10             	add    $0x10,%esp
f01034ac:	eb 0c                	jmp    f01034ba <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01034ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01034b3:	eb 05                	jmp    f01034ba <vsnprintf+0x53>
f01034b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01034ba:	c9                   	leave  
f01034bb:	c3                   	ret    

f01034bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01034bc:	55                   	push   %ebp
f01034bd:	89 e5                	mov    %esp,%ebp
f01034bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01034c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01034c5:	50                   	push   %eax
f01034c6:	ff 75 10             	pushl  0x10(%ebp)
f01034c9:	ff 75 0c             	pushl  0xc(%ebp)
f01034cc:	ff 75 08             	pushl  0x8(%ebp)
f01034cf:	e8 93 ff ff ff       	call   f0103467 <vsnprintf>
	va_end(ap);

	return rc;
}
f01034d4:	c9                   	leave  
f01034d5:	c3                   	ret    
	...

f01034d8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01034d8:	55                   	push   %ebp
f01034d9:	89 e5                	mov    %esp,%ebp
f01034db:	57                   	push   %edi
f01034dc:	56                   	push   %esi
f01034dd:	53                   	push   %ebx
f01034de:	83 ec 0c             	sub    $0xc,%esp
f01034e1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01034e4:	85 c0                	test   %eax,%eax
f01034e6:	74 11                	je     f01034f9 <readline+0x21>
		cprintf("%s", prompt);
f01034e8:	83 ec 08             	sub    $0x8,%esp
f01034eb:	50                   	push   %eax
f01034ec:	68 c4 4c 10 f0       	push   $0xf0104cc4
f01034f1:	e8 4b f7 ff ff       	call   f0102c41 <cprintf>
f01034f6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01034f9:	83 ec 0c             	sub    $0xc,%esp
f01034fc:	6a 00                	push   $0x0
f01034fe:	e8 c4 d0 ff ff       	call   f01005c7 <iscons>
f0103503:	89 c7                	mov    %eax,%edi
f0103505:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103508:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010350d:	e8 a4 d0 ff ff       	call   f01005b6 <getchar>
f0103512:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103514:	85 c0                	test   %eax,%eax
f0103516:	79 18                	jns    f0103530 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103518:	83 ec 08             	sub    $0x8,%esp
f010351b:	50                   	push   %eax
f010351c:	68 74 51 10 f0       	push   $0xf0105174
f0103521:	e8 1b f7 ff ff       	call   f0102c41 <cprintf>
			return NULL;
f0103526:	83 c4 10             	add    $0x10,%esp
f0103529:	b8 00 00 00 00       	mov    $0x0,%eax
f010352e:	eb 6f                	jmp    f010359f <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103530:	83 f8 08             	cmp    $0x8,%eax
f0103533:	74 05                	je     f010353a <readline+0x62>
f0103535:	83 f8 7f             	cmp    $0x7f,%eax
f0103538:	75 18                	jne    f0103552 <readline+0x7a>
f010353a:	85 f6                	test   %esi,%esi
f010353c:	7e 14                	jle    f0103552 <readline+0x7a>
			if (echoing)
f010353e:	85 ff                	test   %edi,%edi
f0103540:	74 0d                	je     f010354f <readline+0x77>
				cputchar('\b');
f0103542:	83 ec 0c             	sub    $0xc,%esp
f0103545:	6a 08                	push   $0x8
f0103547:	e8 5a d0 ff ff       	call   f01005a6 <cputchar>
f010354c:	83 c4 10             	add    $0x10,%esp
			i--;
f010354f:	4e                   	dec    %esi
f0103550:	eb bb                	jmp    f010350d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103552:	83 fb 1f             	cmp    $0x1f,%ebx
f0103555:	7e 21                	jle    f0103578 <readline+0xa0>
f0103557:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010355d:	7f 19                	jg     f0103578 <readline+0xa0>
			if (echoing)
f010355f:	85 ff                	test   %edi,%edi
f0103561:	74 0c                	je     f010356f <readline+0x97>
				cputchar(c);
f0103563:	83 ec 0c             	sub    $0xc,%esp
f0103566:	53                   	push   %ebx
f0103567:	e8 3a d0 ff ff       	call   f01005a6 <cputchar>
f010356c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010356f:	88 9e 40 e5 11 f0    	mov    %bl,-0xfee1ac0(%esi)
f0103575:	46                   	inc    %esi
f0103576:	eb 95                	jmp    f010350d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103578:	83 fb 0a             	cmp    $0xa,%ebx
f010357b:	74 05                	je     f0103582 <readline+0xaa>
f010357d:	83 fb 0d             	cmp    $0xd,%ebx
f0103580:	75 8b                	jne    f010350d <readline+0x35>
			if (echoing)
f0103582:	85 ff                	test   %edi,%edi
f0103584:	74 0d                	je     f0103593 <readline+0xbb>
				cputchar('\n');
f0103586:	83 ec 0c             	sub    $0xc,%esp
f0103589:	6a 0a                	push   $0xa
f010358b:	e8 16 d0 ff ff       	call   f01005a6 <cputchar>
f0103590:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103593:	c6 86 40 e5 11 f0 00 	movb   $0x0,-0xfee1ac0(%esi)
			return buf;
f010359a:	b8 40 e5 11 f0       	mov    $0xf011e540,%eax
		}
	}
}
f010359f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035a2:	5b                   	pop    %ebx
f01035a3:	5e                   	pop    %esi
f01035a4:	5f                   	pop    %edi
f01035a5:	c9                   	leave  
f01035a6:	c3                   	ret    
	...

f01035a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01035a8:	55                   	push   %ebp
f01035a9:	89 e5                	mov    %esp,%ebp
f01035ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01035ae:	80 3a 00             	cmpb   $0x0,(%edx)
f01035b1:	74 0e                	je     f01035c1 <strlen+0x19>
f01035b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01035b8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01035b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01035bd:	75 f9                	jne    f01035b8 <strlen+0x10>
f01035bf:	eb 05                	jmp    f01035c6 <strlen+0x1e>
f01035c1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01035c6:	c9                   	leave  
f01035c7:	c3                   	ret    

f01035c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01035c8:	55                   	push   %ebp
f01035c9:	89 e5                	mov    %esp,%ebp
f01035cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01035ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035d1:	85 d2                	test   %edx,%edx
f01035d3:	74 17                	je     f01035ec <strnlen+0x24>
f01035d5:	80 39 00             	cmpb   $0x0,(%ecx)
f01035d8:	74 19                	je     f01035f3 <strnlen+0x2b>
f01035da:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01035df:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035e0:	39 d0                	cmp    %edx,%eax
f01035e2:	74 14                	je     f01035f8 <strnlen+0x30>
f01035e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01035e8:	75 f5                	jne    f01035df <strnlen+0x17>
f01035ea:	eb 0c                	jmp    f01035f8 <strnlen+0x30>
f01035ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01035f1:	eb 05                	jmp    f01035f8 <strnlen+0x30>
f01035f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01035f8:	c9                   	leave  
f01035f9:	c3                   	ret    

f01035fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01035fa:	55                   	push   %ebp
f01035fb:	89 e5                	mov    %esp,%ebp
f01035fd:	53                   	push   %ebx
f01035fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103604:	ba 00 00 00 00       	mov    $0x0,%edx
f0103609:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f010360c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010360f:	42                   	inc    %edx
f0103610:	84 c9                	test   %cl,%cl
f0103612:	75 f5                	jne    f0103609 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103614:	5b                   	pop    %ebx
f0103615:	c9                   	leave  
f0103616:	c3                   	ret    

f0103617 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103617:	55                   	push   %ebp
f0103618:	89 e5                	mov    %esp,%ebp
f010361a:	53                   	push   %ebx
f010361b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010361e:	53                   	push   %ebx
f010361f:	e8 84 ff ff ff       	call   f01035a8 <strlen>
f0103624:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103627:	ff 75 0c             	pushl  0xc(%ebp)
f010362a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010362d:	50                   	push   %eax
f010362e:	e8 c7 ff ff ff       	call   f01035fa <strcpy>
	return dst;
}
f0103633:	89 d8                	mov    %ebx,%eax
f0103635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103638:	c9                   	leave  
f0103639:	c3                   	ret    

f010363a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010363a:	55                   	push   %ebp
f010363b:	89 e5                	mov    %esp,%ebp
f010363d:	56                   	push   %esi
f010363e:	53                   	push   %ebx
f010363f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103642:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103645:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103648:	85 f6                	test   %esi,%esi
f010364a:	74 15                	je     f0103661 <strncpy+0x27>
f010364c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103651:	8a 1a                	mov    (%edx),%bl
f0103653:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103656:	80 3a 01             	cmpb   $0x1,(%edx)
f0103659:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010365c:	41                   	inc    %ecx
f010365d:	39 ce                	cmp    %ecx,%esi
f010365f:	77 f0                	ja     f0103651 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103661:	5b                   	pop    %ebx
f0103662:	5e                   	pop    %esi
f0103663:	c9                   	leave  
f0103664:	c3                   	ret    

f0103665 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103665:	55                   	push   %ebp
f0103666:	89 e5                	mov    %esp,%ebp
f0103668:	57                   	push   %edi
f0103669:	56                   	push   %esi
f010366a:	53                   	push   %ebx
f010366b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010366e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103671:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103674:	85 f6                	test   %esi,%esi
f0103676:	74 32                	je     f01036aa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103678:	83 fe 01             	cmp    $0x1,%esi
f010367b:	74 22                	je     f010369f <strlcpy+0x3a>
f010367d:	8a 0b                	mov    (%ebx),%cl
f010367f:	84 c9                	test   %cl,%cl
f0103681:	74 20                	je     f01036a3 <strlcpy+0x3e>
f0103683:	89 f8                	mov    %edi,%eax
f0103685:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010368a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010368d:	88 08                	mov    %cl,(%eax)
f010368f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103690:	39 f2                	cmp    %esi,%edx
f0103692:	74 11                	je     f01036a5 <strlcpy+0x40>
f0103694:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103698:	42                   	inc    %edx
f0103699:	84 c9                	test   %cl,%cl
f010369b:	75 f0                	jne    f010368d <strlcpy+0x28>
f010369d:	eb 06                	jmp    f01036a5 <strlcpy+0x40>
f010369f:	89 f8                	mov    %edi,%eax
f01036a1:	eb 02                	jmp    f01036a5 <strlcpy+0x40>
f01036a3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01036a5:	c6 00 00             	movb   $0x0,(%eax)
f01036a8:	eb 02                	jmp    f01036ac <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036aa:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01036ac:	29 f8                	sub    %edi,%eax
}
f01036ae:	5b                   	pop    %ebx
f01036af:	5e                   	pop    %esi
f01036b0:	5f                   	pop    %edi
f01036b1:	c9                   	leave  
f01036b2:	c3                   	ret    

f01036b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01036b3:	55                   	push   %ebp
f01036b4:	89 e5                	mov    %esp,%ebp
f01036b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01036bc:	8a 01                	mov    (%ecx),%al
f01036be:	84 c0                	test   %al,%al
f01036c0:	74 10                	je     f01036d2 <strcmp+0x1f>
f01036c2:	3a 02                	cmp    (%edx),%al
f01036c4:	75 0c                	jne    f01036d2 <strcmp+0x1f>
		p++, q++;
f01036c6:	41                   	inc    %ecx
f01036c7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01036c8:	8a 01                	mov    (%ecx),%al
f01036ca:	84 c0                	test   %al,%al
f01036cc:	74 04                	je     f01036d2 <strcmp+0x1f>
f01036ce:	3a 02                	cmp    (%edx),%al
f01036d0:	74 f4                	je     f01036c6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01036d2:	0f b6 c0             	movzbl %al,%eax
f01036d5:	0f b6 12             	movzbl (%edx),%edx
f01036d8:	29 d0                	sub    %edx,%eax
}
f01036da:	c9                   	leave  
f01036db:	c3                   	ret    

f01036dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01036dc:	55                   	push   %ebp
f01036dd:	89 e5                	mov    %esp,%ebp
f01036df:	53                   	push   %ebx
f01036e0:	8b 55 08             	mov    0x8(%ebp),%edx
f01036e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036e6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01036e9:	85 c0                	test   %eax,%eax
f01036eb:	74 1b                	je     f0103708 <strncmp+0x2c>
f01036ed:	8a 1a                	mov    (%edx),%bl
f01036ef:	84 db                	test   %bl,%bl
f01036f1:	74 24                	je     f0103717 <strncmp+0x3b>
f01036f3:	3a 19                	cmp    (%ecx),%bl
f01036f5:	75 20                	jne    f0103717 <strncmp+0x3b>
f01036f7:	48                   	dec    %eax
f01036f8:	74 15                	je     f010370f <strncmp+0x33>
		n--, p++, q++;
f01036fa:	42                   	inc    %edx
f01036fb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01036fc:	8a 1a                	mov    (%edx),%bl
f01036fe:	84 db                	test   %bl,%bl
f0103700:	74 15                	je     f0103717 <strncmp+0x3b>
f0103702:	3a 19                	cmp    (%ecx),%bl
f0103704:	74 f1                	je     f01036f7 <strncmp+0x1b>
f0103706:	eb 0f                	jmp    f0103717 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103708:	b8 00 00 00 00       	mov    $0x0,%eax
f010370d:	eb 05                	jmp    f0103714 <strncmp+0x38>
f010370f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103714:	5b                   	pop    %ebx
f0103715:	c9                   	leave  
f0103716:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103717:	0f b6 02             	movzbl (%edx),%eax
f010371a:	0f b6 11             	movzbl (%ecx),%edx
f010371d:	29 d0                	sub    %edx,%eax
f010371f:	eb f3                	jmp    f0103714 <strncmp+0x38>

f0103721 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103721:	55                   	push   %ebp
f0103722:	89 e5                	mov    %esp,%ebp
f0103724:	8b 45 08             	mov    0x8(%ebp),%eax
f0103727:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010372a:	8a 10                	mov    (%eax),%dl
f010372c:	84 d2                	test   %dl,%dl
f010372e:	74 18                	je     f0103748 <strchr+0x27>
		if (*s == c)
f0103730:	38 ca                	cmp    %cl,%dl
f0103732:	75 06                	jne    f010373a <strchr+0x19>
f0103734:	eb 17                	jmp    f010374d <strchr+0x2c>
f0103736:	38 ca                	cmp    %cl,%dl
f0103738:	74 13                	je     f010374d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010373a:	40                   	inc    %eax
f010373b:	8a 10                	mov    (%eax),%dl
f010373d:	84 d2                	test   %dl,%dl
f010373f:	75 f5                	jne    f0103736 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103741:	b8 00 00 00 00       	mov    $0x0,%eax
f0103746:	eb 05                	jmp    f010374d <strchr+0x2c>
f0103748:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010374d:	c9                   	leave  
f010374e:	c3                   	ret    

f010374f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010374f:	55                   	push   %ebp
f0103750:	89 e5                	mov    %esp,%ebp
f0103752:	8b 45 08             	mov    0x8(%ebp),%eax
f0103755:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103758:	8a 10                	mov    (%eax),%dl
f010375a:	84 d2                	test   %dl,%dl
f010375c:	74 11                	je     f010376f <strfind+0x20>
		if (*s == c)
f010375e:	38 ca                	cmp    %cl,%dl
f0103760:	75 06                	jne    f0103768 <strfind+0x19>
f0103762:	eb 0b                	jmp    f010376f <strfind+0x20>
f0103764:	38 ca                	cmp    %cl,%dl
f0103766:	74 07                	je     f010376f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103768:	40                   	inc    %eax
f0103769:	8a 10                	mov    (%eax),%dl
f010376b:	84 d2                	test   %dl,%dl
f010376d:	75 f5                	jne    f0103764 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010376f:	c9                   	leave  
f0103770:	c3                   	ret    

f0103771 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103771:	55                   	push   %ebp
f0103772:	89 e5                	mov    %esp,%ebp
f0103774:	57                   	push   %edi
f0103775:	56                   	push   %esi
f0103776:	53                   	push   %ebx
f0103777:	8b 7d 08             	mov    0x8(%ebp),%edi
f010377a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103780:	85 c9                	test   %ecx,%ecx
f0103782:	74 30                	je     f01037b4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103784:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010378a:	75 25                	jne    f01037b1 <memset+0x40>
f010378c:	f6 c1 03             	test   $0x3,%cl
f010378f:	75 20                	jne    f01037b1 <memset+0x40>
		c &= 0xFF;
f0103791:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103794:	89 d3                	mov    %edx,%ebx
f0103796:	c1 e3 08             	shl    $0x8,%ebx
f0103799:	89 d6                	mov    %edx,%esi
f010379b:	c1 e6 18             	shl    $0x18,%esi
f010379e:	89 d0                	mov    %edx,%eax
f01037a0:	c1 e0 10             	shl    $0x10,%eax
f01037a3:	09 f0                	or     %esi,%eax
f01037a5:	09 d0                	or     %edx,%eax
f01037a7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01037a9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01037ac:	fc                   	cld    
f01037ad:	f3 ab                	rep stos %eax,%es:(%edi)
f01037af:	eb 03                	jmp    f01037b4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01037b1:	fc                   	cld    
f01037b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01037b4:	89 f8                	mov    %edi,%eax
f01037b6:	5b                   	pop    %ebx
f01037b7:	5e                   	pop    %esi
f01037b8:	5f                   	pop    %edi
f01037b9:	c9                   	leave  
f01037ba:	c3                   	ret    

f01037bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01037bb:	55                   	push   %ebp
f01037bc:	89 e5                	mov    %esp,%ebp
f01037be:	57                   	push   %edi
f01037bf:	56                   	push   %esi
f01037c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01037c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01037c9:	39 c6                	cmp    %eax,%esi
f01037cb:	73 34                	jae    f0103801 <memmove+0x46>
f01037cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01037d0:	39 d0                	cmp    %edx,%eax
f01037d2:	73 2d                	jae    f0103801 <memmove+0x46>
		s += n;
		d += n;
f01037d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037d7:	f6 c2 03             	test   $0x3,%dl
f01037da:	75 1b                	jne    f01037f7 <memmove+0x3c>
f01037dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01037e2:	75 13                	jne    f01037f7 <memmove+0x3c>
f01037e4:	f6 c1 03             	test   $0x3,%cl
f01037e7:	75 0e                	jne    f01037f7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01037e9:	83 ef 04             	sub    $0x4,%edi
f01037ec:	8d 72 fc             	lea    -0x4(%edx),%esi
f01037ef:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01037f2:	fd                   	std    
f01037f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037f5:	eb 07                	jmp    f01037fe <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01037f7:	4f                   	dec    %edi
f01037f8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01037fb:	fd                   	std    
f01037fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01037fe:	fc                   	cld    
f01037ff:	eb 20                	jmp    f0103821 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103801:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103807:	75 13                	jne    f010381c <memmove+0x61>
f0103809:	a8 03                	test   $0x3,%al
f010380b:	75 0f                	jne    f010381c <memmove+0x61>
f010380d:	f6 c1 03             	test   $0x3,%cl
f0103810:	75 0a                	jne    f010381c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103812:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103815:	89 c7                	mov    %eax,%edi
f0103817:	fc                   	cld    
f0103818:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010381a:	eb 05                	jmp    f0103821 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010381c:	89 c7                	mov    %eax,%edi
f010381e:	fc                   	cld    
f010381f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103821:	5e                   	pop    %esi
f0103822:	5f                   	pop    %edi
f0103823:	c9                   	leave  
f0103824:	c3                   	ret    

f0103825 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103825:	55                   	push   %ebp
f0103826:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103828:	ff 75 10             	pushl  0x10(%ebp)
f010382b:	ff 75 0c             	pushl  0xc(%ebp)
f010382e:	ff 75 08             	pushl  0x8(%ebp)
f0103831:	e8 85 ff ff ff       	call   f01037bb <memmove>
}
f0103836:	c9                   	leave  
f0103837:	c3                   	ret    

f0103838 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103838:	55                   	push   %ebp
f0103839:	89 e5                	mov    %esp,%ebp
f010383b:	57                   	push   %edi
f010383c:	56                   	push   %esi
f010383d:	53                   	push   %ebx
f010383e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103841:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103844:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103847:	85 ff                	test   %edi,%edi
f0103849:	74 32                	je     f010387d <memcmp+0x45>
		if (*s1 != *s2)
f010384b:	8a 03                	mov    (%ebx),%al
f010384d:	8a 0e                	mov    (%esi),%cl
f010384f:	38 c8                	cmp    %cl,%al
f0103851:	74 19                	je     f010386c <memcmp+0x34>
f0103853:	eb 0d                	jmp    f0103862 <memcmp+0x2a>
f0103855:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0103859:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010385d:	42                   	inc    %edx
f010385e:	38 c8                	cmp    %cl,%al
f0103860:	74 10                	je     f0103872 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0103862:	0f b6 c0             	movzbl %al,%eax
f0103865:	0f b6 c9             	movzbl %cl,%ecx
f0103868:	29 c8                	sub    %ecx,%eax
f010386a:	eb 16                	jmp    f0103882 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010386c:	4f                   	dec    %edi
f010386d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103872:	39 fa                	cmp    %edi,%edx
f0103874:	75 df                	jne    f0103855 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103876:	b8 00 00 00 00       	mov    $0x0,%eax
f010387b:	eb 05                	jmp    f0103882 <memcmp+0x4a>
f010387d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103882:	5b                   	pop    %ebx
f0103883:	5e                   	pop    %esi
f0103884:	5f                   	pop    %edi
f0103885:	c9                   	leave  
f0103886:	c3                   	ret    

f0103887 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103887:	55                   	push   %ebp
f0103888:	89 e5                	mov    %esp,%ebp
f010388a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010388d:	89 c2                	mov    %eax,%edx
f010388f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103892:	39 d0                	cmp    %edx,%eax
f0103894:	73 12                	jae    f01038a8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103896:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0103899:	38 08                	cmp    %cl,(%eax)
f010389b:	75 06                	jne    f01038a3 <memfind+0x1c>
f010389d:	eb 09                	jmp    f01038a8 <memfind+0x21>
f010389f:	38 08                	cmp    %cl,(%eax)
f01038a1:	74 05                	je     f01038a8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01038a3:	40                   	inc    %eax
f01038a4:	39 c2                	cmp    %eax,%edx
f01038a6:	77 f7                	ja     f010389f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01038a8:	c9                   	leave  
f01038a9:	c3                   	ret    

f01038aa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01038aa:	55                   	push   %ebp
f01038ab:	89 e5                	mov    %esp,%ebp
f01038ad:	57                   	push   %edi
f01038ae:	56                   	push   %esi
f01038af:	53                   	push   %ebx
f01038b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01038b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038b6:	eb 01                	jmp    f01038b9 <strtol+0xf>
		s++;
f01038b8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038b9:	8a 02                	mov    (%edx),%al
f01038bb:	3c 20                	cmp    $0x20,%al
f01038bd:	74 f9                	je     f01038b8 <strtol+0xe>
f01038bf:	3c 09                	cmp    $0x9,%al
f01038c1:	74 f5                	je     f01038b8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01038c3:	3c 2b                	cmp    $0x2b,%al
f01038c5:	75 08                	jne    f01038cf <strtol+0x25>
		s++;
f01038c7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038c8:	bf 00 00 00 00       	mov    $0x0,%edi
f01038cd:	eb 13                	jmp    f01038e2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01038cf:	3c 2d                	cmp    $0x2d,%al
f01038d1:	75 0a                	jne    f01038dd <strtol+0x33>
		s++, neg = 1;
f01038d3:	8d 52 01             	lea    0x1(%edx),%edx
f01038d6:	bf 01 00 00 00       	mov    $0x1,%edi
f01038db:	eb 05                	jmp    f01038e2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038dd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038e2:	85 db                	test   %ebx,%ebx
f01038e4:	74 05                	je     f01038eb <strtol+0x41>
f01038e6:	83 fb 10             	cmp    $0x10,%ebx
f01038e9:	75 28                	jne    f0103913 <strtol+0x69>
f01038eb:	8a 02                	mov    (%edx),%al
f01038ed:	3c 30                	cmp    $0x30,%al
f01038ef:	75 10                	jne    f0103901 <strtol+0x57>
f01038f1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01038f5:	75 0a                	jne    f0103901 <strtol+0x57>
		s += 2, base = 16;
f01038f7:	83 c2 02             	add    $0x2,%edx
f01038fa:	bb 10 00 00 00       	mov    $0x10,%ebx
f01038ff:	eb 12                	jmp    f0103913 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103901:	85 db                	test   %ebx,%ebx
f0103903:	75 0e                	jne    f0103913 <strtol+0x69>
f0103905:	3c 30                	cmp    $0x30,%al
f0103907:	75 05                	jne    f010390e <strtol+0x64>
		s++, base = 8;
f0103909:	42                   	inc    %edx
f010390a:	b3 08                	mov    $0x8,%bl
f010390c:	eb 05                	jmp    f0103913 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010390e:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103913:	b8 00 00 00 00       	mov    $0x0,%eax
f0103918:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010391a:	8a 0a                	mov    (%edx),%cl
f010391c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010391f:	80 fb 09             	cmp    $0x9,%bl
f0103922:	77 08                	ja     f010392c <strtol+0x82>
			dig = *s - '0';
f0103924:	0f be c9             	movsbl %cl,%ecx
f0103927:	83 e9 30             	sub    $0x30,%ecx
f010392a:	eb 1e                	jmp    f010394a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010392c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010392f:	80 fb 19             	cmp    $0x19,%bl
f0103932:	77 08                	ja     f010393c <strtol+0x92>
			dig = *s - 'a' + 10;
f0103934:	0f be c9             	movsbl %cl,%ecx
f0103937:	83 e9 57             	sub    $0x57,%ecx
f010393a:	eb 0e                	jmp    f010394a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010393c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010393f:	80 fb 19             	cmp    $0x19,%bl
f0103942:	77 13                	ja     f0103957 <strtol+0xad>
			dig = *s - 'A' + 10;
f0103944:	0f be c9             	movsbl %cl,%ecx
f0103947:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010394a:	39 f1                	cmp    %esi,%ecx
f010394c:	7d 0d                	jge    f010395b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010394e:	42                   	inc    %edx
f010394f:	0f af c6             	imul   %esi,%eax
f0103952:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103955:	eb c3                	jmp    f010391a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103957:	89 c1                	mov    %eax,%ecx
f0103959:	eb 02                	jmp    f010395d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010395b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010395d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103961:	74 05                	je     f0103968 <strtol+0xbe>
		*endptr = (char *) s;
f0103963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103966:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103968:	85 ff                	test   %edi,%edi
f010396a:	74 04                	je     f0103970 <strtol+0xc6>
f010396c:	89 c8                	mov    %ecx,%eax
f010396e:	f7 d8                	neg    %eax
}
f0103970:	5b                   	pop    %ebx
f0103971:	5e                   	pop    %esi
f0103972:	5f                   	pop    %edi
f0103973:	c9                   	leave  
f0103974:	c3                   	ret    
f0103975:	00 00                	add    %al,(%eax)
	...

f0103978 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103978:	55                   	push   %ebp
f0103979:	89 e5                	mov    %esp,%ebp
f010397b:	57                   	push   %edi
f010397c:	56                   	push   %esi
f010397d:	83 ec 10             	sub    $0x10,%esp
f0103980:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103983:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103986:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103989:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010398c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010398f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103992:	85 c0                	test   %eax,%eax
f0103994:	75 2e                	jne    f01039c4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0103996:	39 f1                	cmp    %esi,%ecx
f0103998:	77 5a                	ja     f01039f4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010399a:	85 c9                	test   %ecx,%ecx
f010399c:	75 0b                	jne    f01039a9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010399e:	b8 01 00 00 00       	mov    $0x1,%eax
f01039a3:	31 d2                	xor    %edx,%edx
f01039a5:	f7 f1                	div    %ecx
f01039a7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01039a9:	31 d2                	xor    %edx,%edx
f01039ab:	89 f0                	mov    %esi,%eax
f01039ad:	f7 f1                	div    %ecx
f01039af:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01039b1:	89 f8                	mov    %edi,%eax
f01039b3:	f7 f1                	div    %ecx
f01039b5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039b7:	89 f8                	mov    %edi,%eax
f01039b9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01039bb:	83 c4 10             	add    $0x10,%esp
f01039be:	5e                   	pop    %esi
f01039bf:	5f                   	pop    %edi
f01039c0:	c9                   	leave  
f01039c1:	c3                   	ret    
f01039c2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01039c4:	39 f0                	cmp    %esi,%eax
f01039c6:	77 1c                	ja     f01039e4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01039c8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01039cb:	83 f7 1f             	xor    $0x1f,%edi
f01039ce:	75 3c                	jne    f0103a0c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01039d0:	39 f0                	cmp    %esi,%eax
f01039d2:	0f 82 90 00 00 00    	jb     f0103a68 <__udivdi3+0xf0>
f01039d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01039db:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01039de:	0f 86 84 00 00 00    	jbe    f0103a68 <__udivdi3+0xf0>
f01039e4:	31 f6                	xor    %esi,%esi
f01039e6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039e8:	89 f8                	mov    %edi,%eax
f01039ea:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01039ec:	83 c4 10             	add    $0x10,%esp
f01039ef:	5e                   	pop    %esi
f01039f0:	5f                   	pop    %edi
f01039f1:	c9                   	leave  
f01039f2:	c3                   	ret    
f01039f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01039f4:	89 f2                	mov    %esi,%edx
f01039f6:	89 f8                	mov    %edi,%eax
f01039f8:	f7 f1                	div    %ecx
f01039fa:	89 c7                	mov    %eax,%edi
f01039fc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039fe:	89 f8                	mov    %edi,%eax
f0103a00:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a02:	83 c4 10             	add    $0x10,%esp
f0103a05:	5e                   	pop    %esi
f0103a06:	5f                   	pop    %edi
f0103a07:	c9                   	leave  
f0103a08:	c3                   	ret    
f0103a09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103a0c:	89 f9                	mov    %edi,%ecx
f0103a0e:	d3 e0                	shl    %cl,%eax
f0103a10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103a13:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a18:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103a1d:	88 c1                	mov    %al,%cl
f0103a1f:	d3 ea                	shr    %cl,%edx
f0103a21:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a24:	09 ca                	or     %ecx,%edx
f0103a26:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0103a29:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103a2c:	89 f9                	mov    %edi,%ecx
f0103a2e:	d3 e2                	shl    %cl,%edx
f0103a30:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0103a33:	89 f2                	mov    %esi,%edx
f0103a35:	88 c1                	mov    %al,%cl
f0103a37:	d3 ea                	shr    %cl,%edx
f0103a39:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103a3c:	89 f2                	mov    %esi,%edx
f0103a3e:	89 f9                	mov    %edi,%ecx
f0103a40:	d3 e2                	shl    %cl,%edx
f0103a42:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103a45:	88 c1                	mov    %al,%cl
f0103a47:	d3 ee                	shr    %cl,%esi
f0103a49:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103a4b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a4e:	89 f0                	mov    %esi,%eax
f0103a50:	89 ca                	mov    %ecx,%edx
f0103a52:	f7 75 ec             	divl   -0x14(%ebp)
f0103a55:	89 d1                	mov    %edx,%ecx
f0103a57:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103a59:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a5c:	39 d1                	cmp    %edx,%ecx
f0103a5e:	72 28                	jb     f0103a88 <__udivdi3+0x110>
f0103a60:	74 1a                	je     f0103a7c <__udivdi3+0x104>
f0103a62:	89 f7                	mov    %esi,%edi
f0103a64:	31 f6                	xor    %esi,%esi
f0103a66:	eb 80                	jmp    f01039e8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103a68:	31 f6                	xor    %esi,%esi
f0103a6a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a6f:	89 f8                	mov    %edi,%eax
f0103a71:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a73:	83 c4 10             	add    $0x10,%esp
f0103a76:	5e                   	pop    %esi
f0103a77:	5f                   	pop    %edi
f0103a78:	c9                   	leave  
f0103a79:	c3                   	ret    
f0103a7a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103a7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a7f:	89 f9                	mov    %edi,%ecx
f0103a81:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a83:	39 c2                	cmp    %eax,%edx
f0103a85:	73 db                	jae    f0103a62 <__udivdi3+0xea>
f0103a87:	90                   	nop
		{
		  q0--;
f0103a88:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103a8b:	31 f6                	xor    %esi,%esi
f0103a8d:	e9 56 ff ff ff       	jmp    f01039e8 <__udivdi3+0x70>
	...

f0103a94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103a94:	55                   	push   %ebp
f0103a95:	89 e5                	mov    %esp,%ebp
f0103a97:	57                   	push   %edi
f0103a98:	56                   	push   %esi
f0103a99:	83 ec 20             	sub    $0x20,%esp
f0103a9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103aa2:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103aa8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103aab:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103ab1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103ab3:	85 ff                	test   %edi,%edi
f0103ab5:	75 15                	jne    f0103acc <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103ab7:	39 f1                	cmp    %esi,%ecx
f0103ab9:	0f 86 99 00 00 00    	jbe    f0103b58 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103abf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103ac1:	89 d0                	mov    %edx,%eax
f0103ac3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103ac5:	83 c4 20             	add    $0x20,%esp
f0103ac8:	5e                   	pop    %esi
f0103ac9:	5f                   	pop    %edi
f0103aca:	c9                   	leave  
f0103acb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103acc:	39 f7                	cmp    %esi,%edi
f0103ace:	0f 87 a4 00 00 00    	ja     f0103b78 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103ad4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103ad7:	83 f0 1f             	xor    $0x1f,%eax
f0103ada:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103add:	0f 84 a1 00 00 00    	je     f0103b84 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103ae3:	89 f8                	mov    %edi,%eax
f0103ae5:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103ae8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103aea:	bf 20 00 00 00       	mov    $0x20,%edi
f0103aef:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103af5:	89 f9                	mov    %edi,%ecx
f0103af7:	d3 ea                	shr    %cl,%edx
f0103af9:	09 c2                	or     %eax,%edx
f0103afb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b01:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b04:	d3 e0                	shl    %cl,%eax
f0103b06:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b09:	89 f2                	mov    %esi,%edx
f0103b0b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103b0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b10:	d3 e0                	shl    %cl,%eax
f0103b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b18:	89 f9                	mov    %edi,%ecx
f0103b1a:	d3 e8                	shr    %cl,%eax
f0103b1c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103b1e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103b20:	89 f2                	mov    %esi,%edx
f0103b22:	f7 75 f0             	divl   -0x10(%ebp)
f0103b25:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103b27:	f7 65 f4             	mull   -0xc(%ebp)
f0103b2a:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103b2d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b2f:	39 d6                	cmp    %edx,%esi
f0103b31:	72 71                	jb     f0103ba4 <__umoddi3+0x110>
f0103b33:	74 7f                	je     f0103bb4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103b35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b38:	29 c8                	sub    %ecx,%eax
f0103b3a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103b3c:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b3f:	d3 e8                	shr    %cl,%eax
f0103b41:	89 f2                	mov    %esi,%edx
f0103b43:	89 f9                	mov    %edi,%ecx
f0103b45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103b47:	09 d0                	or     %edx,%eax
f0103b49:	89 f2                	mov    %esi,%edx
f0103b4b:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b4e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b50:	83 c4 20             	add    $0x20,%esp
f0103b53:	5e                   	pop    %esi
f0103b54:	5f                   	pop    %edi
f0103b55:	c9                   	leave  
f0103b56:	c3                   	ret    
f0103b57:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103b58:	85 c9                	test   %ecx,%ecx
f0103b5a:	75 0b                	jne    f0103b67 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103b5c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b61:	31 d2                	xor    %edx,%edx
f0103b63:	f7 f1                	div    %ecx
f0103b65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103b67:	89 f0                	mov    %esi,%eax
f0103b69:	31 d2                	xor    %edx,%edx
f0103b6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b70:	f7 f1                	div    %ecx
f0103b72:	e9 4a ff ff ff       	jmp    f0103ac1 <__umoddi3+0x2d>
f0103b77:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103b78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b7a:	83 c4 20             	add    $0x20,%esp
f0103b7d:	5e                   	pop    %esi
f0103b7e:	5f                   	pop    %edi
f0103b7f:	c9                   	leave  
f0103b80:	c3                   	ret    
f0103b81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103b84:	39 f7                	cmp    %esi,%edi
f0103b86:	72 05                	jb     f0103b8d <__umoddi3+0xf9>
f0103b88:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103b8b:	77 0c                	ja     f0103b99 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103b8d:	89 f2                	mov    %esi,%edx
f0103b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b92:	29 c8                	sub    %ecx,%eax
f0103b94:	19 fa                	sbb    %edi,%edx
f0103b96:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b9c:	83 c4 20             	add    $0x20,%esp
f0103b9f:	5e                   	pop    %esi
f0103ba0:	5f                   	pop    %edi
f0103ba1:	c9                   	leave  
f0103ba2:	c3                   	ret    
f0103ba3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103ba4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103ba7:	89 c1                	mov    %eax,%ecx
f0103ba9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103bac:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103baf:	eb 84                	jmp    f0103b35 <__umoddi3+0xa1>
f0103bb1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103bb4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103bb7:	72 eb                	jb     f0103ba4 <__umoddi3+0x110>
f0103bb9:	89 f2                	mov    %esi,%edx
f0103bbb:	e9 75 ff ff ff       	jmp    f0103b35 <__umoddi3+0xa1>
