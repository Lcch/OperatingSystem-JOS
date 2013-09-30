
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
f0100015:	b8 00 70 11 00       	mov    $0x117000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

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
f0100046:	b8 50 99 11 f0       	mov    $0xf0119950,%eax
f010004b:	2d 00 93 11 f0       	sub    $0xf0119300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 93 11 f0       	push   $0xf0119300
f0100058:	e8 fc 15 00 00       	call   f0101659 <memset>

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
f010006a:	68 c0 1a 10 f0       	push   $0xf0101ac0
f010006f:	e8 bd 0a 00 00       	call   f0100b31 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2a 09 00 00       	call   f01009a3 <mem_init>
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
f0100093:	83 3d 40 99 11 f0 00 	cmpl   $0x0,0xf0119940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 99 11 f0    	mov    %esi,0xf0119940

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
f01000b0:	68 db 1a 10 f0       	push   $0xf0101adb
f01000b5:	e8 77 0a 00 00       	call   f0100b31 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 47 0a 00 00       	call   f0100b0b <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 17 1b 10 f0 	movl   $0xf0101b17,(%esp)
f01000cb:	e8 61 0a 00 00       	call   f0100b31 <cprintf>
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
f01000f2:	68 f3 1a 10 f0       	push   $0xf0101af3
f01000f7:	e8 35 0a 00 00       	call   f0100b31 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 03 0a 00 00       	call   f0100b0b <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 17 1b 10 f0 	movl   $0xf0101b17,(%esp)
f010010f:	e8 1d 0a 00 00       	call   f0100b31 <cprintf>
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
f0100155:	8b 15 24 95 11 f0    	mov    0xf0119524,%edx
f010015b:	88 82 20 93 11 f0    	mov    %al,-0xfee6ce0(%edx)
f0100161:	8d 42 01             	lea    0x1(%edx),%eax
f0100164:	a3 24 95 11 f0       	mov    %eax,0xf0119524
		if (cons.wpos == CONSBUFSIZE)
f0100169:	3d 00 02 00 00       	cmp    $0x200,%eax
f010016e:	75 0a                	jne    f010017a <cons_intr+0x34>
			cons.wpos = 0;
f0100170:	c7 05 24 95 11 f0 00 	movl   $0x0,0xf0119524
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
f01001f3:	a1 00 93 11 f0       	mov    0xf0119300,%eax
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
f0100237:	66 a1 04 93 11 f0    	mov    0xf0119304,%ax
f010023d:	66 85 c0             	test   %ax,%ax
f0100240:	0f 84 e0 00 00 00    	je     f0100326 <cons_putc+0x19f>
			crt_pos--;
f0100246:	48                   	dec    %eax
f0100247:	66 a3 04 93 11 f0    	mov    %ax,0xf0119304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010024d:	0f b7 c0             	movzwl %ax,%eax
f0100250:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100256:	83 ce 20             	or     $0x20,%esi
f0100259:	8b 15 08 93 11 f0    	mov    0xf0119308,%edx
f010025f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100263:	eb 78                	jmp    f01002dd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100265:	66 83 05 04 93 11 f0 	addw   $0x50,0xf0119304
f010026c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010026d:	66 8b 0d 04 93 11 f0 	mov    0xf0119304,%cx
f0100274:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100279:	89 c8                	mov    %ecx,%eax
f010027b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100280:	66 f7 f3             	div    %bx
f0100283:	66 29 d1             	sub    %dx,%cx
f0100286:	66 89 0d 04 93 11 f0 	mov    %cx,0xf0119304
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
f01002c3:	66 a1 04 93 11 f0    	mov    0xf0119304,%ax
f01002c9:	0f b7 c8             	movzwl %ax,%ecx
f01002cc:	8b 15 08 93 11 f0    	mov    0xf0119308,%edx
f01002d2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002d6:	40                   	inc    %eax
f01002d7:	66 a3 04 93 11 f0    	mov    %ax,0xf0119304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002dd:	66 81 3d 04 93 11 f0 	cmpw   $0x7cf,0xf0119304
f01002e4:	cf 07 
f01002e6:	76 3e                	jbe    f0100326 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002e8:	a1 08 93 11 f0       	mov    0xf0119308,%eax
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	68 00 0f 00 00       	push   $0xf00
f01002f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002fb:	52                   	push   %edx
f01002fc:	50                   	push   %eax
f01002fd:	e8 a1 13 00 00       	call   f01016a3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100302:	8b 15 08 93 11 f0    	mov    0xf0119308,%edx
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
f010031e:	66 83 2d 04 93 11 f0 	subw   $0x50,0xf0119304
f0100325:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100326:	8b 0d 0c 93 11 f0    	mov    0xf011930c,%ecx
f010032c:	b0 0e                	mov    $0xe,%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100331:	66 8b 35 04 93 11 f0 	mov    0xf0119304,%si
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
f0100374:	83 0d 28 95 11 f0 40 	orl    $0x40,0xf0119528
		return 0;
f010037b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100380:	e9 c7 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100385:	84 c0                	test   %al,%al
f0100387:	79 33                	jns    f01003bc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100389:	8b 0d 28 95 11 f0    	mov    0xf0119528,%ecx
f010038f:	f6 c1 40             	test   $0x40,%cl
f0100392:	75 05                	jne    f0100399 <kbd_proc_data+0x43>
f0100394:	88 c2                	mov    %al,%dl
f0100396:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100399:	0f b6 d2             	movzbl %dl,%edx
f010039c:	8a 82 40 1b 10 f0    	mov    -0xfefe4c0(%edx),%al
f01003a2:	83 c8 40             	or     $0x40,%eax
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	f7 d0                	not    %eax
f01003aa:	21 c1                	and    %eax,%ecx
f01003ac:	89 0d 28 95 11 f0    	mov    %ecx,0xf0119528
		return 0;
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	e9 90 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003bc:	8b 0d 28 95 11 f0    	mov    0xf0119528,%ecx
f01003c2:	f6 c1 40             	test   $0x40,%cl
f01003c5:	74 0e                	je     f01003d5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c7:	88 c2                	mov    %al,%dl
f01003c9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003cc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003cf:	89 0d 28 95 11 f0    	mov    %ecx,0xf0119528
	}

	shift |= shiftcode[data];
f01003d5:	0f b6 d2             	movzbl %dl,%edx
f01003d8:	0f b6 82 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%eax
f01003df:	0b 05 28 95 11 f0    	or     0xf0119528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 40 1c 10 f0 	movzbl -0xfefe3c0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 95 11 f0       	mov    %eax,0xf0119528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 40 1d 10 f0 	mov    -0xfefe2c0(,%ecx,4),%ecx
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
f0100430:	68 0d 1b 10 f0       	push   $0xf0101b0d
f0100435:	e8 f7 06 00 00       	call   f0100b31 <cprintf>
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
f0100459:	80 3d 10 93 11 f0 00 	cmpb   $0x0,0xf0119310
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
f0100490:	8b 15 20 95 11 f0    	mov    0xf0119520,%edx
f0100496:	3b 15 24 95 11 f0    	cmp    0xf0119524,%edx
f010049c:	74 22                	je     f01004c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010049e:	0f b6 82 20 93 11 f0 	movzbl -0xfee6ce0(%edx),%eax
f01004a5:	42                   	inc    %edx
f01004a6:	89 15 20 95 11 f0    	mov    %edx,0xf0119520
		if (cons.rpos == CONSBUFSIZE)
f01004ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b2:	75 11                	jne    f01004c5 <cons_getc+0x45>
			cons.rpos = 0;
f01004b4:	c7 05 20 95 11 f0 00 	movl   $0x0,0xf0119520
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
f01004ec:	c7 05 0c 93 11 f0 b4 	movl   $0x3b4,0xf011930c
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
f0100504:	c7 05 0c 93 11 f0 d4 	movl   $0x3d4,0xf011930c
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
f0100513:	8b 0d 0c 93 11 f0    	mov    0xf011930c,%ecx
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
f0100532:	89 35 08 93 11 f0    	mov    %esi,0xf0119308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100538:	0f b6 d8             	movzbl %al,%ebx
f010053b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010053d:	66 89 3d 04 93 11 f0 	mov    %di,0xf0119304
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
f010057d:	a2 10 93 11 f0       	mov    %al,0xf0119310
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
f0100591:	68 19 1b 10 f0       	push   $0xf0101b19
f0100596:	e8 96 05 00 00       	call   f0100b31 <cprintf>
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
f01005da:	68 50 1d 10 f0       	push   $0xf0101d50
f01005df:	e8 4d 05 00 00       	call   f0100b31 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 48 1e 10 f0       	push   $0xf0101e48
f01005f1:	e8 3b 05 00 00       	call   f0100b31 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 70 1e 10 f0       	push   $0xf0101e70
f0100608:	e8 24 05 00 00       	call   f0100b31 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 a8 1a 10 00       	push   $0x101aa8
f0100615:	68 a8 1a 10 f0       	push   $0xf0101aa8
f010061a:	68 94 1e 10 f0       	push   $0xf0101e94
f010061f:	e8 0d 05 00 00       	call   f0100b31 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 93 11 00       	push   $0x119300
f010062c:	68 00 93 11 f0       	push   $0xf0119300
f0100631:	68 b8 1e 10 f0       	push   $0xf0101eb8
f0100636:	e8 f6 04 00 00       	call   f0100b31 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 99 11 00       	push   $0x119950
f0100643:	68 50 99 11 f0       	push   $0xf0119950
f0100648:	68 dc 1e 10 f0       	push   $0xf0101edc
f010064d:	e8 df 04 00 00       	call   f0100b31 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100652:	b8 4f 9d 11 f0       	mov    $0xf0119d4f,%eax
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
f0100674:	68 00 1f 10 f0       	push   $0xf0101f00
f0100679:	e8 b3 04 00 00       	call   f0100b31 <cprintf>
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
f010068b:	ff 35 84 21 10 f0    	pushl  0xf0102184
f0100691:	ff 35 80 21 10 f0    	pushl  0xf0102180
f0100697:	68 69 1d 10 f0       	push   $0xf0101d69
f010069c:	e8 90 04 00 00       	call   f0100b31 <cprintf>
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	ff 35 90 21 10 f0    	pushl  0xf0102190
f01006aa:	ff 35 8c 21 10 f0    	pushl  0xf010218c
f01006b0:	68 69 1d 10 f0       	push   $0xf0101d69
f01006b5:	e8 77 04 00 00       	call   f0100b31 <cprintf>
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	ff 35 9c 21 10 f0    	pushl  0xf010219c
f01006c3:	ff 35 98 21 10 f0    	pushl  0xf0102198
f01006c9:	68 69 1d 10 f0       	push   $0xf0101d69
f01006ce:	e8 5e 04 00 00       	call   f0100b31 <cprintf>
f01006d3:	83 c4 0c             	add    $0xc,%esp
f01006d6:	ff 35 a8 21 10 f0    	pushl  0xf01021a8
f01006dc:	ff 35 a4 21 10 f0    	pushl  0xf01021a4
f01006e2:	68 69 1d 10 f0       	push   $0xf0101d69
f01006e7:	e8 45 04 00 00       	call   f0100b31 <cprintf>
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
f0100704:	68 2c 1f 10 f0       	push   $0xf0101f2c
f0100709:	e8 23 04 00 00       	call   f0100b31 <cprintf>
        cprintf("num show the color attribute. \n");
f010070e:	c7 04 24 5c 1f 10 f0 	movl   $0xf0101f5c,(%esp)
f0100715:	e8 17 04 00 00       	call   f0100b31 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f010071a:	c7 04 24 7c 1f 10 f0 	movl   $0xf0101f7c,(%esp)
f0100721:	e8 0b 04 00 00       	call   f0100b31 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100726:	c7 04 24 b0 1f 10 f0 	movl   $0xf0101fb0,(%esp)
f010072d:	e8 ff 03 00 00       	call   f0100b31 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100732:	c7 04 24 f4 1f 10 f0 	movl   $0xf0101ff4,(%esp)
f0100739:	e8 f3 03 00 00       	call   f0100b31 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f010073e:	c7 04 24 72 1d 10 f0 	movl   $0xf0101d72,(%esp)
f0100745:	e8 e7 03 00 00       	call   f0100b31 <cprintf>
        cprintf("         set the background color to black\n");
f010074a:	c7 04 24 38 20 10 f0 	movl   $0xf0102038,(%esp)
f0100751:	e8 db 03 00 00       	call   f0100b31 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100756:	c7 04 24 64 20 10 f0 	movl   $0xf0102064,(%esp)
f010075d:	e8 cf 03 00 00       	call   f0100b31 <cprintf>
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	eb 52                	jmp    f01007b9 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	ff 73 04             	pushl  0x4(%ebx)
f010076d:	e8 1e 0d 00 00       	call   f0101490 <strlen>
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
f01007a3:	89 15 00 93 11 f0    	mov    %edx,0xf0119300
        cprintf(" This is color that you want ! \n");
f01007a9:	83 ec 0c             	sub    $0xc,%esp
f01007ac:	68 98 20 10 f0       	push   $0xf0102098
f01007b1:	e8 7b 03 00 00       	call   f0100b31 <cprintf>
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
f01007ed:	68 bc 20 10 f0       	push   $0xf01020bc
f01007f2:	e8 3a 03 00 00       	call   f0100b31 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f01007f7:	83 c4 18             	add    $0x18,%esp
f01007fa:	57                   	push   %edi
f01007fb:	ff 76 04             	pushl  0x4(%esi)
f01007fe:	e8 6a 04 00 00       	call   f0100c6d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100809:	ff 75 d0             	pushl  -0x30(%ebp)
f010080c:	68 8e 1d 10 f0       	push   $0xf0101d8e
f0100811:	e8 1b 03 00 00       	call   f0100b31 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	ff 75 d8             	pushl  -0x28(%ebp)
f010081c:	ff 75 dc             	pushl  -0x24(%ebp)
f010081f:	68 9e 1d 10 f0       	push   $0xf0101d9e
f0100824:	e8 08 03 00 00       	call   f0100b31 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100829:	83 c4 08             	add    $0x8,%esp
f010082c:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010082f:	53                   	push   %ebx
f0100830:	68 a3 1d 10 f0       	push   $0xf0101da3
f0100835:	e8 f7 02 00 00       	call   f0100b31 <cprintf>
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
f0100859:	68 f4 20 10 f0       	push   $0xf01020f4
f010085e:	e8 ce 02 00 00       	call   f0100b31 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100863:	c7 04 24 18 21 10 f0 	movl   $0xf0102118,(%esp)
f010086a:	e8 c2 02 00 00       	call   f0100b31 <cprintf>
f010086f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100872:	83 ec 0c             	sub    $0xc,%esp
f0100875:	68 a8 1d 10 f0       	push   $0xf0101da8
f010087a:	e8 41 0b 00 00       	call   f01013c0 <readline>
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
f01008a7:	68 ac 1d 10 f0       	push   $0xf0101dac
f01008ac:	e8 58 0d 00 00       	call   f0101609 <strchr>
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
f01008c7:	68 b1 1d 10 f0       	push   $0xf0101db1
f01008cc:	e8 60 02 00 00       	call   f0100b31 <cprintf>
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
f01008f1:	68 ac 1d 10 f0       	push   $0xf0101dac
f01008f6:	e8 0e 0d 00 00       	call   f0101609 <strchr>
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
f0100914:	bb 80 21 10 f0       	mov    $0xf0102180,%ebx
f0100919:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	ff 33                	pushl  (%ebx)
f0100923:	ff 75 a8             	pushl  -0x58(%ebp)
f0100926:	e8 70 0c 00 00       	call   f010159b <strcmp>
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
f0100940:	ff 97 88 21 10 f0    	call   *-0xfefde78(%edi)


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
f0100961:	68 ce 1d 10 f0       	push   $0xf0101dce
f0100966:	e8 c6 01 00 00       	call   f0100b31 <cprintf>
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

f010097c <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010097c:	55                   	push   %ebp
f010097d:	89 e5                	mov    %esp,%ebp
f010097f:	56                   	push   %esi
f0100980:	53                   	push   %ebx
f0100981:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100983:	83 ec 0c             	sub    $0xc,%esp
f0100986:	50                   	push   %eax
f0100987:	e8 44 01 00 00       	call   f0100ad0 <mc146818_read>
f010098c:	89 c6                	mov    %eax,%esi
f010098e:	43                   	inc    %ebx
f010098f:	89 1c 24             	mov    %ebx,(%esp)
f0100992:	e8 39 01 00 00       	call   f0100ad0 <mc146818_read>
f0100997:	c1 e0 08             	shl    $0x8,%eax
f010099a:	09 f0                	or     %esi,%eax
}
f010099c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010099f:	5b                   	pop    %ebx
f01009a0:	5e                   	pop    %esi
f01009a1:	c9                   	leave  
f01009a2:	c3                   	ret    

f01009a3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01009a3:	55                   	push   %ebp
f01009a4:	89 e5                	mov    %esp,%ebp
f01009a6:	83 ec 08             	sub    $0x8,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01009a9:	b8 15 00 00 00       	mov    $0x15,%eax
f01009ae:	e8 c9 ff ff ff       	call   f010097c <nvram_read>
f01009b3:	c1 e0 0a             	shl    $0xa,%eax
f01009b6:	89 c2                	mov    %eax,%edx
f01009b8:	85 c0                	test   %eax,%eax
f01009ba:	79 06                	jns    f01009c2 <mem_init+0x1f>
f01009bc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01009c2:	c1 fa 0c             	sar    $0xc,%edx
f01009c5:	89 15 30 95 11 f0    	mov    %edx,0xf0119530
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01009cb:	b8 17 00 00 00       	mov    $0x17,%eax
f01009d0:	e8 a7 ff ff ff       	call   f010097c <nvram_read>
f01009d5:	c1 e0 0a             	shl    $0xa,%eax
f01009d8:	89 c2                	mov    %eax,%edx
f01009da:	85 c0                	test   %eax,%eax
f01009dc:	79 06                	jns    f01009e4 <mem_init+0x41>
f01009de:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01009e4:	c1 fa 0c             	sar    $0xc,%edx
f01009e7:	74 0d                	je     f01009f6 <mem_init+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01009e9:	8d 82 00 01 00 00    	lea    0x100(%edx),%eax
f01009ef:	a3 44 99 11 f0       	mov    %eax,0xf0119944
f01009f4:	eb 0a                	jmp    f0100a00 <mem_init+0x5d>
	else
		npages = npages_basemem;
f01009f6:	a1 30 95 11 f0       	mov    0xf0119530,%eax
f01009fb:	a3 44 99 11 f0       	mov    %eax,0xf0119944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100a00:	c1 e2 0c             	shl    $0xc,%edx
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a03:	c1 ea 0a             	shr    $0xa,%edx
f0100a06:	52                   	push   %edx
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100a07:	a1 30 95 11 f0       	mov    0xf0119530,%eax
f0100a0c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a0f:	c1 e8 0a             	shr    $0xa,%eax
f0100a12:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0100a13:	a1 44 99 11 f0       	mov    0xf0119944,%eax
f0100a18:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a1b:	c1 e8 0a             	shr    $0xa,%eax
f0100a1e:	50                   	push   %eax
f0100a1f:	68 b0 21 10 f0       	push   $0xf01021b0
f0100a24:	e8 08 01 00 00       	call   f0100b31 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f0100a29:	83 c4 0c             	add    $0xc,%esp
f0100a2c:	68 ec 21 10 f0       	push   $0xf01021ec
f0100a31:	6a 7c                	push   $0x7c
f0100a33:	68 18 22 10 f0       	push   $0xf0102218
f0100a38:	e8 4e f6 ff ff       	call   f010008b <_panic>

f0100a3d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100a3d:	55                   	push   %ebp
f0100a3e:	89 e5                	mov    %esp,%ebp
f0100a40:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a41:	83 3d 44 99 11 f0 00 	cmpl   $0x0,0xf0119944
f0100a48:	74 39                	je     f0100a83 <page_init+0x46>
f0100a4a:	8b 1d 2c 95 11 f0    	mov    0xf011952c,%ebx
f0100a50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a55:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100a5c:	89 d1                	mov    %edx,%ecx
f0100a5e:	03 0d 4c 99 11 f0    	add    0xf011994c,%ecx
f0100a64:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100a6a:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100a6c:	89 d3                	mov    %edx,%ebx
f0100a6e:	03 1d 4c 99 11 f0    	add    0xf011994c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a74:	40                   	inc    %eax
f0100a75:	39 05 44 99 11 f0    	cmp    %eax,0xf0119944
f0100a7b:	77 d8                	ja     f0100a55 <page_init+0x18>
f0100a7d:	89 1d 2c 95 11 f0    	mov    %ebx,0xf011952c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100a83:	5b                   	pop    %ebx
f0100a84:	c9                   	leave  
f0100a85:	c3                   	ret    

f0100a86 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100a86:	55                   	push   %ebp
f0100a87:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a8e:	c9                   	leave  
f0100a8f:	c3                   	ret    

f0100a90 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100a90:	55                   	push   %ebp
f0100a91:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a93:	c9                   	leave  
f0100a94:	c3                   	ret    

f0100a95 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100a95:	55                   	push   %ebp
f0100a96:	89 e5                	mov    %esp,%ebp
f0100a98:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100a9b:	66 ff 48 04          	decw   0x4(%eax)
		page_free(pp);
}
f0100a9f:	c9                   	leave  
f0100aa0:	c3                   	ret    

f0100aa1 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100aa1:	55                   	push   %ebp
f0100aa2:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100aa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa9:	c9                   	leave  
f0100aaa:	c3                   	ret    

f0100aab <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100aab:	55                   	push   %ebp
f0100aac:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100aae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab3:	c9                   	leave  
f0100ab4:	c3                   	ret    

f0100ab5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ab5:	55                   	push   %ebp
f0100ab6:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100ab8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100abd:	c9                   	leave  
f0100abe:	c3                   	ret    

f0100abf <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100ac2:	c9                   	leave  
f0100ac3:	c3                   	ret    

f0100ac4 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100ac4:	55                   	push   %ebp
f0100ac5:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100aca:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100acd:	c9                   	leave  
f0100ace:	c3                   	ret    
	...

f0100ad0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ad3:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ad8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100adb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100adc:	b2 71                	mov    $0x71,%dl
f0100ade:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100adf:	0f b6 c0             	movzbl %al,%eax
}
f0100ae2:	c9                   	leave  
f0100ae3:	c3                   	ret    

f0100ae4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100ae4:	55                   	push   %ebp
f0100ae5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ae7:	ba 70 00 00 00       	mov    $0x70,%edx
f0100aec:	8b 45 08             	mov    0x8(%ebp),%eax
f0100aef:	ee                   	out    %al,(%dx)
f0100af0:	b2 71                	mov    $0x71,%dl
f0100af2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100af5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100af6:	c9                   	leave  
f0100af7:	c3                   	ret    

f0100af8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100af8:	55                   	push   %ebp
f0100af9:	89 e5                	mov    %esp,%ebp
f0100afb:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100afe:	ff 75 08             	pushl  0x8(%ebp)
f0100b01:	e8 a0 fa ff ff       	call   f01005a6 <cputchar>
f0100b06:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0100b09:	c9                   	leave  
f0100b0a:	c3                   	ret    

f0100b0b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b0b:	55                   	push   %ebp
f0100b0c:	89 e5                	mov    %esp,%ebp
f0100b0e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100b11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b18:	ff 75 0c             	pushl  0xc(%ebp)
f0100b1b:	ff 75 08             	pushl  0x8(%ebp)
f0100b1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b21:	50                   	push   %eax
f0100b22:	68 f8 0a 10 f0       	push   $0xf0100af8
f0100b27:	e8 6b 04 00 00       	call   f0100f97 <vprintfmt>
	return cnt;
}
f0100b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b2f:	c9                   	leave  
f0100b30:	c3                   	ret    

f0100b31 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b31:	55                   	push   %ebp
f0100b32:	89 e5                	mov    %esp,%ebp
f0100b34:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b37:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b3a:	50                   	push   %eax
f0100b3b:	ff 75 08             	pushl  0x8(%ebp)
f0100b3e:	e8 c8 ff ff ff       	call   f0100b0b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b43:	c9                   	leave  
f0100b44:	c3                   	ret    
f0100b45:	00 00                	add    %al,(%eax)
	...

f0100b48 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b48:	55                   	push   %ebp
f0100b49:	89 e5                	mov    %esp,%ebp
f0100b4b:	57                   	push   %edi
f0100b4c:	56                   	push   %esi
f0100b4d:	53                   	push   %ebx
f0100b4e:	83 ec 14             	sub    $0x14,%esp
f0100b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b54:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100b57:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b5a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b5d:	8b 1a                	mov    (%edx),%ebx
f0100b5f:	8b 01                	mov    (%ecx),%eax
f0100b61:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0100b64:	39 c3                	cmp    %eax,%ebx
f0100b66:	0f 8f 97 00 00 00    	jg     f0100c03 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100b76:	01 d8                	add    %ebx,%eax
f0100b78:	89 c7                	mov    %eax,%edi
f0100b7a:	c1 ef 1f             	shr    $0x1f,%edi
f0100b7d:	01 c7                	add    %eax,%edi
f0100b7f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b81:	39 df                	cmp    %ebx,%edi
f0100b83:	7c 31                	jl     f0100bb6 <stab_binsearch+0x6e>
f0100b85:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100b8b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100b90:	39 f0                	cmp    %esi,%eax
f0100b92:	0f 84 b3 00 00 00    	je     f0100c4b <stab_binsearch+0x103>
f0100b98:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100b9c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100ba0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100ba2:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ba3:	39 d8                	cmp    %ebx,%eax
f0100ba5:	7c 0f                	jl     f0100bb6 <stab_binsearch+0x6e>
f0100ba7:	0f b6 0a             	movzbl (%edx),%ecx
f0100baa:	83 ea 0c             	sub    $0xc,%edx
f0100bad:	39 f1                	cmp    %esi,%ecx
f0100baf:	75 f1                	jne    f0100ba2 <stab_binsearch+0x5a>
f0100bb1:	e9 97 00 00 00       	jmp    f0100c4d <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100bb6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bb9:	eb 39                	jmp    f0100bf4 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100bbb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100bbe:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100bc0:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bc3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100bca:	eb 28                	jmp    f0100bf4 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100bcc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bcf:	76 12                	jbe    f0100be3 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0100bd1:	48                   	dec    %eax
f0100bd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100bd8:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bda:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100be1:	eb 11                	jmp    f0100bf4 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100be3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100be6:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100be8:	ff 45 0c             	incl   0xc(%ebp)
f0100beb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bed:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100bf4:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100bf7:	0f 8d 76 ff ff ff    	jge    f0100b73 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100bfd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c01:	75 0d                	jne    f0100c10 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0100c03:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100c06:	8b 03                	mov    (%ebx),%eax
f0100c08:	48                   	dec    %eax
f0100c09:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c0c:	89 02                	mov    %eax,(%edx)
f0100c0e:	eb 55                	jmp    f0100c65 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100c13:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c15:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100c18:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c1a:	39 c1                	cmp    %eax,%ecx
f0100c1c:	7d 26                	jge    f0100c44 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100c1e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c21:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100c24:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100c29:	39 f2                	cmp    %esi,%edx
f0100c2b:	74 17                	je     f0100c44 <stab_binsearch+0xfc>
f0100c2d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100c31:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100c35:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c36:	39 c1                	cmp    %eax,%ecx
f0100c38:	7d 0a                	jge    f0100c44 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100c3a:	0f b6 1a             	movzbl (%edx),%ebx
f0100c3d:	83 ea 0c             	sub    $0xc,%edx
f0100c40:	39 f3                	cmp    %esi,%ebx
f0100c42:	75 f1                	jne    f0100c35 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100c44:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c47:	89 02                	mov    %eax,(%edx)
f0100c49:	eb 1a                	jmp    f0100c65 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100c4b:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c4d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c50:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100c53:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100c57:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c5a:	0f 82 5b ff ff ff    	jb     f0100bbb <stab_binsearch+0x73>
f0100c60:	e9 67 ff ff ff       	jmp    f0100bcc <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c65:	83 c4 14             	add    $0x14,%esp
f0100c68:	5b                   	pop    %ebx
f0100c69:	5e                   	pop    %esi
f0100c6a:	5f                   	pop    %edi
f0100c6b:	c9                   	leave  
f0100c6c:	c3                   	ret    

f0100c6d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c6d:	55                   	push   %ebp
f0100c6e:	89 e5                	mov    %esp,%ebp
f0100c70:	57                   	push   %edi
f0100c71:	56                   	push   %esi
f0100c72:	53                   	push   %ebx
f0100c73:	83 ec 2c             	sub    $0x2c,%esp
f0100c76:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c7c:	c7 03 24 22 10 f0    	movl   $0xf0102224,(%ebx)
	info->eip_line = 0;
f0100c82:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100c89:	c7 43 08 24 22 10 f0 	movl   $0xf0102224,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100c90:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100c97:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100c9a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ca1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ca7:	76 12                	jbe    f0100cbb <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ca9:	b8 a1 e8 10 f0       	mov    $0xf010e8a1,%eax
f0100cae:	3d b1 72 10 f0       	cmp    $0xf01072b1,%eax
f0100cb3:	0f 86 90 01 00 00    	jbe    f0100e49 <debuginfo_eip+0x1dc>
f0100cb9:	eb 14                	jmp    f0100ccf <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100cbb:	83 ec 04             	sub    $0x4,%esp
f0100cbe:	68 2e 22 10 f0       	push   $0xf010222e
f0100cc3:	6a 7f                	push   $0x7f
f0100cc5:	68 3b 22 10 f0       	push   $0xf010223b
f0100cca:	e8 bc f3 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cd4:	80 3d a0 e8 10 f0 00 	cmpb   $0x0,0xf010e8a0
f0100cdb:	0f 85 74 01 00 00    	jne    f0100e55 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ce1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ce8:	b8 b0 72 10 f0       	mov    $0xf01072b0,%eax
f0100ced:	2d 5c 24 10 f0       	sub    $0xf010245c,%eax
f0100cf2:	c1 f8 02             	sar    $0x2,%eax
f0100cf5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100cfb:	48                   	dec    %eax
f0100cfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cff:	83 ec 08             	sub    $0x8,%esp
f0100d02:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d05:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d08:	56                   	push   %esi
f0100d09:	6a 64                	push   $0x64
f0100d0b:	b8 5c 24 10 f0       	mov    $0xf010245c,%eax
f0100d10:	e8 33 fe ff ff       	call   f0100b48 <stab_binsearch>
	if (lfile == 0)
f0100d15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d18:	83 c4 10             	add    $0x10,%esp
		return -1;
f0100d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100d20:	85 d2                	test   %edx,%edx
f0100d22:	0f 84 2d 01 00 00    	je     f0100e55 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d28:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100d2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d31:	83 ec 08             	sub    $0x8,%esp
f0100d34:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d37:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d3a:	56                   	push   %esi
f0100d3b:	6a 24                	push   $0x24
f0100d3d:	b8 5c 24 10 f0       	mov    $0xf010245c,%eax
f0100d42:	e8 01 fe ff ff       	call   f0100b48 <stab_binsearch>

	if (lfun <= rfun) {
f0100d47:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100d4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d50:	83 c4 10             	add    $0x10,%esp
f0100d53:	39 c7                	cmp    %eax,%edi
f0100d55:	7f 32                	jg     f0100d89 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d57:	89 f9                	mov    %edi,%ecx
f0100d59:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100d5c:	8b 80 5c 24 10 f0    	mov    -0xfefdba4(%eax),%eax
f0100d62:	ba a1 e8 10 f0       	mov    $0xf010e8a1,%edx
f0100d67:	81 ea b1 72 10 f0    	sub    $0xf01072b1,%edx
f0100d6d:	39 d0                	cmp    %edx,%eax
f0100d6f:	73 08                	jae    f0100d79 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d71:	05 b1 72 10 f0       	add    $0xf01072b1,%eax
f0100d76:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d79:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0100d7c:	8b 81 64 24 10 f0    	mov    -0xfefdb9c(%ecx),%eax
f0100d82:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100d85:	29 c6                	sub    %eax,%esi
f0100d87:	eb 0c                	jmp    f0100d95 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100d89:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100d8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0100d8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d92:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d95:	83 ec 08             	sub    $0x8,%esp
f0100d98:	6a 3a                	push   $0x3a
f0100d9a:	ff 73 08             	pushl  0x8(%ebx)
f0100d9d:	e8 95 08 00 00       	call   f0101637 <strfind>
f0100da2:	2b 43 08             	sub    0x8(%ebx),%eax
f0100da5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0100da8:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0100dab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dae:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0100db1:	83 c4 08             	add    $0x8,%esp
f0100db4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100db7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dba:	56                   	push   %esi
f0100dbb:	6a 44                	push   $0x44
f0100dbd:	b8 5c 24 10 f0       	mov    $0xf010245c,%eax
f0100dc2:	e8 81 fd ff ff       	call   f0100b48 <stab_binsearch>
    if (lfun <= rfun) {
f0100dc7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dca:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0100dcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0100dd2:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0100dd5:	7f 7e                	jg     f0100e55 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0100dd7:	6b c2 0c             	imul   $0xc,%edx,%eax
f0100dda:	05 5c 24 10 f0       	add    $0xf010245c,%eax
f0100ddf:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100de3:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100de6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100de9:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100dec:	eb 04                	jmp    f0100df2 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100dee:	4a                   	dec    %edx
f0100def:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100df2:	39 f2                	cmp    %esi,%edx
f0100df4:	7c 1b                	jl     f0100e11 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0100df6:	8a 48 fc             	mov    -0x4(%eax),%cl
f0100df9:	80 f9 84             	cmp    $0x84,%cl
f0100dfc:	74 5f                	je     f0100e5d <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dfe:	80 f9 64             	cmp    $0x64,%cl
f0100e01:	75 eb                	jne    f0100dee <debuginfo_eip+0x181>
f0100e03:	83 38 00             	cmpl   $0x0,(%eax)
f0100e06:	74 e6                	je     f0100dee <debuginfo_eip+0x181>
f0100e08:	eb 53                	jmp    f0100e5d <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e0a:	05 b1 72 10 f0       	add    $0xf01072b1,%eax
f0100e0f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e11:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e14:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e17:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e1c:	39 ca                	cmp    %ecx,%edx
f0100e1e:	7d 35                	jge    f0100e55 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0100e20:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100e23:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100e26:	81 c2 60 24 10 f0    	add    $0xf0102460,%edx
f0100e2c:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e2e:	eb 04                	jmp    f0100e34 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100e30:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100e33:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e34:	39 f0                	cmp    %esi,%eax
f0100e36:	7d 18                	jge    f0100e50 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e38:	8a 0a                	mov    (%edx),%cl
f0100e3a:	83 c2 0c             	add    $0xc,%edx
f0100e3d:	80 f9 a0             	cmp    $0xa0,%cl
f0100e40:	74 ee                	je     f0100e30 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e42:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e47:	eb 0c                	jmp    f0100e55 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e4e:	eb 05                	jmp    f0100e55 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e58:	5b                   	pop    %ebx
f0100e59:	5e                   	pop    %esi
f0100e5a:	5f                   	pop    %edi
f0100e5b:	c9                   	leave  
f0100e5c:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e5d:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100e60:	8b 82 5c 24 10 f0    	mov    -0xfefdba4(%edx),%eax
f0100e66:	ba a1 e8 10 f0       	mov    $0xf010e8a1,%edx
f0100e6b:	81 ea b1 72 10 f0    	sub    $0xf01072b1,%edx
f0100e71:	39 d0                	cmp    %edx,%eax
f0100e73:	72 95                	jb     f0100e0a <debuginfo_eip+0x19d>
f0100e75:	eb 9a                	jmp    f0100e11 <debuginfo_eip+0x1a4>
	...

f0100e78 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e78:	55                   	push   %ebp
f0100e79:	89 e5                	mov    %esp,%ebp
f0100e7b:	57                   	push   %edi
f0100e7c:	56                   	push   %esi
f0100e7d:	53                   	push   %ebx
f0100e7e:	83 ec 2c             	sub    $0x2c,%esp
f0100e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e84:	89 d6                	mov    %edx,%esi
f0100e86:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e89:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100e92:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e95:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100e98:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e9e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100ea5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100ea8:	72 0c                	jb     f0100eb6 <printnum+0x3e>
f0100eaa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100ead:	76 07                	jbe    f0100eb6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100eaf:	4b                   	dec    %ebx
f0100eb0:	85 db                	test   %ebx,%ebx
f0100eb2:	7f 31                	jg     f0100ee5 <printnum+0x6d>
f0100eb4:	eb 3f                	jmp    f0100ef5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100eb6:	83 ec 0c             	sub    $0xc,%esp
f0100eb9:	57                   	push   %edi
f0100eba:	4b                   	dec    %ebx
f0100ebb:	53                   	push   %ebx
f0100ebc:	50                   	push   %eax
f0100ebd:	83 ec 08             	sub    $0x8,%esp
f0100ec0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ec3:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ec6:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ec9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ecc:	e8 8f 09 00 00       	call   f0101860 <__udivdi3>
f0100ed1:	83 c4 18             	add    $0x18,%esp
f0100ed4:	52                   	push   %edx
f0100ed5:	50                   	push   %eax
f0100ed6:	89 f2                	mov    %esi,%edx
f0100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100edb:	e8 98 ff ff ff       	call   f0100e78 <printnum>
f0100ee0:	83 c4 20             	add    $0x20,%esp
f0100ee3:	eb 10                	jmp    f0100ef5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ee5:	83 ec 08             	sub    $0x8,%esp
f0100ee8:	56                   	push   %esi
f0100ee9:	57                   	push   %edi
f0100eea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100eed:	4b                   	dec    %ebx
f0100eee:	83 c4 10             	add    $0x10,%esp
f0100ef1:	85 db                	test   %ebx,%ebx
f0100ef3:	7f f0                	jg     f0100ee5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ef5:	83 ec 08             	sub    $0x8,%esp
f0100ef8:	56                   	push   %esi
f0100ef9:	83 ec 04             	sub    $0x4,%esp
f0100efc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100eff:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f02:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f05:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f08:	e8 6f 0a 00 00       	call   f010197c <__umoddi3>
f0100f0d:	83 c4 14             	add    $0x14,%esp
f0100f10:	0f be 80 49 22 10 f0 	movsbl -0xfefddb7(%eax),%eax
f0100f17:	50                   	push   %eax
f0100f18:	ff 55 e4             	call   *-0x1c(%ebp)
f0100f1b:	83 c4 10             	add    $0x10,%esp
}
f0100f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f21:	5b                   	pop    %ebx
f0100f22:	5e                   	pop    %esi
f0100f23:	5f                   	pop    %edi
f0100f24:	c9                   	leave  
f0100f25:	c3                   	ret    

f0100f26 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100f26:	55                   	push   %ebp
f0100f27:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100f29:	83 fa 01             	cmp    $0x1,%edx
f0100f2c:	7e 0e                	jle    f0100f3c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100f2e:	8b 10                	mov    (%eax),%edx
f0100f30:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100f33:	89 08                	mov    %ecx,(%eax)
f0100f35:	8b 02                	mov    (%edx),%eax
f0100f37:	8b 52 04             	mov    0x4(%edx),%edx
f0100f3a:	eb 22                	jmp    f0100f5e <getuint+0x38>
	else if (lflag)
f0100f3c:	85 d2                	test   %edx,%edx
f0100f3e:	74 10                	je     f0100f50 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100f40:	8b 10                	mov    (%eax),%edx
f0100f42:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f45:	89 08                	mov    %ecx,(%eax)
f0100f47:	8b 02                	mov    (%edx),%eax
f0100f49:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f4e:	eb 0e                	jmp    f0100f5e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100f50:	8b 10                	mov    (%eax),%edx
f0100f52:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f55:	89 08                	mov    %ecx,(%eax)
f0100f57:	8b 02                	mov    (%edx),%eax
f0100f59:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f5e:	c9                   	leave  
f0100f5f:	c3                   	ret    

f0100f60 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f66:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100f69:	8b 10                	mov    (%eax),%edx
f0100f6b:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f6e:	73 08                	jae    f0100f78 <sprintputch+0x18>
		*b->buf++ = ch;
f0100f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100f73:	88 0a                	mov    %cl,(%edx)
f0100f75:	42                   	inc    %edx
f0100f76:	89 10                	mov    %edx,(%eax)
}
f0100f78:	c9                   	leave  
f0100f79:	c3                   	ret    

f0100f7a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f7a:	55                   	push   %ebp
f0100f7b:	89 e5                	mov    %esp,%ebp
f0100f7d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100f80:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f83:	50                   	push   %eax
f0100f84:	ff 75 10             	pushl  0x10(%ebp)
f0100f87:	ff 75 0c             	pushl  0xc(%ebp)
f0100f8a:	ff 75 08             	pushl  0x8(%ebp)
f0100f8d:	e8 05 00 00 00       	call   f0100f97 <vprintfmt>
	va_end(ap);
f0100f92:	83 c4 10             	add    $0x10,%esp
}
f0100f95:	c9                   	leave  
f0100f96:	c3                   	ret    

f0100f97 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100f97:	55                   	push   %ebp
f0100f98:	89 e5                	mov    %esp,%ebp
f0100f9a:	57                   	push   %edi
f0100f9b:	56                   	push   %esi
f0100f9c:	53                   	push   %ebx
f0100f9d:	83 ec 2c             	sub    $0x2c,%esp
f0100fa0:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100fa3:	8b 75 10             	mov    0x10(%ebp),%esi
f0100fa6:	eb 13                	jmp    f0100fbb <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100fa8:	85 c0                	test   %eax,%eax
f0100faa:	0f 84 99 03 00 00    	je     f0101349 <vprintfmt+0x3b2>
				return;
			putch(ch, putdat);
f0100fb0:	83 ec 08             	sub    $0x8,%esp
f0100fb3:	57                   	push   %edi
f0100fb4:	50                   	push   %eax
f0100fb5:	ff 55 08             	call   *0x8(%ebp)
f0100fb8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fbb:	0f b6 06             	movzbl (%esi),%eax
f0100fbe:	46                   	inc    %esi
f0100fbf:	83 f8 25             	cmp    $0x25,%eax
f0100fc2:	75 e4                	jne    f0100fa8 <vprintfmt+0x11>
f0100fc4:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100fc8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100fcf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100fd6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100fdd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe2:	eb 28                	jmp    f010100c <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fe4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100fe6:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0100fea:	eb 20                	jmp    f010100c <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fec:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100fee:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100ff2:	eb 18                	jmp    f010100c <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff4:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100ff6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100ffd:	eb 0d                	jmp    f010100c <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100fff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101002:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101005:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010100c:	8a 06                	mov    (%esi),%al
f010100e:	0f b6 d0             	movzbl %al,%edx
f0101011:	8d 5e 01             	lea    0x1(%esi),%ebx
f0101014:	83 e8 23             	sub    $0x23,%eax
f0101017:	3c 55                	cmp    $0x55,%al
f0101019:	0f 87 0c 03 00 00    	ja     f010132b <vprintfmt+0x394>
f010101f:	0f b6 c0             	movzbl %al,%eax
f0101022:	ff 24 85 d8 22 10 f0 	jmp    *-0xfefdd28(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101029:	83 ea 30             	sub    $0x30,%edx
f010102c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f010102f:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0101032:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101035:	83 fa 09             	cmp    $0x9,%edx
f0101038:	77 44                	ja     f010107e <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010103a:	89 de                	mov    %ebx,%esi
f010103c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010103f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0101040:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101043:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101047:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010104a:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010104d:	83 fb 09             	cmp    $0x9,%ebx
f0101050:	76 ed                	jbe    f010103f <vprintfmt+0xa8>
f0101052:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101055:	eb 29                	jmp    f0101080 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101057:	8b 45 14             	mov    0x14(%ebp),%eax
f010105a:	8d 50 04             	lea    0x4(%eax),%edx
f010105d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101060:	8b 00                	mov    (%eax),%eax
f0101062:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101065:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101067:	eb 17                	jmp    f0101080 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0101069:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010106d:	78 85                	js     f0100ff4 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106f:	89 de                	mov    %ebx,%esi
f0101071:	eb 99                	jmp    f010100c <vprintfmt+0x75>
f0101073:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101075:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010107c:	eb 8e                	jmp    f010100c <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010107e:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101080:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101084:	79 86                	jns    f010100c <vprintfmt+0x75>
f0101086:	e9 74 ff ff ff       	jmp    f0100fff <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010108b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010108c:	89 de                	mov    %ebx,%esi
f010108e:	e9 79 ff ff ff       	jmp    f010100c <vprintfmt+0x75>
f0101093:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101096:	8b 45 14             	mov    0x14(%ebp),%eax
f0101099:	8d 50 04             	lea    0x4(%eax),%edx
f010109c:	89 55 14             	mov    %edx,0x14(%ebp)
f010109f:	83 ec 08             	sub    $0x8,%esp
f01010a2:	57                   	push   %edi
f01010a3:	ff 30                	pushl  (%eax)
f01010a5:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01010ae:	e9 08 ff ff ff       	jmp    f0100fbb <vprintfmt+0x24>
f01010b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01010b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b9:	8d 50 04             	lea    0x4(%eax),%edx
f01010bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01010bf:	8b 00                	mov    (%eax),%eax
f01010c1:	85 c0                	test   %eax,%eax
f01010c3:	79 02                	jns    f01010c7 <vprintfmt+0x130>
f01010c5:	f7 d8                	neg    %eax
f01010c7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010c9:	83 f8 06             	cmp    $0x6,%eax
f01010cc:	7f 0b                	jg     f01010d9 <vprintfmt+0x142>
f01010ce:	8b 04 85 30 24 10 f0 	mov    -0xfefdbd0(,%eax,4),%eax
f01010d5:	85 c0                	test   %eax,%eax
f01010d7:	75 1a                	jne    f01010f3 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01010d9:	52                   	push   %edx
f01010da:	68 61 22 10 f0       	push   $0xf0102261
f01010df:	57                   	push   %edi
f01010e0:	ff 75 08             	pushl  0x8(%ebp)
f01010e3:	e8 92 fe ff ff       	call   f0100f7a <printfmt>
f01010e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01010ee:	e9 c8 fe ff ff       	jmp    f0100fbb <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f01010f3:	50                   	push   %eax
f01010f4:	68 6a 22 10 f0       	push   $0xf010226a
f01010f9:	57                   	push   %edi
f01010fa:	ff 75 08             	pushl  0x8(%ebp)
f01010fd:	e8 78 fe ff ff       	call   f0100f7a <printfmt>
f0101102:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101105:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101108:	e9 ae fe ff ff       	jmp    f0100fbb <vprintfmt+0x24>
f010110d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0101110:	89 de                	mov    %ebx,%esi
f0101112:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101115:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101118:	8b 45 14             	mov    0x14(%ebp),%eax
f010111b:	8d 50 04             	lea    0x4(%eax),%edx
f010111e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101121:	8b 00                	mov    (%eax),%eax
f0101123:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101126:	85 c0                	test   %eax,%eax
f0101128:	75 07                	jne    f0101131 <vprintfmt+0x19a>
				p = "(null)";
f010112a:	c7 45 d0 5a 22 10 f0 	movl   $0xf010225a,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0101131:	85 db                	test   %ebx,%ebx
f0101133:	7e 42                	jle    f0101177 <vprintfmt+0x1e0>
f0101135:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0101139:	74 3c                	je     f0101177 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010113b:	83 ec 08             	sub    $0x8,%esp
f010113e:	51                   	push   %ecx
f010113f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101142:	e8 69 03 00 00       	call   f01014b0 <strnlen>
f0101147:	29 c3                	sub    %eax,%ebx
f0101149:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010114c:	83 c4 10             	add    $0x10,%esp
f010114f:	85 db                	test   %ebx,%ebx
f0101151:	7e 24                	jle    f0101177 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0101153:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0101157:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010115a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010115d:	83 ec 08             	sub    $0x8,%esp
f0101160:	57                   	push   %edi
f0101161:	53                   	push   %ebx
f0101162:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101165:	4e                   	dec    %esi
f0101166:	83 c4 10             	add    $0x10,%esp
f0101169:	85 f6                	test   %esi,%esi
f010116b:	7f f0                	jg     f010115d <vprintfmt+0x1c6>
f010116d:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101170:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101177:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010117a:	0f be 02             	movsbl (%edx),%eax
f010117d:	85 c0                	test   %eax,%eax
f010117f:	75 47                	jne    f01011c8 <vprintfmt+0x231>
f0101181:	eb 37                	jmp    f01011ba <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0101183:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101187:	74 16                	je     f010119f <vprintfmt+0x208>
f0101189:	8d 50 e0             	lea    -0x20(%eax),%edx
f010118c:	83 fa 5e             	cmp    $0x5e,%edx
f010118f:	76 0e                	jbe    f010119f <vprintfmt+0x208>
					putch('?', putdat);
f0101191:	83 ec 08             	sub    $0x8,%esp
f0101194:	57                   	push   %edi
f0101195:	6a 3f                	push   $0x3f
f0101197:	ff 55 08             	call   *0x8(%ebp)
f010119a:	83 c4 10             	add    $0x10,%esp
f010119d:	eb 0b                	jmp    f01011aa <vprintfmt+0x213>
				else
					putch(ch, putdat);
f010119f:	83 ec 08             	sub    $0x8,%esp
f01011a2:	57                   	push   %edi
f01011a3:	50                   	push   %eax
f01011a4:	ff 55 08             	call   *0x8(%ebp)
f01011a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011aa:	ff 4d e4             	decl   -0x1c(%ebp)
f01011ad:	0f be 03             	movsbl (%ebx),%eax
f01011b0:	85 c0                	test   %eax,%eax
f01011b2:	74 03                	je     f01011b7 <vprintfmt+0x220>
f01011b4:	43                   	inc    %ebx
f01011b5:	eb 1b                	jmp    f01011d2 <vprintfmt+0x23b>
f01011b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01011be:	7f 1e                	jg     f01011de <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011c0:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01011c3:	e9 f3 fd ff ff       	jmp    f0100fbb <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01011cb:	43                   	inc    %ebx
f01011cc:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01011cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01011d2:	85 f6                	test   %esi,%esi
f01011d4:	78 ad                	js     f0101183 <vprintfmt+0x1ec>
f01011d6:	4e                   	dec    %esi
f01011d7:	79 aa                	jns    f0101183 <vprintfmt+0x1ec>
f01011d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01011dc:	eb dc                	jmp    f01011ba <vprintfmt+0x223>
f01011de:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01011e1:	83 ec 08             	sub    $0x8,%esp
f01011e4:	57                   	push   %edi
f01011e5:	6a 20                	push   $0x20
f01011e7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011ea:	4b                   	dec    %ebx
f01011eb:	83 c4 10             	add    $0x10,%esp
f01011ee:	85 db                	test   %ebx,%ebx
f01011f0:	7f ef                	jg     f01011e1 <vprintfmt+0x24a>
f01011f2:	e9 c4 fd ff ff       	jmp    f0100fbb <vprintfmt+0x24>
f01011f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01011fa:	83 f9 01             	cmp    $0x1,%ecx
f01011fd:	7e 10                	jle    f010120f <vprintfmt+0x278>
		return va_arg(*ap, long long);
f01011ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101202:	8d 50 08             	lea    0x8(%eax),%edx
f0101205:	89 55 14             	mov    %edx,0x14(%ebp)
f0101208:	8b 18                	mov    (%eax),%ebx
f010120a:	8b 70 04             	mov    0x4(%eax),%esi
f010120d:	eb 26                	jmp    f0101235 <vprintfmt+0x29e>
	else if (lflag)
f010120f:	85 c9                	test   %ecx,%ecx
f0101211:	74 12                	je     f0101225 <vprintfmt+0x28e>
		return va_arg(*ap, long);
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	8d 50 04             	lea    0x4(%eax),%edx
f0101219:	89 55 14             	mov    %edx,0x14(%ebp)
f010121c:	8b 18                	mov    (%eax),%ebx
f010121e:	89 de                	mov    %ebx,%esi
f0101220:	c1 fe 1f             	sar    $0x1f,%esi
f0101223:	eb 10                	jmp    f0101235 <vprintfmt+0x29e>
	else
		return va_arg(*ap, int);
f0101225:	8b 45 14             	mov    0x14(%ebp),%eax
f0101228:	8d 50 04             	lea    0x4(%eax),%edx
f010122b:	89 55 14             	mov    %edx,0x14(%ebp)
f010122e:	8b 18                	mov    (%eax),%ebx
f0101230:	89 de                	mov    %ebx,%esi
f0101232:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101235:	85 f6                	test   %esi,%esi
f0101237:	78 11                	js     f010124a <vprintfmt+0x2b3>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101239:	89 d8                	mov    %ebx,%eax
f010123b:	89 f2                	mov    %esi,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010123d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101240:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101245:	e9 ab 00 00 00       	jmp    f01012f5 <vprintfmt+0x35e>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010124a:	83 ec 08             	sub    $0x8,%esp
f010124d:	57                   	push   %edi
f010124e:	6a 2d                	push   $0x2d
f0101250:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101253:	89 d8                	mov    %ebx,%eax
f0101255:	89 f2                	mov    %esi,%edx
f0101257:	f7 d8                	neg    %eax
f0101259:	83 d2 00             	adc    $0x0,%edx
f010125c:	f7 da                	neg    %edx
f010125e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101261:	8b 75 d8             	mov    -0x28(%ebp),%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101264:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101269:	e9 87 00 00 00       	jmp    f01012f5 <vprintfmt+0x35e>
f010126e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101271:	89 ca                	mov    %ecx,%edx
f0101273:	8d 45 14             	lea    0x14(%ebp),%eax
f0101276:	e8 ab fc ff ff       	call   f0100f26 <getuint>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010127b:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010127e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101283:	eb 70                	jmp    f01012f5 <vprintfmt+0x35e>
f0101285:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101288:	83 ec 08             	sub    $0x8,%esp
f010128b:	57                   	push   %edi
f010128c:	6a 58                	push   $0x58
f010128e:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101291:	83 c4 08             	add    $0x8,%esp
f0101294:	57                   	push   %edi
f0101295:	6a 58                	push   $0x58
f0101297:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010129a:	83 c4 08             	add    $0x8,%esp
f010129d:	57                   	push   %edi
f010129e:	6a 58                	push   $0x58
f01012a0:	ff 55 08             	call   *0x8(%ebp)
			break;
f01012a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01012a9:	e9 0d fd ff ff       	jmp    f0100fbb <vprintfmt+0x24>
f01012ae:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01012b1:	83 ec 08             	sub    $0x8,%esp
f01012b4:	57                   	push   %edi
f01012b5:	6a 30                	push   $0x30
f01012b7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01012ba:	83 c4 08             	add    $0x8,%esp
f01012bd:	57                   	push   %edi
f01012be:	6a 78                	push   $0x78
f01012c0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01012c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c6:	8d 50 04             	lea    0x4(%eax),%edx
f01012c9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01012cc:	8b 00                	mov    (%eax),%eax
f01012ce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01012d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012d6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01012d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01012de:	eb 15                	jmp    f01012f5 <vprintfmt+0x35e>
f01012e0:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01012e3:	89 ca                	mov    %ecx,%edx
f01012e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01012e8:	e8 39 fc ff ff       	call   f0100f26 <getuint>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01012f0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01012f5:	83 ec 0c             	sub    $0xc,%esp
f01012f8:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01012fc:	53                   	push   %ebx
f01012fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101300:	51                   	push   %ecx
f0101301:	52                   	push   %edx
f0101302:	50                   	push   %eax
f0101303:	89 fa                	mov    %edi,%edx
f0101305:	8b 45 08             	mov    0x8(%ebp),%eax
f0101308:	e8 6b fb ff ff       	call   f0100e78 <printnum>
			break;
f010130d:	83 c4 20             	add    $0x20,%esp
f0101310:	e9 a6 fc ff ff       	jmp    f0100fbb <vprintfmt+0x24>
f0101315:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101318:	83 ec 08             	sub    $0x8,%esp
f010131b:	57                   	push   %edi
f010131c:	52                   	push   %edx
f010131d:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101320:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101323:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101326:	e9 90 fc ff ff       	jmp    f0100fbb <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010132b:	83 ec 08             	sub    $0x8,%esp
f010132e:	57                   	push   %edi
f010132f:	6a 25                	push   $0x25
f0101331:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101334:	83 c4 10             	add    $0x10,%esp
f0101337:	eb 02                	jmp    f010133b <vprintfmt+0x3a4>
f0101339:	89 c6                	mov    %eax,%esi
f010133b:	8d 46 ff             	lea    -0x1(%esi),%eax
f010133e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101342:	75 f5                	jne    f0101339 <vprintfmt+0x3a2>
f0101344:	e9 72 fc ff ff       	jmp    f0100fbb <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0101349:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010134c:	5b                   	pop    %ebx
f010134d:	5e                   	pop    %esi
f010134e:	5f                   	pop    %edi
f010134f:	c9                   	leave  
f0101350:	c3                   	ret    

f0101351 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101351:	55                   	push   %ebp
f0101352:	89 e5                	mov    %esp,%ebp
f0101354:	83 ec 18             	sub    $0x18,%esp
f0101357:	8b 45 08             	mov    0x8(%ebp),%eax
f010135a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010135d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101360:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101364:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101367:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010136e:	85 c0                	test   %eax,%eax
f0101370:	74 26                	je     f0101398 <vsnprintf+0x47>
f0101372:	85 d2                	test   %edx,%edx
f0101374:	7e 29                	jle    f010139f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101376:	ff 75 14             	pushl  0x14(%ebp)
f0101379:	ff 75 10             	pushl  0x10(%ebp)
f010137c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010137f:	50                   	push   %eax
f0101380:	68 60 0f 10 f0       	push   $0xf0100f60
f0101385:	e8 0d fc ff ff       	call   f0100f97 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010138a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010138d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101390:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101393:	83 c4 10             	add    $0x10,%esp
f0101396:	eb 0c                	jmp    f01013a4 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101398:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010139d:	eb 05                	jmp    f01013a4 <vsnprintf+0x53>
f010139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01013a4:	c9                   	leave  
f01013a5:	c3                   	ret    

f01013a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01013a6:	55                   	push   %ebp
f01013a7:	89 e5                	mov    %esp,%ebp
f01013a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01013ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01013af:	50                   	push   %eax
f01013b0:	ff 75 10             	pushl  0x10(%ebp)
f01013b3:	ff 75 0c             	pushl  0xc(%ebp)
f01013b6:	ff 75 08             	pushl  0x8(%ebp)
f01013b9:	e8 93 ff ff ff       	call   f0101351 <vsnprintf>
	va_end(ap);

	return rc;
}
f01013be:	c9                   	leave  
f01013bf:	c3                   	ret    

f01013c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01013c0:	55                   	push   %ebp
f01013c1:	89 e5                	mov    %esp,%ebp
f01013c3:	57                   	push   %edi
f01013c4:	56                   	push   %esi
f01013c5:	53                   	push   %ebx
f01013c6:	83 ec 0c             	sub    $0xc,%esp
f01013c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01013cc:	85 c0                	test   %eax,%eax
f01013ce:	74 11                	je     f01013e1 <readline+0x21>
		cprintf("%s", prompt);
f01013d0:	83 ec 08             	sub    $0x8,%esp
f01013d3:	50                   	push   %eax
f01013d4:	68 6a 22 10 f0       	push   $0xf010226a
f01013d9:	e8 53 f7 ff ff       	call   f0100b31 <cprintf>
f01013de:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01013e1:	83 ec 0c             	sub    $0xc,%esp
f01013e4:	6a 00                	push   $0x0
f01013e6:	e8 dc f1 ff ff       	call   f01005c7 <iscons>
f01013eb:	89 c7                	mov    %eax,%edi
f01013ed:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01013f0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01013f5:	e8 bc f1 ff ff       	call   f01005b6 <getchar>
f01013fa:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01013fc:	85 c0                	test   %eax,%eax
f01013fe:	79 18                	jns    f0101418 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101400:	83 ec 08             	sub    $0x8,%esp
f0101403:	50                   	push   %eax
f0101404:	68 4c 24 10 f0       	push   $0xf010244c
f0101409:	e8 23 f7 ff ff       	call   f0100b31 <cprintf>
			return NULL;
f010140e:	83 c4 10             	add    $0x10,%esp
f0101411:	b8 00 00 00 00       	mov    $0x0,%eax
f0101416:	eb 6f                	jmp    f0101487 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101418:	83 f8 08             	cmp    $0x8,%eax
f010141b:	74 05                	je     f0101422 <readline+0x62>
f010141d:	83 f8 7f             	cmp    $0x7f,%eax
f0101420:	75 18                	jne    f010143a <readline+0x7a>
f0101422:	85 f6                	test   %esi,%esi
f0101424:	7e 14                	jle    f010143a <readline+0x7a>
			if (echoing)
f0101426:	85 ff                	test   %edi,%edi
f0101428:	74 0d                	je     f0101437 <readline+0x77>
				cputchar('\b');
f010142a:	83 ec 0c             	sub    $0xc,%esp
f010142d:	6a 08                	push   $0x8
f010142f:	e8 72 f1 ff ff       	call   f01005a6 <cputchar>
f0101434:	83 c4 10             	add    $0x10,%esp
			i--;
f0101437:	4e                   	dec    %esi
f0101438:	eb bb                	jmp    f01013f5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010143a:	83 fb 1f             	cmp    $0x1f,%ebx
f010143d:	7e 21                	jle    f0101460 <readline+0xa0>
f010143f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101445:	7f 19                	jg     f0101460 <readline+0xa0>
			if (echoing)
f0101447:	85 ff                	test   %edi,%edi
f0101449:	74 0c                	je     f0101457 <readline+0x97>
				cputchar(c);
f010144b:	83 ec 0c             	sub    $0xc,%esp
f010144e:	53                   	push   %ebx
f010144f:	e8 52 f1 ff ff       	call   f01005a6 <cputchar>
f0101454:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101457:	88 9e 40 95 11 f0    	mov    %bl,-0xfee6ac0(%esi)
f010145d:	46                   	inc    %esi
f010145e:	eb 95                	jmp    f01013f5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101460:	83 fb 0a             	cmp    $0xa,%ebx
f0101463:	74 05                	je     f010146a <readline+0xaa>
f0101465:	83 fb 0d             	cmp    $0xd,%ebx
f0101468:	75 8b                	jne    f01013f5 <readline+0x35>
			if (echoing)
f010146a:	85 ff                	test   %edi,%edi
f010146c:	74 0d                	je     f010147b <readline+0xbb>
				cputchar('\n');
f010146e:	83 ec 0c             	sub    $0xc,%esp
f0101471:	6a 0a                	push   $0xa
f0101473:	e8 2e f1 ff ff       	call   f01005a6 <cputchar>
f0101478:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010147b:	c6 86 40 95 11 f0 00 	movb   $0x0,-0xfee6ac0(%esi)
			return buf;
f0101482:	b8 40 95 11 f0       	mov    $0xf0119540,%eax
		}
	}
}
f0101487:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010148a:	5b                   	pop    %ebx
f010148b:	5e                   	pop    %esi
f010148c:	5f                   	pop    %edi
f010148d:	c9                   	leave  
f010148e:	c3                   	ret    
	...

f0101490 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101496:	80 3a 00             	cmpb   $0x0,(%edx)
f0101499:	74 0e                	je     f01014a9 <strlen+0x19>
f010149b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01014a0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01014a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01014a5:	75 f9                	jne    f01014a0 <strlen+0x10>
f01014a7:	eb 05                	jmp    f01014ae <strlen+0x1e>
f01014a9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01014ae:	c9                   	leave  
f01014af:	c3                   	ret    

f01014b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01014b9:	85 d2                	test   %edx,%edx
f01014bb:	74 17                	je     f01014d4 <strnlen+0x24>
f01014bd:	80 39 00             	cmpb   $0x0,(%ecx)
f01014c0:	74 19                	je     f01014db <strnlen+0x2b>
f01014c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01014c7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01014c8:	39 d0                	cmp    %edx,%eax
f01014ca:	74 14                	je     f01014e0 <strnlen+0x30>
f01014cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01014d0:	75 f5                	jne    f01014c7 <strnlen+0x17>
f01014d2:	eb 0c                	jmp    f01014e0 <strnlen+0x30>
f01014d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d9:	eb 05                	jmp    f01014e0 <strnlen+0x30>
f01014db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01014e0:	c9                   	leave  
f01014e1:	c3                   	ret    

f01014e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01014e2:	55                   	push   %ebp
f01014e3:	89 e5                	mov    %esp,%ebp
f01014e5:	53                   	push   %ebx
f01014e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01014ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01014f1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01014f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01014f7:	42                   	inc    %edx
f01014f8:	84 c9                	test   %cl,%cl
f01014fa:	75 f5                	jne    f01014f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01014fc:	5b                   	pop    %ebx
f01014fd:	c9                   	leave  
f01014fe:	c3                   	ret    

f01014ff <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014ff:	55                   	push   %ebp
f0101500:	89 e5                	mov    %esp,%ebp
f0101502:	53                   	push   %ebx
f0101503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101506:	53                   	push   %ebx
f0101507:	e8 84 ff ff ff       	call   f0101490 <strlen>
f010150c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010150f:	ff 75 0c             	pushl  0xc(%ebp)
f0101512:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101515:	50                   	push   %eax
f0101516:	e8 c7 ff ff ff       	call   f01014e2 <strcpy>
	return dst;
}
f010151b:	89 d8                	mov    %ebx,%eax
f010151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101520:	c9                   	leave  
f0101521:	c3                   	ret    

f0101522 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101522:	55                   	push   %ebp
f0101523:	89 e5                	mov    %esp,%ebp
f0101525:	56                   	push   %esi
f0101526:	53                   	push   %ebx
f0101527:	8b 45 08             	mov    0x8(%ebp),%eax
f010152a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010152d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101530:	85 f6                	test   %esi,%esi
f0101532:	74 15                	je     f0101549 <strncpy+0x27>
f0101534:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101539:	8a 1a                	mov    (%edx),%bl
f010153b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010153e:	80 3a 01             	cmpb   $0x1,(%edx)
f0101541:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101544:	41                   	inc    %ecx
f0101545:	39 ce                	cmp    %ecx,%esi
f0101547:	77 f0                	ja     f0101539 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101549:	5b                   	pop    %ebx
f010154a:	5e                   	pop    %esi
f010154b:	c9                   	leave  
f010154c:	c3                   	ret    

f010154d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010154d:	55                   	push   %ebp
f010154e:	89 e5                	mov    %esp,%ebp
f0101550:	57                   	push   %edi
f0101551:	56                   	push   %esi
f0101552:	53                   	push   %ebx
f0101553:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101559:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010155c:	85 f6                	test   %esi,%esi
f010155e:	74 32                	je     f0101592 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0101560:	83 fe 01             	cmp    $0x1,%esi
f0101563:	74 22                	je     f0101587 <strlcpy+0x3a>
f0101565:	8a 0b                	mov    (%ebx),%cl
f0101567:	84 c9                	test   %cl,%cl
f0101569:	74 20                	je     f010158b <strlcpy+0x3e>
f010156b:	89 f8                	mov    %edi,%eax
f010156d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0101572:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101575:	88 08                	mov    %cl,(%eax)
f0101577:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101578:	39 f2                	cmp    %esi,%edx
f010157a:	74 11                	je     f010158d <strlcpy+0x40>
f010157c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0101580:	42                   	inc    %edx
f0101581:	84 c9                	test   %cl,%cl
f0101583:	75 f0                	jne    f0101575 <strlcpy+0x28>
f0101585:	eb 06                	jmp    f010158d <strlcpy+0x40>
f0101587:	89 f8                	mov    %edi,%eax
f0101589:	eb 02                	jmp    f010158d <strlcpy+0x40>
f010158b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010158d:	c6 00 00             	movb   $0x0,(%eax)
f0101590:	eb 02                	jmp    f0101594 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101592:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0101594:	29 f8                	sub    %edi,%eax
}
f0101596:	5b                   	pop    %ebx
f0101597:	5e                   	pop    %esi
f0101598:	5f                   	pop    %edi
f0101599:	c9                   	leave  
f010159a:	c3                   	ret    

f010159b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010159b:	55                   	push   %ebp
f010159c:	89 e5                	mov    %esp,%ebp
f010159e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01015a4:	8a 01                	mov    (%ecx),%al
f01015a6:	84 c0                	test   %al,%al
f01015a8:	74 10                	je     f01015ba <strcmp+0x1f>
f01015aa:	3a 02                	cmp    (%edx),%al
f01015ac:	75 0c                	jne    f01015ba <strcmp+0x1f>
		p++, q++;
f01015ae:	41                   	inc    %ecx
f01015af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01015b0:	8a 01                	mov    (%ecx),%al
f01015b2:	84 c0                	test   %al,%al
f01015b4:	74 04                	je     f01015ba <strcmp+0x1f>
f01015b6:	3a 02                	cmp    (%edx),%al
f01015b8:	74 f4                	je     f01015ae <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01015ba:	0f b6 c0             	movzbl %al,%eax
f01015bd:	0f b6 12             	movzbl (%edx),%edx
f01015c0:	29 d0                	sub    %edx,%eax
}
f01015c2:	c9                   	leave  
f01015c3:	c3                   	ret    

f01015c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	53                   	push   %ebx
f01015c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01015cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01015d1:	85 c0                	test   %eax,%eax
f01015d3:	74 1b                	je     f01015f0 <strncmp+0x2c>
f01015d5:	8a 1a                	mov    (%edx),%bl
f01015d7:	84 db                	test   %bl,%bl
f01015d9:	74 24                	je     f01015ff <strncmp+0x3b>
f01015db:	3a 19                	cmp    (%ecx),%bl
f01015dd:	75 20                	jne    f01015ff <strncmp+0x3b>
f01015df:	48                   	dec    %eax
f01015e0:	74 15                	je     f01015f7 <strncmp+0x33>
		n--, p++, q++;
f01015e2:	42                   	inc    %edx
f01015e3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01015e4:	8a 1a                	mov    (%edx),%bl
f01015e6:	84 db                	test   %bl,%bl
f01015e8:	74 15                	je     f01015ff <strncmp+0x3b>
f01015ea:	3a 19                	cmp    (%ecx),%bl
f01015ec:	74 f1                	je     f01015df <strncmp+0x1b>
f01015ee:	eb 0f                	jmp    f01015ff <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01015f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f5:	eb 05                	jmp    f01015fc <strncmp+0x38>
f01015f7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01015fc:	5b                   	pop    %ebx
f01015fd:	c9                   	leave  
f01015fe:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01015ff:	0f b6 02             	movzbl (%edx),%eax
f0101602:	0f b6 11             	movzbl (%ecx),%edx
f0101605:	29 d0                	sub    %edx,%eax
f0101607:	eb f3                	jmp    f01015fc <strncmp+0x38>

f0101609 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101609:	55                   	push   %ebp
f010160a:	89 e5                	mov    %esp,%ebp
f010160c:	8b 45 08             	mov    0x8(%ebp),%eax
f010160f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101612:	8a 10                	mov    (%eax),%dl
f0101614:	84 d2                	test   %dl,%dl
f0101616:	74 18                	je     f0101630 <strchr+0x27>
		if (*s == c)
f0101618:	38 ca                	cmp    %cl,%dl
f010161a:	75 06                	jne    f0101622 <strchr+0x19>
f010161c:	eb 17                	jmp    f0101635 <strchr+0x2c>
f010161e:	38 ca                	cmp    %cl,%dl
f0101620:	74 13                	je     f0101635 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101622:	40                   	inc    %eax
f0101623:	8a 10                	mov    (%eax),%dl
f0101625:	84 d2                	test   %dl,%dl
f0101627:	75 f5                	jne    f010161e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0101629:	b8 00 00 00 00       	mov    $0x0,%eax
f010162e:	eb 05                	jmp    f0101635 <strchr+0x2c>
f0101630:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101635:	c9                   	leave  
f0101636:	c3                   	ret    

f0101637 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101637:	55                   	push   %ebp
f0101638:	89 e5                	mov    %esp,%ebp
f010163a:	8b 45 08             	mov    0x8(%ebp),%eax
f010163d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101640:	8a 10                	mov    (%eax),%dl
f0101642:	84 d2                	test   %dl,%dl
f0101644:	74 11                	je     f0101657 <strfind+0x20>
		if (*s == c)
f0101646:	38 ca                	cmp    %cl,%dl
f0101648:	75 06                	jne    f0101650 <strfind+0x19>
f010164a:	eb 0b                	jmp    f0101657 <strfind+0x20>
f010164c:	38 ca                	cmp    %cl,%dl
f010164e:	74 07                	je     f0101657 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101650:	40                   	inc    %eax
f0101651:	8a 10                	mov    (%eax),%dl
f0101653:	84 d2                	test   %dl,%dl
f0101655:	75 f5                	jne    f010164c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0101657:	c9                   	leave  
f0101658:	c3                   	ret    

f0101659 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101659:	55                   	push   %ebp
f010165a:	89 e5                	mov    %esp,%ebp
f010165c:	57                   	push   %edi
f010165d:	56                   	push   %esi
f010165e:	53                   	push   %ebx
f010165f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101662:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101665:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101668:	85 c9                	test   %ecx,%ecx
f010166a:	74 30                	je     f010169c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010166c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101672:	75 25                	jne    f0101699 <memset+0x40>
f0101674:	f6 c1 03             	test   $0x3,%cl
f0101677:	75 20                	jne    f0101699 <memset+0x40>
		c &= 0xFF;
f0101679:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010167c:	89 d3                	mov    %edx,%ebx
f010167e:	c1 e3 08             	shl    $0x8,%ebx
f0101681:	89 d6                	mov    %edx,%esi
f0101683:	c1 e6 18             	shl    $0x18,%esi
f0101686:	89 d0                	mov    %edx,%eax
f0101688:	c1 e0 10             	shl    $0x10,%eax
f010168b:	09 f0                	or     %esi,%eax
f010168d:	09 d0                	or     %edx,%eax
f010168f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101691:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101694:	fc                   	cld    
f0101695:	f3 ab                	rep stos %eax,%es:(%edi)
f0101697:	eb 03                	jmp    f010169c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101699:	fc                   	cld    
f010169a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010169c:	89 f8                	mov    %edi,%eax
f010169e:	5b                   	pop    %ebx
f010169f:	5e                   	pop    %esi
f01016a0:	5f                   	pop    %edi
f01016a1:	c9                   	leave  
f01016a2:	c3                   	ret    

f01016a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01016a3:	55                   	push   %ebp
f01016a4:	89 e5                	mov    %esp,%ebp
f01016a6:	57                   	push   %edi
f01016a7:	56                   	push   %esi
f01016a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ab:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01016b1:	39 c6                	cmp    %eax,%esi
f01016b3:	73 34                	jae    f01016e9 <memmove+0x46>
f01016b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01016b8:	39 d0                	cmp    %edx,%eax
f01016ba:	73 2d                	jae    f01016e9 <memmove+0x46>
		s += n;
		d += n;
f01016bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016bf:	f6 c2 03             	test   $0x3,%dl
f01016c2:	75 1b                	jne    f01016df <memmove+0x3c>
f01016c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01016ca:	75 13                	jne    f01016df <memmove+0x3c>
f01016cc:	f6 c1 03             	test   $0x3,%cl
f01016cf:	75 0e                	jne    f01016df <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01016d1:	83 ef 04             	sub    $0x4,%edi
f01016d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01016d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01016da:	fd                   	std    
f01016db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01016dd:	eb 07                	jmp    f01016e6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01016df:	4f                   	dec    %edi
f01016e0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01016e3:	fd                   	std    
f01016e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01016e6:	fc                   	cld    
f01016e7:	eb 20                	jmp    f0101709 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01016ef:	75 13                	jne    f0101704 <memmove+0x61>
f01016f1:	a8 03                	test   $0x3,%al
f01016f3:	75 0f                	jne    f0101704 <memmove+0x61>
f01016f5:	f6 c1 03             	test   $0x3,%cl
f01016f8:	75 0a                	jne    f0101704 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01016fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01016fd:	89 c7                	mov    %eax,%edi
f01016ff:	fc                   	cld    
f0101700:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101702:	eb 05                	jmp    f0101709 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101704:	89 c7                	mov    %eax,%edi
f0101706:	fc                   	cld    
f0101707:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101709:	5e                   	pop    %esi
f010170a:	5f                   	pop    %edi
f010170b:	c9                   	leave  
f010170c:	c3                   	ret    

f010170d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010170d:	55                   	push   %ebp
f010170e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101710:	ff 75 10             	pushl  0x10(%ebp)
f0101713:	ff 75 0c             	pushl  0xc(%ebp)
f0101716:	ff 75 08             	pushl  0x8(%ebp)
f0101719:	e8 85 ff ff ff       	call   f01016a3 <memmove>
}
f010171e:	c9                   	leave  
f010171f:	c3                   	ret    

f0101720 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101720:	55                   	push   %ebp
f0101721:	89 e5                	mov    %esp,%ebp
f0101723:	57                   	push   %edi
f0101724:	56                   	push   %esi
f0101725:	53                   	push   %ebx
f0101726:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101729:	8b 75 0c             	mov    0xc(%ebp),%esi
f010172c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010172f:	85 ff                	test   %edi,%edi
f0101731:	74 32                	je     f0101765 <memcmp+0x45>
		if (*s1 != *s2)
f0101733:	8a 03                	mov    (%ebx),%al
f0101735:	8a 0e                	mov    (%esi),%cl
f0101737:	38 c8                	cmp    %cl,%al
f0101739:	74 19                	je     f0101754 <memcmp+0x34>
f010173b:	eb 0d                	jmp    f010174a <memcmp+0x2a>
f010173d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0101741:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0101745:	42                   	inc    %edx
f0101746:	38 c8                	cmp    %cl,%al
f0101748:	74 10                	je     f010175a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010174a:	0f b6 c0             	movzbl %al,%eax
f010174d:	0f b6 c9             	movzbl %cl,%ecx
f0101750:	29 c8                	sub    %ecx,%eax
f0101752:	eb 16                	jmp    f010176a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101754:	4f                   	dec    %edi
f0101755:	ba 00 00 00 00       	mov    $0x0,%edx
f010175a:	39 fa                	cmp    %edi,%edx
f010175c:	75 df                	jne    f010173d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010175e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101763:	eb 05                	jmp    f010176a <memcmp+0x4a>
f0101765:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010176a:	5b                   	pop    %ebx
f010176b:	5e                   	pop    %esi
f010176c:	5f                   	pop    %edi
f010176d:	c9                   	leave  
f010176e:	c3                   	ret    

f010176f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010176f:	55                   	push   %ebp
f0101770:	89 e5                	mov    %esp,%ebp
f0101772:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101775:	89 c2                	mov    %eax,%edx
f0101777:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010177a:	39 d0                	cmp    %edx,%eax
f010177c:	73 12                	jae    f0101790 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010177e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0101781:	38 08                	cmp    %cl,(%eax)
f0101783:	75 06                	jne    f010178b <memfind+0x1c>
f0101785:	eb 09                	jmp    f0101790 <memfind+0x21>
f0101787:	38 08                	cmp    %cl,(%eax)
f0101789:	74 05                	je     f0101790 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010178b:	40                   	inc    %eax
f010178c:	39 c2                	cmp    %eax,%edx
f010178e:	77 f7                	ja     f0101787 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101790:	c9                   	leave  
f0101791:	c3                   	ret    

f0101792 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101792:	55                   	push   %ebp
f0101793:	89 e5                	mov    %esp,%ebp
f0101795:	57                   	push   %edi
f0101796:	56                   	push   %esi
f0101797:	53                   	push   %ebx
f0101798:	8b 55 08             	mov    0x8(%ebp),%edx
f010179b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010179e:	eb 01                	jmp    f01017a1 <strtol+0xf>
		s++;
f01017a0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01017a1:	8a 02                	mov    (%edx),%al
f01017a3:	3c 20                	cmp    $0x20,%al
f01017a5:	74 f9                	je     f01017a0 <strtol+0xe>
f01017a7:	3c 09                	cmp    $0x9,%al
f01017a9:	74 f5                	je     f01017a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01017ab:	3c 2b                	cmp    $0x2b,%al
f01017ad:	75 08                	jne    f01017b7 <strtol+0x25>
		s++;
f01017af:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01017b0:	bf 00 00 00 00       	mov    $0x0,%edi
f01017b5:	eb 13                	jmp    f01017ca <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01017b7:	3c 2d                	cmp    $0x2d,%al
f01017b9:	75 0a                	jne    f01017c5 <strtol+0x33>
		s++, neg = 1;
f01017bb:	8d 52 01             	lea    0x1(%edx),%edx
f01017be:	bf 01 00 00 00       	mov    $0x1,%edi
f01017c3:	eb 05                	jmp    f01017ca <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01017c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01017ca:	85 db                	test   %ebx,%ebx
f01017cc:	74 05                	je     f01017d3 <strtol+0x41>
f01017ce:	83 fb 10             	cmp    $0x10,%ebx
f01017d1:	75 28                	jne    f01017fb <strtol+0x69>
f01017d3:	8a 02                	mov    (%edx),%al
f01017d5:	3c 30                	cmp    $0x30,%al
f01017d7:	75 10                	jne    f01017e9 <strtol+0x57>
f01017d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01017dd:	75 0a                	jne    f01017e9 <strtol+0x57>
		s += 2, base = 16;
f01017df:	83 c2 02             	add    $0x2,%edx
f01017e2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01017e7:	eb 12                	jmp    f01017fb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01017e9:	85 db                	test   %ebx,%ebx
f01017eb:	75 0e                	jne    f01017fb <strtol+0x69>
f01017ed:	3c 30                	cmp    $0x30,%al
f01017ef:	75 05                	jne    f01017f6 <strtol+0x64>
		s++, base = 8;
f01017f1:	42                   	inc    %edx
f01017f2:	b3 08                	mov    $0x8,%bl
f01017f4:	eb 05                	jmp    f01017fb <strtol+0x69>
	else if (base == 0)
		base = 10;
f01017f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01017fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101800:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101802:	8a 0a                	mov    (%edx),%cl
f0101804:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101807:	80 fb 09             	cmp    $0x9,%bl
f010180a:	77 08                	ja     f0101814 <strtol+0x82>
			dig = *s - '0';
f010180c:	0f be c9             	movsbl %cl,%ecx
f010180f:	83 e9 30             	sub    $0x30,%ecx
f0101812:	eb 1e                	jmp    f0101832 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0101814:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101817:	80 fb 19             	cmp    $0x19,%bl
f010181a:	77 08                	ja     f0101824 <strtol+0x92>
			dig = *s - 'a' + 10;
f010181c:	0f be c9             	movsbl %cl,%ecx
f010181f:	83 e9 57             	sub    $0x57,%ecx
f0101822:	eb 0e                	jmp    f0101832 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0101824:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101827:	80 fb 19             	cmp    $0x19,%bl
f010182a:	77 13                	ja     f010183f <strtol+0xad>
			dig = *s - 'A' + 10;
f010182c:	0f be c9             	movsbl %cl,%ecx
f010182f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101832:	39 f1                	cmp    %esi,%ecx
f0101834:	7d 0d                	jge    f0101843 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0101836:	42                   	inc    %edx
f0101837:	0f af c6             	imul   %esi,%eax
f010183a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010183d:	eb c3                	jmp    f0101802 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010183f:	89 c1                	mov    %eax,%ecx
f0101841:	eb 02                	jmp    f0101845 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101843:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101845:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101849:	74 05                	je     f0101850 <strtol+0xbe>
		*endptr = (char *) s;
f010184b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010184e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101850:	85 ff                	test   %edi,%edi
f0101852:	74 04                	je     f0101858 <strtol+0xc6>
f0101854:	89 c8                	mov    %ecx,%eax
f0101856:	f7 d8                	neg    %eax
}
f0101858:	5b                   	pop    %ebx
f0101859:	5e                   	pop    %esi
f010185a:	5f                   	pop    %edi
f010185b:	c9                   	leave  
f010185c:	c3                   	ret    
f010185d:	00 00                	add    %al,(%eax)
	...

f0101860 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0101860:	55                   	push   %ebp
f0101861:	89 e5                	mov    %esp,%ebp
f0101863:	57                   	push   %edi
f0101864:	56                   	push   %esi
f0101865:	83 ec 10             	sub    $0x10,%esp
f0101868:	8b 7d 08             	mov    0x8(%ebp),%edi
f010186b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010186e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0101871:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0101874:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101877:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010187a:	85 c0                	test   %eax,%eax
f010187c:	75 2e                	jne    f01018ac <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010187e:	39 f1                	cmp    %esi,%ecx
f0101880:	77 5a                	ja     f01018dc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101882:	85 c9                	test   %ecx,%ecx
f0101884:	75 0b                	jne    f0101891 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101886:	b8 01 00 00 00       	mov    $0x1,%eax
f010188b:	31 d2                	xor    %edx,%edx
f010188d:	f7 f1                	div    %ecx
f010188f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101891:	31 d2                	xor    %edx,%edx
f0101893:	89 f0                	mov    %esi,%eax
f0101895:	f7 f1                	div    %ecx
f0101897:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101899:	89 f8                	mov    %edi,%eax
f010189b:	f7 f1                	div    %ecx
f010189d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010189f:	89 f8                	mov    %edi,%eax
f01018a1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01018a3:	83 c4 10             	add    $0x10,%esp
f01018a6:	5e                   	pop    %esi
f01018a7:	5f                   	pop    %edi
f01018a8:	c9                   	leave  
f01018a9:	c3                   	ret    
f01018aa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01018ac:	39 f0                	cmp    %esi,%eax
f01018ae:	77 1c                	ja     f01018cc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01018b0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01018b3:	83 f7 1f             	xor    $0x1f,%edi
f01018b6:	75 3c                	jne    f01018f4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01018b8:	39 f0                	cmp    %esi,%eax
f01018ba:	0f 82 90 00 00 00    	jb     f0101950 <__udivdi3+0xf0>
f01018c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01018c3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01018c6:	0f 86 84 00 00 00    	jbe    f0101950 <__udivdi3+0xf0>
f01018cc:	31 f6                	xor    %esi,%esi
f01018ce:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01018d0:	89 f8                	mov    %edi,%eax
f01018d2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	5e                   	pop    %esi
f01018d8:	5f                   	pop    %edi
f01018d9:	c9                   	leave  
f01018da:	c3                   	ret    
f01018db:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01018dc:	89 f2                	mov    %esi,%edx
f01018de:	89 f8                	mov    %edi,%eax
f01018e0:	f7 f1                	div    %ecx
f01018e2:	89 c7                	mov    %eax,%edi
f01018e4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01018e6:	89 f8                	mov    %edi,%eax
f01018e8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01018ea:	83 c4 10             	add    $0x10,%esp
f01018ed:	5e                   	pop    %esi
f01018ee:	5f                   	pop    %edi
f01018ef:	c9                   	leave  
f01018f0:	c3                   	ret    
f01018f1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01018f4:	89 f9                	mov    %edi,%ecx
f01018f6:	d3 e0                	shl    %cl,%eax
f01018f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01018fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0101900:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0101902:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101905:	88 c1                	mov    %al,%cl
f0101907:	d3 ea                	shr    %cl,%edx
f0101909:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010190c:	09 ca                	or     %ecx,%edx
f010190e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0101911:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101914:	89 f9                	mov    %edi,%ecx
f0101916:	d3 e2                	shl    %cl,%edx
f0101918:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f010191b:	89 f2                	mov    %esi,%edx
f010191d:	88 c1                	mov    %al,%cl
f010191f:	d3 ea                	shr    %cl,%edx
f0101921:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0101924:	89 f2                	mov    %esi,%edx
f0101926:	89 f9                	mov    %edi,%ecx
f0101928:	d3 e2                	shl    %cl,%edx
f010192a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f010192d:	88 c1                	mov    %al,%cl
f010192f:	d3 ee                	shr    %cl,%esi
f0101931:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101933:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101936:	89 f0                	mov    %esi,%eax
f0101938:	89 ca                	mov    %ecx,%edx
f010193a:	f7 75 ec             	divl   -0x14(%ebp)
f010193d:	89 d1                	mov    %edx,%ecx
f010193f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101941:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101944:	39 d1                	cmp    %edx,%ecx
f0101946:	72 28                	jb     f0101970 <__udivdi3+0x110>
f0101948:	74 1a                	je     f0101964 <__udivdi3+0x104>
f010194a:	89 f7                	mov    %esi,%edi
f010194c:	31 f6                	xor    %esi,%esi
f010194e:	eb 80                	jmp    f01018d0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101950:	31 f6                	xor    %esi,%esi
f0101952:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101957:	89 f8                	mov    %edi,%eax
f0101959:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	5e                   	pop    %esi
f010195f:	5f                   	pop    %edi
f0101960:	c9                   	leave  
f0101961:	c3                   	ret    
f0101962:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0101964:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101967:	89 f9                	mov    %edi,%ecx
f0101969:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010196b:	39 c2                	cmp    %eax,%edx
f010196d:	73 db                	jae    f010194a <__udivdi3+0xea>
f010196f:	90                   	nop
		{
		  q0--;
f0101970:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101973:	31 f6                	xor    %esi,%esi
f0101975:	e9 56 ff ff ff       	jmp    f01018d0 <__udivdi3+0x70>
	...

f010197c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f010197c:	55                   	push   %ebp
f010197d:	89 e5                	mov    %esp,%ebp
f010197f:	57                   	push   %edi
f0101980:	56                   	push   %esi
f0101981:	83 ec 20             	sub    $0x20,%esp
f0101984:	8b 45 08             	mov    0x8(%ebp),%eax
f0101987:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010198a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010198d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0101990:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101993:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101996:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0101999:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010199b:	85 ff                	test   %edi,%edi
f010199d:	75 15                	jne    f01019b4 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010199f:	39 f1                	cmp    %esi,%ecx
f01019a1:	0f 86 99 00 00 00    	jbe    f0101a40 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01019a7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f01019a9:	89 d0                	mov    %edx,%eax
f01019ab:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01019ad:	83 c4 20             	add    $0x20,%esp
f01019b0:	5e                   	pop    %esi
f01019b1:	5f                   	pop    %edi
f01019b2:	c9                   	leave  
f01019b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01019b4:	39 f7                	cmp    %esi,%edi
f01019b6:	0f 87 a4 00 00 00    	ja     f0101a60 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01019bc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f01019bf:	83 f0 1f             	xor    $0x1f,%eax
f01019c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01019c5:	0f 84 a1 00 00 00    	je     f0101a6c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01019cb:	89 f8                	mov    %edi,%eax
f01019cd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01019d0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01019d2:	bf 20 00 00 00       	mov    $0x20,%edi
f01019d7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f01019da:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01019dd:	89 f9                	mov    %edi,%ecx
f01019df:	d3 ea                	shr    %cl,%edx
f01019e1:	09 c2                	or     %eax,%edx
f01019e3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f01019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01019e9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01019ec:	d3 e0                	shl    %cl,%eax
f01019ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01019f1:	89 f2                	mov    %esi,%edx
f01019f3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01019f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01019f8:	d3 e0                	shl    %cl,%eax
f01019fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01019fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a00:	89 f9                	mov    %edi,%ecx
f0101a02:	d3 e8                	shr    %cl,%eax
f0101a04:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101a06:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101a08:	89 f2                	mov    %esi,%edx
f0101a0a:	f7 75 f0             	divl   -0x10(%ebp)
f0101a0d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101a0f:	f7 65 f4             	mull   -0xc(%ebp)
f0101a12:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101a15:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101a17:	39 d6                	cmp    %edx,%esi
f0101a19:	72 71                	jb     f0101a8c <__umoddi3+0x110>
f0101a1b:	74 7f                	je     f0101a9c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101a20:	29 c8                	sub    %ecx,%eax
f0101a22:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0101a24:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0101a27:	d3 e8                	shr    %cl,%eax
f0101a29:	89 f2                	mov    %esi,%edx
f0101a2b:	89 f9                	mov    %edi,%ecx
f0101a2d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0101a2f:	09 d0                	or     %edx,%eax
f0101a31:	89 f2                	mov    %esi,%edx
f0101a33:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0101a36:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101a38:	83 c4 20             	add    $0x20,%esp
f0101a3b:	5e                   	pop    %esi
f0101a3c:	5f                   	pop    %edi
f0101a3d:	c9                   	leave  
f0101a3e:	c3                   	ret    
f0101a3f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101a40:	85 c9                	test   %ecx,%ecx
f0101a42:	75 0b                	jne    f0101a4f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101a44:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a49:	31 d2                	xor    %edx,%edx
f0101a4b:	f7 f1                	div    %ecx
f0101a4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101a4f:	89 f0                	mov    %esi,%eax
f0101a51:	31 d2                	xor    %edx,%edx
f0101a53:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101a58:	f7 f1                	div    %ecx
f0101a5a:	e9 4a ff ff ff       	jmp    f01019a9 <__umoddi3+0x2d>
f0101a5f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101a60:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101a62:	83 c4 20             	add    $0x20,%esp
f0101a65:	5e                   	pop    %esi
f0101a66:	5f                   	pop    %edi
f0101a67:	c9                   	leave  
f0101a68:	c3                   	ret    
f0101a69:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101a6c:	39 f7                	cmp    %esi,%edi
f0101a6e:	72 05                	jb     f0101a75 <__umoddi3+0xf9>
f0101a70:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101a73:	77 0c                	ja     f0101a81 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101a75:	89 f2                	mov    %esi,%edx
f0101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101a7a:	29 c8                	sub    %ecx,%eax
f0101a7c:	19 fa                	sbb    %edi,%edx
f0101a7e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0101a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101a84:	83 c4 20             	add    $0x20,%esp
f0101a87:	5e                   	pop    %esi
f0101a88:	5f                   	pop    %edi
f0101a89:	c9                   	leave  
f0101a8a:	c3                   	ret    
f0101a8b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101a8c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101a8f:	89 c1                	mov    %eax,%ecx
f0101a91:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0101a94:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0101a97:	eb 84                	jmp    f0101a1d <__umoddi3+0xa1>
f0101a99:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101a9c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101a9f:	72 eb                	jb     f0101a8c <__umoddi3+0x110>
f0101aa1:	89 f2                	mov    %esi,%edx
f0101aa3:	e9 75 ff ff ff       	jmp    f0101a1d <__umoddi3+0xa1>
