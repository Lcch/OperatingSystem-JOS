
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
f0100058:	e8 fc 37 00 00       	call   f0103859 <memset>

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
f010006a:	68 c0 3c 10 f0       	push   $0xf0103cc0
f010006f:	e8 b5 2c 00 00       	call   f0102d29 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 3e 16 00 00       	call   f01016b7 <mem_init>
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
f01000b0:	68 db 3c 10 f0       	push   $0xf0103cdb
f01000b5:	e8 6f 2c 00 00       	call   f0102d29 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 3f 2c 00 00       	call   f0102d03 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 d1 3f 10 f0 	movl   $0xf0103fd1,(%esp)
f01000cb:	e8 59 2c 00 00       	call   f0102d29 <cprintf>
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
f01000f2:	68 f3 3c 10 f0       	push   $0xf0103cf3
f01000f7:	e8 2d 2c 00 00       	call   f0102d29 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 fb 2b 00 00       	call   f0102d03 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 d1 3f 10 f0 	movl   $0xf0103fd1,(%esp)
f010010f:	e8 15 2c 00 00       	call   f0102d29 <cprintf>
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
f01002fd:	e8 a1 35 00 00       	call   f01038a3 <memmove>
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
f010039c:	8a 82 40 3d 10 f0    	mov    -0xfefc2c0(%edx),%al
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
f01003d8:	0f b6 82 40 3d 10 f0 	movzbl -0xfefc2c0(%edx),%eax
f01003df:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 40 3e 10 f0 	movzbl -0xfefc1c0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 40 3f 10 f0 	mov    -0xfefc0c0(,%ecx,4),%ecx
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
f0100430:	68 0d 3d 10 f0       	push   $0xf0103d0d
f0100435:	e8 ef 28 00 00       	call   f0102d29 <cprintf>
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
f0100591:	68 19 3d 10 f0       	push   $0xf0103d19
f0100596:	e8 8e 27 00 00       	call   f0102d29 <cprintf>
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
f01005da:	68 50 3f 10 f0       	push   $0xf0103f50
f01005df:	e8 45 27 00 00       	call   f0102d29 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 88 41 10 f0       	push   $0xf0104188
f01005f1:	e8 33 27 00 00       	call   f0102d29 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 b0 41 10 f0       	push   $0xf01041b0
f0100608:	e8 1c 27 00 00       	call   f0102d29 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 a8 3c 10 00       	push   $0x103ca8
f0100615:	68 a8 3c 10 f0       	push   $0xf0103ca8
f010061a:	68 d4 41 10 f0       	push   $0xf01041d4
f010061f:	e8 05 27 00 00       	call   f0102d29 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 f3 11 00       	push   $0x11f300
f010062c:	68 00 f3 11 f0       	push   $0xf011f300
f0100631:	68 f8 41 10 f0       	push   $0xf01041f8
f0100636:	e8 ee 26 00 00       	call   f0102d29 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 f9 11 00       	push   $0x11f950
f0100643:	68 50 f9 11 f0       	push   $0xf011f950
f0100648:	68 1c 42 10 f0       	push   $0xf010421c
f010064d:	e8 d7 26 00 00       	call   f0102d29 <cprintf>
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
f0100674:	68 40 42 10 f0       	push   $0xf0104240
f0100679:	e8 ab 26 00 00       	call   f0102d29 <cprintf>
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
f0100694:	ff b3 24 47 10 f0    	pushl  -0xfefb8dc(%ebx)
f010069a:	ff b3 20 47 10 f0    	pushl  -0xfefb8e0(%ebx)
f01006a0:	68 69 3f 10 f0       	push   $0xf0103f69
f01006a5:	e8 7f 26 00 00       	call   f0102d29 <cprintf>
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
f01006ce:	68 6c 42 10 f0       	push   $0xf010426c
f01006d3:	e8 51 26 00 00       	call   f0102d29 <cprintf>
        cprintf("Example: kernelpd 0x01\n");
f01006d8:	c7 04 24 72 3f 10 f0 	movl   $0xf0103f72,(%esp)
f01006df:	e8 45 26 00 00       	call   f0102d29 <cprintf>
        cprintf("         show kernel page directory[1] infomation \n");
f01006e4:	c7 04 24 98 42 10 f0 	movl   $0xf0104298,(%esp)
f01006eb:	e8 39 26 00 00       	call   f0102d29 <cprintf>
f01006f0:	83 c4 10             	add    $0x10,%esp
f01006f3:	eb 48                	jmp    f010073d <mon_kernelpd+0x7e>
    } else {
        uint32_t id = strtol(argv[1], NULL, 0);
f01006f5:	83 ec 04             	sub    $0x4,%esp
f01006f8:	6a 00                	push   $0x0
f01006fa:	6a 00                	push   $0x0
f01006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01006ff:	ff 70 04             	pushl  0x4(%eax)
f0100702:	e8 8b 32 00 00       	call   f0103992 <strtol>
        if (0 > id || id >= 1024) {
f0100707:	83 c4 10             	add    $0x10,%esp
f010070a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010070f:	76 12                	jbe    f0100723 <mon_kernelpd+0x64>
            cprintf("out of entry num, it should be in [0, 1024)\n");
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	68 cc 42 10 f0       	push   $0xf01042cc
f0100719:	e8 0b 26 00 00       	call   f0102d29 <cprintf>
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	eb 1a                	jmp    f010073d <mon_kernelpd+0x7e>
        } else {
            cprintf("pgdir[%d] = 0x%08x\n", id, (uint32_t)kern_pgdir[id]);
f0100723:	83 ec 04             	sub    $0x4,%esp
f0100726:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f010072c:	ff 34 82             	pushl  (%edx,%eax,4)
f010072f:	50                   	push   %eax
f0100730:	68 8a 3f 10 f0       	push   $0xf0103f8a
f0100735:	e8 ef 25 00 00       	call   f0102d29 <cprintf>
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
f0100759:	68 fc 42 10 f0       	push   $0xf01042fc
f010075e:	e8 c6 25 00 00       	call   f0102d29 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100763:	c7 04 24 30 43 10 f0 	movl   $0xf0104330,(%esp)
f010076a:	e8 ba 25 00 00       	call   f0102d29 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
f0100772:	e9 1a 01 00 00       	jmp    f0100891 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100777:	83 ec 04             	sub    $0x4,%esp
f010077a:	6a 00                	push   $0x0
f010077c:	6a 00                	push   $0x0
f010077e:	ff 76 04             	pushl  0x4(%esi)
f0100781:	e8 0c 32 00 00       	call   f0103992 <strtol>
f0100786:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100788:	83 c4 0c             	add    $0xc,%esp
f010078b:	6a 00                	push   $0x0
f010078d:	6a 00                	push   $0x0
f010078f:	ff 76 08             	pushl  0x8(%esi)
f0100792:	e8 fb 31 00 00       	call   f0103992 <strtol>
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
f01007b6:	68 9e 3f 10 f0       	push   $0xf0103f9e
f01007bb:	e8 69 25 00 00       	call   f0102d29 <cprintf>
        
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
f01007d9:	68 af 3f 10 f0       	push   $0xf0103faf
f01007de:	e8 46 25 00 00       	call   f0102d29 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	6a 00                	push   $0x0
f01007e8:	53                   	push   %ebx
f01007e9:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01007ef:	e8 6d 0c 00 00       	call   f0101461 <pgdir_walk>
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
f0100806:	68 c6 3f 10 f0       	push   $0xf0103fc6
f010080b:	e8 19 25 00 00       	call   f0102d29 <cprintf>
f0100810:	83 c4 10             	add    $0x10,%esp
f0100813:	eb 74                	jmp    f0100889 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100815:	83 ec 08             	sub    $0x8,%esp
f0100818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010081d:	50                   	push   %eax
f010081e:	68 d3 3f 10 f0       	push   $0xf0103fd3
f0100823:	e8 01 25 00 00       	call   f0102d29 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	f6 03 04             	testb  $0x4,(%ebx)
f010082e:	74 12                	je     f0100842 <mon_showmappings+0xfe>
f0100830:	83 ec 0c             	sub    $0xc,%esp
f0100833:	68 db 3f 10 f0       	push   $0xf0103fdb
f0100838:	e8 ec 24 00 00       	call   f0102d29 <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp
f0100840:	eb 10                	jmp    f0100852 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100842:	83 ec 0c             	sub    $0xc,%esp
f0100845:	68 e8 3f 10 f0       	push   $0xf0103fe8
f010084a:	e8 da 24 00 00       	call   f0102d29 <cprintf>
f010084f:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100852:	f6 03 02             	testb  $0x2,(%ebx)
f0100855:	74 12                	je     f0100869 <mon_showmappings+0x125>
f0100857:	83 ec 0c             	sub    $0xc,%esp
f010085a:	68 f5 3f 10 f0       	push   $0xf0103ff5
f010085f:	e8 c5 24 00 00       	call   f0102d29 <cprintf>
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	eb 10                	jmp    f0100879 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100869:	83 ec 0c             	sub    $0xc,%esp
f010086c:	68 fa 3f 10 f0       	push   $0xf0103ffa
f0100871:	e8 b3 24 00 00       	call   f0102d29 <cprintf>
f0100876:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100879:	83 ec 0c             	sub    $0xc,%esp
f010087c:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100881:	e8 a3 24 00 00       	call   f0102d29 <cprintf>
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
f01008b3:	68 58 43 10 f0       	push   $0xf0104358
f01008b8:	e8 6c 24 00 00       	call   f0102d29 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008bd:	c7 04 24 a8 43 10 f0 	movl   $0xf01043a8,(%esp)
f01008c4:	e8 60 24 00 00       	call   f0102d29 <cprintf>
f01008c9:	83 c4 10             	add    $0x10,%esp
f01008cc:	e9 a5 01 00 00       	jmp    f0100a76 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f01008d1:	83 ec 04             	sub    $0x4,%esp
f01008d4:	6a 00                	push   $0x0
f01008d6:	6a 00                	push   $0x0
f01008d8:	ff 73 04             	pushl  0x4(%ebx)
f01008db:	e8 b2 30 00 00       	call   f0103992 <strtol>
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
f0100921:	e8 3b 0b 00 00       	call   f0101461 <pgdir_walk>
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
f010093f:	68 cc 43 10 f0       	push   $0xf01043cc
f0100944:	e8 e0 23 00 00       	call   f0102d29 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	f6 03 02             	testb  $0x2,(%ebx)
f010094f:	74 12                	je     f0100963 <mon_setpermission+0xc5>
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	68 fe 3f 10 f0       	push   $0xf0103ffe
f0100959:	e8 cb 23 00 00       	call   f0102d29 <cprintf>
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	eb 10                	jmp    f0100973 <mon_setpermission+0xd5>
f0100963:	83 ec 0c             	sub    $0xc,%esp
f0100966:	68 01 40 10 f0       	push   $0xf0104001
f010096b:	e8 b9 23 00 00       	call   f0102d29 <cprintf>
f0100970:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100973:	f6 03 04             	testb  $0x4,(%ebx)
f0100976:	74 12                	je     f010098a <mon_setpermission+0xec>
f0100978:	83 ec 0c             	sub    $0xc,%esp
f010097b:	68 8d 50 10 f0       	push   $0xf010508d
f0100980:	e8 a4 23 00 00       	call   f0102d29 <cprintf>
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	eb 10                	jmp    f010099a <mon_setpermission+0xfc>
f010098a:	83 ec 0c             	sub    $0xc,%esp
f010098d:	68 04 40 10 f0       	push   $0xf0104004
f0100992:	e8 92 23 00 00       	call   f0102d29 <cprintf>
f0100997:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f010099a:	f6 03 01             	testb  $0x1,(%ebx)
f010099d:	74 12                	je     f01009b1 <mon_setpermission+0x113>
f010099f:	83 ec 0c             	sub    $0xc,%esp
f01009a2:	68 19 51 10 f0       	push   $0xf0105119
f01009a7:	e8 7d 23 00 00       	call   f0102d29 <cprintf>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	eb 10                	jmp    f01009c1 <mon_setpermission+0x123>
f01009b1:	83 ec 0c             	sub    $0xc,%esp
f01009b4:	68 02 40 10 f0       	push   $0xf0104002
f01009b9:	e8 6b 23 00 00       	call   f0102d29 <cprintf>
f01009be:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f01009c1:	83 ec 0c             	sub    $0xc,%esp
f01009c4:	68 06 40 10 f0       	push   $0xf0104006
f01009c9:	e8 5b 23 00 00       	call   f0102d29 <cprintf>
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
f01009e7:	68 fe 3f 10 f0       	push   $0xf0103ffe
f01009ec:	e8 38 23 00 00       	call   f0102d29 <cprintf>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	eb 10                	jmp    f0100a06 <mon_setpermission+0x168>
f01009f6:	83 ec 0c             	sub    $0xc,%esp
f01009f9:	68 01 40 10 f0       	push   $0xf0104001
f01009fe:	e8 26 23 00 00       	call   f0102d29 <cprintf>
f0100a03:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a06:	f6 03 04             	testb  $0x4,(%ebx)
f0100a09:	74 12                	je     f0100a1d <mon_setpermission+0x17f>
f0100a0b:	83 ec 0c             	sub    $0xc,%esp
f0100a0e:	68 8d 50 10 f0       	push   $0xf010508d
f0100a13:	e8 11 23 00 00       	call   f0102d29 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	eb 10                	jmp    f0100a2d <mon_setpermission+0x18f>
f0100a1d:	83 ec 0c             	sub    $0xc,%esp
f0100a20:	68 04 40 10 f0       	push   $0xf0104004
f0100a25:	e8 ff 22 00 00       	call   f0102d29 <cprintf>
f0100a2a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a2d:	f6 03 01             	testb  $0x1,(%ebx)
f0100a30:	74 12                	je     f0100a44 <mon_setpermission+0x1a6>
f0100a32:	83 ec 0c             	sub    $0xc,%esp
f0100a35:	68 19 51 10 f0       	push   $0xf0105119
f0100a3a:	e8 ea 22 00 00       	call   f0102d29 <cprintf>
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	eb 10                	jmp    f0100a54 <mon_setpermission+0x1b6>
f0100a44:	83 ec 0c             	sub    $0xc,%esp
f0100a47:	68 02 40 10 f0       	push   $0xf0104002
f0100a4c:	e8 d8 22 00 00       	call   f0102d29 <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a54:	83 ec 0c             	sub    $0xc,%esp
f0100a57:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100a5c:	e8 c8 22 00 00       	call   f0102d29 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
f0100a64:	eb 10                	jmp    f0100a76 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a66:	83 ec 0c             	sub    $0xc,%esp
f0100a69:	68 c6 3f 10 f0       	push   $0xf0103fc6
f0100a6e:	e8 b6 22 00 00       	call   f0102d29 <cprintf>
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
f0100a94:	68 f0 43 10 f0       	push   $0xf01043f0
f0100a99:	e8 8b 22 00 00       	call   f0102d29 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a9e:	c7 04 24 20 44 10 f0 	movl   $0xf0104420,(%esp)
f0100aa5:	e8 7f 22 00 00       	call   f0102d29 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100aaa:	c7 04 24 40 44 10 f0 	movl   $0xf0104440,(%esp)
f0100ab1:	e8 73 22 00 00       	call   f0102d29 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ab6:	c7 04 24 74 44 10 f0 	movl   $0xf0104474,(%esp)
f0100abd:	e8 67 22 00 00       	call   f0102d29 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100ac2:	c7 04 24 b8 44 10 f0 	movl   $0xf01044b8,(%esp)
f0100ac9:	e8 5b 22 00 00       	call   f0102d29 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ace:	c7 04 24 17 40 10 f0 	movl   $0xf0104017,(%esp)
f0100ad5:	e8 4f 22 00 00       	call   f0102d29 <cprintf>
        cprintf("         set the background color to black\n");
f0100ada:	c7 04 24 fc 44 10 f0 	movl   $0xf01044fc,(%esp)
f0100ae1:	e8 43 22 00 00       	call   f0102d29 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100ae6:	c7 04 24 28 45 10 f0 	movl   $0xf0104528,(%esp)
f0100aed:	e8 37 22 00 00       	call   f0102d29 <cprintf>
f0100af2:	83 c4 10             	add    $0x10,%esp
f0100af5:	eb 52                	jmp    f0100b49 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100af7:	83 ec 0c             	sub    $0xc,%esp
f0100afa:	ff 73 04             	pushl  0x4(%ebx)
f0100afd:	e8 8e 2b 00 00       	call   f0103690 <strlen>
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
f0100b3c:	68 5c 45 10 f0       	push   $0xf010455c
f0100b41:	e8 e3 21 00 00       	call   f0102d29 <cprintf>
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
f0100b7d:	68 80 45 10 f0       	push   $0xf0104580
f0100b82:	e8 a2 21 00 00       	call   f0102d29 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b87:	83 c4 18             	add    $0x18,%esp
f0100b8a:	57                   	push   %edi
f0100b8b:	ff 76 04             	pushl  0x4(%esi)
f0100b8e:	e8 d2 22 00 00       	call   f0102e65 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b93:	83 c4 0c             	add    $0xc,%esp
f0100b96:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b99:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b9c:	68 33 40 10 f0       	push   $0xf0104033
f0100ba1:	e8 83 21 00 00       	call   f0102d29 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100ba6:	83 c4 0c             	add    $0xc,%esp
f0100ba9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100bac:	ff 75 dc             	pushl  -0x24(%ebp)
f0100baf:	68 43 40 10 f0       	push   $0xf0104043
f0100bb4:	e8 70 21 00 00       	call   f0102d29 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100bb9:	83 c4 08             	add    $0x8,%esp
f0100bbc:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100bbf:	53                   	push   %ebx
f0100bc0:	68 48 40 10 f0       	push   $0xf0104048
f0100bc5:	e8 5f 21 00 00       	call   f0102d29 <cprintf>
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
f0100bfc:	68 b8 45 10 f0       	push   $0xf01045b8
f0100c01:	68 93 00 00 00       	push   $0x93
f0100c06:	68 4d 40 10 f0       	push   $0xf010404d
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
f0100c40:	68 b8 45 10 f0       	push   $0xf01045b8
f0100c45:	68 98 00 00 00       	push   $0x98
f0100c4a:	68 4d 40 10 f0       	push   $0xf010404d
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
f0100ca2:	68 dc 45 10 f0       	push   $0xf01045dc
f0100ca7:	e8 7d 20 00 00       	call   f0102d29 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100cac:	c7 04 24 0c 46 10 f0 	movl   $0xf010460c,(%esp)
f0100cb3:	e8 71 20 00 00       	call   f0102d29 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100cb8:	c7 04 24 34 46 10 f0 	movl   $0xf0104634,(%esp)
f0100cbf:	e8 65 20 00 00       	call   f0102d29 <cprintf>
f0100cc4:	83 c4 10             	add    $0x10,%esp
f0100cc7:	e9 59 01 00 00       	jmp    f0100e25 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ccc:	83 ec 04             	sub    $0x4,%esp
f0100ccf:	6a 00                	push   $0x0
f0100cd1:	6a 00                	push   $0x0
f0100cd3:	ff 76 08             	pushl  0x8(%esi)
f0100cd6:	e8 b7 2c 00 00       	call   f0103992 <strtol>
f0100cdb:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100cdd:	83 c4 0c             	add    $0xc,%esp
f0100ce0:	6a 00                	push   $0x0
f0100ce2:	6a 00                	push   $0x0
f0100ce4:	ff 76 0c             	pushl  0xc(%esi)
f0100ce7:	e8 a6 2c 00 00       	call   f0103992 <strtol>
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
f0100d28:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100d2d:	e8 f7 1f 00 00       	call   f0102d29 <cprintf>
f0100d32:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d35:	83 ec 08             	sub    $0x8,%esp
f0100d38:	53                   	push   %ebx
f0100d39:	68 5c 40 10 f0       	push   $0xf010405c
f0100d3e:	e8 e6 1f 00 00       	call   f0102d29 <cprintf>
f0100d43:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d46:	83 ec 04             	sub    $0x4,%esp
f0100d49:	6a 00                	push   $0x0
f0100d4b:	89 d8                	mov    %ebx,%eax
f0100d4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d52:	50                   	push   %eax
f0100d53:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0100d59:	e8 03 07 00 00       	call   f0101461 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	74 19                	je     f0100d7e <mon_dump+0xf1>
f0100d65:	f6 00 01             	testb  $0x1,(%eax)
f0100d68:	74 14                	je     f0100d7e <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d6a:	83 ec 08             	sub    $0x8,%esp
f0100d6d:	ff 33                	pushl  (%ebx)
f0100d6f:	68 66 40 10 f0       	push   $0xf0104066
f0100d74:	e8 b0 1f 00 00       	call   f0102d29 <cprintf>
f0100d79:	83 c4 10             	add    $0x10,%esp
f0100d7c:	eb 10                	jmp    f0100d8e <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d7e:	83 ec 0c             	sub    $0xc,%esp
f0100d81:	68 71 40 10 f0       	push   $0xf0104071
f0100d86:	e8 9e 1f 00 00       	call   f0102d29 <cprintf>
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
f0100d99:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100d9e:	e8 86 1f 00 00       	call   f0102d29 <cprintf>
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
f0100db9:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100dbe:	e8 66 1f 00 00       	call   f0102d29 <cprintf>
f0100dc3:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100dc6:	83 ec 08             	sub    $0x8,%esp
f0100dc9:	53                   	push   %ebx
f0100dca:	68 5c 40 10 f0       	push   $0xf010405c
f0100dcf:	e8 55 1f 00 00       	call   f0102d29 <cprintf>
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
f0100dee:	68 66 40 10 f0       	push   $0xf0104066
f0100df3:	e8 31 1f 00 00       	call   f0102d29 <cprintf>
f0100df8:	83 c4 10             	add    $0x10,%esp
f0100dfb:	eb 10                	jmp    f0100e0d <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100dfd:	83 ec 0c             	sub    $0xc,%esp
f0100e00:	68 6f 40 10 f0       	push   $0xf010406f
f0100e05:	e8 1f 1f 00 00       	call   f0102d29 <cprintf>
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
f0100e18:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0100e1d:	e8 07 1f 00 00       	call   f0102d29 <cprintf>
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
f0100e3b:	68 78 46 10 f0       	push   $0xf0104678
f0100e40:	e8 e4 1e 00 00       	call   f0102d29 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e45:	c7 04 24 9c 46 10 f0 	movl   $0xf010469c,(%esp)
f0100e4c:	e8 d8 1e 00 00       	call   f0102d29 <cprintf>
f0100e51:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e54:	83 ec 0c             	sub    $0xc,%esp
f0100e57:	68 7c 40 10 f0       	push   $0xf010407c
f0100e5c:	e8 5f 27 00 00       	call   f01035c0 <readline>
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
f0100e89:	68 80 40 10 f0       	push   $0xf0104080
f0100e8e:	e8 76 29 00 00       	call   f0103809 <strchr>
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
f0100ea9:	68 85 40 10 f0       	push   $0xf0104085
f0100eae:	e8 76 1e 00 00       	call   f0102d29 <cprintf>
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
f0100ed3:	68 80 40 10 f0       	push   $0xf0104080
f0100ed8:	e8 2c 29 00 00       	call   f0103809 <strchr>
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
f0100ef6:	bb 20 47 10 f0       	mov    $0xf0104720,%ebx
f0100efb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f00:	83 ec 08             	sub    $0x8,%esp
f0100f03:	ff 33                	pushl  (%ebx)
f0100f05:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f08:	e8 8e 28 00 00       	call   f010379b <strcmp>
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
f0100f22:	ff 97 28 47 10 f0    	call   *-0xfefb8d8(%edi)
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
f0100f43:	68 a2 40 10 f0       	push   $0xf01040a2
f0100f48:	e8 dc 1d 00 00       	call   f0102d29 <cprintf>
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
f0100fcf:	68 80 47 10 f0       	push   $0xf0104780
f0100fd4:	68 d7 02 00 00       	push   $0x2d7
f0100fd9:	68 78 4e 10 f0       	push   $0xf0104e78
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
f0101017:	e8 ac 1c 00 00       	call   f0102cc8 <mc146818_read>
f010101c:	89 c6                	mov    %eax,%esi
f010101e:	43                   	inc    %ebx
f010101f:	89 1c 24             	mov    %ebx,(%esp)
f0101022:	e8 a1 1c 00 00       	call   f0102cc8 <mc146818_read>
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
f0101054:	68 a4 47 10 f0       	push   $0xf01047a4
f0101059:	68 14 02 00 00       	push   $0x214
f010105e:	68 78 4e 10 f0       	push   $0xf0104e78
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
f01010e1:	68 80 47 10 f0       	push   $0xf0104780
f01010e6:	6a 52                	push   $0x52
f01010e8:	68 84 4e 10 f0       	push   $0xf0104e84
f01010ed:	e8 99 ef ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010f2:	83 ec 04             	sub    $0x4,%esp
f01010f5:	68 80 00 00 00       	push   $0x80
f01010fa:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101104:	50                   	push   %eax
f0101105:	e8 4f 27 00 00       	call   f0103859 <memset>
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
f010117b:	68 92 4e 10 f0       	push   $0xf0104e92
f0101180:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101185:	68 2e 02 00 00       	push   $0x22e
f010118a:	68 78 4e 10 f0       	push   $0xf0104e78
f010118f:	e8 f7 ee ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0101194:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101197:	72 19                	jb     f01011b2 <check_page_free_list+0x17f>
f0101199:	68 b3 4e 10 f0       	push   $0xf0104eb3
f010119e:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01011a3:	68 2f 02 00 00       	push   $0x22f
f01011a8:	68 78 4e 10 f0       	push   $0xf0104e78
f01011ad:	e8 d9 ee ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011b2:	89 d0                	mov    %edx,%eax
f01011b4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011b7:	a8 07                	test   $0x7,%al
f01011b9:	74 19                	je     f01011d4 <check_page_free_list+0x1a1>
f01011bb:	68 c8 47 10 f0       	push   $0xf01047c8
f01011c0:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01011c5:	68 30 02 00 00       	push   $0x230
f01011ca:	68 78 4e 10 f0       	push   $0xf0104e78
f01011cf:	e8 b7 ee ff ff       	call   f010008b <_panic>
f01011d4:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011d7:	c1 e0 0c             	shl    $0xc,%eax
f01011da:	75 19                	jne    f01011f5 <check_page_free_list+0x1c2>
f01011dc:	68 c7 4e 10 f0       	push   $0xf0104ec7
f01011e1:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01011e6:	68 33 02 00 00       	push   $0x233
f01011eb:	68 78 4e 10 f0       	push   $0xf0104e78
f01011f0:	e8 96 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011f5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011fa:	75 19                	jne    f0101215 <check_page_free_list+0x1e2>
f01011fc:	68 d8 4e 10 f0       	push   $0xf0104ed8
f0101201:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101206:	68 34 02 00 00       	push   $0x234
f010120b:	68 78 4e 10 f0       	push   $0xf0104e78
f0101210:	e8 76 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101215:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010121a:	75 19                	jne    f0101235 <check_page_free_list+0x202>
f010121c:	68 fc 47 10 f0       	push   $0xf01047fc
f0101221:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101226:	68 35 02 00 00       	push   $0x235
f010122b:	68 78 4e 10 f0       	push   $0xf0104e78
f0101230:	e8 56 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101235:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010123a:	75 19                	jne    f0101255 <check_page_free_list+0x222>
f010123c:	68 f1 4e 10 f0       	push   $0xf0104ef1
f0101241:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101246:	68 36 02 00 00       	push   $0x236
f010124b:	68 78 4e 10 f0       	push   $0xf0104e78
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
f0101267:	68 80 47 10 f0       	push   $0xf0104780
f010126c:	6a 52                	push   $0x52
f010126e:	68 84 4e 10 f0       	push   $0xf0104e84
f0101273:	e8 13 ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101278:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f010127e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101281:	76 1c                	jbe    f010129f <check_page_free_list+0x26c>
f0101283:	68 20 48 10 f0       	push   $0xf0104820
f0101288:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010128d:	68 37 02 00 00       	push   $0x237
f0101292:	68 78 4e 10 f0       	push   $0xf0104e78
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
f01012ae:	68 0b 4f 10 f0       	push   $0xf0104f0b
f01012b3:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01012b8:	68 3f 02 00 00       	push   $0x23f
f01012bd:	68 78 4e 10 f0       	push   $0xf0104e78
f01012c2:	e8 c4 ed ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f01012c7:	85 f6                	test   %esi,%esi
f01012c9:	7f 19                	jg     f01012e4 <check_page_free_list+0x2b1>
f01012cb:	68 1d 4f 10 f0       	push   $0xf0104f1d
f01012d0:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01012d5:	68 40 02 00 00       	push   $0x240
f01012da:	68 78 4e 10 f0       	push   $0xf0104e78
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
f010130d:	68 b8 45 10 f0       	push   $0xf01045b8
f0101312:	68 14 01 00 00       	push   $0x114
f0101317:	68 78 4e 10 f0       	push   $0xf0104e78
f010131c:	e8 6a ed ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101321:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101327:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f010132a:	83 3d 44 f9 11 f0 00 	cmpl   $0x0,0xf011f944
f0101331:	74 5f                	je     f0101392 <page_init+0xa6>
f0101333:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f0101339:	ba 00 00 00 00       	mov    $0x0,%edx
f010133e:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101343:	85 c0                	test   %eax,%eax
f0101345:	74 25                	je     f010136c <page_init+0x80>
f0101347:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f010134c:	76 04                	jbe    f0101352 <page_init+0x66>
f010134e:	39 c6                	cmp    %eax,%esi
f0101350:	77 1a                	ja     f010136c <page_init+0x80>
		    pages[i].pp_ref = 0;
f0101352:	89 d1                	mov    %edx,%ecx
f0101354:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f010135a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101360:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0101362:	89 d3                	mov    %edx,%ebx
f0101364:	03 1d 4c f9 11 f0    	add    0xf011f94c,%ebx
f010136a:	eb 14                	jmp    f0101380 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f010136c:	89 d1                	mov    %edx,%ecx
f010136e:	03 0d 4c f9 11 f0    	add    0xf011f94c,%ecx
f0101374:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010137a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101380:	40                   	inc    %eax
f0101381:	83 c2 08             	add    $0x8,%edx
f0101384:	39 05 44 f9 11 f0    	cmp    %eax,0xf011f944
f010138a:	77 b7                	ja     f0101343 <page_init+0x57>
f010138c:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f0101392:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101395:	5b                   	pop    %ebx
f0101396:	5e                   	pop    %esi
f0101397:	c9                   	leave  
f0101398:	c3                   	ret    

f0101399 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101399:	55                   	push   %ebp
f010139a:	89 e5                	mov    %esp,%ebp
f010139c:	53                   	push   %ebx
f010139d:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013a0:	8b 1d 2c f5 11 f0    	mov    0xf011f52c,%ebx
f01013a6:	85 db                	test   %ebx,%ebx
f01013a8:	74 63                	je     f010140d <page_alloc+0x74>
f01013aa:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013af:	74 63                	je     f0101414 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01013b1:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013b3:	85 db                	test   %ebx,%ebx
f01013b5:	75 08                	jne    f01013bf <page_alloc+0x26>
f01013b7:	89 1d 2c f5 11 f0    	mov    %ebx,0xf011f52c
f01013bd:	eb 4e                	jmp    f010140d <page_alloc+0x74>
f01013bf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013c4:	75 eb                	jne    f01013b1 <page_alloc+0x18>
f01013c6:	eb 4c                	jmp    f0101414 <page_alloc+0x7b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013c8:	89 d8                	mov    %ebx,%eax
f01013ca:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01013d0:	c1 f8 03             	sar    $0x3,%eax
f01013d3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d6:	89 c2                	mov    %eax,%edx
f01013d8:	c1 ea 0c             	shr    $0xc,%edx
f01013db:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01013e1:	72 12                	jb     f01013f5 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e3:	50                   	push   %eax
f01013e4:	68 80 47 10 f0       	push   $0xf0104780
f01013e9:	6a 52                	push   $0x52
f01013eb:	68 84 4e 10 f0       	push   $0xf0104e84
f01013f0:	e8 96 ec ff ff       	call   f010008b <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f01013f5:	83 ec 04             	sub    $0x4,%esp
f01013f8:	68 00 10 00 00       	push   $0x1000
f01013fd:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101404:	50                   	push   %eax
f0101405:	e8 4f 24 00 00       	call   f0103859 <memset>
f010140a:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f010140d:	89 d8                	mov    %ebx,%eax
f010140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101412:	c9                   	leave  
f0101413:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101414:	8b 03                	mov    (%ebx),%eax
f0101416:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
        if (alloc_flags & ALLOC_ZERO) {
f010141b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010141f:	74 ec                	je     f010140d <page_alloc+0x74>
f0101421:	eb a5                	jmp    f01013c8 <page_alloc+0x2f>

f0101423 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101423:	55                   	push   %ebp
f0101424:	89 e5                	mov    %esp,%ebp
f0101426:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101429:	85 c0                	test   %eax,%eax
f010142b:	74 14                	je     f0101441 <page_free+0x1e>
f010142d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101432:	75 0d                	jne    f0101441 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101434:	8b 15 2c f5 11 f0    	mov    0xf011f52c,%edx
f010143a:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010143c:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c
}
f0101441:	c9                   	leave  
f0101442:	c3                   	ret    

f0101443 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101443:	55                   	push   %ebp
f0101444:	89 e5                	mov    %esp,%ebp
f0101446:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101449:	8b 50 04             	mov    0x4(%eax),%edx
f010144c:	4a                   	dec    %edx
f010144d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101451:	66 85 d2             	test   %dx,%dx
f0101454:	75 09                	jne    f010145f <page_decref+0x1c>
		page_free(pp);
f0101456:	50                   	push   %eax
f0101457:	e8 c7 ff ff ff       	call   f0101423 <page_free>
f010145c:	83 c4 04             	add    $0x4,%esp
}
f010145f:	c9                   	leave  
f0101460:	c3                   	ret    

f0101461 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101461:	55                   	push   %ebp
f0101462:	89 e5                	mov    %esp,%ebp
f0101464:	56                   	push   %esi
f0101465:	53                   	push   %ebx
f0101466:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0101469:	89 f3                	mov    %esi,%ebx
f010146b:	c1 eb 16             	shr    $0x16,%ebx
f010146e:	c1 e3 02             	shl    $0x2,%ebx
f0101471:	03 5d 08             	add    0x8(%ebp),%ebx
f0101474:	8b 03                	mov    (%ebx),%eax
f0101476:	85 c0                	test   %eax,%eax
f0101478:	74 04                	je     f010147e <pgdir_walk+0x1d>
f010147a:	a8 01                	test   $0x1,%al
f010147c:	75 2c                	jne    f01014aa <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f010147e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101482:	74 61                	je     f01014e5 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
f0101484:	83 ec 0c             	sub    $0xc,%esp
f0101487:	6a 01                	push   $0x1
f0101489:	e8 0b ff ff ff       	call   f0101399 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f010148e:	83 c4 10             	add    $0x10,%esp
f0101491:	85 c0                	test   %eax,%eax
f0101493:	74 57                	je     f01014ec <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f0101495:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101499:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f010149f:	c1 f8 03             	sar    $0x3,%eax
f01014a2:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01014a5:	83 c8 07             	or     $0x7,%eax
f01014a8:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01014aa:	8b 03                	mov    (%ebx),%eax
f01014ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014b1:	89 c2                	mov    %eax,%edx
f01014b3:	c1 ea 0c             	shr    $0xc,%edx
f01014b6:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01014bc:	72 15                	jb     f01014d3 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014be:	50                   	push   %eax
f01014bf:	68 80 47 10 f0       	push   $0xf0104780
f01014c4:	68 77 01 00 00       	push   $0x177
f01014c9:	68 78 4e 10 f0       	push   $0xf0104e78
f01014ce:	e8 b8 eb ff ff       	call   f010008b <_panic>
f01014d3:	c1 ee 0a             	shr    $0xa,%esi
f01014d6:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01014dc:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01014e3:	eb 0c                	jmp    f01014f1 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f01014e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ea:	eb 05                	jmp    f01014f1 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
        if (new_page == NULL) return NULL;      // allocation fails
f01014ec:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01014f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014f4:	5b                   	pop    %ebx
f01014f5:	5e                   	pop    %esi
f01014f6:	c9                   	leave  
f01014f7:	c3                   	ret    

f01014f8 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014f8:	55                   	push   %ebp
f01014f9:	89 e5                	mov    %esp,%ebp
f01014fb:	57                   	push   %edi
f01014fc:	56                   	push   %esi
f01014fd:	53                   	push   %ebx
f01014fe:	83 ec 1c             	sub    $0x1c,%esp
f0101501:	89 c7                	mov    %eax,%edi
f0101503:	8b 5d 08             	mov    0x8(%ebp),%ebx
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
f0101506:	f6 45 0c 80          	testb  $0x80,0xc(%ebp)
f010150a:	75 0b                	jne    f0101517 <boot_map_region+0x1f>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010150c:	01 d1                	add    %edx,%ecx
f010150e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101511:	39 ca                	cmp    %ecx,%edx
f0101513:	75 41                	jne    f0101556 <boot_map_region+0x5e>
f0101515:	eb 71                	jmp    f0101588 <boot_map_region+0x90>
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
f0101517:	89 d0                	mov    %edx,%eax
f0101519:	25 00 00 c0 ff       	and    $0xffc00000,%eax
f010151e:	8d b4 0a ff ff 3f 00 	lea    0x3fffff(%edx,%ecx,1),%esi
f0101525:	81 e6 00 00 c0 ff    	and    $0xffc00000,%esi
f010152b:	39 f0                	cmp    %esi,%eax
f010152d:	74 59                	je     f0101588 <boot_map_region+0x90>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
f010152f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101532:	80 ca 81             	or     $0x81,%dl
f0101535:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
    		pte = &pgdir[PDX(va_now)];
f0101538:	89 c2                	mov    %eax,%edx
f010153a:	c1 ea 16             	shr    $0x16,%edx
    		*pte = pa | PTE_P | PTE_PS | perm;
f010153d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101540:	09 d9                	or     %ebx,%ecx
f0101542:	89 0c 97             	mov    %ecx,(%edi,%edx,4)
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    if (perm & PTE_PS) {
    	// 4M mapping
    	for (va_now = ROUNDDOWN(va, PGSIZE_PS); va_now != ROUNDUP(va + size, PGSIZE_PS); va_now += PGSIZE_PS, pa += PGSIZE_PS) {
f0101545:	05 00 00 40 00       	add    $0x400000,%eax
f010154a:	81 c3 00 00 40 00    	add    $0x400000,%ebx
f0101550:	39 f0                	cmp    %esi,%eax
f0101552:	75 e4                	jne    f0101538 <boot_map_region+0x40>
f0101554:	eb 32                	jmp    f0101588 <boot_map_region+0x90>
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101556:	89 d6                	mov    %edx,%esi
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
f0101558:	8b 45 0c             	mov    0xc(%ebp),%eax
f010155b:	83 c8 01             	or     $0x1,%eax
f010155e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101561:	83 ec 04             	sub    $0x4,%esp
f0101564:	6a 01                	push   $0x1
f0101566:	56                   	push   %esi
f0101567:	57                   	push   %edi
f0101568:	e8 f4 fe ff ff       	call   f0101461 <pgdir_walk>
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
f010156d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101570:	09 da                	or     %ebx,%edx
f0101572:	89 10                	mov    %edx,(%eax)
    		pte = &pgdir[PDX(va_now)];
    		*pte = pa | PTE_P | PTE_PS | perm;
    	} 
    } else {
    	// 4K mapping
    	for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101574:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010157a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101580:	83 c4 10             	add    $0x10,%esp
f0101583:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f0101586:	75 d9                	jne    f0101561 <boot_map_region+0x69>
        	pte = pgdir_walk(pgdir, (void *)va_now, true);
        	// 20 PPN, 12 flag
        	*pte = pa | PTE_P | perm;
    	}
	}
}
f0101588:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010158b:	5b                   	pop    %ebx
f010158c:	5e                   	pop    %esi
f010158d:	5f                   	pop    %edi
f010158e:	c9                   	leave  
f010158f:	c3                   	ret    

f0101590 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101590:	55                   	push   %ebp
f0101591:	89 e5                	mov    %esp,%ebp
f0101593:	53                   	push   %ebx
f0101594:	83 ec 08             	sub    $0x8,%esp
f0101597:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f010159a:	6a 00                	push   $0x0
f010159c:	ff 75 0c             	pushl  0xc(%ebp)
f010159f:	ff 75 08             	pushl  0x8(%ebp)
f01015a2:	e8 ba fe ff ff       	call   f0101461 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015a7:	83 c4 10             	add    $0x10,%esp
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 37                	je     f01015e5 <page_lookup+0x55>
f01015ae:	f6 00 01             	testb  $0x1,(%eax)
f01015b1:	74 39                	je     f01015ec <page_lookup+0x5c>
    if (pte_store != 0) {
f01015b3:	85 db                	test   %ebx,%ebx
f01015b5:	74 02                	je     f01015b9 <page_lookup+0x29>
        *pte_store = pte;
f01015b7:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01015b9:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015bb:	c1 e8 0c             	shr    $0xc,%eax
f01015be:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f01015c4:	72 14                	jb     f01015da <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01015c6:	83 ec 04             	sub    $0x4,%esp
f01015c9:	68 68 48 10 f0       	push   $0xf0104868
f01015ce:	6a 4b                	push   $0x4b
f01015d0:	68 84 4e 10 f0       	push   $0xf0104e84
f01015d5:	e8 b1 ea ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f01015da:	c1 e0 03             	shl    $0x3,%eax
f01015dd:	03 05 4c f9 11 f0    	add    0xf011f94c,%eax
f01015e3:	eb 0c                	jmp    f01015f1 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ea:	eb 05                	jmp    f01015f1 <page_lookup+0x61>
f01015ec:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015f4:	c9                   	leave  
f01015f5:	c3                   	ret    

f01015f6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01015f6:	55                   	push   %ebp
f01015f7:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015fc:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01015ff:	c9                   	leave  
f0101600:	c3                   	ret    

f0101601 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101601:	55                   	push   %ebp
f0101602:	89 e5                	mov    %esp,%ebp
f0101604:	56                   	push   %esi
f0101605:	53                   	push   %ebx
f0101606:	83 ec 14             	sub    $0x14,%esp
f0101609:	8b 75 08             	mov    0x8(%ebp),%esi
f010160c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101612:	50                   	push   %eax
f0101613:	53                   	push   %ebx
f0101614:	56                   	push   %esi
f0101615:	e8 76 ff ff ff       	call   f0101590 <page_lookup>
    if (pg == NULL) return;
f010161a:	83 c4 10             	add    $0x10,%esp
f010161d:	85 c0                	test   %eax,%eax
f010161f:	74 26                	je     f0101647 <page_remove+0x46>
    page_decref(pg);
f0101621:	83 ec 0c             	sub    $0xc,%esp
f0101624:	50                   	push   %eax
f0101625:	e8 19 fe ff ff       	call   f0101443 <page_decref>
    if (pte != NULL) *pte = 0;
f010162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	74 06                	je     f010163a <page_remove+0x39>
f0101634:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f010163a:	83 ec 08             	sub    $0x8,%esp
f010163d:	53                   	push   %ebx
f010163e:	56                   	push   %esi
f010163f:	e8 b2 ff ff ff       	call   f01015f6 <tlb_invalidate>
f0101644:	83 c4 10             	add    $0x10,%esp
}
f0101647:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010164a:	5b                   	pop    %ebx
f010164b:	5e                   	pop    %esi
f010164c:	c9                   	leave  
f010164d:	c3                   	ret    

f010164e <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010164e:	55                   	push   %ebp
f010164f:	89 e5                	mov    %esp,%ebp
f0101651:	57                   	push   %edi
f0101652:	56                   	push   %esi
f0101653:	53                   	push   %ebx
f0101654:	83 ec 10             	sub    $0x10,%esp
f0101657:	8b 75 0c             	mov    0xc(%ebp),%esi
f010165a:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f010165d:	6a 01                	push   $0x1
f010165f:	57                   	push   %edi
f0101660:	ff 75 08             	pushl  0x8(%ebp)
f0101663:	e8 f9 fd ff ff       	call   f0101461 <pgdir_walk>
f0101668:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f010166a:	83 c4 10             	add    $0x10,%esp
f010166d:	85 c0                	test   %eax,%eax
f010166f:	74 39                	je     f01016aa <page_insert+0x5c>
    ++pp->pp_ref;
f0101671:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101675:	f6 00 01             	testb  $0x1,(%eax)
f0101678:	74 0f                	je     f0101689 <page_insert+0x3b>
        page_remove(pgdir, va);
f010167a:	83 ec 08             	sub    $0x8,%esp
f010167d:	57                   	push   %edi
f010167e:	ff 75 08             	pushl  0x8(%ebp)
f0101681:	e8 7b ff ff ff       	call   f0101601 <page_remove>
f0101686:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f0101689:	8b 55 14             	mov    0x14(%ebp),%edx
f010168c:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010168f:	2b 35 4c f9 11 f0    	sub    0xf011f94c,%esi
f0101695:	c1 fe 03             	sar    $0x3,%esi
f0101698:	89 f0                	mov    %esi,%eax
f010169a:	c1 e0 0c             	shl    $0xc,%eax
f010169d:	89 d6                	mov    %edx,%esi
f010169f:	09 c6                	or     %eax,%esi
f01016a1:	89 33                	mov    %esi,(%ebx)
	return 0;
f01016a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a8:	eb 05                	jmp    f01016af <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01016aa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01016af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016b2:	5b                   	pop    %ebx
f01016b3:	5e                   	pop    %esi
f01016b4:	5f                   	pop    %edi
f01016b5:	c9                   	leave  
f01016b6:	c3                   	ret    

f01016b7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016b7:	55                   	push   %ebp
f01016b8:	89 e5                	mov    %esp,%ebp
f01016ba:	57                   	push   %edi
f01016bb:	56                   	push   %esi
f01016bc:	53                   	push   %ebx
f01016bd:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016c0:	b8 15 00 00 00       	mov    $0x15,%eax
f01016c5:	e8 42 f9 ff ff       	call   f010100c <nvram_read>
f01016ca:	c1 e0 0a             	shl    $0xa,%eax
f01016cd:	89 c2                	mov    %eax,%edx
f01016cf:	85 c0                	test   %eax,%eax
f01016d1:	79 06                	jns    f01016d9 <mem_init+0x22>
f01016d3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016d9:	c1 fa 0c             	sar    $0xc,%edx
f01016dc:	89 15 34 f5 11 f0    	mov    %edx,0xf011f534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016e2:	b8 17 00 00 00       	mov    $0x17,%eax
f01016e7:	e8 20 f9 ff ff       	call   f010100c <nvram_read>
f01016ec:	89 c2                	mov    %eax,%edx
f01016ee:	c1 e2 0a             	shl    $0xa,%edx
f01016f1:	89 d0                	mov    %edx,%eax
f01016f3:	85 d2                	test   %edx,%edx
f01016f5:	79 06                	jns    f01016fd <mem_init+0x46>
f01016f7:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01016fd:	c1 f8 0c             	sar    $0xc,%eax
f0101700:	74 0e                	je     f0101710 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101702:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101708:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944
f010170e:	eb 0c                	jmp    f010171c <mem_init+0x65>
	else
		npages = npages_basemem;
f0101710:	8b 15 34 f5 11 f0    	mov    0xf011f534,%edx
f0101716:	89 15 44 f9 11 f0    	mov    %edx,0xf011f944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010171c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010171f:	c1 e8 0a             	shr    $0xa,%eax
f0101722:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101723:	a1 34 f5 11 f0       	mov    0xf011f534,%eax
f0101728:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010172b:	c1 e8 0a             	shr    $0xa,%eax
f010172e:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010172f:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0101734:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101737:	c1 e8 0a             	shr    $0xa,%eax
f010173a:	50                   	push   %eax
f010173b:	68 88 48 10 f0       	push   $0xf0104888
f0101740:	e8 e4 15 00 00       	call   f0102d29 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101745:	b8 00 10 00 00       	mov    $0x1000,%eax
f010174a:	e8 11 f8 ff ff       	call   f0100f60 <boot_alloc>
f010174f:	a3 48 f9 11 f0       	mov    %eax,0xf011f948
	memset(kern_pgdir, 0, PGSIZE);
f0101754:	83 c4 0c             	add    $0xc,%esp
f0101757:	68 00 10 00 00       	push   $0x1000
f010175c:	6a 00                	push   $0x0
f010175e:	50                   	push   %eax
f010175f:	e8 f5 20 00 00       	call   f0103859 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101764:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101769:	83 c4 10             	add    $0x10,%esp
f010176c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101771:	77 15                	ja     f0101788 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101773:	50                   	push   %eax
f0101774:	68 b8 45 10 f0       	push   $0xf01045b8
f0101779:	68 8f 00 00 00       	push   $0x8f
f010177e:	68 78 4e 10 f0       	push   $0xf0104e78
f0101783:	e8 03 e9 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101788:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010178e:	83 ca 05             	or     $0x5,%edx
f0101791:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101797:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f010179c:	c1 e0 03             	shl    $0x3,%eax
f010179f:	e8 bc f7 ff ff       	call   f0100f60 <boot_alloc>
f01017a4:	a3 4c f9 11 f0       	mov    %eax,0xf011f94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017a9:	e8 3e fb ff ff       	call   f01012ec <page_init>

	check_page_free_list(1);
f01017ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01017b3:	e8 7b f8 ff ff       	call   f0101033 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017b8:	83 3d 4c f9 11 f0 00 	cmpl   $0x0,0xf011f94c
f01017bf:	75 17                	jne    f01017d8 <mem_init+0x121>
		panic("'pages' is a null pointer!");
f01017c1:	83 ec 04             	sub    $0x4,%esp
f01017c4:	68 2e 4f 10 f0       	push   $0xf0104f2e
f01017c9:	68 51 02 00 00       	push   $0x251
f01017ce:	68 78 4e 10 f0       	push   $0xf0104e78
f01017d3:	e8 b3 e8 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017d8:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	74 0e                	je     f01017ef <mem_init+0x138>
f01017e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01017e6:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017e7:	8b 00                	mov    (%eax),%eax
f01017e9:	85 c0                	test   %eax,%eax
f01017eb:	75 f9                	jne    f01017e6 <mem_init+0x12f>
f01017ed:	eb 05                	jmp    f01017f4 <mem_init+0x13d>
f01017ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017f4:	83 ec 0c             	sub    $0xc,%esp
f01017f7:	6a 00                	push   $0x0
f01017f9:	e8 9b fb ff ff       	call   f0101399 <page_alloc>
f01017fe:	89 c6                	mov    %eax,%esi
f0101800:	83 c4 10             	add    $0x10,%esp
f0101803:	85 c0                	test   %eax,%eax
f0101805:	75 19                	jne    f0101820 <mem_init+0x169>
f0101807:	68 49 4f 10 f0       	push   $0xf0104f49
f010180c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101811:	68 59 02 00 00       	push   $0x259
f0101816:	68 78 4e 10 f0       	push   $0xf0104e78
f010181b:	e8 6b e8 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101820:	83 ec 0c             	sub    $0xc,%esp
f0101823:	6a 00                	push   $0x0
f0101825:	e8 6f fb ff ff       	call   f0101399 <page_alloc>
f010182a:	89 c7                	mov    %eax,%edi
f010182c:	83 c4 10             	add    $0x10,%esp
f010182f:	85 c0                	test   %eax,%eax
f0101831:	75 19                	jne    f010184c <mem_init+0x195>
f0101833:	68 5f 4f 10 f0       	push   $0xf0104f5f
f0101838:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010183d:	68 5a 02 00 00       	push   $0x25a
f0101842:	68 78 4e 10 f0       	push   $0xf0104e78
f0101847:	e8 3f e8 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010184c:	83 ec 0c             	sub    $0xc,%esp
f010184f:	6a 00                	push   $0x0
f0101851:	e8 43 fb ff ff       	call   f0101399 <page_alloc>
f0101856:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101859:	83 c4 10             	add    $0x10,%esp
f010185c:	85 c0                	test   %eax,%eax
f010185e:	75 19                	jne    f0101879 <mem_init+0x1c2>
f0101860:	68 75 4f 10 f0       	push   $0xf0104f75
f0101865:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010186a:	68 5b 02 00 00       	push   $0x25b
f010186f:	68 78 4e 10 f0       	push   $0xf0104e78
f0101874:	e8 12 e8 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101879:	39 fe                	cmp    %edi,%esi
f010187b:	75 19                	jne    f0101896 <mem_init+0x1df>
f010187d:	68 8b 4f 10 f0       	push   $0xf0104f8b
f0101882:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101887:	68 5e 02 00 00       	push   $0x25e
f010188c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101891:	e8 f5 e7 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101896:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101899:	74 05                	je     f01018a0 <mem_init+0x1e9>
f010189b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010189e:	75 19                	jne    f01018b9 <mem_init+0x202>
f01018a0:	68 c4 48 10 f0       	push   $0xf01048c4
f01018a5:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01018aa:	68 5f 02 00 00       	push   $0x25f
f01018af:	68 78 4e 10 f0       	push   $0xf0104e78
f01018b4:	e8 d2 e7 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b9:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018bf:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01018c4:	c1 e0 0c             	shl    $0xc,%eax
f01018c7:	89 f1                	mov    %esi,%ecx
f01018c9:	29 d1                	sub    %edx,%ecx
f01018cb:	c1 f9 03             	sar    $0x3,%ecx
f01018ce:	c1 e1 0c             	shl    $0xc,%ecx
f01018d1:	39 c1                	cmp    %eax,%ecx
f01018d3:	72 19                	jb     f01018ee <mem_init+0x237>
f01018d5:	68 9d 4f 10 f0       	push   $0xf0104f9d
f01018da:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01018df:	68 60 02 00 00       	push   $0x260
f01018e4:	68 78 4e 10 f0       	push   $0xf0104e78
f01018e9:	e8 9d e7 ff ff       	call   f010008b <_panic>
f01018ee:	89 f9                	mov    %edi,%ecx
f01018f0:	29 d1                	sub    %edx,%ecx
f01018f2:	c1 f9 03             	sar    $0x3,%ecx
f01018f5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01018f8:	39 c8                	cmp    %ecx,%eax
f01018fa:	77 19                	ja     f0101915 <mem_init+0x25e>
f01018fc:	68 ba 4f 10 f0       	push   $0xf0104fba
f0101901:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101906:	68 61 02 00 00       	push   $0x261
f010190b:	68 78 4e 10 f0       	push   $0xf0104e78
f0101910:	e8 76 e7 ff ff       	call   f010008b <_panic>
f0101915:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101918:	29 d1                	sub    %edx,%ecx
f010191a:	89 ca                	mov    %ecx,%edx
f010191c:	c1 fa 03             	sar    $0x3,%edx
f010191f:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101922:	39 d0                	cmp    %edx,%eax
f0101924:	77 19                	ja     f010193f <mem_init+0x288>
f0101926:	68 d7 4f 10 f0       	push   $0xf0104fd7
f010192b:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101930:	68 62 02 00 00       	push   $0x262
f0101935:	68 78 4e 10 f0       	push   $0xf0104e78
f010193a:	e8 4c e7 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010193f:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101944:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101947:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f010194e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101951:	83 ec 0c             	sub    $0xc,%esp
f0101954:	6a 00                	push   $0x0
f0101956:	e8 3e fa ff ff       	call   f0101399 <page_alloc>
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	85 c0                	test   %eax,%eax
f0101960:	74 19                	je     f010197b <mem_init+0x2c4>
f0101962:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101967:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010196c:	68 69 02 00 00       	push   $0x269
f0101971:	68 78 4e 10 f0       	push   $0xf0104e78
f0101976:	e8 10 e7 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f010197b:	83 ec 0c             	sub    $0xc,%esp
f010197e:	56                   	push   %esi
f010197f:	e8 9f fa ff ff       	call   f0101423 <page_free>
	page_free(pp1);
f0101984:	89 3c 24             	mov    %edi,(%esp)
f0101987:	e8 97 fa ff ff       	call   f0101423 <page_free>
	page_free(pp2);
f010198c:	83 c4 04             	add    $0x4,%esp
f010198f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101992:	e8 8c fa ff ff       	call   f0101423 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101997:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010199e:	e8 f6 f9 ff ff       	call   f0101399 <page_alloc>
f01019a3:	89 c6                	mov    %eax,%esi
f01019a5:	83 c4 10             	add    $0x10,%esp
f01019a8:	85 c0                	test   %eax,%eax
f01019aa:	75 19                	jne    f01019c5 <mem_init+0x30e>
f01019ac:	68 49 4f 10 f0       	push   $0xf0104f49
f01019b1:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01019b6:	68 70 02 00 00       	push   $0x270
f01019bb:	68 78 4e 10 f0       	push   $0xf0104e78
f01019c0:	e8 c6 e6 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01019c5:	83 ec 0c             	sub    $0xc,%esp
f01019c8:	6a 00                	push   $0x0
f01019ca:	e8 ca f9 ff ff       	call   f0101399 <page_alloc>
f01019cf:	89 c7                	mov    %eax,%edi
f01019d1:	83 c4 10             	add    $0x10,%esp
f01019d4:	85 c0                	test   %eax,%eax
f01019d6:	75 19                	jne    f01019f1 <mem_init+0x33a>
f01019d8:	68 5f 4f 10 f0       	push   $0xf0104f5f
f01019dd:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01019e2:	68 71 02 00 00       	push   $0x271
f01019e7:	68 78 4e 10 f0       	push   $0xf0104e78
f01019ec:	e8 9a e6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01019f1:	83 ec 0c             	sub    $0xc,%esp
f01019f4:	6a 00                	push   $0x0
f01019f6:	e8 9e f9 ff ff       	call   f0101399 <page_alloc>
f01019fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019fe:	83 c4 10             	add    $0x10,%esp
f0101a01:	85 c0                	test   %eax,%eax
f0101a03:	75 19                	jne    f0101a1e <mem_init+0x367>
f0101a05:	68 75 4f 10 f0       	push   $0xf0104f75
f0101a0a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101a0f:	68 72 02 00 00       	push   $0x272
f0101a14:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a19:	e8 6d e6 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a1e:	39 fe                	cmp    %edi,%esi
f0101a20:	75 19                	jne    f0101a3b <mem_init+0x384>
f0101a22:	68 8b 4f 10 f0       	push   $0xf0104f8b
f0101a27:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101a2c:	68 74 02 00 00       	push   $0x274
f0101a31:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a36:	e8 50 e6 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a3b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a3e:	74 05                	je     f0101a45 <mem_init+0x38e>
f0101a40:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a43:	75 19                	jne    f0101a5e <mem_init+0x3a7>
f0101a45:	68 c4 48 10 f0       	push   $0xf01048c4
f0101a4a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101a4f:	68 75 02 00 00       	push   $0x275
f0101a54:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a59:	e8 2d e6 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101a5e:	83 ec 0c             	sub    $0xc,%esp
f0101a61:	6a 00                	push   $0x0
f0101a63:	e8 31 f9 ff ff       	call   f0101399 <page_alloc>
f0101a68:	83 c4 10             	add    $0x10,%esp
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	74 19                	je     f0101a88 <mem_init+0x3d1>
f0101a6f:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101a74:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101a79:	68 76 02 00 00       	push   $0x276
f0101a7e:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a83:	e8 03 e6 ff ff       	call   f010008b <_panic>
f0101a88:	89 f0                	mov    %esi,%eax
f0101a8a:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0101a90:	c1 f8 03             	sar    $0x3,%eax
f0101a93:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a96:	89 c2                	mov    %eax,%edx
f0101a98:	c1 ea 0c             	shr    $0xc,%edx
f0101a9b:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0101aa1:	72 12                	jb     f0101ab5 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aa3:	50                   	push   %eax
f0101aa4:	68 80 47 10 f0       	push   $0xf0104780
f0101aa9:	6a 52                	push   $0x52
f0101aab:	68 84 4e 10 f0       	push   $0xf0104e84
f0101ab0:	e8 d6 e5 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ab5:	83 ec 04             	sub    $0x4,%esp
f0101ab8:	68 00 10 00 00       	push   $0x1000
f0101abd:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101abf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ac4:	50                   	push   %eax
f0101ac5:	e8 8f 1d 00 00       	call   f0103859 <memset>
	page_free(pp0);
f0101aca:	89 34 24             	mov    %esi,(%esp)
f0101acd:	e8 51 f9 ff ff       	call   f0101423 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ad2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ad9:	e8 bb f8 ff ff       	call   f0101399 <page_alloc>
f0101ade:	83 c4 10             	add    $0x10,%esp
f0101ae1:	85 c0                	test   %eax,%eax
f0101ae3:	75 19                	jne    f0101afe <mem_init+0x447>
f0101ae5:	68 03 50 10 f0       	push   $0xf0105003
f0101aea:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101aef:	68 7b 02 00 00       	push   $0x27b
f0101af4:	68 78 4e 10 f0       	push   $0xf0104e78
f0101af9:	e8 8d e5 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101afe:	39 c6                	cmp    %eax,%esi
f0101b00:	74 19                	je     f0101b1b <mem_init+0x464>
f0101b02:	68 21 50 10 f0       	push   $0xf0105021
f0101b07:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101b0c:	68 7c 02 00 00       	push   $0x27c
f0101b11:	68 78 4e 10 f0       	push   $0xf0104e78
f0101b16:	e8 70 e5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b1b:	89 f2                	mov    %esi,%edx
f0101b1d:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101b23:	c1 fa 03             	sar    $0x3,%edx
f0101b26:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b29:	89 d0                	mov    %edx,%eax
f0101b2b:	c1 e8 0c             	shr    $0xc,%eax
f0101b2e:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f0101b34:	72 12                	jb     f0101b48 <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b36:	52                   	push   %edx
f0101b37:	68 80 47 10 f0       	push   $0xf0104780
f0101b3c:	6a 52                	push   $0x52
f0101b3e:	68 84 4e 10 f0       	push   $0xf0104e84
f0101b43:	e8 43 e5 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b48:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b4f:	75 11                	jne    f0101b62 <mem_init+0x4ab>
f0101b51:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b57:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b5d:	80 38 00             	cmpb   $0x0,(%eax)
f0101b60:	74 19                	je     f0101b7b <mem_init+0x4c4>
f0101b62:	68 31 50 10 f0       	push   $0xf0105031
f0101b67:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101b6c:	68 7f 02 00 00       	push   $0x27f
f0101b71:	68 78 4e 10 f0       	push   $0xf0104e78
f0101b76:	e8 10 e5 ff ff       	call   f010008b <_panic>
f0101b7b:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b7c:	39 d0                	cmp    %edx,%eax
f0101b7e:	75 dd                	jne    f0101b5d <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b80:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101b83:	89 15 2c f5 11 f0    	mov    %edx,0xf011f52c

	// free the pages we took
	page_free(pp0);
f0101b89:	83 ec 0c             	sub    $0xc,%esp
f0101b8c:	56                   	push   %esi
f0101b8d:	e8 91 f8 ff ff       	call   f0101423 <page_free>
	page_free(pp1);
f0101b92:	89 3c 24             	mov    %edi,(%esp)
f0101b95:	e8 89 f8 ff ff       	call   f0101423 <page_free>
	page_free(pp2);
f0101b9a:	83 c4 04             	add    $0x4,%esp
f0101b9d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ba0:	e8 7e f8 ff ff       	call   f0101423 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ba5:	a1 2c f5 11 f0       	mov    0xf011f52c,%eax
f0101baa:	83 c4 10             	add    $0x10,%esp
f0101bad:	85 c0                	test   %eax,%eax
f0101baf:	74 07                	je     f0101bb8 <mem_init+0x501>
		--nfree;
f0101bb1:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bb2:	8b 00                	mov    (%eax),%eax
f0101bb4:	85 c0                	test   %eax,%eax
f0101bb6:	75 f9                	jne    f0101bb1 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101bb8:	85 db                	test   %ebx,%ebx
f0101bba:	74 19                	je     f0101bd5 <mem_init+0x51e>
f0101bbc:	68 3b 50 10 f0       	push   $0xf010503b
f0101bc1:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101bc6:	68 8c 02 00 00       	push   $0x28c
f0101bcb:	68 78 4e 10 f0       	push   $0xf0104e78
f0101bd0:	e8 b6 e4 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bd5:	83 ec 0c             	sub    $0xc,%esp
f0101bd8:	68 e4 48 10 f0       	push   $0xf01048e4
f0101bdd:	e8 47 11 00 00       	call   f0102d29 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101be2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be9:	e8 ab f7 ff ff       	call   f0101399 <page_alloc>
f0101bee:	89 c6                	mov    %eax,%esi
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	85 c0                	test   %eax,%eax
f0101bf5:	75 19                	jne    f0101c10 <mem_init+0x559>
f0101bf7:	68 49 4f 10 f0       	push   $0xf0104f49
f0101bfc:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101c01:	68 eb 02 00 00       	push   $0x2eb
f0101c06:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c0b:	e8 7b e4 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101c10:	83 ec 0c             	sub    $0xc,%esp
f0101c13:	6a 00                	push   $0x0
f0101c15:	e8 7f f7 ff ff       	call   f0101399 <page_alloc>
f0101c1a:	89 c7                	mov    %eax,%edi
f0101c1c:	83 c4 10             	add    $0x10,%esp
f0101c1f:	85 c0                	test   %eax,%eax
f0101c21:	75 19                	jne    f0101c3c <mem_init+0x585>
f0101c23:	68 5f 4f 10 f0       	push   $0xf0104f5f
f0101c28:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101c2d:	68 ec 02 00 00       	push   $0x2ec
f0101c32:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c37:	e8 4f e4 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101c3c:	83 ec 0c             	sub    $0xc,%esp
f0101c3f:	6a 00                	push   $0x0
f0101c41:	e8 53 f7 ff ff       	call   f0101399 <page_alloc>
f0101c46:	89 c3                	mov    %eax,%ebx
f0101c48:	83 c4 10             	add    $0x10,%esp
f0101c4b:	85 c0                	test   %eax,%eax
f0101c4d:	75 19                	jne    f0101c68 <mem_init+0x5b1>
f0101c4f:	68 75 4f 10 f0       	push   $0xf0104f75
f0101c54:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101c59:	68 ed 02 00 00       	push   $0x2ed
f0101c5e:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c63:	e8 23 e4 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c68:	39 fe                	cmp    %edi,%esi
f0101c6a:	75 19                	jne    f0101c85 <mem_init+0x5ce>
f0101c6c:	68 8b 4f 10 f0       	push   $0xf0104f8b
f0101c71:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101c76:	68 f0 02 00 00       	push   $0x2f0
f0101c7b:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c80:	e8 06 e4 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c85:	39 c7                	cmp    %eax,%edi
f0101c87:	74 04                	je     f0101c8d <mem_init+0x5d6>
f0101c89:	39 c6                	cmp    %eax,%esi
f0101c8b:	75 19                	jne    f0101ca6 <mem_init+0x5ef>
f0101c8d:	68 c4 48 10 f0       	push   $0xf01048c4
f0101c92:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101c97:	68 f1 02 00 00       	push   $0x2f1
f0101c9c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101ca1:	e8 e5 e3 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ca6:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f0101cac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101caf:	c7 05 2c f5 11 f0 00 	movl   $0x0,0xf011f52c
f0101cb6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cb9:	83 ec 0c             	sub    $0xc,%esp
f0101cbc:	6a 00                	push   $0x0
f0101cbe:	e8 d6 f6 ff ff       	call   f0101399 <page_alloc>
f0101cc3:	83 c4 10             	add    $0x10,%esp
f0101cc6:	85 c0                	test   %eax,%eax
f0101cc8:	74 19                	je     f0101ce3 <mem_init+0x62c>
f0101cca:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101ccf:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101cd4:	68 f8 02 00 00       	push   $0x2f8
f0101cd9:	68 78 4e 10 f0       	push   $0xf0104e78
f0101cde:	e8 a8 e3 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ce3:	83 ec 04             	sub    $0x4,%esp
f0101ce6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ce9:	50                   	push   %eax
f0101cea:	6a 00                	push   $0x0
f0101cec:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101cf2:	e8 99 f8 ff ff       	call   f0101590 <page_lookup>
f0101cf7:	83 c4 10             	add    $0x10,%esp
f0101cfa:	85 c0                	test   %eax,%eax
f0101cfc:	74 19                	je     f0101d17 <mem_init+0x660>
f0101cfe:	68 04 49 10 f0       	push   $0xf0104904
f0101d03:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101d08:	68 fb 02 00 00       	push   $0x2fb
f0101d0d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d12:	e8 74 e3 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d17:	6a 02                	push   $0x2
f0101d19:	6a 00                	push   $0x0
f0101d1b:	57                   	push   %edi
f0101d1c:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d22:	e8 27 f9 ff ff       	call   f010164e <page_insert>
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	85 c0                	test   %eax,%eax
f0101d2c:	78 19                	js     f0101d47 <mem_init+0x690>
f0101d2e:	68 3c 49 10 f0       	push   $0xf010493c
f0101d33:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101d38:	68 fe 02 00 00       	push   $0x2fe
f0101d3d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d42:	e8 44 e3 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d47:	83 ec 0c             	sub    $0xc,%esp
f0101d4a:	56                   	push   %esi
f0101d4b:	e8 d3 f6 ff ff       	call   f0101423 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d50:	6a 02                	push   $0x2
f0101d52:	6a 00                	push   $0x0
f0101d54:	57                   	push   %edi
f0101d55:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101d5b:	e8 ee f8 ff ff       	call   f010164e <page_insert>
f0101d60:	83 c4 20             	add    $0x20,%esp
f0101d63:	85 c0                	test   %eax,%eax
f0101d65:	74 19                	je     f0101d80 <mem_init+0x6c9>
f0101d67:	68 6c 49 10 f0       	push   $0xf010496c
f0101d6c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101d71:	68 02 03 00 00       	push   $0x302
f0101d76:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d7b:	e8 0b e3 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d80:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101d85:	8b 08                	mov    (%eax),%ecx
f0101d87:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d8d:	89 f2                	mov    %esi,%edx
f0101d8f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101d95:	c1 fa 03             	sar    $0x3,%edx
f0101d98:	c1 e2 0c             	shl    $0xc,%edx
f0101d9b:	39 d1                	cmp    %edx,%ecx
f0101d9d:	74 19                	je     f0101db8 <mem_init+0x701>
f0101d9f:	68 9c 49 10 f0       	push   $0xf010499c
f0101da4:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101da9:	68 03 03 00 00       	push   $0x303
f0101dae:	68 78 4e 10 f0       	push   $0xf0104e78
f0101db3:	e8 d3 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101db8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dbd:	e8 d5 f1 ff ff       	call   f0100f97 <check_va2pa>
f0101dc2:	89 fa                	mov    %edi,%edx
f0101dc4:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101dca:	c1 fa 03             	sar    $0x3,%edx
f0101dcd:	c1 e2 0c             	shl    $0xc,%edx
f0101dd0:	39 d0                	cmp    %edx,%eax
f0101dd2:	74 19                	je     f0101ded <mem_init+0x736>
f0101dd4:	68 c4 49 10 f0       	push   $0xf01049c4
f0101dd9:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101dde:	68 04 03 00 00       	push   $0x304
f0101de3:	68 78 4e 10 f0       	push   $0xf0104e78
f0101de8:	e8 9e e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101ded:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101df2:	74 19                	je     f0101e0d <mem_init+0x756>
f0101df4:	68 46 50 10 f0       	push   $0xf0105046
f0101df9:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101dfe:	68 05 03 00 00       	push   $0x305
f0101e03:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e08:	e8 7e e2 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101e0d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e12:	74 19                	je     f0101e2d <mem_init+0x776>
f0101e14:	68 57 50 10 f0       	push   $0xf0105057
f0101e19:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101e1e:	68 06 03 00 00       	push   $0x306
f0101e23:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e28:	e8 5e e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e2d:	6a 02                	push   $0x2
f0101e2f:	68 00 10 00 00       	push   $0x1000
f0101e34:	53                   	push   %ebx
f0101e35:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101e3b:	e8 0e f8 ff ff       	call   f010164e <page_insert>
f0101e40:	83 c4 10             	add    $0x10,%esp
f0101e43:	85 c0                	test   %eax,%eax
f0101e45:	74 19                	je     f0101e60 <mem_init+0x7a9>
f0101e47:	68 f4 49 10 f0       	push   $0xf01049f4
f0101e4c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101e51:	68 09 03 00 00       	push   $0x309
f0101e56:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e5b:	e8 2b e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e65:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101e6a:	e8 28 f1 ff ff       	call   f0100f97 <check_va2pa>
f0101e6f:	89 da                	mov    %ebx,%edx
f0101e71:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101e77:	c1 fa 03             	sar    $0x3,%edx
f0101e7a:	c1 e2 0c             	shl    $0xc,%edx
f0101e7d:	39 d0                	cmp    %edx,%eax
f0101e7f:	74 19                	je     f0101e9a <mem_init+0x7e3>
f0101e81:	68 30 4a 10 f0       	push   $0xf0104a30
f0101e86:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101e8b:	68 0a 03 00 00       	push   $0x30a
f0101e90:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e95:	e8 f1 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e9a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e9f:	74 19                	je     f0101eba <mem_init+0x803>
f0101ea1:	68 68 50 10 f0       	push   $0xf0105068
f0101ea6:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101eab:	68 0b 03 00 00       	push   $0x30b
f0101eb0:	68 78 4e 10 f0       	push   $0xf0104e78
f0101eb5:	e8 d1 e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101eba:	83 ec 0c             	sub    $0xc,%esp
f0101ebd:	6a 00                	push   $0x0
f0101ebf:	e8 d5 f4 ff ff       	call   f0101399 <page_alloc>
f0101ec4:	83 c4 10             	add    $0x10,%esp
f0101ec7:	85 c0                	test   %eax,%eax
f0101ec9:	74 19                	je     f0101ee4 <mem_init+0x82d>
f0101ecb:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101ed0:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101ed5:	68 0e 03 00 00       	push   $0x30e
f0101eda:	68 78 4e 10 f0       	push   $0xf0104e78
f0101edf:	e8 a7 e1 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee4:	6a 02                	push   $0x2
f0101ee6:	68 00 10 00 00       	push   $0x1000
f0101eeb:	53                   	push   %ebx
f0101eec:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0101ef2:	e8 57 f7 ff ff       	call   f010164e <page_insert>
f0101ef7:	83 c4 10             	add    $0x10,%esp
f0101efa:	85 c0                	test   %eax,%eax
f0101efc:	74 19                	je     f0101f17 <mem_init+0x860>
f0101efe:	68 f4 49 10 f0       	push   $0xf01049f4
f0101f03:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101f08:	68 11 03 00 00       	push   $0x311
f0101f0d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f12:	e8 74 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f1c:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0101f21:	e8 71 f0 ff ff       	call   f0100f97 <check_va2pa>
f0101f26:	89 da                	mov    %ebx,%edx
f0101f28:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0101f2e:	c1 fa 03             	sar    $0x3,%edx
f0101f31:	c1 e2 0c             	shl    $0xc,%edx
f0101f34:	39 d0                	cmp    %edx,%eax
f0101f36:	74 19                	je     f0101f51 <mem_init+0x89a>
f0101f38:	68 30 4a 10 f0       	push   $0xf0104a30
f0101f3d:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101f42:	68 12 03 00 00       	push   $0x312
f0101f47:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f4c:	e8 3a e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101f51:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f56:	74 19                	je     f0101f71 <mem_init+0x8ba>
f0101f58:	68 68 50 10 f0       	push   $0xf0105068
f0101f5d:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101f62:	68 13 03 00 00       	push   $0x313
f0101f67:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f6c:	e8 1a e1 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f71:	83 ec 0c             	sub    $0xc,%esp
f0101f74:	6a 00                	push   $0x0
f0101f76:	e8 1e f4 ff ff       	call   f0101399 <page_alloc>
f0101f7b:	83 c4 10             	add    $0x10,%esp
f0101f7e:	85 c0                	test   %eax,%eax
f0101f80:	74 19                	je     f0101f9b <mem_init+0x8e4>
f0101f82:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101f87:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101f8c:	68 17 03 00 00       	push   $0x317
f0101f91:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f96:	e8 f0 e0 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f9b:	8b 15 48 f9 11 f0    	mov    0xf011f948,%edx
f0101fa1:	8b 02                	mov    (%edx),%eax
f0101fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fa8:	89 c1                	mov    %eax,%ecx
f0101faa:	c1 e9 0c             	shr    $0xc,%ecx
f0101fad:	3b 0d 44 f9 11 f0    	cmp    0xf011f944,%ecx
f0101fb3:	72 15                	jb     f0101fca <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fb5:	50                   	push   %eax
f0101fb6:	68 80 47 10 f0       	push   $0xf0104780
f0101fbb:	68 1a 03 00 00       	push   $0x31a
f0101fc0:	68 78 4e 10 f0       	push   $0xf0104e78
f0101fc5:	e8 c1 e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101fca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fd2:	83 ec 04             	sub    $0x4,%esp
f0101fd5:	6a 00                	push   $0x0
f0101fd7:	68 00 10 00 00       	push   $0x1000
f0101fdc:	52                   	push   %edx
f0101fdd:	e8 7f f4 ff ff       	call   f0101461 <pgdir_walk>
f0101fe2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fe5:	83 c2 04             	add    $0x4,%edx
f0101fe8:	83 c4 10             	add    $0x10,%esp
f0101feb:	39 d0                	cmp    %edx,%eax
f0101fed:	74 19                	je     f0102008 <mem_init+0x951>
f0101fef:	68 60 4a 10 f0       	push   $0xf0104a60
f0101ff4:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0101ff9:	68 1b 03 00 00       	push   $0x31b
f0101ffe:	68 78 4e 10 f0       	push   $0xf0104e78
f0102003:	e8 83 e0 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102008:	6a 06                	push   $0x6
f010200a:	68 00 10 00 00       	push   $0x1000
f010200f:	53                   	push   %ebx
f0102010:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102016:	e8 33 f6 ff ff       	call   f010164e <page_insert>
f010201b:	83 c4 10             	add    $0x10,%esp
f010201e:	85 c0                	test   %eax,%eax
f0102020:	74 19                	je     f010203b <mem_init+0x984>
f0102022:	68 a0 4a 10 f0       	push   $0xf0104aa0
f0102027:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010202c:	68 1e 03 00 00       	push   $0x31e
f0102031:	68 78 4e 10 f0       	push   $0xf0104e78
f0102036:	e8 50 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010203b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102040:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102045:	e8 4d ef ff ff       	call   f0100f97 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010204a:	89 da                	mov    %ebx,%edx
f010204c:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102052:	c1 fa 03             	sar    $0x3,%edx
f0102055:	c1 e2 0c             	shl    $0xc,%edx
f0102058:	39 d0                	cmp    %edx,%eax
f010205a:	74 19                	je     f0102075 <mem_init+0x9be>
f010205c:	68 30 4a 10 f0       	push   $0xf0104a30
f0102061:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102066:	68 1f 03 00 00       	push   $0x31f
f010206b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102070:	e8 16 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102075:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010207a:	74 19                	je     f0102095 <mem_init+0x9de>
f010207c:	68 68 50 10 f0       	push   $0xf0105068
f0102081:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102086:	68 20 03 00 00       	push   $0x320
f010208b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102090:	e8 f6 df ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102095:	83 ec 04             	sub    $0x4,%esp
f0102098:	6a 00                	push   $0x0
f010209a:	68 00 10 00 00       	push   $0x1000
f010209f:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01020a5:	e8 b7 f3 ff ff       	call   f0101461 <pgdir_walk>
f01020aa:	83 c4 10             	add    $0x10,%esp
f01020ad:	f6 00 04             	testb  $0x4,(%eax)
f01020b0:	75 19                	jne    f01020cb <mem_init+0xa14>
f01020b2:	68 e0 4a 10 f0       	push   $0xf0104ae0
f01020b7:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01020bc:	68 21 03 00 00       	push   $0x321
f01020c1:	68 78 4e 10 f0       	push   $0xf0104e78
f01020c6:	e8 c0 df ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020cb:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01020d0:	f6 00 04             	testb  $0x4,(%eax)
f01020d3:	75 19                	jne    f01020ee <mem_init+0xa37>
f01020d5:	68 79 50 10 f0       	push   $0xf0105079
f01020da:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01020df:	68 22 03 00 00       	push   $0x322
f01020e4:	68 78 4e 10 f0       	push   $0xf0104e78
f01020e9:	e8 9d df ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020ee:	6a 02                	push   $0x2
f01020f0:	68 00 10 00 00       	push   $0x1000
f01020f5:	53                   	push   %ebx
f01020f6:	50                   	push   %eax
f01020f7:	e8 52 f5 ff ff       	call   f010164e <page_insert>
f01020fc:	83 c4 10             	add    $0x10,%esp
f01020ff:	85 c0                	test   %eax,%eax
f0102101:	74 19                	je     f010211c <mem_init+0xa65>
f0102103:	68 f4 49 10 f0       	push   $0xf01049f4
f0102108:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010210d:	68 25 03 00 00       	push   $0x325
f0102112:	68 78 4e 10 f0       	push   $0xf0104e78
f0102117:	e8 6f df ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010211c:	83 ec 04             	sub    $0x4,%esp
f010211f:	6a 00                	push   $0x0
f0102121:	68 00 10 00 00       	push   $0x1000
f0102126:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f010212c:	e8 30 f3 ff ff       	call   f0101461 <pgdir_walk>
f0102131:	83 c4 10             	add    $0x10,%esp
f0102134:	f6 00 02             	testb  $0x2,(%eax)
f0102137:	75 19                	jne    f0102152 <mem_init+0xa9b>
f0102139:	68 14 4b 10 f0       	push   $0xf0104b14
f010213e:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102143:	68 26 03 00 00       	push   $0x326
f0102148:	68 78 4e 10 f0       	push   $0xf0104e78
f010214d:	e8 39 df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102152:	83 ec 04             	sub    $0x4,%esp
f0102155:	6a 00                	push   $0x0
f0102157:	68 00 10 00 00       	push   $0x1000
f010215c:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102162:	e8 fa f2 ff ff       	call   f0101461 <pgdir_walk>
f0102167:	83 c4 10             	add    $0x10,%esp
f010216a:	f6 00 04             	testb  $0x4,(%eax)
f010216d:	74 19                	je     f0102188 <mem_init+0xad1>
f010216f:	68 48 4b 10 f0       	push   $0xf0104b48
f0102174:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102179:	68 27 03 00 00       	push   $0x327
f010217e:	68 78 4e 10 f0       	push   $0xf0104e78
f0102183:	e8 03 df ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102188:	6a 02                	push   $0x2
f010218a:	68 00 00 40 00       	push   $0x400000
f010218f:	56                   	push   %esi
f0102190:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102196:	e8 b3 f4 ff ff       	call   f010164e <page_insert>
f010219b:	83 c4 10             	add    $0x10,%esp
f010219e:	85 c0                	test   %eax,%eax
f01021a0:	78 19                	js     f01021bb <mem_init+0xb04>
f01021a2:	68 80 4b 10 f0       	push   $0xf0104b80
f01021a7:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01021ac:	68 2a 03 00 00       	push   $0x32a
f01021b1:	68 78 4e 10 f0       	push   $0xf0104e78
f01021b6:	e8 d0 de ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021bb:	6a 02                	push   $0x2
f01021bd:	68 00 10 00 00       	push   $0x1000
f01021c2:	57                   	push   %edi
f01021c3:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01021c9:	e8 80 f4 ff ff       	call   f010164e <page_insert>
f01021ce:	83 c4 10             	add    $0x10,%esp
f01021d1:	85 c0                	test   %eax,%eax
f01021d3:	74 19                	je     f01021ee <mem_init+0xb37>
f01021d5:	68 b8 4b 10 f0       	push   $0xf0104bb8
f01021da:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01021df:	68 2d 03 00 00       	push   $0x32d
f01021e4:	68 78 4e 10 f0       	push   $0xf0104e78
f01021e9:	e8 9d de ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021ee:	83 ec 04             	sub    $0x4,%esp
f01021f1:	6a 00                	push   $0x0
f01021f3:	68 00 10 00 00       	push   $0x1000
f01021f8:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01021fe:	e8 5e f2 ff ff       	call   f0101461 <pgdir_walk>
f0102203:	83 c4 10             	add    $0x10,%esp
f0102206:	f6 00 04             	testb  $0x4,(%eax)
f0102209:	74 19                	je     f0102224 <mem_init+0xb6d>
f010220b:	68 48 4b 10 f0       	push   $0xf0104b48
f0102210:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102215:	68 2e 03 00 00       	push   $0x32e
f010221a:	68 78 4e 10 f0       	push   $0xf0104e78
f010221f:	e8 67 de ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102224:	ba 00 00 00 00       	mov    $0x0,%edx
f0102229:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010222e:	e8 64 ed ff ff       	call   f0100f97 <check_va2pa>
f0102233:	89 fa                	mov    %edi,%edx
f0102235:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f010223b:	c1 fa 03             	sar    $0x3,%edx
f010223e:	c1 e2 0c             	shl    $0xc,%edx
f0102241:	39 d0                	cmp    %edx,%eax
f0102243:	74 19                	je     f010225e <mem_init+0xba7>
f0102245:	68 f4 4b 10 f0       	push   $0xf0104bf4
f010224a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010224f:	68 31 03 00 00       	push   $0x331
f0102254:	68 78 4e 10 f0       	push   $0xf0104e78
f0102259:	e8 2d de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010225e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102263:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102268:	e8 2a ed ff ff       	call   f0100f97 <check_va2pa>
f010226d:	89 fa                	mov    %edi,%edx
f010226f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102275:	c1 fa 03             	sar    $0x3,%edx
f0102278:	c1 e2 0c             	shl    $0xc,%edx
f010227b:	39 d0                	cmp    %edx,%eax
f010227d:	74 19                	je     f0102298 <mem_init+0xbe1>
f010227f:	68 20 4c 10 f0       	push   $0xf0104c20
f0102284:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102289:	68 32 03 00 00       	push   $0x332
f010228e:	68 78 4e 10 f0       	push   $0xf0104e78
f0102293:	e8 f3 dd ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102298:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010229d:	74 19                	je     f01022b8 <mem_init+0xc01>
f010229f:	68 8f 50 10 f0       	push   $0xf010508f
f01022a4:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01022a9:	68 34 03 00 00       	push   $0x334
f01022ae:	68 78 4e 10 f0       	push   $0xf0104e78
f01022b3:	e8 d3 dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01022b8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022bd:	74 19                	je     f01022d8 <mem_init+0xc21>
f01022bf:	68 a0 50 10 f0       	push   $0xf01050a0
f01022c4:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01022c9:	68 35 03 00 00       	push   $0x335
f01022ce:	68 78 4e 10 f0       	push   $0xf0104e78
f01022d3:	e8 b3 dd ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022d8:	83 ec 0c             	sub    $0xc,%esp
f01022db:	6a 00                	push   $0x0
f01022dd:	e8 b7 f0 ff ff       	call   f0101399 <page_alloc>
f01022e2:	83 c4 10             	add    $0x10,%esp
f01022e5:	85 c0                	test   %eax,%eax
f01022e7:	74 04                	je     f01022ed <mem_init+0xc36>
f01022e9:	39 c3                	cmp    %eax,%ebx
f01022eb:	74 19                	je     f0102306 <mem_init+0xc4f>
f01022ed:	68 50 4c 10 f0       	push   $0xf0104c50
f01022f2:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01022f7:	68 38 03 00 00       	push   $0x338
f01022fc:	68 78 4e 10 f0       	push   $0xf0104e78
f0102301:	e8 85 dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102306:	83 ec 08             	sub    $0x8,%esp
f0102309:	6a 00                	push   $0x0
f010230b:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102311:	e8 eb f2 ff ff       	call   f0101601 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102316:	ba 00 00 00 00       	mov    $0x0,%edx
f010231b:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102320:	e8 72 ec ff ff       	call   f0100f97 <check_va2pa>
f0102325:	83 c4 10             	add    $0x10,%esp
f0102328:	83 f8 ff             	cmp    $0xffffffff,%eax
f010232b:	74 19                	je     f0102346 <mem_init+0xc8f>
f010232d:	68 74 4c 10 f0       	push   $0xf0104c74
f0102332:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102337:	68 3c 03 00 00       	push   $0x33c
f010233c:	68 78 4e 10 f0       	push   $0xf0104e78
f0102341:	e8 45 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102346:	ba 00 10 00 00       	mov    $0x1000,%edx
f010234b:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102350:	e8 42 ec ff ff       	call   f0100f97 <check_va2pa>
f0102355:	89 fa                	mov    %edi,%edx
f0102357:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f010235d:	c1 fa 03             	sar    $0x3,%edx
f0102360:	c1 e2 0c             	shl    $0xc,%edx
f0102363:	39 d0                	cmp    %edx,%eax
f0102365:	74 19                	je     f0102380 <mem_init+0xcc9>
f0102367:	68 20 4c 10 f0       	push   $0xf0104c20
f010236c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102371:	68 3d 03 00 00       	push   $0x33d
f0102376:	68 78 4e 10 f0       	push   $0xf0104e78
f010237b:	e8 0b dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102380:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102385:	74 19                	je     f01023a0 <mem_init+0xce9>
f0102387:	68 46 50 10 f0       	push   $0xf0105046
f010238c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102391:	68 3e 03 00 00       	push   $0x33e
f0102396:	68 78 4e 10 f0       	push   $0xf0104e78
f010239b:	e8 eb dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01023a0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023a5:	74 19                	je     f01023c0 <mem_init+0xd09>
f01023a7:	68 a0 50 10 f0       	push   $0xf01050a0
f01023ac:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01023b1:	68 3f 03 00 00       	push   $0x33f
f01023b6:	68 78 4e 10 f0       	push   $0xf0104e78
f01023bb:	e8 cb dc ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023c0:	83 ec 08             	sub    $0x8,%esp
f01023c3:	68 00 10 00 00       	push   $0x1000
f01023c8:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f01023ce:	e8 2e f2 ff ff       	call   f0101601 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01023d8:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01023dd:	e8 b5 eb ff ff       	call   f0100f97 <check_va2pa>
f01023e2:	83 c4 10             	add    $0x10,%esp
f01023e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023e8:	74 19                	je     f0102403 <mem_init+0xd4c>
f01023ea:	68 74 4c 10 f0       	push   $0xf0104c74
f01023ef:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01023f4:	68 43 03 00 00       	push   $0x343
f01023f9:	68 78 4e 10 f0       	push   $0xf0104e78
f01023fe:	e8 88 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102403:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102408:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010240d:	e8 85 eb ff ff       	call   f0100f97 <check_va2pa>
f0102412:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102415:	74 19                	je     f0102430 <mem_init+0xd79>
f0102417:	68 98 4c 10 f0       	push   $0xf0104c98
f010241c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102421:	68 44 03 00 00       	push   $0x344
f0102426:	68 78 4e 10 f0       	push   $0xf0104e78
f010242b:	e8 5b dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102430:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102435:	74 19                	je     f0102450 <mem_init+0xd99>
f0102437:	68 b1 50 10 f0       	push   $0xf01050b1
f010243c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102441:	68 45 03 00 00       	push   $0x345
f0102446:	68 78 4e 10 f0       	push   $0xf0104e78
f010244b:	e8 3b dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102450:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102455:	74 19                	je     f0102470 <mem_init+0xdb9>
f0102457:	68 a0 50 10 f0       	push   $0xf01050a0
f010245c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102461:	68 46 03 00 00       	push   $0x346
f0102466:	68 78 4e 10 f0       	push   $0xf0104e78
f010246b:	e8 1b dc ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102470:	83 ec 0c             	sub    $0xc,%esp
f0102473:	6a 00                	push   $0x0
f0102475:	e8 1f ef ff ff       	call   f0101399 <page_alloc>
f010247a:	83 c4 10             	add    $0x10,%esp
f010247d:	85 c0                	test   %eax,%eax
f010247f:	74 04                	je     f0102485 <mem_init+0xdce>
f0102481:	39 c7                	cmp    %eax,%edi
f0102483:	74 19                	je     f010249e <mem_init+0xde7>
f0102485:	68 c0 4c 10 f0       	push   $0xf0104cc0
f010248a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010248f:	68 49 03 00 00       	push   $0x349
f0102494:	68 78 4e 10 f0       	push   $0xf0104e78
f0102499:	e8 ed db ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010249e:	83 ec 0c             	sub    $0xc,%esp
f01024a1:	6a 00                	push   $0x0
f01024a3:	e8 f1 ee ff ff       	call   f0101399 <page_alloc>
f01024a8:	83 c4 10             	add    $0x10,%esp
f01024ab:	85 c0                	test   %eax,%eax
f01024ad:	74 19                	je     f01024c8 <mem_init+0xe11>
f01024af:	68 f4 4f 10 f0       	push   $0xf0104ff4
f01024b4:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01024b9:	68 4c 03 00 00       	push   $0x34c
f01024be:	68 78 4e 10 f0       	push   $0xf0104e78
f01024c3:	e8 c3 db ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024c8:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f01024cd:	8b 08                	mov    (%eax),%ecx
f01024cf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024d5:	89 f2                	mov    %esi,%edx
f01024d7:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f01024dd:	c1 fa 03             	sar    $0x3,%edx
f01024e0:	c1 e2 0c             	shl    $0xc,%edx
f01024e3:	39 d1                	cmp    %edx,%ecx
f01024e5:	74 19                	je     f0102500 <mem_init+0xe49>
f01024e7:	68 9c 49 10 f0       	push   $0xf010499c
f01024ec:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01024f1:	68 4f 03 00 00       	push   $0x34f
f01024f6:	68 78 4e 10 f0       	push   $0xf0104e78
f01024fb:	e8 8b db ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102500:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102506:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010250b:	74 19                	je     f0102526 <mem_init+0xe6f>
f010250d:	68 57 50 10 f0       	push   $0xf0105057
f0102512:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102517:	68 51 03 00 00       	push   $0x351
f010251c:	68 78 4e 10 f0       	push   $0xf0104e78
f0102521:	e8 65 db ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102526:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010252c:	83 ec 0c             	sub    $0xc,%esp
f010252f:	56                   	push   %esi
f0102530:	e8 ee ee ff ff       	call   f0101423 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102535:	83 c4 0c             	add    $0xc,%esp
f0102538:	6a 01                	push   $0x1
f010253a:	68 00 10 40 00       	push   $0x401000
f010253f:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102545:	e8 17 ef ff ff       	call   f0101461 <pgdir_walk>
f010254a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010254d:	8b 0d 48 f9 11 f0    	mov    0xf011f948,%ecx
f0102553:	8b 51 04             	mov    0x4(%ecx),%edx
f0102556:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010255c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255f:	c1 ea 0c             	shr    $0xc,%edx
f0102562:	83 c4 10             	add    $0x10,%esp
f0102565:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f010256b:	72 17                	jb     f0102584 <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256d:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102570:	68 80 47 10 f0       	push   $0xf0104780
f0102575:	68 58 03 00 00       	push   $0x358
f010257a:	68 78 4e 10 f0       	push   $0xf0104e78
f010257f:	e8 07 db ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102584:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102587:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010258d:	39 d0                	cmp    %edx,%eax
f010258f:	74 19                	je     f01025aa <mem_init+0xef3>
f0102591:	68 c2 50 10 f0       	push   $0xf01050c2
f0102596:	68 9e 4e 10 f0       	push   $0xf0104e9e
f010259b:	68 59 03 00 00       	push   $0x359
f01025a0:	68 78 4e 10 f0       	push   $0xf0104e78
f01025a5:	e8 e1 da ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01025aa:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01025b1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b7:	89 f0                	mov    %esi,%eax
f01025b9:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f01025bf:	c1 f8 03             	sar    $0x3,%eax
f01025c2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c5:	89 c2                	mov    %eax,%edx
f01025c7:	c1 ea 0c             	shr    $0xc,%edx
f01025ca:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f01025d0:	72 12                	jb     f01025e4 <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025d2:	50                   	push   %eax
f01025d3:	68 80 47 10 f0       	push   $0xf0104780
f01025d8:	6a 52                	push   $0x52
f01025da:	68 84 4e 10 f0       	push   $0xf0104e84
f01025df:	e8 a7 da ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01025e4:	83 ec 04             	sub    $0x4,%esp
f01025e7:	68 00 10 00 00       	push   $0x1000
f01025ec:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01025f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025f6:	50                   	push   %eax
f01025f7:	e8 5d 12 00 00       	call   f0103859 <memset>
	page_free(pp0);
f01025fc:	89 34 24             	mov    %esi,(%esp)
f01025ff:	e8 1f ee ff ff       	call   f0101423 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102604:	83 c4 0c             	add    $0xc,%esp
f0102607:	6a 01                	push   $0x1
f0102609:	6a 00                	push   $0x0
f010260b:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102611:	e8 4b ee ff ff       	call   f0101461 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102616:	89 f2                	mov    %esi,%edx
f0102618:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f010261e:	c1 fa 03             	sar    $0x3,%edx
f0102621:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102624:	89 d0                	mov    %edx,%eax
f0102626:	c1 e8 0c             	shr    $0xc,%eax
f0102629:	83 c4 10             	add    $0x10,%esp
f010262c:	3b 05 44 f9 11 f0    	cmp    0xf011f944,%eax
f0102632:	72 12                	jb     f0102646 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102634:	52                   	push   %edx
f0102635:	68 80 47 10 f0       	push   $0xf0104780
f010263a:	6a 52                	push   $0x52
f010263c:	68 84 4e 10 f0       	push   $0xf0104e84
f0102641:	e8 45 da ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102646:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010264c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010264f:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102656:	75 11                	jne    f0102669 <mem_init+0xfb2>
f0102658:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010265e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102664:	f6 00 01             	testb  $0x1,(%eax)
f0102667:	74 19                	je     f0102682 <mem_init+0xfcb>
f0102669:	68 da 50 10 f0       	push   $0xf01050da
f010266e:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102673:	68 63 03 00 00       	push   $0x363
f0102678:	68 78 4e 10 f0       	push   $0xf0104e78
f010267d:	e8 09 da ff ff       	call   f010008b <_panic>
f0102682:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102685:	39 d0                	cmp    %edx,%eax
f0102687:	75 db                	jne    f0102664 <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102689:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f010268e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102694:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010269a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010269d:	a3 2c f5 11 f0       	mov    %eax,0xf011f52c

	// free the pages we took
	page_free(pp0);
f01026a2:	83 ec 0c             	sub    $0xc,%esp
f01026a5:	56                   	push   %esi
f01026a6:	e8 78 ed ff ff       	call   f0101423 <page_free>
	page_free(pp1);
f01026ab:	89 3c 24             	mov    %edi,(%esp)
f01026ae:	e8 70 ed ff ff       	call   f0101423 <page_free>
	page_free(pp2);
f01026b3:	89 1c 24             	mov    %ebx,(%esp)
f01026b6:	e8 68 ed ff ff       	call   f0101423 <page_free>

	cprintf("check_page() succeeded!\n");
f01026bb:	c7 04 24 f1 50 10 f0 	movl   $0xf01050f1,(%esp)
f01026c2:	e8 62 06 00 00       	call   f0102d29 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026c7:	a1 4c f9 11 f0       	mov    0xf011f94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cc:	83 c4 10             	add    $0x10,%esp
f01026cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d4:	77 15                	ja     f01026eb <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d6:	50                   	push   %eax
f01026d7:	68 b8 45 10 f0       	push   $0xf01045b8
f01026dc:	68 b4 00 00 00       	push   $0xb4
f01026e1:	68 78 4e 10 f0       	push   $0xf0104e78
f01026e6:	e8 a0 d9 ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026eb:	8b 15 44 f9 11 f0    	mov    0xf011f944,%edx
f01026f1:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026f8:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026fb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102701:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102703:	05 00 00 00 10       	add    $0x10000000,%eax
f0102708:	50                   	push   %eax
f0102709:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010270e:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102713:	e8 e0 ed ff ff       	call   f01014f8 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102718:	83 c4 10             	add    $0x10,%esp
f010271b:	ba 00 50 11 f0       	mov    $0xf0115000,%edx
f0102720:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102726:	77 15                	ja     f010273d <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102728:	52                   	push   %edx
f0102729:	68 b8 45 10 f0       	push   $0xf01045b8
f010272e:	68 c6 00 00 00       	push   $0xc6
f0102733:	68 78 4e 10 f0       	push   $0xf0104e78
f0102738:	e8 4e d9 ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010273d:	83 ec 08             	sub    $0x8,%esp
f0102740:	6a 02                	push   $0x2
f0102742:	68 00 50 11 00       	push   $0x115000
f0102747:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010274c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102751:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102756:	e8 9d ed ff ff       	call   f01014f8 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010275b:	83 c4 08             	add    $0x8,%esp
f010275e:	68 82 00 00 00       	push   $0x82
f0102763:	6a 00                	push   $0x0
f0102765:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010276a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010276f:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102774:	e8 7f ed ff ff       	call   f01014f8 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102779:	8b 1d 48 f9 11 f0    	mov    0xf011f948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010277f:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f0102784:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010278b:	83 c4 10             	add    $0x10,%esp
f010278e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102794:	74 63                	je     f01027f9 <mem_init+0x1142>
f0102796:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010279b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01027a1:	89 d8                	mov    %ebx,%eax
f01027a3:	e8 ef e7 ff ff       	call   f0100f97 <check_va2pa>
f01027a8:	8b 15 4c f9 11 f0    	mov    0xf011f94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ae:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027b4:	77 15                	ja     f01027cb <mem_init+0x1114>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b6:	52                   	push   %edx
f01027b7:	68 b8 45 10 f0       	push   $0xf01045b8
f01027bc:	68 a4 02 00 00       	push   $0x2a4
f01027c1:	68 78 4e 10 f0       	push   $0xf0104e78
f01027c6:	e8 c0 d8 ff ff       	call   f010008b <_panic>
f01027cb:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027d2:	39 d0                	cmp    %edx,%eax
f01027d4:	74 19                	je     f01027ef <mem_init+0x1138>
f01027d6:	68 e4 4c 10 f0       	push   $0xf0104ce4
f01027db:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01027e0:	68 a4 02 00 00       	push   $0x2a4
f01027e5:	68 78 4e 10 f0       	push   $0xf0104e78
f01027ea:	e8 9c d8 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027ef:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027f5:	39 f7                	cmp    %esi,%edi
f01027f7:	77 a2                	ja     f010279b <mem_init+0x10e4>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027f9:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f01027fe:	c1 e0 0c             	shl    $0xc,%eax
f0102801:	74 41                	je     f0102844 <mem_init+0x118d>
f0102803:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102808:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010280e:	89 d8                	mov    %ebx,%eax
f0102810:	e8 82 e7 ff ff       	call   f0100f97 <check_va2pa>
f0102815:	39 c6                	cmp    %eax,%esi
f0102817:	74 19                	je     f0102832 <mem_init+0x117b>
f0102819:	68 18 4d 10 f0       	push   $0xf0104d18
f010281e:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102823:	68 a9 02 00 00       	push   $0x2a9
f0102828:	68 78 4e 10 f0       	push   $0xf0104e78
f010282d:	e8 59 d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102832:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102838:	a1 44 f9 11 f0       	mov    0xf011f944,%eax
f010283d:	c1 e0 0c             	shl    $0xc,%eax
f0102840:	39 c6                	cmp    %eax,%esi
f0102842:	72 c4                	jb     f0102808 <mem_init+0x1151>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102844:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102849:	89 d8                	mov    %ebx,%eax
f010284b:	e8 47 e7 ff ff       	call   f0100f97 <check_va2pa>
f0102850:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102855:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
f010285a:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102860:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102863:	39 d0                	cmp    %edx,%eax
f0102865:	74 19                	je     f0102880 <mem_init+0x11c9>
f0102867:	68 40 4d 10 f0       	push   $0xf0104d40
f010286c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102871:	68 ad 02 00 00       	push   $0x2ad
f0102876:	68 78 4e 10 f0       	push   $0xf0104e78
f010287b:	e8 0b d8 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102880:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102886:	0f 85 25 04 00 00    	jne    f0102cb1 <mem_init+0x15fa>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010288c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102891:	89 d8                	mov    %ebx,%eax
f0102893:	e8 ff e6 ff ff       	call   f0100f97 <check_va2pa>
f0102898:	83 f8 ff             	cmp    $0xffffffff,%eax
f010289b:	74 19                	je     f01028b6 <mem_init+0x11ff>
f010289d:	68 88 4d 10 f0       	push   $0xf0104d88
f01028a2:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01028a7:	68 ae 02 00 00       	push   $0x2ae
f01028ac:	68 78 4e 10 f0       	push   $0xf0104e78
f01028b1:	e8 d5 d7 ff ff       	call   f010008b <_panic>
f01028b6:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028bb:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01028c0:	72 2d                	jb     f01028ef <mem_init+0x1238>
f01028c2:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028c7:	76 07                	jbe    f01028d0 <mem_init+0x1219>
f01028c9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028ce:	75 1f                	jne    f01028ef <mem_init+0x1238>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01028d0:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01028d4:	75 7e                	jne    f0102954 <mem_init+0x129d>
f01028d6:	68 0a 51 10 f0       	push   $0xf010510a
f01028db:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01028e0:	68 b6 02 00 00       	push   $0x2b6
f01028e5:	68 78 4e 10 f0       	push   $0xf0104e78
f01028ea:	e8 9c d7 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01028ef:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028f4:	76 3f                	jbe    f0102935 <mem_init+0x127e>
				assert(pgdir[i] & PTE_P);
f01028f6:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01028f9:	f6 c2 01             	test   $0x1,%dl
f01028fc:	75 19                	jne    f0102917 <mem_init+0x1260>
f01028fe:	68 0a 51 10 f0       	push   $0xf010510a
f0102903:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102908:	68 ba 02 00 00       	push   $0x2ba
f010290d:	68 78 4e 10 f0       	push   $0xf0104e78
f0102912:	e8 74 d7 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102917:	f6 c2 02             	test   $0x2,%dl
f010291a:	75 38                	jne    f0102954 <mem_init+0x129d>
f010291c:	68 1b 51 10 f0       	push   $0xf010511b
f0102921:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102926:	68 bb 02 00 00       	push   $0x2bb
f010292b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102930:	e8 56 d7 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102935:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102939:	74 19                	je     f0102954 <mem_init+0x129d>
f010293b:	68 2c 51 10 f0       	push   $0xf010512c
f0102940:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102945:	68 bd 02 00 00       	push   $0x2bd
f010294a:	68 78 4e 10 f0       	push   $0xf0104e78
f010294f:	e8 37 d7 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102954:	40                   	inc    %eax
f0102955:	3d 00 04 00 00       	cmp    $0x400,%eax
f010295a:	0f 85 5b ff ff ff    	jne    f01028bb <mem_init+0x1204>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102960:	83 ec 0c             	sub    $0xc,%esp
f0102963:	68 b8 4d 10 f0       	push   $0xf0104db8
f0102968:	e8 bc 03 00 00       	call   f0102d29 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010296d:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102972:	83 c4 10             	add    $0x10,%esp
f0102975:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010297a:	77 15                	ja     f0102991 <mem_init+0x12da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010297c:	50                   	push   %eax
f010297d:	68 b8 45 10 f0       	push   $0xf01045b8
f0102982:	68 e2 00 00 00       	push   $0xe2
f0102987:	68 78 4e 10 f0       	push   $0xf0104e78
f010298c:	e8 fa d6 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102991:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102996:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102999:	b8 00 00 00 00       	mov    $0x0,%eax
f010299e:	e8 90 e6 ff ff       	call   f0101033 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029a3:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029a6:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029ab:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029ae:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029b1:	83 ec 0c             	sub    $0xc,%esp
f01029b4:	6a 00                	push   $0x0
f01029b6:	e8 de e9 ff ff       	call   f0101399 <page_alloc>
f01029bb:	89 c6                	mov    %eax,%esi
f01029bd:	83 c4 10             	add    $0x10,%esp
f01029c0:	85 c0                	test   %eax,%eax
f01029c2:	75 19                	jne    f01029dd <mem_init+0x1326>
f01029c4:	68 49 4f 10 f0       	push   $0xf0104f49
f01029c9:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01029ce:	68 7e 03 00 00       	push   $0x37e
f01029d3:	68 78 4e 10 f0       	push   $0xf0104e78
f01029d8:	e8 ae d6 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01029dd:	83 ec 0c             	sub    $0xc,%esp
f01029e0:	6a 00                	push   $0x0
f01029e2:	e8 b2 e9 ff ff       	call   f0101399 <page_alloc>
f01029e7:	89 c7                	mov    %eax,%edi
f01029e9:	83 c4 10             	add    $0x10,%esp
f01029ec:	85 c0                	test   %eax,%eax
f01029ee:	75 19                	jne    f0102a09 <mem_init+0x1352>
f01029f0:	68 5f 4f 10 f0       	push   $0xf0104f5f
f01029f5:	68 9e 4e 10 f0       	push   $0xf0104e9e
f01029fa:	68 7f 03 00 00       	push   $0x37f
f01029ff:	68 78 4e 10 f0       	push   $0xf0104e78
f0102a04:	e8 82 d6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102a09:	83 ec 0c             	sub    $0xc,%esp
f0102a0c:	6a 00                	push   $0x0
f0102a0e:	e8 86 e9 ff ff       	call   f0101399 <page_alloc>
f0102a13:	89 c3                	mov    %eax,%ebx
f0102a15:	83 c4 10             	add    $0x10,%esp
f0102a18:	85 c0                	test   %eax,%eax
f0102a1a:	75 19                	jne    f0102a35 <mem_init+0x137e>
f0102a1c:	68 75 4f 10 f0       	push   $0xf0104f75
f0102a21:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102a26:	68 80 03 00 00       	push   $0x380
f0102a2b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102a30:	e8 56 d6 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102a35:	83 ec 0c             	sub    $0xc,%esp
f0102a38:	56                   	push   %esi
f0102a39:	e8 e5 e9 ff ff       	call   f0101423 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a3e:	89 f8                	mov    %edi,%eax
f0102a40:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102a46:	c1 f8 03             	sar    $0x3,%eax
f0102a49:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a4c:	89 c2                	mov    %eax,%edx
f0102a4e:	c1 ea 0c             	shr    $0xc,%edx
f0102a51:	83 c4 10             	add    $0x10,%esp
f0102a54:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102a5a:	72 12                	jb     f0102a6e <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a5c:	50                   	push   %eax
f0102a5d:	68 80 47 10 f0       	push   $0xf0104780
f0102a62:	6a 52                	push   $0x52
f0102a64:	68 84 4e 10 f0       	push   $0xf0104e84
f0102a69:	e8 1d d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a6e:	83 ec 04             	sub    $0x4,%esp
f0102a71:	68 00 10 00 00       	push   $0x1000
f0102a76:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a78:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a7d:	50                   	push   %eax
f0102a7e:	e8 d6 0d 00 00       	call   f0103859 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a83:	89 d8                	mov    %ebx,%eax
f0102a85:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102a8b:	c1 f8 03             	sar    $0x3,%eax
f0102a8e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a91:	89 c2                	mov    %eax,%edx
f0102a93:	c1 ea 0c             	shr    $0xc,%edx
f0102a96:	83 c4 10             	add    $0x10,%esp
f0102a99:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102a9f:	72 12                	jb     f0102ab3 <mem_init+0x13fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aa1:	50                   	push   %eax
f0102aa2:	68 80 47 10 f0       	push   $0xf0104780
f0102aa7:	6a 52                	push   $0x52
f0102aa9:	68 84 4e 10 f0       	push   $0xf0104e84
f0102aae:	e8 d8 d5 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ab3:	83 ec 04             	sub    $0x4,%esp
f0102ab6:	68 00 10 00 00       	push   $0x1000
f0102abb:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102abd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ac2:	50                   	push   %eax
f0102ac3:	e8 91 0d 00 00       	call   f0103859 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ac8:	6a 02                	push   $0x2
f0102aca:	68 00 10 00 00       	push   $0x1000
f0102acf:	57                   	push   %edi
f0102ad0:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102ad6:	e8 73 eb ff ff       	call   f010164e <page_insert>
	assert(pp1->pp_ref == 1);
f0102adb:	83 c4 20             	add    $0x20,%esp
f0102ade:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ae3:	74 19                	je     f0102afe <mem_init+0x1447>
f0102ae5:	68 46 50 10 f0       	push   $0xf0105046
f0102aea:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102aef:	68 85 03 00 00       	push   $0x385
f0102af4:	68 78 4e 10 f0       	push   $0xf0104e78
f0102af9:	e8 8d d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102afe:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b05:	01 01 01 
f0102b08:	74 19                	je     f0102b23 <mem_init+0x146c>
f0102b0a:	68 d8 4d 10 f0       	push   $0xf0104dd8
f0102b0f:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102b14:	68 86 03 00 00       	push   $0x386
f0102b19:	68 78 4e 10 f0       	push   $0xf0104e78
f0102b1e:	e8 68 d5 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b23:	6a 02                	push   $0x2
f0102b25:	68 00 10 00 00       	push   $0x1000
f0102b2a:	53                   	push   %ebx
f0102b2b:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102b31:	e8 18 eb ff ff       	call   f010164e <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b36:	83 c4 10             	add    $0x10,%esp
f0102b39:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b40:	02 02 02 
f0102b43:	74 19                	je     f0102b5e <mem_init+0x14a7>
f0102b45:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0102b4a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102b4f:	68 88 03 00 00       	push   $0x388
f0102b54:	68 78 4e 10 f0       	push   $0xf0104e78
f0102b59:	e8 2d d5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102b5e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b63:	74 19                	je     f0102b7e <mem_init+0x14c7>
f0102b65:	68 68 50 10 f0       	push   $0xf0105068
f0102b6a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102b6f:	68 89 03 00 00       	push   $0x389
f0102b74:	68 78 4e 10 f0       	push   $0xf0104e78
f0102b79:	e8 0d d5 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102b7e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b83:	74 19                	je     f0102b9e <mem_init+0x14e7>
f0102b85:	68 b1 50 10 f0       	push   $0xf01050b1
f0102b8a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102b8f:	68 8a 03 00 00       	push   $0x38a
f0102b94:	68 78 4e 10 f0       	push   $0xf0104e78
f0102b99:	e8 ed d4 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b9e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ba5:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba8:	89 d8                	mov    %ebx,%eax
f0102baa:	2b 05 4c f9 11 f0    	sub    0xf011f94c,%eax
f0102bb0:	c1 f8 03             	sar    $0x3,%eax
f0102bb3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb6:	89 c2                	mov    %eax,%edx
f0102bb8:	c1 ea 0c             	shr    $0xc,%edx
f0102bbb:	3b 15 44 f9 11 f0    	cmp    0xf011f944,%edx
f0102bc1:	72 12                	jb     f0102bd5 <mem_init+0x151e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc3:	50                   	push   %eax
f0102bc4:	68 80 47 10 f0       	push   $0xf0104780
f0102bc9:	6a 52                	push   $0x52
f0102bcb:	68 84 4e 10 f0       	push   $0xf0104e84
f0102bd0:	e8 b6 d4 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102bd5:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bdc:	03 03 03 
f0102bdf:	74 19                	je     f0102bfa <mem_init+0x1543>
f0102be1:	68 20 4e 10 f0       	push   $0xf0104e20
f0102be6:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102beb:	68 8c 03 00 00       	push   $0x38c
f0102bf0:	68 78 4e 10 f0       	push   $0xf0104e78
f0102bf5:	e8 91 d4 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bfa:	83 ec 08             	sub    $0x8,%esp
f0102bfd:	68 00 10 00 00       	push   $0x1000
f0102c02:	ff 35 48 f9 11 f0    	pushl  0xf011f948
f0102c08:	e8 f4 e9 ff ff       	call   f0101601 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c0d:	83 c4 10             	add    $0x10,%esp
f0102c10:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c15:	74 19                	je     f0102c30 <mem_init+0x1579>
f0102c17:	68 a0 50 10 f0       	push   $0xf01050a0
f0102c1c:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102c21:	68 8e 03 00 00       	push   $0x38e
f0102c26:	68 78 4e 10 f0       	push   $0xf0104e78
f0102c2b:	e8 5b d4 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c30:	a1 48 f9 11 f0       	mov    0xf011f948,%eax
f0102c35:	8b 08                	mov    (%eax),%ecx
f0102c37:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c3d:	89 f2                	mov    %esi,%edx
f0102c3f:	2b 15 4c f9 11 f0    	sub    0xf011f94c,%edx
f0102c45:	c1 fa 03             	sar    $0x3,%edx
f0102c48:	c1 e2 0c             	shl    $0xc,%edx
f0102c4b:	39 d1                	cmp    %edx,%ecx
f0102c4d:	74 19                	je     f0102c68 <mem_init+0x15b1>
f0102c4f:	68 9c 49 10 f0       	push   $0xf010499c
f0102c54:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102c59:	68 91 03 00 00       	push   $0x391
f0102c5e:	68 78 4e 10 f0       	push   $0xf0104e78
f0102c63:	e8 23 d4 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102c68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c6e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c73:	74 19                	je     f0102c8e <mem_init+0x15d7>
f0102c75:	68 57 50 10 f0       	push   $0xf0105057
f0102c7a:	68 9e 4e 10 f0       	push   $0xf0104e9e
f0102c7f:	68 93 03 00 00       	push   $0x393
f0102c84:	68 78 4e 10 f0       	push   $0xf0104e78
f0102c89:	e8 fd d3 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102c8e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c94:	83 ec 0c             	sub    $0xc,%esp
f0102c97:	56                   	push   %esi
f0102c98:	e8 86 e7 ff ff       	call   f0101423 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c9d:	c7 04 24 4c 4e 10 f0 	movl   $0xf0104e4c,(%esp)
f0102ca4:	e8 80 00 00 00       	call   f0102d29 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cac:	5b                   	pop    %ebx
f0102cad:	5e                   	pop    %esi
f0102cae:	5f                   	pop    %edi
f0102caf:	c9                   	leave  
f0102cb0:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cb1:	89 f2                	mov    %esi,%edx
f0102cb3:	89 d8                	mov    %ebx,%eax
f0102cb5:	e8 dd e2 ff ff       	call   f0100f97 <check_va2pa>
f0102cba:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102cc0:	e9 9b fb ff ff       	jmp    f0102860 <mem_init+0x11a9>
f0102cc5:	00 00                	add    %al,(%eax)
	...

f0102cc8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102cc8:	55                   	push   %ebp
f0102cc9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ccb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102cd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cd3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102cd4:	b2 71                	mov    $0x71,%dl
f0102cd6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102cd7:	0f b6 c0             	movzbl %al,%eax
}
f0102cda:	c9                   	leave  
f0102cdb:	c3                   	ret    

f0102cdc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102cdc:	55                   	push   %ebp
f0102cdd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102cdf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ce4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ce7:	ee                   	out    %al,(%dx)
f0102ce8:	b2 71                	mov    $0x71,%dl
f0102cea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ced:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102cee:	c9                   	leave  
f0102cef:	c3                   	ret    

f0102cf0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102cf0:	55                   	push   %ebp
f0102cf1:	89 e5                	mov    %esp,%ebp
f0102cf3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102cf6:	ff 75 08             	pushl  0x8(%ebp)
f0102cf9:	e8 a8 d8 ff ff       	call   f01005a6 <cputchar>
f0102cfe:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102d01:	c9                   	leave  
f0102d02:	c3                   	ret    

f0102d03 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d03:	55                   	push   %ebp
f0102d04:	89 e5                	mov    %esp,%ebp
f0102d06:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102d09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d10:	ff 75 0c             	pushl  0xc(%ebp)
f0102d13:	ff 75 08             	pushl  0x8(%ebp)
f0102d16:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d19:	50                   	push   %eax
f0102d1a:	68 f0 2c 10 f0       	push   $0xf0102cf0
f0102d1f:	e8 9d 04 00 00       	call   f01031c1 <vprintfmt>
	return cnt;
}
f0102d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d27:	c9                   	leave  
f0102d28:	c3                   	ret    

f0102d29 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d29:	55                   	push   %ebp
f0102d2a:	89 e5                	mov    %esp,%ebp
f0102d2c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d2f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d32:	50                   	push   %eax
f0102d33:	ff 75 08             	pushl  0x8(%ebp)
f0102d36:	e8 c8 ff ff ff       	call   f0102d03 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102d3b:	c9                   	leave  
f0102d3c:	c3                   	ret    
f0102d3d:	00 00                	add    %al,(%eax)
	...

f0102d40 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102d40:	55                   	push   %ebp
f0102d41:	89 e5                	mov    %esp,%ebp
f0102d43:	57                   	push   %edi
f0102d44:	56                   	push   %esi
f0102d45:	53                   	push   %ebx
f0102d46:	83 ec 14             	sub    $0x14,%esp
f0102d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d4c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102d4f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102d52:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d55:	8b 1a                	mov    (%edx),%ebx
f0102d57:	8b 01                	mov    (%ecx),%eax
f0102d59:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102d5c:	39 c3                	cmp    %eax,%ebx
f0102d5e:	0f 8f 97 00 00 00    	jg     f0102dfb <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d6e:	01 d8                	add    %ebx,%eax
f0102d70:	89 c7                	mov    %eax,%edi
f0102d72:	c1 ef 1f             	shr    $0x1f,%edi
f0102d75:	01 c7                	add    %eax,%edi
f0102d77:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d79:	39 df                	cmp    %ebx,%edi
f0102d7b:	7c 31                	jl     f0102dae <stab_binsearch+0x6e>
f0102d7d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102d80:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102d83:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102d88:	39 f0                	cmp    %esi,%eax
f0102d8a:	0f 84 b3 00 00 00    	je     f0102e43 <stab_binsearch+0x103>
f0102d90:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d94:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d98:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102d9a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d9b:	39 d8                	cmp    %ebx,%eax
f0102d9d:	7c 0f                	jl     f0102dae <stab_binsearch+0x6e>
f0102d9f:	0f b6 0a             	movzbl (%edx),%ecx
f0102da2:	83 ea 0c             	sub    $0xc,%edx
f0102da5:	39 f1                	cmp    %esi,%ecx
f0102da7:	75 f1                	jne    f0102d9a <stab_binsearch+0x5a>
f0102da9:	e9 97 00 00 00       	jmp    f0102e45 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102dae:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102db1:	eb 39                	jmp    f0102dec <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102db3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102db6:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102db8:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102dbb:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102dc2:	eb 28                	jmp    f0102dec <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102dc4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102dc7:	76 12                	jbe    f0102ddb <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102dc9:	48                   	dec    %eax
f0102dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102dcd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102dd0:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102dd2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102dd9:	eb 11                	jmp    f0102dec <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102ddb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102dde:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102de0:	ff 45 0c             	incl   0xc(%ebp)
f0102de3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102de5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102dec:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102def:	0f 8d 76 ff ff ff    	jge    f0102d6b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102df5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102df9:	75 0d                	jne    f0102e08 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102dfb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102dfe:	8b 03                	mov    (%ebx),%eax
f0102e00:	48                   	dec    %eax
f0102e01:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e04:	89 02                	mov    %eax,(%edx)
f0102e06:	eb 55                	jmp    f0102e5d <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e08:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e0b:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e0d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e10:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e12:	39 c1                	cmp    %eax,%ecx
f0102e14:	7d 26                	jge    f0102e3c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102e16:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102e19:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102e1c:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102e21:	39 f2                	cmp    %esi,%edx
f0102e23:	74 17                	je     f0102e3c <stab_binsearch+0xfc>
f0102e25:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102e29:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e2d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e2e:	39 c1                	cmp    %eax,%ecx
f0102e30:	7d 0a                	jge    f0102e3c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102e32:	0f b6 1a             	movzbl (%edx),%ebx
f0102e35:	83 ea 0c             	sub    $0xc,%edx
f0102e38:	39 f3                	cmp    %esi,%ebx
f0102e3a:	75 f1                	jne    f0102e2d <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e3c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e3f:	89 02                	mov    %eax,(%edx)
f0102e41:	eb 1a                	jmp    f0102e5d <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102e43:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102e45:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102e48:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102e4b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102e4f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e52:	0f 82 5b ff ff ff    	jb     f0102db3 <stab_binsearch+0x73>
f0102e58:	e9 67 ff ff ff       	jmp    f0102dc4 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102e5d:	83 c4 14             	add    $0x14,%esp
f0102e60:	5b                   	pop    %ebx
f0102e61:	5e                   	pop    %esi
f0102e62:	5f                   	pop    %edi
f0102e63:	c9                   	leave  
f0102e64:	c3                   	ret    

f0102e65 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e65:	55                   	push   %ebp
f0102e66:	89 e5                	mov    %esp,%ebp
f0102e68:	57                   	push   %edi
f0102e69:	56                   	push   %esi
f0102e6a:	53                   	push   %ebx
f0102e6b:	83 ec 2c             	sub    $0x2c,%esp
f0102e6e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102e74:	c7 03 3a 51 10 f0    	movl   $0xf010513a,(%ebx)
	info->eip_line = 0;
f0102e7a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102e81:	c7 43 08 3a 51 10 f0 	movl   $0xf010513a,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102e88:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102e8f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102e92:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102e99:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e9f:	76 12                	jbe    f0102eb3 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ea1:	b8 30 41 11 f0       	mov    $0xf0114130,%eax
f0102ea6:	3d 05 c8 10 f0       	cmp    $0xf010c805,%eax
f0102eab:	0f 86 90 01 00 00    	jbe    f0103041 <debuginfo_eip+0x1dc>
f0102eb1:	eb 14                	jmp    f0102ec7 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102eb3:	83 ec 04             	sub    $0x4,%esp
f0102eb6:	68 44 51 10 f0       	push   $0xf0105144
f0102ebb:	6a 7f                	push   $0x7f
f0102ebd:	68 51 51 10 f0       	push   $0xf0105151
f0102ec2:	e8 c4 d1 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ecc:	80 3d 2f 41 11 f0 00 	cmpb   $0x0,0xf011412f
f0102ed3:	0f 85 74 01 00 00    	jne    f010304d <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102ed9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102ee0:	b8 04 c8 10 f0       	mov    $0xf010c804,%eax
f0102ee5:	2d 70 53 10 f0       	sub    $0xf0105370,%eax
f0102eea:	c1 f8 02             	sar    $0x2,%eax
f0102eed:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ef3:	48                   	dec    %eax
f0102ef4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102ef7:	83 ec 08             	sub    $0x8,%esp
f0102efa:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102efd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f00:	56                   	push   %esi
f0102f01:	6a 64                	push   $0x64
f0102f03:	b8 70 53 10 f0       	mov    $0xf0105370,%eax
f0102f08:	e8 33 fe ff ff       	call   f0102d40 <stab_binsearch>
	if (lfile == 0)
f0102f0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102f10:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102f18:	85 d2                	test   %edx,%edx
f0102f1a:	0f 84 2d 01 00 00    	je     f010304d <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f20:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102f23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f26:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f29:	83 ec 08             	sub    $0x8,%esp
f0102f2c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f2f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f32:	56                   	push   %esi
f0102f33:	6a 24                	push   $0x24
f0102f35:	b8 70 53 10 f0       	mov    $0xf0105370,%eax
f0102f3a:	e8 01 fe ff ff       	call   f0102d40 <stab_binsearch>

	if (lfun <= rfun) {
f0102f3f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102f42:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102f48:	83 c4 10             	add    $0x10,%esp
f0102f4b:	39 c7                	cmp    %eax,%edi
f0102f4d:	7f 32                	jg     f0102f81 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f4f:	89 f9                	mov    %edi,%ecx
f0102f51:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102f54:	8b 80 70 53 10 f0    	mov    -0xfefac90(%eax),%eax
f0102f5a:	ba 30 41 11 f0       	mov    $0xf0114130,%edx
f0102f5f:	81 ea 05 c8 10 f0    	sub    $0xf010c805,%edx
f0102f65:	39 d0                	cmp    %edx,%eax
f0102f67:	73 08                	jae    f0102f71 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102f69:	05 05 c8 10 f0       	add    $0xf010c805,%eax
f0102f6e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102f71:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102f74:	8b 81 78 53 10 f0    	mov    -0xfefac88(%ecx),%eax
f0102f7a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102f7d:	29 c6                	sub    %eax,%esi
f0102f7f:	eb 0c                	jmp    f0102f8d <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102f81:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102f84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102f87:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f8a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102f8d:	83 ec 08             	sub    $0x8,%esp
f0102f90:	6a 3a                	push   $0x3a
f0102f92:	ff 73 08             	pushl  0x8(%ebx)
f0102f95:	e8 9d 08 00 00       	call   f0103837 <strfind>
f0102f9a:	2b 43 08             	sub    0x8(%ebx),%eax
f0102f9d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102fa0:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102fa3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102fa9:	83 c4 08             	add    $0x8,%esp
f0102fac:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102faf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102fb2:	56                   	push   %esi
f0102fb3:	6a 44                	push   $0x44
f0102fb5:	b8 70 53 10 f0       	mov    $0xf0105370,%eax
f0102fba:	e8 81 fd ff ff       	call   f0102d40 <stab_binsearch>
    if (lfun <= rfun) {
f0102fbf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fc2:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102fca:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102fcd:	7f 7e                	jg     f010304d <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102fcf:	6b c2 0c             	imul   $0xc,%edx,%eax
f0102fd2:	05 70 53 10 f0       	add    $0xf0105370,%eax
f0102fd7:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102fdb:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fde:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102fe1:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fe4:	eb 04                	jmp    f0102fea <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102fe6:	4a                   	dec    %edx
f0102fe7:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fea:	39 f2                	cmp    %esi,%edx
f0102fec:	7c 1b                	jl     f0103009 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0102fee:	8a 48 fc             	mov    -0x4(%eax),%cl
f0102ff1:	80 f9 84             	cmp    $0x84,%cl
f0102ff4:	74 5f                	je     f0103055 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102ff6:	80 f9 64             	cmp    $0x64,%cl
f0102ff9:	75 eb                	jne    f0102fe6 <debuginfo_eip+0x181>
f0102ffb:	83 38 00             	cmpl   $0x0,(%eax)
f0102ffe:	74 e6                	je     f0102fe6 <debuginfo_eip+0x181>
f0103000:	eb 53                	jmp    f0103055 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103002:	05 05 c8 10 f0       	add    $0xf010c805,%eax
f0103007:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103009:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010300c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010300f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103014:	39 ca                	cmp    %ecx,%edx
f0103016:	7d 35                	jge    f010304d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0103018:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010301b:	6b d0 0c             	imul   $0xc,%eax,%edx
f010301e:	81 c2 74 53 10 f0    	add    $0xf0105374,%edx
f0103024:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103026:	eb 04                	jmp    f010302c <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103028:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010302b:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010302c:	39 f0                	cmp    %esi,%eax
f010302e:	7d 18                	jge    f0103048 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103030:	8a 0a                	mov    (%edx),%cl
f0103032:	83 c2 0c             	add    $0xc,%edx
f0103035:	80 f9 a0             	cmp    $0xa0,%cl
f0103038:	74 ee                	je     f0103028 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010303a:	b8 00 00 00 00       	mov    $0x0,%eax
f010303f:	eb 0c                	jmp    f010304d <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103046:	eb 05                	jmp    f010304d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103048:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010304d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103050:	5b                   	pop    %ebx
f0103051:	5e                   	pop    %esi
f0103052:	5f                   	pop    %edi
f0103053:	c9                   	leave  
f0103054:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103055:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103058:	8b 82 70 53 10 f0    	mov    -0xfefac90(%edx),%eax
f010305e:	ba 30 41 11 f0       	mov    $0xf0114130,%edx
f0103063:	81 ea 05 c8 10 f0    	sub    $0xf010c805,%edx
f0103069:	39 d0                	cmp    %edx,%eax
f010306b:	72 95                	jb     f0103002 <debuginfo_eip+0x19d>
f010306d:	eb 9a                	jmp    f0103009 <debuginfo_eip+0x1a4>
	...

f0103070 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103070:	55                   	push   %ebp
f0103071:	89 e5                	mov    %esp,%ebp
f0103073:	57                   	push   %edi
f0103074:	56                   	push   %esi
f0103075:	53                   	push   %ebx
f0103076:	83 ec 2c             	sub    $0x2c,%esp
f0103079:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010307c:	89 d6                	mov    %edx,%esi
f010307e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103081:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103084:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103087:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010308a:	8b 45 10             	mov    0x10(%ebp),%eax
f010308d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103090:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103093:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103096:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010309d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f01030a0:	72 0c                	jb     f01030ae <printnum+0x3e>
f01030a2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01030a5:	76 07                	jbe    f01030ae <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01030a7:	4b                   	dec    %ebx
f01030a8:	85 db                	test   %ebx,%ebx
f01030aa:	7f 31                	jg     f01030dd <printnum+0x6d>
f01030ac:	eb 3f                	jmp    f01030ed <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030ae:	83 ec 0c             	sub    $0xc,%esp
f01030b1:	57                   	push   %edi
f01030b2:	4b                   	dec    %ebx
f01030b3:	53                   	push   %ebx
f01030b4:	50                   	push   %eax
f01030b5:	83 ec 08             	sub    $0x8,%esp
f01030b8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01030bb:	ff 75 d0             	pushl  -0x30(%ebp)
f01030be:	ff 75 dc             	pushl  -0x24(%ebp)
f01030c1:	ff 75 d8             	pushl  -0x28(%ebp)
f01030c4:	e8 97 09 00 00       	call   f0103a60 <__udivdi3>
f01030c9:	83 c4 18             	add    $0x18,%esp
f01030cc:	52                   	push   %edx
f01030cd:	50                   	push   %eax
f01030ce:	89 f2                	mov    %esi,%edx
f01030d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030d3:	e8 98 ff ff ff       	call   f0103070 <printnum>
f01030d8:	83 c4 20             	add    $0x20,%esp
f01030db:	eb 10                	jmp    f01030ed <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01030dd:	83 ec 08             	sub    $0x8,%esp
f01030e0:	56                   	push   %esi
f01030e1:	57                   	push   %edi
f01030e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01030e5:	4b                   	dec    %ebx
f01030e6:	83 c4 10             	add    $0x10,%esp
f01030e9:	85 db                	test   %ebx,%ebx
f01030eb:	7f f0                	jg     f01030dd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01030ed:	83 ec 08             	sub    $0x8,%esp
f01030f0:	56                   	push   %esi
f01030f1:	83 ec 04             	sub    $0x4,%esp
f01030f4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01030f7:	ff 75 d0             	pushl  -0x30(%ebp)
f01030fa:	ff 75 dc             	pushl  -0x24(%ebp)
f01030fd:	ff 75 d8             	pushl  -0x28(%ebp)
f0103100:	e8 77 0a 00 00       	call   f0103b7c <__umoddi3>
f0103105:	83 c4 14             	add    $0x14,%esp
f0103108:	0f be 80 5f 51 10 f0 	movsbl -0xfefaea1(%eax),%eax
f010310f:	50                   	push   %eax
f0103110:	ff 55 e4             	call   *-0x1c(%ebp)
f0103113:	83 c4 10             	add    $0x10,%esp
}
f0103116:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103119:	5b                   	pop    %ebx
f010311a:	5e                   	pop    %esi
f010311b:	5f                   	pop    %edi
f010311c:	c9                   	leave  
f010311d:	c3                   	ret    

f010311e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010311e:	55                   	push   %ebp
f010311f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103121:	83 fa 01             	cmp    $0x1,%edx
f0103124:	7e 0e                	jle    f0103134 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103126:	8b 10                	mov    (%eax),%edx
f0103128:	8d 4a 08             	lea    0x8(%edx),%ecx
f010312b:	89 08                	mov    %ecx,(%eax)
f010312d:	8b 02                	mov    (%edx),%eax
f010312f:	8b 52 04             	mov    0x4(%edx),%edx
f0103132:	eb 22                	jmp    f0103156 <getuint+0x38>
	else if (lflag)
f0103134:	85 d2                	test   %edx,%edx
f0103136:	74 10                	je     f0103148 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103138:	8b 10                	mov    (%eax),%edx
f010313a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010313d:	89 08                	mov    %ecx,(%eax)
f010313f:	8b 02                	mov    (%edx),%eax
f0103141:	ba 00 00 00 00       	mov    $0x0,%edx
f0103146:	eb 0e                	jmp    f0103156 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103148:	8b 10                	mov    (%eax),%edx
f010314a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010314d:	89 08                	mov    %ecx,(%eax)
f010314f:	8b 02                	mov    (%edx),%eax
f0103151:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103156:	c9                   	leave  
f0103157:	c3                   	ret    

f0103158 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103158:	55                   	push   %ebp
f0103159:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010315b:	83 fa 01             	cmp    $0x1,%edx
f010315e:	7e 0e                	jle    f010316e <getint+0x16>
		return va_arg(*ap, long long);
f0103160:	8b 10                	mov    (%eax),%edx
f0103162:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103165:	89 08                	mov    %ecx,(%eax)
f0103167:	8b 02                	mov    (%edx),%eax
f0103169:	8b 52 04             	mov    0x4(%edx),%edx
f010316c:	eb 1a                	jmp    f0103188 <getint+0x30>
	else if (lflag)
f010316e:	85 d2                	test   %edx,%edx
f0103170:	74 0c                	je     f010317e <getint+0x26>
		return va_arg(*ap, long);
f0103172:	8b 10                	mov    (%eax),%edx
f0103174:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103177:	89 08                	mov    %ecx,(%eax)
f0103179:	8b 02                	mov    (%edx),%eax
f010317b:	99                   	cltd   
f010317c:	eb 0a                	jmp    f0103188 <getint+0x30>
	else
		return va_arg(*ap, int);
f010317e:	8b 10                	mov    (%eax),%edx
f0103180:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103183:	89 08                	mov    %ecx,(%eax)
f0103185:	8b 02                	mov    (%edx),%eax
f0103187:	99                   	cltd   
}
f0103188:	c9                   	leave  
f0103189:	c3                   	ret    

f010318a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010318a:	55                   	push   %ebp
f010318b:	89 e5                	mov    %esp,%ebp
f010318d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103190:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103193:	8b 10                	mov    (%eax),%edx
f0103195:	3b 50 04             	cmp    0x4(%eax),%edx
f0103198:	73 08                	jae    f01031a2 <sprintputch+0x18>
		*b->buf++ = ch;
f010319a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010319d:	88 0a                	mov    %cl,(%edx)
f010319f:	42                   	inc    %edx
f01031a0:	89 10                	mov    %edx,(%eax)
}
f01031a2:	c9                   	leave  
f01031a3:	c3                   	ret    

f01031a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01031a4:	55                   	push   %ebp
f01031a5:	89 e5                	mov    %esp,%ebp
f01031a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01031aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031ad:	50                   	push   %eax
f01031ae:	ff 75 10             	pushl  0x10(%ebp)
f01031b1:	ff 75 0c             	pushl  0xc(%ebp)
f01031b4:	ff 75 08             	pushl  0x8(%ebp)
f01031b7:	e8 05 00 00 00       	call   f01031c1 <vprintfmt>
	va_end(ap);
f01031bc:	83 c4 10             	add    $0x10,%esp
}
f01031bf:	c9                   	leave  
f01031c0:	c3                   	ret    

f01031c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031c1:	55                   	push   %ebp
f01031c2:	89 e5                	mov    %esp,%ebp
f01031c4:	57                   	push   %edi
f01031c5:	56                   	push   %esi
f01031c6:	53                   	push   %ebx
f01031c7:	83 ec 2c             	sub    $0x2c,%esp
f01031ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01031cd:	8b 75 10             	mov    0x10(%ebp),%esi
f01031d0:	eb 13                	jmp    f01031e5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01031d2:	85 c0                	test   %eax,%eax
f01031d4:	0f 84 6d 03 00 00    	je     f0103547 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01031da:	83 ec 08             	sub    $0x8,%esp
f01031dd:	57                   	push   %edi
f01031de:	50                   	push   %eax
f01031df:	ff 55 08             	call   *0x8(%ebp)
f01031e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01031e5:	0f b6 06             	movzbl (%esi),%eax
f01031e8:	46                   	inc    %esi
f01031e9:	83 f8 25             	cmp    $0x25,%eax
f01031ec:	75 e4                	jne    f01031d2 <vprintfmt+0x11>
f01031ee:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01031f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0103200:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103207:	b9 00 00 00 00       	mov    $0x0,%ecx
f010320c:	eb 28                	jmp    f0103236 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010320e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103210:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103214:	eb 20                	jmp    f0103236 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103216:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103218:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010321c:	eb 18                	jmp    f0103236 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010321e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103220:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103227:	eb 0d                	jmp    f0103236 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103229:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010322c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010322f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103236:	8a 06                	mov    (%esi),%al
f0103238:	0f b6 d0             	movzbl %al,%edx
f010323b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010323e:	83 e8 23             	sub    $0x23,%eax
f0103241:	3c 55                	cmp    $0x55,%al
f0103243:	0f 87 e0 02 00 00    	ja     f0103529 <vprintfmt+0x368>
f0103249:	0f b6 c0             	movzbl %al,%eax
f010324c:	ff 24 85 ec 51 10 f0 	jmp    *-0xfefae14(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103253:	83 ea 30             	sub    $0x30,%edx
f0103256:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103259:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f010325c:	8d 50 d0             	lea    -0x30(%eax),%edx
f010325f:	83 fa 09             	cmp    $0x9,%edx
f0103262:	77 44                	ja     f01032a8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103264:	89 de                	mov    %ebx,%esi
f0103266:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103269:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010326a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010326d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103271:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103274:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103277:	83 fb 09             	cmp    $0x9,%ebx
f010327a:	76 ed                	jbe    f0103269 <vprintfmt+0xa8>
f010327c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010327f:	eb 29                	jmp    f01032aa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103281:	8b 45 14             	mov    0x14(%ebp),%eax
f0103284:	8d 50 04             	lea    0x4(%eax),%edx
f0103287:	89 55 14             	mov    %edx,0x14(%ebp)
f010328a:	8b 00                	mov    (%eax),%eax
f010328c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010328f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103291:	eb 17                	jmp    f01032aa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103293:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103297:	78 85                	js     f010321e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103299:	89 de                	mov    %ebx,%esi
f010329b:	eb 99                	jmp    f0103236 <vprintfmt+0x75>
f010329d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010329f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01032a6:	eb 8e                	jmp    f0103236 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032a8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01032aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032ae:	79 86                	jns    f0103236 <vprintfmt+0x75>
f01032b0:	e9 74 ff ff ff       	jmp    f0103229 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01032b5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032b6:	89 de                	mov    %ebx,%esi
f01032b8:	e9 79 ff ff ff       	jmp    f0103236 <vprintfmt+0x75>
f01032bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c3:	8d 50 04             	lea    0x4(%eax),%edx
f01032c6:	89 55 14             	mov    %edx,0x14(%ebp)
f01032c9:	83 ec 08             	sub    $0x8,%esp
f01032cc:	57                   	push   %edi
f01032cd:	ff 30                	pushl  (%eax)
f01032cf:	ff 55 08             	call   *0x8(%ebp)
			break;
f01032d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01032d8:	e9 08 ff ff ff       	jmp    f01031e5 <vprintfmt+0x24>
f01032dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01032e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01032e3:	8d 50 04             	lea    0x4(%eax),%edx
f01032e6:	89 55 14             	mov    %edx,0x14(%ebp)
f01032e9:	8b 00                	mov    (%eax),%eax
f01032eb:	85 c0                	test   %eax,%eax
f01032ed:	79 02                	jns    f01032f1 <vprintfmt+0x130>
f01032ef:	f7 d8                	neg    %eax
f01032f1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01032f3:	83 f8 06             	cmp    $0x6,%eax
f01032f6:	7f 0b                	jg     f0103303 <vprintfmt+0x142>
f01032f8:	8b 04 85 44 53 10 f0 	mov    -0xfefacbc(,%eax,4),%eax
f01032ff:	85 c0                	test   %eax,%eax
f0103301:	75 1a                	jne    f010331d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0103303:	52                   	push   %edx
f0103304:	68 77 51 10 f0       	push   $0xf0105177
f0103309:	57                   	push   %edi
f010330a:	ff 75 08             	pushl  0x8(%ebp)
f010330d:	e8 92 fe ff ff       	call   f01031a4 <printfmt>
f0103312:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103315:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103318:	e9 c8 fe ff ff       	jmp    f01031e5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f010331d:	50                   	push   %eax
f010331e:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0103323:	57                   	push   %edi
f0103324:	ff 75 08             	pushl  0x8(%ebp)
f0103327:	e8 78 fe ff ff       	call   f01031a4 <printfmt>
f010332c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010332f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103332:	e9 ae fe ff ff       	jmp    f01031e5 <vprintfmt+0x24>
f0103337:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010333a:	89 de                	mov    %ebx,%esi
f010333c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010333f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103342:	8b 45 14             	mov    0x14(%ebp),%eax
f0103345:	8d 50 04             	lea    0x4(%eax),%edx
f0103348:	89 55 14             	mov    %edx,0x14(%ebp)
f010334b:	8b 00                	mov    (%eax),%eax
f010334d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103350:	85 c0                	test   %eax,%eax
f0103352:	75 07                	jne    f010335b <vprintfmt+0x19a>
				p = "(null)";
f0103354:	c7 45 d0 70 51 10 f0 	movl   $0xf0105170,-0x30(%ebp)
			if (width > 0 && padc != '-')
f010335b:	85 db                	test   %ebx,%ebx
f010335d:	7e 42                	jle    f01033a1 <vprintfmt+0x1e0>
f010335f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103363:	74 3c                	je     f01033a1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103365:	83 ec 08             	sub    $0x8,%esp
f0103368:	51                   	push   %ecx
f0103369:	ff 75 d0             	pushl  -0x30(%ebp)
f010336c:	e8 3f 03 00 00       	call   f01036b0 <strnlen>
f0103371:	29 c3                	sub    %eax,%ebx
f0103373:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103376:	83 c4 10             	add    $0x10,%esp
f0103379:	85 db                	test   %ebx,%ebx
f010337b:	7e 24                	jle    f01033a1 <vprintfmt+0x1e0>
					putch(padc, putdat);
f010337d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103381:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103384:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103387:	83 ec 08             	sub    $0x8,%esp
f010338a:	57                   	push   %edi
f010338b:	53                   	push   %ebx
f010338c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010338f:	4e                   	dec    %esi
f0103390:	83 c4 10             	add    $0x10,%esp
f0103393:	85 f6                	test   %esi,%esi
f0103395:	7f f0                	jg     f0103387 <vprintfmt+0x1c6>
f0103397:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010339a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01033a4:	0f be 02             	movsbl (%edx),%eax
f01033a7:	85 c0                	test   %eax,%eax
f01033a9:	75 47                	jne    f01033f2 <vprintfmt+0x231>
f01033ab:	eb 37                	jmp    f01033e4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01033ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01033b1:	74 16                	je     f01033c9 <vprintfmt+0x208>
f01033b3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01033b6:	83 fa 5e             	cmp    $0x5e,%edx
f01033b9:	76 0e                	jbe    f01033c9 <vprintfmt+0x208>
					putch('?', putdat);
f01033bb:	83 ec 08             	sub    $0x8,%esp
f01033be:	57                   	push   %edi
f01033bf:	6a 3f                	push   $0x3f
f01033c1:	ff 55 08             	call   *0x8(%ebp)
f01033c4:	83 c4 10             	add    $0x10,%esp
f01033c7:	eb 0b                	jmp    f01033d4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01033c9:	83 ec 08             	sub    $0x8,%esp
f01033cc:	57                   	push   %edi
f01033cd:	50                   	push   %eax
f01033ce:	ff 55 08             	call   *0x8(%ebp)
f01033d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033d4:	ff 4d e4             	decl   -0x1c(%ebp)
f01033d7:	0f be 03             	movsbl (%ebx),%eax
f01033da:	85 c0                	test   %eax,%eax
f01033dc:	74 03                	je     f01033e1 <vprintfmt+0x220>
f01033de:	43                   	inc    %ebx
f01033df:	eb 1b                	jmp    f01033fc <vprintfmt+0x23b>
f01033e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01033e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01033e8:	7f 1e                	jg     f0103408 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01033ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01033ed:	e9 f3 fd ff ff       	jmp    f01031e5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01033f5:	43                   	inc    %ebx
f01033f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01033f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01033fc:	85 f6                	test   %esi,%esi
f01033fe:	78 ad                	js     f01033ad <vprintfmt+0x1ec>
f0103400:	4e                   	dec    %esi
f0103401:	79 aa                	jns    f01033ad <vprintfmt+0x1ec>
f0103403:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103406:	eb dc                	jmp    f01033e4 <vprintfmt+0x223>
f0103408:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010340b:	83 ec 08             	sub    $0x8,%esp
f010340e:	57                   	push   %edi
f010340f:	6a 20                	push   $0x20
f0103411:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103414:	4b                   	dec    %ebx
f0103415:	83 c4 10             	add    $0x10,%esp
f0103418:	85 db                	test   %ebx,%ebx
f010341a:	7f ef                	jg     f010340b <vprintfmt+0x24a>
f010341c:	e9 c4 fd ff ff       	jmp    f01031e5 <vprintfmt+0x24>
f0103421:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103424:	89 ca                	mov    %ecx,%edx
f0103426:	8d 45 14             	lea    0x14(%ebp),%eax
f0103429:	e8 2a fd ff ff       	call   f0103158 <getint>
f010342e:	89 c3                	mov    %eax,%ebx
f0103430:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103432:	85 d2                	test   %edx,%edx
f0103434:	78 0a                	js     f0103440 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103436:	b8 0a 00 00 00       	mov    $0xa,%eax
f010343b:	e9 b0 00 00 00       	jmp    f01034f0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103440:	83 ec 08             	sub    $0x8,%esp
f0103443:	57                   	push   %edi
f0103444:	6a 2d                	push   $0x2d
f0103446:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103449:	f7 db                	neg    %ebx
f010344b:	83 d6 00             	adc    $0x0,%esi
f010344e:	f7 de                	neg    %esi
f0103450:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103453:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103458:	e9 93 00 00 00       	jmp    f01034f0 <vprintfmt+0x32f>
f010345d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103460:	89 ca                	mov    %ecx,%edx
f0103462:	8d 45 14             	lea    0x14(%ebp),%eax
f0103465:	e8 b4 fc ff ff       	call   f010311e <getuint>
f010346a:	89 c3                	mov    %eax,%ebx
f010346c:	89 d6                	mov    %edx,%esi
			base = 10;
f010346e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103473:	eb 7b                	jmp    f01034f0 <vprintfmt+0x32f>
f0103475:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103478:	89 ca                	mov    %ecx,%edx
f010347a:	8d 45 14             	lea    0x14(%ebp),%eax
f010347d:	e8 d6 fc ff ff       	call   f0103158 <getint>
f0103482:	89 c3                	mov    %eax,%ebx
f0103484:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103486:	85 d2                	test   %edx,%edx
f0103488:	78 07                	js     f0103491 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f010348a:	b8 08 00 00 00       	mov    $0x8,%eax
f010348f:	eb 5f                	jmp    f01034f0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103491:	83 ec 08             	sub    $0x8,%esp
f0103494:	57                   	push   %edi
f0103495:	6a 2d                	push   $0x2d
f0103497:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f010349a:	f7 db                	neg    %ebx
f010349c:	83 d6 00             	adc    $0x0,%esi
f010349f:	f7 de                	neg    %esi
f01034a1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01034a4:	b8 08 00 00 00       	mov    $0x8,%eax
f01034a9:	eb 45                	jmp    f01034f0 <vprintfmt+0x32f>
f01034ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01034ae:	83 ec 08             	sub    $0x8,%esp
f01034b1:	57                   	push   %edi
f01034b2:	6a 30                	push   $0x30
f01034b4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01034b7:	83 c4 08             	add    $0x8,%esp
f01034ba:	57                   	push   %edi
f01034bb:	6a 78                	push   $0x78
f01034bd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01034c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01034c3:	8d 50 04             	lea    0x4(%eax),%edx
f01034c6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01034c9:	8b 18                	mov    (%eax),%ebx
f01034cb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01034d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01034d3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01034d8:	eb 16                	jmp    f01034f0 <vprintfmt+0x32f>
f01034da:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01034dd:	89 ca                	mov    %ecx,%edx
f01034df:	8d 45 14             	lea    0x14(%ebp),%eax
f01034e2:	e8 37 fc ff ff       	call   f010311e <getuint>
f01034e7:	89 c3                	mov    %eax,%ebx
f01034e9:	89 d6                	mov    %edx,%esi
			base = 16;
f01034eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01034f0:	83 ec 0c             	sub    $0xc,%esp
f01034f3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01034f7:	52                   	push   %edx
f01034f8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01034fb:	50                   	push   %eax
f01034fc:	56                   	push   %esi
f01034fd:	53                   	push   %ebx
f01034fe:	89 fa                	mov    %edi,%edx
f0103500:	8b 45 08             	mov    0x8(%ebp),%eax
f0103503:	e8 68 fb ff ff       	call   f0103070 <printnum>
			break;
f0103508:	83 c4 20             	add    $0x20,%esp
f010350b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010350e:	e9 d2 fc ff ff       	jmp    f01031e5 <vprintfmt+0x24>
f0103513:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103516:	83 ec 08             	sub    $0x8,%esp
f0103519:	57                   	push   %edi
f010351a:	52                   	push   %edx
f010351b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010351e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103521:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103524:	e9 bc fc ff ff       	jmp    f01031e5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103529:	83 ec 08             	sub    $0x8,%esp
f010352c:	57                   	push   %edi
f010352d:	6a 25                	push   $0x25
f010352f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103532:	83 c4 10             	add    $0x10,%esp
f0103535:	eb 02                	jmp    f0103539 <vprintfmt+0x378>
f0103537:	89 c6                	mov    %eax,%esi
f0103539:	8d 46 ff             	lea    -0x1(%esi),%eax
f010353c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103540:	75 f5                	jne    f0103537 <vprintfmt+0x376>
f0103542:	e9 9e fc ff ff       	jmp    f01031e5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103547:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010354a:	5b                   	pop    %ebx
f010354b:	5e                   	pop    %esi
f010354c:	5f                   	pop    %edi
f010354d:	c9                   	leave  
f010354e:	c3                   	ret    

f010354f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010354f:	55                   	push   %ebp
f0103550:	89 e5                	mov    %esp,%ebp
f0103552:	83 ec 18             	sub    $0x18,%esp
f0103555:	8b 45 08             	mov    0x8(%ebp),%eax
f0103558:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010355b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010355e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103562:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103565:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010356c:	85 c0                	test   %eax,%eax
f010356e:	74 26                	je     f0103596 <vsnprintf+0x47>
f0103570:	85 d2                	test   %edx,%edx
f0103572:	7e 29                	jle    f010359d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103574:	ff 75 14             	pushl  0x14(%ebp)
f0103577:	ff 75 10             	pushl  0x10(%ebp)
f010357a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010357d:	50                   	push   %eax
f010357e:	68 8a 31 10 f0       	push   $0xf010318a
f0103583:	e8 39 fc ff ff       	call   f01031c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103588:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010358b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010358e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103591:	83 c4 10             	add    $0x10,%esp
f0103594:	eb 0c                	jmp    f01035a2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103596:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010359b:	eb 05                	jmp    f01035a2 <vsnprintf+0x53>
f010359d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01035a2:	c9                   	leave  
f01035a3:	c3                   	ret    

f01035a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01035a4:	55                   	push   %ebp
f01035a5:	89 e5                	mov    %esp,%ebp
f01035a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01035aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01035ad:	50                   	push   %eax
f01035ae:	ff 75 10             	pushl  0x10(%ebp)
f01035b1:	ff 75 0c             	pushl  0xc(%ebp)
f01035b4:	ff 75 08             	pushl  0x8(%ebp)
f01035b7:	e8 93 ff ff ff       	call   f010354f <vsnprintf>
	va_end(ap);

	return rc;
}
f01035bc:	c9                   	leave  
f01035bd:	c3                   	ret    
	...

f01035c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01035c0:	55                   	push   %ebp
f01035c1:	89 e5                	mov    %esp,%ebp
f01035c3:	57                   	push   %edi
f01035c4:	56                   	push   %esi
f01035c5:	53                   	push   %ebx
f01035c6:	83 ec 0c             	sub    $0xc,%esp
f01035c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01035cc:	85 c0                	test   %eax,%eax
f01035ce:	74 11                	je     f01035e1 <readline+0x21>
		cprintf("%s", prompt);
f01035d0:	83 ec 08             	sub    $0x8,%esp
f01035d3:	50                   	push   %eax
f01035d4:	68 b0 4e 10 f0       	push   $0xf0104eb0
f01035d9:	e8 4b f7 ff ff       	call   f0102d29 <cprintf>
f01035de:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01035e1:	83 ec 0c             	sub    $0xc,%esp
f01035e4:	6a 00                	push   $0x0
f01035e6:	e8 dc cf ff ff       	call   f01005c7 <iscons>
f01035eb:	89 c7                	mov    %eax,%edi
f01035ed:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01035f0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01035f5:	e8 bc cf ff ff       	call   f01005b6 <getchar>
f01035fa:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01035fc:	85 c0                	test   %eax,%eax
f01035fe:	79 18                	jns    f0103618 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103600:	83 ec 08             	sub    $0x8,%esp
f0103603:	50                   	push   %eax
f0103604:	68 60 53 10 f0       	push   $0xf0105360
f0103609:	e8 1b f7 ff ff       	call   f0102d29 <cprintf>
			return NULL;
f010360e:	83 c4 10             	add    $0x10,%esp
f0103611:	b8 00 00 00 00       	mov    $0x0,%eax
f0103616:	eb 6f                	jmp    f0103687 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103618:	83 f8 08             	cmp    $0x8,%eax
f010361b:	74 05                	je     f0103622 <readline+0x62>
f010361d:	83 f8 7f             	cmp    $0x7f,%eax
f0103620:	75 18                	jne    f010363a <readline+0x7a>
f0103622:	85 f6                	test   %esi,%esi
f0103624:	7e 14                	jle    f010363a <readline+0x7a>
			if (echoing)
f0103626:	85 ff                	test   %edi,%edi
f0103628:	74 0d                	je     f0103637 <readline+0x77>
				cputchar('\b');
f010362a:	83 ec 0c             	sub    $0xc,%esp
f010362d:	6a 08                	push   $0x8
f010362f:	e8 72 cf ff ff       	call   f01005a6 <cputchar>
f0103634:	83 c4 10             	add    $0x10,%esp
			i--;
f0103637:	4e                   	dec    %esi
f0103638:	eb bb                	jmp    f01035f5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010363a:	83 fb 1f             	cmp    $0x1f,%ebx
f010363d:	7e 21                	jle    f0103660 <readline+0xa0>
f010363f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103645:	7f 19                	jg     f0103660 <readline+0xa0>
			if (echoing)
f0103647:	85 ff                	test   %edi,%edi
f0103649:	74 0c                	je     f0103657 <readline+0x97>
				cputchar(c);
f010364b:	83 ec 0c             	sub    $0xc,%esp
f010364e:	53                   	push   %ebx
f010364f:	e8 52 cf ff ff       	call   f01005a6 <cputchar>
f0103654:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103657:	88 9e 40 f5 11 f0    	mov    %bl,-0xfee0ac0(%esi)
f010365d:	46                   	inc    %esi
f010365e:	eb 95                	jmp    f01035f5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103660:	83 fb 0a             	cmp    $0xa,%ebx
f0103663:	74 05                	je     f010366a <readline+0xaa>
f0103665:	83 fb 0d             	cmp    $0xd,%ebx
f0103668:	75 8b                	jne    f01035f5 <readline+0x35>
			if (echoing)
f010366a:	85 ff                	test   %edi,%edi
f010366c:	74 0d                	je     f010367b <readline+0xbb>
				cputchar('\n');
f010366e:	83 ec 0c             	sub    $0xc,%esp
f0103671:	6a 0a                	push   $0xa
f0103673:	e8 2e cf ff ff       	call   f01005a6 <cputchar>
f0103678:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010367b:	c6 86 40 f5 11 f0 00 	movb   $0x0,-0xfee0ac0(%esi)
			return buf;
f0103682:	b8 40 f5 11 f0       	mov    $0xf011f540,%eax
		}
	}
}
f0103687:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010368a:	5b                   	pop    %ebx
f010368b:	5e                   	pop    %esi
f010368c:	5f                   	pop    %edi
f010368d:	c9                   	leave  
f010368e:	c3                   	ret    
	...

f0103690 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103690:	55                   	push   %ebp
f0103691:	89 e5                	mov    %esp,%ebp
f0103693:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103696:	80 3a 00             	cmpb   $0x0,(%edx)
f0103699:	74 0e                	je     f01036a9 <strlen+0x19>
f010369b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01036a0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01036a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01036a5:	75 f9                	jne    f01036a0 <strlen+0x10>
f01036a7:	eb 05                	jmp    f01036ae <strlen+0x1e>
f01036a9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01036ae:	c9                   	leave  
f01036af:	c3                   	ret    

f01036b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01036b0:	55                   	push   %ebp
f01036b1:	89 e5                	mov    %esp,%ebp
f01036b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036b9:	85 d2                	test   %edx,%edx
f01036bb:	74 17                	je     f01036d4 <strnlen+0x24>
f01036bd:	80 39 00             	cmpb   $0x0,(%ecx)
f01036c0:	74 19                	je     f01036db <strnlen+0x2b>
f01036c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01036c7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036c8:	39 d0                	cmp    %edx,%eax
f01036ca:	74 14                	je     f01036e0 <strnlen+0x30>
f01036cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01036d0:	75 f5                	jne    f01036c7 <strnlen+0x17>
f01036d2:	eb 0c                	jmp    f01036e0 <strnlen+0x30>
f01036d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01036d9:	eb 05                	jmp    f01036e0 <strnlen+0x30>
f01036db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01036e0:	c9                   	leave  
f01036e1:	c3                   	ret    

f01036e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01036e2:	55                   	push   %ebp
f01036e3:	89 e5                	mov    %esp,%ebp
f01036e5:	53                   	push   %ebx
f01036e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01036ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01036f1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01036f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01036f7:	42                   	inc    %edx
f01036f8:	84 c9                	test   %cl,%cl
f01036fa:	75 f5                	jne    f01036f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01036fc:	5b                   	pop    %ebx
f01036fd:	c9                   	leave  
f01036fe:	c3                   	ret    

f01036ff <strcat>:

char *
strcat(char *dst, const char *src)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	53                   	push   %ebx
f0103703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103706:	53                   	push   %ebx
f0103707:	e8 84 ff ff ff       	call   f0103690 <strlen>
f010370c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010370f:	ff 75 0c             	pushl  0xc(%ebp)
f0103712:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103715:	50                   	push   %eax
f0103716:	e8 c7 ff ff ff       	call   f01036e2 <strcpy>
	return dst;
}
f010371b:	89 d8                	mov    %ebx,%eax
f010371d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103720:	c9                   	leave  
f0103721:	c3                   	ret    

f0103722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103722:	55                   	push   %ebp
f0103723:	89 e5                	mov    %esp,%ebp
f0103725:	56                   	push   %esi
f0103726:	53                   	push   %ebx
f0103727:	8b 45 08             	mov    0x8(%ebp),%eax
f010372a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010372d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103730:	85 f6                	test   %esi,%esi
f0103732:	74 15                	je     f0103749 <strncpy+0x27>
f0103734:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103739:	8a 1a                	mov    (%edx),%bl
f010373b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010373e:	80 3a 01             	cmpb   $0x1,(%edx)
f0103741:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103744:	41                   	inc    %ecx
f0103745:	39 ce                	cmp    %ecx,%esi
f0103747:	77 f0                	ja     f0103739 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103749:	5b                   	pop    %ebx
f010374a:	5e                   	pop    %esi
f010374b:	c9                   	leave  
f010374c:	c3                   	ret    

f010374d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010374d:	55                   	push   %ebp
f010374e:	89 e5                	mov    %esp,%ebp
f0103750:	57                   	push   %edi
f0103751:	56                   	push   %esi
f0103752:	53                   	push   %ebx
f0103753:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103759:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010375c:	85 f6                	test   %esi,%esi
f010375e:	74 32                	je     f0103792 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103760:	83 fe 01             	cmp    $0x1,%esi
f0103763:	74 22                	je     f0103787 <strlcpy+0x3a>
f0103765:	8a 0b                	mov    (%ebx),%cl
f0103767:	84 c9                	test   %cl,%cl
f0103769:	74 20                	je     f010378b <strlcpy+0x3e>
f010376b:	89 f8                	mov    %edi,%eax
f010376d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103772:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103775:	88 08                	mov    %cl,(%eax)
f0103777:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103778:	39 f2                	cmp    %esi,%edx
f010377a:	74 11                	je     f010378d <strlcpy+0x40>
f010377c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103780:	42                   	inc    %edx
f0103781:	84 c9                	test   %cl,%cl
f0103783:	75 f0                	jne    f0103775 <strlcpy+0x28>
f0103785:	eb 06                	jmp    f010378d <strlcpy+0x40>
f0103787:	89 f8                	mov    %edi,%eax
f0103789:	eb 02                	jmp    f010378d <strlcpy+0x40>
f010378b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010378d:	c6 00 00             	movb   $0x0,(%eax)
f0103790:	eb 02                	jmp    f0103794 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103792:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103794:	29 f8                	sub    %edi,%eax
}
f0103796:	5b                   	pop    %ebx
f0103797:	5e                   	pop    %esi
f0103798:	5f                   	pop    %edi
f0103799:	c9                   	leave  
f010379a:	c3                   	ret    

f010379b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010379b:	55                   	push   %ebp
f010379c:	89 e5                	mov    %esp,%ebp
f010379e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01037a4:	8a 01                	mov    (%ecx),%al
f01037a6:	84 c0                	test   %al,%al
f01037a8:	74 10                	je     f01037ba <strcmp+0x1f>
f01037aa:	3a 02                	cmp    (%edx),%al
f01037ac:	75 0c                	jne    f01037ba <strcmp+0x1f>
		p++, q++;
f01037ae:	41                   	inc    %ecx
f01037af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01037b0:	8a 01                	mov    (%ecx),%al
f01037b2:	84 c0                	test   %al,%al
f01037b4:	74 04                	je     f01037ba <strcmp+0x1f>
f01037b6:	3a 02                	cmp    (%edx),%al
f01037b8:	74 f4                	je     f01037ae <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01037ba:	0f b6 c0             	movzbl %al,%eax
f01037bd:	0f b6 12             	movzbl (%edx),%edx
f01037c0:	29 d0                	sub    %edx,%eax
}
f01037c2:	c9                   	leave  
f01037c3:	c3                   	ret    

f01037c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01037c4:	55                   	push   %ebp
f01037c5:	89 e5                	mov    %esp,%ebp
f01037c7:	53                   	push   %ebx
f01037c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01037cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01037ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01037d1:	85 c0                	test   %eax,%eax
f01037d3:	74 1b                	je     f01037f0 <strncmp+0x2c>
f01037d5:	8a 1a                	mov    (%edx),%bl
f01037d7:	84 db                	test   %bl,%bl
f01037d9:	74 24                	je     f01037ff <strncmp+0x3b>
f01037db:	3a 19                	cmp    (%ecx),%bl
f01037dd:	75 20                	jne    f01037ff <strncmp+0x3b>
f01037df:	48                   	dec    %eax
f01037e0:	74 15                	je     f01037f7 <strncmp+0x33>
		n--, p++, q++;
f01037e2:	42                   	inc    %edx
f01037e3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01037e4:	8a 1a                	mov    (%edx),%bl
f01037e6:	84 db                	test   %bl,%bl
f01037e8:	74 15                	je     f01037ff <strncmp+0x3b>
f01037ea:	3a 19                	cmp    (%ecx),%bl
f01037ec:	74 f1                	je     f01037df <strncmp+0x1b>
f01037ee:	eb 0f                	jmp    f01037ff <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01037f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01037f5:	eb 05                	jmp    f01037fc <strncmp+0x38>
f01037f7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01037fc:	5b                   	pop    %ebx
f01037fd:	c9                   	leave  
f01037fe:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01037ff:	0f b6 02             	movzbl (%edx),%eax
f0103802:	0f b6 11             	movzbl (%ecx),%edx
f0103805:	29 d0                	sub    %edx,%eax
f0103807:	eb f3                	jmp    f01037fc <strncmp+0x38>

f0103809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103809:	55                   	push   %ebp
f010380a:	89 e5                	mov    %esp,%ebp
f010380c:	8b 45 08             	mov    0x8(%ebp),%eax
f010380f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103812:	8a 10                	mov    (%eax),%dl
f0103814:	84 d2                	test   %dl,%dl
f0103816:	74 18                	je     f0103830 <strchr+0x27>
		if (*s == c)
f0103818:	38 ca                	cmp    %cl,%dl
f010381a:	75 06                	jne    f0103822 <strchr+0x19>
f010381c:	eb 17                	jmp    f0103835 <strchr+0x2c>
f010381e:	38 ca                	cmp    %cl,%dl
f0103820:	74 13                	je     f0103835 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103822:	40                   	inc    %eax
f0103823:	8a 10                	mov    (%eax),%dl
f0103825:	84 d2                	test   %dl,%dl
f0103827:	75 f5                	jne    f010381e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103829:	b8 00 00 00 00       	mov    $0x0,%eax
f010382e:	eb 05                	jmp    f0103835 <strchr+0x2c>
f0103830:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103835:	c9                   	leave  
f0103836:	c3                   	ret    

f0103837 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103837:	55                   	push   %ebp
f0103838:	89 e5                	mov    %esp,%ebp
f010383a:	8b 45 08             	mov    0x8(%ebp),%eax
f010383d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103840:	8a 10                	mov    (%eax),%dl
f0103842:	84 d2                	test   %dl,%dl
f0103844:	74 11                	je     f0103857 <strfind+0x20>
		if (*s == c)
f0103846:	38 ca                	cmp    %cl,%dl
f0103848:	75 06                	jne    f0103850 <strfind+0x19>
f010384a:	eb 0b                	jmp    f0103857 <strfind+0x20>
f010384c:	38 ca                	cmp    %cl,%dl
f010384e:	74 07                	je     f0103857 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103850:	40                   	inc    %eax
f0103851:	8a 10                	mov    (%eax),%dl
f0103853:	84 d2                	test   %dl,%dl
f0103855:	75 f5                	jne    f010384c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103857:	c9                   	leave  
f0103858:	c3                   	ret    

f0103859 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103859:	55                   	push   %ebp
f010385a:	89 e5                	mov    %esp,%ebp
f010385c:	57                   	push   %edi
f010385d:	56                   	push   %esi
f010385e:	53                   	push   %ebx
f010385f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103862:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103868:	85 c9                	test   %ecx,%ecx
f010386a:	74 30                	je     f010389c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010386c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103872:	75 25                	jne    f0103899 <memset+0x40>
f0103874:	f6 c1 03             	test   $0x3,%cl
f0103877:	75 20                	jne    f0103899 <memset+0x40>
		c &= 0xFF;
f0103879:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010387c:	89 d3                	mov    %edx,%ebx
f010387e:	c1 e3 08             	shl    $0x8,%ebx
f0103881:	89 d6                	mov    %edx,%esi
f0103883:	c1 e6 18             	shl    $0x18,%esi
f0103886:	89 d0                	mov    %edx,%eax
f0103888:	c1 e0 10             	shl    $0x10,%eax
f010388b:	09 f0                	or     %esi,%eax
f010388d:	09 d0                	or     %edx,%eax
f010388f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103891:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103894:	fc                   	cld    
f0103895:	f3 ab                	rep stos %eax,%es:(%edi)
f0103897:	eb 03                	jmp    f010389c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103899:	fc                   	cld    
f010389a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010389c:	89 f8                	mov    %edi,%eax
f010389e:	5b                   	pop    %ebx
f010389f:	5e                   	pop    %esi
f01038a0:	5f                   	pop    %edi
f01038a1:	c9                   	leave  
f01038a2:	c3                   	ret    

f01038a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01038a3:	55                   	push   %ebp
f01038a4:	89 e5                	mov    %esp,%ebp
f01038a6:	57                   	push   %edi
f01038a7:	56                   	push   %esi
f01038a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038ab:	8b 75 0c             	mov    0xc(%ebp),%esi
f01038ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01038b1:	39 c6                	cmp    %eax,%esi
f01038b3:	73 34                	jae    f01038e9 <memmove+0x46>
f01038b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01038b8:	39 d0                	cmp    %edx,%eax
f01038ba:	73 2d                	jae    f01038e9 <memmove+0x46>
		s += n;
		d += n;
f01038bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01038bf:	f6 c2 03             	test   $0x3,%dl
f01038c2:	75 1b                	jne    f01038df <memmove+0x3c>
f01038c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01038ca:	75 13                	jne    f01038df <memmove+0x3c>
f01038cc:	f6 c1 03             	test   $0x3,%cl
f01038cf:	75 0e                	jne    f01038df <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01038d1:	83 ef 04             	sub    $0x4,%edi
f01038d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01038d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01038da:	fd                   	std    
f01038db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038dd:	eb 07                	jmp    f01038e6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01038df:	4f                   	dec    %edi
f01038e0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01038e3:	fd                   	std    
f01038e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01038e6:	fc                   	cld    
f01038e7:	eb 20                	jmp    f0103909 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01038e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01038ef:	75 13                	jne    f0103904 <memmove+0x61>
f01038f1:	a8 03                	test   $0x3,%al
f01038f3:	75 0f                	jne    f0103904 <memmove+0x61>
f01038f5:	f6 c1 03             	test   $0x3,%cl
f01038f8:	75 0a                	jne    f0103904 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01038fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01038fd:	89 c7                	mov    %eax,%edi
f01038ff:	fc                   	cld    
f0103900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103902:	eb 05                	jmp    f0103909 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103904:	89 c7                	mov    %eax,%edi
f0103906:	fc                   	cld    
f0103907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103909:	5e                   	pop    %esi
f010390a:	5f                   	pop    %edi
f010390b:	c9                   	leave  
f010390c:	c3                   	ret    

f010390d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010390d:	55                   	push   %ebp
f010390e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103910:	ff 75 10             	pushl  0x10(%ebp)
f0103913:	ff 75 0c             	pushl  0xc(%ebp)
f0103916:	ff 75 08             	pushl  0x8(%ebp)
f0103919:	e8 85 ff ff ff       	call   f01038a3 <memmove>
}
f010391e:	c9                   	leave  
f010391f:	c3                   	ret    

f0103920 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103920:	55                   	push   %ebp
f0103921:	89 e5                	mov    %esp,%ebp
f0103923:	57                   	push   %edi
f0103924:	56                   	push   %esi
f0103925:	53                   	push   %ebx
f0103926:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103929:	8b 75 0c             	mov    0xc(%ebp),%esi
f010392c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010392f:	85 ff                	test   %edi,%edi
f0103931:	74 32                	je     f0103965 <memcmp+0x45>
		if (*s1 != *s2)
f0103933:	8a 03                	mov    (%ebx),%al
f0103935:	8a 0e                	mov    (%esi),%cl
f0103937:	38 c8                	cmp    %cl,%al
f0103939:	74 19                	je     f0103954 <memcmp+0x34>
f010393b:	eb 0d                	jmp    f010394a <memcmp+0x2a>
f010393d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0103941:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0103945:	42                   	inc    %edx
f0103946:	38 c8                	cmp    %cl,%al
f0103948:	74 10                	je     f010395a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010394a:	0f b6 c0             	movzbl %al,%eax
f010394d:	0f b6 c9             	movzbl %cl,%ecx
f0103950:	29 c8                	sub    %ecx,%eax
f0103952:	eb 16                	jmp    f010396a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103954:	4f                   	dec    %edi
f0103955:	ba 00 00 00 00       	mov    $0x0,%edx
f010395a:	39 fa                	cmp    %edi,%edx
f010395c:	75 df                	jne    f010393d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010395e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103963:	eb 05                	jmp    f010396a <memcmp+0x4a>
f0103965:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010396a:	5b                   	pop    %ebx
f010396b:	5e                   	pop    %esi
f010396c:	5f                   	pop    %edi
f010396d:	c9                   	leave  
f010396e:	c3                   	ret    

f010396f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010396f:	55                   	push   %ebp
f0103970:	89 e5                	mov    %esp,%ebp
f0103972:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103975:	89 c2                	mov    %eax,%edx
f0103977:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010397a:	39 d0                	cmp    %edx,%eax
f010397c:	73 12                	jae    f0103990 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010397e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0103981:	38 08                	cmp    %cl,(%eax)
f0103983:	75 06                	jne    f010398b <memfind+0x1c>
f0103985:	eb 09                	jmp    f0103990 <memfind+0x21>
f0103987:	38 08                	cmp    %cl,(%eax)
f0103989:	74 05                	je     f0103990 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010398b:	40                   	inc    %eax
f010398c:	39 c2                	cmp    %eax,%edx
f010398e:	77 f7                	ja     f0103987 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103990:	c9                   	leave  
f0103991:	c3                   	ret    

f0103992 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103992:	55                   	push   %ebp
f0103993:	89 e5                	mov    %esp,%ebp
f0103995:	57                   	push   %edi
f0103996:	56                   	push   %esi
f0103997:	53                   	push   %ebx
f0103998:	8b 55 08             	mov    0x8(%ebp),%edx
f010399b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010399e:	eb 01                	jmp    f01039a1 <strtol+0xf>
		s++;
f01039a0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01039a1:	8a 02                	mov    (%edx),%al
f01039a3:	3c 20                	cmp    $0x20,%al
f01039a5:	74 f9                	je     f01039a0 <strtol+0xe>
f01039a7:	3c 09                	cmp    $0x9,%al
f01039a9:	74 f5                	je     f01039a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01039ab:	3c 2b                	cmp    $0x2b,%al
f01039ad:	75 08                	jne    f01039b7 <strtol+0x25>
		s++;
f01039af:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01039b0:	bf 00 00 00 00       	mov    $0x0,%edi
f01039b5:	eb 13                	jmp    f01039ca <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01039b7:	3c 2d                	cmp    $0x2d,%al
f01039b9:	75 0a                	jne    f01039c5 <strtol+0x33>
		s++, neg = 1;
f01039bb:	8d 52 01             	lea    0x1(%edx),%edx
f01039be:	bf 01 00 00 00       	mov    $0x1,%edi
f01039c3:	eb 05                	jmp    f01039ca <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01039c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01039ca:	85 db                	test   %ebx,%ebx
f01039cc:	74 05                	je     f01039d3 <strtol+0x41>
f01039ce:	83 fb 10             	cmp    $0x10,%ebx
f01039d1:	75 28                	jne    f01039fb <strtol+0x69>
f01039d3:	8a 02                	mov    (%edx),%al
f01039d5:	3c 30                	cmp    $0x30,%al
f01039d7:	75 10                	jne    f01039e9 <strtol+0x57>
f01039d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01039dd:	75 0a                	jne    f01039e9 <strtol+0x57>
		s += 2, base = 16;
f01039df:	83 c2 02             	add    $0x2,%edx
f01039e2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01039e7:	eb 12                	jmp    f01039fb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01039e9:	85 db                	test   %ebx,%ebx
f01039eb:	75 0e                	jne    f01039fb <strtol+0x69>
f01039ed:	3c 30                	cmp    $0x30,%al
f01039ef:	75 05                	jne    f01039f6 <strtol+0x64>
		s++, base = 8;
f01039f1:	42                   	inc    %edx
f01039f2:	b3 08                	mov    $0x8,%bl
f01039f4:	eb 05                	jmp    f01039fb <strtol+0x69>
	else if (base == 0)
		base = 10;
f01039f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01039fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103a02:	8a 0a                	mov    (%edx),%cl
f0103a04:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103a07:	80 fb 09             	cmp    $0x9,%bl
f0103a0a:	77 08                	ja     f0103a14 <strtol+0x82>
			dig = *s - '0';
f0103a0c:	0f be c9             	movsbl %cl,%ecx
f0103a0f:	83 e9 30             	sub    $0x30,%ecx
f0103a12:	eb 1e                	jmp    f0103a32 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0103a14:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103a17:	80 fb 19             	cmp    $0x19,%bl
f0103a1a:	77 08                	ja     f0103a24 <strtol+0x92>
			dig = *s - 'a' + 10;
f0103a1c:	0f be c9             	movsbl %cl,%ecx
f0103a1f:	83 e9 57             	sub    $0x57,%ecx
f0103a22:	eb 0e                	jmp    f0103a32 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0103a24:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103a27:	80 fb 19             	cmp    $0x19,%bl
f0103a2a:	77 13                	ja     f0103a3f <strtol+0xad>
			dig = *s - 'A' + 10;
f0103a2c:	0f be c9             	movsbl %cl,%ecx
f0103a2f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103a32:	39 f1                	cmp    %esi,%ecx
f0103a34:	7d 0d                	jge    f0103a43 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0103a36:	42                   	inc    %edx
f0103a37:	0f af c6             	imul   %esi,%eax
f0103a3a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103a3d:	eb c3                	jmp    f0103a02 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103a3f:	89 c1                	mov    %eax,%ecx
f0103a41:	eb 02                	jmp    f0103a45 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103a43:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103a49:	74 05                	je     f0103a50 <strtol+0xbe>
		*endptr = (char *) s;
f0103a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a4e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103a50:	85 ff                	test   %edi,%edi
f0103a52:	74 04                	je     f0103a58 <strtol+0xc6>
f0103a54:	89 c8                	mov    %ecx,%eax
f0103a56:	f7 d8                	neg    %eax
}
f0103a58:	5b                   	pop    %ebx
f0103a59:	5e                   	pop    %esi
f0103a5a:	5f                   	pop    %edi
f0103a5b:	c9                   	leave  
f0103a5c:	c3                   	ret    
f0103a5d:	00 00                	add    %al,(%eax)
	...

f0103a60 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103a60:	55                   	push   %ebp
f0103a61:	89 e5                	mov    %esp,%ebp
f0103a63:	57                   	push   %edi
f0103a64:	56                   	push   %esi
f0103a65:	83 ec 10             	sub    $0x10,%esp
f0103a68:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103a6e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103a74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103a77:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103a7a:	85 c0                	test   %eax,%eax
f0103a7c:	75 2e                	jne    f0103aac <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0103a7e:	39 f1                	cmp    %esi,%ecx
f0103a80:	77 5a                	ja     f0103adc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103a82:	85 c9                	test   %ecx,%ecx
f0103a84:	75 0b                	jne    f0103a91 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103a86:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a8b:	31 d2                	xor    %edx,%edx
f0103a8d:	f7 f1                	div    %ecx
f0103a8f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103a91:	31 d2                	xor    %edx,%edx
f0103a93:	89 f0                	mov    %esi,%eax
f0103a95:	f7 f1                	div    %ecx
f0103a97:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a99:	89 f8                	mov    %edi,%eax
f0103a9b:	f7 f1                	div    %ecx
f0103a9d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a9f:	89 f8                	mov    %edi,%eax
f0103aa1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103aa3:	83 c4 10             	add    $0x10,%esp
f0103aa6:	5e                   	pop    %esi
f0103aa7:	5f                   	pop    %edi
f0103aa8:	c9                   	leave  
f0103aa9:	c3                   	ret    
f0103aaa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103aac:	39 f0                	cmp    %esi,%eax
f0103aae:	77 1c                	ja     f0103acc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103ab0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0103ab3:	83 f7 1f             	xor    $0x1f,%edi
f0103ab6:	75 3c                	jne    f0103af4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103ab8:	39 f0                	cmp    %esi,%eax
f0103aba:	0f 82 90 00 00 00    	jb     f0103b50 <__udivdi3+0xf0>
f0103ac0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ac3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0103ac6:	0f 86 84 00 00 00    	jbe    f0103b50 <__udivdi3+0xf0>
f0103acc:	31 f6                	xor    %esi,%esi
f0103ace:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103ad0:	89 f8                	mov    %edi,%eax
f0103ad2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103ad4:	83 c4 10             	add    $0x10,%esp
f0103ad7:	5e                   	pop    %esi
f0103ad8:	5f                   	pop    %edi
f0103ad9:	c9                   	leave  
f0103ada:	c3                   	ret    
f0103adb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103adc:	89 f2                	mov    %esi,%edx
f0103ade:	89 f8                	mov    %edi,%eax
f0103ae0:	f7 f1                	div    %ecx
f0103ae2:	89 c7                	mov    %eax,%edi
f0103ae4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103ae6:	89 f8                	mov    %edi,%eax
f0103ae8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103aea:	83 c4 10             	add    $0x10,%esp
f0103aed:	5e                   	pop    %esi
f0103aee:	5f                   	pop    %edi
f0103aef:	c9                   	leave  
f0103af0:	c3                   	ret    
f0103af1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103af4:	89 f9                	mov    %edi,%ecx
f0103af6:	d3 e0                	shl    %cl,%eax
f0103af8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103afb:	b8 20 00 00 00       	mov    $0x20,%eax
f0103b00:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103b02:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b05:	88 c1                	mov    %al,%cl
f0103b07:	d3 ea                	shr    %cl,%edx
f0103b09:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b0c:	09 ca                	or     %ecx,%edx
f0103b0e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0103b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b14:	89 f9                	mov    %edi,%ecx
f0103b16:	d3 e2                	shl    %cl,%edx
f0103b18:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0103b1b:	89 f2                	mov    %esi,%edx
f0103b1d:	88 c1                	mov    %al,%cl
f0103b1f:	d3 ea                	shr    %cl,%edx
f0103b21:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103b24:	89 f2                	mov    %esi,%edx
f0103b26:	89 f9                	mov    %edi,%ecx
f0103b28:	d3 e2                	shl    %cl,%edx
f0103b2a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103b2d:	88 c1                	mov    %al,%cl
f0103b2f:	d3 ee                	shr    %cl,%esi
f0103b31:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103b33:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b36:	89 f0                	mov    %esi,%eax
f0103b38:	89 ca                	mov    %ecx,%edx
f0103b3a:	f7 75 ec             	divl   -0x14(%ebp)
f0103b3d:	89 d1                	mov    %edx,%ecx
f0103b3f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103b41:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b44:	39 d1                	cmp    %edx,%ecx
f0103b46:	72 28                	jb     f0103b70 <__udivdi3+0x110>
f0103b48:	74 1a                	je     f0103b64 <__udivdi3+0x104>
f0103b4a:	89 f7                	mov    %esi,%edi
f0103b4c:	31 f6                	xor    %esi,%esi
f0103b4e:	eb 80                	jmp    f0103ad0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103b50:	31 f6                	xor    %esi,%esi
f0103b52:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103b57:	89 f8                	mov    %edi,%eax
f0103b59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103b5b:	83 c4 10             	add    $0x10,%esp
f0103b5e:	5e                   	pop    %esi
f0103b5f:	5f                   	pop    %edi
f0103b60:	c9                   	leave  
f0103b61:	c3                   	ret    
f0103b62:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103b64:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b67:	89 f9                	mov    %edi,%ecx
f0103b69:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b6b:	39 c2                	cmp    %eax,%edx
f0103b6d:	73 db                	jae    f0103b4a <__udivdi3+0xea>
f0103b6f:	90                   	nop
		{
		  q0--;
f0103b70:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103b73:	31 f6                	xor    %esi,%esi
f0103b75:	e9 56 ff ff ff       	jmp    f0103ad0 <__udivdi3+0x70>
	...

f0103b7c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103b7c:	55                   	push   %ebp
f0103b7d:	89 e5                	mov    %esp,%ebp
f0103b7f:	57                   	push   %edi
f0103b80:	56                   	push   %esi
f0103b81:	83 ec 20             	sub    $0x20,%esp
f0103b84:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b87:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103b8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103b90:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103b99:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103b9b:	85 ff                	test   %edi,%edi
f0103b9d:	75 15                	jne    f0103bb4 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103b9f:	39 f1                	cmp    %esi,%ecx
f0103ba1:	0f 86 99 00 00 00    	jbe    f0103c40 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103ba7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103ba9:	89 d0                	mov    %edx,%eax
f0103bab:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103bad:	83 c4 20             	add    $0x20,%esp
f0103bb0:	5e                   	pop    %esi
f0103bb1:	5f                   	pop    %edi
f0103bb2:	c9                   	leave  
f0103bb3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103bb4:	39 f7                	cmp    %esi,%edi
f0103bb6:	0f 87 a4 00 00 00    	ja     f0103c60 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103bbc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103bbf:	83 f0 1f             	xor    $0x1f,%eax
f0103bc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103bc5:	0f 84 a1 00 00 00    	je     f0103c6c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103bcb:	89 f8                	mov    %edi,%eax
f0103bcd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103bd0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103bd2:	bf 20 00 00 00       	mov    $0x20,%edi
f0103bd7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103bdd:	89 f9                	mov    %edi,%ecx
f0103bdf:	d3 ea                	shr    %cl,%edx
f0103be1:	09 c2                	or     %eax,%edx
f0103be3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103be9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103bec:	d3 e0                	shl    %cl,%eax
f0103bee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103bf1:	89 f2                	mov    %esi,%edx
f0103bf3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103bf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103bf8:	d3 e0                	shl    %cl,%eax
f0103bfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103c00:	89 f9                	mov    %edi,%ecx
f0103c02:	d3 e8                	shr    %cl,%eax
f0103c04:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103c06:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103c08:	89 f2                	mov    %esi,%edx
f0103c0a:	f7 75 f0             	divl   -0x10(%ebp)
f0103c0d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103c0f:	f7 65 f4             	mull   -0xc(%ebp)
f0103c12:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103c15:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103c17:	39 d6                	cmp    %edx,%esi
f0103c19:	72 71                	jb     f0103c8c <__umoddi3+0x110>
f0103c1b:	74 7f                	je     f0103c9c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103c1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c20:	29 c8                	sub    %ecx,%eax
f0103c22:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103c24:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c27:	d3 e8                	shr    %cl,%eax
f0103c29:	89 f2                	mov    %esi,%edx
f0103c2b:	89 f9                	mov    %edi,%ecx
f0103c2d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103c2f:	09 d0                	or     %edx,%eax
f0103c31:	89 f2                	mov    %esi,%edx
f0103c33:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103c36:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c38:	83 c4 20             	add    $0x20,%esp
f0103c3b:	5e                   	pop    %esi
f0103c3c:	5f                   	pop    %edi
f0103c3d:	c9                   	leave  
f0103c3e:	c3                   	ret    
f0103c3f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103c40:	85 c9                	test   %ecx,%ecx
f0103c42:	75 0b                	jne    f0103c4f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103c44:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c49:	31 d2                	xor    %edx,%edx
f0103c4b:	f7 f1                	div    %ecx
f0103c4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103c4f:	89 f0                	mov    %esi,%eax
f0103c51:	31 d2                	xor    %edx,%edx
f0103c53:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c58:	f7 f1                	div    %ecx
f0103c5a:	e9 4a ff ff ff       	jmp    f0103ba9 <__umoddi3+0x2d>
f0103c5f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103c60:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c62:	83 c4 20             	add    $0x20,%esp
f0103c65:	5e                   	pop    %esi
f0103c66:	5f                   	pop    %edi
f0103c67:	c9                   	leave  
f0103c68:	c3                   	ret    
f0103c69:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103c6c:	39 f7                	cmp    %esi,%edi
f0103c6e:	72 05                	jb     f0103c75 <__umoddi3+0xf9>
f0103c70:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103c73:	77 0c                	ja     f0103c81 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103c75:	89 f2                	mov    %esi,%edx
f0103c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103c7a:	29 c8                	sub    %ecx,%eax
f0103c7c:	19 fa                	sbb    %edi,%edx
f0103c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c84:	83 c4 20             	add    $0x20,%esp
f0103c87:	5e                   	pop    %esi
f0103c88:	5f                   	pop    %edi
f0103c89:	c9                   	leave  
f0103c8a:	c3                   	ret    
f0103c8b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103c8c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103c8f:	89 c1                	mov    %eax,%ecx
f0103c91:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103c94:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103c97:	eb 84                	jmp    f0103c1d <__umoddi3+0xa1>
f0103c99:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103c9c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103c9f:	72 eb                	jb     f0103c8c <__umoddi3+0x110>
f0103ca1:	89 f2                	mov    %esi,%edx
f0103ca3:	e9 75 ff ff ff       	jmp    f0103c1d <__umoddi3+0xa1>
