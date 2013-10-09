
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
f0100058:	e8 9c 37 00 00       	call   f01037f9 <memset>

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
f010006a:	68 60 3c 10 f0       	push   $0xf0103c60
f010006f:	e8 55 2c 00 00       	call   f0102cc9 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 e4 15 00 00       	call   f010165d <mem_init>
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
f01000b0:	68 7b 3c 10 f0       	push   $0xf0103c7b
f01000b5:	e8 0f 2c 00 00       	call   f0102cc9 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 df 2b 00 00       	call   f0102ca3 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 71 3f 10 f0 	movl   $0xf0103f71,(%esp)
f01000cb:	e8 f9 2b 00 00       	call   f0102cc9 <cprintf>
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
f01000f2:	68 93 3c 10 f0       	push   $0xf0103c93
f01000f7:	e8 cd 2b 00 00       	call   f0102cc9 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 9b 2b 00 00       	call   f0102ca3 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 71 3f 10 f0 	movl   $0xf0103f71,(%esp)
f010010f:	e8 b5 2b 00 00       	call   f0102cc9 <cprintf>
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
f01002fd:	e8 41 35 00 00       	call   f0103843 <memmove>
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
f010039c:	8a 82 e0 3c 10 f0    	mov    -0xfefc320(%edx),%al
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
f01003d8:	0f b6 82 e0 3c 10 f0 	movzbl -0xfefc320(%edx),%eax
f01003df:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a e0 3d 10 f0 	movzbl -0xfefc220(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d e0 3e 10 f0 	mov    -0xfefc120(,%ecx,4),%ecx
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
f0100430:	68 ad 3c 10 f0       	push   $0xf0103cad
f0100435:	e8 8f 28 00 00       	call   f0102cc9 <cprintf>
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
f0100591:	68 b9 3c 10 f0       	push   $0xf0103cb9
f0100596:	e8 2e 27 00 00       	call   f0102cc9 <cprintf>
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
f01005da:	68 f0 3e 10 f0       	push   $0xf0103ef0
f01005df:	e8 e5 26 00 00       	call   f0102cc9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 28 41 10 f0       	push   $0xf0104128
f01005f1:	e8 d3 26 00 00       	call   f0102cc9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 50 41 10 f0       	push   $0xf0104150
f0100608:	e8 bc 26 00 00       	call   f0102cc9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 48 3c 10 00       	push   $0x103c48
f0100615:	68 48 3c 10 f0       	push   $0xf0103c48
f010061a:	68 74 41 10 f0       	push   $0xf0104174
f010061f:	e8 a5 26 00 00       	call   f0102cc9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 f3 11 00       	push   $0x11f300
f010062c:	68 00 f3 11 f0       	push   $0xf011f300
f0100631:	68 98 41 10 f0       	push   $0xf0104198
f0100636:	e8 8e 26 00 00       	call   f0102cc9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 f9 11 00       	push   $0x11f950
f0100643:	68 50 f9 11 f0       	push   $0xf011f950
f0100648:	68 bc 41 10 f0       	push   $0xf01041bc
f010064d:	e8 77 26 00 00       	call   f0102cc9 <cprintf>
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
f0100674:	68 e0 41 10 f0       	push   $0xf01041e0
f0100679:	e8 4b 26 00 00       	call   f0102cc9 <cprintf>
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
f0100694:	ff b3 c4 46 10 f0    	pushl  -0xfefb93c(%ebx)
f010069a:	ff b3 c0 46 10 f0    	pushl  -0xfefb940(%ebx)
f01006a0:	68 09 3f 10 f0       	push   $0xf0103f09
f01006a5:	e8 1f 26 00 00       	call   f0102cc9 <cprintf>
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
f01006ce:	68 0c 42 10 f0       	push   $0xf010420c
f01006d3:	e8 f1 25 00 00       	call   f0102cc9 <cprintf>
        cprintf("Example: kernelpd 0x01\n");
f01006d8:	c7 04 24 12 3f 10 f0 	movl   $0xf0103f12,(%esp)
f01006df:	e8 e5 25 00 00       	call   f0102cc9 <cprintf>
        cprintf("         show kernel page directory[1] infomation \n");
f01006e4:	c7 04 24 38 42 10 f0 	movl   $0xf0104238,(%esp)
f01006eb:	e8 d9 25 00 00       	call   f0102cc9 <cprintf>
f01006f0:	83 c4 10             	add    $0x10,%esp
f01006f3:	eb 48                	jmp    f010073d <mon_kernelpd+0x7e>
    } else {
        uint32_t id = strtol(argv[1], NULL, 0);
f01006f5:	83 ec 04             	sub    $0x4,%esp
f01006f8:	6a 00                	push   $0x0
f01006fa:	6a 00                	push   $0x0
f01006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01006ff:	ff 70 04             	pushl  0x4(%eax)
f0100702:	e8 2b 32 00 00       	call   f0103932 <strtol>
        if (0 > id || id >= 1024) {
f0100707:	83 c4 10             	add    $0x10,%esp
f010070a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010070f:	76 12                	jbe    f0100723 <mon_kernelpd+0x64>
            cprintf("out of entry num, it should be in [0, 1024)\n");
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	68 6c 42 10 f0       	push   $0xf010426c
f0100719:	e8 ab 25 00 00       	call   f0102cc9 <cprintf>
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	eb 1a                	jmp    f010073d <mon_kernelpd+0x7e>
        } else {
            cprintf("pgdir[%d] = 0x%08x\n", id, (uint32_t)kern_pgdir[id]);
f0100723:	83 ec 04             	sub    $0x4,%esp
f0100726:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f010072c:	ff 34 82             	pushl  (%edx,%eax,4)
f010072f:	50                   	push   %eax
f0100730:	68 2a 3f 10 f0       	push   $0xf0103f2a
f0100735:	e8 8f 25 00 00       	call   f0102cc9 <cprintf>
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
f0100759:	68 9c 42 10 f0       	push   $0xf010429c
f010075e:	e8 66 25 00 00       	call   f0102cc9 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100763:	c7 04 24 d0 42 10 f0 	movl   $0xf01042d0,(%esp)
f010076a:	e8 5a 25 00 00       	call   f0102cc9 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
f0100772:	e9 1a 01 00 00       	jmp    f0100891 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100777:	83 ec 04             	sub    $0x4,%esp
f010077a:	6a 00                	push   $0x0
f010077c:	6a 00                	push   $0x0
f010077e:	ff 76 04             	pushl  0x4(%esi)
f0100781:	e8 ac 31 00 00       	call   f0103932 <strtol>
f0100786:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100788:	83 c4 0c             	add    $0xc,%esp
f010078b:	6a 00                	push   $0x0
f010078d:	6a 00                	push   $0x0
f010078f:	ff 76 08             	pushl  0x8(%esi)
f0100792:	e8 9b 31 00 00       	call   f0103932 <strtol>
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
f01007b6:	68 3e 3f 10 f0       	push   $0xf0103f3e
f01007bb:	e8 09 25 00 00       	call   f0102cc9 <cprintf>
        
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
f01007d9:	68 4f 3f 10 f0       	push   $0xf0103f4f
f01007de:	e8 e6 24 00 00       	call   f0102cc9 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	6a 00                	push   $0x0
f01007e8:	53                   	push   %ebx
f01007e9:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01007ef:	e8 5a 0c 00 00       	call   f010144e <pgdir_walk>
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
f0100806:	68 66 3f 10 f0       	push   $0xf0103f66
f010080b:	e8 b9 24 00 00       	call   f0102cc9 <cprintf>
f0100810:	83 c4 10             	add    $0x10,%esp
f0100813:	eb 74                	jmp    f0100889 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100815:	83 ec 08             	sub    $0x8,%esp
f0100818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010081d:	50                   	push   %eax
f010081e:	68 73 3f 10 f0       	push   $0xf0103f73
f0100823:	e8 a1 24 00 00       	call   f0102cc9 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	f6 03 04             	testb  $0x4,(%ebx)
f010082e:	74 12                	je     f0100842 <mon_showmappings+0xfe>
f0100830:	83 ec 0c             	sub    $0xc,%esp
f0100833:	68 7b 3f 10 f0       	push   $0xf0103f7b
f0100838:	e8 8c 24 00 00       	call   f0102cc9 <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp
f0100840:	eb 10                	jmp    f0100852 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100842:	83 ec 0c             	sub    $0xc,%esp
f0100845:	68 88 3f 10 f0       	push   $0xf0103f88
f010084a:	e8 7a 24 00 00       	call   f0102cc9 <cprintf>
f010084f:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100852:	f6 03 02             	testb  $0x2,(%ebx)
f0100855:	74 12                	je     f0100869 <mon_showmappings+0x125>
f0100857:	83 ec 0c             	sub    $0xc,%esp
f010085a:	68 95 3f 10 f0       	push   $0xf0103f95
f010085f:	e8 65 24 00 00       	call   f0102cc9 <cprintf>
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	eb 10                	jmp    f0100879 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100869:	83 ec 0c             	sub    $0xc,%esp
f010086c:	68 9a 3f 10 f0       	push   $0xf0103f9a
f0100871:	e8 53 24 00 00       	call   f0102cc9 <cprintf>
f0100876:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100879:	83 ec 0c             	sub    $0xc,%esp
f010087c:	68 71 3f 10 f0       	push   $0xf0103f71
f0100881:	e8 43 24 00 00       	call   f0102cc9 <cprintf>
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
f01008b3:	68 f8 42 10 f0       	push   $0xf01042f8
f01008b8:	e8 0c 24 00 00       	call   f0102cc9 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008bd:	c7 04 24 48 43 10 f0 	movl   $0xf0104348,(%esp)
f01008c4:	e8 00 24 00 00       	call   f0102cc9 <cprintf>
f01008c9:	83 c4 10             	add    $0x10,%esp
f01008cc:	e9 a5 01 00 00       	jmp    f0100a76 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f01008d1:	83 ec 04             	sub    $0x4,%esp
f01008d4:	6a 00                	push   $0x0
f01008d6:	6a 00                	push   $0x0
f01008d8:	ff 73 04             	pushl  0x4(%ebx)
f01008db:	e8 52 30 00 00       	call   f0103932 <strtol>
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
f0100921:	e8 28 0b 00 00       	call   f010144e <pgdir_walk>
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
f010093f:	68 6c 43 10 f0       	push   $0xf010436c
f0100944:	e8 80 23 00 00       	call   f0102cc9 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	f6 03 02             	testb  $0x2,(%ebx)
f010094f:	74 12                	je     f0100963 <mon_setpermission+0xc5>
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	68 9e 3f 10 f0       	push   $0xf0103f9e
f0100959:	e8 6b 23 00 00       	call   f0102cc9 <cprintf>
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	eb 10                	jmp    f0100973 <mon_setpermission+0xd5>
f0100963:	83 ec 0c             	sub    $0xc,%esp
f0100966:	68 a1 3f 10 f0       	push   $0xf0103fa1
f010096b:	e8 59 23 00 00       	call   f0102cc9 <cprintf>
f0100970:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100973:	f6 03 04             	testb  $0x4,(%ebx)
f0100976:	74 12                	je     f010098a <mon_setpermission+0xec>
f0100978:	83 ec 0c             	sub    $0xc,%esp
f010097b:	68 2d 50 10 f0       	push   $0xf010502d
f0100980:	e8 44 23 00 00       	call   f0102cc9 <cprintf>
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	eb 10                	jmp    f010099a <mon_setpermission+0xfc>
f010098a:	83 ec 0c             	sub    $0xc,%esp
f010098d:	68 a4 3f 10 f0       	push   $0xf0103fa4
f0100992:	e8 32 23 00 00       	call   f0102cc9 <cprintf>
f0100997:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f010099a:	f6 03 01             	testb  $0x1,(%ebx)
f010099d:	74 12                	je     f01009b1 <mon_setpermission+0x113>
f010099f:	83 ec 0c             	sub    $0xc,%esp
f01009a2:	68 b9 50 10 f0       	push   $0xf01050b9
f01009a7:	e8 1d 23 00 00       	call   f0102cc9 <cprintf>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	eb 10                	jmp    f01009c1 <mon_setpermission+0x123>
f01009b1:	83 ec 0c             	sub    $0xc,%esp
f01009b4:	68 a2 3f 10 f0       	push   $0xf0103fa2
f01009b9:	e8 0b 23 00 00       	call   f0102cc9 <cprintf>
f01009be:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f01009c1:	83 ec 0c             	sub    $0xc,%esp
f01009c4:	68 a6 3f 10 f0       	push   $0xf0103fa6
f01009c9:	e8 fb 22 00 00       	call   f0102cc9 <cprintf>
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
f01009e7:	68 9e 3f 10 f0       	push   $0xf0103f9e
f01009ec:	e8 d8 22 00 00       	call   f0102cc9 <cprintf>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	eb 10                	jmp    f0100a06 <mon_setpermission+0x168>
f01009f6:	83 ec 0c             	sub    $0xc,%esp
f01009f9:	68 a1 3f 10 f0       	push   $0xf0103fa1
f01009fe:	e8 c6 22 00 00       	call   f0102cc9 <cprintf>
f0100a03:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a06:	f6 03 04             	testb  $0x4,(%ebx)
f0100a09:	74 12                	je     f0100a1d <mon_setpermission+0x17f>
f0100a0b:	83 ec 0c             	sub    $0xc,%esp
f0100a0e:	68 2d 50 10 f0       	push   $0xf010502d
f0100a13:	e8 b1 22 00 00       	call   f0102cc9 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	eb 10                	jmp    f0100a2d <mon_setpermission+0x18f>
f0100a1d:	83 ec 0c             	sub    $0xc,%esp
f0100a20:	68 a4 3f 10 f0       	push   $0xf0103fa4
f0100a25:	e8 9f 22 00 00       	call   f0102cc9 <cprintf>
f0100a2a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a2d:	f6 03 01             	testb  $0x1,(%ebx)
f0100a30:	74 12                	je     f0100a44 <mon_setpermission+0x1a6>
f0100a32:	83 ec 0c             	sub    $0xc,%esp
f0100a35:	68 b9 50 10 f0       	push   $0xf01050b9
f0100a3a:	e8 8a 22 00 00       	call   f0102cc9 <cprintf>
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	eb 10                	jmp    f0100a54 <mon_setpermission+0x1b6>
f0100a44:	83 ec 0c             	sub    $0xc,%esp
f0100a47:	68 a2 3f 10 f0       	push   $0xf0103fa2
f0100a4c:	e8 78 22 00 00       	call   f0102cc9 <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a54:	83 ec 0c             	sub    $0xc,%esp
f0100a57:	68 71 3f 10 f0       	push   $0xf0103f71
f0100a5c:	e8 68 22 00 00       	call   f0102cc9 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
f0100a64:	eb 10                	jmp    f0100a76 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a66:	83 ec 0c             	sub    $0xc,%esp
f0100a69:	68 66 3f 10 f0       	push   $0xf0103f66
f0100a6e:	e8 56 22 00 00       	call   f0102cc9 <cprintf>
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
f0100a94:	68 90 43 10 f0       	push   $0xf0104390
f0100a99:	e8 2b 22 00 00       	call   f0102cc9 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a9e:	c7 04 24 c0 43 10 f0 	movl   $0xf01043c0,(%esp)
f0100aa5:	e8 1f 22 00 00       	call   f0102cc9 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100aaa:	c7 04 24 e0 43 10 f0 	movl   $0xf01043e0,(%esp)
f0100ab1:	e8 13 22 00 00       	call   f0102cc9 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ab6:	c7 04 24 14 44 10 f0 	movl   $0xf0104414,(%esp)
f0100abd:	e8 07 22 00 00       	call   f0102cc9 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100ac2:	c7 04 24 58 44 10 f0 	movl   $0xf0104458,(%esp)
f0100ac9:	e8 fb 21 00 00       	call   f0102cc9 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ace:	c7 04 24 b7 3f 10 f0 	movl   $0xf0103fb7,(%esp)
f0100ad5:	e8 ef 21 00 00       	call   f0102cc9 <cprintf>
        cprintf("         set the background color to black\n");
f0100ada:	c7 04 24 9c 44 10 f0 	movl   $0xf010449c,(%esp)
f0100ae1:	e8 e3 21 00 00       	call   f0102cc9 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100ae6:	c7 04 24 c8 44 10 f0 	movl   $0xf01044c8,(%esp)
f0100aed:	e8 d7 21 00 00       	call   f0102cc9 <cprintf>
f0100af2:	83 c4 10             	add    $0x10,%esp
f0100af5:	eb 52                	jmp    f0100b49 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100af7:	83 ec 0c             	sub    $0xc,%esp
f0100afa:	ff 73 04             	pushl  0x4(%ebx)
f0100afd:	e8 2e 2b 00 00       	call   f0103630 <strlen>
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
f0100b3c:	68 fc 44 10 f0       	push   $0xf01044fc
f0100b41:	e8 83 21 00 00       	call   f0102cc9 <cprintf>
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
f0100b7d:	68 20 45 10 f0       	push   $0xf0104520
f0100b82:	e8 42 21 00 00       	call   f0102cc9 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b87:	83 c4 18             	add    $0x18,%esp
f0100b8a:	57                   	push   %edi
f0100b8b:	ff 76 04             	pushl  0x4(%esi)
f0100b8e:	e8 72 22 00 00       	call   f0102e05 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b93:	83 c4 0c             	add    $0xc,%esp
f0100b96:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b99:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b9c:	68 d3 3f 10 f0       	push   $0xf0103fd3
f0100ba1:	e8 23 21 00 00       	call   f0102cc9 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100ba6:	83 c4 0c             	add    $0xc,%esp
f0100ba9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100bac:	ff 75 dc             	pushl  -0x24(%ebp)
f0100baf:	68 e3 3f 10 f0       	push   $0xf0103fe3
f0100bb4:	e8 10 21 00 00       	call   f0102cc9 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100bb9:	83 c4 08             	add    $0x8,%esp
f0100bbc:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100bbf:	53                   	push   %ebx
f0100bc0:	68 e8 3f 10 f0       	push   $0xf0103fe8
f0100bc5:	e8 ff 20 00 00       	call   f0102cc9 <cprintf>
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
f0100bfc:	68 58 45 10 f0       	push   $0xf0104558
f0100c01:	68 93 00 00 00       	push   $0x93
f0100c06:	68 ed 3f 10 f0       	push   $0xf0103fed
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
f0100c40:	68 58 45 10 f0       	push   $0xf0104558
f0100c45:	68 98 00 00 00       	push   $0x98
f0100c4a:	68 ed 3f 10 f0       	push   $0xf0103fed
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
f0100ca2:	68 7c 45 10 f0       	push   $0xf010457c
f0100ca7:	e8 1d 20 00 00       	call   f0102cc9 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100cac:	c7 04 24 ac 45 10 f0 	movl   $0xf01045ac,(%esp)
f0100cb3:	e8 11 20 00 00       	call   f0102cc9 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100cb8:	c7 04 24 d4 45 10 f0 	movl   $0xf01045d4,(%esp)
f0100cbf:	e8 05 20 00 00       	call   f0102cc9 <cprintf>
f0100cc4:	83 c4 10             	add    $0x10,%esp
f0100cc7:	e9 59 01 00 00       	jmp    f0100e25 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ccc:	83 ec 04             	sub    $0x4,%esp
f0100ccf:	6a 00                	push   $0x0
f0100cd1:	6a 00                	push   $0x0
f0100cd3:	ff 76 08             	pushl  0x8(%esi)
f0100cd6:	e8 57 2c 00 00       	call   f0103932 <strtol>
f0100cdb:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100cdd:	83 c4 0c             	add    $0xc,%esp
f0100ce0:	6a 00                	push   $0x0
f0100ce2:	6a 00                	push   $0x0
f0100ce4:	ff 76 0c             	pushl  0xc(%esi)
f0100ce7:	e8 46 2c 00 00       	call   f0103932 <strtol>
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
f0100d28:	68 71 3f 10 f0       	push   $0xf0103f71
f0100d2d:	e8 97 1f 00 00       	call   f0102cc9 <cprintf>
f0100d32:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d35:	83 ec 08             	sub    $0x8,%esp
f0100d38:	53                   	push   %ebx
f0100d39:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0100d3e:	e8 86 1f 00 00       	call   f0102cc9 <cprintf>
f0100d43:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d46:	83 ec 04             	sub    $0x4,%esp
f0100d49:	6a 00                	push   $0x0
f0100d4b:	89 d8                	mov    %ebx,%eax
f0100d4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d52:	50                   	push   %eax
f0100d53:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0100d59:	e8 f0 06 00 00       	call   f010144e <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	74 19                	je     f0100d7e <mon_dump+0xf1>
f0100d65:	f6 00 01             	testb  $0x1,(%eax)
f0100d68:	74 14                	je     f0100d7e <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d6a:	83 ec 08             	sub    $0x8,%esp
f0100d6d:	ff 33                	pushl  (%ebx)
f0100d6f:	68 06 40 10 f0       	push   $0xf0104006
f0100d74:	e8 50 1f 00 00       	call   f0102cc9 <cprintf>
f0100d79:	83 c4 10             	add    $0x10,%esp
f0100d7c:	eb 10                	jmp    f0100d8e <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d7e:	83 ec 0c             	sub    $0xc,%esp
f0100d81:	68 11 40 10 f0       	push   $0xf0104011
f0100d86:	e8 3e 1f 00 00       	call   f0102cc9 <cprintf>
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
f0100d99:	68 71 3f 10 f0       	push   $0xf0103f71
f0100d9e:	e8 26 1f 00 00       	call   f0102cc9 <cprintf>
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
f0100db9:	68 71 3f 10 f0       	push   $0xf0103f71
f0100dbe:	e8 06 1f 00 00       	call   f0102cc9 <cprintf>
f0100dc3:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100dc6:	83 ec 08             	sub    $0x8,%esp
f0100dc9:	53                   	push   %ebx
f0100dca:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0100dcf:	e8 f5 1e 00 00       	call   f0102cc9 <cprintf>
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
f0100dee:	68 06 40 10 f0       	push   $0xf0104006
f0100df3:	e8 d1 1e 00 00       	call   f0102cc9 <cprintf>
f0100df8:	83 c4 10             	add    $0x10,%esp
f0100dfb:	eb 10                	jmp    f0100e0d <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100dfd:	83 ec 0c             	sub    $0xc,%esp
f0100e00:	68 0f 40 10 f0       	push   $0xf010400f
f0100e05:	e8 bf 1e 00 00       	call   f0102cc9 <cprintf>
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
f0100e18:	68 71 3f 10 f0       	push   $0xf0103f71
f0100e1d:	e8 a7 1e 00 00       	call   f0102cc9 <cprintf>
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
f0100e3b:	68 18 46 10 f0       	push   $0xf0104618
f0100e40:	e8 84 1e 00 00       	call   f0102cc9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e45:	c7 04 24 3c 46 10 f0 	movl   $0xf010463c,(%esp)
f0100e4c:	e8 78 1e 00 00       	call   f0102cc9 <cprintf>
f0100e51:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e54:	83 ec 0c             	sub    $0xc,%esp
f0100e57:	68 1c 40 10 f0       	push   $0xf010401c
f0100e5c:	e8 ff 26 00 00       	call   f0103560 <readline>
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
f0100e89:	68 20 40 10 f0       	push   $0xf0104020
f0100e8e:	e8 16 29 00 00       	call   f01037a9 <strchr>
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
f0100ea9:	68 25 40 10 f0       	push   $0xf0104025
f0100eae:	e8 16 1e 00 00       	call   f0102cc9 <cprintf>
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
f0100ed3:	68 20 40 10 f0       	push   $0xf0104020
f0100ed8:	e8 cc 28 00 00       	call   f01037a9 <strchr>
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
f0100ef6:	bb c0 46 10 f0       	mov    $0xf01046c0,%ebx
f0100efb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f00:	83 ec 08             	sub    $0x8,%esp
f0100f03:	ff 33                	pushl  (%ebx)
f0100f05:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f08:	e8 2e 28 00 00       	call   f010373b <strcmp>
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
f0100f22:	ff 97 c8 46 10 f0    	call   *-0xfefb938(%edi)
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
f0100f43:	68 42 40 10 f0       	push   $0xf0104042
f0100f48:	e8 7c 1d 00 00       	call   f0102cc9 <cprintf>
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
f0100fa7:	74 42                	je     f0100feb <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fa9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fae:	89 c1                	mov    %eax,%ecx
f0100fb0:	c1 e9 0c             	shr    $0xc,%ecx
f0100fb3:	3b 0d 44 f9 11 f0    	cmp    0xf011f944,%ecx
f0100fb9:	72 15                	jb     f0100fd0 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbb:	50                   	push   %eax
f0100fbc:	68 20 47 10 f0       	push   $0xf0104720
f0100fc1:	68 d0 02 00 00       	push   $0x2d0
f0100fc6:	68 18 4e 10 f0       	push   $0xf0104e18
f0100fcb:	e8 bb f0 ff ff       	call   f010008b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100fd0:	c1 ea 0c             	shr    $0xc,%edx
f0100fd3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fd9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fe0:	a8 01                	test   $0x1,%al
f0100fe2:	74 0e                	je     f0100ff2 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fe4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fe9:	eb 0c                	jmp    f0100ff7 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ff0:	eb 05                	jmp    f0100ff7 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100ff7:	c9                   	leave  
f0100ff8:	c3                   	ret    

f0100ff9 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ff9:	55                   	push   %ebp
f0100ffa:	89 e5                	mov    %esp,%ebp
f0100ffc:	56                   	push   %esi
f0100ffd:	53                   	push   %ebx
f0100ffe:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101000:	83 ec 0c             	sub    $0xc,%esp
f0101003:	50                   	push   %eax
f0101004:	e8 5f 1c 00 00       	call   f0102c68 <mc146818_read>
f0101009:	89 c6                	mov    %eax,%esi
f010100b:	43                   	inc    %ebx
f010100c:	89 1c 24             	mov    %ebx,(%esp)
f010100f:	e8 54 1c 00 00       	call   f0102c68 <mc146818_read>
f0101014:	c1 e0 08             	shl    $0x8,%eax
f0101017:	09 f0                	or     %esi,%eax
}
f0101019:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010101c:	5b                   	pop    %ebx
f010101d:	5e                   	pop    %esi
f010101e:	c9                   	leave  
f010101f:	c3                   	ret    

f0101020 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	57                   	push   %edi
f0101024:	56                   	push   %esi
f0101025:	53                   	push   %ebx
f0101026:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101029:	3c 01                	cmp    $0x1,%al
f010102b:	19 f6                	sbb    %esi,%esi
f010102d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101033:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101034:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f010103a:	85 db                	test   %ebx,%ebx
f010103c:	75 17                	jne    f0101055 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010103e:	83 ec 04             	sub    $0x4,%esp
f0101041:	68 44 47 10 f0       	push   $0xf0104744
f0101046:	68 13 02 00 00       	push   $0x213
f010104b:	68 18 4e 10 f0       	push   $0xf0104e18
f0101050:	e8 36 f0 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
f0101055:	84 c0                	test   %al,%al
f0101057:	74 50                	je     f01010a9 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101059:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010105c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010105f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101062:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101065:	89 d8                	mov    %ebx,%eax
f0101067:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f010106d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101070:	c1 e8 16             	shr    $0x16,%eax
f0101073:	39 c6                	cmp    %eax,%esi
f0101075:	0f 96 c0             	setbe  %al
f0101078:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010107b:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010107f:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101081:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101085:	8b 1b                	mov    (%ebx),%ebx
f0101087:	85 db                	test   %ebx,%ebx
f0101089:	75 da                	jne    f0101065 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010108b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010108e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101094:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101097:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010109a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010109c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010109f:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010a5:	85 db                	test   %ebx,%ebx
f01010a7:	74 57                	je     f0101100 <check_page_free_list+0xe0>
f01010a9:	89 d8                	mov    %ebx,%eax
f01010ab:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01010b1:	c1 f8 03             	sar    $0x3,%eax
f01010b4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010b7:	89 c2                	mov    %eax,%edx
f01010b9:	c1 ea 16             	shr    $0x16,%edx
f01010bc:	39 d6                	cmp    %edx,%esi
f01010be:	76 3a                	jbe    f01010fa <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010c0:	89 c2                	mov    %eax,%edx
f01010c2:	c1 ea 0c             	shr    $0xc,%edx
f01010c5:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01010cb:	72 12                	jb     f01010df <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010cd:	50                   	push   %eax
f01010ce:	68 20 47 10 f0       	push   $0xf0104720
f01010d3:	6a 52                	push   $0x52
f01010d5:	68 24 4e 10 f0       	push   $0xf0104e24
f01010da:	e8 ac ef ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010df:	83 ec 04             	sub    $0x4,%esp
f01010e2:	68 80 00 00 00       	push   $0x80
f01010e7:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010ec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010f1:	50                   	push   %eax
f01010f2:	e8 02 27 00 00       	call   f01037f9 <memset>
f01010f7:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010fa:	8b 1b                	mov    (%ebx),%ebx
f01010fc:	85 db                	test   %ebx,%ebx
f01010fe:	75 a9                	jne    f01010a9 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101100:	b8 00 00 00 00       	mov    $0x0,%eax
f0101105:	e8 56 fe ff ff       	call   f0100f60 <boot_alloc>
f010110a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010110d:	8b 15 2c f5 11 f0    	mov    0xf011f52c,%edx
f0101113:	85 d2                	test   %edx,%edx
f0101115:	0f 84 80 01 00 00    	je     f010129b <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010111b:	8b 1d 4c f9 11 f0    	mov    0xf011f94c,%ebx
f0101121:	39 da                	cmp    %ebx,%edx
f0101123:	72 43                	jb     f0101168 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0101125:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f010112a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010112d:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101130:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101133:	39 c2                	cmp    %eax,%edx
f0101135:	73 4f                	jae    f0101186 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101137:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010113a:	89 d0                	mov    %edx,%eax
f010113c:	29 d8                	sub    %ebx,%eax
f010113e:	a8 07                	test   $0x7,%al
f0101140:	75 66                	jne    f01011a8 <check_page_free_list+0x188>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101142:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101145:	c1 e0 0c             	shl    $0xc,%eax
f0101148:	74 7f                	je     f01011c9 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f010114a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010114f:	0f 84 94 00 00 00    	je     f01011e9 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101155:	be 00 00 00 00       	mov    $0x0,%esi
f010115a:	bf 00 00 00 00       	mov    $0x0,%edi
f010115f:	e9 9e 00 00 00       	jmp    f0101202 <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101164:	39 da                	cmp    %ebx,%edx
f0101166:	73 19                	jae    f0101181 <check_page_free_list+0x161>
f0101168:	68 32 4e 10 f0       	push   $0xf0104e32
f010116d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101172:	68 2d 02 00 00       	push   $0x22d
f0101177:	68 18 4e 10 f0       	push   $0xf0104e18
f010117c:	e8 0a ef ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0101181:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101184:	72 19                	jb     f010119f <check_page_free_list+0x17f>
f0101186:	68 53 4e 10 f0       	push   $0xf0104e53
f010118b:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101190:	68 2e 02 00 00       	push   $0x22e
f0101195:	68 18 4e 10 f0       	push   $0xf0104e18
f010119a:	e8 ec ee ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010119f:	89 d0                	mov    %edx,%eax
f01011a1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011a4:	a8 07                	test   $0x7,%al
f01011a6:	74 19                	je     f01011c1 <check_page_free_list+0x1a1>
f01011a8:	68 68 47 10 f0       	push   $0xf0104768
f01011ad:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01011b2:	68 2f 02 00 00       	push   $0x22f
f01011b7:	68 18 4e 10 f0       	push   $0xf0104e18
f01011bc:	e8 ca ee ff ff       	call   f010008b <_panic>
f01011c1:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011c4:	c1 e0 0c             	shl    $0xc,%eax
f01011c7:	75 19                	jne    f01011e2 <check_page_free_list+0x1c2>
f01011c9:	68 67 4e 10 f0       	push   $0xf0104e67
f01011ce:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01011d3:	68 32 02 00 00       	push   $0x232
f01011d8:	68 18 4e 10 f0       	push   $0xf0104e18
f01011dd:	e8 a9 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011e2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011e7:	75 19                	jne    f0101202 <check_page_free_list+0x1e2>
f01011e9:	68 78 4e 10 f0       	push   $0xf0104e78
f01011ee:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01011f3:	68 33 02 00 00       	push   $0x233
f01011f8:	68 18 4e 10 f0       	push   $0xf0104e18
f01011fd:	e8 89 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101202:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101207:	75 19                	jne    f0101222 <check_page_free_list+0x202>
f0101209:	68 9c 47 10 f0       	push   $0xf010479c
f010120e:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101213:	68 34 02 00 00       	push   $0x234
f0101218:	68 18 4e 10 f0       	push   $0xf0104e18
f010121d:	e8 69 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101222:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101227:	75 19                	jne    f0101242 <check_page_free_list+0x222>
f0101229:	68 91 4e 10 f0       	push   $0xf0104e91
f010122e:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101233:	68 35 02 00 00       	push   $0x235
f0101238:	68 18 4e 10 f0       	push   $0xf0104e18
f010123d:	e8 49 ee ff ff       	call   f010008b <_panic>
f0101242:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101244:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101249:	76 3e                	jbe    f0101289 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010124b:	c1 e8 0c             	shr    $0xc,%eax
f010124e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101251:	77 12                	ja     f0101265 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101253:	51                   	push   %ecx
f0101254:	68 20 47 10 f0       	push   $0xf0104720
f0101259:	6a 52                	push   $0x52
f010125b:	68 24 4e 10 f0       	push   $0xf0104e24
f0101260:	e8 26 ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101265:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f010126b:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010126e:	76 1c                	jbe    f010128c <check_page_free_list+0x26c>
f0101270:	68 c0 47 10 f0       	push   $0xf01047c0
f0101275:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010127a:	68 36 02 00 00       	push   $0x236
f010127f:	68 18 4e 10 f0       	push   $0xf0104e18
f0101284:	e8 02 ee ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101289:	47                   	inc    %edi
f010128a:	eb 01                	jmp    f010128d <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f010128c:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010128d:	8b 12                	mov    (%edx),%edx
f010128f:	85 d2                	test   %edx,%edx
f0101291:	0f 85 cd fe ff ff    	jne    f0101164 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101297:	85 ff                	test   %edi,%edi
f0101299:	7f 19                	jg     f01012b4 <check_page_free_list+0x294>
f010129b:	68 ab 4e 10 f0       	push   $0xf0104eab
f01012a0:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01012a5:	68 3e 02 00 00       	push   $0x23e
f01012aa:	68 18 4e 10 f0       	push   $0xf0104e18
f01012af:	e8 d7 ed ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f01012b4:	85 f6                	test   %esi,%esi
f01012b6:	7f 19                	jg     f01012d1 <check_page_free_list+0x2b1>
f01012b8:	68 bd 4e 10 f0       	push   $0xf0104ebd
f01012bd:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01012c2:	68 3f 02 00 00       	push   $0x23f
f01012c7:	68 18 4e 10 f0       	push   $0xf0104e18
f01012cc:	e8 ba ed ff ff       	call   f010008b <_panic>
}
f01012d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d4:	5b                   	pop    %ebx
f01012d5:	5e                   	pop    %esi
f01012d6:	5f                   	pop    %edi
f01012d7:	c9                   	leave  
f01012d8:	c3                   	ret    

f01012d9 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012d9:	55                   	push   %ebp
f01012da:	89 e5                	mov    %esp,%ebp
f01012dc:	56                   	push   %esi
f01012dd:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01012de:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f01012e5:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f01012e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ed:	e8 6e fc ff ff       	call   f0100f60 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012f7:	77 15                	ja     f010130e <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012f9:	50                   	push   %eax
f01012fa:	68 58 45 10 f0       	push   $0xf0104558
f01012ff:	68 1c 01 00 00       	push   $0x11c
f0101304:	68 18 4e 10 f0       	push   $0xf0104e18
f0101309:	e8 7d ed ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010130e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101314:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0101317:	83 3d 44 f9 11 f0 00 	cmpl   $0x0,0xf011f944
f010131e:	74 5f                	je     f010137f <page_init+0xa6>
f0101320:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f0101326:	ba 00 00 00 00       	mov    $0x0,%edx
f010132b:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101330:	85 c0                	test   %eax,%eax
f0101332:	74 25                	je     f0101359 <page_init+0x80>
f0101334:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101339:	76 04                	jbe    f010133f <page_init+0x66>
f010133b:	39 c6                	cmp    %eax,%esi
f010133d:	77 1a                	ja     f0101359 <page_init+0x80>
		    pages[i].pp_ref = 0;
f010133f:	89 d1                	mov    %edx,%ecx
f0101341:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f0101347:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f010134d:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f010134f:	89 d3                	mov    %edx,%ebx
f0101351:	03 1d 4c f9 11 f0    	add    0xf011f94c,%ebx
f0101357:	eb 14                	jmp    f010136d <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101359:	89 d1                	mov    %edx,%ecx
f010135b:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f0101361:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f0101367:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f010136d:	40                   	inc    %eax
f010136e:	83 c2 08             	add    $0x8,%edx
f0101371:	39 05 44 f9 11 f0    	cmp    %eax,0xf011f944
f0101377:	77 b7                	ja     f0101330 <page_init+0x57>
f0101379:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f010137f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101382:	5b                   	pop    %ebx
f0101383:	5e                   	pop    %esi
f0101384:	c9                   	leave  
f0101385:	c3                   	ret    

f0101386 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	53                   	push   %ebx
f010138a:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f010138d:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f0101393:	85 db                	test   %ebx,%ebx
f0101395:	74 63                	je     f01013fa <page_alloc+0x74>
f0101397:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010139c:	74 63                	je     f0101401 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f010139e:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013a0:	85 db                	test   %ebx,%ebx
f01013a2:	75 08                	jne    f01013ac <page_alloc+0x26>
f01013a4:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
f01013aa:	eb 4e                	jmp    f01013fa <page_alloc+0x74>
f01013ac:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013b1:	75 eb                	jne    f010139e <page_alloc+0x18>
f01013b3:	eb 4c                	jmp    f0101401 <page_alloc+0x7b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013b5:	89 d8                	mov    %ebx,%eax
f01013b7:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01013bd:	c1 f8 03             	sar    $0x3,%eax
f01013c0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013c3:	89 c2                	mov    %eax,%edx
f01013c5:	c1 ea 0c             	shr    $0xc,%edx
f01013c8:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01013ce:	72 12                	jb     f01013e2 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013d0:	50                   	push   %eax
f01013d1:	68 20 47 10 f0       	push   $0xf0104720
f01013d6:	6a 52                	push   $0x52
f01013d8:	68 24 4e 10 f0       	push   $0xf0104e24
f01013dd:	e8 a9 ec ff ff       	call   f010008b <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f01013e2:	83 ec 04             	sub    $0x4,%esp
f01013e5:	68 00 10 00 00       	push   $0x1000
f01013ea:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013ec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013f1:	50                   	push   %eax
f01013f2:	e8 02 24 00 00       	call   f01037f9 <memset>
f01013f7:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f01013fa:	89 d8                	mov    %ebx,%eax
f01013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013ff:	c9                   	leave  
f0101400:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101401:	8b 03                	mov    (%ebx),%eax
f0101403:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
        if (alloc_flags & ALLOC_ZERO) {
f0101408:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010140c:	74 ec                	je     f01013fa <page_alloc+0x74>
f010140e:	eb a5                	jmp    f01013b5 <page_alloc+0x2f>

f0101410 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101410:	55                   	push   %ebp
f0101411:	89 e5                	mov    %esp,%ebp
f0101413:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101416:	85 c0                	test   %eax,%eax
f0101418:	74 14                	je     f010142e <page_free+0x1e>
f010141a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010141f:	75 0d                	jne    f010142e <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101421:	8b 15 2c f5 11 f0    	mov    0xf011f52c,%edx
f0101427:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101429:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
}
f010142e:	c9                   	leave  
f010142f:	c3                   	ret    

f0101430 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101430:	55                   	push   %ebp
f0101431:	89 e5                	mov    %esp,%ebp
f0101433:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101436:	8b 50 04             	mov    0x4(%eax),%edx
f0101439:	4a                   	dec    %edx
f010143a:	66 89 50 04          	mov    %dx,0x4(%eax)
f010143e:	66 85 d2             	test   %dx,%dx
f0101441:	75 09                	jne    f010144c <page_decref+0x1c>
		page_free(pp);
f0101443:	50                   	push   %eax
f0101444:	e8 c7 ff ff ff       	call   f0101410 <page_free>
f0101449:	83 c4 04             	add    $0x4,%esp
}
f010144c:	c9                   	leave  
f010144d:	c3                   	ret    

f010144e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010144e:	55                   	push   %ebp
f010144f:	89 e5                	mov    %esp,%ebp
f0101451:	56                   	push   %esi
f0101452:	53                   	push   %ebx
f0101453:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0101456:	89 f3                	mov    %esi,%ebx
f0101458:	c1 eb 16             	shr    $0x16,%ebx
f010145b:	c1 e3 02             	shl    $0x2,%ebx
f010145e:	03 5d 08             	add    0x8(%ebp),%ebx
f0101461:	8b 03                	mov    (%ebx),%eax
f0101463:	85 c0                	test   %eax,%eax
f0101465:	74 04                	je     f010146b <pgdir_walk+0x1d>
f0101467:	a8 01                	test   $0x1,%al
f0101469:	75 2c                	jne    f0101497 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f010146b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010146f:	74 61                	je     f01014d2 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
f0101471:	83 ec 0c             	sub    $0xc,%esp
f0101474:	6a 01                	push   $0x1
f0101476:	e8 0b ff ff ff       	call   f0101386 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f010147b:	83 c4 10             	add    $0x10,%esp
f010147e:	85 c0                	test   %eax,%eax
f0101480:	74 57                	je     f01014d9 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f0101482:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101486:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f010148c:	c1 f8 03             	sar    $0x3,%eax
f010148f:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f0101492:	83 c8 07             	or     $0x7,%eax
f0101495:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f0101497:	8b 03                	mov    (%ebx),%eax
f0101499:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010149e:	89 c2                	mov    %eax,%edx
f01014a0:	c1 ea 0c             	shr    $0xc,%edx
f01014a3:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01014a9:	72 15                	jb     f01014c0 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014ab:	50                   	push   %eax
f01014ac:	68 20 47 10 f0       	push   $0xf0104720
f01014b1:	68 7f 01 00 00       	push   $0x17f
f01014b6:	68 18 4e 10 f0       	push   $0xf0104e18
f01014bb:	e8 cb eb ff ff       	call   f010008b <_panic>
f01014c0:	c1 ee 0a             	shr    $0xa,%esi
f01014c3:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01014c9:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01014d0:	eb 0c                	jmp    f01014de <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f01014d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d7:	eb 05                	jmp    f01014de <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
        if (new_page == NULL) return NULL;      // allocation fails
f01014d9:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01014de:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014e1:	5b                   	pop    %ebx
f01014e2:	5e                   	pop    %esi
f01014e3:	c9                   	leave  
f01014e4:	c3                   	ret    

f01014e5 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014e5:	55                   	push   %ebp
f01014e6:	89 e5                	mov    %esp,%ebp
f01014e8:	57                   	push   %edi
f01014e9:	56                   	push   %esi
f01014ea:	53                   	push   %ebx
f01014eb:	83 ec 1c             	sub    $0x1c,%esp
f01014ee:	89 c7                	mov    %eax,%edi
f01014f0:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014f3:	01 d1                	add    %edx,%ecx
f01014f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014f8:	39 ca                	cmp    %ecx,%edx
f01014fa:	74 32                	je     f010152e <boot_map_region+0x49>
f01014fc:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101501:	83 c8 01             	or     $0x1,%eax
f0101504:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101507:	83 ec 04             	sub    $0x4,%esp
f010150a:	6a 01                	push   $0x1
f010150c:	53                   	push   %ebx
f010150d:	57                   	push   %edi
f010150e:	e8 3b ff ff ff       	call   f010144e <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101513:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101516:	09 f2                	or     %esi,%edx
f0101518:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010151a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101520:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101526:	83 c4 10             	add    $0x10,%esp
f0101529:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010152c:	75 d9                	jne    f0101507 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f010152e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101531:	5b                   	pop    %ebx
f0101532:	5e                   	pop    %esi
f0101533:	5f                   	pop    %edi
f0101534:	c9                   	leave  
f0101535:	c3                   	ret    

f0101536 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101536:	55                   	push   %ebp
f0101537:	89 e5                	mov    %esp,%ebp
f0101539:	53                   	push   %ebx
f010153a:	83 ec 08             	sub    $0x8,%esp
f010153d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101540:	6a 00                	push   $0x0
f0101542:	ff 75 0c             	pushl  0xc(%ebp)
f0101545:	ff 75 08             	pushl  0x8(%ebp)
f0101548:	e8 01 ff ff ff       	call   f010144e <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010154d:	83 c4 10             	add    $0x10,%esp
f0101550:	85 c0                	test   %eax,%eax
f0101552:	74 37                	je     f010158b <page_lookup+0x55>
f0101554:	f6 00 01             	testb  $0x1,(%eax)
f0101557:	74 39                	je     f0101592 <page_lookup+0x5c>
    if (pte_store != 0) {
f0101559:	85 db                	test   %ebx,%ebx
f010155b:	74 02                	je     f010155f <page_lookup+0x29>
        *pte_store = pte;
f010155d:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f010155f:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101561:	c1 e8 0c             	shr    $0xc,%eax
f0101564:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f010156a:	72 14                	jb     f0101580 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010156c:	83 ec 04             	sub    $0x4,%esp
f010156f:	68 08 48 10 f0       	push   $0xf0104808
f0101574:	6a 4b                	push   $0x4b
f0101576:	68 24 4e 10 f0       	push   $0xf0104e24
f010157b:	e8 0b eb ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101580:	c1 e0 03             	shl    $0x3,%eax
f0101583:	03 05 4c f9 11 f0    	add    0xf011f94c,%eax
f0101589:	eb 0c                	jmp    f0101597 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010158b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101590:	eb 05                	jmp    f0101597 <page_lookup+0x61>
f0101592:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0101597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010159a:	c9                   	leave  
f010159b:	c3                   	ret    

f010159c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010159c:	55                   	push   %ebp
f010159d:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010159f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015a2:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01015a5:	c9                   	leave  
f01015a6:	c3                   	ret    

f01015a7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015a7:	55                   	push   %ebp
f01015a8:	89 e5                	mov    %esp,%ebp
f01015aa:	56                   	push   %esi
f01015ab:	53                   	push   %ebx
f01015ac:	83 ec 14             	sub    $0x14,%esp
f01015af:	8b 75 08             	mov    0x8(%ebp),%esi
f01015b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f01015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015b8:	50                   	push   %eax
f01015b9:	53                   	push   %ebx
f01015ba:	56                   	push   %esi
f01015bb:	e8 76 ff ff ff       	call   f0101536 <page_lookup>
    if (pg == NULL) return;
f01015c0:	83 c4 10             	add    $0x10,%esp
f01015c3:	85 c0                	test   %eax,%eax
f01015c5:	74 26                	je     f01015ed <page_remove+0x46>
    page_decref(pg);
f01015c7:	83 ec 0c             	sub    $0xc,%esp
f01015ca:	50                   	push   %eax
f01015cb:	e8 60 fe ff ff       	call   f0101430 <page_decref>
    if (pte != NULL) *pte = 0;
f01015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015d3:	83 c4 10             	add    $0x10,%esp
f01015d6:	85 c0                	test   %eax,%eax
f01015d8:	74 06                	je     f01015e0 <page_remove+0x39>
f01015da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f01015e0:	83 ec 08             	sub    $0x8,%esp
f01015e3:	53                   	push   %ebx
f01015e4:	56                   	push   %esi
f01015e5:	e8 b2 ff ff ff       	call   f010159c <tlb_invalidate>
f01015ea:	83 c4 10             	add    $0x10,%esp
}
f01015ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015f0:	5b                   	pop    %ebx
f01015f1:	5e                   	pop    %esi
f01015f2:	c9                   	leave  
f01015f3:	c3                   	ret    

f01015f4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01015f4:	55                   	push   %ebp
f01015f5:	89 e5                	mov    %esp,%ebp
f01015f7:	57                   	push   %edi
f01015f8:	56                   	push   %esi
f01015f9:	53                   	push   %ebx
f01015fa:	83 ec 10             	sub    $0x10,%esp
f01015fd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101600:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0101603:	6a 01                	push   $0x1
f0101605:	57                   	push   %edi
f0101606:	ff 75 08             	pushl  0x8(%ebp)
f0101609:	e8 40 fe ff ff       	call   f010144e <pgdir_walk>
f010160e:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101610:	83 c4 10             	add    $0x10,%esp
f0101613:	85 c0                	test   %eax,%eax
f0101615:	74 39                	je     f0101650 <page_insert+0x5c>
    ++pp->pp_ref;
f0101617:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f010161b:	f6 00 01             	testb  $0x1,(%eax)
f010161e:	74 0f                	je     f010162f <page_insert+0x3b>
        page_remove(pgdir, va);
f0101620:	83 ec 08             	sub    $0x8,%esp
f0101623:	57                   	push   %edi
f0101624:	ff 75 08             	pushl  0x8(%ebp)
f0101627:	e8 7b ff ff ff       	call   f01015a7 <page_remove>
f010162c:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010162f:	8b 55 14             	mov    0x14(%ebp),%edx
f0101632:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101635:	2b 35 4c f9 11 f0    	sub    0xf011f94c,%esi
f010163b:	c1 fe 03             	sar    $0x3,%esi
f010163e:	89 f0                	mov    %esi,%eax
f0101640:	c1 e0 0c             	shl    $0xc,%eax
f0101643:	89 d6                	mov    %edx,%esi
f0101645:	09 c6                	or     %eax,%esi
f0101647:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101649:	b8 00 00 00 00       	mov    $0x0,%eax
f010164e:	eb 05                	jmp    f0101655 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101650:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f0101655:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101658:	5b                   	pop    %ebx
f0101659:	5e                   	pop    %esi
f010165a:	5f                   	pop    %edi
f010165b:	c9                   	leave  
f010165c:	c3                   	ret    

f010165d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010165d:	55                   	push   %ebp
f010165e:	89 e5                	mov    %esp,%ebp
f0101660:	57                   	push   %edi
f0101661:	56                   	push   %esi
f0101662:	53                   	push   %ebx
f0101663:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101666:	b8 15 00 00 00       	mov    $0x15,%eax
f010166b:	e8 89 f9 ff ff       	call   f0100ff9 <nvram_read>
f0101670:	c1 e0 0a             	shl    $0xa,%eax
f0101673:	89 c2                	mov    %eax,%edx
f0101675:	85 c0                	test   %eax,%eax
f0101677:	79 06                	jns    f010167f <mem_init+0x22>
f0101679:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010167f:	c1 fa 0c             	sar    $0xc,%edx
f0101682:	89 15 34 f5 11 f0    	mov    %edx,0xf011f534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101688:	b8 17 00 00 00       	mov    $0x17,%eax
f010168d:	e8 67 f9 ff ff       	call   f0100ff9 <nvram_read>
f0101692:	89 c2                	mov    %eax,%edx
f0101694:	c1 e2 0a             	shl    $0xa,%edx
f0101697:	89 d0                	mov    %edx,%eax
f0101699:	85 d2                	test   %edx,%edx
f010169b:	79 06                	jns    f01016a3 <mem_init+0x46>
f010169d:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01016a3:	c1 f8 0c             	sar    $0xc,%eax
f01016a6:	74 0e                	je     f01016b6 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01016a8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01016ae:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944
f01016b4:	eb 0c                	jmp    f01016c2 <mem_init+0x65>
	else
		npages = npages_basemem;
f01016b6:	8b 15 34 f5 11 f0    	mov    0xf011f534,%edx
f01016bc:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01016c2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016c5:	c1 e8 0a             	shr    $0xa,%eax
f01016c8:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01016c9:	a1 34 f5 11 f0       	mov    0xf011f534,%eax
f01016ce:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016d1:	c1 e8 0a             	shr    $0xa,%eax
f01016d4:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01016d5:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01016da:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016dd:	c1 e8 0a             	shr    $0xa,%eax
f01016e0:	50                   	push   %eax
f01016e1:	68 28 48 10 f0       	push   $0xf0104828
f01016e6:	e8 de 15 00 00       	call   f0102cc9 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016eb:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016f0:	e8 6b f8 ff ff       	call   f0100f60 <boot_alloc>
f01016f5:	a3 48 f9 11 f0       	mov    %eax,0xf011f948
	memset(kern_pgdir, 0, PGSIZE);
f01016fa:	83 c4 0c             	add    $0xc,%esp
f01016fd:	68 00 10 00 00       	push   $0x1000
f0101702:	6a 00                	push   $0x0
f0101704:	50                   	push   %eax
f0101705:	e8 ef 20 00 00       	call   f01037f9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010170a:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010170f:	83 c4 10             	add    $0x10,%esp
f0101712:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101717:	77 15                	ja     f010172e <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101719:	50                   	push   %eax
f010171a:	68 58 45 10 f0       	push   $0xf0104558
f010171f:	68 8d 00 00 00       	push   $0x8d
f0101724:	68 18 4e 10 f0       	push   $0xf0104e18
f0101729:	e8 5d e9 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010172e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101734:	83 ca 05             	or     $0x5,%edx
f0101737:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010173d:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0101742:	c1 e0 03             	shl    $0x3,%eax
f0101745:	e8 16 f8 ff ff       	call   f0100f60 <boot_alloc>
f010174a:	a3 4c f9 11 f0       	mov    %eax,0xf011f94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010174f:	e8 85 fb ff ff       	call   f01012d9 <page_init>


    // cprintf("GGG %08x\n", (uint32_t)page2pa(page_free_list));

	check_page_free_list(1);
f0101754:	b8 01 00 00 00       	mov    $0x1,%eax
f0101759:	e8 c2 f8 ff ff       	call   f0101020 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010175e:	83 3d 4c f9 11 f0 00 	cmpl   $0x0,0xf011f94c
f0101765:	75 17                	jne    f010177e <mem_init+0x121>
		panic("'pages' is a null pointer!");
f0101767:	83 ec 04             	sub    $0x4,%esp
f010176a:	68 ce 4e 10 f0       	push   $0xf0104ece
f010176f:	68 50 02 00 00       	push   $0x250
f0101774:	68 18 4e 10 f0       	push   $0xf0104e18
f0101779:	e8 0d e9 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010177e:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101783:	85 c0                	test   %eax,%eax
f0101785:	74 0e                	je     f0101795 <mem_init+0x138>
f0101787:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f010178c:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010178d:	8b 00                	mov    (%eax),%eax
f010178f:	85 c0                	test   %eax,%eax
f0101791:	75 f9                	jne    f010178c <mem_init+0x12f>
f0101793:	eb 05                	jmp    f010179a <mem_init+0x13d>
f0101795:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010179a:	83 ec 0c             	sub    $0xc,%esp
f010179d:	6a 00                	push   $0x0
f010179f:	e8 e2 fb ff ff       	call   f0101386 <page_alloc>
f01017a4:	89 c6                	mov    %eax,%esi
f01017a6:	83 c4 10             	add    $0x10,%esp
f01017a9:	85 c0                	test   %eax,%eax
f01017ab:	75 19                	jne    f01017c6 <mem_init+0x169>
f01017ad:	68 e9 4e 10 f0       	push   $0xf0104ee9
f01017b2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01017b7:	68 58 02 00 00       	push   $0x258
f01017bc:	68 18 4e 10 f0       	push   $0xf0104e18
f01017c1:	e8 c5 e8 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01017c6:	83 ec 0c             	sub    $0xc,%esp
f01017c9:	6a 00                	push   $0x0
f01017cb:	e8 b6 fb ff ff       	call   f0101386 <page_alloc>
f01017d0:	89 c7                	mov    %eax,%edi
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	85 c0                	test   %eax,%eax
f01017d7:	75 19                	jne    f01017f2 <mem_init+0x195>
f01017d9:	68 ff 4e 10 f0       	push   $0xf0104eff
f01017de:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01017e3:	68 59 02 00 00       	push   $0x259
f01017e8:	68 18 4e 10 f0       	push   $0xf0104e18
f01017ed:	e8 99 e8 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01017f2:	83 ec 0c             	sub    $0xc,%esp
f01017f5:	6a 00                	push   $0x0
f01017f7:	e8 8a fb ff ff       	call   f0101386 <page_alloc>
f01017fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017ff:	83 c4 10             	add    $0x10,%esp
f0101802:	85 c0                	test   %eax,%eax
f0101804:	75 19                	jne    f010181f <mem_init+0x1c2>
f0101806:	68 15 4f 10 f0       	push   $0xf0104f15
f010180b:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101810:	68 5a 02 00 00       	push   $0x25a
f0101815:	68 18 4e 10 f0       	push   $0xf0104e18
f010181a:	e8 6c e8 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010181f:	39 fe                	cmp    %edi,%esi
f0101821:	75 19                	jne    f010183c <mem_init+0x1df>
f0101823:	68 2b 4f 10 f0       	push   $0xf0104f2b
f0101828:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010182d:	68 5d 02 00 00       	push   $0x25d
f0101832:	68 18 4e 10 f0       	push   $0xf0104e18
f0101837:	e8 4f e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010183c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010183f:	74 05                	je     f0101846 <mem_init+0x1e9>
f0101841:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101844:	75 19                	jne    f010185f <mem_init+0x202>
f0101846:	68 64 48 10 f0       	push   $0xf0104864
f010184b:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101850:	68 5e 02 00 00       	push   $0x25e
f0101855:	68 18 4e 10 f0       	push   $0xf0104e18
f010185a:	e8 2c e8 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010185f:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101865:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f010186a:	c1 e0 0c             	shl    $0xc,%eax
f010186d:	89 f1                	mov    %esi,%ecx
f010186f:	29 d1                	sub    %edx,%ecx
f0101871:	c1 f9 03             	sar    $0x3,%ecx
f0101874:	c1 e1 0c             	shl    $0xc,%ecx
f0101877:	39 c1                	cmp    %eax,%ecx
f0101879:	72 19                	jb     f0101894 <mem_init+0x237>
f010187b:	68 3d 4f 10 f0       	push   $0xf0104f3d
f0101880:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101885:	68 5f 02 00 00       	push   $0x25f
f010188a:	68 18 4e 10 f0       	push   $0xf0104e18
f010188f:	e8 f7 e7 ff ff       	call   f010008b <_panic>
f0101894:	89 f9                	mov    %edi,%ecx
f0101896:	29 d1                	sub    %edx,%ecx
f0101898:	c1 f9 03             	sar    $0x3,%ecx
f010189b:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010189e:	39 c8                	cmp    %ecx,%eax
f01018a0:	77 19                	ja     f01018bb <mem_init+0x25e>
f01018a2:	68 5a 4f 10 f0       	push   $0xf0104f5a
f01018a7:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01018ac:	68 60 02 00 00       	push   $0x260
f01018b1:	68 18 4e 10 f0       	push   $0xf0104e18
f01018b6:	e8 d0 e7 ff ff       	call   f010008b <_panic>
f01018bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01018be:	29 d1                	sub    %edx,%ecx
f01018c0:	89 ca                	mov    %ecx,%edx
f01018c2:	c1 fa 03             	sar    $0x3,%edx
f01018c5:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018c8:	39 d0                	cmp    %edx,%eax
f01018ca:	77 19                	ja     f01018e5 <mem_init+0x288>
f01018cc:	68 77 4f 10 f0       	push   $0xf0104f77
f01018d1:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01018d6:	68 61 02 00 00       	push   $0x261
f01018db:	68 18 4e 10 f0       	push   $0xf0104e18
f01018e0:	e8 a6 e7 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018e5:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f01018ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018ed:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f01018f4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018f7:	83 ec 0c             	sub    $0xc,%esp
f01018fa:	6a 00                	push   $0x0
f01018fc:	e8 85 fa ff ff       	call   f0101386 <page_alloc>
f0101901:	83 c4 10             	add    $0x10,%esp
f0101904:	85 c0                	test   %eax,%eax
f0101906:	74 19                	je     f0101921 <mem_init+0x2c4>
f0101908:	68 94 4f 10 f0       	push   $0xf0104f94
f010190d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101912:	68 68 02 00 00       	push   $0x268
f0101917:	68 18 4e 10 f0       	push   $0xf0104e18
f010191c:	e8 6a e7 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101921:	83 ec 0c             	sub    $0xc,%esp
f0101924:	56                   	push   %esi
f0101925:	e8 e6 fa ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f010192a:	89 3c 24             	mov    %edi,(%esp)
f010192d:	e8 de fa ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0101932:	83 c4 04             	add    $0x4,%esp
f0101935:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101938:	e8 d3 fa ff ff       	call   f0101410 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010193d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101944:	e8 3d fa ff ff       	call   f0101386 <page_alloc>
f0101949:	89 c6                	mov    %eax,%esi
f010194b:	83 c4 10             	add    $0x10,%esp
f010194e:	85 c0                	test   %eax,%eax
f0101950:	75 19                	jne    f010196b <mem_init+0x30e>
f0101952:	68 e9 4e 10 f0       	push   $0xf0104ee9
f0101957:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010195c:	68 6f 02 00 00       	push   $0x26f
f0101961:	68 18 4e 10 f0       	push   $0xf0104e18
f0101966:	e8 20 e7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010196b:	83 ec 0c             	sub    $0xc,%esp
f010196e:	6a 00                	push   $0x0
f0101970:	e8 11 fa ff ff       	call   f0101386 <page_alloc>
f0101975:	89 c7                	mov    %eax,%edi
f0101977:	83 c4 10             	add    $0x10,%esp
f010197a:	85 c0                	test   %eax,%eax
f010197c:	75 19                	jne    f0101997 <mem_init+0x33a>
f010197e:	68 ff 4e 10 f0       	push   $0xf0104eff
f0101983:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101988:	68 70 02 00 00       	push   $0x270
f010198d:	68 18 4e 10 f0       	push   $0xf0104e18
f0101992:	e8 f4 e6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101997:	83 ec 0c             	sub    $0xc,%esp
f010199a:	6a 00                	push   $0x0
f010199c:	e8 e5 f9 ff ff       	call   f0101386 <page_alloc>
f01019a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019a4:	83 c4 10             	add    $0x10,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	75 19                	jne    f01019c4 <mem_init+0x367>
f01019ab:	68 15 4f 10 f0       	push   $0xf0104f15
f01019b0:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01019b5:	68 71 02 00 00       	push   $0x271
f01019ba:	68 18 4e 10 f0       	push   $0xf0104e18
f01019bf:	e8 c7 e6 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019c4:	39 fe                	cmp    %edi,%esi
f01019c6:	75 19                	jne    f01019e1 <mem_init+0x384>
f01019c8:	68 2b 4f 10 f0       	push   $0xf0104f2b
f01019cd:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01019d2:	68 73 02 00 00       	push   $0x273
f01019d7:	68 18 4e 10 f0       	push   $0xf0104e18
f01019dc:	e8 aa e6 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019e1:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01019e4:	74 05                	je     f01019eb <mem_init+0x38e>
f01019e6:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019e9:	75 19                	jne    f0101a04 <mem_init+0x3a7>
f01019eb:	68 64 48 10 f0       	push   $0xf0104864
f01019f0:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01019f5:	68 74 02 00 00       	push   $0x274
f01019fa:	68 18 4e 10 f0       	push   $0xf0104e18
f01019ff:	e8 87 e6 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101a04:	83 ec 0c             	sub    $0xc,%esp
f0101a07:	6a 00                	push   $0x0
f0101a09:	e8 78 f9 ff ff       	call   f0101386 <page_alloc>
f0101a0e:	83 c4 10             	add    $0x10,%esp
f0101a11:	85 c0                	test   %eax,%eax
f0101a13:	74 19                	je     f0101a2e <mem_init+0x3d1>
f0101a15:	68 94 4f 10 f0       	push   $0xf0104f94
f0101a1a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101a1f:	68 75 02 00 00       	push   $0x275
f0101a24:	68 18 4e 10 f0       	push   $0xf0104e18
f0101a29:	e8 5d e6 ff ff       	call   f010008b <_panic>
f0101a2e:	89 f0                	mov    %esi,%eax
f0101a30:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0101a36:	c1 f8 03             	sar    $0x3,%eax
f0101a39:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a3c:	89 c2                	mov    %eax,%edx
f0101a3e:	c1 ea 0c             	shr    $0xc,%edx
f0101a41:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0101a47:	72 12                	jb     f0101a5b <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a49:	50                   	push   %eax
f0101a4a:	68 20 47 10 f0       	push   $0xf0104720
f0101a4f:	6a 52                	push   $0x52
f0101a51:	68 24 4e 10 f0       	push   $0xf0104e24
f0101a56:	e8 30 e6 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a5b:	83 ec 04             	sub    $0x4,%esp
f0101a5e:	68 00 10 00 00       	push   $0x1000
f0101a63:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a6a:	50                   	push   %eax
f0101a6b:	e8 89 1d 00 00       	call   f01037f9 <memset>
	page_free(pp0);
f0101a70:	89 34 24             	mov    %esi,(%esp)
f0101a73:	e8 98 f9 ff ff       	call   f0101410 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a7f:	e8 02 f9 ff ff       	call   f0101386 <page_alloc>
f0101a84:	83 c4 10             	add    $0x10,%esp
f0101a87:	85 c0                	test   %eax,%eax
f0101a89:	75 19                	jne    f0101aa4 <mem_init+0x447>
f0101a8b:	68 a3 4f 10 f0       	push   $0xf0104fa3
f0101a90:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101a95:	68 7a 02 00 00       	push   $0x27a
f0101a9a:	68 18 4e 10 f0       	push   $0xf0104e18
f0101a9f:	e8 e7 e5 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101aa4:	39 c6                	cmp    %eax,%esi
f0101aa6:	74 19                	je     f0101ac1 <mem_init+0x464>
f0101aa8:	68 c1 4f 10 f0       	push   $0xf0104fc1
f0101aad:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101ab2:	68 7b 02 00 00       	push   $0x27b
f0101ab7:	68 18 4e 10 f0       	push   $0xf0104e18
f0101abc:	e8 ca e5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ac1:	89 f2                	mov    %esi,%edx
f0101ac3:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101ac9:	c1 fa 03             	sar    $0x3,%edx
f0101acc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101acf:	89 d0                	mov    %edx,%eax
f0101ad1:	c1 e8 0c             	shr    $0xc,%eax
f0101ad4:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f0101ada:	72 12                	jb     f0101aee <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101adc:	52                   	push   %edx
f0101add:	68 20 47 10 f0       	push   $0xf0104720
f0101ae2:	6a 52                	push   $0x52
f0101ae4:	68 24 4e 10 f0       	push   $0xf0104e24
f0101ae9:	e8 9d e5 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101aee:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101af5:	75 11                	jne    f0101b08 <mem_init+0x4ab>
f0101af7:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101afd:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b03:	80 38 00             	cmpb   $0x0,(%eax)
f0101b06:	74 19                	je     f0101b21 <mem_init+0x4c4>
f0101b08:	68 d1 4f 10 f0       	push   $0xf0104fd1
f0101b0d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101b12:	68 7e 02 00 00       	push   $0x27e
f0101b17:	68 18 4e 10 f0       	push   $0xf0104e18
f0101b1c:	e8 6a e5 ff ff       	call   f010008b <_panic>
f0101b21:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b22:	39 d0                	cmp    %edx,%eax
f0101b24:	75 dd                	jne    f0101b03 <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b26:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101b29:	89 15 2c f5 11 f0    	mov    %edx,0xf011f52c

	// free the pages we took
	page_free(pp0);
f0101b2f:	83 ec 0c             	sub    $0xc,%esp
f0101b32:	56                   	push   %esi
f0101b33:	e8 d8 f8 ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f0101b38:	89 3c 24             	mov    %edi,(%esp)
f0101b3b:	e8 d0 f8 ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0101b40:	83 c4 04             	add    $0x4,%esp
f0101b43:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b46:	e8 c5 f8 ff ff       	call   f0101410 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b4b:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101b50:	83 c4 10             	add    $0x10,%esp
f0101b53:	85 c0                	test   %eax,%eax
f0101b55:	74 07                	je     f0101b5e <mem_init+0x501>
		--nfree;
f0101b57:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b58:	8b 00                	mov    (%eax),%eax
f0101b5a:	85 c0                	test   %eax,%eax
f0101b5c:	75 f9                	jne    f0101b57 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101b5e:	85 db                	test   %ebx,%ebx
f0101b60:	74 19                	je     f0101b7b <mem_init+0x51e>
f0101b62:	68 db 4f 10 f0       	push   $0xf0104fdb
f0101b67:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101b6c:	68 8b 02 00 00       	push   $0x28b
f0101b71:	68 18 4e 10 f0       	push   $0xf0104e18
f0101b76:	e8 10 e5 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b7b:	83 ec 0c             	sub    $0xc,%esp
f0101b7e:	68 84 48 10 f0       	push   $0xf0104884
f0101b83:	e8 41 11 00 00       	call   f0102cc9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b8f:	e8 f2 f7 ff ff       	call   f0101386 <page_alloc>
f0101b94:	89 c6                	mov    %eax,%esi
f0101b96:	83 c4 10             	add    $0x10,%esp
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	75 19                	jne    f0101bb6 <mem_init+0x559>
f0101b9d:	68 e9 4e 10 f0       	push   $0xf0104ee9
f0101ba2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101ba7:	68 e4 02 00 00       	push   $0x2e4
f0101bac:	68 18 4e 10 f0       	push   $0xf0104e18
f0101bb1:	e8 d5 e4 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101bb6:	83 ec 0c             	sub    $0xc,%esp
f0101bb9:	6a 00                	push   $0x0
f0101bbb:	e8 c6 f7 ff ff       	call   f0101386 <page_alloc>
f0101bc0:	89 c7                	mov    %eax,%edi
f0101bc2:	83 c4 10             	add    $0x10,%esp
f0101bc5:	85 c0                	test   %eax,%eax
f0101bc7:	75 19                	jne    f0101be2 <mem_init+0x585>
f0101bc9:	68 ff 4e 10 f0       	push   $0xf0104eff
f0101bce:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101bd3:	68 e5 02 00 00       	push   $0x2e5
f0101bd8:	68 18 4e 10 f0       	push   $0xf0104e18
f0101bdd:	e8 a9 e4 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101be2:	83 ec 0c             	sub    $0xc,%esp
f0101be5:	6a 00                	push   $0x0
f0101be7:	e8 9a f7 ff ff       	call   f0101386 <page_alloc>
f0101bec:	89 c3                	mov    %eax,%ebx
f0101bee:	83 c4 10             	add    $0x10,%esp
f0101bf1:	85 c0                	test   %eax,%eax
f0101bf3:	75 19                	jne    f0101c0e <mem_init+0x5b1>
f0101bf5:	68 15 4f 10 f0       	push   $0xf0104f15
f0101bfa:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101bff:	68 e6 02 00 00       	push   $0x2e6
f0101c04:	68 18 4e 10 f0       	push   $0xf0104e18
f0101c09:	e8 7d e4 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c0e:	39 fe                	cmp    %edi,%esi
f0101c10:	75 19                	jne    f0101c2b <mem_init+0x5ce>
f0101c12:	68 2b 4f 10 f0       	push   $0xf0104f2b
f0101c17:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101c1c:	68 e9 02 00 00       	push   $0x2e9
f0101c21:	68 18 4e 10 f0       	push   $0xf0104e18
f0101c26:	e8 60 e4 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c2b:	39 c7                	cmp    %eax,%edi
f0101c2d:	74 04                	je     f0101c33 <mem_init+0x5d6>
f0101c2f:	39 c6                	cmp    %eax,%esi
f0101c31:	75 19                	jne    f0101c4c <mem_init+0x5ef>
f0101c33:	68 64 48 10 f0       	push   $0xf0104864
f0101c38:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101c3d:	68 ea 02 00 00       	push   $0x2ea
f0101c42:	68 18 4e 10 f0       	push   $0xf0104e18
f0101c47:	e8 3f e4 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c4c:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f0101c52:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101c55:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f0101c5c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c5f:	83 ec 0c             	sub    $0xc,%esp
f0101c62:	6a 00                	push   $0x0
f0101c64:	e8 1d f7 ff ff       	call   f0101386 <page_alloc>
f0101c69:	83 c4 10             	add    $0x10,%esp
f0101c6c:	85 c0                	test   %eax,%eax
f0101c6e:	74 19                	je     f0101c89 <mem_init+0x62c>
f0101c70:	68 94 4f 10 f0       	push   $0xf0104f94
f0101c75:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101c7a:	68 f1 02 00 00       	push   $0x2f1
f0101c7f:	68 18 4e 10 f0       	push   $0xf0104e18
f0101c84:	e8 02 e4 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c89:	83 ec 04             	sub    $0x4,%esp
f0101c8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c8f:	50                   	push   %eax
f0101c90:	6a 00                	push   $0x0
f0101c92:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101c98:	e8 99 f8 ff ff       	call   f0101536 <page_lookup>
f0101c9d:	83 c4 10             	add    $0x10,%esp
f0101ca0:	85 c0                	test   %eax,%eax
f0101ca2:	74 19                	je     f0101cbd <mem_init+0x660>
f0101ca4:	68 a4 48 10 f0       	push   $0xf01048a4
f0101ca9:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101cae:	68 f4 02 00 00       	push   $0x2f4
f0101cb3:	68 18 4e 10 f0       	push   $0xf0104e18
f0101cb8:	e8 ce e3 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cbd:	6a 02                	push   $0x2
f0101cbf:	6a 00                	push   $0x0
f0101cc1:	57                   	push   %edi
f0101cc2:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101cc8:	e8 27 f9 ff ff       	call   f01015f4 <page_insert>
f0101ccd:	83 c4 10             	add    $0x10,%esp
f0101cd0:	85 c0                	test   %eax,%eax
f0101cd2:	78 19                	js     f0101ced <mem_init+0x690>
f0101cd4:	68 dc 48 10 f0       	push   $0xf01048dc
f0101cd9:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101cde:	68 f7 02 00 00       	push   $0x2f7
f0101ce3:	68 18 4e 10 f0       	push   $0xf0104e18
f0101ce8:	e8 9e e3 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ced:	83 ec 0c             	sub    $0xc,%esp
f0101cf0:	56                   	push   %esi
f0101cf1:	e8 1a f7 ff ff       	call   f0101410 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cf6:	6a 02                	push   $0x2
f0101cf8:	6a 00                	push   $0x0
f0101cfa:	57                   	push   %edi
f0101cfb:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d01:	e8 ee f8 ff ff       	call   f01015f4 <page_insert>
f0101d06:	83 c4 20             	add    $0x20,%esp
f0101d09:	85 c0                	test   %eax,%eax
f0101d0b:	74 19                	je     f0101d26 <mem_init+0x6c9>
f0101d0d:	68 0c 49 10 f0       	push   $0xf010490c
f0101d12:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101d17:	68 fb 02 00 00       	push   $0x2fb
f0101d1c:	68 18 4e 10 f0       	push   $0xf0104e18
f0101d21:	e8 65 e3 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d26:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101d2b:	8b 08                	mov    (%eax),%ecx
f0101d2d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d33:	89 f2                	mov    %esi,%edx
f0101d35:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101d3b:	c1 fa 03             	sar    $0x3,%edx
f0101d3e:	c1 e2 0c             	shl    $0xc,%edx
f0101d41:	39 d1                	cmp    %edx,%ecx
f0101d43:	74 19                	je     f0101d5e <mem_init+0x701>
f0101d45:	68 3c 49 10 f0       	push   $0xf010493c
f0101d4a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101d4f:	68 fc 02 00 00       	push   $0x2fc
f0101d54:	68 18 4e 10 f0       	push   $0xf0104e18
f0101d59:	e8 2d e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d63:	e8 2f f2 ff ff       	call   f0100f97 <check_va2pa>
f0101d68:	89 fa                	mov    %edi,%edx
f0101d6a:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101d70:	c1 fa 03             	sar    $0x3,%edx
f0101d73:	c1 e2 0c             	shl    $0xc,%edx
f0101d76:	39 d0                	cmp    %edx,%eax
f0101d78:	74 19                	je     f0101d93 <mem_init+0x736>
f0101d7a:	68 64 49 10 f0       	push   $0xf0104964
f0101d7f:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101d84:	68 fd 02 00 00       	push   $0x2fd
f0101d89:	68 18 4e 10 f0       	push   $0xf0104e18
f0101d8e:	e8 f8 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d93:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d98:	74 19                	je     f0101db3 <mem_init+0x756>
f0101d9a:	68 e6 4f 10 f0       	push   $0xf0104fe6
f0101d9f:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101da4:	68 fe 02 00 00       	push   $0x2fe
f0101da9:	68 18 4e 10 f0       	push   $0xf0104e18
f0101dae:	e8 d8 e2 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101db3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101db8:	74 19                	je     f0101dd3 <mem_init+0x776>
f0101dba:	68 f7 4f 10 f0       	push   $0xf0104ff7
f0101dbf:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101dc4:	68 ff 02 00 00       	push   $0x2ff
f0101dc9:	68 18 4e 10 f0       	push   $0xf0104e18
f0101dce:	e8 b8 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dd3:	6a 02                	push   $0x2
f0101dd5:	68 00 10 00 00       	push   $0x1000
f0101dda:	53                   	push   %ebx
f0101ddb:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101de1:	e8 0e f8 ff ff       	call   f01015f4 <page_insert>
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	85 c0                	test   %eax,%eax
f0101deb:	74 19                	je     f0101e06 <mem_init+0x7a9>
f0101ded:	68 94 49 10 f0       	push   $0xf0104994
f0101df2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101df7:	68 02 03 00 00       	push   $0x302
f0101dfc:	68 18 4e 10 f0       	push   $0xf0104e18
f0101e01:	e8 85 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e06:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0b:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101e10:	e8 82 f1 ff ff       	call   f0100f97 <check_va2pa>
f0101e15:	89 da                	mov    %ebx,%edx
f0101e17:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101e1d:	c1 fa 03             	sar    $0x3,%edx
f0101e20:	c1 e2 0c             	shl    $0xc,%edx
f0101e23:	39 d0                	cmp    %edx,%eax
f0101e25:	74 19                	je     f0101e40 <mem_init+0x7e3>
f0101e27:	68 d0 49 10 f0       	push   $0xf01049d0
f0101e2c:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101e31:	68 03 03 00 00       	push   $0x303
f0101e36:	68 18 4e 10 f0       	push   $0xf0104e18
f0101e3b:	e8 4b e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e40:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e45:	74 19                	je     f0101e60 <mem_init+0x803>
f0101e47:	68 08 50 10 f0       	push   $0xf0105008
f0101e4c:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101e51:	68 04 03 00 00       	push   $0x304
f0101e56:	68 18 4e 10 f0       	push   $0xf0104e18
f0101e5b:	e8 2b e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e60:	83 ec 0c             	sub    $0xc,%esp
f0101e63:	6a 00                	push   $0x0
f0101e65:	e8 1c f5 ff ff       	call   f0101386 <page_alloc>
f0101e6a:	83 c4 10             	add    $0x10,%esp
f0101e6d:	85 c0                	test   %eax,%eax
f0101e6f:	74 19                	je     f0101e8a <mem_init+0x82d>
f0101e71:	68 94 4f 10 f0       	push   $0xf0104f94
f0101e76:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101e7b:	68 07 03 00 00       	push   $0x307
f0101e80:	68 18 4e 10 f0       	push   $0xf0104e18
f0101e85:	e8 01 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e8a:	6a 02                	push   $0x2
f0101e8c:	68 00 10 00 00       	push   $0x1000
f0101e91:	53                   	push   %ebx
f0101e92:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101e98:	e8 57 f7 ff ff       	call   f01015f4 <page_insert>
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	74 19                	je     f0101ebd <mem_init+0x860>
f0101ea4:	68 94 49 10 f0       	push   $0xf0104994
f0101ea9:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101eae:	68 0a 03 00 00       	push   $0x30a
f0101eb3:	68 18 4e 10 f0       	push   $0xf0104e18
f0101eb8:	e8 ce e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ebd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ec2:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101ec7:	e8 cb f0 ff ff       	call   f0100f97 <check_va2pa>
f0101ecc:	89 da                	mov    %ebx,%edx
f0101ece:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101ed4:	c1 fa 03             	sar    $0x3,%edx
f0101ed7:	c1 e2 0c             	shl    $0xc,%edx
f0101eda:	39 d0                	cmp    %edx,%eax
f0101edc:	74 19                	je     f0101ef7 <mem_init+0x89a>
f0101ede:	68 d0 49 10 f0       	push   $0xf01049d0
f0101ee3:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101ee8:	68 0b 03 00 00       	push   $0x30b
f0101eed:	68 18 4e 10 f0       	push   $0xf0104e18
f0101ef2:	e8 94 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101ef7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101efc:	74 19                	je     f0101f17 <mem_init+0x8ba>
f0101efe:	68 08 50 10 f0       	push   $0xf0105008
f0101f03:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101f08:	68 0c 03 00 00       	push   $0x30c
f0101f0d:	68 18 4e 10 f0       	push   $0xf0104e18
f0101f12:	e8 74 e1 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f17:	83 ec 0c             	sub    $0xc,%esp
f0101f1a:	6a 00                	push   $0x0
f0101f1c:	e8 65 f4 ff ff       	call   f0101386 <page_alloc>
f0101f21:	83 c4 10             	add    $0x10,%esp
f0101f24:	85 c0                	test   %eax,%eax
f0101f26:	74 19                	je     f0101f41 <mem_init+0x8e4>
f0101f28:	68 94 4f 10 f0       	push   $0xf0104f94
f0101f2d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101f32:	68 10 03 00 00       	push   $0x310
f0101f37:	68 18 4e 10 f0       	push   $0xf0104e18
f0101f3c:	e8 4a e1 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f41:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f0101f47:	8b 02                	mov    (%edx),%eax
f0101f49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f4e:	89 c1                	mov    %eax,%ecx
f0101f50:	c1 e9 0c             	shr    $0xc,%ecx
f0101f53:	3b 0d 44 f9 11 f0    	cmp    0xf011f944,%ecx
f0101f59:	72 15                	jb     f0101f70 <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f5b:	50                   	push   %eax
f0101f5c:	68 20 47 10 f0       	push   $0xf0104720
f0101f61:	68 13 03 00 00       	push   $0x313
f0101f66:	68 18 4e 10 f0       	push   $0xf0104e18
f0101f6b:	e8 1b e1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101f70:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f78:	83 ec 04             	sub    $0x4,%esp
f0101f7b:	6a 00                	push   $0x0
f0101f7d:	68 00 10 00 00       	push   $0x1000
f0101f82:	52                   	push   %edx
f0101f83:	e8 c6 f4 ff ff       	call   f010144e <pgdir_walk>
f0101f88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f8b:	83 c2 04             	add    $0x4,%edx
f0101f8e:	83 c4 10             	add    $0x10,%esp
f0101f91:	39 d0                	cmp    %edx,%eax
f0101f93:	74 19                	je     f0101fae <mem_init+0x951>
f0101f95:	68 00 4a 10 f0       	push   $0xf0104a00
f0101f9a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101f9f:	68 14 03 00 00       	push   $0x314
f0101fa4:	68 18 4e 10 f0       	push   $0xf0104e18
f0101fa9:	e8 dd e0 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fae:	6a 06                	push   $0x6
f0101fb0:	68 00 10 00 00       	push   $0x1000
f0101fb5:	53                   	push   %ebx
f0101fb6:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101fbc:	e8 33 f6 ff ff       	call   f01015f4 <page_insert>
f0101fc1:	83 c4 10             	add    $0x10,%esp
f0101fc4:	85 c0                	test   %eax,%eax
f0101fc6:	74 19                	je     f0101fe1 <mem_init+0x984>
f0101fc8:	68 40 4a 10 f0       	push   $0xf0104a40
f0101fcd:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0101fd2:	68 17 03 00 00       	push   $0x317
f0101fd7:	68 18 4e 10 f0       	push   $0xf0104e18
f0101fdc:	e8 aa e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fe1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe6:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101feb:	e8 a7 ef ff ff       	call   f0100f97 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ff0:	89 da                	mov    %ebx,%edx
f0101ff2:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101ff8:	c1 fa 03             	sar    $0x3,%edx
f0101ffb:	c1 e2 0c             	shl    $0xc,%edx
f0101ffe:	39 d0                	cmp    %edx,%eax
f0102000:	74 19                	je     f010201b <mem_init+0x9be>
f0102002:	68 d0 49 10 f0       	push   $0xf01049d0
f0102007:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010200c:	68 18 03 00 00       	push   $0x318
f0102011:	68 18 4e 10 f0       	push   $0xf0104e18
f0102016:	e8 70 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010201b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102020:	74 19                	je     f010203b <mem_init+0x9de>
f0102022:	68 08 50 10 f0       	push   $0xf0105008
f0102027:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010202c:	68 19 03 00 00       	push   $0x319
f0102031:	68 18 4e 10 f0       	push   $0xf0104e18
f0102036:	e8 50 e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010203b:	83 ec 04             	sub    $0x4,%esp
f010203e:	6a 00                	push   $0x0
f0102040:	68 00 10 00 00       	push   $0x1000
f0102045:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010204b:	e8 fe f3 ff ff       	call   f010144e <pgdir_walk>
f0102050:	83 c4 10             	add    $0x10,%esp
f0102053:	f6 00 04             	testb  $0x4,(%eax)
f0102056:	75 19                	jne    f0102071 <mem_init+0xa14>
f0102058:	68 80 4a 10 f0       	push   $0xf0104a80
f010205d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102062:	68 1a 03 00 00       	push   $0x31a
f0102067:	68 18 4e 10 f0       	push   $0xf0104e18
f010206c:	e8 1a e0 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102071:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102076:	f6 00 04             	testb  $0x4,(%eax)
f0102079:	75 19                	jne    f0102094 <mem_init+0xa37>
f010207b:	68 19 50 10 f0       	push   $0xf0105019
f0102080:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102085:	68 1b 03 00 00       	push   $0x31b
f010208a:	68 18 4e 10 f0       	push   $0xf0104e18
f010208f:	e8 f7 df ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102094:	6a 02                	push   $0x2
f0102096:	68 00 10 00 00       	push   $0x1000
f010209b:	53                   	push   %ebx
f010209c:	50                   	push   %eax
f010209d:	e8 52 f5 ff ff       	call   f01015f4 <page_insert>
f01020a2:	83 c4 10             	add    $0x10,%esp
f01020a5:	85 c0                	test   %eax,%eax
f01020a7:	74 19                	je     f01020c2 <mem_init+0xa65>
f01020a9:	68 94 49 10 f0       	push   $0xf0104994
f01020ae:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01020b3:	68 1e 03 00 00       	push   $0x31e
f01020b8:	68 18 4e 10 f0       	push   $0xf0104e18
f01020bd:	e8 c9 df ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020c2:	83 ec 04             	sub    $0x4,%esp
f01020c5:	6a 00                	push   $0x0
f01020c7:	68 00 10 00 00       	push   $0x1000
f01020cc:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01020d2:	e8 77 f3 ff ff       	call   f010144e <pgdir_walk>
f01020d7:	83 c4 10             	add    $0x10,%esp
f01020da:	f6 00 02             	testb  $0x2,(%eax)
f01020dd:	75 19                	jne    f01020f8 <mem_init+0xa9b>
f01020df:	68 b4 4a 10 f0       	push   $0xf0104ab4
f01020e4:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01020e9:	68 1f 03 00 00       	push   $0x31f
f01020ee:	68 18 4e 10 f0       	push   $0xf0104e18
f01020f3:	e8 93 df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020f8:	83 ec 04             	sub    $0x4,%esp
f01020fb:	6a 00                	push   $0x0
f01020fd:	68 00 10 00 00       	push   $0x1000
f0102102:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102108:	e8 41 f3 ff ff       	call   f010144e <pgdir_walk>
f010210d:	83 c4 10             	add    $0x10,%esp
f0102110:	f6 00 04             	testb  $0x4,(%eax)
f0102113:	74 19                	je     f010212e <mem_init+0xad1>
f0102115:	68 e8 4a 10 f0       	push   $0xf0104ae8
f010211a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010211f:	68 20 03 00 00       	push   $0x320
f0102124:	68 18 4e 10 f0       	push   $0xf0104e18
f0102129:	e8 5d df ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010212e:	6a 02                	push   $0x2
f0102130:	68 00 00 40 00       	push   $0x400000
f0102135:	56                   	push   %esi
f0102136:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010213c:	e8 b3 f4 ff ff       	call   f01015f4 <page_insert>
f0102141:	83 c4 10             	add    $0x10,%esp
f0102144:	85 c0                	test   %eax,%eax
f0102146:	78 19                	js     f0102161 <mem_init+0xb04>
f0102148:	68 20 4b 10 f0       	push   $0xf0104b20
f010214d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102152:	68 23 03 00 00       	push   $0x323
f0102157:	68 18 4e 10 f0       	push   $0xf0104e18
f010215c:	e8 2a df ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102161:	6a 02                	push   $0x2
f0102163:	68 00 10 00 00       	push   $0x1000
f0102168:	57                   	push   %edi
f0102169:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010216f:	e8 80 f4 ff ff       	call   f01015f4 <page_insert>
f0102174:	83 c4 10             	add    $0x10,%esp
f0102177:	85 c0                	test   %eax,%eax
f0102179:	74 19                	je     f0102194 <mem_init+0xb37>
f010217b:	68 58 4b 10 f0       	push   $0xf0104b58
f0102180:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102185:	68 26 03 00 00       	push   $0x326
f010218a:	68 18 4e 10 f0       	push   $0xf0104e18
f010218f:	e8 f7 de ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102194:	83 ec 04             	sub    $0x4,%esp
f0102197:	6a 00                	push   $0x0
f0102199:	68 00 10 00 00       	push   $0x1000
f010219e:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01021a4:	e8 a5 f2 ff ff       	call   f010144e <pgdir_walk>
f01021a9:	83 c4 10             	add    $0x10,%esp
f01021ac:	f6 00 04             	testb  $0x4,(%eax)
f01021af:	74 19                	je     f01021ca <mem_init+0xb6d>
f01021b1:	68 e8 4a 10 f0       	push   $0xf0104ae8
f01021b6:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01021bb:	68 27 03 00 00       	push   $0x327
f01021c0:	68 18 4e 10 f0       	push   $0xf0104e18
f01021c5:	e8 c1 de ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01021cf:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01021d4:	e8 be ed ff ff       	call   f0100f97 <check_va2pa>
f01021d9:	89 fa                	mov    %edi,%edx
f01021db:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f01021e1:	c1 fa 03             	sar    $0x3,%edx
f01021e4:	c1 e2 0c             	shl    $0xc,%edx
f01021e7:	39 d0                	cmp    %edx,%eax
f01021e9:	74 19                	je     f0102204 <mem_init+0xba7>
f01021eb:	68 94 4b 10 f0       	push   $0xf0104b94
f01021f0:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01021f5:	68 2a 03 00 00       	push   $0x32a
f01021fa:	68 18 4e 10 f0       	push   $0xf0104e18
f01021ff:	e8 87 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102204:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102209:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010220e:	e8 84 ed ff ff       	call   f0100f97 <check_va2pa>
f0102213:	89 fa                	mov    %edi,%edx
f0102215:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f010221b:	c1 fa 03             	sar    $0x3,%edx
f010221e:	c1 e2 0c             	shl    $0xc,%edx
f0102221:	39 d0                	cmp    %edx,%eax
f0102223:	74 19                	je     f010223e <mem_init+0xbe1>
f0102225:	68 c0 4b 10 f0       	push   $0xf0104bc0
f010222a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010222f:	68 2b 03 00 00       	push   $0x32b
f0102234:	68 18 4e 10 f0       	push   $0xf0104e18
f0102239:	e8 4d de ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010223e:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102243:	74 19                	je     f010225e <mem_init+0xc01>
f0102245:	68 2f 50 10 f0       	push   $0xf010502f
f010224a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010224f:	68 2d 03 00 00       	push   $0x32d
f0102254:	68 18 4e 10 f0       	push   $0xf0104e18
f0102259:	e8 2d de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f010225e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102263:	74 19                	je     f010227e <mem_init+0xc21>
f0102265:	68 40 50 10 f0       	push   $0xf0105040
f010226a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010226f:	68 2e 03 00 00       	push   $0x32e
f0102274:	68 18 4e 10 f0       	push   $0xf0104e18
f0102279:	e8 0d de ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010227e:	83 ec 0c             	sub    $0xc,%esp
f0102281:	6a 00                	push   $0x0
f0102283:	e8 fe f0 ff ff       	call   f0101386 <page_alloc>
f0102288:	83 c4 10             	add    $0x10,%esp
f010228b:	85 c0                	test   %eax,%eax
f010228d:	74 04                	je     f0102293 <mem_init+0xc36>
f010228f:	39 c3                	cmp    %eax,%ebx
f0102291:	74 19                	je     f01022ac <mem_init+0xc4f>
f0102293:	68 f0 4b 10 f0       	push   $0xf0104bf0
f0102298:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010229d:	68 31 03 00 00       	push   $0x331
f01022a2:	68 18 4e 10 f0       	push   $0xf0104e18
f01022a7:	e8 df dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022ac:	83 ec 08             	sub    $0x8,%esp
f01022af:	6a 00                	push   $0x0
f01022b1:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01022b7:	e8 eb f2 ff ff       	call   f01015a7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01022c1:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01022c6:	e8 cc ec ff ff       	call   f0100f97 <check_va2pa>
f01022cb:	83 c4 10             	add    $0x10,%esp
f01022ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022d1:	74 19                	je     f01022ec <mem_init+0xc8f>
f01022d3:	68 14 4c 10 f0       	push   $0xf0104c14
f01022d8:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01022dd:	68 35 03 00 00       	push   $0x335
f01022e2:	68 18 4e 10 f0       	push   $0xf0104e18
f01022e7:	e8 9f dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022ec:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f1:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01022f6:	e8 9c ec ff ff       	call   f0100f97 <check_va2pa>
f01022fb:	89 fa                	mov    %edi,%edx
f01022fd:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102303:	c1 fa 03             	sar    $0x3,%edx
f0102306:	c1 e2 0c             	shl    $0xc,%edx
f0102309:	39 d0                	cmp    %edx,%eax
f010230b:	74 19                	je     f0102326 <mem_init+0xcc9>
f010230d:	68 c0 4b 10 f0       	push   $0xf0104bc0
f0102312:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102317:	68 36 03 00 00       	push   $0x336
f010231c:	68 18 4e 10 f0       	push   $0xf0104e18
f0102321:	e8 65 dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102326:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010232b:	74 19                	je     f0102346 <mem_init+0xce9>
f010232d:	68 e6 4f 10 f0       	push   $0xf0104fe6
f0102332:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102337:	68 37 03 00 00       	push   $0x337
f010233c:	68 18 4e 10 f0       	push   $0xf0104e18
f0102341:	e8 45 dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102346:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010234b:	74 19                	je     f0102366 <mem_init+0xd09>
f010234d:	68 40 50 10 f0       	push   $0xf0105040
f0102352:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102357:	68 38 03 00 00       	push   $0x338
f010235c:	68 18 4e 10 f0       	push   $0xf0104e18
f0102361:	e8 25 dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102366:	83 ec 08             	sub    $0x8,%esp
f0102369:	68 00 10 00 00       	push   $0x1000
f010236e:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102374:	e8 2e f2 ff ff       	call   f01015a7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102379:	ba 00 00 00 00       	mov    $0x0,%edx
f010237e:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102383:	e8 0f ec ff ff       	call   f0100f97 <check_va2pa>
f0102388:	83 c4 10             	add    $0x10,%esp
f010238b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010238e:	74 19                	je     f01023a9 <mem_init+0xd4c>
f0102390:	68 14 4c 10 f0       	push   $0xf0104c14
f0102395:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010239a:	68 3c 03 00 00       	push   $0x33c
f010239f:	68 18 4e 10 f0       	push   $0xf0104e18
f01023a4:	e8 e2 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01023a9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ae:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01023b3:	e8 df eb ff ff       	call   f0100f97 <check_va2pa>
f01023b8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023bb:	74 19                	je     f01023d6 <mem_init+0xd79>
f01023bd:	68 38 4c 10 f0       	push   $0xf0104c38
f01023c2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01023c7:	68 3d 03 00 00       	push   $0x33d
f01023cc:	68 18 4e 10 f0       	push   $0xf0104e18
f01023d1:	e8 b5 dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01023d6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01023db:	74 19                	je     f01023f6 <mem_init+0xd99>
f01023dd:	68 51 50 10 f0       	push   $0xf0105051
f01023e2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01023e7:	68 3e 03 00 00       	push   $0x33e
f01023ec:	68 18 4e 10 f0       	push   $0xf0104e18
f01023f1:	e8 95 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01023f6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023fb:	74 19                	je     f0102416 <mem_init+0xdb9>
f01023fd:	68 40 50 10 f0       	push   $0xf0105040
f0102402:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102407:	68 3f 03 00 00       	push   $0x33f
f010240c:	68 18 4e 10 f0       	push   $0xf0104e18
f0102411:	e8 75 dc ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102416:	83 ec 0c             	sub    $0xc,%esp
f0102419:	6a 00                	push   $0x0
f010241b:	e8 66 ef ff ff       	call   f0101386 <page_alloc>
f0102420:	83 c4 10             	add    $0x10,%esp
f0102423:	85 c0                	test   %eax,%eax
f0102425:	74 04                	je     f010242b <mem_init+0xdce>
f0102427:	39 c7                	cmp    %eax,%edi
f0102429:	74 19                	je     f0102444 <mem_init+0xde7>
f010242b:	68 60 4c 10 f0       	push   $0xf0104c60
f0102430:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102435:	68 42 03 00 00       	push   $0x342
f010243a:	68 18 4e 10 f0       	push   $0xf0104e18
f010243f:	e8 47 dc ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102444:	83 ec 0c             	sub    $0xc,%esp
f0102447:	6a 00                	push   $0x0
f0102449:	e8 38 ef ff ff       	call   f0101386 <page_alloc>
f010244e:	83 c4 10             	add    $0x10,%esp
f0102451:	85 c0                	test   %eax,%eax
f0102453:	74 19                	je     f010246e <mem_init+0xe11>
f0102455:	68 94 4f 10 f0       	push   $0xf0104f94
f010245a:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010245f:	68 45 03 00 00       	push   $0x345
f0102464:	68 18 4e 10 f0       	push   $0xf0104e18
f0102469:	e8 1d dc ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010246e:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102473:	8b 08                	mov    (%eax),%ecx
f0102475:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010247b:	89 f2                	mov    %esi,%edx
f010247d:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102483:	c1 fa 03             	sar    $0x3,%edx
f0102486:	c1 e2 0c             	shl    $0xc,%edx
f0102489:	39 d1                	cmp    %edx,%ecx
f010248b:	74 19                	je     f01024a6 <mem_init+0xe49>
f010248d:	68 3c 49 10 f0       	push   $0xf010493c
f0102492:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102497:	68 48 03 00 00       	push   $0x348
f010249c:	68 18 4e 10 f0       	push   $0xf0104e18
f01024a1:	e8 e5 db ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01024a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01024ac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024b1:	74 19                	je     f01024cc <mem_init+0xe6f>
f01024b3:	68 f7 4f 10 f0       	push   $0xf0104ff7
f01024b8:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01024bd:	68 4a 03 00 00       	push   $0x34a
f01024c2:	68 18 4e 10 f0       	push   $0xf0104e18
f01024c7:	e8 bf db ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01024cc:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01024d2:	83 ec 0c             	sub    $0xc,%esp
f01024d5:	56                   	push   %esi
f01024d6:	e8 35 ef ff ff       	call   f0101410 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01024db:	83 c4 0c             	add    $0xc,%esp
f01024de:	6a 01                	push   $0x1
f01024e0:	68 00 10 40 00       	push   $0x401000
f01024e5:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01024eb:	e8 5e ef ff ff       	call   f010144e <pgdir_walk>
f01024f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01024f3:	8b 0d 48 f9 11 f0    	mov    0xf011f948,%ecx
f01024f9:	8b 51 04             	mov    0x4(%ecx),%edx
f01024fc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102502:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102505:	c1 ea 0c             	shr    $0xc,%edx
f0102508:	83 c4 10             	add    $0x10,%esp
f010250b:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102511:	72 17                	jb     f010252a <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102513:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102516:	68 20 47 10 f0       	push   $0xf0104720
f010251b:	68 51 03 00 00       	push   $0x351
f0102520:	68 18 4e 10 f0       	push   $0xf0104e18
f0102525:	e8 61 db ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010252a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010252d:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102533:	39 d0                	cmp    %edx,%eax
f0102535:	74 19                	je     f0102550 <mem_init+0xef3>
f0102537:	68 62 50 10 f0       	push   $0xf0105062
f010253c:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102541:	68 52 03 00 00       	push   $0x352
f0102546:	68 18 4e 10 f0       	push   $0xf0104e18
f010254b:	e8 3b db ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102550:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102557:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010255d:	89 f0                	mov    %esi,%eax
f010255f:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102565:	c1 f8 03             	sar    $0x3,%eax
f0102568:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010256b:	89 c2                	mov    %eax,%edx
f010256d:	c1 ea 0c             	shr    $0xc,%edx
f0102570:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102576:	72 12                	jb     f010258a <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102578:	50                   	push   %eax
f0102579:	68 20 47 10 f0       	push   $0xf0104720
f010257e:	6a 52                	push   $0x52
f0102580:	68 24 4e 10 f0       	push   $0xf0104e24
f0102585:	e8 01 db ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010258a:	83 ec 04             	sub    $0x4,%esp
f010258d:	68 00 10 00 00       	push   $0x1000
f0102592:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102597:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010259c:	50                   	push   %eax
f010259d:	e8 57 12 00 00       	call   f01037f9 <memset>
	page_free(pp0);
f01025a2:	89 34 24             	mov    %esi,(%esp)
f01025a5:	e8 66 ee ff ff       	call   f0101410 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01025aa:	83 c4 0c             	add    $0xc,%esp
f01025ad:	6a 01                	push   $0x1
f01025af:	6a 00                	push   $0x0
f01025b1:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01025b7:	e8 92 ee ff ff       	call   f010144e <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025bc:	89 f2                	mov    %esi,%edx
f01025be:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f01025c4:	c1 fa 03             	sar    $0x3,%edx
f01025c7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025ca:	89 d0                	mov    %edx,%eax
f01025cc:	c1 e8 0c             	shr    $0xc,%eax
f01025cf:	83 c4 10             	add    $0x10,%esp
f01025d2:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f01025d8:	72 12                	jb     f01025ec <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025da:	52                   	push   %edx
f01025db:	68 20 47 10 f0       	push   $0xf0104720
f01025e0:	6a 52                	push   $0x52
f01025e2:	68 24 4e 10 f0       	push   $0xf0104e24
f01025e7:	e8 9f da ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01025ec:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025f5:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01025fc:	75 11                	jne    f010260f <mem_init+0xfb2>
f01025fe:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102604:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010260a:	f6 00 01             	testb  $0x1,(%eax)
f010260d:	74 19                	je     f0102628 <mem_init+0xfcb>
f010260f:	68 7a 50 10 f0       	push   $0xf010507a
f0102614:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102619:	68 5c 03 00 00       	push   $0x35c
f010261e:	68 18 4e 10 f0       	push   $0xf0104e18
f0102623:	e8 63 da ff ff       	call   f010008b <_panic>
f0102628:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010262b:	39 d0                	cmp    %edx,%eax
f010262d:	75 db                	jne    f010260a <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010262f:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102634:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010263a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102643:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c

	// free the pages we took
	page_free(pp0);
f0102648:	83 ec 0c             	sub    $0xc,%esp
f010264b:	56                   	push   %esi
f010264c:	e8 bf ed ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f0102651:	89 3c 24             	mov    %edi,(%esp)
f0102654:	e8 b7 ed ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0102659:	89 1c 24             	mov    %ebx,(%esp)
f010265c:	e8 af ed ff ff       	call   f0101410 <page_free>

	cprintf("check_page() succeeded!\n");
f0102661:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0102668:	e8 5c 06 00 00       	call   f0102cc9 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010266d:	a1 4c f9 11 f0       	mov    0xf011f94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102672:	83 c4 10             	add    $0x10,%esp
f0102675:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010267a:	77 15                	ja     f0102691 <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010267c:	50                   	push   %eax
f010267d:	68 58 45 10 f0       	push   $0xf0104558
f0102682:	68 bc 00 00 00       	push   $0xbc
f0102687:	68 18 4e 10 f0       	push   $0xf0104e18
f010268c:	e8 fa d9 ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102691:	8b 15 44 f9 11 f0    	mov    0xf011f944,%edx
f0102697:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010269e:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026a1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026a7:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026a9:	05 00 00 00 10       	add    $0x10000000,%eax
f01026ae:	50                   	push   %eax
f01026af:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026b4:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01026b9:	e8 27 ee ff ff       	call   f01014e5 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026be:	83 c4 10             	add    $0x10,%esp
f01026c1:	ba 00 50 11 f0       	mov    $0xf0115000,%edx
f01026c6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026cc:	77 15                	ja     f01026e3 <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ce:	52                   	push   %edx
f01026cf:	68 58 45 10 f0       	push   $0xf0104558
f01026d4:	68 ce 00 00 00       	push   $0xce
f01026d9:	68 18 4e 10 f0       	push   $0xf0104e18
f01026de:	e8 a8 d9 ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01026e3:	83 ec 08             	sub    $0x8,%esp
f01026e6:	6a 02                	push   $0x2
f01026e8:	68 00 50 11 00       	push   $0x115000
f01026ed:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026f2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026f7:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01026fc:	e8 e4 ed ff ff       	call   f01014e5 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102701:	83 c4 08             	add    $0x8,%esp
f0102704:	6a 02                	push   $0x2
f0102706:	6a 00                	push   $0x0
f0102708:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010270d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102712:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102717:	e8 c9 ed ff ff       	call   f01014e5 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010271c:	8b 1d 48 f9 11 f0    	mov    0xf011f948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102722:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0102727:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010272e:	83 c4 10             	add    $0x10,%esp
f0102731:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102737:	74 63                	je     f010279c <mem_init+0x113f>
f0102739:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010273e:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102744:	89 d8                	mov    %ebx,%eax
f0102746:	e8 4c e8 ff ff       	call   f0100f97 <check_va2pa>
f010274b:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102751:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102757:	77 15                	ja     f010276e <mem_init+0x1111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102759:	52                   	push   %edx
f010275a:	68 58 45 10 f0       	push   $0xf0104558
f010275f:	68 a3 02 00 00       	push   $0x2a3
f0102764:	68 18 4e 10 f0       	push   $0xf0104e18
f0102769:	e8 1d d9 ff ff       	call   f010008b <_panic>
f010276e:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102775:	39 d0                	cmp    %edx,%eax
f0102777:	74 19                	je     f0102792 <mem_init+0x1135>
f0102779:	68 84 4c 10 f0       	push   $0xf0104c84
f010277e:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102783:	68 a3 02 00 00       	push   $0x2a3
f0102788:	68 18 4e 10 f0       	push   $0xf0104e18
f010278d:	e8 f9 d8 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102792:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102798:	39 f7                	cmp    %esi,%edi
f010279a:	77 a2                	ja     f010273e <mem_init+0x10e1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010279c:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01027a1:	c1 e0 0c             	shl    $0xc,%eax
f01027a4:	74 41                	je     f01027e7 <mem_init+0x118a>
f01027a6:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027ab:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01027b1:	89 d8                	mov    %ebx,%eax
f01027b3:	e8 df e7 ff ff       	call   f0100f97 <check_va2pa>
f01027b8:	39 c6                	cmp    %eax,%esi
f01027ba:	74 19                	je     f01027d5 <mem_init+0x1178>
f01027bc:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01027c1:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01027c6:	68 a8 02 00 00       	push   $0x2a8
f01027cb:	68 18 4e 10 f0       	push   $0xf0104e18
f01027d0:	e8 b6 d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027d5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027db:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01027e0:	c1 e0 0c             	shl    $0xc,%eax
f01027e3:	39 c6                	cmp    %eax,%esi
f01027e5:	72 c4                	jb     f01027ab <mem_init+0x114e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027e7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027ec:	89 d8                	mov    %ebx,%eax
f01027ee:	e8 a4 e7 ff ff       	call   f0100f97 <check_va2pa>
f01027f3:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027f8:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
f01027fd:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102803:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102806:	39 d0                	cmp    %edx,%eax
f0102808:	74 19                	je     f0102823 <mem_init+0x11c6>
f010280a:	68 e0 4c 10 f0       	push   $0xf0104ce0
f010280f:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102814:	68 ac 02 00 00       	push   $0x2ac
f0102819:	68 18 4e 10 f0       	push   $0xf0104e18
f010281e:	e8 68 d8 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102823:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102829:	0f 85 25 04 00 00    	jne    f0102c54 <mem_init+0x15f7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010282f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102834:	89 d8                	mov    %ebx,%eax
f0102836:	e8 5c e7 ff ff       	call   f0100f97 <check_va2pa>
f010283b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010283e:	74 19                	je     f0102859 <mem_init+0x11fc>
f0102840:	68 28 4d 10 f0       	push   $0xf0104d28
f0102845:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010284a:	68 ad 02 00 00       	push   $0x2ad
f010284f:	68 18 4e 10 f0       	push   $0xf0104e18
f0102854:	e8 32 d8 ff ff       	call   f010008b <_panic>
f0102859:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010285e:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102863:	72 2d                	jb     f0102892 <mem_init+0x1235>
f0102865:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010286a:	76 07                	jbe    f0102873 <mem_init+0x1216>
f010286c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102871:	75 1f                	jne    f0102892 <mem_init+0x1235>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102873:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102877:	75 7e                	jne    f01028f7 <mem_init+0x129a>
f0102879:	68 aa 50 10 f0       	push   $0xf01050aa
f010287e:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102883:	68 b5 02 00 00       	push   $0x2b5
f0102888:	68 18 4e 10 f0       	push   $0xf0104e18
f010288d:	e8 f9 d7 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102892:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102897:	76 3f                	jbe    f01028d8 <mem_init+0x127b>
				assert(pgdir[i] & PTE_P);
f0102899:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010289c:	f6 c2 01             	test   $0x1,%dl
f010289f:	75 19                	jne    f01028ba <mem_init+0x125d>
f01028a1:	68 aa 50 10 f0       	push   $0xf01050aa
f01028a6:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01028ab:	68 b9 02 00 00       	push   $0x2b9
f01028b0:	68 18 4e 10 f0       	push   $0xf0104e18
f01028b5:	e8 d1 d7 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01028ba:	f6 c2 02             	test   $0x2,%dl
f01028bd:	75 38                	jne    f01028f7 <mem_init+0x129a>
f01028bf:	68 bb 50 10 f0       	push   $0xf01050bb
f01028c4:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01028c9:	68 ba 02 00 00       	push   $0x2ba
f01028ce:	68 18 4e 10 f0       	push   $0xf0104e18
f01028d3:	e8 b3 d7 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f01028d8:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028dc:	74 19                	je     f01028f7 <mem_init+0x129a>
f01028de:	68 cc 50 10 f0       	push   $0xf01050cc
f01028e3:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01028e8:	68 bc 02 00 00       	push   $0x2bc
f01028ed:	68 18 4e 10 f0       	push   $0xf0104e18
f01028f2:	e8 94 d7 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028f7:	40                   	inc    %eax
f01028f8:	3d 00 04 00 00       	cmp    $0x400,%eax
f01028fd:	0f 85 5b ff ff ff    	jne    f010285e <mem_init+0x1201>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102903:	83 ec 0c             	sub    $0xc,%esp
f0102906:	68 58 4d 10 f0       	push   $0xf0104d58
f010290b:	e8 b9 03 00 00       	call   f0102cc9 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102910:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102915:	83 c4 10             	add    $0x10,%esp
f0102918:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010291d:	77 15                	ja     f0102934 <mem_init+0x12d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010291f:	50                   	push   %eax
f0102920:	68 58 45 10 f0       	push   $0xf0104558
f0102925:	68 ea 00 00 00       	push   $0xea
f010292a:	68 18 4e 10 f0       	push   $0xf0104e18
f010292f:	e8 57 d7 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102934:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102939:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010293c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102941:	e8 da e6 ff ff       	call   f0101020 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102946:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102949:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010294e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102951:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102954:	83 ec 0c             	sub    $0xc,%esp
f0102957:	6a 00                	push   $0x0
f0102959:	e8 28 ea ff ff       	call   f0101386 <page_alloc>
f010295e:	89 c6                	mov    %eax,%esi
f0102960:	83 c4 10             	add    $0x10,%esp
f0102963:	85 c0                	test   %eax,%eax
f0102965:	75 19                	jne    f0102980 <mem_init+0x1323>
f0102967:	68 e9 4e 10 f0       	push   $0xf0104ee9
f010296c:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102971:	68 77 03 00 00       	push   $0x377
f0102976:	68 18 4e 10 f0       	push   $0xf0104e18
f010297b:	e8 0b d7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102980:	83 ec 0c             	sub    $0xc,%esp
f0102983:	6a 00                	push   $0x0
f0102985:	e8 fc e9 ff ff       	call   f0101386 <page_alloc>
f010298a:	89 c7                	mov    %eax,%edi
f010298c:	83 c4 10             	add    $0x10,%esp
f010298f:	85 c0                	test   %eax,%eax
f0102991:	75 19                	jne    f01029ac <mem_init+0x134f>
f0102993:	68 ff 4e 10 f0       	push   $0xf0104eff
f0102998:	68 3e 4e 10 f0       	push   $0xf0104e3e
f010299d:	68 78 03 00 00       	push   $0x378
f01029a2:	68 18 4e 10 f0       	push   $0xf0104e18
f01029a7:	e8 df d6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01029ac:	83 ec 0c             	sub    $0xc,%esp
f01029af:	6a 00                	push   $0x0
f01029b1:	e8 d0 e9 ff ff       	call   f0101386 <page_alloc>
f01029b6:	89 c3                	mov    %eax,%ebx
f01029b8:	83 c4 10             	add    $0x10,%esp
f01029bb:	85 c0                	test   %eax,%eax
f01029bd:	75 19                	jne    f01029d8 <mem_init+0x137b>
f01029bf:	68 15 4f 10 f0       	push   $0xf0104f15
f01029c4:	68 3e 4e 10 f0       	push   $0xf0104e3e
f01029c9:	68 79 03 00 00       	push   $0x379
f01029ce:	68 18 4e 10 f0       	push   $0xf0104e18
f01029d3:	e8 b3 d6 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f01029d8:	83 ec 0c             	sub    $0xc,%esp
f01029db:	56                   	push   %esi
f01029dc:	e8 2f ea ff ff       	call   f0101410 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029e1:	89 f8                	mov    %edi,%eax
f01029e3:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01029e9:	c1 f8 03             	sar    $0x3,%eax
f01029ec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ef:	89 c2                	mov    %eax,%edx
f01029f1:	c1 ea 0c             	shr    $0xc,%edx
f01029f4:	83 c4 10             	add    $0x10,%esp
f01029f7:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01029fd:	72 12                	jb     f0102a11 <mem_init+0x13b4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029ff:	50                   	push   %eax
f0102a00:	68 20 47 10 f0       	push   $0xf0104720
f0102a05:	6a 52                	push   $0x52
f0102a07:	68 24 4e 10 f0       	push   $0xf0104e24
f0102a0c:	e8 7a d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a11:	83 ec 04             	sub    $0x4,%esp
f0102a14:	68 00 10 00 00       	push   $0x1000
f0102a19:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a1b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a20:	50                   	push   %eax
f0102a21:	e8 d3 0d 00 00       	call   f01037f9 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a26:	89 d8                	mov    %ebx,%eax
f0102a28:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102a2e:	c1 f8 03             	sar    $0x3,%eax
f0102a31:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a34:	89 c2                	mov    %eax,%edx
f0102a36:	c1 ea 0c             	shr    $0xc,%edx
f0102a39:	83 c4 10             	add    $0x10,%esp
f0102a3c:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102a42:	72 12                	jb     f0102a56 <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a44:	50                   	push   %eax
f0102a45:	68 20 47 10 f0       	push   $0xf0104720
f0102a4a:	6a 52                	push   $0x52
f0102a4c:	68 24 4e 10 f0       	push   $0xf0104e24
f0102a51:	e8 35 d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a56:	83 ec 04             	sub    $0x4,%esp
f0102a59:	68 00 10 00 00       	push   $0x1000
f0102a5e:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102a60:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a65:	50                   	push   %eax
f0102a66:	e8 8e 0d 00 00       	call   f01037f9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a6b:	6a 02                	push   $0x2
f0102a6d:	68 00 10 00 00       	push   $0x1000
f0102a72:	57                   	push   %edi
f0102a73:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102a79:	e8 76 eb ff ff       	call   f01015f4 <page_insert>
	assert(pp1->pp_ref == 1);
f0102a7e:	83 c4 20             	add    $0x20,%esp
f0102a81:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a86:	74 19                	je     f0102aa1 <mem_init+0x1444>
f0102a88:	68 e6 4f 10 f0       	push   $0xf0104fe6
f0102a8d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102a92:	68 7e 03 00 00       	push   $0x37e
f0102a97:	68 18 4e 10 f0       	push   $0xf0104e18
f0102a9c:	e8 ea d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102aa1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102aa8:	01 01 01 
f0102aab:	74 19                	je     f0102ac6 <mem_init+0x1469>
f0102aad:	68 78 4d 10 f0       	push   $0xf0104d78
f0102ab2:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102ab7:	68 7f 03 00 00       	push   $0x37f
f0102abc:	68 18 4e 10 f0       	push   $0xf0104e18
f0102ac1:	e8 c5 d5 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ac6:	6a 02                	push   $0x2
f0102ac8:	68 00 10 00 00       	push   $0x1000
f0102acd:	53                   	push   %ebx
f0102ace:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102ad4:	e8 1b eb ff ff       	call   f01015f4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ad9:	83 c4 10             	add    $0x10,%esp
f0102adc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ae3:	02 02 02 
f0102ae6:	74 19                	je     f0102b01 <mem_init+0x14a4>
f0102ae8:	68 9c 4d 10 f0       	push   $0xf0104d9c
f0102aed:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102af2:	68 81 03 00 00       	push   $0x381
f0102af7:	68 18 4e 10 f0       	push   $0xf0104e18
f0102afc:	e8 8a d5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102b01:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b06:	74 19                	je     f0102b21 <mem_init+0x14c4>
f0102b08:	68 08 50 10 f0       	push   $0xf0105008
f0102b0d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102b12:	68 82 03 00 00       	push   $0x382
f0102b17:	68 18 4e 10 f0       	push   $0xf0104e18
f0102b1c:	e8 6a d5 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102b21:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b26:	74 19                	je     f0102b41 <mem_init+0x14e4>
f0102b28:	68 51 50 10 f0       	push   $0xf0105051
f0102b2d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102b32:	68 83 03 00 00       	push   $0x383
f0102b37:	68 18 4e 10 f0       	push   $0xf0104e18
f0102b3c:	e8 4a d5 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b41:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b48:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b4b:	89 d8                	mov    %ebx,%eax
f0102b4d:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102b53:	c1 f8 03             	sar    $0x3,%eax
f0102b56:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b59:	89 c2                	mov    %eax,%edx
f0102b5b:	c1 ea 0c             	shr    $0xc,%edx
f0102b5e:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102b64:	72 12                	jb     f0102b78 <mem_init+0x151b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b66:	50                   	push   %eax
f0102b67:	68 20 47 10 f0       	push   $0xf0104720
f0102b6c:	6a 52                	push   $0x52
f0102b6e:	68 24 4e 10 f0       	push   $0xf0104e24
f0102b73:	e8 13 d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b78:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b7f:	03 03 03 
f0102b82:	74 19                	je     f0102b9d <mem_init+0x1540>
f0102b84:	68 c0 4d 10 f0       	push   $0xf0104dc0
f0102b89:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102b8e:	68 85 03 00 00       	push   $0x385
f0102b93:	68 18 4e 10 f0       	push   $0xf0104e18
f0102b98:	e8 ee d4 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b9d:	83 ec 08             	sub    $0x8,%esp
f0102ba0:	68 00 10 00 00       	push   $0x1000
f0102ba5:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102bab:	e8 f7 e9 ff ff       	call   f01015a7 <page_remove>
	assert(pp2->pp_ref == 0);
f0102bb0:	83 c4 10             	add    $0x10,%esp
f0102bb3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bb8:	74 19                	je     f0102bd3 <mem_init+0x1576>
f0102bba:	68 40 50 10 f0       	push   $0xf0105040
f0102bbf:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102bc4:	68 87 03 00 00       	push   $0x387
f0102bc9:	68 18 4e 10 f0       	push   $0xf0104e18
f0102bce:	e8 b8 d4 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bd3:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102bd8:	8b 08                	mov    (%eax),%ecx
f0102bda:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be0:	89 f2                	mov    %esi,%edx
f0102be2:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102be8:	c1 fa 03             	sar    $0x3,%edx
f0102beb:	c1 e2 0c             	shl    $0xc,%edx
f0102bee:	39 d1                	cmp    %edx,%ecx
f0102bf0:	74 19                	je     f0102c0b <mem_init+0x15ae>
f0102bf2:	68 3c 49 10 f0       	push   $0xf010493c
f0102bf7:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102bfc:	68 8a 03 00 00       	push   $0x38a
f0102c01:	68 18 4e 10 f0       	push   $0xf0104e18
f0102c06:	e8 80 d4 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102c0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c16:	74 19                	je     f0102c31 <mem_init+0x15d4>
f0102c18:	68 f7 4f 10 f0       	push   $0xf0104ff7
f0102c1d:	68 3e 4e 10 f0       	push   $0xf0104e3e
f0102c22:	68 8c 03 00 00       	push   $0x38c
f0102c27:	68 18 4e 10 f0       	push   $0xf0104e18
f0102c2c:	e8 5a d4 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102c31:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c37:	83 ec 0c             	sub    $0xc,%esp
f0102c3a:	56                   	push   %esi
f0102c3b:	e8 d0 e7 ff ff       	call   f0101410 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c40:	c7 04 24 ec 4d 10 f0 	movl   $0xf0104dec,(%esp)
f0102c47:	e8 7d 00 00 00       	call   f0102cc9 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c4f:	5b                   	pop    %ebx
f0102c50:	5e                   	pop    %esi
f0102c51:	5f                   	pop    %edi
f0102c52:	c9                   	leave  
f0102c53:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c54:	89 f2                	mov    %esi,%edx
f0102c56:	89 d8                	mov    %ebx,%eax
f0102c58:	e8 3a e3 ff ff       	call   f0100f97 <check_va2pa>
f0102c5d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c63:	e9 9b fb ff ff       	jmp    f0102803 <mem_init+0x11a6>

f0102c68 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102c68:	55                   	push   %ebp
f0102c69:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c6b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c70:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c73:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102c74:	b2 71                	mov    $0x71,%dl
f0102c76:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102c77:	0f b6 c0             	movzbl %al,%eax
}
f0102c7a:	c9                   	leave  
f0102c7b:	c3                   	ret    

f0102c7c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102c7c:	55                   	push   %ebp
f0102c7d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c7f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c84:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c87:	ee                   	out    %al,(%dx)
f0102c88:	b2 71                	mov    $0x71,%dl
f0102c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c8d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c8e:	c9                   	leave  
f0102c8f:	c3                   	ret    

f0102c90 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c90:	55                   	push   %ebp
f0102c91:	89 e5                	mov    %esp,%ebp
f0102c93:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102c96:	ff 75 08             	pushl  0x8(%ebp)
f0102c99:	e8 08 d9 ff ff       	call   f01005a6 <cputchar>
f0102c9e:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102ca1:	c9                   	leave  
f0102ca2:	c3                   	ret    

f0102ca3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102ca3:	55                   	push   %ebp
f0102ca4:	89 e5                	mov    %esp,%ebp
f0102ca6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102ca9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102cb0:	ff 75 0c             	pushl  0xc(%ebp)
f0102cb3:	ff 75 08             	pushl  0x8(%ebp)
f0102cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102cb9:	50                   	push   %eax
f0102cba:	68 90 2c 10 f0       	push   $0xf0102c90
f0102cbf:	e8 9d 04 00 00       	call   f0103161 <vprintfmt>
	return cnt;
}
f0102cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cc7:	c9                   	leave  
f0102cc8:	c3                   	ret    

f0102cc9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102cc9:	55                   	push   %ebp
f0102cca:	89 e5                	mov    %esp,%ebp
f0102ccc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102ccf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102cd2:	50                   	push   %eax
f0102cd3:	ff 75 08             	pushl  0x8(%ebp)
f0102cd6:	e8 c8 ff ff ff       	call   f0102ca3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102cdb:	c9                   	leave  
f0102cdc:	c3                   	ret    
f0102cdd:	00 00                	add    %al,(%eax)
	...

f0102ce0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102ce0:	55                   	push   %ebp
f0102ce1:	89 e5                	mov    %esp,%ebp
f0102ce3:	57                   	push   %edi
f0102ce4:	56                   	push   %esi
f0102ce5:	53                   	push   %ebx
f0102ce6:	83 ec 14             	sub    $0x14,%esp
f0102ce9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102cec:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102cef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102cf2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102cf5:	8b 1a                	mov    (%edx),%ebx
f0102cf7:	8b 01                	mov    (%ecx),%eax
f0102cf9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102cfc:	39 c3                	cmp    %eax,%ebx
f0102cfe:	0f 8f 97 00 00 00    	jg     f0102d9b <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d0e:	01 d8                	add    %ebx,%eax
f0102d10:	89 c7                	mov    %eax,%edi
f0102d12:	c1 ef 1f             	shr    $0x1f,%edi
f0102d15:	01 c7                	add    %eax,%edi
f0102d17:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d19:	39 df                	cmp    %ebx,%edi
f0102d1b:	7c 31                	jl     f0102d4e <stab_binsearch+0x6e>
f0102d1d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102d23:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102d28:	39 f0                	cmp    %esi,%eax
f0102d2a:	0f 84 b3 00 00 00    	je     f0102de3 <stab_binsearch+0x103>
f0102d30:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d34:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d38:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102d3a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d3b:	39 d8                	cmp    %ebx,%eax
f0102d3d:	7c 0f                	jl     f0102d4e <stab_binsearch+0x6e>
f0102d3f:	0f b6 0a             	movzbl (%edx),%ecx
f0102d42:	83 ea 0c             	sub    $0xc,%edx
f0102d45:	39 f1                	cmp    %esi,%ecx
f0102d47:	75 f1                	jne    f0102d3a <stab_binsearch+0x5a>
f0102d49:	e9 97 00 00 00       	jmp    f0102de5 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102d4e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102d51:	eb 39                	jmp    f0102d8c <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102d53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d56:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102d58:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d5b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102d62:	eb 28                	jmp    f0102d8c <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102d64:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102d67:	76 12                	jbe    f0102d7b <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102d69:	48                   	dec    %eax
f0102d6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102d6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d70:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d72:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102d79:	eb 11                	jmp    f0102d8c <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102d7b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d7e:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102d80:	ff 45 0c             	incl   0xc(%ebp)
f0102d83:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d85:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d8c:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102d8f:	0f 8d 76 ff ff ff    	jge    f0102d0b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102d99:	75 0d                	jne    f0102da8 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102d9b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d9e:	8b 03                	mov    (%ebx),%eax
f0102da0:	48                   	dec    %eax
f0102da1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102da4:	89 02                	mov    %eax,(%edx)
f0102da6:	eb 55                	jmp    f0102dfd <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102da8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102dab:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102dad:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102db0:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102db2:	39 c1                	cmp    %eax,%ecx
f0102db4:	7d 26                	jge    f0102ddc <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102db6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102db9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102dbc:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102dc1:	39 f2                	cmp    %esi,%edx
f0102dc3:	74 17                	je     f0102ddc <stab_binsearch+0xfc>
f0102dc5:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102dc9:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102dcd:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102dce:	39 c1                	cmp    %eax,%ecx
f0102dd0:	7d 0a                	jge    f0102ddc <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102dd2:	0f b6 1a             	movzbl (%edx),%ebx
f0102dd5:	83 ea 0c             	sub    $0xc,%edx
f0102dd8:	39 f3                	cmp    %esi,%ebx
f0102dda:	75 f1                	jne    f0102dcd <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102ddc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102ddf:	89 02                	mov    %eax,(%edx)
f0102de1:	eb 1a                	jmp    f0102dfd <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102de3:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102de5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102de8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102deb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102def:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102df2:	0f 82 5b ff ff ff    	jb     f0102d53 <stab_binsearch+0x73>
f0102df8:	e9 67 ff ff ff       	jmp    f0102d64 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102dfd:	83 c4 14             	add    $0x14,%esp
f0102e00:	5b                   	pop    %ebx
f0102e01:	5e                   	pop    %esi
f0102e02:	5f                   	pop    %edi
f0102e03:	c9                   	leave  
f0102e04:	c3                   	ret    

f0102e05 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e05:	55                   	push   %ebp
f0102e06:	89 e5                	mov    %esp,%ebp
f0102e08:	57                   	push   %edi
f0102e09:	56                   	push   %esi
f0102e0a:	53                   	push   %ebx
f0102e0b:	83 ec 2c             	sub    $0x2c,%esp
f0102e0e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102e14:	c7 03 da 50 10 f0    	movl   $0xf01050da,(%ebx)
	info->eip_line = 0;
f0102e1a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102e21:	c7 43 08 da 50 10 f0 	movl   $0xf01050da,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102e28:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102e2f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102e32:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102e39:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e3f:	76 12                	jbe    f0102e53 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e41:	b8 8b 40 11 f0       	mov    $0xf011408b,%eax
f0102e46:	3d 51 c7 10 f0       	cmp    $0xf010c751,%eax
f0102e4b:	0f 86 90 01 00 00    	jbe    f0102fe1 <debuginfo_eip+0x1dc>
f0102e51:	eb 14                	jmp    f0102e67 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102e53:	83 ec 04             	sub    $0x4,%esp
f0102e56:	68 e4 50 10 f0       	push   $0xf01050e4
f0102e5b:	6a 7f                	push   $0x7f
f0102e5d:	68 f1 50 10 f0       	push   $0xf01050f1
f0102e62:	e8 24 d2 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e6c:	80 3d 8a 40 11 f0 00 	cmpb   $0x0,0xf011408a
f0102e73:	0f 85 74 01 00 00    	jne    f0102fed <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102e79:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102e80:	b8 50 c7 10 f0       	mov    $0xf010c750,%eax
f0102e85:	2d 10 53 10 f0       	sub    $0xf0105310,%eax
f0102e8a:	c1 f8 02             	sar    $0x2,%eax
f0102e8d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102e93:	48                   	dec    %eax
f0102e94:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102e97:	83 ec 08             	sub    $0x8,%esp
f0102e9a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102e9d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102ea0:	56                   	push   %esi
f0102ea1:	6a 64                	push   $0x64
f0102ea3:	b8 10 53 10 f0       	mov    $0xf0105310,%eax
f0102ea8:	e8 33 fe ff ff       	call   f0102ce0 <stab_binsearch>
	if (lfile == 0)
f0102ead:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102eb0:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102eb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102eb8:	85 d2                	test   %edx,%edx
f0102eba:	0f 84 2d 01 00 00    	je     f0102fed <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102ec0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102ec3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ec6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102ec9:	83 ec 08             	sub    $0x8,%esp
f0102ecc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102ecf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102ed2:	56                   	push   %esi
f0102ed3:	6a 24                	push   $0x24
f0102ed5:	b8 10 53 10 f0       	mov    $0xf0105310,%eax
f0102eda:	e8 01 fe ff ff       	call   f0102ce0 <stab_binsearch>

	if (lfun <= rfun) {
f0102edf:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102ee2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102ee5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ee8:	83 c4 10             	add    $0x10,%esp
f0102eeb:	39 c7                	cmp    %eax,%edi
f0102eed:	7f 32                	jg     f0102f21 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102eef:	89 f9                	mov    %edi,%ecx
f0102ef1:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102ef4:	8b 80 10 53 10 f0    	mov    -0xfefacf0(%eax),%eax
f0102efa:	ba 8b 40 11 f0       	mov    $0xf011408b,%edx
f0102eff:	81 ea 51 c7 10 f0    	sub    $0xf010c751,%edx
f0102f05:	39 d0                	cmp    %edx,%eax
f0102f07:	73 08                	jae    f0102f11 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102f09:	05 51 c7 10 f0       	add    $0xf010c751,%eax
f0102f0e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102f11:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102f14:	8b 81 18 53 10 f0    	mov    -0xfeface8(%ecx),%eax
f0102f1a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102f1d:	29 c6                	sub    %eax,%esi
f0102f1f:	eb 0c                	jmp    f0102f2d <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102f21:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102f24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102f27:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f2a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102f2d:	83 ec 08             	sub    $0x8,%esp
f0102f30:	6a 3a                	push   $0x3a
f0102f32:	ff 73 08             	pushl  0x8(%ebx)
f0102f35:	e8 9d 08 00 00       	call   f01037d7 <strfind>
f0102f3a:	2b 43 08             	sub    0x8(%ebx),%eax
f0102f3d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102f40:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102f43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f46:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102f49:	83 c4 08             	add    $0x8,%esp
f0102f4c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f4f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f52:	56                   	push   %esi
f0102f53:	6a 44                	push   $0x44
f0102f55:	b8 10 53 10 f0       	mov    $0xf0105310,%eax
f0102f5a:	e8 81 fd ff ff       	call   f0102ce0 <stab_binsearch>
    if (lfun <= rfun) {
f0102f5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f62:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102f6a:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102f6d:	7f 7e                	jg     f0102fed <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102f6f:	6b c2 0c             	imul   $0xc,%edx,%eax
f0102f72:	05 10 53 10 f0       	add    $0xf0105310,%eax
f0102f77:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102f7b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102f81:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f84:	eb 04                	jmp    f0102f8a <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102f86:	4a                   	dec    %edx
f0102f87:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f8a:	39 f2                	cmp    %esi,%edx
f0102f8c:	7c 1b                	jl     f0102fa9 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0102f8e:	8a 48 fc             	mov    -0x4(%eax),%cl
f0102f91:	80 f9 84             	cmp    $0x84,%cl
f0102f94:	74 5f                	je     f0102ff5 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f96:	80 f9 64             	cmp    $0x64,%cl
f0102f99:	75 eb                	jne    f0102f86 <debuginfo_eip+0x181>
f0102f9b:	83 38 00             	cmpl   $0x0,(%eax)
f0102f9e:	74 e6                	je     f0102f86 <debuginfo_eip+0x181>
f0102fa0:	eb 53                	jmp    f0102ff5 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102fa2:	05 51 c7 10 f0       	add    $0xf010c751,%eax
f0102fa7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102fa9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fac:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102faf:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102fb4:	39 ca                	cmp    %ecx,%edx
f0102fb6:	7d 35                	jge    f0102fed <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0102fb8:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102fbb:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102fbe:	81 c2 14 53 10 f0    	add    $0xf0105314,%edx
f0102fc4:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102fc6:	eb 04                	jmp    f0102fcc <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102fc8:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0102fcb:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102fcc:	39 f0                	cmp    %esi,%eax
f0102fce:	7d 18                	jge    f0102fe8 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102fd0:	8a 0a                	mov    (%edx),%cl
f0102fd2:	83 c2 0c             	add    $0xc,%edx
f0102fd5:	80 f9 a0             	cmp    $0xa0,%cl
f0102fd8:	74 ee                	je     f0102fc8 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fda:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fdf:	eb 0c                	jmp    f0102fed <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102fe6:	eb 05                	jmp    f0102fed <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fe8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ff0:	5b                   	pop    %ebx
f0102ff1:	5e                   	pop    %esi
f0102ff2:	5f                   	pop    %edi
f0102ff3:	c9                   	leave  
f0102ff4:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102ff5:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102ff8:	8b 82 10 53 10 f0    	mov    -0xfefacf0(%edx),%eax
f0102ffe:	ba 8b 40 11 f0       	mov    $0xf011408b,%edx
f0103003:	81 ea 51 c7 10 f0    	sub    $0xf010c751,%edx
f0103009:	39 d0                	cmp    %edx,%eax
f010300b:	72 95                	jb     f0102fa2 <debuginfo_eip+0x19d>
f010300d:	eb 9a                	jmp    f0102fa9 <debuginfo_eip+0x1a4>
	...

f0103010 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103010:	55                   	push   %ebp
f0103011:	89 e5                	mov    %esp,%ebp
f0103013:	57                   	push   %edi
f0103014:	56                   	push   %esi
f0103015:	53                   	push   %ebx
f0103016:	83 ec 2c             	sub    $0x2c,%esp
f0103019:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010301c:	89 d6                	mov    %edx,%esi
f010301e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103021:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103024:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103027:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010302a:	8b 45 10             	mov    0x10(%ebp),%eax
f010302d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103030:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103033:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103036:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010303d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103040:	72 0c                	jb     f010304e <printnum+0x3e>
f0103042:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103045:	76 07                	jbe    f010304e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103047:	4b                   	dec    %ebx
f0103048:	85 db                	test   %ebx,%ebx
f010304a:	7f 31                	jg     f010307d <printnum+0x6d>
f010304c:	eb 3f                	jmp    f010308d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010304e:	83 ec 0c             	sub    $0xc,%esp
f0103051:	57                   	push   %edi
f0103052:	4b                   	dec    %ebx
f0103053:	53                   	push   %ebx
f0103054:	50                   	push   %eax
f0103055:	83 ec 08             	sub    $0x8,%esp
f0103058:	ff 75 d4             	pushl  -0x2c(%ebp)
f010305b:	ff 75 d0             	pushl  -0x30(%ebp)
f010305e:	ff 75 dc             	pushl  -0x24(%ebp)
f0103061:	ff 75 d8             	pushl  -0x28(%ebp)
f0103064:	e8 97 09 00 00       	call   f0103a00 <__udivdi3>
f0103069:	83 c4 18             	add    $0x18,%esp
f010306c:	52                   	push   %edx
f010306d:	50                   	push   %eax
f010306e:	89 f2                	mov    %esi,%edx
f0103070:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103073:	e8 98 ff ff ff       	call   f0103010 <printnum>
f0103078:	83 c4 20             	add    $0x20,%esp
f010307b:	eb 10                	jmp    f010308d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010307d:	83 ec 08             	sub    $0x8,%esp
f0103080:	56                   	push   %esi
f0103081:	57                   	push   %edi
f0103082:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103085:	4b                   	dec    %ebx
f0103086:	83 c4 10             	add    $0x10,%esp
f0103089:	85 db                	test   %ebx,%ebx
f010308b:	7f f0                	jg     f010307d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010308d:	83 ec 08             	sub    $0x8,%esp
f0103090:	56                   	push   %esi
f0103091:	83 ec 04             	sub    $0x4,%esp
f0103094:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103097:	ff 75 d0             	pushl  -0x30(%ebp)
f010309a:	ff 75 dc             	pushl  -0x24(%ebp)
f010309d:	ff 75 d8             	pushl  -0x28(%ebp)
f01030a0:	e8 77 0a 00 00       	call   f0103b1c <__umoddi3>
f01030a5:	83 c4 14             	add    $0x14,%esp
f01030a8:	0f be 80 ff 50 10 f0 	movsbl -0xfefaf01(%eax),%eax
f01030af:	50                   	push   %eax
f01030b0:	ff 55 e4             	call   *-0x1c(%ebp)
f01030b3:	83 c4 10             	add    $0x10,%esp
}
f01030b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030b9:	5b                   	pop    %ebx
f01030ba:	5e                   	pop    %esi
f01030bb:	5f                   	pop    %edi
f01030bc:	c9                   	leave  
f01030bd:	c3                   	ret    

f01030be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01030be:	55                   	push   %ebp
f01030bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01030c1:	83 fa 01             	cmp    $0x1,%edx
f01030c4:	7e 0e                	jle    f01030d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01030c6:	8b 10                	mov    (%eax),%edx
f01030c8:	8d 4a 08             	lea    0x8(%edx),%ecx
f01030cb:	89 08                	mov    %ecx,(%eax)
f01030cd:	8b 02                	mov    (%edx),%eax
f01030cf:	8b 52 04             	mov    0x4(%edx),%edx
f01030d2:	eb 22                	jmp    f01030f6 <getuint+0x38>
	else if (lflag)
f01030d4:	85 d2                	test   %edx,%edx
f01030d6:	74 10                	je     f01030e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01030d8:	8b 10                	mov    (%eax),%edx
f01030da:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030dd:	89 08                	mov    %ecx,(%eax)
f01030df:	8b 02                	mov    (%edx),%eax
f01030e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01030e6:	eb 0e                	jmp    f01030f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01030e8:	8b 10                	mov    (%eax),%edx
f01030ea:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030ed:	89 08                	mov    %ecx,(%eax)
f01030ef:	8b 02                	mov    (%edx),%eax
f01030f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01030f6:	c9                   	leave  
f01030f7:	c3                   	ret    

f01030f8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01030f8:	55                   	push   %ebp
f01030f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01030fb:	83 fa 01             	cmp    $0x1,%edx
f01030fe:	7e 0e                	jle    f010310e <getint+0x16>
		return va_arg(*ap, long long);
f0103100:	8b 10                	mov    (%eax),%edx
f0103102:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103105:	89 08                	mov    %ecx,(%eax)
f0103107:	8b 02                	mov    (%edx),%eax
f0103109:	8b 52 04             	mov    0x4(%edx),%edx
f010310c:	eb 1a                	jmp    f0103128 <getint+0x30>
	else if (lflag)
f010310e:	85 d2                	test   %edx,%edx
f0103110:	74 0c                	je     f010311e <getint+0x26>
		return va_arg(*ap, long);
f0103112:	8b 10                	mov    (%eax),%edx
f0103114:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103117:	89 08                	mov    %ecx,(%eax)
f0103119:	8b 02                	mov    (%edx),%eax
f010311b:	99                   	cltd   
f010311c:	eb 0a                	jmp    f0103128 <getint+0x30>
	else
		return va_arg(*ap, int);
f010311e:	8b 10                	mov    (%eax),%edx
f0103120:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103123:	89 08                	mov    %ecx,(%eax)
f0103125:	8b 02                	mov    (%edx),%eax
f0103127:	99                   	cltd   
}
f0103128:	c9                   	leave  
f0103129:	c3                   	ret    

f010312a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010312a:	55                   	push   %ebp
f010312b:	89 e5                	mov    %esp,%ebp
f010312d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103130:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103133:	8b 10                	mov    (%eax),%edx
f0103135:	3b 50 04             	cmp    0x4(%eax),%edx
f0103138:	73 08                	jae    f0103142 <sprintputch+0x18>
		*b->buf++ = ch;
f010313a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010313d:	88 0a                	mov    %cl,(%edx)
f010313f:	42                   	inc    %edx
f0103140:	89 10                	mov    %edx,(%eax)
}
f0103142:	c9                   	leave  
f0103143:	c3                   	ret    

f0103144 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103144:	55                   	push   %ebp
f0103145:	89 e5                	mov    %esp,%ebp
f0103147:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010314a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010314d:	50                   	push   %eax
f010314e:	ff 75 10             	pushl  0x10(%ebp)
f0103151:	ff 75 0c             	pushl  0xc(%ebp)
f0103154:	ff 75 08             	pushl  0x8(%ebp)
f0103157:	e8 05 00 00 00       	call   f0103161 <vprintfmt>
	va_end(ap);
f010315c:	83 c4 10             	add    $0x10,%esp
}
f010315f:	c9                   	leave  
f0103160:	c3                   	ret    

f0103161 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103161:	55                   	push   %ebp
f0103162:	89 e5                	mov    %esp,%ebp
f0103164:	57                   	push   %edi
f0103165:	56                   	push   %esi
f0103166:	53                   	push   %ebx
f0103167:	83 ec 2c             	sub    $0x2c,%esp
f010316a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010316d:	8b 75 10             	mov    0x10(%ebp),%esi
f0103170:	eb 13                	jmp    f0103185 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103172:	85 c0                	test   %eax,%eax
f0103174:	0f 84 6d 03 00 00    	je     f01034e7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f010317a:	83 ec 08             	sub    $0x8,%esp
f010317d:	57                   	push   %edi
f010317e:	50                   	push   %eax
f010317f:	ff 55 08             	call   *0x8(%ebp)
f0103182:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103185:	0f b6 06             	movzbl (%esi),%eax
f0103188:	46                   	inc    %esi
f0103189:	83 f8 25             	cmp    $0x25,%eax
f010318c:	75 e4                	jne    f0103172 <vprintfmt+0x11>
f010318e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103192:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103199:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01031a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01031a7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031ac:	eb 28                	jmp    f01031d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01031b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01031b4:	eb 20                	jmp    f01031d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01031b8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01031bc:	eb 18                	jmp    f01031d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031be:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01031c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01031c7:	eb 0d                	jmp    f01031d6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01031c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01031cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031d6:	8a 06                	mov    (%esi),%al
f01031d8:	0f b6 d0             	movzbl %al,%edx
f01031db:	8d 5e 01             	lea    0x1(%esi),%ebx
f01031de:	83 e8 23             	sub    $0x23,%eax
f01031e1:	3c 55                	cmp    $0x55,%al
f01031e3:	0f 87 e0 02 00 00    	ja     f01034c9 <vprintfmt+0x368>
f01031e9:	0f b6 c0             	movzbl %al,%eax
f01031ec:	ff 24 85 8c 51 10 f0 	jmp    *-0xfefae74(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01031f3:	83 ea 30             	sub    $0x30,%edx
f01031f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01031f9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01031fc:	8d 50 d0             	lea    -0x30(%eax),%edx
f01031ff:	83 fa 09             	cmp    $0x9,%edx
f0103202:	77 44                	ja     f0103248 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103204:	89 de                	mov    %ebx,%esi
f0103206:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103209:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010320a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010320d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103211:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103214:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103217:	83 fb 09             	cmp    $0x9,%ebx
f010321a:	76 ed                	jbe    f0103209 <vprintfmt+0xa8>
f010321c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010321f:	eb 29                	jmp    f010324a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103221:	8b 45 14             	mov    0x14(%ebp),%eax
f0103224:	8d 50 04             	lea    0x4(%eax),%edx
f0103227:	89 55 14             	mov    %edx,0x14(%ebp)
f010322a:	8b 00                	mov    (%eax),%eax
f010322c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010322f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103231:	eb 17                	jmp    f010324a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103233:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103237:	78 85                	js     f01031be <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103239:	89 de                	mov    %ebx,%esi
f010323b:	eb 99                	jmp    f01031d6 <vprintfmt+0x75>
f010323d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010323f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103246:	eb 8e                	jmp    f01031d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103248:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010324a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010324e:	79 86                	jns    f01031d6 <vprintfmt+0x75>
f0103250:	e9 74 ff ff ff       	jmp    f01031c9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103255:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103256:	89 de                	mov    %ebx,%esi
f0103258:	e9 79 ff ff ff       	jmp    f01031d6 <vprintfmt+0x75>
f010325d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103260:	8b 45 14             	mov    0x14(%ebp),%eax
f0103263:	8d 50 04             	lea    0x4(%eax),%edx
f0103266:	89 55 14             	mov    %edx,0x14(%ebp)
f0103269:	83 ec 08             	sub    $0x8,%esp
f010326c:	57                   	push   %edi
f010326d:	ff 30                	pushl  (%eax)
f010326f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103272:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103275:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103278:	e9 08 ff ff ff       	jmp    f0103185 <vprintfmt+0x24>
f010327d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103280:	8b 45 14             	mov    0x14(%ebp),%eax
f0103283:	8d 50 04             	lea    0x4(%eax),%edx
f0103286:	89 55 14             	mov    %edx,0x14(%ebp)
f0103289:	8b 00                	mov    (%eax),%eax
f010328b:	85 c0                	test   %eax,%eax
f010328d:	79 02                	jns    f0103291 <vprintfmt+0x130>
f010328f:	f7 d8                	neg    %eax
f0103291:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103293:	83 f8 06             	cmp    $0x6,%eax
f0103296:	7f 0b                	jg     f01032a3 <vprintfmt+0x142>
f0103298:	8b 04 85 e4 52 10 f0 	mov    -0xfefad1c(,%eax,4),%eax
f010329f:	85 c0                	test   %eax,%eax
f01032a1:	75 1a                	jne    f01032bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01032a3:	52                   	push   %edx
f01032a4:	68 17 51 10 f0       	push   $0xf0105117
f01032a9:	57                   	push   %edi
f01032aa:	ff 75 08             	pushl  0x8(%ebp)
f01032ad:	e8 92 fe ff ff       	call   f0103144 <printfmt>
f01032b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01032b8:	e9 c8 fe ff ff       	jmp    f0103185 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f01032bd:	50                   	push   %eax
f01032be:	68 50 4e 10 f0       	push   $0xf0104e50
f01032c3:	57                   	push   %edi
f01032c4:	ff 75 08             	pushl  0x8(%ebp)
f01032c7:	e8 78 fe ff ff       	call   f0103144 <printfmt>
f01032cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01032d2:	e9 ae fe ff ff       	jmp    f0103185 <vprintfmt+0x24>
f01032d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01032da:	89 de                	mov    %ebx,%esi
f01032dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01032df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01032e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01032e5:	8d 50 04             	lea    0x4(%eax),%edx
f01032e8:	89 55 14             	mov    %edx,0x14(%ebp)
f01032eb:	8b 00                	mov    (%eax),%eax
f01032ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01032f0:	85 c0                	test   %eax,%eax
f01032f2:	75 07                	jne    f01032fb <vprintfmt+0x19a>
				p = "(null)";
f01032f4:	c7 45 d0 10 51 10 f0 	movl   $0xf0105110,-0x30(%ebp)
			if (width > 0 && padc != '-')
f01032fb:	85 db                	test   %ebx,%ebx
f01032fd:	7e 42                	jle    f0103341 <vprintfmt+0x1e0>
f01032ff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103303:	74 3c                	je     f0103341 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103305:	83 ec 08             	sub    $0x8,%esp
f0103308:	51                   	push   %ecx
f0103309:	ff 75 d0             	pushl  -0x30(%ebp)
f010330c:	e8 3f 03 00 00       	call   f0103650 <strnlen>
f0103311:	29 c3                	sub    %eax,%ebx
f0103313:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103316:	83 c4 10             	add    $0x10,%esp
f0103319:	85 db                	test   %ebx,%ebx
f010331b:	7e 24                	jle    f0103341 <vprintfmt+0x1e0>
					putch(padc, putdat);
f010331d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103321:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103324:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103327:	83 ec 08             	sub    $0x8,%esp
f010332a:	57                   	push   %edi
f010332b:	53                   	push   %ebx
f010332c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010332f:	4e                   	dec    %esi
f0103330:	83 c4 10             	add    $0x10,%esp
f0103333:	85 f6                	test   %esi,%esi
f0103335:	7f f0                	jg     f0103327 <vprintfmt+0x1c6>
f0103337:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010333a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103341:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103344:	0f be 02             	movsbl (%edx),%eax
f0103347:	85 c0                	test   %eax,%eax
f0103349:	75 47                	jne    f0103392 <vprintfmt+0x231>
f010334b:	eb 37                	jmp    f0103384 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f010334d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103351:	74 16                	je     f0103369 <vprintfmt+0x208>
f0103353:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103356:	83 fa 5e             	cmp    $0x5e,%edx
f0103359:	76 0e                	jbe    f0103369 <vprintfmt+0x208>
					putch('?', putdat);
f010335b:	83 ec 08             	sub    $0x8,%esp
f010335e:	57                   	push   %edi
f010335f:	6a 3f                	push   $0x3f
f0103361:	ff 55 08             	call   *0x8(%ebp)
f0103364:	83 c4 10             	add    $0x10,%esp
f0103367:	eb 0b                	jmp    f0103374 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0103369:	83 ec 08             	sub    $0x8,%esp
f010336c:	57                   	push   %edi
f010336d:	50                   	push   %eax
f010336e:	ff 55 08             	call   *0x8(%ebp)
f0103371:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103374:	ff 4d e4             	decl   -0x1c(%ebp)
f0103377:	0f be 03             	movsbl (%ebx),%eax
f010337a:	85 c0                	test   %eax,%eax
f010337c:	74 03                	je     f0103381 <vprintfmt+0x220>
f010337e:	43                   	inc    %ebx
f010337f:	eb 1b                	jmp    f010339c <vprintfmt+0x23b>
f0103381:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103384:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103388:	7f 1e                	jg     f01033a8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010338a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010338d:	e9 f3 fd ff ff       	jmp    f0103185 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103392:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103395:	43                   	inc    %ebx
f0103396:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103399:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010339c:	85 f6                	test   %esi,%esi
f010339e:	78 ad                	js     f010334d <vprintfmt+0x1ec>
f01033a0:	4e                   	dec    %esi
f01033a1:	79 aa                	jns    f010334d <vprintfmt+0x1ec>
f01033a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01033a6:	eb dc                	jmp    f0103384 <vprintfmt+0x223>
f01033a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01033ab:	83 ec 08             	sub    $0x8,%esp
f01033ae:	57                   	push   %edi
f01033af:	6a 20                	push   $0x20
f01033b1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01033b4:	4b                   	dec    %ebx
f01033b5:	83 c4 10             	add    $0x10,%esp
f01033b8:	85 db                	test   %ebx,%ebx
f01033ba:	7f ef                	jg     f01033ab <vprintfmt+0x24a>
f01033bc:	e9 c4 fd ff ff       	jmp    f0103185 <vprintfmt+0x24>
f01033c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01033c4:	89 ca                	mov    %ecx,%edx
f01033c6:	8d 45 14             	lea    0x14(%ebp),%eax
f01033c9:	e8 2a fd ff ff       	call   f01030f8 <getint>
f01033ce:	89 c3                	mov    %eax,%ebx
f01033d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f01033d2:	85 d2                	test   %edx,%edx
f01033d4:	78 0a                	js     f01033e0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01033d6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01033db:	e9 b0 00 00 00       	jmp    f0103490 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01033e0:	83 ec 08             	sub    $0x8,%esp
f01033e3:	57                   	push   %edi
f01033e4:	6a 2d                	push   $0x2d
f01033e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01033e9:	f7 db                	neg    %ebx
f01033eb:	83 d6 00             	adc    $0x0,%esi
f01033ee:	f7 de                	neg    %esi
f01033f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01033f3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01033f8:	e9 93 00 00 00       	jmp    f0103490 <vprintfmt+0x32f>
f01033fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103400:	89 ca                	mov    %ecx,%edx
f0103402:	8d 45 14             	lea    0x14(%ebp),%eax
f0103405:	e8 b4 fc ff ff       	call   f01030be <getuint>
f010340a:	89 c3                	mov    %eax,%ebx
f010340c:	89 d6                	mov    %edx,%esi
			base = 10;
f010340e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103413:	eb 7b                	jmp    f0103490 <vprintfmt+0x32f>
f0103415:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103418:	89 ca                	mov    %ecx,%edx
f010341a:	8d 45 14             	lea    0x14(%ebp),%eax
f010341d:	e8 d6 fc ff ff       	call   f01030f8 <getint>
f0103422:	89 c3                	mov    %eax,%ebx
f0103424:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103426:	85 d2                	test   %edx,%edx
f0103428:	78 07                	js     f0103431 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f010342a:	b8 08 00 00 00       	mov    $0x8,%eax
f010342f:	eb 5f                	jmp    f0103490 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103431:	83 ec 08             	sub    $0x8,%esp
f0103434:	57                   	push   %edi
f0103435:	6a 2d                	push   $0x2d
f0103437:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f010343a:	f7 db                	neg    %ebx
f010343c:	83 d6 00             	adc    $0x0,%esi
f010343f:	f7 de                	neg    %esi
f0103441:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0103444:	b8 08 00 00 00       	mov    $0x8,%eax
f0103449:	eb 45                	jmp    f0103490 <vprintfmt+0x32f>
f010344b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f010344e:	83 ec 08             	sub    $0x8,%esp
f0103451:	57                   	push   %edi
f0103452:	6a 30                	push   $0x30
f0103454:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103457:	83 c4 08             	add    $0x8,%esp
f010345a:	57                   	push   %edi
f010345b:	6a 78                	push   $0x78
f010345d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103460:	8b 45 14             	mov    0x14(%ebp),%eax
f0103463:	8d 50 04             	lea    0x4(%eax),%edx
f0103466:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103469:	8b 18                	mov    (%eax),%ebx
f010346b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103470:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103473:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103478:	eb 16                	jmp    f0103490 <vprintfmt+0x32f>
f010347a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010347d:	89 ca                	mov    %ecx,%edx
f010347f:	8d 45 14             	lea    0x14(%ebp),%eax
f0103482:	e8 37 fc ff ff       	call   f01030be <getuint>
f0103487:	89 c3                	mov    %eax,%ebx
f0103489:	89 d6                	mov    %edx,%esi
			base = 16;
f010348b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103490:	83 ec 0c             	sub    $0xc,%esp
f0103493:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103497:	52                   	push   %edx
f0103498:	ff 75 e4             	pushl  -0x1c(%ebp)
f010349b:	50                   	push   %eax
f010349c:	56                   	push   %esi
f010349d:	53                   	push   %ebx
f010349e:	89 fa                	mov    %edi,%edx
f01034a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a3:	e8 68 fb ff ff       	call   f0103010 <printnum>
			break;
f01034a8:	83 c4 20             	add    $0x20,%esp
f01034ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01034ae:	e9 d2 fc ff ff       	jmp    f0103185 <vprintfmt+0x24>
f01034b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01034b6:	83 ec 08             	sub    $0x8,%esp
f01034b9:	57                   	push   %edi
f01034ba:	52                   	push   %edx
f01034bb:	ff 55 08             	call   *0x8(%ebp)
			break;
f01034be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01034c4:	e9 bc fc ff ff       	jmp    f0103185 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01034c9:	83 ec 08             	sub    $0x8,%esp
f01034cc:	57                   	push   %edi
f01034cd:	6a 25                	push   $0x25
f01034cf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01034d2:	83 c4 10             	add    $0x10,%esp
f01034d5:	eb 02                	jmp    f01034d9 <vprintfmt+0x378>
f01034d7:	89 c6                	mov    %eax,%esi
f01034d9:	8d 46 ff             	lea    -0x1(%esi),%eax
f01034dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01034e0:	75 f5                	jne    f01034d7 <vprintfmt+0x376>
f01034e2:	e9 9e fc ff ff       	jmp    f0103185 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f01034e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034ea:	5b                   	pop    %ebx
f01034eb:	5e                   	pop    %esi
f01034ec:	5f                   	pop    %edi
f01034ed:	c9                   	leave  
f01034ee:	c3                   	ret    

f01034ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01034ef:	55                   	push   %ebp
f01034f0:	89 e5                	mov    %esp,%ebp
f01034f2:	83 ec 18             	sub    $0x18,%esp
f01034f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01034fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01034fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103502:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103505:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010350c:	85 c0                	test   %eax,%eax
f010350e:	74 26                	je     f0103536 <vsnprintf+0x47>
f0103510:	85 d2                	test   %edx,%edx
f0103512:	7e 29                	jle    f010353d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103514:	ff 75 14             	pushl  0x14(%ebp)
f0103517:	ff 75 10             	pushl  0x10(%ebp)
f010351a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010351d:	50                   	push   %eax
f010351e:	68 2a 31 10 f0       	push   $0xf010312a
f0103523:	e8 39 fc ff ff       	call   f0103161 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103528:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010352b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010352e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103531:	83 c4 10             	add    $0x10,%esp
f0103534:	eb 0c                	jmp    f0103542 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010353b:	eb 05                	jmp    f0103542 <vsnprintf+0x53>
f010353d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103542:	c9                   	leave  
f0103543:	c3                   	ret    

f0103544 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103544:	55                   	push   %ebp
f0103545:	89 e5                	mov    %esp,%ebp
f0103547:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010354a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010354d:	50                   	push   %eax
f010354e:	ff 75 10             	pushl  0x10(%ebp)
f0103551:	ff 75 0c             	pushl  0xc(%ebp)
f0103554:	ff 75 08             	pushl  0x8(%ebp)
f0103557:	e8 93 ff ff ff       	call   f01034ef <vsnprintf>
	va_end(ap);

	return rc;
}
f010355c:	c9                   	leave  
f010355d:	c3                   	ret    
	...

f0103560 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103560:	55                   	push   %ebp
f0103561:	89 e5                	mov    %esp,%ebp
f0103563:	57                   	push   %edi
f0103564:	56                   	push   %esi
f0103565:	53                   	push   %ebx
f0103566:	83 ec 0c             	sub    $0xc,%esp
f0103569:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010356c:	85 c0                	test   %eax,%eax
f010356e:	74 11                	je     f0103581 <readline+0x21>
		cprintf("%s", prompt);
f0103570:	83 ec 08             	sub    $0x8,%esp
f0103573:	50                   	push   %eax
f0103574:	68 50 4e 10 f0       	push   $0xf0104e50
f0103579:	e8 4b f7 ff ff       	call   f0102cc9 <cprintf>
f010357e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103581:	83 ec 0c             	sub    $0xc,%esp
f0103584:	6a 00                	push   $0x0
f0103586:	e8 3c d0 ff ff       	call   f01005c7 <iscons>
f010358b:	89 c7                	mov    %eax,%edi
f010358d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103590:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103595:	e8 1c d0 ff ff       	call   f01005b6 <getchar>
f010359a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010359c:	85 c0                	test   %eax,%eax
f010359e:	79 18                	jns    f01035b8 <readline+0x58>
			cprintf("read error: %e\n", c);
f01035a0:	83 ec 08             	sub    $0x8,%esp
f01035a3:	50                   	push   %eax
f01035a4:	68 00 53 10 f0       	push   $0xf0105300
f01035a9:	e8 1b f7 ff ff       	call   f0102cc9 <cprintf>
			return NULL;
f01035ae:	83 c4 10             	add    $0x10,%esp
f01035b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01035b6:	eb 6f                	jmp    f0103627 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01035b8:	83 f8 08             	cmp    $0x8,%eax
f01035bb:	74 05                	je     f01035c2 <readline+0x62>
f01035bd:	83 f8 7f             	cmp    $0x7f,%eax
f01035c0:	75 18                	jne    f01035da <readline+0x7a>
f01035c2:	85 f6                	test   %esi,%esi
f01035c4:	7e 14                	jle    f01035da <readline+0x7a>
			if (echoing)
f01035c6:	85 ff                	test   %edi,%edi
f01035c8:	74 0d                	je     f01035d7 <readline+0x77>
				cputchar('\b');
f01035ca:	83 ec 0c             	sub    $0xc,%esp
f01035cd:	6a 08                	push   $0x8
f01035cf:	e8 d2 cf ff ff       	call   f01005a6 <cputchar>
f01035d4:	83 c4 10             	add    $0x10,%esp
			i--;
f01035d7:	4e                   	dec    %esi
f01035d8:	eb bb                	jmp    f0103595 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01035da:	83 fb 1f             	cmp    $0x1f,%ebx
f01035dd:	7e 21                	jle    f0103600 <readline+0xa0>
f01035df:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01035e5:	7f 19                	jg     f0103600 <readline+0xa0>
			if (echoing)
f01035e7:	85 ff                	test   %edi,%edi
f01035e9:	74 0c                	je     f01035f7 <readline+0x97>
				cputchar(c);
f01035eb:	83 ec 0c             	sub    $0xc,%esp
f01035ee:	53                   	push   %ebx
f01035ef:	e8 b2 cf ff ff       	call   f01005a6 <cputchar>
f01035f4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01035f7:	88 9e 40 f5 11 f0    	mov    %bl,-0xfee0ac0(%esi)
f01035fd:	46                   	inc    %esi
f01035fe:	eb 95                	jmp    f0103595 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103600:	83 fb 0a             	cmp    $0xa,%ebx
f0103603:	74 05                	je     f010360a <readline+0xaa>
f0103605:	83 fb 0d             	cmp    $0xd,%ebx
f0103608:	75 8b                	jne    f0103595 <readline+0x35>
			if (echoing)
f010360a:	85 ff                	test   %edi,%edi
f010360c:	74 0d                	je     f010361b <readline+0xbb>
				cputchar('\n');
f010360e:	83 ec 0c             	sub    $0xc,%esp
f0103611:	6a 0a                	push   $0xa
f0103613:	e8 8e cf ff ff       	call   f01005a6 <cputchar>
f0103618:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010361b:	c6 86 40 f5 11 f0 00 	movb   $0x0,-0xfee0ac0(%esi)
			return buf;
f0103622:	b8 40 f5 11 f0       	mov    $0xf011f540,%eax
		}
	}
}
f0103627:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010362a:	5b                   	pop    %ebx
f010362b:	5e                   	pop    %esi
f010362c:	5f                   	pop    %edi
f010362d:	c9                   	leave  
f010362e:	c3                   	ret    
	...

f0103630 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103630:	55                   	push   %ebp
f0103631:	89 e5                	mov    %esp,%ebp
f0103633:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103636:	80 3a 00             	cmpb   $0x0,(%edx)
f0103639:	74 0e                	je     f0103649 <strlen+0x19>
f010363b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103640:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103641:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103645:	75 f9                	jne    f0103640 <strlen+0x10>
f0103647:	eb 05                	jmp    f010364e <strlen+0x1e>
f0103649:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010364e:	c9                   	leave  
f010364f:	c3                   	ret    

f0103650 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
f0103653:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103656:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103659:	85 d2                	test   %edx,%edx
f010365b:	74 17                	je     f0103674 <strnlen+0x24>
f010365d:	80 39 00             	cmpb   $0x0,(%ecx)
f0103660:	74 19                	je     f010367b <strnlen+0x2b>
f0103662:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103667:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103668:	39 d0                	cmp    %edx,%eax
f010366a:	74 14                	je     f0103680 <strnlen+0x30>
f010366c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103670:	75 f5                	jne    f0103667 <strnlen+0x17>
f0103672:	eb 0c                	jmp    f0103680 <strnlen+0x30>
f0103674:	b8 00 00 00 00       	mov    $0x0,%eax
f0103679:	eb 05                	jmp    f0103680 <strnlen+0x30>
f010367b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103680:	c9                   	leave  
f0103681:	c3                   	ret    

f0103682 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103682:	55                   	push   %ebp
f0103683:	89 e5                	mov    %esp,%ebp
f0103685:	53                   	push   %ebx
f0103686:	8b 45 08             	mov    0x8(%ebp),%eax
f0103689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010368c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103691:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103694:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103697:	42                   	inc    %edx
f0103698:	84 c9                	test   %cl,%cl
f010369a:	75 f5                	jne    f0103691 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010369c:	5b                   	pop    %ebx
f010369d:	c9                   	leave  
f010369e:	c3                   	ret    

f010369f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010369f:	55                   	push   %ebp
f01036a0:	89 e5                	mov    %esp,%ebp
f01036a2:	53                   	push   %ebx
f01036a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01036a6:	53                   	push   %ebx
f01036a7:	e8 84 ff ff ff       	call   f0103630 <strlen>
f01036ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01036af:	ff 75 0c             	pushl  0xc(%ebp)
f01036b2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01036b5:	50                   	push   %eax
f01036b6:	e8 c7 ff ff ff       	call   f0103682 <strcpy>
	return dst;
}
f01036bb:	89 d8                	mov    %ebx,%eax
f01036bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036c0:	c9                   	leave  
f01036c1:	c3                   	ret    

f01036c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01036c2:	55                   	push   %ebp
f01036c3:	89 e5                	mov    %esp,%ebp
f01036c5:	56                   	push   %esi
f01036c6:	53                   	push   %ebx
f01036c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01036d0:	85 f6                	test   %esi,%esi
f01036d2:	74 15                	je     f01036e9 <strncpy+0x27>
f01036d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01036d9:	8a 1a                	mov    (%edx),%bl
f01036db:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01036de:	80 3a 01             	cmpb   $0x1,(%edx)
f01036e1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01036e4:	41                   	inc    %ecx
f01036e5:	39 ce                	cmp    %ecx,%esi
f01036e7:	77 f0                	ja     f01036d9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01036e9:	5b                   	pop    %ebx
f01036ea:	5e                   	pop    %esi
f01036eb:	c9                   	leave  
f01036ec:	c3                   	ret    

f01036ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01036ed:	55                   	push   %ebp
f01036ee:	89 e5                	mov    %esp,%ebp
f01036f0:	57                   	push   %edi
f01036f1:	56                   	push   %esi
f01036f2:	53                   	push   %ebx
f01036f3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036f9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036fc:	85 f6                	test   %esi,%esi
f01036fe:	74 32                	je     f0103732 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103700:	83 fe 01             	cmp    $0x1,%esi
f0103703:	74 22                	je     f0103727 <strlcpy+0x3a>
f0103705:	8a 0b                	mov    (%ebx),%cl
f0103707:	84 c9                	test   %cl,%cl
f0103709:	74 20                	je     f010372b <strlcpy+0x3e>
f010370b:	89 f8                	mov    %edi,%eax
f010370d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103712:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103715:	88 08                	mov    %cl,(%eax)
f0103717:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103718:	39 f2                	cmp    %esi,%edx
f010371a:	74 11                	je     f010372d <strlcpy+0x40>
f010371c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103720:	42                   	inc    %edx
f0103721:	84 c9                	test   %cl,%cl
f0103723:	75 f0                	jne    f0103715 <strlcpy+0x28>
f0103725:	eb 06                	jmp    f010372d <strlcpy+0x40>
f0103727:	89 f8                	mov    %edi,%eax
f0103729:	eb 02                	jmp    f010372d <strlcpy+0x40>
f010372b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010372d:	c6 00 00             	movb   $0x0,(%eax)
f0103730:	eb 02                	jmp    f0103734 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103732:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103734:	29 f8                	sub    %edi,%eax
}
f0103736:	5b                   	pop    %ebx
f0103737:	5e                   	pop    %esi
f0103738:	5f                   	pop    %edi
f0103739:	c9                   	leave  
f010373a:	c3                   	ret    

f010373b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010373b:	55                   	push   %ebp
f010373c:	89 e5                	mov    %esp,%ebp
f010373e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103741:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103744:	8a 01                	mov    (%ecx),%al
f0103746:	84 c0                	test   %al,%al
f0103748:	74 10                	je     f010375a <strcmp+0x1f>
f010374a:	3a 02                	cmp    (%edx),%al
f010374c:	75 0c                	jne    f010375a <strcmp+0x1f>
		p++, q++;
f010374e:	41                   	inc    %ecx
f010374f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103750:	8a 01                	mov    (%ecx),%al
f0103752:	84 c0                	test   %al,%al
f0103754:	74 04                	je     f010375a <strcmp+0x1f>
f0103756:	3a 02                	cmp    (%edx),%al
f0103758:	74 f4                	je     f010374e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010375a:	0f b6 c0             	movzbl %al,%eax
f010375d:	0f b6 12             	movzbl (%edx),%edx
f0103760:	29 d0                	sub    %edx,%eax
}
f0103762:	c9                   	leave  
f0103763:	c3                   	ret    

f0103764 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103764:	55                   	push   %ebp
f0103765:	89 e5                	mov    %esp,%ebp
f0103767:	53                   	push   %ebx
f0103768:	8b 55 08             	mov    0x8(%ebp),%edx
f010376b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010376e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103771:	85 c0                	test   %eax,%eax
f0103773:	74 1b                	je     f0103790 <strncmp+0x2c>
f0103775:	8a 1a                	mov    (%edx),%bl
f0103777:	84 db                	test   %bl,%bl
f0103779:	74 24                	je     f010379f <strncmp+0x3b>
f010377b:	3a 19                	cmp    (%ecx),%bl
f010377d:	75 20                	jne    f010379f <strncmp+0x3b>
f010377f:	48                   	dec    %eax
f0103780:	74 15                	je     f0103797 <strncmp+0x33>
		n--, p++, q++;
f0103782:	42                   	inc    %edx
f0103783:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103784:	8a 1a                	mov    (%edx),%bl
f0103786:	84 db                	test   %bl,%bl
f0103788:	74 15                	je     f010379f <strncmp+0x3b>
f010378a:	3a 19                	cmp    (%ecx),%bl
f010378c:	74 f1                	je     f010377f <strncmp+0x1b>
f010378e:	eb 0f                	jmp    f010379f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103790:	b8 00 00 00 00       	mov    $0x0,%eax
f0103795:	eb 05                	jmp    f010379c <strncmp+0x38>
f0103797:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010379c:	5b                   	pop    %ebx
f010379d:	c9                   	leave  
f010379e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010379f:	0f b6 02             	movzbl (%edx),%eax
f01037a2:	0f b6 11             	movzbl (%ecx),%edx
f01037a5:	29 d0                	sub    %edx,%eax
f01037a7:	eb f3                	jmp    f010379c <strncmp+0x38>

f01037a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01037a9:	55                   	push   %ebp
f01037aa:	89 e5                	mov    %esp,%ebp
f01037ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01037af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01037b2:	8a 10                	mov    (%eax),%dl
f01037b4:	84 d2                	test   %dl,%dl
f01037b6:	74 18                	je     f01037d0 <strchr+0x27>
		if (*s == c)
f01037b8:	38 ca                	cmp    %cl,%dl
f01037ba:	75 06                	jne    f01037c2 <strchr+0x19>
f01037bc:	eb 17                	jmp    f01037d5 <strchr+0x2c>
f01037be:	38 ca                	cmp    %cl,%dl
f01037c0:	74 13                	je     f01037d5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01037c2:	40                   	inc    %eax
f01037c3:	8a 10                	mov    (%eax),%dl
f01037c5:	84 d2                	test   %dl,%dl
f01037c7:	75 f5                	jne    f01037be <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01037c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01037ce:	eb 05                	jmp    f01037d5 <strchr+0x2c>
f01037d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037d5:	c9                   	leave  
f01037d6:	c3                   	ret    

f01037d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01037d7:	55                   	push   %ebp
f01037d8:	89 e5                	mov    %esp,%ebp
f01037da:	8b 45 08             	mov    0x8(%ebp),%eax
f01037dd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01037e0:	8a 10                	mov    (%eax),%dl
f01037e2:	84 d2                	test   %dl,%dl
f01037e4:	74 11                	je     f01037f7 <strfind+0x20>
		if (*s == c)
f01037e6:	38 ca                	cmp    %cl,%dl
f01037e8:	75 06                	jne    f01037f0 <strfind+0x19>
f01037ea:	eb 0b                	jmp    f01037f7 <strfind+0x20>
f01037ec:	38 ca                	cmp    %cl,%dl
f01037ee:	74 07                	je     f01037f7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01037f0:	40                   	inc    %eax
f01037f1:	8a 10                	mov    (%eax),%dl
f01037f3:	84 d2                	test   %dl,%dl
f01037f5:	75 f5                	jne    f01037ec <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01037f7:	c9                   	leave  
f01037f8:	c3                   	ret    

f01037f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01037f9:	55                   	push   %ebp
f01037fa:	89 e5                	mov    %esp,%ebp
f01037fc:	57                   	push   %edi
f01037fd:	56                   	push   %esi
f01037fe:	53                   	push   %ebx
f01037ff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103802:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103808:	85 c9                	test   %ecx,%ecx
f010380a:	74 30                	je     f010383c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010380c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103812:	75 25                	jne    f0103839 <memset+0x40>
f0103814:	f6 c1 03             	test   $0x3,%cl
f0103817:	75 20                	jne    f0103839 <memset+0x40>
		c &= 0xFF;
f0103819:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010381c:	89 d3                	mov    %edx,%ebx
f010381e:	c1 e3 08             	shl    $0x8,%ebx
f0103821:	89 d6                	mov    %edx,%esi
f0103823:	c1 e6 18             	shl    $0x18,%esi
f0103826:	89 d0                	mov    %edx,%eax
f0103828:	c1 e0 10             	shl    $0x10,%eax
f010382b:	09 f0                	or     %esi,%eax
f010382d:	09 d0                	or     %edx,%eax
f010382f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103831:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103834:	fc                   	cld    
f0103835:	f3 ab                	rep stos %eax,%es:(%edi)
f0103837:	eb 03                	jmp    f010383c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103839:	fc                   	cld    
f010383a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010383c:	89 f8                	mov    %edi,%eax
f010383e:	5b                   	pop    %ebx
f010383f:	5e                   	pop    %esi
f0103840:	5f                   	pop    %edi
f0103841:	c9                   	leave  
f0103842:	c3                   	ret    

f0103843 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103843:	55                   	push   %ebp
f0103844:	89 e5                	mov    %esp,%ebp
f0103846:	57                   	push   %edi
f0103847:	56                   	push   %esi
f0103848:	8b 45 08             	mov    0x8(%ebp),%eax
f010384b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010384e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103851:	39 c6                	cmp    %eax,%esi
f0103853:	73 34                	jae    f0103889 <memmove+0x46>
f0103855:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103858:	39 d0                	cmp    %edx,%eax
f010385a:	73 2d                	jae    f0103889 <memmove+0x46>
		s += n;
		d += n;
f010385c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010385f:	f6 c2 03             	test   $0x3,%dl
f0103862:	75 1b                	jne    f010387f <memmove+0x3c>
f0103864:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010386a:	75 13                	jne    f010387f <memmove+0x3c>
f010386c:	f6 c1 03             	test   $0x3,%cl
f010386f:	75 0e                	jne    f010387f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103871:	83 ef 04             	sub    $0x4,%edi
f0103874:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103877:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010387a:	fd                   	std    
f010387b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010387d:	eb 07                	jmp    f0103886 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010387f:	4f                   	dec    %edi
f0103880:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103883:	fd                   	std    
f0103884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103886:	fc                   	cld    
f0103887:	eb 20                	jmp    f01038a9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103889:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010388f:	75 13                	jne    f01038a4 <memmove+0x61>
f0103891:	a8 03                	test   $0x3,%al
f0103893:	75 0f                	jne    f01038a4 <memmove+0x61>
f0103895:	f6 c1 03             	test   $0x3,%cl
f0103898:	75 0a                	jne    f01038a4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010389a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010389d:	89 c7                	mov    %eax,%edi
f010389f:	fc                   	cld    
f01038a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038a2:	eb 05                	jmp    f01038a9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01038a4:	89 c7                	mov    %eax,%edi
f01038a6:	fc                   	cld    
f01038a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01038a9:	5e                   	pop    %esi
f01038aa:	5f                   	pop    %edi
f01038ab:	c9                   	leave  
f01038ac:	c3                   	ret    

f01038ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01038ad:	55                   	push   %ebp
f01038ae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01038b0:	ff 75 10             	pushl  0x10(%ebp)
f01038b3:	ff 75 0c             	pushl  0xc(%ebp)
f01038b6:	ff 75 08             	pushl  0x8(%ebp)
f01038b9:	e8 85 ff ff ff       	call   f0103843 <memmove>
}
f01038be:	c9                   	leave  
f01038bf:	c3                   	ret    

f01038c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01038c0:	55                   	push   %ebp
f01038c1:	89 e5                	mov    %esp,%ebp
f01038c3:	57                   	push   %edi
f01038c4:	56                   	push   %esi
f01038c5:	53                   	push   %ebx
f01038c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01038c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01038cc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01038cf:	85 ff                	test   %edi,%edi
f01038d1:	74 32                	je     f0103905 <memcmp+0x45>
		if (*s1 != *s2)
f01038d3:	8a 03                	mov    (%ebx),%al
f01038d5:	8a 0e                	mov    (%esi),%cl
f01038d7:	38 c8                	cmp    %cl,%al
f01038d9:	74 19                	je     f01038f4 <memcmp+0x34>
f01038db:	eb 0d                	jmp    f01038ea <memcmp+0x2a>
f01038dd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01038e1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01038e5:	42                   	inc    %edx
f01038e6:	38 c8                	cmp    %cl,%al
f01038e8:	74 10                	je     f01038fa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01038ea:	0f b6 c0             	movzbl %al,%eax
f01038ed:	0f b6 c9             	movzbl %cl,%ecx
f01038f0:	29 c8                	sub    %ecx,%eax
f01038f2:	eb 16                	jmp    f010390a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01038f4:	4f                   	dec    %edi
f01038f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01038fa:	39 fa                	cmp    %edi,%edx
f01038fc:	75 df                	jne    f01038dd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01038fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103903:	eb 05                	jmp    f010390a <memcmp+0x4a>
f0103905:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010390a:	5b                   	pop    %ebx
f010390b:	5e                   	pop    %esi
f010390c:	5f                   	pop    %edi
f010390d:	c9                   	leave  
f010390e:	c3                   	ret    

f010390f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010390f:	55                   	push   %ebp
f0103910:	89 e5                	mov    %esp,%ebp
f0103912:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103915:	89 c2                	mov    %eax,%edx
f0103917:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010391a:	39 d0                	cmp    %edx,%eax
f010391c:	73 12                	jae    f0103930 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010391e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0103921:	38 08                	cmp    %cl,(%eax)
f0103923:	75 06                	jne    f010392b <memfind+0x1c>
f0103925:	eb 09                	jmp    f0103930 <memfind+0x21>
f0103927:	38 08                	cmp    %cl,(%eax)
f0103929:	74 05                	je     f0103930 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010392b:	40                   	inc    %eax
f010392c:	39 c2                	cmp    %eax,%edx
f010392e:	77 f7                	ja     f0103927 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103930:	c9                   	leave  
f0103931:	c3                   	ret    

f0103932 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103932:	55                   	push   %ebp
f0103933:	89 e5                	mov    %esp,%ebp
f0103935:	57                   	push   %edi
f0103936:	56                   	push   %esi
f0103937:	53                   	push   %ebx
f0103938:	8b 55 08             	mov    0x8(%ebp),%edx
f010393b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010393e:	eb 01                	jmp    f0103941 <strtol+0xf>
		s++;
f0103940:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103941:	8a 02                	mov    (%edx),%al
f0103943:	3c 20                	cmp    $0x20,%al
f0103945:	74 f9                	je     f0103940 <strtol+0xe>
f0103947:	3c 09                	cmp    $0x9,%al
f0103949:	74 f5                	je     f0103940 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010394b:	3c 2b                	cmp    $0x2b,%al
f010394d:	75 08                	jne    f0103957 <strtol+0x25>
		s++;
f010394f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103950:	bf 00 00 00 00       	mov    $0x0,%edi
f0103955:	eb 13                	jmp    f010396a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103957:	3c 2d                	cmp    $0x2d,%al
f0103959:	75 0a                	jne    f0103965 <strtol+0x33>
		s++, neg = 1;
f010395b:	8d 52 01             	lea    0x1(%edx),%edx
f010395e:	bf 01 00 00 00       	mov    $0x1,%edi
f0103963:	eb 05                	jmp    f010396a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103965:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010396a:	85 db                	test   %ebx,%ebx
f010396c:	74 05                	je     f0103973 <strtol+0x41>
f010396e:	83 fb 10             	cmp    $0x10,%ebx
f0103971:	75 28                	jne    f010399b <strtol+0x69>
f0103973:	8a 02                	mov    (%edx),%al
f0103975:	3c 30                	cmp    $0x30,%al
f0103977:	75 10                	jne    f0103989 <strtol+0x57>
f0103979:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010397d:	75 0a                	jne    f0103989 <strtol+0x57>
		s += 2, base = 16;
f010397f:	83 c2 02             	add    $0x2,%edx
f0103982:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103987:	eb 12                	jmp    f010399b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103989:	85 db                	test   %ebx,%ebx
f010398b:	75 0e                	jne    f010399b <strtol+0x69>
f010398d:	3c 30                	cmp    $0x30,%al
f010398f:	75 05                	jne    f0103996 <strtol+0x64>
		s++, base = 8;
f0103991:	42                   	inc    %edx
f0103992:	b3 08                	mov    $0x8,%bl
f0103994:	eb 05                	jmp    f010399b <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103996:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010399b:	b8 00 00 00 00       	mov    $0x0,%eax
f01039a0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01039a2:	8a 0a                	mov    (%edx),%cl
f01039a4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01039a7:	80 fb 09             	cmp    $0x9,%bl
f01039aa:	77 08                	ja     f01039b4 <strtol+0x82>
			dig = *s - '0';
f01039ac:	0f be c9             	movsbl %cl,%ecx
f01039af:	83 e9 30             	sub    $0x30,%ecx
f01039b2:	eb 1e                	jmp    f01039d2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01039b4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01039b7:	80 fb 19             	cmp    $0x19,%bl
f01039ba:	77 08                	ja     f01039c4 <strtol+0x92>
			dig = *s - 'a' + 10;
f01039bc:	0f be c9             	movsbl %cl,%ecx
f01039bf:	83 e9 57             	sub    $0x57,%ecx
f01039c2:	eb 0e                	jmp    f01039d2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01039c4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01039c7:	80 fb 19             	cmp    $0x19,%bl
f01039ca:	77 13                	ja     f01039df <strtol+0xad>
			dig = *s - 'A' + 10;
f01039cc:	0f be c9             	movsbl %cl,%ecx
f01039cf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01039d2:	39 f1                	cmp    %esi,%ecx
f01039d4:	7d 0d                	jge    f01039e3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01039d6:	42                   	inc    %edx
f01039d7:	0f af c6             	imul   %esi,%eax
f01039da:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01039dd:	eb c3                	jmp    f01039a2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01039df:	89 c1                	mov    %eax,%ecx
f01039e1:	eb 02                	jmp    f01039e5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01039e3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01039e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01039e9:	74 05                	je     f01039f0 <strtol+0xbe>
		*endptr = (char *) s;
f01039eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039ee:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01039f0:	85 ff                	test   %edi,%edi
f01039f2:	74 04                	je     f01039f8 <strtol+0xc6>
f01039f4:	89 c8                	mov    %ecx,%eax
f01039f6:	f7 d8                	neg    %eax
}
f01039f8:	5b                   	pop    %ebx
f01039f9:	5e                   	pop    %esi
f01039fa:	5f                   	pop    %edi
f01039fb:	c9                   	leave  
f01039fc:	c3                   	ret    
f01039fd:	00 00                	add    %al,(%eax)
	...

f0103a00 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103a00:	55                   	push   %ebp
f0103a01:	89 e5                	mov    %esp,%ebp
f0103a03:	57                   	push   %edi
f0103a04:	56                   	push   %esi
f0103a05:	83 ec 10             	sub    $0x10,%esp
f0103a08:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103a0e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103a14:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103a17:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103a1a:	85 c0                	test   %eax,%eax
f0103a1c:	75 2e                	jne    f0103a4c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0103a1e:	39 f1                	cmp    %esi,%ecx
f0103a20:	77 5a                	ja     f0103a7c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103a22:	85 c9                	test   %ecx,%ecx
f0103a24:	75 0b                	jne    f0103a31 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103a26:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a2b:	31 d2                	xor    %edx,%edx
f0103a2d:	f7 f1                	div    %ecx
f0103a2f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103a31:	31 d2                	xor    %edx,%edx
f0103a33:	89 f0                	mov    %esi,%eax
f0103a35:	f7 f1                	div    %ecx
f0103a37:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a39:	89 f8                	mov    %edi,%eax
f0103a3b:	f7 f1                	div    %ecx
f0103a3d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a3f:	89 f8                	mov    %edi,%eax
f0103a41:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a43:	83 c4 10             	add    $0x10,%esp
f0103a46:	5e                   	pop    %esi
f0103a47:	5f                   	pop    %edi
f0103a48:	c9                   	leave  
f0103a49:	c3                   	ret    
f0103a4a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103a4c:	39 f0                	cmp    %esi,%eax
f0103a4e:	77 1c                	ja     f0103a6c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103a50:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0103a53:	83 f7 1f             	xor    $0x1f,%edi
f0103a56:	75 3c                	jne    f0103a94 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103a58:	39 f0                	cmp    %esi,%eax
f0103a5a:	0f 82 90 00 00 00    	jb     f0103af0 <__udivdi3+0xf0>
f0103a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a63:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0103a66:	0f 86 84 00 00 00    	jbe    f0103af0 <__udivdi3+0xf0>
f0103a6c:	31 f6                	xor    %esi,%esi
f0103a6e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a70:	89 f8                	mov    %edi,%eax
f0103a72:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a74:	83 c4 10             	add    $0x10,%esp
f0103a77:	5e                   	pop    %esi
f0103a78:	5f                   	pop    %edi
f0103a79:	c9                   	leave  
f0103a7a:	c3                   	ret    
f0103a7b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a7c:	89 f2                	mov    %esi,%edx
f0103a7e:	89 f8                	mov    %edi,%eax
f0103a80:	f7 f1                	div    %ecx
f0103a82:	89 c7                	mov    %eax,%edi
f0103a84:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a86:	89 f8                	mov    %edi,%eax
f0103a88:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a8a:	83 c4 10             	add    $0x10,%esp
f0103a8d:	5e                   	pop    %esi
f0103a8e:	5f                   	pop    %edi
f0103a8f:	c9                   	leave  
f0103a90:	c3                   	ret    
f0103a91:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103a94:	89 f9                	mov    %edi,%ecx
f0103a96:	d3 e0                	shl    %cl,%eax
f0103a98:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103a9b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103aa0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103aa5:	88 c1                	mov    %al,%cl
f0103aa7:	d3 ea                	shr    %cl,%edx
f0103aa9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103aac:	09 ca                	or     %ecx,%edx
f0103aae:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0103ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103ab4:	89 f9                	mov    %edi,%ecx
f0103ab6:	d3 e2                	shl    %cl,%edx
f0103ab8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0103abb:	89 f2                	mov    %esi,%edx
f0103abd:	88 c1                	mov    %al,%cl
f0103abf:	d3 ea                	shr    %cl,%edx
f0103ac1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103ac4:	89 f2                	mov    %esi,%edx
f0103ac6:	89 f9                	mov    %edi,%ecx
f0103ac8:	d3 e2                	shl    %cl,%edx
f0103aca:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103acd:	88 c1                	mov    %al,%cl
f0103acf:	d3 ee                	shr    %cl,%esi
f0103ad1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103ad3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ad6:	89 f0                	mov    %esi,%eax
f0103ad8:	89 ca                	mov    %ecx,%edx
f0103ada:	f7 75 ec             	divl   -0x14(%ebp)
f0103add:	89 d1                	mov    %edx,%ecx
f0103adf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103ae1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103ae4:	39 d1                	cmp    %edx,%ecx
f0103ae6:	72 28                	jb     f0103b10 <__udivdi3+0x110>
f0103ae8:	74 1a                	je     f0103b04 <__udivdi3+0x104>
f0103aea:	89 f7                	mov    %esi,%edi
f0103aec:	31 f6                	xor    %esi,%esi
f0103aee:	eb 80                	jmp    f0103a70 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103af0:	31 f6                	xor    %esi,%esi
f0103af2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103af7:	89 f8                	mov    %edi,%eax
f0103af9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103afb:	83 c4 10             	add    $0x10,%esp
f0103afe:	5e                   	pop    %esi
f0103aff:	5f                   	pop    %edi
f0103b00:	c9                   	leave  
f0103b01:	c3                   	ret    
f0103b02:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b07:	89 f9                	mov    %edi,%ecx
f0103b09:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b0b:	39 c2                	cmp    %eax,%edx
f0103b0d:	73 db                	jae    f0103aea <__udivdi3+0xea>
f0103b0f:	90                   	nop
		{
		  q0--;
f0103b10:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103b13:	31 f6                	xor    %esi,%esi
f0103b15:	e9 56 ff ff ff       	jmp    f0103a70 <__udivdi3+0x70>
	...

f0103b1c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103b1c:	55                   	push   %ebp
f0103b1d:	89 e5                	mov    %esp,%ebp
f0103b1f:	57                   	push   %edi
f0103b20:	56                   	push   %esi
f0103b21:	83 ec 20             	sub    $0x20,%esp
f0103b24:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b27:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103b2a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103b30:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103b33:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103b39:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103b3b:	85 ff                	test   %edi,%edi
f0103b3d:	75 15                	jne    f0103b54 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103b3f:	39 f1                	cmp    %esi,%ecx
f0103b41:	0f 86 99 00 00 00    	jbe    f0103be0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b47:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103b49:	89 d0                	mov    %edx,%eax
f0103b4b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b4d:	83 c4 20             	add    $0x20,%esp
f0103b50:	5e                   	pop    %esi
f0103b51:	5f                   	pop    %edi
f0103b52:	c9                   	leave  
f0103b53:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103b54:	39 f7                	cmp    %esi,%edi
f0103b56:	0f 87 a4 00 00 00    	ja     f0103c00 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103b5c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103b5f:	83 f0 1f             	xor    $0x1f,%eax
f0103b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b65:	0f 84 a1 00 00 00    	je     f0103c0c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103b6b:	89 f8                	mov    %edi,%eax
f0103b6d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b70:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103b72:	bf 20 00 00 00       	mov    $0x20,%edi
f0103b77:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b7d:	89 f9                	mov    %edi,%ecx
f0103b7f:	d3 ea                	shr    %cl,%edx
f0103b81:	09 c2                	or     %eax,%edx
f0103b83:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b89:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b8c:	d3 e0                	shl    %cl,%eax
f0103b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b91:	89 f2                	mov    %esi,%edx
f0103b93:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b98:	d3 e0                	shl    %cl,%eax
f0103b9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ba0:	89 f9                	mov    %edi,%ecx
f0103ba2:	d3 e8                	shr    %cl,%eax
f0103ba4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103ba6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103ba8:	89 f2                	mov    %esi,%edx
f0103baa:	f7 75 f0             	divl   -0x10(%ebp)
f0103bad:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103baf:	f7 65 f4             	mull   -0xc(%ebp)
f0103bb2:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103bb5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103bb7:	39 d6                	cmp    %edx,%esi
f0103bb9:	72 71                	jb     f0103c2c <__umoddi3+0x110>
f0103bbb:	74 7f                	je     f0103c3c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103bc0:	29 c8                	sub    %ecx,%eax
f0103bc2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103bc4:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103bc7:	d3 e8                	shr    %cl,%eax
f0103bc9:	89 f2                	mov    %esi,%edx
f0103bcb:	89 f9                	mov    %edi,%ecx
f0103bcd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103bcf:	09 d0                	or     %edx,%eax
f0103bd1:	89 f2                	mov    %esi,%edx
f0103bd3:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103bd6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103bd8:	83 c4 20             	add    $0x20,%esp
f0103bdb:	5e                   	pop    %esi
f0103bdc:	5f                   	pop    %edi
f0103bdd:	c9                   	leave  
f0103bde:	c3                   	ret    
f0103bdf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103be0:	85 c9                	test   %ecx,%ecx
f0103be2:	75 0b                	jne    f0103bef <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103be4:	b8 01 00 00 00       	mov    $0x1,%eax
f0103be9:	31 d2                	xor    %edx,%edx
f0103beb:	f7 f1                	div    %ecx
f0103bed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103bef:	89 f0                	mov    %esi,%eax
f0103bf1:	31 d2                	xor    %edx,%edx
f0103bf3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103bf8:	f7 f1                	div    %ecx
f0103bfa:	e9 4a ff ff ff       	jmp    f0103b49 <__umoddi3+0x2d>
f0103bff:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103c00:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c02:	83 c4 20             	add    $0x20,%esp
f0103c05:	5e                   	pop    %esi
f0103c06:	5f                   	pop    %edi
f0103c07:	c9                   	leave  
f0103c08:	c3                   	ret    
f0103c09:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103c0c:	39 f7                	cmp    %esi,%edi
f0103c0e:	72 05                	jb     f0103c15 <__umoddi3+0xf9>
f0103c10:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103c13:	77 0c                	ja     f0103c21 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103c15:	89 f2                	mov    %esi,%edx
f0103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c1a:	29 c8                	sub    %ecx,%eax
f0103c1c:	19 fa                	sbb    %edi,%edx
f0103c1e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c24:	83 c4 20             	add    $0x20,%esp
f0103c27:	5e                   	pop    %esi
f0103c28:	5f                   	pop    %edi
f0103c29:	c9                   	leave  
f0103c2a:	c3                   	ret    
f0103c2b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103c2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c2f:	89 c1                	mov    %eax,%ecx
f0103c31:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103c34:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103c37:	eb 84                	jmp    f0103bbd <__umoddi3+0xa1>
f0103c39:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103c3c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103c3f:	72 eb                	jb     f0103c2c <__umoddi3+0x110>
f0103c41:	89 f2                	mov    %esi,%edx
f0103c43:	e9 75 ff ff ff       	jmp    f0103bbd <__umoddi3+0xa1>
