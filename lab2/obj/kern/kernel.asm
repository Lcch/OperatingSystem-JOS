
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

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
f0100046:	b8 50 f9 11 f0       	mov    $0xf011f950,%eax
f010004b:	2d 00 f3 11 f0       	sub    $0xf011f300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 f3 11 f0       	push   $0xf011f300
f0100058:	e8 2c 38 00 00       	call   f0103889 <memset>

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
f010006a:	68 e0 3c 10 f0       	push   $0xf0103ce0
f010006f:	e8 e5 2c 00 00       	call   f0102d59 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 4f 16 00 00       	call   f01016c8 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 ac 0d 00 00       	call   f0100e32 <monitor>
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
f0100093:	83 3d 40 f9 11 f0 00 	cmpl   $0x0,0xf011f940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 f9 11 f0    	mov    %esi,0xf011f940

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
f01000b0:	68 fb 3c 10 f0       	push   $0xf0103cfb
f01000b5:	e8 9f 2c 00 00       	call   f0102d59 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 6f 2c 00 00       	call   f0102d33 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 f1 3f 10 f0 	movl   $0xf0103ff1,(%esp)
f01000cb:	e8 89 2c 00 00       	call   f0102d59 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 55 0d 00 00       	call   f0100e32 <monitor>
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
f01000f2:	68 13 3d 10 f0       	push   $0xf0103d13
f01000f7:	e8 5d 2c 00 00       	call   f0102d59 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 2b 2c 00 00       	call   f0102d33 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 f1 3f 10 f0 	movl   $0xf0103ff1,(%esp)
f010010f:	e8 45 2c 00 00       	call   f0102d59 <cprintf>
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
f0100155:	8b 15 24 f5 11 f0    	mov    0xf011f524,%edx
f010015b:	88 82 20 f3 11 f0    	mov    %al,-0xfee0ce0(%edx)
f0100161:	8d 42 01             	lea    0x1(%edx),%eax
f0100164:	a3 24 f5 11 f0       	mov    %eax,0xf011f524
		if (cons.wpos == CONSBUFSIZE)
f0100169:	3d 00 02 00 00       	cmp    $0x200,%eax
f010016e:	75 0a                	jne    f010017a <cons_intr+0x34>
			cons.wpos = 0;
f0100170:	c7 05 24 f5 11 f0 00 	movl   $0x0,0xf011f524
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
f01001f3:	a1 00 f3 11 f0       	mov    0xf011f300,%eax
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
f0100237:	66 a1 04 f3 11 f0    	mov    0xf011f304,%ax
f010023d:	66 85 c0             	test   %ax,%ax
f0100240:	0f 84 e0 00 00 00    	je     f0100326 <cons_putc+0x19f>
			crt_pos--;
f0100246:	48                   	dec    %eax
f0100247:	66 a3 04 f3 11 f0    	mov    %ax,0xf011f304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010024d:	0f b7 c0             	movzwl %ax,%eax
f0100250:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100256:	83 ce 20             	or     $0x20,%esi
f0100259:	8b 15 08 f3 11 f0    	mov    0xf011f308,%edx
f010025f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100263:	eb 78                	jmp    f01002dd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100265:	66 83 05 04 f3 11 f0 	addw   $0x50,0xf011f304
f010026c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010026d:	66 8b 0d 04 f3 11 f0 	mov    0xf011f304,%cx
f0100274:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100279:	89 c8                	mov    %ecx,%eax
f010027b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100280:	66 f7 f3             	div    %bx
f0100283:	66 29 d1             	sub    %dx,%cx
f0100286:	66 89 0d 04 f3 11 f0 	mov    %cx,0xf011f304
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
f01002c3:	66 a1 04 f3 11 f0    	mov    0xf011f304,%ax
f01002c9:	0f b7 c8             	movzwl %ax,%ecx
f01002cc:	8b 15 08 f3 11 f0    	mov    0xf011f308,%edx
f01002d2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002d6:	40                   	inc    %eax
f01002d7:	66 a3 04 f3 11 f0    	mov    %ax,0xf011f304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002dd:	66 81 3d 04 f3 11 f0 	cmpw   $0x7cf,0xf011f304
f01002e4:	cf 07 
f01002e6:	76 3e                	jbe    f0100326 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002e8:	a1 08 f3 11 f0       	mov    0xf011f308,%eax
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	68 00 0f 00 00       	push   $0xf00
f01002f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002fb:	52                   	push   %edx
f01002fc:	50                   	push   %eax
f01002fd:	e8 d1 35 00 00       	call   f01038d3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100302:	8b 15 08 f3 11 f0    	mov    0xf011f308,%edx
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
f010031e:	66 83 2d 04 f3 11 f0 	subw   $0x50,0xf011f304
f0100325:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100326:	8b 0d 0c f3 11 f0    	mov    0xf011f30c,%ecx
f010032c:	b0 0e                	mov    $0xe,%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100331:	66 8b 35 04 f3 11 f0 	mov    0xf011f304,%si
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
f0100374:	83 0d 28 f5 11 f0 40 	orl    $0x40,0xf011f528
		return 0;
f010037b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100380:	e9 c7 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100385:	84 c0                	test   %al,%al
f0100387:	79 33                	jns    f01003bc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100389:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f010038f:	f6 c1 40             	test   $0x40,%cl
f0100392:	75 05                	jne    f0100399 <kbd_proc_data+0x43>
f0100394:	88 c2                	mov    %al,%dl
f0100396:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100399:	0f b6 d2             	movzbl %dl,%edx
f010039c:	8a 82 60 3d 10 f0    	mov    -0xfefc2a0(%edx),%al
f01003a2:	83 c8 40             	or     $0x40,%eax
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	f7 d0                	not    %eax
f01003aa:	21 c1                	and    %eax,%ecx
f01003ac:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
		return 0;
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	e9 90 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003bc:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f01003c2:	f6 c1 40             	test   $0x40,%cl
f01003c5:	74 0e                	je     f01003d5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c7:	88 c2                	mov    %al,%dl
f01003c9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003cc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003cf:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
	}

	shift |= shiftcode[data];
f01003d5:	0f b6 d2             	movzbl %dl,%edx
f01003d8:	0f b6 82 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%eax
f01003df:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 60 3e 10 f0 	movzbl -0xfefc1a0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 60 3f 10 f0 	mov    -0xfefc0a0(,%ecx,4),%ecx
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
f0100430:	68 2d 3d 10 f0       	push   $0xf0103d2d
f0100435:	e8 1f 29 00 00       	call   f0102d59 <cprintf>
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
f0100459:	80 3d 10 f3 11 f0 00 	cmpb   $0x0,0xf011f310
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
f0100490:	8b 15 20 f5 11 f0    	mov    0xf011f520,%edx
f0100496:	3b 15 24 f5 11 f0    	cmp    0xf011f524,%edx
f010049c:	74 22                	je     f01004c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010049e:	0f b6 82 20 f3 11 f0 	movzbl -0xfee0ce0(%edx),%eax
f01004a5:	42                   	inc    %edx
f01004a6:	89 15 20 f5 11 f0    	mov    %edx,0xf011f520
		if (cons.rpos == CONSBUFSIZE)
f01004ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b2:	75 11                	jne    f01004c5 <cons_getc+0x45>
			cons.rpos = 0;
f01004b4:	c7 05 20 f5 11 f0 00 	movl   $0x0,0xf011f520
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
f01004ec:	c7 05 0c f3 11 f0 b4 	movl   $0x3b4,0xf011f30c
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
f0100504:	c7 05 0c f3 11 f0 d4 	movl   $0x3d4,0xf011f30c
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
f0100513:	8b 0d 0c f3 11 f0    	mov    0xf011f30c,%ecx
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
f0100532:	89 35 08 f3 11 f0    	mov    %esi,0xf011f308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100538:	0f b6 d8             	movzbl %al,%ebx
f010053b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010053d:	66 89 3d 04 f3 11 f0 	mov    %di,0xf011f304
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
f010057d:	a2 10 f3 11 f0       	mov    %al,0xf011f310
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
f0100591:	68 39 3d 10 f0       	push   $0xf0103d39
f0100596:	e8 be 27 00 00       	call   f0102d59 <cprintf>
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
f01005da:	68 70 3f 10 f0       	push   $0xf0103f70
f01005df:	e8 75 27 00 00       	call   f0102d59 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 a8 41 10 f0       	push   $0xf01041a8
f01005f1:	e8 63 27 00 00       	call   f0102d59 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 d0 41 10 f0       	push   $0xf01041d0
f0100608:	e8 4c 27 00 00       	call   f0102d59 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 d8 3c 10 00       	push   $0x103cd8
f0100615:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010061a:	68 f4 41 10 f0       	push   $0xf01041f4
f010061f:	e8 35 27 00 00       	call   f0102d59 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 f3 11 00       	push   $0x11f300
f010062c:	68 00 f3 11 f0       	push   $0xf011f300
f0100631:	68 18 42 10 f0       	push   $0xf0104218
f0100636:	e8 1e 27 00 00       	call   f0102d59 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 f9 11 00       	push   $0x11f950
f0100643:	68 50 f9 11 f0       	push   $0xf011f950
f0100648:	68 3c 42 10 f0       	push   $0xf010423c
f010064d:	e8 07 27 00 00       	call   f0102d59 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100652:	b8 4f fd 11 f0       	mov    $0xf011fd4f,%eax
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
f0100674:	68 60 42 10 f0       	push   $0xf0104260
f0100679:	e8 db 26 00 00       	call   f0102d59 <cprintf>
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
f0100694:	ff b3 44 47 10 f0    	pushl  -0xfefb8bc(%ebx)
f010069a:	ff b3 40 47 10 f0    	pushl  -0xfefb8c0(%ebx)
f01006a0:	68 89 3f 10 f0       	push   $0xf0103f89
f01006a5:	e8 af 26 00 00       	call   f0102d59 <cprintf>
f01006aa:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006ad:	83 c4 10             	add    $0x10,%esp
f01006b0:	83 fb 60             	cmp    $0x60,%ebx
f01006b3:	75 dc                	jne    f0100691 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006bd:	c9                   	leave  
f01006be:	c3                   	ret    

f01006bf <mon_kernelpd>:
    return 0;
}

int 
mon_kernelpd(int argc, char **argv, struct Trapframe *tf)
{
f01006bf:	55                   	push   %ebp
f01006c0:	89 e5                	mov    %esp,%ebp
f01006c2:	83 ec 08             	sub    $0x8,%esp
    if (argc != 2) {
f01006c5:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01006c9:	74 2a                	je     f01006f5 <mon_kernelpd+0x36>
        cprintf("Command should be: kernelpd [entry_num]\n");
f01006cb:	83 ec 0c             	sub    $0xc,%esp
f01006ce:	68 8c 42 10 f0       	push   $0xf010428c
f01006d3:	e8 81 26 00 00       	call   f0102d59 <cprintf>
        cprintf("Example: kernelpd 0x01\n");
f01006d8:	c7 04 24 92 3f 10 f0 	movl   $0xf0103f92,(%esp)
f01006df:	e8 75 26 00 00       	call   f0102d59 <cprintf>
        cprintf("         show kernel page directory[1] infomation \n");
f01006e4:	c7 04 24 b8 42 10 f0 	movl   $0xf01042b8,(%esp)
f01006eb:	e8 69 26 00 00       	call   f0102d59 <cprintf>
f01006f0:	83 c4 10             	add    $0x10,%esp
f01006f3:	eb 48                	jmp    f010073d <mon_kernelpd+0x7e>
    } else {
        uint32_t id = strtol(argv[1], NULL, 0);
f01006f5:	83 ec 04             	sub    $0x4,%esp
f01006f8:	6a 00                	push   $0x0
f01006fa:	6a 00                	push   $0x0
f01006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01006ff:	ff 70 04             	pushl  0x4(%eax)
f0100702:	e8 bb 32 00 00       	call   f01039c2 <strtol>
        if (0 > id || id >= 1024) {
f0100707:	83 c4 10             	add    $0x10,%esp
f010070a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010070f:	76 12                	jbe    f0100723 <mon_kernelpd+0x64>
            cprintf("out of entry num, it should be in [0, 1024)\n");
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	68 ec 42 10 f0       	push   $0xf01042ec
f0100719:	e8 3b 26 00 00       	call   f0102d59 <cprintf>
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	eb 1a                	jmp    f010073d <mon_kernelpd+0x7e>
        } else {
            cprintf("pgdir[%d] = 0x%08x\n", id, (uint32_t)kern_pgdir[id]);
f0100723:	83 ec 04             	sub    $0x4,%esp
f0100726:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f010072c:	ff 34 82             	pushl  (%edx,%eax,4)
f010072f:	50                   	push   %eax
f0100730:	68 aa 3f 10 f0       	push   $0xf0103faa
f0100735:	e8 1f 26 00 00       	call   f0102d59 <cprintf>
f010073a:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	c9                   	leave  
f0100743:	c3                   	ret    

f0100744 <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100744:	55                   	push   %ebp
f0100745:	89 e5                	mov    %esp,%ebp
f0100747:	57                   	push   %edi
f0100748:	56                   	push   %esi
f0100749:	53                   	push   %ebx
f010074a:	83 ec 0c             	sub    $0xc,%esp
f010074d:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100750:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100754:	74 21                	je     f0100777 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100756:	83 ec 0c             	sub    $0xc,%esp
f0100759:	68 1c 43 10 f0       	push   $0xf010431c
f010075e:	e8 f6 25 00 00       	call   f0102d59 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100763:	c7 04 24 50 43 10 f0 	movl   $0xf0104350,(%esp)
f010076a:	e8 ea 25 00 00       	call   f0102d59 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
f0100772:	e9 1a 01 00 00       	jmp    f0100891 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100777:	83 ec 04             	sub    $0x4,%esp
f010077a:	6a 00                	push   $0x0
f010077c:	6a 00                	push   $0x0
f010077e:	ff 76 04             	pushl  0x4(%esi)
f0100781:	e8 3c 32 00 00       	call   f01039c2 <strtol>
f0100786:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100788:	83 c4 0c             	add    $0xc,%esp
f010078b:	6a 00                	push   $0x0
f010078d:	6a 00                	push   $0x0
f010078f:	ff 76 08             	pushl  0x8(%esi)
f0100792:	e8 2b 32 00 00       	call   f01039c2 <strtol>
        if (laddr > haddr) {
f0100797:	83 c4 10             	add    $0x10,%esp
f010079a:	39 c3                	cmp    %eax,%ebx
f010079c:	76 01                	jbe    f010079f <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f010079e:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f010079f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01007a5:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01007ab:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01007b1:	83 ec 04             	sub    $0x4,%esp
f01007b4:	57                   	push   %edi
f01007b5:	53                   	push   %ebx
f01007b6:	68 be 3f 10 f0       	push   $0xf0103fbe
f01007bb:	e8 99 25 00 00       	call   f0102d59 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01007c0:	83 c4 10             	add    $0x10,%esp
f01007c3:	39 fb                	cmp    %edi,%ebx
f01007c5:	75 07                	jne    f01007ce <mon_showmappings+0x8a>
f01007c7:	e9 c5 00 00 00       	jmp    f0100891 <mon_showmappings+0x14d>
f01007cc:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f01007ce:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f01007d4:	83 ec 04             	sub    $0x4,%esp
f01007d7:	56                   	push   %esi
f01007d8:	53                   	push   %ebx
f01007d9:	68 cf 3f 10 f0       	push   $0xf0103fcf
f01007de:	e8 76 25 00 00       	call   f0102d59 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	6a 00                	push   $0x0
f01007e8:	53                   	push   %ebx
f01007e9:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01007ef:	e8 7e 0c 00 00       	call   f0101472 <pgdir_walk>
f01007f4:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f01007f6:	83 c4 10             	add    $0x10,%esp
f01007f9:	85 c0                	test   %eax,%eax
f01007fb:	74 06                	je     f0100803 <mon_showmappings+0xbf>
f01007fd:	8b 00                	mov    (%eax),%eax
f01007ff:	a8 01                	test   $0x1,%al
f0100801:	75 12                	jne    f0100815 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100803:	83 ec 0c             	sub    $0xc,%esp
f0100806:	68 e6 3f 10 f0       	push   $0xf0103fe6
f010080b:	e8 49 25 00 00       	call   f0102d59 <cprintf>
f0100810:	83 c4 10             	add    $0x10,%esp
f0100813:	eb 74                	jmp    f0100889 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100815:	83 ec 08             	sub    $0x8,%esp
f0100818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010081d:	50                   	push   %eax
f010081e:	68 f3 3f 10 f0       	push   $0xf0103ff3
f0100823:	e8 31 25 00 00       	call   f0102d59 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	f6 03 04             	testb  $0x4,(%ebx)
f010082e:	74 12                	je     f0100842 <mon_showmappings+0xfe>
f0100830:	83 ec 0c             	sub    $0xc,%esp
f0100833:	68 fb 3f 10 f0       	push   $0xf0103ffb
f0100838:	e8 1c 25 00 00       	call   f0102d59 <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp
f0100840:	eb 10                	jmp    f0100852 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100842:	83 ec 0c             	sub    $0xc,%esp
f0100845:	68 08 40 10 f0       	push   $0xf0104008
f010084a:	e8 0a 25 00 00       	call   f0102d59 <cprintf>
f010084f:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100852:	f6 03 02             	testb  $0x2,(%ebx)
f0100855:	74 12                	je     f0100869 <mon_showmappings+0x125>
f0100857:	83 ec 0c             	sub    $0xc,%esp
f010085a:	68 15 40 10 f0       	push   $0xf0104015
f010085f:	e8 f5 24 00 00       	call   f0102d59 <cprintf>
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	eb 10                	jmp    f0100879 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100869:	83 ec 0c             	sub    $0xc,%esp
f010086c:	68 1a 40 10 f0       	push   $0xf010401a
f0100871:	e8 e3 24 00 00       	call   f0102d59 <cprintf>
f0100876:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100879:	83 ec 0c             	sub    $0xc,%esp
f010087c:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100881:	e8 d3 24 00 00       	call   f0102d59 <cprintf>
f0100886:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100889:	39 f7                	cmp    %esi,%edi
f010088b:	0f 85 3b ff ff ff    	jne    f01007cc <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100891:	b8 00 00 00 00       	mov    $0x0,%eax
f0100896:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100899:	5b                   	pop    %ebx
f010089a:	5e                   	pop    %esi
f010089b:	5f                   	pop    %edi
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	55                   	push   %ebp
f010089f:	89 e5                	mov    %esp,%ebp
f01008a1:	57                   	push   %edi
f01008a2:	56                   	push   %esi
f01008a3:	53                   	push   %ebx
f01008a4:	83 ec 0c             	sub    $0xc,%esp
f01008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f01008aa:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f01008ae:	74 21                	je     f01008d1 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f01008b0:	83 ec 0c             	sub    $0xc,%esp
f01008b3:	68 78 43 10 f0       	push   $0xf0104378
f01008b8:	e8 9c 24 00 00       	call   f0102d59 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008bd:	c7 04 24 c8 43 10 f0 	movl   $0xf01043c8,(%esp)
f01008c4:	e8 90 24 00 00       	call   f0102d59 <cprintf>
f01008c9:	83 c4 10             	add    $0x10,%esp
f01008cc:	e9 a5 01 00 00       	jmp    f0100a76 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f01008d1:	83 ec 04             	sub    $0x4,%esp
f01008d4:	6a 00                	push   $0x0
f01008d6:	6a 00                	push   $0x0
f01008d8:	ff 73 04             	pushl  0x4(%ebx)
f01008db:	e8 e2 30 00 00       	call   f01039c2 <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f01008e0:	8b 53 08             	mov    0x8(%ebx),%edx
f01008e3:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f01008e6:	80 3a 31             	cmpb   $0x31,(%edx)
f01008e9:	0f 94 c2             	sete   %dl
f01008ec:	0f b6 d2             	movzbl %dl,%edx
f01008ef:	89 d6                	mov    %edx,%esi
f01008f1:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f01008f3:	8b 53 0c             	mov    0xc(%ebx),%edx
f01008f6:	80 3a 31             	cmpb   $0x31,(%edx)
f01008f9:	75 03                	jne    f01008fe <mon_setpermission+0x60>
f01008fb:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f01008fe:	8b 53 10             	mov    0x10(%ebx),%edx
f0100901:	80 3a 31             	cmpb   $0x31,(%edx)
f0100904:	75 03                	jne    f0100909 <mon_setpermission+0x6b>
f0100906:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100909:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f010090f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100915:	83 ec 04             	sub    $0x4,%esp
f0100918:	6a 00                	push   $0x0
f010091a:	57                   	push   %edi
f010091b:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0100921:	e8 4c 0b 00 00       	call   f0101472 <pgdir_walk>
f0100926:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	85 c0                	test   %eax,%eax
f010092d:	0f 84 33 01 00 00    	je     f0100a66 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100933:	83 ec 04             	sub    $0x4,%esp
f0100936:	8b 00                	mov    (%eax),%eax
f0100938:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010093d:	50                   	push   %eax
f010093e:	57                   	push   %edi
f010093f:	68 ec 43 10 f0       	push   $0xf01043ec
f0100944:	e8 10 24 00 00       	call   f0102d59 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	f6 03 02             	testb  $0x2,(%ebx)
f010094f:	74 12                	je     f0100963 <mon_setpermission+0xc5>
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	68 1e 40 10 f0       	push   $0xf010401e
f0100959:	e8 fb 23 00 00       	call   f0102d59 <cprintf>
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	eb 10                	jmp    f0100973 <mon_setpermission+0xd5>
f0100963:	83 ec 0c             	sub    $0xc,%esp
f0100966:	68 21 40 10 f0       	push   $0xf0104021
f010096b:	e8 e9 23 00 00       	call   f0102d59 <cprintf>
f0100970:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100973:	f6 03 04             	testb  $0x4,(%ebx)
f0100976:	74 12                	je     f010098a <mon_setpermission+0xec>
f0100978:	83 ec 0c             	sub    $0xc,%esp
f010097b:	68 c5 50 10 f0       	push   $0xf01050c5
f0100980:	e8 d4 23 00 00       	call   f0102d59 <cprintf>
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	eb 10                	jmp    f010099a <mon_setpermission+0xfc>
f010098a:	83 ec 0c             	sub    $0xc,%esp
f010098d:	68 24 40 10 f0       	push   $0xf0104024
f0100992:	e8 c2 23 00 00       	call   f0102d59 <cprintf>
f0100997:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f010099a:	f6 03 01             	testb  $0x1,(%ebx)
f010099d:	74 12                	je     f01009b1 <mon_setpermission+0x113>
f010099f:	83 ec 0c             	sub    $0xc,%esp
f01009a2:	68 51 51 10 f0       	push   $0xf0105151
f01009a7:	e8 ad 23 00 00       	call   f0102d59 <cprintf>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	eb 10                	jmp    f01009c1 <mon_setpermission+0x123>
f01009b1:	83 ec 0c             	sub    $0xc,%esp
f01009b4:	68 22 40 10 f0       	push   $0xf0104022
f01009b9:	e8 9b 23 00 00       	call   f0102d59 <cprintf>
f01009be:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f01009c1:	83 ec 0c             	sub    $0xc,%esp
f01009c4:	68 26 40 10 f0       	push   $0xf0104026
f01009c9:	e8 8b 23 00 00       	call   f0102d59 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f01009ce:	8b 03                	mov    (%ebx),%eax
f01009d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d5:	09 c6                	or     %eax,%esi
f01009d7:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01009d9:	83 c4 10             	add    $0x10,%esp
f01009dc:	f7 c6 02 00 00 00    	test   $0x2,%esi
f01009e2:	74 12                	je     f01009f6 <mon_setpermission+0x158>
f01009e4:	83 ec 0c             	sub    $0xc,%esp
f01009e7:	68 1e 40 10 f0       	push   $0xf010401e
f01009ec:	e8 68 23 00 00       	call   f0102d59 <cprintf>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	eb 10                	jmp    f0100a06 <mon_setpermission+0x168>
f01009f6:	83 ec 0c             	sub    $0xc,%esp
f01009f9:	68 21 40 10 f0       	push   $0xf0104021
f01009fe:	e8 56 23 00 00       	call   f0102d59 <cprintf>
f0100a03:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a06:	f6 03 04             	testb  $0x4,(%ebx)
f0100a09:	74 12                	je     f0100a1d <mon_setpermission+0x17f>
f0100a0b:	83 ec 0c             	sub    $0xc,%esp
f0100a0e:	68 c5 50 10 f0       	push   $0xf01050c5
f0100a13:	e8 41 23 00 00       	call   f0102d59 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	eb 10                	jmp    f0100a2d <mon_setpermission+0x18f>
f0100a1d:	83 ec 0c             	sub    $0xc,%esp
f0100a20:	68 24 40 10 f0       	push   $0xf0104024
f0100a25:	e8 2f 23 00 00       	call   f0102d59 <cprintf>
f0100a2a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a2d:	f6 03 01             	testb  $0x1,(%ebx)
f0100a30:	74 12                	je     f0100a44 <mon_setpermission+0x1a6>
f0100a32:	83 ec 0c             	sub    $0xc,%esp
f0100a35:	68 51 51 10 f0       	push   $0xf0105151
f0100a3a:	e8 1a 23 00 00       	call   f0102d59 <cprintf>
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	eb 10                	jmp    f0100a54 <mon_setpermission+0x1b6>
f0100a44:	83 ec 0c             	sub    $0xc,%esp
f0100a47:	68 22 40 10 f0       	push   $0xf0104022
f0100a4c:	e8 08 23 00 00       	call   f0102d59 <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a54:	83 ec 0c             	sub    $0xc,%esp
f0100a57:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100a5c:	e8 f8 22 00 00       	call   f0102d59 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
f0100a64:	eb 10                	jmp    f0100a76 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a66:	83 ec 0c             	sub    $0xc,%esp
f0100a69:	68 e6 3f 10 f0       	push   $0xf0103fe6
f0100a6e:	e8 e6 22 00 00       	call   f0102d59 <cprintf>
f0100a73:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100a76:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a7e:	5b                   	pop    %ebx
f0100a7f:	5e                   	pop    %esi
f0100a80:	5f                   	pop    %edi
f0100a81:	c9                   	leave  
f0100a82:	c3                   	ret    

f0100a83 <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100a83:	55                   	push   %ebp
f0100a84:	89 e5                	mov    %esp,%ebp
f0100a86:	56                   	push   %esi
f0100a87:	53                   	push   %ebx
f0100a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100a8b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a8f:	74 66                	je     f0100af7 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100a91:	83 ec 0c             	sub    $0xc,%esp
f0100a94:	68 10 44 10 f0       	push   $0xf0104410
f0100a99:	e8 bb 22 00 00       	call   f0102d59 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a9e:	c7 04 24 40 44 10 f0 	movl   $0xf0104440,(%esp)
f0100aa5:	e8 af 22 00 00       	call   f0102d59 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100aaa:	c7 04 24 60 44 10 f0 	movl   $0xf0104460,(%esp)
f0100ab1:	e8 a3 22 00 00       	call   f0102d59 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ab6:	c7 04 24 94 44 10 f0 	movl   $0xf0104494,(%esp)
f0100abd:	e8 97 22 00 00       	call   f0102d59 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100ac2:	c7 04 24 d8 44 10 f0 	movl   $0xf01044d8,(%esp)
f0100ac9:	e8 8b 22 00 00       	call   f0102d59 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ace:	c7 04 24 37 40 10 f0 	movl   $0xf0104037,(%esp)
f0100ad5:	e8 7f 22 00 00       	call   f0102d59 <cprintf>
        cprintf("         set the background color to black\n");
f0100ada:	c7 04 24 1c 45 10 f0 	movl   $0xf010451c,(%esp)
f0100ae1:	e8 73 22 00 00       	call   f0102d59 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100ae6:	c7 04 24 48 45 10 f0 	movl   $0xf0104548,(%esp)
f0100aed:	e8 67 22 00 00       	call   f0102d59 <cprintf>
f0100af2:	83 c4 10             	add    $0x10,%esp
f0100af5:	eb 52                	jmp    f0100b49 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100af7:	83 ec 0c             	sub    $0xc,%esp
f0100afa:	ff 73 04             	pushl  0x4(%ebx)
f0100afd:	e8 be 2b 00 00       	call   f01036c0 <strlen>
f0100b02:	83 c4 10             	add    $0x10,%esp
f0100b05:	48                   	dec    %eax
f0100b06:	78 26                	js     f0100b2e <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100b08:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b0b:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b10:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100b15:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100b19:	0f 94 c3             	sete   %bl
f0100b1c:	0f b6 db             	movzbl %bl,%ebx
f0100b1f:	d3 e3                	shl    %cl,%ebx
f0100b21:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b23:	48                   	dec    %eax
f0100b24:	78 0d                	js     f0100b33 <mon_setcolor+0xb0>
f0100b26:	41                   	inc    %ecx
f0100b27:	83 f9 08             	cmp    $0x8,%ecx
f0100b2a:	75 e9                	jne    f0100b15 <mon_setcolor+0x92>
f0100b2c:	eb 05                	jmp    f0100b33 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b2e:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100b33:	89 15 00 f3 11 f0    	mov    %edx,0xf011f300
        cprintf(" This is color that you want ! \n");
f0100b39:	83 ec 0c             	sub    $0xc,%esp
f0100b3c:	68 7c 45 10 f0       	push   $0xf010457c
f0100b41:	e8 13 22 00 00       	call   f0102d59 <cprintf>
f0100b46:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100b49:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b51:	5b                   	pop    %ebx
f0100b52:	5e                   	pop    %esi
f0100b53:	c9                   	leave  
f0100b54:	c3                   	ret    

f0100b55 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100b55:	55                   	push   %ebp
f0100b56:	89 e5                	mov    %esp,%ebp
f0100b58:	57                   	push   %edi
f0100b59:	56                   	push   %esi
f0100b5a:	53                   	push   %ebx
f0100b5b:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100b5e:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100b60:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b62:	85 c0                	test   %eax,%eax
f0100b64:	74 6d                	je     f0100bd3 <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b66:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100b69:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100b6c:	ff 76 18             	pushl  0x18(%esi)
f0100b6f:	ff 76 14             	pushl  0x14(%esi)
f0100b72:	ff 76 10             	pushl  0x10(%esi)
f0100b75:	ff 76 0c             	pushl  0xc(%esi)
f0100b78:	ff 76 08             	pushl  0x8(%esi)
f0100b7b:	53                   	push   %ebx
f0100b7c:	56                   	push   %esi
f0100b7d:	68 a0 45 10 f0       	push   $0xf01045a0
f0100b82:	e8 d2 21 00 00       	call   f0102d59 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b87:	83 c4 18             	add    $0x18,%esp
f0100b8a:	57                   	push   %edi
f0100b8b:	ff 76 04             	pushl  0x4(%esi)
f0100b8e:	e8 02 23 00 00       	call   f0102e95 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b93:	83 c4 0c             	add    $0xc,%esp
f0100b96:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b99:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b9c:	68 53 40 10 f0       	push   $0xf0104053
f0100ba1:	e8 b3 21 00 00       	call   f0102d59 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100ba6:	83 c4 0c             	add    $0xc,%esp
f0100ba9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100bac:	ff 75 dc             	pushl  -0x24(%ebp)
f0100baf:	68 63 40 10 f0       	push   $0xf0104063
f0100bb4:	e8 a0 21 00 00       	call   f0102d59 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100bb9:	83 c4 08             	add    $0x8,%esp
f0100bbc:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100bbf:	53                   	push   %ebx
f0100bc0:	68 68 40 10 f0       	push   $0xf0104068
f0100bc5:	e8 8f 21 00 00       	call   f0102d59 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100bca:	8b 36                	mov    (%esi),%esi
f0100bcc:	83 c4 10             	add    $0x10,%esp
f0100bcf:	85 f6                	test   %esi,%esi
f0100bd1:	75 96                	jne    f0100b69 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100bd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bdb:	5b                   	pop    %ebx
f0100bdc:	5e                   	pop    %esi
f0100bdd:	5f                   	pop    %edi
f0100bde:	c9                   	leave  
f0100bdf:	c3                   	ret    

f0100be0 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
f0100be3:	53                   	push   %ebx
f0100be4:	83 ec 04             	sub    $0x4,%esp
f0100be7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100bed:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bf3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bf9:	77 15                	ja     f0100c10 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bfb:	52                   	push   %edx
f0100bfc:	68 d8 45 10 f0       	push   $0xf01045d8
f0100c01:	68 93 00 00 00       	push   $0x93
f0100c06:	68 6d 40 10 f0       	push   $0xf010406d
f0100c0b:	e8 7b f4 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c10:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100c16:	39 d0                	cmp    %edx,%eax
f0100c18:	72 18                	jb     f0100c32 <pa_con+0x52>
f0100c1a:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100c20:	39 d8                	cmp    %ebx,%eax
f0100c22:	73 0e                	jae    f0100c32 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100c24:	29 d0                	sub    %edx,%eax
f0100c26:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100c2c:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c2e:	b0 01                	mov    $0x1,%al
f0100c30:	eb 56                	jmp    f0100c88 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c32:	ba 00 50 11 f0       	mov    $0xf0115000,%edx
f0100c37:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c3d:	77 15                	ja     f0100c54 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c3f:	52                   	push   %edx
f0100c40:	68 d8 45 10 f0       	push   $0xf01045d8
f0100c45:	68 98 00 00 00       	push   $0x98
f0100c4a:	68 6d 40 10 f0       	push   $0xf010406d
f0100c4f:	e8 37 f4 ff ff       	call   f010008b <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100c54:	3d 00 50 11 00       	cmp    $0x115000,%eax
f0100c59:	72 18                	jb     f0100c73 <pa_con+0x93>
f0100c5b:	3d 00 d0 11 00       	cmp    $0x11d000,%eax
f0100c60:	73 11                	jae    f0100c73 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100c62:	2d 00 50 11 00       	sub    $0x115000,%eax
f0100c67:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100c6d:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c6f:	b0 01                	mov    $0x1,%al
f0100c71:	eb 15                	jmp    f0100c88 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100c73:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100c78:	77 0c                	ja     f0100c86 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100c7a:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100c80:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c82:	b0 01                	mov    $0x1,%al
f0100c84:	eb 02                	jmp    f0100c88 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100c86:	b0 00                	mov    $0x0,%al
}
f0100c88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c8b:	c9                   	leave  
f0100c8c:	c3                   	ret    

f0100c8d <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100c8d:	55                   	push   %ebp
f0100c8e:	89 e5                	mov    %esp,%ebp
f0100c90:	57                   	push   %edi
f0100c91:	56                   	push   %esi
f0100c92:	53                   	push   %ebx
f0100c93:	83 ec 2c             	sub    $0x2c,%esp
f0100c96:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100c99:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c9d:	74 2d                	je     f0100ccc <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100c9f:	83 ec 0c             	sub    $0xc,%esp
f0100ca2:	68 fc 45 10 f0       	push   $0xf01045fc
f0100ca7:	e8 ad 20 00 00       	call   f0102d59 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100cac:	c7 04 24 2c 46 10 f0 	movl   $0xf010462c,(%esp)
f0100cb3:	e8 a1 20 00 00       	call   f0102d59 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100cb8:	c7 04 24 54 46 10 f0 	movl   $0xf0104654,(%esp)
f0100cbf:	e8 95 20 00 00       	call   f0102d59 <cprintf>
f0100cc4:	83 c4 10             	add    $0x10,%esp
f0100cc7:	e9 59 01 00 00       	jmp    f0100e25 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ccc:	83 ec 04             	sub    $0x4,%esp
f0100ccf:	6a 00                	push   $0x0
f0100cd1:	6a 00                	push   $0x0
f0100cd3:	ff 76 08             	pushl  0x8(%esi)
f0100cd6:	e8 e7 2c 00 00       	call   f01039c2 <strtol>
f0100cdb:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100cdd:	83 c4 0c             	add    $0xc,%esp
f0100ce0:	6a 00                	push   $0x0
f0100ce2:	6a 00                	push   $0x0
f0100ce4:	ff 76 0c             	pushl  0xc(%esi)
f0100ce7:	e8 d6 2c 00 00       	call   f01039c2 <strtol>
        if (laddr > haddr) {
f0100cec:	83 c4 10             	add    $0x10,%esp
f0100cef:	39 c3                	cmp    %eax,%ebx
f0100cf1:	76 01                	jbe    f0100cf4 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100cf3:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100cf4:	89 df                	mov    %ebx,%edi
f0100cf6:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100cf9:	83 e0 fc             	and    $0xfffffffc,%eax
f0100cfc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100cff:	8b 46 04             	mov    0x4(%esi),%eax
f0100d02:	80 38 76             	cmpb   $0x76,(%eax)
f0100d05:	74 0e                	je     f0100d15 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d07:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d0a:	0f 85 98 00 00 00    	jne    f0100da8 <mon_dump+0x11b>
f0100d10:	e9 00 01 00 00       	jmp    f0100e15 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d15:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d18:	74 7c                	je     f0100d96 <mon_dump+0x109>
f0100d1a:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d1c:	39 fb                	cmp    %edi,%ebx
f0100d1e:	74 15                	je     f0100d35 <mon_dump+0xa8>
f0100d20:	f6 c3 0f             	test   $0xf,%bl
f0100d23:	75 21                	jne    f0100d46 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100d25:	83 ec 0c             	sub    $0xc,%esp
f0100d28:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100d2d:	e8 27 20 00 00       	call   f0102d59 <cprintf>
f0100d32:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d35:	83 ec 08             	sub    $0x8,%esp
f0100d38:	53                   	push   %ebx
f0100d39:	68 7c 40 10 f0       	push   $0xf010407c
f0100d3e:	e8 16 20 00 00       	call   f0102d59 <cprintf>
f0100d43:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d46:	83 ec 04             	sub    $0x4,%esp
f0100d49:	6a 00                	push   $0x0
f0100d4b:	89 d8                	mov    %ebx,%eax
f0100d4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d52:	50                   	push   %eax
f0100d53:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0100d59:	e8 14 07 00 00       	call   f0101472 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	74 19                	je     f0100d7e <mon_dump+0xf1>
f0100d65:	f6 00 01             	testb  $0x1,(%eax)
f0100d68:	74 14                	je     f0100d7e <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d6a:	83 ec 08             	sub    $0x8,%esp
f0100d6d:	ff 33                	pushl  (%ebx)
f0100d6f:	68 86 40 10 f0       	push   $0xf0104086
f0100d74:	e8 e0 1f 00 00       	call   f0102d59 <cprintf>
f0100d79:	83 c4 10             	add    $0x10,%esp
f0100d7c:	eb 10                	jmp    f0100d8e <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d7e:	83 ec 0c             	sub    $0xc,%esp
f0100d81:	68 91 40 10 f0       	push   $0xf0104091
f0100d86:	e8 ce 1f 00 00       	call   f0102d59 <cprintf>
f0100d8b:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d8e:	83 c3 04             	add    $0x4,%ebx
f0100d91:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d94:	75 86                	jne    f0100d1c <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100d96:	83 ec 0c             	sub    $0xc,%esp
f0100d99:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100d9e:	e8 b6 1f 00 00       	call   f0102d59 <cprintf>
f0100da3:	83 c4 10             	add    $0x10,%esp
f0100da6:	eb 7d                	jmp    f0100e25 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100da8:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100daa:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100dad:	39 fb                	cmp    %edi,%ebx
f0100daf:	74 15                	je     f0100dc6 <mon_dump+0x139>
f0100db1:	f6 c3 0f             	test   $0xf,%bl
f0100db4:	75 21                	jne    f0100dd7 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100db6:	83 ec 0c             	sub    $0xc,%esp
f0100db9:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100dbe:	e8 96 1f 00 00       	call   f0102d59 <cprintf>
f0100dc3:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100dc6:	83 ec 08             	sub    $0x8,%esp
f0100dc9:	53                   	push   %ebx
f0100dca:	68 7c 40 10 f0       	push   $0xf010407c
f0100dcf:	e8 85 1f 00 00       	call   f0102d59 <cprintf>
f0100dd4:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100dd7:	83 ec 08             	sub    $0x8,%esp
f0100dda:	56                   	push   %esi
f0100ddb:	53                   	push   %ebx
f0100ddc:	e8 ff fd ff ff       	call   f0100be0 <pa_con>
f0100de1:	83 c4 10             	add    $0x10,%esp
f0100de4:	84 c0                	test   %al,%al
f0100de6:	74 15                	je     f0100dfd <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100de8:	83 ec 08             	sub    $0x8,%esp
f0100deb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dee:	68 86 40 10 f0       	push   $0xf0104086
f0100df3:	e8 61 1f 00 00       	call   f0102d59 <cprintf>
f0100df8:	83 c4 10             	add    $0x10,%esp
f0100dfb:	eb 10                	jmp    f0100e0d <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100dfd:	83 ec 0c             	sub    $0xc,%esp
f0100e00:	68 8f 40 10 f0       	push   $0xf010408f
f0100e05:	e8 4f 1f 00 00       	call   f0102d59 <cprintf>
f0100e0a:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e0d:	83 c3 04             	add    $0x4,%ebx
f0100e10:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100e13:	75 98                	jne    f0100dad <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100e15:	83 ec 0c             	sub    $0xc,%esp
f0100e18:	68 f1 3f 10 f0       	push   $0xf0103ff1
f0100e1d:	e8 37 1f 00 00       	call   f0102d59 <cprintf>
f0100e22:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e2d:	5b                   	pop    %ebx
f0100e2e:	5e                   	pop    %esi
f0100e2f:	5f                   	pop    %edi
f0100e30:	c9                   	leave  
f0100e31:	c3                   	ret    

f0100e32 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e32:	55                   	push   %ebp
f0100e33:	89 e5                	mov    %esp,%ebp
f0100e35:	57                   	push   %edi
f0100e36:	56                   	push   %esi
f0100e37:	53                   	push   %ebx
f0100e38:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e3b:	68 98 46 10 f0       	push   $0xf0104698
f0100e40:	e8 14 1f 00 00       	call   f0102d59 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e45:	c7 04 24 bc 46 10 f0 	movl   $0xf01046bc,(%esp)
f0100e4c:	e8 08 1f 00 00       	call   f0102d59 <cprintf>
f0100e51:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e54:	83 ec 0c             	sub    $0xc,%esp
f0100e57:	68 9c 40 10 f0       	push   $0xf010409c
f0100e5c:	e8 8f 27 00 00       	call   f01035f0 <readline>
f0100e61:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e63:	83 c4 10             	add    $0x10,%esp
f0100e66:	85 c0                	test   %eax,%eax
f0100e68:	74 ea                	je     f0100e54 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e6a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e71:	be 00 00 00 00       	mov    $0x0,%esi
f0100e76:	eb 04                	jmp    f0100e7c <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e78:	c6 03 00             	movb   $0x0,(%ebx)
f0100e7b:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e7c:	8a 03                	mov    (%ebx),%al
f0100e7e:	84 c0                	test   %al,%al
f0100e80:	74 64                	je     f0100ee6 <monitor+0xb4>
f0100e82:	83 ec 08             	sub    $0x8,%esp
f0100e85:	0f be c0             	movsbl %al,%eax
f0100e88:	50                   	push   %eax
f0100e89:	68 a0 40 10 f0       	push   $0xf01040a0
f0100e8e:	e8 a6 29 00 00       	call   f0103839 <strchr>
f0100e93:	83 c4 10             	add    $0x10,%esp
f0100e96:	85 c0                	test   %eax,%eax
f0100e98:	75 de                	jne    f0100e78 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100e9a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e9d:	74 47                	je     f0100ee6 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e9f:	83 fe 0f             	cmp    $0xf,%esi
f0100ea2:	75 14                	jne    f0100eb8 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ea4:	83 ec 08             	sub    $0x8,%esp
f0100ea7:	6a 10                	push   $0x10
f0100ea9:	68 a5 40 10 f0       	push   $0xf01040a5
f0100eae:	e8 a6 1e 00 00       	call   f0102d59 <cprintf>
f0100eb3:	83 c4 10             	add    $0x10,%esp
f0100eb6:	eb 9c                	jmp    f0100e54 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100eb8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100ebc:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ebd:	8a 03                	mov    (%ebx),%al
f0100ebf:	84 c0                	test   %al,%al
f0100ec1:	75 09                	jne    f0100ecc <monitor+0x9a>
f0100ec3:	eb b7                	jmp    f0100e7c <monitor+0x4a>
			buf++;
f0100ec5:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ec6:	8a 03                	mov    (%ebx),%al
f0100ec8:	84 c0                	test   %al,%al
f0100eca:	74 b0                	je     f0100e7c <monitor+0x4a>
f0100ecc:	83 ec 08             	sub    $0x8,%esp
f0100ecf:	0f be c0             	movsbl %al,%eax
f0100ed2:	50                   	push   %eax
f0100ed3:	68 a0 40 10 f0       	push   $0xf01040a0
f0100ed8:	e8 5c 29 00 00       	call   f0103839 <strchr>
f0100edd:	83 c4 10             	add    $0x10,%esp
f0100ee0:	85 c0                	test   %eax,%eax
f0100ee2:	74 e1                	je     f0100ec5 <monitor+0x93>
f0100ee4:	eb 96                	jmp    f0100e7c <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100ee6:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100eed:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100eee:	85 f6                	test   %esi,%esi
f0100ef0:	0f 84 5e ff ff ff    	je     f0100e54 <monitor+0x22>
f0100ef6:	bb 40 47 10 f0       	mov    $0xf0104740,%ebx
f0100efb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f00:	83 ec 08             	sub    $0x8,%esp
f0100f03:	ff 33                	pushl  (%ebx)
f0100f05:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f08:	e8 be 28 00 00       	call   f01037cb <strcmp>
f0100f0d:	83 c4 10             	add    $0x10,%esp
f0100f10:	85 c0                	test   %eax,%eax
f0100f12:	75 20                	jne    f0100f34 <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f0100f14:	83 ec 04             	sub    $0x4,%esp
f0100f17:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100f1a:	ff 75 08             	pushl  0x8(%ebp)
f0100f1d:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f20:	50                   	push   %eax
f0100f21:	56                   	push   %esi
f0100f22:	ff 97 48 47 10 f0    	call   *-0xfefb8b8(%edi)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f28:	83 c4 10             	add    $0x10,%esp
f0100f2b:	85 c0                	test   %eax,%eax
f0100f2d:	78 26                	js     f0100f55 <monitor+0x123>
f0100f2f:	e9 20 ff ff ff       	jmp    f0100e54 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f34:	47                   	inc    %edi
f0100f35:	83 c3 0c             	add    $0xc,%ebx
f0100f38:	83 ff 08             	cmp    $0x8,%edi
f0100f3b:	75 c3                	jne    f0100f00 <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f3d:	83 ec 08             	sub    $0x8,%esp
f0100f40:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f43:	68 c2 40 10 f0       	push   $0xf01040c2
f0100f48:	e8 0c 1e 00 00       	call   f0102d59 <cprintf>
f0100f4d:	83 c4 10             	add    $0x10,%esp
f0100f50:	e9 ff fe ff ff       	jmp    f0100e54 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f58:	5b                   	pop    %ebx
f0100f59:	5e                   	pop    %esi
f0100f5a:	5f                   	pop    %edi
f0100f5b:	c9                   	leave  
f0100f5c:	c3                   	ret    
f0100f5d:	00 00                	add    %al,(%eax)
	...

f0100f60 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f65:	83 3d 30 f5 11 f0 00 	cmpl   $0x0,0xf011f530
f0100f6c:	75 0f                	jne    f0100f7d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f6e:	b8 4f 09 12 f0       	mov    $0xf012094f,%eax
f0100f73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f78:	a3 30 f5 11 f0       	mov    %eax,0xf011f530
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100f7d:	a1 30 f5 11 f0       	mov    0xf011f530,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f82:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100f89:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f8f:	89 15 30 f5 11 f0    	mov    %edx,0xf011f530

	return result;
}
f0100f95:	c9                   	leave  
f0100f96:	c3                   	ret    

f0100f97 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f97:	55                   	push   %ebp
f0100f98:	89 e5                	mov    %esp,%ebp
f0100f9a:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f9d:	89 d1                	mov    %edx,%ecx
f0100f9f:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fa2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fa5:	a8 01                	test   $0x1,%al
f0100fa7:	74 55                	je     f0100ffe <check_va2pa+0x67>
		return ~0;
	if (*pgdir & PTE_PS) {
f0100fa9:	a8 80                	test   $0x80,%al
f0100fab:	74 0f                	je     f0100fbc <check_va2pa+0x25>
		// 4M page
		// uintptr_t tmp = ((*pgdir) & (0xffc00000)) | (va & (~0xffc00000));
		// cprintf("%u\n", tmp);
		return PTE_ADDR(((*pgdir) & (0xffc00000)) | (va & (~0xffc00000)));
f0100fad:	25 00 00 c0 ff       	and    $0xffc00000,%eax
f0100fb2:	81 e2 00 f0 3f 00    	and    $0x3ff000,%edx
f0100fb8:	09 d0                	or     %edx,%eax
f0100fba:	eb 4e                	jmp    f010100a <check_va2pa+0x73>
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc1:	89 c1                	mov    %eax,%ecx
f0100fc3:	c1 e9 0c             	shr    $0xc,%ecx
f0100fc6:	3b 0d 44 f9 11 f0    	cmp    0xf011f944,%ecx
f0100fcc:	72 15                	jb     f0100fe3 <check_va2pa+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fce:	50                   	push   %eax
f0100fcf:	68 a0 47 10 f0       	push   $0xf01047a0
f0100fd4:	68 dd 02 00 00       	push   $0x2dd
f0100fd9:	68 98 4e 10 f0       	push   $0xf0104e98
f0100fde:	e8 a8 f0 ff ff       	call   f010008b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100fe3:	c1 ea 0c             	shr    $0xc,%edx
f0100fe6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fec:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ff3:	a8 01                	test   $0x1,%al
f0100ff5:	74 0e                	je     f0101005 <check_va2pa+0x6e>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ff7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ffc:	eb 0c                	jmp    f010100a <check_va2pa+0x73>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101003:	eb 05                	jmp    f010100a <check_va2pa+0x73>
		// cprintf("%u\n", tmp);
		return PTE_ADDR(((*pgdir) & (0xffc00000)) | (va & (~0xffc00000)));
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010100a:	c9                   	leave  
f010100b:	c3                   	ret    

f010100c <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010100c:	55                   	push   %ebp
f010100d:	89 e5                	mov    %esp,%ebp
f010100f:	56                   	push   %esi
f0101010:	53                   	push   %ebx
f0101011:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101013:	83 ec 0c             	sub    $0xc,%esp
f0101016:	50                   	push   %eax
f0101017:	e8 dc 1c 00 00       	call   f0102cf8 <mc146818_read>
f010101c:	89 c6                	mov    %eax,%esi
f010101e:	43                   	inc    %ebx
f010101f:	89 1c 24             	mov    %ebx,(%esp)
f0101022:	e8 d1 1c 00 00       	call   f0102cf8 <mc146818_read>
f0101027:	c1 e0 08             	shl    $0x8,%eax
f010102a:	09 f0                	or     %esi,%eax
}
f010102c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010102f:	5b                   	pop    %ebx
f0101030:	5e                   	pop    %esi
f0101031:	c9                   	leave  
f0101032:	c3                   	ret    

f0101033 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101033:	55                   	push   %ebp
f0101034:	89 e5                	mov    %esp,%ebp
f0101036:	57                   	push   %edi
f0101037:	56                   	push   %esi
f0101038:	53                   	push   %ebx
f0101039:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010103c:	3c 01                	cmp    $0x1,%al
f010103e:	19 f6                	sbb    %esi,%esi
f0101040:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101046:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101047:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f010104d:	85 db                	test   %ebx,%ebx
f010104f:	75 17                	jne    f0101068 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101051:	83 ec 04             	sub    $0x4,%esp
f0101054:	68 c4 47 10 f0       	push   $0xf01047c4
f0101059:	68 1a 02 00 00       	push   $0x21a
f010105e:	68 98 4e 10 f0       	push   $0xf0104e98
f0101063:	e8 23 f0 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
f0101068:	84 c0                	test   %al,%al
f010106a:	74 50                	je     f01010bc <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010106c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010106f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101072:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101075:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101078:	89 d8                	mov    %ebx,%eax
f010107a:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0101080:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101083:	c1 e8 16             	shr    $0x16,%eax
f0101086:	39 c6                	cmp    %eax,%esi
f0101088:	0f 96 c0             	setbe  %al
f010108b:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010108e:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101092:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101094:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101098:	8b 1b                	mov    (%ebx),%ebx
f010109a:	85 db                	test   %ebx,%ebx
f010109c:	75 da                	jne    f0101078 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010109e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010ad:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010b2:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010b8:	85 db                	test   %ebx,%ebx
f01010ba:	74 57                	je     f0101113 <check_page_free_list+0xe0>
f01010bc:	89 d8                	mov    %ebx,%eax
f01010be:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01010c4:	c1 f8 03             	sar    $0x3,%eax
f01010c7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010ca:	89 c2                	mov    %eax,%edx
f01010cc:	c1 ea 16             	shr    $0x16,%edx
f01010cf:	39 d6                	cmp    %edx,%esi
f01010d1:	76 3a                	jbe    f010110d <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010d3:	89 c2                	mov    %eax,%edx
f01010d5:	c1 ea 0c             	shr    $0xc,%edx
f01010d8:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01010de:	72 12                	jb     f01010f2 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010e0:	50                   	push   %eax
f01010e1:	68 a0 47 10 f0       	push   $0xf01047a0
f01010e6:	6a 52                	push   $0x52
f01010e8:	68 a4 4e 10 f0       	push   $0xf0104ea4
f01010ed:	e8 99 ef ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010f2:	83 ec 04             	sub    $0x4,%esp
f01010f5:	68 80 00 00 00       	push   $0x80
f01010fa:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101104:	50                   	push   %eax
f0101105:	e8 7f 27 00 00       	call   f0103889 <memset>
f010110a:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010110d:	8b 1b                	mov    (%ebx),%ebx
f010110f:	85 db                	test   %ebx,%ebx
f0101111:	75 a9                	jne    f01010bc <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101113:	b8 00 00 00 00       	mov    $0x0,%eax
f0101118:	e8 43 fe ff ff       	call   f0100f60 <boot_alloc>
f010111d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101120:	8b 15 2c f5 11 f0    	mov    0xf011f52c,%edx
f0101126:	85 d2                	test   %edx,%edx
f0101128:	0f 84 80 01 00 00    	je     f01012ae <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010112e:	8b 1d 4c f9 11 f0    	mov    0xf011f94c,%ebx
f0101134:	39 da                	cmp    %ebx,%edx
f0101136:	72 43                	jb     f010117b <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0101138:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f010113d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101140:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101143:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101146:	39 c2                	cmp    %eax,%edx
f0101148:	73 4f                	jae    f0101199 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010114a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010114d:	89 d0                	mov    %edx,%eax
f010114f:	29 d8                	sub    %ebx,%eax
f0101151:	a8 07                	test   $0x7,%al
f0101153:	75 66                	jne    f01011bb <check_page_free_list+0x188>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101155:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101158:	c1 e0 0c             	shl    $0xc,%eax
f010115b:	74 7f                	je     f01011dc <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f010115d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101162:	0f 84 94 00 00 00    	je     f01011fc <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101168:	be 00 00 00 00       	mov    $0x0,%esi
f010116d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101172:	e9 9e 00 00 00       	jmp    f0101215 <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101177:	39 da                	cmp    %ebx,%edx
f0101179:	73 19                	jae    f0101194 <check_page_free_list+0x161>
f010117b:	68 b2 4e 10 f0       	push   $0xf0104eb2
f0101180:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101185:	68 34 02 00 00       	push   $0x234
f010118a:	68 98 4e 10 f0       	push   $0xf0104e98
f010118f:	e8 f7 ee ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0101194:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101197:	72 19                	jb     f01011b2 <check_page_free_list+0x17f>
f0101199:	68 d3 4e 10 f0       	push   $0xf0104ed3
f010119e:	68 be 4e 10 f0       	push   $0xf0104ebe
f01011a3:	68 35 02 00 00       	push   $0x235
f01011a8:	68 98 4e 10 f0       	push   $0xf0104e98
f01011ad:	e8 d9 ee ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011b2:	89 d0                	mov    %edx,%eax
f01011b4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011b7:	a8 07                	test   $0x7,%al
f01011b9:	74 19                	je     f01011d4 <check_page_free_list+0x1a1>
f01011bb:	68 e8 47 10 f0       	push   $0xf01047e8
f01011c0:	68 be 4e 10 f0       	push   $0xf0104ebe
f01011c5:	68 36 02 00 00       	push   $0x236
f01011ca:	68 98 4e 10 f0       	push   $0xf0104e98
f01011cf:	e8 b7 ee ff ff       	call   f010008b <_panic>
f01011d4:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011d7:	c1 e0 0c             	shl    $0xc,%eax
f01011da:	75 19                	jne    f01011f5 <check_page_free_list+0x1c2>
f01011dc:	68 e7 4e 10 f0       	push   $0xf0104ee7
f01011e1:	68 be 4e 10 f0       	push   $0xf0104ebe
f01011e6:	68 39 02 00 00       	push   $0x239
f01011eb:	68 98 4e 10 f0       	push   $0xf0104e98
f01011f0:	e8 96 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011f5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011fa:	75 19                	jne    f0101215 <check_page_free_list+0x1e2>
f01011fc:	68 f8 4e 10 f0       	push   $0xf0104ef8
f0101201:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101206:	68 3a 02 00 00       	push   $0x23a
f010120b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101210:	e8 76 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101215:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010121a:	75 19                	jne    f0101235 <check_page_free_list+0x202>
f010121c:	68 1c 48 10 f0       	push   $0xf010481c
f0101221:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101226:	68 3b 02 00 00       	push   $0x23b
f010122b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101230:	e8 56 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101235:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010123a:	75 19                	jne    f0101255 <check_page_free_list+0x222>
f010123c:	68 11 4f 10 f0       	push   $0xf0104f11
f0101241:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101246:	68 3c 02 00 00       	push   $0x23c
f010124b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101250:	e8 36 ee ff ff       	call   f010008b <_panic>
f0101255:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101257:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010125c:	76 3e                	jbe    f010129c <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010125e:	c1 e8 0c             	shr    $0xc,%eax
f0101261:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101264:	77 12                	ja     f0101278 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101266:	51                   	push   %ecx
f0101267:	68 a0 47 10 f0       	push   $0xf01047a0
f010126c:	6a 52                	push   $0x52
f010126e:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0101273:	e8 13 ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101278:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f010127e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101281:	76 1c                	jbe    f010129f <check_page_free_list+0x26c>
f0101283:	68 40 48 10 f0       	push   $0xf0104840
f0101288:	68 be 4e 10 f0       	push   $0xf0104ebe
f010128d:	68 3d 02 00 00       	push   $0x23d
f0101292:	68 98 4e 10 f0       	push   $0xf0104e98
f0101297:	e8 ef ed ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010129c:	47                   	inc    %edi
f010129d:	eb 01                	jmp    f01012a0 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f010129f:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012a0:	8b 12                	mov    (%edx),%edx
f01012a2:	85 d2                	test   %edx,%edx
f01012a4:	0f 85 cd fe ff ff    	jne    f0101177 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01012aa:	85 ff                	test   %edi,%edi
f01012ac:	7f 19                	jg     f01012c7 <check_page_free_list+0x294>
f01012ae:	68 2b 4f 10 f0       	push   $0xf0104f2b
f01012b3:	68 be 4e 10 f0       	push   $0xf0104ebe
f01012b8:	68 45 02 00 00       	push   $0x245
f01012bd:	68 98 4e 10 f0       	push   $0xf0104e98
f01012c2:	e8 c4 ed ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f01012c7:	85 f6                	test   %esi,%esi
f01012c9:	7f 19                	jg     f01012e4 <check_page_free_list+0x2b1>
f01012cb:	68 3d 4f 10 f0       	push   $0xf0104f3d
f01012d0:	68 be 4e 10 f0       	push   $0xf0104ebe
f01012d5:	68 46 02 00 00       	push   $0x246
f01012da:	68 98 4e 10 f0       	push   $0xf0104e98
f01012df:	e8 a7 ed ff ff       	call   f010008b <_panic>
}
f01012e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e7:	5b                   	pop    %ebx
f01012e8:	5e                   	pop    %esi
f01012e9:	5f                   	pop    %edi
f01012ea:	c9                   	leave  
f01012eb:	c3                   	ret    

f01012ec <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012ec:	55                   	push   %ebp
f01012ed:	89 e5                	mov    %esp,%ebp
f01012ef:	56                   	push   %esi
f01012f0:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01012f1:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f01012f8:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f01012fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101300:	e8 5b fc ff ff       	call   f0100f60 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101305:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010130a:	77 15                	ja     f0101321 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010130c:	50                   	push   %eax
f010130d:	68 d8 45 10 f0       	push   $0xf01045d8
f0101312:	68 19 01 00 00       	push   $0x119
f0101317:	68 98 4e 10 f0       	push   $0xf0104e98
f010131c:	e8 6a ed ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101321:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0101327:	c1 eb 0c             	shr    $0xc,%ebx
    cprintf("BOOT_ALLOC_0: %u\n", nf_ub);
f010132a:	83 ec 08             	sub    $0x8,%esp
f010132d:	53                   	push   %ebx
f010132e:	68 4e 4f 10 f0       	push   $0xf0104f4e
f0101333:	e8 21 1a 00 00       	call   f0102d59 <cprintf>
    for (i = 0; i < npages; i++) {
f0101338:	83 c4 10             	add    $0x10,%esp
f010133b:	83 3d 44 f9 11 f0 00 	cmpl   $0x0,0xf011f944
f0101342:	74 5f                	je     f01013a3 <page_init+0xb7>
f0101344:	8b 35 2c f5 11 f0    	mov    0xf011f52c,%esi
f010134a:	ba 00 00 00 00       	mov    $0x0,%edx
f010134f:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101354:	85 c0                	test   %eax,%eax
f0101356:	74 25                	je     f010137d <page_init+0x91>
f0101358:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f010135d:	76 04                	jbe    f0101363 <page_init+0x77>
f010135f:	39 c3                	cmp    %eax,%ebx
f0101361:	77 1a                	ja     f010137d <page_init+0x91>
		    pages[i].pp_ref = 0;
f0101363:	89 d1                	mov    %edx,%ecx
f0101365:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f010136b:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101371:	89 31                	mov    %esi,(%ecx)
		    page_free_list = &pages[i];
f0101373:	89 d6                	mov    %edx,%esi
f0101375:	03 35 4c f9 11 f0    	add    0xf011f94c,%esi
f010137b:	eb 14                	jmp    f0101391 <page_init+0xa5>
        } else {
            pages[i].pp_ref = 1;
f010137d:	89 d1                	mov    %edx,%ecx
f010137f:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f0101385:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010138b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    cprintf("BOOT_ALLOC_0: %u\n", nf_ub);
    for (i = 0; i < npages; i++) {
f0101391:	40                   	inc    %eax
f0101392:	83 c2 08             	add    $0x8,%edx
f0101395:	39 05 44 f9 11 f0    	cmp    %eax,0xf011f944
f010139b:	77 b7                	ja     f0101354 <page_init+0x68>
f010139d:	89 35 2c f5 11 f0    	mov    %esi,0xf011f52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01013a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013a6:	5b                   	pop    %ebx
f01013a7:	5e                   	pop    %esi
f01013a8:	c9                   	leave  
f01013a9:	c3                   	ret    

f01013aa <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013aa:	55                   	push   %ebp
f01013ab:	89 e5                	mov    %esp,%ebp
f01013ad:	53                   	push   %ebx
f01013ae:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013b1:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f01013b7:	85 db                	test   %ebx,%ebx
f01013b9:	74 63                	je     f010141e <page_alloc+0x74>
f01013bb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013c0:	74 63                	je     f0101425 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01013c2:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013c4:	85 db                	test   %ebx,%ebx
f01013c6:	75 08                	jne    f01013d0 <page_alloc+0x26>
f01013c8:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
f01013ce:	eb 4e                	jmp    f010141e <page_alloc+0x74>
f01013d0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013d5:	75 eb                	jne    f01013c2 <page_alloc+0x18>
f01013d7:	eb 4c                	jmp    f0101425 <page_alloc+0x7b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013d9:	89 d8                	mov    %ebx,%eax
f01013db:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01013e1:	c1 f8 03             	sar    $0x3,%eax
f01013e4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013e7:	89 c2                	mov    %eax,%edx
f01013e9:	c1 ea 0c             	shr    $0xc,%edx
f01013ec:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01013f2:	72 12                	jb     f0101406 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013f4:	50                   	push   %eax
f01013f5:	68 a0 47 10 f0       	push   $0xf01047a0
f01013fa:	6a 52                	push   $0x52
f01013fc:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0101401:	e8 85 ec ff ff       	call   f010008b <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101406:	83 ec 04             	sub    $0x4,%esp
f0101409:	68 00 10 00 00       	push   $0x1000
f010140e:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101410:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101415:	50                   	push   %eax
f0101416:	e8 6e 24 00 00       	call   f0103889 <memset>
f010141b:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f010141e:	89 d8                	mov    %ebx,%eax
f0101420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101423:	c9                   	leave  
f0101424:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101425:	8b 03                	mov    (%ebx),%eax
f0101427:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
        if (alloc_flags & ALLOC_ZERO) {
f010142c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101430:	74 ec                	je     f010141e <page_alloc+0x74>
f0101432:	eb a5                	jmp    f01013d9 <page_alloc+0x2f>

f0101434 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101434:	55                   	push   %ebp
f0101435:	89 e5                	mov    %esp,%ebp
f0101437:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f010143a:	85 c0                	test   %eax,%eax
f010143c:	74 14                	je     f0101452 <page_free+0x1e>
f010143e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101443:	75 0d                	jne    f0101452 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101445:	8b 15 2c f5 11 f0    	mov    0xf011f52c,%edx
f010144b:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010144d:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
}
f0101452:	c9                   	leave  
f0101453:	c3                   	ret    

f0101454 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101454:	55                   	push   %ebp
f0101455:	89 e5                	mov    %esp,%ebp
f0101457:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010145a:	8b 50 04             	mov    0x4(%eax),%edx
f010145d:	4a                   	dec    %edx
f010145e:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101462:	66 85 d2             	test   %dx,%dx
f0101465:	75 09                	jne    f0101470 <page_decref+0x1c>
		page_free(pp);
f0101467:	50                   	push   %eax
f0101468:	e8 c7 ff ff ff       	call   f0101434 <page_free>
f010146d:	83 c4 04             	add    $0x4,%esp
}
f0101470:	c9                   	leave  
f0101471:	c3                   	ret    

f0101472 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101472:	55                   	push   %ebp
f0101473:	89 e5                	mov    %esp,%ebp
f0101475:	56                   	push   %esi
f0101476:	53                   	push   %ebx
f0101477:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f010147a:	89 f3                	mov    %esi,%ebx
f010147c:	c1 eb 16             	shr    $0x16,%ebx
f010147f:	c1 e3 02             	shl    $0x2,%ebx
f0101482:	03 5d 08             	add    0x8(%ebp),%ebx
f0101485:	8b 03                	mov    (%ebx),%eax
f0101487:	85 c0                	test   %eax,%eax
f0101489:	74 04                	je     f010148f <pgdir_walk+0x1d>
f010148b:	a8 01                	test   $0x1,%al
f010148d:	75 2c                	jne    f01014bb <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f010148f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101493:	74 61                	je     f01014f6 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
f0101495:	83 ec 0c             	sub    $0xc,%esp
f0101498:	6a 01                	push   $0x1
f010149a:	e8 0b ff ff ff       	call   f01013aa <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f010149f:	83 c4 10             	add    $0x10,%esp
f01014a2:	85 c0                	test   %eax,%eax
f01014a4:	74 57                	je     f01014fd <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01014a6:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014aa:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01014b0:	c1 f8 03             	sar    $0x3,%eax
f01014b3:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01014b6:	83 c8 07             	or     $0x7,%eax
f01014b9:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01014bb:	8b 03                	mov    (%ebx),%eax
f01014bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014c2:	89 c2                	mov    %eax,%edx
f01014c4:	c1 ea 0c             	shr    $0xc,%edx
f01014c7:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01014cd:	72 15                	jb     f01014e4 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014cf:	50                   	push   %eax
f01014d0:	68 a0 47 10 f0       	push   $0xf01047a0
f01014d5:	68 7d 01 00 00       	push   $0x17d
f01014da:	68 98 4e 10 f0       	push   $0xf0104e98
f01014df:	e8 a7 eb ff ff       	call   f010008b <_panic>
f01014e4:	c1 ee 0a             	shr    $0xa,%esi
f01014e7:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01014ed:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01014f4:	eb 0c                	jmp    f0101502 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f01014f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014fb:	eb 05                	jmp    f0101502 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
        if (new_page == NULL) return NULL;      // allocation fails
f01014fd:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101502:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101505:	5b                   	pop    %ebx
f0101506:	5e                   	pop    %esi
f0101507:	c9                   	leave  
f0101508:	c3                   	ret    

f0101509 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101509:	55                   	push   %ebp
f010150a:	89 e5                	mov    %esp,%ebp
f010150c:	57                   	push   %edi
f010150d:	56                   	push   %esi
f010150e:	53                   	push   %ebx
f010150f:	83 ec 1c             	sub    $0x1c,%esp
f0101512:	89 c7                	mov    %eax,%edi
f0101514:	8b 5d 08             	mov    0x8(%ebp),%ebx
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
f0101517:	f6 45 0c 80          	testb  $0x80,0xc(%ebp)
f010151b:	75 0b                	jne    f0101528 <boot_map_region+0x1f>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010151d:	01 d1                	add    %edx,%ecx
f010151f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101522:	39 ca                	cmp    %ecx,%edx
f0101524:	75 41                	jne    f0101567 <boot_map_region+0x5e>
f0101526:	eb 71                	jmp    f0101599 <boot_map_region+0x90>
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
f0101528:	89 d0                	mov    %edx,%eax
f010152a:	25 00 00 c0 ff       	and    $0xffc00000,%eax
f010152f:	8d b4 0a ff ff 3f 00 	lea    0x3fffff(%edx,%ecx,1),%esi
f0101536:	81 e6 00 00 c0 ff    	and    $0xffc00000,%esi
f010153c:	39 f0                	cmp    %esi,%eax
f010153e:	74 59                	je     f0101599 <boot_map_region+0x90>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
f0101540:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101543:	80 ca 81             	or     $0x81,%dl
f0101546:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
    		pte = &pgdir[PDX(va_now)];
f0101549:	89 c2                	mov    %eax,%edx
f010154b:	c1 ea 16             	shr    $0x16,%edx
    		*pte = pa | PTE_P | PTE_PS | perm;
f010154e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101551:	09 d9                	or     %ebx,%ecx
f0101553:	89 0c 97             	mov    %ecx,(%edi,%edx,4)
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
f0101556:	05 00 00 40 00       	add    $0x400000,%eax
f010155b:	81 c3 00 00 40 00    	add    $0x400000,%ebx
f0101561:	39 f0                	cmp    %esi,%eax
f0101563:	75 e4                	jne    f0101549 <boot_map_region+0x40>
f0101565:	eb 32                	jmp    f0101599 <boot_map_region+0x90>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101567:	89 d6                	mov    %edx,%esi
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
f0101569:	8b 45 0c             	mov    0xc(%ebp),%eax
f010156c:	83 c8 01             	or     $0x1,%eax
f010156f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101572:	83 ec 04             	sub    $0x4,%esp
f0101575:	6a 01                	push   $0x1
f0101577:	56                   	push   %esi
f0101578:	57                   	push   %edi
f0101579:	e8 f4 fe ff ff       	call   f0101472 <pgdir_walk>
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
f010157e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101581:	09 da                	or     %ebx,%edx
f0101583:	89 10                	mov    %edx,(%eax)
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101585:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010158b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101591:	83 c4 10             	add    $0x10,%esp
f0101594:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f0101597:	75 d9                	jne    f0101572 <boot_map_region+0x69>
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
    	}
	}
}
f0101599:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010159c:	5b                   	pop    %ebx
f010159d:	5e                   	pop    %esi
f010159e:	5f                   	pop    %edi
f010159f:	c9                   	leave  
f01015a0:	c3                   	ret    

f01015a1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015a1:	55                   	push   %ebp
f01015a2:	89 e5                	mov    %esp,%ebp
f01015a4:	53                   	push   %ebx
f01015a5:	83 ec 08             	sub    $0x8,%esp
f01015a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01015ab:	6a 00                	push   $0x0
f01015ad:	ff 75 0c             	pushl  0xc(%ebp)
f01015b0:	ff 75 08             	pushl  0x8(%ebp)
f01015b3:	e8 ba fe ff ff       	call   f0101472 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015b8:	83 c4 10             	add    $0x10,%esp
f01015bb:	85 c0                	test   %eax,%eax
f01015bd:	74 37                	je     f01015f6 <page_lookup+0x55>
f01015bf:	f6 00 01             	testb  $0x1,(%eax)
f01015c2:	74 39                	je     f01015fd <page_lookup+0x5c>
    if (pte_store != 0) {
f01015c4:	85 db                	test   %ebx,%ebx
f01015c6:	74 02                	je     f01015ca <page_lookup+0x29>
        *pte_store = pte;
f01015c8:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01015ca:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015cc:	c1 e8 0c             	shr    $0xc,%eax
f01015cf:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f01015d5:	72 14                	jb     f01015eb <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01015d7:	83 ec 04             	sub    $0x4,%esp
f01015da:	68 88 48 10 f0       	push   $0xf0104888
f01015df:	6a 4b                	push   $0x4b
f01015e1:	68 a4 4e 10 f0       	push   $0xf0104ea4
f01015e6:	e8 a0 ea ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f01015eb:	c1 e0 03             	shl    $0x3,%eax
f01015ee:	03 05 4c f9 11 f0    	add    0xf011f94c,%eax
f01015f4:	eb 0c                	jmp    f0101602 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015fb:	eb 05                	jmp    f0101602 <page_lookup+0x61>
f01015fd:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0101602:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101605:	c9                   	leave  
f0101606:	c3                   	ret    

f0101607 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010160a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010160d:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101610:	c9                   	leave  
f0101611:	c3                   	ret    

f0101612 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101612:	55                   	push   %ebp
f0101613:	89 e5                	mov    %esp,%ebp
f0101615:	56                   	push   %esi
f0101616:	53                   	push   %ebx
f0101617:	83 ec 14             	sub    $0x14,%esp
f010161a:	8b 75 08             	mov    0x8(%ebp),%esi
f010161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101620:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101623:	50                   	push   %eax
f0101624:	53                   	push   %ebx
f0101625:	56                   	push   %esi
f0101626:	e8 76 ff ff ff       	call   f01015a1 <page_lookup>
    if (pg == NULL) return;
f010162b:	83 c4 10             	add    $0x10,%esp
f010162e:	85 c0                	test   %eax,%eax
f0101630:	74 26                	je     f0101658 <page_remove+0x46>
    page_decref(pg);
f0101632:	83 ec 0c             	sub    $0xc,%esp
f0101635:	50                   	push   %eax
f0101636:	e8 19 fe ff ff       	call   f0101454 <page_decref>
    if (pte != NULL) *pte = 0;
f010163b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010163e:	83 c4 10             	add    $0x10,%esp
f0101641:	85 c0                	test   %eax,%eax
f0101643:	74 06                	je     f010164b <page_remove+0x39>
f0101645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f010164b:	83 ec 08             	sub    $0x8,%esp
f010164e:	53                   	push   %ebx
f010164f:	56                   	push   %esi
f0101650:	e8 b2 ff ff ff       	call   f0101607 <tlb_invalidate>
f0101655:	83 c4 10             	add    $0x10,%esp
}
f0101658:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010165b:	5b                   	pop    %ebx
f010165c:	5e                   	pop    %esi
f010165d:	c9                   	leave  
f010165e:	c3                   	ret    

f010165f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010165f:	55                   	push   %ebp
f0101660:	89 e5                	mov    %esp,%ebp
f0101662:	57                   	push   %edi
f0101663:	56                   	push   %esi
f0101664:	53                   	push   %ebx
f0101665:	83 ec 10             	sub    $0x10,%esp
f0101668:	8b 75 0c             	mov    0xc(%ebp),%esi
f010166b:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f010166e:	6a 01                	push   $0x1
f0101670:	57                   	push   %edi
f0101671:	ff 75 08             	pushl  0x8(%ebp)
f0101674:	e8 f9 fd ff ff       	call   f0101472 <pgdir_walk>
f0101679:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f010167b:	83 c4 10             	add    $0x10,%esp
f010167e:	85 c0                	test   %eax,%eax
f0101680:	74 39                	je     f01016bb <page_insert+0x5c>
    ++pp->pp_ref;
f0101682:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101686:	f6 00 01             	testb  $0x1,(%eax)
f0101689:	74 0f                	je     f010169a <page_insert+0x3b>
        page_remove(pgdir, va);
f010168b:	83 ec 08             	sub    $0x8,%esp
f010168e:	57                   	push   %edi
f010168f:	ff 75 08             	pushl  0x8(%ebp)
f0101692:	e8 7b ff ff ff       	call   f0101612 <page_remove>
f0101697:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010169a:	8b 55 14             	mov    0x14(%ebp),%edx
f010169d:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a0:	2b 35 4c f9 11 f0    	sub    0xf011f94c,%esi
f01016a6:	c1 fe 03             	sar    $0x3,%esi
f01016a9:	89 f0                	mov    %esi,%eax
f01016ab:	c1 e0 0c             	shl    $0xc,%eax
f01016ae:	89 d6                	mov    %edx,%esi
f01016b0:	09 c6                	or     %eax,%esi
f01016b2:	89 33                	mov    %esi,(%ebx)
	return 0;
f01016b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01016b9:	eb 05                	jmp    f01016c0 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01016bb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016c3:	5b                   	pop    %ebx
f01016c4:	5e                   	pop    %esi
f01016c5:	5f                   	pop    %edi
f01016c6:	c9                   	leave  
f01016c7:	c3                   	ret    

f01016c8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016c8:	55                   	push   %ebp
f01016c9:	89 e5                	mov    %esp,%ebp
f01016cb:	57                   	push   %edi
f01016cc:	56                   	push   %esi
f01016cd:	53                   	push   %ebx
f01016ce:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016d1:	b8 15 00 00 00       	mov    $0x15,%eax
f01016d6:	e8 31 f9 ff ff       	call   f010100c <nvram_read>
f01016db:	c1 e0 0a             	shl    $0xa,%eax
f01016de:	89 c2                	mov    %eax,%edx
f01016e0:	85 c0                	test   %eax,%eax
f01016e2:	79 06                	jns    f01016ea <mem_init+0x22>
f01016e4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016ea:	c1 fa 0c             	sar    $0xc,%edx
f01016ed:	89 15 34 f5 11 f0    	mov    %edx,0xf011f534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016f3:	b8 17 00 00 00       	mov    $0x17,%eax
f01016f8:	e8 0f f9 ff ff       	call   f010100c <nvram_read>
f01016fd:	89 c2                	mov    %eax,%edx
f01016ff:	c1 e2 0a             	shl    $0xa,%edx
f0101702:	89 d0                	mov    %edx,%eax
f0101704:	85 d2                	test   %edx,%edx
f0101706:	79 06                	jns    f010170e <mem_init+0x46>
f0101708:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010170e:	c1 f8 0c             	sar    $0xc,%eax
f0101711:	74 0e                	je     f0101721 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101713:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101719:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944
f010171f:	eb 0c                	jmp    f010172d <mem_init+0x65>
	else
		npages = npages_basemem;
f0101721:	8b 15 34 f5 11 f0    	mov    0xf011f534,%edx
f0101727:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010172d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101730:	c1 e8 0a             	shr    $0xa,%eax
f0101733:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101734:	a1 34 f5 11 f0       	mov    0xf011f534,%eax
f0101739:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010173c:	c1 e8 0a             	shr    $0xa,%eax
f010173f:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101740:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0101745:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101748:	c1 e8 0a             	shr    $0xa,%eax
f010174b:	50                   	push   %eax
f010174c:	68 a8 48 10 f0       	push   $0xf01048a8
f0101751:	e8 03 16 00 00       	call   f0102d59 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101756:	b8 00 10 00 00       	mov    $0x1000,%eax
f010175b:	e8 00 f8 ff ff       	call   f0100f60 <boot_alloc>
f0101760:	a3 48 f9 11 f0       	mov    %eax,0xf011f948
	memset(kern_pgdir, 0, PGSIZE);
f0101765:	83 c4 0c             	add    $0xc,%esp
f0101768:	68 00 10 00 00       	push   $0x1000
f010176d:	6a 00                	push   $0x0
f010176f:	50                   	push   %eax
f0101770:	e8 14 21 00 00       	call   f0103889 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101775:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010177a:	83 c4 10             	add    $0x10,%esp
f010177d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101782:	77 15                	ja     f0101799 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101784:	50                   	push   %eax
f0101785:	68 d8 45 10 f0       	push   $0xf01045d8
f010178a:	68 8d 00 00 00       	push   $0x8d
f010178f:	68 98 4e 10 f0       	push   $0xf0104e98
f0101794:	e8 f2 e8 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101799:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010179f:	83 ca 05             	or     $0x5,%edx
f01017a2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    cprintf("P %u\n", npages);
f01017a8:	83 ec 08             	sub    $0x8,%esp
f01017ab:	ff 35 44 f9 11 f0    	pushl  0xf011f944
f01017b1:	68 60 4f 10 f0       	push   $0xf0104f60
f01017b6:	e8 9e 15 00 00       	call   f0102d59 <cprintf>
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01017bb:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01017c0:	c1 e0 03             	shl    $0x3,%eax
f01017c3:	e8 98 f7 ff ff       	call   f0100f60 <boot_alloc>
f01017c8:	a3 4c f9 11 f0       	mov    %eax,0xf011f94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017cd:	e8 1a fb ff ff       	call   f01012ec <page_init>



	check_page_free_list(1);
f01017d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01017d7:	e8 57 f8 ff ff       	call   f0101033 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017dc:	83 c4 10             	add    $0x10,%esp
f01017df:	83 3d 4c f9 11 f0 00 	cmpl   $0x0,0xf011f94c
f01017e6:	75 17                	jne    f01017ff <mem_init+0x137>
		panic("'pages' is a null pointer!");
f01017e8:	83 ec 04             	sub    $0x4,%esp
f01017eb:	68 66 4f 10 f0       	push   $0xf0104f66
f01017f0:	68 57 02 00 00       	push   $0x257
f01017f5:	68 98 4e 10 f0       	push   $0xf0104e98
f01017fa:	e8 8c e8 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017ff:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101804:	85 c0                	test   %eax,%eax
f0101806:	74 0e                	je     f0101816 <mem_init+0x14e>
f0101808:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f010180d:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010180e:	8b 00                	mov    (%eax),%eax
f0101810:	85 c0                	test   %eax,%eax
f0101812:	75 f9                	jne    f010180d <mem_init+0x145>
f0101814:	eb 05                	jmp    f010181b <mem_init+0x153>
f0101816:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010181b:	83 ec 0c             	sub    $0xc,%esp
f010181e:	6a 00                	push   $0x0
f0101820:	e8 85 fb ff ff       	call   f01013aa <page_alloc>
f0101825:	89 c6                	mov    %eax,%esi
f0101827:	83 c4 10             	add    $0x10,%esp
f010182a:	85 c0                	test   %eax,%eax
f010182c:	75 19                	jne    f0101847 <mem_init+0x17f>
f010182e:	68 81 4f 10 f0       	push   $0xf0104f81
f0101833:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101838:	68 5f 02 00 00       	push   $0x25f
f010183d:	68 98 4e 10 f0       	push   $0xf0104e98
f0101842:	e8 44 e8 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101847:	83 ec 0c             	sub    $0xc,%esp
f010184a:	6a 00                	push   $0x0
f010184c:	e8 59 fb ff ff       	call   f01013aa <page_alloc>
f0101851:	89 c7                	mov    %eax,%edi
f0101853:	83 c4 10             	add    $0x10,%esp
f0101856:	85 c0                	test   %eax,%eax
f0101858:	75 19                	jne    f0101873 <mem_init+0x1ab>
f010185a:	68 97 4f 10 f0       	push   $0xf0104f97
f010185f:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101864:	68 60 02 00 00       	push   $0x260
f0101869:	68 98 4e 10 f0       	push   $0xf0104e98
f010186e:	e8 18 e8 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101873:	83 ec 0c             	sub    $0xc,%esp
f0101876:	6a 00                	push   $0x0
f0101878:	e8 2d fb ff ff       	call   f01013aa <page_alloc>
f010187d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101880:	83 c4 10             	add    $0x10,%esp
f0101883:	85 c0                	test   %eax,%eax
f0101885:	75 19                	jne    f01018a0 <mem_init+0x1d8>
f0101887:	68 ad 4f 10 f0       	push   $0xf0104fad
f010188c:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101891:	68 61 02 00 00       	push   $0x261
f0101896:	68 98 4e 10 f0       	push   $0xf0104e98
f010189b:	e8 eb e7 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018a0:	39 fe                	cmp    %edi,%esi
f01018a2:	75 19                	jne    f01018bd <mem_init+0x1f5>
f01018a4:	68 c3 4f 10 f0       	push   $0xf0104fc3
f01018a9:	68 be 4e 10 f0       	push   $0xf0104ebe
f01018ae:	68 64 02 00 00       	push   $0x264
f01018b3:	68 98 4e 10 f0       	push   $0xf0104e98
f01018b8:	e8 ce e7 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018bd:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018c0:	74 05                	je     f01018c7 <mem_init+0x1ff>
f01018c2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018c5:	75 19                	jne    f01018e0 <mem_init+0x218>
f01018c7:	68 e4 48 10 f0       	push   $0xf01048e4
f01018cc:	68 be 4e 10 f0       	push   $0xf0104ebe
f01018d1:	68 65 02 00 00       	push   $0x265
f01018d6:	68 98 4e 10 f0       	push   $0xf0104e98
f01018db:	e8 ab e7 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e0:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018e6:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01018eb:	c1 e0 0c             	shl    $0xc,%eax
f01018ee:	89 f1                	mov    %esi,%ecx
f01018f0:	29 d1                	sub    %edx,%ecx
f01018f2:	c1 f9 03             	sar    $0x3,%ecx
f01018f5:	c1 e1 0c             	shl    $0xc,%ecx
f01018f8:	39 c1                	cmp    %eax,%ecx
f01018fa:	72 19                	jb     f0101915 <mem_init+0x24d>
f01018fc:	68 d5 4f 10 f0       	push   $0xf0104fd5
f0101901:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101906:	68 66 02 00 00       	push   $0x266
f010190b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101910:	e8 76 e7 ff ff       	call   f010008b <_panic>
f0101915:	89 f9                	mov    %edi,%ecx
f0101917:	29 d1                	sub    %edx,%ecx
f0101919:	c1 f9 03             	sar    $0x3,%ecx
f010191c:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010191f:	39 c8                	cmp    %ecx,%eax
f0101921:	77 19                	ja     f010193c <mem_init+0x274>
f0101923:	68 f2 4f 10 f0       	push   $0xf0104ff2
f0101928:	68 be 4e 10 f0       	push   $0xf0104ebe
f010192d:	68 67 02 00 00       	push   $0x267
f0101932:	68 98 4e 10 f0       	push   $0xf0104e98
f0101937:	e8 4f e7 ff ff       	call   f010008b <_panic>
f010193c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010193f:	29 d1                	sub    %edx,%ecx
f0101941:	89 ca                	mov    %ecx,%edx
f0101943:	c1 fa 03             	sar    $0x3,%edx
f0101946:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101949:	39 d0                	cmp    %edx,%eax
f010194b:	77 19                	ja     f0101966 <mem_init+0x29e>
f010194d:	68 0f 50 10 f0       	push   $0xf010500f
f0101952:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101957:	68 68 02 00 00       	push   $0x268
f010195c:	68 98 4e 10 f0       	push   $0xf0104e98
f0101961:	e8 25 e7 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101966:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f010196b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010196e:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f0101975:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101978:	83 ec 0c             	sub    $0xc,%esp
f010197b:	6a 00                	push   $0x0
f010197d:	e8 28 fa ff ff       	call   f01013aa <page_alloc>
f0101982:	83 c4 10             	add    $0x10,%esp
f0101985:	85 c0                	test   %eax,%eax
f0101987:	74 19                	je     f01019a2 <mem_init+0x2da>
f0101989:	68 2c 50 10 f0       	push   $0xf010502c
f010198e:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101993:	68 6f 02 00 00       	push   $0x26f
f0101998:	68 98 4e 10 f0       	push   $0xf0104e98
f010199d:	e8 e9 e6 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019a2:	83 ec 0c             	sub    $0xc,%esp
f01019a5:	56                   	push   %esi
f01019a6:	e8 89 fa ff ff       	call   f0101434 <page_free>
	page_free(pp1);
f01019ab:	89 3c 24             	mov    %edi,(%esp)
f01019ae:	e8 81 fa ff ff       	call   f0101434 <page_free>
	page_free(pp2);
f01019b3:	83 c4 04             	add    $0x4,%esp
f01019b6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019b9:	e8 76 fa ff ff       	call   f0101434 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c5:	e8 e0 f9 ff ff       	call   f01013aa <page_alloc>
f01019ca:	89 c6                	mov    %eax,%esi
f01019cc:	83 c4 10             	add    $0x10,%esp
f01019cf:	85 c0                	test   %eax,%eax
f01019d1:	75 19                	jne    f01019ec <mem_init+0x324>
f01019d3:	68 81 4f 10 f0       	push   $0xf0104f81
f01019d8:	68 be 4e 10 f0       	push   $0xf0104ebe
f01019dd:	68 76 02 00 00       	push   $0x276
f01019e2:	68 98 4e 10 f0       	push   $0xf0104e98
f01019e7:	e8 9f e6 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01019ec:	83 ec 0c             	sub    $0xc,%esp
f01019ef:	6a 00                	push   $0x0
f01019f1:	e8 b4 f9 ff ff       	call   f01013aa <page_alloc>
f01019f6:	89 c7                	mov    %eax,%edi
f01019f8:	83 c4 10             	add    $0x10,%esp
f01019fb:	85 c0                	test   %eax,%eax
f01019fd:	75 19                	jne    f0101a18 <mem_init+0x350>
f01019ff:	68 97 4f 10 f0       	push   $0xf0104f97
f0101a04:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101a09:	68 77 02 00 00       	push   $0x277
f0101a0e:	68 98 4e 10 f0       	push   $0xf0104e98
f0101a13:	e8 73 e6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101a18:	83 ec 0c             	sub    $0xc,%esp
f0101a1b:	6a 00                	push   $0x0
f0101a1d:	e8 88 f9 ff ff       	call   f01013aa <page_alloc>
f0101a22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a25:	83 c4 10             	add    $0x10,%esp
f0101a28:	85 c0                	test   %eax,%eax
f0101a2a:	75 19                	jne    f0101a45 <mem_init+0x37d>
f0101a2c:	68 ad 4f 10 f0       	push   $0xf0104fad
f0101a31:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101a36:	68 78 02 00 00       	push   $0x278
f0101a3b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101a40:	e8 46 e6 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a45:	39 fe                	cmp    %edi,%esi
f0101a47:	75 19                	jne    f0101a62 <mem_init+0x39a>
f0101a49:	68 c3 4f 10 f0       	push   $0xf0104fc3
f0101a4e:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101a53:	68 7a 02 00 00       	push   $0x27a
f0101a58:	68 98 4e 10 f0       	push   $0xf0104e98
f0101a5d:	e8 29 e6 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a62:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a65:	74 05                	je     f0101a6c <mem_init+0x3a4>
f0101a67:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a6a:	75 19                	jne    f0101a85 <mem_init+0x3bd>
f0101a6c:	68 e4 48 10 f0       	push   $0xf01048e4
f0101a71:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101a76:	68 7b 02 00 00       	push   $0x27b
f0101a7b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101a80:	e8 06 e6 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101a85:	83 ec 0c             	sub    $0xc,%esp
f0101a88:	6a 00                	push   $0x0
f0101a8a:	e8 1b f9 ff ff       	call   f01013aa <page_alloc>
f0101a8f:	83 c4 10             	add    $0x10,%esp
f0101a92:	85 c0                	test   %eax,%eax
f0101a94:	74 19                	je     f0101aaf <mem_init+0x3e7>
f0101a96:	68 2c 50 10 f0       	push   $0xf010502c
f0101a9b:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101aa0:	68 7c 02 00 00       	push   $0x27c
f0101aa5:	68 98 4e 10 f0       	push   $0xf0104e98
f0101aaa:	e8 dc e5 ff ff       	call   f010008b <_panic>
f0101aaf:	89 f0                	mov    %esi,%eax
f0101ab1:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0101ab7:	c1 f8 03             	sar    $0x3,%eax
f0101aba:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101abd:	89 c2                	mov    %eax,%edx
f0101abf:	c1 ea 0c             	shr    $0xc,%edx
f0101ac2:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0101ac8:	72 12                	jb     f0101adc <mem_init+0x414>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aca:	50                   	push   %eax
f0101acb:	68 a0 47 10 f0       	push   $0xf01047a0
f0101ad0:	6a 52                	push   $0x52
f0101ad2:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0101ad7:	e8 af e5 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101adc:	83 ec 04             	sub    $0x4,%esp
f0101adf:	68 00 10 00 00       	push   $0x1000
f0101ae4:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101ae6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aeb:	50                   	push   %eax
f0101aec:	e8 98 1d 00 00       	call   f0103889 <memset>
	page_free(pp0);
f0101af1:	89 34 24             	mov    %esi,(%esp)
f0101af4:	e8 3b f9 ff ff       	call   f0101434 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b00:	e8 a5 f8 ff ff       	call   f01013aa <page_alloc>
f0101b05:	83 c4 10             	add    $0x10,%esp
f0101b08:	85 c0                	test   %eax,%eax
f0101b0a:	75 19                	jne    f0101b25 <mem_init+0x45d>
f0101b0c:	68 3b 50 10 f0       	push   $0xf010503b
f0101b11:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101b16:	68 81 02 00 00       	push   $0x281
f0101b1b:	68 98 4e 10 f0       	push   $0xf0104e98
f0101b20:	e8 66 e5 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101b25:	39 c6                	cmp    %eax,%esi
f0101b27:	74 19                	je     f0101b42 <mem_init+0x47a>
f0101b29:	68 59 50 10 f0       	push   $0xf0105059
f0101b2e:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101b33:	68 82 02 00 00       	push   $0x282
f0101b38:	68 98 4e 10 f0       	push   $0xf0104e98
f0101b3d:	e8 49 e5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b42:	89 f2                	mov    %esi,%edx
f0101b44:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101b4a:	c1 fa 03             	sar    $0x3,%edx
f0101b4d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b50:	89 d0                	mov    %edx,%eax
f0101b52:	c1 e8 0c             	shr    $0xc,%eax
f0101b55:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f0101b5b:	72 12                	jb     f0101b6f <mem_init+0x4a7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b5d:	52                   	push   %edx
f0101b5e:	68 a0 47 10 f0       	push   $0xf01047a0
f0101b63:	6a 52                	push   $0x52
f0101b65:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0101b6a:	e8 1c e5 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b6f:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b76:	75 11                	jne    f0101b89 <mem_init+0x4c1>
f0101b78:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b7e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b84:	80 38 00             	cmpb   $0x0,(%eax)
f0101b87:	74 19                	je     f0101ba2 <mem_init+0x4da>
f0101b89:	68 69 50 10 f0       	push   $0xf0105069
f0101b8e:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101b93:	68 85 02 00 00       	push   $0x285
f0101b98:	68 98 4e 10 f0       	push   $0xf0104e98
f0101b9d:	e8 e9 e4 ff ff       	call   f010008b <_panic>
f0101ba2:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ba3:	39 d0                	cmp    %edx,%eax
f0101ba5:	75 dd                	jne    f0101b84 <mem_init+0x4bc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ba7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101baa:	89 15 2c f5 11 f0    	mov    %edx,0xf011f52c

	// free the pages we took
	page_free(pp0);
f0101bb0:	83 ec 0c             	sub    $0xc,%esp
f0101bb3:	56                   	push   %esi
f0101bb4:	e8 7b f8 ff ff       	call   f0101434 <page_free>
	page_free(pp1);
f0101bb9:	89 3c 24             	mov    %edi,(%esp)
f0101bbc:	e8 73 f8 ff ff       	call   f0101434 <page_free>
	page_free(pp2);
f0101bc1:	83 c4 04             	add    $0x4,%esp
f0101bc4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc7:	e8 68 f8 ff ff       	call   f0101434 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bcc:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101bd1:	83 c4 10             	add    $0x10,%esp
f0101bd4:	85 c0                	test   %eax,%eax
f0101bd6:	74 07                	je     f0101bdf <mem_init+0x517>
		--nfree;
f0101bd8:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bd9:	8b 00                	mov    (%eax),%eax
f0101bdb:	85 c0                	test   %eax,%eax
f0101bdd:	75 f9                	jne    f0101bd8 <mem_init+0x510>
		--nfree;
	assert(nfree == 0);
f0101bdf:	85 db                	test   %ebx,%ebx
f0101be1:	74 19                	je     f0101bfc <mem_init+0x534>
f0101be3:	68 73 50 10 f0       	push   $0xf0105073
f0101be8:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101bed:	68 92 02 00 00       	push   $0x292
f0101bf2:	68 98 4e 10 f0       	push   $0xf0104e98
f0101bf7:	e8 8f e4 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bfc:	83 ec 0c             	sub    $0xc,%esp
f0101bff:	68 04 49 10 f0       	push   $0xf0104904
f0101c04:	e8 50 11 00 00       	call   f0102d59 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c10:	e8 95 f7 ff ff       	call   f01013aa <page_alloc>
f0101c15:	89 c6                	mov    %eax,%esi
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	75 19                	jne    f0101c37 <mem_init+0x56f>
f0101c1e:	68 81 4f 10 f0       	push   $0xf0104f81
f0101c23:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101c28:	68 f1 02 00 00       	push   $0x2f1
f0101c2d:	68 98 4e 10 f0       	push   $0xf0104e98
f0101c32:	e8 54 e4 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101c37:	83 ec 0c             	sub    $0xc,%esp
f0101c3a:	6a 00                	push   $0x0
f0101c3c:	e8 69 f7 ff ff       	call   f01013aa <page_alloc>
f0101c41:	89 c7                	mov    %eax,%edi
f0101c43:	83 c4 10             	add    $0x10,%esp
f0101c46:	85 c0                	test   %eax,%eax
f0101c48:	75 19                	jne    f0101c63 <mem_init+0x59b>
f0101c4a:	68 97 4f 10 f0       	push   $0xf0104f97
f0101c4f:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101c54:	68 f2 02 00 00       	push   $0x2f2
f0101c59:	68 98 4e 10 f0       	push   $0xf0104e98
f0101c5e:	e8 28 e4 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101c63:	83 ec 0c             	sub    $0xc,%esp
f0101c66:	6a 00                	push   $0x0
f0101c68:	e8 3d f7 ff ff       	call   f01013aa <page_alloc>
f0101c6d:	89 c3                	mov    %eax,%ebx
f0101c6f:	83 c4 10             	add    $0x10,%esp
f0101c72:	85 c0                	test   %eax,%eax
f0101c74:	75 19                	jne    f0101c8f <mem_init+0x5c7>
f0101c76:	68 ad 4f 10 f0       	push   $0xf0104fad
f0101c7b:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101c80:	68 f3 02 00 00       	push   $0x2f3
f0101c85:	68 98 4e 10 f0       	push   $0xf0104e98
f0101c8a:	e8 fc e3 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c8f:	39 fe                	cmp    %edi,%esi
f0101c91:	75 19                	jne    f0101cac <mem_init+0x5e4>
f0101c93:	68 c3 4f 10 f0       	push   $0xf0104fc3
f0101c98:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101c9d:	68 f6 02 00 00       	push   $0x2f6
f0101ca2:	68 98 4e 10 f0       	push   $0xf0104e98
f0101ca7:	e8 df e3 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cac:	39 c7                	cmp    %eax,%edi
f0101cae:	74 04                	je     f0101cb4 <mem_init+0x5ec>
f0101cb0:	39 c6                	cmp    %eax,%esi
f0101cb2:	75 19                	jne    f0101ccd <mem_init+0x605>
f0101cb4:	68 e4 48 10 f0       	push   $0xf01048e4
f0101cb9:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101cbe:	68 f7 02 00 00       	push   $0x2f7
f0101cc3:	68 98 4e 10 f0       	push   $0xf0104e98
f0101cc8:	e8 be e3 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ccd:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f0101cd3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101cd6:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f0101cdd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ce0:	83 ec 0c             	sub    $0xc,%esp
f0101ce3:	6a 00                	push   $0x0
f0101ce5:	e8 c0 f6 ff ff       	call   f01013aa <page_alloc>
f0101cea:	83 c4 10             	add    $0x10,%esp
f0101ced:	85 c0                	test   %eax,%eax
f0101cef:	74 19                	je     f0101d0a <mem_init+0x642>
f0101cf1:	68 2c 50 10 f0       	push   $0xf010502c
f0101cf6:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101cfb:	68 fe 02 00 00       	push   $0x2fe
f0101d00:	68 98 4e 10 f0       	push   $0xf0104e98
f0101d05:	e8 81 e3 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d0a:	83 ec 04             	sub    $0x4,%esp
f0101d0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d10:	50                   	push   %eax
f0101d11:	6a 00                	push   $0x0
f0101d13:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d19:	e8 83 f8 ff ff       	call   f01015a1 <page_lookup>
f0101d1e:	83 c4 10             	add    $0x10,%esp
f0101d21:	85 c0                	test   %eax,%eax
f0101d23:	74 19                	je     f0101d3e <mem_init+0x676>
f0101d25:	68 24 49 10 f0       	push   $0xf0104924
f0101d2a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101d2f:	68 01 03 00 00       	push   $0x301
f0101d34:	68 98 4e 10 f0       	push   $0xf0104e98
f0101d39:	e8 4d e3 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d3e:	6a 02                	push   $0x2
f0101d40:	6a 00                	push   $0x0
f0101d42:	57                   	push   %edi
f0101d43:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d49:	e8 11 f9 ff ff       	call   f010165f <page_insert>
f0101d4e:	83 c4 10             	add    $0x10,%esp
f0101d51:	85 c0                	test   %eax,%eax
f0101d53:	78 19                	js     f0101d6e <mem_init+0x6a6>
f0101d55:	68 5c 49 10 f0       	push   $0xf010495c
f0101d5a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101d5f:	68 04 03 00 00       	push   $0x304
f0101d64:	68 98 4e 10 f0       	push   $0xf0104e98
f0101d69:	e8 1d e3 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d6e:	83 ec 0c             	sub    $0xc,%esp
f0101d71:	56                   	push   %esi
f0101d72:	e8 bd f6 ff ff       	call   f0101434 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d77:	6a 02                	push   $0x2
f0101d79:	6a 00                	push   $0x0
f0101d7b:	57                   	push   %edi
f0101d7c:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d82:	e8 d8 f8 ff ff       	call   f010165f <page_insert>
f0101d87:	83 c4 20             	add    $0x20,%esp
f0101d8a:	85 c0                	test   %eax,%eax
f0101d8c:	74 19                	je     f0101da7 <mem_init+0x6df>
f0101d8e:	68 8c 49 10 f0       	push   $0xf010498c
f0101d93:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101d98:	68 08 03 00 00       	push   $0x308
f0101d9d:	68 98 4e 10 f0       	push   $0xf0104e98
f0101da2:	e8 e4 e2 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101da7:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101dac:	8b 08                	mov    (%eax),%ecx
f0101dae:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101db4:	89 f2                	mov    %esi,%edx
f0101db6:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101dbc:	c1 fa 03             	sar    $0x3,%edx
f0101dbf:	c1 e2 0c             	shl    $0xc,%edx
f0101dc2:	39 d1                	cmp    %edx,%ecx
f0101dc4:	74 19                	je     f0101ddf <mem_init+0x717>
f0101dc6:	68 bc 49 10 f0       	push   $0xf01049bc
f0101dcb:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101dd0:	68 09 03 00 00       	push   $0x309
f0101dd5:	68 98 4e 10 f0       	push   $0xf0104e98
f0101dda:	e8 ac e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ddf:	ba 00 00 00 00       	mov    $0x0,%edx
f0101de4:	e8 ae f1 ff ff       	call   f0100f97 <check_va2pa>
f0101de9:	89 fa                	mov    %edi,%edx
f0101deb:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101df1:	c1 fa 03             	sar    $0x3,%edx
f0101df4:	c1 e2 0c             	shl    $0xc,%edx
f0101df7:	39 d0                	cmp    %edx,%eax
f0101df9:	74 19                	je     f0101e14 <mem_init+0x74c>
f0101dfb:	68 e4 49 10 f0       	push   $0xf01049e4
f0101e00:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101e05:	68 0a 03 00 00       	push   $0x30a
f0101e0a:	68 98 4e 10 f0       	push   $0xf0104e98
f0101e0f:	e8 77 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101e14:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e19:	74 19                	je     f0101e34 <mem_init+0x76c>
f0101e1b:	68 7e 50 10 f0       	push   $0xf010507e
f0101e20:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101e25:	68 0b 03 00 00       	push   $0x30b
f0101e2a:	68 98 4e 10 f0       	push   $0xf0104e98
f0101e2f:	e8 57 e2 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101e34:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e39:	74 19                	je     f0101e54 <mem_init+0x78c>
f0101e3b:	68 8f 50 10 f0       	push   $0xf010508f
f0101e40:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101e45:	68 0c 03 00 00       	push   $0x30c
f0101e4a:	68 98 4e 10 f0       	push   $0xf0104e98
f0101e4f:	e8 37 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e54:	6a 02                	push   $0x2
f0101e56:	68 00 10 00 00       	push   $0x1000
f0101e5b:	53                   	push   %ebx
f0101e5c:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101e62:	e8 f8 f7 ff ff       	call   f010165f <page_insert>
f0101e67:	83 c4 10             	add    $0x10,%esp
f0101e6a:	85 c0                	test   %eax,%eax
f0101e6c:	74 19                	je     f0101e87 <mem_init+0x7bf>
f0101e6e:	68 14 4a 10 f0       	push   $0xf0104a14
f0101e73:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101e78:	68 0f 03 00 00       	push   $0x30f
f0101e7d:	68 98 4e 10 f0       	push   $0xf0104e98
f0101e82:	e8 04 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e87:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e8c:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101e91:	e8 01 f1 ff ff       	call   f0100f97 <check_va2pa>
f0101e96:	89 da                	mov    %ebx,%edx
f0101e98:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101e9e:	c1 fa 03             	sar    $0x3,%edx
f0101ea1:	c1 e2 0c             	shl    $0xc,%edx
f0101ea4:	39 d0                	cmp    %edx,%eax
f0101ea6:	74 19                	je     f0101ec1 <mem_init+0x7f9>
f0101ea8:	68 50 4a 10 f0       	push   $0xf0104a50
f0101ead:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101eb2:	68 10 03 00 00       	push   $0x310
f0101eb7:	68 98 4e 10 f0       	push   $0xf0104e98
f0101ebc:	e8 ca e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101ec1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ec6:	74 19                	je     f0101ee1 <mem_init+0x819>
f0101ec8:	68 a0 50 10 f0       	push   $0xf01050a0
f0101ecd:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101ed2:	68 11 03 00 00       	push   $0x311
f0101ed7:	68 98 4e 10 f0       	push   $0xf0104e98
f0101edc:	e8 aa e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ee1:	83 ec 0c             	sub    $0xc,%esp
f0101ee4:	6a 00                	push   $0x0
f0101ee6:	e8 bf f4 ff ff       	call   f01013aa <page_alloc>
f0101eeb:	83 c4 10             	add    $0x10,%esp
f0101eee:	85 c0                	test   %eax,%eax
f0101ef0:	74 19                	je     f0101f0b <mem_init+0x843>
f0101ef2:	68 2c 50 10 f0       	push   $0xf010502c
f0101ef7:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101efc:	68 14 03 00 00       	push   $0x314
f0101f01:	68 98 4e 10 f0       	push   $0xf0104e98
f0101f06:	e8 80 e1 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f0b:	6a 02                	push   $0x2
f0101f0d:	68 00 10 00 00       	push   $0x1000
f0101f12:	53                   	push   %ebx
f0101f13:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101f19:	e8 41 f7 ff ff       	call   f010165f <page_insert>
f0101f1e:	83 c4 10             	add    $0x10,%esp
f0101f21:	85 c0                	test   %eax,%eax
f0101f23:	74 19                	je     f0101f3e <mem_init+0x876>
f0101f25:	68 14 4a 10 f0       	push   $0xf0104a14
f0101f2a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101f2f:	68 17 03 00 00       	push   $0x317
f0101f34:	68 98 4e 10 f0       	push   $0xf0104e98
f0101f39:	e8 4d e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f3e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f43:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101f48:	e8 4a f0 ff ff       	call   f0100f97 <check_va2pa>
f0101f4d:	89 da                	mov    %ebx,%edx
f0101f4f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101f55:	c1 fa 03             	sar    $0x3,%edx
f0101f58:	c1 e2 0c             	shl    $0xc,%edx
f0101f5b:	39 d0                	cmp    %edx,%eax
f0101f5d:	74 19                	je     f0101f78 <mem_init+0x8b0>
f0101f5f:	68 50 4a 10 f0       	push   $0xf0104a50
f0101f64:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101f69:	68 18 03 00 00       	push   $0x318
f0101f6e:	68 98 4e 10 f0       	push   $0xf0104e98
f0101f73:	e8 13 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101f78:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f7d:	74 19                	je     f0101f98 <mem_init+0x8d0>
f0101f7f:	68 a0 50 10 f0       	push   $0xf01050a0
f0101f84:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101f89:	68 19 03 00 00       	push   $0x319
f0101f8e:	68 98 4e 10 f0       	push   $0xf0104e98
f0101f93:	e8 f3 e0 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f98:	83 ec 0c             	sub    $0xc,%esp
f0101f9b:	6a 00                	push   $0x0
f0101f9d:	e8 08 f4 ff ff       	call   f01013aa <page_alloc>
f0101fa2:	83 c4 10             	add    $0x10,%esp
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	74 19                	je     f0101fc2 <mem_init+0x8fa>
f0101fa9:	68 2c 50 10 f0       	push   $0xf010502c
f0101fae:	68 be 4e 10 f0       	push   $0xf0104ebe
f0101fb3:	68 1d 03 00 00       	push   $0x31d
f0101fb8:	68 98 4e 10 f0       	push   $0xf0104e98
f0101fbd:	e8 c9 e0 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fc2:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f0101fc8:	8b 02                	mov    (%edx),%eax
f0101fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fcf:	89 c1                	mov    %eax,%ecx
f0101fd1:	c1 e9 0c             	shr    $0xc,%ecx
f0101fd4:	3b 0d 44 f9 11 f0    	cmp    0xf011f944,%ecx
f0101fda:	72 15                	jb     f0101ff1 <mem_init+0x929>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fdc:	50                   	push   %eax
f0101fdd:	68 a0 47 10 f0       	push   $0xf01047a0
f0101fe2:	68 20 03 00 00       	push   $0x320
f0101fe7:	68 98 4e 10 f0       	push   $0xf0104e98
f0101fec:	e8 9a e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101ff1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ff9:	83 ec 04             	sub    $0x4,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	68 00 10 00 00       	push   $0x1000
f0102003:	52                   	push   %edx
f0102004:	e8 69 f4 ff ff       	call   f0101472 <pgdir_walk>
f0102009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010200c:	83 c2 04             	add    $0x4,%edx
f010200f:	83 c4 10             	add    $0x10,%esp
f0102012:	39 d0                	cmp    %edx,%eax
f0102014:	74 19                	je     f010202f <mem_init+0x967>
f0102016:	68 80 4a 10 f0       	push   $0xf0104a80
f010201b:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102020:	68 21 03 00 00       	push   $0x321
f0102025:	68 98 4e 10 f0       	push   $0xf0104e98
f010202a:	e8 5c e0 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010202f:	6a 06                	push   $0x6
f0102031:	68 00 10 00 00       	push   $0x1000
f0102036:	53                   	push   %ebx
f0102037:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010203d:	e8 1d f6 ff ff       	call   f010165f <page_insert>
f0102042:	83 c4 10             	add    $0x10,%esp
f0102045:	85 c0                	test   %eax,%eax
f0102047:	74 19                	je     f0102062 <mem_init+0x99a>
f0102049:	68 c0 4a 10 f0       	push   $0xf0104ac0
f010204e:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102053:	68 24 03 00 00       	push   $0x324
f0102058:	68 98 4e 10 f0       	push   $0xf0104e98
f010205d:	e8 29 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102062:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102067:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010206c:	e8 26 ef ff ff       	call   f0100f97 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102071:	89 da                	mov    %ebx,%edx
f0102073:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102079:	c1 fa 03             	sar    $0x3,%edx
f010207c:	c1 e2 0c             	shl    $0xc,%edx
f010207f:	39 d0                	cmp    %edx,%eax
f0102081:	74 19                	je     f010209c <mem_init+0x9d4>
f0102083:	68 50 4a 10 f0       	push   $0xf0104a50
f0102088:	68 be 4e 10 f0       	push   $0xf0104ebe
f010208d:	68 25 03 00 00       	push   $0x325
f0102092:	68 98 4e 10 f0       	push   $0xf0104e98
f0102097:	e8 ef df ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010209c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020a1:	74 19                	je     f01020bc <mem_init+0x9f4>
f01020a3:	68 a0 50 10 f0       	push   $0xf01050a0
f01020a8:	68 be 4e 10 f0       	push   $0xf0104ebe
f01020ad:	68 26 03 00 00       	push   $0x326
f01020b2:	68 98 4e 10 f0       	push   $0xf0104e98
f01020b7:	e8 cf df ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020bc:	83 ec 04             	sub    $0x4,%esp
f01020bf:	6a 00                	push   $0x0
f01020c1:	68 00 10 00 00       	push   $0x1000
f01020c6:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01020cc:	e8 a1 f3 ff ff       	call   f0101472 <pgdir_walk>
f01020d1:	83 c4 10             	add    $0x10,%esp
f01020d4:	f6 00 04             	testb  $0x4,(%eax)
f01020d7:	75 19                	jne    f01020f2 <mem_init+0xa2a>
f01020d9:	68 00 4b 10 f0       	push   $0xf0104b00
f01020de:	68 be 4e 10 f0       	push   $0xf0104ebe
f01020e3:	68 27 03 00 00       	push   $0x327
f01020e8:	68 98 4e 10 f0       	push   $0xf0104e98
f01020ed:	e8 99 df ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020f2:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01020f7:	f6 00 04             	testb  $0x4,(%eax)
f01020fa:	75 19                	jne    f0102115 <mem_init+0xa4d>
f01020fc:	68 b1 50 10 f0       	push   $0xf01050b1
f0102101:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102106:	68 28 03 00 00       	push   $0x328
f010210b:	68 98 4e 10 f0       	push   $0xf0104e98
f0102110:	e8 76 df ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102115:	6a 02                	push   $0x2
f0102117:	68 00 10 00 00       	push   $0x1000
f010211c:	53                   	push   %ebx
f010211d:	50                   	push   %eax
f010211e:	e8 3c f5 ff ff       	call   f010165f <page_insert>
f0102123:	83 c4 10             	add    $0x10,%esp
f0102126:	85 c0                	test   %eax,%eax
f0102128:	74 19                	je     f0102143 <mem_init+0xa7b>
f010212a:	68 14 4a 10 f0       	push   $0xf0104a14
f010212f:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102134:	68 2b 03 00 00       	push   $0x32b
f0102139:	68 98 4e 10 f0       	push   $0xf0104e98
f010213e:	e8 48 df ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102143:	83 ec 04             	sub    $0x4,%esp
f0102146:	6a 00                	push   $0x0
f0102148:	68 00 10 00 00       	push   $0x1000
f010214d:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102153:	e8 1a f3 ff ff       	call   f0101472 <pgdir_walk>
f0102158:	83 c4 10             	add    $0x10,%esp
f010215b:	f6 00 02             	testb  $0x2,(%eax)
f010215e:	75 19                	jne    f0102179 <mem_init+0xab1>
f0102160:	68 34 4b 10 f0       	push   $0xf0104b34
f0102165:	68 be 4e 10 f0       	push   $0xf0104ebe
f010216a:	68 2c 03 00 00       	push   $0x32c
f010216f:	68 98 4e 10 f0       	push   $0xf0104e98
f0102174:	e8 12 df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102179:	83 ec 04             	sub    $0x4,%esp
f010217c:	6a 00                	push   $0x0
f010217e:	68 00 10 00 00       	push   $0x1000
f0102183:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102189:	e8 e4 f2 ff ff       	call   f0101472 <pgdir_walk>
f010218e:	83 c4 10             	add    $0x10,%esp
f0102191:	f6 00 04             	testb  $0x4,(%eax)
f0102194:	74 19                	je     f01021af <mem_init+0xae7>
f0102196:	68 68 4b 10 f0       	push   $0xf0104b68
f010219b:	68 be 4e 10 f0       	push   $0xf0104ebe
f01021a0:	68 2d 03 00 00       	push   $0x32d
f01021a5:	68 98 4e 10 f0       	push   $0xf0104e98
f01021aa:	e8 dc de ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021af:	6a 02                	push   $0x2
f01021b1:	68 00 00 40 00       	push   $0x400000
f01021b6:	56                   	push   %esi
f01021b7:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01021bd:	e8 9d f4 ff ff       	call   f010165f <page_insert>
f01021c2:	83 c4 10             	add    $0x10,%esp
f01021c5:	85 c0                	test   %eax,%eax
f01021c7:	78 19                	js     f01021e2 <mem_init+0xb1a>
f01021c9:	68 a0 4b 10 f0       	push   $0xf0104ba0
f01021ce:	68 be 4e 10 f0       	push   $0xf0104ebe
f01021d3:	68 30 03 00 00       	push   $0x330
f01021d8:	68 98 4e 10 f0       	push   $0xf0104e98
f01021dd:	e8 a9 de ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021e2:	6a 02                	push   $0x2
f01021e4:	68 00 10 00 00       	push   $0x1000
f01021e9:	57                   	push   %edi
f01021ea:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01021f0:	e8 6a f4 ff ff       	call   f010165f <page_insert>
f01021f5:	83 c4 10             	add    $0x10,%esp
f01021f8:	85 c0                	test   %eax,%eax
f01021fa:	74 19                	je     f0102215 <mem_init+0xb4d>
f01021fc:	68 d8 4b 10 f0       	push   $0xf0104bd8
f0102201:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102206:	68 33 03 00 00       	push   $0x333
f010220b:	68 98 4e 10 f0       	push   $0xf0104e98
f0102210:	e8 76 de ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102215:	83 ec 04             	sub    $0x4,%esp
f0102218:	6a 00                	push   $0x0
f010221a:	68 00 10 00 00       	push   $0x1000
f010221f:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102225:	e8 48 f2 ff ff       	call   f0101472 <pgdir_walk>
f010222a:	83 c4 10             	add    $0x10,%esp
f010222d:	f6 00 04             	testb  $0x4,(%eax)
f0102230:	74 19                	je     f010224b <mem_init+0xb83>
f0102232:	68 68 4b 10 f0       	push   $0xf0104b68
f0102237:	68 be 4e 10 f0       	push   $0xf0104ebe
f010223c:	68 34 03 00 00       	push   $0x334
f0102241:	68 98 4e 10 f0       	push   $0xf0104e98
f0102246:	e8 40 de ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010224b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102250:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102255:	e8 3d ed ff ff       	call   f0100f97 <check_va2pa>
f010225a:	89 fa                	mov    %edi,%edx
f010225c:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102262:	c1 fa 03             	sar    $0x3,%edx
f0102265:	c1 e2 0c             	shl    $0xc,%edx
f0102268:	39 d0                	cmp    %edx,%eax
f010226a:	74 19                	je     f0102285 <mem_init+0xbbd>
f010226c:	68 14 4c 10 f0       	push   $0xf0104c14
f0102271:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102276:	68 37 03 00 00       	push   $0x337
f010227b:	68 98 4e 10 f0       	push   $0xf0104e98
f0102280:	e8 06 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102285:	ba 00 10 00 00       	mov    $0x1000,%edx
f010228a:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010228f:	e8 03 ed ff ff       	call   f0100f97 <check_va2pa>
f0102294:	89 fa                	mov    %edi,%edx
f0102296:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f010229c:	c1 fa 03             	sar    $0x3,%edx
f010229f:	c1 e2 0c             	shl    $0xc,%edx
f01022a2:	39 d0                	cmp    %edx,%eax
f01022a4:	74 19                	je     f01022bf <mem_init+0xbf7>
f01022a6:	68 40 4c 10 f0       	push   $0xf0104c40
f01022ab:	68 be 4e 10 f0       	push   $0xf0104ebe
f01022b0:	68 38 03 00 00       	push   $0x338
f01022b5:	68 98 4e 10 f0       	push   $0xf0104e98
f01022ba:	e8 cc dd ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022bf:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01022c4:	74 19                	je     f01022df <mem_init+0xc17>
f01022c6:	68 c7 50 10 f0       	push   $0xf01050c7
f01022cb:	68 be 4e 10 f0       	push   $0xf0104ebe
f01022d0:	68 3a 03 00 00       	push   $0x33a
f01022d5:	68 98 4e 10 f0       	push   $0xf0104e98
f01022da:	e8 ac dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01022df:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022e4:	74 19                	je     f01022ff <mem_init+0xc37>
f01022e6:	68 d8 50 10 f0       	push   $0xf01050d8
f01022eb:	68 be 4e 10 f0       	push   $0xf0104ebe
f01022f0:	68 3b 03 00 00       	push   $0x33b
f01022f5:	68 98 4e 10 f0       	push   $0xf0104e98
f01022fa:	e8 8c dd ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022ff:	83 ec 0c             	sub    $0xc,%esp
f0102302:	6a 00                	push   $0x0
f0102304:	e8 a1 f0 ff ff       	call   f01013aa <page_alloc>
f0102309:	83 c4 10             	add    $0x10,%esp
f010230c:	85 c0                	test   %eax,%eax
f010230e:	74 04                	je     f0102314 <mem_init+0xc4c>
f0102310:	39 c3                	cmp    %eax,%ebx
f0102312:	74 19                	je     f010232d <mem_init+0xc65>
f0102314:	68 70 4c 10 f0       	push   $0xf0104c70
f0102319:	68 be 4e 10 f0       	push   $0xf0104ebe
f010231e:	68 3e 03 00 00       	push   $0x33e
f0102323:	68 98 4e 10 f0       	push   $0xf0104e98
f0102328:	e8 5e dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010232d:	83 ec 08             	sub    $0x8,%esp
f0102330:	6a 00                	push   $0x0
f0102332:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102338:	e8 d5 f2 ff ff       	call   f0101612 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010233d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102342:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102347:	e8 4b ec ff ff       	call   f0100f97 <check_va2pa>
f010234c:	83 c4 10             	add    $0x10,%esp
f010234f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102352:	74 19                	je     f010236d <mem_init+0xca5>
f0102354:	68 94 4c 10 f0       	push   $0xf0104c94
f0102359:	68 be 4e 10 f0       	push   $0xf0104ebe
f010235e:	68 42 03 00 00       	push   $0x342
f0102363:	68 98 4e 10 f0       	push   $0xf0104e98
f0102368:	e8 1e dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010236d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102372:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102377:	e8 1b ec ff ff       	call   f0100f97 <check_va2pa>
f010237c:	89 fa                	mov    %edi,%edx
f010237e:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102384:	c1 fa 03             	sar    $0x3,%edx
f0102387:	c1 e2 0c             	shl    $0xc,%edx
f010238a:	39 d0                	cmp    %edx,%eax
f010238c:	74 19                	je     f01023a7 <mem_init+0xcdf>
f010238e:	68 40 4c 10 f0       	push   $0xf0104c40
f0102393:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102398:	68 43 03 00 00       	push   $0x343
f010239d:	68 98 4e 10 f0       	push   $0xf0104e98
f01023a2:	e8 e4 dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01023a7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023ac:	74 19                	je     f01023c7 <mem_init+0xcff>
f01023ae:	68 7e 50 10 f0       	push   $0xf010507e
f01023b3:	68 be 4e 10 f0       	push   $0xf0104ebe
f01023b8:	68 44 03 00 00       	push   $0x344
f01023bd:	68 98 4e 10 f0       	push   $0xf0104e98
f01023c2:	e8 c4 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01023c7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023cc:	74 19                	je     f01023e7 <mem_init+0xd1f>
f01023ce:	68 d8 50 10 f0       	push   $0xf01050d8
f01023d3:	68 be 4e 10 f0       	push   $0xf0104ebe
f01023d8:	68 45 03 00 00       	push   $0x345
f01023dd:	68 98 4e 10 f0       	push   $0xf0104e98
f01023e2:	e8 a4 dc ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023e7:	83 ec 08             	sub    $0x8,%esp
f01023ea:	68 00 10 00 00       	push   $0x1000
f01023ef:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01023f5:	e8 18 f2 ff ff       	call   f0101612 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01023ff:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102404:	e8 8e eb ff ff       	call   f0100f97 <check_va2pa>
f0102409:	83 c4 10             	add    $0x10,%esp
f010240c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010240f:	74 19                	je     f010242a <mem_init+0xd62>
f0102411:	68 94 4c 10 f0       	push   $0xf0104c94
f0102416:	68 be 4e 10 f0       	push   $0xf0104ebe
f010241b:	68 49 03 00 00       	push   $0x349
f0102420:	68 98 4e 10 f0       	push   $0xf0104e98
f0102425:	e8 61 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010242a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010242f:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102434:	e8 5e eb ff ff       	call   f0100f97 <check_va2pa>
f0102439:	83 f8 ff             	cmp    $0xffffffff,%eax
f010243c:	74 19                	je     f0102457 <mem_init+0xd8f>
f010243e:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0102443:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102448:	68 4a 03 00 00       	push   $0x34a
f010244d:	68 98 4e 10 f0       	push   $0xf0104e98
f0102452:	e8 34 dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102457:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010245c:	74 19                	je     f0102477 <mem_init+0xdaf>
f010245e:	68 e9 50 10 f0       	push   $0xf01050e9
f0102463:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102468:	68 4b 03 00 00       	push   $0x34b
f010246d:	68 98 4e 10 f0       	push   $0xf0104e98
f0102472:	e8 14 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102477:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010247c:	74 19                	je     f0102497 <mem_init+0xdcf>
f010247e:	68 d8 50 10 f0       	push   $0xf01050d8
f0102483:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102488:	68 4c 03 00 00       	push   $0x34c
f010248d:	68 98 4e 10 f0       	push   $0xf0104e98
f0102492:	e8 f4 db ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102497:	83 ec 0c             	sub    $0xc,%esp
f010249a:	6a 00                	push   $0x0
f010249c:	e8 09 ef ff ff       	call   f01013aa <page_alloc>
f01024a1:	83 c4 10             	add    $0x10,%esp
f01024a4:	85 c0                	test   %eax,%eax
f01024a6:	74 04                	je     f01024ac <mem_init+0xde4>
f01024a8:	39 c7                	cmp    %eax,%edi
f01024aa:	74 19                	je     f01024c5 <mem_init+0xdfd>
f01024ac:	68 e0 4c 10 f0       	push   $0xf0104ce0
f01024b1:	68 be 4e 10 f0       	push   $0xf0104ebe
f01024b6:	68 4f 03 00 00       	push   $0x34f
f01024bb:	68 98 4e 10 f0       	push   $0xf0104e98
f01024c0:	e8 c6 db ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024c5:	83 ec 0c             	sub    $0xc,%esp
f01024c8:	6a 00                	push   $0x0
f01024ca:	e8 db ee ff ff       	call   f01013aa <page_alloc>
f01024cf:	83 c4 10             	add    $0x10,%esp
f01024d2:	85 c0                	test   %eax,%eax
f01024d4:	74 19                	je     f01024ef <mem_init+0xe27>
f01024d6:	68 2c 50 10 f0       	push   $0xf010502c
f01024db:	68 be 4e 10 f0       	push   $0xf0104ebe
f01024e0:	68 52 03 00 00       	push   $0x352
f01024e5:	68 98 4e 10 f0       	push   $0xf0104e98
f01024ea:	e8 9c db ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024ef:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01024f4:	8b 08                	mov    (%eax),%ecx
f01024f6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024fc:	89 f2                	mov    %esi,%edx
f01024fe:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102504:	c1 fa 03             	sar    $0x3,%edx
f0102507:	c1 e2 0c             	shl    $0xc,%edx
f010250a:	39 d1                	cmp    %edx,%ecx
f010250c:	74 19                	je     f0102527 <mem_init+0xe5f>
f010250e:	68 bc 49 10 f0       	push   $0xf01049bc
f0102513:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102518:	68 55 03 00 00       	push   $0x355
f010251d:	68 98 4e 10 f0       	push   $0xf0104e98
f0102522:	e8 64 db ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102527:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010252d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102532:	74 19                	je     f010254d <mem_init+0xe85>
f0102534:	68 8f 50 10 f0       	push   $0xf010508f
f0102539:	68 be 4e 10 f0       	push   $0xf0104ebe
f010253e:	68 57 03 00 00       	push   $0x357
f0102543:	68 98 4e 10 f0       	push   $0xf0104e98
f0102548:	e8 3e db ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010254d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102553:	83 ec 0c             	sub    $0xc,%esp
f0102556:	56                   	push   %esi
f0102557:	e8 d8 ee ff ff       	call   f0101434 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010255c:	83 c4 0c             	add    $0xc,%esp
f010255f:	6a 01                	push   $0x1
f0102561:	68 00 10 40 00       	push   $0x401000
f0102566:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010256c:	e8 01 ef ff ff       	call   f0101472 <pgdir_walk>
f0102571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102574:	8b 0d 48 f9 11 f0    	mov    0xf011f948,%ecx
f010257a:	8b 51 04             	mov    0x4(%ecx),%edx
f010257d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102583:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102586:	c1 ea 0c             	shr    $0xc,%edx
f0102589:	83 c4 10             	add    $0x10,%esp
f010258c:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102592:	72 17                	jb     f01025ab <mem_init+0xee3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102594:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102597:	68 a0 47 10 f0       	push   $0xf01047a0
f010259c:	68 5e 03 00 00       	push   $0x35e
f01025a1:	68 98 4e 10 f0       	push   $0xf0104e98
f01025a6:	e8 e0 da ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01025ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01025ae:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01025b4:	39 d0                	cmp    %edx,%eax
f01025b6:	74 19                	je     f01025d1 <mem_init+0xf09>
f01025b8:	68 fa 50 10 f0       	push   $0xf01050fa
f01025bd:	68 be 4e 10 f0       	push   $0xf0104ebe
f01025c2:	68 5f 03 00 00       	push   $0x35f
f01025c7:	68 98 4e 10 f0       	push   $0xf0104e98
f01025cc:	e8 ba da ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01025d1:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01025d8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025de:	89 f0                	mov    %esi,%eax
f01025e0:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01025e6:	c1 f8 03             	sar    $0x3,%eax
f01025e9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025ec:	89 c2                	mov    %eax,%edx
f01025ee:	c1 ea 0c             	shr    $0xc,%edx
f01025f1:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01025f7:	72 12                	jb     f010260b <mem_init+0xf43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025f9:	50                   	push   %eax
f01025fa:	68 a0 47 10 f0       	push   $0xf01047a0
f01025ff:	6a 52                	push   $0x52
f0102601:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0102606:	e8 80 da ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010260b:	83 ec 04             	sub    $0x4,%esp
f010260e:	68 00 10 00 00       	push   $0x1000
f0102613:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102618:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010261d:	50                   	push   %eax
f010261e:	e8 66 12 00 00       	call   f0103889 <memset>
	page_free(pp0);
f0102623:	89 34 24             	mov    %esi,(%esp)
f0102626:	e8 09 ee ff ff       	call   f0101434 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010262b:	83 c4 0c             	add    $0xc,%esp
f010262e:	6a 01                	push   $0x1
f0102630:	6a 00                	push   $0x0
f0102632:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102638:	e8 35 ee ff ff       	call   f0101472 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010263d:	89 f2                	mov    %esi,%edx
f010263f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102645:	c1 fa 03             	sar    $0x3,%edx
f0102648:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010264b:	89 d0                	mov    %edx,%eax
f010264d:	c1 e8 0c             	shr    $0xc,%eax
f0102650:	83 c4 10             	add    $0x10,%esp
f0102653:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f0102659:	72 12                	jb     f010266d <mem_init+0xfa5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010265b:	52                   	push   %edx
f010265c:	68 a0 47 10 f0       	push   $0xf01047a0
f0102661:	6a 52                	push   $0x52
f0102663:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0102668:	e8 1e da ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010266d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102673:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102676:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010267d:	75 11                	jne    f0102690 <mem_init+0xfc8>
f010267f:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102685:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010268b:	f6 00 01             	testb  $0x1,(%eax)
f010268e:	74 19                	je     f01026a9 <mem_init+0xfe1>
f0102690:	68 12 51 10 f0       	push   $0xf0105112
f0102695:	68 be 4e 10 f0       	push   $0xf0104ebe
f010269a:	68 69 03 00 00       	push   $0x369
f010269f:	68 98 4e 10 f0       	push   $0xf0104e98
f01026a4:	e8 e2 d9 ff ff       	call   f010008b <_panic>
f01026a9:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01026ac:	39 d0                	cmp    %edx,%eax
f01026ae:	75 db                	jne    f010268b <mem_init+0xfc3>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01026b0:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01026b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01026bb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01026c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026c4:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c

	// free the pages we took
	page_free(pp0);
f01026c9:	83 ec 0c             	sub    $0xc,%esp
f01026cc:	56                   	push   %esi
f01026cd:	e8 62 ed ff ff       	call   f0101434 <page_free>
	page_free(pp1);
f01026d2:	89 3c 24             	mov    %edi,(%esp)
f01026d5:	e8 5a ed ff ff       	call   f0101434 <page_free>
	page_free(pp2);
f01026da:	89 1c 24             	mov    %ebx,(%esp)
f01026dd:	e8 52 ed ff ff       	call   f0101434 <page_free>

	cprintf("check_page() succeeded!\n");
f01026e2:	c7 04 24 29 51 10 f0 	movl   $0xf0105129,(%esp)
f01026e9:	e8 6b 06 00 00       	call   f0102d59 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026ee:	a1 4c f9 11 f0       	mov    0xf011f94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f3:	83 c4 10             	add    $0x10,%esp
f01026f6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026fb:	77 15                	ja     f0102712 <mem_init+0x104a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026fd:	50                   	push   %eax
f01026fe:	68 d8 45 10 f0       	push   $0xf01045d8
f0102703:	68 b5 00 00 00       	push   $0xb5
f0102708:	68 98 4e 10 f0       	push   $0xf0104e98
f010270d:	e8 79 d9 ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102712:	8b 15 44 f9 11 f0    	mov    0xf011f944,%edx
f0102718:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010271f:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102722:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102728:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010272a:	05 00 00 00 10       	add    $0x10000000,%eax
f010272f:	50                   	push   %eax
f0102730:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102735:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010273a:	e8 ca ed ff ff       	call   f0101509 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010273f:	83 c4 10             	add    $0x10,%esp
f0102742:	ba 00 50 11 f0       	mov    $0xf0115000,%edx
f0102747:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010274d:	77 15                	ja     f0102764 <mem_init+0x109c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010274f:	52                   	push   %edx
f0102750:	68 d8 45 10 f0       	push   $0xf01045d8
f0102755:	68 c7 00 00 00       	push   $0xc7
f010275a:	68 98 4e 10 f0       	push   $0xf0104e98
f010275f:	e8 27 d9 ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102764:	83 ec 08             	sub    $0x8,%esp
f0102767:	6a 02                	push   $0x2
f0102769:	68 00 50 11 00       	push   $0x115000
f010276e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102773:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102778:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010277d:	e8 87 ed ff ff       	call   f0101509 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102782:	83 c4 08             	add    $0x8,%esp
f0102785:	68 82 00 00 00       	push   $0x82
f010278a:	6a 00                	push   $0x0
f010278c:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102791:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102796:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010279b:	e8 69 ed ff ff       	call   f0101509 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027a0:	8b 1d 48 f9 11 f0    	mov    0xf011f948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027a6:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01027ab:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01027b2:	83 c4 10             	add    $0x10,%esp
f01027b5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01027bb:	74 63                	je     f0102820 <mem_init+0x1158>
f01027bd:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027c2:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01027c8:	89 d8                	mov    %ebx,%eax
f01027ca:	e8 c8 e7 ff ff       	call   f0100f97 <check_va2pa>
f01027cf:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027db:	77 15                	ja     f01027f2 <mem_init+0x112a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027dd:	52                   	push   %edx
f01027de:	68 d8 45 10 f0       	push   $0xf01045d8
f01027e3:	68 aa 02 00 00       	push   $0x2aa
f01027e8:	68 98 4e 10 f0       	push   $0xf0104e98
f01027ed:	e8 99 d8 ff ff       	call   f010008b <_panic>
f01027f2:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027f9:	39 d0                	cmp    %edx,%eax
f01027fb:	74 19                	je     f0102816 <mem_init+0x114e>
f01027fd:	68 04 4d 10 f0       	push   $0xf0104d04
f0102802:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102807:	68 aa 02 00 00       	push   $0x2aa
f010280c:	68 98 4e 10 f0       	push   $0xf0104e98
f0102811:	e8 75 d8 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102816:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010281c:	39 f7                	cmp    %esi,%edi
f010281e:	77 a2                	ja     f01027c2 <mem_init+0x10fa>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102820:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0102825:	c1 e0 0c             	shl    $0xc,%eax
f0102828:	74 41                	je     f010286b <mem_init+0x11a3>
f010282a:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010282f:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102835:	89 d8                	mov    %ebx,%eax
f0102837:	e8 5b e7 ff ff       	call   f0100f97 <check_va2pa>
f010283c:	39 c6                	cmp    %eax,%esi
f010283e:	74 19                	je     f0102859 <mem_init+0x1191>
f0102840:	68 38 4d 10 f0       	push   $0xf0104d38
f0102845:	68 be 4e 10 f0       	push   $0xf0104ebe
f010284a:	68 af 02 00 00       	push   $0x2af
f010284f:	68 98 4e 10 f0       	push   $0xf0104e98
f0102854:	e8 32 d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102859:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010285f:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0102864:	c1 e0 0c             	shl    $0xc,%eax
f0102867:	39 c6                	cmp    %eax,%esi
f0102869:	72 c4                	jb     f010282f <mem_init+0x1167>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010286b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102870:	89 d8                	mov    %ebx,%eax
f0102872:	e8 20 e7 ff ff       	call   f0100f97 <check_va2pa>
f0102877:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010287c:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
f0102881:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102887:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010288a:	39 d0                	cmp    %edx,%eax
f010288c:	74 19                	je     f01028a7 <mem_init+0x11df>
f010288e:	68 60 4d 10 f0       	push   $0xf0104d60
f0102893:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102898:	68 b3 02 00 00       	push   $0x2b3
f010289d:	68 98 4e 10 f0       	push   $0xf0104e98
f01028a2:	e8 e4 d7 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028a7:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028ad:	0f 85 2e 04 00 00    	jne    f0102ce1 <mem_init+0x1619>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028b3:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028b8:	89 d8                	mov    %ebx,%eax
f01028ba:	e8 d8 e6 ff ff       	call   f0100f97 <check_va2pa>
f01028bf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028c2:	74 19                	je     f01028dd <mem_init+0x1215>
f01028c4:	68 a8 4d 10 f0       	push   $0xf0104da8
f01028c9:	68 be 4e 10 f0       	push   $0xf0104ebe
f01028ce:	68 b4 02 00 00       	push   $0x2b4
f01028d3:	68 98 4e 10 f0       	push   $0xf0104e98
f01028d8:	e8 ae d7 ff ff       	call   f010008b <_panic>
f01028dd:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028e2:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01028e7:	72 2d                	jb     f0102916 <mem_init+0x124e>
f01028e9:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028ee:	76 07                	jbe    f01028f7 <mem_init+0x122f>
f01028f0:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028f5:	75 1f                	jne    f0102916 <mem_init+0x124e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01028f7:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01028fb:	75 7e                	jne    f010297b <mem_init+0x12b3>
f01028fd:	68 42 51 10 f0       	push   $0xf0105142
f0102902:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102907:	68 bc 02 00 00       	push   $0x2bc
f010290c:	68 98 4e 10 f0       	push   $0xf0104e98
f0102911:	e8 75 d7 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102916:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010291b:	76 3f                	jbe    f010295c <mem_init+0x1294>
				assert(pgdir[i] & PTE_P);
f010291d:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102920:	f6 c2 01             	test   $0x1,%dl
f0102923:	75 19                	jne    f010293e <mem_init+0x1276>
f0102925:	68 42 51 10 f0       	push   $0xf0105142
f010292a:	68 be 4e 10 f0       	push   $0xf0104ebe
f010292f:	68 c0 02 00 00       	push   $0x2c0
f0102934:	68 98 4e 10 f0       	push   $0xf0104e98
f0102939:	e8 4d d7 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f010293e:	f6 c2 02             	test   $0x2,%dl
f0102941:	75 38                	jne    f010297b <mem_init+0x12b3>
f0102943:	68 53 51 10 f0       	push   $0xf0105153
f0102948:	68 be 4e 10 f0       	push   $0xf0104ebe
f010294d:	68 c1 02 00 00       	push   $0x2c1
f0102952:	68 98 4e 10 f0       	push   $0xf0104e98
f0102957:	e8 2f d7 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f010295c:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102960:	74 19                	je     f010297b <mem_init+0x12b3>
f0102962:	68 64 51 10 f0       	push   $0xf0105164
f0102967:	68 be 4e 10 f0       	push   $0xf0104ebe
f010296c:	68 c3 02 00 00       	push   $0x2c3
f0102971:	68 98 4e 10 f0       	push   $0xf0104e98
f0102976:	e8 10 d7 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010297b:	40                   	inc    %eax
f010297c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102981:	0f 85 5b ff ff ff    	jne    f01028e2 <mem_init+0x121a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102987:	83 ec 0c             	sub    $0xc,%esp
f010298a:	68 d8 4d 10 f0       	push   $0xf0104dd8
f010298f:	e8 c5 03 00 00       	call   f0102d59 <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0102994:	0f 20 e0             	mov    %cr4,%eax
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
    
    cr4 = rcr4();
    cr4 |= CR4_PSE;
f0102997:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f010299a:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);					// Open Size Page Extension
	lcr3(PADDR(kern_pgdir));
f010299d:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029a2:	83 c4 10             	add    $0x10,%esp
f01029a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029aa:	77 15                	ja     f01029c1 <mem_init+0x12f9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ac:	50                   	push   %eax
f01029ad:	68 d8 45 10 f0       	push   $0xf01045d8
f01029b2:	68 e7 00 00 00       	push   $0xe7
f01029b7:	68 98 4e 10 f0       	push   $0xf0104e98
f01029bc:	e8 ca d6 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029c1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029c6:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01029ce:	e8 60 e6 ff ff       	call   f0101033 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029d3:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029d6:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029db:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029de:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029e1:	83 ec 0c             	sub    $0xc,%esp
f01029e4:	6a 00                	push   $0x0
f01029e6:	e8 bf e9 ff ff       	call   f01013aa <page_alloc>
f01029eb:	89 c6                	mov    %eax,%esi
f01029ed:	83 c4 10             	add    $0x10,%esp
f01029f0:	85 c0                	test   %eax,%eax
f01029f2:	75 19                	jne    f0102a0d <mem_init+0x1345>
f01029f4:	68 81 4f 10 f0       	push   $0xf0104f81
f01029f9:	68 be 4e 10 f0       	push   $0xf0104ebe
f01029fe:	68 84 03 00 00       	push   $0x384
f0102a03:	68 98 4e 10 f0       	push   $0xf0104e98
f0102a08:	e8 7e d6 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102a0d:	83 ec 0c             	sub    $0xc,%esp
f0102a10:	6a 00                	push   $0x0
f0102a12:	e8 93 e9 ff ff       	call   f01013aa <page_alloc>
f0102a17:	89 c7                	mov    %eax,%edi
f0102a19:	83 c4 10             	add    $0x10,%esp
f0102a1c:	85 c0                	test   %eax,%eax
f0102a1e:	75 19                	jne    f0102a39 <mem_init+0x1371>
f0102a20:	68 97 4f 10 f0       	push   $0xf0104f97
f0102a25:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102a2a:	68 85 03 00 00       	push   $0x385
f0102a2f:	68 98 4e 10 f0       	push   $0xf0104e98
f0102a34:	e8 52 d6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102a39:	83 ec 0c             	sub    $0xc,%esp
f0102a3c:	6a 00                	push   $0x0
f0102a3e:	e8 67 e9 ff ff       	call   f01013aa <page_alloc>
f0102a43:	89 c3                	mov    %eax,%ebx
f0102a45:	83 c4 10             	add    $0x10,%esp
f0102a48:	85 c0                	test   %eax,%eax
f0102a4a:	75 19                	jne    f0102a65 <mem_init+0x139d>
f0102a4c:	68 ad 4f 10 f0       	push   $0xf0104fad
f0102a51:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102a56:	68 86 03 00 00       	push   $0x386
f0102a5b:	68 98 4e 10 f0       	push   $0xf0104e98
f0102a60:	e8 26 d6 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102a65:	83 ec 0c             	sub    $0xc,%esp
f0102a68:	56                   	push   %esi
f0102a69:	e8 c6 e9 ff ff       	call   f0101434 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a6e:	89 f8                	mov    %edi,%eax
f0102a70:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102a76:	c1 f8 03             	sar    $0x3,%eax
f0102a79:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a7c:	89 c2                	mov    %eax,%edx
f0102a7e:	c1 ea 0c             	shr    $0xc,%edx
f0102a81:	83 c4 10             	add    $0x10,%esp
f0102a84:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102a8a:	72 12                	jb     f0102a9e <mem_init+0x13d6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a8c:	50                   	push   %eax
f0102a8d:	68 a0 47 10 f0       	push   $0xf01047a0
f0102a92:	6a 52                	push   $0x52
f0102a94:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0102a99:	e8 ed d5 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a9e:	83 ec 04             	sub    $0x4,%esp
f0102aa1:	68 00 10 00 00       	push   $0x1000
f0102aa6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102aa8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aad:	50                   	push   %eax
f0102aae:	e8 d6 0d 00 00       	call   f0103889 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ab3:	89 d8                	mov    %ebx,%eax
f0102ab5:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102abb:	c1 f8 03             	sar    $0x3,%eax
f0102abe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ac1:	89 c2                	mov    %eax,%edx
f0102ac3:	c1 ea 0c             	shr    $0xc,%edx
f0102ac6:	83 c4 10             	add    $0x10,%esp
f0102ac9:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102acf:	72 12                	jb     f0102ae3 <mem_init+0x141b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ad1:	50                   	push   %eax
f0102ad2:	68 a0 47 10 f0       	push   $0xf01047a0
f0102ad7:	6a 52                	push   $0x52
f0102ad9:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0102ade:	e8 a8 d5 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ae3:	83 ec 04             	sub    $0x4,%esp
f0102ae6:	68 00 10 00 00       	push   $0x1000
f0102aeb:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102aed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102af2:	50                   	push   %eax
f0102af3:	e8 91 0d 00 00       	call   f0103889 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102af8:	6a 02                	push   $0x2
f0102afa:	68 00 10 00 00       	push   $0x1000
f0102aff:	57                   	push   %edi
f0102b00:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102b06:	e8 54 eb ff ff       	call   f010165f <page_insert>
	assert(pp1->pp_ref == 1);
f0102b0b:	83 c4 20             	add    $0x20,%esp
f0102b0e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b13:	74 19                	je     f0102b2e <mem_init+0x1466>
f0102b15:	68 7e 50 10 f0       	push   $0xf010507e
f0102b1a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102b1f:	68 8b 03 00 00       	push   $0x38b
f0102b24:	68 98 4e 10 f0       	push   $0xf0104e98
f0102b29:	e8 5d d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b2e:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b35:	01 01 01 
f0102b38:	74 19                	je     f0102b53 <mem_init+0x148b>
f0102b3a:	68 f8 4d 10 f0       	push   $0xf0104df8
f0102b3f:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102b44:	68 8c 03 00 00       	push   $0x38c
f0102b49:	68 98 4e 10 f0       	push   $0xf0104e98
f0102b4e:	e8 38 d5 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b53:	6a 02                	push   $0x2
f0102b55:	68 00 10 00 00       	push   $0x1000
f0102b5a:	53                   	push   %ebx
f0102b5b:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102b61:	e8 f9 ea ff ff       	call   f010165f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b66:	83 c4 10             	add    $0x10,%esp
f0102b69:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b70:	02 02 02 
f0102b73:	74 19                	je     f0102b8e <mem_init+0x14c6>
f0102b75:	68 1c 4e 10 f0       	push   $0xf0104e1c
f0102b7a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102b7f:	68 8e 03 00 00       	push   $0x38e
f0102b84:	68 98 4e 10 f0       	push   $0xf0104e98
f0102b89:	e8 fd d4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102b8e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b93:	74 19                	je     f0102bae <mem_init+0x14e6>
f0102b95:	68 a0 50 10 f0       	push   $0xf01050a0
f0102b9a:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102b9f:	68 8f 03 00 00       	push   $0x38f
f0102ba4:	68 98 4e 10 f0       	push   $0xf0104e98
f0102ba9:	e8 dd d4 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102bae:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bb3:	74 19                	je     f0102bce <mem_init+0x1506>
f0102bb5:	68 e9 50 10 f0       	push   $0xf01050e9
f0102bba:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102bbf:	68 90 03 00 00       	push   $0x390
f0102bc4:	68 98 4e 10 f0       	push   $0xf0104e98
f0102bc9:	e8 bd d4 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bce:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bd5:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd8:	89 d8                	mov    %ebx,%eax
f0102bda:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102be0:	c1 f8 03             	sar    $0x3,%eax
f0102be3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be6:	89 c2                	mov    %eax,%edx
f0102be8:	c1 ea 0c             	shr    $0xc,%edx
f0102beb:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102bf1:	72 12                	jb     f0102c05 <mem_init+0x153d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bf3:	50                   	push   %eax
f0102bf4:	68 a0 47 10 f0       	push   $0xf01047a0
f0102bf9:	6a 52                	push   $0x52
f0102bfb:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0102c00:	e8 86 d4 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c05:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c0c:	03 03 03 
f0102c0f:	74 19                	je     f0102c2a <mem_init+0x1562>
f0102c11:	68 40 4e 10 f0       	push   $0xf0104e40
f0102c16:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102c1b:	68 92 03 00 00       	push   $0x392
f0102c20:	68 98 4e 10 f0       	push   $0xf0104e98
f0102c25:	e8 61 d4 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c2a:	83 ec 08             	sub    $0x8,%esp
f0102c2d:	68 00 10 00 00       	push   $0x1000
f0102c32:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102c38:	e8 d5 e9 ff ff       	call   f0101612 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c3d:	83 c4 10             	add    $0x10,%esp
f0102c40:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c45:	74 19                	je     f0102c60 <mem_init+0x1598>
f0102c47:	68 d8 50 10 f0       	push   $0xf01050d8
f0102c4c:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102c51:	68 94 03 00 00       	push   $0x394
f0102c56:	68 98 4e 10 f0       	push   $0xf0104e98
f0102c5b:	e8 2b d4 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c60:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102c65:	8b 08                	mov    (%eax),%ecx
f0102c67:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c6d:	89 f2                	mov    %esi,%edx
f0102c6f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102c75:	c1 fa 03             	sar    $0x3,%edx
f0102c78:	c1 e2 0c             	shl    $0xc,%edx
f0102c7b:	39 d1                	cmp    %edx,%ecx
f0102c7d:	74 19                	je     f0102c98 <mem_init+0x15d0>
f0102c7f:	68 bc 49 10 f0       	push   $0xf01049bc
f0102c84:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102c89:	68 97 03 00 00       	push   $0x397
f0102c8e:	68 98 4e 10 f0       	push   $0xf0104e98
f0102c93:	e8 f3 d3 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102c98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c9e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ca3:	74 19                	je     f0102cbe <mem_init+0x15f6>
f0102ca5:	68 8f 50 10 f0       	push   $0xf010508f
f0102caa:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102caf:	68 99 03 00 00       	push   $0x399
f0102cb4:	68 98 4e 10 f0       	push   $0xf0104e98
f0102cb9:	e8 cd d3 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102cbe:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cc4:	83 ec 0c             	sub    $0xc,%esp
f0102cc7:	56                   	push   %esi
f0102cc8:	e8 67 e7 ff ff       	call   f0101434 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ccd:	c7 04 24 6c 4e 10 f0 	movl   $0xf0104e6c,(%esp)
f0102cd4:	e8 80 00 00 00       	call   f0102d59 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cdc:	5b                   	pop    %ebx
f0102cdd:	5e                   	pop    %esi
f0102cde:	5f                   	pop    %edi
f0102cdf:	c9                   	leave  
f0102ce0:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ce1:	89 f2                	mov    %esi,%edx
f0102ce3:	89 d8                	mov    %ebx,%eax
f0102ce5:	e8 ad e2 ff ff       	call   f0100f97 <check_va2pa>
f0102cea:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102cf0:	e9 92 fb ff ff       	jmp    f0102887 <mem_init+0x11bf>
f0102cf5:	00 00                	add    %al,(%eax)
	...

f0102cf8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102cf8:	55                   	push   %ebp
f0102cf9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102cfb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d00:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d03:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d04:	b2 71                	mov    $0x71,%dl
f0102d06:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d07:	0f b6 c0             	movzbl %al,%eax
}
f0102d0a:	c9                   	leave  
f0102d0b:	c3                   	ret    

f0102d0c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d0c:	55                   	push   %ebp
f0102d0d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d14:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d17:	ee                   	out    %al,(%dx)
f0102d18:	b2 71                	mov    $0x71,%dl
f0102d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d1d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d1e:	c9                   	leave  
f0102d1f:	c3                   	ret    

f0102d20 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d20:	55                   	push   %ebp
f0102d21:	89 e5                	mov    %esp,%ebp
f0102d23:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102d26:	ff 75 08             	pushl  0x8(%ebp)
f0102d29:	e8 78 d8 ff ff       	call   f01005a6 <cputchar>
f0102d2e:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102d31:	c9                   	leave  
f0102d32:	c3                   	ret    

f0102d33 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d33:	55                   	push   %ebp
f0102d34:	89 e5                	mov    %esp,%ebp
f0102d36:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102d39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d40:	ff 75 0c             	pushl  0xc(%ebp)
f0102d43:	ff 75 08             	pushl  0x8(%ebp)
f0102d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d49:	50                   	push   %eax
f0102d4a:	68 20 2d 10 f0       	push   $0xf0102d20
f0102d4f:	e8 9d 04 00 00       	call   f01031f1 <vprintfmt>
	return cnt;
}
f0102d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d57:	c9                   	leave  
f0102d58:	c3                   	ret    

f0102d59 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d59:	55                   	push   %ebp
f0102d5a:	89 e5                	mov    %esp,%ebp
f0102d5c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d5f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d62:	50                   	push   %eax
f0102d63:	ff 75 08             	pushl  0x8(%ebp)
f0102d66:	e8 c8 ff ff ff       	call   f0102d33 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102d6b:	c9                   	leave  
f0102d6c:	c3                   	ret    
f0102d6d:	00 00                	add    %al,(%eax)
	...

f0102d70 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102d70:	55                   	push   %ebp
f0102d71:	89 e5                	mov    %esp,%ebp
f0102d73:	57                   	push   %edi
f0102d74:	56                   	push   %esi
f0102d75:	53                   	push   %ebx
f0102d76:	83 ec 14             	sub    $0x14,%esp
f0102d79:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d7c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102d7f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102d82:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d85:	8b 1a                	mov    (%edx),%ebx
f0102d87:	8b 01                	mov    (%ecx),%eax
f0102d89:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102d8c:	39 c3                	cmp    %eax,%ebx
f0102d8e:	0f 8f 97 00 00 00    	jg     f0102e2b <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d94:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d9e:	01 d8                	add    %ebx,%eax
f0102da0:	89 c7                	mov    %eax,%edi
f0102da2:	c1 ef 1f             	shr    $0x1f,%edi
f0102da5:	01 c7                	add    %eax,%edi
f0102da7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102da9:	39 df                	cmp    %ebx,%edi
f0102dab:	7c 31                	jl     f0102dde <stab_binsearch+0x6e>
f0102dad:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102db0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102db3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102db8:	39 f0                	cmp    %esi,%eax
f0102dba:	0f 84 b3 00 00 00    	je     f0102e73 <stab_binsearch+0x103>
f0102dc0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102dc4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102dc8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102dca:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102dcb:	39 d8                	cmp    %ebx,%eax
f0102dcd:	7c 0f                	jl     f0102dde <stab_binsearch+0x6e>
f0102dcf:	0f b6 0a             	movzbl (%edx),%ecx
f0102dd2:	83 ea 0c             	sub    $0xc,%edx
f0102dd5:	39 f1                	cmp    %esi,%ecx
f0102dd7:	75 f1                	jne    f0102dca <stab_binsearch+0x5a>
f0102dd9:	e9 97 00 00 00       	jmp    f0102e75 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102dde:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102de1:	eb 39                	jmp    f0102e1c <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102de3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102de6:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102de8:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102deb:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102df2:	eb 28                	jmp    f0102e1c <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102df4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102df7:	76 12                	jbe    f0102e0b <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102df9:	48                   	dec    %eax
f0102dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102dfd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e00:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e02:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102e09:	eb 11                	jmp    f0102e1c <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e0b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102e0e:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102e10:	ff 45 0c             	incl   0xc(%ebp)
f0102e13:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e15:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102e1c:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102e1f:	0f 8d 76 ff ff ff    	jge    f0102d9b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102e25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102e29:	75 0d                	jne    f0102e38 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102e2b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e2e:	8b 03                	mov    (%ebx),%eax
f0102e30:	48                   	dec    %eax
f0102e31:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e34:	89 02                	mov    %eax,(%edx)
f0102e36:	eb 55                	jmp    f0102e8d <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e38:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e3b:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e3d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e40:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e42:	39 c1                	cmp    %eax,%ecx
f0102e44:	7d 26                	jge    f0102e6c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102e46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102e49:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102e4c:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102e51:	39 f2                	cmp    %esi,%edx
f0102e53:	74 17                	je     f0102e6c <stab_binsearch+0xfc>
f0102e55:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102e59:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e5d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e5e:	39 c1                	cmp    %eax,%ecx
f0102e60:	7d 0a                	jge    f0102e6c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102e62:	0f b6 1a             	movzbl (%edx),%ebx
f0102e65:	83 ea 0c             	sub    $0xc,%edx
f0102e68:	39 f3                	cmp    %esi,%ebx
f0102e6a:	75 f1                	jne    f0102e5d <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e6f:	89 02                	mov    %eax,(%edx)
f0102e71:	eb 1a                	jmp    f0102e8d <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102e73:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102e75:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102e78:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102e7b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102e7f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e82:	0f 82 5b ff ff ff    	jb     f0102de3 <stab_binsearch+0x73>
f0102e88:	e9 67 ff ff ff       	jmp    f0102df4 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102e8d:	83 c4 14             	add    $0x14,%esp
f0102e90:	5b                   	pop    %ebx
f0102e91:	5e                   	pop    %esi
f0102e92:	5f                   	pop    %edi
f0102e93:	c9                   	leave  
f0102e94:	c3                   	ret    

f0102e95 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e95:	55                   	push   %ebp
f0102e96:	89 e5                	mov    %esp,%ebp
f0102e98:	57                   	push   %edi
f0102e99:	56                   	push   %esi
f0102e9a:	53                   	push   %ebx
f0102e9b:	83 ec 2c             	sub    $0x2c,%esp
f0102e9e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102ea4:	c7 03 72 51 10 f0    	movl   $0xf0105172,(%ebx)
	info->eip_line = 0;
f0102eaa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102eb1:	c7 43 08 72 51 10 f0 	movl   $0xf0105172,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102eb8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102ebf:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102ec2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102ec9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ecf:	76 12                	jbe    f0102ee3 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ed1:	b8 d4 41 11 f0       	mov    $0xf01141d4,%eax
f0102ed6:	3d a9 c8 10 f0       	cmp    $0xf010c8a9,%eax
f0102edb:	0f 86 90 01 00 00    	jbe    f0103071 <debuginfo_eip+0x1dc>
f0102ee1:	eb 14                	jmp    f0102ef7 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ee3:	83 ec 04             	sub    $0x4,%esp
f0102ee6:	68 7c 51 10 f0       	push   $0xf010517c
f0102eeb:	6a 7f                	push   $0x7f
f0102eed:	68 89 51 10 f0       	push   $0xf0105189
f0102ef2:	e8 94 d1 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102efc:	80 3d d3 41 11 f0 00 	cmpb   $0x0,0xf01141d3
f0102f03:	0f 85 74 01 00 00    	jne    f010307d <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102f09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102f10:	b8 a8 c8 10 f0       	mov    $0xf010c8a8,%eax
f0102f15:	2d a8 53 10 f0       	sub    $0xf01053a8,%eax
f0102f1a:	c1 f8 02             	sar    $0x2,%eax
f0102f1d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102f23:	48                   	dec    %eax
f0102f24:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102f27:	83 ec 08             	sub    $0x8,%esp
f0102f2a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f2d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f30:	56                   	push   %esi
f0102f31:	6a 64                	push   $0x64
f0102f33:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f0102f38:	e8 33 fe ff ff       	call   f0102d70 <stab_binsearch>
	if (lfile == 0)
f0102f3d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102f40:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102f48:	85 d2                	test   %edx,%edx
f0102f4a:	0f 84 2d 01 00 00    	je     f010307d <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f50:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f56:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f59:	83 ec 08             	sub    $0x8,%esp
f0102f5c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f62:	56                   	push   %esi
f0102f63:	6a 24                	push   $0x24
f0102f65:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f0102f6a:	e8 01 fe ff ff       	call   f0102d70 <stab_binsearch>

	if (lfun <= rfun) {
f0102f6f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102f72:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102f78:	83 c4 10             	add    $0x10,%esp
f0102f7b:	39 c7                	cmp    %eax,%edi
f0102f7d:	7f 32                	jg     f0102fb1 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f7f:	89 f9                	mov    %edi,%ecx
f0102f81:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102f84:	8b 80 a8 53 10 f0    	mov    -0xfefac58(%eax),%eax
f0102f8a:	ba d4 41 11 f0       	mov    $0xf01141d4,%edx
f0102f8f:	81 ea a9 c8 10 f0    	sub    $0xf010c8a9,%edx
f0102f95:	39 d0                	cmp    %edx,%eax
f0102f97:	73 08                	jae    f0102fa1 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102f99:	05 a9 c8 10 f0       	add    $0xf010c8a9,%eax
f0102f9e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102fa1:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102fa4:	8b 81 b0 53 10 f0    	mov    -0xfefac50(%ecx),%eax
f0102faa:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102fad:	29 c6                	sub    %eax,%esi
f0102faf:	eb 0c                	jmp    f0102fbd <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102fb1:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102fb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102fb7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102fba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102fbd:	83 ec 08             	sub    $0x8,%esp
f0102fc0:	6a 3a                	push   $0x3a
f0102fc2:	ff 73 08             	pushl  0x8(%ebx)
f0102fc5:	e8 9d 08 00 00       	call   f0103867 <strfind>
f0102fca:	2b 43 08             	sub    0x8(%ebx),%eax
f0102fcd:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102fd0:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102fd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102fd9:	83 c4 08             	add    $0x8,%esp
f0102fdc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102fdf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102fe2:	56                   	push   %esi
f0102fe3:	6a 44                	push   $0x44
f0102fe5:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f0102fea:	e8 81 fd ff ff       	call   f0102d70 <stab_binsearch>
    if (lfun <= rfun) {
f0102fef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ff2:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102ffa:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102ffd:	7f 7e                	jg     f010307d <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102fff:	6b c2 0c             	imul   $0xc,%edx,%eax
f0103002:	05 a8 53 10 f0       	add    $0xf01053a8,%eax
f0103007:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f010300b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010300e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103011:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103014:	eb 04                	jmp    f010301a <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103016:	4a                   	dec    %edx
f0103017:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010301a:	39 f2                	cmp    %esi,%edx
f010301c:	7c 1b                	jl     f0103039 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f010301e:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103021:	80 f9 84             	cmp    $0x84,%cl
f0103024:	74 5f                	je     f0103085 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103026:	80 f9 64             	cmp    $0x64,%cl
f0103029:	75 eb                	jne    f0103016 <debuginfo_eip+0x181>
f010302b:	83 38 00             	cmpl   $0x0,(%eax)
f010302e:	74 e6                	je     f0103016 <debuginfo_eip+0x181>
f0103030:	eb 53                	jmp    f0103085 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103032:	05 a9 c8 10 f0       	add    $0xf010c8a9,%eax
f0103037:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103039:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010303c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010303f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103044:	39 ca                	cmp    %ecx,%edx
f0103046:	7d 35                	jge    f010307d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0103048:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010304b:	6b d0 0c             	imul   $0xc,%eax,%edx
f010304e:	81 c2 ac 53 10 f0    	add    $0xf01053ac,%edx
f0103054:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103056:	eb 04                	jmp    f010305c <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103058:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010305b:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010305c:	39 f0                	cmp    %esi,%eax
f010305e:	7d 18                	jge    f0103078 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103060:	8a 0a                	mov    (%edx),%cl
f0103062:	83 c2 0c             	add    $0xc,%edx
f0103065:	80 f9 a0             	cmp    $0xa0,%cl
f0103068:	74 ee                	je     f0103058 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010306a:	b8 00 00 00 00       	mov    $0x0,%eax
f010306f:	eb 0c                	jmp    f010307d <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103076:	eb 05                	jmp    f010307d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103078:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010307d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103080:	5b                   	pop    %ebx
f0103081:	5e                   	pop    %esi
f0103082:	5f                   	pop    %edi
f0103083:	c9                   	leave  
f0103084:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103085:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103088:	8b 82 a8 53 10 f0    	mov    -0xfefac58(%edx),%eax
f010308e:	ba d4 41 11 f0       	mov    $0xf01141d4,%edx
f0103093:	81 ea a9 c8 10 f0    	sub    $0xf010c8a9,%edx
f0103099:	39 d0                	cmp    %edx,%eax
f010309b:	72 95                	jb     f0103032 <debuginfo_eip+0x19d>
f010309d:	eb 9a                	jmp    f0103039 <debuginfo_eip+0x1a4>
	...

f01030a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01030a0:	55                   	push   %ebp
f01030a1:	89 e5                	mov    %esp,%ebp
f01030a3:	57                   	push   %edi
f01030a4:	56                   	push   %esi
f01030a5:	53                   	push   %ebx
f01030a6:	83 ec 2c             	sub    $0x2c,%esp
f01030a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01030ac:	89 d6                	mov    %edx,%esi
f01030ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01030b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01030ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01030bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01030c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01030c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01030c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01030cd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f01030d0:	72 0c                	jb     f01030de <printnum+0x3e>
f01030d2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01030d5:	76 07                	jbe    f01030de <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01030d7:	4b                   	dec    %ebx
f01030d8:	85 db                	test   %ebx,%ebx
f01030da:	7f 31                	jg     f010310d <printnum+0x6d>
f01030dc:	eb 3f                	jmp    f010311d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030de:	83 ec 0c             	sub    $0xc,%esp
f01030e1:	57                   	push   %edi
f01030e2:	4b                   	dec    %ebx
f01030e3:	53                   	push   %ebx
f01030e4:	50                   	push   %eax
f01030e5:	83 ec 08             	sub    $0x8,%esp
f01030e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01030eb:	ff 75 d0             	pushl  -0x30(%ebp)
f01030ee:	ff 75 dc             	pushl  -0x24(%ebp)
f01030f1:	ff 75 d8             	pushl  -0x28(%ebp)
f01030f4:	e8 97 09 00 00       	call   f0103a90 <__udivdi3>
f01030f9:	83 c4 18             	add    $0x18,%esp
f01030fc:	52                   	push   %edx
f01030fd:	50                   	push   %eax
f01030fe:	89 f2                	mov    %esi,%edx
f0103100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103103:	e8 98 ff ff ff       	call   f01030a0 <printnum>
f0103108:	83 c4 20             	add    $0x20,%esp
f010310b:	eb 10                	jmp    f010311d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010310d:	83 ec 08             	sub    $0x8,%esp
f0103110:	56                   	push   %esi
f0103111:	57                   	push   %edi
f0103112:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103115:	4b                   	dec    %ebx
f0103116:	83 c4 10             	add    $0x10,%esp
f0103119:	85 db                	test   %ebx,%ebx
f010311b:	7f f0                	jg     f010310d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010311d:	83 ec 08             	sub    $0x8,%esp
f0103120:	56                   	push   %esi
f0103121:	83 ec 04             	sub    $0x4,%esp
f0103124:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103127:	ff 75 d0             	pushl  -0x30(%ebp)
f010312a:	ff 75 dc             	pushl  -0x24(%ebp)
f010312d:	ff 75 d8             	pushl  -0x28(%ebp)
f0103130:	e8 77 0a 00 00       	call   f0103bac <__umoddi3>
f0103135:	83 c4 14             	add    $0x14,%esp
f0103138:	0f be 80 97 51 10 f0 	movsbl -0xfefae69(%eax),%eax
f010313f:	50                   	push   %eax
f0103140:	ff 55 e4             	call   *-0x1c(%ebp)
f0103143:	83 c4 10             	add    $0x10,%esp
}
f0103146:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103149:	5b                   	pop    %ebx
f010314a:	5e                   	pop    %esi
f010314b:	5f                   	pop    %edi
f010314c:	c9                   	leave  
f010314d:	c3                   	ret    

f010314e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010314e:	55                   	push   %ebp
f010314f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103151:	83 fa 01             	cmp    $0x1,%edx
f0103154:	7e 0e                	jle    f0103164 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103156:	8b 10                	mov    (%eax),%edx
f0103158:	8d 4a 08             	lea    0x8(%edx),%ecx
f010315b:	89 08                	mov    %ecx,(%eax)
f010315d:	8b 02                	mov    (%edx),%eax
f010315f:	8b 52 04             	mov    0x4(%edx),%edx
f0103162:	eb 22                	jmp    f0103186 <getuint+0x38>
	else if (lflag)
f0103164:	85 d2                	test   %edx,%edx
f0103166:	74 10                	je     f0103178 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103168:	8b 10                	mov    (%eax),%edx
f010316a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010316d:	89 08                	mov    %ecx,(%eax)
f010316f:	8b 02                	mov    (%edx),%eax
f0103171:	ba 00 00 00 00       	mov    $0x0,%edx
f0103176:	eb 0e                	jmp    f0103186 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103178:	8b 10                	mov    (%eax),%edx
f010317a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010317d:	89 08                	mov    %ecx,(%eax)
f010317f:	8b 02                	mov    (%edx),%eax
f0103181:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103186:	c9                   	leave  
f0103187:	c3                   	ret    

f0103188 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103188:	55                   	push   %ebp
f0103189:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010318b:	83 fa 01             	cmp    $0x1,%edx
f010318e:	7e 0e                	jle    f010319e <getint+0x16>
		return va_arg(*ap, long long);
f0103190:	8b 10                	mov    (%eax),%edx
f0103192:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103195:	89 08                	mov    %ecx,(%eax)
f0103197:	8b 02                	mov    (%edx),%eax
f0103199:	8b 52 04             	mov    0x4(%edx),%edx
f010319c:	eb 1a                	jmp    f01031b8 <getint+0x30>
	else if (lflag)
f010319e:	85 d2                	test   %edx,%edx
f01031a0:	74 0c                	je     f01031ae <getint+0x26>
		return va_arg(*ap, long);
f01031a2:	8b 10                	mov    (%eax),%edx
f01031a4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01031a7:	89 08                	mov    %ecx,(%eax)
f01031a9:	8b 02                	mov    (%edx),%eax
f01031ab:	99                   	cltd   
f01031ac:	eb 0a                	jmp    f01031b8 <getint+0x30>
	else
		return va_arg(*ap, int);
f01031ae:	8b 10                	mov    (%eax),%edx
f01031b0:	8d 4a 04             	lea    0x4(%edx),%ecx
f01031b3:	89 08                	mov    %ecx,(%eax)
f01031b5:	8b 02                	mov    (%edx),%eax
f01031b7:	99                   	cltd   
}
f01031b8:	c9                   	leave  
f01031b9:	c3                   	ret    

f01031ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01031ba:	55                   	push   %ebp
f01031bb:	89 e5                	mov    %esp,%ebp
f01031bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01031c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01031c3:	8b 10                	mov    (%eax),%edx
f01031c5:	3b 50 04             	cmp    0x4(%eax),%edx
f01031c8:	73 08                	jae    f01031d2 <sprintputch+0x18>
		*b->buf++ = ch;
f01031ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031cd:	88 0a                	mov    %cl,(%edx)
f01031cf:	42                   	inc    %edx
f01031d0:	89 10                	mov    %edx,(%eax)
}
f01031d2:	c9                   	leave  
f01031d3:	c3                   	ret    

f01031d4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01031d4:	55                   	push   %ebp
f01031d5:	89 e5                	mov    %esp,%ebp
f01031d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01031da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031dd:	50                   	push   %eax
f01031de:	ff 75 10             	pushl  0x10(%ebp)
f01031e1:	ff 75 0c             	pushl  0xc(%ebp)
f01031e4:	ff 75 08             	pushl  0x8(%ebp)
f01031e7:	e8 05 00 00 00       	call   f01031f1 <vprintfmt>
	va_end(ap);
f01031ec:	83 c4 10             	add    $0x10,%esp
}
f01031ef:	c9                   	leave  
f01031f0:	c3                   	ret    

f01031f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031f1:	55                   	push   %ebp
f01031f2:	89 e5                	mov    %esp,%ebp
f01031f4:	57                   	push   %edi
f01031f5:	56                   	push   %esi
f01031f6:	53                   	push   %ebx
f01031f7:	83 ec 2c             	sub    $0x2c,%esp
f01031fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01031fd:	8b 75 10             	mov    0x10(%ebp),%esi
f0103200:	eb 13                	jmp    f0103215 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103202:	85 c0                	test   %eax,%eax
f0103204:	0f 84 6d 03 00 00    	je     f0103577 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f010320a:	83 ec 08             	sub    $0x8,%esp
f010320d:	57                   	push   %edi
f010320e:	50                   	push   %eax
f010320f:	ff 55 08             	call   *0x8(%ebp)
f0103212:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103215:	0f b6 06             	movzbl (%esi),%eax
f0103218:	46                   	inc    %esi
f0103219:	83 f8 25             	cmp    $0x25,%eax
f010321c:	75 e4                	jne    f0103202 <vprintfmt+0x11>
f010321e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103222:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103229:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0103230:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103237:	b9 00 00 00 00       	mov    $0x0,%ecx
f010323c:	eb 28                	jmp    f0103266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010323e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103240:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103244:	eb 20                	jmp    f0103266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103246:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103248:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010324c:	eb 18                	jmp    f0103266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010324e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103257:	eb 0d                	jmp    f0103266 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103259:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010325c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010325f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103266:	8a 06                	mov    (%esi),%al
f0103268:	0f b6 d0             	movzbl %al,%edx
f010326b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010326e:	83 e8 23             	sub    $0x23,%eax
f0103271:	3c 55                	cmp    $0x55,%al
f0103273:	0f 87 e0 02 00 00    	ja     f0103559 <vprintfmt+0x368>
f0103279:	0f b6 c0             	movzbl %al,%eax
f010327c:	ff 24 85 24 52 10 f0 	jmp    *-0xfefaddc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103283:	83 ea 30             	sub    $0x30,%edx
f0103286:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103289:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f010328c:	8d 50 d0             	lea    -0x30(%eax),%edx
f010328f:	83 fa 09             	cmp    $0x9,%edx
f0103292:	77 44                	ja     f01032d8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103294:	89 de                	mov    %ebx,%esi
f0103296:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103299:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010329a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010329d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01032a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01032a4:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01032a7:	83 fb 09             	cmp    $0x9,%ebx
f01032aa:	76 ed                	jbe    f0103299 <vprintfmt+0xa8>
f01032ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01032af:	eb 29                	jmp    f01032da <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01032b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032b4:	8d 50 04             	lea    0x4(%eax),%edx
f01032b7:	89 55 14             	mov    %edx,0x14(%ebp)
f01032ba:	8b 00                	mov    (%eax),%eax
f01032bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01032c1:	eb 17                	jmp    f01032da <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01032c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032c7:	78 85                	js     f010324e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032c9:	89 de                	mov    %ebx,%esi
f01032cb:	eb 99                	jmp    f0103266 <vprintfmt+0x75>
f01032cd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01032cf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01032d6:	eb 8e                	jmp    f0103266 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032d8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01032da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032de:	79 86                	jns    f0103266 <vprintfmt+0x75>
f01032e0:	e9 74 ff ff ff       	jmp    f0103259 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01032e5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032e6:	89 de                	mov    %ebx,%esi
f01032e8:	e9 79 ff ff ff       	jmp    f0103266 <vprintfmt+0x75>
f01032ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01032f3:	8d 50 04             	lea    0x4(%eax),%edx
f01032f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01032f9:	83 ec 08             	sub    $0x8,%esp
f01032fc:	57                   	push   %edi
f01032fd:	ff 30                	pushl  (%eax)
f01032ff:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103302:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103305:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103308:	e9 08 ff ff ff       	jmp    f0103215 <vprintfmt+0x24>
f010330d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103310:	8b 45 14             	mov    0x14(%ebp),%eax
f0103313:	8d 50 04             	lea    0x4(%eax),%edx
f0103316:	89 55 14             	mov    %edx,0x14(%ebp)
f0103319:	8b 00                	mov    (%eax),%eax
f010331b:	85 c0                	test   %eax,%eax
f010331d:	79 02                	jns    f0103321 <vprintfmt+0x130>
f010331f:	f7 d8                	neg    %eax
f0103321:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103323:	83 f8 06             	cmp    $0x6,%eax
f0103326:	7f 0b                	jg     f0103333 <vprintfmt+0x142>
f0103328:	8b 04 85 7c 53 10 f0 	mov    -0xfefac84(,%eax,4),%eax
f010332f:	85 c0                	test   %eax,%eax
f0103331:	75 1a                	jne    f010334d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0103333:	52                   	push   %edx
f0103334:	68 af 51 10 f0       	push   $0xf01051af
f0103339:	57                   	push   %edi
f010333a:	ff 75 08             	pushl  0x8(%ebp)
f010333d:	e8 92 fe ff ff       	call   f01031d4 <printfmt>
f0103342:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103345:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103348:	e9 c8 fe ff ff       	jmp    f0103215 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f010334d:	50                   	push   %eax
f010334e:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0103353:	57                   	push   %edi
f0103354:	ff 75 08             	pushl  0x8(%ebp)
f0103357:	e8 78 fe ff ff       	call   f01031d4 <printfmt>
f010335c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010335f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103362:	e9 ae fe ff ff       	jmp    f0103215 <vprintfmt+0x24>
f0103367:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010336a:	89 de                	mov    %ebx,%esi
f010336c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010336f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103372:	8b 45 14             	mov    0x14(%ebp),%eax
f0103375:	8d 50 04             	lea    0x4(%eax),%edx
f0103378:	89 55 14             	mov    %edx,0x14(%ebp)
f010337b:	8b 00                	mov    (%eax),%eax
f010337d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103380:	85 c0                	test   %eax,%eax
f0103382:	75 07                	jne    f010338b <vprintfmt+0x19a>
				p = "(null)";
f0103384:	c7 45 d0 a8 51 10 f0 	movl   $0xf01051a8,-0x30(%ebp)
			if (width > 0 && padc != '-')
f010338b:	85 db                	test   %ebx,%ebx
f010338d:	7e 42                	jle    f01033d1 <vprintfmt+0x1e0>
f010338f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103393:	74 3c                	je     f01033d1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103395:	83 ec 08             	sub    $0x8,%esp
f0103398:	51                   	push   %ecx
f0103399:	ff 75 d0             	pushl  -0x30(%ebp)
f010339c:	e8 3f 03 00 00       	call   f01036e0 <strnlen>
f01033a1:	29 c3                	sub    %eax,%ebx
f01033a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01033a6:	83 c4 10             	add    $0x10,%esp
f01033a9:	85 db                	test   %ebx,%ebx
f01033ab:	7e 24                	jle    f01033d1 <vprintfmt+0x1e0>
					putch(padc, putdat);
f01033ad:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01033b1:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01033b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033b7:	83 ec 08             	sub    $0x8,%esp
f01033ba:	57                   	push   %edi
f01033bb:	53                   	push   %ebx
f01033bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01033bf:	4e                   	dec    %esi
f01033c0:	83 c4 10             	add    $0x10,%esp
f01033c3:	85 f6                	test   %esi,%esi
f01033c5:	7f f0                	jg     f01033b7 <vprintfmt+0x1c6>
f01033c7:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01033ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01033d4:	0f be 02             	movsbl (%edx),%eax
f01033d7:	85 c0                	test   %eax,%eax
f01033d9:	75 47                	jne    f0103422 <vprintfmt+0x231>
f01033db:	eb 37                	jmp    f0103414 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01033dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01033e1:	74 16                	je     f01033f9 <vprintfmt+0x208>
f01033e3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01033e6:	83 fa 5e             	cmp    $0x5e,%edx
f01033e9:	76 0e                	jbe    f01033f9 <vprintfmt+0x208>
					putch('?', putdat);
f01033eb:	83 ec 08             	sub    $0x8,%esp
f01033ee:	57                   	push   %edi
f01033ef:	6a 3f                	push   $0x3f
f01033f1:	ff 55 08             	call   *0x8(%ebp)
f01033f4:	83 c4 10             	add    $0x10,%esp
f01033f7:	eb 0b                	jmp    f0103404 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01033f9:	83 ec 08             	sub    $0x8,%esp
f01033fc:	57                   	push   %edi
f01033fd:	50                   	push   %eax
f01033fe:	ff 55 08             	call   *0x8(%ebp)
f0103401:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103404:	ff 4d e4             	decl   -0x1c(%ebp)
f0103407:	0f be 03             	movsbl (%ebx),%eax
f010340a:	85 c0                	test   %eax,%eax
f010340c:	74 03                	je     f0103411 <vprintfmt+0x220>
f010340e:	43                   	inc    %ebx
f010340f:	eb 1b                	jmp    f010342c <vprintfmt+0x23b>
f0103411:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103418:	7f 1e                	jg     f0103438 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010341a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010341d:	e9 f3 fd ff ff       	jmp    f0103215 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103422:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103425:	43                   	inc    %ebx
f0103426:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103429:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010342c:	85 f6                	test   %esi,%esi
f010342e:	78 ad                	js     f01033dd <vprintfmt+0x1ec>
f0103430:	4e                   	dec    %esi
f0103431:	79 aa                	jns    f01033dd <vprintfmt+0x1ec>
f0103433:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103436:	eb dc                	jmp    f0103414 <vprintfmt+0x223>
f0103438:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010343b:	83 ec 08             	sub    $0x8,%esp
f010343e:	57                   	push   %edi
f010343f:	6a 20                	push   $0x20
f0103441:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103444:	4b                   	dec    %ebx
f0103445:	83 c4 10             	add    $0x10,%esp
f0103448:	85 db                	test   %ebx,%ebx
f010344a:	7f ef                	jg     f010343b <vprintfmt+0x24a>
f010344c:	e9 c4 fd ff ff       	jmp    f0103215 <vprintfmt+0x24>
f0103451:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103454:	89 ca                	mov    %ecx,%edx
f0103456:	8d 45 14             	lea    0x14(%ebp),%eax
f0103459:	e8 2a fd ff ff       	call   f0103188 <getint>
f010345e:	89 c3                	mov    %eax,%ebx
f0103460:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103462:	85 d2                	test   %edx,%edx
f0103464:	78 0a                	js     f0103470 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103466:	b8 0a 00 00 00       	mov    $0xa,%eax
f010346b:	e9 b0 00 00 00       	jmp    f0103520 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103470:	83 ec 08             	sub    $0x8,%esp
f0103473:	57                   	push   %edi
f0103474:	6a 2d                	push   $0x2d
f0103476:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103479:	f7 db                	neg    %ebx
f010347b:	83 d6 00             	adc    $0x0,%esi
f010347e:	f7 de                	neg    %esi
f0103480:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103483:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103488:	e9 93 00 00 00       	jmp    f0103520 <vprintfmt+0x32f>
f010348d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103490:	89 ca                	mov    %ecx,%edx
f0103492:	8d 45 14             	lea    0x14(%ebp),%eax
f0103495:	e8 b4 fc ff ff       	call   f010314e <getuint>
f010349a:	89 c3                	mov    %eax,%ebx
f010349c:	89 d6                	mov    %edx,%esi
			base = 10;
f010349e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01034a3:	eb 7b                	jmp    f0103520 <vprintfmt+0x32f>
f01034a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01034a8:	89 ca                	mov    %ecx,%edx
f01034aa:	8d 45 14             	lea    0x14(%ebp),%eax
f01034ad:	e8 d6 fc ff ff       	call   f0103188 <getint>
f01034b2:	89 c3                	mov    %eax,%ebx
f01034b4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01034b6:	85 d2                	test   %edx,%edx
f01034b8:	78 07                	js     f01034c1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01034ba:	b8 08 00 00 00       	mov    $0x8,%eax
f01034bf:	eb 5f                	jmp    f0103520 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01034c1:	83 ec 08             	sub    $0x8,%esp
f01034c4:	57                   	push   %edi
f01034c5:	6a 2d                	push   $0x2d
f01034c7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01034ca:	f7 db                	neg    %ebx
f01034cc:	83 d6 00             	adc    $0x0,%esi
f01034cf:	f7 de                	neg    %esi
f01034d1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01034d4:	b8 08 00 00 00       	mov    $0x8,%eax
f01034d9:	eb 45                	jmp    f0103520 <vprintfmt+0x32f>
f01034db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01034de:	83 ec 08             	sub    $0x8,%esp
f01034e1:	57                   	push   %edi
f01034e2:	6a 30                	push   $0x30
f01034e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01034e7:	83 c4 08             	add    $0x8,%esp
f01034ea:	57                   	push   %edi
f01034eb:	6a 78                	push   $0x78
f01034ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01034f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f3:	8d 50 04             	lea    0x4(%eax),%edx
f01034f6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01034f9:	8b 18                	mov    (%eax),%ebx
f01034fb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103500:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103503:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103508:	eb 16                	jmp    f0103520 <vprintfmt+0x32f>
f010350a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010350d:	89 ca                	mov    %ecx,%edx
f010350f:	8d 45 14             	lea    0x14(%ebp),%eax
f0103512:	e8 37 fc ff ff       	call   f010314e <getuint>
f0103517:	89 c3                	mov    %eax,%ebx
f0103519:	89 d6                	mov    %edx,%esi
			base = 16;
f010351b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103520:	83 ec 0c             	sub    $0xc,%esp
f0103523:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103527:	52                   	push   %edx
f0103528:	ff 75 e4             	pushl  -0x1c(%ebp)
f010352b:	50                   	push   %eax
f010352c:	56                   	push   %esi
f010352d:	53                   	push   %ebx
f010352e:	89 fa                	mov    %edi,%edx
f0103530:	8b 45 08             	mov    0x8(%ebp),%eax
f0103533:	e8 68 fb ff ff       	call   f01030a0 <printnum>
			break;
f0103538:	83 c4 20             	add    $0x20,%esp
f010353b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010353e:	e9 d2 fc ff ff       	jmp    f0103215 <vprintfmt+0x24>
f0103543:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103546:	83 ec 08             	sub    $0x8,%esp
f0103549:	57                   	push   %edi
f010354a:	52                   	push   %edx
f010354b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010354e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103551:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103554:	e9 bc fc ff ff       	jmp    f0103215 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103559:	83 ec 08             	sub    $0x8,%esp
f010355c:	57                   	push   %edi
f010355d:	6a 25                	push   $0x25
f010355f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103562:	83 c4 10             	add    $0x10,%esp
f0103565:	eb 02                	jmp    f0103569 <vprintfmt+0x378>
f0103567:	89 c6                	mov    %eax,%esi
f0103569:	8d 46 ff             	lea    -0x1(%esi),%eax
f010356c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103570:	75 f5                	jne    f0103567 <vprintfmt+0x376>
f0103572:	e9 9e fc ff ff       	jmp    f0103215 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103577:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010357a:	5b                   	pop    %ebx
f010357b:	5e                   	pop    %esi
f010357c:	5f                   	pop    %edi
f010357d:	c9                   	leave  
f010357e:	c3                   	ret    

f010357f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010357f:	55                   	push   %ebp
f0103580:	89 e5                	mov    %esp,%ebp
f0103582:	83 ec 18             	sub    $0x18,%esp
f0103585:	8b 45 08             	mov    0x8(%ebp),%eax
f0103588:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010358b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010358e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103592:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103595:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010359c:	85 c0                	test   %eax,%eax
f010359e:	74 26                	je     f01035c6 <vsnprintf+0x47>
f01035a0:	85 d2                	test   %edx,%edx
f01035a2:	7e 29                	jle    f01035cd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01035a4:	ff 75 14             	pushl  0x14(%ebp)
f01035a7:	ff 75 10             	pushl  0x10(%ebp)
f01035aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01035ad:	50                   	push   %eax
f01035ae:	68 ba 31 10 f0       	push   $0xf01031ba
f01035b3:	e8 39 fc ff ff       	call   f01031f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01035b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01035be:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01035c1:	83 c4 10             	add    $0x10,%esp
f01035c4:	eb 0c                	jmp    f01035d2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01035c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01035cb:	eb 05                	jmp    f01035d2 <vsnprintf+0x53>
f01035cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01035d2:	c9                   	leave  
f01035d3:	c3                   	ret    

f01035d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01035d4:	55                   	push   %ebp
f01035d5:	89 e5                	mov    %esp,%ebp
f01035d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01035da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01035dd:	50                   	push   %eax
f01035de:	ff 75 10             	pushl  0x10(%ebp)
f01035e1:	ff 75 0c             	pushl  0xc(%ebp)
f01035e4:	ff 75 08             	pushl  0x8(%ebp)
f01035e7:	e8 93 ff ff ff       	call   f010357f <vsnprintf>
	va_end(ap);

	return rc;
}
f01035ec:	c9                   	leave  
f01035ed:	c3                   	ret    
	...

f01035f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01035f0:	55                   	push   %ebp
f01035f1:	89 e5                	mov    %esp,%ebp
f01035f3:	57                   	push   %edi
f01035f4:	56                   	push   %esi
f01035f5:	53                   	push   %ebx
f01035f6:	83 ec 0c             	sub    $0xc,%esp
f01035f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01035fc:	85 c0                	test   %eax,%eax
f01035fe:	74 11                	je     f0103611 <readline+0x21>
		cprintf("%s", prompt);
f0103600:	83 ec 08             	sub    $0x8,%esp
f0103603:	50                   	push   %eax
f0103604:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0103609:	e8 4b f7 ff ff       	call   f0102d59 <cprintf>
f010360e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103611:	83 ec 0c             	sub    $0xc,%esp
f0103614:	6a 00                	push   $0x0
f0103616:	e8 ac cf ff ff       	call   f01005c7 <iscons>
f010361b:	89 c7                	mov    %eax,%edi
f010361d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103620:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103625:	e8 8c cf ff ff       	call   f01005b6 <getchar>
f010362a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010362c:	85 c0                	test   %eax,%eax
f010362e:	79 18                	jns    f0103648 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103630:	83 ec 08             	sub    $0x8,%esp
f0103633:	50                   	push   %eax
f0103634:	68 98 53 10 f0       	push   $0xf0105398
f0103639:	e8 1b f7 ff ff       	call   f0102d59 <cprintf>
			return NULL;
f010363e:	83 c4 10             	add    $0x10,%esp
f0103641:	b8 00 00 00 00       	mov    $0x0,%eax
f0103646:	eb 6f                	jmp    f01036b7 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103648:	83 f8 08             	cmp    $0x8,%eax
f010364b:	74 05                	je     f0103652 <readline+0x62>
f010364d:	83 f8 7f             	cmp    $0x7f,%eax
f0103650:	75 18                	jne    f010366a <readline+0x7a>
f0103652:	85 f6                	test   %esi,%esi
f0103654:	7e 14                	jle    f010366a <readline+0x7a>
			if (echoing)
f0103656:	85 ff                	test   %edi,%edi
f0103658:	74 0d                	je     f0103667 <readline+0x77>
				cputchar('\b');
f010365a:	83 ec 0c             	sub    $0xc,%esp
f010365d:	6a 08                	push   $0x8
f010365f:	e8 42 cf ff ff       	call   f01005a6 <cputchar>
f0103664:	83 c4 10             	add    $0x10,%esp
			i--;
f0103667:	4e                   	dec    %esi
f0103668:	eb bb                	jmp    f0103625 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010366a:	83 fb 1f             	cmp    $0x1f,%ebx
f010366d:	7e 21                	jle    f0103690 <readline+0xa0>
f010366f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103675:	7f 19                	jg     f0103690 <readline+0xa0>
			if (echoing)
f0103677:	85 ff                	test   %edi,%edi
f0103679:	74 0c                	je     f0103687 <readline+0x97>
				cputchar(c);
f010367b:	83 ec 0c             	sub    $0xc,%esp
f010367e:	53                   	push   %ebx
f010367f:	e8 22 cf ff ff       	call   f01005a6 <cputchar>
f0103684:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103687:	88 9e 40 f5 11 f0    	mov    %bl,-0xfee0ac0(%esi)
f010368d:	46                   	inc    %esi
f010368e:	eb 95                	jmp    f0103625 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103690:	83 fb 0a             	cmp    $0xa,%ebx
f0103693:	74 05                	je     f010369a <readline+0xaa>
f0103695:	83 fb 0d             	cmp    $0xd,%ebx
f0103698:	75 8b                	jne    f0103625 <readline+0x35>
			if (echoing)
f010369a:	85 ff                	test   %edi,%edi
f010369c:	74 0d                	je     f01036ab <readline+0xbb>
				cputchar('\n');
f010369e:	83 ec 0c             	sub    $0xc,%esp
f01036a1:	6a 0a                	push   $0xa
f01036a3:	e8 fe ce ff ff       	call   f01005a6 <cputchar>
f01036a8:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01036ab:	c6 86 40 f5 11 f0 00 	movb   $0x0,-0xfee0ac0(%esi)
			return buf;
f01036b2:	b8 40 f5 11 f0       	mov    $0xf011f540,%eax
		}
	}
}
f01036b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036ba:	5b                   	pop    %ebx
f01036bb:	5e                   	pop    %esi
f01036bc:	5f                   	pop    %edi
f01036bd:	c9                   	leave  
f01036be:	c3                   	ret    
	...

f01036c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01036c0:	55                   	push   %ebp
f01036c1:	89 e5                	mov    %esp,%ebp
f01036c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01036c6:	80 3a 00             	cmpb   $0x0,(%edx)
f01036c9:	74 0e                	je     f01036d9 <strlen+0x19>
f01036cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01036d0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01036d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01036d5:	75 f9                	jne    f01036d0 <strlen+0x10>
f01036d7:	eb 05                	jmp    f01036de <strlen+0x1e>
f01036d9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01036de:	c9                   	leave  
f01036df:	c3                   	ret    

f01036e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01036e0:	55                   	push   %ebp
f01036e1:	89 e5                	mov    %esp,%ebp
f01036e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036e9:	85 d2                	test   %edx,%edx
f01036eb:	74 17                	je     f0103704 <strnlen+0x24>
f01036ed:	80 39 00             	cmpb   $0x0,(%ecx)
f01036f0:	74 19                	je     f010370b <strnlen+0x2b>
f01036f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01036f7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036f8:	39 d0                	cmp    %edx,%eax
f01036fa:	74 14                	je     f0103710 <strnlen+0x30>
f01036fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103700:	75 f5                	jne    f01036f7 <strnlen+0x17>
f0103702:	eb 0c                	jmp    f0103710 <strnlen+0x30>
f0103704:	b8 00 00 00 00       	mov    $0x0,%eax
f0103709:	eb 05                	jmp    f0103710 <strnlen+0x30>
f010370b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103710:	c9                   	leave  
f0103711:	c3                   	ret    

f0103712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103712:	55                   	push   %ebp
f0103713:	89 e5                	mov    %esp,%ebp
f0103715:	53                   	push   %ebx
f0103716:	8b 45 08             	mov    0x8(%ebp),%eax
f0103719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010371c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103721:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103724:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103727:	42                   	inc    %edx
f0103728:	84 c9                	test   %cl,%cl
f010372a:	75 f5                	jne    f0103721 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010372c:	5b                   	pop    %ebx
f010372d:	c9                   	leave  
f010372e:	c3                   	ret    

f010372f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010372f:	55                   	push   %ebp
f0103730:	89 e5                	mov    %esp,%ebp
f0103732:	53                   	push   %ebx
f0103733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103736:	53                   	push   %ebx
f0103737:	e8 84 ff ff ff       	call   f01036c0 <strlen>
f010373c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010373f:	ff 75 0c             	pushl  0xc(%ebp)
f0103742:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103745:	50                   	push   %eax
f0103746:	e8 c7 ff ff ff       	call   f0103712 <strcpy>
	return dst;
}
f010374b:	89 d8                	mov    %ebx,%eax
f010374d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103750:	c9                   	leave  
f0103751:	c3                   	ret    

f0103752 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103752:	55                   	push   %ebp
f0103753:	89 e5                	mov    %esp,%ebp
f0103755:	56                   	push   %esi
f0103756:	53                   	push   %ebx
f0103757:	8b 45 08             	mov    0x8(%ebp),%eax
f010375a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010375d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103760:	85 f6                	test   %esi,%esi
f0103762:	74 15                	je     f0103779 <strncpy+0x27>
f0103764:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103769:	8a 1a                	mov    (%edx),%bl
f010376b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010376e:	80 3a 01             	cmpb   $0x1,(%edx)
f0103771:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103774:	41                   	inc    %ecx
f0103775:	39 ce                	cmp    %ecx,%esi
f0103777:	77 f0                	ja     f0103769 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103779:	5b                   	pop    %ebx
f010377a:	5e                   	pop    %esi
f010377b:	c9                   	leave  
f010377c:	c3                   	ret    

f010377d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
f0103780:	57                   	push   %edi
f0103781:	56                   	push   %esi
f0103782:	53                   	push   %ebx
f0103783:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103789:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010378c:	85 f6                	test   %esi,%esi
f010378e:	74 32                	je     f01037c2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103790:	83 fe 01             	cmp    $0x1,%esi
f0103793:	74 22                	je     f01037b7 <strlcpy+0x3a>
f0103795:	8a 0b                	mov    (%ebx),%cl
f0103797:	84 c9                	test   %cl,%cl
f0103799:	74 20                	je     f01037bb <strlcpy+0x3e>
f010379b:	89 f8                	mov    %edi,%eax
f010379d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01037a2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01037a5:	88 08                	mov    %cl,(%eax)
f01037a7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01037a8:	39 f2                	cmp    %esi,%edx
f01037aa:	74 11                	je     f01037bd <strlcpy+0x40>
f01037ac:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01037b0:	42                   	inc    %edx
f01037b1:	84 c9                	test   %cl,%cl
f01037b3:	75 f0                	jne    f01037a5 <strlcpy+0x28>
f01037b5:	eb 06                	jmp    f01037bd <strlcpy+0x40>
f01037b7:	89 f8                	mov    %edi,%eax
f01037b9:	eb 02                	jmp    f01037bd <strlcpy+0x40>
f01037bb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01037bd:	c6 00 00             	movb   $0x0,(%eax)
f01037c0:	eb 02                	jmp    f01037c4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01037c2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01037c4:	29 f8                	sub    %edi,%eax
}
f01037c6:	5b                   	pop    %ebx
f01037c7:	5e                   	pop    %esi
f01037c8:	5f                   	pop    %edi
f01037c9:	c9                   	leave  
f01037ca:	c3                   	ret    

f01037cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01037cb:	55                   	push   %ebp
f01037cc:	89 e5                	mov    %esp,%ebp
f01037ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01037d4:	8a 01                	mov    (%ecx),%al
f01037d6:	84 c0                	test   %al,%al
f01037d8:	74 10                	je     f01037ea <strcmp+0x1f>
f01037da:	3a 02                	cmp    (%edx),%al
f01037dc:	75 0c                	jne    f01037ea <strcmp+0x1f>
		p++, q++;
f01037de:	41                   	inc    %ecx
f01037df:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01037e0:	8a 01                	mov    (%ecx),%al
f01037e2:	84 c0                	test   %al,%al
f01037e4:	74 04                	je     f01037ea <strcmp+0x1f>
f01037e6:	3a 02                	cmp    (%edx),%al
f01037e8:	74 f4                	je     f01037de <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01037ea:	0f b6 c0             	movzbl %al,%eax
f01037ed:	0f b6 12             	movzbl (%edx),%edx
f01037f0:	29 d0                	sub    %edx,%eax
}
f01037f2:	c9                   	leave  
f01037f3:	c3                   	ret    

f01037f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01037f4:	55                   	push   %ebp
f01037f5:	89 e5                	mov    %esp,%ebp
f01037f7:	53                   	push   %ebx
f01037f8:	8b 55 08             	mov    0x8(%ebp),%edx
f01037fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01037fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103801:	85 c0                	test   %eax,%eax
f0103803:	74 1b                	je     f0103820 <strncmp+0x2c>
f0103805:	8a 1a                	mov    (%edx),%bl
f0103807:	84 db                	test   %bl,%bl
f0103809:	74 24                	je     f010382f <strncmp+0x3b>
f010380b:	3a 19                	cmp    (%ecx),%bl
f010380d:	75 20                	jne    f010382f <strncmp+0x3b>
f010380f:	48                   	dec    %eax
f0103810:	74 15                	je     f0103827 <strncmp+0x33>
		n--, p++, q++;
f0103812:	42                   	inc    %edx
f0103813:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103814:	8a 1a                	mov    (%edx),%bl
f0103816:	84 db                	test   %bl,%bl
f0103818:	74 15                	je     f010382f <strncmp+0x3b>
f010381a:	3a 19                	cmp    (%ecx),%bl
f010381c:	74 f1                	je     f010380f <strncmp+0x1b>
f010381e:	eb 0f                	jmp    f010382f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103820:	b8 00 00 00 00       	mov    $0x0,%eax
f0103825:	eb 05                	jmp    f010382c <strncmp+0x38>
f0103827:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010382c:	5b                   	pop    %ebx
f010382d:	c9                   	leave  
f010382e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010382f:	0f b6 02             	movzbl (%edx),%eax
f0103832:	0f b6 11             	movzbl (%ecx),%edx
f0103835:	29 d0                	sub    %edx,%eax
f0103837:	eb f3                	jmp    f010382c <strncmp+0x38>

f0103839 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103839:	55                   	push   %ebp
f010383a:	89 e5                	mov    %esp,%ebp
f010383c:	8b 45 08             	mov    0x8(%ebp),%eax
f010383f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103842:	8a 10                	mov    (%eax),%dl
f0103844:	84 d2                	test   %dl,%dl
f0103846:	74 18                	je     f0103860 <strchr+0x27>
		if (*s == c)
f0103848:	38 ca                	cmp    %cl,%dl
f010384a:	75 06                	jne    f0103852 <strchr+0x19>
f010384c:	eb 17                	jmp    f0103865 <strchr+0x2c>
f010384e:	38 ca                	cmp    %cl,%dl
f0103850:	74 13                	je     f0103865 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103852:	40                   	inc    %eax
f0103853:	8a 10                	mov    (%eax),%dl
f0103855:	84 d2                	test   %dl,%dl
f0103857:	75 f5                	jne    f010384e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103859:	b8 00 00 00 00       	mov    $0x0,%eax
f010385e:	eb 05                	jmp    f0103865 <strchr+0x2c>
f0103860:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103865:	c9                   	leave  
f0103866:	c3                   	ret    

f0103867 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103867:	55                   	push   %ebp
f0103868:	89 e5                	mov    %esp,%ebp
f010386a:	8b 45 08             	mov    0x8(%ebp),%eax
f010386d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103870:	8a 10                	mov    (%eax),%dl
f0103872:	84 d2                	test   %dl,%dl
f0103874:	74 11                	je     f0103887 <strfind+0x20>
		if (*s == c)
f0103876:	38 ca                	cmp    %cl,%dl
f0103878:	75 06                	jne    f0103880 <strfind+0x19>
f010387a:	eb 0b                	jmp    f0103887 <strfind+0x20>
f010387c:	38 ca                	cmp    %cl,%dl
f010387e:	74 07                	je     f0103887 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103880:	40                   	inc    %eax
f0103881:	8a 10                	mov    (%eax),%dl
f0103883:	84 d2                	test   %dl,%dl
f0103885:	75 f5                	jne    f010387c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103887:	c9                   	leave  
f0103888:	c3                   	ret    

f0103889 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103889:	55                   	push   %ebp
f010388a:	89 e5                	mov    %esp,%ebp
f010388c:	57                   	push   %edi
f010388d:	56                   	push   %esi
f010388e:	53                   	push   %ebx
f010388f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103892:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103898:	85 c9                	test   %ecx,%ecx
f010389a:	74 30                	je     f01038cc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010389c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01038a2:	75 25                	jne    f01038c9 <memset+0x40>
f01038a4:	f6 c1 03             	test   $0x3,%cl
f01038a7:	75 20                	jne    f01038c9 <memset+0x40>
		c &= 0xFF;
f01038a9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01038ac:	89 d3                	mov    %edx,%ebx
f01038ae:	c1 e3 08             	shl    $0x8,%ebx
f01038b1:	89 d6                	mov    %edx,%esi
f01038b3:	c1 e6 18             	shl    $0x18,%esi
f01038b6:	89 d0                	mov    %edx,%eax
f01038b8:	c1 e0 10             	shl    $0x10,%eax
f01038bb:	09 f0                	or     %esi,%eax
f01038bd:	09 d0                	or     %edx,%eax
f01038bf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01038c1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01038c4:	fc                   	cld    
f01038c5:	f3 ab                	rep stos %eax,%es:(%edi)
f01038c7:	eb 03                	jmp    f01038cc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01038c9:	fc                   	cld    
f01038ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01038cc:	89 f8                	mov    %edi,%eax
f01038ce:	5b                   	pop    %ebx
f01038cf:	5e                   	pop    %esi
f01038d0:	5f                   	pop    %edi
f01038d1:	c9                   	leave  
f01038d2:	c3                   	ret    

f01038d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01038d3:	55                   	push   %ebp
f01038d4:	89 e5                	mov    %esp,%ebp
f01038d6:	57                   	push   %edi
f01038d7:	56                   	push   %esi
f01038d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01038de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01038e1:	39 c6                	cmp    %eax,%esi
f01038e3:	73 34                	jae    f0103919 <memmove+0x46>
f01038e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01038e8:	39 d0                	cmp    %edx,%eax
f01038ea:	73 2d                	jae    f0103919 <memmove+0x46>
		s += n;
		d += n;
f01038ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01038ef:	f6 c2 03             	test   $0x3,%dl
f01038f2:	75 1b                	jne    f010390f <memmove+0x3c>
f01038f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01038fa:	75 13                	jne    f010390f <memmove+0x3c>
f01038fc:	f6 c1 03             	test   $0x3,%cl
f01038ff:	75 0e                	jne    f010390f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103901:	83 ef 04             	sub    $0x4,%edi
f0103904:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103907:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010390a:	fd                   	std    
f010390b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010390d:	eb 07                	jmp    f0103916 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010390f:	4f                   	dec    %edi
f0103910:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103913:	fd                   	std    
f0103914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103916:	fc                   	cld    
f0103917:	eb 20                	jmp    f0103939 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103919:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010391f:	75 13                	jne    f0103934 <memmove+0x61>
f0103921:	a8 03                	test   $0x3,%al
f0103923:	75 0f                	jne    f0103934 <memmove+0x61>
f0103925:	f6 c1 03             	test   $0x3,%cl
f0103928:	75 0a                	jne    f0103934 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010392a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010392d:	89 c7                	mov    %eax,%edi
f010392f:	fc                   	cld    
f0103930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103932:	eb 05                	jmp    f0103939 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103934:	89 c7                	mov    %eax,%edi
f0103936:	fc                   	cld    
f0103937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103939:	5e                   	pop    %esi
f010393a:	5f                   	pop    %edi
f010393b:	c9                   	leave  
f010393c:	c3                   	ret    

f010393d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010393d:	55                   	push   %ebp
f010393e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103940:	ff 75 10             	pushl  0x10(%ebp)
f0103943:	ff 75 0c             	pushl  0xc(%ebp)
f0103946:	ff 75 08             	pushl  0x8(%ebp)
f0103949:	e8 85 ff ff ff       	call   f01038d3 <memmove>
}
f010394e:	c9                   	leave  
f010394f:	c3                   	ret    

f0103950 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103950:	55                   	push   %ebp
f0103951:	89 e5                	mov    %esp,%ebp
f0103953:	57                   	push   %edi
f0103954:	56                   	push   %esi
f0103955:	53                   	push   %ebx
f0103956:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103959:	8b 75 0c             	mov    0xc(%ebp),%esi
f010395c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010395f:	85 ff                	test   %edi,%edi
f0103961:	74 32                	je     f0103995 <memcmp+0x45>
		if (*s1 != *s2)
f0103963:	8a 03                	mov    (%ebx),%al
f0103965:	8a 0e                	mov    (%esi),%cl
f0103967:	38 c8                	cmp    %cl,%al
f0103969:	74 19                	je     f0103984 <memcmp+0x34>
f010396b:	eb 0d                	jmp    f010397a <memcmp+0x2a>
f010396d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0103971:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0103975:	42                   	inc    %edx
f0103976:	38 c8                	cmp    %cl,%al
f0103978:	74 10                	je     f010398a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010397a:	0f b6 c0             	movzbl %al,%eax
f010397d:	0f b6 c9             	movzbl %cl,%ecx
f0103980:	29 c8                	sub    %ecx,%eax
f0103982:	eb 16                	jmp    f010399a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103984:	4f                   	dec    %edi
f0103985:	ba 00 00 00 00       	mov    $0x0,%edx
f010398a:	39 fa                	cmp    %edi,%edx
f010398c:	75 df                	jne    f010396d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010398e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103993:	eb 05                	jmp    f010399a <memcmp+0x4a>
f0103995:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010399a:	5b                   	pop    %ebx
f010399b:	5e                   	pop    %esi
f010399c:	5f                   	pop    %edi
f010399d:	c9                   	leave  
f010399e:	c3                   	ret    

f010399f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010399f:	55                   	push   %ebp
f01039a0:	89 e5                	mov    %esp,%ebp
f01039a2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01039a5:	89 c2                	mov    %eax,%edx
f01039a7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01039aa:	39 d0                	cmp    %edx,%eax
f01039ac:	73 12                	jae    f01039c0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01039ae:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01039b1:	38 08                	cmp    %cl,(%eax)
f01039b3:	75 06                	jne    f01039bb <memfind+0x1c>
f01039b5:	eb 09                	jmp    f01039c0 <memfind+0x21>
f01039b7:	38 08                	cmp    %cl,(%eax)
f01039b9:	74 05                	je     f01039c0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01039bb:	40                   	inc    %eax
f01039bc:	39 c2                	cmp    %eax,%edx
f01039be:	77 f7                	ja     f01039b7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01039c0:	c9                   	leave  
f01039c1:	c3                   	ret    

f01039c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01039c2:	55                   	push   %ebp
f01039c3:	89 e5                	mov    %esp,%ebp
f01039c5:	57                   	push   %edi
f01039c6:	56                   	push   %esi
f01039c7:	53                   	push   %ebx
f01039c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01039cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01039ce:	eb 01                	jmp    f01039d1 <strtol+0xf>
		s++;
f01039d0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01039d1:	8a 02                	mov    (%edx),%al
f01039d3:	3c 20                	cmp    $0x20,%al
f01039d5:	74 f9                	je     f01039d0 <strtol+0xe>
f01039d7:	3c 09                	cmp    $0x9,%al
f01039d9:	74 f5                	je     f01039d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01039db:	3c 2b                	cmp    $0x2b,%al
f01039dd:	75 08                	jne    f01039e7 <strtol+0x25>
		s++;
f01039df:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01039e0:	bf 00 00 00 00       	mov    $0x0,%edi
f01039e5:	eb 13                	jmp    f01039fa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01039e7:	3c 2d                	cmp    $0x2d,%al
f01039e9:	75 0a                	jne    f01039f5 <strtol+0x33>
		s++, neg = 1;
f01039eb:	8d 52 01             	lea    0x1(%edx),%edx
f01039ee:	bf 01 00 00 00       	mov    $0x1,%edi
f01039f3:	eb 05                	jmp    f01039fa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01039f5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01039fa:	85 db                	test   %ebx,%ebx
f01039fc:	74 05                	je     f0103a03 <strtol+0x41>
f01039fe:	83 fb 10             	cmp    $0x10,%ebx
f0103a01:	75 28                	jne    f0103a2b <strtol+0x69>
f0103a03:	8a 02                	mov    (%edx),%al
f0103a05:	3c 30                	cmp    $0x30,%al
f0103a07:	75 10                	jne    f0103a19 <strtol+0x57>
f0103a09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103a0d:	75 0a                	jne    f0103a19 <strtol+0x57>
		s += 2, base = 16;
f0103a0f:	83 c2 02             	add    $0x2,%edx
f0103a12:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103a17:	eb 12                	jmp    f0103a2b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103a19:	85 db                	test   %ebx,%ebx
f0103a1b:	75 0e                	jne    f0103a2b <strtol+0x69>
f0103a1d:	3c 30                	cmp    $0x30,%al
f0103a1f:	75 05                	jne    f0103a26 <strtol+0x64>
		s++, base = 8;
f0103a21:	42                   	inc    %edx
f0103a22:	b3 08                	mov    $0x8,%bl
f0103a24:	eb 05                	jmp    f0103a2b <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103a26:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103a2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103a32:	8a 0a                	mov    (%edx),%cl
f0103a34:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103a37:	80 fb 09             	cmp    $0x9,%bl
f0103a3a:	77 08                	ja     f0103a44 <strtol+0x82>
			dig = *s - '0';
f0103a3c:	0f be c9             	movsbl %cl,%ecx
f0103a3f:	83 e9 30             	sub    $0x30,%ecx
f0103a42:	eb 1e                	jmp    f0103a62 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0103a44:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103a47:	80 fb 19             	cmp    $0x19,%bl
f0103a4a:	77 08                	ja     f0103a54 <strtol+0x92>
			dig = *s - 'a' + 10;
f0103a4c:	0f be c9             	movsbl %cl,%ecx
f0103a4f:	83 e9 57             	sub    $0x57,%ecx
f0103a52:	eb 0e                	jmp    f0103a62 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0103a54:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103a57:	80 fb 19             	cmp    $0x19,%bl
f0103a5a:	77 13                	ja     f0103a6f <strtol+0xad>
			dig = *s - 'A' + 10;
f0103a5c:	0f be c9             	movsbl %cl,%ecx
f0103a5f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103a62:	39 f1                	cmp    %esi,%ecx
f0103a64:	7d 0d                	jge    f0103a73 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0103a66:	42                   	inc    %edx
f0103a67:	0f af c6             	imul   %esi,%eax
f0103a6a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103a6d:	eb c3                	jmp    f0103a32 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103a6f:	89 c1                	mov    %eax,%ecx
f0103a71:	eb 02                	jmp    f0103a75 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103a73:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103a75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103a79:	74 05                	je     f0103a80 <strtol+0xbe>
		*endptr = (char *) s;
f0103a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a7e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103a80:	85 ff                	test   %edi,%edi
f0103a82:	74 04                	je     f0103a88 <strtol+0xc6>
f0103a84:	89 c8                	mov    %ecx,%eax
f0103a86:	f7 d8                	neg    %eax
}
f0103a88:	5b                   	pop    %ebx
f0103a89:	5e                   	pop    %esi
f0103a8a:	5f                   	pop    %edi
f0103a8b:	c9                   	leave  
f0103a8c:	c3                   	ret    
f0103a8d:	00 00                	add    %al,(%eax)
	...

f0103a90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103a90:	55                   	push   %ebp
f0103a91:	89 e5                	mov    %esp,%ebp
f0103a93:	57                   	push   %edi
f0103a94:	56                   	push   %esi
f0103a95:	83 ec 10             	sub    $0x10,%esp
f0103a98:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103a9e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103aa4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103aaa:	85 c0                	test   %eax,%eax
f0103aac:	75 2e                	jne    f0103adc <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0103aae:	39 f1                	cmp    %esi,%ecx
f0103ab0:	77 5a                	ja     f0103b0c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103ab2:	85 c9                	test   %ecx,%ecx
f0103ab4:	75 0b                	jne    f0103ac1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103ab6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103abb:	31 d2                	xor    %edx,%edx
f0103abd:	f7 f1                	div    %ecx
f0103abf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103ac1:	31 d2                	xor    %edx,%edx
f0103ac3:	89 f0                	mov    %esi,%eax
f0103ac5:	f7 f1                	div    %ecx
f0103ac7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103ac9:	89 f8                	mov    %edi,%eax
f0103acb:	f7 f1                	div    %ecx
f0103acd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103acf:	89 f8                	mov    %edi,%eax
f0103ad1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103ad3:	83 c4 10             	add    $0x10,%esp
f0103ad6:	5e                   	pop    %esi
f0103ad7:	5f                   	pop    %edi
f0103ad8:	c9                   	leave  
f0103ad9:	c3                   	ret    
f0103ada:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103adc:	39 f0                	cmp    %esi,%eax
f0103ade:	77 1c                	ja     f0103afc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103ae0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0103ae3:	83 f7 1f             	xor    $0x1f,%edi
f0103ae6:	75 3c                	jne    f0103b24 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103ae8:	39 f0                	cmp    %esi,%eax
f0103aea:	0f 82 90 00 00 00    	jb     f0103b80 <__udivdi3+0xf0>
f0103af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103af3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0103af6:	0f 86 84 00 00 00    	jbe    f0103b80 <__udivdi3+0xf0>
f0103afc:	31 f6                	xor    %esi,%esi
f0103afe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103b00:	89 f8                	mov    %edi,%eax
f0103b02:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103b04:	83 c4 10             	add    $0x10,%esp
f0103b07:	5e                   	pop    %esi
f0103b08:	5f                   	pop    %edi
f0103b09:	c9                   	leave  
f0103b0a:	c3                   	ret    
f0103b0b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b0c:	89 f2                	mov    %esi,%edx
f0103b0e:	89 f8                	mov    %edi,%eax
f0103b10:	f7 f1                	div    %ecx
f0103b12:	89 c7                	mov    %eax,%edi
f0103b14:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103b16:	89 f8                	mov    %edi,%eax
f0103b18:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103b1a:	83 c4 10             	add    $0x10,%esp
f0103b1d:	5e                   	pop    %esi
f0103b1e:	5f                   	pop    %edi
f0103b1f:	c9                   	leave  
f0103b20:	c3                   	ret    
f0103b21:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103b24:	89 f9                	mov    %edi,%ecx
f0103b26:	d3 e0                	shl    %cl,%eax
f0103b28:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103b2b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103b30:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b35:	88 c1                	mov    %al,%cl
f0103b37:	d3 ea                	shr    %cl,%edx
f0103b39:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b3c:	09 ca                	or     %ecx,%edx
f0103b3e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0103b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b44:	89 f9                	mov    %edi,%ecx
f0103b46:	d3 e2                	shl    %cl,%edx
f0103b48:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0103b4b:	89 f2                	mov    %esi,%edx
f0103b4d:	88 c1                	mov    %al,%cl
f0103b4f:	d3 ea                	shr    %cl,%edx
f0103b51:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103b54:	89 f2                	mov    %esi,%edx
f0103b56:	89 f9                	mov    %edi,%ecx
f0103b58:	d3 e2                	shl    %cl,%edx
f0103b5a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103b5d:	88 c1                	mov    %al,%cl
f0103b5f:	d3 ee                	shr    %cl,%esi
f0103b61:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103b63:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b66:	89 f0                	mov    %esi,%eax
f0103b68:	89 ca                	mov    %ecx,%edx
f0103b6a:	f7 75 ec             	divl   -0x14(%ebp)
f0103b6d:	89 d1                	mov    %edx,%ecx
f0103b6f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103b71:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b74:	39 d1                	cmp    %edx,%ecx
f0103b76:	72 28                	jb     f0103ba0 <__udivdi3+0x110>
f0103b78:	74 1a                	je     f0103b94 <__udivdi3+0x104>
f0103b7a:	89 f7                	mov    %esi,%edi
f0103b7c:	31 f6                	xor    %esi,%esi
f0103b7e:	eb 80                	jmp    f0103b00 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103b80:	31 f6                	xor    %esi,%esi
f0103b82:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103b87:	89 f8                	mov    %edi,%eax
f0103b89:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103b8b:	83 c4 10             	add    $0x10,%esp
f0103b8e:	5e                   	pop    %esi
f0103b8f:	5f                   	pop    %edi
f0103b90:	c9                   	leave  
f0103b91:	c3                   	ret    
f0103b92:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b97:	89 f9                	mov    %edi,%ecx
f0103b99:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b9b:	39 c2                	cmp    %eax,%edx
f0103b9d:	73 db                	jae    f0103b7a <__udivdi3+0xea>
f0103b9f:	90                   	nop
		{
		  q0--;
f0103ba0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103ba3:	31 f6                	xor    %esi,%esi
f0103ba5:	e9 56 ff ff ff       	jmp    f0103b00 <__udivdi3+0x70>
	...

f0103bac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103bac:	55                   	push   %ebp
f0103bad:	89 e5                	mov    %esp,%ebp
f0103baf:	57                   	push   %edi
f0103bb0:	56                   	push   %esi
f0103bb1:	83 ec 20             	sub    $0x20,%esp
f0103bb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103bba:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103bc0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103bc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103bc9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103bcb:	85 ff                	test   %edi,%edi
f0103bcd:	75 15                	jne    f0103be4 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103bcf:	39 f1                	cmp    %esi,%ecx
f0103bd1:	0f 86 99 00 00 00    	jbe    f0103c70 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103bd7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103bd9:	89 d0                	mov    %edx,%eax
f0103bdb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103bdd:	83 c4 20             	add    $0x20,%esp
f0103be0:	5e                   	pop    %esi
f0103be1:	5f                   	pop    %edi
f0103be2:	c9                   	leave  
f0103be3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103be4:	39 f7                	cmp    %esi,%edi
f0103be6:	0f 87 a4 00 00 00    	ja     f0103c90 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103bec:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103bef:	83 f0 1f             	xor    $0x1f,%eax
f0103bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103bf5:	0f 84 a1 00 00 00    	je     f0103c9c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103bfb:	89 f8                	mov    %edi,%eax
f0103bfd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c00:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103c02:	bf 20 00 00 00       	mov    $0x20,%edi
f0103c07:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103c0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103c0d:	89 f9                	mov    %edi,%ecx
f0103c0f:	d3 ea                	shr    %cl,%edx
f0103c11:	09 c2                	or     %eax,%edx
f0103c13:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c19:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c1c:	d3 e0                	shl    %cl,%eax
f0103c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103c21:	89 f2                	mov    %esi,%edx
f0103c23:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103c25:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103c28:	d3 e0                	shl    %cl,%eax
f0103c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103c2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103c30:	89 f9                	mov    %edi,%ecx
f0103c32:	d3 e8                	shr    %cl,%eax
f0103c34:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103c36:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103c38:	89 f2                	mov    %esi,%edx
f0103c3a:	f7 75 f0             	divl   -0x10(%ebp)
f0103c3d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103c3f:	f7 65 f4             	mull   -0xc(%ebp)
f0103c42:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103c45:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103c47:	39 d6                	cmp    %edx,%esi
f0103c49:	72 71                	jb     f0103cbc <__umoddi3+0x110>
f0103c4b:	74 7f                	je     f0103ccc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103c4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c50:	29 c8                	sub    %ecx,%eax
f0103c52:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103c54:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c57:	d3 e8                	shr    %cl,%eax
f0103c59:	89 f2                	mov    %esi,%edx
f0103c5b:	89 f9                	mov    %edi,%ecx
f0103c5d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103c5f:	09 d0                	or     %edx,%eax
f0103c61:	89 f2                	mov    %esi,%edx
f0103c63:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c66:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c68:	83 c4 20             	add    $0x20,%esp
f0103c6b:	5e                   	pop    %esi
f0103c6c:	5f                   	pop    %edi
f0103c6d:	c9                   	leave  
f0103c6e:	c3                   	ret    
f0103c6f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103c70:	85 c9                	test   %ecx,%ecx
f0103c72:	75 0b                	jne    f0103c7f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103c74:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c79:	31 d2                	xor    %edx,%edx
f0103c7b:	f7 f1                	div    %ecx
f0103c7d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103c7f:	89 f0                	mov    %esi,%eax
f0103c81:	31 d2                	xor    %edx,%edx
f0103c83:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c88:	f7 f1                	div    %ecx
f0103c8a:	e9 4a ff ff ff       	jmp    f0103bd9 <__umoddi3+0x2d>
f0103c8f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103c90:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c92:	83 c4 20             	add    $0x20,%esp
f0103c95:	5e                   	pop    %esi
f0103c96:	5f                   	pop    %edi
f0103c97:	c9                   	leave  
f0103c98:	c3                   	ret    
f0103c99:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103c9c:	39 f7                	cmp    %esi,%edi
f0103c9e:	72 05                	jb     f0103ca5 <__umoddi3+0xf9>
f0103ca0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103ca3:	77 0c                	ja     f0103cb1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103ca5:	89 f2                	mov    %esi,%edx
f0103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103caa:	29 c8                	sub    %ecx,%eax
f0103cac:	19 fa                	sbb    %edi,%edx
f0103cae:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103cb4:	83 c4 20             	add    $0x20,%esp
f0103cb7:	5e                   	pop    %esi
f0103cb8:	5f                   	pop    %edi
f0103cb9:	c9                   	leave  
f0103cba:	c3                   	ret    
f0103cbb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103cbc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103cbf:	89 c1                	mov    %eax,%ecx
f0103cc1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103cc4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103cc7:	eb 84                	jmp    f0103c4d <__umoddi3+0xa1>
f0103cc9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103ccc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103ccf:	72 eb                	jb     f0103cbc <__umoddi3+0x110>
f0103cd1:	89 f2                	mov    %esi,%edx
f0103cd3:	e9 75 ff ff ff       	jmp    f0103c4d <__umoddi3+0xa1>
