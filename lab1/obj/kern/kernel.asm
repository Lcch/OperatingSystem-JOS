
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 a0 19 10 f0       	push   $0xf01019a0
f0100050:	e8 bc 09 00 00       	call   f0100a11 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 a6 07 00 00       	call   f0100821 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 bc 19 10 f0       	push   $0xf01019bc
f0100087:	e8 85 09 00 00       	call   f0100a11 <cprintf>
f010008c:	83 c4 10             	add    $0x10,%esp
}
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char * edata, * end;

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	a1 00 83 11 f0       	mov    0xf0118300,%eax
f010009f:	8b 15 44 89 11 f0    	mov    0xf0118944,%edx
f01000a5:	29 c2                	sub    %eax,%edx
f01000a7:	52                   	push   %edx
f01000a8:	6a 00                	push   $0x0
f01000aa:	50                   	push   %eax
f01000ab:	e8 91 14 00 00       	call   f0101541 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b0:	e8 6e 04 00 00       	call   f0100523 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b5:	83 c4 08             	add    $0x8,%esp
f01000b8:	68 ac 1a 00 00       	push   $0x1aac
f01000bd:	68 d7 19 10 f0       	push   $0xf01019d7
f01000c2:	e8 4a 09 00 00       	call   f0100a11 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ce:	e8 6d ff ff ff       	call   f0100040 <test_backtrace>
f01000d3:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d6:	83 ec 0c             	sub    $0xc,%esp
f01000d9:	6a 00                	push   $0x0
f01000db:	e8 cc 07 00 00       	call   f01008ac <monitor>
f01000e0:	83 c4 10             	add    $0x10,%esp
f01000e3:	eb f1                	jmp    f01000d6 <i386_init+0x42>

f01000e5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e5:	55                   	push   %ebp
f01000e6:	89 e5                	mov    %esp,%ebp
f01000e8:	56                   	push   %esi
f01000e9:	53                   	push   %ebx
f01000ea:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ed:	83 3d 40 89 11 f0 00 	cmpl   $0x0,0xf0118940
f01000f4:	75 37                	jne    f010012d <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f6:	89 35 40 89 11 f0    	mov    %esi,0xf0118940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fc:	fa                   	cli    
f01000fd:	fc                   	cld    

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100101:	83 ec 04             	sub    $0x4,%esp
f0100104:	ff 75 0c             	pushl  0xc(%ebp)
f0100107:	ff 75 08             	pushl  0x8(%ebp)
f010010a:	68 f2 19 10 f0       	push   $0xf01019f2
f010010f:	e8 fd 08 00 00       	call   f0100a11 <cprintf>
	vcprintf(fmt, ap);
f0100114:	83 c4 08             	add    $0x8,%esp
f0100117:	53                   	push   %ebx
f0100118:	56                   	push   %esi
f0100119:	e8 cd 08 00 00       	call   f01009eb <vcprintf>
	cprintf("\n");
f010011e:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100125:	e8 e7 08 00 00       	call   f0100a11 <cprintf>
	va_end(ap);
f010012a:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012d:	83 ec 0c             	sub    $0xc,%esp
f0100130:	6a 00                	push   $0x0
f0100132:	e8 75 07 00 00       	call   f01008ac <monitor>
f0100137:	83 c4 10             	add    $0x10,%esp
f010013a:	eb f1                	jmp    f010012d <_panic+0x48>

f010013c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013c:	55                   	push   %ebp
f010013d:	89 e5                	mov    %esp,%ebp
f010013f:	53                   	push   %ebx
f0100140:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100143:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100146:	ff 75 0c             	pushl  0xc(%ebp)
f0100149:	ff 75 08             	pushl  0x8(%ebp)
f010014c:	68 0a 1a 10 f0       	push   $0xf0101a0a
f0100151:	e8 bb 08 00 00       	call   f0100a11 <cprintf>
	vcprintf(fmt, ap);
f0100156:	83 c4 08             	add    $0x8,%esp
f0100159:	53                   	push   %ebx
f010015a:	ff 75 10             	pushl  0x10(%ebp)
f010015d:	e8 89 08 00 00       	call   f01009eb <vcprintf>
	cprintf("\n");
f0100162:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100169:	e8 a3 08 00 00       	call   f0100a11 <cprintf>
	va_end(ap);
f010016e:	83 c4 10             	add    $0x10,%esp
}
f0100171:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100174:	c9                   	leave  
f0100175:	c3                   	ret    
	...

f0100178 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100178:	55                   	push   %ebp
f0100179:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100180:	ec                   	in     (%dx),%al
f0100181:	ec                   	in     (%dx),%al
f0100182:	ec                   	in     (%dx),%al
f0100183:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100184:	c9                   	leave  
f0100185:	c3                   	ret    

f0100186 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100186:	55                   	push   %ebp
f0100187:	89 e5                	mov    %esp,%ebp
f0100189:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010018e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018f:	a8 01                	test   $0x1,%al
f0100191:	74 08                	je     f010019b <serial_proc_data+0x15>
f0100193:	b2 f8                	mov    $0xf8,%dl
f0100195:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100196:	0f b6 c0             	movzbl %al,%eax
f0100199:	eb 05                	jmp    f01001a0 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010019b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a0:	c9                   	leave  
f01001a1:	c3                   	ret    

f01001a2 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a2:	55                   	push   %ebp
f01001a3:	89 e5                	mov    %esp,%ebp
f01001a5:	53                   	push   %ebx
f01001a6:	83 ec 04             	sub    $0x4,%esp
f01001a9:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001ab:	eb 29                	jmp    f01001d6 <cons_intr+0x34>
		if (c == 0)
f01001ad:	85 c0                	test   %eax,%eax
f01001af:	74 25                	je     f01001d6 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b1:	8b 15 24 85 11 f0    	mov    0xf0118524,%edx
f01001b7:	88 82 20 83 11 f0    	mov    %al,-0xfee7ce0(%edx)
f01001bd:	8d 42 01             	lea    0x1(%edx),%eax
f01001c0:	a3 24 85 11 f0       	mov    %eax,0xf0118524
		if (cons.wpos == CONSBUFSIZE)
f01001c5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ca:	75 0a                	jne    f01001d6 <cons_intr+0x34>
			cons.wpos = 0;
f01001cc:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
f01001d3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d6:	ff d3                	call   *%ebx
f01001d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001db:	75 d0                	jne    f01001ad <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001dd:	83 c4 04             	add    $0x4,%esp
f01001e0:	5b                   	pop    %ebx
f01001e1:	c9                   	leave  
f01001e2:	c3                   	ret    

f01001e3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001e3:	55                   	push   %ebp
f01001e4:	89 e5                	mov    %esp,%ebp
f01001e6:	57                   	push   %edi
f01001e7:	56                   	push   %esi
f01001e8:	53                   	push   %ebx
f01001e9:	83 ec 0c             	sub    $0xc,%esp
f01001ec:	89 c6                	mov    %eax,%esi
f01001ee:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001f3:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001f4:	a8 20                	test   $0x20,%al
f01001f6:	75 19                	jne    f0100211 <cons_putc+0x2e>
f01001f8:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001fd:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100202:	e8 71 ff ff ff       	call   f0100178 <delay>
f0100207:	89 fa                	mov    %edi,%edx
f0100209:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010020a:	a8 20                	test   $0x20,%al
f010020c:	75 03                	jne    f0100211 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010020e:	4b                   	dec    %ebx
f010020f:	75 f1                	jne    f0100202 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100211:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100213:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100218:	89 f0                	mov    %esi,%eax
f010021a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010021b:	b2 79                	mov    $0x79,%dl
f010021d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010021e:	84 c0                	test   %al,%al
f0100220:	78 1d                	js     f010023f <cons_putc+0x5c>
f0100222:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f0100227:	e8 4c ff ff ff       	call   f0100178 <delay>
f010022c:	ba 79 03 00 00       	mov    $0x379,%edx
f0100231:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100232:	84 c0                	test   %al,%al
f0100234:	78 09                	js     f010023f <cons_putc+0x5c>
f0100236:	43                   	inc    %ebx
f0100237:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010023d:	75 e8                	jne    f0100227 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010023f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100244:	89 f8                	mov    %edi,%eax
f0100246:	ee                   	out    %al,(%dx)
f0100247:	b2 7a                	mov    $0x7a,%dl
f0100249:	b0 0d                	mov    $0xd,%al
f010024b:	ee                   	out    %al,(%dx)
f010024c:	b0 08                	mov    $0x8,%al
f010024e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f010024f:	a1 00 83 11 f0       	mov    0xf0118300,%eax
f0100254:	c1 e0 08             	shl    $0x8,%eax
f0100257:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100259:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010025f:	75 06                	jne    f0100267 <cons_putc+0x84>
		c |= 0x0700;
f0100261:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100267:	89 f0                	mov    %esi,%eax
f0100269:	25 ff 00 00 00       	and    $0xff,%eax
f010026e:	83 f8 09             	cmp    $0x9,%eax
f0100271:	74 78                	je     f01002eb <cons_putc+0x108>
f0100273:	83 f8 09             	cmp    $0x9,%eax
f0100276:	7f 0b                	jg     f0100283 <cons_putc+0xa0>
f0100278:	83 f8 08             	cmp    $0x8,%eax
f010027b:	0f 85 9e 00 00 00    	jne    f010031f <cons_putc+0x13c>
f0100281:	eb 10                	jmp    f0100293 <cons_putc+0xb0>
f0100283:	83 f8 0a             	cmp    $0xa,%eax
f0100286:	74 39                	je     f01002c1 <cons_putc+0xde>
f0100288:	83 f8 0d             	cmp    $0xd,%eax
f010028b:	0f 85 8e 00 00 00    	jne    f010031f <cons_putc+0x13c>
f0100291:	eb 36                	jmp    f01002c9 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100293:	66 a1 04 83 11 f0    	mov    0xf0118304,%ax
f0100299:	66 85 c0             	test   %ax,%ax
f010029c:	0f 84 e0 00 00 00    	je     f0100382 <cons_putc+0x19f>
			crt_pos--;
f01002a2:	48                   	dec    %eax
f01002a3:	66 a3 04 83 11 f0    	mov    %ax,0xf0118304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002a9:	0f b7 c0             	movzwl %ax,%eax
f01002ac:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002b2:	83 ce 20             	or     $0x20,%esi
f01002b5:	8b 15 08 83 11 f0    	mov    0xf0118308,%edx
f01002bb:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002bf:	eb 78                	jmp    f0100339 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002c1:	66 83 05 04 83 11 f0 	addw   $0x50,0xf0118304
f01002c8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002c9:	66 8b 0d 04 83 11 f0 	mov    0xf0118304,%cx
f01002d0:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002d5:	89 c8                	mov    %ecx,%eax
f01002d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01002dc:	66 f7 f3             	div    %bx
f01002df:	66 29 d1             	sub    %dx,%cx
f01002e2:	66 89 0d 04 83 11 f0 	mov    %cx,0xf0118304
f01002e9:	eb 4e                	jmp    f0100339 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f0:	e8 ee fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f01002f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fa:	e8 e4 fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f01002ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0100304:	e8 da fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f0100309:	b8 20 00 00 00       	mov    $0x20,%eax
f010030e:	e8 d0 fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f0100313:	b8 20 00 00 00       	mov    $0x20,%eax
f0100318:	e8 c6 fe ff ff       	call   f01001e3 <cons_putc>
f010031d:	eb 1a                	jmp    f0100339 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010031f:	66 a1 04 83 11 f0    	mov    0xf0118304,%ax
f0100325:	0f b7 c8             	movzwl %ax,%ecx
f0100328:	8b 15 08 83 11 f0    	mov    0xf0118308,%edx
f010032e:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100332:	40                   	inc    %eax
f0100333:	66 a3 04 83 11 f0    	mov    %ax,0xf0118304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f0100339:	66 81 3d 04 83 11 f0 	cmpw   $0x7cf,0xf0118304
f0100340:	cf 07 
f0100342:	76 3e                	jbe    f0100382 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100344:	a1 08 83 11 f0       	mov    0xf0118308,%eax
f0100349:	83 ec 04             	sub    $0x4,%esp
f010034c:	68 00 0f 00 00       	push   $0xf00
f0100351:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100357:	52                   	push   %edx
f0100358:	50                   	push   %eax
f0100359:	e8 2d 12 00 00       	call   f010158b <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010035e:	8b 15 08 83 11 f0    	mov    0xf0118308,%edx
f0100364:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100367:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010036c:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100372:	40                   	inc    %eax
f0100373:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100378:	75 f2                	jne    f010036c <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010037a:	66 83 2d 04 83 11 f0 	subw   $0x50,0xf0118304
f0100381:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100382:	8b 0d 0c 83 11 f0    	mov    0xf011830c,%ecx
f0100388:	b0 0e                	mov    $0xe,%al
f010038a:	89 ca                	mov    %ecx,%edx
f010038c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010038d:	66 8b 35 04 83 11 f0 	mov    0xf0118304,%si
f0100394:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100397:	89 f0                	mov    %esi,%eax
f0100399:	66 c1 e8 08          	shr    $0x8,%ax
f010039d:	89 da                	mov    %ebx,%edx
f010039f:	ee                   	out    %al,(%dx)
f01003a0:	b0 0f                	mov    $0xf,%al
f01003a2:	89 ca                	mov    %ecx,%edx
f01003a4:	ee                   	out    %al,(%dx)
f01003a5:	89 f0                	mov    %esi,%eax
f01003a7:	89 da                	mov    %ebx,%edx
f01003a9:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003ad:	5b                   	pop    %ebx
f01003ae:	5e                   	pop    %esi
f01003af:	5f                   	pop    %edi
f01003b0:	c9                   	leave  
f01003b1:	c3                   	ret    

f01003b2 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003b2:	55                   	push   %ebp
f01003b3:	89 e5                	mov    %esp,%ebp
f01003b5:	53                   	push   %ebx
f01003b6:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b9:	ba 64 00 00 00       	mov    $0x64,%edx
f01003be:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003bf:	a8 01                	test   $0x1,%al
f01003c1:	0f 84 dc 00 00 00    	je     f01004a3 <kbd_proc_data+0xf1>
f01003c7:	b2 60                	mov    $0x60,%dl
f01003c9:	ec                   	in     (%dx),%al
f01003ca:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003cc:	3c e0                	cmp    $0xe0,%al
f01003ce:	75 11                	jne    f01003e1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003d0:	83 0d 28 85 11 f0 40 	orl    $0x40,0xf0118528
		return 0;
f01003d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003dc:	e9 c7 00 00 00       	jmp    f01004a8 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003e1:	84 c0                	test   %al,%al
f01003e3:	79 33                	jns    f0100418 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003e5:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f01003eb:	f6 c1 40             	test   $0x40,%cl
f01003ee:	75 05                	jne    f01003f5 <kbd_proc_data+0x43>
f01003f0:	88 c2                	mov    %al,%dl
f01003f2:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003f5:	0f b6 d2             	movzbl %dl,%edx
f01003f8:	8a 82 60 1a 10 f0    	mov    -0xfefe5a0(%edx),%al
f01003fe:	83 c8 40             	or     $0x40,%eax
f0100401:	0f b6 c0             	movzbl %al,%eax
f0100404:	f7 d0                	not    %eax
f0100406:	21 c1                	and    %eax,%ecx
f0100408:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
		return 0;
f010040e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100413:	e9 90 00 00 00       	jmp    f01004a8 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100418:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f010041e:	f6 c1 40             	test   $0x40,%cl
f0100421:	74 0e                	je     f0100431 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100423:	88 c2                	mov    %al,%dl
f0100425:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100428:	83 e1 bf             	and    $0xffffffbf,%ecx
f010042b:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
	}

	shift |= shiftcode[data];
f0100431:	0f b6 d2             	movzbl %dl,%edx
f0100434:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f010043b:	0b 05 28 85 11 f0    	or     0xf0118528,%eax
	shift ^= togglecode[data];
f0100441:	0f b6 8a 60 1b 10 f0 	movzbl -0xfefe4a0(%edx),%ecx
f0100448:	31 c8                	xor    %ecx,%eax
f010044a:	a3 28 85 11 f0       	mov    %eax,0xf0118528

	c = charcode[shift & (CTL | SHIFT)][data];
f010044f:	89 c1                	mov    %eax,%ecx
f0100451:	83 e1 03             	and    $0x3,%ecx
f0100454:	8b 0c 8d 60 1c 10 f0 	mov    -0xfefe3a0(,%ecx,4),%ecx
f010045b:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010045f:	a8 08                	test   $0x8,%al
f0100461:	74 18                	je     f010047b <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100463:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100466:	83 fa 19             	cmp    $0x19,%edx
f0100469:	77 05                	ja     f0100470 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010046b:	83 eb 20             	sub    $0x20,%ebx
f010046e:	eb 0b                	jmp    f010047b <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100470:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100473:	83 fa 19             	cmp    $0x19,%edx
f0100476:	77 03                	ja     f010047b <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100478:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010047b:	f7 d0                	not    %eax
f010047d:	a8 06                	test   $0x6,%al
f010047f:	75 27                	jne    f01004a8 <kbd_proc_data+0xf6>
f0100481:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100487:	75 1f                	jne    f01004a8 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100489:	83 ec 0c             	sub    $0xc,%esp
f010048c:	68 24 1a 10 f0       	push   $0xf0101a24
f0100491:	e8 7b 05 00 00       	call   f0100a11 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100496:	ba 92 00 00 00       	mov    $0x92,%edx
f010049b:	b0 03                	mov    $0x3,%al
f010049d:	ee                   	out    %al,(%dx)
f010049e:	83 c4 10             	add    $0x10,%esp
f01004a1:	eb 05                	jmp    f01004a8 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004a3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004a8:	89 d8                	mov    %ebx,%eax
f01004aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01004ad:	c9                   	leave  
f01004ae:	c3                   	ret    

f01004af <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004af:	55                   	push   %ebp
f01004b0:	89 e5                	mov    %esp,%ebp
f01004b2:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004b5:	80 3d 10 83 11 f0 00 	cmpb   $0x0,0xf0118310
f01004bc:	74 0a                	je     f01004c8 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004be:	b8 86 01 10 f0       	mov    $0xf0100186,%eax
f01004c3:	e8 da fc ff ff       	call   f01001a2 <cons_intr>
}
f01004c8:	c9                   	leave  
f01004c9:	c3                   	ret    

f01004ca <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004ca:	55                   	push   %ebp
f01004cb:	89 e5                	mov    %esp,%ebp
f01004cd:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004d0:	b8 b2 03 10 f0       	mov    $0xf01003b2,%eax
f01004d5:	e8 c8 fc ff ff       	call   f01001a2 <cons_intr>
}
f01004da:	c9                   	leave  
f01004db:	c3                   	ret    

f01004dc <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004dc:	55                   	push   %ebp
f01004dd:	89 e5                	mov    %esp,%ebp
f01004df:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004e2:	e8 c8 ff ff ff       	call   f01004af <serial_intr>
	kbd_intr();
f01004e7:	e8 de ff ff ff       	call   f01004ca <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ec:	8b 15 20 85 11 f0    	mov    0xf0118520,%edx
f01004f2:	3b 15 24 85 11 f0    	cmp    0xf0118524,%edx
f01004f8:	74 22                	je     f010051c <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004fa:	0f b6 82 20 83 11 f0 	movzbl -0xfee7ce0(%edx),%eax
f0100501:	42                   	inc    %edx
f0100502:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
		if (cons.rpos == CONSBUFSIZE)
f0100508:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050e:	75 11                	jne    f0100521 <cons_getc+0x45>
			cons.rpos = 0;
f0100510:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
f0100517:	00 00 00 
f010051a:	eb 05                	jmp    f0100521 <cons_getc+0x45>
		return c;
	}
	return 0;
f010051c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100521:	c9                   	leave  
f0100522:	c3                   	ret    

f0100523 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100523:	55                   	push   %ebp
f0100524:	89 e5                	mov    %esp,%ebp
f0100526:	57                   	push   %edi
f0100527:	56                   	push   %esi
f0100528:	53                   	push   %ebx
f0100529:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010052c:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100533:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010053a:	5a a5 
	if (*cp != 0xA55A) {
f010053c:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100542:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100546:	74 11                	je     f0100559 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100548:	c7 05 0c 83 11 f0 b4 	movl   $0x3b4,0xf011830c
f010054f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100552:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100557:	eb 16                	jmp    f010056f <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100559:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100560:	c7 05 0c 83 11 f0 d4 	movl   $0x3d4,0xf011830c
f0100567:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010056a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056f:	8b 0d 0c 83 11 f0    	mov    0xf011830c,%ecx
f0100575:	b0 0e                	mov    $0xe,%al
f0100577:	89 ca                	mov    %ecx,%edx
f0100579:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010057a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057d:	89 da                	mov    %ebx,%edx
f010057f:	ec                   	in     (%dx),%al
f0100580:	0f b6 f8             	movzbl %al,%edi
f0100583:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100586:	b0 0f                	mov    $0xf,%al
f0100588:	89 ca                	mov    %ecx,%edx
f010058a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058b:	89 da                	mov    %ebx,%edx
f010058d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010058e:	89 35 08 83 11 f0    	mov    %esi,0xf0118308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100594:	0f b6 d8             	movzbl %al,%ebx
f0100597:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100599:	66 89 3d 04 83 11 f0 	mov    %di,0xf0118304
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005a5:	b0 00                	mov    $0x0,%al
f01005a7:	89 da                	mov    %ebx,%edx
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	b2 fb                	mov    $0xfb,%dl
f01005ac:	b0 80                	mov    $0x80,%al
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005b4:	b0 0c                	mov    $0xc,%al
f01005b6:	89 ca                	mov    %ecx,%edx
f01005b8:	ee                   	out    %al,(%dx)
f01005b9:	b2 f9                	mov    $0xf9,%dl
f01005bb:	b0 00                	mov    $0x0,%al
f01005bd:	ee                   	out    %al,(%dx)
f01005be:	b2 fb                	mov    $0xfb,%dl
f01005c0:	b0 03                	mov    $0x3,%al
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	b2 fc                	mov    $0xfc,%dl
f01005c5:	b0 00                	mov    $0x0,%al
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	b2 f9                	mov    $0xf9,%dl
f01005ca:	b0 01                	mov    $0x1,%al
f01005cc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cd:	b2 fd                	mov    $0xfd,%dl
f01005cf:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d0:	3c ff                	cmp    $0xff,%al
f01005d2:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005d6:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005d9:	a2 10 83 11 f0       	mov    %al,0xf0118310
f01005de:	89 da                	mov    %ebx,%edx
f01005e0:	ec                   	in     (%dx),%al
f01005e1:	89 ca                	mov    %ecx,%edx
f01005e3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005e8:	75 10                	jne    f01005fa <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005ea:	83 ec 0c             	sub    $0xc,%esp
f01005ed:	68 30 1a 10 f0       	push   $0xf0101a30
f01005f2:	e8 1a 04 00 00       	call   f0100a11 <cprintf>
f01005f7:	83 c4 10             	add    $0x10,%esp
}
f01005fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fd:	5b                   	pop    %ebx
f01005fe:	5e                   	pop    %esi
f01005ff:	5f                   	pop    %edi
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100608:	8b 45 08             	mov    0x8(%ebp),%eax
f010060b:	e8 d3 fb ff ff       	call   f01001e3 <cons_putc>
}
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <getchar>:

int
getchar(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100618:	e8 bf fe ff ff       	call   f01004dc <cons_getc>
f010061d:	85 c0                	test   %eax,%eax
f010061f:	74 f7                	je     f0100618 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100621:	c9                   	leave  
f0100622:	c3                   	ret    

f0100623 <iscons>:

int
iscons(int fdnum)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100626:	b8 01 00 00 00       	mov    $0x1,%eax
f010062b:	c9                   	leave  
f010062c:	c3                   	ret    
f010062d:	00 00                	add    %al,(%eax)
	...

f0100630 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100636:	68 70 1c 10 f0       	push   $0xf0101c70
f010063b:	e8 d1 03 00 00       	call   f0100a11 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100640:	83 c4 08             	add    $0x8,%esp
f0100643:	68 0c 00 10 00       	push   $0x10000c
f0100648:	68 68 1d 10 f0       	push   $0xf0101d68
f010064d:	e8 bf 03 00 00       	call   f0100a11 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100652:	83 c4 0c             	add    $0xc,%esp
f0100655:	68 0c 00 10 00       	push   $0x10000c
f010065a:	68 0c 00 10 f0       	push   $0xf010000c
f010065f:	68 90 1d 10 f0       	push   $0xf0101d90
f0100664:	e8 a8 03 00 00       	call   f0100a11 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100669:	83 c4 0c             	add    $0xc,%esp
f010066c:	68 90 19 10 00       	push   $0x101990
f0100671:	68 90 19 10 f0       	push   $0xf0101990
f0100676:	68 b4 1d 10 f0       	push   $0xf0101db4
f010067b:	e8 91 03 00 00       	call   f0100a11 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100680:	83 c4 0c             	add    $0xc,%esp
f0100683:	68 00 83 11 00       	push   $0x118300
f0100688:	68 00 83 11 f0       	push   $0xf0118300
f010068d:	68 d8 1d 10 f0       	push   $0xf0101dd8
f0100692:	e8 7a 03 00 00       	call   f0100a11 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100697:	83 c4 0c             	add    $0xc,%esp
f010069a:	68 44 89 11 00       	push   $0x118944
f010069f:	68 44 89 11 f0       	push   $0xf0118944
f01006a4:	68 fc 1d 10 f0       	push   $0xf0101dfc
f01006a9:	e8 63 03 00 00       	call   f0100a11 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ae:	b8 43 8d 11 f0       	mov    $0xf0118d43,%eax
f01006b3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b8:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006bb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006c0:	89 c2                	mov    %eax,%edx
f01006c2:	85 c0                	test   %eax,%eax
f01006c4:	79 06                	jns    f01006cc <mon_kerninfo+0x9c>
f01006c6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006cc:	c1 fa 0a             	sar    $0xa,%edx
f01006cf:	52                   	push   %edx
f01006d0:	68 20 1e 10 f0       	push   $0xf0101e20
f01006d5:	e8 37 03 00 00       	call   f0100a11 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006da:	b8 00 00 00 00       	mov    $0x0,%eax
f01006df:	c9                   	leave  
f01006e0:	c3                   	ret    

f01006e1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006e1:	55                   	push   %ebp
f01006e2:	89 e5                	mov    %esp,%ebp
f01006e4:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006e7:	ff 35 a4 20 10 f0    	pushl  0xf01020a4
f01006ed:	ff 35 a0 20 10 f0    	pushl  0xf01020a0
f01006f3:	68 89 1c 10 f0       	push   $0xf0101c89
f01006f8:	e8 14 03 00 00       	call   f0100a11 <cprintf>
f01006fd:	83 c4 0c             	add    $0xc,%esp
f0100700:	ff 35 b0 20 10 f0    	pushl  0xf01020b0
f0100706:	ff 35 ac 20 10 f0    	pushl  0xf01020ac
f010070c:	68 89 1c 10 f0       	push   $0xf0101c89
f0100711:	e8 fb 02 00 00       	call   f0100a11 <cprintf>
f0100716:	83 c4 0c             	add    $0xc,%esp
f0100719:	ff 35 bc 20 10 f0    	pushl  0xf01020bc
f010071f:	ff 35 b8 20 10 f0    	pushl  0xf01020b8
f0100725:	68 89 1c 10 f0       	push   $0xf0101c89
f010072a:	e8 e2 02 00 00       	call   f0100a11 <cprintf>
f010072f:	83 c4 0c             	add    $0xc,%esp
f0100732:	ff 35 c8 20 10 f0    	pushl  0xf01020c8
f0100738:	ff 35 c4 20 10 f0    	pushl  0xf01020c4
f010073e:	68 89 1c 10 f0       	push   $0xf0101c89
f0100743:	e8 c9 02 00 00       	call   f0100a11 <cprintf>
	return 0;
}
f0100748:	b8 00 00 00 00       	mov    $0x0,%eax
f010074d:	c9                   	leave  
f010074e:	c3                   	ret    

f010074f <mon_setcolor>:
}


int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f010074f:	55                   	push   %ebp
f0100750:	89 e5                	mov    %esp,%ebp
f0100752:	56                   	push   %esi
f0100753:	53                   	push   %ebx
f0100754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100757:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010075b:	74 66                	je     f01007c3 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f010075d:	83 ec 0c             	sub    $0xc,%esp
f0100760:	68 4c 1e 10 f0       	push   $0xf0101e4c
f0100765:	e8 a7 02 00 00       	call   f0100a11 <cprintf>
        cprintf("num show the color attribute. \n");
f010076a:	c7 04 24 7c 1e 10 f0 	movl   $0xf0101e7c,(%esp)
f0100771:	e8 9b 02 00 00       	call   f0100a11 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100776:	c7 04 24 9c 1e 10 f0 	movl   $0xf0101e9c,(%esp)
f010077d:	e8 8f 02 00 00       	call   f0100a11 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100782:	c7 04 24 d0 1e 10 f0 	movl   $0xf0101ed0,(%esp)
f0100789:	e8 83 02 00 00       	call   f0100a11 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f010078e:	c7 04 24 14 1f 10 f0 	movl   $0xf0101f14,(%esp)
f0100795:	e8 77 02 00 00       	call   f0100a11 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f010079a:	c7 04 24 92 1c 10 f0 	movl   $0xf0101c92,(%esp)
f01007a1:	e8 6b 02 00 00       	call   f0100a11 <cprintf>
        cprintf("         set the background color to black\n");
f01007a6:	c7 04 24 58 1f 10 f0 	movl   $0xf0101f58,(%esp)
f01007ad:	e8 5f 02 00 00       	call   f0100a11 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f01007b2:	c7 04 24 84 1f 10 f0 	movl   $0xf0101f84,(%esp)
f01007b9:	e8 53 02 00 00       	call   f0100a11 <cprintf>
f01007be:	83 c4 10             	add    $0x10,%esp
f01007c1:	eb 52                	jmp    f0100815 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f01007c3:	83 ec 0c             	sub    $0xc,%esp
f01007c6:	ff 73 04             	pushl  0x4(%ebx)
f01007c9:	e8 aa 0b 00 00       	call   f0101378 <strlen>
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	48                   	dec    %eax
f01007d2:	78 26                	js     f01007fa <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f01007d4:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f01007d7:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f01007dc:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f01007e1:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f01007e5:	0f 94 c3             	sete   %bl
f01007e8:	0f b6 db             	movzbl %bl,%ebx
f01007eb:	d3 e3                	shl    %cl,%ebx
f01007ed:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f01007ef:	48                   	dec    %eax
f01007f0:	78 0d                	js     f01007ff <mon_setcolor+0xb0>
f01007f2:	41                   	inc    %ecx
f01007f3:	83 f9 08             	cmp    $0x8,%ecx
f01007f6:	75 e9                	jne    f01007e1 <mon_setcolor+0x92>
f01007f8:	eb 05                	jmp    f01007ff <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f01007fa:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f01007ff:	89 15 00 83 11 f0    	mov    %edx,0xf0118300
        cprintf(" This is color that you want ! \n");
f0100805:	83 ec 0c             	sub    $0xc,%esp
f0100808:	68 b8 1f 10 f0       	push   $0xf0101fb8
f010080d:	e8 ff 01 00 00       	call   f0100a11 <cprintf>
f0100812:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	c9                   	leave  
f0100820:	c3                   	ret    

f0100821 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100821:	55                   	push   %ebp
f0100822:	89 e5                	mov    %esp,%ebp
f0100824:	57                   	push   %edi
f0100825:	56                   	push   %esi
f0100826:	53                   	push   %ebx
f0100827:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010082a:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f010082c:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f010082e:	85 c0                	test   %eax,%eax
f0100830:	74 6d                	je     f010089f <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100832:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100835:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100838:	ff 76 18             	pushl  0x18(%esi)
f010083b:	ff 76 14             	pushl  0x14(%esi)
f010083e:	ff 76 10             	pushl  0x10(%esi)
f0100841:	ff 76 0c             	pushl  0xc(%esi)
f0100844:	ff 76 08             	pushl  0x8(%esi)
f0100847:	53                   	push   %ebx
f0100848:	56                   	push   %esi
f0100849:	68 dc 1f 10 f0       	push   $0xf0101fdc
f010084e:	e8 be 01 00 00       	call   f0100a11 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100853:	83 c4 18             	add    $0x18,%esp
f0100856:	57                   	push   %edi
f0100857:	ff 76 04             	pushl  0x4(%esi)
f010085a:	e8 ee 02 00 00       	call   f0100b4d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f010085f:	83 c4 0c             	add    $0xc,%esp
f0100862:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100865:	ff 75 d0             	pushl  -0x30(%ebp)
f0100868:	68 ae 1c 10 f0       	push   $0xf0101cae
f010086d:	e8 9f 01 00 00       	call   f0100a11 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100872:	83 c4 0c             	add    $0xc,%esp
f0100875:	ff 75 d8             	pushl  -0x28(%ebp)
f0100878:	ff 75 dc             	pushl  -0x24(%ebp)
f010087b:	68 be 1c 10 f0       	push   $0xf0101cbe
f0100880:	e8 8c 01 00 00       	call   f0100a11 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100885:	83 c4 08             	add    $0x8,%esp
f0100888:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010088b:	53                   	push   %ebx
f010088c:	68 c3 1c 10 f0       	push   $0xf0101cc3
f0100891:	e8 7b 01 00 00       	call   f0100a11 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100896:	8b 36                	mov    (%esi),%esi
f0100898:	83 c4 10             	add    $0x10,%esp
f010089b:	85 f6                	test   %esi,%esi
f010089d:	75 96                	jne    f0100835 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f010089f:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008a7:	5b                   	pop    %ebx
f01008a8:	5e                   	pop    %esi
f01008a9:	5f                   	pop    %edi
f01008aa:	c9                   	leave  
f01008ab:	c3                   	ret    

f01008ac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008ac:	55                   	push   %ebp
f01008ad:	89 e5                	mov    %esp,%ebp
f01008af:	57                   	push   %edi
f01008b0:	56                   	push   %esi
f01008b1:	53                   	push   %ebx
f01008b2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008b5:	68 14 20 10 f0       	push   $0xf0102014
f01008ba:	e8 52 01 00 00       	call   f0100a11 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008bf:	c7 04 24 38 20 10 f0 	movl   $0xf0102038,(%esp)
f01008c6:	e8 46 01 00 00       	call   f0100a11 <cprintf>
f01008cb:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01008ce:	83 ec 0c             	sub    $0xc,%esp
f01008d1:	68 c8 1c 10 f0       	push   $0xf0101cc8
f01008d6:	e8 cd 09 00 00       	call   f01012a8 <readline>
f01008db:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008dd:	83 c4 10             	add    $0x10,%esp
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	74 ea                	je     f01008ce <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008e4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008eb:	be 00 00 00 00       	mov    $0x0,%esi
f01008f0:	eb 04                	jmp    f01008f6 <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008f2:	c6 03 00             	movb   $0x0,(%ebx)
f01008f5:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008f6:	8a 03                	mov    (%ebx),%al
f01008f8:	84 c0                	test   %al,%al
f01008fa:	74 64                	je     f0100960 <monitor+0xb4>
f01008fc:	83 ec 08             	sub    $0x8,%esp
f01008ff:	0f be c0             	movsbl %al,%eax
f0100902:	50                   	push   %eax
f0100903:	68 cc 1c 10 f0       	push   $0xf0101ccc
f0100908:	e8 e4 0b 00 00       	call   f01014f1 <strchr>
f010090d:	83 c4 10             	add    $0x10,%esp
f0100910:	85 c0                	test   %eax,%eax
f0100912:	75 de                	jne    f01008f2 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100914:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100917:	74 47                	je     f0100960 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100919:	83 fe 0f             	cmp    $0xf,%esi
f010091c:	75 14                	jne    f0100932 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	6a 10                	push   $0x10
f0100923:	68 d1 1c 10 f0       	push   $0xf0101cd1
f0100928:	e8 e4 00 00 00       	call   f0100a11 <cprintf>
f010092d:	83 c4 10             	add    $0x10,%esp
f0100930:	eb 9c                	jmp    f01008ce <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100932:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100936:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100937:	8a 03                	mov    (%ebx),%al
f0100939:	84 c0                	test   %al,%al
f010093b:	75 09                	jne    f0100946 <monitor+0x9a>
f010093d:	eb b7                	jmp    f01008f6 <monitor+0x4a>
			buf++;
f010093f:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100940:	8a 03                	mov    (%ebx),%al
f0100942:	84 c0                	test   %al,%al
f0100944:	74 b0                	je     f01008f6 <monitor+0x4a>
f0100946:	83 ec 08             	sub    $0x8,%esp
f0100949:	0f be c0             	movsbl %al,%eax
f010094c:	50                   	push   %eax
f010094d:	68 cc 1c 10 f0       	push   $0xf0101ccc
f0100952:	e8 9a 0b 00 00       	call   f01014f1 <strchr>
f0100957:	83 c4 10             	add    $0x10,%esp
f010095a:	85 c0                	test   %eax,%eax
f010095c:	74 e1                	je     f010093f <monitor+0x93>
f010095e:	eb 96                	jmp    f01008f6 <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100960:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100967:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100968:	85 f6                	test   %esi,%esi
f010096a:	0f 84 5e ff ff ff    	je     f01008ce <monitor+0x22>
f0100970:	bb a0 20 10 f0       	mov    $0xf01020a0,%ebx
f0100975:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010097a:	83 ec 08             	sub    $0x8,%esp
f010097d:	ff 33                	pushl  (%ebx)
f010097f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100982:	e8 fc 0a 00 00       	call   f0101483 <strcmp>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	85 c0                	test   %eax,%eax
f010098c:	75 20                	jne    f01009ae <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f010098e:	83 ec 04             	sub    $0x4,%esp
f0100991:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100994:	ff 75 08             	pushl  0x8(%ebp)
f0100997:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010099a:	50                   	push   %eax
f010099b:	56                   	push   %esi
f010099c:	ff 97 a8 20 10 f0    	call   *-0xfefdf58(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	85 c0                	test   %eax,%eax
f01009a7:	78 26                	js     f01009cf <monitor+0x123>
f01009a9:	e9 20 ff ff ff       	jmp    f01008ce <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009ae:	47                   	inc    %edi
f01009af:	83 c3 0c             	add    $0xc,%ebx
f01009b2:	83 ff 04             	cmp    $0x4,%edi
f01009b5:	75 c3                	jne    f010097a <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009b7:	83 ec 08             	sub    $0x8,%esp
f01009ba:	ff 75 a8             	pushl  -0x58(%ebp)
f01009bd:	68 ee 1c 10 f0       	push   $0xf0101cee
f01009c2:	e8 4a 00 00 00       	call   f0100a11 <cprintf>
f01009c7:	83 c4 10             	add    $0x10,%esp
f01009ca:	e9 ff fe ff ff       	jmp    f01008ce <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009d2:	5b                   	pop    %ebx
f01009d3:	5e                   	pop    %esi
f01009d4:	5f                   	pop    %edi
f01009d5:	c9                   	leave  
f01009d6:	c3                   	ret    
	...

f01009d8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009d8:	55                   	push   %ebp
f01009d9:	89 e5                	mov    %esp,%ebp
f01009db:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01009de:	ff 75 08             	pushl  0x8(%ebp)
f01009e1:	e8 1c fc ff ff       	call   f0100602 <cputchar>
f01009e6:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01009e9:	c9                   	leave  
f01009ea:	c3                   	ret    

f01009eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009eb:	55                   	push   %ebp
f01009ec:	89 e5                	mov    %esp,%ebp
f01009ee:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009f8:	ff 75 0c             	pushl  0xc(%ebp)
f01009fb:	ff 75 08             	pushl  0x8(%ebp)
f01009fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a01:	50                   	push   %eax
f0100a02:	68 d8 09 10 f0       	push   $0xf01009d8
f0100a07:	e8 9d 04 00 00       	call   f0100ea9 <vprintfmt>
	return cnt;
}
f0100a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a0f:	c9                   	leave  
f0100a10:	c3                   	ret    

f0100a11 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a11:	55                   	push   %ebp
f0100a12:	89 e5                	mov    %esp,%ebp
f0100a14:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a17:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a1a:	50                   	push   %eax
f0100a1b:	ff 75 08             	pushl  0x8(%ebp)
f0100a1e:	e8 c8 ff ff ff       	call   f01009eb <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a23:	c9                   	leave  
f0100a24:	c3                   	ret    
f0100a25:	00 00                	add    %al,(%eax)
	...

f0100a28 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a28:	55                   	push   %ebp
f0100a29:	89 e5                	mov    %esp,%ebp
f0100a2b:	57                   	push   %edi
f0100a2c:	56                   	push   %esi
f0100a2d:	53                   	push   %ebx
f0100a2e:	83 ec 14             	sub    $0x14,%esp
f0100a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a34:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100a37:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a3a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a3d:	8b 1a                	mov    (%edx),%ebx
f0100a3f:	8b 01                	mov    (%ecx),%eax
f0100a41:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0100a44:	39 c3                	cmp    %eax,%ebx
f0100a46:	0f 8f 97 00 00 00    	jg     f0100ae3 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a56:	01 d8                	add    %ebx,%eax
f0100a58:	89 c7                	mov    %eax,%edi
f0100a5a:	c1 ef 1f             	shr    $0x1f,%edi
f0100a5d:	01 c7                	add    %eax,%edi
f0100a5f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a61:	39 df                	cmp    %ebx,%edi
f0100a63:	7c 31                	jl     f0100a96 <stab_binsearch+0x6e>
f0100a65:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100a6b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100a70:	39 f0                	cmp    %esi,%eax
f0100a72:	0f 84 b3 00 00 00    	je     f0100b2b <stab_binsearch+0x103>
f0100a78:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a7c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100a80:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100a82:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a83:	39 d8                	cmp    %ebx,%eax
f0100a85:	7c 0f                	jl     f0100a96 <stab_binsearch+0x6e>
f0100a87:	0f b6 0a             	movzbl (%edx),%ecx
f0100a8a:	83 ea 0c             	sub    $0xc,%edx
f0100a8d:	39 f1                	cmp    %esi,%ecx
f0100a8f:	75 f1                	jne    f0100a82 <stab_binsearch+0x5a>
f0100a91:	e9 97 00 00 00       	jmp    f0100b2d <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a96:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100a99:	eb 39                	jmp    f0100ad4 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a9b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100a9e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100aa0:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100aa3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100aaa:	eb 28                	jmp    f0100ad4 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100aac:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100aaf:	76 12                	jbe    f0100ac3 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0100ab1:	48                   	dec    %eax
f0100ab2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100ab5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ab8:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100aba:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100ac1:	eb 11                	jmp    f0100ad4 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ac3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100ac6:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100ac8:	ff 45 0c             	incl   0xc(%ebp)
f0100acb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100acd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100ad4:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100ad7:	0f 8d 76 ff ff ff    	jge    f0100a53 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100add:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ae1:	75 0d                	jne    f0100af0 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0100ae3:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100ae6:	8b 03                	mov    (%ebx),%eax
f0100ae8:	48                   	dec    %eax
f0100ae9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100aec:	89 02                	mov    %eax,(%edx)
f0100aee:	eb 55                	jmp    f0100b45 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100af0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100af3:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100af5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100af8:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100afa:	39 c1                	cmp    %eax,%ecx
f0100afc:	7d 26                	jge    f0100b24 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100afe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b01:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100b04:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100b09:	39 f2                	cmp    %esi,%edx
f0100b0b:	74 17                	je     f0100b24 <stab_binsearch+0xfc>
f0100b0d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100b11:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b15:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b16:	39 c1                	cmp    %eax,%ecx
f0100b18:	7d 0a                	jge    f0100b24 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100b1a:	0f b6 1a             	movzbl (%edx),%ebx
f0100b1d:	83 ea 0c             	sub    $0xc,%edx
f0100b20:	39 f3                	cmp    %esi,%ebx
f0100b22:	75 f1                	jne    f0100b15 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b24:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b27:	89 02                	mov    %eax,(%edx)
f0100b29:	eb 1a                	jmp    f0100b45 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100b2b:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b2d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b30:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100b33:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b37:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b3a:	0f 82 5b ff ff ff    	jb     f0100a9b <stab_binsearch+0x73>
f0100b40:	e9 67 ff ff ff       	jmp    f0100aac <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b45:	83 c4 14             	add    $0x14,%esp
f0100b48:	5b                   	pop    %ebx
f0100b49:	5e                   	pop    %esi
f0100b4a:	5f                   	pop    %edi
f0100b4b:	c9                   	leave  
f0100b4c:	c3                   	ret    

f0100b4d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b4d:	55                   	push   %ebp
f0100b4e:	89 e5                	mov    %esp,%ebp
f0100b50:	57                   	push   %edi
f0100b51:	56                   	push   %esi
f0100b52:	53                   	push   %ebx
f0100b53:	83 ec 2c             	sub    $0x2c,%esp
f0100b56:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b5c:	c7 03 d0 20 10 f0    	movl   $0xf01020d0,(%ebx)
	info->eip_line = 0;
f0100b62:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b69:	c7 43 08 d0 20 10 f0 	movl   $0xf01020d0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b70:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b77:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b7a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b81:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b87:	76 12                	jbe    f0100b9b <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b89:	b8 d6 dd 10 f0       	mov    $0xf010ddd6,%eax
f0100b8e:	3d 79 6a 10 f0       	cmp    $0xf0106a79,%eax
f0100b93:	0f 86 90 01 00 00    	jbe    f0100d29 <debuginfo_eip+0x1dc>
f0100b99:	eb 14                	jmp    f0100baf <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b9b:	83 ec 04             	sub    $0x4,%esp
f0100b9e:	68 da 20 10 f0       	push   $0xf01020da
f0100ba3:	6a 7f                	push   $0x7f
f0100ba5:	68 e7 20 10 f0       	push   $0xf01020e7
f0100baa:	e8 36 f5 ff ff       	call   f01000e5 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100baf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bb4:	80 3d d5 dd 10 f0 00 	cmpb   $0x0,0xf010ddd5
f0100bbb:	0f 85 74 01 00 00    	jne    f0100d35 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bc1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc8:	b8 78 6a 10 f0       	mov    $0xf0106a78,%eax
f0100bcd:	2d 08 23 10 f0       	sub    $0xf0102308,%eax
f0100bd2:	c1 f8 02             	sar    $0x2,%eax
f0100bd5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bdb:	48                   	dec    %eax
f0100bdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bdf:	83 ec 08             	sub    $0x8,%esp
f0100be2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100be5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100be8:	56                   	push   %esi
f0100be9:	6a 64                	push   $0x64
f0100beb:	b8 08 23 10 f0       	mov    $0xf0102308,%eax
f0100bf0:	e8 33 fe ff ff       	call   f0100a28 <stab_binsearch>
	if (lfile == 0)
f0100bf5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bf8:	83 c4 10             	add    $0x10,%esp
		return -1;
f0100bfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100c00:	85 d2                	test   %edx,%edx
f0100c02:	0f 84 2d 01 00 00    	je     f0100d35 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c08:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100c0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c11:	83 ec 08             	sub    $0x8,%esp
f0100c14:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c17:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c1a:	56                   	push   %esi
f0100c1b:	6a 24                	push   $0x24
f0100c1d:	b8 08 23 10 f0       	mov    $0xf0102308,%eax
f0100c22:	e8 01 fe ff ff       	call   f0100a28 <stab_binsearch>

	if (lfun <= rfun) {
f0100c27:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100c2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c30:	83 c4 10             	add    $0x10,%esp
f0100c33:	39 c7                	cmp    %eax,%edi
f0100c35:	7f 32                	jg     f0100c69 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c37:	89 f9                	mov    %edi,%ecx
f0100c39:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100c3c:	8b 80 08 23 10 f0    	mov    -0xfefdcf8(%eax),%eax
f0100c42:	ba d6 dd 10 f0       	mov    $0xf010ddd6,%edx
f0100c47:	81 ea 79 6a 10 f0    	sub    $0xf0106a79,%edx
f0100c4d:	39 d0                	cmp    %edx,%eax
f0100c4f:	73 08                	jae    f0100c59 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c51:	05 79 6a 10 f0       	add    $0xf0106a79,%eax
f0100c56:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c59:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0100c5c:	8b 81 10 23 10 f0    	mov    -0xfefdcf0(%ecx),%eax
f0100c62:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c65:	29 c6                	sub    %eax,%esi
f0100c67:	eb 0c                	jmp    f0100c75 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c69:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0100c6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100c72:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c75:	83 ec 08             	sub    $0x8,%esp
f0100c78:	6a 3a                	push   $0x3a
f0100c7a:	ff 73 08             	pushl  0x8(%ebx)
f0100c7d:	e8 9d 08 00 00       	call   f010151f <strfind>
f0100c82:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c85:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0100c88:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0100c8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0100c91:	83 c4 08             	add    $0x8,%esp
f0100c94:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c97:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c9a:	56                   	push   %esi
f0100c9b:	6a 44                	push   $0x44
f0100c9d:	b8 08 23 10 f0       	mov    $0xf0102308,%eax
f0100ca2:	e8 81 fd ff ff       	call   f0100a28 <stab_binsearch>
    if (lfun <= rfun) {
f0100ca7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100caa:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0100cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0100cb2:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0100cb5:	7f 7e                	jg     f0100d35 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0100cb7:	6b c2 0c             	imul   $0xc,%edx,%eax
f0100cba:	05 08 23 10 f0       	add    $0xf0102308,%eax
f0100cbf:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100cc3:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100cc9:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ccc:	eb 04                	jmp    f0100cd2 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100cce:	4a                   	dec    %edx
f0100ccf:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cd2:	39 f2                	cmp    %esi,%edx
f0100cd4:	7c 1b                	jl     f0100cf1 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0100cd6:	8a 48 fc             	mov    -0x4(%eax),%cl
f0100cd9:	80 f9 84             	cmp    $0x84,%cl
f0100cdc:	74 5f                	je     f0100d3d <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cde:	80 f9 64             	cmp    $0x64,%cl
f0100ce1:	75 eb                	jne    f0100cce <debuginfo_eip+0x181>
f0100ce3:	83 38 00             	cmpl   $0x0,(%eax)
f0100ce6:	74 e6                	je     f0100cce <debuginfo_eip+0x181>
f0100ce8:	eb 53                	jmp    f0100d3d <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cea:	05 79 6a 10 f0       	add    $0xf0106a79,%eax
f0100cef:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cf1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cf4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cf7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cfc:	39 ca                	cmp    %ecx,%edx
f0100cfe:	7d 35                	jge    f0100d35 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0100d00:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100d03:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100d06:	81 c2 0c 23 10 f0    	add    $0xf010230c,%edx
f0100d0c:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d0e:	eb 04                	jmp    f0100d14 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d10:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100d13:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d14:	39 f0                	cmp    %esi,%eax
f0100d16:	7d 18                	jge    f0100d30 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d18:	8a 0a                	mov    (%edx),%cl
f0100d1a:	83 c2 0c             	add    $0xc,%edx
f0100d1d:	80 f9 a0             	cmp    $0xa0,%cl
f0100d20:	74 ee                	je     f0100d10 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d22:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d27:	eb 0c                	jmp    f0100d35 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d2e:	eb 05                	jmp    f0100d35 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d38:	5b                   	pop    %ebx
f0100d39:	5e                   	pop    %esi
f0100d3a:	5f                   	pop    %edi
f0100d3b:	c9                   	leave  
f0100d3c:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d3d:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100d40:	8b 82 08 23 10 f0    	mov    -0xfefdcf8(%edx),%eax
f0100d46:	ba d6 dd 10 f0       	mov    $0xf010ddd6,%edx
f0100d4b:	81 ea 79 6a 10 f0    	sub    $0xf0106a79,%edx
f0100d51:	39 d0                	cmp    %edx,%eax
f0100d53:	72 95                	jb     f0100cea <debuginfo_eip+0x19d>
f0100d55:	eb 9a                	jmp    f0100cf1 <debuginfo_eip+0x1a4>
	...

f0100d58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d58:	55                   	push   %ebp
f0100d59:	89 e5                	mov    %esp,%ebp
f0100d5b:	57                   	push   %edi
f0100d5c:	56                   	push   %esi
f0100d5d:	53                   	push   %ebx
f0100d5e:	83 ec 2c             	sub    $0x2c,%esp
f0100d61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d64:	89 d6                	mov    %edx,%esi
f0100d66:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d6f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100d72:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d75:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100d78:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d7e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100d85:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d88:	72 0c                	jb     f0100d96 <printnum+0x3e>
f0100d8a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100d8d:	76 07                	jbe    f0100d96 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d8f:	4b                   	dec    %ebx
f0100d90:	85 db                	test   %ebx,%ebx
f0100d92:	7f 31                	jg     f0100dc5 <printnum+0x6d>
f0100d94:	eb 3f                	jmp    f0100dd5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d96:	83 ec 0c             	sub    $0xc,%esp
f0100d99:	57                   	push   %edi
f0100d9a:	4b                   	dec    %ebx
f0100d9b:	53                   	push   %ebx
f0100d9c:	50                   	push   %eax
f0100d9d:	83 ec 08             	sub    $0x8,%esp
f0100da0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100da3:	ff 75 d0             	pushl  -0x30(%ebp)
f0100da6:	ff 75 dc             	pushl  -0x24(%ebp)
f0100da9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dac:	e8 97 09 00 00       	call   f0101748 <__udivdi3>
f0100db1:	83 c4 18             	add    $0x18,%esp
f0100db4:	52                   	push   %edx
f0100db5:	50                   	push   %eax
f0100db6:	89 f2                	mov    %esi,%edx
f0100db8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dbb:	e8 98 ff ff ff       	call   f0100d58 <printnum>
f0100dc0:	83 c4 20             	add    $0x20,%esp
f0100dc3:	eb 10                	jmp    f0100dd5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dc5:	83 ec 08             	sub    $0x8,%esp
f0100dc8:	56                   	push   %esi
f0100dc9:	57                   	push   %edi
f0100dca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100dcd:	4b                   	dec    %ebx
f0100dce:	83 c4 10             	add    $0x10,%esp
f0100dd1:	85 db                	test   %ebx,%ebx
f0100dd3:	7f f0                	jg     f0100dc5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100dd5:	83 ec 08             	sub    $0x8,%esp
f0100dd8:	56                   	push   %esi
f0100dd9:	83 ec 04             	sub    $0x4,%esp
f0100ddc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ddf:	ff 75 d0             	pushl  -0x30(%ebp)
f0100de2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100de5:	ff 75 d8             	pushl  -0x28(%ebp)
f0100de8:	e8 77 0a 00 00       	call   f0101864 <__umoddi3>
f0100ded:	83 c4 14             	add    $0x14,%esp
f0100df0:	0f be 80 f5 20 10 f0 	movsbl -0xfefdf0b(%eax),%eax
f0100df7:	50                   	push   %eax
f0100df8:	ff 55 e4             	call   *-0x1c(%ebp)
f0100dfb:	83 c4 10             	add    $0x10,%esp
}
f0100dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e01:	5b                   	pop    %ebx
f0100e02:	5e                   	pop    %esi
f0100e03:	5f                   	pop    %edi
f0100e04:	c9                   	leave  
f0100e05:	c3                   	ret    

f0100e06 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e06:	55                   	push   %ebp
f0100e07:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e09:	83 fa 01             	cmp    $0x1,%edx
f0100e0c:	7e 0e                	jle    f0100e1c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e0e:	8b 10                	mov    (%eax),%edx
f0100e10:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e13:	89 08                	mov    %ecx,(%eax)
f0100e15:	8b 02                	mov    (%edx),%eax
f0100e17:	8b 52 04             	mov    0x4(%edx),%edx
f0100e1a:	eb 22                	jmp    f0100e3e <getuint+0x38>
	else if (lflag)
f0100e1c:	85 d2                	test   %edx,%edx
f0100e1e:	74 10                	je     f0100e30 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e20:	8b 10                	mov    (%eax),%edx
f0100e22:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e25:	89 08                	mov    %ecx,(%eax)
f0100e27:	8b 02                	mov    (%edx),%eax
f0100e29:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e2e:	eb 0e                	jmp    f0100e3e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100e30:	8b 10                	mov    (%eax),%edx
f0100e32:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e35:	89 08                	mov    %ecx,(%eax)
f0100e37:	8b 02                	mov    (%edx),%eax
f0100e39:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e3e:	c9                   	leave  
f0100e3f:	c3                   	ret    

f0100e40 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0100e40:	55                   	push   %ebp
f0100e41:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e43:	83 fa 01             	cmp    $0x1,%edx
f0100e46:	7e 0e                	jle    f0100e56 <getint+0x16>
		return va_arg(*ap, long long);
f0100e48:	8b 10                	mov    (%eax),%edx
f0100e4a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e4d:	89 08                	mov    %ecx,(%eax)
f0100e4f:	8b 02                	mov    (%edx),%eax
f0100e51:	8b 52 04             	mov    0x4(%edx),%edx
f0100e54:	eb 1a                	jmp    f0100e70 <getint+0x30>
	else if (lflag)
f0100e56:	85 d2                	test   %edx,%edx
f0100e58:	74 0c                	je     f0100e66 <getint+0x26>
		return va_arg(*ap, long);
f0100e5a:	8b 10                	mov    (%eax),%edx
f0100e5c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e5f:	89 08                	mov    %ecx,(%eax)
f0100e61:	8b 02                	mov    (%edx),%eax
f0100e63:	99                   	cltd   
f0100e64:	eb 0a                	jmp    f0100e70 <getint+0x30>
	else
		return va_arg(*ap, int);
f0100e66:	8b 10                	mov    (%eax),%edx
f0100e68:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e6b:	89 08                	mov    %ecx,(%eax)
f0100e6d:	8b 02                	mov    (%edx),%eax
f0100e6f:	99                   	cltd   
}
f0100e70:	c9                   	leave  
f0100e71:	c3                   	ret    

f0100e72 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e72:	55                   	push   %ebp
f0100e73:	89 e5                	mov    %esp,%ebp
f0100e75:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e78:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100e7b:	8b 10                	mov    (%eax),%edx
f0100e7d:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e80:	73 08                	jae    f0100e8a <sprintputch+0x18>
		*b->buf++ = ch;
f0100e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100e85:	88 0a                	mov    %cl,(%edx)
f0100e87:	42                   	inc    %edx
f0100e88:	89 10                	mov    %edx,(%eax)
}
f0100e8a:	c9                   	leave  
f0100e8b:	c3                   	ret    

f0100e8c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e8c:	55                   	push   %ebp
f0100e8d:	89 e5                	mov    %esp,%ebp
f0100e8f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e92:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e95:	50                   	push   %eax
f0100e96:	ff 75 10             	pushl  0x10(%ebp)
f0100e99:	ff 75 0c             	pushl  0xc(%ebp)
f0100e9c:	ff 75 08             	pushl  0x8(%ebp)
f0100e9f:	e8 05 00 00 00       	call   f0100ea9 <vprintfmt>
	va_end(ap);
f0100ea4:	83 c4 10             	add    $0x10,%esp
}
f0100ea7:	c9                   	leave  
f0100ea8:	c3                   	ret    

f0100ea9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ea9:	55                   	push   %ebp
f0100eaa:	89 e5                	mov    %esp,%ebp
f0100eac:	57                   	push   %edi
f0100ead:	56                   	push   %esi
f0100eae:	53                   	push   %ebx
f0100eaf:	83 ec 2c             	sub    $0x2c,%esp
f0100eb2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100eb5:	8b 75 10             	mov    0x10(%ebp),%esi
f0100eb8:	eb 13                	jmp    f0100ecd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100eba:	85 c0                	test   %eax,%eax
f0100ebc:	0f 84 6d 03 00 00    	je     f010122f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0100ec2:	83 ec 08             	sub    $0x8,%esp
f0100ec5:	57                   	push   %edi
f0100ec6:	50                   	push   %eax
f0100ec7:	ff 55 08             	call   *0x8(%ebp)
f0100eca:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ecd:	0f b6 06             	movzbl (%esi),%eax
f0100ed0:	46                   	inc    %esi
f0100ed1:	83 f8 25             	cmp    $0x25,%eax
f0100ed4:	75 e4                	jne    f0100eba <vprintfmt+0x11>
f0100ed6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100eda:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100ee1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100ee8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100eef:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ef4:	eb 28                	jmp    f0100f1e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ef6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ef8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0100efc:	eb 20                	jmp    f0100f1e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100efe:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f00:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100f04:	eb 18                	jmp    f0100f1e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f06:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100f08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f0f:	eb 0d                	jmp    f0100f1e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100f11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f17:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f1e:	8a 06                	mov    (%esi),%al
f0100f20:	0f b6 d0             	movzbl %al,%edx
f0100f23:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100f26:	83 e8 23             	sub    $0x23,%eax
f0100f29:	3c 55                	cmp    $0x55,%al
f0100f2b:	0f 87 e0 02 00 00    	ja     f0101211 <vprintfmt+0x368>
f0100f31:	0f b6 c0             	movzbl %al,%eax
f0100f34:	ff 24 85 84 21 10 f0 	jmp    *-0xfefde7c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f3b:	83 ea 30             	sub    $0x30,%edx
f0100f3e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0100f41:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0100f44:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100f47:	83 fa 09             	cmp    $0x9,%edx
f0100f4a:	77 44                	ja     f0100f90 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4c:	89 de                	mov    %ebx,%esi
f0100f4e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100f51:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0100f52:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0100f55:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0100f59:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100f5c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100f5f:	83 fb 09             	cmp    $0x9,%ebx
f0100f62:	76 ed                	jbe    f0100f51 <vprintfmt+0xa8>
f0100f64:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0100f67:	eb 29                	jmp    f0100f92 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f69:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f6c:	8d 50 04             	lea    0x4(%eax),%edx
f0100f6f:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f72:	8b 00                	mov    (%eax),%eax
f0100f74:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f77:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f79:	eb 17                	jmp    f0100f92 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0100f7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100f7f:	78 85                	js     f0100f06 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f81:	89 de                	mov    %ebx,%esi
f0100f83:	eb 99                	jmp    f0100f1e <vprintfmt+0x75>
f0100f85:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f87:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100f8e:	eb 8e                	jmp    f0100f1e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f90:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100f92:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100f96:	79 86                	jns    f0100f1e <vprintfmt+0x75>
f0100f98:	e9 74 ff ff ff       	jmp    f0100f11 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f9d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f9e:	89 de                	mov    %ebx,%esi
f0100fa0:	e9 79 ff ff ff       	jmp    f0100f1e <vprintfmt+0x75>
f0100fa5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100fa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fab:	8d 50 04             	lea    0x4(%eax),%edx
f0100fae:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fb1:	83 ec 08             	sub    $0x8,%esp
f0100fb4:	57                   	push   %edi
f0100fb5:	ff 30                	pushl  (%eax)
f0100fb7:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100fba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fbd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100fc0:	e9 08 ff ff ff       	jmp    f0100ecd <vprintfmt+0x24>
f0100fc5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100fc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fcb:	8d 50 04             	lea    0x4(%eax),%edx
f0100fce:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fd1:	8b 00                	mov    (%eax),%eax
f0100fd3:	85 c0                	test   %eax,%eax
f0100fd5:	79 02                	jns    f0100fd9 <vprintfmt+0x130>
f0100fd7:	f7 d8                	neg    %eax
f0100fd9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100fdb:	83 f8 06             	cmp    $0x6,%eax
f0100fde:	7f 0b                	jg     f0100feb <vprintfmt+0x142>
f0100fe0:	8b 04 85 dc 22 10 f0 	mov    -0xfefdd24(,%eax,4),%eax
f0100fe7:	85 c0                	test   %eax,%eax
f0100fe9:	75 1a                	jne    f0101005 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0100feb:	52                   	push   %edx
f0100fec:	68 0d 21 10 f0       	push   $0xf010210d
f0100ff1:	57                   	push   %edi
f0100ff2:	ff 75 08             	pushl  0x8(%ebp)
f0100ff5:	e8 92 fe ff ff       	call   f0100e8c <printfmt>
f0100ffa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ffd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101000:	e9 c8 fe ff ff       	jmp    f0100ecd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0101005:	50                   	push   %eax
f0101006:	68 16 21 10 f0       	push   $0xf0102116
f010100b:	57                   	push   %edi
f010100c:	ff 75 08             	pushl  0x8(%ebp)
f010100f:	e8 78 fe ff ff       	call   f0100e8c <printfmt>
f0101014:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101017:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010101a:	e9 ae fe ff ff       	jmp    f0100ecd <vprintfmt+0x24>
f010101f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0101022:	89 de                	mov    %ebx,%esi
f0101024:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101027:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010102a:	8b 45 14             	mov    0x14(%ebp),%eax
f010102d:	8d 50 04             	lea    0x4(%eax),%edx
f0101030:	89 55 14             	mov    %edx,0x14(%ebp)
f0101033:	8b 00                	mov    (%eax),%eax
f0101035:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101038:	85 c0                	test   %eax,%eax
f010103a:	75 07                	jne    f0101043 <vprintfmt+0x19a>
				p = "(null)";
f010103c:	c7 45 d0 06 21 10 f0 	movl   $0xf0102106,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0101043:	85 db                	test   %ebx,%ebx
f0101045:	7e 42                	jle    f0101089 <vprintfmt+0x1e0>
f0101047:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010104b:	74 3c                	je     f0101089 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010104d:	83 ec 08             	sub    $0x8,%esp
f0101050:	51                   	push   %ecx
f0101051:	ff 75 d0             	pushl  -0x30(%ebp)
f0101054:	e8 3f 03 00 00       	call   f0101398 <strnlen>
f0101059:	29 c3                	sub    %eax,%ebx
f010105b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010105e:	83 c4 10             	add    $0x10,%esp
f0101061:	85 db                	test   %ebx,%ebx
f0101063:	7e 24                	jle    f0101089 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0101065:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0101069:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010106c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010106f:	83 ec 08             	sub    $0x8,%esp
f0101072:	57                   	push   %edi
f0101073:	53                   	push   %ebx
f0101074:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101077:	4e                   	dec    %esi
f0101078:	83 c4 10             	add    $0x10,%esp
f010107b:	85 f6                	test   %esi,%esi
f010107d:	7f f0                	jg     f010106f <vprintfmt+0x1c6>
f010107f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101082:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101089:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010108c:	0f be 02             	movsbl (%edx),%eax
f010108f:	85 c0                	test   %eax,%eax
f0101091:	75 47                	jne    f01010da <vprintfmt+0x231>
f0101093:	eb 37                	jmp    f01010cc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0101095:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101099:	74 16                	je     f01010b1 <vprintfmt+0x208>
f010109b:	8d 50 e0             	lea    -0x20(%eax),%edx
f010109e:	83 fa 5e             	cmp    $0x5e,%edx
f01010a1:	76 0e                	jbe    f01010b1 <vprintfmt+0x208>
					putch('?', putdat);
f01010a3:	83 ec 08             	sub    $0x8,%esp
f01010a6:	57                   	push   %edi
f01010a7:	6a 3f                	push   $0x3f
f01010a9:	ff 55 08             	call   *0x8(%ebp)
f01010ac:	83 c4 10             	add    $0x10,%esp
f01010af:	eb 0b                	jmp    f01010bc <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01010b1:	83 ec 08             	sub    $0x8,%esp
f01010b4:	57                   	push   %edi
f01010b5:	50                   	push   %eax
f01010b6:	ff 55 08             	call   *0x8(%ebp)
f01010b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010bc:	ff 4d e4             	decl   -0x1c(%ebp)
f01010bf:	0f be 03             	movsbl (%ebx),%eax
f01010c2:	85 c0                	test   %eax,%eax
f01010c4:	74 03                	je     f01010c9 <vprintfmt+0x220>
f01010c6:	43                   	inc    %ebx
f01010c7:	eb 1b                	jmp    f01010e4 <vprintfmt+0x23b>
f01010c9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010d0:	7f 1e                	jg     f01010f0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010d2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01010d5:	e9 f3 fd ff ff       	jmp    f0100ecd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010da:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01010dd:	43                   	inc    %ebx
f01010de:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01010e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01010e4:	85 f6                	test   %esi,%esi
f01010e6:	78 ad                	js     f0101095 <vprintfmt+0x1ec>
f01010e8:	4e                   	dec    %esi
f01010e9:	79 aa                	jns    f0101095 <vprintfmt+0x1ec>
f01010eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01010ee:	eb dc                	jmp    f01010cc <vprintfmt+0x223>
f01010f0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010f3:	83 ec 08             	sub    $0x8,%esp
f01010f6:	57                   	push   %edi
f01010f7:	6a 20                	push   $0x20
f01010f9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010fc:	4b                   	dec    %ebx
f01010fd:	83 c4 10             	add    $0x10,%esp
f0101100:	85 db                	test   %ebx,%ebx
f0101102:	7f ef                	jg     f01010f3 <vprintfmt+0x24a>
f0101104:	e9 c4 fd ff ff       	jmp    f0100ecd <vprintfmt+0x24>
f0101109:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010110c:	89 ca                	mov    %ecx,%edx
f010110e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101111:	e8 2a fd ff ff       	call   f0100e40 <getint>
f0101116:	89 c3                	mov    %eax,%ebx
f0101118:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010111a:	85 d2                	test   %edx,%edx
f010111c:	78 0a                	js     f0101128 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010111e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101123:	e9 b0 00 00 00       	jmp    f01011d8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101128:	83 ec 08             	sub    $0x8,%esp
f010112b:	57                   	push   %edi
f010112c:	6a 2d                	push   $0x2d
f010112e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101131:	f7 db                	neg    %ebx
f0101133:	83 d6 00             	adc    $0x0,%esi
f0101136:	f7 de                	neg    %esi
f0101138:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010113b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101140:	e9 93 00 00 00       	jmp    f01011d8 <vprintfmt+0x32f>
f0101145:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101148:	89 ca                	mov    %ecx,%edx
f010114a:	8d 45 14             	lea    0x14(%ebp),%eax
f010114d:	e8 b4 fc ff ff       	call   f0100e06 <getuint>
f0101152:	89 c3                	mov    %eax,%ebx
f0101154:	89 d6                	mov    %edx,%esi
			base = 10;
f0101156:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010115b:	eb 7b                	jmp    f01011d8 <vprintfmt+0x32f>
f010115d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0101160:	89 ca                	mov    %ecx,%edx
f0101162:	8d 45 14             	lea    0x14(%ebp),%eax
f0101165:	e8 d6 fc ff ff       	call   f0100e40 <getint>
f010116a:	89 c3                	mov    %eax,%ebx
f010116c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f010116e:	85 d2                	test   %edx,%edx
f0101170:	78 07                	js     f0101179 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0101172:	b8 08 00 00 00       	mov    $0x8,%eax
f0101177:	eb 5f                	jmp    f01011d8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0101179:	83 ec 08             	sub    $0x8,%esp
f010117c:	57                   	push   %edi
f010117d:	6a 2d                	push   $0x2d
f010117f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0101182:	f7 db                	neg    %ebx
f0101184:	83 d6 00             	adc    $0x0,%esi
f0101187:	f7 de                	neg    %esi
f0101189:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f010118c:	b8 08 00 00 00       	mov    $0x8,%eax
f0101191:	eb 45                	jmp    f01011d8 <vprintfmt+0x32f>
f0101193:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0101196:	83 ec 08             	sub    $0x8,%esp
f0101199:	57                   	push   %edi
f010119a:	6a 30                	push   $0x30
f010119c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010119f:	83 c4 08             	add    $0x8,%esp
f01011a2:	57                   	push   %edi
f01011a3:	6a 78                	push   $0x78
f01011a5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01011a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ab:	8d 50 04             	lea    0x4(%eax),%edx
f01011ae:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01011b1:	8b 18                	mov    (%eax),%ebx
f01011b3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01011b8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01011bb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01011c0:	eb 16                	jmp    f01011d8 <vprintfmt+0x32f>
f01011c2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01011c5:	89 ca                	mov    %ecx,%edx
f01011c7:	8d 45 14             	lea    0x14(%ebp),%eax
f01011ca:	e8 37 fc ff ff       	call   f0100e06 <getuint>
f01011cf:	89 c3                	mov    %eax,%ebx
f01011d1:	89 d6                	mov    %edx,%esi
			base = 16;
f01011d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011d8:	83 ec 0c             	sub    $0xc,%esp
f01011db:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01011df:	52                   	push   %edx
f01011e0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011e3:	50                   	push   %eax
f01011e4:	56                   	push   %esi
f01011e5:	53                   	push   %ebx
f01011e6:	89 fa                	mov    %edi,%edx
f01011e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01011eb:	e8 68 fb ff ff       	call   f0100d58 <printnum>
			break;
f01011f0:	83 c4 20             	add    $0x20,%esp
f01011f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01011f6:	e9 d2 fc ff ff       	jmp    f0100ecd <vprintfmt+0x24>
f01011fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011fe:	83 ec 08             	sub    $0x8,%esp
f0101201:	57                   	push   %edi
f0101202:	52                   	push   %edx
f0101203:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101206:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101209:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010120c:	e9 bc fc ff ff       	jmp    f0100ecd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101211:	83 ec 08             	sub    $0x8,%esp
f0101214:	57                   	push   %edi
f0101215:	6a 25                	push   $0x25
f0101217:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010121a:	83 c4 10             	add    $0x10,%esp
f010121d:	eb 02                	jmp    f0101221 <vprintfmt+0x378>
f010121f:	89 c6                	mov    %eax,%esi
f0101221:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101224:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101228:	75 f5                	jne    f010121f <vprintfmt+0x376>
f010122a:	e9 9e fc ff ff       	jmp    f0100ecd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010122f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101232:	5b                   	pop    %ebx
f0101233:	5e                   	pop    %esi
f0101234:	5f                   	pop    %edi
f0101235:	c9                   	leave  
f0101236:	c3                   	ret    

f0101237 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101237:	55                   	push   %ebp
f0101238:	89 e5                	mov    %esp,%ebp
f010123a:	83 ec 18             	sub    $0x18,%esp
f010123d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101240:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101243:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101246:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010124a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010124d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101254:	85 c0                	test   %eax,%eax
f0101256:	74 26                	je     f010127e <vsnprintf+0x47>
f0101258:	85 d2                	test   %edx,%edx
f010125a:	7e 29                	jle    f0101285 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010125c:	ff 75 14             	pushl  0x14(%ebp)
f010125f:	ff 75 10             	pushl  0x10(%ebp)
f0101262:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101265:	50                   	push   %eax
f0101266:	68 72 0e 10 f0       	push   $0xf0100e72
f010126b:	e8 39 fc ff ff       	call   f0100ea9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101270:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101273:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101279:	83 c4 10             	add    $0x10,%esp
f010127c:	eb 0c                	jmp    f010128a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101283:	eb 05                	jmp    f010128a <vsnprintf+0x53>
f0101285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010128a:	c9                   	leave  
f010128b:	c3                   	ret    

f010128c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010128c:	55                   	push   %ebp
f010128d:	89 e5                	mov    %esp,%ebp
f010128f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101292:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101295:	50                   	push   %eax
f0101296:	ff 75 10             	pushl  0x10(%ebp)
f0101299:	ff 75 0c             	pushl  0xc(%ebp)
f010129c:	ff 75 08             	pushl  0x8(%ebp)
f010129f:	e8 93 ff ff ff       	call   f0101237 <vsnprintf>
	va_end(ap);

	return rc;
}
f01012a4:	c9                   	leave  
f01012a5:	c3                   	ret    
	...

f01012a8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012a8:	55                   	push   %ebp
f01012a9:	89 e5                	mov    %esp,%ebp
f01012ab:	57                   	push   %edi
f01012ac:	56                   	push   %esi
f01012ad:	53                   	push   %ebx
f01012ae:	83 ec 0c             	sub    $0xc,%esp
f01012b1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012b4:	85 c0                	test   %eax,%eax
f01012b6:	74 11                	je     f01012c9 <readline+0x21>
		cprintf("%s", prompt);
f01012b8:	83 ec 08             	sub    $0x8,%esp
f01012bb:	50                   	push   %eax
f01012bc:	68 16 21 10 f0       	push   $0xf0102116
f01012c1:	e8 4b f7 ff ff       	call   f0100a11 <cprintf>
f01012c6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01012c9:	83 ec 0c             	sub    $0xc,%esp
f01012cc:	6a 00                	push   $0x0
f01012ce:	e8 50 f3 ff ff       	call   f0100623 <iscons>
f01012d3:	89 c7                	mov    %eax,%edi
f01012d5:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01012d8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012dd:	e8 30 f3 ff ff       	call   f0100612 <getchar>
f01012e2:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012e4:	85 c0                	test   %eax,%eax
f01012e6:	79 18                	jns    f0101300 <readline+0x58>
			cprintf("read error: %e\n", c);
f01012e8:	83 ec 08             	sub    $0x8,%esp
f01012eb:	50                   	push   %eax
f01012ec:	68 f8 22 10 f0       	push   $0xf01022f8
f01012f1:	e8 1b f7 ff ff       	call   f0100a11 <cprintf>
			return NULL;
f01012f6:	83 c4 10             	add    $0x10,%esp
f01012f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01012fe:	eb 6f                	jmp    f010136f <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101300:	83 f8 08             	cmp    $0x8,%eax
f0101303:	74 05                	je     f010130a <readline+0x62>
f0101305:	83 f8 7f             	cmp    $0x7f,%eax
f0101308:	75 18                	jne    f0101322 <readline+0x7a>
f010130a:	85 f6                	test   %esi,%esi
f010130c:	7e 14                	jle    f0101322 <readline+0x7a>
			if (echoing)
f010130e:	85 ff                	test   %edi,%edi
f0101310:	74 0d                	je     f010131f <readline+0x77>
				cputchar('\b');
f0101312:	83 ec 0c             	sub    $0xc,%esp
f0101315:	6a 08                	push   $0x8
f0101317:	e8 e6 f2 ff ff       	call   f0100602 <cputchar>
f010131c:	83 c4 10             	add    $0x10,%esp
			i--;
f010131f:	4e                   	dec    %esi
f0101320:	eb bb                	jmp    f01012dd <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101322:	83 fb 1f             	cmp    $0x1f,%ebx
f0101325:	7e 21                	jle    f0101348 <readline+0xa0>
f0101327:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010132d:	7f 19                	jg     f0101348 <readline+0xa0>
			if (echoing)
f010132f:	85 ff                	test   %edi,%edi
f0101331:	74 0c                	je     f010133f <readline+0x97>
				cputchar(c);
f0101333:	83 ec 0c             	sub    $0xc,%esp
f0101336:	53                   	push   %ebx
f0101337:	e8 c6 f2 ff ff       	call   f0100602 <cputchar>
f010133c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010133f:	88 9e 40 85 11 f0    	mov    %bl,-0xfee7ac0(%esi)
f0101345:	46                   	inc    %esi
f0101346:	eb 95                	jmp    f01012dd <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101348:	83 fb 0a             	cmp    $0xa,%ebx
f010134b:	74 05                	je     f0101352 <readline+0xaa>
f010134d:	83 fb 0d             	cmp    $0xd,%ebx
f0101350:	75 8b                	jne    f01012dd <readline+0x35>
			if (echoing)
f0101352:	85 ff                	test   %edi,%edi
f0101354:	74 0d                	je     f0101363 <readline+0xbb>
				cputchar('\n');
f0101356:	83 ec 0c             	sub    $0xc,%esp
f0101359:	6a 0a                	push   $0xa
f010135b:	e8 a2 f2 ff ff       	call   f0100602 <cputchar>
f0101360:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101363:	c6 86 40 85 11 f0 00 	movb   $0x0,-0xfee7ac0(%esi)
			return buf;
f010136a:	b8 40 85 11 f0       	mov    $0xf0118540,%eax
		}
	}
}
f010136f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101372:	5b                   	pop    %ebx
f0101373:	5e                   	pop    %esi
f0101374:	5f                   	pop    %edi
f0101375:	c9                   	leave  
f0101376:	c3                   	ret    
	...

f0101378 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101378:	55                   	push   %ebp
f0101379:	89 e5                	mov    %esp,%ebp
f010137b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010137e:	80 3a 00             	cmpb   $0x0,(%edx)
f0101381:	74 0e                	je     f0101391 <strlen+0x19>
f0101383:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101388:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101389:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010138d:	75 f9                	jne    f0101388 <strlen+0x10>
f010138f:	eb 05                	jmp    f0101396 <strlen+0x1e>
f0101391:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101396:	c9                   	leave  
f0101397:	c3                   	ret    

f0101398 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101398:	55                   	push   %ebp
f0101399:	89 e5                	mov    %esp,%ebp
f010139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010139e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013a1:	85 d2                	test   %edx,%edx
f01013a3:	74 17                	je     f01013bc <strnlen+0x24>
f01013a5:	80 39 00             	cmpb   $0x0,(%ecx)
f01013a8:	74 19                	je     f01013c3 <strnlen+0x2b>
f01013aa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01013af:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013b0:	39 d0                	cmp    %edx,%eax
f01013b2:	74 14                	je     f01013c8 <strnlen+0x30>
f01013b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01013b8:	75 f5                	jne    f01013af <strnlen+0x17>
f01013ba:	eb 0c                	jmp    f01013c8 <strnlen+0x30>
f01013bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01013c1:	eb 05                	jmp    f01013c8 <strnlen+0x30>
f01013c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01013c8:	c9                   	leave  
f01013c9:	c3                   	ret    

f01013ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013ca:	55                   	push   %ebp
f01013cb:	89 e5                	mov    %esp,%ebp
f01013cd:	53                   	push   %ebx
f01013ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01013d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01013d9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01013dc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01013df:	42                   	inc    %edx
f01013e0:	84 c9                	test   %cl,%cl
f01013e2:	75 f5                	jne    f01013d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01013e4:	5b                   	pop    %ebx
f01013e5:	c9                   	leave  
f01013e6:	c3                   	ret    

f01013e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013e7:	55                   	push   %ebp
f01013e8:	89 e5                	mov    %esp,%ebp
f01013ea:	53                   	push   %ebx
f01013eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013ee:	53                   	push   %ebx
f01013ef:	e8 84 ff ff ff       	call   f0101378 <strlen>
f01013f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01013f7:	ff 75 0c             	pushl  0xc(%ebp)
f01013fa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01013fd:	50                   	push   %eax
f01013fe:	e8 c7 ff ff ff       	call   f01013ca <strcpy>
	return dst;
}
f0101403:	89 d8                	mov    %ebx,%eax
f0101405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101408:	c9                   	leave  
f0101409:	c3                   	ret    

f010140a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010140a:	55                   	push   %ebp
f010140b:	89 e5                	mov    %esp,%ebp
f010140d:	56                   	push   %esi
f010140e:	53                   	push   %ebx
f010140f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101412:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101415:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101418:	85 f6                	test   %esi,%esi
f010141a:	74 15                	je     f0101431 <strncpy+0x27>
f010141c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101421:	8a 1a                	mov    (%edx),%bl
f0101423:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101426:	80 3a 01             	cmpb   $0x1,(%edx)
f0101429:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010142c:	41                   	inc    %ecx
f010142d:	39 ce                	cmp    %ecx,%esi
f010142f:	77 f0                	ja     f0101421 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101431:	5b                   	pop    %ebx
f0101432:	5e                   	pop    %esi
f0101433:	c9                   	leave  
f0101434:	c3                   	ret    

f0101435 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101435:	55                   	push   %ebp
f0101436:	89 e5                	mov    %esp,%ebp
f0101438:	57                   	push   %edi
f0101439:	56                   	push   %esi
f010143a:	53                   	push   %ebx
f010143b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010143e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101441:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101444:	85 f6                	test   %esi,%esi
f0101446:	74 32                	je     f010147a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0101448:	83 fe 01             	cmp    $0x1,%esi
f010144b:	74 22                	je     f010146f <strlcpy+0x3a>
f010144d:	8a 0b                	mov    (%ebx),%cl
f010144f:	84 c9                	test   %cl,%cl
f0101451:	74 20                	je     f0101473 <strlcpy+0x3e>
f0101453:	89 f8                	mov    %edi,%eax
f0101455:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010145a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010145d:	88 08                	mov    %cl,(%eax)
f010145f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101460:	39 f2                	cmp    %esi,%edx
f0101462:	74 11                	je     f0101475 <strlcpy+0x40>
f0101464:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0101468:	42                   	inc    %edx
f0101469:	84 c9                	test   %cl,%cl
f010146b:	75 f0                	jne    f010145d <strlcpy+0x28>
f010146d:	eb 06                	jmp    f0101475 <strlcpy+0x40>
f010146f:	89 f8                	mov    %edi,%eax
f0101471:	eb 02                	jmp    f0101475 <strlcpy+0x40>
f0101473:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101475:	c6 00 00             	movb   $0x0,(%eax)
f0101478:	eb 02                	jmp    f010147c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010147a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f010147c:	29 f8                	sub    %edi,%eax
}
f010147e:	5b                   	pop    %ebx
f010147f:	5e                   	pop    %esi
f0101480:	5f                   	pop    %edi
f0101481:	c9                   	leave  
f0101482:	c3                   	ret    

f0101483 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101483:	55                   	push   %ebp
f0101484:	89 e5                	mov    %esp,%ebp
f0101486:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101489:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010148c:	8a 01                	mov    (%ecx),%al
f010148e:	84 c0                	test   %al,%al
f0101490:	74 10                	je     f01014a2 <strcmp+0x1f>
f0101492:	3a 02                	cmp    (%edx),%al
f0101494:	75 0c                	jne    f01014a2 <strcmp+0x1f>
		p++, q++;
f0101496:	41                   	inc    %ecx
f0101497:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101498:	8a 01                	mov    (%ecx),%al
f010149a:	84 c0                	test   %al,%al
f010149c:	74 04                	je     f01014a2 <strcmp+0x1f>
f010149e:	3a 02                	cmp    (%edx),%al
f01014a0:	74 f4                	je     f0101496 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01014a2:	0f b6 c0             	movzbl %al,%eax
f01014a5:	0f b6 12             	movzbl (%edx),%edx
f01014a8:	29 d0                	sub    %edx,%eax
}
f01014aa:	c9                   	leave  
f01014ab:	c3                   	ret    

f01014ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014ac:	55                   	push   %ebp
f01014ad:	89 e5                	mov    %esp,%ebp
f01014af:	53                   	push   %ebx
f01014b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01014b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014b6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01014b9:	85 c0                	test   %eax,%eax
f01014bb:	74 1b                	je     f01014d8 <strncmp+0x2c>
f01014bd:	8a 1a                	mov    (%edx),%bl
f01014bf:	84 db                	test   %bl,%bl
f01014c1:	74 24                	je     f01014e7 <strncmp+0x3b>
f01014c3:	3a 19                	cmp    (%ecx),%bl
f01014c5:	75 20                	jne    f01014e7 <strncmp+0x3b>
f01014c7:	48                   	dec    %eax
f01014c8:	74 15                	je     f01014df <strncmp+0x33>
		n--, p++, q++;
f01014ca:	42                   	inc    %edx
f01014cb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01014cc:	8a 1a                	mov    (%edx),%bl
f01014ce:	84 db                	test   %bl,%bl
f01014d0:	74 15                	je     f01014e7 <strncmp+0x3b>
f01014d2:	3a 19                	cmp    (%ecx),%bl
f01014d4:	74 f1                	je     f01014c7 <strncmp+0x1b>
f01014d6:	eb 0f                	jmp    f01014e7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01014d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01014dd:	eb 05                	jmp    f01014e4 <strncmp+0x38>
f01014df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01014e4:	5b                   	pop    %ebx
f01014e5:	c9                   	leave  
f01014e6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014e7:	0f b6 02             	movzbl (%edx),%eax
f01014ea:	0f b6 11             	movzbl (%ecx),%edx
f01014ed:	29 d0                	sub    %edx,%eax
f01014ef:	eb f3                	jmp    f01014e4 <strncmp+0x38>

f01014f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014f1:	55                   	push   %ebp
f01014f2:	89 e5                	mov    %esp,%ebp
f01014f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01014f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01014fa:	8a 10                	mov    (%eax),%dl
f01014fc:	84 d2                	test   %dl,%dl
f01014fe:	74 18                	je     f0101518 <strchr+0x27>
		if (*s == c)
f0101500:	38 ca                	cmp    %cl,%dl
f0101502:	75 06                	jne    f010150a <strchr+0x19>
f0101504:	eb 17                	jmp    f010151d <strchr+0x2c>
f0101506:	38 ca                	cmp    %cl,%dl
f0101508:	74 13                	je     f010151d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010150a:	40                   	inc    %eax
f010150b:	8a 10                	mov    (%eax),%dl
f010150d:	84 d2                	test   %dl,%dl
f010150f:	75 f5                	jne    f0101506 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0101511:	b8 00 00 00 00       	mov    $0x0,%eax
f0101516:	eb 05                	jmp    f010151d <strchr+0x2c>
f0101518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010151d:	c9                   	leave  
f010151e:	c3                   	ret    

f010151f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010151f:	55                   	push   %ebp
f0101520:	89 e5                	mov    %esp,%ebp
f0101522:	8b 45 08             	mov    0x8(%ebp),%eax
f0101525:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101528:	8a 10                	mov    (%eax),%dl
f010152a:	84 d2                	test   %dl,%dl
f010152c:	74 11                	je     f010153f <strfind+0x20>
		if (*s == c)
f010152e:	38 ca                	cmp    %cl,%dl
f0101530:	75 06                	jne    f0101538 <strfind+0x19>
f0101532:	eb 0b                	jmp    f010153f <strfind+0x20>
f0101534:	38 ca                	cmp    %cl,%dl
f0101536:	74 07                	je     f010153f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101538:	40                   	inc    %eax
f0101539:	8a 10                	mov    (%eax),%dl
f010153b:	84 d2                	test   %dl,%dl
f010153d:	75 f5                	jne    f0101534 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010153f:	c9                   	leave  
f0101540:	c3                   	ret    

f0101541 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101541:	55                   	push   %ebp
f0101542:	89 e5                	mov    %esp,%ebp
f0101544:	57                   	push   %edi
f0101545:	56                   	push   %esi
f0101546:	53                   	push   %ebx
f0101547:	8b 7d 08             	mov    0x8(%ebp),%edi
f010154a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010154d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101550:	85 c9                	test   %ecx,%ecx
f0101552:	74 30                	je     f0101584 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101554:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010155a:	75 25                	jne    f0101581 <memset+0x40>
f010155c:	f6 c1 03             	test   $0x3,%cl
f010155f:	75 20                	jne    f0101581 <memset+0x40>
		c &= 0xFF;
f0101561:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101564:	89 d3                	mov    %edx,%ebx
f0101566:	c1 e3 08             	shl    $0x8,%ebx
f0101569:	89 d6                	mov    %edx,%esi
f010156b:	c1 e6 18             	shl    $0x18,%esi
f010156e:	89 d0                	mov    %edx,%eax
f0101570:	c1 e0 10             	shl    $0x10,%eax
f0101573:	09 f0                	or     %esi,%eax
f0101575:	09 d0                	or     %edx,%eax
f0101577:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101579:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010157c:	fc                   	cld    
f010157d:	f3 ab                	rep stos %eax,%es:(%edi)
f010157f:	eb 03                	jmp    f0101584 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101581:	fc                   	cld    
f0101582:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101584:	89 f8                	mov    %edi,%eax
f0101586:	5b                   	pop    %ebx
f0101587:	5e                   	pop    %esi
f0101588:	5f                   	pop    %edi
f0101589:	c9                   	leave  
f010158a:	c3                   	ret    

f010158b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010158b:	55                   	push   %ebp
f010158c:	89 e5                	mov    %esp,%ebp
f010158e:	57                   	push   %edi
f010158f:	56                   	push   %esi
f0101590:	8b 45 08             	mov    0x8(%ebp),%eax
f0101593:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101596:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101599:	39 c6                	cmp    %eax,%esi
f010159b:	73 34                	jae    f01015d1 <memmove+0x46>
f010159d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01015a0:	39 d0                	cmp    %edx,%eax
f01015a2:	73 2d                	jae    f01015d1 <memmove+0x46>
		s += n;
		d += n;
f01015a4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015a7:	f6 c2 03             	test   $0x3,%dl
f01015aa:	75 1b                	jne    f01015c7 <memmove+0x3c>
f01015ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015b2:	75 13                	jne    f01015c7 <memmove+0x3c>
f01015b4:	f6 c1 03             	test   $0x3,%cl
f01015b7:	75 0e                	jne    f01015c7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01015b9:	83 ef 04             	sub    $0x4,%edi
f01015bc:	8d 72 fc             	lea    -0x4(%edx),%esi
f01015bf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01015c2:	fd                   	std    
f01015c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015c5:	eb 07                	jmp    f01015ce <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01015c7:	4f                   	dec    %edi
f01015c8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01015cb:	fd                   	std    
f01015cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01015ce:	fc                   	cld    
f01015cf:	eb 20                	jmp    f01015f1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01015d7:	75 13                	jne    f01015ec <memmove+0x61>
f01015d9:	a8 03                	test   $0x3,%al
f01015db:	75 0f                	jne    f01015ec <memmove+0x61>
f01015dd:	f6 c1 03             	test   $0x3,%cl
f01015e0:	75 0a                	jne    f01015ec <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01015e2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01015e5:	89 c7                	mov    %eax,%edi
f01015e7:	fc                   	cld    
f01015e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015ea:	eb 05                	jmp    f01015f1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01015ec:	89 c7                	mov    %eax,%edi
f01015ee:	fc                   	cld    
f01015ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01015f1:	5e                   	pop    %esi
f01015f2:	5f                   	pop    %edi
f01015f3:	c9                   	leave  
f01015f4:	c3                   	ret    

f01015f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015f5:	55                   	push   %ebp
f01015f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01015f8:	ff 75 10             	pushl  0x10(%ebp)
f01015fb:	ff 75 0c             	pushl  0xc(%ebp)
f01015fe:	ff 75 08             	pushl  0x8(%ebp)
f0101601:	e8 85 ff ff ff       	call   f010158b <memmove>
}
f0101606:	c9                   	leave  
f0101607:	c3                   	ret    

f0101608 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101608:	55                   	push   %ebp
f0101609:	89 e5                	mov    %esp,%ebp
f010160b:	57                   	push   %edi
f010160c:	56                   	push   %esi
f010160d:	53                   	push   %ebx
f010160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101611:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101614:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101617:	85 ff                	test   %edi,%edi
f0101619:	74 32                	je     f010164d <memcmp+0x45>
		if (*s1 != *s2)
f010161b:	8a 03                	mov    (%ebx),%al
f010161d:	8a 0e                	mov    (%esi),%cl
f010161f:	38 c8                	cmp    %cl,%al
f0101621:	74 19                	je     f010163c <memcmp+0x34>
f0101623:	eb 0d                	jmp    f0101632 <memcmp+0x2a>
f0101625:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0101629:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010162d:	42                   	inc    %edx
f010162e:	38 c8                	cmp    %cl,%al
f0101630:	74 10                	je     f0101642 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0101632:	0f b6 c0             	movzbl %al,%eax
f0101635:	0f b6 c9             	movzbl %cl,%ecx
f0101638:	29 c8                	sub    %ecx,%eax
f010163a:	eb 16                	jmp    f0101652 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010163c:	4f                   	dec    %edi
f010163d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101642:	39 fa                	cmp    %edi,%edx
f0101644:	75 df                	jne    f0101625 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101646:	b8 00 00 00 00       	mov    $0x0,%eax
f010164b:	eb 05                	jmp    f0101652 <memcmp+0x4a>
f010164d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101652:	5b                   	pop    %ebx
f0101653:	5e                   	pop    %esi
f0101654:	5f                   	pop    %edi
f0101655:	c9                   	leave  
f0101656:	c3                   	ret    

f0101657 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101657:	55                   	push   %ebp
f0101658:	89 e5                	mov    %esp,%ebp
f010165a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010165d:	89 c2                	mov    %eax,%edx
f010165f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101662:	39 d0                	cmp    %edx,%eax
f0101664:	73 12                	jae    f0101678 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101666:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0101669:	38 08                	cmp    %cl,(%eax)
f010166b:	75 06                	jne    f0101673 <memfind+0x1c>
f010166d:	eb 09                	jmp    f0101678 <memfind+0x21>
f010166f:	38 08                	cmp    %cl,(%eax)
f0101671:	74 05                	je     f0101678 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101673:	40                   	inc    %eax
f0101674:	39 c2                	cmp    %eax,%edx
f0101676:	77 f7                	ja     f010166f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101678:	c9                   	leave  
f0101679:	c3                   	ret    

f010167a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010167a:	55                   	push   %ebp
f010167b:	89 e5                	mov    %esp,%ebp
f010167d:	57                   	push   %edi
f010167e:	56                   	push   %esi
f010167f:	53                   	push   %ebx
f0101680:	8b 55 08             	mov    0x8(%ebp),%edx
f0101683:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101686:	eb 01                	jmp    f0101689 <strtol+0xf>
		s++;
f0101688:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101689:	8a 02                	mov    (%edx),%al
f010168b:	3c 20                	cmp    $0x20,%al
f010168d:	74 f9                	je     f0101688 <strtol+0xe>
f010168f:	3c 09                	cmp    $0x9,%al
f0101691:	74 f5                	je     f0101688 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101693:	3c 2b                	cmp    $0x2b,%al
f0101695:	75 08                	jne    f010169f <strtol+0x25>
		s++;
f0101697:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101698:	bf 00 00 00 00       	mov    $0x0,%edi
f010169d:	eb 13                	jmp    f01016b2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010169f:	3c 2d                	cmp    $0x2d,%al
f01016a1:	75 0a                	jne    f01016ad <strtol+0x33>
		s++, neg = 1;
f01016a3:	8d 52 01             	lea    0x1(%edx),%edx
f01016a6:	bf 01 00 00 00       	mov    $0x1,%edi
f01016ab:	eb 05                	jmp    f01016b2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01016ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016b2:	85 db                	test   %ebx,%ebx
f01016b4:	74 05                	je     f01016bb <strtol+0x41>
f01016b6:	83 fb 10             	cmp    $0x10,%ebx
f01016b9:	75 28                	jne    f01016e3 <strtol+0x69>
f01016bb:	8a 02                	mov    (%edx),%al
f01016bd:	3c 30                	cmp    $0x30,%al
f01016bf:	75 10                	jne    f01016d1 <strtol+0x57>
f01016c1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01016c5:	75 0a                	jne    f01016d1 <strtol+0x57>
		s += 2, base = 16;
f01016c7:	83 c2 02             	add    $0x2,%edx
f01016ca:	bb 10 00 00 00       	mov    $0x10,%ebx
f01016cf:	eb 12                	jmp    f01016e3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01016d1:	85 db                	test   %ebx,%ebx
f01016d3:	75 0e                	jne    f01016e3 <strtol+0x69>
f01016d5:	3c 30                	cmp    $0x30,%al
f01016d7:	75 05                	jne    f01016de <strtol+0x64>
		s++, base = 8;
f01016d9:	42                   	inc    %edx
f01016da:	b3 08                	mov    $0x8,%bl
f01016dc:	eb 05                	jmp    f01016e3 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01016de:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01016e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01016e8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01016ea:	8a 0a                	mov    (%edx),%cl
f01016ec:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01016ef:	80 fb 09             	cmp    $0x9,%bl
f01016f2:	77 08                	ja     f01016fc <strtol+0x82>
			dig = *s - '0';
f01016f4:	0f be c9             	movsbl %cl,%ecx
f01016f7:	83 e9 30             	sub    $0x30,%ecx
f01016fa:	eb 1e                	jmp    f010171a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01016fc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01016ff:	80 fb 19             	cmp    $0x19,%bl
f0101702:	77 08                	ja     f010170c <strtol+0x92>
			dig = *s - 'a' + 10;
f0101704:	0f be c9             	movsbl %cl,%ecx
f0101707:	83 e9 57             	sub    $0x57,%ecx
f010170a:	eb 0e                	jmp    f010171a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010170c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010170f:	80 fb 19             	cmp    $0x19,%bl
f0101712:	77 13                	ja     f0101727 <strtol+0xad>
			dig = *s - 'A' + 10;
f0101714:	0f be c9             	movsbl %cl,%ecx
f0101717:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010171a:	39 f1                	cmp    %esi,%ecx
f010171c:	7d 0d                	jge    f010172b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010171e:	42                   	inc    %edx
f010171f:	0f af c6             	imul   %esi,%eax
f0101722:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101725:	eb c3                	jmp    f01016ea <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101727:	89 c1                	mov    %eax,%ecx
f0101729:	eb 02                	jmp    f010172d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010172b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010172d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101731:	74 05                	je     f0101738 <strtol+0xbe>
		*endptr = (char *) s;
f0101733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101736:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101738:	85 ff                	test   %edi,%edi
f010173a:	74 04                	je     f0101740 <strtol+0xc6>
f010173c:	89 c8                	mov    %ecx,%eax
f010173e:	f7 d8                	neg    %eax
}
f0101740:	5b                   	pop    %ebx
f0101741:	5e                   	pop    %esi
f0101742:	5f                   	pop    %edi
f0101743:	c9                   	leave  
f0101744:	c3                   	ret    
f0101745:	00 00                	add    %al,(%eax)
	...

f0101748 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0101748:	55                   	push   %ebp
f0101749:	89 e5                	mov    %esp,%ebp
f010174b:	57                   	push   %edi
f010174c:	56                   	push   %esi
f010174d:	83 ec 10             	sub    $0x10,%esp
f0101750:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101753:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0101756:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0101759:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010175c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010175f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101762:	85 c0                	test   %eax,%eax
f0101764:	75 2e                	jne    f0101794 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0101766:	39 f1                	cmp    %esi,%ecx
f0101768:	77 5a                	ja     f01017c4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010176a:	85 c9                	test   %ecx,%ecx
f010176c:	75 0b                	jne    f0101779 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010176e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101773:	31 d2                	xor    %edx,%edx
f0101775:	f7 f1                	div    %ecx
f0101777:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101779:	31 d2                	xor    %edx,%edx
f010177b:	89 f0                	mov    %esi,%eax
f010177d:	f7 f1                	div    %ecx
f010177f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101781:	89 f8                	mov    %edi,%eax
f0101783:	f7 f1                	div    %ecx
f0101785:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101787:	89 f8                	mov    %edi,%eax
f0101789:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010178b:	83 c4 10             	add    $0x10,%esp
f010178e:	5e                   	pop    %esi
f010178f:	5f                   	pop    %edi
f0101790:	c9                   	leave  
f0101791:	c3                   	ret    
f0101792:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101794:	39 f0                	cmp    %esi,%eax
f0101796:	77 1c                	ja     f01017b4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101798:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f010179b:	83 f7 1f             	xor    $0x1f,%edi
f010179e:	75 3c                	jne    f01017dc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01017a0:	39 f0                	cmp    %esi,%eax
f01017a2:	0f 82 90 00 00 00    	jb     f0101838 <__udivdi3+0xf0>
f01017a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01017ab:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01017ae:	0f 86 84 00 00 00    	jbe    f0101838 <__udivdi3+0xf0>
f01017b4:	31 f6                	xor    %esi,%esi
f01017b6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01017b8:	89 f8                	mov    %edi,%eax
f01017ba:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01017bc:	83 c4 10             	add    $0x10,%esp
f01017bf:	5e                   	pop    %esi
f01017c0:	5f                   	pop    %edi
f01017c1:	c9                   	leave  
f01017c2:	c3                   	ret    
f01017c3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01017c4:	89 f2                	mov    %esi,%edx
f01017c6:	89 f8                	mov    %edi,%eax
f01017c8:	f7 f1                	div    %ecx
f01017ca:	89 c7                	mov    %eax,%edi
f01017cc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01017ce:	89 f8                	mov    %edi,%eax
f01017d0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	5e                   	pop    %esi
f01017d6:	5f                   	pop    %edi
f01017d7:	c9                   	leave  
f01017d8:	c3                   	ret    
f01017d9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01017dc:	89 f9                	mov    %edi,%ecx
f01017de:	d3 e0                	shl    %cl,%eax
f01017e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01017e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01017e8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017ed:	88 c1                	mov    %al,%cl
f01017ef:	d3 ea                	shr    %cl,%edx
f01017f1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01017f4:	09 ca                	or     %ecx,%edx
f01017f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01017f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017fc:	89 f9                	mov    %edi,%ecx
f01017fe:	d3 e2                	shl    %cl,%edx
f0101800:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0101803:	89 f2                	mov    %esi,%edx
f0101805:	88 c1                	mov    %al,%cl
f0101807:	d3 ea                	shr    %cl,%edx
f0101809:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f010180c:	89 f2                	mov    %esi,%edx
f010180e:	89 f9                	mov    %edi,%ecx
f0101810:	d3 e2                	shl    %cl,%edx
f0101812:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101815:	88 c1                	mov    %al,%cl
f0101817:	d3 ee                	shr    %cl,%esi
f0101819:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010181b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010181e:	89 f0                	mov    %esi,%eax
f0101820:	89 ca                	mov    %ecx,%edx
f0101822:	f7 75 ec             	divl   -0x14(%ebp)
f0101825:	89 d1                	mov    %edx,%ecx
f0101827:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101829:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010182c:	39 d1                	cmp    %edx,%ecx
f010182e:	72 28                	jb     f0101858 <__udivdi3+0x110>
f0101830:	74 1a                	je     f010184c <__udivdi3+0x104>
f0101832:	89 f7                	mov    %esi,%edi
f0101834:	31 f6                	xor    %esi,%esi
f0101836:	eb 80                	jmp    f01017b8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101838:	31 f6                	xor    %esi,%esi
f010183a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010183f:	89 f8                	mov    %edi,%eax
f0101841:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101843:	83 c4 10             	add    $0x10,%esp
f0101846:	5e                   	pop    %esi
f0101847:	5f                   	pop    %edi
f0101848:	c9                   	leave  
f0101849:	c3                   	ret    
f010184a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f010184c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010184f:	89 f9                	mov    %edi,%ecx
f0101851:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101853:	39 c2                	cmp    %eax,%edx
f0101855:	73 db                	jae    f0101832 <__udivdi3+0xea>
f0101857:	90                   	nop
		{
		  q0--;
f0101858:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010185b:	31 f6                	xor    %esi,%esi
f010185d:	e9 56 ff ff ff       	jmp    f01017b8 <__udivdi3+0x70>
	...

f0101864 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0101864:	55                   	push   %ebp
f0101865:	89 e5                	mov    %esp,%ebp
f0101867:	57                   	push   %edi
f0101868:	56                   	push   %esi
f0101869:	83 ec 20             	sub    $0x20,%esp
f010186c:	8b 45 08             	mov    0x8(%ebp),%eax
f010186f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0101872:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101875:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0101878:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010187b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f010187e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0101881:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101883:	85 ff                	test   %edi,%edi
f0101885:	75 15                	jne    f010189c <__umoddi3+0x38>
    {
      if (d0 > n1)
f0101887:	39 f1                	cmp    %esi,%ecx
f0101889:	0f 86 99 00 00 00    	jbe    f0101928 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010188f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0101891:	89 d0                	mov    %edx,%eax
f0101893:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101895:	83 c4 20             	add    $0x20,%esp
f0101898:	5e                   	pop    %esi
f0101899:	5f                   	pop    %edi
f010189a:	c9                   	leave  
f010189b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010189c:	39 f7                	cmp    %esi,%edi
f010189e:	0f 87 a4 00 00 00    	ja     f0101948 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01018a4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f01018a7:	83 f0 1f             	xor    $0x1f,%eax
f01018aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01018ad:	0f 84 a1 00 00 00    	je     f0101954 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01018b3:	89 f8                	mov    %edi,%eax
f01018b5:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01018b8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01018ba:	bf 20 00 00 00       	mov    $0x20,%edi
f01018bf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f01018c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01018c5:	89 f9                	mov    %edi,%ecx
f01018c7:	d3 ea                	shr    %cl,%edx
f01018c9:	09 c2                	or     %eax,%edx
f01018cb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f01018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018d1:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01018d4:	d3 e0                	shl    %cl,%eax
f01018d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01018d9:	89 f2                	mov    %esi,%edx
f01018db:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01018dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01018e0:	d3 e0                	shl    %cl,%eax
f01018e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01018e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01018e8:	89 f9                	mov    %edi,%ecx
f01018ea:	d3 e8                	shr    %cl,%eax
f01018ec:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01018ee:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01018f0:	89 f2                	mov    %esi,%edx
f01018f2:	f7 75 f0             	divl   -0x10(%ebp)
f01018f5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01018f7:	f7 65 f4             	mull   -0xc(%ebp)
f01018fa:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01018fd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01018ff:	39 d6                	cmp    %edx,%esi
f0101901:	72 71                	jb     f0101974 <__umoddi3+0x110>
f0101903:	74 7f                	je     f0101984 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101905:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101908:	29 c8                	sub    %ecx,%eax
f010190a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f010190c:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010190f:	d3 e8                	shr    %cl,%eax
f0101911:	89 f2                	mov    %esi,%edx
f0101913:	89 f9                	mov    %edi,%ecx
f0101915:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0101917:	09 d0                	or     %edx,%eax
f0101919:	89 f2                	mov    %esi,%edx
f010191b:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010191e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101920:	83 c4 20             	add    $0x20,%esp
f0101923:	5e                   	pop    %esi
f0101924:	5f                   	pop    %edi
f0101925:	c9                   	leave  
f0101926:	c3                   	ret    
f0101927:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101928:	85 c9                	test   %ecx,%ecx
f010192a:	75 0b                	jne    f0101937 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010192c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101931:	31 d2                	xor    %edx,%edx
f0101933:	f7 f1                	div    %ecx
f0101935:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101937:	89 f0                	mov    %esi,%eax
f0101939:	31 d2                	xor    %edx,%edx
f010193b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010193d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101940:	f7 f1                	div    %ecx
f0101942:	e9 4a ff ff ff       	jmp    f0101891 <__umoddi3+0x2d>
f0101947:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101948:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010194a:	83 c4 20             	add    $0x20,%esp
f010194d:	5e                   	pop    %esi
f010194e:	5f                   	pop    %edi
f010194f:	c9                   	leave  
f0101950:	c3                   	ret    
f0101951:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101954:	39 f7                	cmp    %esi,%edi
f0101956:	72 05                	jb     f010195d <__umoddi3+0xf9>
f0101958:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010195b:	77 0c                	ja     f0101969 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010195d:	89 f2                	mov    %esi,%edx
f010195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101962:	29 c8                	sub    %ecx,%eax
f0101964:	19 fa                	sbb    %edi,%edx
f0101966:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010196c:	83 c4 20             	add    $0x20,%esp
f010196f:	5e                   	pop    %esi
f0101970:	5f                   	pop    %edi
f0101971:	c9                   	leave  
f0101972:	c3                   	ret    
f0101973:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101974:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101977:	89 c1                	mov    %eax,%ecx
f0101979:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f010197c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f010197f:	eb 84                	jmp    f0101905 <__umoddi3+0xa1>
f0101981:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101984:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101987:	72 eb                	jb     f0101974 <__umoddi3+0x110>
f0101989:	89 f2                	mov    %esi,%edx
f010198b:	e9 75 ff ff ff       	jmp    f0101905 <__umoddi3+0xa1>
