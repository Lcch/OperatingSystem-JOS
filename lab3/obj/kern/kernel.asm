
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 90 7f 1d f0       	mov    $0xf01d7f90,%eax
f010004b:	2d 64 70 1d f0       	sub    $0xf01d7064,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 64 70 1d f0       	push   $0xf01d7064
f0100058:	e8 78 42 00 00       	call   f01042d5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 b1 04 00 00       	call   f0100513 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 40 47 10 f0       	push   $0xf0104740
f010006f:	e8 91 33 00 00       	call   f0103405 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 bc 15 00 00       	call   f0101635 <mem_init>

    cprintf("mem_init done! \n");
f0100079:	c7 04 24 5b 47 10 f0 	movl   $0xf010475b,(%esp)
f0100080:	e8 80 33 00 00       	call   f0103405 <cprintf>
	// Lab 3 user environment initialization functions
	env_init();
f0100085:	e8 67 2d 00 00       	call   f0102df1 <env_init>
    cprintf("env_init done! \n");
f010008a:	c7 04 24 6c 47 10 f0 	movl   $0xf010476c,(%esp)
f0100091:	e8 6f 33 00 00       	call   f0103405 <cprintf>
	trap_init();
f0100096:	e8 de 33 00 00       	call   f0103479 <trap_init>
    cprintf("trap_init done! \n");
f010009b:	c7 04 24 7d 47 10 f0 	movl   $0xf010477d,(%esp)
f01000a2:	e8 5e 33 00 00       	call   f0103405 <cprintf>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01000a7:	83 c4 0c             	add    $0xc,%esp
f01000aa:	6a 00                	push   $0x0
f01000ac:	68 5b e8 00 00       	push   $0xe85b
f01000b1:	68 40 23 12 f0       	push   $0xf0122340
f01000b6:	e8 44 2f 00 00       	call   f0102fff <env_create>
#endif // TEST*
    
    cprintf("ready env_run(&envs[0])\n");
f01000bb:	c7 04 24 8f 47 10 f0 	movl   $0xf010478f,(%esp)
f01000c2:	e8 3e 33 00 00       	call   f0103405 <cprintf>
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000c7:	83 c4 04             	add    $0x4,%esp
f01000ca:	ff 35 b8 72 1d f0    	pushl  0xf01d72b8
f01000d0:	e8 6d 32 00 00       	call   f0103342 <env_run>

f01000d5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d5:	55                   	push   %ebp
f01000d6:	89 e5                	mov    %esp,%ebp
f01000d8:	56                   	push   %esi
f01000d9:	53                   	push   %ebx
f01000da:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000dd:	83 3d 80 7f 1d f0 00 	cmpl   $0x0,0xf01d7f80
f01000e4:	75 37                	jne    f010011d <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000e6:	89 35 80 7f 1d f0    	mov    %esi,0xf01d7f80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ec:	fa                   	cli    
f01000ed:	fc                   	cld    

	va_start(ap, fmt);
f01000ee:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f1:	83 ec 04             	sub    $0x4,%esp
f01000f4:	ff 75 0c             	pushl  0xc(%ebp)
f01000f7:	ff 75 08             	pushl  0x8(%ebp)
f01000fa:	68 a8 47 10 f0       	push   $0xf01047a8
f01000ff:	e8 01 33 00 00       	call   f0103405 <cprintf>
	vcprintf(fmt, ap);
f0100104:	83 c4 08             	add    $0x8,%esp
f0100107:	53                   	push   %ebx
f0100108:	56                   	push   %esi
f0100109:	e8 d1 32 00 00       	call   f01033df <vcprintf>
	cprintf("\n");
f010010e:	c7 04 24 6a 47 10 f0 	movl   $0xf010476a,(%esp)
f0100115:	e8 eb 32 00 00       	call   f0103405 <cprintf>
	va_end(ap);
f010011a:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011d:	83 ec 0c             	sub    $0xc,%esp
f0100120:	6a 00                	push   $0x0
f0100122:	e8 d2 0c 00 00       	call   f0100df9 <monitor>
f0100127:	83 c4 10             	add    $0x10,%esp
f010012a:	eb f1                	jmp    f010011d <_panic+0x48>

f010012c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010012c:	55                   	push   %ebp
f010012d:	89 e5                	mov    %esp,%ebp
f010012f:	53                   	push   %ebx
f0100130:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100133:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100136:	ff 75 0c             	pushl  0xc(%ebp)
f0100139:	ff 75 08             	pushl  0x8(%ebp)
f010013c:	68 c0 47 10 f0       	push   $0xf01047c0
f0100141:	e8 bf 32 00 00       	call   f0103405 <cprintf>
	vcprintf(fmt, ap);
f0100146:	83 c4 08             	add    $0x8,%esp
f0100149:	53                   	push   %ebx
f010014a:	ff 75 10             	pushl  0x10(%ebp)
f010014d:	e8 8d 32 00 00       	call   f01033df <vcprintf>
	cprintf("\n");
f0100152:	c7 04 24 6a 47 10 f0 	movl   $0xf010476a,(%esp)
f0100159:	e8 a7 32 00 00       	call   f0103405 <cprintf>
	va_end(ap);
f010015e:	83 c4 10             	add    $0x10,%esp
}
f0100161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100164:	c9                   	leave  
f0100165:	c3                   	ret    
	...

f0100168 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100168:	55                   	push   %ebp
f0100169:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100170:	ec                   	in     (%dx),%al
f0100171:	ec                   	in     (%dx),%al
f0100172:	ec                   	in     (%dx),%al
f0100173:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100174:	c9                   	leave  
f0100175:	c3                   	ret    

f0100176 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100176:	55                   	push   %ebp
f0100177:	89 e5                	mov    %esp,%ebp
f0100179:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017f:	a8 01                	test   $0x1,%al
f0100181:	74 08                	je     f010018b <serial_proc_data+0x15>
f0100183:	b2 f8                	mov    $0xf8,%dl
f0100185:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100186:	0f b6 c0             	movzbl %al,%eax
f0100189:	eb 05                	jmp    f0100190 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100190:	c9                   	leave  
f0100191:	c3                   	ret    

f0100192 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100192:	55                   	push   %ebp
f0100193:	89 e5                	mov    %esp,%ebp
f0100195:	53                   	push   %ebx
f0100196:	83 ec 04             	sub    $0x4,%esp
f0100199:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019b:	eb 29                	jmp    f01001c6 <cons_intr+0x34>
		if (c == 0)
f010019d:	85 c0                	test   %eax,%eax
f010019f:	74 25                	je     f01001c6 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a1:	8b 15 a4 72 1d f0    	mov    0xf01d72a4,%edx
f01001a7:	88 82 a0 70 1d f0    	mov    %al,-0xfe28f60(%edx)
f01001ad:	8d 42 01             	lea    0x1(%edx),%eax
f01001b0:	a3 a4 72 1d f0       	mov    %eax,0xf01d72a4
		if (cons.wpos == CONSBUFSIZE)
f01001b5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ba:	75 0a                	jne    f01001c6 <cons_intr+0x34>
			cons.wpos = 0;
f01001bc:	c7 05 a4 72 1d f0 00 	movl   $0x0,0xf01d72a4
f01001c3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c6:	ff d3                	call   *%ebx
f01001c8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001cb:	75 d0                	jne    f010019d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001cd:	83 c4 04             	add    $0x4,%esp
f01001d0:	5b                   	pop    %ebx
f01001d1:	c9                   	leave  
f01001d2:	c3                   	ret    

f01001d3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001d3:	55                   	push   %ebp
f01001d4:	89 e5                	mov    %esp,%ebp
f01001d6:	57                   	push   %edi
f01001d7:	56                   	push   %esi
f01001d8:	53                   	push   %ebx
f01001d9:	83 ec 0c             	sub    $0xc,%esp
f01001dc:	89 c6                	mov    %eax,%esi
f01001de:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e3:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001e4:	a8 20                	test   $0x20,%al
f01001e6:	75 19                	jne    f0100201 <cons_putc+0x2e>
f01001e8:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001ed:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001f2:	e8 71 ff ff ff       	call   f0100168 <delay>
f01001f7:	89 fa                	mov    %edi,%edx
f01001f9:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001fa:	a8 20                	test   $0x20,%al
f01001fc:	75 03                	jne    f0100201 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001fe:	4b                   	dec    %ebx
f01001ff:	75 f1                	jne    f01001f2 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100201:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100203:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100208:	89 f0                	mov    %esi,%eax
f010020a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010020b:	b2 79                	mov    $0x79,%dl
f010020d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010020e:	84 c0                	test   %al,%al
f0100210:	78 1d                	js     f010022f <cons_putc+0x5c>
f0100212:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f0100217:	e8 4c ff ff ff       	call   f0100168 <delay>
f010021c:	ba 79 03 00 00       	mov    $0x379,%edx
f0100221:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100222:	84 c0                	test   %al,%al
f0100224:	78 09                	js     f010022f <cons_putc+0x5c>
f0100226:	43                   	inc    %ebx
f0100227:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010022d:	75 e8                	jne    f0100217 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010022f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100234:	89 f8                	mov    %edi,%eax
f0100236:	ee                   	out    %al,(%dx)
f0100237:	b2 7a                	mov    $0x7a,%dl
f0100239:	b0 0d                	mov    $0xd,%al
f010023b:	ee                   	out    %al,(%dx)
f010023c:	b0 08                	mov    $0x8,%al
f010023e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f010023f:	a1 80 70 1d f0       	mov    0xf01d7080,%eax
f0100244:	c1 e0 08             	shl    $0x8,%eax
f0100247:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100249:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010024f:	75 06                	jne    f0100257 <cons_putc+0x84>
		c |= 0x0700;
f0100251:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100257:	89 f0                	mov    %esi,%eax
f0100259:	25 ff 00 00 00       	and    $0xff,%eax
f010025e:	83 f8 09             	cmp    $0x9,%eax
f0100261:	74 78                	je     f01002db <cons_putc+0x108>
f0100263:	83 f8 09             	cmp    $0x9,%eax
f0100266:	7f 0b                	jg     f0100273 <cons_putc+0xa0>
f0100268:	83 f8 08             	cmp    $0x8,%eax
f010026b:	0f 85 9e 00 00 00    	jne    f010030f <cons_putc+0x13c>
f0100271:	eb 10                	jmp    f0100283 <cons_putc+0xb0>
f0100273:	83 f8 0a             	cmp    $0xa,%eax
f0100276:	74 39                	je     f01002b1 <cons_putc+0xde>
f0100278:	83 f8 0d             	cmp    $0xd,%eax
f010027b:	0f 85 8e 00 00 00    	jne    f010030f <cons_putc+0x13c>
f0100281:	eb 36                	jmp    f01002b9 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100283:	66 a1 84 70 1d f0    	mov    0xf01d7084,%ax
f0100289:	66 85 c0             	test   %ax,%ax
f010028c:	0f 84 e0 00 00 00    	je     f0100372 <cons_putc+0x19f>
			crt_pos--;
f0100292:	48                   	dec    %eax
f0100293:	66 a3 84 70 1d f0    	mov    %ax,0xf01d7084
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100299:	0f b7 c0             	movzwl %ax,%eax
f010029c:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002a2:	83 ce 20             	or     $0x20,%esi
f01002a5:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f01002ab:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002af:	eb 78                	jmp    f0100329 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002b1:	66 83 05 84 70 1d f0 	addw   $0x50,0xf01d7084
f01002b8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002b9:	66 8b 0d 84 70 1d f0 	mov    0xf01d7084,%cx
f01002c0:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002c5:	89 c8                	mov    %ecx,%eax
f01002c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01002cc:	66 f7 f3             	div    %bx
f01002cf:	66 29 d1             	sub    %dx,%cx
f01002d2:	66 89 0d 84 70 1d f0 	mov    %cx,0xf01d7084
f01002d9:	eb 4e                	jmp    f0100329 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002db:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e0:	e8 ee fe ff ff       	call   f01001d3 <cons_putc>
		cons_putc(' ');
f01002e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ea:	e8 e4 fe ff ff       	call   f01001d3 <cons_putc>
		cons_putc(' ');
f01002ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f4:	e8 da fe ff ff       	call   f01001d3 <cons_putc>
		cons_putc(' ');
f01002f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fe:	e8 d0 fe ff ff       	call   f01001d3 <cons_putc>
		cons_putc(' ');
f0100303:	b8 20 00 00 00       	mov    $0x20,%eax
f0100308:	e8 c6 fe ff ff       	call   f01001d3 <cons_putc>
f010030d:	eb 1a                	jmp    f0100329 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010030f:	66 a1 84 70 1d f0    	mov    0xf01d7084,%ax
f0100315:	0f b7 c8             	movzwl %ax,%ecx
f0100318:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f010031e:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100322:	40                   	inc    %eax
f0100323:	66 a3 84 70 1d f0    	mov    %ax,0xf01d7084
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f0100329:	66 81 3d 84 70 1d f0 	cmpw   $0x7cf,0xf01d7084
f0100330:	cf 07 
f0100332:	76 3e                	jbe    f0100372 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100334:	a1 88 70 1d f0       	mov    0xf01d7088,%eax
f0100339:	83 ec 04             	sub    $0x4,%esp
f010033c:	68 00 0f 00 00       	push   $0xf00
f0100341:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100347:	52                   	push   %edx
f0100348:	50                   	push   %eax
f0100349:	e8 d1 3f 00 00       	call   f010431f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010034e:	8b 15 88 70 1d f0    	mov    0xf01d7088,%edx
f0100354:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100357:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010035c:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100362:	40                   	inc    %eax
f0100363:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100368:	75 f2                	jne    f010035c <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010036a:	66 83 2d 84 70 1d f0 	subw   $0x50,0xf01d7084
f0100371:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100372:	8b 0d 8c 70 1d f0    	mov    0xf01d708c,%ecx
f0100378:	b0 0e                	mov    $0xe,%al
f010037a:	89 ca                	mov    %ecx,%edx
f010037c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010037d:	66 8b 35 84 70 1d f0 	mov    0xf01d7084,%si
f0100384:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100387:	89 f0                	mov    %esi,%eax
f0100389:	66 c1 e8 08          	shr    $0x8,%ax
f010038d:	89 da                	mov    %ebx,%edx
f010038f:	ee                   	out    %al,(%dx)
f0100390:	b0 0f                	mov    $0xf,%al
f0100392:	89 ca                	mov    %ecx,%edx
f0100394:	ee                   	out    %al,(%dx)
f0100395:	89 f0                	mov    %esi,%eax
f0100397:	89 da                	mov    %ebx,%edx
f0100399:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010039a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010039d:	5b                   	pop    %ebx
f010039e:	5e                   	pop    %esi
f010039f:	5f                   	pop    %edi
f01003a0:	c9                   	leave  
f01003a1:	c3                   	ret    

f01003a2 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003a2:	55                   	push   %ebp
f01003a3:	89 e5                	mov    %esp,%ebp
f01003a5:	53                   	push   %ebx
f01003a6:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a9:	ba 64 00 00 00       	mov    $0x64,%edx
f01003ae:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003af:	a8 01                	test   $0x1,%al
f01003b1:	0f 84 dc 00 00 00    	je     f0100493 <kbd_proc_data+0xf1>
f01003b7:	b2 60                	mov    $0x60,%dl
f01003b9:	ec                   	in     (%dx),%al
f01003ba:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003bc:	3c e0                	cmp    $0xe0,%al
f01003be:	75 11                	jne    f01003d1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003c0:	83 0d a8 72 1d f0 40 	orl    $0x40,0xf01d72a8
		return 0;
f01003c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003cc:	e9 c7 00 00 00       	jmp    f0100498 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003d1:	84 c0                	test   %al,%al
f01003d3:	79 33                	jns    f0100408 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003d5:	8b 0d a8 72 1d f0    	mov    0xf01d72a8,%ecx
f01003db:	f6 c1 40             	test   $0x40,%cl
f01003de:	75 05                	jne    f01003e5 <kbd_proc_data+0x43>
f01003e0:	88 c2                	mov    %al,%dl
f01003e2:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003e5:	0f b6 d2             	movzbl %dl,%edx
f01003e8:	8a 82 20 48 10 f0    	mov    -0xfefb7e0(%edx),%al
f01003ee:	83 c8 40             	or     $0x40,%eax
f01003f1:	0f b6 c0             	movzbl %al,%eax
f01003f4:	f7 d0                	not    %eax
f01003f6:	21 c1                	and    %eax,%ecx
f01003f8:	89 0d a8 72 1d f0    	mov    %ecx,0xf01d72a8
		return 0;
f01003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100403:	e9 90 00 00 00       	jmp    f0100498 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100408:	8b 0d a8 72 1d f0    	mov    0xf01d72a8,%ecx
f010040e:	f6 c1 40             	test   $0x40,%cl
f0100411:	74 0e                	je     f0100421 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100413:	88 c2                	mov    %al,%dl
f0100415:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100418:	83 e1 bf             	and    $0xffffffbf,%ecx
f010041b:	89 0d a8 72 1d f0    	mov    %ecx,0xf01d72a8
	}

	shift |= shiftcode[data];
f0100421:	0f b6 d2             	movzbl %dl,%edx
f0100424:	0f b6 82 20 48 10 f0 	movzbl -0xfefb7e0(%edx),%eax
f010042b:	0b 05 a8 72 1d f0    	or     0xf01d72a8,%eax
	shift ^= togglecode[data];
f0100431:	0f b6 8a 20 49 10 f0 	movzbl -0xfefb6e0(%edx),%ecx
f0100438:	31 c8                	xor    %ecx,%eax
f010043a:	a3 a8 72 1d f0       	mov    %eax,0xf01d72a8

	c = charcode[shift & (CTL | SHIFT)][data];
f010043f:	89 c1                	mov    %eax,%ecx
f0100441:	83 e1 03             	and    $0x3,%ecx
f0100444:	8b 0c 8d 20 4a 10 f0 	mov    -0xfefb5e0(,%ecx,4),%ecx
f010044b:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010044f:	a8 08                	test   $0x8,%al
f0100451:	74 18                	je     f010046b <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100453:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100456:	83 fa 19             	cmp    $0x19,%edx
f0100459:	77 05                	ja     f0100460 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010045b:	83 eb 20             	sub    $0x20,%ebx
f010045e:	eb 0b                	jmp    f010046b <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100460:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100463:	83 fa 19             	cmp    $0x19,%edx
f0100466:	77 03                	ja     f010046b <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100468:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010046b:	f7 d0                	not    %eax
f010046d:	a8 06                	test   $0x6,%al
f010046f:	75 27                	jne    f0100498 <kbd_proc_data+0xf6>
f0100471:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100477:	75 1f                	jne    f0100498 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100479:	83 ec 0c             	sub    $0xc,%esp
f010047c:	68 da 47 10 f0       	push   $0xf01047da
f0100481:	e8 7f 2f 00 00       	call   f0103405 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100486:	ba 92 00 00 00       	mov    $0x92,%edx
f010048b:	b0 03                	mov    $0x3,%al
f010048d:	ee                   	out    %al,(%dx)
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	eb 05                	jmp    f0100498 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100493:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100498:	89 d8                	mov    %ebx,%eax
f010049a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010049d:	c9                   	leave  
f010049e:	c3                   	ret    

f010049f <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049f:	55                   	push   %ebp
f01004a0:	89 e5                	mov    %esp,%ebp
f01004a2:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004a5:	80 3d 90 70 1d f0 00 	cmpb   $0x0,0xf01d7090
f01004ac:	74 0a                	je     f01004b8 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004ae:	b8 76 01 10 f0       	mov    $0xf0100176,%eax
f01004b3:	e8 da fc ff ff       	call   f0100192 <cons_intr>
}
f01004b8:	c9                   	leave  
f01004b9:	c3                   	ret    

f01004ba <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004ba:	55                   	push   %ebp
f01004bb:	89 e5                	mov    %esp,%ebp
f01004bd:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c0:	b8 a2 03 10 f0       	mov    $0xf01003a2,%eax
f01004c5:	e8 c8 fc ff ff       	call   f0100192 <cons_intr>
}
f01004ca:	c9                   	leave  
f01004cb:	c3                   	ret    

f01004cc <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004cc:	55                   	push   %ebp
f01004cd:	89 e5                	mov    %esp,%ebp
f01004cf:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004d2:	e8 c8 ff ff ff       	call   f010049f <serial_intr>
	kbd_intr();
f01004d7:	e8 de ff ff ff       	call   f01004ba <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004dc:	8b 15 a0 72 1d f0    	mov    0xf01d72a0,%edx
f01004e2:	3b 15 a4 72 1d f0    	cmp    0xf01d72a4,%edx
f01004e8:	74 22                	je     f010050c <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004ea:	0f b6 82 a0 70 1d f0 	movzbl -0xfe28f60(%edx),%eax
f01004f1:	42                   	inc    %edx
f01004f2:	89 15 a0 72 1d f0    	mov    %edx,0xf01d72a0
		if (cons.rpos == CONSBUFSIZE)
f01004f8:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004fe:	75 11                	jne    f0100511 <cons_getc+0x45>
			cons.rpos = 0;
f0100500:	c7 05 a0 72 1d f0 00 	movl   $0x0,0xf01d72a0
f0100507:	00 00 00 
f010050a:	eb 05                	jmp    f0100511 <cons_getc+0x45>
		return c;
	}
	return 0;
f010050c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100511:	c9                   	leave  
f0100512:	c3                   	ret    

f0100513 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100513:	55                   	push   %ebp
f0100514:	89 e5                	mov    %esp,%ebp
f0100516:	57                   	push   %edi
f0100517:	56                   	push   %esi
f0100518:	53                   	push   %ebx
f0100519:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010051c:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100523:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010052a:	5a a5 
	if (*cp != 0xA55A) {
f010052c:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100532:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100536:	74 11                	je     f0100549 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100538:	c7 05 8c 70 1d f0 b4 	movl   $0x3b4,0xf01d708c
f010053f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100542:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100547:	eb 16                	jmp    f010055f <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100549:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100550:	c7 05 8c 70 1d f0 d4 	movl   $0x3d4,0xf01d708c
f0100557:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010055a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055f:	8b 0d 8c 70 1d f0    	mov    0xf01d708c,%ecx
f0100565:	b0 0e                	mov    $0xe,%al
f0100567:	89 ca                	mov    %ecx,%edx
f0100569:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010056a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056d:	89 da                	mov    %ebx,%edx
f010056f:	ec                   	in     (%dx),%al
f0100570:	0f b6 f8             	movzbl %al,%edi
f0100573:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100576:	b0 0f                	mov    $0xf,%al
f0100578:	89 ca                	mov    %ecx,%edx
f010057a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057b:	89 da                	mov    %ebx,%edx
f010057d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057e:	89 35 88 70 1d f0    	mov    %esi,0xf01d7088

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100584:	0f b6 d8             	movzbl %al,%ebx
f0100587:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100589:	66 89 3d 84 70 1d f0 	mov    %di,0xf01d7084
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100590:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100595:	b0 00                	mov    $0x0,%al
f0100597:	89 da                	mov    %ebx,%edx
f0100599:	ee                   	out    %al,(%dx)
f010059a:	b2 fb                	mov    $0xfb,%dl
f010059c:	b0 80                	mov    $0x80,%al
f010059e:	ee                   	out    %al,(%dx)
f010059f:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005a4:	b0 0c                	mov    $0xc,%al
f01005a6:	89 ca                	mov    %ecx,%edx
f01005a8:	ee                   	out    %al,(%dx)
f01005a9:	b2 f9                	mov    $0xf9,%dl
f01005ab:	b0 00                	mov    $0x0,%al
f01005ad:	ee                   	out    %al,(%dx)
f01005ae:	b2 fb                	mov    $0xfb,%dl
f01005b0:	b0 03                	mov    $0x3,%al
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	b2 fc                	mov    $0xfc,%dl
f01005b5:	b0 00                	mov    $0x0,%al
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	b2 f9                	mov    $0xf9,%dl
f01005ba:	b0 01                	mov    $0x1,%al
f01005bc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bd:	b2 fd                	mov    $0xfd,%dl
f01005bf:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c0:	3c ff                	cmp    $0xff,%al
f01005c2:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005c6:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005c9:	a2 90 70 1d f0       	mov    %al,0xf01d7090
f01005ce:	89 da                	mov    %ebx,%edx
f01005d0:	ec                   	in     (%dx),%al
f01005d1:	89 ca                	mov    %ecx,%edx
f01005d3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005d8:	75 10                	jne    f01005ea <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005da:	83 ec 0c             	sub    $0xc,%esp
f01005dd:	68 e6 47 10 f0       	push   $0xf01047e6
f01005e2:	e8 1e 2e 00 00       	call   f0103405 <cprintf>
f01005e7:	83 c4 10             	add    $0x10,%esp
}
f01005ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ed:	5b                   	pop    %ebx
f01005ee:	5e                   	pop    %esi
f01005ef:	5f                   	pop    %edi
f01005f0:	c9                   	leave  
f01005f1:	c3                   	ret    

f01005f2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fb:	e8 d3 fb ff ff       	call   f01001d3 <cons_putc>
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <getchar>:

int
getchar(void)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100608:	e8 bf fe ff ff       	call   f01004cc <cons_getc>
f010060d:	85 c0                	test   %eax,%eax
f010060f:	74 f7                	je     f0100608 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100611:	c9                   	leave  
f0100612:	c3                   	ret    

f0100613 <iscons>:

int
iscons(int fdnum)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100616:	b8 01 00 00 00       	mov    $0x1,%eax
f010061b:	c9                   	leave  
f010061c:	c3                   	ret    
f010061d:	00 00                	add    %al,(%eax)
	...

f0100620 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100626:	68 30 4a 10 f0       	push   $0xf0104a30
f010062b:	e8 d5 2d 00 00       	call   f0103405 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100630:	83 c4 08             	add    $0x8,%esp
f0100633:	68 0c 00 10 00       	push   $0x10000c
f0100638:	68 14 4c 10 f0       	push   $0xf0104c14
f010063d:	e8 c3 2d 00 00       	call   f0103405 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100642:	83 c4 0c             	add    $0xc,%esp
f0100645:	68 0c 00 10 00       	push   $0x10000c
f010064a:	68 0c 00 10 f0       	push   $0xf010000c
f010064f:	68 3c 4c 10 f0       	push   $0xf0104c3c
f0100654:	e8 ac 2d 00 00       	call   f0103405 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100659:	83 c4 0c             	add    $0xc,%esp
f010065c:	68 24 47 10 00       	push   $0x104724
f0100661:	68 24 47 10 f0       	push   $0xf0104724
f0100666:	68 60 4c 10 f0       	push   $0xf0104c60
f010066b:	e8 95 2d 00 00       	call   f0103405 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100670:	83 c4 0c             	add    $0xc,%esp
f0100673:	68 64 70 1d 00       	push   $0x1d7064
f0100678:	68 64 70 1d f0       	push   $0xf01d7064
f010067d:	68 84 4c 10 f0       	push   $0xf0104c84
f0100682:	e8 7e 2d 00 00       	call   f0103405 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100687:	83 c4 0c             	add    $0xc,%esp
f010068a:	68 90 7f 1d 00       	push   $0x1d7f90
f010068f:	68 90 7f 1d f0       	push   $0xf01d7f90
f0100694:	68 a8 4c 10 f0       	push   $0xf0104ca8
f0100699:	e8 67 2d 00 00       	call   f0103405 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010069e:	b8 8f 83 1d f0       	mov    $0xf01d838f,%eax
f01006a3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a8:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006ab:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b0:	89 c2                	mov    %eax,%edx
f01006b2:	85 c0                	test   %eax,%eax
f01006b4:	79 06                	jns    f01006bc <mon_kerninfo+0x9c>
f01006b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006bc:	c1 fa 0a             	sar    $0xa,%edx
f01006bf:	52                   	push   %edx
f01006c0:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01006c5:	e8 3b 2d 00 00       	call   f0103405 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cf:	c9                   	leave  
f01006d0:	c3                   	ret    

f01006d1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006d1:	55                   	push   %ebp
f01006d2:	89 e5                	mov    %esp,%ebp
f01006d4:	53                   	push   %ebx
f01006d5:	83 ec 04             	sub    $0x4,%esp
f01006d8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006dd:	83 ec 04             	sub    $0x4,%esp
f01006e0:	ff b3 24 51 10 f0    	pushl  -0xfefaedc(%ebx)
f01006e6:	ff b3 20 51 10 f0    	pushl  -0xfefaee0(%ebx)
f01006ec:	68 49 4a 10 f0       	push   $0xf0104a49
f01006f1:	e8 0f 2d 00 00       	call   f0103405 <cprintf>
f01006f6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006f9:	83 c4 10             	add    $0x10,%esp
f01006fc:	83 fb 54             	cmp    $0x54,%ebx
f01006ff:	75 dc                	jne    f01006dd <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100701:	b8 00 00 00 00       	mov    $0x0,%eax
f0100706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100709:	c9                   	leave  
f010070a:	c3                   	ret    

f010070b <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010070b:	55                   	push   %ebp
f010070c:	89 e5                	mov    %esp,%ebp
f010070e:	57                   	push   %edi
f010070f:	56                   	push   %esi
f0100710:	53                   	push   %ebx
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100717:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010071b:	74 21                	je     f010073e <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f010071d:	83 ec 0c             	sub    $0xc,%esp
f0100720:	68 f8 4c 10 f0       	push   $0xf0104cf8
f0100725:	e8 db 2c 00 00       	call   f0103405 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f010072a:	c7 04 24 2c 4d 10 f0 	movl   $0xf0104d2c,(%esp)
f0100731:	e8 cf 2c 00 00       	call   f0103405 <cprintf>
f0100736:	83 c4 10             	add    $0x10,%esp
f0100739:	e9 1a 01 00 00       	jmp    f0100858 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f010073e:	83 ec 04             	sub    $0x4,%esp
f0100741:	6a 00                	push   $0x0
f0100743:	6a 00                	push   $0x0
f0100745:	ff 76 04             	pushl  0x4(%esi)
f0100748:	e8 c1 3c 00 00       	call   f010440e <strtol>
f010074d:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f010074f:	83 c4 0c             	add    $0xc,%esp
f0100752:	6a 00                	push   $0x0
f0100754:	6a 00                	push   $0x0
f0100756:	ff 76 08             	pushl  0x8(%esi)
f0100759:	e8 b0 3c 00 00       	call   f010440e <strtol>
        if (laddr > haddr) {
f010075e:	83 c4 10             	add    $0x10,%esp
f0100761:	39 c3                	cmp    %eax,%ebx
f0100763:	76 01                	jbe    f0100766 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100765:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f0100766:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f010076c:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100772:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f0100778:	83 ec 04             	sub    $0x4,%esp
f010077b:	57                   	push   %edi
f010077c:	53                   	push   %ebx
f010077d:	68 52 4a 10 f0       	push   $0xf0104a52
f0100782:	e8 7e 2c 00 00       	call   f0103405 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100787:	83 c4 10             	add    $0x10,%esp
f010078a:	39 fb                	cmp    %edi,%ebx
f010078c:	75 07                	jne    f0100795 <mon_showmappings+0x8a>
f010078e:	e9 c5 00 00 00       	jmp    f0100858 <mon_showmappings+0x14d>
f0100793:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100795:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f010079b:	83 ec 04             	sub    $0x4,%esp
f010079e:	56                   	push   %esi
f010079f:	53                   	push   %ebx
f01007a0:	68 63 4a 10 f0       	push   $0xf0104a63
f01007a5:	e8 5b 2c 00 00       	call   f0103405 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01007aa:	83 c4 0c             	add    $0xc,%esp
f01007ad:	6a 00                	push   $0x0
f01007af:	53                   	push   %ebx
f01007b0:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01007b6:	e8 6b 0c 00 00       	call   f0101426 <pgdir_walk>
f01007bb:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f01007bd:	83 c4 10             	add    $0x10,%esp
f01007c0:	85 c0                	test   %eax,%eax
f01007c2:	74 06                	je     f01007ca <mon_showmappings+0xbf>
f01007c4:	8b 00                	mov    (%eax),%eax
f01007c6:	a8 01                	test   $0x1,%al
f01007c8:	75 12                	jne    f01007dc <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f01007ca:	83 ec 0c             	sub    $0xc,%esp
f01007cd:	68 7a 4a 10 f0       	push   $0xf0104a7a
f01007d2:	e8 2e 2c 00 00       	call   f0103405 <cprintf>
f01007d7:	83 c4 10             	add    $0x10,%esp
f01007da:	eb 74                	jmp    f0100850 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01007dc:	83 ec 08             	sub    $0x8,%esp
f01007df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007e4:	50                   	push   %eax
f01007e5:	68 87 4a 10 f0       	push   $0xf0104a87
f01007ea:	e8 16 2c 00 00       	call   f0103405 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007ef:	83 c4 10             	add    $0x10,%esp
f01007f2:	f6 03 04             	testb  $0x4,(%ebx)
f01007f5:	74 12                	je     f0100809 <mon_showmappings+0xfe>
f01007f7:	83 ec 0c             	sub    $0xc,%esp
f01007fa:	68 8f 4a 10 f0       	push   $0xf0104a8f
f01007ff:	e8 01 2c 00 00       	call   f0103405 <cprintf>
f0100804:	83 c4 10             	add    $0x10,%esp
f0100807:	eb 10                	jmp    f0100819 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100809:	83 ec 0c             	sub    $0xc,%esp
f010080c:	68 9c 4a 10 f0       	push   $0xf0104a9c
f0100811:	e8 ef 2b 00 00       	call   f0103405 <cprintf>
f0100816:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100819:	f6 03 02             	testb  $0x2,(%ebx)
f010081c:	74 12                	je     f0100830 <mon_showmappings+0x125>
f010081e:	83 ec 0c             	sub    $0xc,%esp
f0100821:	68 a9 4a 10 f0       	push   $0xf0104aa9
f0100826:	e8 da 2b 00 00       	call   f0103405 <cprintf>
f010082b:	83 c4 10             	add    $0x10,%esp
f010082e:	eb 10                	jmp    f0100840 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100830:	83 ec 0c             	sub    $0xc,%esp
f0100833:	68 ae 4a 10 f0       	push   $0xf0104aae
f0100838:	e8 c8 2b 00 00       	call   f0103405 <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100840:	83 ec 0c             	sub    $0xc,%esp
f0100843:	68 6a 47 10 f0       	push   $0xf010476a
f0100848:	e8 b8 2b 00 00       	call   f0103405 <cprintf>
f010084d:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100850:	39 f7                	cmp    %esi,%edi
f0100852:	0f 85 3b ff ff ff    	jne    f0100793 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100858:	b8 00 00 00 00       	mov    $0x0,%eax
f010085d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100860:	5b                   	pop    %ebx
f0100861:	5e                   	pop    %esi
f0100862:	5f                   	pop    %edi
f0100863:	c9                   	leave  
f0100864:	c3                   	ret    

f0100865 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100865:	55                   	push   %ebp
f0100866:	89 e5                	mov    %esp,%ebp
f0100868:	57                   	push   %edi
f0100869:	56                   	push   %esi
f010086a:	53                   	push   %ebx
f010086b:	83 ec 0c             	sub    $0xc,%esp
f010086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100871:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100875:	74 21                	je     f0100898 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100877:	83 ec 0c             	sub    $0xc,%esp
f010087a:	68 54 4d 10 f0       	push   $0xf0104d54
f010087f:	e8 81 2b 00 00       	call   f0103405 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100884:	c7 04 24 a4 4d 10 f0 	movl   $0xf0104da4,(%esp)
f010088b:	e8 75 2b 00 00       	call   f0103405 <cprintf>
f0100890:	83 c4 10             	add    $0x10,%esp
f0100893:	e9 a5 01 00 00       	jmp    f0100a3d <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100898:	83 ec 04             	sub    $0x4,%esp
f010089b:	6a 00                	push   $0x0
f010089d:	6a 00                	push   $0x0
f010089f:	ff 73 04             	pushl  0x4(%ebx)
f01008a2:	e8 67 3b 00 00       	call   f010440e <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f01008a7:	8b 53 08             	mov    0x8(%ebx),%edx
f01008aa:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f01008ad:	80 3a 31             	cmpb   $0x31,(%edx)
f01008b0:	0f 94 c2             	sete   %dl
f01008b3:	0f b6 d2             	movzbl %dl,%edx
f01008b6:	89 d6                	mov    %edx,%esi
f01008b8:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f01008ba:	8b 53 0c             	mov    0xc(%ebx),%edx
f01008bd:	80 3a 31             	cmpb   $0x31,(%edx)
f01008c0:	75 03                	jne    f01008c5 <mon_setpermission+0x60>
f01008c2:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f01008c5:	8b 53 10             	mov    0x10(%ebx),%edx
f01008c8:	80 3a 31             	cmpb   $0x31,(%edx)
f01008cb:	75 03                	jne    f01008d0 <mon_setpermission+0x6b>
f01008cd:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f01008d0:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01008d6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f01008dc:	83 ec 04             	sub    $0x4,%esp
f01008df:	6a 00                	push   $0x0
f01008e1:	57                   	push   %edi
f01008e2:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01008e8:	e8 39 0b 00 00       	call   f0101426 <pgdir_walk>
f01008ed:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f01008ef:	83 c4 10             	add    $0x10,%esp
f01008f2:	85 c0                	test   %eax,%eax
f01008f4:	0f 84 33 01 00 00    	je     f0100a2d <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f01008fa:	83 ec 04             	sub    $0x4,%esp
f01008fd:	8b 00                	mov    (%eax),%eax
f01008ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100904:	50                   	push   %eax
f0100905:	57                   	push   %edi
f0100906:	68 c8 4d 10 f0       	push   $0xf0104dc8
f010090b:	e8 f5 2a 00 00       	call   f0103405 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100910:	83 c4 10             	add    $0x10,%esp
f0100913:	f6 03 02             	testb  $0x2,(%ebx)
f0100916:	74 12                	je     f010092a <mon_setpermission+0xc5>
f0100918:	83 ec 0c             	sub    $0xc,%esp
f010091b:	68 b2 4a 10 f0       	push   $0xf0104ab2
f0100920:	e8 e0 2a 00 00       	call   f0103405 <cprintf>
f0100925:	83 c4 10             	add    $0x10,%esp
f0100928:	eb 10                	jmp    f010093a <mon_setpermission+0xd5>
f010092a:	83 ec 0c             	sub    $0xc,%esp
f010092d:	68 b5 4a 10 f0       	push   $0xf0104ab5
f0100932:	e8 ce 2a 00 00       	call   f0103405 <cprintf>
f0100937:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010093a:	f6 03 04             	testb  $0x4,(%ebx)
f010093d:	74 12                	je     f0100951 <mon_setpermission+0xec>
f010093f:	83 ec 0c             	sub    $0xc,%esp
f0100942:	68 ea 5a 10 f0       	push   $0xf0105aea
f0100947:	e8 b9 2a 00 00       	call   f0103405 <cprintf>
f010094c:	83 c4 10             	add    $0x10,%esp
f010094f:	eb 10                	jmp    f0100961 <mon_setpermission+0xfc>
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	68 06 5f 10 f0       	push   $0xf0105f06
f0100959:	e8 a7 2a 00 00       	call   f0103405 <cprintf>
f010095e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100961:	f6 03 01             	testb  $0x1,(%ebx)
f0100964:	74 12                	je     f0100978 <mon_setpermission+0x113>
f0100966:	83 ec 0c             	sub    $0xc,%esp
f0100969:	68 5e 5b 10 f0       	push   $0xf0105b5e
f010096e:	e8 92 2a 00 00       	call   f0103405 <cprintf>
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	eb 10                	jmp    f0100988 <mon_setpermission+0x123>
f0100978:	83 ec 0c             	sub    $0xc,%esp
f010097b:	68 b6 4a 10 f0       	push   $0xf0104ab6
f0100980:	e8 80 2a 00 00       	call   f0103405 <cprintf>
f0100985:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100988:	83 ec 0c             	sub    $0xc,%esp
f010098b:	68 b8 4a 10 f0       	push   $0xf0104ab8
f0100990:	e8 70 2a 00 00       	call   f0103405 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100995:	8b 03                	mov    (%ebx),%eax
f0100997:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010099c:	09 c6                	or     %eax,%esi
f010099e:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	f7 c6 02 00 00 00    	test   $0x2,%esi
f01009a9:	74 12                	je     f01009bd <mon_setpermission+0x158>
f01009ab:	83 ec 0c             	sub    $0xc,%esp
f01009ae:	68 b2 4a 10 f0       	push   $0xf0104ab2
f01009b3:	e8 4d 2a 00 00       	call   f0103405 <cprintf>
f01009b8:	83 c4 10             	add    $0x10,%esp
f01009bb:	eb 10                	jmp    f01009cd <mon_setpermission+0x168>
f01009bd:	83 ec 0c             	sub    $0xc,%esp
f01009c0:	68 b5 4a 10 f0       	push   $0xf0104ab5
f01009c5:	e8 3b 2a 00 00       	call   f0103405 <cprintf>
f01009ca:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01009cd:	f6 03 04             	testb  $0x4,(%ebx)
f01009d0:	74 12                	je     f01009e4 <mon_setpermission+0x17f>
f01009d2:	83 ec 0c             	sub    $0xc,%esp
f01009d5:	68 ea 5a 10 f0       	push   $0xf0105aea
f01009da:	e8 26 2a 00 00       	call   f0103405 <cprintf>
f01009df:	83 c4 10             	add    $0x10,%esp
f01009e2:	eb 10                	jmp    f01009f4 <mon_setpermission+0x18f>
f01009e4:	83 ec 0c             	sub    $0xc,%esp
f01009e7:	68 06 5f 10 f0       	push   $0xf0105f06
f01009ec:	e8 14 2a 00 00       	call   f0103405 <cprintf>
f01009f1:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009f4:	f6 03 01             	testb  $0x1,(%ebx)
f01009f7:	74 12                	je     f0100a0b <mon_setpermission+0x1a6>
f01009f9:	83 ec 0c             	sub    $0xc,%esp
f01009fc:	68 5e 5b 10 f0       	push   $0xf0105b5e
f0100a01:	e8 ff 29 00 00       	call   f0103405 <cprintf>
f0100a06:	83 c4 10             	add    $0x10,%esp
f0100a09:	eb 10                	jmp    f0100a1b <mon_setpermission+0x1b6>
f0100a0b:	83 ec 0c             	sub    $0xc,%esp
f0100a0e:	68 b6 4a 10 f0       	push   $0xf0104ab6
f0100a13:	e8 ed 29 00 00       	call   f0103405 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a1b:	83 ec 0c             	sub    $0xc,%esp
f0100a1e:	68 6a 47 10 f0       	push   $0xf010476a
f0100a23:	e8 dd 29 00 00       	call   f0103405 <cprintf>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	eb 10                	jmp    f0100a3d <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a2d:	83 ec 0c             	sub    $0xc,%esp
f0100a30:	68 7a 4a 10 f0       	push   $0xf0104a7a
f0100a35:	e8 cb 29 00 00       	call   f0103405 <cprintf>
f0100a3a:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100a3d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a45:	5b                   	pop    %ebx
f0100a46:	5e                   	pop    %esi
f0100a47:	5f                   	pop    %edi
f0100a48:	c9                   	leave  
f0100a49:	c3                   	ret    

f0100a4a <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100a4a:	55                   	push   %ebp
f0100a4b:	89 e5                	mov    %esp,%ebp
f0100a4d:	56                   	push   %esi
f0100a4e:	53                   	push   %ebx
f0100a4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100a52:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a56:	74 66                	je     f0100abe <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100a58:	83 ec 0c             	sub    $0xc,%esp
f0100a5b:	68 ec 4d 10 f0       	push   $0xf0104dec
f0100a60:	e8 a0 29 00 00       	call   f0103405 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a65:	c7 04 24 1c 4e 10 f0 	movl   $0xf0104e1c,(%esp)
f0100a6c:	e8 94 29 00 00       	call   f0103405 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a71:	c7 04 24 3c 4e 10 f0 	movl   $0xf0104e3c,(%esp)
f0100a78:	e8 88 29 00 00       	call   f0103405 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a7d:	c7 04 24 70 4e 10 f0 	movl   $0xf0104e70,(%esp)
f0100a84:	e8 7c 29 00 00       	call   f0103405 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a89:	c7 04 24 b4 4e 10 f0 	movl   $0xf0104eb4,(%esp)
f0100a90:	e8 70 29 00 00       	call   f0103405 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a95:	c7 04 24 c9 4a 10 f0 	movl   $0xf0104ac9,(%esp)
f0100a9c:	e8 64 29 00 00       	call   f0103405 <cprintf>
        cprintf("         set the background color to black\n");
f0100aa1:	c7 04 24 f8 4e 10 f0 	movl   $0xf0104ef8,(%esp)
f0100aa8:	e8 58 29 00 00       	call   f0103405 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100aad:	c7 04 24 24 4f 10 f0 	movl   $0xf0104f24,(%esp)
f0100ab4:	e8 4c 29 00 00       	call   f0103405 <cprintf>
f0100ab9:	83 c4 10             	add    $0x10,%esp
f0100abc:	eb 52                	jmp    f0100b10 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100abe:	83 ec 0c             	sub    $0xc,%esp
f0100ac1:	ff 73 04             	pushl  0x4(%ebx)
f0100ac4:	e8 43 36 00 00       	call   f010410c <strlen>
f0100ac9:	83 c4 10             	add    $0x10,%esp
f0100acc:	48                   	dec    %eax
f0100acd:	78 26                	js     f0100af5 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100acf:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100ad2:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100adc:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100ae0:	0f 94 c3             	sete   %bl
f0100ae3:	0f b6 db             	movzbl %bl,%ebx
f0100ae6:	d3 e3                	shl    %cl,%ebx
f0100ae8:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100aea:	48                   	dec    %eax
f0100aeb:	78 0d                	js     f0100afa <mon_setcolor+0xb0>
f0100aed:	41                   	inc    %ecx
f0100aee:	83 f9 08             	cmp    $0x8,%ecx
f0100af1:	75 e9                	jne    f0100adc <mon_setcolor+0x92>
f0100af3:	eb 05                	jmp    f0100afa <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100af5:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100afa:	89 15 80 70 1d f0    	mov    %edx,0xf01d7080
        cprintf(" This is color that you want ! \n");
f0100b00:	83 ec 0c             	sub    $0xc,%esp
f0100b03:	68 58 4f 10 f0       	push   $0xf0104f58
f0100b08:	e8 f8 28 00 00       	call   f0103405 <cprintf>
f0100b0d:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100b10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b15:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b18:	5b                   	pop    %ebx
f0100b19:	5e                   	pop    %esi
f0100b1a:	c9                   	leave  
f0100b1b:	c3                   	ret    

f0100b1c <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100b1c:	55                   	push   %ebp
f0100b1d:	89 e5                	mov    %esp,%ebp
f0100b1f:	57                   	push   %edi
f0100b20:	56                   	push   %esi
f0100b21:	53                   	push   %ebx
f0100b22:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100b25:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100b27:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b29:	85 c0                	test   %eax,%eax
f0100b2b:	74 6d                	je     f0100b9a <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b2d:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100b30:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100b33:	ff 76 18             	pushl  0x18(%esi)
f0100b36:	ff 76 14             	pushl  0x14(%esi)
f0100b39:	ff 76 10             	pushl  0x10(%esi)
f0100b3c:	ff 76 0c             	pushl  0xc(%esi)
f0100b3f:	ff 76 08             	pushl  0x8(%esi)
f0100b42:	53                   	push   %ebx
f0100b43:	56                   	push   %esi
f0100b44:	68 7c 4f 10 f0       	push   $0xf0104f7c
f0100b49:	e8 b7 28 00 00       	call   f0103405 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b4e:	83 c4 18             	add    $0x18,%esp
f0100b51:	57                   	push   %edi
f0100b52:	ff 76 04             	pushl  0x4(%esi)
f0100b55:	e8 8b 2d 00 00       	call   f01038e5 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b5a:	83 c4 0c             	add    $0xc,%esp
f0100b5d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b60:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b63:	68 e5 4a 10 f0       	push   $0xf0104ae5
f0100b68:	e8 98 28 00 00       	call   f0103405 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b6d:	83 c4 0c             	add    $0xc,%esp
f0100b70:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b73:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b76:	68 f5 4a 10 f0       	push   $0xf0104af5
f0100b7b:	e8 85 28 00 00       	call   f0103405 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b80:	83 c4 08             	add    $0x8,%esp
f0100b83:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b86:	53                   	push   %ebx
f0100b87:	68 fa 4a 10 f0       	push   $0xf0104afa
f0100b8c:	e8 74 28 00 00       	call   f0103405 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b91:	8b 36                	mov    (%esi),%esi
f0100b93:	83 c4 10             	add    $0x10,%esp
f0100b96:	85 f6                	test   %esi,%esi
f0100b98:	75 96                	jne    f0100b30 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100b9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba2:	5b                   	pop    %ebx
f0100ba3:	5e                   	pop    %esi
f0100ba4:	5f                   	pop    %edi
f0100ba5:	c9                   	leave  
f0100ba6:	c3                   	ret    

f0100ba7 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100ba7:	55                   	push   %ebp
f0100ba8:	89 e5                	mov    %esp,%ebp
f0100baa:	53                   	push   %ebx
f0100bab:	83 ec 04             	sub    $0x4,%esp
f0100bae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100bb4:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bba:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bc0:	77 15                	ja     f0100bd7 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bc2:	52                   	push   %edx
f0100bc3:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0100bc8:	68 93 00 00 00       	push   $0x93
f0100bcd:	68 ff 4a 10 f0       	push   $0xf0104aff
f0100bd2:	e8 fe f4 ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100bd7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100bdd:	39 d0                	cmp    %edx,%eax
f0100bdf:	72 18                	jb     f0100bf9 <pa_con+0x52>
f0100be1:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100be7:	39 d8                	cmp    %ebx,%eax
f0100be9:	73 0e                	jae    f0100bf9 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100beb:	29 d0                	sub    %edx,%eax
f0100bed:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100bf3:	89 01                	mov    %eax,(%ecx)
        return true;
f0100bf5:	b0 01                	mov    $0x1,%al
f0100bf7:	eb 56                	jmp    f0100c4f <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bf9:	ba 00 80 11 f0       	mov    $0xf0118000,%edx
f0100bfe:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c04:	77 15                	ja     f0100c1b <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c06:	52                   	push   %edx
f0100c07:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0100c0c:	68 98 00 00 00       	push   $0x98
f0100c11:	68 ff 4a 10 f0       	push   $0xf0104aff
f0100c16:	e8 ba f4 ff ff       	call   f01000d5 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100c1b:	3d 00 80 11 00       	cmp    $0x118000,%eax
f0100c20:	72 18                	jb     f0100c3a <pa_con+0x93>
f0100c22:	3d 00 00 12 00       	cmp    $0x120000,%eax
f0100c27:	73 11                	jae    f0100c3a <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100c29:	2d 00 80 11 00       	sub    $0x118000,%eax
f0100c2e:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100c34:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c36:	b0 01                	mov    $0x1,%al
f0100c38:	eb 15                	jmp    f0100c4f <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100c3a:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100c3f:	77 0c                	ja     f0100c4d <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100c41:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100c47:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c49:	b0 01                	mov    $0x1,%al
f0100c4b:	eb 02                	jmp    f0100c4f <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100c4d:	b0 00                	mov    $0x0,%al
}
f0100c4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c52:	c9                   	leave  
f0100c53:	c3                   	ret    

f0100c54 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100c54:	55                   	push   %ebp
f0100c55:	89 e5                	mov    %esp,%ebp
f0100c57:	57                   	push   %edi
f0100c58:	56                   	push   %esi
f0100c59:	53                   	push   %ebx
f0100c5a:	83 ec 2c             	sub    $0x2c,%esp
f0100c5d:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100c60:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c64:	74 2d                	je     f0100c93 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100c66:	83 ec 0c             	sub    $0xc,%esp
f0100c69:	68 d8 4f 10 f0       	push   $0xf0104fd8
f0100c6e:	e8 92 27 00 00       	call   f0103405 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c73:	c7 04 24 08 50 10 f0 	movl   $0xf0105008,(%esp)
f0100c7a:	e8 86 27 00 00       	call   f0103405 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c7f:	c7 04 24 30 50 10 f0 	movl   $0xf0105030,(%esp)
f0100c86:	e8 7a 27 00 00       	call   f0103405 <cprintf>
f0100c8b:	83 c4 10             	add    $0x10,%esp
f0100c8e:	e9 59 01 00 00       	jmp    f0100dec <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c93:	83 ec 04             	sub    $0x4,%esp
f0100c96:	6a 00                	push   $0x0
f0100c98:	6a 00                	push   $0x0
f0100c9a:	ff 76 08             	pushl  0x8(%esi)
f0100c9d:	e8 6c 37 00 00       	call   f010440e <strtol>
f0100ca2:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100ca4:	83 c4 0c             	add    $0xc,%esp
f0100ca7:	6a 00                	push   $0x0
f0100ca9:	6a 00                	push   $0x0
f0100cab:	ff 76 0c             	pushl  0xc(%esi)
f0100cae:	e8 5b 37 00 00       	call   f010440e <strtol>
        if (laddr > haddr) {
f0100cb3:	83 c4 10             	add    $0x10,%esp
f0100cb6:	39 c3                	cmp    %eax,%ebx
f0100cb8:	76 01                	jbe    f0100cbb <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100cba:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100cbb:	89 df                	mov    %ebx,%edi
f0100cbd:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100cc0:	83 e0 fc             	and    $0xfffffffc,%eax
f0100cc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100cc6:	8b 46 04             	mov    0x4(%esi),%eax
f0100cc9:	80 38 76             	cmpb   $0x76,(%eax)
f0100ccc:	74 0e                	je     f0100cdc <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100cce:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100cd1:	0f 85 98 00 00 00    	jne    f0100d6f <mon_dump+0x11b>
f0100cd7:	e9 00 01 00 00       	jmp    f0100ddc <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100cdc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100cdf:	74 7c                	je     f0100d5d <mon_dump+0x109>
f0100ce1:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100ce3:	39 fb                	cmp    %edi,%ebx
f0100ce5:	74 15                	je     f0100cfc <mon_dump+0xa8>
f0100ce7:	f6 c3 0f             	test   $0xf,%bl
f0100cea:	75 21                	jne    f0100d0d <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100cec:	83 ec 0c             	sub    $0xc,%esp
f0100cef:	68 6a 47 10 f0       	push   $0xf010476a
f0100cf4:	e8 0c 27 00 00       	call   f0103405 <cprintf>
f0100cf9:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100cfc:	83 ec 08             	sub    $0x8,%esp
f0100cff:	53                   	push   %ebx
f0100d00:	68 0e 4b 10 f0       	push   $0xf0104b0e
f0100d05:	e8 fb 26 00 00       	call   f0103405 <cprintf>
f0100d0a:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d0d:	83 ec 04             	sub    $0x4,%esp
f0100d10:	6a 00                	push   $0x0
f0100d12:	89 d8                	mov    %ebx,%eax
f0100d14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d19:	50                   	push   %eax
f0100d1a:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0100d20:	e8 01 07 00 00       	call   f0101426 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d25:	83 c4 10             	add    $0x10,%esp
f0100d28:	85 c0                	test   %eax,%eax
f0100d2a:	74 19                	je     f0100d45 <mon_dump+0xf1>
f0100d2c:	f6 00 01             	testb  $0x1,(%eax)
f0100d2f:	74 14                	je     f0100d45 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d31:	83 ec 08             	sub    $0x8,%esp
f0100d34:	ff 33                	pushl  (%ebx)
f0100d36:	68 18 4b 10 f0       	push   $0xf0104b18
f0100d3b:	e8 c5 26 00 00       	call   f0103405 <cprintf>
f0100d40:	83 c4 10             	add    $0x10,%esp
f0100d43:	eb 10                	jmp    f0100d55 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d45:	83 ec 0c             	sub    $0xc,%esp
f0100d48:	68 23 4b 10 f0       	push   $0xf0104b23
f0100d4d:	e8 b3 26 00 00       	call   f0103405 <cprintf>
f0100d52:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d55:	83 c3 04             	add    $0x4,%ebx
f0100d58:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d5b:	75 86                	jne    f0100ce3 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100d5d:	83 ec 0c             	sub    $0xc,%esp
f0100d60:	68 6a 47 10 f0       	push   $0xf010476a
f0100d65:	e8 9b 26 00 00       	call   f0103405 <cprintf>
f0100d6a:	83 c4 10             	add    $0x10,%esp
f0100d6d:	eb 7d                	jmp    f0100dec <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d6f:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100d71:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d74:	39 fb                	cmp    %edi,%ebx
f0100d76:	74 15                	je     f0100d8d <mon_dump+0x139>
f0100d78:	f6 c3 0f             	test   $0xf,%bl
f0100d7b:	75 21                	jne    f0100d9e <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100d7d:	83 ec 0c             	sub    $0xc,%esp
f0100d80:	68 6a 47 10 f0       	push   $0xf010476a
f0100d85:	e8 7b 26 00 00       	call   f0103405 <cprintf>
f0100d8a:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d8d:	83 ec 08             	sub    $0x8,%esp
f0100d90:	53                   	push   %ebx
f0100d91:	68 0e 4b 10 f0       	push   $0xf0104b0e
f0100d96:	e8 6a 26 00 00       	call   f0103405 <cprintf>
f0100d9b:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100d9e:	83 ec 08             	sub    $0x8,%esp
f0100da1:	56                   	push   %esi
f0100da2:	53                   	push   %ebx
f0100da3:	e8 ff fd ff ff       	call   f0100ba7 <pa_con>
f0100da8:	83 c4 10             	add    $0x10,%esp
f0100dab:	84 c0                	test   %al,%al
f0100dad:	74 15                	je     f0100dc4 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100daf:	83 ec 08             	sub    $0x8,%esp
f0100db2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100db5:	68 18 4b 10 f0       	push   $0xf0104b18
f0100dba:	e8 46 26 00 00       	call   f0103405 <cprintf>
f0100dbf:	83 c4 10             	add    $0x10,%esp
f0100dc2:	eb 10                	jmp    f0100dd4 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100dc4:	83 ec 0c             	sub    $0xc,%esp
f0100dc7:	68 21 4b 10 f0       	push   $0xf0104b21
f0100dcc:	e8 34 26 00 00       	call   f0103405 <cprintf>
f0100dd1:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100dd4:	83 c3 04             	add    $0x4,%ebx
f0100dd7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100dda:	75 98                	jne    f0100d74 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100ddc:	83 ec 0c             	sub    $0xc,%esp
f0100ddf:	68 6a 47 10 f0       	push   $0xf010476a
f0100de4:	e8 1c 26 00 00       	call   f0103405 <cprintf>
f0100de9:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100dec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100df4:	5b                   	pop    %ebx
f0100df5:	5e                   	pop    %esi
f0100df6:	5f                   	pop    %edi
f0100df7:	c9                   	leave  
f0100df8:	c3                   	ret    

f0100df9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100df9:	55                   	push   %ebp
f0100dfa:	89 e5                	mov    %esp,%ebp
f0100dfc:	57                   	push   %edi
f0100dfd:	56                   	push   %esi
f0100dfe:	53                   	push   %ebx
f0100dff:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e02:	68 74 50 10 f0       	push   $0xf0105074
f0100e07:	e8 f9 25 00 00       	call   f0103405 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e0c:	c7 04 24 98 50 10 f0 	movl   $0xf0105098,(%esp)
f0100e13:	e8 ed 25 00 00       	call   f0103405 <cprintf>

	if (tf != NULL)
f0100e18:	83 c4 10             	add    $0x10,%esp
f0100e1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e1f:	74 0e                	je     f0100e2f <monitor+0x36>
		print_trapframe(tf);
f0100e21:	83 ec 0c             	sub    $0xc,%esp
f0100e24:	ff 75 08             	pushl  0x8(%ebp)
f0100e27:	e8 e5 26 00 00       	call   f0103511 <print_trapframe>
f0100e2c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e2f:	83 ec 0c             	sub    $0xc,%esp
f0100e32:	68 2e 4b 10 f0       	push   $0xf0104b2e
f0100e37:	e8 00 32 00 00       	call   f010403c <readline>
f0100e3c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e3e:	83 c4 10             	add    $0x10,%esp
f0100e41:	85 c0                	test   %eax,%eax
f0100e43:	74 ea                	je     f0100e2f <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e45:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e4c:	be 00 00 00 00       	mov    $0x0,%esi
f0100e51:	eb 04                	jmp    f0100e57 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e53:	c6 03 00             	movb   $0x0,(%ebx)
f0100e56:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e57:	8a 03                	mov    (%ebx),%al
f0100e59:	84 c0                	test   %al,%al
f0100e5b:	74 64                	je     f0100ec1 <monitor+0xc8>
f0100e5d:	83 ec 08             	sub    $0x8,%esp
f0100e60:	0f be c0             	movsbl %al,%eax
f0100e63:	50                   	push   %eax
f0100e64:	68 32 4b 10 f0       	push   $0xf0104b32
f0100e69:	e8 17 34 00 00       	call   f0104285 <strchr>
f0100e6e:	83 c4 10             	add    $0x10,%esp
f0100e71:	85 c0                	test   %eax,%eax
f0100e73:	75 de                	jne    f0100e53 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100e75:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e78:	74 47                	je     f0100ec1 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e7a:	83 fe 0f             	cmp    $0xf,%esi
f0100e7d:	75 14                	jne    f0100e93 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e7f:	83 ec 08             	sub    $0x8,%esp
f0100e82:	6a 10                	push   $0x10
f0100e84:	68 37 4b 10 f0       	push   $0xf0104b37
f0100e89:	e8 77 25 00 00       	call   f0103405 <cprintf>
f0100e8e:	83 c4 10             	add    $0x10,%esp
f0100e91:	eb 9c                	jmp    f0100e2f <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100e93:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e97:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e98:	8a 03                	mov    (%ebx),%al
f0100e9a:	84 c0                	test   %al,%al
f0100e9c:	75 09                	jne    f0100ea7 <monitor+0xae>
f0100e9e:	eb b7                	jmp    f0100e57 <monitor+0x5e>
			buf++;
f0100ea0:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ea1:	8a 03                	mov    (%ebx),%al
f0100ea3:	84 c0                	test   %al,%al
f0100ea5:	74 b0                	je     f0100e57 <monitor+0x5e>
f0100ea7:	83 ec 08             	sub    $0x8,%esp
f0100eaa:	0f be c0             	movsbl %al,%eax
f0100ead:	50                   	push   %eax
f0100eae:	68 32 4b 10 f0       	push   $0xf0104b32
f0100eb3:	e8 cd 33 00 00       	call   f0104285 <strchr>
f0100eb8:	83 c4 10             	add    $0x10,%esp
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	74 e1                	je     f0100ea0 <monitor+0xa7>
f0100ebf:	eb 96                	jmp    f0100e57 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100ec1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ec8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ec9:	85 f6                	test   %esi,%esi
f0100ecb:	0f 84 5e ff ff ff    	je     f0100e2f <monitor+0x36>
f0100ed1:	bb 20 51 10 f0       	mov    $0xf0105120,%ebx
f0100ed6:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100edb:	83 ec 08             	sub    $0x8,%esp
f0100ede:	ff 33                	pushl  (%ebx)
f0100ee0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ee3:	e8 2f 33 00 00       	call   f0104217 <strcmp>
f0100ee8:	83 c4 10             	add    $0x10,%esp
f0100eeb:	85 c0                	test   %eax,%eax
f0100eed:	75 20                	jne    f0100f0f <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100eef:	83 ec 04             	sub    $0x4,%esp
f0100ef2:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ef5:	ff 75 08             	pushl  0x8(%ebp)
f0100ef8:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100efb:	50                   	push   %eax
f0100efc:	56                   	push   %esi
f0100efd:	ff 97 28 51 10 f0    	call   *-0xfefaed8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f03:	83 c4 10             	add    $0x10,%esp
f0100f06:	85 c0                	test   %eax,%eax
f0100f08:	78 26                	js     f0100f30 <monitor+0x137>
f0100f0a:	e9 20 ff ff ff       	jmp    f0100e2f <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f0f:	47                   	inc    %edi
f0100f10:	83 c3 0c             	add    $0xc,%ebx
f0100f13:	83 ff 07             	cmp    $0x7,%edi
f0100f16:	75 c3                	jne    f0100edb <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f18:	83 ec 08             	sub    $0x8,%esp
f0100f1b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f1e:	68 54 4b 10 f0       	push   $0xf0104b54
f0100f23:	e8 dd 24 00 00       	call   f0103405 <cprintf>
f0100f28:	83 c4 10             	add    $0x10,%esp
f0100f2b:	e9 ff fe ff ff       	jmp    f0100e2f <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f33:	5b                   	pop    %ebx
f0100f34:	5e                   	pop    %esi
f0100f35:	5f                   	pop    %edi
f0100f36:	c9                   	leave  
f0100f37:	c3                   	ret    

f0100f38 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f38:	55                   	push   %ebp
f0100f39:	89 e5                	mov    %esp,%ebp
f0100f3b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f3d:	83 3d b0 72 1d f0 00 	cmpl   $0x0,0xf01d72b0
f0100f44:	75 0f                	jne    f0100f55 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f46:	b8 8f 8f 1d f0       	mov    $0xf01d8f8f,%eax
f0100f4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f50:	a3 b0 72 1d f0       	mov    %eax,0xf01d72b0
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100f55:	a1 b0 72 1d f0       	mov    0xf01d72b0,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f5a:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100f61:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f67:	89 15 b0 72 1d f0    	mov    %edx,0xf01d72b0

	return result;
}
f0100f6d:	c9                   	leave  
f0100f6e:	c3                   	ret    

f0100f6f <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f6f:	55                   	push   %ebp
f0100f70:	89 e5                	mov    %esp,%ebp
f0100f72:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f75:	89 d1                	mov    %edx,%ecx
f0100f77:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f7a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f7d:	a8 01                	test   $0x1,%al
f0100f7f:	74 42                	je     f0100fc3 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f86:	89 c1                	mov    %eax,%ecx
f0100f88:	c1 e9 0c             	shr    $0xc,%ecx
f0100f8b:	3b 0d 84 7f 1d f0    	cmp    0xf01d7f84,%ecx
f0100f91:	72 15                	jb     f0100fa8 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f93:	50                   	push   %eax
f0100f94:	68 74 51 10 f0       	push   $0xf0105174
f0100f99:	68 0a 03 00 00       	push   $0x30a
f0100f9e:	68 d5 58 10 f0       	push   $0xf01058d5
f0100fa3:	e8 2d f1 ff ff       	call   f01000d5 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100fa8:	c1 ea 0c             	shr    $0xc,%edx
f0100fab:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fb1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fb8:	a8 01                	test   $0x1,%al
f0100fba:	74 0e                	je     f0100fca <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fc1:	eb 0c                	jmp    f0100fcf <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fc8:	eb 05                	jmp    f0100fcf <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100fca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100fcf:	c9                   	leave  
f0100fd0:	c3                   	ret    

f0100fd1 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100fd1:	55                   	push   %ebp
f0100fd2:	89 e5                	mov    %esp,%ebp
f0100fd4:	56                   	push   %esi
f0100fd5:	53                   	push   %ebx
f0100fd6:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fd8:	83 ec 0c             	sub    $0xc,%esp
f0100fdb:	50                   	push   %eax
f0100fdc:	e8 c3 23 00 00       	call   f01033a4 <mc146818_read>
f0100fe1:	89 c6                	mov    %eax,%esi
f0100fe3:	43                   	inc    %ebx
f0100fe4:	89 1c 24             	mov    %ebx,(%esp)
f0100fe7:	e8 b8 23 00 00       	call   f01033a4 <mc146818_read>
f0100fec:	c1 e0 08             	shl    $0x8,%eax
f0100fef:	09 f0                	or     %esi,%eax
}
f0100ff1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ff4:	5b                   	pop    %ebx
f0100ff5:	5e                   	pop    %esi
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    

f0100ff8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	57                   	push   %edi
f0100ffc:	56                   	push   %esi
f0100ffd:	53                   	push   %ebx
f0100ffe:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101001:	3c 01                	cmp    $0x1,%al
f0101003:	19 f6                	sbb    %esi,%esi
f0101005:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010100b:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010100c:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f0101012:	85 db                	test   %ebx,%ebx
f0101014:	75 17                	jne    f010102d <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101016:	83 ec 04             	sub    $0x4,%esp
f0101019:	68 98 51 10 f0       	push   $0xf0105198
f010101e:	68 48 02 00 00       	push   $0x248
f0101023:	68 d5 58 10 f0       	push   $0xf01058d5
f0101028:	e8 a8 f0 ff ff       	call   f01000d5 <_panic>

	if (only_low_memory) {
f010102d:	84 c0                	test   %al,%al
f010102f:	74 50                	je     f0101081 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101031:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101034:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101037:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010103a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010103d:	89 d8                	mov    %ebx,%eax
f010103f:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101045:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101048:	c1 e8 16             	shr    $0x16,%eax
f010104b:	39 c6                	cmp    %eax,%esi
f010104d:	0f 96 c0             	setbe  %al
f0101050:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101053:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101057:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101059:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010105d:	8b 1b                	mov    (%ebx),%ebx
f010105f:	85 db                	test   %ebx,%ebx
f0101061:	75 da                	jne    f010103d <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101063:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101066:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010106c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010106f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101072:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101074:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101077:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010107d:	85 db                	test   %ebx,%ebx
f010107f:	74 57                	je     f01010d8 <check_page_free_list+0xe0>
f0101081:	89 d8                	mov    %ebx,%eax
f0101083:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101089:	c1 f8 03             	sar    $0x3,%eax
f010108c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010108f:	89 c2                	mov    %eax,%edx
f0101091:	c1 ea 16             	shr    $0x16,%edx
f0101094:	39 d6                	cmp    %edx,%esi
f0101096:	76 3a                	jbe    f01010d2 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101098:	89 c2                	mov    %eax,%edx
f010109a:	c1 ea 0c             	shr    $0xc,%edx
f010109d:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f01010a3:	72 12                	jb     f01010b7 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a5:	50                   	push   %eax
f01010a6:	68 74 51 10 f0       	push   $0xf0105174
f01010ab:	6a 56                	push   $0x56
f01010ad:	68 e1 58 10 f0       	push   $0xf01058e1
f01010b2:	e8 1e f0 ff ff       	call   f01000d5 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010b7:	83 ec 04             	sub    $0x4,%esp
f01010ba:	68 80 00 00 00       	push   $0x80
f01010bf:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010c9:	50                   	push   %eax
f01010ca:	e8 06 32 00 00       	call   f01042d5 <memset>
f01010cf:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010d2:	8b 1b                	mov    (%ebx),%ebx
f01010d4:	85 db                	test   %ebx,%ebx
f01010d6:	75 a9                	jne    f0101081 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01010dd:	e8 56 fe ff ff       	call   f0100f38 <boot_alloc>
f01010e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010e5:	8b 15 ac 72 1d f0    	mov    0xf01d72ac,%edx
f01010eb:	85 d2                	test   %edx,%edx
f01010ed:	0f 84 80 01 00 00    	je     f0101273 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010f3:	8b 1d 8c 7f 1d f0    	mov    0xf01d7f8c,%ebx
f01010f9:	39 da                	cmp    %ebx,%edx
f01010fb:	72 43                	jb     f0101140 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f01010fd:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f0101102:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101105:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101108:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010110b:	39 c2                	cmp    %eax,%edx
f010110d:	73 4f                	jae    f010115e <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010110f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101112:	89 d0                	mov    %edx,%eax
f0101114:	29 d8                	sub    %ebx,%eax
f0101116:	a8 07                	test   $0x7,%al
f0101118:	75 66                	jne    f0101180 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010111a:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010111d:	c1 e0 0c             	shl    $0xc,%eax
f0101120:	74 7f                	je     f01011a1 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f0101122:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101127:	0f 84 94 00 00 00    	je     f01011c1 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010112d:	be 00 00 00 00       	mov    $0x0,%esi
f0101132:	bf 00 00 00 00       	mov    $0x0,%edi
f0101137:	e9 9e 00 00 00       	jmp    f01011da <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010113c:	39 da                	cmp    %ebx,%edx
f010113e:	73 19                	jae    f0101159 <check_page_free_list+0x161>
f0101140:	68 ef 58 10 f0       	push   $0xf01058ef
f0101145:	68 fb 58 10 f0       	push   $0xf01058fb
f010114a:	68 62 02 00 00       	push   $0x262
f010114f:	68 d5 58 10 f0       	push   $0xf01058d5
f0101154:	e8 7c ef ff ff       	call   f01000d5 <_panic>
		assert(pp < pages + npages);
f0101159:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010115c:	72 19                	jb     f0101177 <check_page_free_list+0x17f>
f010115e:	68 10 59 10 f0       	push   $0xf0105910
f0101163:	68 fb 58 10 f0       	push   $0xf01058fb
f0101168:	68 63 02 00 00       	push   $0x263
f010116d:	68 d5 58 10 f0       	push   $0xf01058d5
f0101172:	e8 5e ef ff ff       	call   f01000d5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101177:	89 d0                	mov    %edx,%eax
f0101179:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010117c:	a8 07                	test   $0x7,%al
f010117e:	74 19                	je     f0101199 <check_page_free_list+0x1a1>
f0101180:	68 bc 51 10 f0       	push   $0xf01051bc
f0101185:	68 fb 58 10 f0       	push   $0xf01058fb
f010118a:	68 64 02 00 00       	push   $0x264
f010118f:	68 d5 58 10 f0       	push   $0xf01058d5
f0101194:	e8 3c ef ff ff       	call   f01000d5 <_panic>
f0101199:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010119c:	c1 e0 0c             	shl    $0xc,%eax
f010119f:	75 19                	jne    f01011ba <check_page_free_list+0x1c2>
f01011a1:	68 24 59 10 f0       	push   $0xf0105924
f01011a6:	68 fb 58 10 f0       	push   $0xf01058fb
f01011ab:	68 67 02 00 00       	push   $0x267
f01011b0:	68 d5 58 10 f0       	push   $0xf01058d5
f01011b5:	e8 1b ef ff ff       	call   f01000d5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011ba:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011bf:	75 19                	jne    f01011da <check_page_free_list+0x1e2>
f01011c1:	68 35 59 10 f0       	push   $0xf0105935
f01011c6:	68 fb 58 10 f0       	push   $0xf01058fb
f01011cb:	68 68 02 00 00       	push   $0x268
f01011d0:	68 d5 58 10 f0       	push   $0xf01058d5
f01011d5:	e8 fb ee ff ff       	call   f01000d5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011da:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011df:	75 19                	jne    f01011fa <check_page_free_list+0x202>
f01011e1:	68 f0 51 10 f0       	push   $0xf01051f0
f01011e6:	68 fb 58 10 f0       	push   $0xf01058fb
f01011eb:	68 69 02 00 00       	push   $0x269
f01011f0:	68 d5 58 10 f0       	push   $0xf01058d5
f01011f5:	e8 db ee ff ff       	call   f01000d5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011fa:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011ff:	75 19                	jne    f010121a <check_page_free_list+0x222>
f0101201:	68 4e 59 10 f0       	push   $0xf010594e
f0101206:	68 fb 58 10 f0       	push   $0xf01058fb
f010120b:	68 6a 02 00 00       	push   $0x26a
f0101210:	68 d5 58 10 f0       	push   $0xf01058d5
f0101215:	e8 bb ee ff ff       	call   f01000d5 <_panic>
f010121a:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010121c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101221:	76 3e                	jbe    f0101261 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101223:	c1 e8 0c             	shr    $0xc,%eax
f0101226:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101229:	77 12                	ja     f010123d <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010122b:	51                   	push   %ecx
f010122c:	68 74 51 10 f0       	push   $0xf0105174
f0101231:	6a 56                	push   $0x56
f0101233:	68 e1 58 10 f0       	push   $0xf01058e1
f0101238:	e8 98 ee ff ff       	call   f01000d5 <_panic>
	return (void *)(pa + KERNBASE);
f010123d:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101243:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101246:	76 1c                	jbe    f0101264 <check_page_free_list+0x26c>
f0101248:	68 14 52 10 f0       	push   $0xf0105214
f010124d:	68 fb 58 10 f0       	push   $0xf01058fb
f0101252:	68 6b 02 00 00       	push   $0x26b
f0101257:	68 d5 58 10 f0       	push   $0xf01058d5
f010125c:	e8 74 ee ff ff       	call   f01000d5 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101261:	47                   	inc    %edi
f0101262:	eb 01                	jmp    f0101265 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101264:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101265:	8b 12                	mov    (%edx),%edx
f0101267:	85 d2                	test   %edx,%edx
f0101269:	0f 85 cd fe ff ff    	jne    f010113c <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010126f:	85 ff                	test   %edi,%edi
f0101271:	7f 19                	jg     f010128c <check_page_free_list+0x294>
f0101273:	68 68 59 10 f0       	push   $0xf0105968
f0101278:	68 fb 58 10 f0       	push   $0xf01058fb
f010127d:	68 73 02 00 00       	push   $0x273
f0101282:	68 d5 58 10 f0       	push   $0xf01058d5
f0101287:	e8 49 ee ff ff       	call   f01000d5 <_panic>
	assert(nfree_extmem > 0);
f010128c:	85 f6                	test   %esi,%esi
f010128e:	7f 19                	jg     f01012a9 <check_page_free_list+0x2b1>
f0101290:	68 7a 59 10 f0       	push   $0xf010597a
f0101295:	68 fb 58 10 f0       	push   $0xf01058fb
f010129a:	68 74 02 00 00       	push   $0x274
f010129f:	68 d5 58 10 f0       	push   $0xf01058d5
f01012a4:	e8 2c ee ff ff       	call   f01000d5 <_panic>
}
f01012a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ac:	5b                   	pop    %ebx
f01012ad:	5e                   	pop    %esi
f01012ae:	5f                   	pop    %edi
f01012af:	c9                   	leave  
f01012b0:	c3                   	ret    

f01012b1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012b1:	55                   	push   %ebp
f01012b2:	89 e5                	mov    %esp,%ebp
f01012b4:	56                   	push   %esi
f01012b5:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01012b6:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f01012bd:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f01012c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c5:	e8 6e fc ff ff       	call   f0100f38 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012cf:	77 15                	ja     f01012e6 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012d1:	50                   	push   %eax
f01012d2:	68 b4 4f 10 f0       	push   $0xf0104fb4
f01012d7:	68 24 01 00 00       	push   $0x124
f01012dc:	68 d5 58 10 f0       	push   $0xf01058d5
f01012e1:	e8 ef ed ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012e6:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f01012ec:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f01012ef:	83 3d 84 7f 1d f0 00 	cmpl   $0x0,0xf01d7f84
f01012f6:	74 5f                	je     f0101357 <page_init+0xa6>
f01012f8:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f01012fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0101303:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101308:	85 c0                	test   %eax,%eax
f010130a:	74 25                	je     f0101331 <page_init+0x80>
f010130c:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101311:	76 04                	jbe    f0101317 <page_init+0x66>
f0101313:	39 c6                	cmp    %eax,%esi
f0101315:	77 1a                	ja     f0101331 <page_init+0x80>
		    pages[i].pp_ref = 0;
f0101317:	89 d1                	mov    %edx,%ecx
f0101319:	03 0d 8c 7f 1d f0    	add    0xf01d7f8c,%ecx
f010131f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101325:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0101327:	89 d3                	mov    %edx,%ebx
f0101329:	03 1d 8c 7f 1d f0    	add    0xf01d7f8c,%ebx
f010132f:	eb 14                	jmp    f0101345 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101331:	89 d1                	mov    %edx,%ecx
f0101333:	03 0d 8c 7f 1d f0    	add    0xf01d7f8c,%ecx
f0101339:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010133f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101345:	40                   	inc    %eax
f0101346:	83 c2 08             	add    $0x8,%edx
f0101349:	39 05 84 7f 1d f0    	cmp    %eax,0xf01d7f84
f010134f:	77 b7                	ja     f0101308 <page_init+0x57>
f0101351:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f0101357:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010135a:	5b                   	pop    %ebx
f010135b:	5e                   	pop    %esi
f010135c:	c9                   	leave  
f010135d:	c3                   	ret    

f010135e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010135e:	55                   	push   %ebp
f010135f:	89 e5                	mov    %esp,%ebp
f0101361:	53                   	push   %ebx
f0101362:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101365:	8b 1d ac 72 1d f0    	mov    0xf01d72ac,%ebx
f010136b:	85 db                	test   %ebx,%ebx
f010136d:	74 63                	je     f01013d2 <page_alloc+0x74>
f010136f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101374:	74 63                	je     f01013d9 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101376:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101378:	85 db                	test   %ebx,%ebx
f010137a:	75 08                	jne    f0101384 <page_alloc+0x26>
f010137c:	89 1d ac 72 1d f0    	mov    %ebx,0xf01d72ac
f0101382:	eb 4e                	jmp    f01013d2 <page_alloc+0x74>
f0101384:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101389:	75 eb                	jne    f0101376 <page_alloc+0x18>
f010138b:	eb 4c                	jmp    f01013d9 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010138d:	89 d8                	mov    %ebx,%eax
f010138f:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101395:	c1 f8 03             	sar    $0x3,%eax
f0101398:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010139b:	89 c2                	mov    %eax,%edx
f010139d:	c1 ea 0c             	shr    $0xc,%edx
f01013a0:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f01013a6:	72 12                	jb     f01013ba <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013a8:	50                   	push   %eax
f01013a9:	68 74 51 10 f0       	push   $0xf0105174
f01013ae:	6a 56                	push   $0x56
f01013b0:	68 e1 58 10 f0       	push   $0xf01058e1
f01013b5:	e8 1b ed ff ff       	call   f01000d5 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f01013ba:	83 ec 04             	sub    $0x4,%esp
f01013bd:	68 00 10 00 00       	push   $0x1000
f01013c2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013c9:	50                   	push   %eax
f01013ca:	e8 06 2f 00 00       	call   f01042d5 <memset>
f01013cf:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f01013d2:	89 d8                	mov    %ebx,%eax
f01013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013d7:	c9                   	leave  
f01013d8:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f01013d9:	8b 03                	mov    (%ebx),%eax
f01013db:	a3 ac 72 1d f0       	mov    %eax,0xf01d72ac
        if (alloc_flags & ALLOC_ZERO) {
f01013e0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013e4:	74 ec                	je     f01013d2 <page_alloc+0x74>
f01013e6:	eb a5                	jmp    f010138d <page_alloc+0x2f>

f01013e8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01013e8:	55                   	push   %ebp
f01013e9:	89 e5                	mov    %esp,%ebp
f01013eb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f01013ee:	85 c0                	test   %eax,%eax
f01013f0:	74 14                	je     f0101406 <page_free+0x1e>
f01013f2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01013f7:	75 0d                	jne    f0101406 <page_free+0x1e>
    pp->pp_link = page_free_list;
f01013f9:	8b 15 ac 72 1d f0    	mov    0xf01d72ac,%edx
f01013ff:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101401:	a3 ac 72 1d f0       	mov    %eax,0xf01d72ac
}
f0101406:	c9                   	leave  
f0101407:	c3                   	ret    

f0101408 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101408:	55                   	push   %ebp
f0101409:	89 e5                	mov    %esp,%ebp
f010140b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010140e:	8b 50 04             	mov    0x4(%eax),%edx
f0101411:	4a                   	dec    %edx
f0101412:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101416:	66 85 d2             	test   %dx,%dx
f0101419:	75 09                	jne    f0101424 <page_decref+0x1c>
		page_free(pp);
f010141b:	50                   	push   %eax
f010141c:	e8 c7 ff ff ff       	call   f01013e8 <page_free>
f0101421:	83 c4 04             	add    $0x4,%esp
}
f0101424:	c9                   	leave  
f0101425:	c3                   	ret    

f0101426 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101426:	55                   	push   %ebp
f0101427:	89 e5                	mov    %esp,%ebp
f0101429:	56                   	push   %esi
f010142a:	53                   	push   %ebx
f010142b:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f010142e:	89 f3                	mov    %esi,%ebx
f0101430:	c1 eb 16             	shr    $0x16,%ebx
f0101433:	c1 e3 02             	shl    $0x2,%ebx
f0101436:	03 5d 08             	add    0x8(%ebp),%ebx
f0101439:	8b 03                	mov    (%ebx),%eax
f010143b:	85 c0                	test   %eax,%eax
f010143d:	74 04                	je     f0101443 <pgdir_walk+0x1d>
f010143f:	a8 01                	test   $0x1,%al
f0101441:	75 2c                	jne    f010146f <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0101443:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101447:	74 61                	je     f01014aa <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f0101449:	83 ec 0c             	sub    $0xc,%esp
f010144c:	6a 01                	push   $0x1
f010144e:	e8 0b ff ff ff       	call   f010135e <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	85 c0                	test   %eax,%eax
f0101458:	74 57                	je     f01014b1 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f010145a:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010145e:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101464:	c1 f8 03             	sar    $0x3,%eax
f0101467:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010146a:	83 c8 07             	or     $0x7,%eax
f010146d:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f010146f:	8b 03                	mov    (%ebx),%eax
f0101471:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101476:	89 c2                	mov    %eax,%edx
f0101478:	c1 ea 0c             	shr    $0xc,%edx
f010147b:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0101481:	72 15                	jb     f0101498 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101483:	50                   	push   %eax
f0101484:	68 74 51 10 f0       	push   $0xf0105174
f0101489:	68 87 01 00 00       	push   $0x187
f010148e:	68 d5 58 10 f0       	push   $0xf01058d5
f0101493:	e8 3d ec ff ff       	call   f01000d5 <_panic>
f0101498:	c1 ee 0a             	shr    $0xa,%esi
f010149b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01014a1:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01014a8:	eb 0c                	jmp    f01014b6 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f01014aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01014af:	eb 05                	jmp    f01014b6 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f01014b1:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01014b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014b9:	5b                   	pop    %ebx
f01014ba:	5e                   	pop    %esi
f01014bb:	c9                   	leave  
f01014bc:	c3                   	ret    

f01014bd <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014bd:	55                   	push   %ebp
f01014be:	89 e5                	mov    %esp,%ebp
f01014c0:	57                   	push   %edi
f01014c1:	56                   	push   %esi
f01014c2:	53                   	push   %ebx
f01014c3:	83 ec 1c             	sub    $0x1c,%esp
f01014c6:	89 c7                	mov    %eax,%edi
f01014c8:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014cb:	01 d1                	add    %edx,%ecx
f01014cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014d0:	39 ca                	cmp    %ecx,%edx
f01014d2:	74 32                	je     f0101506 <boot_map_region+0x49>
f01014d4:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d9:	83 c8 01             	or     $0x1,%eax
f01014dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f01014df:	83 ec 04             	sub    $0x4,%esp
f01014e2:	6a 01                	push   $0x1
f01014e4:	53                   	push   %ebx
f01014e5:	57                   	push   %edi
f01014e6:	e8 3b ff ff ff       	call   f0101426 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014ee:	09 f2                	or     %esi,%edx
f01014f0:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014f2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01014f8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01014fe:	83 c4 10             	add    $0x10,%esp
f0101501:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101504:	75 d9                	jne    f01014df <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f0101506:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101509:	5b                   	pop    %ebx
f010150a:	5e                   	pop    %esi
f010150b:	5f                   	pop    %edi
f010150c:	c9                   	leave  
f010150d:	c3                   	ret    

f010150e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	53                   	push   %ebx
f0101512:	83 ec 08             	sub    $0x8,%esp
f0101515:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101518:	6a 00                	push   $0x0
f010151a:	ff 75 0c             	pushl  0xc(%ebp)
f010151d:	ff 75 08             	pushl  0x8(%ebp)
f0101520:	e8 01 ff ff ff       	call   f0101426 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101525:	83 c4 10             	add    $0x10,%esp
f0101528:	85 c0                	test   %eax,%eax
f010152a:	74 37                	je     f0101563 <page_lookup+0x55>
f010152c:	f6 00 01             	testb  $0x1,(%eax)
f010152f:	74 39                	je     f010156a <page_lookup+0x5c>
    if (pte_store != 0) {
f0101531:	85 db                	test   %ebx,%ebx
f0101533:	74 02                	je     f0101537 <page_lookup+0x29>
        *pte_store = pte;
f0101535:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f0101537:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101539:	c1 e8 0c             	shr    $0xc,%eax
f010153c:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0101542:	72 14                	jb     f0101558 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101544:	83 ec 04             	sub    $0x4,%esp
f0101547:	68 5c 52 10 f0       	push   $0xf010525c
f010154c:	6a 4f                	push   $0x4f
f010154e:	68 e1 58 10 f0       	push   $0xf01058e1
f0101553:	e8 7d eb ff ff       	call   f01000d5 <_panic>
	return &pages[PGNUM(pa)];
f0101558:	c1 e0 03             	shl    $0x3,%eax
f010155b:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f0101561:	eb 0c                	jmp    f010156f <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101563:	b8 00 00 00 00       	mov    $0x0,%eax
f0101568:	eb 05                	jmp    f010156f <page_lookup+0x61>
f010156a:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f010156f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101572:	c9                   	leave  
f0101573:	c3                   	ret    

f0101574 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101574:	55                   	push   %ebp
f0101575:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101577:	8b 45 0c             	mov    0xc(%ebp),%eax
f010157a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010157d:	c9                   	leave  
f010157e:	c3                   	ret    

f010157f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010157f:	55                   	push   %ebp
f0101580:	89 e5                	mov    %esp,%ebp
f0101582:	56                   	push   %esi
f0101583:	53                   	push   %ebx
f0101584:	83 ec 14             	sub    $0x14,%esp
f0101587:	8b 75 08             	mov    0x8(%ebp),%esi
f010158a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101590:	50                   	push   %eax
f0101591:	53                   	push   %ebx
f0101592:	56                   	push   %esi
f0101593:	e8 76 ff ff ff       	call   f010150e <page_lookup>
    if (pg == NULL) return;
f0101598:	83 c4 10             	add    $0x10,%esp
f010159b:	85 c0                	test   %eax,%eax
f010159d:	74 26                	je     f01015c5 <page_remove+0x46>
    page_decref(pg);
f010159f:	83 ec 0c             	sub    $0xc,%esp
f01015a2:	50                   	push   %eax
f01015a3:	e8 60 fe ff ff       	call   f0101408 <page_decref>
    if (pte != NULL) *pte = 0;
f01015a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015ab:	83 c4 10             	add    $0x10,%esp
f01015ae:	85 c0                	test   %eax,%eax
f01015b0:	74 06                	je     f01015b8 <page_remove+0x39>
f01015b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f01015b8:	83 ec 08             	sub    $0x8,%esp
f01015bb:	53                   	push   %ebx
f01015bc:	56                   	push   %esi
f01015bd:	e8 b2 ff ff ff       	call   f0101574 <tlb_invalidate>
f01015c2:	83 c4 10             	add    $0x10,%esp
}
f01015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015c8:	5b                   	pop    %ebx
f01015c9:	5e                   	pop    %esi
f01015ca:	c9                   	leave  
f01015cb:	c3                   	ret    

f01015cc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01015cc:	55                   	push   %ebp
f01015cd:	89 e5                	mov    %esp,%ebp
f01015cf:	57                   	push   %edi
f01015d0:	56                   	push   %esi
f01015d1:	53                   	push   %ebx
f01015d2:	83 ec 10             	sub    $0x10,%esp
f01015d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015d8:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01015db:	6a 01                	push   $0x1
f01015dd:	57                   	push   %edi
f01015de:	ff 75 08             	pushl  0x8(%ebp)
f01015e1:	e8 40 fe ff ff       	call   f0101426 <pgdir_walk>
f01015e6:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01015e8:	83 c4 10             	add    $0x10,%esp
f01015eb:	85 c0                	test   %eax,%eax
f01015ed:	74 39                	je     f0101628 <page_insert+0x5c>
    ++pp->pp_ref;
f01015ef:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01015f3:	f6 00 01             	testb  $0x1,(%eax)
f01015f6:	74 0f                	je     f0101607 <page_insert+0x3b>
        page_remove(pgdir, va);
f01015f8:	83 ec 08             	sub    $0x8,%esp
f01015fb:	57                   	push   %edi
f01015fc:	ff 75 08             	pushl  0x8(%ebp)
f01015ff:	e8 7b ff ff ff       	call   f010157f <page_remove>
f0101604:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f0101607:	8b 55 14             	mov    0x14(%ebp),%edx
f010160a:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010160d:	2b 35 8c 7f 1d f0    	sub    0xf01d7f8c,%esi
f0101613:	c1 fe 03             	sar    $0x3,%esi
f0101616:	89 f0                	mov    %esi,%eax
f0101618:	c1 e0 0c             	shl    $0xc,%eax
f010161b:	89 d6                	mov    %edx,%esi
f010161d:	09 c6                	or     %eax,%esi
f010161f:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101621:	b8 00 00 00 00       	mov    $0x0,%eax
f0101626:	eb 05                	jmp    f010162d <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101628:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f010162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101630:	5b                   	pop    %ebx
f0101631:	5e                   	pop    %esi
f0101632:	5f                   	pop    %edi
f0101633:	c9                   	leave  
f0101634:	c3                   	ret    

f0101635 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101635:	55                   	push   %ebp
f0101636:	89 e5                	mov    %esp,%ebp
f0101638:	57                   	push   %edi
f0101639:	56                   	push   %esi
f010163a:	53                   	push   %ebx
f010163b:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010163e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101643:	e8 89 f9 ff ff       	call   f0100fd1 <nvram_read>
f0101648:	c1 e0 0a             	shl    $0xa,%eax
f010164b:	89 c2                	mov    %eax,%edx
f010164d:	85 c0                	test   %eax,%eax
f010164f:	79 06                	jns    f0101657 <mem_init+0x22>
f0101651:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101657:	c1 fa 0c             	sar    $0xc,%edx
f010165a:	89 15 b4 72 1d f0    	mov    %edx,0xf01d72b4
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101660:	b8 17 00 00 00       	mov    $0x17,%eax
f0101665:	e8 67 f9 ff ff       	call   f0100fd1 <nvram_read>
f010166a:	89 c2                	mov    %eax,%edx
f010166c:	c1 e2 0a             	shl    $0xa,%edx
f010166f:	89 d0                	mov    %edx,%eax
f0101671:	85 d2                	test   %edx,%edx
f0101673:	79 06                	jns    f010167b <mem_init+0x46>
f0101675:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010167b:	c1 f8 0c             	sar    $0xc,%eax
f010167e:	74 0e                	je     f010168e <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101680:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101686:	89 15 84 7f 1d f0    	mov    %edx,0xf01d7f84
f010168c:	eb 0c                	jmp    f010169a <mem_init+0x65>
	else
		npages = npages_basemem;
f010168e:	8b 15 b4 72 1d f0    	mov    0xf01d72b4,%edx
f0101694:	89 15 84 7f 1d f0    	mov    %edx,0xf01d7f84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010169a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010169d:	c1 e8 0a             	shr    $0xa,%eax
f01016a0:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01016a1:	a1 b4 72 1d f0       	mov    0xf01d72b4,%eax
f01016a6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016a9:	c1 e8 0a             	shr    $0xa,%eax
f01016ac:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01016ad:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01016b2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016b5:	c1 e8 0a             	shr    $0xa,%eax
f01016b8:	50                   	push   %eax
f01016b9:	68 7c 52 10 f0       	push   $0xf010527c
f01016be:	e8 42 1d 00 00       	call   f0103405 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016c3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016c8:	e8 6b f8 ff ff       	call   f0100f38 <boot_alloc>
f01016cd:	a3 88 7f 1d f0       	mov    %eax,0xf01d7f88
	memset(kern_pgdir, 0, PGSIZE);
f01016d2:	83 c4 0c             	add    $0xc,%esp
f01016d5:	68 00 10 00 00       	push   $0x1000
f01016da:	6a 00                	push   $0x0
f01016dc:	50                   	push   %eax
f01016dd:	e8 f3 2b 00 00       	call   f01042d5 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016e2:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016e7:	83 c4 10             	add    $0x10,%esp
f01016ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016ef:	77 15                	ja     f0101706 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016f1:	50                   	push   %eax
f01016f2:	68 b4 4f 10 f0       	push   $0xf0104fb4
f01016f7:	68 8e 00 00 00       	push   $0x8e
f01016fc:	68 d5 58 10 f0       	push   $0xf01058d5
f0101701:	e8 cf e9 ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101706:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010170c:	83 ca 05             	or     $0x5,%edx
f010170f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101715:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f010171a:	c1 e0 03             	shl    $0x3,%eax
f010171d:	e8 16 f8 ff ff       	call   f0100f38 <boot_alloc>
f0101722:	a3 8c 7f 1d f0       	mov    %eax,0xf01d7f8c
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101727:	b8 00 80 01 00       	mov    $0x18000,%eax
f010172c:	e8 07 f8 ff ff       	call   f0100f38 <boot_alloc>
f0101731:	a3 b8 72 1d f0       	mov    %eax,0xf01d72b8
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101736:	e8 76 fb ff ff       	call   f01012b1 <page_init>

	check_page_free_list(1);
f010173b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101740:	e8 b3 f8 ff ff       	call   f0100ff8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101745:	83 3d 8c 7f 1d f0 00 	cmpl   $0x0,0xf01d7f8c
f010174c:	75 17                	jne    f0101765 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f010174e:	83 ec 04             	sub    $0x4,%esp
f0101751:	68 8b 59 10 f0       	push   $0xf010598b
f0101756:	68 85 02 00 00       	push   $0x285
f010175b:	68 d5 58 10 f0       	push   $0xf01058d5
f0101760:	e8 70 e9 ff ff       	call   f01000d5 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101765:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f010176a:	85 c0                	test   %eax,%eax
f010176c:	74 0e                	je     f010177c <mem_init+0x147>
f010176e:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101773:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101774:	8b 00                	mov    (%eax),%eax
f0101776:	85 c0                	test   %eax,%eax
f0101778:	75 f9                	jne    f0101773 <mem_init+0x13e>
f010177a:	eb 05                	jmp    f0101781 <mem_init+0x14c>
f010177c:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101781:	83 ec 0c             	sub    $0xc,%esp
f0101784:	6a 00                	push   $0x0
f0101786:	e8 d3 fb ff ff       	call   f010135e <page_alloc>
f010178b:	89 c6                	mov    %eax,%esi
f010178d:	83 c4 10             	add    $0x10,%esp
f0101790:	85 c0                	test   %eax,%eax
f0101792:	75 19                	jne    f01017ad <mem_init+0x178>
f0101794:	68 a6 59 10 f0       	push   $0xf01059a6
f0101799:	68 fb 58 10 f0       	push   $0xf01058fb
f010179e:	68 8d 02 00 00       	push   $0x28d
f01017a3:	68 d5 58 10 f0       	push   $0xf01058d5
f01017a8:	e8 28 e9 ff ff       	call   f01000d5 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ad:	83 ec 0c             	sub    $0xc,%esp
f01017b0:	6a 00                	push   $0x0
f01017b2:	e8 a7 fb ff ff       	call   f010135e <page_alloc>
f01017b7:	89 c7                	mov    %eax,%edi
f01017b9:	83 c4 10             	add    $0x10,%esp
f01017bc:	85 c0                	test   %eax,%eax
f01017be:	75 19                	jne    f01017d9 <mem_init+0x1a4>
f01017c0:	68 bc 59 10 f0       	push   $0xf01059bc
f01017c5:	68 fb 58 10 f0       	push   $0xf01058fb
f01017ca:	68 8e 02 00 00       	push   $0x28e
f01017cf:	68 d5 58 10 f0       	push   $0xf01058d5
f01017d4:	e8 fc e8 ff ff       	call   f01000d5 <_panic>
	assert((pp2 = page_alloc(0)));
f01017d9:	83 ec 0c             	sub    $0xc,%esp
f01017dc:	6a 00                	push   $0x0
f01017de:	e8 7b fb ff ff       	call   f010135e <page_alloc>
f01017e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017e6:	83 c4 10             	add    $0x10,%esp
f01017e9:	85 c0                	test   %eax,%eax
f01017eb:	75 19                	jne    f0101806 <mem_init+0x1d1>
f01017ed:	68 d2 59 10 f0       	push   $0xf01059d2
f01017f2:	68 fb 58 10 f0       	push   $0xf01058fb
f01017f7:	68 8f 02 00 00       	push   $0x28f
f01017fc:	68 d5 58 10 f0       	push   $0xf01058d5
f0101801:	e8 cf e8 ff ff       	call   f01000d5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101806:	39 fe                	cmp    %edi,%esi
f0101808:	75 19                	jne    f0101823 <mem_init+0x1ee>
f010180a:	68 e8 59 10 f0       	push   $0xf01059e8
f010180f:	68 fb 58 10 f0       	push   $0xf01058fb
f0101814:	68 92 02 00 00       	push   $0x292
f0101819:	68 d5 58 10 f0       	push   $0xf01058d5
f010181e:	e8 b2 e8 ff ff       	call   f01000d5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101823:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101826:	74 05                	je     f010182d <mem_init+0x1f8>
f0101828:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010182b:	75 19                	jne    f0101846 <mem_init+0x211>
f010182d:	68 b8 52 10 f0       	push   $0xf01052b8
f0101832:	68 fb 58 10 f0       	push   $0xf01058fb
f0101837:	68 93 02 00 00       	push   $0x293
f010183c:	68 d5 58 10 f0       	push   $0xf01058d5
f0101841:	e8 8f e8 ff ff       	call   f01000d5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101846:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010184c:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f0101851:	c1 e0 0c             	shl    $0xc,%eax
f0101854:	89 f1                	mov    %esi,%ecx
f0101856:	29 d1                	sub    %edx,%ecx
f0101858:	c1 f9 03             	sar    $0x3,%ecx
f010185b:	c1 e1 0c             	shl    $0xc,%ecx
f010185e:	39 c1                	cmp    %eax,%ecx
f0101860:	72 19                	jb     f010187b <mem_init+0x246>
f0101862:	68 fa 59 10 f0       	push   $0xf01059fa
f0101867:	68 fb 58 10 f0       	push   $0xf01058fb
f010186c:	68 94 02 00 00       	push   $0x294
f0101871:	68 d5 58 10 f0       	push   $0xf01058d5
f0101876:	e8 5a e8 ff ff       	call   f01000d5 <_panic>
f010187b:	89 f9                	mov    %edi,%ecx
f010187d:	29 d1                	sub    %edx,%ecx
f010187f:	c1 f9 03             	sar    $0x3,%ecx
f0101882:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101885:	39 c8                	cmp    %ecx,%eax
f0101887:	77 19                	ja     f01018a2 <mem_init+0x26d>
f0101889:	68 17 5a 10 f0       	push   $0xf0105a17
f010188e:	68 fb 58 10 f0       	push   $0xf01058fb
f0101893:	68 95 02 00 00       	push   $0x295
f0101898:	68 d5 58 10 f0       	push   $0xf01058d5
f010189d:	e8 33 e8 ff ff       	call   f01000d5 <_panic>
f01018a2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01018a5:	29 d1                	sub    %edx,%ecx
f01018a7:	89 ca                	mov    %ecx,%edx
f01018a9:	c1 fa 03             	sar    $0x3,%edx
f01018ac:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018af:	39 d0                	cmp    %edx,%eax
f01018b1:	77 19                	ja     f01018cc <mem_init+0x297>
f01018b3:	68 34 5a 10 f0       	push   $0xf0105a34
f01018b8:	68 fb 58 10 f0       	push   $0xf01058fb
f01018bd:	68 96 02 00 00       	push   $0x296
f01018c2:	68 d5 58 10 f0       	push   $0xf01058d5
f01018c7:	e8 09 e8 ff ff       	call   f01000d5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018cc:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f01018d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018d4:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f01018db:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018de:	83 ec 0c             	sub    $0xc,%esp
f01018e1:	6a 00                	push   $0x0
f01018e3:	e8 76 fa ff ff       	call   f010135e <page_alloc>
f01018e8:	83 c4 10             	add    $0x10,%esp
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	74 19                	je     f0101908 <mem_init+0x2d3>
f01018ef:	68 51 5a 10 f0       	push   $0xf0105a51
f01018f4:	68 fb 58 10 f0       	push   $0xf01058fb
f01018f9:	68 9d 02 00 00       	push   $0x29d
f01018fe:	68 d5 58 10 f0       	push   $0xf01058d5
f0101903:	e8 cd e7 ff ff       	call   f01000d5 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101908:	83 ec 0c             	sub    $0xc,%esp
f010190b:	56                   	push   %esi
f010190c:	e8 d7 fa ff ff       	call   f01013e8 <page_free>
	page_free(pp1);
f0101911:	89 3c 24             	mov    %edi,(%esp)
f0101914:	e8 cf fa ff ff       	call   f01013e8 <page_free>
	page_free(pp2);
f0101919:	83 c4 04             	add    $0x4,%esp
f010191c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010191f:	e8 c4 fa ff ff       	call   f01013e8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101924:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010192b:	e8 2e fa ff ff       	call   f010135e <page_alloc>
f0101930:	89 c6                	mov    %eax,%esi
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	85 c0                	test   %eax,%eax
f0101937:	75 19                	jne    f0101952 <mem_init+0x31d>
f0101939:	68 a6 59 10 f0       	push   $0xf01059a6
f010193e:	68 fb 58 10 f0       	push   $0xf01058fb
f0101943:	68 a4 02 00 00       	push   $0x2a4
f0101948:	68 d5 58 10 f0       	push   $0xf01058d5
f010194d:	e8 83 e7 ff ff       	call   f01000d5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101952:	83 ec 0c             	sub    $0xc,%esp
f0101955:	6a 00                	push   $0x0
f0101957:	e8 02 fa ff ff       	call   f010135e <page_alloc>
f010195c:	89 c7                	mov    %eax,%edi
f010195e:	83 c4 10             	add    $0x10,%esp
f0101961:	85 c0                	test   %eax,%eax
f0101963:	75 19                	jne    f010197e <mem_init+0x349>
f0101965:	68 bc 59 10 f0       	push   $0xf01059bc
f010196a:	68 fb 58 10 f0       	push   $0xf01058fb
f010196f:	68 a5 02 00 00       	push   $0x2a5
f0101974:	68 d5 58 10 f0       	push   $0xf01058d5
f0101979:	e8 57 e7 ff ff       	call   f01000d5 <_panic>
	assert((pp2 = page_alloc(0)));
f010197e:	83 ec 0c             	sub    $0xc,%esp
f0101981:	6a 00                	push   $0x0
f0101983:	e8 d6 f9 ff ff       	call   f010135e <page_alloc>
f0101988:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010198b:	83 c4 10             	add    $0x10,%esp
f010198e:	85 c0                	test   %eax,%eax
f0101990:	75 19                	jne    f01019ab <mem_init+0x376>
f0101992:	68 d2 59 10 f0       	push   $0xf01059d2
f0101997:	68 fb 58 10 f0       	push   $0xf01058fb
f010199c:	68 a6 02 00 00       	push   $0x2a6
f01019a1:	68 d5 58 10 f0       	push   $0xf01058d5
f01019a6:	e8 2a e7 ff ff       	call   f01000d5 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ab:	39 fe                	cmp    %edi,%esi
f01019ad:	75 19                	jne    f01019c8 <mem_init+0x393>
f01019af:	68 e8 59 10 f0       	push   $0xf01059e8
f01019b4:	68 fb 58 10 f0       	push   $0xf01058fb
f01019b9:	68 a8 02 00 00       	push   $0x2a8
f01019be:	68 d5 58 10 f0       	push   $0xf01058d5
f01019c3:	e8 0d e7 ff ff       	call   f01000d5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019c8:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01019cb:	74 05                	je     f01019d2 <mem_init+0x39d>
f01019cd:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019d0:	75 19                	jne    f01019eb <mem_init+0x3b6>
f01019d2:	68 b8 52 10 f0       	push   $0xf01052b8
f01019d7:	68 fb 58 10 f0       	push   $0xf01058fb
f01019dc:	68 a9 02 00 00       	push   $0x2a9
f01019e1:	68 d5 58 10 f0       	push   $0xf01058d5
f01019e6:	e8 ea e6 ff ff       	call   f01000d5 <_panic>
	assert(!page_alloc(0));
f01019eb:	83 ec 0c             	sub    $0xc,%esp
f01019ee:	6a 00                	push   $0x0
f01019f0:	e8 69 f9 ff ff       	call   f010135e <page_alloc>
f01019f5:	83 c4 10             	add    $0x10,%esp
f01019f8:	85 c0                	test   %eax,%eax
f01019fa:	74 19                	je     f0101a15 <mem_init+0x3e0>
f01019fc:	68 51 5a 10 f0       	push   $0xf0105a51
f0101a01:	68 fb 58 10 f0       	push   $0xf01058fb
f0101a06:	68 aa 02 00 00       	push   $0x2aa
f0101a0b:	68 d5 58 10 f0       	push   $0xf01058d5
f0101a10:	e8 c0 e6 ff ff       	call   f01000d5 <_panic>
f0101a15:	89 f0                	mov    %esi,%eax
f0101a17:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0101a1d:	c1 f8 03             	sar    $0x3,%eax
f0101a20:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a23:	89 c2                	mov    %eax,%edx
f0101a25:	c1 ea 0c             	shr    $0xc,%edx
f0101a28:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0101a2e:	72 12                	jb     f0101a42 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a30:	50                   	push   %eax
f0101a31:	68 74 51 10 f0       	push   $0xf0105174
f0101a36:	6a 56                	push   $0x56
f0101a38:	68 e1 58 10 f0       	push   $0xf01058e1
f0101a3d:	e8 93 e6 ff ff       	call   f01000d5 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a42:	83 ec 04             	sub    $0x4,%esp
f0101a45:	68 00 10 00 00       	push   $0x1000
f0101a4a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a51:	50                   	push   %eax
f0101a52:	e8 7e 28 00 00       	call   f01042d5 <memset>
	page_free(pp0);
f0101a57:	89 34 24             	mov    %esi,(%esp)
f0101a5a:	e8 89 f9 ff ff       	call   f01013e8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a66:	e8 f3 f8 ff ff       	call   f010135e <page_alloc>
f0101a6b:	83 c4 10             	add    $0x10,%esp
f0101a6e:	85 c0                	test   %eax,%eax
f0101a70:	75 19                	jne    f0101a8b <mem_init+0x456>
f0101a72:	68 60 5a 10 f0       	push   $0xf0105a60
f0101a77:	68 fb 58 10 f0       	push   $0xf01058fb
f0101a7c:	68 af 02 00 00       	push   $0x2af
f0101a81:	68 d5 58 10 f0       	push   $0xf01058d5
f0101a86:	e8 4a e6 ff ff       	call   f01000d5 <_panic>
	assert(pp && pp0 == pp);
f0101a8b:	39 c6                	cmp    %eax,%esi
f0101a8d:	74 19                	je     f0101aa8 <mem_init+0x473>
f0101a8f:	68 7e 5a 10 f0       	push   $0xf0105a7e
f0101a94:	68 fb 58 10 f0       	push   $0xf01058fb
f0101a99:	68 b0 02 00 00       	push   $0x2b0
f0101a9e:	68 d5 58 10 f0       	push   $0xf01058d5
f0101aa3:	e8 2d e6 ff ff       	call   f01000d5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aa8:	89 f2                	mov    %esi,%edx
f0101aaa:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101ab0:	c1 fa 03             	sar    $0x3,%edx
f0101ab3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ab6:	89 d0                	mov    %edx,%eax
f0101ab8:	c1 e8 0c             	shr    $0xc,%eax
f0101abb:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0101ac1:	72 12                	jb     f0101ad5 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ac3:	52                   	push   %edx
f0101ac4:	68 74 51 10 f0       	push   $0xf0105174
f0101ac9:	6a 56                	push   $0x56
f0101acb:	68 e1 58 10 f0       	push   $0xf01058e1
f0101ad0:	e8 00 e6 ff ff       	call   f01000d5 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ad5:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101adc:	75 11                	jne    f0101aef <mem_init+0x4ba>
f0101ade:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ae4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101aea:	80 38 00             	cmpb   $0x0,(%eax)
f0101aed:	74 19                	je     f0101b08 <mem_init+0x4d3>
f0101aef:	68 8e 5a 10 f0       	push   $0xf0105a8e
f0101af4:	68 fb 58 10 f0       	push   $0xf01058fb
f0101af9:	68 b3 02 00 00       	push   $0x2b3
f0101afe:	68 d5 58 10 f0       	push   $0xf01058d5
f0101b03:	e8 cd e5 ff ff       	call   f01000d5 <_panic>
f0101b08:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b09:	39 d0                	cmp    %edx,%eax
f0101b0b:	75 dd                	jne    f0101aea <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b0d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b10:	89 0d ac 72 1d f0    	mov    %ecx,0xf01d72ac

	// free the pages we took
	page_free(pp0);
f0101b16:	83 ec 0c             	sub    $0xc,%esp
f0101b19:	56                   	push   %esi
f0101b1a:	e8 c9 f8 ff ff       	call   f01013e8 <page_free>
	page_free(pp1);
f0101b1f:	89 3c 24             	mov    %edi,(%esp)
f0101b22:	e8 c1 f8 ff ff       	call   f01013e8 <page_free>
	page_free(pp2);
f0101b27:	83 c4 04             	add    $0x4,%esp
f0101b2a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b2d:	e8 b6 f8 ff ff       	call   f01013e8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b32:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f0101b37:	83 c4 10             	add    $0x10,%esp
f0101b3a:	85 c0                	test   %eax,%eax
f0101b3c:	74 07                	je     f0101b45 <mem_init+0x510>
		--nfree;
f0101b3e:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b3f:	8b 00                	mov    (%eax),%eax
f0101b41:	85 c0                	test   %eax,%eax
f0101b43:	75 f9                	jne    f0101b3e <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101b45:	85 db                	test   %ebx,%ebx
f0101b47:	74 19                	je     f0101b62 <mem_init+0x52d>
f0101b49:	68 98 5a 10 f0       	push   $0xf0105a98
f0101b4e:	68 fb 58 10 f0       	push   $0xf01058fb
f0101b53:	68 c0 02 00 00       	push   $0x2c0
f0101b58:	68 d5 58 10 f0       	push   $0xf01058d5
f0101b5d:	e8 73 e5 ff ff       	call   f01000d5 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b62:	83 ec 0c             	sub    $0xc,%esp
f0101b65:	68 d8 52 10 f0       	push   $0xf01052d8
f0101b6a:	e8 96 18 00 00       	call   f0103405 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b76:	e8 e3 f7 ff ff       	call   f010135e <page_alloc>
f0101b7b:	89 c7                	mov    %eax,%edi
f0101b7d:	83 c4 10             	add    $0x10,%esp
f0101b80:	85 c0                	test   %eax,%eax
f0101b82:	75 19                	jne    f0101b9d <mem_init+0x568>
f0101b84:	68 a6 59 10 f0       	push   $0xf01059a6
f0101b89:	68 fb 58 10 f0       	push   $0xf01058fb
f0101b8e:	68 1e 03 00 00       	push   $0x31e
f0101b93:	68 d5 58 10 f0       	push   $0xf01058d5
f0101b98:	e8 38 e5 ff ff       	call   f01000d5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b9d:	83 ec 0c             	sub    $0xc,%esp
f0101ba0:	6a 00                	push   $0x0
f0101ba2:	e8 b7 f7 ff ff       	call   f010135e <page_alloc>
f0101ba7:	89 c6                	mov    %eax,%esi
f0101ba9:	83 c4 10             	add    $0x10,%esp
f0101bac:	85 c0                	test   %eax,%eax
f0101bae:	75 19                	jne    f0101bc9 <mem_init+0x594>
f0101bb0:	68 bc 59 10 f0       	push   $0xf01059bc
f0101bb5:	68 fb 58 10 f0       	push   $0xf01058fb
f0101bba:	68 1f 03 00 00       	push   $0x31f
f0101bbf:	68 d5 58 10 f0       	push   $0xf01058d5
f0101bc4:	e8 0c e5 ff ff       	call   f01000d5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bc9:	83 ec 0c             	sub    $0xc,%esp
f0101bcc:	6a 00                	push   $0x0
f0101bce:	e8 8b f7 ff ff       	call   f010135e <page_alloc>
f0101bd3:	89 c3                	mov    %eax,%ebx
f0101bd5:	83 c4 10             	add    $0x10,%esp
f0101bd8:	85 c0                	test   %eax,%eax
f0101bda:	75 19                	jne    f0101bf5 <mem_init+0x5c0>
f0101bdc:	68 d2 59 10 f0       	push   $0xf01059d2
f0101be1:	68 fb 58 10 f0       	push   $0xf01058fb
f0101be6:	68 20 03 00 00       	push   $0x320
f0101beb:	68 d5 58 10 f0       	push   $0xf01058d5
f0101bf0:	e8 e0 e4 ff ff       	call   f01000d5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bf5:	39 f7                	cmp    %esi,%edi
f0101bf7:	75 19                	jne    f0101c12 <mem_init+0x5dd>
f0101bf9:	68 e8 59 10 f0       	push   $0xf01059e8
f0101bfe:	68 fb 58 10 f0       	push   $0xf01058fb
f0101c03:	68 23 03 00 00       	push   $0x323
f0101c08:	68 d5 58 10 f0       	push   $0xf01058d5
f0101c0d:	e8 c3 e4 ff ff       	call   f01000d5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c12:	39 c6                	cmp    %eax,%esi
f0101c14:	74 04                	je     f0101c1a <mem_init+0x5e5>
f0101c16:	39 c7                	cmp    %eax,%edi
f0101c18:	75 19                	jne    f0101c33 <mem_init+0x5fe>
f0101c1a:	68 b8 52 10 f0       	push   $0xf01052b8
f0101c1f:	68 fb 58 10 f0       	push   $0xf01058fb
f0101c24:	68 24 03 00 00       	push   $0x324
f0101c29:	68 d5 58 10 f0       	push   $0xf01058d5
f0101c2e:	e8 a2 e4 ff ff       	call   f01000d5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c33:	a1 ac 72 1d f0       	mov    0xf01d72ac,%eax
f0101c38:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101c3b:	c7 05 ac 72 1d f0 00 	movl   $0x0,0xf01d72ac
f0101c42:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c45:	83 ec 0c             	sub    $0xc,%esp
f0101c48:	6a 00                	push   $0x0
f0101c4a:	e8 0f f7 ff ff       	call   f010135e <page_alloc>
f0101c4f:	83 c4 10             	add    $0x10,%esp
f0101c52:	85 c0                	test   %eax,%eax
f0101c54:	74 19                	je     f0101c6f <mem_init+0x63a>
f0101c56:	68 51 5a 10 f0       	push   $0xf0105a51
f0101c5b:	68 fb 58 10 f0       	push   $0xf01058fb
f0101c60:	68 2b 03 00 00       	push   $0x32b
f0101c65:	68 d5 58 10 f0       	push   $0xf01058d5
f0101c6a:	e8 66 e4 ff ff       	call   f01000d5 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c6f:	83 ec 04             	sub    $0x4,%esp
f0101c72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c75:	50                   	push   %eax
f0101c76:	6a 00                	push   $0x0
f0101c78:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101c7e:	e8 8b f8 ff ff       	call   f010150e <page_lookup>
f0101c83:	83 c4 10             	add    $0x10,%esp
f0101c86:	85 c0                	test   %eax,%eax
f0101c88:	74 19                	je     f0101ca3 <mem_init+0x66e>
f0101c8a:	68 f8 52 10 f0       	push   $0xf01052f8
f0101c8f:	68 fb 58 10 f0       	push   $0xf01058fb
f0101c94:	68 2e 03 00 00       	push   $0x32e
f0101c99:	68 d5 58 10 f0       	push   $0xf01058d5
f0101c9e:	e8 32 e4 ff ff       	call   f01000d5 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ca3:	6a 02                	push   $0x2
f0101ca5:	6a 00                	push   $0x0
f0101ca7:	56                   	push   %esi
f0101ca8:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101cae:	e8 19 f9 ff ff       	call   f01015cc <page_insert>
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	85 c0                	test   %eax,%eax
f0101cb8:	78 19                	js     f0101cd3 <mem_init+0x69e>
f0101cba:	68 30 53 10 f0       	push   $0xf0105330
f0101cbf:	68 fb 58 10 f0       	push   $0xf01058fb
f0101cc4:	68 31 03 00 00       	push   $0x331
f0101cc9:	68 d5 58 10 f0       	push   $0xf01058d5
f0101cce:	e8 02 e4 ff ff       	call   f01000d5 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101cd3:	83 ec 0c             	sub    $0xc,%esp
f0101cd6:	57                   	push   %edi
f0101cd7:	e8 0c f7 ff ff       	call   f01013e8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cdc:	6a 02                	push   $0x2
f0101cde:	6a 00                	push   $0x0
f0101ce0:	56                   	push   %esi
f0101ce1:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101ce7:	e8 e0 f8 ff ff       	call   f01015cc <page_insert>
f0101cec:	83 c4 20             	add    $0x20,%esp
f0101cef:	85 c0                	test   %eax,%eax
f0101cf1:	74 19                	je     f0101d0c <mem_init+0x6d7>
f0101cf3:	68 60 53 10 f0       	push   $0xf0105360
f0101cf8:	68 fb 58 10 f0       	push   $0xf01058fb
f0101cfd:	68 35 03 00 00       	push   $0x335
f0101d02:	68 d5 58 10 f0       	push   $0xf01058d5
f0101d07:	e8 c9 e3 ff ff       	call   f01000d5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d0c:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101d11:	8b 08                	mov    (%eax),%ecx
f0101d13:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d19:	89 fa                	mov    %edi,%edx
f0101d1b:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101d21:	c1 fa 03             	sar    $0x3,%edx
f0101d24:	c1 e2 0c             	shl    $0xc,%edx
f0101d27:	39 d1                	cmp    %edx,%ecx
f0101d29:	74 19                	je     f0101d44 <mem_init+0x70f>
f0101d2b:	68 90 53 10 f0       	push   $0xf0105390
f0101d30:	68 fb 58 10 f0       	push   $0xf01058fb
f0101d35:	68 36 03 00 00       	push   $0x336
f0101d3a:	68 d5 58 10 f0       	push   $0xf01058d5
f0101d3f:	e8 91 e3 ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d44:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d49:	e8 21 f2 ff ff       	call   f0100f6f <check_va2pa>
f0101d4e:	89 f2                	mov    %esi,%edx
f0101d50:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101d56:	c1 fa 03             	sar    $0x3,%edx
f0101d59:	c1 e2 0c             	shl    $0xc,%edx
f0101d5c:	39 d0                	cmp    %edx,%eax
f0101d5e:	74 19                	je     f0101d79 <mem_init+0x744>
f0101d60:	68 b8 53 10 f0       	push   $0xf01053b8
f0101d65:	68 fb 58 10 f0       	push   $0xf01058fb
f0101d6a:	68 37 03 00 00       	push   $0x337
f0101d6f:	68 d5 58 10 f0       	push   $0xf01058d5
f0101d74:	e8 5c e3 ff ff       	call   f01000d5 <_panic>
	assert(pp1->pp_ref == 1);
f0101d79:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d7e:	74 19                	je     f0101d99 <mem_init+0x764>
f0101d80:	68 a3 5a 10 f0       	push   $0xf0105aa3
f0101d85:	68 fb 58 10 f0       	push   $0xf01058fb
f0101d8a:	68 38 03 00 00       	push   $0x338
f0101d8f:	68 d5 58 10 f0       	push   $0xf01058d5
f0101d94:	e8 3c e3 ff ff       	call   f01000d5 <_panic>
	assert(pp0->pp_ref == 1);
f0101d99:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d9e:	74 19                	je     f0101db9 <mem_init+0x784>
f0101da0:	68 b4 5a 10 f0       	push   $0xf0105ab4
f0101da5:	68 fb 58 10 f0       	push   $0xf01058fb
f0101daa:	68 39 03 00 00       	push   $0x339
f0101daf:	68 d5 58 10 f0       	push   $0xf01058d5
f0101db4:	e8 1c e3 ff ff       	call   f01000d5 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101db9:	6a 02                	push   $0x2
f0101dbb:	68 00 10 00 00       	push   $0x1000
f0101dc0:	53                   	push   %ebx
f0101dc1:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101dc7:	e8 00 f8 ff ff       	call   f01015cc <page_insert>
f0101dcc:	83 c4 10             	add    $0x10,%esp
f0101dcf:	85 c0                	test   %eax,%eax
f0101dd1:	74 19                	je     f0101dec <mem_init+0x7b7>
f0101dd3:	68 e8 53 10 f0       	push   $0xf01053e8
f0101dd8:	68 fb 58 10 f0       	push   $0xf01058fb
f0101ddd:	68 3c 03 00 00       	push   $0x33c
f0101de2:	68 d5 58 10 f0       	push   $0xf01058d5
f0101de7:	e8 e9 e2 ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dec:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df1:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101df6:	e8 74 f1 ff ff       	call   f0100f6f <check_va2pa>
f0101dfb:	89 da                	mov    %ebx,%edx
f0101dfd:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101e03:	c1 fa 03             	sar    $0x3,%edx
f0101e06:	c1 e2 0c             	shl    $0xc,%edx
f0101e09:	39 d0                	cmp    %edx,%eax
f0101e0b:	74 19                	je     f0101e26 <mem_init+0x7f1>
f0101e0d:	68 24 54 10 f0       	push   $0xf0105424
f0101e12:	68 fb 58 10 f0       	push   $0xf01058fb
f0101e17:	68 3d 03 00 00       	push   $0x33d
f0101e1c:	68 d5 58 10 f0       	push   $0xf01058d5
f0101e21:	e8 af e2 ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 1);
f0101e26:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e2b:	74 19                	je     f0101e46 <mem_init+0x811>
f0101e2d:	68 c5 5a 10 f0       	push   $0xf0105ac5
f0101e32:	68 fb 58 10 f0       	push   $0xf01058fb
f0101e37:	68 3e 03 00 00       	push   $0x33e
f0101e3c:	68 d5 58 10 f0       	push   $0xf01058d5
f0101e41:	e8 8f e2 ff ff       	call   f01000d5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e46:	83 ec 0c             	sub    $0xc,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	e8 0e f5 ff ff       	call   f010135e <page_alloc>
f0101e50:	83 c4 10             	add    $0x10,%esp
f0101e53:	85 c0                	test   %eax,%eax
f0101e55:	74 19                	je     f0101e70 <mem_init+0x83b>
f0101e57:	68 51 5a 10 f0       	push   $0xf0105a51
f0101e5c:	68 fb 58 10 f0       	push   $0xf01058fb
f0101e61:	68 41 03 00 00       	push   $0x341
f0101e66:	68 d5 58 10 f0       	push   $0xf01058d5
f0101e6b:	e8 65 e2 ff ff       	call   f01000d5 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e70:	6a 02                	push   $0x2
f0101e72:	68 00 10 00 00       	push   $0x1000
f0101e77:	53                   	push   %ebx
f0101e78:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101e7e:	e8 49 f7 ff ff       	call   f01015cc <page_insert>
f0101e83:	83 c4 10             	add    $0x10,%esp
f0101e86:	85 c0                	test   %eax,%eax
f0101e88:	74 19                	je     f0101ea3 <mem_init+0x86e>
f0101e8a:	68 e8 53 10 f0       	push   $0xf01053e8
f0101e8f:	68 fb 58 10 f0       	push   $0xf01058fb
f0101e94:	68 44 03 00 00       	push   $0x344
f0101e99:	68 d5 58 10 f0       	push   $0xf01058d5
f0101e9e:	e8 32 e2 ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ea3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea8:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101ead:	e8 bd f0 ff ff       	call   f0100f6f <check_va2pa>
f0101eb2:	89 da                	mov    %ebx,%edx
f0101eb4:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101eba:	c1 fa 03             	sar    $0x3,%edx
f0101ebd:	c1 e2 0c             	shl    $0xc,%edx
f0101ec0:	39 d0                	cmp    %edx,%eax
f0101ec2:	74 19                	je     f0101edd <mem_init+0x8a8>
f0101ec4:	68 24 54 10 f0       	push   $0xf0105424
f0101ec9:	68 fb 58 10 f0       	push   $0xf01058fb
f0101ece:	68 45 03 00 00       	push   $0x345
f0101ed3:	68 d5 58 10 f0       	push   $0xf01058d5
f0101ed8:	e8 f8 e1 ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 1);
f0101edd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ee2:	74 19                	je     f0101efd <mem_init+0x8c8>
f0101ee4:	68 c5 5a 10 f0       	push   $0xf0105ac5
f0101ee9:	68 fb 58 10 f0       	push   $0xf01058fb
f0101eee:	68 46 03 00 00       	push   $0x346
f0101ef3:	68 d5 58 10 f0       	push   $0xf01058d5
f0101ef8:	e8 d8 e1 ff ff       	call   f01000d5 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101efd:	83 ec 0c             	sub    $0xc,%esp
f0101f00:	6a 00                	push   $0x0
f0101f02:	e8 57 f4 ff ff       	call   f010135e <page_alloc>
f0101f07:	83 c4 10             	add    $0x10,%esp
f0101f0a:	85 c0                	test   %eax,%eax
f0101f0c:	74 19                	je     f0101f27 <mem_init+0x8f2>
f0101f0e:	68 51 5a 10 f0       	push   $0xf0105a51
f0101f13:	68 fb 58 10 f0       	push   $0xf01058fb
f0101f18:	68 4a 03 00 00       	push   $0x34a
f0101f1d:	68 d5 58 10 f0       	push   $0xf01058d5
f0101f22:	e8 ae e1 ff ff       	call   f01000d5 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f27:	8b 15 88 7f 1d f0    	mov    0xf01d7f88,%edx
f0101f2d:	8b 02                	mov    (%edx),%eax
f0101f2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f34:	89 c1                	mov    %eax,%ecx
f0101f36:	c1 e9 0c             	shr    $0xc,%ecx
f0101f39:	3b 0d 84 7f 1d f0    	cmp    0xf01d7f84,%ecx
f0101f3f:	72 15                	jb     f0101f56 <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f41:	50                   	push   %eax
f0101f42:	68 74 51 10 f0       	push   $0xf0105174
f0101f47:	68 4d 03 00 00       	push   $0x34d
f0101f4c:	68 d5 58 10 f0       	push   $0xf01058d5
f0101f51:	e8 7f e1 ff ff       	call   f01000d5 <_panic>
	return (void *)(pa + KERNBASE);
f0101f56:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f5e:	83 ec 04             	sub    $0x4,%esp
f0101f61:	6a 00                	push   $0x0
f0101f63:	68 00 10 00 00       	push   $0x1000
f0101f68:	52                   	push   %edx
f0101f69:	e8 b8 f4 ff ff       	call   f0101426 <pgdir_walk>
f0101f6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f71:	83 c2 04             	add    $0x4,%edx
f0101f74:	83 c4 10             	add    $0x10,%esp
f0101f77:	39 d0                	cmp    %edx,%eax
f0101f79:	74 19                	je     f0101f94 <mem_init+0x95f>
f0101f7b:	68 54 54 10 f0       	push   $0xf0105454
f0101f80:	68 fb 58 10 f0       	push   $0xf01058fb
f0101f85:	68 4e 03 00 00       	push   $0x34e
f0101f8a:	68 d5 58 10 f0       	push   $0xf01058d5
f0101f8f:	e8 41 e1 ff ff       	call   f01000d5 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f94:	6a 06                	push   $0x6
f0101f96:	68 00 10 00 00       	push   $0x1000
f0101f9b:	53                   	push   %ebx
f0101f9c:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0101fa2:	e8 25 f6 ff ff       	call   f01015cc <page_insert>
f0101fa7:	83 c4 10             	add    $0x10,%esp
f0101faa:	85 c0                	test   %eax,%eax
f0101fac:	74 19                	je     f0101fc7 <mem_init+0x992>
f0101fae:	68 94 54 10 f0       	push   $0xf0105494
f0101fb3:	68 fb 58 10 f0       	push   $0xf01058fb
f0101fb8:	68 51 03 00 00       	push   $0x351
f0101fbd:	68 d5 58 10 f0       	push   $0xf01058d5
f0101fc2:	e8 0e e1 ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fc7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fcc:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0101fd1:	e8 99 ef ff ff       	call   f0100f6f <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fd6:	89 da                	mov    %ebx,%edx
f0101fd8:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0101fde:	c1 fa 03             	sar    $0x3,%edx
f0101fe1:	c1 e2 0c             	shl    $0xc,%edx
f0101fe4:	39 d0                	cmp    %edx,%eax
f0101fe6:	74 19                	je     f0102001 <mem_init+0x9cc>
f0101fe8:	68 24 54 10 f0       	push   $0xf0105424
f0101fed:	68 fb 58 10 f0       	push   $0xf01058fb
f0101ff2:	68 52 03 00 00       	push   $0x352
f0101ff7:	68 d5 58 10 f0       	push   $0xf01058d5
f0101ffc:	e8 d4 e0 ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 1);
f0102001:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102006:	74 19                	je     f0102021 <mem_init+0x9ec>
f0102008:	68 c5 5a 10 f0       	push   $0xf0105ac5
f010200d:	68 fb 58 10 f0       	push   $0xf01058fb
f0102012:	68 53 03 00 00       	push   $0x353
f0102017:	68 d5 58 10 f0       	push   $0xf01058d5
f010201c:	e8 b4 e0 ff ff       	call   f01000d5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102021:	83 ec 04             	sub    $0x4,%esp
f0102024:	6a 00                	push   $0x0
f0102026:	68 00 10 00 00       	push   $0x1000
f010202b:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102031:	e8 f0 f3 ff ff       	call   f0101426 <pgdir_walk>
f0102036:	83 c4 10             	add    $0x10,%esp
f0102039:	f6 00 04             	testb  $0x4,(%eax)
f010203c:	75 19                	jne    f0102057 <mem_init+0xa22>
f010203e:	68 d4 54 10 f0       	push   $0xf01054d4
f0102043:	68 fb 58 10 f0       	push   $0xf01058fb
f0102048:	68 54 03 00 00       	push   $0x354
f010204d:	68 d5 58 10 f0       	push   $0xf01058d5
f0102052:	e8 7e e0 ff ff       	call   f01000d5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102057:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010205c:	f6 00 04             	testb  $0x4,(%eax)
f010205f:	75 19                	jne    f010207a <mem_init+0xa45>
f0102061:	68 d6 5a 10 f0       	push   $0xf0105ad6
f0102066:	68 fb 58 10 f0       	push   $0xf01058fb
f010206b:	68 55 03 00 00       	push   $0x355
f0102070:	68 d5 58 10 f0       	push   $0xf01058d5
f0102075:	e8 5b e0 ff ff       	call   f01000d5 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010207a:	6a 02                	push   $0x2
f010207c:	68 00 10 00 00       	push   $0x1000
f0102081:	53                   	push   %ebx
f0102082:	50                   	push   %eax
f0102083:	e8 44 f5 ff ff       	call   f01015cc <page_insert>
f0102088:	83 c4 10             	add    $0x10,%esp
f010208b:	85 c0                	test   %eax,%eax
f010208d:	74 19                	je     f01020a8 <mem_init+0xa73>
f010208f:	68 e8 53 10 f0       	push   $0xf01053e8
f0102094:	68 fb 58 10 f0       	push   $0xf01058fb
f0102099:	68 58 03 00 00       	push   $0x358
f010209e:	68 d5 58 10 f0       	push   $0xf01058d5
f01020a3:	e8 2d e0 ff ff       	call   f01000d5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020a8:	83 ec 04             	sub    $0x4,%esp
f01020ab:	6a 00                	push   $0x0
f01020ad:	68 00 10 00 00       	push   $0x1000
f01020b2:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01020b8:	e8 69 f3 ff ff       	call   f0101426 <pgdir_walk>
f01020bd:	83 c4 10             	add    $0x10,%esp
f01020c0:	f6 00 02             	testb  $0x2,(%eax)
f01020c3:	75 19                	jne    f01020de <mem_init+0xaa9>
f01020c5:	68 08 55 10 f0       	push   $0xf0105508
f01020ca:	68 fb 58 10 f0       	push   $0xf01058fb
f01020cf:	68 59 03 00 00       	push   $0x359
f01020d4:	68 d5 58 10 f0       	push   $0xf01058d5
f01020d9:	e8 f7 df ff ff       	call   f01000d5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020de:	83 ec 04             	sub    $0x4,%esp
f01020e1:	6a 00                	push   $0x0
f01020e3:	68 00 10 00 00       	push   $0x1000
f01020e8:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f01020ee:	e8 33 f3 ff ff       	call   f0101426 <pgdir_walk>
f01020f3:	83 c4 10             	add    $0x10,%esp
f01020f6:	f6 00 04             	testb  $0x4,(%eax)
f01020f9:	74 19                	je     f0102114 <mem_init+0xadf>
f01020fb:	68 3c 55 10 f0       	push   $0xf010553c
f0102100:	68 fb 58 10 f0       	push   $0xf01058fb
f0102105:	68 5a 03 00 00       	push   $0x35a
f010210a:	68 d5 58 10 f0       	push   $0xf01058d5
f010210f:	e8 c1 df ff ff       	call   f01000d5 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102114:	6a 02                	push   $0x2
f0102116:	68 00 00 40 00       	push   $0x400000
f010211b:	57                   	push   %edi
f010211c:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102122:	e8 a5 f4 ff ff       	call   f01015cc <page_insert>
f0102127:	83 c4 10             	add    $0x10,%esp
f010212a:	85 c0                	test   %eax,%eax
f010212c:	78 19                	js     f0102147 <mem_init+0xb12>
f010212e:	68 74 55 10 f0       	push   $0xf0105574
f0102133:	68 fb 58 10 f0       	push   $0xf01058fb
f0102138:	68 5d 03 00 00       	push   $0x35d
f010213d:	68 d5 58 10 f0       	push   $0xf01058d5
f0102142:	e8 8e df ff ff       	call   f01000d5 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102147:	6a 02                	push   $0x2
f0102149:	68 00 10 00 00       	push   $0x1000
f010214e:	56                   	push   %esi
f010214f:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102155:	e8 72 f4 ff ff       	call   f01015cc <page_insert>
f010215a:	83 c4 10             	add    $0x10,%esp
f010215d:	85 c0                	test   %eax,%eax
f010215f:	74 19                	je     f010217a <mem_init+0xb45>
f0102161:	68 ac 55 10 f0       	push   $0xf01055ac
f0102166:	68 fb 58 10 f0       	push   $0xf01058fb
f010216b:	68 60 03 00 00       	push   $0x360
f0102170:	68 d5 58 10 f0       	push   $0xf01058d5
f0102175:	e8 5b df ff ff       	call   f01000d5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010217a:	83 ec 04             	sub    $0x4,%esp
f010217d:	6a 00                	push   $0x0
f010217f:	68 00 10 00 00       	push   $0x1000
f0102184:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010218a:	e8 97 f2 ff ff       	call   f0101426 <pgdir_walk>
f010218f:	83 c4 10             	add    $0x10,%esp
f0102192:	f6 00 04             	testb  $0x4,(%eax)
f0102195:	74 19                	je     f01021b0 <mem_init+0xb7b>
f0102197:	68 3c 55 10 f0       	push   $0xf010553c
f010219c:	68 fb 58 10 f0       	push   $0xf01058fb
f01021a1:	68 61 03 00 00       	push   $0x361
f01021a6:	68 d5 58 10 f0       	push   $0xf01058d5
f01021ab:	e8 25 df ff ff       	call   f01000d5 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021b5:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01021ba:	e8 b0 ed ff ff       	call   f0100f6f <check_va2pa>
f01021bf:	89 f2                	mov    %esi,%edx
f01021c1:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f01021c7:	c1 fa 03             	sar    $0x3,%edx
f01021ca:	c1 e2 0c             	shl    $0xc,%edx
f01021cd:	39 d0                	cmp    %edx,%eax
f01021cf:	74 19                	je     f01021ea <mem_init+0xbb5>
f01021d1:	68 e8 55 10 f0       	push   $0xf01055e8
f01021d6:	68 fb 58 10 f0       	push   $0xf01058fb
f01021db:	68 64 03 00 00       	push   $0x364
f01021e0:	68 d5 58 10 f0       	push   $0xf01058d5
f01021e5:	e8 eb de ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021ea:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ef:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01021f4:	e8 76 ed ff ff       	call   f0100f6f <check_va2pa>
f01021f9:	89 f2                	mov    %esi,%edx
f01021fb:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0102201:	c1 fa 03             	sar    $0x3,%edx
f0102204:	c1 e2 0c             	shl    $0xc,%edx
f0102207:	39 d0                	cmp    %edx,%eax
f0102209:	74 19                	je     f0102224 <mem_init+0xbef>
f010220b:	68 14 56 10 f0       	push   $0xf0105614
f0102210:	68 fb 58 10 f0       	push   $0xf01058fb
f0102215:	68 65 03 00 00       	push   $0x365
f010221a:	68 d5 58 10 f0       	push   $0xf01058d5
f010221f:	e8 b1 de ff ff       	call   f01000d5 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102224:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102229:	74 19                	je     f0102244 <mem_init+0xc0f>
f010222b:	68 ec 5a 10 f0       	push   $0xf0105aec
f0102230:	68 fb 58 10 f0       	push   $0xf01058fb
f0102235:	68 67 03 00 00       	push   $0x367
f010223a:	68 d5 58 10 f0       	push   $0xf01058d5
f010223f:	e8 91 de ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 0);
f0102244:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102249:	74 19                	je     f0102264 <mem_init+0xc2f>
f010224b:	68 fd 5a 10 f0       	push   $0xf0105afd
f0102250:	68 fb 58 10 f0       	push   $0xf01058fb
f0102255:	68 68 03 00 00       	push   $0x368
f010225a:	68 d5 58 10 f0       	push   $0xf01058d5
f010225f:	e8 71 de ff ff       	call   f01000d5 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102264:	83 ec 0c             	sub    $0xc,%esp
f0102267:	6a 00                	push   $0x0
f0102269:	e8 f0 f0 ff ff       	call   f010135e <page_alloc>
f010226e:	83 c4 10             	add    $0x10,%esp
f0102271:	85 c0                	test   %eax,%eax
f0102273:	74 04                	je     f0102279 <mem_init+0xc44>
f0102275:	39 c3                	cmp    %eax,%ebx
f0102277:	74 19                	je     f0102292 <mem_init+0xc5d>
f0102279:	68 44 56 10 f0       	push   $0xf0105644
f010227e:	68 fb 58 10 f0       	push   $0xf01058fb
f0102283:	68 6b 03 00 00       	push   $0x36b
f0102288:	68 d5 58 10 f0       	push   $0xf01058d5
f010228d:	e8 43 de ff ff       	call   f01000d5 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102292:	83 ec 08             	sub    $0x8,%esp
f0102295:	6a 00                	push   $0x0
f0102297:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010229d:	e8 dd f2 ff ff       	call   f010157f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01022a7:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01022ac:	e8 be ec ff ff       	call   f0100f6f <check_va2pa>
f01022b1:	83 c4 10             	add    $0x10,%esp
f01022b4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022b7:	74 19                	je     f01022d2 <mem_init+0xc9d>
f01022b9:	68 68 56 10 f0       	push   $0xf0105668
f01022be:	68 fb 58 10 f0       	push   $0xf01058fb
f01022c3:	68 6f 03 00 00       	push   $0x36f
f01022c8:	68 d5 58 10 f0       	push   $0xf01058d5
f01022cd:	e8 03 de ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022d2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022d7:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01022dc:	e8 8e ec ff ff       	call   f0100f6f <check_va2pa>
f01022e1:	89 f2                	mov    %esi,%edx
f01022e3:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f01022e9:	c1 fa 03             	sar    $0x3,%edx
f01022ec:	c1 e2 0c             	shl    $0xc,%edx
f01022ef:	39 d0                	cmp    %edx,%eax
f01022f1:	74 19                	je     f010230c <mem_init+0xcd7>
f01022f3:	68 14 56 10 f0       	push   $0xf0105614
f01022f8:	68 fb 58 10 f0       	push   $0xf01058fb
f01022fd:	68 70 03 00 00       	push   $0x370
f0102302:	68 d5 58 10 f0       	push   $0xf01058d5
f0102307:	e8 c9 dd ff ff       	call   f01000d5 <_panic>
	assert(pp1->pp_ref == 1);
f010230c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102311:	74 19                	je     f010232c <mem_init+0xcf7>
f0102313:	68 a3 5a 10 f0       	push   $0xf0105aa3
f0102318:	68 fb 58 10 f0       	push   $0xf01058fb
f010231d:	68 71 03 00 00       	push   $0x371
f0102322:	68 d5 58 10 f0       	push   $0xf01058d5
f0102327:	e8 a9 dd ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 0);
f010232c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102331:	74 19                	je     f010234c <mem_init+0xd17>
f0102333:	68 fd 5a 10 f0       	push   $0xf0105afd
f0102338:	68 fb 58 10 f0       	push   $0xf01058fb
f010233d:	68 72 03 00 00       	push   $0x372
f0102342:	68 d5 58 10 f0       	push   $0xf01058d5
f0102347:	e8 89 dd ff ff       	call   f01000d5 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010234c:	83 ec 08             	sub    $0x8,%esp
f010234f:	68 00 10 00 00       	push   $0x1000
f0102354:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010235a:	e8 20 f2 ff ff       	call   f010157f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010235f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102364:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102369:	e8 01 ec ff ff       	call   f0100f6f <check_va2pa>
f010236e:	83 c4 10             	add    $0x10,%esp
f0102371:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102374:	74 19                	je     f010238f <mem_init+0xd5a>
f0102376:	68 68 56 10 f0       	push   $0xf0105668
f010237b:	68 fb 58 10 f0       	push   $0xf01058fb
f0102380:	68 76 03 00 00       	push   $0x376
f0102385:	68 d5 58 10 f0       	push   $0xf01058d5
f010238a:	e8 46 dd ff ff       	call   f01000d5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010238f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102394:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102399:	e8 d1 eb ff ff       	call   f0100f6f <check_va2pa>
f010239e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023a1:	74 19                	je     f01023bc <mem_init+0xd87>
f01023a3:	68 8c 56 10 f0       	push   $0xf010568c
f01023a8:	68 fb 58 10 f0       	push   $0xf01058fb
f01023ad:	68 77 03 00 00       	push   $0x377
f01023b2:	68 d5 58 10 f0       	push   $0xf01058d5
f01023b7:	e8 19 dd ff ff       	call   f01000d5 <_panic>
	assert(pp1->pp_ref == 0);
f01023bc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023c1:	74 19                	je     f01023dc <mem_init+0xda7>
f01023c3:	68 0e 5b 10 f0       	push   $0xf0105b0e
f01023c8:	68 fb 58 10 f0       	push   $0xf01058fb
f01023cd:	68 78 03 00 00       	push   $0x378
f01023d2:	68 d5 58 10 f0       	push   $0xf01058d5
f01023d7:	e8 f9 dc ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 0);
f01023dc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023e1:	74 19                	je     f01023fc <mem_init+0xdc7>
f01023e3:	68 fd 5a 10 f0       	push   $0xf0105afd
f01023e8:	68 fb 58 10 f0       	push   $0xf01058fb
f01023ed:	68 79 03 00 00       	push   $0x379
f01023f2:	68 d5 58 10 f0       	push   $0xf01058d5
f01023f7:	e8 d9 dc ff ff       	call   f01000d5 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023fc:	83 ec 0c             	sub    $0xc,%esp
f01023ff:	6a 00                	push   $0x0
f0102401:	e8 58 ef ff ff       	call   f010135e <page_alloc>
f0102406:	83 c4 10             	add    $0x10,%esp
f0102409:	85 c0                	test   %eax,%eax
f010240b:	74 04                	je     f0102411 <mem_init+0xddc>
f010240d:	39 c6                	cmp    %eax,%esi
f010240f:	74 19                	je     f010242a <mem_init+0xdf5>
f0102411:	68 b4 56 10 f0       	push   $0xf01056b4
f0102416:	68 fb 58 10 f0       	push   $0xf01058fb
f010241b:	68 7c 03 00 00       	push   $0x37c
f0102420:	68 d5 58 10 f0       	push   $0xf01058d5
f0102425:	e8 ab dc ff ff       	call   f01000d5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010242a:	83 ec 0c             	sub    $0xc,%esp
f010242d:	6a 00                	push   $0x0
f010242f:	e8 2a ef ff ff       	call   f010135e <page_alloc>
f0102434:	83 c4 10             	add    $0x10,%esp
f0102437:	85 c0                	test   %eax,%eax
f0102439:	74 19                	je     f0102454 <mem_init+0xe1f>
f010243b:	68 51 5a 10 f0       	push   $0xf0105a51
f0102440:	68 fb 58 10 f0       	push   $0xf01058fb
f0102445:	68 7f 03 00 00       	push   $0x37f
f010244a:	68 d5 58 10 f0       	push   $0xf01058d5
f010244f:	e8 81 dc ff ff       	call   f01000d5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102454:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102459:	8b 08                	mov    (%eax),%ecx
f010245b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102461:	89 fa                	mov    %edi,%edx
f0102463:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0102469:	c1 fa 03             	sar    $0x3,%edx
f010246c:	c1 e2 0c             	shl    $0xc,%edx
f010246f:	39 d1                	cmp    %edx,%ecx
f0102471:	74 19                	je     f010248c <mem_init+0xe57>
f0102473:	68 90 53 10 f0       	push   $0xf0105390
f0102478:	68 fb 58 10 f0       	push   $0xf01058fb
f010247d:	68 82 03 00 00       	push   $0x382
f0102482:	68 d5 58 10 f0       	push   $0xf01058d5
f0102487:	e8 49 dc ff ff       	call   f01000d5 <_panic>
	kern_pgdir[0] = 0;
f010248c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102492:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102497:	74 19                	je     f01024b2 <mem_init+0xe7d>
f0102499:	68 b4 5a 10 f0       	push   $0xf0105ab4
f010249e:	68 fb 58 10 f0       	push   $0xf01058fb
f01024a3:	68 84 03 00 00       	push   $0x384
f01024a8:	68 d5 58 10 f0       	push   $0xf01058d5
f01024ad:	e8 23 dc ff ff       	call   f01000d5 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01024b2:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01024b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024bd:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01024c3:	89 f8                	mov    %edi,%eax
f01024c5:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f01024cb:	c1 f8 03             	sar    $0x3,%eax
f01024ce:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024d1:	89 c2                	mov    %eax,%edx
f01024d3:	c1 ea 0c             	shr    $0xc,%edx
f01024d6:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f01024dc:	72 12                	jb     f01024f0 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024de:	50                   	push   %eax
f01024df:	68 74 51 10 f0       	push   $0xf0105174
f01024e4:	6a 56                	push   $0x56
f01024e6:	68 e1 58 10 f0       	push   $0xf01058e1
f01024eb:	e8 e5 db ff ff       	call   f01000d5 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024f0:	83 ec 04             	sub    $0x4,%esp
f01024f3:	68 00 10 00 00       	push   $0x1000
f01024f8:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01024fd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102502:	50                   	push   %eax
f0102503:	e8 cd 1d 00 00       	call   f01042d5 <memset>
	page_free(pp0);
f0102508:	89 3c 24             	mov    %edi,(%esp)
f010250b:	e8 d8 ee ff ff       	call   f01013e8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102510:	83 c4 0c             	add    $0xc,%esp
f0102513:	6a 01                	push   $0x1
f0102515:	6a 00                	push   $0x0
f0102517:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f010251d:	e8 04 ef ff ff       	call   f0101426 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102522:	89 fa                	mov    %edi,%edx
f0102524:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f010252a:	c1 fa 03             	sar    $0x3,%edx
f010252d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102530:	89 d0                	mov    %edx,%eax
f0102532:	c1 e8 0c             	shr    $0xc,%eax
f0102535:	83 c4 10             	add    $0x10,%esp
f0102538:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f010253e:	72 12                	jb     f0102552 <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102540:	52                   	push   %edx
f0102541:	68 74 51 10 f0       	push   $0xf0105174
f0102546:	6a 56                	push   $0x56
f0102548:	68 e1 58 10 f0       	push   $0xf01058e1
f010254d:	e8 83 db ff ff       	call   f01000d5 <_panic>
	return (void *)(pa + KERNBASE);
f0102552:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010255b:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102562:	75 11                	jne    f0102575 <mem_init+0xf40>
f0102564:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010256a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102570:	f6 00 01             	testb  $0x1,(%eax)
f0102573:	74 19                	je     f010258e <mem_init+0xf59>
f0102575:	68 1f 5b 10 f0       	push   $0xf0105b1f
f010257a:	68 fb 58 10 f0       	push   $0xf01058fb
f010257f:	68 90 03 00 00       	push   $0x390
f0102584:	68 d5 58 10 f0       	push   $0xf01058d5
f0102589:	e8 47 db ff ff       	call   f01000d5 <_panic>
f010258e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102591:	39 d0                	cmp    %edx,%eax
f0102593:	75 db                	jne    f0102570 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102595:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f010259a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025a0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01025a9:	89 0d ac 72 1d f0    	mov    %ecx,0xf01d72ac

	// free the pages we took
	page_free(pp0);
f01025af:	83 ec 0c             	sub    $0xc,%esp
f01025b2:	57                   	push   %edi
f01025b3:	e8 30 ee ff ff       	call   f01013e8 <page_free>
	page_free(pp1);
f01025b8:	89 34 24             	mov    %esi,(%esp)
f01025bb:	e8 28 ee ff ff       	call   f01013e8 <page_free>
	page_free(pp2);
f01025c0:	89 1c 24             	mov    %ebx,(%esp)
f01025c3:	e8 20 ee ff ff       	call   f01013e8 <page_free>

	cprintf("check_page() succeeded!\n");
f01025c8:	c7 04 24 36 5b 10 f0 	movl   $0xf0105b36,(%esp)
f01025cf:	e8 31 0e 00 00       	call   f0103405 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025d4:	a1 8c 7f 1d f0       	mov    0xf01d7f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025d9:	83 c4 10             	add    $0x10,%esp
f01025dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e1:	77 15                	ja     f01025f8 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e3:	50                   	push   %eax
f01025e4:	68 b4 4f 10 f0       	push   $0xf0104fb4
f01025e9:	68 b7 00 00 00       	push   $0xb7
f01025ee:	68 d5 58 10 f0       	push   $0xf01058d5
f01025f3:	e8 dd da ff ff       	call   f01000d5 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025f8:	8b 15 84 7f 1d f0    	mov    0xf01d7f84,%edx
f01025fe:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102605:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102608:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010260e:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102610:	05 00 00 00 10       	add    $0x10000000,%eax
f0102615:	50                   	push   %eax
f0102616:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010261b:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102620:	e8 98 ee ff ff       	call   f01014bd <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102625:	a1 b8 72 1d f0       	mov    0xf01d72b8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010262a:	83 c4 10             	add    $0x10,%esp
f010262d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102632:	77 15                	ja     f0102649 <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102634:	50                   	push   %eax
f0102635:	68 b4 4f 10 f0       	push   $0xf0104fb4
f010263a:	68 c4 00 00 00       	push   $0xc4
f010263f:	68 d5 58 10 f0       	push   $0xf01058d5
f0102644:	e8 8c da ff ff       	call   f01000d5 <_panic>
f0102649:	83 ec 08             	sub    $0x8,%esp
f010264c:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010264e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102653:	50                   	push   %eax
f0102654:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102659:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010265e:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102663:	e8 55 ee ff ff       	call   f01014bd <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102668:	83 c4 10             	add    $0x10,%esp
f010266b:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102670:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102675:	77 15                	ja     f010268c <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102677:	50                   	push   %eax
f0102678:	68 b4 4f 10 f0       	push   $0xf0104fb4
f010267d:	68 d5 00 00 00       	push   $0xd5
f0102682:	68 d5 58 10 f0       	push   $0xf01058d5
f0102687:	e8 49 da ff ff       	call   f01000d5 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010268c:	83 ec 08             	sub    $0x8,%esp
f010268f:	6a 02                	push   $0x2
f0102691:	68 00 80 11 00       	push   $0x118000
f0102696:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010269b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026a0:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01026a5:	e8 13 ee ff ff       	call   f01014bd <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01026aa:	83 c4 08             	add    $0x8,%esp
f01026ad:	6a 02                	push   $0x2
f01026af:	6a 00                	push   $0x0
f01026b1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026b6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026bb:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f01026c0:	e8 f8 ed ff ff       	call   f01014bd <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026c5:	8b 1d 88 7f 1d f0    	mov    0xf01d7f88,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026cb:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01026d0:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026d7:	83 c4 10             	add    $0x10,%esp
f01026da:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026e0:	74 63                	je     f0102745 <mem_init+0x1110>
f01026e2:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026e7:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026ed:	89 d8                	mov    %ebx,%eax
f01026ef:	e8 7b e8 ff ff       	call   f0100f6f <check_va2pa>
f01026f4:	8b 15 8c 7f 1d f0    	mov    0xf01d7f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026fa:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102700:	77 15                	ja     f0102717 <mem_init+0x10e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102702:	52                   	push   %edx
f0102703:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0102708:	68 d8 02 00 00       	push   $0x2d8
f010270d:	68 d5 58 10 f0       	push   $0xf01058d5
f0102712:	e8 be d9 ff ff       	call   f01000d5 <_panic>
f0102717:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010271e:	39 d0                	cmp    %edx,%eax
f0102720:	74 19                	je     f010273b <mem_init+0x1106>
f0102722:	68 d8 56 10 f0       	push   $0xf01056d8
f0102727:	68 fb 58 10 f0       	push   $0xf01058fb
f010272c:	68 d8 02 00 00       	push   $0x2d8
f0102731:	68 d5 58 10 f0       	push   $0xf01058d5
f0102736:	e8 9a d9 ff ff       	call   f01000d5 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010273b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102741:	39 f7                	cmp    %esi,%edi
f0102743:	77 a2                	ja     f01026e7 <mem_init+0x10b2>
f0102745:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010274a:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102750:	89 d8                	mov    %ebx,%eax
f0102752:	e8 18 e8 ff ff       	call   f0100f6f <check_va2pa>
f0102757:	8b 15 b8 72 1d f0    	mov    0xf01d72b8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010275d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102763:	77 15                	ja     f010277a <mem_init+0x1145>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102765:	52                   	push   %edx
f0102766:	68 b4 4f 10 f0       	push   $0xf0104fb4
f010276b:	68 dd 02 00 00       	push   $0x2dd
f0102770:	68 d5 58 10 f0       	push   $0xf01058d5
f0102775:	e8 5b d9 ff ff       	call   f01000d5 <_panic>
f010277a:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102781:	39 d0                	cmp    %edx,%eax
f0102783:	74 19                	je     f010279e <mem_init+0x1169>
f0102785:	68 0c 57 10 f0       	push   $0xf010570c
f010278a:	68 fb 58 10 f0       	push   $0xf01058fb
f010278f:	68 dd 02 00 00       	push   $0x2dd
f0102794:	68 d5 58 10 f0       	push   $0xf01058d5
f0102799:	e8 37 d9 ff ff       	call   f01000d5 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010279e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027a4:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f01027aa:	75 9e                	jne    f010274a <mem_init+0x1115>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027ac:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01027b1:	c1 e0 0c             	shl    $0xc,%eax
f01027b4:	74 41                	je     f01027f7 <mem_init+0x11c2>
f01027b6:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027bb:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01027c1:	89 d8                	mov    %ebx,%eax
f01027c3:	e8 a7 e7 ff ff       	call   f0100f6f <check_va2pa>
f01027c8:	39 c6                	cmp    %eax,%esi
f01027ca:	74 19                	je     f01027e5 <mem_init+0x11b0>
f01027cc:	68 40 57 10 f0       	push   $0xf0105740
f01027d1:	68 fb 58 10 f0       	push   $0xf01058fb
f01027d6:	68 e1 02 00 00       	push   $0x2e1
f01027db:	68 d5 58 10 f0       	push   $0xf01058d5
f01027e0:	e8 f0 d8 ff ff       	call   f01000d5 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027e5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027eb:	a1 84 7f 1d f0       	mov    0xf01d7f84,%eax
f01027f0:	c1 e0 0c             	shl    $0xc,%eax
f01027f3:	39 c6                	cmp    %eax,%esi
f01027f5:	72 c4                	jb     f01027bb <mem_init+0x1186>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027f7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027fc:	89 d8                	mov    %ebx,%eax
f01027fe:	e8 6c e7 ff ff       	call   f0100f6f <check_va2pa>
f0102803:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102808:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
f010280d:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102813:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102816:	39 c2                	cmp    %eax,%edx
f0102818:	74 19                	je     f0102833 <mem_init+0x11fe>
f010281a:	68 68 57 10 f0       	push   $0xf0105768
f010281f:	68 fb 58 10 f0       	push   $0xf01058fb
f0102824:	68 e5 02 00 00       	push   $0x2e5
f0102829:	68 d5 58 10 f0       	push   $0xf01058d5
f010282e:	e8 a2 d8 ff ff       	call   f01000d5 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102833:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102839:	0f 85 25 04 00 00    	jne    f0102c64 <mem_init+0x162f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010283f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102844:	89 d8                	mov    %ebx,%eax
f0102846:	e8 24 e7 ff ff       	call   f0100f6f <check_va2pa>
f010284b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010284e:	74 19                	je     f0102869 <mem_init+0x1234>
f0102850:	68 b0 57 10 f0       	push   $0xf01057b0
f0102855:	68 fb 58 10 f0       	push   $0xf01058fb
f010285a:	68 e6 02 00 00       	push   $0x2e6
f010285f:	68 d5 58 10 f0       	push   $0xf01058d5
f0102864:	e8 6c d8 ff ff       	call   f01000d5 <_panic>
f0102869:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010286e:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102873:	72 2d                	jb     f01028a2 <mem_init+0x126d>
f0102875:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010287a:	76 07                	jbe    f0102883 <mem_init+0x124e>
f010287c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102881:	75 1f                	jne    f01028a2 <mem_init+0x126d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102883:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102887:	75 7e                	jne    f0102907 <mem_init+0x12d2>
f0102889:	68 4f 5b 10 f0       	push   $0xf0105b4f
f010288e:	68 fb 58 10 f0       	push   $0xf01058fb
f0102893:	68 ef 02 00 00       	push   $0x2ef
f0102898:	68 d5 58 10 f0       	push   $0xf01058d5
f010289d:	e8 33 d8 ff ff       	call   f01000d5 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01028a2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028a7:	76 3f                	jbe    f01028e8 <mem_init+0x12b3>
				assert(pgdir[i] & PTE_P);
f01028a9:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01028ac:	f6 c2 01             	test   $0x1,%dl
f01028af:	75 19                	jne    f01028ca <mem_init+0x1295>
f01028b1:	68 4f 5b 10 f0       	push   $0xf0105b4f
f01028b6:	68 fb 58 10 f0       	push   $0xf01058fb
f01028bb:	68 f3 02 00 00       	push   $0x2f3
f01028c0:	68 d5 58 10 f0       	push   $0xf01058d5
f01028c5:	e8 0b d8 ff ff       	call   f01000d5 <_panic>
				assert(pgdir[i] & PTE_W);
f01028ca:	f6 c2 02             	test   $0x2,%dl
f01028cd:	75 38                	jne    f0102907 <mem_init+0x12d2>
f01028cf:	68 60 5b 10 f0       	push   $0xf0105b60
f01028d4:	68 fb 58 10 f0       	push   $0xf01058fb
f01028d9:	68 f4 02 00 00       	push   $0x2f4
f01028de:	68 d5 58 10 f0       	push   $0xf01058d5
f01028e3:	e8 ed d7 ff ff       	call   f01000d5 <_panic>
			} else
				assert(pgdir[i] == 0);
f01028e8:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028ec:	74 19                	je     f0102907 <mem_init+0x12d2>
f01028ee:	68 71 5b 10 f0       	push   $0xf0105b71
f01028f3:	68 fb 58 10 f0       	push   $0xf01058fb
f01028f8:	68 f6 02 00 00       	push   $0x2f6
f01028fd:	68 d5 58 10 f0       	push   $0xf01058d5
f0102902:	e8 ce d7 ff ff       	call   f01000d5 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102907:	40                   	inc    %eax
f0102908:	3d 00 04 00 00       	cmp    $0x400,%eax
f010290d:	0f 85 5b ff ff ff    	jne    f010286e <mem_init+0x1239>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102913:	83 ec 0c             	sub    $0xc,%esp
f0102916:	68 e0 57 10 f0       	push   $0xf01057e0
f010291b:	e8 e5 0a 00 00       	call   f0103405 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102920:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102925:	83 c4 10             	add    $0x10,%esp
f0102928:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010292d:	77 15                	ja     f0102944 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010292f:	50                   	push   %eax
f0102930:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0102935:	68 f2 00 00 00       	push   $0xf2
f010293a:	68 d5 58 10 f0       	push   $0xf01058d5
f010293f:	e8 91 d7 ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102944:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102949:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010294c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102951:	e8 a2 e6 ff ff       	call   f0100ff8 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102956:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102959:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010295e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102961:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102964:	83 ec 0c             	sub    $0xc,%esp
f0102967:	6a 00                	push   $0x0
f0102969:	e8 f0 e9 ff ff       	call   f010135e <page_alloc>
f010296e:	89 c6                	mov    %eax,%esi
f0102970:	83 c4 10             	add    $0x10,%esp
f0102973:	85 c0                	test   %eax,%eax
f0102975:	75 19                	jne    f0102990 <mem_init+0x135b>
f0102977:	68 a6 59 10 f0       	push   $0xf01059a6
f010297c:	68 fb 58 10 f0       	push   $0xf01058fb
f0102981:	68 ab 03 00 00       	push   $0x3ab
f0102986:	68 d5 58 10 f0       	push   $0xf01058d5
f010298b:	e8 45 d7 ff ff       	call   f01000d5 <_panic>
	assert((pp1 = page_alloc(0)));
f0102990:	83 ec 0c             	sub    $0xc,%esp
f0102993:	6a 00                	push   $0x0
f0102995:	e8 c4 e9 ff ff       	call   f010135e <page_alloc>
f010299a:	89 c7                	mov    %eax,%edi
f010299c:	83 c4 10             	add    $0x10,%esp
f010299f:	85 c0                	test   %eax,%eax
f01029a1:	75 19                	jne    f01029bc <mem_init+0x1387>
f01029a3:	68 bc 59 10 f0       	push   $0xf01059bc
f01029a8:	68 fb 58 10 f0       	push   $0xf01058fb
f01029ad:	68 ac 03 00 00       	push   $0x3ac
f01029b2:	68 d5 58 10 f0       	push   $0xf01058d5
f01029b7:	e8 19 d7 ff ff       	call   f01000d5 <_panic>
	assert((pp2 = page_alloc(0)));
f01029bc:	83 ec 0c             	sub    $0xc,%esp
f01029bf:	6a 00                	push   $0x0
f01029c1:	e8 98 e9 ff ff       	call   f010135e <page_alloc>
f01029c6:	89 c3                	mov    %eax,%ebx
f01029c8:	83 c4 10             	add    $0x10,%esp
f01029cb:	85 c0                	test   %eax,%eax
f01029cd:	75 19                	jne    f01029e8 <mem_init+0x13b3>
f01029cf:	68 d2 59 10 f0       	push   $0xf01059d2
f01029d4:	68 fb 58 10 f0       	push   $0xf01058fb
f01029d9:	68 ad 03 00 00       	push   $0x3ad
f01029de:	68 d5 58 10 f0       	push   $0xf01058d5
f01029e3:	e8 ed d6 ff ff       	call   f01000d5 <_panic>
	page_free(pp0);
f01029e8:	83 ec 0c             	sub    $0xc,%esp
f01029eb:	56                   	push   %esi
f01029ec:	e8 f7 e9 ff ff       	call   f01013e8 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029f1:	89 f8                	mov    %edi,%eax
f01029f3:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f01029f9:	c1 f8 03             	sar    $0x3,%eax
f01029fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ff:	89 c2                	mov    %eax,%edx
f0102a01:	c1 ea 0c             	shr    $0xc,%edx
f0102a04:	83 c4 10             	add    $0x10,%esp
f0102a07:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102a0d:	72 12                	jb     f0102a21 <mem_init+0x13ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a0f:	50                   	push   %eax
f0102a10:	68 74 51 10 f0       	push   $0xf0105174
f0102a15:	6a 56                	push   $0x56
f0102a17:	68 e1 58 10 f0       	push   $0xf01058e1
f0102a1c:	e8 b4 d6 ff ff       	call   f01000d5 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a21:	83 ec 04             	sub    $0x4,%esp
f0102a24:	68 00 10 00 00       	push   $0x1000
f0102a29:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a30:	50                   	push   %eax
f0102a31:	e8 9f 18 00 00       	call   f01042d5 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a36:	89 d8                	mov    %ebx,%eax
f0102a38:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0102a3e:	c1 f8 03             	sar    $0x3,%eax
f0102a41:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a44:	89 c2                	mov    %eax,%edx
f0102a46:	c1 ea 0c             	shr    $0xc,%edx
f0102a49:	83 c4 10             	add    $0x10,%esp
f0102a4c:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102a52:	72 12                	jb     f0102a66 <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a54:	50                   	push   %eax
f0102a55:	68 74 51 10 f0       	push   $0xf0105174
f0102a5a:	6a 56                	push   $0x56
f0102a5c:	68 e1 58 10 f0       	push   $0xf01058e1
f0102a61:	e8 6f d6 ff ff       	call   f01000d5 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a66:	83 ec 04             	sub    $0x4,%esp
f0102a69:	68 00 10 00 00       	push   $0x1000
f0102a6e:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102a70:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a75:	50                   	push   %eax
f0102a76:	e8 5a 18 00 00       	call   f01042d5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a7b:	6a 02                	push   $0x2
f0102a7d:	68 00 10 00 00       	push   $0x1000
f0102a82:	57                   	push   %edi
f0102a83:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102a89:	e8 3e eb ff ff       	call   f01015cc <page_insert>
	assert(pp1->pp_ref == 1);
f0102a8e:	83 c4 20             	add    $0x20,%esp
f0102a91:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a96:	74 19                	je     f0102ab1 <mem_init+0x147c>
f0102a98:	68 a3 5a 10 f0       	push   $0xf0105aa3
f0102a9d:	68 fb 58 10 f0       	push   $0xf01058fb
f0102aa2:	68 b2 03 00 00       	push   $0x3b2
f0102aa7:	68 d5 58 10 f0       	push   $0xf01058d5
f0102aac:	e8 24 d6 ff ff       	call   f01000d5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ab1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ab8:	01 01 01 
f0102abb:	74 19                	je     f0102ad6 <mem_init+0x14a1>
f0102abd:	68 00 58 10 f0       	push   $0xf0105800
f0102ac2:	68 fb 58 10 f0       	push   $0xf01058fb
f0102ac7:	68 b3 03 00 00       	push   $0x3b3
f0102acc:	68 d5 58 10 f0       	push   $0xf01058d5
f0102ad1:	e8 ff d5 ff ff       	call   f01000d5 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ad6:	6a 02                	push   $0x2
f0102ad8:	68 00 10 00 00       	push   $0x1000
f0102add:	53                   	push   %ebx
f0102ade:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102ae4:	e8 e3 ea ff ff       	call   f01015cc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ae9:	83 c4 10             	add    $0x10,%esp
f0102aec:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102af3:	02 02 02 
f0102af6:	74 19                	je     f0102b11 <mem_init+0x14dc>
f0102af8:	68 24 58 10 f0       	push   $0xf0105824
f0102afd:	68 fb 58 10 f0       	push   $0xf01058fb
f0102b02:	68 b5 03 00 00       	push   $0x3b5
f0102b07:	68 d5 58 10 f0       	push   $0xf01058d5
f0102b0c:	e8 c4 d5 ff ff       	call   f01000d5 <_panic>
	assert(pp2->pp_ref == 1);
f0102b11:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b16:	74 19                	je     f0102b31 <mem_init+0x14fc>
f0102b18:	68 c5 5a 10 f0       	push   $0xf0105ac5
f0102b1d:	68 fb 58 10 f0       	push   $0xf01058fb
f0102b22:	68 b6 03 00 00       	push   $0x3b6
f0102b27:	68 d5 58 10 f0       	push   $0xf01058d5
f0102b2c:	e8 a4 d5 ff ff       	call   f01000d5 <_panic>
	assert(pp1->pp_ref == 0);
f0102b31:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b36:	74 19                	je     f0102b51 <mem_init+0x151c>
f0102b38:	68 0e 5b 10 f0       	push   $0xf0105b0e
f0102b3d:	68 fb 58 10 f0       	push   $0xf01058fb
f0102b42:	68 b7 03 00 00       	push   $0x3b7
f0102b47:	68 d5 58 10 f0       	push   $0xf01058d5
f0102b4c:	e8 84 d5 ff ff       	call   f01000d5 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b51:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b58:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b5b:	89 d8                	mov    %ebx,%eax
f0102b5d:	2b 05 8c 7f 1d f0    	sub    0xf01d7f8c,%eax
f0102b63:	c1 f8 03             	sar    $0x3,%eax
f0102b66:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b69:	89 c2                	mov    %eax,%edx
f0102b6b:	c1 ea 0c             	shr    $0xc,%edx
f0102b6e:	3b 15 84 7f 1d f0    	cmp    0xf01d7f84,%edx
f0102b74:	72 12                	jb     f0102b88 <mem_init+0x1553>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b76:	50                   	push   %eax
f0102b77:	68 74 51 10 f0       	push   $0xf0105174
f0102b7c:	6a 56                	push   $0x56
f0102b7e:	68 e1 58 10 f0       	push   $0xf01058e1
f0102b83:	e8 4d d5 ff ff       	call   f01000d5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b88:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b8f:	03 03 03 
f0102b92:	74 19                	je     f0102bad <mem_init+0x1578>
f0102b94:	68 48 58 10 f0       	push   $0xf0105848
f0102b99:	68 fb 58 10 f0       	push   $0xf01058fb
f0102b9e:	68 b9 03 00 00       	push   $0x3b9
f0102ba3:	68 d5 58 10 f0       	push   $0xf01058d5
f0102ba8:	e8 28 d5 ff ff       	call   f01000d5 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bad:	83 ec 08             	sub    $0x8,%esp
f0102bb0:	68 00 10 00 00       	push   $0x1000
f0102bb5:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102bbb:	e8 bf e9 ff ff       	call   f010157f <page_remove>
	assert(pp2->pp_ref == 0);
f0102bc0:	83 c4 10             	add    $0x10,%esp
f0102bc3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bc8:	74 19                	je     f0102be3 <mem_init+0x15ae>
f0102bca:	68 fd 5a 10 f0       	push   $0xf0105afd
f0102bcf:	68 fb 58 10 f0       	push   $0xf01058fb
f0102bd4:	68 bb 03 00 00       	push   $0x3bb
f0102bd9:	68 d5 58 10 f0       	push   $0xf01058d5
f0102bde:	e8 f2 d4 ff ff       	call   f01000d5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102be3:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
f0102be8:	8b 08                	mov    (%eax),%ecx
f0102bea:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf0:	89 f2                	mov    %esi,%edx
f0102bf2:	2b 15 8c 7f 1d f0    	sub    0xf01d7f8c,%edx
f0102bf8:	c1 fa 03             	sar    $0x3,%edx
f0102bfb:	c1 e2 0c             	shl    $0xc,%edx
f0102bfe:	39 d1                	cmp    %edx,%ecx
f0102c00:	74 19                	je     f0102c1b <mem_init+0x15e6>
f0102c02:	68 90 53 10 f0       	push   $0xf0105390
f0102c07:	68 fb 58 10 f0       	push   $0xf01058fb
f0102c0c:	68 be 03 00 00       	push   $0x3be
f0102c11:	68 d5 58 10 f0       	push   $0xf01058d5
f0102c16:	e8 ba d4 ff ff       	call   f01000d5 <_panic>
	kern_pgdir[0] = 0;
f0102c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c21:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c26:	74 19                	je     f0102c41 <mem_init+0x160c>
f0102c28:	68 b4 5a 10 f0       	push   $0xf0105ab4
f0102c2d:	68 fb 58 10 f0       	push   $0xf01058fb
f0102c32:	68 c0 03 00 00       	push   $0x3c0
f0102c37:	68 d5 58 10 f0       	push   $0xf01058d5
f0102c3c:	e8 94 d4 ff ff       	call   f01000d5 <_panic>
	pp0->pp_ref = 0;
f0102c41:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c47:	83 ec 0c             	sub    $0xc,%esp
f0102c4a:	56                   	push   %esi
f0102c4b:	e8 98 e7 ff ff       	call   f01013e8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c50:	c7 04 24 74 58 10 f0 	movl   $0xf0105874,(%esp)
f0102c57:	e8 a9 07 00 00       	call   f0103405 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c5f:	5b                   	pop    %ebx
f0102c60:	5e                   	pop    %esi
f0102c61:	5f                   	pop    %edi
f0102c62:	c9                   	leave  
f0102c63:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c64:	89 f2                	mov    %esi,%edx
f0102c66:	89 d8                	mov    %ebx,%eax
f0102c68:	e8 02 e3 ff ff       	call   f0100f6f <check_va2pa>
f0102c6d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c73:	e9 9b fb ff ff       	jmp    f0102813 <mem_init+0x11de>

f0102c78 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102c78:	55                   	push   %ebp
f0102c79:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c80:	c9                   	leave  
f0102c81:	c3                   	ret    

f0102c82 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c82:	55                   	push   %ebp
f0102c83:	89 e5                	mov    %esp,%ebp
f0102c85:	53                   	push   %ebx
f0102c86:	83 ec 04             	sub    $0x4,%esp
f0102c89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c8f:	83 c8 04             	or     $0x4,%eax
f0102c92:	50                   	push   %eax
f0102c93:	ff 75 10             	pushl  0x10(%ebp)
f0102c96:	ff 75 0c             	pushl  0xc(%ebp)
f0102c99:	53                   	push   %ebx
f0102c9a:	e8 d9 ff ff ff       	call   f0102c78 <user_mem_check>
f0102c9f:	83 c4 10             	add    $0x10,%esp
f0102ca2:	85 c0                	test   %eax,%eax
f0102ca4:	79 1d                	jns    f0102cc3 <user_mem_assert+0x41>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ca6:	83 ec 04             	sub    $0x4,%esp
f0102ca9:	6a 00                	push   $0x0
f0102cab:	ff 73 48             	pushl  0x48(%ebx)
f0102cae:	68 a0 58 10 f0       	push   $0xf01058a0
f0102cb3:	e8 4d 07 00 00       	call   f0103405 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102cb8:	89 1c 24             	mov    %ebx,(%esp)
f0102cbb:	e8 32 06 00 00       	call   f01032f2 <env_destroy>
f0102cc0:	83 c4 10             	add    $0x10,%esp
	}
}
f0102cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102cc6:	c9                   	leave  
f0102cc7:	c3                   	ret    

f0102cc8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102cc8:	55                   	push   %ebp
f0102cc9:	89 e5                	mov    %esp,%ebp
f0102ccb:	57                   	push   %edi
f0102ccc:	56                   	push   %esi
f0102ccd:	53                   	push   %ebx
f0102cce:	83 ec 0c             	sub    $0xc,%esp
f0102cd1:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102cd3:	89 d3                	mov    %edx,%ebx
f0102cd5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102cdb:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102ce2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102ce8:	39 fb                	cmp    %edi,%ebx
f0102cea:	74 5c                	je     f0102d48 <region_alloc+0x80>
        pg = page_alloc(1);
f0102cec:	83 ec 0c             	sub    $0xc,%esp
f0102cef:	6a 01                	push   $0x1
f0102cf1:	e8 68 e6 ff ff       	call   f010135e <page_alloc>
        if (pg == NULL) {
f0102cf6:	83 c4 10             	add    $0x10,%esp
f0102cf9:	85 c0                	test   %eax,%eax
f0102cfb:	75 17                	jne    f0102d14 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102cfd:	83 ec 04             	sub    $0x4,%esp
f0102d00:	68 80 5b 10 f0       	push   $0xf0105b80
f0102d05:	68 29 01 00 00       	push   $0x129
f0102d0a:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0102d0f:	e8 c1 d3 ff ff       	call   f01000d5 <_panic>
        } else {
            if (page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W) != 0) {
f0102d14:	6a 06                	push   $0x6
f0102d16:	53                   	push   %ebx
f0102d17:	50                   	push   %eax
f0102d18:	ff 76 5c             	pushl  0x5c(%esi)
f0102d1b:	e8 ac e8 ff ff       	call   f01015cc <page_insert>
f0102d20:	83 c4 10             	add    $0x10,%esp
f0102d23:	85 c0                	test   %eax,%eax
f0102d25:	74 17                	je     f0102d3e <region_alloc+0x76>
                panic("region_alloc : page_insert fail\n");
f0102d27:	83 ec 04             	sub    $0x4,%esp
f0102d2a:	68 a4 5b 10 f0       	push   $0xf0105ba4
f0102d2f:	68 2c 01 00 00       	push   $0x12c
f0102d34:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0102d39:	e8 97 d3 ff ff       	call   f01000d5 <_panic>
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102d3e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d44:	39 df                	cmp    %ebx,%edi
f0102d46:	75 a4                	jne    f0102cec <region_alloc+0x24>
                panic("region_alloc : page_insert fail\n");
            }
        }
    }
    return;
}
f0102d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d4b:	5b                   	pop    %ebx
f0102d4c:	5e                   	pop    %esi
f0102d4d:	5f                   	pop    %edi
f0102d4e:	c9                   	leave  
f0102d4f:	c3                   	ret    

f0102d50 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102d50:	55                   	push   %ebp
f0102d51:	89 e5                	mov    %esp,%ebp
f0102d53:	53                   	push   %ebx
f0102d54:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d5a:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102d5d:	85 c0                	test   %eax,%eax
f0102d5f:	75 0e                	jne    f0102d6f <envid2env+0x1f>
		*env_store = curenv;
f0102d61:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102d66:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102d68:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6d:	eb 55                	jmp    f0102dc4 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102d6f:	89 c2                	mov    %eax,%edx
f0102d71:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102d77:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102d7a:	c1 e2 05             	shl    $0x5,%edx
f0102d7d:	03 15 b8 72 1d f0    	add    0xf01d72b8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d83:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102d87:	74 05                	je     f0102d8e <envid2env+0x3e>
f0102d89:	39 42 48             	cmp    %eax,0x48(%edx)
f0102d8c:	74 0d                	je     f0102d9b <envid2env+0x4b>
		*env_store = 0;
f0102d8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102d94:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d99:	eb 29                	jmp    f0102dc4 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d9b:	84 db                	test   %bl,%bl
f0102d9d:	74 1e                	je     f0102dbd <envid2env+0x6d>
f0102d9f:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102da4:	39 c2                	cmp    %eax,%edx
f0102da6:	74 15                	je     f0102dbd <envid2env+0x6d>
f0102da8:	8b 58 48             	mov    0x48(%eax),%ebx
f0102dab:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102dae:	74 0d                	je     f0102dbd <envid2env+0x6d>
		*env_store = 0;
f0102db0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102db6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102dbb:	eb 07                	jmp    f0102dc4 <envid2env+0x74>
	}

	*env_store = e;
f0102dbd:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dc4:	5b                   	pop    %ebx
f0102dc5:	c9                   	leave  
f0102dc6:	c3                   	ret    

f0102dc7 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102dc7:	55                   	push   %ebp
f0102dc8:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102dca:	b8 30 23 12 f0       	mov    $0xf0122330,%eax
f0102dcf:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102dd2:	b8 23 00 00 00       	mov    $0x23,%eax
f0102dd7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102dd9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102ddb:	b0 10                	mov    $0x10,%al
f0102ddd:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102ddf:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102de1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102de3:	ea ea 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102dea
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102dea:	b0 00                	mov    $0x0,%al
f0102dec:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102def:	c9                   	leave  
f0102df0:	c3                   	ret    

f0102df1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102df1:	55                   	push   %ebp
f0102df2:	89 e5                	mov    %esp,%ebp
f0102df4:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102df5:	8b 1d b8 72 1d f0    	mov    0xf01d72b8,%ebx
f0102dfb:	89 1d c0 72 1d f0    	mov    %ebx,0xf01d72c0
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102e01:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102e08:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102e0f:	8d 43 60             	lea    0x60(%ebx),%eax
f0102e12:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102e18:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102e1a:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102e1d:	39 c8                	cmp    %ecx,%eax
f0102e1f:	74 1c                	je     f0102e3d <env_init+0x4c>
        envs[i].env_id = 0;
f0102e21:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102e28:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102e2f:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102e32:	39 c8                	cmp    %ecx,%eax
f0102e34:	75 0f                	jne    f0102e45 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102e36:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102e3d:	e8 85 ff ff ff       	call   f0102dc7 <env_init_percpu>
}
f0102e42:	5b                   	pop    %ebx
f0102e43:	c9                   	leave  
f0102e44:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102e45:	89 42 44             	mov    %eax,0x44(%edx)
f0102e48:	89 c2                	mov    %eax,%edx
f0102e4a:	eb d5                	jmp    f0102e21 <env_init+0x30>

f0102e4c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e4c:	55                   	push   %ebp
f0102e4d:	89 e5                	mov    %esp,%ebp
f0102e4f:	56                   	push   %esi
f0102e50:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e51:	8b 35 c0 72 1d f0    	mov    0xf01d72c0,%esi
f0102e57:	85 f6                	test   %esi,%esi
f0102e59:	0f 84 8d 01 00 00    	je     f0102fec <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e5f:	83 ec 0c             	sub    $0xc,%esp
f0102e62:	6a 01                	push   $0x1
f0102e64:	e8 f5 e4 ff ff       	call   f010135e <page_alloc>
f0102e69:	89 c3                	mov    %eax,%ebx
f0102e6b:	83 c4 10             	add    $0x10,%esp
f0102e6e:	85 c0                	test   %eax,%eax
f0102e70:	0f 84 7d 01 00 00    	je     f0102ff3 <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0102e76:	83 ec 0c             	sub    $0xc,%esp
f0102e79:	68 09 5c 10 f0       	push   $0xf0105c09
f0102e7e:	e8 82 05 00 00       	call   f0103405 <cprintf>

    p->pp_ref++;
f0102e83:	66 ff 43 04          	incw   0x4(%ebx)
f0102e87:	2b 1d 8c 7f 1d f0    	sub    0xf01d7f8c,%ebx
f0102e8d:	c1 fb 03             	sar    $0x3,%ebx
f0102e90:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e93:	89 d8                	mov    %ebx,%eax
f0102e95:	c1 e8 0c             	shr    $0xc,%eax
f0102e98:	83 c4 10             	add    $0x10,%esp
f0102e9b:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0102ea1:	72 12                	jb     f0102eb5 <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ea3:	53                   	push   %ebx
f0102ea4:	68 74 51 10 f0       	push   $0xf0105174
f0102ea9:	6a 56                	push   $0x56
f0102eab:	68 e1 58 10 f0       	push   $0xf01058e1
f0102eb0:	e8 20 d2 ff ff       	call   f01000d5 <_panic>
	return (void *)(pa + KERNBASE);
f0102eb5:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0102ebb:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102ebe:	83 ec 04             	sub    $0x4,%esp
f0102ec1:	68 00 10 00 00       	push   $0x1000
f0102ec6:	ff 35 88 7f 1d f0    	pushl  0xf01d7f88
f0102ecc:	53                   	push   %ebx
f0102ecd:	e8 b7 14 00 00       	call   f0104389 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0102ed2:	83 c4 0c             	add    $0xc,%esp
f0102ed5:	68 ec 0e 00 00       	push   $0xeec
f0102eda:	6a 00                	push   $0x0
f0102edc:	ff 76 5c             	pushl  0x5c(%esi)
f0102edf:	e8 f1 13 00 00       	call   f01042d5 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ee4:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ee7:	83 c4 10             	add    $0x10,%esp
f0102eea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102eef:	77 15                	ja     f0102f06 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ef1:	50                   	push   %eax
f0102ef2:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0102ef7:	68 cc 00 00 00       	push   $0xcc
f0102efc:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0102f01:	e8 cf d1 ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f06:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102f0c:	83 ca 05             	or     $0x5,%edx
f0102f0f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f0102f15:	83 ec 0c             	sub    $0xc,%esp
f0102f18:	68 1a 5c 10 f0       	push   $0xf0105c1a
f0102f1d:	e8 e3 04 00 00       	call   f0103405 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102f22:	8b 46 48             	mov    0x48(%esi),%eax
f0102f25:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102f2a:	83 c4 10             	add    $0x10,%esp
f0102f2d:	89 c1                	mov    %eax,%ecx
f0102f2f:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0102f35:	7f 05                	jg     f0102f3c <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f0102f37:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0102f3c:	89 f0                	mov    %esi,%eax
f0102f3e:	2b 05 b8 72 1d f0    	sub    0xf01d72b8,%eax
f0102f44:	c1 f8 05             	sar    $0x5,%eax
f0102f47:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0102f4a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f4d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f50:	89 d3                	mov    %edx,%ebx
f0102f52:	c1 e3 08             	shl    $0x8,%ebx
f0102f55:	01 da                	add    %ebx,%edx
f0102f57:	89 d3                	mov    %edx,%ebx
f0102f59:	c1 e3 10             	shl    $0x10,%ebx
f0102f5c:	01 da                	add    %ebx,%edx
f0102f5e:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0102f61:	09 c1                	or     %eax,%ecx
f0102f63:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102f66:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f69:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0102f6c:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0102f73:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0102f7a:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f81:	83 ec 04             	sub    $0x4,%esp
f0102f84:	6a 44                	push   $0x44
f0102f86:	6a 00                	push   $0x0
f0102f88:	56                   	push   %esi
f0102f89:	e8 47 13 00 00       	call   f01042d5 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f8e:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0102f94:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f9a:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0102fa0:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0102fa7:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102fad:	8b 46 44             	mov    0x44(%esi),%eax
f0102fb0:	a3 c0 72 1d f0       	mov    %eax,0xf01d72c0
	*newenv_store = e;
f0102fb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb8:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102fba:	8b 56 48             	mov    0x48(%esi),%edx
f0102fbd:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0102fc2:	83 c4 10             	add    $0x10,%esp
f0102fc5:	85 c0                	test   %eax,%eax
f0102fc7:	74 05                	je     f0102fce <env_alloc+0x182>
f0102fc9:	8b 40 48             	mov    0x48(%eax),%eax
f0102fcc:	eb 05                	jmp    f0102fd3 <env_alloc+0x187>
f0102fce:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fd3:	83 ec 04             	sub    $0x4,%esp
f0102fd6:	52                   	push   %edx
f0102fd7:	50                   	push   %eax
f0102fd8:	68 2c 5c 10 f0       	push   $0xf0105c2c
f0102fdd:	e8 23 04 00 00       	call   f0103405 <cprintf>
	return 0;
f0102fe2:	83 c4 10             	add    $0x10,%esp
f0102fe5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fea:	eb 0c                	jmp    f0102ff8 <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102fec:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102ff1:	eb 05                	jmp    f0102ff8 <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102ff3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102ff8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102ffb:	5b                   	pop    %ebx
f0102ffc:	5e                   	pop    %esi
f0102ffd:	c9                   	leave  
f0102ffe:	c3                   	ret    

f0102fff <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102fff:	55                   	push   %ebp
f0103000:	89 e5                	mov    %esp,%ebp
f0103002:	57                   	push   %edi
f0103003:	56                   	push   %esi
f0103004:	53                   	push   %ebx
f0103005:	83 ec 34             	sub    $0x34,%esp
f0103008:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f010300b:	6a 00                	push   $0x0
f010300d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103010:	50                   	push   %eax
f0103011:	e8 36 fe ff ff       	call   f0102e4c <env_alloc>
    if (r < 0) {
f0103016:	83 c4 10             	add    $0x10,%esp
f0103019:	85 c0                	test   %eax,%eax
f010301b:	79 15                	jns    f0103032 <env_create+0x33>
        panic("env_create: %e\n", r);
f010301d:	50                   	push   %eax
f010301e:	68 41 5c 10 f0       	push   $0xf0105c41
f0103023:	68 96 01 00 00       	push   $0x196
f0103028:	68 fe 5b 10 f0       	push   $0xf0105bfe
f010302d:	e8 a3 d0 ff ff       	call   f01000d5 <_panic>
    }
    load_icode(e, binary, size);
f0103032:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103035:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103038:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010303e:	74 17                	je     f0103057 <env_create+0x58>
        panic("error elf magic number\n");
f0103040:	83 ec 04             	sub    $0x4,%esp
f0103043:	68 51 5c 10 f0       	push   $0xf0105c51
f0103048:	68 6b 01 00 00       	push   $0x16b
f010304d:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0103052:	e8 7e d0 ff ff       	call   f01000d5 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103057:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f010305a:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f010305d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103060:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103063:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103068:	77 15                	ja     f010307f <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010306a:	50                   	push   %eax
f010306b:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0103070:	68 71 01 00 00       	push   $0x171
f0103075:	68 fe 5b 10 f0       	push   $0xf0105bfe
f010307a:	e8 56 d0 ff ff       	call   f01000d5 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010307f:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f0103082:	0f b7 ff             	movzwl %di,%edi
f0103085:	c1 e7 05             	shl    $0x5,%edi
f0103088:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f010308b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103090:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103093:	39 fb                	cmp    %edi,%ebx
f0103095:	73 48                	jae    f01030df <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f0103097:	83 3b 01             	cmpl   $0x1,(%ebx)
f010309a:	75 3c                	jne    f01030d8 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010309c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010309f:	8b 53 08             	mov    0x8(%ebx),%edx
f01030a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030a5:	e8 1e fc ff ff       	call   f0102cc8 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01030aa:	83 ec 04             	sub    $0x4,%esp
f01030ad:	ff 73 10             	pushl  0x10(%ebx)
f01030b0:	89 f0                	mov    %esi,%eax
f01030b2:	03 43 04             	add    0x4(%ebx),%eax
f01030b5:	50                   	push   %eax
f01030b6:	ff 73 08             	pushl  0x8(%ebx)
f01030b9:	e8 cb 12 00 00       	call   f0104389 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01030be:	8b 43 10             	mov    0x10(%ebx),%eax
f01030c1:	83 c4 0c             	add    $0xc,%esp
f01030c4:	8b 53 14             	mov    0x14(%ebx),%edx
f01030c7:	29 c2                	sub    %eax,%edx
f01030c9:	52                   	push   %edx
f01030ca:	6a 00                	push   $0x0
f01030cc:	03 43 08             	add    0x8(%ebx),%eax
f01030cf:	50                   	push   %eax
f01030d0:	e8 00 12 00 00       	call   f01042d5 <memset>
f01030d5:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01030d8:	83 c3 20             	add    $0x20,%ebx
f01030db:	39 df                	cmp    %ebx,%edi
f01030dd:	77 b8                	ja     f0103097 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f01030df:	8b 46 18             	mov    0x18(%esi),%eax
f01030e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01030e5:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f01030e8:	a1 88 7f 1d f0       	mov    0xf01d7f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030f2:	77 15                	ja     f0103109 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030f4:	50                   	push   %eax
f01030f5:	68 b4 4f 10 f0       	push   $0xf0104fb4
f01030fa:	68 7d 01 00 00       	push   $0x17d
f01030ff:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0103104:	e8 cc cf ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103109:	05 00 00 00 10       	add    $0x10000000,%eax
f010310e:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103111:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103116:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010311b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010311e:	e8 a5 fb ff ff       	call   f0102cc8 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103126:	8b 55 10             	mov    0x10(%ebp),%edx
f0103129:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f010312c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010312f:	5b                   	pop    %ebx
f0103130:	5e                   	pop    %esi
f0103131:	5f                   	pop    %edi
f0103132:	c9                   	leave  
f0103133:	c3                   	ret    

f0103134 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103134:	55                   	push   %ebp
f0103135:	89 e5                	mov    %esp,%ebp
f0103137:	57                   	push   %edi
f0103138:	56                   	push   %esi
f0103139:	53                   	push   %ebx
f010313a:	83 ec 1c             	sub    $0x1c,%esp
f010313d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103140:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103145:	39 c7                	cmp    %eax,%edi
f0103147:	75 2c                	jne    f0103175 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0103149:	8b 15 88 7f 1d f0    	mov    0xf01d7f88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010314f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103155:	77 15                	ja     f010316c <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103157:	52                   	push   %edx
f0103158:	68 b4 4f 10 f0       	push   $0xf0104fb4
f010315d:	68 ac 01 00 00       	push   $0x1ac
f0103162:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0103167:	e8 69 cf ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010316c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103172:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103175:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103178:	ba 00 00 00 00       	mov    $0x0,%edx
f010317d:	85 c0                	test   %eax,%eax
f010317f:	74 03                	je     f0103184 <env_free+0x50>
f0103181:	8b 50 48             	mov    0x48(%eax),%edx
f0103184:	83 ec 04             	sub    $0x4,%esp
f0103187:	51                   	push   %ecx
f0103188:	52                   	push   %edx
f0103189:	68 69 5c 10 f0       	push   $0xf0105c69
f010318e:	e8 72 02 00 00       	call   f0103405 <cprintf>
f0103193:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103196:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010319d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031a0:	c1 e0 02             	shl    $0x2,%eax
f01031a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01031a6:	8b 47 5c             	mov    0x5c(%edi),%eax
f01031a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01031ac:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01031af:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01031b5:	0f 84 ab 00 00 00    	je     f0103266 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01031bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031c1:	89 f0                	mov    %esi,%eax
f01031c3:	c1 e8 0c             	shr    $0xc,%eax
f01031c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01031c9:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f01031cf:	72 15                	jb     f01031e6 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031d1:	56                   	push   %esi
f01031d2:	68 74 51 10 f0       	push   $0xf0105174
f01031d7:	68 bb 01 00 00       	push   $0x1bb
f01031dc:	68 fe 5b 10 f0       	push   $0xf0105bfe
f01031e1:	e8 ef ce ff ff       	call   f01000d5 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01031e9:	c1 e2 16             	shl    $0x16,%edx
f01031ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01031ef:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01031f4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01031fb:	01 
f01031fc:	74 17                	je     f0103215 <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031fe:	83 ec 08             	sub    $0x8,%esp
f0103201:	89 d8                	mov    %ebx,%eax
f0103203:	c1 e0 0c             	shl    $0xc,%eax
f0103206:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103209:	50                   	push   %eax
f010320a:	ff 77 5c             	pushl  0x5c(%edi)
f010320d:	e8 6d e3 ff ff       	call   f010157f <page_remove>
f0103212:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103215:	43                   	inc    %ebx
f0103216:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010321c:	75 d6                	jne    f01031f4 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010321e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103221:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103224:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010322b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010322e:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f0103234:	72 14                	jb     f010324a <env_free+0x116>
		panic("pa2page called with invalid pa");
f0103236:	83 ec 04             	sub    $0x4,%esp
f0103239:	68 5c 52 10 f0       	push   $0xf010525c
f010323e:	6a 4f                	push   $0x4f
f0103240:	68 e1 58 10 f0       	push   $0xf01058e1
f0103245:	e8 8b ce ff ff       	call   f01000d5 <_panic>
		page_decref(pa2page(pa));
f010324a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010324d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103250:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103257:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f010325d:	50                   	push   %eax
f010325e:	e8 a5 e1 ff ff       	call   f0101408 <page_decref>
f0103263:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103266:	ff 45 e0             	incl   -0x20(%ebp)
f0103269:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103270:	0f 85 27 ff ff ff    	jne    f010319d <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103276:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103279:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010327e:	77 15                	ja     f0103295 <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103280:	50                   	push   %eax
f0103281:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0103286:	68 c9 01 00 00       	push   $0x1c9
f010328b:	68 fe 5b 10 f0       	push   $0xf0105bfe
f0103290:	e8 40 ce ff ff       	call   f01000d5 <_panic>
	e->env_pgdir = 0;
f0103295:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f010329c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032a1:	c1 e8 0c             	shr    $0xc,%eax
f01032a4:	3b 05 84 7f 1d f0    	cmp    0xf01d7f84,%eax
f01032aa:	72 14                	jb     f01032c0 <env_free+0x18c>
		panic("pa2page called with invalid pa");
f01032ac:	83 ec 04             	sub    $0x4,%esp
f01032af:	68 5c 52 10 f0       	push   $0xf010525c
f01032b4:	6a 4f                	push   $0x4f
f01032b6:	68 e1 58 10 f0       	push   $0xf01058e1
f01032bb:	e8 15 ce ff ff       	call   f01000d5 <_panic>
	page_decref(pa2page(pa));
f01032c0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01032c3:	c1 e0 03             	shl    $0x3,%eax
f01032c6:	03 05 8c 7f 1d f0    	add    0xf01d7f8c,%eax
f01032cc:	50                   	push   %eax
f01032cd:	e8 36 e1 ff ff       	call   f0101408 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01032d2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01032d9:	a1 c0 72 1d f0       	mov    0xf01d72c0,%eax
f01032de:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01032e1:	89 3d c0 72 1d f0    	mov    %edi,0xf01d72c0
f01032e7:	83 c4 10             	add    $0x10,%esp
}
f01032ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032ed:	5b                   	pop    %ebx
f01032ee:	5e                   	pop    %esi
f01032ef:	5f                   	pop    %edi
f01032f0:	c9                   	leave  
f01032f1:	c3                   	ret    

f01032f2 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01032f2:	55                   	push   %ebp
f01032f3:	89 e5                	mov    %esp,%ebp
f01032f5:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01032f8:	ff 75 08             	pushl  0x8(%ebp)
f01032fb:	e8 34 fe ff ff       	call   f0103134 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103300:	c7 04 24 c8 5b 10 f0 	movl   $0xf0105bc8,(%esp)
f0103307:	e8 f9 00 00 00       	call   f0103405 <cprintf>
f010330c:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010330f:	83 ec 0c             	sub    $0xc,%esp
f0103312:	6a 00                	push   $0x0
f0103314:	e8 e0 da ff ff       	call   f0100df9 <monitor>
f0103319:	83 c4 10             	add    $0x10,%esp
f010331c:	eb f1                	jmp    f010330f <env_destroy+0x1d>

f010331e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010331e:	55                   	push   %ebp
f010331f:	89 e5                	mov    %esp,%ebp
f0103321:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103324:	8b 65 08             	mov    0x8(%ebp),%esp
f0103327:	61                   	popa   
f0103328:	07                   	pop    %es
f0103329:	1f                   	pop    %ds
f010332a:	83 c4 08             	add    $0x8,%esp
f010332d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010332e:	68 7f 5c 10 f0       	push   $0xf0105c7f
f0103333:	68 f1 01 00 00       	push   $0x1f1
f0103338:	68 fe 5b 10 f0       	push   $0xf0105bfe
f010333d:	e8 93 cd ff ff       	call   f01000d5 <_panic>

f0103342 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103342:	55                   	push   %ebp
f0103343:	89 e5                	mov    %esp,%ebp
f0103345:	83 ec 08             	sub    $0x8,%esp
f0103348:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f010334b:	8b 15 bc 72 1d f0    	mov    0xf01d72bc,%edx
f0103351:	85 d2                	test   %edx,%edx
f0103353:	74 0d                	je     f0103362 <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103355:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103359:	75 07                	jne    f0103362 <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f010335b:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103362:	a3 bc 72 1d f0       	mov    %eax,0xf01d72bc
    curenv->env_status = ENV_RUNNING;
f0103367:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f010336e:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f0103371:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103374:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010337a:	77 15                	ja     f0103391 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337c:	52                   	push   %edx
f010337d:	68 b4 4f 10 f0       	push   $0xf0104fb4
f0103382:	68 1c 02 00 00       	push   $0x21c
f0103387:	68 fe 5b 10 f0       	push   $0xf0105bfe
f010338c:	e8 44 cd ff ff       	call   f01000d5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103391:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103397:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f010339a:	83 ec 0c             	sub    $0xc,%esp
f010339d:	50                   	push   %eax
f010339e:	e8 7b ff ff ff       	call   f010331e <env_pop_tf>
	...

f01033a4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01033a4:	55                   	push   %ebp
f01033a5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01033a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01033ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01033af:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01033b0:	b2 71                	mov    $0x71,%dl
f01033b2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01033b3:	0f b6 c0             	movzbl %al,%eax
}
f01033b6:	c9                   	leave  
f01033b7:	c3                   	ret    

f01033b8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01033b8:	55                   	push   %ebp
f01033b9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01033bb:	ba 70 00 00 00       	mov    $0x70,%edx
f01033c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01033c3:	ee                   	out    %al,(%dx)
f01033c4:	b2 71                	mov    $0x71,%dl
f01033c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033c9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01033ca:	c9                   	leave  
f01033cb:	c3                   	ret    

f01033cc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01033cc:	55                   	push   %ebp
f01033cd:	89 e5                	mov    %esp,%ebp
f01033cf:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01033d2:	ff 75 08             	pushl  0x8(%ebp)
f01033d5:	e8 18 d2 ff ff       	call   f01005f2 <cputchar>
f01033da:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01033dd:	c9                   	leave  
f01033de:	c3                   	ret    

f01033df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01033df:	55                   	push   %ebp
f01033e0:	89 e5                	mov    %esp,%ebp
f01033e2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01033e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01033ec:	ff 75 0c             	pushl  0xc(%ebp)
f01033ef:	ff 75 08             	pushl  0x8(%ebp)
f01033f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01033f5:	50                   	push   %eax
f01033f6:	68 cc 33 10 f0       	push   $0xf01033cc
f01033fb:	e8 3d 08 00 00       	call   f0103c3d <vprintfmt>
	return cnt;
}
f0103400:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103403:	c9                   	leave  
f0103404:	c3                   	ret    

f0103405 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103405:	55                   	push   %ebp
f0103406:	89 e5                	mov    %esp,%ebp
f0103408:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010340b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010340e:	50                   	push   %eax
f010340f:	ff 75 08             	pushl  0x8(%ebp)
f0103412:	e8 c8 ff ff ff       	call   f01033df <vcprintf>
	va_end(ap);

	return cnt;
}
f0103417:	c9                   	leave  
f0103418:	c3                   	ret    
f0103419:	00 00                	add    %al,(%eax)
	...

f010341c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010341c:	55                   	push   %ebp
f010341d:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010341f:	c7 05 04 7b 1d f0 00 	movl   $0xf0000000,0xf01d7b04
f0103426:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103429:	66 c7 05 08 7b 1d f0 	movw   $0x10,0xf01d7b08
f0103430:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103432:	66 c7 05 28 23 12 f0 	movw   $0x68,0xf0122328
f0103439:	68 00 
f010343b:	b8 00 7b 1d f0       	mov    $0xf01d7b00,%eax
f0103440:	66 a3 2a 23 12 f0    	mov    %ax,0xf012232a
f0103446:	89 c2                	mov    %eax,%edx
f0103448:	c1 ea 10             	shr    $0x10,%edx
f010344b:	88 15 2c 23 12 f0    	mov    %dl,0xf012232c
f0103451:	c6 05 2e 23 12 f0 40 	movb   $0x40,0xf012232e
f0103458:	c1 e8 18             	shr    $0x18,%eax
f010345b:	a2 2f 23 12 f0       	mov    %al,0xf012232f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103460:	c6 05 2d 23 12 f0 89 	movb   $0x89,0xf012232d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103467:	b8 28 00 00 00       	mov    $0x28,%eax
f010346c:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010346f:	b8 38 23 12 f0       	mov    $0xf0122338,%eax
f0103474:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103477:	c9                   	leave  
f0103478:	c3                   	ret    

f0103479 <trap_init>:
}


void
trap_init(void)
{
f0103479:	55                   	push   %ebp
f010347a:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f010347c:	e8 9b ff ff ff       	call   f010341c <trap_init_percpu>
}
f0103481:	c9                   	leave  
f0103482:	c3                   	ret    

f0103483 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103483:	55                   	push   %ebp
f0103484:	89 e5                	mov    %esp,%ebp
f0103486:	53                   	push   %ebx
f0103487:	83 ec 0c             	sub    $0xc,%esp
f010348a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010348d:	ff 33                	pushl  (%ebx)
f010348f:	68 8b 5c 10 f0       	push   $0xf0105c8b
f0103494:	e8 6c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103499:	83 c4 08             	add    $0x8,%esp
f010349c:	ff 73 04             	pushl  0x4(%ebx)
f010349f:	68 9a 5c 10 f0       	push   $0xf0105c9a
f01034a4:	e8 5c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01034a9:	83 c4 08             	add    $0x8,%esp
f01034ac:	ff 73 08             	pushl  0x8(%ebx)
f01034af:	68 a9 5c 10 f0       	push   $0xf0105ca9
f01034b4:	e8 4c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01034b9:	83 c4 08             	add    $0x8,%esp
f01034bc:	ff 73 0c             	pushl  0xc(%ebx)
f01034bf:	68 b8 5c 10 f0       	push   $0xf0105cb8
f01034c4:	e8 3c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01034c9:	83 c4 08             	add    $0x8,%esp
f01034cc:	ff 73 10             	pushl  0x10(%ebx)
f01034cf:	68 c7 5c 10 f0       	push   $0xf0105cc7
f01034d4:	e8 2c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01034d9:	83 c4 08             	add    $0x8,%esp
f01034dc:	ff 73 14             	pushl  0x14(%ebx)
f01034df:	68 d6 5c 10 f0       	push   $0xf0105cd6
f01034e4:	e8 1c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01034e9:	83 c4 08             	add    $0x8,%esp
f01034ec:	ff 73 18             	pushl  0x18(%ebx)
f01034ef:	68 e5 5c 10 f0       	push   $0xf0105ce5
f01034f4:	e8 0c ff ff ff       	call   f0103405 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01034f9:	83 c4 08             	add    $0x8,%esp
f01034fc:	ff 73 1c             	pushl  0x1c(%ebx)
f01034ff:	68 f4 5c 10 f0       	push   $0xf0105cf4
f0103504:	e8 fc fe ff ff       	call   f0103405 <cprintf>
f0103509:	83 c4 10             	add    $0x10,%esp
}
f010350c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010350f:	c9                   	leave  
f0103510:	c3                   	ret    

f0103511 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103511:	55                   	push   %ebp
f0103512:	89 e5                	mov    %esp,%ebp
f0103514:	53                   	push   %ebx
f0103515:	83 ec 0c             	sub    $0xc,%esp
f0103518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010351b:	53                   	push   %ebx
f010351c:	68 2a 5e 10 f0       	push   $0xf0105e2a
f0103521:	e8 df fe ff ff       	call   f0103405 <cprintf>
	print_regs(&tf->tf_regs);
f0103526:	89 1c 24             	mov    %ebx,(%esp)
f0103529:	e8 55 ff ff ff       	call   f0103483 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010352e:	83 c4 08             	add    $0x8,%esp
f0103531:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103535:	50                   	push   %eax
f0103536:	68 45 5d 10 f0       	push   $0xf0105d45
f010353b:	e8 c5 fe ff ff       	call   f0103405 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103540:	83 c4 08             	add    $0x8,%esp
f0103543:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103547:	50                   	push   %eax
f0103548:	68 58 5d 10 f0       	push   $0xf0105d58
f010354d:	e8 b3 fe ff ff       	call   f0103405 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103552:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103555:	83 c4 10             	add    $0x10,%esp
f0103558:	83 f8 13             	cmp    $0x13,%eax
f010355b:	77 09                	ja     f0103566 <print_trapframe+0x55>
		return excnames[trapno];
f010355d:	8b 14 85 00 60 10 f0 	mov    -0xfefa000(,%eax,4),%edx
f0103564:	eb 11                	jmp    f0103577 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f0103566:	83 f8 30             	cmp    $0x30,%eax
f0103569:	75 07                	jne    f0103572 <print_trapframe+0x61>
		return "System call";
f010356b:	ba 03 5d 10 f0       	mov    $0xf0105d03,%edx
f0103570:	eb 05                	jmp    f0103577 <print_trapframe+0x66>
	return "(unknown trap)";
f0103572:	ba 0f 5d 10 f0       	mov    $0xf0105d0f,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103577:	83 ec 04             	sub    $0x4,%esp
f010357a:	52                   	push   %edx
f010357b:	50                   	push   %eax
f010357c:	68 6b 5d 10 f0       	push   $0xf0105d6b
f0103581:	e8 7f fe ff ff       	call   f0103405 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103586:	83 c4 10             	add    $0x10,%esp
f0103589:	3b 1d e0 7a 1d f0    	cmp    0xf01d7ae0,%ebx
f010358f:	75 1a                	jne    f01035ab <print_trapframe+0x9a>
f0103591:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103595:	75 14                	jne    f01035ab <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103597:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010359a:	83 ec 08             	sub    $0x8,%esp
f010359d:	50                   	push   %eax
f010359e:	68 7d 5d 10 f0       	push   $0xf0105d7d
f01035a3:	e8 5d fe ff ff       	call   f0103405 <cprintf>
f01035a8:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01035ab:	83 ec 08             	sub    $0x8,%esp
f01035ae:	ff 73 2c             	pushl  0x2c(%ebx)
f01035b1:	68 8c 5d 10 f0       	push   $0xf0105d8c
f01035b6:	e8 4a fe ff ff       	call   f0103405 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01035bb:	83 c4 10             	add    $0x10,%esp
f01035be:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01035c2:	75 45                	jne    f0103609 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01035c4:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01035c7:	a8 01                	test   $0x1,%al
f01035c9:	74 07                	je     f01035d2 <print_trapframe+0xc1>
f01035cb:	b9 1e 5d 10 f0       	mov    $0xf0105d1e,%ecx
f01035d0:	eb 05                	jmp    f01035d7 <print_trapframe+0xc6>
f01035d2:	b9 29 5d 10 f0       	mov    $0xf0105d29,%ecx
f01035d7:	a8 02                	test   $0x2,%al
f01035d9:	74 07                	je     f01035e2 <print_trapframe+0xd1>
f01035db:	ba 35 5d 10 f0       	mov    $0xf0105d35,%edx
f01035e0:	eb 05                	jmp    f01035e7 <print_trapframe+0xd6>
f01035e2:	ba 3b 5d 10 f0       	mov    $0xf0105d3b,%edx
f01035e7:	a8 04                	test   $0x4,%al
f01035e9:	74 07                	je     f01035f2 <print_trapframe+0xe1>
f01035eb:	b8 40 5d 10 f0       	mov    $0xf0105d40,%eax
f01035f0:	eb 05                	jmp    f01035f7 <print_trapframe+0xe6>
f01035f2:	b8 55 5e 10 f0       	mov    $0xf0105e55,%eax
f01035f7:	51                   	push   %ecx
f01035f8:	52                   	push   %edx
f01035f9:	50                   	push   %eax
f01035fa:	68 9a 5d 10 f0       	push   $0xf0105d9a
f01035ff:	e8 01 fe ff ff       	call   f0103405 <cprintf>
f0103604:	83 c4 10             	add    $0x10,%esp
f0103607:	eb 10                	jmp    f0103619 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103609:	83 ec 0c             	sub    $0xc,%esp
f010360c:	68 6a 47 10 f0       	push   $0xf010476a
f0103611:	e8 ef fd ff ff       	call   f0103405 <cprintf>
f0103616:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103619:	83 ec 08             	sub    $0x8,%esp
f010361c:	ff 73 30             	pushl  0x30(%ebx)
f010361f:	68 a9 5d 10 f0       	push   $0xf0105da9
f0103624:	e8 dc fd ff ff       	call   f0103405 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103629:	83 c4 08             	add    $0x8,%esp
f010362c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103630:	50                   	push   %eax
f0103631:	68 b8 5d 10 f0       	push   $0xf0105db8
f0103636:	e8 ca fd ff ff       	call   f0103405 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010363b:	83 c4 08             	add    $0x8,%esp
f010363e:	ff 73 38             	pushl  0x38(%ebx)
f0103641:	68 cb 5d 10 f0       	push   $0xf0105dcb
f0103646:	e8 ba fd ff ff       	call   f0103405 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010364b:	83 c4 10             	add    $0x10,%esp
f010364e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103652:	74 25                	je     f0103679 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103654:	83 ec 08             	sub    $0x8,%esp
f0103657:	ff 73 3c             	pushl  0x3c(%ebx)
f010365a:	68 da 5d 10 f0       	push   $0xf0105dda
f010365f:	e8 a1 fd ff ff       	call   f0103405 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103664:	83 c4 08             	add    $0x8,%esp
f0103667:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010366b:	50                   	push   %eax
f010366c:	68 e9 5d 10 f0       	push   $0xf0105de9
f0103671:	e8 8f fd ff ff       	call   f0103405 <cprintf>
f0103676:	83 c4 10             	add    $0x10,%esp
	}
}
f0103679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010367c:	c9                   	leave  
f010367d:	c3                   	ret    

f010367e <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010367e:	55                   	push   %ebp
f010367f:	89 e5                	mov    %esp,%ebp
f0103681:	57                   	push   %edi
f0103682:	56                   	push   %esi
f0103683:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103686:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103687:	9c                   	pushf  
f0103688:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103689:	f6 c4 02             	test   $0x2,%ah
f010368c:	74 19                	je     f01036a7 <trap+0x29>
f010368e:	68 fc 5d 10 f0       	push   $0xf0105dfc
f0103693:	68 fb 58 10 f0       	push   $0xf01058fb
f0103698:	68 a7 00 00 00       	push   $0xa7
f010369d:	68 15 5e 10 f0       	push   $0xf0105e15
f01036a2:	e8 2e ca ff ff       	call   f01000d5 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01036a7:	83 ec 08             	sub    $0x8,%esp
f01036aa:	56                   	push   %esi
f01036ab:	68 21 5e 10 f0       	push   $0xf0105e21
f01036b0:	e8 50 fd ff ff       	call   f0103405 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01036b5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01036b9:	83 e0 03             	and    $0x3,%eax
f01036bc:	83 c4 10             	add    $0x10,%esp
f01036bf:	83 f8 03             	cmp    $0x3,%eax
f01036c2:	75 31                	jne    f01036f5 <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01036c4:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f01036c9:	85 c0                	test   %eax,%eax
f01036cb:	75 19                	jne    f01036e6 <trap+0x68>
f01036cd:	68 3c 5e 10 f0       	push   $0xf0105e3c
f01036d2:	68 fb 58 10 f0       	push   $0xf01058fb
f01036d7:	68 ad 00 00 00       	push   $0xad
f01036dc:	68 15 5e 10 f0       	push   $0xf0105e15
f01036e1:	e8 ef c9 ff ff       	call   f01000d5 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01036e6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01036eb:	89 c7                	mov    %eax,%edi
f01036ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01036ef:	8b 35 bc 72 1d f0    	mov    0xf01d72bc,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01036f5:	89 35 e0 7a 1d f0    	mov    %esi,0xf01d7ae0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01036fb:	83 ec 0c             	sub    $0xc,%esp
f01036fe:	56                   	push   %esi
f01036ff:	e8 0d fe ff ff       	call   f0103511 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103704:	83 c4 10             	add    $0x10,%esp
f0103707:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010370c:	75 17                	jne    f0103725 <trap+0xa7>
		panic("unhandled trap in kernel");
f010370e:	83 ec 04             	sub    $0x4,%esp
f0103711:	68 43 5e 10 f0       	push   $0xf0105e43
f0103716:	68 96 00 00 00       	push   $0x96
f010371b:	68 15 5e 10 f0       	push   $0xf0105e15
f0103720:	e8 b0 c9 ff ff       	call   f01000d5 <_panic>
	else {
		env_destroy(curenv);
f0103725:	83 ec 0c             	sub    $0xc,%esp
f0103728:	ff 35 bc 72 1d f0    	pushl  0xf01d72bc
f010372e:	e8 bf fb ff ff       	call   f01032f2 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103733:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax
f0103738:	83 c4 10             	add    $0x10,%esp
f010373b:	85 c0                	test   %eax,%eax
f010373d:	74 06                	je     f0103745 <trap+0xc7>
f010373f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103743:	74 19                	je     f010375e <trap+0xe0>
f0103745:	68 a0 5f 10 f0       	push   $0xf0105fa0
f010374a:	68 fb 58 10 f0       	push   $0xf01058fb
f010374f:	68 bf 00 00 00       	push   $0xbf
f0103754:	68 15 5e 10 f0       	push   $0xf0105e15
f0103759:	e8 77 c9 ff ff       	call   f01000d5 <_panic>
	env_run(curenv);
f010375e:	83 ec 0c             	sub    $0xc,%esp
f0103761:	50                   	push   %eax
f0103762:	e8 db fb ff ff       	call   f0103342 <env_run>

f0103767 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103767:	55                   	push   %ebp
f0103768:	89 e5                	mov    %esp,%ebp
f010376a:	53                   	push   %ebx
f010376b:	83 ec 04             	sub    $0x4,%esp
f010376e:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103771:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103774:	ff 73 30             	pushl  0x30(%ebx)
f0103777:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f0103778:	a1 bc 72 1d f0       	mov    0xf01d72bc,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010377d:	ff 70 48             	pushl  0x48(%eax)
f0103780:	68 cc 5f 10 f0       	push   $0xf0105fcc
f0103785:	e8 7b fc ff ff       	call   f0103405 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010378a:	89 1c 24             	mov    %ebx,(%esp)
f010378d:	e8 7f fd ff ff       	call   f0103511 <print_trapframe>
	env_destroy(curenv);
f0103792:	83 c4 04             	add    $0x4,%esp
f0103795:	ff 35 bc 72 1d f0    	pushl  0xf01d72bc
f010379b:	e8 52 fb ff ff       	call   f01032f2 <env_destroy>
f01037a0:	83 c4 10             	add    $0x10,%esp
}
f01037a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037a6:	c9                   	leave  
f01037a7:	c3                   	ret    

f01037a8 <syscall>:
f01037a8:	55                   	push   %ebp
f01037a9:	89 e5                	mov    %esp,%ebp
f01037ab:	83 ec 0c             	sub    $0xc,%esp
f01037ae:	68 50 60 10 f0       	push   $0xf0106050
f01037b3:	6a 49                	push   $0x49
f01037b5:	68 68 60 10 f0       	push   $0xf0106068
f01037ba:	e8 16 c9 ff ff       	call   f01000d5 <_panic>
	...

f01037c0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01037c0:	55                   	push   %ebp
f01037c1:	89 e5                	mov    %esp,%ebp
f01037c3:	57                   	push   %edi
f01037c4:	56                   	push   %esi
f01037c5:	53                   	push   %ebx
f01037c6:	83 ec 14             	sub    $0x14,%esp
f01037c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01037cc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01037cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01037d2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01037d5:	8b 1a                	mov    (%edx),%ebx
f01037d7:	8b 01                	mov    (%ecx),%eax
f01037d9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01037dc:	39 c3                	cmp    %eax,%ebx
f01037de:	0f 8f 97 00 00 00    	jg     f010387b <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01037e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01037eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037ee:	01 d8                	add    %ebx,%eax
f01037f0:	89 c7                	mov    %eax,%edi
f01037f2:	c1 ef 1f             	shr    $0x1f,%edi
f01037f5:	01 c7                	add    %eax,%edi
f01037f7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037f9:	39 df                	cmp    %ebx,%edi
f01037fb:	7c 31                	jl     f010382e <stab_binsearch+0x6e>
f01037fd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103800:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103803:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103808:	39 f0                	cmp    %esi,%eax
f010380a:	0f 84 b3 00 00 00    	je     f01038c3 <stab_binsearch+0x103>
f0103810:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103814:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103818:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010381a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010381b:	39 d8                	cmp    %ebx,%eax
f010381d:	7c 0f                	jl     f010382e <stab_binsearch+0x6e>
f010381f:	0f b6 0a             	movzbl (%edx),%ecx
f0103822:	83 ea 0c             	sub    $0xc,%edx
f0103825:	39 f1                	cmp    %esi,%ecx
f0103827:	75 f1                	jne    f010381a <stab_binsearch+0x5a>
f0103829:	e9 97 00 00 00       	jmp    f01038c5 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010382e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103831:	eb 39                	jmp    f010386c <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103833:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103836:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103838:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010383b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103842:	eb 28                	jmp    f010386c <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103844:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103847:	76 12                	jbe    f010385b <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103849:	48                   	dec    %eax
f010384a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010384d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103850:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103852:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103859:	eb 11                	jmp    f010386c <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010385b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010385e:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103860:	ff 45 0c             	incl   0xc(%ebp)
f0103863:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103865:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010386c:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f010386f:	0f 8d 76 ff ff ff    	jge    f01037eb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103875:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103879:	75 0d                	jne    f0103888 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f010387b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010387e:	8b 03                	mov    (%ebx),%eax
f0103880:	48                   	dec    %eax
f0103881:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103884:	89 02                	mov    %eax,(%edx)
f0103886:	eb 55                	jmp    f01038dd <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103888:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010388b:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010388d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103890:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103892:	39 c1                	cmp    %eax,%ecx
f0103894:	7d 26                	jge    f01038bc <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103896:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103899:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010389c:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01038a1:	39 f2                	cmp    %esi,%edx
f01038a3:	74 17                	je     f01038bc <stab_binsearch+0xfc>
f01038a5:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01038a9:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01038ad:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01038ae:	39 c1                	cmp    %eax,%ecx
f01038b0:	7d 0a                	jge    f01038bc <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01038b2:	0f b6 1a             	movzbl (%edx),%ebx
f01038b5:	83 ea 0c             	sub    $0xc,%edx
f01038b8:	39 f3                	cmp    %esi,%ebx
f01038ba:	75 f1                	jne    f01038ad <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01038bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01038bf:	89 02                	mov    %eax,(%edx)
f01038c1:	eb 1a                	jmp    f01038dd <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01038c3:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01038c5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01038c8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01038cb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01038cf:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01038d2:	0f 82 5b ff ff ff    	jb     f0103833 <stab_binsearch+0x73>
f01038d8:	e9 67 ff ff ff       	jmp    f0103844 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01038dd:	83 c4 14             	add    $0x14,%esp
f01038e0:	5b                   	pop    %ebx
f01038e1:	5e                   	pop    %esi
f01038e2:	5f                   	pop    %edi
f01038e3:	c9                   	leave  
f01038e4:	c3                   	ret    

f01038e5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01038e5:	55                   	push   %ebp
f01038e6:	89 e5                	mov    %esp,%ebp
f01038e8:	57                   	push   %edi
f01038e9:	56                   	push   %esi
f01038ea:	53                   	push   %ebx
f01038eb:	83 ec 2c             	sub    $0x2c,%esp
f01038ee:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01038f4:	c7 03 77 60 10 f0    	movl   $0xf0106077,(%ebx)
	info->eip_line = 0;
f01038fa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103901:	c7 43 08 77 60 10 f0 	movl   $0xf0106077,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103908:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010390f:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103912:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103919:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010391f:	77 1e                	ja     f010393f <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103921:	a1 00 00 20 00       	mov    0x200000,%eax
f0103926:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103929:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010392e:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103934:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103937:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f010393d:	eb 18                	jmp    f0103957 <debuginfo_eip+0x72>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010393f:	be da 76 11 f0       	mov    $0xf01176da,%esi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103944:	c7 45 d4 41 f1 10 f0 	movl   $0xf010f141,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010394b:	b8 40 f1 10 f0       	mov    $0xf010f140,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103950:	c7 45 d0 90 62 10 f0 	movl   $0xf0106290,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103957:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010395a:	0f 83 5c 01 00 00    	jae    f0103abc <debuginfo_eip+0x1d7>
f0103960:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f0103964:	0f 85 59 01 00 00    	jne    f0103ac3 <debuginfo_eip+0x1de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010396a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103971:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103974:	c1 f8 02             	sar    $0x2,%eax
f0103977:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010397d:	48                   	dec    %eax
f010397e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103981:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103984:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103987:	57                   	push   %edi
f0103988:	6a 64                	push   $0x64
f010398a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010398d:	e8 2e fe ff ff       	call   f01037c0 <stab_binsearch>
	if (lfile == 0)
f0103992:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103995:	83 c4 08             	add    $0x8,%esp
		return -1;
f0103998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010399d:	85 d2                	test   %edx,%edx
f010399f:	0f 84 2a 01 00 00    	je     f0103acf <debuginfo_eip+0x1ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01039a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01039a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01039ae:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01039b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01039b4:	57                   	push   %edi
f01039b5:	6a 24                	push   $0x24
f01039b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039ba:	e8 01 fe ff ff       	call   f01037c0 <stab_binsearch>

	if (lfun <= rfun) {
f01039bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01039c2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01039c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01039c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01039cb:	83 c4 08             	add    $0x8,%esp
f01039ce:	39 c1                	cmp    %eax,%ecx
f01039d0:	7f 21                	jg     f01039f3 <debuginfo_eip+0x10e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039d2:	6b c1 0c             	imul   $0xc,%ecx,%eax
f01039d5:	03 45 d0             	add    -0x30(%ebp),%eax
f01039d8:	8b 10                	mov    (%eax),%edx
f01039da:	89 f1                	mov    %esi,%ecx
f01039dc:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f01039df:	39 ca                	cmp    %ecx,%edx
f01039e1:	73 06                	jae    f01039e9 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039e3:	03 55 d4             	add    -0x2c(%ebp),%edx
f01039e6:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01039e9:	8b 40 08             	mov    0x8(%eax),%eax
f01039ec:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01039ef:	29 c7                	sub    %eax,%edi
f01039f1:	eb 0f                	jmp    f0103a02 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01039f3:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01039f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01039f9:	89 55 cc             	mov    %edx,-0x34(%ebp)
		rline = rfile;
f01039fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01039ff:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a02:	83 ec 08             	sub    $0x8,%esp
f0103a05:	6a 3a                	push   $0x3a
f0103a07:	ff 73 08             	pushl  0x8(%ebx)
f0103a0a:	e8 a4 08 00 00       	call   f01042b3 <strfind>
f0103a0f:	2b 43 08             	sub    0x8(%ebx),%eax
f0103a12:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103a15:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a18:	89 45 dc             	mov    %eax,-0x24(%ebp)
    rfun = rline;
f0103a1b:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103a1e:	89 55 d8             	mov    %edx,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103a21:	83 c4 08             	add    $0x8,%esp
f0103a24:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103a27:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103a2a:	57                   	push   %edi
f0103a2b:	6a 44                	push   $0x44
f0103a2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a30:	e8 8b fd ff ff       	call   f01037c0 <stab_binsearch>
    if (lfun <= rfun) {
f0103a35:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a38:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103a40:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103a43:	0f 8f 86 00 00 00    	jg     f0103acf <debuginfo_eip+0x1ea>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103a49:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103a4c:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103a4f:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103a53:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a59:	89 45 cc             	mov    %eax,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103a5c:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a5f:	eb 04                	jmp    f0103a65 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103a61:	4a                   	dec    %edx
f0103a62:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a65:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103a68:	7c 19                	jl     f0103a83 <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
f0103a6a:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103a6d:	80 f9 84             	cmp    $0x84,%cl
f0103a70:	74 65                	je     f0103ad7 <debuginfo_eip+0x1f2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a72:	80 f9 64             	cmp    $0x64,%cl
f0103a75:	75 ea                	jne    f0103a61 <debuginfo_eip+0x17c>
f0103a77:	83 38 00             	cmpl   $0x0,(%eax)
f0103a7a:	74 e5                	je     f0103a61 <debuginfo_eip+0x17c>
f0103a7c:	eb 59                	jmp    f0103ad7 <debuginfo_eip+0x1f2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103a7e:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103a81:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a83:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a86:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a89:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a8e:	39 ca                	cmp    %ecx,%edx
f0103a90:	7d 3d                	jge    f0103acf <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
f0103a92:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103a95:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103a98:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103a9b:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103a9f:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103aa1:	eb 04                	jmp    f0103aa7 <debuginfo_eip+0x1c2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103aa3:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103aa6:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103aa7:	39 f0                	cmp    %esi,%eax
f0103aa9:	7d 1f                	jge    f0103aca <debuginfo_eip+0x1e5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103aab:	8a 0a                	mov    (%edx),%cl
f0103aad:	83 c2 0c             	add    $0xc,%edx
f0103ab0:	80 f9 a0             	cmp    $0xa0,%cl
f0103ab3:	74 ee                	je     f0103aa3 <debuginfo_eip+0x1be>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103ab5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103aba:	eb 13                	jmp    f0103acf <debuginfo_eip+0x1ea>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ac1:	eb 0c                	jmp    f0103acf <debuginfo_eip+0x1ea>
f0103ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ac8:	eb 05                	jmp    f0103acf <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ad2:	5b                   	pop    %ebx
f0103ad3:	5e                   	pop    %esi
f0103ad4:	5f                   	pop    %edi
f0103ad5:	c9                   	leave  
f0103ad6:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103ad7:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103ada:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103add:	8b 04 11             	mov    (%ecx,%edx,1),%eax
f0103ae0:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f0103ae3:	39 f0                	cmp    %esi,%eax
f0103ae5:	72 97                	jb     f0103a7e <debuginfo_eip+0x199>
f0103ae7:	eb 9a                	jmp    f0103a83 <debuginfo_eip+0x19e>
f0103ae9:	00 00                	add    %al,(%eax)
	...

f0103aec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103aec:	55                   	push   %ebp
f0103aed:	89 e5                	mov    %esp,%ebp
f0103aef:	57                   	push   %edi
f0103af0:	56                   	push   %esi
f0103af1:	53                   	push   %ebx
f0103af2:	83 ec 2c             	sub    $0x2c,%esp
f0103af5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103af8:	89 d6                	mov    %edx,%esi
f0103afa:	8b 45 08             	mov    0x8(%ebp),%eax
f0103afd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b00:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b03:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103b06:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b09:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103b0c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103b0f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b12:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103b19:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103b1c:	72 0c                	jb     f0103b2a <printnum+0x3e>
f0103b1e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103b21:	76 07                	jbe    f0103b2a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b23:	4b                   	dec    %ebx
f0103b24:	85 db                	test   %ebx,%ebx
f0103b26:	7f 31                	jg     f0103b59 <printnum+0x6d>
f0103b28:	eb 3f                	jmp    f0103b69 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103b2a:	83 ec 0c             	sub    $0xc,%esp
f0103b2d:	57                   	push   %edi
f0103b2e:	4b                   	dec    %ebx
f0103b2f:	53                   	push   %ebx
f0103b30:	50                   	push   %eax
f0103b31:	83 ec 08             	sub    $0x8,%esp
f0103b34:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103b37:	ff 75 d0             	pushl  -0x30(%ebp)
f0103b3a:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b3d:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b40:	e8 97 09 00 00       	call   f01044dc <__udivdi3>
f0103b45:	83 c4 18             	add    $0x18,%esp
f0103b48:	52                   	push   %edx
f0103b49:	50                   	push   %eax
f0103b4a:	89 f2                	mov    %esi,%edx
f0103b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b4f:	e8 98 ff ff ff       	call   f0103aec <printnum>
f0103b54:	83 c4 20             	add    $0x20,%esp
f0103b57:	eb 10                	jmp    f0103b69 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103b59:	83 ec 08             	sub    $0x8,%esp
f0103b5c:	56                   	push   %esi
f0103b5d:	57                   	push   %edi
f0103b5e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b61:	4b                   	dec    %ebx
f0103b62:	83 c4 10             	add    $0x10,%esp
f0103b65:	85 db                	test   %ebx,%ebx
f0103b67:	7f f0                	jg     f0103b59 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103b69:	83 ec 08             	sub    $0x8,%esp
f0103b6c:	56                   	push   %esi
f0103b6d:	83 ec 04             	sub    $0x4,%esp
f0103b70:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103b73:	ff 75 d0             	pushl  -0x30(%ebp)
f0103b76:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b79:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b7c:	e8 77 0a 00 00       	call   f01045f8 <__umoddi3>
f0103b81:	83 c4 14             	add    $0x14,%esp
f0103b84:	0f be 80 81 60 10 f0 	movsbl -0xfef9f7f(%eax),%eax
f0103b8b:	50                   	push   %eax
f0103b8c:	ff 55 e4             	call   *-0x1c(%ebp)
f0103b8f:	83 c4 10             	add    $0x10,%esp
}
f0103b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b95:	5b                   	pop    %ebx
f0103b96:	5e                   	pop    %esi
f0103b97:	5f                   	pop    %edi
f0103b98:	c9                   	leave  
f0103b99:	c3                   	ret    

f0103b9a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103b9a:	55                   	push   %ebp
f0103b9b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103b9d:	83 fa 01             	cmp    $0x1,%edx
f0103ba0:	7e 0e                	jle    f0103bb0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103ba2:	8b 10                	mov    (%eax),%edx
f0103ba4:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103ba7:	89 08                	mov    %ecx,(%eax)
f0103ba9:	8b 02                	mov    (%edx),%eax
f0103bab:	8b 52 04             	mov    0x4(%edx),%edx
f0103bae:	eb 22                	jmp    f0103bd2 <getuint+0x38>
	else if (lflag)
f0103bb0:	85 d2                	test   %edx,%edx
f0103bb2:	74 10                	je     f0103bc4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103bb4:	8b 10                	mov    (%eax),%edx
f0103bb6:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103bb9:	89 08                	mov    %ecx,(%eax)
f0103bbb:	8b 02                	mov    (%edx),%eax
f0103bbd:	ba 00 00 00 00       	mov    $0x0,%edx
f0103bc2:	eb 0e                	jmp    f0103bd2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103bc4:	8b 10                	mov    (%eax),%edx
f0103bc6:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103bc9:	89 08                	mov    %ecx,(%eax)
f0103bcb:	8b 02                	mov    (%edx),%eax
f0103bcd:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103bd2:	c9                   	leave  
f0103bd3:	c3                   	ret    

f0103bd4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103bd4:	55                   	push   %ebp
f0103bd5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103bd7:	83 fa 01             	cmp    $0x1,%edx
f0103bda:	7e 0e                	jle    f0103bea <getint+0x16>
		return va_arg(*ap, long long);
f0103bdc:	8b 10                	mov    (%eax),%edx
f0103bde:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103be1:	89 08                	mov    %ecx,(%eax)
f0103be3:	8b 02                	mov    (%edx),%eax
f0103be5:	8b 52 04             	mov    0x4(%edx),%edx
f0103be8:	eb 1a                	jmp    f0103c04 <getint+0x30>
	else if (lflag)
f0103bea:	85 d2                	test   %edx,%edx
f0103bec:	74 0c                	je     f0103bfa <getint+0x26>
		return va_arg(*ap, long);
f0103bee:	8b 10                	mov    (%eax),%edx
f0103bf0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103bf3:	89 08                	mov    %ecx,(%eax)
f0103bf5:	8b 02                	mov    (%edx),%eax
f0103bf7:	99                   	cltd   
f0103bf8:	eb 0a                	jmp    f0103c04 <getint+0x30>
	else
		return va_arg(*ap, int);
f0103bfa:	8b 10                	mov    (%eax),%edx
f0103bfc:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103bff:	89 08                	mov    %ecx,(%eax)
f0103c01:	8b 02                	mov    (%edx),%eax
f0103c03:	99                   	cltd   
}
f0103c04:	c9                   	leave  
f0103c05:	c3                   	ret    

f0103c06 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103c06:	55                   	push   %ebp
f0103c07:	89 e5                	mov    %esp,%ebp
f0103c09:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103c0c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103c0f:	8b 10                	mov    (%eax),%edx
f0103c11:	3b 50 04             	cmp    0x4(%eax),%edx
f0103c14:	73 08                	jae    f0103c1e <sprintputch+0x18>
		*b->buf++ = ch;
f0103c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c19:	88 0a                	mov    %cl,(%edx)
f0103c1b:	42                   	inc    %edx
f0103c1c:	89 10                	mov    %edx,(%eax)
}
f0103c1e:	c9                   	leave  
f0103c1f:	c3                   	ret    

f0103c20 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103c26:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103c29:	50                   	push   %eax
f0103c2a:	ff 75 10             	pushl  0x10(%ebp)
f0103c2d:	ff 75 0c             	pushl  0xc(%ebp)
f0103c30:	ff 75 08             	pushl  0x8(%ebp)
f0103c33:	e8 05 00 00 00       	call   f0103c3d <vprintfmt>
	va_end(ap);
f0103c38:	83 c4 10             	add    $0x10,%esp
}
f0103c3b:	c9                   	leave  
f0103c3c:	c3                   	ret    

f0103c3d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103c3d:	55                   	push   %ebp
f0103c3e:	89 e5                	mov    %esp,%ebp
f0103c40:	57                   	push   %edi
f0103c41:	56                   	push   %esi
f0103c42:	53                   	push   %ebx
f0103c43:	83 ec 2c             	sub    $0x2c,%esp
f0103c46:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103c49:	8b 75 10             	mov    0x10(%ebp),%esi
f0103c4c:	eb 13                	jmp    f0103c61 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103c4e:	85 c0                	test   %eax,%eax
f0103c50:	0f 84 6d 03 00 00    	je     f0103fc3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0103c56:	83 ec 08             	sub    $0x8,%esp
f0103c59:	57                   	push   %edi
f0103c5a:	50                   	push   %eax
f0103c5b:	ff 55 08             	call   *0x8(%ebp)
f0103c5e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103c61:	0f b6 06             	movzbl (%esi),%eax
f0103c64:	46                   	inc    %esi
f0103c65:	83 f8 25             	cmp    $0x25,%eax
f0103c68:	75 e4                	jne    f0103c4e <vprintfmt+0x11>
f0103c6a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103c6e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103c75:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0103c7c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103c83:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c88:	eb 28                	jmp    f0103cb2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c8a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103c8c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103c90:	eb 20                	jmp    f0103cb2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c92:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103c94:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0103c98:	eb 18                	jmp    f0103cb2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c9a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103c9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103ca3:	eb 0d                	jmp    f0103cb2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103ca5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103cab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb2:	8a 06                	mov    (%esi),%al
f0103cb4:	0f b6 d0             	movzbl %al,%edx
f0103cb7:	8d 5e 01             	lea    0x1(%esi),%ebx
f0103cba:	83 e8 23             	sub    $0x23,%eax
f0103cbd:	3c 55                	cmp    $0x55,%al
f0103cbf:	0f 87 e0 02 00 00    	ja     f0103fa5 <vprintfmt+0x368>
f0103cc5:	0f b6 c0             	movzbl %al,%eax
f0103cc8:	ff 24 85 0c 61 10 f0 	jmp    *-0xfef9ef4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103ccf:	83 ea 30             	sub    $0x30,%edx
f0103cd2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103cd5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0103cd8:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103cdb:	83 fa 09             	cmp    $0x9,%edx
f0103cde:	77 44                	ja     f0103d24 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ce0:	89 de                	mov    %ebx,%esi
f0103ce2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103ce5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0103ce6:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103ce9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103ced:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103cf0:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103cf3:	83 fb 09             	cmp    $0x9,%ebx
f0103cf6:	76 ed                	jbe    f0103ce5 <vprintfmt+0xa8>
f0103cf8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103cfb:	eb 29                	jmp    f0103d26 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103cfd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d00:	8d 50 04             	lea    0x4(%eax),%edx
f0103d03:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d06:	8b 00                	mov    (%eax),%eax
f0103d08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d0b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103d0d:	eb 17                	jmp    f0103d26 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103d0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d13:	78 85                	js     f0103c9a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d15:	89 de                	mov    %ebx,%esi
f0103d17:	eb 99                	jmp    f0103cb2 <vprintfmt+0x75>
f0103d19:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103d1b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103d22:	eb 8e                	jmp    f0103cb2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d24:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103d26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d2a:	79 86                	jns    f0103cb2 <vprintfmt+0x75>
f0103d2c:	e9 74 ff ff ff       	jmp    f0103ca5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103d31:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d32:	89 de                	mov    %ebx,%esi
f0103d34:	e9 79 ff ff ff       	jmp    f0103cb2 <vprintfmt+0x75>
f0103d39:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103d3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d3f:	8d 50 04             	lea    0x4(%eax),%edx
f0103d42:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d45:	83 ec 08             	sub    $0x8,%esp
f0103d48:	57                   	push   %edi
f0103d49:	ff 30                	pushl  (%eax)
f0103d4b:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103d4e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d51:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103d54:	e9 08 ff ff ff       	jmp    f0103c61 <vprintfmt+0x24>
f0103d59:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d5f:	8d 50 04             	lea    0x4(%eax),%edx
f0103d62:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d65:	8b 00                	mov    (%eax),%eax
f0103d67:	85 c0                	test   %eax,%eax
f0103d69:	79 02                	jns    f0103d6d <vprintfmt+0x130>
f0103d6b:	f7 d8                	neg    %eax
f0103d6d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103d6f:	83 f8 06             	cmp    $0x6,%eax
f0103d72:	7f 0b                	jg     f0103d7f <vprintfmt+0x142>
f0103d74:	8b 04 85 64 62 10 f0 	mov    -0xfef9d9c(,%eax,4),%eax
f0103d7b:	85 c0                	test   %eax,%eax
f0103d7d:	75 1a                	jne    f0103d99 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0103d7f:	52                   	push   %edx
f0103d80:	68 99 60 10 f0       	push   $0xf0106099
f0103d85:	57                   	push   %edi
f0103d86:	ff 75 08             	pushl  0x8(%ebp)
f0103d89:	e8 92 fe ff ff       	call   f0103c20 <printfmt>
f0103d8e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d91:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103d94:	e9 c8 fe ff ff       	jmp    f0103c61 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0103d99:	50                   	push   %eax
f0103d9a:	68 0d 59 10 f0       	push   $0xf010590d
f0103d9f:	57                   	push   %edi
f0103da0:	ff 75 08             	pushl  0x8(%ebp)
f0103da3:	e8 78 fe ff ff       	call   f0103c20 <printfmt>
f0103da8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103dab:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103dae:	e9 ae fe ff ff       	jmp    f0103c61 <vprintfmt+0x24>
f0103db3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103db6:	89 de                	mov    %ebx,%esi
f0103db8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103dbb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103dbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dc1:	8d 50 04             	lea    0x4(%eax),%edx
f0103dc4:	89 55 14             	mov    %edx,0x14(%ebp)
f0103dc7:	8b 00                	mov    (%eax),%eax
f0103dc9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103dcc:	85 c0                	test   %eax,%eax
f0103dce:	75 07                	jne    f0103dd7 <vprintfmt+0x19a>
				p = "(null)";
f0103dd0:	c7 45 d0 92 60 10 f0 	movl   $0xf0106092,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0103dd7:	85 db                	test   %ebx,%ebx
f0103dd9:	7e 42                	jle    f0103e1d <vprintfmt+0x1e0>
f0103ddb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103ddf:	74 3c                	je     f0103e1d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103de1:	83 ec 08             	sub    $0x8,%esp
f0103de4:	51                   	push   %ecx
f0103de5:	ff 75 d0             	pushl  -0x30(%ebp)
f0103de8:	e8 3f 03 00 00       	call   f010412c <strnlen>
f0103ded:	29 c3                	sub    %eax,%ebx
f0103def:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103df2:	83 c4 10             	add    $0x10,%esp
f0103df5:	85 db                	test   %ebx,%ebx
f0103df7:	7e 24                	jle    f0103e1d <vprintfmt+0x1e0>
					putch(padc, putdat);
f0103df9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103dfd:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103e00:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103e03:	83 ec 08             	sub    $0x8,%esp
f0103e06:	57                   	push   %edi
f0103e07:	53                   	push   %ebx
f0103e08:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e0b:	4e                   	dec    %esi
f0103e0c:	83 c4 10             	add    $0x10,%esp
f0103e0f:	85 f6                	test   %esi,%esi
f0103e11:	7f f0                	jg     f0103e03 <vprintfmt+0x1c6>
f0103e13:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103e16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e1d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103e20:	0f be 02             	movsbl (%edx),%eax
f0103e23:	85 c0                	test   %eax,%eax
f0103e25:	75 47                	jne    f0103e6e <vprintfmt+0x231>
f0103e27:	eb 37                	jmp    f0103e60 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0103e29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103e2d:	74 16                	je     f0103e45 <vprintfmt+0x208>
f0103e2f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103e32:	83 fa 5e             	cmp    $0x5e,%edx
f0103e35:	76 0e                	jbe    f0103e45 <vprintfmt+0x208>
					putch('?', putdat);
f0103e37:	83 ec 08             	sub    $0x8,%esp
f0103e3a:	57                   	push   %edi
f0103e3b:	6a 3f                	push   $0x3f
f0103e3d:	ff 55 08             	call   *0x8(%ebp)
f0103e40:	83 c4 10             	add    $0x10,%esp
f0103e43:	eb 0b                	jmp    f0103e50 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0103e45:	83 ec 08             	sub    $0x8,%esp
f0103e48:	57                   	push   %edi
f0103e49:	50                   	push   %eax
f0103e4a:	ff 55 08             	call   *0x8(%ebp)
f0103e4d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e50:	ff 4d e4             	decl   -0x1c(%ebp)
f0103e53:	0f be 03             	movsbl (%ebx),%eax
f0103e56:	85 c0                	test   %eax,%eax
f0103e58:	74 03                	je     f0103e5d <vprintfmt+0x220>
f0103e5a:	43                   	inc    %ebx
f0103e5b:	eb 1b                	jmp    f0103e78 <vprintfmt+0x23b>
f0103e5d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103e64:	7f 1e                	jg     f0103e84 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e66:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103e69:	e9 f3 fd ff ff       	jmp    f0103c61 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e6e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103e71:	43                   	inc    %ebx
f0103e72:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103e75:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103e78:	85 f6                	test   %esi,%esi
f0103e7a:	78 ad                	js     f0103e29 <vprintfmt+0x1ec>
f0103e7c:	4e                   	dec    %esi
f0103e7d:	79 aa                	jns    f0103e29 <vprintfmt+0x1ec>
f0103e7f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103e82:	eb dc                	jmp    f0103e60 <vprintfmt+0x223>
f0103e84:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103e87:	83 ec 08             	sub    $0x8,%esp
f0103e8a:	57                   	push   %edi
f0103e8b:	6a 20                	push   $0x20
f0103e8d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e90:	4b                   	dec    %ebx
f0103e91:	83 c4 10             	add    $0x10,%esp
f0103e94:	85 db                	test   %ebx,%ebx
f0103e96:	7f ef                	jg     f0103e87 <vprintfmt+0x24a>
f0103e98:	e9 c4 fd ff ff       	jmp    f0103c61 <vprintfmt+0x24>
f0103e9d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103ea0:	89 ca                	mov    %ecx,%edx
f0103ea2:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ea5:	e8 2a fd ff ff       	call   f0103bd4 <getint>
f0103eaa:	89 c3                	mov    %eax,%ebx
f0103eac:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103eae:	85 d2                	test   %edx,%edx
f0103eb0:	78 0a                	js     f0103ebc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103eb2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103eb7:	e9 b0 00 00 00       	jmp    f0103f6c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103ebc:	83 ec 08             	sub    $0x8,%esp
f0103ebf:	57                   	push   %edi
f0103ec0:	6a 2d                	push   $0x2d
f0103ec2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103ec5:	f7 db                	neg    %ebx
f0103ec7:	83 d6 00             	adc    $0x0,%esi
f0103eca:	f7 de                	neg    %esi
f0103ecc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103ecf:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ed4:	e9 93 00 00 00       	jmp    f0103f6c <vprintfmt+0x32f>
f0103ed9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103edc:	89 ca                	mov    %ecx,%edx
f0103ede:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ee1:	e8 b4 fc ff ff       	call   f0103b9a <getuint>
f0103ee6:	89 c3                	mov    %eax,%ebx
f0103ee8:	89 d6                	mov    %edx,%esi
			base = 10;
f0103eea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103eef:	eb 7b                	jmp    f0103f6c <vprintfmt+0x32f>
f0103ef1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103ef4:	89 ca                	mov    %ecx,%edx
f0103ef6:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ef9:	e8 d6 fc ff ff       	call   f0103bd4 <getint>
f0103efe:	89 c3                	mov    %eax,%ebx
f0103f00:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103f02:	85 d2                	test   %edx,%edx
f0103f04:	78 07                	js     f0103f0d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0103f06:	b8 08 00 00 00       	mov    $0x8,%eax
f0103f0b:	eb 5f                	jmp    f0103f6c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103f0d:	83 ec 08             	sub    $0x8,%esp
f0103f10:	57                   	push   %edi
f0103f11:	6a 2d                	push   $0x2d
f0103f13:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0103f16:	f7 db                	neg    %ebx
f0103f18:	83 d6 00             	adc    $0x0,%esi
f0103f1b:	f7 de                	neg    %esi
f0103f1d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0103f20:	b8 08 00 00 00       	mov    $0x8,%eax
f0103f25:	eb 45                	jmp    f0103f6c <vprintfmt+0x32f>
f0103f27:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0103f2a:	83 ec 08             	sub    $0x8,%esp
f0103f2d:	57                   	push   %edi
f0103f2e:	6a 30                	push   $0x30
f0103f30:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103f33:	83 c4 08             	add    $0x8,%esp
f0103f36:	57                   	push   %edi
f0103f37:	6a 78                	push   $0x78
f0103f39:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103f3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3f:	8d 50 04             	lea    0x4(%eax),%edx
f0103f42:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103f45:	8b 18                	mov    (%eax),%ebx
f0103f47:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103f4c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103f4f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103f54:	eb 16                	jmp    f0103f6c <vprintfmt+0x32f>
f0103f56:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103f59:	89 ca                	mov    %ecx,%edx
f0103f5b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f5e:	e8 37 fc ff ff       	call   f0103b9a <getuint>
f0103f63:	89 c3                	mov    %eax,%ebx
f0103f65:	89 d6                	mov    %edx,%esi
			base = 16;
f0103f67:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103f6c:	83 ec 0c             	sub    $0xc,%esp
f0103f6f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103f73:	52                   	push   %edx
f0103f74:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103f77:	50                   	push   %eax
f0103f78:	56                   	push   %esi
f0103f79:	53                   	push   %ebx
f0103f7a:	89 fa                	mov    %edi,%edx
f0103f7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f7f:	e8 68 fb ff ff       	call   f0103aec <printnum>
			break;
f0103f84:	83 c4 20             	add    $0x20,%esp
f0103f87:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103f8a:	e9 d2 fc ff ff       	jmp    f0103c61 <vprintfmt+0x24>
f0103f8f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103f92:	83 ec 08             	sub    $0x8,%esp
f0103f95:	57                   	push   %edi
f0103f96:	52                   	push   %edx
f0103f97:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103f9a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f9d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103fa0:	e9 bc fc ff ff       	jmp    f0103c61 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103fa5:	83 ec 08             	sub    $0x8,%esp
f0103fa8:	57                   	push   %edi
f0103fa9:	6a 25                	push   $0x25
f0103fab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103fae:	83 c4 10             	add    $0x10,%esp
f0103fb1:	eb 02                	jmp    f0103fb5 <vprintfmt+0x378>
f0103fb3:	89 c6                	mov    %eax,%esi
f0103fb5:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103fb8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103fbc:	75 f5                	jne    f0103fb3 <vprintfmt+0x376>
f0103fbe:	e9 9e fc ff ff       	jmp    f0103c61 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fc6:	5b                   	pop    %ebx
f0103fc7:	5e                   	pop    %esi
f0103fc8:	5f                   	pop    %edi
f0103fc9:	c9                   	leave  
f0103fca:	c3                   	ret    

f0103fcb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103fcb:	55                   	push   %ebp
f0103fcc:	89 e5                	mov    %esp,%ebp
f0103fce:	83 ec 18             	sub    $0x18,%esp
f0103fd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103fda:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103fde:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103fe1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103fe8:	85 c0                	test   %eax,%eax
f0103fea:	74 26                	je     f0104012 <vsnprintf+0x47>
f0103fec:	85 d2                	test   %edx,%edx
f0103fee:	7e 29                	jle    f0104019 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ff0:	ff 75 14             	pushl  0x14(%ebp)
f0103ff3:	ff 75 10             	pushl  0x10(%ebp)
f0103ff6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ff9:	50                   	push   %eax
f0103ffa:	68 06 3c 10 f0       	push   $0xf0103c06
f0103fff:	e8 39 fc ff ff       	call   f0103c3d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104004:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104007:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010400a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010400d:	83 c4 10             	add    $0x10,%esp
f0104010:	eb 0c                	jmp    f010401e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104012:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104017:	eb 05                	jmp    f010401e <vsnprintf+0x53>
f0104019:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010401e:	c9                   	leave  
f010401f:	c3                   	ret    

f0104020 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104020:	55                   	push   %ebp
f0104021:	89 e5                	mov    %esp,%ebp
f0104023:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104026:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104029:	50                   	push   %eax
f010402a:	ff 75 10             	pushl  0x10(%ebp)
f010402d:	ff 75 0c             	pushl  0xc(%ebp)
f0104030:	ff 75 08             	pushl  0x8(%ebp)
f0104033:	e8 93 ff ff ff       	call   f0103fcb <vsnprintf>
	va_end(ap);

	return rc;
}
f0104038:	c9                   	leave  
f0104039:	c3                   	ret    
	...

f010403c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010403c:	55                   	push   %ebp
f010403d:	89 e5                	mov    %esp,%ebp
f010403f:	57                   	push   %edi
f0104040:	56                   	push   %esi
f0104041:	53                   	push   %ebx
f0104042:	83 ec 0c             	sub    $0xc,%esp
f0104045:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104048:	85 c0                	test   %eax,%eax
f010404a:	74 11                	je     f010405d <readline+0x21>
		cprintf("%s", prompt);
f010404c:	83 ec 08             	sub    $0x8,%esp
f010404f:	50                   	push   %eax
f0104050:	68 0d 59 10 f0       	push   $0xf010590d
f0104055:	e8 ab f3 ff ff       	call   f0103405 <cprintf>
f010405a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010405d:	83 ec 0c             	sub    $0xc,%esp
f0104060:	6a 00                	push   $0x0
f0104062:	e8 ac c5 ff ff       	call   f0100613 <iscons>
f0104067:	89 c7                	mov    %eax,%edi
f0104069:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010406c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104071:	e8 8c c5 ff ff       	call   f0100602 <getchar>
f0104076:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104078:	85 c0                	test   %eax,%eax
f010407a:	79 18                	jns    f0104094 <readline+0x58>
			cprintf("read error: %e\n", c);
f010407c:	83 ec 08             	sub    $0x8,%esp
f010407f:	50                   	push   %eax
f0104080:	68 80 62 10 f0       	push   $0xf0106280
f0104085:	e8 7b f3 ff ff       	call   f0103405 <cprintf>
			return NULL;
f010408a:	83 c4 10             	add    $0x10,%esp
f010408d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104092:	eb 6f                	jmp    f0104103 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104094:	83 f8 08             	cmp    $0x8,%eax
f0104097:	74 05                	je     f010409e <readline+0x62>
f0104099:	83 f8 7f             	cmp    $0x7f,%eax
f010409c:	75 18                	jne    f01040b6 <readline+0x7a>
f010409e:	85 f6                	test   %esi,%esi
f01040a0:	7e 14                	jle    f01040b6 <readline+0x7a>
			if (echoing)
f01040a2:	85 ff                	test   %edi,%edi
f01040a4:	74 0d                	je     f01040b3 <readline+0x77>
				cputchar('\b');
f01040a6:	83 ec 0c             	sub    $0xc,%esp
f01040a9:	6a 08                	push   $0x8
f01040ab:	e8 42 c5 ff ff       	call   f01005f2 <cputchar>
f01040b0:	83 c4 10             	add    $0x10,%esp
			i--;
f01040b3:	4e                   	dec    %esi
f01040b4:	eb bb                	jmp    f0104071 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01040b6:	83 fb 1f             	cmp    $0x1f,%ebx
f01040b9:	7e 21                	jle    f01040dc <readline+0xa0>
f01040bb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01040c1:	7f 19                	jg     f01040dc <readline+0xa0>
			if (echoing)
f01040c3:	85 ff                	test   %edi,%edi
f01040c5:	74 0c                	je     f01040d3 <readline+0x97>
				cputchar(c);
f01040c7:	83 ec 0c             	sub    $0xc,%esp
f01040ca:	53                   	push   %ebx
f01040cb:	e8 22 c5 ff ff       	call   f01005f2 <cputchar>
f01040d0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01040d3:	88 9e 80 7b 1d f0    	mov    %bl,-0xfe28480(%esi)
f01040d9:	46                   	inc    %esi
f01040da:	eb 95                	jmp    f0104071 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01040dc:	83 fb 0a             	cmp    $0xa,%ebx
f01040df:	74 05                	je     f01040e6 <readline+0xaa>
f01040e1:	83 fb 0d             	cmp    $0xd,%ebx
f01040e4:	75 8b                	jne    f0104071 <readline+0x35>
			if (echoing)
f01040e6:	85 ff                	test   %edi,%edi
f01040e8:	74 0d                	je     f01040f7 <readline+0xbb>
				cputchar('\n');
f01040ea:	83 ec 0c             	sub    $0xc,%esp
f01040ed:	6a 0a                	push   $0xa
f01040ef:	e8 fe c4 ff ff       	call   f01005f2 <cputchar>
f01040f4:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01040f7:	c6 86 80 7b 1d f0 00 	movb   $0x0,-0xfe28480(%esi)
			return buf;
f01040fe:	b8 80 7b 1d f0       	mov    $0xf01d7b80,%eax
		}
	}
}
f0104103:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104106:	5b                   	pop    %ebx
f0104107:	5e                   	pop    %esi
f0104108:	5f                   	pop    %edi
f0104109:	c9                   	leave  
f010410a:	c3                   	ret    
	...

f010410c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010410c:	55                   	push   %ebp
f010410d:	89 e5                	mov    %esp,%ebp
f010410f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104112:	80 3a 00             	cmpb   $0x0,(%edx)
f0104115:	74 0e                	je     f0104125 <strlen+0x19>
f0104117:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010411c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010411d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104121:	75 f9                	jne    f010411c <strlen+0x10>
f0104123:	eb 05                	jmp    f010412a <strlen+0x1e>
f0104125:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010412a:	c9                   	leave  
f010412b:	c3                   	ret    

f010412c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010412c:	55                   	push   %ebp
f010412d:	89 e5                	mov    %esp,%ebp
f010412f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104132:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104135:	85 d2                	test   %edx,%edx
f0104137:	74 17                	je     f0104150 <strnlen+0x24>
f0104139:	80 39 00             	cmpb   $0x0,(%ecx)
f010413c:	74 19                	je     f0104157 <strnlen+0x2b>
f010413e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104143:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104144:	39 d0                	cmp    %edx,%eax
f0104146:	74 14                	je     f010415c <strnlen+0x30>
f0104148:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010414c:	75 f5                	jne    f0104143 <strnlen+0x17>
f010414e:	eb 0c                	jmp    f010415c <strnlen+0x30>
f0104150:	b8 00 00 00 00       	mov    $0x0,%eax
f0104155:	eb 05                	jmp    f010415c <strnlen+0x30>
f0104157:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010415c:	c9                   	leave  
f010415d:	c3                   	ret    

f010415e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010415e:	55                   	push   %ebp
f010415f:	89 e5                	mov    %esp,%ebp
f0104161:	53                   	push   %ebx
f0104162:	8b 45 08             	mov    0x8(%ebp),%eax
f0104165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104168:	ba 00 00 00 00       	mov    $0x0,%edx
f010416d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104170:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104173:	42                   	inc    %edx
f0104174:	84 c9                	test   %cl,%cl
f0104176:	75 f5                	jne    f010416d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104178:	5b                   	pop    %ebx
f0104179:	c9                   	leave  
f010417a:	c3                   	ret    

f010417b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010417b:	55                   	push   %ebp
f010417c:	89 e5                	mov    %esp,%ebp
f010417e:	53                   	push   %ebx
f010417f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104182:	53                   	push   %ebx
f0104183:	e8 84 ff ff ff       	call   f010410c <strlen>
f0104188:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010418b:	ff 75 0c             	pushl  0xc(%ebp)
f010418e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104191:	50                   	push   %eax
f0104192:	e8 c7 ff ff ff       	call   f010415e <strcpy>
	return dst;
}
f0104197:	89 d8                	mov    %ebx,%eax
f0104199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010419c:	c9                   	leave  
f010419d:	c3                   	ret    

f010419e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010419e:	55                   	push   %ebp
f010419f:	89 e5                	mov    %esp,%ebp
f01041a1:	56                   	push   %esi
f01041a2:	53                   	push   %ebx
f01041a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01041a6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041a9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041ac:	85 f6                	test   %esi,%esi
f01041ae:	74 15                	je     f01041c5 <strncpy+0x27>
f01041b0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01041b5:	8a 1a                	mov    (%edx),%bl
f01041b7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01041ba:	80 3a 01             	cmpb   $0x1,(%edx)
f01041bd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041c0:	41                   	inc    %ecx
f01041c1:	39 ce                	cmp    %ecx,%esi
f01041c3:	77 f0                	ja     f01041b5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01041c5:	5b                   	pop    %ebx
f01041c6:	5e                   	pop    %esi
f01041c7:	c9                   	leave  
f01041c8:	c3                   	ret    

f01041c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01041c9:	55                   	push   %ebp
f01041ca:	89 e5                	mov    %esp,%ebp
f01041cc:	57                   	push   %edi
f01041cd:	56                   	push   %esi
f01041ce:	53                   	push   %ebx
f01041cf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01041d5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01041d8:	85 f6                	test   %esi,%esi
f01041da:	74 32                	je     f010420e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01041dc:	83 fe 01             	cmp    $0x1,%esi
f01041df:	74 22                	je     f0104203 <strlcpy+0x3a>
f01041e1:	8a 0b                	mov    (%ebx),%cl
f01041e3:	84 c9                	test   %cl,%cl
f01041e5:	74 20                	je     f0104207 <strlcpy+0x3e>
f01041e7:	89 f8                	mov    %edi,%eax
f01041e9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01041ee:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01041f1:	88 08                	mov    %cl,(%eax)
f01041f3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01041f4:	39 f2                	cmp    %esi,%edx
f01041f6:	74 11                	je     f0104209 <strlcpy+0x40>
f01041f8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01041fc:	42                   	inc    %edx
f01041fd:	84 c9                	test   %cl,%cl
f01041ff:	75 f0                	jne    f01041f1 <strlcpy+0x28>
f0104201:	eb 06                	jmp    f0104209 <strlcpy+0x40>
f0104203:	89 f8                	mov    %edi,%eax
f0104205:	eb 02                	jmp    f0104209 <strlcpy+0x40>
f0104207:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104209:	c6 00 00             	movb   $0x0,(%eax)
f010420c:	eb 02                	jmp    f0104210 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010420e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0104210:	29 f8                	sub    %edi,%eax
}
f0104212:	5b                   	pop    %ebx
f0104213:	5e                   	pop    %esi
f0104214:	5f                   	pop    %edi
f0104215:	c9                   	leave  
f0104216:	c3                   	ret    

f0104217 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104217:	55                   	push   %ebp
f0104218:	89 e5                	mov    %esp,%ebp
f010421a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010421d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104220:	8a 01                	mov    (%ecx),%al
f0104222:	84 c0                	test   %al,%al
f0104224:	74 10                	je     f0104236 <strcmp+0x1f>
f0104226:	3a 02                	cmp    (%edx),%al
f0104228:	75 0c                	jne    f0104236 <strcmp+0x1f>
		p++, q++;
f010422a:	41                   	inc    %ecx
f010422b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010422c:	8a 01                	mov    (%ecx),%al
f010422e:	84 c0                	test   %al,%al
f0104230:	74 04                	je     f0104236 <strcmp+0x1f>
f0104232:	3a 02                	cmp    (%edx),%al
f0104234:	74 f4                	je     f010422a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104236:	0f b6 c0             	movzbl %al,%eax
f0104239:	0f b6 12             	movzbl (%edx),%edx
f010423c:	29 d0                	sub    %edx,%eax
}
f010423e:	c9                   	leave  
f010423f:	c3                   	ret    

f0104240 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104240:	55                   	push   %ebp
f0104241:	89 e5                	mov    %esp,%ebp
f0104243:	53                   	push   %ebx
f0104244:	8b 55 08             	mov    0x8(%ebp),%edx
f0104247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010424a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f010424d:	85 c0                	test   %eax,%eax
f010424f:	74 1b                	je     f010426c <strncmp+0x2c>
f0104251:	8a 1a                	mov    (%edx),%bl
f0104253:	84 db                	test   %bl,%bl
f0104255:	74 24                	je     f010427b <strncmp+0x3b>
f0104257:	3a 19                	cmp    (%ecx),%bl
f0104259:	75 20                	jne    f010427b <strncmp+0x3b>
f010425b:	48                   	dec    %eax
f010425c:	74 15                	je     f0104273 <strncmp+0x33>
		n--, p++, q++;
f010425e:	42                   	inc    %edx
f010425f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104260:	8a 1a                	mov    (%edx),%bl
f0104262:	84 db                	test   %bl,%bl
f0104264:	74 15                	je     f010427b <strncmp+0x3b>
f0104266:	3a 19                	cmp    (%ecx),%bl
f0104268:	74 f1                	je     f010425b <strncmp+0x1b>
f010426a:	eb 0f                	jmp    f010427b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010426c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104271:	eb 05                	jmp    f0104278 <strncmp+0x38>
f0104273:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104278:	5b                   	pop    %ebx
f0104279:	c9                   	leave  
f010427a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010427b:	0f b6 02             	movzbl (%edx),%eax
f010427e:	0f b6 11             	movzbl (%ecx),%edx
f0104281:	29 d0                	sub    %edx,%eax
f0104283:	eb f3                	jmp    f0104278 <strncmp+0x38>

f0104285 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104285:	55                   	push   %ebp
f0104286:	89 e5                	mov    %esp,%ebp
f0104288:	8b 45 08             	mov    0x8(%ebp),%eax
f010428b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010428e:	8a 10                	mov    (%eax),%dl
f0104290:	84 d2                	test   %dl,%dl
f0104292:	74 18                	je     f01042ac <strchr+0x27>
		if (*s == c)
f0104294:	38 ca                	cmp    %cl,%dl
f0104296:	75 06                	jne    f010429e <strchr+0x19>
f0104298:	eb 17                	jmp    f01042b1 <strchr+0x2c>
f010429a:	38 ca                	cmp    %cl,%dl
f010429c:	74 13                	je     f01042b1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010429e:	40                   	inc    %eax
f010429f:	8a 10                	mov    (%eax),%dl
f01042a1:	84 d2                	test   %dl,%dl
f01042a3:	75 f5                	jne    f010429a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01042a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01042aa:	eb 05                	jmp    f01042b1 <strchr+0x2c>
f01042ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042b1:	c9                   	leave  
f01042b2:	c3                   	ret    

f01042b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01042b3:	55                   	push   %ebp
f01042b4:	89 e5                	mov    %esp,%ebp
f01042b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01042b9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01042bc:	8a 10                	mov    (%eax),%dl
f01042be:	84 d2                	test   %dl,%dl
f01042c0:	74 11                	je     f01042d3 <strfind+0x20>
		if (*s == c)
f01042c2:	38 ca                	cmp    %cl,%dl
f01042c4:	75 06                	jne    f01042cc <strfind+0x19>
f01042c6:	eb 0b                	jmp    f01042d3 <strfind+0x20>
f01042c8:	38 ca                	cmp    %cl,%dl
f01042ca:	74 07                	je     f01042d3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01042cc:	40                   	inc    %eax
f01042cd:	8a 10                	mov    (%eax),%dl
f01042cf:	84 d2                	test   %dl,%dl
f01042d1:	75 f5                	jne    f01042c8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01042d3:	c9                   	leave  
f01042d4:	c3                   	ret    

f01042d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01042d5:	55                   	push   %ebp
f01042d6:	89 e5                	mov    %esp,%ebp
f01042d8:	57                   	push   %edi
f01042d9:	56                   	push   %esi
f01042da:	53                   	push   %ebx
f01042db:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01042e4:	85 c9                	test   %ecx,%ecx
f01042e6:	74 30                	je     f0104318 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01042e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01042ee:	75 25                	jne    f0104315 <memset+0x40>
f01042f0:	f6 c1 03             	test   $0x3,%cl
f01042f3:	75 20                	jne    f0104315 <memset+0x40>
		c &= 0xFF;
f01042f5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01042f8:	89 d3                	mov    %edx,%ebx
f01042fa:	c1 e3 08             	shl    $0x8,%ebx
f01042fd:	89 d6                	mov    %edx,%esi
f01042ff:	c1 e6 18             	shl    $0x18,%esi
f0104302:	89 d0                	mov    %edx,%eax
f0104304:	c1 e0 10             	shl    $0x10,%eax
f0104307:	09 f0                	or     %esi,%eax
f0104309:	09 d0                	or     %edx,%eax
f010430b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010430d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104310:	fc                   	cld    
f0104311:	f3 ab                	rep stos %eax,%es:(%edi)
f0104313:	eb 03                	jmp    f0104318 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104315:	fc                   	cld    
f0104316:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104318:	89 f8                	mov    %edi,%eax
f010431a:	5b                   	pop    %ebx
f010431b:	5e                   	pop    %esi
f010431c:	5f                   	pop    %edi
f010431d:	c9                   	leave  
f010431e:	c3                   	ret    

f010431f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010431f:	55                   	push   %ebp
f0104320:	89 e5                	mov    %esp,%ebp
f0104322:	57                   	push   %edi
f0104323:	56                   	push   %esi
f0104324:	8b 45 08             	mov    0x8(%ebp),%eax
f0104327:	8b 75 0c             	mov    0xc(%ebp),%esi
f010432a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010432d:	39 c6                	cmp    %eax,%esi
f010432f:	73 34                	jae    f0104365 <memmove+0x46>
f0104331:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104334:	39 d0                	cmp    %edx,%eax
f0104336:	73 2d                	jae    f0104365 <memmove+0x46>
		s += n;
		d += n;
f0104338:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010433b:	f6 c2 03             	test   $0x3,%dl
f010433e:	75 1b                	jne    f010435b <memmove+0x3c>
f0104340:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104346:	75 13                	jne    f010435b <memmove+0x3c>
f0104348:	f6 c1 03             	test   $0x3,%cl
f010434b:	75 0e                	jne    f010435b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010434d:	83 ef 04             	sub    $0x4,%edi
f0104350:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104353:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104356:	fd                   	std    
f0104357:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104359:	eb 07                	jmp    f0104362 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010435b:	4f                   	dec    %edi
f010435c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010435f:	fd                   	std    
f0104360:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104362:	fc                   	cld    
f0104363:	eb 20                	jmp    f0104385 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104365:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010436b:	75 13                	jne    f0104380 <memmove+0x61>
f010436d:	a8 03                	test   $0x3,%al
f010436f:	75 0f                	jne    f0104380 <memmove+0x61>
f0104371:	f6 c1 03             	test   $0x3,%cl
f0104374:	75 0a                	jne    f0104380 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104376:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104379:	89 c7                	mov    %eax,%edi
f010437b:	fc                   	cld    
f010437c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010437e:	eb 05                	jmp    f0104385 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104380:	89 c7                	mov    %eax,%edi
f0104382:	fc                   	cld    
f0104383:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104385:	5e                   	pop    %esi
f0104386:	5f                   	pop    %edi
f0104387:	c9                   	leave  
f0104388:	c3                   	ret    

f0104389 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104389:	55                   	push   %ebp
f010438a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010438c:	ff 75 10             	pushl  0x10(%ebp)
f010438f:	ff 75 0c             	pushl  0xc(%ebp)
f0104392:	ff 75 08             	pushl  0x8(%ebp)
f0104395:	e8 85 ff ff ff       	call   f010431f <memmove>
}
f010439a:	c9                   	leave  
f010439b:	c3                   	ret    

f010439c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010439c:	55                   	push   %ebp
f010439d:	89 e5                	mov    %esp,%ebp
f010439f:	57                   	push   %edi
f01043a0:	56                   	push   %esi
f01043a1:	53                   	push   %ebx
f01043a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01043a5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043a8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043ab:	85 ff                	test   %edi,%edi
f01043ad:	74 32                	je     f01043e1 <memcmp+0x45>
		if (*s1 != *s2)
f01043af:	8a 03                	mov    (%ebx),%al
f01043b1:	8a 0e                	mov    (%esi),%cl
f01043b3:	38 c8                	cmp    %cl,%al
f01043b5:	74 19                	je     f01043d0 <memcmp+0x34>
f01043b7:	eb 0d                	jmp    f01043c6 <memcmp+0x2a>
f01043b9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01043bd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01043c1:	42                   	inc    %edx
f01043c2:	38 c8                	cmp    %cl,%al
f01043c4:	74 10                	je     f01043d6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01043c6:	0f b6 c0             	movzbl %al,%eax
f01043c9:	0f b6 c9             	movzbl %cl,%ecx
f01043cc:	29 c8                	sub    %ecx,%eax
f01043ce:	eb 16                	jmp    f01043e6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043d0:	4f                   	dec    %edi
f01043d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01043d6:	39 fa                	cmp    %edi,%edx
f01043d8:	75 df                	jne    f01043b9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01043da:	b8 00 00 00 00       	mov    $0x0,%eax
f01043df:	eb 05                	jmp    f01043e6 <memcmp+0x4a>
f01043e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043e6:	5b                   	pop    %ebx
f01043e7:	5e                   	pop    %esi
f01043e8:	5f                   	pop    %edi
f01043e9:	c9                   	leave  
f01043ea:	c3                   	ret    

f01043eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01043eb:	55                   	push   %ebp
f01043ec:	89 e5                	mov    %esp,%ebp
f01043ee:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01043f1:	89 c2                	mov    %eax,%edx
f01043f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01043f6:	39 d0                	cmp    %edx,%eax
f01043f8:	73 12                	jae    f010440c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01043fa:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01043fd:	38 08                	cmp    %cl,(%eax)
f01043ff:	75 06                	jne    f0104407 <memfind+0x1c>
f0104401:	eb 09                	jmp    f010440c <memfind+0x21>
f0104403:	38 08                	cmp    %cl,(%eax)
f0104405:	74 05                	je     f010440c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104407:	40                   	inc    %eax
f0104408:	39 c2                	cmp    %eax,%edx
f010440a:	77 f7                	ja     f0104403 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010440c:	c9                   	leave  
f010440d:	c3                   	ret    

f010440e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010440e:	55                   	push   %ebp
f010440f:	89 e5                	mov    %esp,%ebp
f0104411:	57                   	push   %edi
f0104412:	56                   	push   %esi
f0104413:	53                   	push   %ebx
f0104414:	8b 55 08             	mov    0x8(%ebp),%edx
f0104417:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010441a:	eb 01                	jmp    f010441d <strtol+0xf>
		s++;
f010441c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010441d:	8a 02                	mov    (%edx),%al
f010441f:	3c 20                	cmp    $0x20,%al
f0104421:	74 f9                	je     f010441c <strtol+0xe>
f0104423:	3c 09                	cmp    $0x9,%al
f0104425:	74 f5                	je     f010441c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104427:	3c 2b                	cmp    $0x2b,%al
f0104429:	75 08                	jne    f0104433 <strtol+0x25>
		s++;
f010442b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010442c:	bf 00 00 00 00       	mov    $0x0,%edi
f0104431:	eb 13                	jmp    f0104446 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104433:	3c 2d                	cmp    $0x2d,%al
f0104435:	75 0a                	jne    f0104441 <strtol+0x33>
		s++, neg = 1;
f0104437:	8d 52 01             	lea    0x1(%edx),%edx
f010443a:	bf 01 00 00 00       	mov    $0x1,%edi
f010443f:	eb 05                	jmp    f0104446 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104441:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104446:	85 db                	test   %ebx,%ebx
f0104448:	74 05                	je     f010444f <strtol+0x41>
f010444a:	83 fb 10             	cmp    $0x10,%ebx
f010444d:	75 28                	jne    f0104477 <strtol+0x69>
f010444f:	8a 02                	mov    (%edx),%al
f0104451:	3c 30                	cmp    $0x30,%al
f0104453:	75 10                	jne    f0104465 <strtol+0x57>
f0104455:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104459:	75 0a                	jne    f0104465 <strtol+0x57>
		s += 2, base = 16;
f010445b:	83 c2 02             	add    $0x2,%edx
f010445e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104463:	eb 12                	jmp    f0104477 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104465:	85 db                	test   %ebx,%ebx
f0104467:	75 0e                	jne    f0104477 <strtol+0x69>
f0104469:	3c 30                	cmp    $0x30,%al
f010446b:	75 05                	jne    f0104472 <strtol+0x64>
		s++, base = 8;
f010446d:	42                   	inc    %edx
f010446e:	b3 08                	mov    $0x8,%bl
f0104470:	eb 05                	jmp    f0104477 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104472:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104477:	b8 00 00 00 00       	mov    $0x0,%eax
f010447c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010447e:	8a 0a                	mov    (%edx),%cl
f0104480:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104483:	80 fb 09             	cmp    $0x9,%bl
f0104486:	77 08                	ja     f0104490 <strtol+0x82>
			dig = *s - '0';
f0104488:	0f be c9             	movsbl %cl,%ecx
f010448b:	83 e9 30             	sub    $0x30,%ecx
f010448e:	eb 1e                	jmp    f01044ae <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104490:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104493:	80 fb 19             	cmp    $0x19,%bl
f0104496:	77 08                	ja     f01044a0 <strtol+0x92>
			dig = *s - 'a' + 10;
f0104498:	0f be c9             	movsbl %cl,%ecx
f010449b:	83 e9 57             	sub    $0x57,%ecx
f010449e:	eb 0e                	jmp    f01044ae <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01044a0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01044a3:	80 fb 19             	cmp    $0x19,%bl
f01044a6:	77 13                	ja     f01044bb <strtol+0xad>
			dig = *s - 'A' + 10;
f01044a8:	0f be c9             	movsbl %cl,%ecx
f01044ab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01044ae:	39 f1                	cmp    %esi,%ecx
f01044b0:	7d 0d                	jge    f01044bf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01044b2:	42                   	inc    %edx
f01044b3:	0f af c6             	imul   %esi,%eax
f01044b6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01044b9:	eb c3                	jmp    f010447e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01044bb:	89 c1                	mov    %eax,%ecx
f01044bd:	eb 02                	jmp    f01044c1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01044bf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01044c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01044c5:	74 05                	je     f01044cc <strtol+0xbe>
		*endptr = (char *) s;
f01044c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01044ca:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01044cc:	85 ff                	test   %edi,%edi
f01044ce:	74 04                	je     f01044d4 <strtol+0xc6>
f01044d0:	89 c8                	mov    %ecx,%eax
f01044d2:	f7 d8                	neg    %eax
}
f01044d4:	5b                   	pop    %ebx
f01044d5:	5e                   	pop    %esi
f01044d6:	5f                   	pop    %edi
f01044d7:	c9                   	leave  
f01044d8:	c3                   	ret    
f01044d9:	00 00                	add    %al,(%eax)
	...

f01044dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01044dc:	55                   	push   %ebp
f01044dd:	89 e5                	mov    %esp,%ebp
f01044df:	57                   	push   %edi
f01044e0:	56                   	push   %esi
f01044e1:	83 ec 10             	sub    $0x10,%esp
f01044e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01044e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01044ea:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01044ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01044f0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01044f3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01044f6:	85 c0                	test   %eax,%eax
f01044f8:	75 2e                	jne    f0104528 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01044fa:	39 f1                	cmp    %esi,%ecx
f01044fc:	77 5a                	ja     f0104558 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01044fe:	85 c9                	test   %ecx,%ecx
f0104500:	75 0b                	jne    f010450d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104502:	b8 01 00 00 00       	mov    $0x1,%eax
f0104507:	31 d2                	xor    %edx,%edx
f0104509:	f7 f1                	div    %ecx
f010450b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010450d:	31 d2                	xor    %edx,%edx
f010450f:	89 f0                	mov    %esi,%eax
f0104511:	f7 f1                	div    %ecx
f0104513:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104515:	89 f8                	mov    %edi,%eax
f0104517:	f7 f1                	div    %ecx
f0104519:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010451b:	89 f8                	mov    %edi,%eax
f010451d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010451f:	83 c4 10             	add    $0x10,%esp
f0104522:	5e                   	pop    %esi
f0104523:	5f                   	pop    %edi
f0104524:	c9                   	leave  
f0104525:	c3                   	ret    
f0104526:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104528:	39 f0                	cmp    %esi,%eax
f010452a:	77 1c                	ja     f0104548 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010452c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f010452f:	83 f7 1f             	xor    $0x1f,%edi
f0104532:	75 3c                	jne    f0104570 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104534:	39 f0                	cmp    %esi,%eax
f0104536:	0f 82 90 00 00 00    	jb     f01045cc <__udivdi3+0xf0>
f010453c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010453f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0104542:	0f 86 84 00 00 00    	jbe    f01045cc <__udivdi3+0xf0>
f0104548:	31 f6                	xor    %esi,%esi
f010454a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010454c:	89 f8                	mov    %edi,%eax
f010454e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104550:	83 c4 10             	add    $0x10,%esp
f0104553:	5e                   	pop    %esi
f0104554:	5f                   	pop    %edi
f0104555:	c9                   	leave  
f0104556:	c3                   	ret    
f0104557:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104558:	89 f2                	mov    %esi,%edx
f010455a:	89 f8                	mov    %edi,%eax
f010455c:	f7 f1                	div    %ecx
f010455e:	89 c7                	mov    %eax,%edi
f0104560:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104562:	89 f8                	mov    %edi,%eax
f0104564:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104566:	83 c4 10             	add    $0x10,%esp
f0104569:	5e                   	pop    %esi
f010456a:	5f                   	pop    %edi
f010456b:	c9                   	leave  
f010456c:	c3                   	ret    
f010456d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104570:	89 f9                	mov    %edi,%ecx
f0104572:	d3 e0                	shl    %cl,%eax
f0104574:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104577:	b8 20 00 00 00       	mov    $0x20,%eax
f010457c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010457e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104581:	88 c1                	mov    %al,%cl
f0104583:	d3 ea                	shr    %cl,%edx
f0104585:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104588:	09 ca                	or     %ecx,%edx
f010458a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f010458d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104590:	89 f9                	mov    %edi,%ecx
f0104592:	d3 e2                	shl    %cl,%edx
f0104594:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104597:	89 f2                	mov    %esi,%edx
f0104599:	88 c1                	mov    %al,%cl
f010459b:	d3 ea                	shr    %cl,%edx
f010459d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01045a0:	89 f2                	mov    %esi,%edx
f01045a2:	89 f9                	mov    %edi,%ecx
f01045a4:	d3 e2                	shl    %cl,%edx
f01045a6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01045a9:	88 c1                	mov    %al,%cl
f01045ab:	d3 ee                	shr    %cl,%esi
f01045ad:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01045af:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01045b2:	89 f0                	mov    %esi,%eax
f01045b4:	89 ca                	mov    %ecx,%edx
f01045b6:	f7 75 ec             	divl   -0x14(%ebp)
f01045b9:	89 d1                	mov    %edx,%ecx
f01045bb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01045bd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01045c0:	39 d1                	cmp    %edx,%ecx
f01045c2:	72 28                	jb     f01045ec <__udivdi3+0x110>
f01045c4:	74 1a                	je     f01045e0 <__udivdi3+0x104>
f01045c6:	89 f7                	mov    %esi,%edi
f01045c8:	31 f6                	xor    %esi,%esi
f01045ca:	eb 80                	jmp    f010454c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01045cc:	31 f6                	xor    %esi,%esi
f01045ce:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01045d3:	89 f8                	mov    %edi,%eax
f01045d5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01045d7:	83 c4 10             	add    $0x10,%esp
f01045da:	5e                   	pop    %esi
f01045db:	5f                   	pop    %edi
f01045dc:	c9                   	leave  
f01045dd:	c3                   	ret    
f01045de:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01045e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045e3:	89 f9                	mov    %edi,%ecx
f01045e5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01045e7:	39 c2                	cmp    %eax,%edx
f01045e9:	73 db                	jae    f01045c6 <__udivdi3+0xea>
f01045eb:	90                   	nop
		{
		  q0--;
f01045ec:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01045ef:	31 f6                	xor    %esi,%esi
f01045f1:	e9 56 ff ff ff       	jmp    f010454c <__udivdi3+0x70>
	...

f01045f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01045f8:	55                   	push   %ebp
f01045f9:	89 e5                	mov    %esp,%ebp
f01045fb:	57                   	push   %edi
f01045fc:	56                   	push   %esi
f01045fd:	83 ec 20             	sub    $0x20,%esp
f0104600:	8b 45 08             	mov    0x8(%ebp),%eax
f0104603:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104606:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104609:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010460c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010460f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104612:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104615:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104617:	85 ff                	test   %edi,%edi
f0104619:	75 15                	jne    f0104630 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010461b:	39 f1                	cmp    %esi,%ecx
f010461d:	0f 86 99 00 00 00    	jbe    f01046bc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104623:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104625:	89 d0                	mov    %edx,%eax
f0104627:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104629:	83 c4 20             	add    $0x20,%esp
f010462c:	5e                   	pop    %esi
f010462d:	5f                   	pop    %edi
f010462e:	c9                   	leave  
f010462f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104630:	39 f7                	cmp    %esi,%edi
f0104632:	0f 87 a4 00 00 00    	ja     f01046dc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104638:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010463b:	83 f0 1f             	xor    $0x1f,%eax
f010463e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104641:	0f 84 a1 00 00 00    	je     f01046e8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104647:	89 f8                	mov    %edi,%eax
f0104649:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010464c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010464e:	bf 20 00 00 00       	mov    $0x20,%edi
f0104653:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104656:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104659:	89 f9                	mov    %edi,%ecx
f010465b:	d3 ea                	shr    %cl,%edx
f010465d:	09 c2                	or     %eax,%edx
f010465f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104662:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104665:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104668:	d3 e0                	shl    %cl,%eax
f010466a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010466d:	89 f2                	mov    %esi,%edx
f010466f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104671:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104674:	d3 e0                	shl    %cl,%eax
f0104676:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104679:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010467c:	89 f9                	mov    %edi,%ecx
f010467e:	d3 e8                	shr    %cl,%eax
f0104680:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104682:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104684:	89 f2                	mov    %esi,%edx
f0104686:	f7 75 f0             	divl   -0x10(%ebp)
f0104689:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f010468b:	f7 65 f4             	mull   -0xc(%ebp)
f010468e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104691:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104693:	39 d6                	cmp    %edx,%esi
f0104695:	72 71                	jb     f0104708 <__umoddi3+0x110>
f0104697:	74 7f                	je     f0104718 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010469c:	29 c8                	sub    %ecx,%eax
f010469e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01046a0:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01046a3:	d3 e8                	shr    %cl,%eax
f01046a5:	89 f2                	mov    %esi,%edx
f01046a7:	89 f9                	mov    %edi,%ecx
f01046a9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01046ab:	09 d0                	or     %edx,%eax
f01046ad:	89 f2                	mov    %esi,%edx
f01046af:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01046b2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01046b4:	83 c4 20             	add    $0x20,%esp
f01046b7:	5e                   	pop    %esi
f01046b8:	5f                   	pop    %edi
f01046b9:	c9                   	leave  
f01046ba:	c3                   	ret    
f01046bb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01046bc:	85 c9                	test   %ecx,%ecx
f01046be:	75 0b                	jne    f01046cb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01046c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01046c5:	31 d2                	xor    %edx,%edx
f01046c7:	f7 f1                	div    %ecx
f01046c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01046cb:	89 f0                	mov    %esi,%eax
f01046cd:	31 d2                	xor    %edx,%edx
f01046cf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01046d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046d4:	f7 f1                	div    %ecx
f01046d6:	e9 4a ff ff ff       	jmp    f0104625 <__umoddi3+0x2d>
f01046db:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01046dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01046de:	83 c4 20             	add    $0x20,%esp
f01046e1:	5e                   	pop    %esi
f01046e2:	5f                   	pop    %edi
f01046e3:	c9                   	leave  
f01046e4:	c3                   	ret    
f01046e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01046e8:	39 f7                	cmp    %esi,%edi
f01046ea:	72 05                	jb     f01046f1 <__umoddi3+0xf9>
f01046ec:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01046ef:	77 0c                	ja     f01046fd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01046f1:	89 f2                	mov    %esi,%edx
f01046f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046f6:	29 c8                	sub    %ecx,%eax
f01046f8:	19 fa                	sbb    %edi,%edx
f01046fa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01046fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104700:	83 c4 20             	add    $0x20,%esp
f0104703:	5e                   	pop    %esi
f0104704:	5f                   	pop    %edi
f0104705:	c9                   	leave  
f0104706:	c3                   	ret    
f0104707:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104708:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010470b:	89 c1                	mov    %eax,%ecx
f010470d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104710:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104713:	eb 84                	jmp    f0104699 <__umoddi3+0xa1>
f0104715:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104718:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010471b:	72 eb                	jb     f0104708 <__umoddi3+0x110>
f010471d:	89 f2                	mov    %esi,%edx
f010471f:	e9 75 ff ff ff       	jmp    f0104699 <__umoddi3+0xa1>
