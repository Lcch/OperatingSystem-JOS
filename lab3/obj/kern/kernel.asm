
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

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
f0100046:	b8 f0 9f 1d f0       	mov    $0xf01d9ff0,%eax
f010004b:	2d cc 90 1d f0       	sub    $0xf01d90cc,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 cc 90 1d f0       	push   $0xf01d90cc
f0100058:	e8 f4 46 00 00       	call   f0104751 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 a5 04 00 00       	call   f0100507 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 4b 10 f0       	push   $0xf0104ba0
f010006f:	e8 b1 34 00 00       	call   f0103525 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2c 16 00 00       	call   f01016a5 <mem_init>

    cprintf("mem_init done! \n");
f0100079:	c7 04 24 bb 4b 10 f0 	movl   $0xf0104bbb,(%esp)
f0100080:	e8 a0 34 00 00       	call   f0103525 <cprintf>
	// Lab 3 user environment initialization functions
	env_init();
f0100085:	e8 85 2e 00 00       	call   f0102f0f <env_init>
    cprintf("env_init done! \n");
f010008a:	c7 04 24 cc 4b 10 f0 	movl   $0xf0104bcc,(%esp)
f0100091:	e8 8f 34 00 00       	call   f0103525 <cprintf>
	trap_init();
f0100096:	e8 fe 34 00 00       	call   f0103599 <trap_init>
    cprintf("trap_init done! \n");
f010009b:	c7 04 24 dd 4b 10 f0 	movl   $0xf0104bdd,(%esp)
f01000a2:	e8 7e 34 00 00       	call   f0103525 <cprintf>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000a7:	83 c4 0c             	add    $0xc,%esp
f01000aa:	6a 00                	push   $0x0
f01000ac:	68 5f d8 00 00       	push   $0xd85f
f01000b1:	68 de dc 14 f0       	push   $0xf014dcde
f01000b6:	e8 62 30 00 00       	call   f010311d <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*
    
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000bb:	83 c4 04             	add    $0x4,%esp
f01000be:	ff 35 1c 93 1d f0    	pushl  0xf01d931c
f01000c4:	e8 97 33 00 00       	call   f0103460 <env_run>

f01000c9 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000c9:	55                   	push   %ebp
f01000ca:	89 e5                	mov    %esp,%ebp
f01000cc:	56                   	push   %esi
f01000cd:	53                   	push   %ebx
f01000ce:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000d1:	83 3d e0 9f 1d f0 00 	cmpl   $0x0,0xf01d9fe0
f01000d8:	75 37                	jne    f0100111 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000da:	89 35 e0 9f 1d f0    	mov    %esi,0xf01d9fe0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000e0:	fa                   	cli    
f01000e1:	fc                   	cld    

	va_start(ap, fmt);
f01000e2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e5:	83 ec 04             	sub    $0x4,%esp
f01000e8:	ff 75 0c             	pushl  0xc(%ebp)
f01000eb:	ff 75 08             	pushl  0x8(%ebp)
f01000ee:	68 ef 4b 10 f0       	push   $0xf0104bef
f01000f3:	e8 2d 34 00 00       	call   f0103525 <cprintf>
	vcprintf(fmt, ap);
f01000f8:	83 c4 08             	add    $0x8,%esp
f01000fb:	53                   	push   %ebx
f01000fc:	56                   	push   %esi
f01000fd:	e8 fd 33 00 00       	call   f01034ff <vcprintf>
	cprintf("\n");
f0100102:	c7 04 24 ca 4b 10 f0 	movl   $0xf0104bca,(%esp)
f0100109:	e8 17 34 00 00       	call   f0103525 <cprintf>
	va_end(ap);
f010010e:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100111:	83 ec 0c             	sub    $0xc,%esp
f0100114:	6a 00                	push   $0x0
f0100116:	e8 4e 0d 00 00       	call   f0100e69 <monitor>
f010011b:	83 c4 10             	add    $0x10,%esp
f010011e:	eb f1                	jmp    f0100111 <_panic+0x48>

f0100120 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100120:	55                   	push   %ebp
f0100121:	89 e5                	mov    %esp,%ebp
f0100123:	53                   	push   %ebx
f0100124:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100127:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010012a:	ff 75 0c             	pushl  0xc(%ebp)
f010012d:	ff 75 08             	pushl  0x8(%ebp)
f0100130:	68 07 4c 10 f0       	push   $0xf0104c07
f0100135:	e8 eb 33 00 00       	call   f0103525 <cprintf>
	vcprintf(fmt, ap);
f010013a:	83 c4 08             	add    $0x8,%esp
f010013d:	53                   	push   %ebx
f010013e:	ff 75 10             	pushl  0x10(%ebp)
f0100141:	e8 b9 33 00 00       	call   f01034ff <vcprintf>
	cprintf("\n");
f0100146:	c7 04 24 ca 4b 10 f0 	movl   $0xf0104bca,(%esp)
f010014d:	e8 d3 33 00 00       	call   f0103525 <cprintf>
	va_end(ap);
f0100152:	83 c4 10             	add    $0x10,%esp
}
f0100155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100158:	c9                   	leave  
f0100159:	c3                   	ret    
	...

f010015c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100164:	ec                   	in     (%dx),%al
f0100165:	ec                   	in     (%dx),%al
f0100166:	ec                   	in     (%dx),%al
f0100167:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100168:	c9                   	leave  
f0100169:	c3                   	ret    

f010016a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016a:	55                   	push   %ebp
f010016b:	89 e5                	mov    %esp,%ebp
f010016d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100172:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100173:	a8 01                	test   $0x1,%al
f0100175:	74 08                	je     f010017f <serial_proc_data+0x15>
f0100177:	b2 f8                	mov    $0xf8,%dl
f0100179:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017a:	0f b6 c0             	movzbl %al,%eax
f010017d:	eb 05                	jmp    f0100184 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100184:	c9                   	leave  
f0100185:	c3                   	ret    

f0100186 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100186:	55                   	push   %ebp
f0100187:	89 e5                	mov    %esp,%ebp
f0100189:	53                   	push   %ebx
f010018a:	83 ec 04             	sub    $0x4,%esp
f010018d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010018f:	eb 29                	jmp    f01001ba <cons_intr+0x34>
		if (c == 0)
f0100191:	85 c0                	test   %eax,%eax
f0100193:	74 25                	je     f01001ba <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100195:	8b 15 04 93 1d f0    	mov    0xf01d9304,%edx
f010019b:	88 82 00 91 1d f0    	mov    %al,-0xfe26f00(%edx)
f01001a1:	8d 42 01             	lea    0x1(%edx),%eax
f01001a4:	a3 04 93 1d f0       	mov    %eax,0xf01d9304
		if (cons.wpos == CONSBUFSIZE)
f01001a9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ae:	75 0a                	jne    f01001ba <cons_intr+0x34>
			cons.wpos = 0;
f01001b0:	c7 05 04 93 1d f0 00 	movl   $0x0,0xf01d9304
f01001b7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ba:	ff d3                	call   *%ebx
f01001bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001bf:	75 d0                	jne    f0100191 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001c1:	83 c4 04             	add    $0x4,%esp
f01001c4:	5b                   	pop    %ebx
f01001c5:	c9                   	leave  
f01001c6:	c3                   	ret    

f01001c7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	57                   	push   %edi
f01001cb:	56                   	push   %esi
f01001cc:	53                   	push   %ebx
f01001cd:	83 ec 0c             	sub    $0xc,%esp
f01001d0:	89 c6                	mov    %eax,%esi
f01001d2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d7:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001d8:	a8 20                	test   $0x20,%al
f01001da:	75 19                	jne    f01001f5 <cons_putc+0x2e>
f01001dc:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001e1:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001e6:	e8 71 ff ff ff       	call   f010015c <delay>
f01001eb:	89 fa                	mov    %edi,%edx
f01001ed:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ee:	a8 20                	test   $0x20,%al
f01001f0:	75 03                	jne    f01001f5 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001f2:	4b                   	dec    %ebx
f01001f3:	75 f1                	jne    f01001e6 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001f5:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001fc:	89 f0                	mov    %esi,%eax
f01001fe:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001ff:	b2 79                	mov    $0x79,%dl
f0100201:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100202:	84 c0                	test   %al,%al
f0100204:	78 1d                	js     f0100223 <cons_putc+0x5c>
f0100206:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f010020b:	e8 4c ff ff ff       	call   f010015c <delay>
f0100210:	ba 79 03 00 00       	mov    $0x379,%edx
f0100215:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100216:	84 c0                	test   %al,%al
f0100218:	78 09                	js     f0100223 <cons_putc+0x5c>
f010021a:	43                   	inc    %ebx
f010021b:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100221:	75 e8                	jne    f010020b <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100223:	ba 78 03 00 00       	mov    $0x378,%edx
f0100228:	89 f8                	mov    %edi,%eax
f010022a:	ee                   	out    %al,(%dx)
f010022b:	b2 7a                	mov    $0x7a,%dl
f010022d:	b0 0d                	mov    $0xd,%al
f010022f:	ee                   	out    %al,(%dx)
f0100230:	b0 08                	mov    $0x8,%al
f0100232:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f0100233:	a1 e0 90 1d f0       	mov    0xf01d90e0,%eax
f0100238:	c1 e0 08             	shl    $0x8,%eax
f010023b:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010023d:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100243:	75 06                	jne    f010024b <cons_putc+0x84>
		c |= 0x0700;
f0100245:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010024b:	89 f0                	mov    %esi,%eax
f010024d:	25 ff 00 00 00       	and    $0xff,%eax
f0100252:	83 f8 09             	cmp    $0x9,%eax
f0100255:	74 78                	je     f01002cf <cons_putc+0x108>
f0100257:	83 f8 09             	cmp    $0x9,%eax
f010025a:	7f 0b                	jg     f0100267 <cons_putc+0xa0>
f010025c:	83 f8 08             	cmp    $0x8,%eax
f010025f:	0f 85 9e 00 00 00    	jne    f0100303 <cons_putc+0x13c>
f0100265:	eb 10                	jmp    f0100277 <cons_putc+0xb0>
f0100267:	83 f8 0a             	cmp    $0xa,%eax
f010026a:	74 39                	je     f01002a5 <cons_putc+0xde>
f010026c:	83 f8 0d             	cmp    $0xd,%eax
f010026f:	0f 85 8e 00 00 00    	jne    f0100303 <cons_putc+0x13c>
f0100275:	eb 36                	jmp    f01002ad <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100277:	66 a1 e4 90 1d f0    	mov    0xf01d90e4,%ax
f010027d:	66 85 c0             	test   %ax,%ax
f0100280:	0f 84 e0 00 00 00    	je     f0100366 <cons_putc+0x19f>
			crt_pos--;
f0100286:	48                   	dec    %eax
f0100287:	66 a3 e4 90 1d f0    	mov    %ax,0xf01d90e4
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010028d:	0f b7 c0             	movzwl %ax,%eax
f0100290:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100296:	83 ce 20             	or     $0x20,%esi
f0100299:	8b 15 e8 90 1d f0    	mov    0xf01d90e8,%edx
f010029f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002a3:	eb 78                	jmp    f010031d <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002a5:	66 83 05 e4 90 1d f0 	addw   $0x50,0xf01d90e4
f01002ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002ad:	66 8b 0d e4 90 1d f0 	mov    0xf01d90e4,%cx
f01002b4:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002b9:	89 c8                	mov    %ecx,%eax
f01002bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01002c0:	66 f7 f3             	div    %bx
f01002c3:	66 29 d1             	sub    %dx,%cx
f01002c6:	66 89 0d e4 90 1d f0 	mov    %cx,0xf01d90e4
f01002cd:	eb 4e                	jmp    f010031d <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d4:	e8 ee fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002de:	e8 e4 fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e8:	e8 da fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f2:	e8 d0 fe ff ff       	call   f01001c7 <cons_putc>
		cons_putc(' ');
f01002f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fc:	e8 c6 fe ff ff       	call   f01001c7 <cons_putc>
f0100301:	eb 1a                	jmp    f010031d <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100303:	66 a1 e4 90 1d f0    	mov    0xf01d90e4,%ax
f0100309:	0f b7 c8             	movzwl %ax,%ecx
f010030c:	8b 15 e8 90 1d f0    	mov    0xf01d90e8,%edx
f0100312:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100316:	40                   	inc    %eax
f0100317:	66 a3 e4 90 1d f0    	mov    %ax,0xf01d90e4
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f010031d:	66 81 3d e4 90 1d f0 	cmpw   $0x7cf,0xf01d90e4
f0100324:	cf 07 
f0100326:	76 3e                	jbe    f0100366 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100328:	a1 e8 90 1d f0       	mov    0xf01d90e8,%eax
f010032d:	83 ec 04             	sub    $0x4,%esp
f0100330:	68 00 0f 00 00       	push   $0xf00
f0100335:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010033b:	52                   	push   %edx
f010033c:	50                   	push   %eax
f010033d:	e8 59 44 00 00       	call   f010479b <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100342:	8b 15 e8 90 1d f0    	mov    0xf01d90e8,%edx
f0100348:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010034b:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100350:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100356:	40                   	inc    %eax
f0100357:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010035c:	75 f2                	jne    f0100350 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010035e:	66 83 2d e4 90 1d f0 	subw   $0x50,0xf01d90e4
f0100365:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100366:	8b 0d ec 90 1d f0    	mov    0xf01d90ec,%ecx
f010036c:	b0 0e                	mov    $0xe,%al
f010036e:	89 ca                	mov    %ecx,%edx
f0100370:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100371:	66 8b 35 e4 90 1d f0 	mov    0xf01d90e4,%si
f0100378:	8d 59 01             	lea    0x1(%ecx),%ebx
f010037b:	89 f0                	mov    %esi,%eax
f010037d:	66 c1 e8 08          	shr    $0x8,%ax
f0100381:	89 da                	mov    %ebx,%edx
f0100383:	ee                   	out    %al,(%dx)
f0100384:	b0 0f                	mov    $0xf,%al
f0100386:	89 ca                	mov    %ecx,%edx
f0100388:	ee                   	out    %al,(%dx)
f0100389:	89 f0                	mov    %esi,%eax
f010038b:	89 da                	mov    %ebx,%edx
f010038d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010038e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100391:	5b                   	pop    %ebx
f0100392:	5e                   	pop    %esi
f0100393:	5f                   	pop    %edi
f0100394:	c9                   	leave  
f0100395:	c3                   	ret    

f0100396 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100396:	55                   	push   %ebp
f0100397:	89 e5                	mov    %esp,%ebp
f0100399:	53                   	push   %ebx
f010039a:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039d:	ba 64 00 00 00       	mov    $0x64,%edx
f01003a2:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003a3:	a8 01                	test   $0x1,%al
f01003a5:	0f 84 dc 00 00 00    	je     f0100487 <kbd_proc_data+0xf1>
f01003ab:	b2 60                	mov    $0x60,%dl
f01003ad:	ec                   	in     (%dx),%al
f01003ae:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003b0:	3c e0                	cmp    $0xe0,%al
f01003b2:	75 11                	jne    f01003c5 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003b4:	83 0d 08 93 1d f0 40 	orl    $0x40,0xf01d9308
		return 0;
f01003bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c0:	e9 c7 00 00 00       	jmp    f010048c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003c5:	84 c0                	test   %al,%al
f01003c7:	79 33                	jns    f01003fc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c9:	8b 0d 08 93 1d f0    	mov    0xf01d9308,%ecx
f01003cf:	f6 c1 40             	test   $0x40,%cl
f01003d2:	75 05                	jne    f01003d9 <kbd_proc_data+0x43>
f01003d4:	88 c2                	mov    %al,%dl
f01003d6:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d9:	0f b6 d2             	movzbl %dl,%edx
f01003dc:	8a 82 60 4c 10 f0    	mov    -0xfefb3a0(%edx),%al
f01003e2:	83 c8 40             	or     $0x40,%eax
f01003e5:	0f b6 c0             	movzbl %al,%eax
f01003e8:	f7 d0                	not    %eax
f01003ea:	21 c1                	and    %eax,%ecx
f01003ec:	89 0d 08 93 1d f0    	mov    %ecx,0xf01d9308
		return 0;
f01003f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f7:	e9 90 00 00 00       	jmp    f010048c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003fc:	8b 0d 08 93 1d f0    	mov    0xf01d9308,%ecx
f0100402:	f6 c1 40             	test   $0x40,%cl
f0100405:	74 0e                	je     f0100415 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100407:	88 c2                	mov    %al,%dl
f0100409:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010040c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010040f:	89 0d 08 93 1d f0    	mov    %ecx,0xf01d9308
	}

	shift |= shiftcode[data];
f0100415:	0f b6 d2             	movzbl %dl,%edx
f0100418:	0f b6 82 60 4c 10 f0 	movzbl -0xfefb3a0(%edx),%eax
f010041f:	0b 05 08 93 1d f0    	or     0xf01d9308,%eax
	shift ^= togglecode[data];
f0100425:	0f b6 8a 60 4d 10 f0 	movzbl -0xfefb2a0(%edx),%ecx
f010042c:	31 c8                	xor    %ecx,%eax
f010042e:	a3 08 93 1d f0       	mov    %eax,0xf01d9308

	c = charcode[shift & (CTL | SHIFT)][data];
f0100433:	89 c1                	mov    %eax,%ecx
f0100435:	83 e1 03             	and    $0x3,%ecx
f0100438:	8b 0c 8d 60 4e 10 f0 	mov    -0xfefb1a0(,%ecx,4),%ecx
f010043f:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100443:	a8 08                	test   $0x8,%al
f0100445:	74 18                	je     f010045f <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100447:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010044a:	83 fa 19             	cmp    $0x19,%edx
f010044d:	77 05                	ja     f0100454 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010044f:	83 eb 20             	sub    $0x20,%ebx
f0100452:	eb 0b                	jmp    f010045f <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100454:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100457:	83 fa 19             	cmp    $0x19,%edx
f010045a:	77 03                	ja     f010045f <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010045c:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010045f:	f7 d0                	not    %eax
f0100461:	a8 06                	test   $0x6,%al
f0100463:	75 27                	jne    f010048c <kbd_proc_data+0xf6>
f0100465:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010046b:	75 1f                	jne    f010048c <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f010046d:	83 ec 0c             	sub    $0xc,%esp
f0100470:	68 21 4c 10 f0       	push   $0xf0104c21
f0100475:	e8 ab 30 00 00       	call   f0103525 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047a:	ba 92 00 00 00       	mov    $0x92,%edx
f010047f:	b0 03                	mov    $0x3,%al
f0100481:	ee                   	out    %al,(%dx)
f0100482:	83 c4 10             	add    $0x10,%esp
f0100485:	eb 05                	jmp    f010048c <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100487:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010048c:	89 d8                	mov    %ebx,%eax
f010048e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100491:	c9                   	leave  
f0100492:	c3                   	ret    

f0100493 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100493:	55                   	push   %ebp
f0100494:	89 e5                	mov    %esp,%ebp
f0100496:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100499:	80 3d f0 90 1d f0 00 	cmpb   $0x0,0xf01d90f0
f01004a0:	74 0a                	je     f01004ac <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004a2:	b8 6a 01 10 f0       	mov    $0xf010016a,%eax
f01004a7:	e8 da fc ff ff       	call   f0100186 <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004b4:	b8 96 03 10 f0       	mov    $0xf0100396,%eax
f01004b9:	e8 c8 fc ff ff       	call   f0100186 <cons_intr>
}
f01004be:	c9                   	leave  
f01004bf:	c3                   	ret    

f01004c0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c0:	55                   	push   %ebp
f01004c1:	89 e5                	mov    %esp,%ebp
f01004c3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004c6:	e8 c8 ff ff ff       	call   f0100493 <serial_intr>
	kbd_intr();
f01004cb:	e8 de ff ff ff       	call   f01004ae <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d0:	8b 15 00 93 1d f0    	mov    0xf01d9300,%edx
f01004d6:	3b 15 04 93 1d f0    	cmp    0xf01d9304,%edx
f01004dc:	74 22                	je     f0100500 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004de:	0f b6 82 00 91 1d f0 	movzbl -0xfe26f00(%edx),%eax
f01004e5:	42                   	inc    %edx
f01004e6:	89 15 00 93 1d f0    	mov    %edx,0xf01d9300
		if (cons.rpos == CONSBUFSIZE)
f01004ec:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004f2:	75 11                	jne    f0100505 <cons_getc+0x45>
			cons.rpos = 0;
f01004f4:	c7 05 00 93 1d f0 00 	movl   $0x0,0xf01d9300
f01004fb:	00 00 00 
f01004fe:	eb 05                	jmp    f0100505 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100500:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100505:	c9                   	leave  
f0100506:	c3                   	ret    

f0100507 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100507:	55                   	push   %ebp
f0100508:	89 e5                	mov    %esp,%ebp
f010050a:	57                   	push   %edi
f010050b:	56                   	push   %esi
f010050c:	53                   	push   %ebx
f010050d:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100510:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100517:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010051e:	5a a5 
	if (*cp != 0xA55A) {
f0100520:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100526:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010052a:	74 11                	je     f010053d <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010052c:	c7 05 ec 90 1d f0 b4 	movl   $0x3b4,0xf01d90ec
f0100533:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100536:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010053b:	eb 16                	jmp    f0100553 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010053d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100544:	c7 05 ec 90 1d f0 d4 	movl   $0x3d4,0xf01d90ec
f010054b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010054e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100553:	8b 0d ec 90 1d f0    	mov    0xf01d90ec,%ecx
f0100559:	b0 0e                	mov    $0xe,%al
f010055b:	89 ca                	mov    %ecx,%edx
f010055d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100561:	89 da                	mov    %ebx,%edx
f0100563:	ec                   	in     (%dx),%al
f0100564:	0f b6 f8             	movzbl %al,%edi
f0100567:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056a:	b0 0f                	mov    $0xf,%al
f010056c:	89 ca                	mov    %ecx,%edx
f010056e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056f:	89 da                	mov    %ebx,%edx
f0100571:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100572:	89 35 e8 90 1d f0    	mov    %esi,0xf01d90e8

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100578:	0f b6 d8             	movzbl %al,%ebx
f010057b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057d:	66 89 3d e4 90 1d f0 	mov    %di,0xf01d90e4
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100584:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100589:	b0 00                	mov    $0x0,%al
f010058b:	89 da                	mov    %ebx,%edx
f010058d:	ee                   	out    %al,(%dx)
f010058e:	b2 fb                	mov    $0xfb,%dl
f0100590:	b0 80                	mov    $0x80,%al
f0100592:	ee                   	out    %al,(%dx)
f0100593:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100598:	b0 0c                	mov    $0xc,%al
f010059a:	89 ca                	mov    %ecx,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	b2 f9                	mov    $0xf9,%dl
f010059f:	b0 00                	mov    $0x0,%al
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	b2 fb                	mov    $0xfb,%dl
f01005a4:	b0 03                	mov    $0x3,%al
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	b2 fc                	mov    $0xfc,%dl
f01005a9:	b0 00                	mov    $0x0,%al
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	b2 f9                	mov    $0xf9,%dl
f01005ae:	b0 01                	mov    $0x1,%al
f01005b0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	b2 fd                	mov    $0xfd,%dl
f01005b3:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b4:	3c ff                	cmp    $0xff,%al
f01005b6:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005ba:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005bd:	a2 f0 90 1d f0       	mov    %al,0xf01d90f0
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
f01005c5:	89 ca                	mov    %ecx,%edx
f01005c7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005c8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005cc:	75 10                	jne    f01005de <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005ce:	83 ec 0c             	sub    $0xc,%esp
f01005d1:	68 2d 4c 10 f0       	push   $0xf0104c2d
f01005d6:	e8 4a 2f 00 00       	call   f0103525 <cprintf>
f01005db:	83 c4 10             	add    $0x10,%esp
}
f01005de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005e1:	5b                   	pop    %ebx
f01005e2:	5e                   	pop    %esi
f01005e3:	5f                   	pop    %edi
f01005e4:	c9                   	leave  
f01005e5:	c3                   	ret    

f01005e6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005e6:	55                   	push   %ebp
f01005e7:	89 e5                	mov    %esp,%ebp
f01005e9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01005ef:	e8 d3 fb ff ff       	call   f01001c7 <cons_putc>
}
f01005f4:	c9                   	leave  
f01005f5:	c3                   	ret    

f01005f6 <getchar>:

int
getchar(void)
{
f01005f6:	55                   	push   %ebp
f01005f7:	89 e5                	mov    %esp,%ebp
f01005f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005fc:	e8 bf fe ff ff       	call   f01004c0 <cons_getc>
f0100601:	85 c0                	test   %eax,%eax
f0100603:	74 f7                	je     f01005fc <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100605:	c9                   	leave  
f0100606:	c3                   	ret    

f0100607 <iscons>:

int
iscons(int fdnum)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010060a:	b8 01 00 00 00       	mov    $0x1,%eax
f010060f:	c9                   	leave  
f0100610:	c3                   	ret    
f0100611:	00 00                	add    %al,(%eax)
	...

f0100614 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100614:	55                   	push   %ebp
f0100615:	89 e5                	mov    %esp,%ebp
f0100617:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010061a:	68 70 4e 10 f0       	push   $0xf0104e70
f010061f:	e8 01 2f 00 00       	call   f0103525 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100624:	83 c4 08             	add    $0x8,%esp
f0100627:	68 0c 00 10 00       	push   $0x10000c
f010062c:	68 9c 50 10 f0       	push   $0xf010509c
f0100631:	e8 ef 2e 00 00       	call   f0103525 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100636:	83 c4 0c             	add    $0xc,%esp
f0100639:	68 0c 00 10 00       	push   $0x10000c
f010063e:	68 0c 00 10 f0       	push   $0xf010000c
f0100643:	68 c4 50 10 f0       	push   $0xf01050c4
f0100648:	e8 d8 2e 00 00       	call   f0103525 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010064d:	83 c4 0c             	add    $0xc,%esp
f0100650:	68 a0 4b 10 00       	push   $0x104ba0
f0100655:	68 a0 4b 10 f0       	push   $0xf0104ba0
f010065a:	68 e8 50 10 f0       	push   $0xf01050e8
f010065f:	e8 c1 2e 00 00       	call   f0103525 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100664:	83 c4 0c             	add    $0xc,%esp
f0100667:	68 cc 90 1d 00       	push   $0x1d90cc
f010066c:	68 cc 90 1d f0       	push   $0xf01d90cc
f0100671:	68 0c 51 10 f0       	push   $0xf010510c
f0100676:	e8 aa 2e 00 00       	call   f0103525 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010067b:	83 c4 0c             	add    $0xc,%esp
f010067e:	68 f0 9f 1d 00       	push   $0x1d9ff0
f0100683:	68 f0 9f 1d f0       	push   $0xf01d9ff0
f0100688:	68 30 51 10 f0       	push   $0xf0105130
f010068d:	e8 93 2e 00 00       	call   f0103525 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100692:	b8 ef a3 1d f0       	mov    $0xf01da3ef,%eax
f0100697:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010069c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010069f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a4:	89 c2                	mov    %eax,%edx
f01006a6:	85 c0                	test   %eax,%eax
f01006a8:	79 06                	jns    f01006b0 <mon_kerninfo+0x9c>
f01006aa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006b0:	c1 fa 0a             	sar    $0xa,%edx
f01006b3:	52                   	push   %edx
f01006b4:	68 54 51 10 f0       	push   $0xf0105154
f01006b9:	e8 67 2e 00 00       	call   f0103525 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006be:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c3:	c9                   	leave  
f01006c4:	c3                   	ret    

f01006c5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c5:	55                   	push   %ebp
f01006c6:	89 e5                	mov    %esp,%ebp
f01006c8:	53                   	push   %ebx
f01006c9:	83 ec 04             	sub    $0x4,%esp
f01006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006d1:	83 ec 04             	sub    $0x4,%esp
f01006d4:	ff b3 04 56 10 f0    	pushl  -0xfefa9fc(%ebx)
f01006da:	ff b3 00 56 10 f0    	pushl  -0xfefaa00(%ebx)
f01006e0:	68 89 4e 10 f0       	push   $0xf0104e89
f01006e5:	e8 3b 2e 00 00       	call   f0103525 <cprintf>
f01006ea:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006ed:	83 c4 10             	add    $0x10,%esp
f01006f0:	83 fb 6c             	cmp    $0x6c,%ebx
f01006f3:	75 dc                	jne    f01006d1 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
f0100702:	83 ec 08             	sub    $0x8,%esp
f0100705:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100708:	85 c0                	test   %eax,%eax
f010070a:	75 14                	jne    f0100720 <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f010070c:	83 ec 0c             	sub    $0xc,%esp
f010070f:	68 80 51 10 f0       	push   $0xf0105180
f0100714:	e8 0c 2e 00 00       	call   f0103525 <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f0100719:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010071e:	c9                   	leave  
f010071f:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f0100720:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f0100727:	83 ec 08             	sub    $0x8,%esp
f010072a:	ff 70 28             	pushl  0x28(%eax)
f010072d:	68 92 4e 10 f0       	push   $0xf0104e92
f0100732:	e8 ee 2d 00 00       	call   f0103525 <cprintf>
    env_run(curenv);
f0100737:	83 c4 04             	add    $0x4,%esp
f010073a:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0100740:	e8 1b 2d 00 00       	call   f0103460 <env_run>

f0100745 <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 08             	sub    $0x8,%esp
f010074b:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f010074e:	85 c0                	test   %eax,%eax
f0100750:	75 14                	jne    f0100766 <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f0100752:	83 ec 0c             	sub    $0xc,%esp
f0100755:	68 ac 51 10 f0       	push   $0xf01051ac
f010075a:	e8 c6 2d 00 00       	call   f0103525 <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f010075f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f0100766:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f010076d:	83 ec 0c             	sub    $0xc,%esp
f0100770:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0100776:	e8 e5 2c 00 00       	call   f0103460 <env_run>

f010077b <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010077b:	55                   	push   %ebp
f010077c:	89 e5                	mov    %esp,%ebp
f010077e:	57                   	push   %edi
f010077f:	56                   	push   %esi
f0100780:	53                   	push   %ebx
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100787:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010078b:	74 21                	je     f01007ae <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f010078d:	83 ec 0c             	sub    $0xc,%esp
f0100790:	68 e0 51 10 f0       	push   $0xf01051e0
f0100795:	e8 8b 2d 00 00       	call   f0103525 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f010079a:	c7 04 24 14 52 10 f0 	movl   $0xf0105214,(%esp)
f01007a1:	e8 7f 2d 00 00       	call   f0103525 <cprintf>
f01007a6:	83 c4 10             	add    $0x10,%esp
f01007a9:	e9 1a 01 00 00       	jmp    f01008c8 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01007ae:	83 ec 04             	sub    $0x4,%esp
f01007b1:	6a 00                	push   $0x0
f01007b3:	6a 00                	push   $0x0
f01007b5:	ff 76 04             	pushl  0x4(%esi)
f01007b8:	e8 cd 40 00 00       	call   f010488a <strtol>
f01007bd:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	6a 00                	push   $0x0
f01007c4:	6a 00                	push   $0x0
f01007c6:	ff 76 08             	pushl  0x8(%esi)
f01007c9:	e8 bc 40 00 00       	call   f010488a <strtol>
        if (laddr > haddr) {
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	39 c3                	cmp    %eax,%ebx
f01007d3:	76 01                	jbe    f01007d6 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f01007d5:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f01007d6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01007dc:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01007e2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01007e8:	83 ec 04             	sub    $0x4,%esp
f01007eb:	57                   	push   %edi
f01007ec:	53                   	push   %ebx
f01007ed:	68 9c 4e 10 f0       	push   $0xf0104e9c
f01007f2:	e8 2e 2d 00 00       	call   f0103525 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	39 fb                	cmp    %edi,%ebx
f01007fc:	75 07                	jne    f0100805 <mon_showmappings+0x8a>
f01007fe:	e9 c5 00 00 00       	jmp    f01008c8 <mon_showmappings+0x14d>
f0100803:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100805:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f010080b:	83 ec 04             	sub    $0x4,%esp
f010080e:	56                   	push   %esi
f010080f:	53                   	push   %ebx
f0100810:	68 ad 4e 10 f0       	push   $0xf0104ead
f0100815:	e8 0b 2d 00 00       	call   f0103525 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f010081a:	83 c4 0c             	add    $0xc,%esp
f010081d:	6a 00                	push   $0x0
f010081f:	53                   	push   %ebx
f0100820:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0100826:	e8 6b 0c 00 00       	call   f0101496 <pgdir_walk>
f010082b:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f010082d:	83 c4 10             	add    $0x10,%esp
f0100830:	85 c0                	test   %eax,%eax
f0100832:	74 06                	je     f010083a <mon_showmappings+0xbf>
f0100834:	8b 00                	mov    (%eax),%eax
f0100836:	a8 01                	test   $0x1,%al
f0100838:	75 12                	jne    f010084c <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f010083a:	83 ec 0c             	sub    $0xc,%esp
f010083d:	68 c4 4e 10 f0       	push   $0xf0104ec4
f0100842:	e8 de 2c 00 00       	call   f0103525 <cprintf>
f0100847:	83 c4 10             	add    $0x10,%esp
f010084a:	eb 74                	jmp    f01008c0 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f010084c:	83 ec 08             	sub    $0x8,%esp
f010084f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100854:	50                   	push   %eax
f0100855:	68 d1 4e 10 f0       	push   $0xf0104ed1
f010085a:	e8 c6 2c 00 00       	call   f0103525 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f010085f:	83 c4 10             	add    $0x10,%esp
f0100862:	f6 03 04             	testb  $0x4,(%ebx)
f0100865:	74 12                	je     f0100879 <mon_showmappings+0xfe>
f0100867:	83 ec 0c             	sub    $0xc,%esp
f010086a:	68 d9 4e 10 f0       	push   $0xf0104ed9
f010086f:	e8 b1 2c 00 00       	call   f0103525 <cprintf>
f0100874:	83 c4 10             	add    $0x10,%esp
f0100877:	eb 10                	jmp    f0100889 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100879:	83 ec 0c             	sub    $0xc,%esp
f010087c:	68 e6 4e 10 f0       	push   $0xf0104ee6
f0100881:	e8 9f 2c 00 00       	call   f0103525 <cprintf>
f0100886:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100889:	f6 03 02             	testb  $0x2,(%ebx)
f010088c:	74 12                	je     f01008a0 <mon_showmappings+0x125>
f010088e:	83 ec 0c             	sub    $0xc,%esp
f0100891:	68 f3 4e 10 f0       	push   $0xf0104ef3
f0100896:	e8 8a 2c 00 00       	call   f0103525 <cprintf>
f010089b:	83 c4 10             	add    $0x10,%esp
f010089e:	eb 10                	jmp    f01008b0 <mon_showmappings+0x135>
                else cprintf(" R ");
f01008a0:	83 ec 0c             	sub    $0xc,%esp
f01008a3:	68 f8 4e 10 f0       	push   $0xf0104ef8
f01008a8:	e8 78 2c 00 00       	call   f0103525 <cprintf>
f01008ad:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01008b0:	83 ec 0c             	sub    $0xc,%esp
f01008b3:	68 ca 4b 10 f0       	push   $0xf0104bca
f01008b8:	e8 68 2c 00 00       	call   f0103525 <cprintf>
f01008bd:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01008c0:	39 f7                	cmp    %esi,%edi
f01008c2:	0f 85 3b ff ff ff    	jne    f0100803 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f01008c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d0:	5b                   	pop    %ebx
f01008d1:	5e                   	pop    %esi
f01008d2:	5f                   	pop    %edi
f01008d3:	c9                   	leave  
f01008d4:	c3                   	ret    

f01008d5 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f01008d5:	55                   	push   %ebp
f01008d6:	89 e5                	mov    %esp,%ebp
f01008d8:	57                   	push   %edi
f01008d9:	56                   	push   %esi
f01008da:	53                   	push   %ebx
f01008db:	83 ec 0c             	sub    $0xc,%esp
f01008de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f01008e1:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f01008e5:	74 21                	je     f0100908 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f01008e7:	83 ec 0c             	sub    $0xc,%esp
f01008ea:	68 3c 52 10 f0       	push   $0xf010523c
f01008ef:	e8 31 2c 00 00       	call   f0103525 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008f4:	c7 04 24 8c 52 10 f0 	movl   $0xf010528c,(%esp)
f01008fb:	e8 25 2c 00 00       	call   f0103525 <cprintf>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	e9 a5 01 00 00       	jmp    f0100aad <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100908:	83 ec 04             	sub    $0x4,%esp
f010090b:	6a 00                	push   $0x0
f010090d:	6a 00                	push   $0x0
f010090f:	ff 73 04             	pushl  0x4(%ebx)
f0100912:	e8 73 3f 00 00       	call   f010488a <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100917:	8b 53 08             	mov    0x8(%ebx),%edx
f010091a:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f010091d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100920:	0f 94 c2             	sete   %dl
f0100923:	0f b6 d2             	movzbl %dl,%edx
f0100926:	89 d6                	mov    %edx,%esi
f0100928:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f010092a:	8b 53 0c             	mov    0xc(%ebx),%edx
f010092d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100930:	75 03                	jne    f0100935 <mon_setpermission+0x60>
f0100932:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100935:	8b 53 10             	mov    0x10(%ebx),%edx
f0100938:	80 3a 31             	cmpb   $0x31,(%edx)
f010093b:	75 03                	jne    f0100940 <mon_setpermission+0x6b>
f010093d:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100940:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100946:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f010094c:	83 ec 04             	sub    $0x4,%esp
f010094f:	6a 00                	push   $0x0
f0100951:	57                   	push   %edi
f0100952:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0100958:	e8 39 0b 00 00       	call   f0101496 <pgdir_walk>
f010095d:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f010095f:	83 c4 10             	add    $0x10,%esp
f0100962:	85 c0                	test   %eax,%eax
f0100964:	0f 84 33 01 00 00    	je     f0100a9d <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f010096a:	83 ec 04             	sub    $0x4,%esp
f010096d:	8b 00                	mov    (%eax),%eax
f010096f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100974:	50                   	push   %eax
f0100975:	57                   	push   %edi
f0100976:	68 b0 52 10 f0       	push   $0xf01052b0
f010097b:	e8 a5 2b 00 00       	call   f0103525 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100980:	83 c4 10             	add    $0x10,%esp
f0100983:	f6 03 02             	testb  $0x2,(%ebx)
f0100986:	74 12                	je     f010099a <mon_setpermission+0xc5>
f0100988:	83 ec 0c             	sub    $0xc,%esp
f010098b:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100990:	e8 90 2b 00 00       	call   f0103525 <cprintf>
f0100995:	83 c4 10             	add    $0x10,%esp
f0100998:	eb 10                	jmp    f01009aa <mon_setpermission+0xd5>
f010099a:	83 ec 0c             	sub    $0xc,%esp
f010099d:	68 ff 4e 10 f0       	push   $0xf0104eff
f01009a2:	e8 7e 2b 00 00       	call   f0103525 <cprintf>
f01009a7:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01009aa:	f6 03 04             	testb  $0x4,(%ebx)
f01009ad:	74 12                	je     f01009c1 <mon_setpermission+0xec>
f01009af:	83 ec 0c             	sub    $0xc,%esp
f01009b2:	68 e2 5f 10 f0       	push   $0xf0105fe2
f01009b7:	e8 69 2b 00 00       	call   f0103525 <cprintf>
f01009bc:	83 c4 10             	add    $0x10,%esp
f01009bf:	eb 10                	jmp    f01009d1 <mon_setpermission+0xfc>
f01009c1:	83 ec 0c             	sub    $0xc,%esp
f01009c4:	68 1e 64 10 f0       	push   $0xf010641e
f01009c9:	e8 57 2b 00 00       	call   f0103525 <cprintf>
f01009ce:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009d1:	f6 03 01             	testb  $0x1,(%ebx)
f01009d4:	74 12                	je     f01009e8 <mon_setpermission+0x113>
f01009d6:	83 ec 0c             	sub    $0xc,%esp
f01009d9:	68 56 60 10 f0       	push   $0xf0106056
f01009de:	e8 42 2b 00 00       	call   f0103525 <cprintf>
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	eb 10                	jmp    f01009f8 <mon_setpermission+0x123>
f01009e8:	83 ec 0c             	sub    $0xc,%esp
f01009eb:	68 00 4f 10 f0       	push   $0xf0104f00
f01009f0:	e8 30 2b 00 00       	call   f0103525 <cprintf>
f01009f5:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f01009f8:	83 ec 0c             	sub    $0xc,%esp
f01009fb:	68 02 4f 10 f0       	push   $0xf0104f02
f0100a00:	e8 20 2b 00 00       	call   f0103525 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100a05:	8b 03                	mov    (%ebx),%eax
f0100a07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a0c:	09 c6                	or     %eax,%esi
f0100a0e:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100a10:	83 c4 10             	add    $0x10,%esp
f0100a13:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100a19:	74 12                	je     f0100a2d <mon_setpermission+0x158>
f0100a1b:	83 ec 0c             	sub    $0xc,%esp
f0100a1e:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100a23:	e8 fd 2a 00 00       	call   f0103525 <cprintf>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	eb 10                	jmp    f0100a3d <mon_setpermission+0x168>
f0100a2d:	83 ec 0c             	sub    $0xc,%esp
f0100a30:	68 ff 4e 10 f0       	push   $0xf0104eff
f0100a35:	e8 eb 2a 00 00       	call   f0103525 <cprintf>
f0100a3a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a3d:	f6 03 04             	testb  $0x4,(%ebx)
f0100a40:	74 12                	je     f0100a54 <mon_setpermission+0x17f>
f0100a42:	83 ec 0c             	sub    $0xc,%esp
f0100a45:	68 e2 5f 10 f0       	push   $0xf0105fe2
f0100a4a:	e8 d6 2a 00 00       	call   f0103525 <cprintf>
f0100a4f:	83 c4 10             	add    $0x10,%esp
f0100a52:	eb 10                	jmp    f0100a64 <mon_setpermission+0x18f>
f0100a54:	83 ec 0c             	sub    $0xc,%esp
f0100a57:	68 1e 64 10 f0       	push   $0xf010641e
f0100a5c:	e8 c4 2a 00 00       	call   f0103525 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a64:	f6 03 01             	testb  $0x1,(%ebx)
f0100a67:	74 12                	je     f0100a7b <mon_setpermission+0x1a6>
f0100a69:	83 ec 0c             	sub    $0xc,%esp
f0100a6c:	68 56 60 10 f0       	push   $0xf0106056
f0100a71:	e8 af 2a 00 00       	call   f0103525 <cprintf>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	eb 10                	jmp    f0100a8b <mon_setpermission+0x1b6>
f0100a7b:	83 ec 0c             	sub    $0xc,%esp
f0100a7e:	68 00 4f 10 f0       	push   $0xf0104f00
f0100a83:	e8 9d 2a 00 00       	call   f0103525 <cprintf>
f0100a88:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a8b:	83 ec 0c             	sub    $0xc,%esp
f0100a8e:	68 ca 4b 10 f0       	push   $0xf0104bca
f0100a93:	e8 8d 2a 00 00       	call   f0103525 <cprintf>
f0100a98:	83 c4 10             	add    $0x10,%esp
f0100a9b:	eb 10                	jmp    f0100aad <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100a9d:	83 ec 0c             	sub    $0xc,%esp
f0100aa0:	68 c4 4e 10 f0       	push   $0xf0104ec4
f0100aa5:	e8 7b 2a 00 00       	call   f0103525 <cprintf>
f0100aaa:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100aad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab5:	5b                   	pop    %ebx
f0100ab6:	5e                   	pop    %esi
f0100ab7:	5f                   	pop    %edi
f0100ab8:	c9                   	leave  
f0100ab9:	c3                   	ret    

f0100aba <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100aba:	55                   	push   %ebp
f0100abb:	89 e5                	mov    %esp,%ebp
f0100abd:	56                   	push   %esi
f0100abe:	53                   	push   %ebx
f0100abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100ac2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100ac6:	74 66                	je     f0100b2e <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100ac8:	83 ec 0c             	sub    $0xc,%esp
f0100acb:	68 d4 52 10 f0       	push   $0xf01052d4
f0100ad0:	e8 50 2a 00 00       	call   f0103525 <cprintf>
        cprintf("num show the color attribute. \n");
f0100ad5:	c7 04 24 04 53 10 f0 	movl   $0xf0105304,(%esp)
f0100adc:	e8 44 2a 00 00       	call   f0103525 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ae1:	c7 04 24 24 53 10 f0 	movl   $0xf0105324,(%esp)
f0100ae8:	e8 38 2a 00 00       	call   f0103525 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100aed:	c7 04 24 58 53 10 f0 	movl   $0xf0105358,(%esp)
f0100af4:	e8 2c 2a 00 00       	call   f0103525 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100af9:	c7 04 24 9c 53 10 f0 	movl   $0xf010539c,(%esp)
f0100b00:	e8 20 2a 00 00       	call   f0103525 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100b05:	c7 04 24 13 4f 10 f0 	movl   $0xf0104f13,(%esp)
f0100b0c:	e8 14 2a 00 00       	call   f0103525 <cprintf>
        cprintf("         set the background color to black\n");
f0100b11:	c7 04 24 e0 53 10 f0 	movl   $0xf01053e0,(%esp)
f0100b18:	e8 08 2a 00 00       	call   f0103525 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100b1d:	c7 04 24 0c 54 10 f0 	movl   $0xf010540c,(%esp)
f0100b24:	e8 fc 29 00 00       	call   f0103525 <cprintf>
f0100b29:	83 c4 10             	add    $0x10,%esp
f0100b2c:	eb 52                	jmp    f0100b80 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b2e:	83 ec 0c             	sub    $0xc,%esp
f0100b31:	ff 73 04             	pushl  0x4(%ebx)
f0100b34:	e8 4f 3a 00 00       	call   f0104588 <strlen>
f0100b39:	83 c4 10             	add    $0x10,%esp
f0100b3c:	48                   	dec    %eax
f0100b3d:	78 26                	js     f0100b65 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100b3f:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b42:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b47:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100b4c:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100b50:	0f 94 c3             	sete   %bl
f0100b53:	0f b6 db             	movzbl %bl,%ebx
f0100b56:	d3 e3                	shl    %cl,%ebx
f0100b58:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b5a:	48                   	dec    %eax
f0100b5b:	78 0d                	js     f0100b6a <mon_setcolor+0xb0>
f0100b5d:	41                   	inc    %ecx
f0100b5e:	83 f9 08             	cmp    $0x8,%ecx
f0100b61:	75 e9                	jne    f0100b4c <mon_setcolor+0x92>
f0100b63:	eb 05                	jmp    f0100b6a <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b65:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100b6a:	89 15 e0 90 1d f0    	mov    %edx,0xf01d90e0
        cprintf(" This is color that you want ! \n");
f0100b70:	83 ec 0c             	sub    $0xc,%esp
f0100b73:	68 40 54 10 f0       	push   $0xf0105440
f0100b78:	e8 a8 29 00 00       	call   f0103525 <cprintf>
f0100b7d:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100b80:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b88:	5b                   	pop    %ebx
f0100b89:	5e                   	pop    %esi
f0100b8a:	c9                   	leave  
f0100b8b:	c3                   	ret    

f0100b8c <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100b8c:	55                   	push   %ebp
f0100b8d:	89 e5                	mov    %esp,%ebp
f0100b8f:	57                   	push   %edi
f0100b90:	56                   	push   %esi
f0100b91:	53                   	push   %ebx
f0100b92:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100b95:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100b97:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b99:	85 c0                	test   %eax,%eax
f0100b9b:	74 6d                	je     f0100c0a <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b9d:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100ba0:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100ba3:	ff 76 18             	pushl  0x18(%esi)
f0100ba6:	ff 76 14             	pushl  0x14(%esi)
f0100ba9:	ff 76 10             	pushl  0x10(%esi)
f0100bac:	ff 76 0c             	pushl  0xc(%esi)
f0100baf:	ff 76 08             	pushl  0x8(%esi)
f0100bb2:	53                   	push   %ebx
f0100bb3:	56                   	push   %esi
f0100bb4:	68 64 54 10 f0       	push   $0xf0105464
f0100bb9:	e8 67 29 00 00       	call   f0103525 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100bbe:	83 c4 18             	add    $0x18,%esp
f0100bc1:	57                   	push   %edi
f0100bc2:	ff 76 04             	pushl  0x4(%esi)
f0100bc5:	e8 0f 31 00 00       	call   f0103cd9 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100bca:	83 c4 0c             	add    $0xc,%esp
f0100bcd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100bd0:	ff 75 d0             	pushl  -0x30(%ebp)
f0100bd3:	68 2f 4f 10 f0       	push   $0xf0104f2f
f0100bd8:	e8 48 29 00 00       	call   f0103525 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100bdd:	83 c4 0c             	add    $0xc,%esp
f0100be0:	ff 75 d8             	pushl  -0x28(%ebp)
f0100be3:	ff 75 dc             	pushl  -0x24(%ebp)
f0100be6:	68 3f 4f 10 f0       	push   $0xf0104f3f
f0100beb:	e8 35 29 00 00       	call   f0103525 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100bf0:	83 c4 08             	add    $0x8,%esp
f0100bf3:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100bf6:	53                   	push   %ebx
f0100bf7:	68 44 4f 10 f0       	push   $0xf0104f44
f0100bfc:	e8 24 29 00 00       	call   f0103525 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100c01:	8b 36                	mov    (%esi),%esi
f0100c03:	83 c4 10             	add    $0x10,%esp
f0100c06:	85 f6                	test   %esi,%esi
f0100c08:	75 96                	jne    f0100ba0 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100c0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c12:	5b                   	pop    %ebx
f0100c13:	5e                   	pop    %esi
f0100c14:	5f                   	pop    %edi
f0100c15:	c9                   	leave  
f0100c16:	c3                   	ret    

f0100c17 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100c17:	55                   	push   %ebp
f0100c18:	89 e5                	mov    %esp,%ebp
f0100c1a:	53                   	push   %ebx
f0100c1b:	83 ec 04             	sub    $0x4,%esp
f0100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100c24:	8b 15 ec 9f 1d f0    	mov    0xf01d9fec,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c2a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c30:	77 15                	ja     f0100c47 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c32:	52                   	push   %edx
f0100c33:	68 9c 54 10 f0       	push   $0xf010549c
f0100c38:	68 96 00 00 00       	push   $0x96
f0100c3d:	68 49 4f 10 f0       	push   $0xf0104f49
f0100c42:	e8 82 f4 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c47:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100c4d:	39 d0                	cmp    %edx,%eax
f0100c4f:	72 18                	jb     f0100c69 <pa_con+0x52>
f0100c51:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100c57:	39 d8                	cmp    %ebx,%eax
f0100c59:	73 0e                	jae    f0100c69 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100c5b:	29 d0                	sub    %edx,%eax
f0100c5d:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100c63:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c65:	b0 01                	mov    $0x1,%al
f0100c67:	eb 56                	jmp    f0100cbf <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c69:	ba 00 90 11 f0       	mov    $0xf0119000,%edx
f0100c6e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c74:	77 15                	ja     f0100c8b <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c76:	52                   	push   %edx
f0100c77:	68 9c 54 10 f0       	push   $0xf010549c
f0100c7c:	68 9b 00 00 00       	push   $0x9b
f0100c81:	68 49 4f 10 f0       	push   $0xf0104f49
f0100c86:	e8 3e f4 ff ff       	call   f01000c9 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100c8b:	3d 00 90 11 00       	cmp    $0x119000,%eax
f0100c90:	72 18                	jb     f0100caa <pa_con+0x93>
f0100c92:	3d 00 10 12 00       	cmp    $0x121000,%eax
f0100c97:	73 11                	jae    f0100caa <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100c99:	2d 00 90 11 00       	sub    $0x119000,%eax
f0100c9e:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100ca4:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ca6:	b0 01                	mov    $0x1,%al
f0100ca8:	eb 15                	jmp    f0100cbf <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100caa:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100caf:	77 0c                	ja     f0100cbd <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100cb1:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100cb7:	89 01                	mov    %eax,(%ecx)
        return true;
f0100cb9:	b0 01                	mov    $0x1,%al
f0100cbb:	eb 02                	jmp    f0100cbf <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100cbd:	b0 00                	mov    $0x0,%al
}
f0100cbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cc2:	c9                   	leave  
f0100cc3:	c3                   	ret    

f0100cc4 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100cc4:	55                   	push   %ebp
f0100cc5:	89 e5                	mov    %esp,%ebp
f0100cc7:	57                   	push   %edi
f0100cc8:	56                   	push   %esi
f0100cc9:	53                   	push   %ebx
f0100cca:	83 ec 2c             	sub    $0x2c,%esp
f0100ccd:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100cd0:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100cd4:	74 2d                	je     f0100d03 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100cd6:	83 ec 0c             	sub    $0xc,%esp
f0100cd9:	68 c0 54 10 f0       	push   $0xf01054c0
f0100cde:	e8 42 28 00 00       	call   f0103525 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100ce3:	c7 04 24 f0 54 10 f0 	movl   $0xf01054f0,(%esp)
f0100cea:	e8 36 28 00 00       	call   f0103525 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100cef:	c7 04 24 18 55 10 f0 	movl   $0xf0105518,(%esp)
f0100cf6:	e8 2a 28 00 00       	call   f0103525 <cprintf>
f0100cfb:	83 c4 10             	add    $0x10,%esp
f0100cfe:	e9 59 01 00 00       	jmp    f0100e5c <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100d03:	83 ec 04             	sub    $0x4,%esp
f0100d06:	6a 00                	push   $0x0
f0100d08:	6a 00                	push   $0x0
f0100d0a:	ff 76 08             	pushl  0x8(%esi)
f0100d0d:	e8 78 3b 00 00       	call   f010488a <strtol>
f0100d12:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100d14:	83 c4 0c             	add    $0xc,%esp
f0100d17:	6a 00                	push   $0x0
f0100d19:	6a 00                	push   $0x0
f0100d1b:	ff 76 0c             	pushl  0xc(%esi)
f0100d1e:	e8 67 3b 00 00       	call   f010488a <strtol>
        if (laddr > haddr) {
f0100d23:	83 c4 10             	add    $0x10,%esp
f0100d26:	39 c3                	cmp    %eax,%ebx
f0100d28:	76 01                	jbe    f0100d2b <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100d2a:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100d2b:	89 df                	mov    %ebx,%edi
f0100d2d:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100d30:	83 e0 fc             	and    $0xfffffffc,%eax
f0100d33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100d36:	8b 46 04             	mov    0x4(%esi),%eax
f0100d39:	80 38 76             	cmpb   $0x76,(%eax)
f0100d3c:	74 0e                	je     f0100d4c <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d3e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d41:	0f 85 98 00 00 00    	jne    f0100ddf <mon_dump+0x11b>
f0100d47:	e9 00 01 00 00       	jmp    f0100e4c <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d4c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d4f:	74 7c                	je     f0100dcd <mon_dump+0x109>
f0100d51:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d53:	39 fb                	cmp    %edi,%ebx
f0100d55:	74 15                	je     f0100d6c <mon_dump+0xa8>
f0100d57:	f6 c3 0f             	test   $0xf,%bl
f0100d5a:	75 21                	jne    f0100d7d <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100d5c:	83 ec 0c             	sub    $0xc,%esp
f0100d5f:	68 ca 4b 10 f0       	push   $0xf0104bca
f0100d64:	e8 bc 27 00 00       	call   f0103525 <cprintf>
f0100d69:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d6c:	83 ec 08             	sub    $0x8,%esp
f0100d6f:	53                   	push   %ebx
f0100d70:	68 58 4f 10 f0       	push   $0xf0104f58
f0100d75:	e8 ab 27 00 00       	call   f0103525 <cprintf>
f0100d7a:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d7d:	83 ec 04             	sub    $0x4,%esp
f0100d80:	6a 00                	push   $0x0
f0100d82:	89 d8                	mov    %ebx,%eax
f0100d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d89:	50                   	push   %eax
f0100d8a:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0100d90:	e8 01 07 00 00       	call   f0101496 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d95:	83 c4 10             	add    $0x10,%esp
f0100d98:	85 c0                	test   %eax,%eax
f0100d9a:	74 19                	je     f0100db5 <mon_dump+0xf1>
f0100d9c:	f6 00 01             	testb  $0x1,(%eax)
f0100d9f:	74 14                	je     f0100db5 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100da1:	83 ec 08             	sub    $0x8,%esp
f0100da4:	ff 33                	pushl  (%ebx)
f0100da6:	68 62 4f 10 f0       	push   $0xf0104f62
f0100dab:	e8 75 27 00 00       	call   f0103525 <cprintf>
f0100db0:	83 c4 10             	add    $0x10,%esp
f0100db3:	eb 10                	jmp    f0100dc5 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100db5:	83 ec 0c             	sub    $0xc,%esp
f0100db8:	68 6d 4f 10 f0       	push   $0xf0104f6d
f0100dbd:	e8 63 27 00 00       	call   f0103525 <cprintf>
f0100dc2:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100dc5:	83 c3 04             	add    $0x4,%ebx
f0100dc8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100dcb:	75 86                	jne    f0100d53 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100dcd:	83 ec 0c             	sub    $0xc,%esp
f0100dd0:	68 ca 4b 10 f0       	push   $0xf0104bca
f0100dd5:	e8 4b 27 00 00       	call   f0103525 <cprintf>
f0100dda:	83 c4 10             	add    $0x10,%esp
f0100ddd:	eb 7d                	jmp    f0100e5c <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100ddf:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100de1:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100de4:	39 fb                	cmp    %edi,%ebx
f0100de6:	74 15                	je     f0100dfd <mon_dump+0x139>
f0100de8:	f6 c3 0f             	test   $0xf,%bl
f0100deb:	75 21                	jne    f0100e0e <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100ded:	83 ec 0c             	sub    $0xc,%esp
f0100df0:	68 ca 4b 10 f0       	push   $0xf0104bca
f0100df5:	e8 2b 27 00 00       	call   f0103525 <cprintf>
f0100dfa:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100dfd:	83 ec 08             	sub    $0x8,%esp
f0100e00:	53                   	push   %ebx
f0100e01:	68 58 4f 10 f0       	push   $0xf0104f58
f0100e06:	e8 1a 27 00 00       	call   f0103525 <cprintf>
f0100e0b:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100e0e:	83 ec 08             	sub    $0x8,%esp
f0100e11:	56                   	push   %esi
f0100e12:	53                   	push   %ebx
f0100e13:	e8 ff fd ff ff       	call   f0100c17 <pa_con>
f0100e18:	83 c4 10             	add    $0x10,%esp
f0100e1b:	84 c0                	test   %al,%al
f0100e1d:	74 15                	je     f0100e34 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100e1f:	83 ec 08             	sub    $0x8,%esp
f0100e22:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e25:	68 62 4f 10 f0       	push   $0xf0104f62
f0100e2a:	e8 f6 26 00 00       	call   f0103525 <cprintf>
f0100e2f:	83 c4 10             	add    $0x10,%esp
f0100e32:	eb 10                	jmp    f0100e44 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100e34:	83 ec 0c             	sub    $0xc,%esp
f0100e37:	68 6b 4f 10 f0       	push   $0xf0104f6b
f0100e3c:	e8 e4 26 00 00       	call   f0103525 <cprintf>
f0100e41:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e44:	83 c3 04             	add    $0x4,%ebx
f0100e47:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100e4a:	75 98                	jne    f0100de4 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100e4c:	83 ec 0c             	sub    $0xc,%esp
f0100e4f:	68 ca 4b 10 f0       	push   $0xf0104bca
f0100e54:	e8 cc 26 00 00       	call   f0103525 <cprintf>
f0100e59:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100e5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e64:	5b                   	pop    %ebx
f0100e65:	5e                   	pop    %esi
f0100e66:	5f                   	pop    %edi
f0100e67:	c9                   	leave  
f0100e68:	c3                   	ret    

f0100e69 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e69:	55                   	push   %ebp
f0100e6a:	89 e5                	mov    %esp,%ebp
f0100e6c:	57                   	push   %edi
f0100e6d:	56                   	push   %esi
f0100e6e:	53                   	push   %ebx
f0100e6f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e72:	68 5c 55 10 f0       	push   $0xf010555c
f0100e77:	e8 a9 26 00 00       	call   f0103525 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e7c:	c7 04 24 80 55 10 f0 	movl   $0xf0105580,(%esp)
f0100e83:	e8 9d 26 00 00       	call   f0103525 <cprintf>

	if (tf != NULL)
f0100e88:	83 c4 10             	add    $0x10,%esp
f0100e8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e8f:	74 0e                	je     f0100e9f <monitor+0x36>
		print_trapframe(tf);
f0100e91:	83 ec 0c             	sub    $0xc,%esp
f0100e94:	ff 75 08             	pushl  0x8(%ebp)
f0100e97:	e8 3c 28 00 00       	call   f01036d8 <print_trapframe>
f0100e9c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e9f:	83 ec 0c             	sub    $0xc,%esp
f0100ea2:	68 78 4f 10 f0       	push   $0xf0104f78
f0100ea7:	e8 0c 36 00 00       	call   f01044b8 <readline>
f0100eac:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100eae:	83 c4 10             	add    $0x10,%esp
f0100eb1:	85 c0                	test   %eax,%eax
f0100eb3:	74 ea                	je     f0100e9f <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100eb5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ebc:	be 00 00 00 00       	mov    $0x0,%esi
f0100ec1:	eb 04                	jmp    f0100ec7 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ec3:	c6 03 00             	movb   $0x0,(%ebx)
f0100ec6:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ec7:	8a 03                	mov    (%ebx),%al
f0100ec9:	84 c0                	test   %al,%al
f0100ecb:	74 64                	je     f0100f31 <monitor+0xc8>
f0100ecd:	83 ec 08             	sub    $0x8,%esp
f0100ed0:	0f be c0             	movsbl %al,%eax
f0100ed3:	50                   	push   %eax
f0100ed4:	68 7c 4f 10 f0       	push   $0xf0104f7c
f0100ed9:	e8 23 38 00 00       	call   f0104701 <strchr>
f0100ede:	83 c4 10             	add    $0x10,%esp
f0100ee1:	85 c0                	test   %eax,%eax
f0100ee3:	75 de                	jne    f0100ec3 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100ee5:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ee8:	74 47                	je     f0100f31 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100eea:	83 fe 0f             	cmp    $0xf,%esi
f0100eed:	75 14                	jne    f0100f03 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100eef:	83 ec 08             	sub    $0x8,%esp
f0100ef2:	6a 10                	push   $0x10
f0100ef4:	68 81 4f 10 f0       	push   $0xf0104f81
f0100ef9:	e8 27 26 00 00       	call   f0103525 <cprintf>
f0100efe:	83 c4 10             	add    $0x10,%esp
f0100f01:	eb 9c                	jmp    f0100e9f <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100f03:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f07:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f08:	8a 03                	mov    (%ebx),%al
f0100f0a:	84 c0                	test   %al,%al
f0100f0c:	75 09                	jne    f0100f17 <monitor+0xae>
f0100f0e:	eb b7                	jmp    f0100ec7 <monitor+0x5e>
			buf++;
f0100f10:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f11:	8a 03                	mov    (%ebx),%al
f0100f13:	84 c0                	test   %al,%al
f0100f15:	74 b0                	je     f0100ec7 <monitor+0x5e>
f0100f17:	83 ec 08             	sub    $0x8,%esp
f0100f1a:	0f be c0             	movsbl %al,%eax
f0100f1d:	50                   	push   %eax
f0100f1e:	68 7c 4f 10 f0       	push   $0xf0104f7c
f0100f23:	e8 d9 37 00 00       	call   f0104701 <strchr>
f0100f28:	83 c4 10             	add    $0x10,%esp
f0100f2b:	85 c0                	test   %eax,%eax
f0100f2d:	74 e1                	je     f0100f10 <monitor+0xa7>
f0100f2f:	eb 96                	jmp    f0100ec7 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100f31:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f38:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f39:	85 f6                	test   %esi,%esi
f0100f3b:	0f 84 5e ff ff ff    	je     f0100e9f <monitor+0x36>
f0100f41:	bb 00 56 10 f0       	mov    $0xf0105600,%ebx
f0100f46:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f4b:	83 ec 08             	sub    $0x8,%esp
f0100f4e:	ff 33                	pushl  (%ebx)
f0100f50:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f53:	e8 3b 37 00 00       	call   f0104693 <strcmp>
f0100f58:	83 c4 10             	add    $0x10,%esp
f0100f5b:	85 c0                	test   %eax,%eax
f0100f5d:	75 20                	jne    f0100f7f <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100f5f:	83 ec 04             	sub    $0x4,%esp
f0100f62:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100f65:	ff 75 08             	pushl  0x8(%ebp)
f0100f68:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f6b:	50                   	push   %eax
f0100f6c:	56                   	push   %esi
f0100f6d:	ff 97 08 56 10 f0    	call   *-0xfefa9f8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f73:	83 c4 10             	add    $0x10,%esp
f0100f76:	85 c0                	test   %eax,%eax
f0100f78:	78 26                	js     f0100fa0 <monitor+0x137>
f0100f7a:	e9 20 ff ff ff       	jmp    f0100e9f <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f7f:	47                   	inc    %edi
f0100f80:	83 c3 0c             	add    $0xc,%ebx
f0100f83:	83 ff 09             	cmp    $0x9,%edi
f0100f86:	75 c3                	jne    f0100f4b <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f88:	83 ec 08             	sub    $0x8,%esp
f0100f8b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f8e:	68 9e 4f 10 f0       	push   $0xf0104f9e
f0100f93:	e8 8d 25 00 00       	call   f0103525 <cprintf>
f0100f98:	83 c4 10             	add    $0x10,%esp
f0100f9b:	e9 ff fe ff ff       	jmp    f0100e9f <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fa3:	5b                   	pop    %ebx
f0100fa4:	5e                   	pop    %esi
f0100fa5:	5f                   	pop    %edi
f0100fa6:	c9                   	leave  
f0100fa7:	c3                   	ret    

f0100fa8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100fa8:	55                   	push   %ebp
f0100fa9:	89 e5                	mov    %esp,%ebp
f0100fab:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100fad:	83 3d 14 93 1d f0 00 	cmpl   $0x0,0xf01d9314
f0100fb4:	75 0f                	jne    f0100fc5 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fb6:	b8 ef af 1d f0       	mov    $0xf01dafef,%eax
f0100fbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fc0:	a3 14 93 1d f0       	mov    %eax,0xf01d9314
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100fc5:	a1 14 93 1d f0       	mov    0xf01d9314,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100fca:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100fd1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fd7:	89 15 14 93 1d f0    	mov    %edx,0xf01d9314

	return result;
}
f0100fdd:	c9                   	leave  
f0100fde:	c3                   	ret    

f0100fdf <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fe5:	89 d1                	mov    %edx,%ecx
f0100fe7:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fea:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fed:	a8 01                	test   $0x1,%al
f0100fef:	74 42                	je     f0101033 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff6:	89 c1                	mov    %eax,%ecx
f0100ff8:	c1 e9 0c             	shr    $0xc,%ecx
f0100ffb:	3b 0d e4 9f 1d f0    	cmp    0xf01d9fe4,%ecx
f0101001:	72 15                	jb     f0101018 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101003:	50                   	push   %eax
f0101004:	68 6c 56 10 f0       	push   $0xf010566c
f0101009:	68 1a 03 00 00       	push   $0x31a
f010100e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101013:	e8 b1 f0 ff ff       	call   f01000c9 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101018:	c1 ea 0c             	shr    $0xc,%edx
f010101b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101021:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101028:	a8 01                	test   $0x1,%al
f010102a:	74 0e                	je     f010103a <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010102c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101031:	eb 0c                	jmp    f010103f <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0101033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101038:	eb 05                	jmp    f010103f <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010103a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010103f:	c9                   	leave  
f0101040:	c3                   	ret    

f0101041 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101041:	55                   	push   %ebp
f0101042:	89 e5                	mov    %esp,%ebp
f0101044:	56                   	push   %esi
f0101045:	53                   	push   %ebx
f0101046:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101048:	83 ec 0c             	sub    $0xc,%esp
f010104b:	50                   	push   %eax
f010104c:	e8 73 24 00 00       	call   f01034c4 <mc146818_read>
f0101051:	89 c6                	mov    %eax,%esi
f0101053:	43                   	inc    %ebx
f0101054:	89 1c 24             	mov    %ebx,(%esp)
f0101057:	e8 68 24 00 00       	call   f01034c4 <mc146818_read>
f010105c:	c1 e0 08             	shl    $0x8,%eax
f010105f:	09 f0                	or     %esi,%eax
}
f0101061:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101064:	5b                   	pop    %ebx
f0101065:	5e                   	pop    %esi
f0101066:	c9                   	leave  
f0101067:	c3                   	ret    

f0101068 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101068:	55                   	push   %ebp
f0101069:	89 e5                	mov    %esp,%ebp
f010106b:	57                   	push   %edi
f010106c:	56                   	push   %esi
f010106d:	53                   	push   %ebx
f010106e:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101071:	3c 01                	cmp    $0x1,%al
f0101073:	19 f6                	sbb    %esi,%esi
f0101075:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010107b:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010107c:	8b 1d 10 93 1d f0    	mov    0xf01d9310,%ebx
f0101082:	85 db                	test   %ebx,%ebx
f0101084:	75 17                	jne    f010109d <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101086:	83 ec 04             	sub    $0x4,%esp
f0101089:	68 90 56 10 f0       	push   $0xf0105690
f010108e:	68 58 02 00 00       	push   $0x258
f0101093:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101098:	e8 2c f0 ff ff       	call   f01000c9 <_panic>

	if (only_low_memory) {
f010109d:	84 c0                	test   %al,%al
f010109f:	74 50                	je     f01010f1 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01010aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010ad:	89 d8                	mov    %ebx,%eax
f01010af:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f01010b5:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01010b8:	c1 e8 16             	shr    $0x16,%eax
f01010bb:	39 c6                	cmp    %eax,%esi
f01010bd:	0f 96 c0             	setbe  %al
f01010c0:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01010c3:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01010c7:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01010c9:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010cd:	8b 1b                	mov    (%ebx),%ebx
f01010cf:	85 db                	test   %ebx,%ebx
f01010d1:	75 da                	jne    f01010ad <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01010d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010e2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010e7:	89 1d 10 93 1d f0    	mov    %ebx,0xf01d9310
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010ed:	85 db                	test   %ebx,%ebx
f01010ef:	74 57                	je     f0101148 <check_page_free_list+0xe0>
f01010f1:	89 d8                	mov    %ebx,%eax
f01010f3:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f01010f9:	c1 f8 03             	sar    $0x3,%eax
f01010fc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010ff:	89 c2                	mov    %eax,%edx
f0101101:	c1 ea 16             	shr    $0x16,%edx
f0101104:	39 d6                	cmp    %edx,%esi
f0101106:	76 3a                	jbe    f0101142 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101108:	89 c2                	mov    %eax,%edx
f010110a:	c1 ea 0c             	shr    $0xc,%edx
f010110d:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0101113:	72 12                	jb     f0101127 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101115:	50                   	push   %eax
f0101116:	68 6c 56 10 f0       	push   $0xf010566c
f010111b:	6a 56                	push   $0x56
f010111d:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101122:	e8 a2 ef ff ff       	call   f01000c9 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101127:	83 ec 04             	sub    $0x4,%esp
f010112a:	68 80 00 00 00       	push   $0x80
f010112f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101134:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101139:	50                   	push   %eax
f010113a:	e8 12 36 00 00       	call   f0104751 <memset>
f010113f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101142:	8b 1b                	mov    (%ebx),%ebx
f0101144:	85 db                	test   %ebx,%ebx
f0101146:	75 a9                	jne    f01010f1 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101148:	b8 00 00 00 00       	mov    $0x0,%eax
f010114d:	e8 56 fe ff ff       	call   f0100fa8 <boot_alloc>
f0101152:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101155:	8b 15 10 93 1d f0    	mov    0xf01d9310,%edx
f010115b:	85 d2                	test   %edx,%edx
f010115d:	0f 84 80 01 00 00    	je     f01012e3 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101163:	8b 1d ec 9f 1d f0    	mov    0xf01d9fec,%ebx
f0101169:	39 da                	cmp    %ebx,%edx
f010116b:	72 43                	jb     f01011b0 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f010116d:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f0101172:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101175:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101178:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010117b:	39 c2                	cmp    %eax,%edx
f010117d:	73 4f                	jae    f01011ce <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010117f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101182:	89 d0                	mov    %edx,%eax
f0101184:	29 d8                	sub    %ebx,%eax
f0101186:	a8 07                	test   $0x7,%al
f0101188:	75 66                	jne    f01011f0 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010118a:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010118d:	c1 e0 0c             	shl    $0xc,%eax
f0101190:	74 7f                	je     f0101211 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f0101192:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101197:	0f 84 94 00 00 00    	je     f0101231 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010119d:	be 00 00 00 00       	mov    $0x0,%esi
f01011a2:	bf 00 00 00 00       	mov    $0x0,%edi
f01011a7:	e9 9e 00 00 00       	jmp    f010124a <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011ac:	39 da                	cmp    %ebx,%edx
f01011ae:	73 19                	jae    f01011c9 <check_page_free_list+0x161>
f01011b0:	68 e7 5d 10 f0       	push   $0xf0105de7
f01011b5:	68 f3 5d 10 f0       	push   $0xf0105df3
f01011ba:	68 72 02 00 00       	push   $0x272
f01011bf:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01011c4:	e8 00 ef ff ff       	call   f01000c9 <_panic>
		assert(pp < pages + npages);
f01011c9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01011cc:	72 19                	jb     f01011e7 <check_page_free_list+0x17f>
f01011ce:	68 08 5e 10 f0       	push   $0xf0105e08
f01011d3:	68 f3 5d 10 f0       	push   $0xf0105df3
f01011d8:	68 73 02 00 00       	push   $0x273
f01011dd:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01011e2:	e8 e2 ee ff ff       	call   f01000c9 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011e7:	89 d0                	mov    %edx,%eax
f01011e9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011ec:	a8 07                	test   $0x7,%al
f01011ee:	74 19                	je     f0101209 <check_page_free_list+0x1a1>
f01011f0:	68 b4 56 10 f0       	push   $0xf01056b4
f01011f5:	68 f3 5d 10 f0       	push   $0xf0105df3
f01011fa:	68 74 02 00 00       	push   $0x274
f01011ff:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101204:	e8 c0 ee ff ff       	call   f01000c9 <_panic>
f0101209:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010120c:	c1 e0 0c             	shl    $0xc,%eax
f010120f:	75 19                	jne    f010122a <check_page_free_list+0x1c2>
f0101211:	68 1c 5e 10 f0       	push   $0xf0105e1c
f0101216:	68 f3 5d 10 f0       	push   $0xf0105df3
f010121b:	68 77 02 00 00       	push   $0x277
f0101220:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101225:	e8 9f ee ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010122a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010122f:	75 19                	jne    f010124a <check_page_free_list+0x1e2>
f0101231:	68 2d 5e 10 f0       	push   $0xf0105e2d
f0101236:	68 f3 5d 10 f0       	push   $0xf0105df3
f010123b:	68 78 02 00 00       	push   $0x278
f0101240:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101245:	e8 7f ee ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010124a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010124f:	75 19                	jne    f010126a <check_page_free_list+0x202>
f0101251:	68 e8 56 10 f0       	push   $0xf01056e8
f0101256:	68 f3 5d 10 f0       	push   $0xf0105df3
f010125b:	68 79 02 00 00       	push   $0x279
f0101260:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101265:	e8 5f ee ff ff       	call   f01000c9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010126a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010126f:	75 19                	jne    f010128a <check_page_free_list+0x222>
f0101271:	68 46 5e 10 f0       	push   $0xf0105e46
f0101276:	68 f3 5d 10 f0       	push   $0xf0105df3
f010127b:	68 7a 02 00 00       	push   $0x27a
f0101280:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101285:	e8 3f ee ff ff       	call   f01000c9 <_panic>
f010128a:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010128c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101291:	76 3e                	jbe    f01012d1 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101293:	c1 e8 0c             	shr    $0xc,%eax
f0101296:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101299:	77 12                	ja     f01012ad <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010129b:	51                   	push   %ecx
f010129c:	68 6c 56 10 f0       	push   $0xf010566c
f01012a1:	6a 56                	push   $0x56
f01012a3:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01012a8:	e8 1c ee ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f01012ad:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01012b3:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01012b6:	76 1c                	jbe    f01012d4 <check_page_free_list+0x26c>
f01012b8:	68 0c 57 10 f0       	push   $0xf010570c
f01012bd:	68 f3 5d 10 f0       	push   $0xf0105df3
f01012c2:	68 7b 02 00 00       	push   $0x27b
f01012c7:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01012cc:	e8 f8 ed ff ff       	call   f01000c9 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01012d1:	47                   	inc    %edi
f01012d2:	eb 01                	jmp    f01012d5 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f01012d4:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012d5:	8b 12                	mov    (%edx),%edx
f01012d7:	85 d2                	test   %edx,%edx
f01012d9:	0f 85 cd fe ff ff    	jne    f01011ac <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01012df:	85 ff                	test   %edi,%edi
f01012e1:	7f 19                	jg     f01012fc <check_page_free_list+0x294>
f01012e3:	68 60 5e 10 f0       	push   $0xf0105e60
f01012e8:	68 f3 5d 10 f0       	push   $0xf0105df3
f01012ed:	68 83 02 00 00       	push   $0x283
f01012f2:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01012f7:	e8 cd ed ff ff       	call   f01000c9 <_panic>
	assert(nfree_extmem > 0);
f01012fc:	85 f6                	test   %esi,%esi
f01012fe:	7f 19                	jg     f0101319 <check_page_free_list+0x2b1>
f0101300:	68 72 5e 10 f0       	push   $0xf0105e72
f0101305:	68 f3 5d 10 f0       	push   $0xf0105df3
f010130a:	68 84 02 00 00       	push   $0x284
f010130f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101314:	e8 b0 ed ff ff       	call   f01000c9 <_panic>
}
f0101319:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010131c:	5b                   	pop    %ebx
f010131d:	5e                   	pop    %esi
f010131e:	5f                   	pop    %edi
f010131f:	c9                   	leave  
f0101320:	c3                   	ret    

f0101321 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	56                   	push   %esi
f0101325:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101326:	c7 05 10 93 1d f0 00 	movl   $0x0,0xf01d9310
f010132d:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101330:	b8 00 00 00 00       	mov    $0x0,%eax
f0101335:	e8 6e fc ff ff       	call   f0100fa8 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010133a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010133f:	77 15                	ja     f0101356 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101341:	50                   	push   %eax
f0101342:	68 9c 54 10 f0       	push   $0xf010549c
f0101347:	68 24 01 00 00       	push   $0x124
f010134c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101351:	e8 73 ed ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101356:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f010135c:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f010135f:	83 3d e4 9f 1d f0 00 	cmpl   $0x0,0xf01d9fe4
f0101366:	74 5f                	je     f01013c7 <page_init+0xa6>
f0101368:	8b 1d 10 93 1d f0    	mov    0xf01d9310,%ebx
f010136e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101373:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101378:	85 c0                	test   %eax,%eax
f010137a:	74 25                	je     f01013a1 <page_init+0x80>
f010137c:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101381:	76 04                	jbe    f0101387 <page_init+0x66>
f0101383:	39 c6                	cmp    %eax,%esi
f0101385:	77 1a                	ja     f01013a1 <page_init+0x80>
		    pages[i].pp_ref = 0;
f0101387:	89 d1                	mov    %edx,%ecx
f0101389:	03 0d ec 9f 1d f0    	add    0xf01d9fec,%ecx
f010138f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101395:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0101397:	89 d3                	mov    %edx,%ebx
f0101399:	03 1d ec 9f 1d f0    	add    0xf01d9fec,%ebx
f010139f:	eb 14                	jmp    f01013b5 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f01013a1:	89 d1                	mov    %edx,%ecx
f01013a3:	03 0d ec 9f 1d f0    	add    0xf01d9fec,%ecx
f01013a9:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01013af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f01013b5:	40                   	inc    %eax
f01013b6:	83 c2 08             	add    $0x8,%edx
f01013b9:	39 05 e4 9f 1d f0    	cmp    %eax,0xf01d9fe4
f01013bf:	77 b7                	ja     f0101378 <page_init+0x57>
f01013c1:	89 1d 10 93 1d f0    	mov    %ebx,0xf01d9310
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01013c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013ca:	5b                   	pop    %ebx
f01013cb:	5e                   	pop    %esi
f01013cc:	c9                   	leave  
f01013cd:	c3                   	ret    

f01013ce <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013ce:	55                   	push   %ebp
f01013cf:	89 e5                	mov    %esp,%ebp
f01013d1:	53                   	push   %ebx
f01013d2:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013d5:	8b 1d 10 93 1d f0    	mov    0xf01d9310,%ebx
f01013db:	85 db                	test   %ebx,%ebx
f01013dd:	74 63                	je     f0101442 <page_alloc+0x74>
f01013df:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013e4:	74 63                	je     f0101449 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01013e6:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013e8:	85 db                	test   %ebx,%ebx
f01013ea:	75 08                	jne    f01013f4 <page_alloc+0x26>
f01013ec:	89 1d 10 93 1d f0    	mov    %ebx,0xf01d9310
f01013f2:	eb 4e                	jmp    f0101442 <page_alloc+0x74>
f01013f4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013f9:	75 eb                	jne    f01013e6 <page_alloc+0x18>
f01013fb:	eb 4c                	jmp    f0101449 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013fd:	89 d8                	mov    %ebx,%eax
f01013ff:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f0101405:	c1 f8 03             	sar    $0x3,%eax
f0101408:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010140b:	89 c2                	mov    %eax,%edx
f010140d:	c1 ea 0c             	shr    $0xc,%edx
f0101410:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0101416:	72 12                	jb     f010142a <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101418:	50                   	push   %eax
f0101419:	68 6c 56 10 f0       	push   $0xf010566c
f010141e:	6a 56                	push   $0x56
f0101420:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101425:	e8 9f ec ff ff       	call   f01000c9 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f010142a:	83 ec 04             	sub    $0x4,%esp
f010142d:	68 00 10 00 00       	push   $0x1000
f0101432:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101434:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101439:	50                   	push   %eax
f010143a:	e8 12 33 00 00       	call   f0104751 <memset>
f010143f:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101442:	89 d8                	mov    %ebx,%eax
f0101444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101447:	c9                   	leave  
f0101448:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101449:	8b 03                	mov    (%ebx),%eax
f010144b:	a3 10 93 1d f0       	mov    %eax,0xf01d9310
        if (alloc_flags & ALLOC_ZERO) {
f0101450:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101454:	74 ec                	je     f0101442 <page_alloc+0x74>
f0101456:	eb a5                	jmp    f01013fd <page_alloc+0x2f>

f0101458 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101458:	55                   	push   %ebp
f0101459:	89 e5                	mov    %esp,%ebp
f010145b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f010145e:	85 c0                	test   %eax,%eax
f0101460:	74 14                	je     f0101476 <page_free+0x1e>
f0101462:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101467:	75 0d                	jne    f0101476 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101469:	8b 15 10 93 1d f0    	mov    0xf01d9310,%edx
f010146f:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101471:	a3 10 93 1d f0       	mov    %eax,0xf01d9310
}
f0101476:	c9                   	leave  
f0101477:	c3                   	ret    

f0101478 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101478:	55                   	push   %ebp
f0101479:	89 e5                	mov    %esp,%ebp
f010147b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010147e:	8b 50 04             	mov    0x4(%eax),%edx
f0101481:	4a                   	dec    %edx
f0101482:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101486:	66 85 d2             	test   %dx,%dx
f0101489:	75 09                	jne    f0101494 <page_decref+0x1c>
		page_free(pp);
f010148b:	50                   	push   %eax
f010148c:	e8 c7 ff ff ff       	call   f0101458 <page_free>
f0101491:	83 c4 04             	add    $0x4,%esp
}
f0101494:	c9                   	leave  
f0101495:	c3                   	ret    

f0101496 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101496:	55                   	push   %ebp
f0101497:	89 e5                	mov    %esp,%ebp
f0101499:	56                   	push   %esi
f010149a:	53                   	push   %ebx
f010149b:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f010149e:	89 f3                	mov    %esi,%ebx
f01014a0:	c1 eb 16             	shr    $0x16,%ebx
f01014a3:	c1 e3 02             	shl    $0x2,%ebx
f01014a6:	03 5d 08             	add    0x8(%ebp),%ebx
f01014a9:	8b 03                	mov    (%ebx),%eax
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	74 04                	je     f01014b3 <pgdir_walk+0x1d>
f01014af:	a8 01                	test   $0x1,%al
f01014b1:	75 2c                	jne    f01014df <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01014b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014b7:	74 61                	je     f010151a <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01014b9:	83 ec 0c             	sub    $0xc,%esp
f01014bc:	6a 01                	push   $0x1
f01014be:	e8 0b ff ff ff       	call   f01013ce <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01014c3:	83 c4 10             	add    $0x10,%esp
f01014c6:	85 c0                	test   %eax,%eax
f01014c8:	74 57                	je     f0101521 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01014ca:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014ce:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f01014d4:	c1 f8 03             	sar    $0x3,%eax
f01014d7:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01014da:	83 c8 07             	or     $0x7,%eax
f01014dd:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01014df:	8b 03                	mov    (%ebx),%eax
f01014e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014e6:	89 c2                	mov    %eax,%edx
f01014e8:	c1 ea 0c             	shr    $0xc,%edx
f01014eb:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f01014f1:	72 15                	jb     f0101508 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014f3:	50                   	push   %eax
f01014f4:	68 6c 56 10 f0       	push   $0xf010566c
f01014f9:	68 87 01 00 00       	push   $0x187
f01014fe:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101503:	e8 c1 eb ff ff       	call   f01000c9 <_panic>
f0101508:	c1 ee 0a             	shr    $0xa,%esi
f010150b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101511:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101518:	eb 0c                	jmp    f0101526 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010151a:	b8 00 00 00 00       	mov    $0x0,%eax
f010151f:	eb 05                	jmp    f0101526 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101521:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101526:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101529:	5b                   	pop    %ebx
f010152a:	5e                   	pop    %esi
f010152b:	c9                   	leave  
f010152c:	c3                   	ret    

f010152d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010152d:	55                   	push   %ebp
f010152e:	89 e5                	mov    %esp,%ebp
f0101530:	57                   	push   %edi
f0101531:	56                   	push   %esi
f0101532:	53                   	push   %ebx
f0101533:	83 ec 1c             	sub    $0x1c,%esp
f0101536:	89 c7                	mov    %eax,%edi
f0101538:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010153b:	01 d1                	add    %edx,%ecx
f010153d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101540:	39 ca                	cmp    %ecx,%edx
f0101542:	74 32                	je     f0101576 <boot_map_region+0x49>
f0101544:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101546:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101549:	83 c8 01             	or     $0x1,%eax
f010154c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f010154f:	83 ec 04             	sub    $0x4,%esp
f0101552:	6a 01                	push   $0x1
f0101554:	53                   	push   %ebx
f0101555:	57                   	push   %edi
f0101556:	e8 3b ff ff ff       	call   f0101496 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010155b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010155e:	09 f2                	or     %esi,%edx
f0101560:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101562:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101568:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010156e:	83 c4 10             	add    $0x10,%esp
f0101571:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101574:	75 d9                	jne    f010154f <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f0101576:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101579:	5b                   	pop    %ebx
f010157a:	5e                   	pop    %esi
f010157b:	5f                   	pop    %edi
f010157c:	c9                   	leave  
f010157d:	c3                   	ret    

f010157e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010157e:	55                   	push   %ebp
f010157f:	89 e5                	mov    %esp,%ebp
f0101581:	53                   	push   %ebx
f0101582:	83 ec 08             	sub    $0x8,%esp
f0101585:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101588:	6a 00                	push   $0x0
f010158a:	ff 75 0c             	pushl  0xc(%ebp)
f010158d:	ff 75 08             	pushl  0x8(%ebp)
f0101590:	e8 01 ff ff ff       	call   f0101496 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101595:	83 c4 10             	add    $0x10,%esp
f0101598:	85 c0                	test   %eax,%eax
f010159a:	74 37                	je     f01015d3 <page_lookup+0x55>
f010159c:	f6 00 01             	testb  $0x1,(%eax)
f010159f:	74 39                	je     f01015da <page_lookup+0x5c>
    if (pte_store != 0) {
f01015a1:	85 db                	test   %ebx,%ebx
f01015a3:	74 02                	je     f01015a7 <page_lookup+0x29>
        *pte_store = pte;
f01015a5:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01015a7:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015a9:	c1 e8 0c             	shr    $0xc,%eax
f01015ac:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f01015b2:	72 14                	jb     f01015c8 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01015b4:	83 ec 04             	sub    $0x4,%esp
f01015b7:	68 54 57 10 f0       	push   $0xf0105754
f01015bc:	6a 4f                	push   $0x4f
f01015be:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01015c3:	e8 01 eb ff ff       	call   f01000c9 <_panic>
	return &pages[PGNUM(pa)];
f01015c8:	c1 e0 03             	shl    $0x3,%eax
f01015cb:	03 05 ec 9f 1d f0    	add    0xf01d9fec,%eax
f01015d1:	eb 0c                	jmp    f01015df <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d8:	eb 05                	jmp    f01015df <page_lookup+0x61>
f01015da:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01015df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015e2:	c9                   	leave  
f01015e3:	c3                   	ret    

f01015e4 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01015e4:	55                   	push   %ebp
f01015e5:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ea:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01015ed:	c9                   	leave  
f01015ee:	c3                   	ret    

f01015ef <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015ef:	55                   	push   %ebp
f01015f0:	89 e5                	mov    %esp,%ebp
f01015f2:	56                   	push   %esi
f01015f3:	53                   	push   %ebx
f01015f4:	83 ec 14             	sub    $0x14,%esp
f01015f7:	8b 75 08             	mov    0x8(%ebp),%esi
f01015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f01015fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101600:	50                   	push   %eax
f0101601:	53                   	push   %ebx
f0101602:	56                   	push   %esi
f0101603:	e8 76 ff ff ff       	call   f010157e <page_lookup>
    if (pg == NULL) return;
f0101608:	83 c4 10             	add    $0x10,%esp
f010160b:	85 c0                	test   %eax,%eax
f010160d:	74 26                	je     f0101635 <page_remove+0x46>
    page_decref(pg);
f010160f:	83 ec 0c             	sub    $0xc,%esp
f0101612:	50                   	push   %eax
f0101613:	e8 60 fe ff ff       	call   f0101478 <page_decref>
    if (pte != NULL) *pte = 0;
f0101618:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010161b:	83 c4 10             	add    $0x10,%esp
f010161e:	85 c0                	test   %eax,%eax
f0101620:	74 06                	je     f0101628 <page_remove+0x39>
f0101622:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101628:	83 ec 08             	sub    $0x8,%esp
f010162b:	53                   	push   %ebx
f010162c:	56                   	push   %esi
f010162d:	e8 b2 ff ff ff       	call   f01015e4 <tlb_invalidate>
f0101632:	83 c4 10             	add    $0x10,%esp
}
f0101635:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101638:	5b                   	pop    %ebx
f0101639:	5e                   	pop    %esi
f010163a:	c9                   	leave  
f010163b:	c3                   	ret    

f010163c <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010163c:	55                   	push   %ebp
f010163d:	89 e5                	mov    %esp,%ebp
f010163f:	57                   	push   %edi
f0101640:	56                   	push   %esi
f0101641:	53                   	push   %ebx
f0101642:	83 ec 10             	sub    $0x10,%esp
f0101645:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101648:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f010164b:	6a 01                	push   $0x1
f010164d:	57                   	push   %edi
f010164e:	ff 75 08             	pushl  0x8(%ebp)
f0101651:	e8 40 fe ff ff       	call   f0101496 <pgdir_walk>
f0101656:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101658:	83 c4 10             	add    $0x10,%esp
f010165b:	85 c0                	test   %eax,%eax
f010165d:	74 39                	je     f0101698 <page_insert+0x5c>
    ++pp->pp_ref;
f010165f:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101663:	f6 00 01             	testb  $0x1,(%eax)
f0101666:	74 0f                	je     f0101677 <page_insert+0x3b>
        page_remove(pgdir, va);
f0101668:	83 ec 08             	sub    $0x8,%esp
f010166b:	57                   	push   %edi
f010166c:	ff 75 08             	pushl  0x8(%ebp)
f010166f:	e8 7b ff ff ff       	call   f01015ef <page_remove>
f0101674:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f0101677:	8b 55 14             	mov    0x14(%ebp),%edx
f010167a:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010167d:	2b 35 ec 9f 1d f0    	sub    0xf01d9fec,%esi
f0101683:	c1 fe 03             	sar    $0x3,%esi
f0101686:	89 f0                	mov    %esi,%eax
f0101688:	c1 e0 0c             	shl    $0xc,%eax
f010168b:	89 d6                	mov    %edx,%esi
f010168d:	09 c6                	or     %eax,%esi
f010168f:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101691:	b8 00 00 00 00       	mov    $0x0,%eax
f0101696:	eb 05                	jmp    f010169d <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101698:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f010169d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016a0:	5b                   	pop    %ebx
f01016a1:	5e                   	pop    %esi
f01016a2:	5f                   	pop    %edi
f01016a3:	c9                   	leave  
f01016a4:	c3                   	ret    

f01016a5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016a5:	55                   	push   %ebp
f01016a6:	89 e5                	mov    %esp,%ebp
f01016a8:	57                   	push   %edi
f01016a9:	56                   	push   %esi
f01016aa:	53                   	push   %ebx
f01016ab:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016ae:	b8 15 00 00 00       	mov    $0x15,%eax
f01016b3:	e8 89 f9 ff ff       	call   f0101041 <nvram_read>
f01016b8:	c1 e0 0a             	shl    $0xa,%eax
f01016bb:	89 c2                	mov    %eax,%edx
f01016bd:	85 c0                	test   %eax,%eax
f01016bf:	79 06                	jns    f01016c7 <mem_init+0x22>
f01016c1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016c7:	c1 fa 0c             	sar    $0xc,%edx
f01016ca:	89 15 18 93 1d f0    	mov    %edx,0xf01d9318
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016d0:	b8 17 00 00 00       	mov    $0x17,%eax
f01016d5:	e8 67 f9 ff ff       	call   f0101041 <nvram_read>
f01016da:	89 c2                	mov    %eax,%edx
f01016dc:	c1 e2 0a             	shl    $0xa,%edx
f01016df:	89 d0                	mov    %edx,%eax
f01016e1:	85 d2                	test   %edx,%edx
f01016e3:	79 06                	jns    f01016eb <mem_init+0x46>
f01016e5:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01016eb:	c1 f8 0c             	sar    $0xc,%eax
f01016ee:	74 0e                	je     f01016fe <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01016f0:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01016f6:	89 15 e4 9f 1d f0    	mov    %edx,0xf01d9fe4
f01016fc:	eb 0c                	jmp    f010170a <mem_init+0x65>
	else
		npages = npages_basemem;
f01016fe:	8b 15 18 93 1d f0    	mov    0xf01d9318,%edx
f0101704:	89 15 e4 9f 1d f0    	mov    %edx,0xf01d9fe4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010170a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010170d:	c1 e8 0a             	shr    $0xa,%eax
f0101710:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101711:	a1 18 93 1d f0       	mov    0xf01d9318,%eax
f0101716:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101719:	c1 e8 0a             	shr    $0xa,%eax
f010171c:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010171d:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f0101722:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101725:	c1 e8 0a             	shr    $0xa,%eax
f0101728:	50                   	push   %eax
f0101729:	68 74 57 10 f0       	push   $0xf0105774
f010172e:	e8 f2 1d 00 00       	call   f0103525 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101733:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101738:	e8 6b f8 ff ff       	call   f0100fa8 <boot_alloc>
f010173d:	a3 e8 9f 1d f0       	mov    %eax,0xf01d9fe8
	memset(kern_pgdir, 0, PGSIZE);
f0101742:	83 c4 0c             	add    $0xc,%esp
f0101745:	68 00 10 00 00       	push   $0x1000
f010174a:	6a 00                	push   $0x0
f010174c:	50                   	push   %eax
f010174d:	e8 ff 2f 00 00       	call   f0104751 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101752:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101757:	83 c4 10             	add    $0x10,%esp
f010175a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010175f:	77 15                	ja     f0101776 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101761:	50                   	push   %eax
f0101762:	68 9c 54 10 f0       	push   $0xf010549c
f0101767:	68 8e 00 00 00       	push   $0x8e
f010176c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101771:	e8 53 e9 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101776:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010177c:	83 ca 05             	or     $0x5,%edx
f010177f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101785:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f010178a:	c1 e0 03             	shl    $0x3,%eax
f010178d:	e8 16 f8 ff ff       	call   f0100fa8 <boot_alloc>
f0101792:	a3 ec 9f 1d f0       	mov    %eax,0xf01d9fec
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101797:	b8 00 80 01 00       	mov    $0x18000,%eax
f010179c:	e8 07 f8 ff ff       	call   f0100fa8 <boot_alloc>
f01017a1:	a3 1c 93 1d f0       	mov    %eax,0xf01d931c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017a6:	e8 76 fb ff ff       	call   f0101321 <page_init>

	check_page_free_list(1);
f01017ab:	b8 01 00 00 00       	mov    $0x1,%eax
f01017b0:	e8 b3 f8 ff ff       	call   f0101068 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017b5:	83 3d ec 9f 1d f0 00 	cmpl   $0x0,0xf01d9fec
f01017bc:	75 17                	jne    f01017d5 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f01017be:	83 ec 04             	sub    $0x4,%esp
f01017c1:	68 83 5e 10 f0       	push   $0xf0105e83
f01017c6:	68 95 02 00 00       	push   $0x295
f01017cb:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01017d0:	e8 f4 e8 ff ff       	call   f01000c9 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017d5:	a1 10 93 1d f0       	mov    0xf01d9310,%eax
f01017da:	85 c0                	test   %eax,%eax
f01017dc:	74 0e                	je     f01017ec <mem_init+0x147>
f01017de:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01017e3:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017e4:	8b 00                	mov    (%eax),%eax
f01017e6:	85 c0                	test   %eax,%eax
f01017e8:	75 f9                	jne    f01017e3 <mem_init+0x13e>
f01017ea:	eb 05                	jmp    f01017f1 <mem_init+0x14c>
f01017ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017f1:	83 ec 0c             	sub    $0xc,%esp
f01017f4:	6a 00                	push   $0x0
f01017f6:	e8 d3 fb ff ff       	call   f01013ce <page_alloc>
f01017fb:	89 c6                	mov    %eax,%esi
f01017fd:	83 c4 10             	add    $0x10,%esp
f0101800:	85 c0                	test   %eax,%eax
f0101802:	75 19                	jne    f010181d <mem_init+0x178>
f0101804:	68 9e 5e 10 f0       	push   $0xf0105e9e
f0101809:	68 f3 5d 10 f0       	push   $0xf0105df3
f010180e:	68 9d 02 00 00       	push   $0x29d
f0101813:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101818:	e8 ac e8 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f010181d:	83 ec 0c             	sub    $0xc,%esp
f0101820:	6a 00                	push   $0x0
f0101822:	e8 a7 fb ff ff       	call   f01013ce <page_alloc>
f0101827:	89 c7                	mov    %eax,%edi
f0101829:	83 c4 10             	add    $0x10,%esp
f010182c:	85 c0                	test   %eax,%eax
f010182e:	75 19                	jne    f0101849 <mem_init+0x1a4>
f0101830:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0101835:	68 f3 5d 10 f0       	push   $0xf0105df3
f010183a:	68 9e 02 00 00       	push   $0x29e
f010183f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101844:	e8 80 e8 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f0101849:	83 ec 0c             	sub    $0xc,%esp
f010184c:	6a 00                	push   $0x0
f010184e:	e8 7b fb ff ff       	call   f01013ce <page_alloc>
f0101853:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101856:	83 c4 10             	add    $0x10,%esp
f0101859:	85 c0                	test   %eax,%eax
f010185b:	75 19                	jne    f0101876 <mem_init+0x1d1>
f010185d:	68 ca 5e 10 f0       	push   $0xf0105eca
f0101862:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101867:	68 9f 02 00 00       	push   $0x29f
f010186c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101871:	e8 53 e8 ff ff       	call   f01000c9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101876:	39 fe                	cmp    %edi,%esi
f0101878:	75 19                	jne    f0101893 <mem_init+0x1ee>
f010187a:	68 e0 5e 10 f0       	push   $0xf0105ee0
f010187f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101884:	68 a2 02 00 00       	push   $0x2a2
f0101889:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010188e:	e8 36 e8 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101893:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101896:	74 05                	je     f010189d <mem_init+0x1f8>
f0101898:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010189b:	75 19                	jne    f01018b6 <mem_init+0x211>
f010189d:	68 b0 57 10 f0       	push   $0xf01057b0
f01018a2:	68 f3 5d 10 f0       	push   $0xf0105df3
f01018a7:	68 a3 02 00 00       	push   $0x2a3
f01018ac:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01018b1:	e8 13 e8 ff ff       	call   f01000c9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b6:	8b 15 ec 9f 1d f0    	mov    0xf01d9fec,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018bc:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f01018c1:	c1 e0 0c             	shl    $0xc,%eax
f01018c4:	89 f1                	mov    %esi,%ecx
f01018c6:	29 d1                	sub    %edx,%ecx
f01018c8:	c1 f9 03             	sar    $0x3,%ecx
f01018cb:	c1 e1 0c             	shl    $0xc,%ecx
f01018ce:	39 c1                	cmp    %eax,%ecx
f01018d0:	72 19                	jb     f01018eb <mem_init+0x246>
f01018d2:	68 f2 5e 10 f0       	push   $0xf0105ef2
f01018d7:	68 f3 5d 10 f0       	push   $0xf0105df3
f01018dc:	68 a4 02 00 00       	push   $0x2a4
f01018e1:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01018e6:	e8 de e7 ff ff       	call   f01000c9 <_panic>
f01018eb:	89 f9                	mov    %edi,%ecx
f01018ed:	29 d1                	sub    %edx,%ecx
f01018ef:	c1 f9 03             	sar    $0x3,%ecx
f01018f2:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01018f5:	39 c8                	cmp    %ecx,%eax
f01018f7:	77 19                	ja     f0101912 <mem_init+0x26d>
f01018f9:	68 0f 5f 10 f0       	push   $0xf0105f0f
f01018fe:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101903:	68 a5 02 00 00       	push   $0x2a5
f0101908:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010190d:	e8 b7 e7 ff ff       	call   f01000c9 <_panic>
f0101912:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101915:	29 d1                	sub    %edx,%ecx
f0101917:	89 ca                	mov    %ecx,%edx
f0101919:	c1 fa 03             	sar    $0x3,%edx
f010191c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010191f:	39 d0                	cmp    %edx,%eax
f0101921:	77 19                	ja     f010193c <mem_init+0x297>
f0101923:	68 2c 5f 10 f0       	push   $0xf0105f2c
f0101928:	68 f3 5d 10 f0       	push   $0xf0105df3
f010192d:	68 a6 02 00 00       	push   $0x2a6
f0101932:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101937:	e8 8d e7 ff ff       	call   f01000c9 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010193c:	a1 10 93 1d f0       	mov    0xf01d9310,%eax
f0101941:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101944:	c7 05 10 93 1d f0 00 	movl   $0x0,0xf01d9310
f010194b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010194e:	83 ec 0c             	sub    $0xc,%esp
f0101951:	6a 00                	push   $0x0
f0101953:	e8 76 fa ff ff       	call   f01013ce <page_alloc>
f0101958:	83 c4 10             	add    $0x10,%esp
f010195b:	85 c0                	test   %eax,%eax
f010195d:	74 19                	je     f0101978 <mem_init+0x2d3>
f010195f:	68 49 5f 10 f0       	push   $0xf0105f49
f0101964:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101969:	68 ad 02 00 00       	push   $0x2ad
f010196e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101973:	e8 51 e7 ff ff       	call   f01000c9 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101978:	83 ec 0c             	sub    $0xc,%esp
f010197b:	56                   	push   %esi
f010197c:	e8 d7 fa ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0101981:	89 3c 24             	mov    %edi,(%esp)
f0101984:	e8 cf fa ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f0101989:	83 c4 04             	add    $0x4,%esp
f010198c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010198f:	e8 c4 fa ff ff       	call   f0101458 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010199b:	e8 2e fa ff ff       	call   f01013ce <page_alloc>
f01019a0:	89 c6                	mov    %eax,%esi
f01019a2:	83 c4 10             	add    $0x10,%esp
f01019a5:	85 c0                	test   %eax,%eax
f01019a7:	75 19                	jne    f01019c2 <mem_init+0x31d>
f01019a9:	68 9e 5e 10 f0       	push   $0xf0105e9e
f01019ae:	68 f3 5d 10 f0       	push   $0xf0105df3
f01019b3:	68 b4 02 00 00       	push   $0x2b4
f01019b8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01019bd:	e8 07 e7 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f01019c2:	83 ec 0c             	sub    $0xc,%esp
f01019c5:	6a 00                	push   $0x0
f01019c7:	e8 02 fa ff ff       	call   f01013ce <page_alloc>
f01019cc:	89 c7                	mov    %eax,%edi
f01019ce:	83 c4 10             	add    $0x10,%esp
f01019d1:	85 c0                	test   %eax,%eax
f01019d3:	75 19                	jne    f01019ee <mem_init+0x349>
f01019d5:	68 b4 5e 10 f0       	push   $0xf0105eb4
f01019da:	68 f3 5d 10 f0       	push   $0xf0105df3
f01019df:	68 b5 02 00 00       	push   $0x2b5
f01019e4:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01019e9:	e8 db e6 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f01019ee:	83 ec 0c             	sub    $0xc,%esp
f01019f1:	6a 00                	push   $0x0
f01019f3:	e8 d6 f9 ff ff       	call   f01013ce <page_alloc>
f01019f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019fb:	83 c4 10             	add    $0x10,%esp
f01019fe:	85 c0                	test   %eax,%eax
f0101a00:	75 19                	jne    f0101a1b <mem_init+0x376>
f0101a02:	68 ca 5e 10 f0       	push   $0xf0105eca
f0101a07:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a0c:	68 b6 02 00 00       	push   $0x2b6
f0101a11:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a16:	e8 ae e6 ff ff       	call   f01000c9 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a1b:	39 fe                	cmp    %edi,%esi
f0101a1d:	75 19                	jne    f0101a38 <mem_init+0x393>
f0101a1f:	68 e0 5e 10 f0       	push   $0xf0105ee0
f0101a24:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a29:	68 b8 02 00 00       	push   $0x2b8
f0101a2e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a33:	e8 91 e6 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a38:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a3b:	74 05                	je     f0101a42 <mem_init+0x39d>
f0101a3d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a40:	75 19                	jne    f0101a5b <mem_init+0x3b6>
f0101a42:	68 b0 57 10 f0       	push   $0xf01057b0
f0101a47:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a4c:	68 b9 02 00 00       	push   $0x2b9
f0101a51:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a56:	e8 6e e6 ff ff       	call   f01000c9 <_panic>
	assert(!page_alloc(0));
f0101a5b:	83 ec 0c             	sub    $0xc,%esp
f0101a5e:	6a 00                	push   $0x0
f0101a60:	e8 69 f9 ff ff       	call   f01013ce <page_alloc>
f0101a65:	83 c4 10             	add    $0x10,%esp
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	74 19                	je     f0101a85 <mem_init+0x3e0>
f0101a6c:	68 49 5f 10 f0       	push   $0xf0105f49
f0101a71:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a76:	68 ba 02 00 00       	push   $0x2ba
f0101a7b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a80:	e8 44 e6 ff ff       	call   f01000c9 <_panic>
f0101a85:	89 f0                	mov    %esi,%eax
f0101a87:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f0101a8d:	c1 f8 03             	sar    $0x3,%eax
f0101a90:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a93:	89 c2                	mov    %eax,%edx
f0101a95:	c1 ea 0c             	shr    $0xc,%edx
f0101a98:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0101a9e:	72 12                	jb     f0101ab2 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aa0:	50                   	push   %eax
f0101aa1:	68 6c 56 10 f0       	push   $0xf010566c
f0101aa6:	6a 56                	push   $0x56
f0101aa8:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101aad:	e8 17 e6 ff ff       	call   f01000c9 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ab2:	83 ec 04             	sub    $0x4,%esp
f0101ab5:	68 00 10 00 00       	push   $0x1000
f0101aba:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101abc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ac1:	50                   	push   %eax
f0101ac2:	e8 8a 2c 00 00       	call   f0104751 <memset>
	page_free(pp0);
f0101ac7:	89 34 24             	mov    %esi,(%esp)
f0101aca:	e8 89 f9 ff ff       	call   f0101458 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ad6:	e8 f3 f8 ff ff       	call   f01013ce <page_alloc>
f0101adb:	83 c4 10             	add    $0x10,%esp
f0101ade:	85 c0                	test   %eax,%eax
f0101ae0:	75 19                	jne    f0101afb <mem_init+0x456>
f0101ae2:	68 58 5f 10 f0       	push   $0xf0105f58
f0101ae7:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101aec:	68 bf 02 00 00       	push   $0x2bf
f0101af1:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101af6:	e8 ce e5 ff ff       	call   f01000c9 <_panic>
	assert(pp && pp0 == pp);
f0101afb:	39 c6                	cmp    %eax,%esi
f0101afd:	74 19                	je     f0101b18 <mem_init+0x473>
f0101aff:	68 76 5f 10 f0       	push   $0xf0105f76
f0101b04:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101b09:	68 c0 02 00 00       	push   $0x2c0
f0101b0e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101b13:	e8 b1 e5 ff ff       	call   f01000c9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b18:	89 f2                	mov    %esi,%edx
f0101b1a:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0101b20:	c1 fa 03             	sar    $0x3,%edx
f0101b23:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b26:	89 d0                	mov    %edx,%eax
f0101b28:	c1 e8 0c             	shr    $0xc,%eax
f0101b2b:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f0101b31:	72 12                	jb     f0101b45 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b33:	52                   	push   %edx
f0101b34:	68 6c 56 10 f0       	push   $0xf010566c
f0101b39:	6a 56                	push   $0x56
f0101b3b:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101b40:	e8 84 e5 ff ff       	call   f01000c9 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b45:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b4c:	75 11                	jne    f0101b5f <mem_init+0x4ba>
f0101b4e:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b54:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b5a:	80 38 00             	cmpb   $0x0,(%eax)
f0101b5d:	74 19                	je     f0101b78 <mem_init+0x4d3>
f0101b5f:	68 86 5f 10 f0       	push   $0xf0105f86
f0101b64:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101b69:	68 c3 02 00 00       	push   $0x2c3
f0101b6e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101b73:	e8 51 e5 ff ff       	call   f01000c9 <_panic>
f0101b78:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b79:	39 d0                	cmp    %edx,%eax
f0101b7b:	75 dd                	jne    f0101b5a <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b7d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b80:	89 0d 10 93 1d f0    	mov    %ecx,0xf01d9310

	// free the pages we took
	page_free(pp0);
f0101b86:	83 ec 0c             	sub    $0xc,%esp
f0101b89:	56                   	push   %esi
f0101b8a:	e8 c9 f8 ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0101b8f:	89 3c 24             	mov    %edi,(%esp)
f0101b92:	e8 c1 f8 ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f0101b97:	83 c4 04             	add    $0x4,%esp
f0101b9a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b9d:	e8 b6 f8 ff ff       	call   f0101458 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ba2:	a1 10 93 1d f0       	mov    0xf01d9310,%eax
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	74 07                	je     f0101bb5 <mem_init+0x510>
		--nfree;
f0101bae:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101baf:	8b 00                	mov    (%eax),%eax
f0101bb1:	85 c0                	test   %eax,%eax
f0101bb3:	75 f9                	jne    f0101bae <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101bb5:	85 db                	test   %ebx,%ebx
f0101bb7:	74 19                	je     f0101bd2 <mem_init+0x52d>
f0101bb9:	68 90 5f 10 f0       	push   $0xf0105f90
f0101bbe:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101bc3:	68 d0 02 00 00       	push   $0x2d0
f0101bc8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101bcd:	e8 f7 e4 ff ff       	call   f01000c9 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bd2:	83 ec 0c             	sub    $0xc,%esp
f0101bd5:	68 d0 57 10 f0       	push   $0xf01057d0
f0101bda:	e8 46 19 00 00       	call   f0103525 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be6:	e8 e3 f7 ff ff       	call   f01013ce <page_alloc>
f0101beb:	89 c7                	mov    %eax,%edi
f0101bed:	83 c4 10             	add    $0x10,%esp
f0101bf0:	85 c0                	test   %eax,%eax
f0101bf2:	75 19                	jne    f0101c0d <mem_init+0x568>
f0101bf4:	68 9e 5e 10 f0       	push   $0xf0105e9e
f0101bf9:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101bfe:	68 2e 03 00 00       	push   $0x32e
f0101c03:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c08:	e8 bc e4 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c0d:	83 ec 0c             	sub    $0xc,%esp
f0101c10:	6a 00                	push   $0x0
f0101c12:	e8 b7 f7 ff ff       	call   f01013ce <page_alloc>
f0101c17:	89 c6                	mov    %eax,%esi
f0101c19:	83 c4 10             	add    $0x10,%esp
f0101c1c:	85 c0                	test   %eax,%eax
f0101c1e:	75 19                	jne    f0101c39 <mem_init+0x594>
f0101c20:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0101c25:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c2a:	68 2f 03 00 00       	push   $0x32f
f0101c2f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c34:	e8 90 e4 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c39:	83 ec 0c             	sub    $0xc,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	e8 8b f7 ff ff       	call   f01013ce <page_alloc>
f0101c43:	89 c3                	mov    %eax,%ebx
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	75 19                	jne    f0101c65 <mem_init+0x5c0>
f0101c4c:	68 ca 5e 10 f0       	push   $0xf0105eca
f0101c51:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c56:	68 30 03 00 00       	push   $0x330
f0101c5b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c60:	e8 64 e4 ff ff       	call   f01000c9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c65:	39 f7                	cmp    %esi,%edi
f0101c67:	75 19                	jne    f0101c82 <mem_init+0x5dd>
f0101c69:	68 e0 5e 10 f0       	push   $0xf0105ee0
f0101c6e:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c73:	68 33 03 00 00       	push   $0x333
f0101c78:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c7d:	e8 47 e4 ff ff       	call   f01000c9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c82:	39 c6                	cmp    %eax,%esi
f0101c84:	74 04                	je     f0101c8a <mem_init+0x5e5>
f0101c86:	39 c7                	cmp    %eax,%edi
f0101c88:	75 19                	jne    f0101ca3 <mem_init+0x5fe>
f0101c8a:	68 b0 57 10 f0       	push   $0xf01057b0
f0101c8f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c94:	68 34 03 00 00       	push   $0x334
f0101c99:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c9e:	e8 26 e4 ff ff       	call   f01000c9 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ca3:	a1 10 93 1d f0       	mov    0xf01d9310,%eax
f0101ca8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101cab:	c7 05 10 93 1d f0 00 	movl   $0x0,0xf01d9310
f0101cb2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cb5:	83 ec 0c             	sub    $0xc,%esp
f0101cb8:	6a 00                	push   $0x0
f0101cba:	e8 0f f7 ff ff       	call   f01013ce <page_alloc>
f0101cbf:	83 c4 10             	add    $0x10,%esp
f0101cc2:	85 c0                	test   %eax,%eax
f0101cc4:	74 19                	je     f0101cdf <mem_init+0x63a>
f0101cc6:	68 49 5f 10 f0       	push   $0xf0105f49
f0101ccb:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101cd0:	68 3b 03 00 00       	push   $0x33b
f0101cd5:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101cda:	e8 ea e3 ff ff       	call   f01000c9 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cdf:	83 ec 04             	sub    $0x4,%esp
f0101ce2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ce5:	50                   	push   %eax
f0101ce6:	6a 00                	push   $0x0
f0101ce8:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0101cee:	e8 8b f8 ff ff       	call   f010157e <page_lookup>
f0101cf3:	83 c4 10             	add    $0x10,%esp
f0101cf6:	85 c0                	test   %eax,%eax
f0101cf8:	74 19                	je     f0101d13 <mem_init+0x66e>
f0101cfa:	68 f0 57 10 f0       	push   $0xf01057f0
f0101cff:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d04:	68 3e 03 00 00       	push   $0x33e
f0101d09:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d0e:	e8 b6 e3 ff ff       	call   f01000c9 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d13:	6a 02                	push   $0x2
f0101d15:	6a 00                	push   $0x0
f0101d17:	56                   	push   %esi
f0101d18:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0101d1e:	e8 19 f9 ff ff       	call   f010163c <page_insert>
f0101d23:	83 c4 10             	add    $0x10,%esp
f0101d26:	85 c0                	test   %eax,%eax
f0101d28:	78 19                	js     f0101d43 <mem_init+0x69e>
f0101d2a:	68 28 58 10 f0       	push   $0xf0105828
f0101d2f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d34:	68 41 03 00 00       	push   $0x341
f0101d39:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d3e:	e8 86 e3 ff ff       	call   f01000c9 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d43:	83 ec 0c             	sub    $0xc,%esp
f0101d46:	57                   	push   %edi
f0101d47:	e8 0c f7 ff ff       	call   f0101458 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d4c:	6a 02                	push   $0x2
f0101d4e:	6a 00                	push   $0x0
f0101d50:	56                   	push   %esi
f0101d51:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0101d57:	e8 e0 f8 ff ff       	call   f010163c <page_insert>
f0101d5c:	83 c4 20             	add    $0x20,%esp
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	74 19                	je     f0101d7c <mem_init+0x6d7>
f0101d63:	68 58 58 10 f0       	push   $0xf0105858
f0101d68:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d6d:	68 45 03 00 00       	push   $0x345
f0101d72:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d77:	e8 4d e3 ff ff       	call   f01000c9 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d7c:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0101d81:	8b 08                	mov    (%eax),%ecx
f0101d83:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d89:	89 fa                	mov    %edi,%edx
f0101d8b:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0101d91:	c1 fa 03             	sar    $0x3,%edx
f0101d94:	c1 e2 0c             	shl    $0xc,%edx
f0101d97:	39 d1                	cmp    %edx,%ecx
f0101d99:	74 19                	je     f0101db4 <mem_init+0x70f>
f0101d9b:	68 88 58 10 f0       	push   $0xf0105888
f0101da0:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101da5:	68 46 03 00 00       	push   $0x346
f0101daa:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101daf:	e8 15 e3 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101db4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101db9:	e8 21 f2 ff ff       	call   f0100fdf <check_va2pa>
f0101dbe:	89 f2                	mov    %esi,%edx
f0101dc0:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0101dc6:	c1 fa 03             	sar    $0x3,%edx
f0101dc9:	c1 e2 0c             	shl    $0xc,%edx
f0101dcc:	39 d0                	cmp    %edx,%eax
f0101dce:	74 19                	je     f0101de9 <mem_init+0x744>
f0101dd0:	68 b0 58 10 f0       	push   $0xf01058b0
f0101dd5:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101dda:	68 47 03 00 00       	push   $0x347
f0101ddf:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101de4:	e8 e0 e2 ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 1);
f0101de9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dee:	74 19                	je     f0101e09 <mem_init+0x764>
f0101df0:	68 9b 5f 10 f0       	push   $0xf0105f9b
f0101df5:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101dfa:	68 48 03 00 00       	push   $0x348
f0101dff:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e04:	e8 c0 e2 ff ff       	call   f01000c9 <_panic>
	assert(pp0->pp_ref == 1);
f0101e09:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e0e:	74 19                	je     f0101e29 <mem_init+0x784>
f0101e10:	68 ac 5f 10 f0       	push   $0xf0105fac
f0101e15:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e1a:	68 49 03 00 00       	push   $0x349
f0101e1f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e24:	e8 a0 e2 ff ff       	call   f01000c9 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e29:	6a 02                	push   $0x2
f0101e2b:	68 00 10 00 00       	push   $0x1000
f0101e30:	53                   	push   %ebx
f0101e31:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0101e37:	e8 00 f8 ff ff       	call   f010163c <page_insert>
f0101e3c:	83 c4 10             	add    $0x10,%esp
f0101e3f:	85 c0                	test   %eax,%eax
f0101e41:	74 19                	je     f0101e5c <mem_init+0x7b7>
f0101e43:	68 e0 58 10 f0       	push   $0xf01058e0
f0101e48:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e4d:	68 4c 03 00 00       	push   $0x34c
f0101e52:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e57:	e8 6d e2 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e61:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0101e66:	e8 74 f1 ff ff       	call   f0100fdf <check_va2pa>
f0101e6b:	89 da                	mov    %ebx,%edx
f0101e6d:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0101e73:	c1 fa 03             	sar    $0x3,%edx
f0101e76:	c1 e2 0c             	shl    $0xc,%edx
f0101e79:	39 d0                	cmp    %edx,%eax
f0101e7b:	74 19                	je     f0101e96 <mem_init+0x7f1>
f0101e7d:	68 1c 59 10 f0       	push   $0xf010591c
f0101e82:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e87:	68 4d 03 00 00       	push   $0x34d
f0101e8c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e91:	e8 33 e2 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0101e96:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e9b:	74 19                	je     f0101eb6 <mem_init+0x811>
f0101e9d:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0101ea2:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101ea7:	68 4e 03 00 00       	push   $0x34e
f0101eac:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101eb1:	e8 13 e2 ff ff       	call   f01000c9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101eb6:	83 ec 0c             	sub    $0xc,%esp
f0101eb9:	6a 00                	push   $0x0
f0101ebb:	e8 0e f5 ff ff       	call   f01013ce <page_alloc>
f0101ec0:	83 c4 10             	add    $0x10,%esp
f0101ec3:	85 c0                	test   %eax,%eax
f0101ec5:	74 19                	je     f0101ee0 <mem_init+0x83b>
f0101ec7:	68 49 5f 10 f0       	push   $0xf0105f49
f0101ecc:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101ed1:	68 51 03 00 00       	push   $0x351
f0101ed6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101edb:	e8 e9 e1 ff ff       	call   f01000c9 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee0:	6a 02                	push   $0x2
f0101ee2:	68 00 10 00 00       	push   $0x1000
f0101ee7:	53                   	push   %ebx
f0101ee8:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0101eee:	e8 49 f7 ff ff       	call   f010163c <page_insert>
f0101ef3:	83 c4 10             	add    $0x10,%esp
f0101ef6:	85 c0                	test   %eax,%eax
f0101ef8:	74 19                	je     f0101f13 <mem_init+0x86e>
f0101efa:	68 e0 58 10 f0       	push   $0xf01058e0
f0101eff:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f04:	68 54 03 00 00       	push   $0x354
f0101f09:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f0e:	e8 b6 e1 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f18:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0101f1d:	e8 bd f0 ff ff       	call   f0100fdf <check_va2pa>
f0101f22:	89 da                	mov    %ebx,%edx
f0101f24:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0101f2a:	c1 fa 03             	sar    $0x3,%edx
f0101f2d:	c1 e2 0c             	shl    $0xc,%edx
f0101f30:	39 d0                	cmp    %edx,%eax
f0101f32:	74 19                	je     f0101f4d <mem_init+0x8a8>
f0101f34:	68 1c 59 10 f0       	push   $0xf010591c
f0101f39:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f3e:	68 55 03 00 00       	push   $0x355
f0101f43:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f48:	e8 7c e1 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0101f4d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f52:	74 19                	je     f0101f6d <mem_init+0x8c8>
f0101f54:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0101f59:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f5e:	68 56 03 00 00       	push   $0x356
f0101f63:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f68:	e8 5c e1 ff ff       	call   f01000c9 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f6d:	83 ec 0c             	sub    $0xc,%esp
f0101f70:	6a 00                	push   $0x0
f0101f72:	e8 57 f4 ff ff       	call   f01013ce <page_alloc>
f0101f77:	83 c4 10             	add    $0x10,%esp
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	74 19                	je     f0101f97 <mem_init+0x8f2>
f0101f7e:	68 49 5f 10 f0       	push   $0xf0105f49
f0101f83:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f88:	68 5a 03 00 00       	push   $0x35a
f0101f8d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f92:	e8 32 e1 ff ff       	call   f01000c9 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f97:	8b 15 e8 9f 1d f0    	mov    0xf01d9fe8,%edx
f0101f9d:	8b 02                	mov    (%edx),%eax
f0101f9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fa4:	89 c1                	mov    %eax,%ecx
f0101fa6:	c1 e9 0c             	shr    $0xc,%ecx
f0101fa9:	3b 0d e4 9f 1d f0    	cmp    0xf01d9fe4,%ecx
f0101faf:	72 15                	jb     f0101fc6 <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fb1:	50                   	push   %eax
f0101fb2:	68 6c 56 10 f0       	push   $0xf010566c
f0101fb7:	68 5d 03 00 00       	push   $0x35d
f0101fbc:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101fc1:	e8 03 e1 ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0101fc6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fcb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fce:	83 ec 04             	sub    $0x4,%esp
f0101fd1:	6a 00                	push   $0x0
f0101fd3:	68 00 10 00 00       	push   $0x1000
f0101fd8:	52                   	push   %edx
f0101fd9:	e8 b8 f4 ff ff       	call   f0101496 <pgdir_walk>
f0101fde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fe1:	83 c2 04             	add    $0x4,%edx
f0101fe4:	83 c4 10             	add    $0x10,%esp
f0101fe7:	39 d0                	cmp    %edx,%eax
f0101fe9:	74 19                	je     f0102004 <mem_init+0x95f>
f0101feb:	68 4c 59 10 f0       	push   $0xf010594c
f0101ff0:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101ff5:	68 5e 03 00 00       	push   $0x35e
f0101ffa:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101fff:	e8 c5 e0 ff ff       	call   f01000c9 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102004:	6a 06                	push   $0x6
f0102006:	68 00 10 00 00       	push   $0x1000
f010200b:	53                   	push   %ebx
f010200c:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102012:	e8 25 f6 ff ff       	call   f010163c <page_insert>
f0102017:	83 c4 10             	add    $0x10,%esp
f010201a:	85 c0                	test   %eax,%eax
f010201c:	74 19                	je     f0102037 <mem_init+0x992>
f010201e:	68 8c 59 10 f0       	push   $0xf010598c
f0102023:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102028:	68 61 03 00 00       	push   $0x361
f010202d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102032:	e8 92 e0 ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102037:	ba 00 10 00 00       	mov    $0x1000,%edx
f010203c:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102041:	e8 99 ef ff ff       	call   f0100fdf <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102046:	89 da                	mov    %ebx,%edx
f0102048:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f010204e:	c1 fa 03             	sar    $0x3,%edx
f0102051:	c1 e2 0c             	shl    $0xc,%edx
f0102054:	39 d0                	cmp    %edx,%eax
f0102056:	74 19                	je     f0102071 <mem_init+0x9cc>
f0102058:	68 1c 59 10 f0       	push   $0xf010591c
f010205d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102062:	68 62 03 00 00       	push   $0x362
f0102067:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010206c:	e8 58 e0 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0102071:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102076:	74 19                	je     f0102091 <mem_init+0x9ec>
f0102078:	68 bd 5f 10 f0       	push   $0xf0105fbd
f010207d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102082:	68 63 03 00 00       	push   $0x363
f0102087:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010208c:	e8 38 e0 ff ff       	call   f01000c9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102091:	83 ec 04             	sub    $0x4,%esp
f0102094:	6a 00                	push   $0x0
f0102096:	68 00 10 00 00       	push   $0x1000
f010209b:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f01020a1:	e8 f0 f3 ff ff       	call   f0101496 <pgdir_walk>
f01020a6:	83 c4 10             	add    $0x10,%esp
f01020a9:	f6 00 04             	testb  $0x4,(%eax)
f01020ac:	75 19                	jne    f01020c7 <mem_init+0xa22>
f01020ae:	68 cc 59 10 f0       	push   $0xf01059cc
f01020b3:	68 f3 5d 10 f0       	push   $0xf0105df3
f01020b8:	68 64 03 00 00       	push   $0x364
f01020bd:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01020c2:	e8 02 e0 ff ff       	call   f01000c9 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020c7:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f01020cc:	f6 00 04             	testb  $0x4,(%eax)
f01020cf:	75 19                	jne    f01020ea <mem_init+0xa45>
f01020d1:	68 ce 5f 10 f0       	push   $0xf0105fce
f01020d6:	68 f3 5d 10 f0       	push   $0xf0105df3
f01020db:	68 65 03 00 00       	push   $0x365
f01020e0:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01020e5:	e8 df df ff ff       	call   f01000c9 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020ea:	6a 02                	push   $0x2
f01020ec:	68 00 10 00 00       	push   $0x1000
f01020f1:	53                   	push   %ebx
f01020f2:	50                   	push   %eax
f01020f3:	e8 44 f5 ff ff       	call   f010163c <page_insert>
f01020f8:	83 c4 10             	add    $0x10,%esp
f01020fb:	85 c0                	test   %eax,%eax
f01020fd:	74 19                	je     f0102118 <mem_init+0xa73>
f01020ff:	68 e0 58 10 f0       	push   $0xf01058e0
f0102104:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102109:	68 68 03 00 00       	push   $0x368
f010210e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102113:	e8 b1 df ff ff       	call   f01000c9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102118:	83 ec 04             	sub    $0x4,%esp
f010211b:	6a 00                	push   $0x0
f010211d:	68 00 10 00 00       	push   $0x1000
f0102122:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102128:	e8 69 f3 ff ff       	call   f0101496 <pgdir_walk>
f010212d:	83 c4 10             	add    $0x10,%esp
f0102130:	f6 00 02             	testb  $0x2,(%eax)
f0102133:	75 19                	jne    f010214e <mem_init+0xaa9>
f0102135:	68 00 5a 10 f0       	push   $0xf0105a00
f010213a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010213f:	68 69 03 00 00       	push   $0x369
f0102144:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102149:	e8 7b df ff ff       	call   f01000c9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010214e:	83 ec 04             	sub    $0x4,%esp
f0102151:	6a 00                	push   $0x0
f0102153:	68 00 10 00 00       	push   $0x1000
f0102158:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f010215e:	e8 33 f3 ff ff       	call   f0101496 <pgdir_walk>
f0102163:	83 c4 10             	add    $0x10,%esp
f0102166:	f6 00 04             	testb  $0x4,(%eax)
f0102169:	74 19                	je     f0102184 <mem_init+0xadf>
f010216b:	68 34 5a 10 f0       	push   $0xf0105a34
f0102170:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102175:	68 6a 03 00 00       	push   $0x36a
f010217a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010217f:	e8 45 df ff ff       	call   f01000c9 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102184:	6a 02                	push   $0x2
f0102186:	68 00 00 40 00       	push   $0x400000
f010218b:	57                   	push   %edi
f010218c:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102192:	e8 a5 f4 ff ff       	call   f010163c <page_insert>
f0102197:	83 c4 10             	add    $0x10,%esp
f010219a:	85 c0                	test   %eax,%eax
f010219c:	78 19                	js     f01021b7 <mem_init+0xb12>
f010219e:	68 6c 5a 10 f0       	push   $0xf0105a6c
f01021a3:	68 f3 5d 10 f0       	push   $0xf0105df3
f01021a8:	68 6d 03 00 00       	push   $0x36d
f01021ad:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01021b2:	e8 12 df ff ff       	call   f01000c9 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021b7:	6a 02                	push   $0x2
f01021b9:	68 00 10 00 00       	push   $0x1000
f01021be:	56                   	push   %esi
f01021bf:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f01021c5:	e8 72 f4 ff ff       	call   f010163c <page_insert>
f01021ca:	83 c4 10             	add    $0x10,%esp
f01021cd:	85 c0                	test   %eax,%eax
f01021cf:	74 19                	je     f01021ea <mem_init+0xb45>
f01021d1:	68 a4 5a 10 f0       	push   $0xf0105aa4
f01021d6:	68 f3 5d 10 f0       	push   $0xf0105df3
f01021db:	68 70 03 00 00       	push   $0x370
f01021e0:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01021e5:	e8 df de ff ff       	call   f01000c9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021ea:	83 ec 04             	sub    $0x4,%esp
f01021ed:	6a 00                	push   $0x0
f01021ef:	68 00 10 00 00       	push   $0x1000
f01021f4:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f01021fa:	e8 97 f2 ff ff       	call   f0101496 <pgdir_walk>
f01021ff:	83 c4 10             	add    $0x10,%esp
f0102202:	f6 00 04             	testb  $0x4,(%eax)
f0102205:	74 19                	je     f0102220 <mem_init+0xb7b>
f0102207:	68 34 5a 10 f0       	push   $0xf0105a34
f010220c:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102211:	68 71 03 00 00       	push   $0x371
f0102216:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010221b:	e8 a9 de ff ff       	call   f01000c9 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102220:	ba 00 00 00 00       	mov    $0x0,%edx
f0102225:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f010222a:	e8 b0 ed ff ff       	call   f0100fdf <check_va2pa>
f010222f:	89 f2                	mov    %esi,%edx
f0102231:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0102237:	c1 fa 03             	sar    $0x3,%edx
f010223a:	c1 e2 0c             	shl    $0xc,%edx
f010223d:	39 d0                	cmp    %edx,%eax
f010223f:	74 19                	je     f010225a <mem_init+0xbb5>
f0102241:	68 e0 5a 10 f0       	push   $0xf0105ae0
f0102246:	68 f3 5d 10 f0       	push   $0xf0105df3
f010224b:	68 74 03 00 00       	push   $0x374
f0102250:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102255:	e8 6f de ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010225a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010225f:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102264:	e8 76 ed ff ff       	call   f0100fdf <check_va2pa>
f0102269:	89 f2                	mov    %esi,%edx
f010226b:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0102271:	c1 fa 03             	sar    $0x3,%edx
f0102274:	c1 e2 0c             	shl    $0xc,%edx
f0102277:	39 d0                	cmp    %edx,%eax
f0102279:	74 19                	je     f0102294 <mem_init+0xbef>
f010227b:	68 0c 5b 10 f0       	push   $0xf0105b0c
f0102280:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102285:	68 75 03 00 00       	push   $0x375
f010228a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010228f:	e8 35 de ff ff       	call   f01000c9 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102294:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102299:	74 19                	je     f01022b4 <mem_init+0xc0f>
f010229b:	68 e4 5f 10 f0       	push   $0xf0105fe4
f01022a0:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022a5:	68 77 03 00 00       	push   $0x377
f01022aa:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022af:	e8 15 de ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f01022b4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b9:	74 19                	je     f01022d4 <mem_init+0xc2f>
f01022bb:	68 f5 5f 10 f0       	push   $0xf0105ff5
f01022c0:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022c5:	68 78 03 00 00       	push   $0x378
f01022ca:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022cf:	e8 f5 dd ff ff       	call   f01000c9 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022d4:	83 ec 0c             	sub    $0xc,%esp
f01022d7:	6a 00                	push   $0x0
f01022d9:	e8 f0 f0 ff ff       	call   f01013ce <page_alloc>
f01022de:	83 c4 10             	add    $0x10,%esp
f01022e1:	85 c0                	test   %eax,%eax
f01022e3:	74 04                	je     f01022e9 <mem_init+0xc44>
f01022e5:	39 c3                	cmp    %eax,%ebx
f01022e7:	74 19                	je     f0102302 <mem_init+0xc5d>
f01022e9:	68 3c 5b 10 f0       	push   $0xf0105b3c
f01022ee:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022f3:	68 7b 03 00 00       	push   $0x37b
f01022f8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022fd:	e8 c7 dd ff ff       	call   f01000c9 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102302:	83 ec 08             	sub    $0x8,%esp
f0102305:	6a 00                	push   $0x0
f0102307:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f010230d:	e8 dd f2 ff ff       	call   f01015ef <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102312:	ba 00 00 00 00       	mov    $0x0,%edx
f0102317:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f010231c:	e8 be ec ff ff       	call   f0100fdf <check_va2pa>
f0102321:	83 c4 10             	add    $0x10,%esp
f0102324:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102327:	74 19                	je     f0102342 <mem_init+0xc9d>
f0102329:	68 60 5b 10 f0       	push   $0xf0105b60
f010232e:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102333:	68 7f 03 00 00       	push   $0x37f
f0102338:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010233d:	e8 87 dd ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102342:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102347:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f010234c:	e8 8e ec ff ff       	call   f0100fdf <check_va2pa>
f0102351:	89 f2                	mov    %esi,%edx
f0102353:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0102359:	c1 fa 03             	sar    $0x3,%edx
f010235c:	c1 e2 0c             	shl    $0xc,%edx
f010235f:	39 d0                	cmp    %edx,%eax
f0102361:	74 19                	je     f010237c <mem_init+0xcd7>
f0102363:	68 0c 5b 10 f0       	push   $0xf0105b0c
f0102368:	68 f3 5d 10 f0       	push   $0xf0105df3
f010236d:	68 80 03 00 00       	push   $0x380
f0102372:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102377:	e8 4d dd ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 1);
f010237c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102381:	74 19                	je     f010239c <mem_init+0xcf7>
f0102383:	68 9b 5f 10 f0       	push   $0xf0105f9b
f0102388:	68 f3 5d 10 f0       	push   $0xf0105df3
f010238d:	68 81 03 00 00       	push   $0x381
f0102392:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102397:	e8 2d dd ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f010239c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023a1:	74 19                	je     f01023bc <mem_init+0xd17>
f01023a3:	68 f5 5f 10 f0       	push   $0xf0105ff5
f01023a8:	68 f3 5d 10 f0       	push   $0xf0105df3
f01023ad:	68 82 03 00 00       	push   $0x382
f01023b2:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01023b7:	e8 0d dd ff ff       	call   f01000c9 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023bc:	83 ec 08             	sub    $0x8,%esp
f01023bf:	68 00 10 00 00       	push   $0x1000
f01023c4:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f01023ca:	e8 20 f2 ff ff       	call   f01015ef <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01023d4:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f01023d9:	e8 01 ec ff ff       	call   f0100fdf <check_va2pa>
f01023de:	83 c4 10             	add    $0x10,%esp
f01023e1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023e4:	74 19                	je     f01023ff <mem_init+0xd5a>
f01023e6:	68 60 5b 10 f0       	push   $0xf0105b60
f01023eb:	68 f3 5d 10 f0       	push   $0xf0105df3
f01023f0:	68 86 03 00 00       	push   $0x386
f01023f5:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01023fa:	e8 ca dc ff ff       	call   f01000c9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01023ff:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102404:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102409:	e8 d1 eb ff ff       	call   f0100fdf <check_va2pa>
f010240e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102411:	74 19                	je     f010242c <mem_init+0xd87>
f0102413:	68 84 5b 10 f0       	push   $0xf0105b84
f0102418:	68 f3 5d 10 f0       	push   $0xf0105df3
f010241d:	68 87 03 00 00       	push   $0x387
f0102422:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102427:	e8 9d dc ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 0);
f010242c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102431:	74 19                	je     f010244c <mem_init+0xda7>
f0102433:	68 06 60 10 f0       	push   $0xf0106006
f0102438:	68 f3 5d 10 f0       	push   $0xf0105df3
f010243d:	68 88 03 00 00       	push   $0x388
f0102442:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102447:	e8 7d dc ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 0);
f010244c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102451:	74 19                	je     f010246c <mem_init+0xdc7>
f0102453:	68 f5 5f 10 f0       	push   $0xf0105ff5
f0102458:	68 f3 5d 10 f0       	push   $0xf0105df3
f010245d:	68 89 03 00 00       	push   $0x389
f0102462:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102467:	e8 5d dc ff ff       	call   f01000c9 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010246c:	83 ec 0c             	sub    $0xc,%esp
f010246f:	6a 00                	push   $0x0
f0102471:	e8 58 ef ff ff       	call   f01013ce <page_alloc>
f0102476:	83 c4 10             	add    $0x10,%esp
f0102479:	85 c0                	test   %eax,%eax
f010247b:	74 04                	je     f0102481 <mem_init+0xddc>
f010247d:	39 c6                	cmp    %eax,%esi
f010247f:	74 19                	je     f010249a <mem_init+0xdf5>
f0102481:	68 ac 5b 10 f0       	push   $0xf0105bac
f0102486:	68 f3 5d 10 f0       	push   $0xf0105df3
f010248b:	68 8c 03 00 00       	push   $0x38c
f0102490:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102495:	e8 2f dc ff ff       	call   f01000c9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010249a:	83 ec 0c             	sub    $0xc,%esp
f010249d:	6a 00                	push   $0x0
f010249f:	e8 2a ef ff ff       	call   f01013ce <page_alloc>
f01024a4:	83 c4 10             	add    $0x10,%esp
f01024a7:	85 c0                	test   %eax,%eax
f01024a9:	74 19                	je     f01024c4 <mem_init+0xe1f>
f01024ab:	68 49 5f 10 f0       	push   $0xf0105f49
f01024b0:	68 f3 5d 10 f0       	push   $0xf0105df3
f01024b5:	68 8f 03 00 00       	push   $0x38f
f01024ba:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01024bf:	e8 05 dc ff ff       	call   f01000c9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024c4:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f01024c9:	8b 08                	mov    (%eax),%ecx
f01024cb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024d1:	89 fa                	mov    %edi,%edx
f01024d3:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f01024d9:	c1 fa 03             	sar    $0x3,%edx
f01024dc:	c1 e2 0c             	shl    $0xc,%edx
f01024df:	39 d1                	cmp    %edx,%ecx
f01024e1:	74 19                	je     f01024fc <mem_init+0xe57>
f01024e3:	68 88 58 10 f0       	push   $0xf0105888
f01024e8:	68 f3 5d 10 f0       	push   $0xf0105df3
f01024ed:	68 92 03 00 00       	push   $0x392
f01024f2:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01024f7:	e8 cd db ff ff       	call   f01000c9 <_panic>
	kern_pgdir[0] = 0;
f01024fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102502:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102507:	74 19                	je     f0102522 <mem_init+0xe7d>
f0102509:	68 ac 5f 10 f0       	push   $0xf0105fac
f010250e:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102513:	68 94 03 00 00       	push   $0x394
f0102518:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010251d:	e8 a7 db ff ff       	call   f01000c9 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f0102522:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102527:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010252d:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f0102533:	89 f8                	mov    %edi,%eax
f0102535:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f010253b:	c1 f8 03             	sar    $0x3,%eax
f010253e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102541:	89 c2                	mov    %eax,%edx
f0102543:	c1 ea 0c             	shr    $0xc,%edx
f0102546:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f010254c:	72 12                	jb     f0102560 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010254e:	50                   	push   %eax
f010254f:	68 6c 56 10 f0       	push   $0xf010566c
f0102554:	6a 56                	push   $0x56
f0102556:	68 d9 5d 10 f0       	push   $0xf0105dd9
f010255b:	e8 69 db ff ff       	call   f01000c9 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102560:	83 ec 04             	sub    $0x4,%esp
f0102563:	68 00 10 00 00       	push   $0x1000
f0102568:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010256d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102572:	50                   	push   %eax
f0102573:	e8 d9 21 00 00       	call   f0104751 <memset>
	page_free(pp0);
f0102578:	89 3c 24             	mov    %edi,(%esp)
f010257b:	e8 d8 ee ff ff       	call   f0101458 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102580:	83 c4 0c             	add    $0xc,%esp
f0102583:	6a 01                	push   $0x1
f0102585:	6a 00                	push   $0x0
f0102587:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f010258d:	e8 04 ef ff ff       	call   f0101496 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102592:	89 fa                	mov    %edi,%edx
f0102594:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f010259a:	c1 fa 03             	sar    $0x3,%edx
f010259d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025a0:	89 d0                	mov    %edx,%eax
f01025a2:	c1 e8 0c             	shr    $0xc,%eax
f01025a5:	83 c4 10             	add    $0x10,%esp
f01025a8:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f01025ae:	72 12                	jb     f01025c2 <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025b0:	52                   	push   %edx
f01025b1:	68 6c 56 10 f0       	push   $0xf010566c
f01025b6:	6a 56                	push   $0x56
f01025b8:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01025bd:	e8 07 db ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f01025c2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025cb:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01025d2:	75 11                	jne    f01025e5 <mem_init+0xf40>
f01025d4:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01025da:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025e0:	f6 00 01             	testb  $0x1,(%eax)
f01025e3:	74 19                	je     f01025fe <mem_init+0xf59>
f01025e5:	68 17 60 10 f0       	push   $0xf0106017
f01025ea:	68 f3 5d 10 f0       	push   $0xf0105df3
f01025ef:	68 a0 03 00 00       	push   $0x3a0
f01025f4:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01025f9:	e8 cb da ff ff       	call   f01000c9 <_panic>
f01025fe:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102601:	39 d0                	cmp    %edx,%eax
f0102603:	75 db                	jne    f01025e0 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102605:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f010260a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102610:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102616:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102619:	89 0d 10 93 1d f0    	mov    %ecx,0xf01d9310

	// free the pages we took
	page_free(pp0);
f010261f:	83 ec 0c             	sub    $0xc,%esp
f0102622:	57                   	push   %edi
f0102623:	e8 30 ee ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0102628:	89 34 24             	mov    %esi,(%esp)
f010262b:	e8 28 ee ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f0102630:	89 1c 24             	mov    %ebx,(%esp)
f0102633:	e8 20 ee ff ff       	call   f0101458 <page_free>

	cprintf("check_page() succeeded!\n");
f0102638:	c7 04 24 2e 60 10 f0 	movl   $0xf010602e,(%esp)
f010263f:	e8 e1 0e 00 00       	call   f0103525 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102644:	a1 ec 9f 1d f0       	mov    0xf01d9fec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102649:	83 c4 10             	add    $0x10,%esp
f010264c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102651:	77 15                	ja     f0102668 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102653:	50                   	push   %eax
f0102654:	68 9c 54 10 f0       	push   $0xf010549c
f0102659:	68 b7 00 00 00       	push   $0xb7
f010265e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102663:	e8 61 da ff ff       	call   f01000c9 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102668:	8b 15 e4 9f 1d f0    	mov    0xf01d9fe4,%edx
f010266e:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102675:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102678:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010267e:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102680:	05 00 00 00 10       	add    $0x10000000,%eax
f0102685:	50                   	push   %eax
f0102686:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010268b:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102690:	e8 98 ee ff ff       	call   f010152d <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102695:	a1 1c 93 1d f0       	mov    0xf01d931c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010269a:	83 c4 10             	add    $0x10,%esp
f010269d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026a2:	77 15                	ja     f01026b9 <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a4:	50                   	push   %eax
f01026a5:	68 9c 54 10 f0       	push   $0xf010549c
f01026aa:	68 c4 00 00 00       	push   $0xc4
f01026af:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01026b4:	e8 10 da ff ff       	call   f01000c9 <_panic>
f01026b9:	83 ec 08             	sub    $0x8,%esp
f01026bc:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026be:	05 00 00 00 10       	add    $0x10000000,%eax
f01026c3:	50                   	push   %eax
f01026c4:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026c9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026ce:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f01026d3:	e8 55 ee ff ff       	call   f010152d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026d8:	83 c4 10             	add    $0x10,%esp
f01026db:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01026e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026e5:	77 15                	ja     f01026fc <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e7:	50                   	push   %eax
f01026e8:	68 9c 54 10 f0       	push   $0xf010549c
f01026ed:	68 d5 00 00 00       	push   $0xd5
f01026f2:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01026f7:	e8 cd d9 ff ff       	call   f01000c9 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01026fc:	83 ec 08             	sub    $0x8,%esp
f01026ff:	6a 02                	push   $0x2
f0102701:	68 00 90 11 00       	push   $0x119000
f0102706:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010270b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102710:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102715:	e8 13 ee ff ff       	call   f010152d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010271a:	83 c4 08             	add    $0x8,%esp
f010271d:	6a 02                	push   $0x2
f010271f:	6a 00                	push   $0x0
f0102721:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102726:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010272b:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102730:	e8 f8 ed ff ff       	call   f010152d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102735:	8b 1d e8 9f 1d f0    	mov    0xf01d9fe8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010273b:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f0102740:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102747:	83 c4 10             	add    $0x10,%esp
f010274a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102750:	74 63                	je     f01027b5 <mem_init+0x1110>
f0102752:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102757:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010275d:	89 d8                	mov    %ebx,%eax
f010275f:	e8 7b e8 ff ff       	call   f0100fdf <check_va2pa>
f0102764:	8b 15 ec 9f 1d f0    	mov    0xf01d9fec,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010276a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102770:	77 15                	ja     f0102787 <mem_init+0x10e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102772:	52                   	push   %edx
f0102773:	68 9c 54 10 f0       	push   $0xf010549c
f0102778:	68 e8 02 00 00       	push   $0x2e8
f010277d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102782:	e8 42 d9 ff ff       	call   f01000c9 <_panic>
f0102787:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010278e:	39 d0                	cmp    %edx,%eax
f0102790:	74 19                	je     f01027ab <mem_init+0x1106>
f0102792:	68 d0 5b 10 f0       	push   $0xf0105bd0
f0102797:	68 f3 5d 10 f0       	push   $0xf0105df3
f010279c:	68 e8 02 00 00       	push   $0x2e8
f01027a1:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01027a6:	e8 1e d9 ff ff       	call   f01000c9 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027ab:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027b1:	39 f7                	cmp    %esi,%edi
f01027b3:	77 a2                	ja     f0102757 <mem_init+0x10b2>
f01027b5:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027ba:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f01027c0:	89 d8                	mov    %ebx,%eax
f01027c2:	e8 18 e8 ff ff       	call   f0100fdf <check_va2pa>
f01027c7:	8b 15 1c 93 1d f0    	mov    0xf01d931c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027cd:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027d3:	77 15                	ja     f01027ea <mem_init+0x1145>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027d5:	52                   	push   %edx
f01027d6:	68 9c 54 10 f0       	push   $0xf010549c
f01027db:	68 ed 02 00 00       	push   $0x2ed
f01027e0:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01027e5:	e8 df d8 ff ff       	call   f01000c9 <_panic>
f01027ea:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027f1:	39 d0                	cmp    %edx,%eax
f01027f3:	74 19                	je     f010280e <mem_init+0x1169>
f01027f5:	68 04 5c 10 f0       	push   $0xf0105c04
f01027fa:	68 f3 5d 10 f0       	push   $0xf0105df3
f01027ff:	68 ed 02 00 00       	push   $0x2ed
f0102804:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102809:	e8 bb d8 ff ff       	call   f01000c9 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010280e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102814:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f010281a:	75 9e                	jne    f01027ba <mem_init+0x1115>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010281c:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f0102821:	c1 e0 0c             	shl    $0xc,%eax
f0102824:	74 41                	je     f0102867 <mem_init+0x11c2>
f0102826:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010282b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102831:	89 d8                	mov    %ebx,%eax
f0102833:	e8 a7 e7 ff ff       	call   f0100fdf <check_va2pa>
f0102838:	39 c6                	cmp    %eax,%esi
f010283a:	74 19                	je     f0102855 <mem_init+0x11b0>
f010283c:	68 38 5c 10 f0       	push   $0xf0105c38
f0102841:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102846:	68 f1 02 00 00       	push   $0x2f1
f010284b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102850:	e8 74 d8 ff ff       	call   f01000c9 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102855:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010285b:	a1 e4 9f 1d f0       	mov    0xf01d9fe4,%eax
f0102860:	c1 e0 0c             	shl    $0xc,%eax
f0102863:	39 c6                	cmp    %eax,%esi
f0102865:	72 c4                	jb     f010282b <mem_init+0x1186>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102867:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010286c:	89 d8                	mov    %ebx,%eax
f010286e:	e8 6c e7 ff ff       	call   f0100fdf <check_va2pa>
f0102873:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102878:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
f010287d:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102883:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102886:	39 c2                	cmp    %eax,%edx
f0102888:	74 19                	je     f01028a3 <mem_init+0x11fe>
f010288a:	68 60 5c 10 f0       	push   $0xf0105c60
f010288f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102894:	68 f5 02 00 00       	push   $0x2f5
f0102899:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010289e:	e8 26 d8 ff ff       	call   f01000c9 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028a3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028a9:	0f 85 25 04 00 00    	jne    f0102cd4 <mem_init+0x162f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028af:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028b4:	89 d8                	mov    %ebx,%eax
f01028b6:	e8 24 e7 ff ff       	call   f0100fdf <check_va2pa>
f01028bb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028be:	74 19                	je     f01028d9 <mem_init+0x1234>
f01028c0:	68 a8 5c 10 f0       	push   $0xf0105ca8
f01028c5:	68 f3 5d 10 f0       	push   $0xf0105df3
f01028ca:	68 f6 02 00 00       	push   $0x2f6
f01028cf:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01028d4:	e8 f0 d7 ff ff       	call   f01000c9 <_panic>
f01028d9:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028de:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01028e3:	72 2d                	jb     f0102912 <mem_init+0x126d>
f01028e5:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028ea:	76 07                	jbe    f01028f3 <mem_init+0x124e>
f01028ec:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028f1:	75 1f                	jne    f0102912 <mem_init+0x126d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01028f3:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01028f7:	75 7e                	jne    f0102977 <mem_init+0x12d2>
f01028f9:	68 47 60 10 f0       	push   $0xf0106047
f01028fe:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102903:	68 ff 02 00 00       	push   $0x2ff
f0102908:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010290d:	e8 b7 d7 ff ff       	call   f01000c9 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102912:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102917:	76 3f                	jbe    f0102958 <mem_init+0x12b3>
				assert(pgdir[i] & PTE_P);
f0102919:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010291c:	f6 c2 01             	test   $0x1,%dl
f010291f:	75 19                	jne    f010293a <mem_init+0x1295>
f0102921:	68 47 60 10 f0       	push   $0xf0106047
f0102926:	68 f3 5d 10 f0       	push   $0xf0105df3
f010292b:	68 03 03 00 00       	push   $0x303
f0102930:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102935:	e8 8f d7 ff ff       	call   f01000c9 <_panic>
				assert(pgdir[i] & PTE_W);
f010293a:	f6 c2 02             	test   $0x2,%dl
f010293d:	75 38                	jne    f0102977 <mem_init+0x12d2>
f010293f:	68 58 60 10 f0       	push   $0xf0106058
f0102944:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102949:	68 04 03 00 00       	push   $0x304
f010294e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102953:	e8 71 d7 ff ff       	call   f01000c9 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102958:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010295c:	74 19                	je     f0102977 <mem_init+0x12d2>
f010295e:	68 69 60 10 f0       	push   $0xf0106069
f0102963:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102968:	68 06 03 00 00       	push   $0x306
f010296d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102972:	e8 52 d7 ff ff       	call   f01000c9 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102977:	40                   	inc    %eax
f0102978:	3d 00 04 00 00       	cmp    $0x400,%eax
f010297d:	0f 85 5b ff ff ff    	jne    f01028de <mem_init+0x1239>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102983:	83 ec 0c             	sub    $0xc,%esp
f0102986:	68 d8 5c 10 f0       	push   $0xf0105cd8
f010298b:	e8 95 0b 00 00       	call   f0103525 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102990:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102995:	83 c4 10             	add    $0x10,%esp
f0102998:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010299d:	77 15                	ja     f01029b4 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010299f:	50                   	push   %eax
f01029a0:	68 9c 54 10 f0       	push   $0xf010549c
f01029a5:	68 f2 00 00 00       	push   $0xf2
f01029aa:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01029af:	e8 15 d7 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029b4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029b9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01029c1:	e8 a2 e6 ff ff       	call   f0101068 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029c6:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029c9:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029ce:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029d1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029d4:	83 ec 0c             	sub    $0xc,%esp
f01029d7:	6a 00                	push   $0x0
f01029d9:	e8 f0 e9 ff ff       	call   f01013ce <page_alloc>
f01029de:	89 c6                	mov    %eax,%esi
f01029e0:	83 c4 10             	add    $0x10,%esp
f01029e3:	85 c0                	test   %eax,%eax
f01029e5:	75 19                	jne    f0102a00 <mem_init+0x135b>
f01029e7:	68 9e 5e 10 f0       	push   $0xf0105e9e
f01029ec:	68 f3 5d 10 f0       	push   $0xf0105df3
f01029f1:	68 bb 03 00 00       	push   $0x3bb
f01029f6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01029fb:	e8 c9 d6 ff ff       	call   f01000c9 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a00:	83 ec 0c             	sub    $0xc,%esp
f0102a03:	6a 00                	push   $0x0
f0102a05:	e8 c4 e9 ff ff       	call   f01013ce <page_alloc>
f0102a0a:	89 c7                	mov    %eax,%edi
f0102a0c:	83 c4 10             	add    $0x10,%esp
f0102a0f:	85 c0                	test   %eax,%eax
f0102a11:	75 19                	jne    f0102a2c <mem_init+0x1387>
f0102a13:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0102a18:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102a1d:	68 bc 03 00 00       	push   $0x3bc
f0102a22:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102a27:	e8 9d d6 ff ff       	call   f01000c9 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a2c:	83 ec 0c             	sub    $0xc,%esp
f0102a2f:	6a 00                	push   $0x0
f0102a31:	e8 98 e9 ff ff       	call   f01013ce <page_alloc>
f0102a36:	89 c3                	mov    %eax,%ebx
f0102a38:	83 c4 10             	add    $0x10,%esp
f0102a3b:	85 c0                	test   %eax,%eax
f0102a3d:	75 19                	jne    f0102a58 <mem_init+0x13b3>
f0102a3f:	68 ca 5e 10 f0       	push   $0xf0105eca
f0102a44:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102a49:	68 bd 03 00 00       	push   $0x3bd
f0102a4e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102a53:	e8 71 d6 ff ff       	call   f01000c9 <_panic>
	page_free(pp0);
f0102a58:	83 ec 0c             	sub    $0xc,%esp
f0102a5b:	56                   	push   %esi
f0102a5c:	e8 f7 e9 ff ff       	call   f0101458 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a61:	89 f8                	mov    %edi,%eax
f0102a63:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f0102a69:	c1 f8 03             	sar    $0x3,%eax
f0102a6c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a6f:	89 c2                	mov    %eax,%edx
f0102a71:	c1 ea 0c             	shr    $0xc,%edx
f0102a74:	83 c4 10             	add    $0x10,%esp
f0102a77:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0102a7d:	72 12                	jb     f0102a91 <mem_init+0x13ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a7f:	50                   	push   %eax
f0102a80:	68 6c 56 10 f0       	push   $0xf010566c
f0102a85:	6a 56                	push   $0x56
f0102a87:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102a8c:	e8 38 d6 ff ff       	call   f01000c9 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a91:	83 ec 04             	sub    $0x4,%esp
f0102a94:	68 00 10 00 00       	push   $0x1000
f0102a99:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aa0:	50                   	push   %eax
f0102aa1:	e8 ab 1c 00 00       	call   f0104751 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aa6:	89 d8                	mov    %ebx,%eax
f0102aa8:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f0102aae:	c1 f8 03             	sar    $0x3,%eax
f0102ab1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ab4:	89 c2                	mov    %eax,%edx
f0102ab6:	c1 ea 0c             	shr    $0xc,%edx
f0102ab9:	83 c4 10             	add    $0x10,%esp
f0102abc:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0102ac2:	72 12                	jb     f0102ad6 <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ac4:	50                   	push   %eax
f0102ac5:	68 6c 56 10 f0       	push   $0xf010566c
f0102aca:	6a 56                	push   $0x56
f0102acc:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102ad1:	e8 f3 d5 ff ff       	call   f01000c9 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ad6:	83 ec 04             	sub    $0x4,%esp
f0102ad9:	68 00 10 00 00       	push   $0x1000
f0102ade:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ae0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ae5:	50                   	push   %eax
f0102ae6:	e8 66 1c 00 00       	call   f0104751 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102aeb:	6a 02                	push   $0x2
f0102aed:	68 00 10 00 00       	push   $0x1000
f0102af2:	57                   	push   %edi
f0102af3:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102af9:	e8 3e eb ff ff       	call   f010163c <page_insert>
	assert(pp1->pp_ref == 1);
f0102afe:	83 c4 20             	add    $0x20,%esp
f0102b01:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b06:	74 19                	je     f0102b21 <mem_init+0x147c>
f0102b08:	68 9b 5f 10 f0       	push   $0xf0105f9b
f0102b0d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b12:	68 c2 03 00 00       	push   $0x3c2
f0102b17:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b1c:	e8 a8 d5 ff ff       	call   f01000c9 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b21:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b28:	01 01 01 
f0102b2b:	74 19                	je     f0102b46 <mem_init+0x14a1>
f0102b2d:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102b32:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b37:	68 c3 03 00 00       	push   $0x3c3
f0102b3c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b41:	e8 83 d5 ff ff       	call   f01000c9 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b46:	6a 02                	push   $0x2
f0102b48:	68 00 10 00 00       	push   $0x1000
f0102b4d:	53                   	push   %ebx
f0102b4e:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102b54:	e8 e3 ea ff ff       	call   f010163c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b59:	83 c4 10             	add    $0x10,%esp
f0102b5c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b63:	02 02 02 
f0102b66:	74 19                	je     f0102b81 <mem_init+0x14dc>
f0102b68:	68 1c 5d 10 f0       	push   $0xf0105d1c
f0102b6d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b72:	68 c5 03 00 00       	push   $0x3c5
f0102b77:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b7c:	e8 48 d5 ff ff       	call   f01000c9 <_panic>
	assert(pp2->pp_ref == 1);
f0102b81:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b86:	74 19                	je     f0102ba1 <mem_init+0x14fc>
f0102b88:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0102b8d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b92:	68 c6 03 00 00       	push   $0x3c6
f0102b97:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b9c:	e8 28 d5 ff ff       	call   f01000c9 <_panic>
	assert(pp1->pp_ref == 0);
f0102ba1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ba6:	74 19                	je     f0102bc1 <mem_init+0x151c>
f0102ba8:	68 06 60 10 f0       	push   $0xf0106006
f0102bad:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102bb2:	68 c7 03 00 00       	push   $0x3c7
f0102bb7:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102bbc:	e8 08 d5 ff ff       	call   f01000c9 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bc1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bc8:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bcb:	89 d8                	mov    %ebx,%eax
f0102bcd:	2b 05 ec 9f 1d f0    	sub    0xf01d9fec,%eax
f0102bd3:	c1 f8 03             	sar    $0x3,%eax
f0102bd6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd9:	89 c2                	mov    %eax,%edx
f0102bdb:	c1 ea 0c             	shr    $0xc,%edx
f0102bde:	3b 15 e4 9f 1d f0    	cmp    0xf01d9fe4,%edx
f0102be4:	72 12                	jb     f0102bf8 <mem_init+0x1553>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102be6:	50                   	push   %eax
f0102be7:	68 6c 56 10 f0       	push   $0xf010566c
f0102bec:	6a 56                	push   $0x56
f0102bee:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102bf3:	e8 d1 d4 ff ff       	call   f01000c9 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102bf8:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bff:	03 03 03 
f0102c02:	74 19                	je     f0102c1d <mem_init+0x1578>
f0102c04:	68 40 5d 10 f0       	push   $0xf0105d40
f0102c09:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102c0e:	68 c9 03 00 00       	push   $0x3c9
f0102c13:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102c18:	e8 ac d4 ff ff       	call   f01000c9 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c1d:	83 ec 08             	sub    $0x8,%esp
f0102c20:	68 00 10 00 00       	push   $0x1000
f0102c25:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102c2b:	e8 bf e9 ff ff       	call   f01015ef <page_remove>
	assert(pp2->pp_ref == 0);
f0102c30:	83 c4 10             	add    $0x10,%esp
f0102c33:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c38:	74 19                	je     f0102c53 <mem_init+0x15ae>
f0102c3a:	68 f5 5f 10 f0       	push   $0xf0105ff5
f0102c3f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102c44:	68 cb 03 00 00       	push   $0x3cb
f0102c49:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102c4e:	e8 76 d4 ff ff       	call   f01000c9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c53:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
f0102c58:	8b 08                	mov    (%eax),%ecx
f0102c5a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c60:	89 f2                	mov    %esi,%edx
f0102c62:	2b 15 ec 9f 1d f0    	sub    0xf01d9fec,%edx
f0102c68:	c1 fa 03             	sar    $0x3,%edx
f0102c6b:	c1 e2 0c             	shl    $0xc,%edx
f0102c6e:	39 d1                	cmp    %edx,%ecx
f0102c70:	74 19                	je     f0102c8b <mem_init+0x15e6>
f0102c72:	68 88 58 10 f0       	push   $0xf0105888
f0102c77:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102c7c:	68 ce 03 00 00       	push   $0x3ce
f0102c81:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102c86:	e8 3e d4 ff ff       	call   f01000c9 <_panic>
	kern_pgdir[0] = 0;
f0102c8b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c91:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c96:	74 19                	je     f0102cb1 <mem_init+0x160c>
f0102c98:	68 ac 5f 10 f0       	push   $0xf0105fac
f0102c9d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102ca2:	68 d0 03 00 00       	push   $0x3d0
f0102ca7:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102cac:	e8 18 d4 ff ff       	call   f01000c9 <_panic>
	pp0->pp_ref = 0;
f0102cb1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cb7:	83 ec 0c             	sub    $0xc,%esp
f0102cba:	56                   	push   %esi
f0102cbb:	e8 98 e7 ff ff       	call   f0101458 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cc0:	c7 04 24 6c 5d 10 f0 	movl   $0xf0105d6c,(%esp)
f0102cc7:	e8 59 08 00 00       	call   f0103525 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ccf:	5b                   	pop    %ebx
f0102cd0:	5e                   	pop    %esi
f0102cd1:	5f                   	pop    %edi
f0102cd2:	c9                   	leave  
f0102cd3:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cd4:	89 f2                	mov    %esi,%edx
f0102cd6:	89 d8                	mov    %ebx,%eax
f0102cd8:	e8 02 e3 ff ff       	call   f0100fdf <check_va2pa>
f0102cdd:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ce3:	e9 9b fb ff ff       	jmp    f0102883 <mem_init+0x11de>

f0102ce8 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102ce8:	55                   	push   %ebp
f0102ce9:	89 e5                	mov    %esp,%ebp
f0102ceb:	57                   	push   %edi
f0102cec:	56                   	push   %esi
f0102ced:	53                   	push   %ebx
f0102cee:	83 ec 1c             	sub    $0x1c,%esp
f0102cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cf7:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102cfa:	85 d2                	test   %edx,%edx
f0102cfc:	0f 84 85 00 00 00    	je     f0102d87 <user_mem_check+0x9f>

	perm |= PTE_P;
f0102d02:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d05:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f0102d08:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102d0a:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102d11:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d1a:	89 c2                	mov    %eax,%edx
f0102d1c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d22:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0102d25:	74 67                	je     f0102d8e <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f0102d27:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102d2c:	76 17                	jbe    f0102d45 <user_mem_check+0x5d>
f0102d2e:	eb 08                	jmp    f0102d38 <user_mem_check+0x50>
f0102d30:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d36:	76 0d                	jbe    f0102d45 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f0102d38:	89 1d 0c 93 1d f0    	mov    %ebx,0xf01d930c
			return -E_FAULT;
f0102d3e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d43:	eb 4e                	jmp    f0102d93 <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f0102d45:	83 ec 04             	sub    $0x4,%esp
f0102d48:	6a 00                	push   $0x0
f0102d4a:	53                   	push   %ebx
f0102d4b:	ff 77 5c             	pushl  0x5c(%edi)
f0102d4e:	e8 43 e7 ff ff       	call   f0101496 <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f0102d53:	83 c4 10             	add    $0x10,%esp
f0102d56:	85 c0                	test   %eax,%eax
f0102d58:	74 08                	je     f0102d62 <user_mem_check+0x7a>
f0102d5a:	8b 00                	mov    (%eax),%eax
f0102d5c:	21 f0                	and    %esi,%eax
f0102d5e:	39 c6                	cmp    %eax,%esi
f0102d60:	74 0d                	je     f0102d6f <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0102d62:	89 1d 0c 93 1d f0    	mov    %ebx,0xf01d930c
			return -E_FAULT;
f0102d68:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d6d:	eb 24                	jmp    f0102d93 <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d6f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d75:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102d7b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102d7e:	75 b0                	jne    f0102d30 <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102d80:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d85:	eb 0c                	jmp    f0102d93 <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102d87:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d8c:	eb 05                	jmp    f0102d93 <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102d8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d96:	5b                   	pop    %ebx
f0102d97:	5e                   	pop    %esi
f0102d98:	5f                   	pop    %edi
f0102d99:	c9                   	leave  
f0102d9a:	c3                   	ret    

f0102d9b <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d9b:	55                   	push   %ebp
f0102d9c:	89 e5                	mov    %esp,%ebp
f0102d9e:	53                   	push   %ebx
f0102d9f:	83 ec 04             	sub    $0x4,%esp
f0102da2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102da5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102da8:	83 c8 04             	or     $0x4,%eax
f0102dab:	50                   	push   %eax
f0102dac:	ff 75 10             	pushl  0x10(%ebp)
f0102daf:	ff 75 0c             	pushl  0xc(%ebp)
f0102db2:	53                   	push   %ebx
f0102db3:	e8 30 ff ff ff       	call   f0102ce8 <user_mem_check>
f0102db8:	83 c4 10             	add    $0x10,%esp
f0102dbb:	85 c0                	test   %eax,%eax
f0102dbd:	79 21                	jns    f0102de0 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102dbf:	83 ec 04             	sub    $0x4,%esp
f0102dc2:	ff 35 0c 93 1d f0    	pushl  0xf01d930c
f0102dc8:	ff 73 48             	pushl  0x48(%ebx)
f0102dcb:	68 98 5d 10 f0       	push   $0xf0105d98
f0102dd0:	e8 50 07 00 00       	call   f0103525 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102dd5:	89 1c 24             	mov    %ebx,(%esp)
f0102dd8:	e8 33 06 00 00       	call   f0103410 <env_destroy>
f0102ddd:	83 c4 10             	add    $0x10,%esp
	}
}
f0102de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102de3:	c9                   	leave  
f0102de4:	c3                   	ret    
f0102de5:	00 00                	add    %al,(%eax)
	...

f0102de8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102de8:	55                   	push   %ebp
f0102de9:	89 e5                	mov    %esp,%ebp
f0102deb:	57                   	push   %edi
f0102dec:	56                   	push   %esi
f0102ded:	53                   	push   %ebx
f0102dee:	83 ec 0c             	sub    $0xc,%esp
f0102df1:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102df3:	89 d3                	mov    %edx,%ebx
f0102df5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102dfb:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102e02:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e08:	39 fb                	cmp    %edi,%ebx
f0102e0a:	74 5a                	je     f0102e66 <region_alloc+0x7e>
        pg = page_alloc(1);
f0102e0c:	83 ec 0c             	sub    $0xc,%esp
f0102e0f:	6a 01                	push   $0x1
f0102e11:	e8 b8 e5 ff ff       	call   f01013ce <page_alloc>
        if (pg == NULL) {
f0102e16:	83 c4 10             	add    $0x10,%esp
f0102e19:	85 c0                	test   %eax,%eax
f0102e1b:	75 17                	jne    f0102e34 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102e1d:	83 ec 04             	sub    $0x4,%esp
f0102e20:	68 78 60 10 f0       	push   $0xf0106078
f0102e25:	68 2a 01 00 00       	push   $0x12a
f0102e2a:	68 f2 60 10 f0       	push   $0xf01060f2
f0102e2f:	e8 95 d2 ff ff       	call   f01000c9 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f0102e34:	6a 06                	push   $0x6
f0102e36:	53                   	push   %ebx
f0102e37:	50                   	push   %eax
f0102e38:	ff 76 5c             	pushl  0x5c(%esi)
f0102e3b:	e8 fc e7 ff ff       	call   f010163c <page_insert>
            if (r != 0) {
f0102e40:	83 c4 10             	add    $0x10,%esp
f0102e43:	85 c0                	test   %eax,%eax
f0102e45:	74 15                	je     f0102e5c <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f0102e47:	50                   	push   %eax
f0102e48:	68 9c 60 10 f0       	push   $0xf010609c
f0102e4d:	68 2e 01 00 00       	push   $0x12e
f0102e52:	68 f2 60 10 f0       	push   $0xf01060f2
f0102e57:	e8 6d d2 ff ff       	call   f01000c9 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e5c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e62:	39 df                	cmp    %ebx,%edi
f0102e64:	75 a6                	jne    f0102e0c <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0102e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e69:	5b                   	pop    %ebx
f0102e6a:	5e                   	pop    %esi
f0102e6b:	5f                   	pop    %edi
f0102e6c:	c9                   	leave  
f0102e6d:	c3                   	ret    

f0102e6e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e6e:	55                   	push   %ebp
f0102e6f:	89 e5                	mov    %esp,%ebp
f0102e71:	53                   	push   %ebx
f0102e72:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e78:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e7b:	85 c0                	test   %eax,%eax
f0102e7d:	75 0e                	jne    f0102e8d <envid2env+0x1f>
		*env_store = curenv;
f0102e7f:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f0102e84:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e8b:	eb 55                	jmp    f0102ee2 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e8d:	89 c2                	mov    %eax,%edx
f0102e8f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102e95:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102e98:	c1 e2 05             	shl    $0x5,%edx
f0102e9b:	03 15 1c 93 1d f0    	add    0xf01d931c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ea1:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102ea5:	74 05                	je     f0102eac <envid2env+0x3e>
f0102ea7:	39 42 48             	cmp    %eax,0x48(%edx)
f0102eaa:	74 0d                	je     f0102eb9 <envid2env+0x4b>
		*env_store = 0;
f0102eac:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102eb2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eb7:	eb 29                	jmp    f0102ee2 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eb9:	84 db                	test   %bl,%bl
f0102ebb:	74 1e                	je     f0102edb <envid2env+0x6d>
f0102ebd:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f0102ec2:	39 c2                	cmp    %eax,%edx
f0102ec4:	74 15                	je     f0102edb <envid2env+0x6d>
f0102ec6:	8b 58 48             	mov    0x48(%eax),%ebx
f0102ec9:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102ecc:	74 0d                	je     f0102edb <envid2env+0x6d>
		*env_store = 0;
f0102ece:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102ed4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ed9:	eb 07                	jmp    f0102ee2 <envid2env+0x74>
	}

	*env_store = e;
f0102edb:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ee2:	5b                   	pop    %ebx
f0102ee3:	c9                   	leave  
f0102ee4:	c3                   	ret    

f0102ee5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ee5:	55                   	push   %ebp
f0102ee6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ee8:	b8 30 33 12 f0       	mov    $0xf0123330,%eax
f0102eed:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ef0:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ef5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102ef7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102ef9:	b0 10                	mov    $0x10,%al
f0102efb:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102efd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102eff:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f01:	ea 08 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f08
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f08:	b0 00                	mov    $0x0,%al
f0102f0a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f0d:	c9                   	leave  
f0102f0e:	c3                   	ret    

f0102f0f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f0f:	55                   	push   %ebp
f0102f10:	89 e5                	mov    %esp,%ebp
f0102f12:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102f13:	8b 1d 1c 93 1d f0    	mov    0xf01d931c,%ebx
f0102f19:	89 1d 24 93 1d f0    	mov    %ebx,0xf01d9324
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102f1f:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102f26:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102f2d:	8d 43 60             	lea    0x60(%ebx),%eax
f0102f30:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102f36:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f38:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102f3b:	39 c8                	cmp    %ecx,%eax
f0102f3d:	74 1c                	je     f0102f5b <env_init+0x4c>
        envs[i].env_id = 0;
f0102f3f:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102f46:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102f4d:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102f50:	39 c8                	cmp    %ecx,%eax
f0102f52:	75 0f                	jne    f0102f63 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102f54:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f5b:	e8 85 ff ff ff       	call   f0102ee5 <env_init_percpu>
}
f0102f60:	5b                   	pop    %ebx
f0102f61:	c9                   	leave  
f0102f62:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f63:	89 42 44             	mov    %eax,0x44(%edx)
f0102f66:	89 c2                	mov    %eax,%edx
f0102f68:	eb d5                	jmp    f0102f3f <env_init+0x30>

f0102f6a <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f6a:	55                   	push   %ebp
f0102f6b:	89 e5                	mov    %esp,%ebp
f0102f6d:	56                   	push   %esi
f0102f6e:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f6f:	8b 35 24 93 1d f0    	mov    0xf01d9324,%esi
f0102f75:	85 f6                	test   %esi,%esi
f0102f77:	0f 84 8d 01 00 00    	je     f010310a <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f7d:	83 ec 0c             	sub    $0xc,%esp
f0102f80:	6a 01                	push   $0x1
f0102f82:	e8 47 e4 ff ff       	call   f01013ce <page_alloc>
f0102f87:	89 c3                	mov    %eax,%ebx
f0102f89:	83 c4 10             	add    $0x10,%esp
f0102f8c:	85 c0                	test   %eax,%eax
f0102f8e:	0f 84 7d 01 00 00    	je     f0103111 <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0102f94:	83 ec 0c             	sub    $0xc,%esp
f0102f97:	68 fd 60 10 f0       	push   $0xf01060fd
f0102f9c:	e8 84 05 00 00       	call   f0103525 <cprintf>

    p->pp_ref++;
f0102fa1:	66 ff 43 04          	incw   0x4(%ebx)
f0102fa5:	2b 1d ec 9f 1d f0    	sub    0xf01d9fec,%ebx
f0102fab:	c1 fb 03             	sar    $0x3,%ebx
f0102fae:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fb1:	89 d8                	mov    %ebx,%eax
f0102fb3:	c1 e8 0c             	shr    $0xc,%eax
f0102fb6:	83 c4 10             	add    $0x10,%esp
f0102fb9:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f0102fbf:	72 12                	jb     f0102fd3 <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fc1:	53                   	push   %ebx
f0102fc2:	68 6c 56 10 f0       	push   $0xf010566c
f0102fc7:	6a 56                	push   $0x56
f0102fc9:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102fce:	e8 f6 d0 ff ff       	call   f01000c9 <_panic>
	return (void *)(pa + KERNBASE);
f0102fd3:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0102fd9:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fdc:	83 ec 04             	sub    $0x4,%esp
f0102fdf:	68 00 10 00 00       	push   $0x1000
f0102fe4:	ff 35 e8 9f 1d f0    	pushl  0xf01d9fe8
f0102fea:	53                   	push   %ebx
f0102feb:	e8 15 18 00 00       	call   f0104805 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0102ff0:	83 c4 0c             	add    $0xc,%esp
f0102ff3:	68 ec 0e 00 00       	push   $0xeec
f0102ff8:	6a 00                	push   $0x0
f0102ffa:	ff 76 5c             	pushl  0x5c(%esi)
f0102ffd:	e8 4f 17 00 00       	call   f0104751 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103002:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103005:	83 c4 10             	add    $0x10,%esp
f0103008:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010300d:	77 15                	ja     f0103024 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010300f:	50                   	push   %eax
f0103010:	68 9c 54 10 f0       	push   $0xf010549c
f0103015:	68 cc 00 00 00       	push   $0xcc
f010301a:	68 f2 60 10 f0       	push   $0xf01060f2
f010301f:	e8 a5 d0 ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103024:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010302a:	83 ca 05             	or     $0x5,%edx
f010302d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f0103033:	83 ec 0c             	sub    $0xc,%esp
f0103036:	68 0e 61 10 f0       	push   $0xf010610e
f010303b:	e8 e5 04 00 00       	call   f0103525 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103040:	8b 46 48             	mov    0x48(%esi),%eax
f0103043:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103048:	83 c4 10             	add    $0x10,%esp
f010304b:	89 c1                	mov    %eax,%ecx
f010304d:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103053:	7f 05                	jg     f010305a <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f0103055:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010305a:	89 f0                	mov    %esi,%eax
f010305c:	2b 05 1c 93 1d f0    	sub    0xf01d931c,%eax
f0103062:	c1 f8 05             	sar    $0x5,%eax
f0103065:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103068:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010306b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010306e:	89 d3                	mov    %edx,%ebx
f0103070:	c1 e3 08             	shl    $0x8,%ebx
f0103073:	01 da                	add    %ebx,%edx
f0103075:	89 d3                	mov    %edx,%ebx
f0103077:	c1 e3 10             	shl    $0x10,%ebx
f010307a:	01 da                	add    %ebx,%edx
f010307c:	8d 04 50             	lea    (%eax,%edx,2),%eax
f010307f:	09 c1                	or     %eax,%ecx
f0103081:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103084:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103087:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010308a:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103091:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103098:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010309f:	83 ec 04             	sub    $0x4,%esp
f01030a2:	6a 44                	push   $0x44
f01030a4:	6a 00                	push   $0x0
f01030a6:	56                   	push   %esi
f01030a7:	e8 a5 16 00 00       	call   f0104751 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030ac:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01030b2:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01030b8:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01030be:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01030c5:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01030cb:	8b 46 44             	mov    0x44(%esi),%eax
f01030ce:	a3 24 93 1d f0       	mov    %eax,0xf01d9324
	*newenv_store = e;
f01030d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01030d6:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030d8:	8b 56 48             	mov    0x48(%esi),%edx
f01030db:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f01030e0:	83 c4 10             	add    $0x10,%esp
f01030e3:	85 c0                	test   %eax,%eax
f01030e5:	74 05                	je     f01030ec <env_alloc+0x182>
f01030e7:	8b 40 48             	mov    0x48(%eax),%eax
f01030ea:	eb 05                	jmp    f01030f1 <env_alloc+0x187>
f01030ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01030f1:	83 ec 04             	sub    $0x4,%esp
f01030f4:	52                   	push   %edx
f01030f5:	50                   	push   %eax
f01030f6:	68 20 61 10 f0       	push   $0xf0106120
f01030fb:	e8 25 04 00 00       	call   f0103525 <cprintf>
	return 0;
f0103100:	83 c4 10             	add    $0x10,%esp
f0103103:	b8 00 00 00 00       	mov    $0x0,%eax
f0103108:	eb 0c                	jmp    f0103116 <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010310a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010310f:	eb 05                	jmp    f0103116 <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103111:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103116:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103119:	5b                   	pop    %ebx
f010311a:	5e                   	pop    %esi
f010311b:	c9                   	leave  
f010311c:	c3                   	ret    

f010311d <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010311d:	55                   	push   %ebp
f010311e:	89 e5                	mov    %esp,%ebp
f0103120:	57                   	push   %edi
f0103121:	56                   	push   %esi
f0103122:	53                   	push   %ebx
f0103123:	83 ec 34             	sub    $0x34,%esp
f0103126:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103129:	6a 00                	push   $0x0
f010312b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010312e:	50                   	push   %eax
f010312f:	e8 36 fe ff ff       	call   f0102f6a <env_alloc>
    if (r < 0) {
f0103134:	83 c4 10             	add    $0x10,%esp
f0103137:	85 c0                	test   %eax,%eax
f0103139:	79 15                	jns    f0103150 <env_create+0x33>
        panic("env_create: %e\n", r);
f010313b:	50                   	push   %eax
f010313c:	68 35 61 10 f0       	push   $0xf0106135
f0103141:	68 98 01 00 00       	push   $0x198
f0103146:	68 f2 60 10 f0       	push   $0xf01060f2
f010314b:	e8 79 cf ff ff       	call   f01000c9 <_panic>
    }
    load_icode(e, binary, size);
f0103150:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103153:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103156:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010315c:	74 17                	je     f0103175 <env_create+0x58>
        panic("error elf magic number\n");
f010315e:	83 ec 04             	sub    $0x4,%esp
f0103161:	68 45 61 10 f0       	push   $0xf0106145
f0103166:	68 6d 01 00 00       	push   $0x16d
f010316b:	68 f2 60 10 f0       	push   $0xf01060f2
f0103170:	e8 54 cf ff ff       	call   f01000c9 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103175:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f0103178:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f010317b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010317e:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103181:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103186:	77 15                	ja     f010319d <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103188:	50                   	push   %eax
f0103189:	68 9c 54 10 f0       	push   $0xf010549c
f010318e:	68 73 01 00 00       	push   $0x173
f0103193:	68 f2 60 10 f0       	push   $0xf01060f2
f0103198:	e8 2c cf ff ff       	call   f01000c9 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010319d:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01031a0:	0f b7 ff             	movzwl %di,%edi
f01031a3:	c1 e7 05             	shl    $0x5,%edi
f01031a6:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01031a9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031ae:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01031b1:	39 fb                	cmp    %edi,%ebx
f01031b3:	73 48                	jae    f01031fd <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01031b5:	83 3b 01             	cmpl   $0x1,(%ebx)
f01031b8:	75 3c                	jne    f01031f6 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01031ba:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01031bd:	8b 53 08             	mov    0x8(%ebx),%edx
f01031c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031c3:	e8 20 fc ff ff       	call   f0102de8 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01031c8:	83 ec 04             	sub    $0x4,%esp
f01031cb:	ff 73 10             	pushl  0x10(%ebx)
f01031ce:	89 f0                	mov    %esi,%eax
f01031d0:	03 43 04             	add    0x4(%ebx),%eax
f01031d3:	50                   	push   %eax
f01031d4:	ff 73 08             	pushl  0x8(%ebx)
f01031d7:	e8 29 16 00 00       	call   f0104805 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01031dc:	8b 43 10             	mov    0x10(%ebx),%eax
f01031df:	83 c4 0c             	add    $0xc,%esp
f01031e2:	8b 53 14             	mov    0x14(%ebx),%edx
f01031e5:	29 c2                	sub    %eax,%edx
f01031e7:	52                   	push   %edx
f01031e8:	6a 00                	push   $0x0
f01031ea:	03 43 08             	add    0x8(%ebx),%eax
f01031ed:	50                   	push   %eax
f01031ee:	e8 5e 15 00 00       	call   f0104751 <memset>
f01031f3:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01031f6:	83 c3 20             	add    $0x20,%ebx
f01031f9:	39 df                	cmp    %ebx,%edi
f01031fb:	77 b8                	ja     f01031b5 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f01031fd:	8b 46 18             	mov    0x18(%esi),%eax
f0103200:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103203:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103206:	a1 e8 9f 1d f0       	mov    0xf01d9fe8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010320b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103210:	77 15                	ja     f0103227 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103212:	50                   	push   %eax
f0103213:	68 9c 54 10 f0       	push   $0xf010549c
f0103218:	68 7f 01 00 00       	push   $0x17f
f010321d:	68 f2 60 10 f0       	push   $0xf01060f2
f0103222:	e8 a2 ce ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103227:	05 00 00 00 10       	add    $0x10000000,%eax
f010322c:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010322f:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103234:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103239:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010323c:	e8 a7 fb ff ff       	call   f0102de8 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103244:	8b 55 10             	mov    0x10(%ebp),%edx
f0103247:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f010324a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010324d:	5b                   	pop    %ebx
f010324e:	5e                   	pop    %esi
f010324f:	5f                   	pop    %edi
f0103250:	c9                   	leave  
f0103251:	c3                   	ret    

f0103252 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103252:	55                   	push   %ebp
f0103253:	89 e5                	mov    %esp,%ebp
f0103255:	57                   	push   %edi
f0103256:	56                   	push   %esi
f0103257:	53                   	push   %ebx
f0103258:	83 ec 1c             	sub    $0x1c,%esp
f010325b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010325e:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f0103263:	39 c7                	cmp    %eax,%edi
f0103265:	75 2c                	jne    f0103293 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0103267:	8b 15 e8 9f 1d f0    	mov    0xf01d9fe8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010326d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103273:	77 15                	ja     f010328a <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103275:	52                   	push   %edx
f0103276:	68 9c 54 10 f0       	push   $0xf010549c
f010327b:	68 ae 01 00 00       	push   $0x1ae
f0103280:	68 f2 60 10 f0       	push   $0xf01060f2
f0103285:	e8 3f ce ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010328a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103290:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103293:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103296:	ba 00 00 00 00       	mov    $0x0,%edx
f010329b:	85 c0                	test   %eax,%eax
f010329d:	74 03                	je     f01032a2 <env_free+0x50>
f010329f:	8b 50 48             	mov    0x48(%eax),%edx
f01032a2:	83 ec 04             	sub    $0x4,%esp
f01032a5:	51                   	push   %ecx
f01032a6:	52                   	push   %edx
f01032a7:	68 5d 61 10 f0       	push   $0xf010615d
f01032ac:	e8 74 02 00 00       	call   f0103525 <cprintf>
f01032b1:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032b4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032be:	c1 e0 02             	shl    $0x2,%eax
f01032c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032c4:	8b 47 5c             	mov    0x5c(%edi),%eax
f01032c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032ca:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01032cd:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032d3:	0f 84 ab 00 00 00    	je     f0103384 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032d9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032df:	89 f0                	mov    %esi,%eax
f01032e1:	c1 e8 0c             	shr    $0xc,%eax
f01032e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032e7:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f01032ed:	72 15                	jb     f0103304 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ef:	56                   	push   %esi
f01032f0:	68 6c 56 10 f0       	push   $0xf010566c
f01032f5:	68 bd 01 00 00       	push   $0x1bd
f01032fa:	68 f2 60 10 f0       	push   $0xf01060f2
f01032ff:	e8 c5 cd ff ff       	call   f01000c9 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103304:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103307:	c1 e2 16             	shl    $0x16,%edx
f010330a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010330d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103312:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103319:	01 
f010331a:	74 17                	je     f0103333 <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010331c:	83 ec 08             	sub    $0x8,%esp
f010331f:	89 d8                	mov    %ebx,%eax
f0103321:	c1 e0 0c             	shl    $0xc,%eax
f0103324:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103327:	50                   	push   %eax
f0103328:	ff 77 5c             	pushl  0x5c(%edi)
f010332b:	e8 bf e2 ff ff       	call   f01015ef <page_remove>
f0103330:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103333:	43                   	inc    %ebx
f0103334:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010333a:	75 d6                	jne    f0103312 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010333c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010333f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103342:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103349:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010334c:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f0103352:	72 14                	jb     f0103368 <env_free+0x116>
		panic("pa2page called with invalid pa");
f0103354:	83 ec 04             	sub    $0x4,%esp
f0103357:	68 54 57 10 f0       	push   $0xf0105754
f010335c:	6a 4f                	push   $0x4f
f010335e:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0103363:	e8 61 cd ff ff       	call   f01000c9 <_panic>
		page_decref(pa2page(pa));
f0103368:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010336b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010336e:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103375:	03 05 ec 9f 1d f0    	add    0xf01d9fec,%eax
f010337b:	50                   	push   %eax
f010337c:	e8 f7 e0 ff ff       	call   f0101478 <page_decref>
f0103381:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103384:	ff 45 e0             	incl   -0x20(%ebp)
f0103387:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010338e:	0f 85 27 ff ff ff    	jne    f01032bb <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103394:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103397:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339c:	77 15                	ja     f01033b3 <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010339e:	50                   	push   %eax
f010339f:	68 9c 54 10 f0       	push   $0xf010549c
f01033a4:	68 cb 01 00 00       	push   $0x1cb
f01033a9:	68 f2 60 10 f0       	push   $0xf01060f2
f01033ae:	e8 16 cd ff ff       	call   f01000c9 <_panic>
	e->env_pgdir = 0;
f01033b3:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033ba:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033bf:	c1 e8 0c             	shr    $0xc,%eax
f01033c2:	3b 05 e4 9f 1d f0    	cmp    0xf01d9fe4,%eax
f01033c8:	72 14                	jb     f01033de <env_free+0x18c>
		panic("pa2page called with invalid pa");
f01033ca:	83 ec 04             	sub    $0x4,%esp
f01033cd:	68 54 57 10 f0       	push   $0xf0105754
f01033d2:	6a 4f                	push   $0x4f
f01033d4:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01033d9:	e8 eb cc ff ff       	call   f01000c9 <_panic>
	page_decref(pa2page(pa));
f01033de:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033e1:	c1 e0 03             	shl    $0x3,%eax
f01033e4:	03 05 ec 9f 1d f0    	add    0xf01d9fec,%eax
f01033ea:	50                   	push   %eax
f01033eb:	e8 88 e0 ff ff       	call   f0101478 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033f0:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033f7:	a1 24 93 1d f0       	mov    0xf01d9324,%eax
f01033fc:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033ff:	89 3d 24 93 1d f0    	mov    %edi,0xf01d9324
f0103405:	83 c4 10             	add    $0x10,%esp
}
f0103408:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010340b:	5b                   	pop    %ebx
f010340c:	5e                   	pop    %esi
f010340d:	5f                   	pop    %edi
f010340e:	c9                   	leave  
f010340f:	c3                   	ret    

f0103410 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103410:	55                   	push   %ebp
f0103411:	89 e5                	mov    %esp,%ebp
f0103413:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103416:	ff 75 08             	pushl  0x8(%ebp)
f0103419:	e8 34 fe ff ff       	call   f0103252 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010341e:	c7 04 24 bc 60 10 f0 	movl   $0xf01060bc,(%esp)
f0103425:	e8 fb 00 00 00       	call   f0103525 <cprintf>
f010342a:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010342d:	83 ec 0c             	sub    $0xc,%esp
f0103430:	6a 00                	push   $0x0
f0103432:	e8 32 da ff ff       	call   f0100e69 <monitor>
f0103437:	83 c4 10             	add    $0x10,%esp
f010343a:	eb f1                	jmp    f010342d <env_destroy+0x1d>

f010343c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010343c:	55                   	push   %ebp
f010343d:	89 e5                	mov    %esp,%ebp
f010343f:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103442:	8b 65 08             	mov    0x8(%ebp),%esp
f0103445:	61                   	popa   
f0103446:	07                   	pop    %es
f0103447:	1f                   	pop    %ds
f0103448:	83 c4 08             	add    $0x8,%esp
f010344b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010344c:	68 73 61 10 f0       	push   $0xf0106173
f0103451:	68 f3 01 00 00       	push   $0x1f3
f0103456:	68 f2 60 10 f0       	push   $0xf01060f2
f010345b:	e8 69 cc ff ff       	call   f01000c9 <_panic>

f0103460 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103460:	55                   	push   %ebp
f0103461:	89 e5                	mov    %esp,%ebp
f0103463:	83 ec 08             	sub    $0x8,%esp
f0103466:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f0103469:	8b 15 20 93 1d f0    	mov    0xf01d9320,%edx
f010346f:	85 d2                	test   %edx,%edx
f0103471:	74 0d                	je     f0103480 <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103473:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103477:	75 07                	jne    f0103480 <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f0103479:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103480:	a3 20 93 1d f0       	mov    %eax,0xf01d9320
    curenv->env_status = ENV_RUNNING;
f0103485:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f010348c:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f010348f:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103492:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103498:	77 15                	ja     f01034af <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349a:	52                   	push   %edx
f010349b:	68 9c 54 10 f0       	push   $0xf010549c
f01034a0:	68 1e 02 00 00       	push   $0x21e
f01034a5:	68 f2 60 10 f0       	push   $0xf01060f2
f01034aa:	e8 1a cc ff ff       	call   f01000c9 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034af:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01034b5:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f01034b8:	83 ec 0c             	sub    $0xc,%esp
f01034bb:	50                   	push   %eax
f01034bc:	e8 7b ff ff ff       	call   f010343c <env_pop_tf>
f01034c1:	00 00                	add    %al,(%eax)
	...

f01034c4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034c4:	55                   	push   %ebp
f01034c5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034c7:	ba 70 00 00 00       	mov    $0x70,%edx
f01034cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01034cf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034d0:	b2 71                	mov    $0x71,%dl
f01034d2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034d3:	0f b6 c0             	movzbl %al,%eax
}
f01034d6:	c9                   	leave  
f01034d7:	c3                   	ret    

f01034d8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034d8:	55                   	push   %ebp
f01034d9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034db:	ba 70 00 00 00       	mov    $0x70,%edx
f01034e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034e3:	ee                   	out    %al,(%dx)
f01034e4:	b2 71                	mov    $0x71,%dl
f01034e6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034e9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034ea:	c9                   	leave  
f01034eb:	c3                   	ret    

f01034ec <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034ec:	55                   	push   %ebp
f01034ed:	89 e5                	mov    %esp,%ebp
f01034ef:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01034f2:	ff 75 08             	pushl  0x8(%ebp)
f01034f5:	e8 ec d0 ff ff       	call   f01005e6 <cputchar>
f01034fa:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01034fd:	c9                   	leave  
f01034fe:	c3                   	ret    

f01034ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01034ff:	55                   	push   %ebp
f0103500:	89 e5                	mov    %esp,%ebp
f0103502:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103505:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010350c:	ff 75 0c             	pushl  0xc(%ebp)
f010350f:	ff 75 08             	pushl  0x8(%ebp)
f0103512:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103515:	50                   	push   %eax
f0103516:	68 ec 34 10 f0       	push   $0xf01034ec
f010351b:	e8 99 0b 00 00       	call   f01040b9 <vprintfmt>
	return cnt;
}
f0103520:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103523:	c9                   	leave  
f0103524:	c3                   	ret    

f0103525 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103525:	55                   	push   %ebp
f0103526:	89 e5                	mov    %esp,%ebp
f0103528:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010352b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010352e:	50                   	push   %eax
f010352f:	ff 75 08             	pushl  0x8(%ebp)
f0103532:	e8 c8 ff ff ff       	call   f01034ff <vcprintf>
	va_end(ap);

	return cnt;
}
f0103537:	c9                   	leave  
f0103538:	c3                   	ret    
f0103539:	00 00                	add    %al,(%eax)
	...

f010353c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010353c:	55                   	push   %ebp
f010353d:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010353f:	c7 05 64 9b 1d f0 00 	movl   $0xf0000000,0xf01d9b64
f0103546:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103549:	66 c7 05 68 9b 1d f0 	movw   $0x10,0xf01d9b68
f0103550:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103552:	66 c7 05 28 33 12 f0 	movw   $0x68,0xf0123328
f0103559:	68 00 
f010355b:	b8 60 9b 1d f0       	mov    $0xf01d9b60,%eax
f0103560:	66 a3 2a 33 12 f0    	mov    %ax,0xf012332a
f0103566:	89 c2                	mov    %eax,%edx
f0103568:	c1 ea 10             	shr    $0x10,%edx
f010356b:	88 15 2c 33 12 f0    	mov    %dl,0xf012332c
f0103571:	c6 05 2e 33 12 f0 40 	movb   $0x40,0xf012332e
f0103578:	c1 e8 18             	shr    $0x18,%eax
f010357b:	a2 2f 33 12 f0       	mov    %al,0xf012332f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103580:	c6 05 2d 33 12 f0 89 	movb   $0x89,0xf012332d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103587:	b8 28 00 00 00       	mov    $0x28,%eax
f010358c:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010358f:	b8 38 33 12 f0       	mov    $0xf0123338,%eax
f0103594:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103597:	c9                   	leave  
f0103598:	c3                   	ret    

f0103599 <trap_init>:
}


void
trap_init(void)
{
f0103599:	55                   	push   %ebp
f010359a:	89 e5                	mov    %esp,%ebp
f010359c:	ba 01 00 00 00       	mov    $0x1,%edx
f01035a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01035a6:	eb 02                	jmp    f01035aa <trap_init+0x11>
f01035a8:	40                   	inc    %eax
f01035a9:	42                   	inc    %edx
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f01035aa:	83 f8 03             	cmp    $0x3,%eax
f01035ad:	75 30                	jne    f01035df <trap_init+0x46>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f01035af:	8b 0d 4c 33 12 f0    	mov    0xf012334c,%ecx
f01035b5:	66 89 0d 58 93 1d f0 	mov    %cx,0xf01d9358
f01035bc:	66 c7 05 5a 93 1d f0 	movw   $0x8,0xf01d935a
f01035c3:	08 00 
f01035c5:	c6 05 5c 93 1d f0 00 	movb   $0x0,0xf01d935c
f01035cc:	c6 05 5d 93 1d f0 ee 	movb   $0xee,0xf01d935d
f01035d3:	c1 e9 10             	shr    $0x10,%ecx
f01035d6:	66 89 0d 5e 93 1d f0 	mov    %cx,0xf01d935e
f01035dd:	eb c9                	jmp    f01035a8 <trap_init+0xf>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f01035df:	8b 0c 85 40 33 12 f0 	mov    -0xfedccc0(,%eax,4),%ecx
f01035e6:	66 89 0c c5 40 93 1d 	mov    %cx,-0xfe26cc0(,%eax,8)
f01035ed:	f0 
f01035ee:	66 c7 04 c5 42 93 1d 	movw   $0x8,-0xfe26cbe(,%eax,8)
f01035f5:	f0 08 00 
f01035f8:	c6 04 c5 44 93 1d f0 	movb   $0x0,-0xfe26cbc(,%eax,8)
f01035ff:	00 
f0103600:	c6 04 c5 45 93 1d f0 	movb   $0x8e,-0xfe26cbb(,%eax,8)
f0103607:	8e 
f0103608:	c1 e9 10             	shr    $0x10,%ecx
f010360b:	66 89 0c c5 46 93 1d 	mov    %cx,-0xfe26cba(,%eax,8)
f0103612:	f0 
    */
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f0103613:	83 fa 14             	cmp    $0x14,%edx
f0103616:	75 90                	jne    f01035a8 <trap_init+0xf>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103618:	b8 90 33 12 f0       	mov    $0xf0123390,%eax
f010361d:	66 a3 c0 94 1d f0    	mov    %ax,0xf01d94c0
f0103623:	66 c7 05 c2 94 1d f0 	movw   $0x8,0xf01d94c2
f010362a:	08 00 
f010362c:	c6 05 c4 94 1d f0 00 	movb   $0x0,0xf01d94c4
f0103633:	c6 05 c5 94 1d f0 ee 	movb   $0xee,0xf01d94c5
f010363a:	c1 e8 10             	shr    $0x10,%eax
f010363d:	66 a3 c6 94 1d f0    	mov    %ax,0xf01d94c6

	// Per-CPU setup 
	trap_init_percpu();
f0103643:	e8 f4 fe ff ff       	call   f010353c <trap_init_percpu>
}
f0103648:	c9                   	leave  
f0103649:	c3                   	ret    

f010364a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010364a:	55                   	push   %ebp
f010364b:	89 e5                	mov    %esp,%ebp
f010364d:	53                   	push   %ebx
f010364e:	83 ec 0c             	sub    $0xc,%esp
f0103651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103654:	ff 33                	pushl  (%ebx)
f0103656:	68 7f 61 10 f0       	push   $0xf010617f
f010365b:	e8 c5 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103660:	83 c4 08             	add    $0x8,%esp
f0103663:	ff 73 04             	pushl  0x4(%ebx)
f0103666:	68 8e 61 10 f0       	push   $0xf010618e
f010366b:	e8 b5 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103670:	83 c4 08             	add    $0x8,%esp
f0103673:	ff 73 08             	pushl  0x8(%ebx)
f0103676:	68 9d 61 10 f0       	push   $0xf010619d
f010367b:	e8 a5 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103680:	83 c4 08             	add    $0x8,%esp
f0103683:	ff 73 0c             	pushl  0xc(%ebx)
f0103686:	68 ac 61 10 f0       	push   $0xf01061ac
f010368b:	e8 95 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103690:	83 c4 08             	add    $0x8,%esp
f0103693:	ff 73 10             	pushl  0x10(%ebx)
f0103696:	68 bb 61 10 f0       	push   $0xf01061bb
f010369b:	e8 85 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036a0:	83 c4 08             	add    $0x8,%esp
f01036a3:	ff 73 14             	pushl  0x14(%ebx)
f01036a6:	68 ca 61 10 f0       	push   $0xf01061ca
f01036ab:	e8 75 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036b0:	83 c4 08             	add    $0x8,%esp
f01036b3:	ff 73 18             	pushl  0x18(%ebx)
f01036b6:	68 d9 61 10 f0       	push   $0xf01061d9
f01036bb:	e8 65 fe ff ff       	call   f0103525 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036c0:	83 c4 08             	add    $0x8,%esp
f01036c3:	ff 73 1c             	pushl  0x1c(%ebx)
f01036c6:	68 e8 61 10 f0       	push   $0xf01061e8
f01036cb:	e8 55 fe ff ff       	call   f0103525 <cprintf>
f01036d0:	83 c4 10             	add    $0x10,%esp
}
f01036d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036d6:	c9                   	leave  
f01036d7:	c3                   	ret    

f01036d8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01036d8:	55                   	push   %ebp
f01036d9:	89 e5                	mov    %esp,%ebp
f01036db:	53                   	push   %ebx
f01036dc:	83 ec 0c             	sub    $0xc,%esp
f01036df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01036e2:	53                   	push   %ebx
f01036e3:	68 1e 63 10 f0       	push   $0xf010631e
f01036e8:	e8 38 fe ff ff       	call   f0103525 <cprintf>
	print_regs(&tf->tf_regs);
f01036ed:	89 1c 24             	mov    %ebx,(%esp)
f01036f0:	e8 55 ff ff ff       	call   f010364a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01036f5:	83 c4 08             	add    $0x8,%esp
f01036f8:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01036fc:	50                   	push   %eax
f01036fd:	68 39 62 10 f0       	push   $0xf0106239
f0103702:	e8 1e fe ff ff       	call   f0103525 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103707:	83 c4 08             	add    $0x8,%esp
f010370a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010370e:	50                   	push   %eax
f010370f:	68 4c 62 10 f0       	push   $0xf010624c
f0103714:	e8 0c fe ff ff       	call   f0103525 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103719:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010371c:	83 c4 10             	add    $0x10,%esp
f010371f:	83 f8 13             	cmp    $0x13,%eax
f0103722:	77 09                	ja     f010372d <print_trapframe+0x55>
		return excnames[trapno];
f0103724:	8b 14 85 40 65 10 f0 	mov    -0xfef9ac0(,%eax,4),%edx
f010372b:	eb 11                	jmp    f010373e <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f010372d:	83 f8 30             	cmp    $0x30,%eax
f0103730:	75 07                	jne    f0103739 <print_trapframe+0x61>
		return "System call";
f0103732:	ba f7 61 10 f0       	mov    $0xf01061f7,%edx
f0103737:	eb 05                	jmp    f010373e <print_trapframe+0x66>
	return "(unknown trap)";
f0103739:	ba 03 62 10 f0       	mov    $0xf0106203,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010373e:	83 ec 04             	sub    $0x4,%esp
f0103741:	52                   	push   %edx
f0103742:	50                   	push   %eax
f0103743:	68 5f 62 10 f0       	push   $0xf010625f
f0103748:	e8 d8 fd ff ff       	call   f0103525 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010374d:	83 c4 10             	add    $0x10,%esp
f0103750:	3b 1d 40 9b 1d f0    	cmp    0xf01d9b40,%ebx
f0103756:	75 1a                	jne    f0103772 <print_trapframe+0x9a>
f0103758:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010375c:	75 14                	jne    f0103772 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010375e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103761:	83 ec 08             	sub    $0x8,%esp
f0103764:	50                   	push   %eax
f0103765:	68 71 62 10 f0       	push   $0xf0106271
f010376a:	e8 b6 fd ff ff       	call   f0103525 <cprintf>
f010376f:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103772:	83 ec 08             	sub    $0x8,%esp
f0103775:	ff 73 2c             	pushl  0x2c(%ebx)
f0103778:	68 80 62 10 f0       	push   $0xf0106280
f010377d:	e8 a3 fd ff ff       	call   f0103525 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103782:	83 c4 10             	add    $0x10,%esp
f0103785:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103789:	75 45                	jne    f01037d0 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010378b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010378e:	a8 01                	test   $0x1,%al
f0103790:	74 07                	je     f0103799 <print_trapframe+0xc1>
f0103792:	b9 12 62 10 f0       	mov    $0xf0106212,%ecx
f0103797:	eb 05                	jmp    f010379e <print_trapframe+0xc6>
f0103799:	b9 1d 62 10 f0       	mov    $0xf010621d,%ecx
f010379e:	a8 02                	test   $0x2,%al
f01037a0:	74 07                	je     f01037a9 <print_trapframe+0xd1>
f01037a2:	ba 29 62 10 f0       	mov    $0xf0106229,%edx
f01037a7:	eb 05                	jmp    f01037ae <print_trapframe+0xd6>
f01037a9:	ba 2f 62 10 f0       	mov    $0xf010622f,%edx
f01037ae:	a8 04                	test   $0x4,%al
f01037b0:	74 07                	je     f01037b9 <print_trapframe+0xe1>
f01037b2:	b8 34 62 10 f0       	mov    $0xf0106234,%eax
f01037b7:	eb 05                	jmp    f01037be <print_trapframe+0xe6>
f01037b9:	b8 6d 63 10 f0       	mov    $0xf010636d,%eax
f01037be:	51                   	push   %ecx
f01037bf:	52                   	push   %edx
f01037c0:	50                   	push   %eax
f01037c1:	68 8e 62 10 f0       	push   $0xf010628e
f01037c6:	e8 5a fd ff ff       	call   f0103525 <cprintf>
f01037cb:	83 c4 10             	add    $0x10,%esp
f01037ce:	eb 10                	jmp    f01037e0 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01037d0:	83 ec 0c             	sub    $0xc,%esp
f01037d3:	68 ca 4b 10 f0       	push   $0xf0104bca
f01037d8:	e8 48 fd ff ff       	call   f0103525 <cprintf>
f01037dd:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01037e0:	83 ec 08             	sub    $0x8,%esp
f01037e3:	ff 73 30             	pushl  0x30(%ebx)
f01037e6:	68 9d 62 10 f0       	push   $0xf010629d
f01037eb:	e8 35 fd ff ff       	call   f0103525 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01037f0:	83 c4 08             	add    $0x8,%esp
f01037f3:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01037f7:	50                   	push   %eax
f01037f8:	68 ac 62 10 f0       	push   $0xf01062ac
f01037fd:	e8 23 fd ff ff       	call   f0103525 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103802:	83 c4 08             	add    $0x8,%esp
f0103805:	ff 73 38             	pushl  0x38(%ebx)
f0103808:	68 bf 62 10 f0       	push   $0xf01062bf
f010380d:	e8 13 fd ff ff       	call   f0103525 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103812:	83 c4 10             	add    $0x10,%esp
f0103815:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103819:	74 25                	je     f0103840 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010381b:	83 ec 08             	sub    $0x8,%esp
f010381e:	ff 73 3c             	pushl  0x3c(%ebx)
f0103821:	68 ce 62 10 f0       	push   $0xf01062ce
f0103826:	e8 fa fc ff ff       	call   f0103525 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010382b:	83 c4 08             	add    $0x8,%esp
f010382e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103832:	50                   	push   %eax
f0103833:	68 dd 62 10 f0       	push   $0xf01062dd
f0103838:	e8 e8 fc ff ff       	call   f0103525 <cprintf>
f010383d:	83 c4 10             	add    $0x10,%esp
	}
}
f0103840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103843:	c9                   	leave  
f0103844:	c3                   	ret    

f0103845 <page_fault_handler>:
	env_run(curenv);
}

void
page_fault_handler(struct Trapframe *tf)
{
f0103845:	55                   	push   %ebp
f0103846:	89 e5                	mov    %esp,%ebp
f0103848:	53                   	push   %ebx
f0103849:	83 ec 04             	sub    $0x4,%esp
f010384c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010384f:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f0103852:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103857:	75 17                	jne    f0103870 <page_fault_handler+0x2b>
    	panic("page_fault_handler : page fault in kernel\n");
f0103859:	83 ec 04             	sub    $0x4,%esp
f010385c:	68 b8 64 10 f0       	push   $0xf01064b8
f0103861:	68 1c 01 00 00       	push   $0x11c
f0103866:	68 f0 62 10 f0       	push   $0xf01062f0
f010386b:	e8 59 c8 ff ff       	call   f01000c9 <_panic>
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103870:	ff 73 30             	pushl  0x30(%ebx)
f0103873:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f0103874:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103879:	ff 70 48             	pushl  0x48(%eax)
f010387c:	68 e4 64 10 f0       	push   $0xf01064e4
f0103881:	e8 9f fc ff ff       	call   f0103525 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103886:	89 1c 24             	mov    %ebx,(%esp)
f0103889:	e8 4a fe ff ff       	call   f01036d8 <print_trapframe>
	env_destroy(curenv);
f010388e:	83 c4 04             	add    $0x4,%esp
f0103891:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0103897:	e8 74 fb ff ff       	call   f0103410 <env_destroy>
f010389c:	83 c4 10             	add    $0x10,%esp
}
f010389f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038a2:	c9                   	leave  
f01038a3:	c3                   	ret    

f01038a4 <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f01038a4:	55                   	push   %ebp
f01038a5:	89 e5                	mov    %esp,%ebp
f01038a7:	57                   	push   %edi
f01038a8:	56                   	push   %esi
f01038a9:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01038ac:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01038ad:	9c                   	pushf  
f01038ae:	58                   	pop    %eax
	
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01038af:	f6 c4 02             	test   $0x2,%ah
f01038b2:	74 19                	je     f01038cd <trap+0x29>
f01038b4:	68 fc 62 10 f0       	push   $0xf01062fc
f01038b9:	68 f3 5d 10 f0       	push   $0xf0105df3
f01038be:	68 f4 00 00 00       	push   $0xf4
f01038c3:	68 f0 62 10 f0       	push   $0xf01062f0
f01038c8:	e8 fc c7 ff ff       	call   f01000c9 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01038cd:	83 ec 08             	sub    $0x8,%esp
f01038d0:	56                   	push   %esi
f01038d1:	68 15 63 10 f0       	push   $0xf0106315
f01038d6:	e8 4a fc ff ff       	call   f0103525 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01038db:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01038df:	83 e0 03             	and    $0x3,%eax
f01038e2:	83 c4 10             	add    $0x10,%esp
f01038e5:	83 f8 03             	cmp    $0x3,%eax
f01038e8:	75 31                	jne    f010391b <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01038ea:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f01038ef:	85 c0                	test   %eax,%eax
f01038f1:	75 19                	jne    f010390c <trap+0x68>
f01038f3:	68 30 63 10 f0       	push   $0xf0106330
f01038f8:	68 f3 5d 10 f0       	push   $0xf0105df3
f01038fd:	68 fa 00 00 00       	push   $0xfa
f0103902:	68 f0 62 10 f0       	push   $0xf01062f0
f0103907:	e8 bd c7 ff ff       	call   f01000c9 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010390c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103911:	89 c7                	mov    %eax,%edi
f0103913:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103915:	8b 35 20 93 1d f0    	mov    0xf01d9320,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010391b:	89 35 40 9b 1d f0    	mov    %esi,0xf01d9b40
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    
    cprintf("TRAP NUM : %u\n", tf->tf_trapno);
f0103921:	83 ec 08             	sub    $0x8,%esp
f0103924:	ff 76 28             	pushl  0x28(%esi)
f0103927:	68 37 63 10 f0       	push   $0xf0106337
f010392c:	e8 f4 fb ff ff       	call   f0103525 <cprintf>

    int r;
    // cprintf("TRAPNO : %d\n", tf->tf_trapno);
    switch (tf->tf_trapno) {
f0103931:	83 c4 10             	add    $0x10,%esp
f0103934:	8b 46 28             	mov    0x28(%esi),%eax
f0103937:	83 f8 03             	cmp    $0x3,%eax
f010393a:	74 3a                	je     f0103976 <trap+0xd2>
f010393c:	83 f8 03             	cmp    $0x3,%eax
f010393f:	77 07                	ja     f0103948 <trap+0xa4>
f0103941:	83 f8 01             	cmp    $0x1,%eax
f0103944:	75 78                	jne    f01039be <trap+0x11a>
f0103946:	eb 0c                	jmp    f0103954 <trap+0xb0>
f0103948:	83 f8 0e             	cmp    $0xe,%eax
f010394b:	74 18                	je     f0103965 <trap+0xc1>
f010394d:	83 f8 30             	cmp    $0x30,%eax
f0103950:	75 6c                	jne    f01039be <trap+0x11a>
f0103952:	eb 30                	jmp    f0103984 <trap+0xe0>
    	case T_DEBUG:
    		monitor(tf);
f0103954:	83 ec 0c             	sub    $0xc,%esp
f0103957:	56                   	push   %esi
f0103958:	e8 0c d5 ff ff       	call   f0100e69 <monitor>
f010395d:	83 c4 10             	add    $0x10,%esp
f0103960:	e9 94 00 00 00       	jmp    f01039f9 <trap+0x155>
    		break;
        case T_PGFLT:
        	page_fault_handler(tf);
f0103965:	83 ec 0c             	sub    $0xc,%esp
f0103968:	56                   	push   %esi
f0103969:	e8 d7 fe ff ff       	call   f0103845 <page_fault_handler>
f010396e:	83 c4 10             	add    $0x10,%esp
f0103971:	e9 83 00 00 00       	jmp    f01039f9 <trap+0x155>
            break;
        case T_BRKPT:
            monitor(tf); 
f0103976:	83 ec 0c             	sub    $0xc,%esp
f0103979:	56                   	push   %esi
f010397a:	e8 ea d4 ff ff       	call   f0100e69 <monitor>
f010397f:	83 c4 10             	add    $0x10,%esp
f0103982:	eb 75                	jmp    f01039f9 <trap+0x155>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103984:	83 ec 08             	sub    $0x8,%esp
f0103987:	ff 76 04             	pushl  0x4(%esi)
f010398a:	ff 36                	pushl  (%esi)
f010398c:	ff 76 10             	pushl  0x10(%esi)
f010398f:	ff 76 18             	pushl  0x18(%esi)
f0103992:	ff 76 14             	pushl  0x14(%esi)
f0103995:	ff 76 1c             	pushl  0x1c(%esi)
f0103998:	e8 2f 01 00 00       	call   f0103acc <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f010399d:	83 c4 20             	add    $0x20,%esp
f01039a0:	85 c0                	test   %eax,%eax
f01039a2:	79 15                	jns    f01039b9 <trap+0x115>
                panic("trap.c/syscall : %e\n", r);
f01039a4:	50                   	push   %eax
f01039a5:	68 46 63 10 f0       	push   $0xf0106346
f01039aa:	68 da 00 00 00       	push   $0xda
f01039af:	68 f0 62 10 f0       	push   $0xf01062f0
f01039b4:	e8 10 c7 ff ff       	call   f01000c9 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f01039b9:	89 46 1c             	mov    %eax,0x1c(%esi)
f01039bc:	eb 3b                	jmp    f01039f9 <trap+0x155>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f01039be:	83 ec 0c             	sub    $0xc,%esp
f01039c1:	56                   	push   %esi
f01039c2:	e8 11 fd ff ff       	call   f01036d8 <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f01039c7:	83 c4 10             	add    $0x10,%esp
f01039ca:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01039cf:	75 17                	jne    f01039e8 <trap+0x144>
		        panic("unhandled trap in kernel");
f01039d1:	83 ec 04             	sub    $0x4,%esp
f01039d4:	68 5b 63 10 f0       	push   $0xf010635b
f01039d9:	68 e2 00 00 00       	push   $0xe2
f01039de:	68 f0 62 10 f0       	push   $0xf01062f0
f01039e3:	e8 e1 c6 ff ff       	call   f01000c9 <_panic>
	        else {
		        env_destroy(curenv);
f01039e8:	83 ec 0c             	sub    $0xc,%esp
f01039eb:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f01039f1:	e8 1a fa ff ff       	call   f0103410 <env_destroy>
f01039f6:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01039f9:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f01039fe:	85 c0                	test   %eax,%eax
f0103a00:	74 06                	je     f0103a08 <trap+0x164>
f0103a02:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a06:	74 19                	je     f0103a21 <trap+0x17d>
f0103a08:	68 08 65 10 f0       	push   $0xf0106508
f0103a0d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0103a12:	68 0c 01 00 00       	push   $0x10c
f0103a17:	68 f0 62 10 f0       	push   $0xf01062f0
f0103a1c:	e8 a8 c6 ff ff       	call   f01000c9 <_panic>
	env_run(curenv);
f0103a21:	83 ec 0c             	sub    $0xc,%esp
f0103a24:	50                   	push   %eax
f0103a25:	e8 36 fa ff ff       	call   f0103460 <env_run>
	...

f0103a2c <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0103a2c:	6a 00                	push   $0x0
f0103a2e:	6a 00                	push   $0x0
f0103a30:	e9 61 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a35:	90                   	nop

f0103a36 <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f0103a36:	6a 00                	push   $0x0
f0103a38:	6a 01                	push   $0x1
f0103a3a:	e9 57 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a3f:	90                   	nop

f0103a40 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f0103a40:	6a 00                	push   $0x0
f0103a42:	6a 02                	push   $0x2
f0103a44:	e9 4d f9 01 00       	jmp    f0123396 <_alltraps>
f0103a49:	90                   	nop

f0103a4a <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f0103a4a:	6a 00                	push   $0x0
f0103a4c:	6a 03                	push   $0x3
f0103a4e:	e9 43 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a53:	90                   	nop

f0103a54 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0103a54:	6a 00                	push   $0x0
f0103a56:	6a 04                	push   $0x4
f0103a58:	e9 39 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a5d:	90                   	nop

f0103a5e <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f0103a5e:	6a 00                	push   $0x0
f0103a60:	6a 05                	push   $0x5
f0103a62:	e9 2f f9 01 00       	jmp    f0123396 <_alltraps>
f0103a67:	90                   	nop

f0103a68 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f0103a68:	6a 00                	push   $0x0
f0103a6a:	6a 07                	push   $0x7
f0103a6c:	e9 25 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a71:	90                   	nop

f0103a72 <vec8>:
 	MYTH_NOEC(vec8, T_DBLFLT)
f0103a72:	6a 00                	push   $0x0
f0103a74:	6a 08                	push   $0x8
f0103a76:	e9 1b f9 01 00       	jmp    f0123396 <_alltraps>
f0103a7b:	90                   	nop

f0103a7c <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0103a7c:	6a 0a                	push   $0xa
f0103a7e:	e9 13 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a83:	90                   	nop

f0103a84 <vec11>:
 	MYTH(vec11, T_SEGNP)
f0103a84:	6a 0b                	push   $0xb
f0103a86:	e9 0b f9 01 00       	jmp    f0123396 <_alltraps>
f0103a8b:	90                   	nop

f0103a8c <vec12>:
 	MYTH(vec12, T_STACK)
f0103a8c:	6a 0c                	push   $0xc
f0103a8e:	e9 03 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a93:	90                   	nop

f0103a94 <vec13>:
 	MYTH(vec13, T_GPFLT)
f0103a94:	6a 0d                	push   $0xd
f0103a96:	e9 fb f8 01 00       	jmp    f0123396 <_alltraps>
f0103a9b:	90                   	nop

f0103a9c <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0103a9c:	6a 0e                	push   $0xe
f0103a9e:	e9 f3 f8 01 00       	jmp    f0123396 <_alltraps>
f0103aa3:	90                   	nop

f0103aa4 <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f0103aa4:	6a 00                	push   $0x0
f0103aa6:	6a 10                	push   $0x10
f0103aa8:	e9 e9 f8 01 00       	jmp    f0123396 <_alltraps>
f0103aad:	90                   	nop

f0103aae <vec17>:
 	MYTH(vec17, T_ALIGN)
f0103aae:	6a 11                	push   $0x11
f0103ab0:	e9 e1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ab5:	90                   	nop

f0103ab6 <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f0103ab6:	6a 00                	push   $0x0
f0103ab8:	6a 12                	push   $0x12
f0103aba:	e9 d7 f8 01 00       	jmp    f0123396 <_alltraps>
f0103abf:	90                   	nop

f0103ac0 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0103ac0:	6a 00                	push   $0x0
f0103ac2:	6a 13                	push   $0x13
f0103ac4:	e9 cd f8 01 00       	jmp    f0123396 <_alltraps>
f0103ac9:	00 00                	add    %al,(%eax)
	...

f0103acc <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103acc:	55                   	push   %ebp
f0103acd:	89 e5                	mov    %esp,%ebp
f0103acf:	56                   	push   %esi
f0103ad0:	53                   	push   %ebx
f0103ad1:	83 ec 10             	sub    $0x10,%esp
f0103ad4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ada:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    switch (syscallno) {
f0103add:	83 f8 01             	cmp    $0x1,%eax
f0103ae0:	74 40                	je     f0103b22 <syscall+0x56>
f0103ae2:	83 f8 01             	cmp    $0x1,%eax
f0103ae5:	72 10                	jb     f0103af7 <syscall+0x2b>
f0103ae7:	83 f8 02             	cmp    $0x2,%eax
f0103aea:	74 40                	je     f0103b2c <syscall+0x60>
f0103aec:	83 f8 03             	cmp    $0x3,%eax
f0103aef:	0f 85 a4 00 00 00    	jne    f0103b99 <syscall+0xcd>
f0103af5:	eb 3f                	jmp    f0103b36 <syscall+0x6a>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103af7:	6a 04                	push   $0x4
f0103af9:	53                   	push   %ebx
f0103afa:	56                   	push   %esi
f0103afb:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0103b01:	e8 95 f2 ff ff       	call   f0102d9b <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b06:	83 c4 0c             	add    $0xc,%esp
f0103b09:	56                   	push   %esi
f0103b0a:	53                   	push   %ebx
f0103b0b:	68 3f 4f 10 f0       	push   $0xf0104f3f
f0103b10:	e8 10 fa ff ff       	call   f0103525 <cprintf>
f0103b15:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
    
    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0103b18:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b1d:	e9 8b 00 00 00       	jmp    f0103bad <syscall+0xe1>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103b22:	e8 99 c9 ff ff       	call   f01004c0 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0103b27:	e9 81 00 00 00       	jmp    f0103bad <syscall+0xe1>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103b2c:	a1 20 93 1d f0       	mov    0xf01d9320,%eax
f0103b31:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0103b34:	eb 77                	jmp    f0103bad <syscall+0xe1>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103b36:	83 ec 04             	sub    $0x4,%esp
f0103b39:	6a 01                	push   $0x1
f0103b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b3e:	50                   	push   %eax
f0103b3f:	56                   	push   %esi
f0103b40:	e8 29 f3 ff ff       	call   f0102e6e <envid2env>
f0103b45:	83 c4 10             	add    $0x10,%esp
f0103b48:	85 c0                	test   %eax,%eax
f0103b4a:	78 61                	js     f0103bad <syscall+0xe1>
		return r;
	if (e == curenv)
f0103b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b4f:	8b 15 20 93 1d f0    	mov    0xf01d9320,%edx
f0103b55:	39 d0                	cmp    %edx,%eax
f0103b57:	75 15                	jne    f0103b6e <syscall+0xa2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103b59:	83 ec 08             	sub    $0x8,%esp
f0103b5c:	ff 70 48             	pushl  0x48(%eax)
f0103b5f:	68 90 65 10 f0       	push   $0xf0106590
f0103b64:	e8 bc f9 ff ff       	call   f0103525 <cprintf>
f0103b69:	83 c4 10             	add    $0x10,%esp
f0103b6c:	eb 16                	jmp    f0103b84 <syscall+0xb8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103b6e:	83 ec 04             	sub    $0x4,%esp
f0103b71:	ff 70 48             	pushl  0x48(%eax)
f0103b74:	ff 72 48             	pushl  0x48(%edx)
f0103b77:	68 ab 65 10 f0       	push   $0xf01065ab
f0103b7c:	e8 a4 f9 ff ff       	call   f0103525 <cprintf>
f0103b81:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103b84:	83 ec 0c             	sub    $0xc,%esp
f0103b87:	ff 75 f4             	pushl  -0xc(%ebp)
f0103b8a:	e8 81 f8 ff ff       	call   f0103410 <env_destroy>
f0103b8f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103b92:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0103b97:	eb 14                	jmp    f0103bad <syscall+0xe1>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0103b99:	83 ec 04             	sub    $0x4,%esp
f0103b9c:	68 c3 65 10 f0       	push   $0xf01065c3
f0103ba1:	6a 5c                	push   $0x5c
f0103ba3:	68 db 65 10 f0       	push   $0xf01065db
f0103ba8:	e8 1c c5 ff ff       	call   f01000c9 <_panic>
}
f0103bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bb0:	5b                   	pop    %ebx
f0103bb1:	5e                   	pop    %esi
f0103bb2:	c9                   	leave  
f0103bb3:	c3                   	ret    

f0103bb4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103bb4:	55                   	push   %ebp
f0103bb5:	89 e5                	mov    %esp,%ebp
f0103bb7:	57                   	push   %edi
f0103bb8:	56                   	push   %esi
f0103bb9:	53                   	push   %ebx
f0103bba:	83 ec 14             	sub    $0x14,%esp
f0103bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103bc0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103bc3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bc9:	8b 1a                	mov    (%edx),%ebx
f0103bcb:	8b 01                	mov    (%ecx),%eax
f0103bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103bd0:	39 c3                	cmp    %eax,%ebx
f0103bd2:	0f 8f 97 00 00 00    	jg     f0103c6f <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bd8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103bdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103be2:	01 d8                	add    %ebx,%eax
f0103be4:	89 c7                	mov    %eax,%edi
f0103be6:	c1 ef 1f             	shr    $0x1f,%edi
f0103be9:	01 c7                	add    %eax,%edi
f0103beb:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103bed:	39 df                	cmp    %ebx,%edi
f0103bef:	7c 31                	jl     f0103c22 <stab_binsearch+0x6e>
f0103bf1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103bf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103bf7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103bfc:	39 f0                	cmp    %esi,%eax
f0103bfe:	0f 84 b3 00 00 00    	je     f0103cb7 <stab_binsearch+0x103>
f0103c04:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c08:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103c0c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103c0e:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c0f:	39 d8                	cmp    %ebx,%eax
f0103c11:	7c 0f                	jl     f0103c22 <stab_binsearch+0x6e>
f0103c13:	0f b6 0a             	movzbl (%edx),%ecx
f0103c16:	83 ea 0c             	sub    $0xc,%edx
f0103c19:	39 f1                	cmp    %esi,%ecx
f0103c1b:	75 f1                	jne    f0103c0e <stab_binsearch+0x5a>
f0103c1d:	e9 97 00 00 00       	jmp    f0103cb9 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103c22:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103c25:	eb 39                	jmp    f0103c60 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103c27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c2a:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103c2c:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c2f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c36:	eb 28                	jmp    f0103c60 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103c38:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c3b:	76 12                	jbe    f0103c4f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103c3d:	48                   	dec    %eax
f0103c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c41:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c44:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c46:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c4d:	eb 11                	jmp    f0103c60 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c52:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103c54:	ff 45 0c             	incl   0xc(%ebp)
f0103c57:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c59:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103c60:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103c63:	0f 8d 76 ff ff ff    	jge    f0103bdf <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103c69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c6d:	75 0d                	jne    f0103c7c <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103c6f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103c72:	8b 03                	mov    (%ebx),%eax
f0103c74:	48                   	dec    %eax
f0103c75:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c78:	89 02                	mov    %eax,(%edx)
f0103c7a:	eb 55                	jmp    f0103cd1 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c7c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c7f:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103c81:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103c84:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c86:	39 c1                	cmp    %eax,%ecx
f0103c88:	7d 26                	jge    f0103cb0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103c8a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103c8d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103c90:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103c95:	39 f2                	cmp    %esi,%edx
f0103c97:	74 17                	je     f0103cb0 <stab_binsearch+0xfc>
f0103c99:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c9d:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103ca1:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103ca2:	39 c1                	cmp    %eax,%ecx
f0103ca4:	7d 0a                	jge    f0103cb0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103ca6:	0f b6 1a             	movzbl (%edx),%ebx
f0103ca9:	83 ea 0c             	sub    $0xc,%edx
f0103cac:	39 f3                	cmp    %esi,%ebx
f0103cae:	75 f1                	jne    f0103ca1 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103cb0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103cb3:	89 02                	mov    %eax,(%edx)
f0103cb5:	eb 1a                	jmp    f0103cd1 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103cb7:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103cb9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cbc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103cbf:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103cc3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103cc6:	0f 82 5b ff ff ff    	jb     f0103c27 <stab_binsearch+0x73>
f0103ccc:	e9 67 ff ff ff       	jmp    f0103c38 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103cd1:	83 c4 14             	add    $0x14,%esp
f0103cd4:	5b                   	pop    %ebx
f0103cd5:	5e                   	pop    %esi
f0103cd6:	5f                   	pop    %edi
f0103cd7:	c9                   	leave  
f0103cd8:	c3                   	ret    

f0103cd9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103cd9:	55                   	push   %ebp
f0103cda:	89 e5                	mov    %esp,%ebp
f0103cdc:	57                   	push   %edi
f0103cdd:	56                   	push   %esi
f0103cde:	53                   	push   %ebx
f0103cdf:	83 ec 2c             	sub    $0x2c,%esp
f0103ce2:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ce5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103ce8:	c7 03 ea 65 10 f0    	movl   $0xf01065ea,(%ebx)
	info->eip_line = 0;
f0103cee:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103cf5:	c7 43 08 ea 65 10 f0 	movl   $0xf01065ea,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103cfc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103d03:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103d06:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103d0d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103d13:	0f 87 89 00 00 00    	ja     f0103da2 <debuginfo_eip+0xc9>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0103d19:	6a 04                	push   $0x4
f0103d1b:	6a 10                	push   $0x10
f0103d1d:	68 00 00 20 00       	push   $0x200000
f0103d22:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0103d28:	e8 bb ef ff ff       	call   f0102ce8 <user_mem_check>
f0103d2d:	83 c4 10             	add    $0x10,%esp
f0103d30:	85 c0                	test   %eax,%eax
f0103d32:	0f 88 f2 01 00 00    	js     f0103f2a <debuginfo_eip+0x251>
			return -1;
		}

		stabs = usd->stabs;
f0103d38:	a1 00 00 20 00       	mov    0x200000,%eax
f0103d3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103d40:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0103d46:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0103d49:	a1 08 00 20 00       	mov    0x200008,%eax
f0103d4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103d51:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0103d57:	6a 04                	push   $0x4
f0103d59:	89 c8                	mov    %ecx,%eax
f0103d5b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103d5e:	50                   	push   %eax
f0103d5f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103d62:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0103d68:	e8 7b ef ff ff       	call   f0102ce8 <user_mem_check>
f0103d6d:	83 c4 10             	add    $0x10,%esp
f0103d70:	85 c0                	test   %eax,%eax
f0103d72:	0f 88 b9 01 00 00    	js     f0103f31 <debuginfo_eip+0x258>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103d78:	6a 04                	push   $0x4
f0103d7a:	89 f8                	mov    %edi,%eax
f0103d7c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103d7f:	50                   	push   %eax
f0103d80:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103d83:	ff 35 20 93 1d f0    	pushl  0xf01d9320
f0103d89:	e8 5a ef ff ff       	call   f0102ce8 <user_mem_check>
f0103d8e:	89 c2                	mov    %eax,%edx
f0103d90:	83 c4 10             	add    $0x10,%esp
			return -1;
f0103d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103d98:	85 d2                	test   %edx,%edx
f0103d9a:	0f 88 ab 01 00 00    	js     f0103f4b <debuginfo_eip+0x272>
f0103da0:	eb 1a                	jmp    f0103dbc <debuginfo_eip+0xe3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103da2:	bf 56 83 11 f0       	mov    $0xf0118356,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103da7:	c7 45 d4 09 fd 10 f0 	movl   $0xf010fd09,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103dae:	c7 45 cc 08 fd 10 f0 	movl   $0xf010fd08,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103db5:	c7 45 d0 04 68 10 f0 	movl   $0xf0106804,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103dbc:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0103dbf:	0f 83 73 01 00 00    	jae    f0103f38 <debuginfo_eip+0x25f>
f0103dc5:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103dc9:	0f 85 70 01 00 00    	jne    f0103f3f <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103dcf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103dd6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103dd9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103ddc:	c1 f8 02             	sar    $0x2,%eax
f0103ddf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103de5:	48                   	dec    %eax
f0103de6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103de9:	83 ec 08             	sub    $0x8,%esp
f0103dec:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103def:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103df2:	56                   	push   %esi
f0103df3:	6a 64                	push   $0x64
f0103df5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103df8:	e8 b7 fd ff ff       	call   f0103bb4 <stab_binsearch>
	if (lfile == 0)
f0103dfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e00:	83 c4 10             	add    $0x10,%esp
		return -1;
f0103e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103e08:	85 d2                	test   %edx,%edx
f0103e0a:	0f 84 3b 01 00 00    	je     f0103f4b <debuginfo_eip+0x272>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103e10:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103e13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e16:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103e19:	83 ec 08             	sub    $0x8,%esp
f0103e1c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e1f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e22:	56                   	push   %esi
f0103e23:	6a 24                	push   $0x24
f0103e25:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e28:	e8 87 fd ff ff       	call   f0103bb4 <stab_binsearch>

	if (lfun <= rfun) {
f0103e2d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103e30:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103e33:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e36:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103e39:	83 c4 10             	add    $0x10,%esp
f0103e3c:	39 c1                	cmp    %eax,%ecx
f0103e3e:	7f 21                	jg     f0103e61 <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e40:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103e43:	03 45 d0             	add    -0x30(%ebp),%eax
f0103e46:	8b 10                	mov    (%eax),%edx
f0103e48:	89 f9                	mov    %edi,%ecx
f0103e4a:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103e4d:	39 ca                	cmp    %ecx,%edx
f0103e4f:	73 06                	jae    f0103e57 <debuginfo_eip+0x17e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103e51:	03 55 d4             	add    -0x2c(%ebp),%edx
f0103e54:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e57:	8b 40 08             	mov    0x8(%eax),%eax
f0103e5a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103e5d:	29 c6                	sub    %eax,%esi
f0103e5f:	eb 0f                	jmp    f0103e70 <debuginfo_eip+0x197>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103e61:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103e64:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0103e6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e6d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103e70:	83 ec 08             	sub    $0x8,%esp
f0103e73:	6a 3a                	push   $0x3a
f0103e75:	ff 73 08             	pushl  0x8(%ebx)
f0103e78:	e8 b2 08 00 00       	call   f010472f <strfind>
f0103e7d:	2b 43 08             	sub    0x8(%ebx),%eax
f0103e80:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103e83:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103e86:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0103e89:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103e8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103e8f:	83 c4 08             	add    $0x8,%esp
f0103e92:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e95:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e98:	56                   	push   %esi
f0103e99:	6a 44                	push   $0x44
f0103e9b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e9e:	e8 11 fd ff ff       	call   f0103bb4 <stab_binsearch>
    if (lfun <= rfun) {
f0103ea3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ea6:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103eae:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103eb1:	0f 8f 94 00 00 00    	jg     f0103f4b <debuginfo_eip+0x272>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103eb7:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103eba:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103ebd:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103ec1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ec4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103ec7:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103eca:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ecd:	eb 04                	jmp    f0103ed3 <debuginfo_eip+0x1fa>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ecf:	4a                   	dec    %edx
f0103ed0:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ed3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103ed6:	7c 19                	jl     f0103ef1 <debuginfo_eip+0x218>
	       && stabs[lline].n_type != N_SOL
f0103ed8:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103edb:	80 f9 84             	cmp    $0x84,%cl
f0103ede:	74 73                	je     f0103f53 <debuginfo_eip+0x27a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103ee0:	80 f9 64             	cmp    $0x64,%cl
f0103ee3:	75 ea                	jne    f0103ecf <debuginfo_eip+0x1f6>
f0103ee5:	83 38 00             	cmpl   $0x0,(%eax)
f0103ee8:	74 e5                	je     f0103ecf <debuginfo_eip+0x1f6>
f0103eea:	eb 67                	jmp    f0103f53 <debuginfo_eip+0x27a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103eec:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103eef:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103ef1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ef4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103ef7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103efc:	39 ca                	cmp    %ecx,%edx
f0103efe:	7d 4b                	jge    f0103f4b <debuginfo_eip+0x272>
		for (lline = lfun + 1;
f0103f00:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f03:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f06:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f09:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103f0d:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f0f:	eb 04                	jmp    f0103f15 <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f11:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103f14:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f15:	39 f0                	cmp    %esi,%eax
f0103f17:	7d 2d                	jge    f0103f46 <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f19:	8a 0a                	mov    (%edx),%cl
f0103f1b:	83 c2 0c             	add    $0xc,%edx
f0103f1e:	80 f9 a0             	cmp    $0xa0,%cl
f0103f21:	74 ee                	je     f0103f11 <debuginfo_eip+0x238>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f23:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f28:	eb 21                	jmp    f0103f4b <debuginfo_eip+0x272>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0103f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f2f:	eb 1a                	jmp    f0103f4b <debuginfo_eip+0x272>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0103f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f36:	eb 13                	jmp    f0103f4b <debuginfo_eip+0x272>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f3d:	eb 0c                	jmp    f0103f4b <debuginfo_eip+0x272>
f0103f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f44:	eb 05                	jmp    f0103f4b <debuginfo_eip+0x272>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f46:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f4e:	5b                   	pop    %ebx
f0103f4f:	5e                   	pop    %esi
f0103f50:	5f                   	pop    %edi
f0103f51:	c9                   	leave  
f0103f52:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f53:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103f56:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f59:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0103f5c:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0103f5f:	39 f8                	cmp    %edi,%eax
f0103f61:	72 89                	jb     f0103eec <debuginfo_eip+0x213>
f0103f63:	eb 8c                	jmp    f0103ef1 <debuginfo_eip+0x218>
f0103f65:	00 00                	add    %al,(%eax)
	...

f0103f68 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103f68:	55                   	push   %ebp
f0103f69:	89 e5                	mov    %esp,%ebp
f0103f6b:	57                   	push   %edi
f0103f6c:	56                   	push   %esi
f0103f6d:	53                   	push   %ebx
f0103f6e:	83 ec 2c             	sub    $0x2c,%esp
f0103f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f74:	89 d6                	mov    %edx,%esi
f0103f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f79:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103f7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f7f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103f82:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f85:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103f88:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103f8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103f95:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103f98:	72 0c                	jb     f0103fa6 <printnum+0x3e>
f0103f9a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103f9d:	76 07                	jbe    f0103fa6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103f9f:	4b                   	dec    %ebx
f0103fa0:	85 db                	test   %ebx,%ebx
f0103fa2:	7f 31                	jg     f0103fd5 <printnum+0x6d>
f0103fa4:	eb 3f                	jmp    f0103fe5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103fa6:	83 ec 0c             	sub    $0xc,%esp
f0103fa9:	57                   	push   %edi
f0103faa:	4b                   	dec    %ebx
f0103fab:	53                   	push   %ebx
f0103fac:	50                   	push   %eax
f0103fad:	83 ec 08             	sub    $0x8,%esp
f0103fb0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103fb3:	ff 75 d0             	pushl  -0x30(%ebp)
f0103fb6:	ff 75 dc             	pushl  -0x24(%ebp)
f0103fb9:	ff 75 d8             	pushl  -0x28(%ebp)
f0103fbc:	e8 97 09 00 00       	call   f0104958 <__udivdi3>
f0103fc1:	83 c4 18             	add    $0x18,%esp
f0103fc4:	52                   	push   %edx
f0103fc5:	50                   	push   %eax
f0103fc6:	89 f2                	mov    %esi,%edx
f0103fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103fcb:	e8 98 ff ff ff       	call   f0103f68 <printnum>
f0103fd0:	83 c4 20             	add    $0x20,%esp
f0103fd3:	eb 10                	jmp    f0103fe5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103fd5:	83 ec 08             	sub    $0x8,%esp
f0103fd8:	56                   	push   %esi
f0103fd9:	57                   	push   %edi
f0103fda:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103fdd:	4b                   	dec    %ebx
f0103fde:	83 c4 10             	add    $0x10,%esp
f0103fe1:	85 db                	test   %ebx,%ebx
f0103fe3:	7f f0                	jg     f0103fd5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103fe5:	83 ec 08             	sub    $0x8,%esp
f0103fe8:	56                   	push   %esi
f0103fe9:	83 ec 04             	sub    $0x4,%esp
f0103fec:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103fef:	ff 75 d0             	pushl  -0x30(%ebp)
f0103ff2:	ff 75 dc             	pushl  -0x24(%ebp)
f0103ff5:	ff 75 d8             	pushl  -0x28(%ebp)
f0103ff8:	e8 77 0a 00 00       	call   f0104a74 <__umoddi3>
f0103ffd:	83 c4 14             	add    $0x14,%esp
f0104000:	0f be 80 f4 65 10 f0 	movsbl -0xfef9a0c(%eax),%eax
f0104007:	50                   	push   %eax
f0104008:	ff 55 e4             	call   *-0x1c(%ebp)
f010400b:	83 c4 10             	add    $0x10,%esp
}
f010400e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104011:	5b                   	pop    %ebx
f0104012:	5e                   	pop    %esi
f0104013:	5f                   	pop    %edi
f0104014:	c9                   	leave  
f0104015:	c3                   	ret    

f0104016 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104016:	55                   	push   %ebp
f0104017:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104019:	83 fa 01             	cmp    $0x1,%edx
f010401c:	7e 0e                	jle    f010402c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010401e:	8b 10                	mov    (%eax),%edx
f0104020:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104023:	89 08                	mov    %ecx,(%eax)
f0104025:	8b 02                	mov    (%edx),%eax
f0104027:	8b 52 04             	mov    0x4(%edx),%edx
f010402a:	eb 22                	jmp    f010404e <getuint+0x38>
	else if (lflag)
f010402c:	85 d2                	test   %edx,%edx
f010402e:	74 10                	je     f0104040 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104030:	8b 10                	mov    (%eax),%edx
f0104032:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104035:	89 08                	mov    %ecx,(%eax)
f0104037:	8b 02                	mov    (%edx),%eax
f0104039:	ba 00 00 00 00       	mov    $0x0,%edx
f010403e:	eb 0e                	jmp    f010404e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104040:	8b 10                	mov    (%eax),%edx
f0104042:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104045:	89 08                	mov    %ecx,(%eax)
f0104047:	8b 02                	mov    (%edx),%eax
f0104049:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010404e:	c9                   	leave  
f010404f:	c3                   	ret    

f0104050 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0104050:	55                   	push   %ebp
f0104051:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104053:	83 fa 01             	cmp    $0x1,%edx
f0104056:	7e 0e                	jle    f0104066 <getint+0x16>
		return va_arg(*ap, long long);
f0104058:	8b 10                	mov    (%eax),%edx
f010405a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010405d:	89 08                	mov    %ecx,(%eax)
f010405f:	8b 02                	mov    (%edx),%eax
f0104061:	8b 52 04             	mov    0x4(%edx),%edx
f0104064:	eb 1a                	jmp    f0104080 <getint+0x30>
	else if (lflag)
f0104066:	85 d2                	test   %edx,%edx
f0104068:	74 0c                	je     f0104076 <getint+0x26>
		return va_arg(*ap, long);
f010406a:	8b 10                	mov    (%eax),%edx
f010406c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010406f:	89 08                	mov    %ecx,(%eax)
f0104071:	8b 02                	mov    (%edx),%eax
f0104073:	99                   	cltd   
f0104074:	eb 0a                	jmp    f0104080 <getint+0x30>
	else
		return va_arg(*ap, int);
f0104076:	8b 10                	mov    (%eax),%edx
f0104078:	8d 4a 04             	lea    0x4(%edx),%ecx
f010407b:	89 08                	mov    %ecx,(%eax)
f010407d:	8b 02                	mov    (%edx),%eax
f010407f:	99                   	cltd   
}
f0104080:	c9                   	leave  
f0104081:	c3                   	ret    

f0104082 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104082:	55                   	push   %ebp
f0104083:	89 e5                	mov    %esp,%ebp
f0104085:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104088:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010408b:	8b 10                	mov    (%eax),%edx
f010408d:	3b 50 04             	cmp    0x4(%eax),%edx
f0104090:	73 08                	jae    f010409a <sprintputch+0x18>
		*b->buf++ = ch;
f0104092:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104095:	88 0a                	mov    %cl,(%edx)
f0104097:	42                   	inc    %edx
f0104098:	89 10                	mov    %edx,(%eax)
}
f010409a:	c9                   	leave  
f010409b:	c3                   	ret    

f010409c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010409c:	55                   	push   %ebp
f010409d:	89 e5                	mov    %esp,%ebp
f010409f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01040a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01040a5:	50                   	push   %eax
f01040a6:	ff 75 10             	pushl  0x10(%ebp)
f01040a9:	ff 75 0c             	pushl  0xc(%ebp)
f01040ac:	ff 75 08             	pushl  0x8(%ebp)
f01040af:	e8 05 00 00 00       	call   f01040b9 <vprintfmt>
	va_end(ap);
f01040b4:	83 c4 10             	add    $0x10,%esp
}
f01040b7:	c9                   	leave  
f01040b8:	c3                   	ret    

f01040b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01040b9:	55                   	push   %ebp
f01040ba:	89 e5                	mov    %esp,%ebp
f01040bc:	57                   	push   %edi
f01040bd:	56                   	push   %esi
f01040be:	53                   	push   %ebx
f01040bf:	83 ec 2c             	sub    $0x2c,%esp
f01040c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01040c5:	8b 75 10             	mov    0x10(%ebp),%esi
f01040c8:	eb 13                	jmp    f01040dd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01040ca:	85 c0                	test   %eax,%eax
f01040cc:	0f 84 6d 03 00 00    	je     f010443f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01040d2:	83 ec 08             	sub    $0x8,%esp
f01040d5:	57                   	push   %edi
f01040d6:	50                   	push   %eax
f01040d7:	ff 55 08             	call   *0x8(%ebp)
f01040da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01040dd:	0f b6 06             	movzbl (%esi),%eax
f01040e0:	46                   	inc    %esi
f01040e1:	83 f8 25             	cmp    $0x25,%eax
f01040e4:	75 e4                	jne    f01040ca <vprintfmt+0x11>
f01040e6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01040ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01040f1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01040f8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01040ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104104:	eb 28                	jmp    f010412e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104106:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104108:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010410c:	eb 20                	jmp    f010412e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010410e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104110:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104114:	eb 18                	jmp    f010412e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104116:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104118:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010411f:	eb 0d                	jmp    f010412e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104121:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104124:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104127:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010412e:	8a 06                	mov    (%esi),%al
f0104130:	0f b6 d0             	movzbl %al,%edx
f0104133:	8d 5e 01             	lea    0x1(%esi),%ebx
f0104136:	83 e8 23             	sub    $0x23,%eax
f0104139:	3c 55                	cmp    $0x55,%al
f010413b:	0f 87 e0 02 00 00    	ja     f0104421 <vprintfmt+0x368>
f0104141:	0f b6 c0             	movzbl %al,%eax
f0104144:	ff 24 85 80 66 10 f0 	jmp    *-0xfef9980(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010414b:	83 ea 30             	sub    $0x30,%edx
f010414e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0104151:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0104154:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104157:	83 fa 09             	cmp    $0x9,%edx
f010415a:	77 44                	ja     f01041a0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010415c:	89 de                	mov    %ebx,%esi
f010415e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104161:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0104162:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104165:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104169:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010416c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010416f:	83 fb 09             	cmp    $0x9,%ebx
f0104172:	76 ed                	jbe    f0104161 <vprintfmt+0xa8>
f0104174:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104177:	eb 29                	jmp    f01041a2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104179:	8b 45 14             	mov    0x14(%ebp),%eax
f010417c:	8d 50 04             	lea    0x4(%eax),%edx
f010417f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104182:	8b 00                	mov    (%eax),%eax
f0104184:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104187:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104189:	eb 17                	jmp    f01041a2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f010418b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010418f:	78 85                	js     f0104116 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104191:	89 de                	mov    %ebx,%esi
f0104193:	eb 99                	jmp    f010412e <vprintfmt+0x75>
f0104195:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104197:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010419e:	eb 8e                	jmp    f010412e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041a0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01041a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041a6:	79 86                	jns    f010412e <vprintfmt+0x75>
f01041a8:	e9 74 ff ff ff       	jmp    f0104121 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01041ad:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041ae:	89 de                	mov    %ebx,%esi
f01041b0:	e9 79 ff ff ff       	jmp    f010412e <vprintfmt+0x75>
f01041b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01041b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041bb:	8d 50 04             	lea    0x4(%eax),%edx
f01041be:	89 55 14             	mov    %edx,0x14(%ebp)
f01041c1:	83 ec 08             	sub    $0x8,%esp
f01041c4:	57                   	push   %edi
f01041c5:	ff 30                	pushl  (%eax)
f01041c7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01041ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01041d0:	e9 08 ff ff ff       	jmp    f01040dd <vprintfmt+0x24>
f01041d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01041d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041db:	8d 50 04             	lea    0x4(%eax),%edx
f01041de:	89 55 14             	mov    %edx,0x14(%ebp)
f01041e1:	8b 00                	mov    (%eax),%eax
f01041e3:	85 c0                	test   %eax,%eax
f01041e5:	79 02                	jns    f01041e9 <vprintfmt+0x130>
f01041e7:	f7 d8                	neg    %eax
f01041e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01041eb:	83 f8 06             	cmp    $0x6,%eax
f01041ee:	7f 0b                	jg     f01041fb <vprintfmt+0x142>
f01041f0:	8b 04 85 d8 67 10 f0 	mov    -0xfef9828(,%eax,4),%eax
f01041f7:	85 c0                	test   %eax,%eax
f01041f9:	75 1a                	jne    f0104215 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01041fb:	52                   	push   %edx
f01041fc:	68 0c 66 10 f0       	push   $0xf010660c
f0104201:	57                   	push   %edi
f0104202:	ff 75 08             	pushl  0x8(%ebp)
f0104205:	e8 92 fe ff ff       	call   f010409c <printfmt>
f010420a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010420d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104210:	e9 c8 fe ff ff       	jmp    f01040dd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0104215:	50                   	push   %eax
f0104216:	68 05 5e 10 f0       	push   $0xf0105e05
f010421b:	57                   	push   %edi
f010421c:	ff 75 08             	pushl  0x8(%ebp)
f010421f:	e8 78 fe ff ff       	call   f010409c <printfmt>
f0104224:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104227:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010422a:	e9 ae fe ff ff       	jmp    f01040dd <vprintfmt+0x24>
f010422f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104232:	89 de                	mov    %ebx,%esi
f0104234:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104237:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010423a:	8b 45 14             	mov    0x14(%ebp),%eax
f010423d:	8d 50 04             	lea    0x4(%eax),%edx
f0104240:	89 55 14             	mov    %edx,0x14(%ebp)
f0104243:	8b 00                	mov    (%eax),%eax
f0104245:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104248:	85 c0                	test   %eax,%eax
f010424a:	75 07                	jne    f0104253 <vprintfmt+0x19a>
				p = "(null)";
f010424c:	c7 45 d0 05 66 10 f0 	movl   $0xf0106605,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0104253:	85 db                	test   %ebx,%ebx
f0104255:	7e 42                	jle    f0104299 <vprintfmt+0x1e0>
f0104257:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010425b:	74 3c                	je     f0104299 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010425d:	83 ec 08             	sub    $0x8,%esp
f0104260:	51                   	push   %ecx
f0104261:	ff 75 d0             	pushl  -0x30(%ebp)
f0104264:	e8 3f 03 00 00       	call   f01045a8 <strnlen>
f0104269:	29 c3                	sub    %eax,%ebx
f010426b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010426e:	83 c4 10             	add    $0x10,%esp
f0104271:	85 db                	test   %ebx,%ebx
f0104273:	7e 24                	jle    f0104299 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0104275:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0104279:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010427c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010427f:	83 ec 08             	sub    $0x8,%esp
f0104282:	57                   	push   %edi
f0104283:	53                   	push   %ebx
f0104284:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104287:	4e                   	dec    %esi
f0104288:	83 c4 10             	add    $0x10,%esp
f010428b:	85 f6                	test   %esi,%esi
f010428d:	7f f0                	jg     f010427f <vprintfmt+0x1c6>
f010428f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104292:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104299:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010429c:	0f be 02             	movsbl (%edx),%eax
f010429f:	85 c0                	test   %eax,%eax
f01042a1:	75 47                	jne    f01042ea <vprintfmt+0x231>
f01042a3:	eb 37                	jmp    f01042dc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01042a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042a9:	74 16                	je     f01042c1 <vprintfmt+0x208>
f01042ab:	8d 50 e0             	lea    -0x20(%eax),%edx
f01042ae:	83 fa 5e             	cmp    $0x5e,%edx
f01042b1:	76 0e                	jbe    f01042c1 <vprintfmt+0x208>
					putch('?', putdat);
f01042b3:	83 ec 08             	sub    $0x8,%esp
f01042b6:	57                   	push   %edi
f01042b7:	6a 3f                	push   $0x3f
f01042b9:	ff 55 08             	call   *0x8(%ebp)
f01042bc:	83 c4 10             	add    $0x10,%esp
f01042bf:	eb 0b                	jmp    f01042cc <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01042c1:	83 ec 08             	sub    $0x8,%esp
f01042c4:	57                   	push   %edi
f01042c5:	50                   	push   %eax
f01042c6:	ff 55 08             	call   *0x8(%ebp)
f01042c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042cc:	ff 4d e4             	decl   -0x1c(%ebp)
f01042cf:	0f be 03             	movsbl (%ebx),%eax
f01042d2:	85 c0                	test   %eax,%eax
f01042d4:	74 03                	je     f01042d9 <vprintfmt+0x220>
f01042d6:	43                   	inc    %ebx
f01042d7:	eb 1b                	jmp    f01042f4 <vprintfmt+0x23b>
f01042d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01042dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01042e0:	7f 1e                	jg     f0104300 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042e2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01042e5:	e9 f3 fd ff ff       	jmp    f01040dd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01042ed:	43                   	inc    %ebx
f01042ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01042f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01042f4:	85 f6                	test   %esi,%esi
f01042f6:	78 ad                	js     f01042a5 <vprintfmt+0x1ec>
f01042f8:	4e                   	dec    %esi
f01042f9:	79 aa                	jns    f01042a5 <vprintfmt+0x1ec>
f01042fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01042fe:	eb dc                	jmp    f01042dc <vprintfmt+0x223>
f0104300:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104303:	83 ec 08             	sub    $0x8,%esp
f0104306:	57                   	push   %edi
f0104307:	6a 20                	push   $0x20
f0104309:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010430c:	4b                   	dec    %ebx
f010430d:	83 c4 10             	add    $0x10,%esp
f0104310:	85 db                	test   %ebx,%ebx
f0104312:	7f ef                	jg     f0104303 <vprintfmt+0x24a>
f0104314:	e9 c4 fd ff ff       	jmp    f01040dd <vprintfmt+0x24>
f0104319:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010431c:	89 ca                	mov    %ecx,%edx
f010431e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104321:	e8 2a fd ff ff       	call   f0104050 <getint>
f0104326:	89 c3                	mov    %eax,%ebx
f0104328:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010432a:	85 d2                	test   %edx,%edx
f010432c:	78 0a                	js     f0104338 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010432e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104333:	e9 b0 00 00 00       	jmp    f01043e8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104338:	83 ec 08             	sub    $0x8,%esp
f010433b:	57                   	push   %edi
f010433c:	6a 2d                	push   $0x2d
f010433e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104341:	f7 db                	neg    %ebx
f0104343:	83 d6 00             	adc    $0x0,%esi
f0104346:	f7 de                	neg    %esi
f0104348:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010434b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104350:	e9 93 00 00 00       	jmp    f01043e8 <vprintfmt+0x32f>
f0104355:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104358:	89 ca                	mov    %ecx,%edx
f010435a:	8d 45 14             	lea    0x14(%ebp),%eax
f010435d:	e8 b4 fc ff ff       	call   f0104016 <getuint>
f0104362:	89 c3                	mov    %eax,%ebx
f0104364:	89 d6                	mov    %edx,%esi
			base = 10;
f0104366:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010436b:	eb 7b                	jmp    f01043e8 <vprintfmt+0x32f>
f010436d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0104370:	89 ca                	mov    %ecx,%edx
f0104372:	8d 45 14             	lea    0x14(%ebp),%eax
f0104375:	e8 d6 fc ff ff       	call   f0104050 <getint>
f010437a:	89 c3                	mov    %eax,%ebx
f010437c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f010437e:	85 d2                	test   %edx,%edx
f0104380:	78 07                	js     f0104389 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0104382:	b8 08 00 00 00       	mov    $0x8,%eax
f0104387:	eb 5f                	jmp    f01043e8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0104389:	83 ec 08             	sub    $0x8,%esp
f010438c:	57                   	push   %edi
f010438d:	6a 2d                	push   $0x2d
f010438f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0104392:	f7 db                	neg    %ebx
f0104394:	83 d6 00             	adc    $0x0,%esi
f0104397:	f7 de                	neg    %esi
f0104399:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f010439c:	b8 08 00 00 00       	mov    $0x8,%eax
f01043a1:	eb 45                	jmp    f01043e8 <vprintfmt+0x32f>
f01043a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01043a6:	83 ec 08             	sub    $0x8,%esp
f01043a9:	57                   	push   %edi
f01043aa:	6a 30                	push   $0x30
f01043ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01043af:	83 c4 08             	add    $0x8,%esp
f01043b2:	57                   	push   %edi
f01043b3:	6a 78                	push   $0x78
f01043b5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01043b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01043bb:	8d 50 04             	lea    0x4(%eax),%edx
f01043be:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01043c1:	8b 18                	mov    (%eax),%ebx
f01043c3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01043c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01043cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01043d0:	eb 16                	jmp    f01043e8 <vprintfmt+0x32f>
f01043d2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01043d5:	89 ca                	mov    %ecx,%edx
f01043d7:	8d 45 14             	lea    0x14(%ebp),%eax
f01043da:	e8 37 fc ff ff       	call   f0104016 <getuint>
f01043df:	89 c3                	mov    %eax,%ebx
f01043e1:	89 d6                	mov    %edx,%esi
			base = 16;
f01043e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01043e8:	83 ec 0c             	sub    $0xc,%esp
f01043eb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01043ef:	52                   	push   %edx
f01043f0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01043f3:	50                   	push   %eax
f01043f4:	56                   	push   %esi
f01043f5:	53                   	push   %ebx
f01043f6:	89 fa                	mov    %edi,%edx
f01043f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01043fb:	e8 68 fb ff ff       	call   f0103f68 <printnum>
			break;
f0104400:	83 c4 20             	add    $0x20,%esp
f0104403:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104406:	e9 d2 fc ff ff       	jmp    f01040dd <vprintfmt+0x24>
f010440b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010440e:	83 ec 08             	sub    $0x8,%esp
f0104411:	57                   	push   %edi
f0104412:	52                   	push   %edx
f0104413:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104416:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104419:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010441c:	e9 bc fc ff ff       	jmp    f01040dd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104421:	83 ec 08             	sub    $0x8,%esp
f0104424:	57                   	push   %edi
f0104425:	6a 25                	push   $0x25
f0104427:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010442a:	83 c4 10             	add    $0x10,%esp
f010442d:	eb 02                	jmp    f0104431 <vprintfmt+0x378>
f010442f:	89 c6                	mov    %eax,%esi
f0104431:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104434:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104438:	75 f5                	jne    f010442f <vprintfmt+0x376>
f010443a:	e9 9e fc ff ff       	jmp    f01040dd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010443f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104442:	5b                   	pop    %ebx
f0104443:	5e                   	pop    %esi
f0104444:	5f                   	pop    %edi
f0104445:	c9                   	leave  
f0104446:	c3                   	ret    

f0104447 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104447:	55                   	push   %ebp
f0104448:	89 e5                	mov    %esp,%ebp
f010444a:	83 ec 18             	sub    $0x18,%esp
f010444d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104450:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104453:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104456:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010445a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010445d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104464:	85 c0                	test   %eax,%eax
f0104466:	74 26                	je     f010448e <vsnprintf+0x47>
f0104468:	85 d2                	test   %edx,%edx
f010446a:	7e 29                	jle    f0104495 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010446c:	ff 75 14             	pushl  0x14(%ebp)
f010446f:	ff 75 10             	pushl  0x10(%ebp)
f0104472:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104475:	50                   	push   %eax
f0104476:	68 82 40 10 f0       	push   $0xf0104082
f010447b:	e8 39 fc ff ff       	call   f01040b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104480:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104483:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104489:	83 c4 10             	add    $0x10,%esp
f010448c:	eb 0c                	jmp    f010449a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010448e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104493:	eb 05                	jmp    f010449a <vsnprintf+0x53>
f0104495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010449a:	c9                   	leave  
f010449b:	c3                   	ret    

f010449c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010449c:	55                   	push   %ebp
f010449d:	89 e5                	mov    %esp,%ebp
f010449f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01044a5:	50                   	push   %eax
f01044a6:	ff 75 10             	pushl  0x10(%ebp)
f01044a9:	ff 75 0c             	pushl  0xc(%ebp)
f01044ac:	ff 75 08             	pushl  0x8(%ebp)
f01044af:	e8 93 ff ff ff       	call   f0104447 <vsnprintf>
	va_end(ap);

	return rc;
}
f01044b4:	c9                   	leave  
f01044b5:	c3                   	ret    
	...

f01044b8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01044b8:	55                   	push   %ebp
f01044b9:	89 e5                	mov    %esp,%ebp
f01044bb:	57                   	push   %edi
f01044bc:	56                   	push   %esi
f01044bd:	53                   	push   %ebx
f01044be:	83 ec 0c             	sub    $0xc,%esp
f01044c1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01044c4:	85 c0                	test   %eax,%eax
f01044c6:	74 11                	je     f01044d9 <readline+0x21>
		cprintf("%s", prompt);
f01044c8:	83 ec 08             	sub    $0x8,%esp
f01044cb:	50                   	push   %eax
f01044cc:	68 05 5e 10 f0       	push   $0xf0105e05
f01044d1:	e8 4f f0 ff ff       	call   f0103525 <cprintf>
f01044d6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01044d9:	83 ec 0c             	sub    $0xc,%esp
f01044dc:	6a 00                	push   $0x0
f01044de:	e8 24 c1 ff ff       	call   f0100607 <iscons>
f01044e3:	89 c7                	mov    %eax,%edi
f01044e5:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01044e8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01044ed:	e8 04 c1 ff ff       	call   f01005f6 <getchar>
f01044f2:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01044f4:	85 c0                	test   %eax,%eax
f01044f6:	79 18                	jns    f0104510 <readline+0x58>
			cprintf("read error: %e\n", c);
f01044f8:	83 ec 08             	sub    $0x8,%esp
f01044fb:	50                   	push   %eax
f01044fc:	68 f4 67 10 f0       	push   $0xf01067f4
f0104501:	e8 1f f0 ff ff       	call   f0103525 <cprintf>
			return NULL;
f0104506:	83 c4 10             	add    $0x10,%esp
f0104509:	b8 00 00 00 00       	mov    $0x0,%eax
f010450e:	eb 6f                	jmp    f010457f <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104510:	83 f8 08             	cmp    $0x8,%eax
f0104513:	74 05                	je     f010451a <readline+0x62>
f0104515:	83 f8 7f             	cmp    $0x7f,%eax
f0104518:	75 18                	jne    f0104532 <readline+0x7a>
f010451a:	85 f6                	test   %esi,%esi
f010451c:	7e 14                	jle    f0104532 <readline+0x7a>
			if (echoing)
f010451e:	85 ff                	test   %edi,%edi
f0104520:	74 0d                	je     f010452f <readline+0x77>
				cputchar('\b');
f0104522:	83 ec 0c             	sub    $0xc,%esp
f0104525:	6a 08                	push   $0x8
f0104527:	e8 ba c0 ff ff       	call   f01005e6 <cputchar>
f010452c:	83 c4 10             	add    $0x10,%esp
			i--;
f010452f:	4e                   	dec    %esi
f0104530:	eb bb                	jmp    f01044ed <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104532:	83 fb 1f             	cmp    $0x1f,%ebx
f0104535:	7e 21                	jle    f0104558 <readline+0xa0>
f0104537:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010453d:	7f 19                	jg     f0104558 <readline+0xa0>
			if (echoing)
f010453f:	85 ff                	test   %edi,%edi
f0104541:	74 0c                	je     f010454f <readline+0x97>
				cputchar(c);
f0104543:	83 ec 0c             	sub    $0xc,%esp
f0104546:	53                   	push   %ebx
f0104547:	e8 9a c0 ff ff       	call   f01005e6 <cputchar>
f010454c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010454f:	88 9e e0 9b 1d f0    	mov    %bl,-0xfe26420(%esi)
f0104555:	46                   	inc    %esi
f0104556:	eb 95                	jmp    f01044ed <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104558:	83 fb 0a             	cmp    $0xa,%ebx
f010455b:	74 05                	je     f0104562 <readline+0xaa>
f010455d:	83 fb 0d             	cmp    $0xd,%ebx
f0104560:	75 8b                	jne    f01044ed <readline+0x35>
			if (echoing)
f0104562:	85 ff                	test   %edi,%edi
f0104564:	74 0d                	je     f0104573 <readline+0xbb>
				cputchar('\n');
f0104566:	83 ec 0c             	sub    $0xc,%esp
f0104569:	6a 0a                	push   $0xa
f010456b:	e8 76 c0 ff ff       	call   f01005e6 <cputchar>
f0104570:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104573:	c6 86 e0 9b 1d f0 00 	movb   $0x0,-0xfe26420(%esi)
			return buf;
f010457a:	b8 e0 9b 1d f0       	mov    $0xf01d9be0,%eax
		}
	}
}
f010457f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104582:	5b                   	pop    %ebx
f0104583:	5e                   	pop    %esi
f0104584:	5f                   	pop    %edi
f0104585:	c9                   	leave  
f0104586:	c3                   	ret    
	...

f0104588 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104588:	55                   	push   %ebp
f0104589:	89 e5                	mov    %esp,%ebp
f010458b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010458e:	80 3a 00             	cmpb   $0x0,(%edx)
f0104591:	74 0e                	je     f01045a1 <strlen+0x19>
f0104593:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104598:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104599:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010459d:	75 f9                	jne    f0104598 <strlen+0x10>
f010459f:	eb 05                	jmp    f01045a6 <strlen+0x1e>
f01045a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045a6:	c9                   	leave  
f01045a7:	c3                   	ret    

f01045a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01045a8:	55                   	push   %ebp
f01045a9:	89 e5                	mov    %esp,%ebp
f01045ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045b1:	85 d2                	test   %edx,%edx
f01045b3:	74 17                	je     f01045cc <strnlen+0x24>
f01045b5:	80 39 00             	cmpb   $0x0,(%ecx)
f01045b8:	74 19                	je     f01045d3 <strnlen+0x2b>
f01045ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01045bf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045c0:	39 d0                	cmp    %edx,%eax
f01045c2:	74 14                	je     f01045d8 <strnlen+0x30>
f01045c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01045c8:	75 f5                	jne    f01045bf <strnlen+0x17>
f01045ca:	eb 0c                	jmp    f01045d8 <strnlen+0x30>
f01045cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01045d1:	eb 05                	jmp    f01045d8 <strnlen+0x30>
f01045d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045d8:	c9                   	leave  
f01045d9:	c3                   	ret    

f01045da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01045da:	55                   	push   %ebp
f01045db:	89 e5                	mov    %esp,%ebp
f01045dd:	53                   	push   %ebx
f01045de:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01045e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01045e9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01045ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01045ef:	42                   	inc    %edx
f01045f0:	84 c9                	test   %cl,%cl
f01045f2:	75 f5                	jne    f01045e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01045f4:	5b                   	pop    %ebx
f01045f5:	c9                   	leave  
f01045f6:	c3                   	ret    

f01045f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01045f7:	55                   	push   %ebp
f01045f8:	89 e5                	mov    %esp,%ebp
f01045fa:	53                   	push   %ebx
f01045fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01045fe:	53                   	push   %ebx
f01045ff:	e8 84 ff ff ff       	call   f0104588 <strlen>
f0104604:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104607:	ff 75 0c             	pushl  0xc(%ebp)
f010460a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010460d:	50                   	push   %eax
f010460e:	e8 c7 ff ff ff       	call   f01045da <strcpy>
	return dst;
}
f0104613:	89 d8                	mov    %ebx,%eax
f0104615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104618:	c9                   	leave  
f0104619:	c3                   	ret    

f010461a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010461a:	55                   	push   %ebp
f010461b:	89 e5                	mov    %esp,%ebp
f010461d:	56                   	push   %esi
f010461e:	53                   	push   %ebx
f010461f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104622:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104625:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104628:	85 f6                	test   %esi,%esi
f010462a:	74 15                	je     f0104641 <strncpy+0x27>
f010462c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104631:	8a 1a                	mov    (%edx),%bl
f0104633:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104636:	80 3a 01             	cmpb   $0x1,(%edx)
f0104639:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010463c:	41                   	inc    %ecx
f010463d:	39 ce                	cmp    %ecx,%esi
f010463f:	77 f0                	ja     f0104631 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104641:	5b                   	pop    %ebx
f0104642:	5e                   	pop    %esi
f0104643:	c9                   	leave  
f0104644:	c3                   	ret    

f0104645 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104645:	55                   	push   %ebp
f0104646:	89 e5                	mov    %esp,%ebp
f0104648:	57                   	push   %edi
f0104649:	56                   	push   %esi
f010464a:	53                   	push   %ebx
f010464b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010464e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104651:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104654:	85 f6                	test   %esi,%esi
f0104656:	74 32                	je     f010468a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0104658:	83 fe 01             	cmp    $0x1,%esi
f010465b:	74 22                	je     f010467f <strlcpy+0x3a>
f010465d:	8a 0b                	mov    (%ebx),%cl
f010465f:	84 c9                	test   %cl,%cl
f0104661:	74 20                	je     f0104683 <strlcpy+0x3e>
f0104663:	89 f8                	mov    %edi,%eax
f0104665:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010466a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010466d:	88 08                	mov    %cl,(%eax)
f010466f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104670:	39 f2                	cmp    %esi,%edx
f0104672:	74 11                	je     f0104685 <strlcpy+0x40>
f0104674:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0104678:	42                   	inc    %edx
f0104679:	84 c9                	test   %cl,%cl
f010467b:	75 f0                	jne    f010466d <strlcpy+0x28>
f010467d:	eb 06                	jmp    f0104685 <strlcpy+0x40>
f010467f:	89 f8                	mov    %edi,%eax
f0104681:	eb 02                	jmp    f0104685 <strlcpy+0x40>
f0104683:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104685:	c6 00 00             	movb   $0x0,(%eax)
f0104688:	eb 02                	jmp    f010468c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010468a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f010468c:	29 f8                	sub    %edi,%eax
}
f010468e:	5b                   	pop    %ebx
f010468f:	5e                   	pop    %esi
f0104690:	5f                   	pop    %edi
f0104691:	c9                   	leave  
f0104692:	c3                   	ret    

f0104693 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104693:	55                   	push   %ebp
f0104694:	89 e5                	mov    %esp,%ebp
f0104696:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104699:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010469c:	8a 01                	mov    (%ecx),%al
f010469e:	84 c0                	test   %al,%al
f01046a0:	74 10                	je     f01046b2 <strcmp+0x1f>
f01046a2:	3a 02                	cmp    (%edx),%al
f01046a4:	75 0c                	jne    f01046b2 <strcmp+0x1f>
		p++, q++;
f01046a6:	41                   	inc    %ecx
f01046a7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01046a8:	8a 01                	mov    (%ecx),%al
f01046aa:	84 c0                	test   %al,%al
f01046ac:	74 04                	je     f01046b2 <strcmp+0x1f>
f01046ae:	3a 02                	cmp    (%edx),%al
f01046b0:	74 f4                	je     f01046a6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01046b2:	0f b6 c0             	movzbl %al,%eax
f01046b5:	0f b6 12             	movzbl (%edx),%edx
f01046b8:	29 d0                	sub    %edx,%eax
}
f01046ba:	c9                   	leave  
f01046bb:	c3                   	ret    

f01046bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01046bc:	55                   	push   %ebp
f01046bd:	89 e5                	mov    %esp,%ebp
f01046bf:	53                   	push   %ebx
f01046c0:	8b 55 08             	mov    0x8(%ebp),%edx
f01046c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01046c6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01046c9:	85 c0                	test   %eax,%eax
f01046cb:	74 1b                	je     f01046e8 <strncmp+0x2c>
f01046cd:	8a 1a                	mov    (%edx),%bl
f01046cf:	84 db                	test   %bl,%bl
f01046d1:	74 24                	je     f01046f7 <strncmp+0x3b>
f01046d3:	3a 19                	cmp    (%ecx),%bl
f01046d5:	75 20                	jne    f01046f7 <strncmp+0x3b>
f01046d7:	48                   	dec    %eax
f01046d8:	74 15                	je     f01046ef <strncmp+0x33>
		n--, p++, q++;
f01046da:	42                   	inc    %edx
f01046db:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01046dc:	8a 1a                	mov    (%edx),%bl
f01046de:	84 db                	test   %bl,%bl
f01046e0:	74 15                	je     f01046f7 <strncmp+0x3b>
f01046e2:	3a 19                	cmp    (%ecx),%bl
f01046e4:	74 f1                	je     f01046d7 <strncmp+0x1b>
f01046e6:	eb 0f                	jmp    f01046f7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01046e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01046ed:	eb 05                	jmp    f01046f4 <strncmp+0x38>
f01046ef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01046f4:	5b                   	pop    %ebx
f01046f5:	c9                   	leave  
f01046f6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01046f7:	0f b6 02             	movzbl (%edx),%eax
f01046fa:	0f b6 11             	movzbl (%ecx),%edx
f01046fd:	29 d0                	sub    %edx,%eax
f01046ff:	eb f3                	jmp    f01046f4 <strncmp+0x38>

f0104701 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104701:	55                   	push   %ebp
f0104702:	89 e5                	mov    %esp,%ebp
f0104704:	8b 45 08             	mov    0x8(%ebp),%eax
f0104707:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010470a:	8a 10                	mov    (%eax),%dl
f010470c:	84 d2                	test   %dl,%dl
f010470e:	74 18                	je     f0104728 <strchr+0x27>
		if (*s == c)
f0104710:	38 ca                	cmp    %cl,%dl
f0104712:	75 06                	jne    f010471a <strchr+0x19>
f0104714:	eb 17                	jmp    f010472d <strchr+0x2c>
f0104716:	38 ca                	cmp    %cl,%dl
f0104718:	74 13                	je     f010472d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010471a:	40                   	inc    %eax
f010471b:	8a 10                	mov    (%eax),%dl
f010471d:	84 d2                	test   %dl,%dl
f010471f:	75 f5                	jne    f0104716 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0104721:	b8 00 00 00 00       	mov    $0x0,%eax
f0104726:	eb 05                	jmp    f010472d <strchr+0x2c>
f0104728:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010472d:	c9                   	leave  
f010472e:	c3                   	ret    

f010472f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010472f:	55                   	push   %ebp
f0104730:	89 e5                	mov    %esp,%ebp
f0104732:	8b 45 08             	mov    0x8(%ebp),%eax
f0104735:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104738:	8a 10                	mov    (%eax),%dl
f010473a:	84 d2                	test   %dl,%dl
f010473c:	74 11                	je     f010474f <strfind+0x20>
		if (*s == c)
f010473e:	38 ca                	cmp    %cl,%dl
f0104740:	75 06                	jne    f0104748 <strfind+0x19>
f0104742:	eb 0b                	jmp    f010474f <strfind+0x20>
f0104744:	38 ca                	cmp    %cl,%dl
f0104746:	74 07                	je     f010474f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104748:	40                   	inc    %eax
f0104749:	8a 10                	mov    (%eax),%dl
f010474b:	84 d2                	test   %dl,%dl
f010474d:	75 f5                	jne    f0104744 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010474f:	c9                   	leave  
f0104750:	c3                   	ret    

f0104751 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104751:	55                   	push   %ebp
f0104752:	89 e5                	mov    %esp,%ebp
f0104754:	57                   	push   %edi
f0104755:	56                   	push   %esi
f0104756:	53                   	push   %ebx
f0104757:	8b 7d 08             	mov    0x8(%ebp),%edi
f010475a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010475d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104760:	85 c9                	test   %ecx,%ecx
f0104762:	74 30                	je     f0104794 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104764:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010476a:	75 25                	jne    f0104791 <memset+0x40>
f010476c:	f6 c1 03             	test   $0x3,%cl
f010476f:	75 20                	jne    f0104791 <memset+0x40>
		c &= 0xFF;
f0104771:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104774:	89 d3                	mov    %edx,%ebx
f0104776:	c1 e3 08             	shl    $0x8,%ebx
f0104779:	89 d6                	mov    %edx,%esi
f010477b:	c1 e6 18             	shl    $0x18,%esi
f010477e:	89 d0                	mov    %edx,%eax
f0104780:	c1 e0 10             	shl    $0x10,%eax
f0104783:	09 f0                	or     %esi,%eax
f0104785:	09 d0                	or     %edx,%eax
f0104787:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104789:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010478c:	fc                   	cld    
f010478d:	f3 ab                	rep stos %eax,%es:(%edi)
f010478f:	eb 03                	jmp    f0104794 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104791:	fc                   	cld    
f0104792:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104794:	89 f8                	mov    %edi,%eax
f0104796:	5b                   	pop    %ebx
f0104797:	5e                   	pop    %esi
f0104798:	5f                   	pop    %edi
f0104799:	c9                   	leave  
f010479a:	c3                   	ret    

f010479b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010479b:	55                   	push   %ebp
f010479c:	89 e5                	mov    %esp,%ebp
f010479e:	57                   	push   %edi
f010479f:	56                   	push   %esi
f01047a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01047a3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047a9:	39 c6                	cmp    %eax,%esi
f01047ab:	73 34                	jae    f01047e1 <memmove+0x46>
f01047ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01047b0:	39 d0                	cmp    %edx,%eax
f01047b2:	73 2d                	jae    f01047e1 <memmove+0x46>
		s += n;
		d += n;
f01047b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047b7:	f6 c2 03             	test   $0x3,%dl
f01047ba:	75 1b                	jne    f01047d7 <memmove+0x3c>
f01047bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01047c2:	75 13                	jne    f01047d7 <memmove+0x3c>
f01047c4:	f6 c1 03             	test   $0x3,%cl
f01047c7:	75 0e                	jne    f01047d7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01047c9:	83 ef 04             	sub    $0x4,%edi
f01047cc:	8d 72 fc             	lea    -0x4(%edx),%esi
f01047cf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01047d2:	fd                   	std    
f01047d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047d5:	eb 07                	jmp    f01047de <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047d7:	4f                   	dec    %edi
f01047d8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01047db:	fd                   	std    
f01047dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01047de:	fc                   	cld    
f01047df:	eb 20                	jmp    f0104801 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01047e7:	75 13                	jne    f01047fc <memmove+0x61>
f01047e9:	a8 03                	test   $0x3,%al
f01047eb:	75 0f                	jne    f01047fc <memmove+0x61>
f01047ed:	f6 c1 03             	test   $0x3,%cl
f01047f0:	75 0a                	jne    f01047fc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01047f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01047f5:	89 c7                	mov    %eax,%edi
f01047f7:	fc                   	cld    
f01047f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047fa:	eb 05                	jmp    f0104801 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01047fc:	89 c7                	mov    %eax,%edi
f01047fe:	fc                   	cld    
f01047ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104801:	5e                   	pop    %esi
f0104802:	5f                   	pop    %edi
f0104803:	c9                   	leave  
f0104804:	c3                   	ret    

f0104805 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104805:	55                   	push   %ebp
f0104806:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104808:	ff 75 10             	pushl  0x10(%ebp)
f010480b:	ff 75 0c             	pushl  0xc(%ebp)
f010480e:	ff 75 08             	pushl  0x8(%ebp)
f0104811:	e8 85 ff ff ff       	call   f010479b <memmove>
}
f0104816:	c9                   	leave  
f0104817:	c3                   	ret    

f0104818 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104818:	55                   	push   %ebp
f0104819:	89 e5                	mov    %esp,%ebp
f010481b:	57                   	push   %edi
f010481c:	56                   	push   %esi
f010481d:	53                   	push   %ebx
f010481e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104821:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104824:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104827:	85 ff                	test   %edi,%edi
f0104829:	74 32                	je     f010485d <memcmp+0x45>
		if (*s1 != *s2)
f010482b:	8a 03                	mov    (%ebx),%al
f010482d:	8a 0e                	mov    (%esi),%cl
f010482f:	38 c8                	cmp    %cl,%al
f0104831:	74 19                	je     f010484c <memcmp+0x34>
f0104833:	eb 0d                	jmp    f0104842 <memcmp+0x2a>
f0104835:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0104839:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010483d:	42                   	inc    %edx
f010483e:	38 c8                	cmp    %cl,%al
f0104840:	74 10                	je     f0104852 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0104842:	0f b6 c0             	movzbl %al,%eax
f0104845:	0f b6 c9             	movzbl %cl,%ecx
f0104848:	29 c8                	sub    %ecx,%eax
f010484a:	eb 16                	jmp    f0104862 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010484c:	4f                   	dec    %edi
f010484d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104852:	39 fa                	cmp    %edi,%edx
f0104854:	75 df                	jne    f0104835 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104856:	b8 00 00 00 00       	mov    $0x0,%eax
f010485b:	eb 05                	jmp    f0104862 <memcmp+0x4a>
f010485d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104862:	5b                   	pop    %ebx
f0104863:	5e                   	pop    %esi
f0104864:	5f                   	pop    %edi
f0104865:	c9                   	leave  
f0104866:	c3                   	ret    

f0104867 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104867:	55                   	push   %ebp
f0104868:	89 e5                	mov    %esp,%ebp
f010486a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010486d:	89 c2                	mov    %eax,%edx
f010486f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104872:	39 d0                	cmp    %edx,%eax
f0104874:	73 12                	jae    f0104888 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104876:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0104879:	38 08                	cmp    %cl,(%eax)
f010487b:	75 06                	jne    f0104883 <memfind+0x1c>
f010487d:	eb 09                	jmp    f0104888 <memfind+0x21>
f010487f:	38 08                	cmp    %cl,(%eax)
f0104881:	74 05                	je     f0104888 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104883:	40                   	inc    %eax
f0104884:	39 c2                	cmp    %eax,%edx
f0104886:	77 f7                	ja     f010487f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104888:	c9                   	leave  
f0104889:	c3                   	ret    

f010488a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010488a:	55                   	push   %ebp
f010488b:	89 e5                	mov    %esp,%ebp
f010488d:	57                   	push   %edi
f010488e:	56                   	push   %esi
f010488f:	53                   	push   %ebx
f0104890:	8b 55 08             	mov    0x8(%ebp),%edx
f0104893:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104896:	eb 01                	jmp    f0104899 <strtol+0xf>
		s++;
f0104898:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104899:	8a 02                	mov    (%edx),%al
f010489b:	3c 20                	cmp    $0x20,%al
f010489d:	74 f9                	je     f0104898 <strtol+0xe>
f010489f:	3c 09                	cmp    $0x9,%al
f01048a1:	74 f5                	je     f0104898 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01048a3:	3c 2b                	cmp    $0x2b,%al
f01048a5:	75 08                	jne    f01048af <strtol+0x25>
		s++;
f01048a7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048a8:	bf 00 00 00 00       	mov    $0x0,%edi
f01048ad:	eb 13                	jmp    f01048c2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01048af:	3c 2d                	cmp    $0x2d,%al
f01048b1:	75 0a                	jne    f01048bd <strtol+0x33>
		s++, neg = 1;
f01048b3:	8d 52 01             	lea    0x1(%edx),%edx
f01048b6:	bf 01 00 00 00       	mov    $0x1,%edi
f01048bb:	eb 05                	jmp    f01048c2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048c2:	85 db                	test   %ebx,%ebx
f01048c4:	74 05                	je     f01048cb <strtol+0x41>
f01048c6:	83 fb 10             	cmp    $0x10,%ebx
f01048c9:	75 28                	jne    f01048f3 <strtol+0x69>
f01048cb:	8a 02                	mov    (%edx),%al
f01048cd:	3c 30                	cmp    $0x30,%al
f01048cf:	75 10                	jne    f01048e1 <strtol+0x57>
f01048d1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01048d5:	75 0a                	jne    f01048e1 <strtol+0x57>
		s += 2, base = 16;
f01048d7:	83 c2 02             	add    $0x2,%edx
f01048da:	bb 10 00 00 00       	mov    $0x10,%ebx
f01048df:	eb 12                	jmp    f01048f3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01048e1:	85 db                	test   %ebx,%ebx
f01048e3:	75 0e                	jne    f01048f3 <strtol+0x69>
f01048e5:	3c 30                	cmp    $0x30,%al
f01048e7:	75 05                	jne    f01048ee <strtol+0x64>
		s++, base = 8;
f01048e9:	42                   	inc    %edx
f01048ea:	b3 08                	mov    $0x8,%bl
f01048ec:	eb 05                	jmp    f01048f3 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01048ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01048f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01048f8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01048fa:	8a 0a                	mov    (%edx),%cl
f01048fc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01048ff:	80 fb 09             	cmp    $0x9,%bl
f0104902:	77 08                	ja     f010490c <strtol+0x82>
			dig = *s - '0';
f0104904:	0f be c9             	movsbl %cl,%ecx
f0104907:	83 e9 30             	sub    $0x30,%ecx
f010490a:	eb 1e                	jmp    f010492a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010490c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010490f:	80 fb 19             	cmp    $0x19,%bl
f0104912:	77 08                	ja     f010491c <strtol+0x92>
			dig = *s - 'a' + 10;
f0104914:	0f be c9             	movsbl %cl,%ecx
f0104917:	83 e9 57             	sub    $0x57,%ecx
f010491a:	eb 0e                	jmp    f010492a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010491c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010491f:	80 fb 19             	cmp    $0x19,%bl
f0104922:	77 13                	ja     f0104937 <strtol+0xad>
			dig = *s - 'A' + 10;
f0104924:	0f be c9             	movsbl %cl,%ecx
f0104927:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010492a:	39 f1                	cmp    %esi,%ecx
f010492c:	7d 0d                	jge    f010493b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010492e:	42                   	inc    %edx
f010492f:	0f af c6             	imul   %esi,%eax
f0104932:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104935:	eb c3                	jmp    f01048fa <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104937:	89 c1                	mov    %eax,%ecx
f0104939:	eb 02                	jmp    f010493d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010493b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010493d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104941:	74 05                	je     f0104948 <strtol+0xbe>
		*endptr = (char *) s;
f0104943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104946:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104948:	85 ff                	test   %edi,%edi
f010494a:	74 04                	je     f0104950 <strtol+0xc6>
f010494c:	89 c8                	mov    %ecx,%eax
f010494e:	f7 d8                	neg    %eax
}
f0104950:	5b                   	pop    %ebx
f0104951:	5e                   	pop    %esi
f0104952:	5f                   	pop    %edi
f0104953:	c9                   	leave  
f0104954:	c3                   	ret    
f0104955:	00 00                	add    %al,(%eax)
	...

f0104958 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0104958:	55                   	push   %ebp
f0104959:	89 e5                	mov    %esp,%ebp
f010495b:	57                   	push   %edi
f010495c:	56                   	push   %esi
f010495d:	83 ec 10             	sub    $0x10,%esp
f0104960:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104963:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104966:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0104969:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010496c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010496f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104972:	85 c0                	test   %eax,%eax
f0104974:	75 2e                	jne    f01049a4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104976:	39 f1                	cmp    %esi,%ecx
f0104978:	77 5a                	ja     f01049d4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010497a:	85 c9                	test   %ecx,%ecx
f010497c:	75 0b                	jne    f0104989 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010497e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104983:	31 d2                	xor    %edx,%edx
f0104985:	f7 f1                	div    %ecx
f0104987:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104989:	31 d2                	xor    %edx,%edx
f010498b:	89 f0                	mov    %esi,%eax
f010498d:	f7 f1                	div    %ecx
f010498f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104991:	89 f8                	mov    %edi,%eax
f0104993:	f7 f1                	div    %ecx
f0104995:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104997:	89 f8                	mov    %edi,%eax
f0104999:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010499b:	83 c4 10             	add    $0x10,%esp
f010499e:	5e                   	pop    %esi
f010499f:	5f                   	pop    %edi
f01049a0:	c9                   	leave  
f01049a1:	c3                   	ret    
f01049a2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01049a4:	39 f0                	cmp    %esi,%eax
f01049a6:	77 1c                	ja     f01049c4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01049a8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01049ab:	83 f7 1f             	xor    $0x1f,%edi
f01049ae:	75 3c                	jne    f01049ec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01049b0:	39 f0                	cmp    %esi,%eax
f01049b2:	0f 82 90 00 00 00    	jb     f0104a48 <__udivdi3+0xf0>
f01049b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01049bb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01049be:	0f 86 84 00 00 00    	jbe    f0104a48 <__udivdi3+0xf0>
f01049c4:	31 f6                	xor    %esi,%esi
f01049c6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049c8:	89 f8                	mov    %edi,%eax
f01049ca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049cc:	83 c4 10             	add    $0x10,%esp
f01049cf:	5e                   	pop    %esi
f01049d0:	5f                   	pop    %edi
f01049d1:	c9                   	leave  
f01049d2:	c3                   	ret    
f01049d3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01049d4:	89 f2                	mov    %esi,%edx
f01049d6:	89 f8                	mov    %edi,%eax
f01049d8:	f7 f1                	div    %ecx
f01049da:	89 c7                	mov    %eax,%edi
f01049dc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049de:	89 f8                	mov    %edi,%eax
f01049e0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049e2:	83 c4 10             	add    $0x10,%esp
f01049e5:	5e                   	pop    %esi
f01049e6:	5f                   	pop    %edi
f01049e7:	c9                   	leave  
f01049e8:	c3                   	ret    
f01049e9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01049ec:	89 f9                	mov    %edi,%ecx
f01049ee:	d3 e0                	shl    %cl,%eax
f01049f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01049f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01049f8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01049fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049fd:	88 c1                	mov    %al,%cl
f01049ff:	d3 ea                	shr    %cl,%edx
f0104a01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a04:	09 ca                	or     %ecx,%edx
f0104a06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104a09:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a0c:	89 f9                	mov    %edi,%ecx
f0104a0e:	d3 e2                	shl    %cl,%edx
f0104a10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104a13:	89 f2                	mov    %esi,%edx
f0104a15:	88 c1                	mov    %al,%cl
f0104a17:	d3 ea                	shr    %cl,%edx
f0104a19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0104a1c:	89 f2                	mov    %esi,%edx
f0104a1e:	89 f9                	mov    %edi,%ecx
f0104a20:	d3 e2                	shl    %cl,%edx
f0104a22:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104a25:	88 c1                	mov    %al,%cl
f0104a27:	d3 ee                	shr    %cl,%esi
f0104a29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104a2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a2e:	89 f0                	mov    %esi,%eax
f0104a30:	89 ca                	mov    %ecx,%edx
f0104a32:	f7 75 ec             	divl   -0x14(%ebp)
f0104a35:	89 d1                	mov    %edx,%ecx
f0104a37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104a39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a3c:	39 d1                	cmp    %edx,%ecx
f0104a3e:	72 28                	jb     f0104a68 <__udivdi3+0x110>
f0104a40:	74 1a                	je     f0104a5c <__udivdi3+0x104>
f0104a42:	89 f7                	mov    %esi,%edi
f0104a44:	31 f6                	xor    %esi,%esi
f0104a46:	eb 80                	jmp    f01049c8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104a48:	31 f6                	xor    %esi,%esi
f0104a4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a4f:	89 f8                	mov    %edi,%eax
f0104a51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a53:	83 c4 10             	add    $0x10,%esp
f0104a56:	5e                   	pop    %esi
f0104a57:	5f                   	pop    %edi
f0104a58:	c9                   	leave  
f0104a59:	c3                   	ret    
f0104a5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104a5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104a5f:	89 f9                	mov    %edi,%ecx
f0104a61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a63:	39 c2                	cmp    %eax,%edx
f0104a65:	73 db                	jae    f0104a42 <__udivdi3+0xea>
f0104a67:	90                   	nop
		{
		  q0--;
f0104a68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104a6b:	31 f6                	xor    %esi,%esi
f0104a6d:	e9 56 ff ff ff       	jmp    f01049c8 <__udivdi3+0x70>
	...

f0104a74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104a74:	55                   	push   %ebp
f0104a75:	89 e5                	mov    %esp,%ebp
f0104a77:	57                   	push   %edi
f0104a78:	56                   	push   %esi
f0104a79:	83 ec 20             	sub    $0x20,%esp
f0104a7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104a82:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104a88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104a8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104a91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104a93:	85 ff                	test   %edi,%edi
f0104a95:	75 15                	jne    f0104aac <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104a97:	39 f1                	cmp    %esi,%ecx
f0104a99:	0f 86 99 00 00 00    	jbe    f0104b38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104a9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104aa1:	89 d0                	mov    %edx,%eax
f0104aa3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104aa5:	83 c4 20             	add    $0x20,%esp
f0104aa8:	5e                   	pop    %esi
f0104aa9:	5f                   	pop    %edi
f0104aaa:	c9                   	leave  
f0104aab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104aac:	39 f7                	cmp    %esi,%edi
f0104aae:	0f 87 a4 00 00 00    	ja     f0104b58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104ab4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104ab7:	83 f0 1f             	xor    $0x1f,%eax
f0104aba:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104abd:	0f 84 a1 00 00 00    	je     f0104b64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104ac3:	89 f8                	mov    %edi,%eax
f0104ac5:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104ac8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104aca:	bf 20 00 00 00       	mov    $0x20,%edi
f0104acf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104ad2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104ad5:	89 f9                	mov    %edi,%ecx
f0104ad7:	d3 ea                	shr    %cl,%edx
f0104ad9:	09 c2                	or     %eax,%edx
f0104adb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ae1:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104ae4:	d3 e0                	shl    %cl,%eax
f0104ae6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104ae9:	89 f2                	mov    %esi,%edx
f0104aeb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104aed:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104af0:	d3 e0                	shl    %cl,%eax
f0104af2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104af5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104af8:	89 f9                	mov    %edi,%ecx
f0104afa:	d3 e8                	shr    %cl,%eax
f0104afc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104afe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104b00:	89 f2                	mov    %esi,%edx
f0104b02:	f7 75 f0             	divl   -0x10(%ebp)
f0104b05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104b07:	f7 65 f4             	mull   -0xc(%ebp)
f0104b0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104b0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b0f:	39 d6                	cmp    %edx,%esi
f0104b11:	72 71                	jb     f0104b84 <__umoddi3+0x110>
f0104b13:	74 7f                	je     f0104b94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b18:	29 c8                	sub    %ecx,%eax
f0104b1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0104b1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b1f:	d3 e8                	shr    %cl,%eax
f0104b21:	89 f2                	mov    %esi,%edx
f0104b23:	89 f9                	mov    %edi,%ecx
f0104b25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0104b27:	09 d0                	or     %edx,%eax
f0104b29:	89 f2                	mov    %esi,%edx
f0104b2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b30:	83 c4 20             	add    $0x20,%esp
f0104b33:	5e                   	pop    %esi
f0104b34:	5f                   	pop    %edi
f0104b35:	c9                   	leave  
f0104b36:	c3                   	ret    
f0104b37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104b38:	85 c9                	test   %ecx,%ecx
f0104b3a:	75 0b                	jne    f0104b47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104b3c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b41:	31 d2                	xor    %edx,%edx
f0104b43:	f7 f1                	div    %ecx
f0104b45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104b47:	89 f0                	mov    %esi,%eax
f0104b49:	31 d2                	xor    %edx,%edx
f0104b4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b50:	f7 f1                	div    %ecx
f0104b52:	e9 4a ff ff ff       	jmp    f0104aa1 <__umoddi3+0x2d>
f0104b57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104b58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b5a:	83 c4 20             	add    $0x20,%esp
f0104b5d:	5e                   	pop    %esi
f0104b5e:	5f                   	pop    %edi
f0104b5f:	c9                   	leave  
f0104b60:	c3                   	ret    
f0104b61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104b64:	39 f7                	cmp    %esi,%edi
f0104b66:	72 05                	jb     f0104b6d <__umoddi3+0xf9>
f0104b68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104b6b:	77 0c                	ja     f0104b79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104b6d:	89 f2                	mov    %esi,%edx
f0104b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b72:	29 c8                	sub    %ecx,%eax
f0104b74:	19 fa                	sbb    %edi,%edx
f0104b76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b7c:	83 c4 20             	add    $0x20,%esp
f0104b7f:	5e                   	pop    %esi
f0104b80:	5f                   	pop    %edi
f0104b81:	c9                   	leave  
f0104b82:	c3                   	ret    
f0104b83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104b84:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104b87:	89 c1                	mov    %eax,%ecx
f0104b89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104b8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104b8f:	eb 84                	jmp    f0104b15 <__umoddi3+0xa1>
f0104b91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104b97:	72 eb                	jb     f0104b84 <__umoddi3+0x110>
f0104b99:	89 f2                	mov    %esi,%edx
f0104b9b:	e9 75 ff ff ff       	jmp    f0104b15 <__umoddi3+0xa1>
