
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 bf 0a 00 00       	call   800af0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800081:	b2 f7                	mov    $0xf7,%dl
  800083:	ec                   	in     (%dx),%al
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800084:	a8 a1                	test   $0xa1,%al
  800086:	75 12                	jne    80009a <ide_probe_disk1+0x32>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800088:	bb 00 00 00 00       	mov    $0x0,%ebx
  80008d:	eb 1a                	jmp    8000a9 <ide_probe_disk1+0x41>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008f:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800090:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800096:	75 0c                	jne    8000a4 <ide_probe_disk1+0x3c>
  800098:	eb 0f                	jmp    8000a9 <ide_probe_disk1+0x41>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80009a:	bb 01 00 00 00       	mov    $0x1,%ebx
  80009f:	ba f7 01 00 00       	mov    $0x1f7,%edx
  8000a4:	ec                   	in     (%dx),%al
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  8000a5:	a8 a1                	test   $0xa1,%al
  8000a7:	75 e6                	jne    80008f <ide_probe_disk1+0x27>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000a9:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000ae:	b0 e0                	mov    $0xe0,%al
  8000b0:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000b1:	83 ec 08             	sub    $0x8,%esp
  8000b4:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000ba:	0f 9e c0             	setle  %al
  8000bd:	0f b6 c0             	movzbl %al,%eax
  8000c0:	50                   	push   %eax
  8000c1:	68 c0 28 80 00       	push   $0x8028c0
  8000c6:	e8 69 0b 00 00       	call   800c34 <cprintf>
	return (x < 1000);
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000d4:	0f 9e c0             	setle  %al
}
  8000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000e5:	83 f8 01             	cmp    $0x1,%eax
  8000e8:	76 14                	jbe    8000fe <ide_set_disk+0x22>
		panic("bad disk number");
  8000ea:	83 ec 04             	sub    $0x4,%esp
  8000ed:	68 d7 28 80 00       	push   $0x8028d7
  8000f2:	6a 3a                	push   $0x3a
  8000f4:	68 e7 28 80 00       	push   $0x8028e7
  8000f9:	e8 5e 0a 00 00       	call   800b5c <_panic>
	diskno = d;
  8000fe:	a3 00 30 80 00       	mov    %eax,0x803000
}
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800114:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800117:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80011d:	76 16                	jbe    800135 <ide_read+0x30>
  80011f:	68 f0 28 80 00       	push   $0x8028f0
  800124:	68 fd 28 80 00       	push   $0x8028fd
  800129:	6a 43                	push   $0x43
  80012b:	68 e7 28 80 00       	push   $0x8028e7
  800130:	e8 27 0a 00 00       	call   800b5c <_panic>

	ide_wait_ready(0);
  800135:	b8 00 00 00 00       	mov    $0x0,%eax
  80013a:	e8 f5 fe ff ff       	call   800034 <ide_wait_ready>
  80013f:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800144:	89 f0                	mov    %esi,%eax
  800146:	ee                   	out    %al,(%dx)
  800147:	b2 f3                	mov    $0xf3,%dl
  800149:	89 f8                	mov    %edi,%eax
  80014b:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80014c:	89 f8                	mov    %edi,%eax
  80014e:	c1 e8 08             	shr    $0x8,%eax
  800151:	b2 f4                	mov    $0xf4,%dl
  800153:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800154:	89 f8                	mov    %edi,%eax
  800156:	c1 e8 10             	shr    $0x10,%eax
  800159:	b2 f5                	mov    $0xf5,%dl
  80015b:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80015c:	a1 00 30 80 00       	mov    0x803000,%eax
  800161:	83 e0 01             	and    $0x1,%eax
  800164:	c1 e0 04             	shl    $0x4,%eax
  800167:	83 c8 e0             	or     $0xffffffe0,%eax
  80016a:	c1 ef 18             	shr    $0x18,%edi
  80016d:	83 e7 0f             	and    $0xf,%edi
  800170:	09 f8                	or     %edi,%eax
  800172:	b2 f6                	mov    $0xf6,%dl
  800174:	ee                   	out    %al,(%dx)
  800175:	b2 f7                	mov    $0xf7,%dl
  800177:	b0 20                	mov    $0x20,%al
  800179:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80017a:	85 f6                	test   %esi,%esi
  80017c:	74 28                	je     8001a6 <ide_read+0xa1>
		if ((r = ide_wait_ready(1)) < 0)
  80017e:	b8 01 00 00 00       	mov    $0x1,%eax
  800183:	e8 ac fe ff ff       	call   800034 <ide_wait_ready>
  800188:	85 c0                	test   %eax,%eax
  80018a:	78 26                	js     8001b2 <ide_read+0xad>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018c:	89 df                	mov    %ebx,%edi
  80018e:	b9 80 00 00 00       	mov    $0x80,%ecx
  800193:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800198:	fc                   	cld    
  800199:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019b:	4e                   	dec    %esi
  80019c:	74 0f                	je     8001ad <ide_read+0xa8>
  80019e:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001a4:	eb d8                	jmp    80017e <ide_read+0x79>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ab:	eb 05                	jmp    8001b2 <ide_read+0xad>
  8001ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b5:	5b                   	pop    %ebx
  8001b6:	5e                   	pop    %esi
  8001b7:	5f                   	pop    %edi
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c9:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001cc:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001d2:	76 16                	jbe    8001ea <ide_write+0x30>
  8001d4:	68 f0 28 80 00       	push   $0x8028f0
  8001d9:	68 fd 28 80 00       	push   $0x8028fd
  8001de:	6a 5c                	push   $0x5c
  8001e0:	68 e7 28 80 00       	push   $0x8028e7
  8001e5:	e8 72 09 00 00       	call   800b5c <_panic>

	ide_wait_ready(0);
  8001ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ef:	e8 40 fe ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001f4:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001f9:	89 f8                	mov    %edi,%eax
  8001fb:	ee                   	out    %al,(%dx)
  8001fc:	b2 f3                	mov    $0xf3,%dl
  8001fe:	89 f0                	mov    %esi,%eax
  800200:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800201:	89 f0                	mov    %esi,%eax
  800203:	c1 e8 08             	shr    $0x8,%eax
  800206:	b2 f4                	mov    $0xf4,%dl
  800208:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800209:	89 f0                	mov    %esi,%eax
  80020b:	c1 e8 10             	shr    $0x10,%eax
  80020e:	b2 f5                	mov    $0xf5,%dl
  800210:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800211:	a1 00 30 80 00       	mov    0x803000,%eax
  800216:	83 e0 01             	and    $0x1,%eax
  800219:	c1 e0 04             	shl    $0x4,%eax
  80021c:	83 c8 e0             	or     $0xffffffe0,%eax
  80021f:	c1 ee 18             	shr    $0x18,%esi
  800222:	83 e6 0f             	and    $0xf,%esi
  800225:	09 f0                	or     %esi,%eax
  800227:	b2 f6                	mov    $0xf6,%dl
  800229:	ee                   	out    %al,(%dx)
  80022a:	b2 f7                	mov    $0xf7,%dl
  80022c:	b0 30                	mov    $0x30,%al
  80022e:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80022f:	85 ff                	test   %edi,%edi
  800231:	74 28                	je     80025b <ide_write+0xa1>
		if ((r = ide_wait_ready(1)) < 0)
  800233:	b8 01 00 00 00       	mov    $0x1,%eax
  800238:	e8 f7 fd ff ff       	call   800034 <ide_wait_ready>
  80023d:	85 c0                	test   %eax,%eax
  80023f:	78 26                	js     800267 <ide_write+0xad>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800241:	89 de                	mov    %ebx,%esi
  800243:	b9 80 00 00 00       	mov    $0x80,%ecx
  800248:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80024d:	fc                   	cld    
  80024e:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800250:	4f                   	dec    %edi
  800251:	74 0f                	je     800262 <ide_write+0xa8>
  800253:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800259:	eb d8                	jmp    800233 <ide_write+0x79>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80025b:	b8 00 00 00 00       	mov    $0x0,%eax
  800260:	eb 05                	jmp    800267 <ide_write+0xad>
  800262:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    
	...

00800270 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800278:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800280:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800286:	76 1b                	jbe    8002a3 <bc_pgfault+0x33>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	ff 70 04             	pushl  0x4(%eax)
  80028e:	53                   	push   %ebx
  80028f:	ff 70 28             	pushl  0x28(%eax)
  800292:	68 14 29 80 00       	push   $0x802914
  800297:	6a 19                	push   $0x19
  800299:	68 d2 29 80 00       	push   $0x8029d2
  80029e:	e8 b9 08 00 00       	call   800b5c <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002a3:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002a9:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ac:	a1 08 80 80 00       	mov    0x808008,%eax
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	74 17                	je     8002cc <bc_pgfault+0x5c>
  8002b5:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b8:	72 12                	jb     8002cc <bc_pgfault+0x5c>
		panic("reading non-existent block %08x\n", blockno);
  8002ba:	56                   	push   %esi
  8002bb:	68 44 29 80 00       	push   $0x802944
  8002c0:	6a 1d                	push   $0x1d
  8002c2:	68 d2 29 80 00       	push   $0x8029d2
  8002c7:	e8 90 08 00 00       	call   800b5c <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary.
	//
	// LAB 5: you code here:
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8002cc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P);
  8002d2:	83 ec 04             	sub    $0x4,%esp
  8002d5:	6a 07                	push   $0x7
  8002d7:	53                   	push   %ebx
  8002d8:	6a 00                	push   $0x0
  8002da:	e8 8d 13 00 00       	call   80166c <sys_page_alloc>
	if (r < 0) panic("bc_pgfault sys_page_alloc error : %e\n", r);
  8002df:	83 c4 10             	add    $0x10,%esp
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	79 12                	jns    8002f8 <bc_pgfault+0x88>
  8002e6:	50                   	push   %eax
  8002e7:	68 68 29 80 00       	push   $0x802968
  8002ec:	6a 27                	push   $0x27
  8002ee:	68 d2 29 80 00       	push   $0x8029d2
  8002f3:	e8 64 08 00 00       	call   800b5c <_panic>

	r = ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  8002f8:	83 ec 04             	sub    $0x4,%esp
  8002fb:	6a 08                	push   $0x8
  8002fd:	53                   	push   %ebx
  8002fe:	c1 e6 03             	shl    $0x3,%esi
  800301:	56                   	push   %esi
  800302:	e8 fe fd ff ff       	call   800105 <ide_read>
	if (r < 0) panic("bc_pgfault ide_read error : %e\n", r);
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	85 c0                	test   %eax,%eax
  80030c:	79 12                	jns    800320 <bc_pgfault+0xb0>
  80030e:	50                   	push   %eax
  80030f:	68 90 29 80 00       	push   $0x802990
  800314:	6a 2a                	push   $0x2a
  800316:	68 d2 29 80 00       	push   $0x8029d2
  80031b:	e8 3c 08 00 00       	call   800b5c <_panic>
}
  800320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800330:	85 c0                	test   %eax,%eax
  800332:	74 0f                	je     800343 <diskaddr+0x1c>
  800334:	8b 15 08 80 80 00    	mov    0x808008,%edx
  80033a:	85 d2                	test   %edx,%edx
  80033c:	74 17                	je     800355 <diskaddr+0x2e>
  80033e:	3b 42 04             	cmp    0x4(%edx),%eax
  800341:	72 12                	jb     800355 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800343:	50                   	push   %eax
  800344:	68 b0 29 80 00       	push   $0x8029b0
  800349:	6a 09                	push   $0x9
  80034b:	68 d2 29 80 00       	push   $0x8029d2
  800350:	e8 07 08 00 00       	call   800b5c <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800355:	05 00 00 01 00       	add    $0x10000,%eax
  80035a:	c1 e0 0c             	shl    $0xc,%eax
}
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    

0080035f <bc_init>:
}


void
bc_init(void)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800368:	68 70 02 80 00       	push   $0x800270
  80036d:	e8 3a 14 00 00       	call   8017ac <set_pgfault_handler>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800372:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800379:	e8 a9 ff ff ff       	call   800327 <diskaddr>
  80037e:	83 c4 0c             	add    $0xc,%esp
  800381:	68 08 01 00 00       	push   $0x108
  800386:	50                   	push   %eax
  800387:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038d:	50                   	push   %eax
  80038e:	e8 18 10 00 00       	call   8013ab <memmove>
  800393:	83 c4 10             	add    $0x10,%esp
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <skip_slash>:


// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  80039b:	80 38 2f             	cmpb   $0x2f,(%eax)
  80039e:	75 06                	jne    8003a6 <skip_slash+0xe>
		p++;
  8003a0:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8003a1:	80 38 2f             	cmpb   $0x2f,(%eax)
  8003a4:	74 fa                	je     8003a0 <skip_slash+0x8>
		p++;
	return p;
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8003ae:	a1 08 80 80 00       	mov    0x808008,%eax
  8003b3:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8003b9:	74 14                	je     8003cf <check_super+0x27>
		panic("bad file system magic number");
  8003bb:	83 ec 04             	sub    $0x4,%esp
  8003be:	68 da 29 80 00       	push   $0x8029da
  8003c3:	6a 0e                	push   $0xe
  8003c5:	68 f7 29 80 00       	push   $0x8029f7
  8003ca:	e8 8d 07 00 00       	call   800b5c <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8003cf:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8003d6:	76 14                	jbe    8003ec <check_super+0x44>
		panic("file system is too large");
  8003d8:	83 ec 04             	sub    $0x4,%esp
  8003db:	68 ff 29 80 00       	push   $0x8029ff
  8003e0:	6a 11                	push   $0x11
  8003e2:	68 f7 29 80 00       	push   $0x8029f7
  8003e7:	e8 70 07 00 00       	call   800b5c <_panic>

	cprintf("superblock is good\n");
  8003ec:	83 ec 0c             	sub    $0xc,%esp
  8003ef:	68 18 2a 80 00       	push   $0x802a18
  8003f4:	e8 3b 08 00 00       	call   800c34 <cprintf>
  8003f9:	83 c4 10             	add    $0x10,%esp
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  800404:	e8 5f fc ff ff       	call   800068 <ide_probe_disk1>
  800409:	84 c0                	test   %al,%al
  80040b:	74 0f                	je     80041c <fs_init+0x1e>
		ide_set_disk(1);
  80040d:	83 ec 0c             	sub    $0xc,%esp
  800410:	6a 01                	push   $0x1
  800412:	e8 c5 fc ff ff       	call   8000dc <ide_set_disk>
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	eb 0d                	jmp    800429 <fs_init+0x2b>
	else
		ide_set_disk(0);
  80041c:	83 ec 0c             	sub    $0xc,%esp
  80041f:	6a 00                	push   $0x0
  800421:	e8 b6 fc ff ff       	call   8000dc <ide_set_disk>
  800426:	83 c4 10             	add    $0x10,%esp

	bc_init();
  800429:	e8 31 ff ff ff       	call   80035f <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	6a 01                	push   $0x1
  800433:	e8 ef fe ff ff       	call   800327 <diskaddr>
  800438:	a3 08 80 80 00       	mov    %eax,0x808008
	check_super();
  80043d:	e8 66 ff ff ff       	call   8003a8 <check_super>
  800442:	83 c4 10             	add    $0x10,%esp
}
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <file_get_block>:
//	-E_NO_DISK if a block needed to be allocated but the disk is full.
//	-E_INVAL if filebno is out of range.
//
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	53                   	push   %ebx
  80044b:	83 ec 04             	sub    $0x4,%esp
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
{
	int r;
	uint32_t *ptr;
	char *blk;

	if (filebno < NDIRECT)
  800454:	83 fb 09             	cmp    $0x9,%ebx
  800457:	77 09                	ja     800462 <file_get_block+0x1b>
		ptr = &f->f_direct[filebno];
  800459:	8d 84 98 88 00 00 00 	lea    0x88(%eax,%ebx,4),%eax
  800460:	eb 22                	jmp    800484 <file_get_block+0x3d>
	else if (filebno < NDIRECT + NINDIRECT) {
  800462:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  800468:	77 22                	ja     80048c <file_get_block+0x45>
		if (f->f_indirect == 0) {
  80046a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  800470:	85 c0                	test   %eax,%eax
  800472:	74 1f                	je     800493 <file_get_block+0x4c>
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
  800474:	83 ec 0c             	sub    $0xc,%esp
  800477:	50                   	push   %eax
  800478:	e8 aa fe ff ff       	call   800327 <diskaddr>
  80047d:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800481:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
  800484:	8b 00                	mov    (%eax),%eax
  800486:	85 c0                	test   %eax,%eax
  800488:	74 28                	je     8004b2 <file_get_block+0x6b>
  80048a:	eb 0e                	jmp    80049a <file_get_block+0x53>
		if (f->f_indirect == 0) {
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
	} else
		return -E_INVAL;
  80048c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800491:	eb 24                	jmp    8004b7 <file_get_block+0x70>

	if (filebno < NDIRECT)
		ptr = &f->f_direct[filebno];
	else if (filebno < NDIRECT + NINDIRECT) {
		if (f->f_indirect == 0) {
			return -E_NOT_FOUND;
  800493:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800498:	eb 1d                	jmp    8004b7 <file_get_block+0x70>
	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
		return -E_NOT_FOUND;
	}
	*blk = diskaddr(*ptr);
  80049a:	83 ec 0c             	sub    $0xc,%esp
  80049d:	50                   	push   %eax
  80049e:	e8 84 fe ff ff       	call   800327 <diskaddr>
  8004a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8004a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	eb 05                	jmp    8004b7 <file_get_block+0x70>
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
		return -E_NOT_FOUND;
  8004b2:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
	}
	*blk = diskaddr(*ptr);
	return 0;
}
  8004b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	57                   	push   %edi
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  8004c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cb:	e8 c8 fe ff ff       	call   800398 <skip_slash>
  8004d0:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  8004d6:	a1 08 80 80 00       	mov    0x808008,%eax
  8004db:	83 c0 08             	add    $0x8,%eax
  8004de:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	dir = 0;
	name[0] = 0;
  8004e4:	c6 85 64 ff ff ff 00 	movb   $0x0,-0x9c(%ebp)

	if (pdir)
		*pdir = 0;
	*pf = 0;
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8004f4:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
  8004fa:	e9 2e 01 00 00       	jmp    80062d <file_open+0x171>
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8004ff:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
			path++;
  800505:	46                   	inc    %esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800506:	8a 06                	mov    (%esi),%al
  800508:	3c 2f                	cmp    $0x2f,%al
  80050a:	74 04                	je     800510 <file_open+0x54>
  80050c:	84 c0                	test   %al,%al
  80050e:	75 f5                	jne    800505 <file_open+0x49>
			path++;
		if (path - p >= MAXNAMELEN)
  800510:	89 f3                	mov    %esi,%ebx
  800512:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  800518:	83 fb 7f             	cmp    $0x7f,%ebx
  80051b:	0f 8f 39 01 00 00    	jg     80065a <file_open+0x19e>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800521:	83 ec 04             	sub    $0x4,%esp
  800524:	53                   	push   %ebx
  800525:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  80052b:	57                   	push   %edi
  80052c:	e8 7a 0e 00 00       	call   8013ab <memmove>
		name[path - p] = '\0';
  800531:	c6 84 1d 64 ff ff ff 	movb   $0x0,-0x9c(%ebp,%ebx,1)
  800538:	00 
		path = skip_slash(path);
  800539:	89 f0                	mov    %esi,%eax
  80053b:	e8 58 fe ff ff       	call   800398 <skip_slash>
  800540:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	8b 95 48 ff ff ff    	mov    -0xb8(%ebp),%edx
  80054f:	83 ba 84 00 00 00 01 	cmpl   $0x1,0x84(%edx)
  800556:	0f 85 05 01 00 00    	jne    800661 <file_open+0x1a5>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  80055c:	8b 82 80 00 00 00    	mov    0x80(%edx),%eax
  800562:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800567:	74 16                	je     80057f <file_open+0xc3>
  800569:	68 2c 2a 80 00       	push   $0x802a2c
  80056e:	68 fd 28 80 00       	push   $0x8028fd
  800573:	6a 78                	push   $0x78
  800575:	68 f7 29 80 00       	push   $0x8029f7
  80057a:	e8 dd 05 00 00       	call   800b5c <_panic>
	nblock = dir->f_size / BLKSIZE;
  80057f:	89 c2                	mov    %eax,%edx
  800581:	85 c0                	test   %eax,%eax
  800583:	79 06                	jns    80058b <file_open+0xcf>
  800585:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80058b:	89 d0                	mov    %edx,%eax
  80058d:	c1 f8 0c             	sar    $0xc,%eax
  800590:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800596:	85 c0                	test   %eax,%eax
  800598:	74 72                	je     80060c <file_open+0x150>
  80059a:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  8005a1:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005aa:	50                   	push   %eax
  8005ab:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  8005b1:	ff b5 48 ff ff ff    	pushl  -0xb8(%ebp)
  8005b7:	e8 8b fe ff ff       	call   800447 <file_get_block>
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	78 44                	js     800607 <file_open+0x14b>
  8005c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx


// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
  8005c6:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
  8005cc:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	57                   	push   %edi
  8005d6:	53                   	push   %ebx
  8005d7:	e8 c7 0c 00 00       	call   8012a3 <strcmp>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	74 44                	je     800627 <file_open+0x16b>
  8005e3:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8005e9:	3b 9d 54 ff ff ff    	cmp    -0xac(%ebp),%ebx
  8005ef:	75 e1                	jne    8005d2 <file_open+0x116>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8005f1:	ff 85 50 ff ff ff    	incl   -0xb0(%ebp)
  8005f7:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8005fd:	39 85 44 ff ff ff    	cmp    %eax,-0xbc(%ebp)
  800603:	77 9f                	ja     8005a4 <file_open+0xe8>
  800605:	eb 05                	jmp    80060c <file_open+0x150>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800607:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80060a:	75 61                	jne    80066d <file_open+0x1b1>
  80060c:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800612:	80 3a 00             	cmpb   $0x0,(%edx)
  800615:	75 51                	jne    800668 <file_open+0x1ac>
				if (pdir)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
  800617:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800620:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800625:	eb 46                	jmp    80066d <file_open+0x1b1>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800627:	89 9d 48 ff ff ff    	mov    %ebx,-0xb8(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  80062d:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800633:	8a 02                	mov    (%edx),%al
  800635:	84 c0                	test   %al,%al
  800637:	74 0f                	je     800648 <file_open+0x18c>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800639:	3c 2f                	cmp    $0x2f,%al
  80063b:	0f 85 be fe ff ff    	jne    8004ff <file_open+0x43>
  800641:	89 d6                	mov    %edx,%esi
  800643:	e9 c8 fe ff ff       	jmp    800510 <file_open+0x54>
		}
	}

	if (pdir)
		*pdir = dir;
	*pf = f;
  800648:	8b 95 48 ff ff ff    	mov    -0xb8(%ebp),%edx
  80064e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800651:	89 10                	mov    %edx,(%eax)
	return 0;
  800653:	b8 00 00 00 00       	mov    $0x0,%eax
  800658:	eb 13                	jmp    80066d <file_open+0x1b1>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  80065a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80065f:	eb 0c                	jmp    80066d <file_open+0x1b1>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800661:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800666:	eb 05                	jmp    80066d <file_open+0x1b1>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800668:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
	return walk_path(path, 0, pf, 0);
}
  80066d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	c9                   	leave  
  800674:	c3                   	ret    

00800675 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	57                   	push   %edi
  800679:	56                   	push   %esi
  80067a:	53                   	push   %ebx
  80067b:	83 ec 2c             	sub    $0x2c,%esp
  80067e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800681:	8b 55 10             	mov    0x10(%ebp),%edx
  800684:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800687:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068a:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800690:	39 d8                	cmp    %ebx,%eax
  800692:	0f 8e 8e 00 00 00    	jle    800726 <file_read+0xb1>
		return 0;

	count = MIN(count, f->f_size - offset);
  800698:	29 d8                	sub    %ebx,%eax
  80069a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80069d:	39 d0                	cmp    %edx,%eax
  80069f:	76 03                	jbe    8006a4 <file_read+0x2f>
  8006a1:	89 55 cc             	mov    %edx,-0x34(%ebp)

	for (pos = offset; pos < offset + count; ) {
  8006a4:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006aa:	01 d8                	add    %ebx,%eax
  8006ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006af:	39 c3                	cmp    %eax,%ebx
  8006b1:	73 6e                	jae    800721 <file_read+0xac>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8006b3:	83 ec 04             	sub    $0x4,%esp
  8006b6:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8006b9:	51                   	push   %ecx
  8006ba:	89 d8                	mov    %ebx,%eax
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	79 06                	jns    8006c6 <file_read+0x51>
  8006c0:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8006c6:	c1 f8 0c             	sar    $0xc,%eax
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 08             	pushl  0x8(%ebp)
  8006cd:	e8 75 fd ff ff       	call   800447 <file_get_block>
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	78 52                	js     80072b <file_read+0xb6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8006d9:	89 d8                	mov    %ebx,%eax
  8006db:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  8006e0:	79 07                	jns    8006e9 <file_read+0x74>
  8006e2:	48                   	dec    %eax
  8006e3:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  8006e8:	40                   	inc    %eax
  8006e9:	89 c2                	mov    %eax,%edx
  8006eb:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8006f0:	29 c1                	sub    %eax,%ecx
  8006f2:	89 c8                	mov    %ecx,%eax
  8006f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006f7:	2b 4d d0             	sub    -0x30(%ebp),%ecx
  8006fa:	89 c6                	mov    %eax,%esi
  8006fc:	39 c8                	cmp    %ecx,%eax
  8006fe:	76 02                	jbe    800702 <file_read+0x8d>
  800700:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800702:	83 ec 04             	sub    $0x4,%esp
  800705:	56                   	push   %esi
  800706:	03 55 e4             	add    -0x1c(%ebp),%edx
  800709:	52                   	push   %edx
  80070a:	57                   	push   %edi
  80070b:	e8 9b 0c 00 00       	call   8013ab <memmove>
		pos += bn;
  800710:	01 f3                	add    %esi,%ebx
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800712:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  80071b:	73 04                	jae    800721 <file_read+0xac>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  80071d:	01 f7                	add    %esi,%edi
  80071f:	eb 92                	jmp    8006b3 <file_read+0x3e>
	}

	return count;
  800721:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800724:	eb 05                	jmp    80072b <file_read+0xb6>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  80072b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072e:	5b                   	pop    %ebx
  80072f:	5e                   	pop    %esi
  800730:	5f                   	pop    %edi
  800731:	c9                   	leave  
  800732:	c3                   	ret    
	...

00800734 <serve_flush>:


// Our read-only file system do nothing for flush
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800741:	ba 20 30 80 00       	mov    $0x803020,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  800746:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800750:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800752:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800755:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80075b:	40                   	inc    %eax
  80075c:	83 c2 10             	add    $0x10,%edx
  80075f:	3d 00 04 00 00       	cmp    $0x400,%eax
  800764:	75 ea                	jne    800750 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	57                   	push   %edi
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	83 ec 0c             	sub    $0xc,%esp
  800771:	8b 7d 08             	mov    0x8(%ebp),%edi
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800774:	bb 2c 30 80 00       	mov    $0x80302c,%ebx
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800779:	be 00 00 00 00       	mov    $0x0,%esi
		switch (pageref(opentab[i].o_fd)) {
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	ff 33                	pushl  (%ebx)
  800783:	e8 90 19 00 00       	call   802118 <pageref>
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 07                	je     800796 <openfile_alloc+0x2e>
  80078f:	83 f8 01             	cmp    $0x1,%eax
  800792:	75 53                	jne    8007e7 <openfile_alloc+0x7f>
  800794:	eb 1e                	jmp    8007b4 <openfile_alloc+0x4c>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800796:	83 ec 04             	sub    $0x4,%esp
  800799:	6a 07                	push   $0x7
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	c1 e0 04             	shl    $0x4,%eax
  8007a0:	ff b0 2c 30 80 00    	pushl  0x80302c(%eax)
  8007a6:	6a 00                	push   $0x0
  8007a8:	e8 bf 0e 00 00       	call   80166c <sys_page_alloc>
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	78 44                	js     8007f8 <openfile_alloc+0x90>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8007b4:	c1 e6 04             	shl    $0x4,%esi
  8007b7:	8d 86 20 30 80 00    	lea    0x803020(%esi),%eax
  8007bd:	81 86 20 30 80 00 00 	addl   $0x400,0x803020(%esi)
  8007c4:	04 00 00 
			*o = &opentab[i];
  8007c7:	89 07                	mov    %eax,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8007c9:	83 ec 04             	sub    $0x4,%esp
  8007cc:	68 00 10 00 00       	push   $0x1000
  8007d1:	6a 00                	push   $0x0
  8007d3:	ff b6 2c 30 80 00    	pushl  0x80302c(%esi)
  8007d9:	e8 83 0b 00 00       	call   801361 <memset>
			return (*o)->o_fileid;
  8007de:	8b 07                	mov    (%edi),%eax
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	eb 11                	jmp    8007f8 <openfile_alloc+0x90>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8007e7:	46                   	inc    %esi
  8007e8:	83 c3 10             	add    $0x10,%ebx
  8007eb:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  8007f1:	75 8b                	jne    80077e <openfile_alloc+0x16>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8007f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  800810:	83 ec 0c             	sub    $0xc,%esp
  800813:	89 d8                	mov    %ebx,%eax
  800815:	c1 e0 04             	shl    $0x4,%eax
  800818:	ff b0 2c 30 80 00    	pushl  0x80302c(%eax)
  80081e:	e8 f5 18 00 00       	call   802118 <pageref>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	83 f8 01             	cmp    $0x1,%eax
  800829:	74 21                	je     80084c <openfile_lookup+0x4c>
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	c1 e0 04             	shl    $0x4,%eax
  800830:	39 b0 20 30 80 00    	cmp    %esi,0x803020(%eax)
  800836:	75 1b                	jne    800853 <openfile_lookup+0x53>
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800838:	89 c3                	mov    %eax,%ebx
  80083a:	81 c3 20 30 80 00    	add    $0x803020,%ebx
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	89 18                	mov    %ebx,(%eax)
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
	*po = o;
	return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	eb 0c                	jmp    800858 <openfile_lookup+0x58>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80084c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800851:	eb 05                	jmp    800858 <openfile_lookup+0x58>
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800858:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	83 ec 18             	sub    $0x18,%esp
  800866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086c:	50                   	push   %eax
  80086d:	ff 33                	pushl  (%ebx)
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 89 ff ff ff       	call   800800 <openfile_lookup>
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	85 c0                	test   %eax,%eax
  80087c:	78 3f                	js     8008bd <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800884:	ff 70 04             	pushl  0x4(%eax)
  800887:	53                   	push   %ebx
  800888:	e8 5d 09 00 00       	call   8011ea <strcpy>
	ret->ret_size = o->o_file->f_size;
  80088d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800890:	8b 50 04             	mov    0x4(%eax),%edx
  800893:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800899:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80089f:	8b 40 04             	mov    0x4(%eax),%eax
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8008ac:	0f 94 c0             	sete   %al
  8008af:	0f b6 c0             	movzbl %al,%eax
  8008b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	83 ec 18             	sub    $0x18,%esp
  8008c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// so filling in ret will overwrite req.
	//
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8008cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008cf:	50                   	push   %eax
  8008d0:	ff 33                	pushl  (%ebx)
  8008d2:	ff 75 08             	pushl  0x8(%ebp)
  8008d5:	e8 26 ff ff ff       	call   800800 <openfile_lookup>
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 32                	js     800913 <serve_read+0x51>
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
  8008e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e4:	8b 42 0c             	mov    0xc(%edx),%eax
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
  8008e7:	ff 70 04             	pushl  0x4(%eax)
			   MIN(req->req_n, sizeof ret->ret_buf),
  8008ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8008ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8008f2:	76 05                	jbe    8008f9 <serve_read+0x37>
  8008f4:	b8 00 10 00 00       	mov    $0x1000,%eax
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
  8008f9:	50                   	push   %eax
  8008fa:	53                   	push   %ebx
  8008fb:	ff 72 04             	pushl  0x4(%edx)
  8008fe:	e8 72 fd ff ff       	call   800675 <file_read>
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	85 c0                	test   %eax,%eax
  800908:	78 09                	js     800913 <serve_read+0x51>
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
		return r;

	o->o_fd->fd_offset += r;
  80090a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80090d:	8b 52 0c             	mov    0xc(%edx),%edx
  800910:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  800913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	81 ec 18 04 00 00    	sub    $0x418,%esp
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800925:	68 00 04 00 00       	push   $0x400
  80092a:	53                   	push   %ebx
  80092b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800931:	50                   	push   %eax
  800932:	e8 74 0a 00 00       	call   8013ab <memmove>
	path[MAXPATHLEN-1] = 0;
  800937:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80093b:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800941:	89 04 24             	mov    %eax,(%esp)
  800944:	e8 1f fe ff ff       	call   800768 <openfile_alloc>
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	85 c0                	test   %eax,%eax
  80094e:	0f 88 83 00 00 00    	js     8009d7 <serve_open+0xbf>
			cprintf("openfile_alloc failed: %e", r);
		return r;
	}
	fileid = r;

	if (req->req_omode != 0) {
  800954:	83 bb 00 04 00 00 00 	cmpl   $0x0,0x400(%ebx)
  80095b:	75 75                	jne    8009d2 <serve_open+0xba>
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
	}

	if ((r = file_open(path, &f)) < 0) {
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800966:	50                   	push   %eax
  800967:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80096d:	50                   	push   %eax
  80096e:	e8 49 fb ff ff       	call   8004bc <file_open>
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	85 c0                	test   %eax,%eax
  800978:	78 5d                	js     8009d7 <serve_open+0xbf>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80097a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800980:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800986:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800989:	8b 50 0c             	mov    0xc(%eax),%edx
  80098c:	8b 08                	mov    (%eax),%ecx
  80098e:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800991:	8b 50 0c             	mov    0xc(%eax),%edx
  800994:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  80099a:	83 e1 03             	and    $0x3,%ecx
  80099d:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8009a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a3:	8b 15 44 70 80 00    	mov    0x807044,%edx
  8009a9:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8009ab:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8009b1:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8009b7:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8009ba:	8b 50 0c             	mov    0xc(%eax),%edx
  8009bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c0:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	eb 05                	jmp    8009d7 <serve_open+0xbf>
	fileid = r;

	if (req->req_omode != 0) {
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
  8009d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	// store its permission in *perm_store
	*pg_store = o->o_fd;
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;

	return 0;
}
  8009d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	83 ec 1c             	sub    $0x1c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8009e5:	8d 5d e0             	lea    -0x20(%ebp),%ebx
  8009e8:	8d 75 e4             	lea    -0x1c(%ebp),%esi
			continue; // just leave it hanging...
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8009eb:	8d 7d dc             	lea    -0x24(%ebp),%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8009ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8009f5:	83 ec 04             	sub    $0x4,%esp
  8009f8:	53                   	push   %ebx
  8009f9:	ff 35 20 70 80 00    	pushl  0x807020
  8009ff:	56                   	push   %esi
  800a00:	e8 3b 0e 00 00       	call   801840 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  800a0c:	75 15                	jne    800a23 <serve+0x47>
			cprintf("Invalid request from %08x: no argument page\n",
  800a0e:	83 ec 08             	sub    $0x8,%esp
  800a11:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a14:	68 4c 2a 80 00       	push   $0x802a4c
  800a19:	e8 16 02 00 00       	call   800c34 <cprintf>
				whom);
			continue; // just leave it hanging...
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	eb cb                	jmp    8009ee <serve+0x12>
		}

		pg = NULL;
  800a23:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  800a2a:	83 f8 01             	cmp    $0x1,%eax
  800a2d:	75 15                	jne    800a44 <serve+0x68>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800a2f:	53                   	push   %ebx
  800a30:	57                   	push   %edi
  800a31:	ff 35 20 70 80 00    	pushl  0x807020
  800a37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a3a:	e8 d9 fe ff ff       	call   800918 <serve_open>
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	eb 3c                	jmp    800a80 <serve+0xa4>
		} else if (req < NHANDLERS && handlers[req]) {
  800a44:	83 f8 06             	cmp    $0x6,%eax
  800a47:	77 1e                	ja     800a67 <serve+0x8b>
  800a49:	8b 14 85 24 70 80 00 	mov    0x807024(,%eax,4),%edx
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 13                	je     800a67 <serve+0x8b>
			r = handlers[req](whom, fsreq);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	ff 35 20 70 80 00    	pushl  0x807020
  800a5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a60:	ff d2                	call   *%edx
  800a62:	83 c4 10             	add    $0x10,%esp
  800a65:	eb 19                	jmp    800a80 <serve+0xa4>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800a67:	83 ec 04             	sub    $0x4,%esp
  800a6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a6d:	50                   	push   %eax
  800a6e:	68 7c 2a 80 00       	push   $0x802a7c
  800a73:	e8 bc 01 00 00       	call   800c34 <cprintf>
  800a78:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800a7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800a80:	ff 75 e0             	pushl  -0x20(%ebp)
  800a83:	ff 75 dc             	pushl  -0x24(%ebp)
  800a86:	50                   	push   %eax
  800a87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a8a:	e8 26 0e 00 00       	call   8018b5 <ipc_send>
		sys_page_unmap(0, fsreq);
  800a8f:	83 c4 08             	add    $0x8,%esp
  800a92:	ff 35 20 70 80 00    	pushl  0x807020
  800a98:	6a 00                	push   $0x0
  800a9a:	e8 17 0c 00 00       	call   8016b6 <sys_page_unmap>
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	e9 47 ff ff ff       	jmp    8009ee <serve+0x12>

00800aa7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800aad:	c7 05 40 70 80 00 9f 	movl   $0x802a9f,0x807040
  800ab4:	2a 80 00 
	cprintf("FS is running\n");
  800ab7:	68 a2 2a 80 00       	push   $0x802aa2
  800abc:	e8 73 01 00 00       	call   800c34 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ac1:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800ac6:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800acb:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800acd:	c7 04 24 b1 2a 80 00 	movl   $0x802ab1,(%esp)
  800ad4:	e8 5b 01 00 00       	call   800c34 <cprintf>

	serve_init();
  800ad9:	e8 60 fc ff ff       	call   80073e <serve_init>
	fs_init();
  800ade:	e8 1b f9 ff ff       	call   8003fe <fs_init>
	serve();
  800ae3:	e8 f4 fe ff ff       	call   8009dc <serve>
  800ae8:	83 c4 10             	add    $0x10,%esp
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    
  800aed:	00 00                	add    %al,(%eax)
	...

00800af0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 08             	mov    0x8(%ebp),%esi
  800af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800afb:	e8 21 0b 00 00       	call   801621 <sys_getenvid>
  800b00:	25 ff 03 00 00       	and    $0x3ff,%eax
  800b05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800b0c:	c1 e0 07             	shl    $0x7,%eax
  800b0f:	29 d0                	sub    %edx,%eax
  800b11:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800b16:	a3 0c 80 80 00       	mov    %eax,0x80800c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800b1b:	85 f6                	test   %esi,%esi
  800b1d:	7e 07                	jle    800b26 <libmain+0x36>
		binaryname = argv[0];
  800b1f:	8b 03                	mov    (%ebx),%eax
  800b21:	a3 40 70 80 00       	mov    %eax,0x807040
	// call user main routine
	umain(argc, argv);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	53                   	push   %ebx
  800b2a:	56                   	push   %esi
  800b2b:	e8 77 ff ff ff       	call   800aa7 <umain>

	// exit gracefully
	exit();
  800b30:	e8 0b 00 00 00       	call   800b40 <exit>
  800b35:	83 c4 10             	add    $0x10,%esp
}
  800b38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    
	...

00800b40 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800b46:	e8 27 10 00 00       	call   801b72 <close_all>
	sys_env_destroy(0);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	6a 00                	push   $0x0
  800b50:	e8 aa 0a 00 00       	call   8015ff <sys_env_destroy>
  800b55:	83 c4 10             	add    $0x10,%esp
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    
	...

00800b5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b61:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b64:	8b 1d 40 70 80 00    	mov    0x807040,%ebx
  800b6a:	e8 b2 0a 00 00       	call   801621 <sys_getenvid>
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	ff 75 08             	pushl  0x8(%ebp)
  800b78:	53                   	push   %ebx
  800b79:	50                   	push   %eax
  800b7a:	68 cc 2a 80 00       	push   $0x802acc
  800b7f:	e8 b0 00 00 00       	call   800c34 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b84:	83 c4 18             	add    $0x18,%esp
  800b87:	56                   	push   %esi
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	e8 53 00 00 00       	call   800be3 <vcprintf>
	cprintf("\n");
  800b90:	c7 04 24 be 2a 80 00 	movl   $0x802abe,(%esp)
  800b97:	e8 98 00 00 00       	call   800c34 <cprintf>
  800b9c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b9f:	cc                   	int3   
  800ba0:	eb fd                	jmp    800b9f <_panic+0x43>
	...

00800ba4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 04             	sub    $0x4,%esp
  800bab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800bae:	8b 03                	mov    (%ebx),%eax
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800bb7:	40                   	inc    %eax
  800bb8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800bba:	3d ff 00 00 00       	cmp    $0xff,%eax
  800bbf:	75 1a                	jne    800bdb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	68 ff 00 00 00       	push   $0xff
  800bc9:	8d 43 08             	lea    0x8(%ebx),%eax
  800bcc:	50                   	push   %eax
  800bcd:	e8 e3 09 00 00       	call   8015b5 <sys_cputs>
		b->idx = 0;
  800bd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800bd8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800bdb:	ff 43 04             	incl   0x4(%ebx)
}
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800bec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800bf3:	00 00 00 
	b.cnt = 0;
  800bf6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800bfd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800c00:	ff 75 0c             	pushl  0xc(%ebp)
  800c03:	ff 75 08             	pushl  0x8(%ebp)
  800c06:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800c0c:	50                   	push   %eax
  800c0d:	68 a4 0b 80 00       	push   $0x800ba4
  800c12:	e8 82 01 00 00       	call   800d99 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800c17:	83 c4 08             	add    $0x8,%esp
  800c1a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800c20:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800c26:	50                   	push   %eax
  800c27:	e8 89 09 00 00       	call   8015b5 <sys_cputs>

	return b.cnt;
}
  800c2c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800c3a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800c3d:	50                   	push   %eax
  800c3e:	ff 75 08             	pushl  0x8(%ebp)
  800c41:	e8 9d ff ff ff       	call   800be3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
  800c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	8b 45 08             	mov    0x8(%ebp),%eax
  800c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c62:	8b 45 10             	mov    0x10(%ebp),%eax
  800c65:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800c68:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c6e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800c75:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800c78:	72 0c                	jb     800c86 <printnum+0x3e>
  800c7a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800c7d:	76 07                	jbe    800c86 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c7f:	4b                   	dec    %ebx
  800c80:	85 db                	test   %ebx,%ebx
  800c82:	7f 31                	jg     800cb5 <printnum+0x6d>
  800c84:	eb 3f                	jmp    800cc5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	57                   	push   %edi
  800c8a:	4b                   	dec    %ebx
  800c8b:	53                   	push   %ebx
  800c8c:	50                   	push   %eax
  800c8d:	83 ec 08             	sub    $0x8,%esp
  800c90:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c93:	ff 75 d0             	pushl  -0x30(%ebp)
  800c96:	ff 75 dc             	pushl  -0x24(%ebp)
  800c99:	ff 75 d8             	pushl  -0x28(%ebp)
  800c9c:	e8 bf 19 00 00       	call   802660 <__udivdi3>
  800ca1:	83 c4 18             	add    $0x18,%esp
  800ca4:	52                   	push   %edx
  800ca5:	50                   	push   %eax
  800ca6:	89 f2                	mov    %esi,%edx
  800ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cab:	e8 98 ff ff ff       	call   800c48 <printnum>
  800cb0:	83 c4 20             	add    $0x20,%esp
  800cb3:	eb 10                	jmp    800cc5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800cb5:	83 ec 08             	sub    $0x8,%esp
  800cb8:	56                   	push   %esi
  800cb9:	57                   	push   %edi
  800cba:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800cbd:	4b                   	dec    %ebx
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	85 db                	test   %ebx,%ebx
  800cc3:	7f f0                	jg     800cb5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cc5:	83 ec 08             	sub    $0x8,%esp
  800cc8:	56                   	push   %esi
  800cc9:	83 ec 04             	sub    $0x4,%esp
  800ccc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ccf:	ff 75 d0             	pushl  -0x30(%ebp)
  800cd2:	ff 75 dc             	pushl  -0x24(%ebp)
  800cd5:	ff 75 d8             	pushl  -0x28(%ebp)
  800cd8:	e8 9f 1a 00 00       	call   80277c <__umoddi3>
  800cdd:	83 c4 14             	add    $0x14,%esp
  800ce0:	0f be 80 ef 2a 80 00 	movsbl 0x802aef(%eax),%eax
  800ce7:	50                   	push   %eax
  800ce8:	ff 55 e4             	call   *-0x1c(%ebp)
  800ceb:	83 c4 10             	add    $0x10,%esp
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800cf9:	83 fa 01             	cmp    $0x1,%edx
  800cfc:	7e 0e                	jle    800d0c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800cfe:	8b 10                	mov    (%eax),%edx
  800d00:	8d 4a 08             	lea    0x8(%edx),%ecx
  800d03:	89 08                	mov    %ecx,(%eax)
  800d05:	8b 02                	mov    (%edx),%eax
  800d07:	8b 52 04             	mov    0x4(%edx),%edx
  800d0a:	eb 22                	jmp    800d2e <getuint+0x38>
	else if (lflag)
  800d0c:	85 d2                	test   %edx,%edx
  800d0e:	74 10                	je     800d20 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800d10:	8b 10                	mov    (%eax),%edx
  800d12:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d15:	89 08                	mov    %ecx,(%eax)
  800d17:	8b 02                	mov    (%edx),%eax
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	eb 0e                	jmp    800d2e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800d20:	8b 10                	mov    (%eax),%edx
  800d22:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d25:	89 08                	mov    %ecx,(%eax)
  800d27:	8b 02                	mov    (%edx),%eax
  800d29:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800d33:	83 fa 01             	cmp    $0x1,%edx
  800d36:	7e 0e                	jle    800d46 <getint+0x16>
		return va_arg(*ap, long long);
  800d38:	8b 10                	mov    (%eax),%edx
  800d3a:	8d 4a 08             	lea    0x8(%edx),%ecx
  800d3d:	89 08                	mov    %ecx,(%eax)
  800d3f:	8b 02                	mov    (%edx),%eax
  800d41:	8b 52 04             	mov    0x4(%edx),%edx
  800d44:	eb 1a                	jmp    800d60 <getint+0x30>
	else if (lflag)
  800d46:	85 d2                	test   %edx,%edx
  800d48:	74 0c                	je     800d56 <getint+0x26>
		return va_arg(*ap, long);
  800d4a:	8b 10                	mov    (%eax),%edx
  800d4c:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d4f:	89 08                	mov    %ecx,(%eax)
  800d51:	8b 02                	mov    (%edx),%eax
  800d53:	99                   	cltd   
  800d54:	eb 0a                	jmp    800d60 <getint+0x30>
	else
		return va_arg(*ap, int);
  800d56:	8b 10                	mov    (%eax),%edx
  800d58:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d5b:	89 08                	mov    %ecx,(%eax)
  800d5d:	8b 02                	mov    (%edx),%eax
  800d5f:	99                   	cltd   
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800d68:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800d6b:	8b 10                	mov    (%eax),%edx
  800d6d:	3b 50 04             	cmp    0x4(%eax),%edx
  800d70:	73 08                	jae    800d7a <sprintputch+0x18>
		*b->buf++ = ch;
  800d72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d75:	88 0a                	mov    %cl,(%edx)
  800d77:	42                   	inc    %edx
  800d78:	89 10                	mov    %edx,(%eax)
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800d82:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800d85:	50                   	push   %eax
  800d86:	ff 75 10             	pushl  0x10(%ebp)
  800d89:	ff 75 0c             	pushl  0xc(%ebp)
  800d8c:	ff 75 08             	pushl  0x8(%ebp)
  800d8f:	e8 05 00 00 00       	call   800d99 <vprintfmt>
	va_end(ap);
  800d94:	83 c4 10             	add    $0x10,%esp
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 2c             	sub    $0x2c,%esp
  800da2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da5:	8b 75 10             	mov    0x10(%ebp),%esi
  800da8:	eb 13                	jmp    800dbd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800daa:	85 c0                	test   %eax,%eax
  800dac:	0f 84 6d 03 00 00    	je     80111f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800db2:	83 ec 08             	sub    $0x8,%esp
  800db5:	57                   	push   %edi
  800db6:	50                   	push   %eax
  800db7:	ff 55 08             	call   *0x8(%ebp)
  800dba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800dbd:	0f b6 06             	movzbl (%esi),%eax
  800dc0:	46                   	inc    %esi
  800dc1:	83 f8 25             	cmp    $0x25,%eax
  800dc4:	75 e4                	jne    800daa <vprintfmt+0x11>
  800dc6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800dca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800dd1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800dd8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ddf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de4:	eb 28                	jmp    800e0e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800de8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800dec:	eb 20                	jmp    800e0e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dee:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800df0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800df4:	eb 18                	jmp    800e0e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800df8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800dff:	eb 0d                	jmp    800e0e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800e01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800e04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e07:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e0e:	8a 06                	mov    (%esi),%al
  800e10:	0f b6 d0             	movzbl %al,%edx
  800e13:	8d 5e 01             	lea    0x1(%esi),%ebx
  800e16:	83 e8 23             	sub    $0x23,%eax
  800e19:	3c 55                	cmp    $0x55,%al
  800e1b:	0f 87 e0 02 00 00    	ja     801101 <vprintfmt+0x368>
  800e21:	0f b6 c0             	movzbl %al,%eax
  800e24:	ff 24 85 40 2c 80 00 	jmp    *0x802c40(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800e2b:	83 ea 30             	sub    $0x30,%edx
  800e2e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800e31:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800e34:	8d 50 d0             	lea    -0x30(%eax),%edx
  800e37:	83 fa 09             	cmp    $0x9,%edx
  800e3a:	77 44                	ja     800e80 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e3c:	89 de                	mov    %ebx,%esi
  800e3e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800e41:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800e42:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800e45:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800e49:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800e4c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800e4f:	83 fb 09             	cmp    $0x9,%ebx
  800e52:	76 ed                	jbe    800e41 <vprintfmt+0xa8>
  800e54:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800e57:	eb 29                	jmp    800e82 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800e59:	8b 45 14             	mov    0x14(%ebp),%eax
  800e5c:	8d 50 04             	lea    0x4(%eax),%edx
  800e5f:	89 55 14             	mov    %edx,0x14(%ebp)
  800e62:	8b 00                	mov    (%eax),%eax
  800e64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e67:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800e69:	eb 17                	jmp    800e82 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800e6b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e6f:	78 85                	js     800df6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	eb 99                	jmp    800e0e <vprintfmt+0x75>
  800e75:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800e77:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800e7e:	eb 8e                	jmp    800e0e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e80:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800e82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e86:	79 86                	jns    800e0e <vprintfmt+0x75>
  800e88:	e9 74 ff ff ff       	jmp    800e01 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800e8d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e8e:	89 de                	mov    %ebx,%esi
  800e90:	e9 79 ff ff ff       	jmp    800e0e <vprintfmt+0x75>
  800e95:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800e98:	8b 45 14             	mov    0x14(%ebp),%eax
  800e9b:	8d 50 04             	lea    0x4(%eax),%edx
  800e9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	57                   	push   %edi
  800ea5:	ff 30                	pushl  (%eax)
  800ea7:	ff 55 08             	call   *0x8(%ebp)
			break;
  800eaa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ead:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800eb0:	e9 08 ff ff ff       	jmp    800dbd <vprintfmt+0x24>
  800eb5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8d 50 04             	lea    0x4(%eax),%edx
  800ebe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec1:	8b 00                	mov    (%eax),%eax
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	79 02                	jns    800ec9 <vprintfmt+0x130>
  800ec7:	f7 d8                	neg    %eax
  800ec9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ecb:	83 f8 0f             	cmp    $0xf,%eax
  800ece:	7f 0b                	jg     800edb <vprintfmt+0x142>
  800ed0:	8b 04 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%eax
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	75 1a                	jne    800ef5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800edb:	52                   	push   %edx
  800edc:	68 07 2b 80 00       	push   $0x802b07
  800ee1:	57                   	push   %edi
  800ee2:	ff 75 08             	pushl  0x8(%ebp)
  800ee5:	e8 92 fe ff ff       	call   800d7c <printfmt>
  800eea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eed:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ef0:	e9 c8 fe ff ff       	jmp    800dbd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800ef5:	50                   	push   %eax
  800ef6:	68 0f 29 80 00       	push   $0x80290f
  800efb:	57                   	push   %edi
  800efc:	ff 75 08             	pushl  0x8(%ebp)
  800eff:	e8 78 fe ff ff       	call   800d7c <printfmt>
  800f04:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f07:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800f0a:	e9 ae fe ff ff       	jmp    800dbd <vprintfmt+0x24>
  800f0f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800f12:	89 de                	mov    %ebx,%esi
  800f14:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f17:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1d:	8d 50 04             	lea    0x4(%eax),%edx
  800f20:	89 55 14             	mov    %edx,0x14(%ebp)
  800f23:	8b 00                	mov    (%eax),%eax
  800f25:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	75 07                	jne    800f33 <vprintfmt+0x19a>
				p = "(null)";
  800f2c:	c7 45 d0 00 2b 80 00 	movl   $0x802b00,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800f33:	85 db                	test   %ebx,%ebx
  800f35:	7e 42                	jle    800f79 <vprintfmt+0x1e0>
  800f37:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800f3b:	74 3c                	je     800f79 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	51                   	push   %ecx
  800f41:	ff 75 d0             	pushl  -0x30(%ebp)
  800f44:	e8 6f 02 00 00       	call   8011b8 <strnlen>
  800f49:	29 c3                	sub    %eax,%ebx
  800f4b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	85 db                	test   %ebx,%ebx
  800f53:	7e 24                	jle    800f79 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800f55:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800f59:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800f5c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	57                   	push   %edi
  800f63:	53                   	push   %ebx
  800f64:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800f67:	4e                   	dec    %esi
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 f6                	test   %esi,%esi
  800f6d:	7f f0                	jg     800f5f <vprintfmt+0x1c6>
  800f6f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800f72:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f79:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f7c:	0f be 02             	movsbl (%edx),%eax
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	75 47                	jne    800fca <vprintfmt+0x231>
  800f83:	eb 37                	jmp    800fbc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800f85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f89:	74 16                	je     800fa1 <vprintfmt+0x208>
  800f8b:	8d 50 e0             	lea    -0x20(%eax),%edx
  800f8e:	83 fa 5e             	cmp    $0x5e,%edx
  800f91:	76 0e                	jbe    800fa1 <vprintfmt+0x208>
					putch('?', putdat);
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	57                   	push   %edi
  800f97:	6a 3f                	push   $0x3f
  800f99:	ff 55 08             	call   *0x8(%ebp)
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	eb 0b                	jmp    800fac <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	57                   	push   %edi
  800fa5:	50                   	push   %eax
  800fa6:	ff 55 08             	call   *0x8(%ebp)
  800fa9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fac:	ff 4d e4             	decl   -0x1c(%ebp)
  800faf:	0f be 03             	movsbl (%ebx),%eax
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	74 03                	je     800fb9 <vprintfmt+0x220>
  800fb6:	43                   	inc    %ebx
  800fb7:	eb 1b                	jmp    800fd4 <vprintfmt+0x23b>
  800fb9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800fbc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc0:	7f 1e                	jg     800fe0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fc5:	e9 f3 fd ff ff       	jmp    800dbd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fca:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800fcd:	43                   	inc    %ebx
  800fce:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800fd1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800fd4:	85 f6                	test   %esi,%esi
  800fd6:	78 ad                	js     800f85 <vprintfmt+0x1ec>
  800fd8:	4e                   	dec    %esi
  800fd9:	79 aa                	jns    800f85 <vprintfmt+0x1ec>
  800fdb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800fde:	eb dc                	jmp    800fbc <vprintfmt+0x223>
  800fe0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800fe3:	83 ec 08             	sub    $0x8,%esp
  800fe6:	57                   	push   %edi
  800fe7:	6a 20                	push   $0x20
  800fe9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800fec:	4b                   	dec    %ebx
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 db                	test   %ebx,%ebx
  800ff2:	7f ef                	jg     800fe3 <vprintfmt+0x24a>
  800ff4:	e9 c4 fd ff ff       	jmp    800dbd <vprintfmt+0x24>
  800ff9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ffc:	89 ca                	mov    %ecx,%edx
  800ffe:	8d 45 14             	lea    0x14(%ebp),%eax
  801001:	e8 2a fd ff ff       	call   800d30 <getint>
  801006:	89 c3                	mov    %eax,%ebx
  801008:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80100a:	85 d2                	test   %edx,%edx
  80100c:	78 0a                	js     801018 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80100e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801013:	e9 b0 00 00 00       	jmp    8010c8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	57                   	push   %edi
  80101c:	6a 2d                	push   $0x2d
  80101e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801021:	f7 db                	neg    %ebx
  801023:	83 d6 00             	adc    $0x0,%esi
  801026:	f7 de                	neg    %esi
  801028:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80102b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801030:	e9 93 00 00 00       	jmp    8010c8 <vprintfmt+0x32f>
  801035:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801038:	89 ca                	mov    %ecx,%edx
  80103a:	8d 45 14             	lea    0x14(%ebp),%eax
  80103d:	e8 b4 fc ff ff       	call   800cf6 <getuint>
  801042:	89 c3                	mov    %eax,%ebx
  801044:	89 d6                	mov    %edx,%esi
			base = 10;
  801046:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80104b:	eb 7b                	jmp    8010c8 <vprintfmt+0x32f>
  80104d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801050:	89 ca                	mov    %ecx,%edx
  801052:	8d 45 14             	lea    0x14(%ebp),%eax
  801055:	e8 d6 fc ff ff       	call   800d30 <getint>
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80105e:	85 d2                	test   %edx,%edx
  801060:	78 07                	js     801069 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801062:	b8 08 00 00 00       	mov    $0x8,%eax
  801067:	eb 5f                	jmp    8010c8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	57                   	push   %edi
  80106d:	6a 2d                	push   $0x2d
  80106f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801072:	f7 db                	neg    %ebx
  801074:	83 d6 00             	adc    $0x0,%esi
  801077:	f7 de                	neg    %esi
  801079:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80107c:	b8 08 00 00 00       	mov    $0x8,%eax
  801081:	eb 45                	jmp    8010c8 <vprintfmt+0x32f>
  801083:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	57                   	push   %edi
  80108a:	6a 30                	push   $0x30
  80108c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80108f:	83 c4 08             	add    $0x8,%esp
  801092:	57                   	push   %edi
  801093:	6a 78                	push   $0x78
  801095:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801098:	8b 45 14             	mov    0x14(%ebp),%eax
  80109b:	8d 50 04             	lea    0x4(%eax),%edx
  80109e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8010a1:	8b 18                	mov    (%eax),%ebx
  8010a3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8010a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8010ab:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8010b0:	eb 16                	jmp    8010c8 <vprintfmt+0x32f>
  8010b2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8010b5:	89 ca                	mov    %ecx,%edx
  8010b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8010ba:	e8 37 fc ff ff       	call   800cf6 <getuint>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	89 d6                	mov    %edx,%esi
			base = 16;
  8010c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8010cf:	52                   	push   %edx
  8010d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d3:	50                   	push   %eax
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	89 fa                	mov    %edi,%edx
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	e8 68 fb ff ff       	call   800c48 <printnum>
			break;
  8010e0:	83 c4 20             	add    $0x20,%esp
  8010e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010e6:	e9 d2 fc ff ff       	jmp    800dbd <vprintfmt+0x24>
  8010eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	57                   	push   %edi
  8010f2:	52                   	push   %edx
  8010f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8010f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8010fc:	e9 bc fc ff ff       	jmp    800dbd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	57                   	push   %edi
  801105:	6a 25                	push   $0x25
  801107:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	eb 02                	jmp    801111 <vprintfmt+0x378>
  80110f:	89 c6                	mov    %eax,%esi
  801111:	8d 46 ff             	lea    -0x1(%esi),%eax
  801114:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801118:	75 f5                	jne    80110f <vprintfmt+0x376>
  80111a:	e9 9e fc ff ff       	jmp    800dbd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80111f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 18             	sub    $0x18,%esp
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801133:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801136:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80113a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80113d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801144:	85 c0                	test   %eax,%eax
  801146:	74 26                	je     80116e <vsnprintf+0x47>
  801148:	85 d2                	test   %edx,%edx
  80114a:	7e 29                	jle    801175 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80114c:	ff 75 14             	pushl  0x14(%ebp)
  80114f:	ff 75 10             	pushl  0x10(%ebp)
  801152:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	68 62 0d 80 00       	push   $0x800d62
  80115b:	e8 39 fc ff ff       	call   800d99 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801160:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801163:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 0c                	jmp    80117a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80116e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801173:	eb 05                	jmp    80117a <vsnprintf+0x53>
  801175:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801182:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801185:	50                   	push   %eax
  801186:	ff 75 10             	pushl  0x10(%ebp)
  801189:	ff 75 0c             	pushl  0xc(%ebp)
  80118c:	ff 75 08             	pushl  0x8(%ebp)
  80118f:	e8 93 ff ff ff       	call   801127 <vsnprintf>
	va_end(ap);

	return rc;
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    
	...

00801198 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80119e:	80 3a 00             	cmpb   $0x0,(%edx)
  8011a1:	74 0e                	je     8011b1 <strlen+0x19>
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011a8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011ad:	75 f9                	jne    8011a8 <strlen+0x10>
  8011af:	eb 05                	jmp    8011b6 <strlen+0x1e>
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011c1:	85 d2                	test   %edx,%edx
  8011c3:	74 17                	je     8011dc <strnlen+0x24>
  8011c5:	80 39 00             	cmpb   $0x0,(%ecx)
  8011c8:	74 19                	je     8011e3 <strnlen+0x2b>
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011cf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011d0:	39 d0                	cmp    %edx,%eax
  8011d2:	74 14                	je     8011e8 <strnlen+0x30>
  8011d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011d8:	75 f5                	jne    8011cf <strnlen+0x17>
  8011da:	eb 0c                	jmp    8011e8 <strnlen+0x30>
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e1:	eb 05                	jmp    8011e8 <strnlen+0x30>
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	53                   	push   %ebx
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011fc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011ff:	42                   	inc    %edx
  801200:	84 c9                	test   %cl,%cl
  801202:	75 f5                	jne    8011f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801204:	5b                   	pop    %ebx
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	53                   	push   %ebx
  80120b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120e:	53                   	push   %ebx
  80120f:	e8 84 ff ff ff       	call   801198 <strlen>
  801214:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801217:	ff 75 0c             	pushl  0xc(%ebp)
  80121a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80121d:	50                   	push   %eax
  80121e:	e8 c7 ff ff ff       	call   8011ea <strcpy>
	return dst;
}
  801223:	89 d8                	mov    %ebx,%eax
  801225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	56                   	push   %esi
  80122e:	53                   	push   %ebx
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	8b 55 0c             	mov    0xc(%ebp),%edx
  801235:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801238:	85 f6                	test   %esi,%esi
  80123a:	74 15                	je     801251 <strncpy+0x27>
  80123c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801241:	8a 1a                	mov    (%edx),%bl
  801243:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801246:	80 3a 01             	cmpb   $0x1,(%edx)
  801249:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80124c:	41                   	inc    %ecx
  80124d:	39 ce                	cmp    %ecx,%esi
  80124f:	77 f0                	ja     801241 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801261:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801264:	85 f6                	test   %esi,%esi
  801266:	74 32                	je     80129a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801268:	83 fe 01             	cmp    $0x1,%esi
  80126b:	74 22                	je     80128f <strlcpy+0x3a>
  80126d:	8a 0b                	mov    (%ebx),%cl
  80126f:	84 c9                	test   %cl,%cl
  801271:	74 20                	je     801293 <strlcpy+0x3e>
  801273:	89 f8                	mov    %edi,%eax
  801275:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80127a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80127d:	88 08                	mov    %cl,(%eax)
  80127f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801280:	39 f2                	cmp    %esi,%edx
  801282:	74 11                	je     801295 <strlcpy+0x40>
  801284:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801288:	42                   	inc    %edx
  801289:	84 c9                	test   %cl,%cl
  80128b:	75 f0                	jne    80127d <strlcpy+0x28>
  80128d:	eb 06                	jmp    801295 <strlcpy+0x40>
  80128f:	89 f8                	mov    %edi,%eax
  801291:	eb 02                	jmp    801295 <strlcpy+0x40>
  801293:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801295:	c6 00 00             	movb   $0x0,(%eax)
  801298:	eb 02                	jmp    80129c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80129a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80129c:	29 f8                	sub    %edi,%eax
}
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	c9                   	leave  
  8012a2:	c3                   	ret    

008012a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012ac:	8a 01                	mov    (%ecx),%al
  8012ae:	84 c0                	test   %al,%al
  8012b0:	74 10                	je     8012c2 <strcmp+0x1f>
  8012b2:	3a 02                	cmp    (%edx),%al
  8012b4:	75 0c                	jne    8012c2 <strcmp+0x1f>
		p++, q++;
  8012b6:	41                   	inc    %ecx
  8012b7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012b8:	8a 01                	mov    (%ecx),%al
  8012ba:	84 c0                	test   %al,%al
  8012bc:	74 04                	je     8012c2 <strcmp+0x1f>
  8012be:	3a 02                	cmp    (%edx),%al
  8012c0:	74 f4                	je     8012b6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012c2:	0f b6 c0             	movzbl %al,%eax
  8012c5:	0f b6 12             	movzbl (%edx),%edx
  8012c8:	29 d0                	sub    %edx,%eax
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	74 1b                	je     8012f8 <strncmp+0x2c>
  8012dd:	8a 1a                	mov    (%edx),%bl
  8012df:	84 db                	test   %bl,%bl
  8012e1:	74 24                	je     801307 <strncmp+0x3b>
  8012e3:	3a 19                	cmp    (%ecx),%bl
  8012e5:	75 20                	jne    801307 <strncmp+0x3b>
  8012e7:	48                   	dec    %eax
  8012e8:	74 15                	je     8012ff <strncmp+0x33>
		n--, p++, q++;
  8012ea:	42                   	inc    %edx
  8012eb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012ec:	8a 1a                	mov    (%edx),%bl
  8012ee:	84 db                	test   %bl,%bl
  8012f0:	74 15                	je     801307 <strncmp+0x3b>
  8012f2:	3a 19                	cmp    (%ecx),%bl
  8012f4:	74 f1                	je     8012e7 <strncmp+0x1b>
  8012f6:	eb 0f                	jmp    801307 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	eb 05                	jmp    801304 <strncmp+0x38>
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801304:	5b                   	pop    %ebx
  801305:	c9                   	leave  
  801306:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801307:	0f b6 02             	movzbl (%edx),%eax
  80130a:	0f b6 11             	movzbl (%ecx),%edx
  80130d:	29 d0                	sub    %edx,%eax
  80130f:	eb f3                	jmp    801304 <strncmp+0x38>

00801311 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80131a:	8a 10                	mov    (%eax),%dl
  80131c:	84 d2                	test   %dl,%dl
  80131e:	74 18                	je     801338 <strchr+0x27>
		if (*s == c)
  801320:	38 ca                	cmp    %cl,%dl
  801322:	75 06                	jne    80132a <strchr+0x19>
  801324:	eb 17                	jmp    80133d <strchr+0x2c>
  801326:	38 ca                	cmp    %cl,%dl
  801328:	74 13                	je     80133d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80132a:	40                   	inc    %eax
  80132b:	8a 10                	mov    (%eax),%dl
  80132d:	84 d2                	test   %dl,%dl
  80132f:	75 f5                	jne    801326 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 05                	jmp    80133d <strchr+0x2c>
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	8b 45 08             	mov    0x8(%ebp),%eax
  801345:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801348:	8a 10                	mov    (%eax),%dl
  80134a:	84 d2                	test   %dl,%dl
  80134c:	74 11                	je     80135f <strfind+0x20>
		if (*s == c)
  80134e:	38 ca                	cmp    %cl,%dl
  801350:	75 06                	jne    801358 <strfind+0x19>
  801352:	eb 0b                	jmp    80135f <strfind+0x20>
  801354:	38 ca                	cmp    %cl,%dl
  801356:	74 07                	je     80135f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801358:	40                   	inc    %eax
  801359:	8a 10                	mov    (%eax),%dl
  80135b:	84 d2                	test   %dl,%dl
  80135d:	75 f5                	jne    801354 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801370:	85 c9                	test   %ecx,%ecx
  801372:	74 30                	je     8013a4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801374:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80137a:	75 25                	jne    8013a1 <memset+0x40>
  80137c:	f6 c1 03             	test   $0x3,%cl
  80137f:	75 20                	jne    8013a1 <memset+0x40>
		c &= 0xFF;
  801381:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801384:	89 d3                	mov    %edx,%ebx
  801386:	c1 e3 08             	shl    $0x8,%ebx
  801389:	89 d6                	mov    %edx,%esi
  80138b:	c1 e6 18             	shl    $0x18,%esi
  80138e:	89 d0                	mov    %edx,%eax
  801390:	c1 e0 10             	shl    $0x10,%eax
  801393:	09 f0                	or     %esi,%eax
  801395:	09 d0                	or     %edx,%eax
  801397:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801399:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80139c:	fc                   	cld    
  80139d:	f3 ab                	rep stos %eax,%es:(%edi)
  80139f:	eb 03                	jmp    8013a4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013a1:	fc                   	cld    
  8013a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	57                   	push   %edi
  8013af:	56                   	push   %esi
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013b9:	39 c6                	cmp    %eax,%esi
  8013bb:	73 34                	jae    8013f1 <memmove+0x46>
  8013bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013c0:	39 d0                	cmp    %edx,%eax
  8013c2:	73 2d                	jae    8013f1 <memmove+0x46>
		s += n;
		d += n;
  8013c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c7:	f6 c2 03             	test   $0x3,%dl
  8013ca:	75 1b                	jne    8013e7 <memmove+0x3c>
  8013cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013d2:	75 13                	jne    8013e7 <memmove+0x3c>
  8013d4:	f6 c1 03             	test   $0x3,%cl
  8013d7:	75 0e                	jne    8013e7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013d9:	83 ef 04             	sub    $0x4,%edi
  8013dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013df:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8013e2:	fd                   	std    
  8013e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013e5:	eb 07                	jmp    8013ee <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013e7:	4f                   	dec    %edi
  8013e8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013eb:	fd                   	std    
  8013ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013ee:	fc                   	cld    
  8013ef:	eb 20                	jmp    801411 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013f7:	75 13                	jne    80140c <memmove+0x61>
  8013f9:	a8 03                	test   $0x3,%al
  8013fb:	75 0f                	jne    80140c <memmove+0x61>
  8013fd:	f6 c1 03             	test   $0x3,%cl
  801400:	75 0a                	jne    80140c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801402:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801405:	89 c7                	mov    %eax,%edi
  801407:	fc                   	cld    
  801408:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80140a:	eb 05                	jmp    801411 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	fc                   	cld    
  80140f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801418:	ff 75 10             	pushl  0x10(%ebp)
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	ff 75 08             	pushl  0x8(%ebp)
  801421:	e8 85 ff ff ff       	call   8013ab <memmove>
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	57                   	push   %edi
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
  80142e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801431:	8b 75 0c             	mov    0xc(%ebp),%esi
  801434:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801437:	85 ff                	test   %edi,%edi
  801439:	74 32                	je     80146d <memcmp+0x45>
		if (*s1 != *s2)
  80143b:	8a 03                	mov    (%ebx),%al
  80143d:	8a 0e                	mov    (%esi),%cl
  80143f:	38 c8                	cmp    %cl,%al
  801441:	74 19                	je     80145c <memcmp+0x34>
  801443:	eb 0d                	jmp    801452 <memcmp+0x2a>
  801445:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801449:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80144d:	42                   	inc    %edx
  80144e:	38 c8                	cmp    %cl,%al
  801450:	74 10                	je     801462 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801452:	0f b6 c0             	movzbl %al,%eax
  801455:	0f b6 c9             	movzbl %cl,%ecx
  801458:	29 c8                	sub    %ecx,%eax
  80145a:	eb 16                	jmp    801472 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80145c:	4f                   	dec    %edi
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	39 fa                	cmp    %edi,%edx
  801464:	75 df                	jne    801445 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 05                	jmp    801472 <memcmp+0x4a>
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801482:	39 d0                	cmp    %edx,%eax
  801484:	73 12                	jae    801498 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801486:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801489:	38 08                	cmp    %cl,(%eax)
  80148b:	75 06                	jne    801493 <memfind+0x1c>
  80148d:	eb 09                	jmp    801498 <memfind+0x21>
  80148f:	38 08                	cmp    %cl,(%eax)
  801491:	74 05                	je     801498 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801493:	40                   	inc    %eax
  801494:	39 c2                	cmp    %eax,%edx
  801496:	77 f7                	ja     80148f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	57                   	push   %edi
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014a6:	eb 01                	jmp    8014a9 <strtol+0xf>
		s++;
  8014a8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014a9:	8a 02                	mov    (%edx),%al
  8014ab:	3c 20                	cmp    $0x20,%al
  8014ad:	74 f9                	je     8014a8 <strtol+0xe>
  8014af:	3c 09                	cmp    $0x9,%al
  8014b1:	74 f5                	je     8014a8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8014b3:	3c 2b                	cmp    $0x2b,%al
  8014b5:	75 08                	jne    8014bf <strtol+0x25>
		s++;
  8014b7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8014bd:	eb 13                	jmp    8014d2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014bf:	3c 2d                	cmp    $0x2d,%al
  8014c1:	75 0a                	jne    8014cd <strtol+0x33>
		s++, neg = 1;
  8014c3:	8d 52 01             	lea    0x1(%edx),%edx
  8014c6:	bf 01 00 00 00       	mov    $0x1,%edi
  8014cb:	eb 05                	jmp    8014d2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014cd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014d2:	85 db                	test   %ebx,%ebx
  8014d4:	74 05                	je     8014db <strtol+0x41>
  8014d6:	83 fb 10             	cmp    $0x10,%ebx
  8014d9:	75 28                	jne    801503 <strtol+0x69>
  8014db:	8a 02                	mov    (%edx),%al
  8014dd:	3c 30                	cmp    $0x30,%al
  8014df:	75 10                	jne    8014f1 <strtol+0x57>
  8014e1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014e5:	75 0a                	jne    8014f1 <strtol+0x57>
		s += 2, base = 16;
  8014e7:	83 c2 02             	add    $0x2,%edx
  8014ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014ef:	eb 12                	jmp    801503 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8014f1:	85 db                	test   %ebx,%ebx
  8014f3:	75 0e                	jne    801503 <strtol+0x69>
  8014f5:	3c 30                	cmp    $0x30,%al
  8014f7:	75 05                	jne    8014fe <strtol+0x64>
		s++, base = 8;
  8014f9:	42                   	inc    %edx
  8014fa:	b3 08                	mov    $0x8,%bl
  8014fc:	eb 05                	jmp    801503 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8014fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
  801508:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80150a:	8a 0a                	mov    (%edx),%cl
  80150c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80150f:	80 fb 09             	cmp    $0x9,%bl
  801512:	77 08                	ja     80151c <strtol+0x82>
			dig = *s - '0';
  801514:	0f be c9             	movsbl %cl,%ecx
  801517:	83 e9 30             	sub    $0x30,%ecx
  80151a:	eb 1e                	jmp    80153a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80151c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80151f:	80 fb 19             	cmp    $0x19,%bl
  801522:	77 08                	ja     80152c <strtol+0x92>
			dig = *s - 'a' + 10;
  801524:	0f be c9             	movsbl %cl,%ecx
  801527:	83 e9 57             	sub    $0x57,%ecx
  80152a:	eb 0e                	jmp    80153a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80152c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80152f:	80 fb 19             	cmp    $0x19,%bl
  801532:	77 13                	ja     801547 <strtol+0xad>
			dig = *s - 'A' + 10;
  801534:	0f be c9             	movsbl %cl,%ecx
  801537:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80153a:	39 f1                	cmp    %esi,%ecx
  80153c:	7d 0d                	jge    80154b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80153e:	42                   	inc    %edx
  80153f:	0f af c6             	imul   %esi,%eax
  801542:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801545:	eb c3                	jmp    80150a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801547:	89 c1                	mov    %eax,%ecx
  801549:	eb 02                	jmp    80154d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80154b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80154d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801551:	74 05                	je     801558 <strtol+0xbe>
		*endptr = (char *) s;
  801553:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801556:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801558:	85 ff                	test   %edi,%edi
  80155a:	74 04                	je     801560 <strtol+0xc6>
  80155c:	89 c8                	mov    %ecx,%eax
  80155e:	f7 d8                	neg    %eax
}
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	c9                   	leave  
  801564:	c3                   	ret    
  801565:	00 00                	add    %al,(%eax)
	...

00801568 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	57                   	push   %edi
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
  80156e:	83 ec 1c             	sub    $0x1c,%esp
  801571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801574:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801577:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801579:	8b 75 14             	mov    0x14(%ebp),%esi
  80157c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80157f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801582:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801585:	cd 30                	int    $0x30
  801587:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80158d:	74 1c                	je     8015ab <syscall+0x43>
  80158f:	85 c0                	test   %eax,%eax
  801591:	7e 18                	jle    8015ab <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	50                   	push   %eax
  801597:	ff 75 e4             	pushl  -0x1c(%ebp)
  80159a:	68 ff 2d 80 00       	push   $0x802dff
  80159f:	6a 42                	push   $0x42
  8015a1:	68 1c 2e 80 00       	push   $0x802e1c
  8015a6:	e8 b1 f5 ff ff       	call   800b5c <_panic>

	return ret;
}
  8015ab:	89 d0                	mov    %edx,%eax
  8015ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5f                   	pop    %edi
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8015bb:	6a 00                	push   $0x0
  8015bd:	6a 00                	push   $0x0
  8015bf:	6a 00                	push   $0x0
  8015c1:	ff 75 0c             	pushl  0xc(%ebp)
  8015c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d1:	e8 92 ff ff ff       	call   801568 <syscall>
  8015d6:	83 c4 10             	add    $0x10,%esp
	return;
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <sys_cgetc>:

int
sys_cgetc(void)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8015e1:	6a 00                	push   $0x0
  8015e3:	6a 00                	push   $0x0
  8015e5:	6a 00                	push   $0x0
  8015e7:	6a 00                	push   $0x0
  8015e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	e8 6b ff ff ff       	call   801568 <syscall>
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801605:	6a 00                	push   $0x0
  801607:	6a 00                	push   $0x0
  801609:	6a 00                	push   $0x0
  80160b:	6a 00                	push   $0x0
  80160d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801610:	ba 01 00 00 00       	mov    $0x1,%edx
  801615:	b8 03 00 00 00       	mov    $0x3,%eax
  80161a:	e8 49 ff ff ff       	call   801568 <syscall>
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801627:	6a 00                	push   $0x0
  801629:	6a 00                	push   $0x0
  80162b:	6a 00                	push   $0x0
  80162d:	6a 00                	push   $0x0
  80162f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 02 00 00 00       	mov    $0x2,%eax
  80163e:	e8 25 ff ff ff       	call   801568 <syscall>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <sys_yield>:

void
sys_yield(void)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80164b:	6a 00                	push   $0x0
  80164d:	6a 00                	push   $0x0
  80164f:	6a 00                	push   $0x0
  801651:	6a 00                	push   $0x0
  801653:	b9 00 00 00 00       	mov    $0x0,%ecx
  801658:	ba 00 00 00 00       	mov    $0x0,%edx
  80165d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801662:	e8 01 ff ff ff       	call   801568 <syscall>
  801667:	83 c4 10             	add    $0x10,%esp
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801672:	6a 00                	push   $0x0
  801674:	6a 00                	push   $0x0
  801676:	ff 75 10             	pushl  0x10(%ebp)
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167f:	ba 01 00 00 00       	mov    $0x1,%edx
  801684:	b8 04 00 00 00       	mov    $0x4,%eax
  801689:	e8 da fe ff ff       	call   801568 <syscall>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801696:	ff 75 18             	pushl  0x18(%ebp)
  801699:	ff 75 14             	pushl  0x14(%ebp)
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a5:	ba 01 00 00 00       	mov    $0x1,%edx
  8016aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8016af:	e8 b4 fe ff ff       	call   801568 <syscall>
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8016bc:	6a 00                	push   $0x0
  8016be:	6a 00                	push   $0x0
  8016c0:	6a 00                	push   $0x0
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c8:	ba 01 00 00 00       	mov    $0x1,%edx
  8016cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d2:	e8 91 fe ff ff       	call   801568 <syscall>
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8016df:	6a 00                	push   $0x0
  8016e1:	6a 00                	push   $0x0
  8016e3:	6a 00                	push   $0x0
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016eb:	ba 01 00 00 00       	mov    $0x1,%edx
  8016f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f5:	e8 6e fe ff ff       	call   801568 <syscall>
}
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801702:	6a 00                	push   $0x0
  801704:	6a 00                	push   $0x0
  801706:	6a 00                	push   $0x0
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	ba 01 00 00 00       	mov    $0x1,%edx
  801713:	b8 09 00 00 00       	mov    $0x9,%eax
  801718:	e8 4b fe ff ff       	call   801568 <syscall>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801725:	6a 00                	push   $0x0
  801727:	6a 00                	push   $0x0
  801729:	6a 00                	push   $0x0
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801731:	ba 01 00 00 00       	mov    $0x1,%edx
  801736:	b8 0a 00 00 00       	mov    $0xa,%eax
  80173b:	e8 28 fe ff ff       	call   801568 <syscall>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801748:	6a 00                	push   $0x0
  80174a:	ff 75 14             	pushl  0x14(%ebp)
  80174d:	ff 75 10             	pushl  0x10(%ebp)
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801760:	e8 03 fe ff ff       	call   801568 <syscall>
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80176d:	6a 00                	push   $0x0
  80176f:	6a 00                	push   $0x0
  801771:	6a 00                	push   $0x0
  801773:	6a 00                	push   $0x0
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	ba 01 00 00 00       	mov    $0x1,%edx
  80177d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801782:	e8 e1 fd ff ff       	call   801568 <syscall>
}
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80178f:	6a 00                	push   $0x0
  801791:	6a 00                	push   $0x0
  801793:	6a 00                	push   $0x0
  801795:	ff 75 0c             	pushl  0xc(%ebp)
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8017a5:	e8 be fd ff ff       	call   801568 <syscall>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8017b2:	83 3d 10 80 80 00 00 	cmpl   $0x0,0x808010
  8017b9:	75 52                	jne    80180d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	6a 07                	push   $0x7
  8017c0:	68 00 f0 bf ee       	push   $0xeebff000
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 a0 fe ff ff       	call   80166c <sys_page_alloc>
		if (r < 0) {
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	79 12                	jns    8017e5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8017d3:	50                   	push   %eax
  8017d4:	68 2a 2e 80 00       	push   $0x802e2a
  8017d9:	6a 24                	push   $0x24
  8017db:	68 45 2e 80 00       	push   $0x802e45
  8017e0:	e8 77 f3 ff ff       	call   800b5c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	68 18 18 80 00       	push   $0x801818
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 2b ff ff ff       	call   80171f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	79 12                	jns    80180d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8017fb:	50                   	push   %eax
  8017fc:	68 54 2e 80 00       	push   $0x802e54
  801801:	6a 2a                	push   $0x2a
  801803:	68 45 2e 80 00       	push   $0x802e45
  801808:	e8 4f f3 ff ff       	call   800b5c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	a3 10 80 80 00       	mov    %eax,0x808010
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    
	...

00801818 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801818:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801819:	a1 10 80 80 00       	mov    0x808010,%eax
	call *%eax
  80181e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801820:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801823:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801827:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80182a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80182e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801832:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801834:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801837:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801838:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80183b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80183c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80183d:	c3                   	ret    
	...

00801840 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	8b 75 08             	mov    0x8(%ebp),%esi
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  80184e:	85 c0                	test   %eax,%eax
  801850:	74 0e                	je     801860 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	50                   	push   %eax
  801856:	e8 0c ff ff ff       	call   801767 <sys_ipc_recv>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	eb 10                	jmp    801870 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	68 00 00 c0 ee       	push   $0xeec00000
  801868:	e8 fa fe ff ff       	call   801767 <sys_ipc_recv>
  80186d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801870:	85 c0                	test   %eax,%eax
  801872:	75 26                	jne    80189a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801874:	85 f6                	test   %esi,%esi
  801876:	74 0a                	je     801882 <ipc_recv+0x42>
  801878:	a1 0c 80 80 00       	mov    0x80800c,%eax
  80187d:	8b 40 74             	mov    0x74(%eax),%eax
  801880:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801882:	85 db                	test   %ebx,%ebx
  801884:	74 0a                	je     801890 <ipc_recv+0x50>
  801886:	a1 0c 80 80 00       	mov    0x80800c,%eax
  80188b:	8b 40 78             	mov    0x78(%eax),%eax
  80188e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801890:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801895:	8b 40 70             	mov    0x70(%eax),%eax
  801898:	eb 14                	jmp    8018ae <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80189a:	85 f6                	test   %esi,%esi
  80189c:	74 06                	je     8018a4 <ipc_recv+0x64>
  80189e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8018a4:	85 db                	test   %ebx,%ebx
  8018a6:	74 06                	je     8018ae <ipc_recv+0x6e>
  8018a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	57                   	push   %edi
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018c4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8018c7:	85 db                	test   %ebx,%ebx
  8018c9:	75 25                	jne    8018f0 <ipc_send+0x3b>
  8018cb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8018d0:	eb 1e                	jmp    8018f0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8018d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018d5:	75 07                	jne    8018de <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8018d7:	e8 69 fd ff ff       	call   801645 <sys_yield>
  8018dc:	eb 12                	jmp    8018f0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8018de:	50                   	push   %eax
  8018df:	68 7b 2e 80 00       	push   $0x802e7b
  8018e4:	6a 43                	push   $0x43
  8018e6:	68 8e 2e 80 00       	push   $0x802e8e
  8018eb:	e8 6c f2 ff ff       	call   800b5c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	57                   	push   %edi
  8018f3:	ff 75 08             	pushl  0x8(%ebp)
  8018f6:	e8 47 fe ff ff       	call   801742 <sys_ipc_try_send>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	75 d0                	jne    8018d2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801911:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801917:	74 22                	je     80193b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801919:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80191e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801925:	89 c2                	mov    %eax,%edx
  801927:	c1 e2 07             	shl    $0x7,%edx
  80192a:	29 ca                	sub    %ecx,%edx
  80192c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801932:	8b 52 50             	mov    0x50(%edx),%edx
  801935:	39 da                	cmp    %ebx,%edx
  801937:	75 1d                	jne    801956 <ipc_find_env+0x4c>
  801939:	eb 05                	jmp    801940 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801940:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801947:	c1 e0 07             	shl    $0x7,%eax
  80194a:	29 d0                	sub    %edx,%eax
  80194c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801951:	8b 40 40             	mov    0x40(%eax),%eax
  801954:	eb 0c                	jmp    801962 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801956:	40                   	inc    %eax
  801957:	3d 00 04 00 00       	cmp    $0x400,%eax
  80195c:	75 c0                	jne    80191e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80195e:	66 b8 00 00          	mov    $0x0,%ax
}
  801962:	5b                   	pop    %ebx
  801963:	c9                   	leave  
  801964:	c3                   	ret    
  801965:	00 00                	add    %al,(%eax)
	...

00801968 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	05 00 00 00 30       	add    $0x30000000,%eax
  801973:	c1 e8 0c             	shr    $0xc,%eax
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80197b:	ff 75 08             	pushl  0x8(%ebp)
  80197e:	e8 e5 ff ff ff       	call   801968 <fd2num>
  801983:	83 c4 04             	add    $0x4,%esp
  801986:	05 20 00 0d 00       	add    $0xd0020,%eax
  80198b:	c1 e0 0c             	shl    $0xc,%eax
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801997:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80199c:	a8 01                	test   $0x1,%al
  80199e:	74 34                	je     8019d4 <fd_alloc+0x44>
  8019a0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8019a5:	a8 01                	test   $0x1,%al
  8019a7:	74 32                	je     8019db <fd_alloc+0x4b>
  8019a9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8019ae:	89 c1                	mov    %eax,%ecx
  8019b0:	89 c2                	mov    %eax,%edx
  8019b2:	c1 ea 16             	shr    $0x16,%edx
  8019b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019bc:	f6 c2 01             	test   $0x1,%dl
  8019bf:	74 1f                	je     8019e0 <fd_alloc+0x50>
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	c1 ea 0c             	shr    $0xc,%edx
  8019c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019cd:	f6 c2 01             	test   $0x1,%dl
  8019d0:	75 17                	jne    8019e9 <fd_alloc+0x59>
  8019d2:	eb 0c                	jmp    8019e0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8019d4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8019d9:	eb 05                	jmp    8019e0 <fd_alloc+0x50>
  8019db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8019e0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8019e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e7:	eb 17                	jmp    801a00 <fd_alloc+0x70>
  8019e9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019f3:	75 b9                	jne    8019ae <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8019fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801a00:	5b                   	pop    %ebx
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801a09:	83 f8 1f             	cmp    $0x1f,%eax
  801a0c:	77 36                	ja     801a44 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801a0e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801a13:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	c1 ea 16             	shr    $0x16,%edx
  801a1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a22:	f6 c2 01             	test   $0x1,%dl
  801a25:	74 24                	je     801a4b <fd_lookup+0x48>
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	c1 ea 0c             	shr    $0xc,%edx
  801a2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a33:	f6 c2 01             	test   $0x1,%dl
  801a36:	74 1a                	je     801a52 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3b:	89 02                	mov    %eax,(%edx)
	return 0;
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a42:	eb 13                	jmp    801a57 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a49:	eb 0c                	jmp    801a57 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a50:	eb 05                	jmp    801a57 <fd_lookup+0x54>
  801a52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801a66:	39 0d 44 70 80 00    	cmp    %ecx,0x807044
  801a6c:	74 0d                	je     801a7b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a73:	eb 14                	jmp    801a89 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801a75:	39 0a                	cmp    %ecx,(%edx)
  801a77:	75 10                	jne    801a89 <dev_lookup+0x30>
  801a79:	eb 05                	jmp    801a80 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a7b:	ba 44 70 80 00       	mov    $0x807044,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801a80:	89 13                	mov    %edx,(%ebx)
			return 0;
  801a82:	b8 00 00 00 00       	mov    $0x0,%eax
  801a87:	eb 31                	jmp    801aba <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a89:	40                   	inc    %eax
  801a8a:	8b 14 85 18 2f 80 00 	mov    0x802f18(,%eax,4),%edx
  801a91:	85 d2                	test   %edx,%edx
  801a93:	75 e0                	jne    801a75 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a95:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801a9a:	8b 40 48             	mov    0x48(%eax),%eax
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	51                   	push   %ecx
  801aa1:	50                   	push   %eax
  801aa2:	68 98 2e 80 00       	push   $0x802e98
  801aa7:	e8 88 f1 ff ff       	call   800c34 <cprintf>
	*dev = 0;
  801aac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 20             	sub    $0x20,%esp
  801ac7:	8b 75 08             	mov    0x8(%ebp),%esi
  801aca:	8a 45 0c             	mov    0xc(%ebp),%al
  801acd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ad0:	56                   	push   %esi
  801ad1:	e8 92 fe ff ff       	call   801968 <fd2num>
  801ad6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ad9:	89 14 24             	mov    %edx,(%esp)
  801adc:	50                   	push   %eax
  801add:	e8 21 ff ff ff       	call   801a03 <fd_lookup>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 05                	js     801af0 <fd_close+0x31>
	    || fd != fd2)
  801aeb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aee:	74 0d                	je     801afd <fd_close+0x3e>
		return (must_exist ? r : 0);
  801af0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801af4:	75 48                	jne    801b3e <fd_close+0x7f>
  801af6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afb:	eb 41                	jmp    801b3e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b03:	50                   	push   %eax
  801b04:	ff 36                	pushl  (%esi)
  801b06:	e8 4e ff ff ff       	call   801a59 <dev_lookup>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 1c                	js     801b30 <fd_close+0x71>
		if (dev->dev_close)
  801b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b17:	8b 40 10             	mov    0x10(%eax),%eax
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	74 0d                	je     801b2b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	56                   	push   %esi
  801b22:	ff d0                	call   *%eax
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	eb 05                	jmp    801b30 <fd_close+0x71>
		else
			r = 0;
  801b2b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	56                   	push   %esi
  801b34:	6a 00                	push   $0x0
  801b36:	e8 7b fb ff ff       	call   8016b6 <sys_page_unmap>
	return r;
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	89 d8                	mov    %ebx,%eax
  801b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b50:	50                   	push   %eax
  801b51:	ff 75 08             	pushl  0x8(%ebp)
  801b54:	e8 aa fe ff ff       	call   801a03 <fd_lookup>
  801b59:	83 c4 08             	add    $0x8,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 10                	js     801b70 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	6a 01                	push   $0x1
  801b65:	ff 75 f4             	pushl  -0xc(%ebp)
  801b68:	e8 52 ff ff ff       	call   801abf <fd_close>
  801b6d:	83 c4 10             	add    $0x10,%esp
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <close_all>:

void
close_all(void)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801b79:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	53                   	push   %ebx
  801b82:	e8 c0 ff ff ff       	call   801b47 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b87:	43                   	inc    %ebx
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	83 fb 20             	cmp    $0x20,%ebx
  801b8e:	75 ee                	jne    801b7e <close_all+0xc>
		close(i);
}
  801b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	57                   	push   %edi
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 2c             	sub    $0x2c,%esp
  801b9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ba1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ba4:	50                   	push   %eax
  801ba5:	ff 75 08             	pushl  0x8(%ebp)
  801ba8:	e8 56 fe ff ff       	call   801a03 <fd_lookup>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 08             	add    $0x8,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 c0 00 00 00    	js     801c7a <dup+0xe5>
		return r;
	close(newfdnum);
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	57                   	push   %edi
  801bbe:	e8 84 ff ff ff       	call   801b47 <close>

	newfd = INDEX2FD(newfdnum);
  801bc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bcc:	83 c4 04             	add    $0x4,%esp
  801bcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd2:	e8 a1 fd ff ff       	call   801978 <fd2data>
  801bd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bd9:	89 34 24             	mov    %esi,(%esp)
  801bdc:	e8 97 fd ff ff       	call   801978 <fd2data>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801be7:	89 d8                	mov    %ebx,%eax
  801be9:	c1 e8 16             	shr    $0x16,%eax
  801bec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bf3:	a8 01                	test   $0x1,%al
  801bf5:	74 37                	je     801c2e <dup+0x99>
  801bf7:	89 d8                	mov    %ebx,%eax
  801bf9:	c1 e8 0c             	shr    $0xc,%eax
  801bfc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c03:	f6 c2 01             	test   $0x1,%dl
  801c06:	74 26                	je     801c2e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c08:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	25 07 0e 00 00       	and    $0xe07,%eax
  801c17:	50                   	push   %eax
  801c18:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c1b:	6a 00                	push   $0x0
  801c1d:	53                   	push   %ebx
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 6b fa ff ff       	call   801690 <sys_page_map>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 2d                	js     801c5b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c31:	89 c2                	mov    %eax,%edx
  801c33:	c1 ea 0c             	shr    $0xc,%edx
  801c36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c46:	52                   	push   %edx
  801c47:	56                   	push   %esi
  801c48:	6a 00                	push   $0x0
  801c4a:	50                   	push   %eax
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 3e fa ff ff       	call   801690 <sys_page_map>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 20             	add    $0x20,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	79 1d                	jns    801c78 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c5b:	83 ec 08             	sub    $0x8,%esp
  801c5e:	56                   	push   %esi
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 50 fa ff ff       	call   8016b6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c6c:	6a 00                	push   $0x0
  801c6e:	e8 43 fa ff ff       	call   8016b6 <sys_page_unmap>
	return r;
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	eb 02                	jmp    801c7a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801c78:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801c7a:	89 d8                	mov    %ebx,%eax
  801c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	83 ec 14             	sub    $0x14,%esp
  801c8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c91:	50                   	push   %eax
  801c92:	53                   	push   %ebx
  801c93:	e8 6b fd ff ff       	call   801a03 <fd_lookup>
  801c98:	83 c4 08             	add    $0x8,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 67                	js     801d06 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca5:	50                   	push   %eax
  801ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca9:	ff 30                	pushl  (%eax)
  801cab:	e8 a9 fd ff ff       	call   801a59 <dev_lookup>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 4f                	js     801d06 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	8b 50 08             	mov    0x8(%eax),%edx
  801cbd:	83 e2 03             	and    $0x3,%edx
  801cc0:	83 fa 01             	cmp    $0x1,%edx
  801cc3:	75 21                	jne    801ce6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801cc5:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801cca:	8b 40 48             	mov    0x48(%eax),%eax
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	53                   	push   %ebx
  801cd1:	50                   	push   %eax
  801cd2:	68 dc 2e 80 00       	push   $0x802edc
  801cd7:	e8 58 ef ff ff       	call   800c34 <cprintf>
		return -E_INVAL;
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce4:	eb 20                	jmp    801d06 <read+0x82>
	}
	if (!dev->dev_read)
  801ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce9:	8b 52 08             	mov    0x8(%edx),%edx
  801cec:	85 d2                	test   %edx,%edx
  801cee:	74 11                	je     801d01 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	ff 75 10             	pushl  0x10(%ebp)
  801cf6:	ff 75 0c             	pushl  0xc(%ebp)
  801cf9:	50                   	push   %eax
  801cfa:	ff d2                	call   *%edx
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	eb 05                	jmp    801d06 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801d01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801d06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	57                   	push   %edi
  801d0f:	56                   	push   %esi
  801d10:	53                   	push   %ebx
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d17:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d1a:	85 f6                	test   %esi,%esi
  801d1c:	74 31                	je     801d4f <readn+0x44>
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d28:	83 ec 04             	sub    $0x4,%esp
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	29 c2                	sub    %eax,%edx
  801d2f:	52                   	push   %edx
  801d30:	03 45 0c             	add    0xc(%ebp),%eax
  801d33:	50                   	push   %eax
  801d34:	57                   	push   %edi
  801d35:	e8 4a ff ff ff       	call   801c84 <read>
		if (m < 0)
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 17                	js     801d58 <readn+0x4d>
			return m;
		if (m == 0)
  801d41:	85 c0                	test   %eax,%eax
  801d43:	74 11                	je     801d56 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d45:	01 c3                	add    %eax,%ebx
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	39 f3                	cmp    %esi,%ebx
  801d4b:	72 db                	jb     801d28 <readn+0x1d>
  801d4d:	eb 09                	jmp    801d58 <readn+0x4d>
  801d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d54:	eb 02                	jmp    801d58 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801d56:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	53                   	push   %ebx
  801d64:	83 ec 14             	sub    $0x14,%esp
  801d67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	53                   	push   %ebx
  801d6f:	e8 8f fc ff ff       	call   801a03 <fd_lookup>
  801d74:	83 c4 08             	add    $0x8,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 62                	js     801ddd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d7b:	83 ec 08             	sub    $0x8,%esp
  801d7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d81:	50                   	push   %eax
  801d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d85:	ff 30                	pushl  (%eax)
  801d87:	e8 cd fc ff ff       	call   801a59 <dev_lookup>
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 4a                	js     801ddd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d96:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d9a:	75 21                	jne    801dbd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d9c:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801da1:	8b 40 48             	mov    0x48(%eax),%eax
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	53                   	push   %ebx
  801da8:	50                   	push   %eax
  801da9:	68 f8 2e 80 00       	push   $0x802ef8
  801dae:	e8 81 ee ff ff       	call   800c34 <cprintf>
		return -E_INVAL;
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dbb:	eb 20                	jmp    801ddd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801dbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc0:	8b 52 0c             	mov    0xc(%edx),%edx
  801dc3:	85 d2                	test   %edx,%edx
  801dc5:	74 11                	je     801dd8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801dc7:	83 ec 04             	sub    $0x4,%esp
  801dca:	ff 75 10             	pushl  0x10(%ebp)
  801dcd:	ff 75 0c             	pushl  0xc(%ebp)
  801dd0:	50                   	push   %eax
  801dd1:	ff d2                	call   *%edx
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	eb 05                	jmp    801ddd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801dd8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ddd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <seek>:

int
seek(int fdnum, off_t offset)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	ff 75 08             	pushl  0x8(%ebp)
  801def:	e8 0f fc ff ff       	call   801a03 <fd_lookup>
  801df4:	83 c4 08             	add    $0x8,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 0e                	js     801e09 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801dfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e01:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801e04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 14             	sub    $0x14,%esp
  801e12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	53                   	push   %ebx
  801e1a:	e8 e4 fb ff ff       	call   801a03 <fd_lookup>
  801e1f:	83 c4 08             	add    $0x8,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 5f                	js     801e85 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e30:	ff 30                	pushl  (%eax)
  801e32:	e8 22 fc ff ff       	call   801a59 <dev_lookup>
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 47                	js     801e85 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e41:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e45:	75 21                	jne    801e68 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e47:	a1 0c 80 80 00       	mov    0x80800c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e4c:	8b 40 48             	mov    0x48(%eax),%eax
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	53                   	push   %ebx
  801e53:	50                   	push   %eax
  801e54:	68 b8 2e 80 00       	push   $0x802eb8
  801e59:	e8 d6 ed ff ff       	call   800c34 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e66:	eb 1d                	jmp    801e85 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801e68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e6b:	8b 52 18             	mov    0x18(%edx),%edx
  801e6e:	85 d2                	test   %edx,%edx
  801e70:	74 0e                	je     801e80 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	50                   	push   %eax
  801e79:	ff d2                	call   *%edx
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	eb 05                	jmp    801e85 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801e80:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	53                   	push   %ebx
  801e8e:	83 ec 14             	sub    $0x14,%esp
  801e91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e97:	50                   	push   %eax
  801e98:	ff 75 08             	pushl  0x8(%ebp)
  801e9b:	e8 63 fb ff ff       	call   801a03 <fd_lookup>
  801ea0:	83 c4 08             	add    $0x8,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	78 52                	js     801ef9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ea7:	83 ec 08             	sub    $0x8,%esp
  801eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ead:	50                   	push   %eax
  801eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb1:	ff 30                	pushl  (%eax)
  801eb3:	e8 a1 fb ff ff       	call   801a59 <dev_lookup>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 3a                	js     801ef9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ec6:	74 2c                	je     801ef4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ec8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ecb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ed2:	00 00 00 
	stat->st_isdir = 0;
  801ed5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801edc:	00 00 00 
	stat->st_dev = dev;
  801edf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ee5:	83 ec 08             	sub    $0x8,%esp
  801ee8:	53                   	push   %ebx
  801ee9:	ff 75 f0             	pushl  -0x10(%ebp)
  801eec:	ff 50 14             	call   *0x14(%eax)
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	eb 05                	jmp    801ef9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ef4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	6a 00                	push   $0x0
  801f08:	ff 75 08             	pushl  0x8(%ebp)
  801f0b:	e8 78 01 00 00       	call   802088 <open>
  801f10:	89 c3                	mov    %eax,%ebx
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	85 c0                	test   %eax,%eax
  801f17:	78 1b                	js     801f34 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	ff 75 0c             	pushl  0xc(%ebp)
  801f1f:	50                   	push   %eax
  801f20:	e8 65 ff ff ff       	call   801e8a <fstat>
  801f25:	89 c6                	mov    %eax,%esi
	close(fd);
  801f27:	89 1c 24             	mov    %ebx,(%esp)
  801f2a:	e8 18 fc ff ff       	call   801b47 <close>
	return r;
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	89 f3                	mov    %esi,%ebx
}
  801f34:	89 d8                	mov    %ebx,%eax
  801f36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    
  801f3d:	00 00                	add    %al,(%eax)
	...

00801f40 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	56                   	push   %esi
  801f44:	53                   	push   %ebx
  801f45:	89 c3                	mov    %eax,%ebx
  801f47:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f49:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801f50:	75 12                	jne    801f64 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f52:	83 ec 0c             	sub    $0xc,%esp
  801f55:	6a 01                	push   $0x1
  801f57:	e8 ae f9 ff ff       	call   80190a <ipc_find_env>
  801f5c:	a3 00 80 80 00       	mov    %eax,0x808000
  801f61:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f64:	6a 07                	push   $0x7
  801f66:	68 00 90 80 00       	push   $0x809000
  801f6b:	53                   	push   %ebx
  801f6c:	ff 35 00 80 80 00    	pushl  0x808000
  801f72:	e8 3e f9 ff ff       	call   8018b5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801f77:	83 c4 0c             	add    $0xc,%esp
  801f7a:	6a 00                	push   $0x0
  801f7c:	56                   	push   %esi
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 bc f8 ff ff       	call   801840 <ipc_recv>
}
  801f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 04             	sub    $0x4,%esp
  801f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f95:	8b 45 08             	mov    0x8(%ebp),%eax
  801f98:	8b 40 0c             	mov    0xc(%eax),%eax
  801f9b:	a3 00 90 80 00       	mov    %eax,0x809000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801fa0:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa5:	b8 05 00 00 00       	mov    $0x5,%eax
  801faa:	e8 91 ff ff ff       	call   801f40 <fsipc>
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 2c                	js     801fdf <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fb3:	83 ec 08             	sub    $0x8,%esp
  801fb6:	68 00 90 80 00       	push   $0x809000
  801fbb:	53                   	push   %ebx
  801fbc:	e8 29 f2 ff ff       	call   8011ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fc1:	a1 80 90 80 00       	mov    0x809080,%eax
  801fc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801fcc:	a1 84 90 80 00       	mov    0x809084,%eax
  801fd1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	8b 40 0c             	mov    0xc(%eax),%eax
  801ff0:	a3 00 90 80 00       	mov    %eax,0x809000
	return fsipc(FSREQ_FLUSH, NULL);
  801ff5:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffa:	b8 06 00 00 00       	mov    $0x6,%eax
  801fff:	e8 3c ff ff ff       	call   801f40 <fsipc>
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	8b 40 0c             	mov    0xc(%eax),%eax
  802014:	a3 00 90 80 00       	mov    %eax,0x809000
	fsipcbuf.read.req_n = n;
  802019:	89 35 04 90 80 00    	mov    %esi,0x809004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80201f:	ba 00 00 00 00       	mov    $0x0,%edx
  802024:	b8 03 00 00 00       	mov    $0x3,%eax
  802029:	e8 12 ff ff ff       	call   801f40 <fsipc>
  80202e:	89 c3                	mov    %eax,%ebx
  802030:	85 c0                	test   %eax,%eax
  802032:	78 4b                	js     80207f <devfile_read+0x79>
		return r;
	assert(r <= n);
  802034:	39 c6                	cmp    %eax,%esi
  802036:	73 16                	jae    80204e <devfile_read+0x48>
  802038:	68 28 2f 80 00       	push   $0x802f28
  80203d:	68 fd 28 80 00       	push   $0x8028fd
  802042:	6a 7d                	push   $0x7d
  802044:	68 2f 2f 80 00       	push   $0x802f2f
  802049:	e8 0e eb ff ff       	call   800b5c <_panic>
	assert(r <= PGSIZE);
  80204e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802053:	7e 16                	jle    80206b <devfile_read+0x65>
  802055:	68 3a 2f 80 00       	push   $0x802f3a
  80205a:	68 fd 28 80 00       	push   $0x8028fd
  80205f:	6a 7e                	push   $0x7e
  802061:	68 2f 2f 80 00       	push   $0x802f2f
  802066:	e8 f1 ea ff ff       	call   800b5c <_panic>
	memmove(buf, &fsipcbuf, r);
  80206b:	83 ec 04             	sub    $0x4,%esp
  80206e:	50                   	push   %eax
  80206f:	68 00 90 80 00       	push   $0x809000
  802074:	ff 75 0c             	pushl  0xc(%ebp)
  802077:	e8 2f f3 ff ff       	call   8013ab <memmove>
	return r;
  80207c:	83 c4 10             	add    $0x10,%esp
}
  80207f:	89 d8                	mov    %ebx,%eax
  802081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	83 ec 1c             	sub    $0x1c,%esp
  802090:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802093:	56                   	push   %esi
  802094:	e8 ff f0 ff ff       	call   801198 <strlen>
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020a1:	7f 65                	jg     802108 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a9:	50                   	push   %eax
  8020aa:	e8 e1 f8 ff ff       	call   801990 <fd_alloc>
  8020af:	89 c3                	mov    %eax,%ebx
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	78 55                	js     80210d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8020b8:	83 ec 08             	sub    $0x8,%esp
  8020bb:	56                   	push   %esi
  8020bc:	68 00 90 80 00       	push   $0x809000
  8020c1:	e8 24 f1 ff ff       	call   8011ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  8020c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c9:	a3 00 94 80 00       	mov    %eax,0x809400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8020ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	e8 65 fe ff ff       	call   801f40 <fsipc>
  8020db:	89 c3                	mov    %eax,%ebx
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	79 12                	jns    8020f6 <open+0x6e>
		fd_close(fd, 0);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	6a 00                	push   $0x0
  8020e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ec:	e8 ce f9 ff ff       	call   801abf <fd_close>
		return r;
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	eb 17                	jmp    80210d <open+0x85>
	}

	return fd2num(fd);
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fc:	e8 67 f8 ff ff       	call   801968 <fd2num>
  802101:	89 c3                	mov    %eax,%ebx
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	eb 05                	jmp    80210d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802108:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80210d:	89 d8                	mov    %ebx,%eax
  80210f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802112:	5b                   	pop    %ebx
  802113:	5e                   	pop    %esi
  802114:	c9                   	leave  
  802115:	c3                   	ret    
	...

00802118 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211e:	89 c2                	mov    %eax,%edx
  802120:	c1 ea 16             	shr    $0x16,%edx
  802123:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80212a:	f6 c2 01             	test   $0x1,%dl
  80212d:	74 1e                	je     80214d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80212f:	c1 e8 0c             	shr    $0xc,%eax
  802132:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802139:	a8 01                	test   $0x1,%al
  80213b:	74 17                	je     802154 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80213d:	c1 e8 0c             	shr    $0xc,%eax
  802140:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802147:	ef 
  802148:	0f b7 c0             	movzwl %ax,%eax
  80214b:	eb 0c                	jmp    802159 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80214d:	b8 00 00 00 00       	mov    $0x0,%eax
  802152:	eb 05                	jmp    802159 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802154:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    
	...

0080215c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	56                   	push   %esi
  802160:	53                   	push   %ebx
  802161:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802164:	83 ec 0c             	sub    $0xc,%esp
  802167:	ff 75 08             	pushl  0x8(%ebp)
  80216a:	e8 09 f8 ff ff       	call   801978 <fd2data>
  80216f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802171:	83 c4 08             	add    $0x8,%esp
  802174:	68 46 2f 80 00       	push   $0x802f46
  802179:	56                   	push   %esi
  80217a:	e8 6b f0 ff ff       	call   8011ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80217f:	8b 43 04             	mov    0x4(%ebx),%eax
  802182:	2b 03                	sub    (%ebx),%eax
  802184:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80218a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802191:	00 00 00 
	stat->st_dev = &devpipe;
  802194:	c7 86 88 00 00 00 60 	movl   $0x807060,0x88(%esi)
  80219b:	70 80 00 
	return 0;
}
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a6:	5b                   	pop    %ebx
  8021a7:	5e                   	pop    %esi
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	53                   	push   %ebx
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021b4:	53                   	push   %ebx
  8021b5:	6a 00                	push   $0x0
  8021b7:	e8 fa f4 ff ff       	call   8016b6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021bc:	89 1c 24             	mov    %ebx,(%esp)
  8021bf:	e8 b4 f7 ff ff       	call   801978 <fd2data>
  8021c4:	83 c4 08             	add    $0x8,%esp
  8021c7:	50                   	push   %eax
  8021c8:	6a 00                	push   $0x0
  8021ca:	e8 e7 f4 ff ff       	call   8016b6 <sys_page_unmap>
}
  8021cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d2:	c9                   	leave  
  8021d3:	c3                   	ret    

008021d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	57                   	push   %edi
  8021d8:	56                   	push   %esi
  8021d9:	53                   	push   %ebx
  8021da:	83 ec 1c             	sub    $0x1c,%esp
  8021dd:	89 c7                	mov    %eax,%edi
  8021df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021e2:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8021e7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	57                   	push   %edi
  8021ee:	e8 25 ff ff ff       	call   802118 <pageref>
  8021f3:	89 c6                	mov    %eax,%esi
  8021f5:	83 c4 04             	add    $0x4,%esp
  8021f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021fb:	e8 18 ff ff ff       	call   802118 <pageref>
  802200:	83 c4 10             	add    $0x10,%esp
  802203:	39 c6                	cmp    %eax,%esi
  802205:	0f 94 c0             	sete   %al
  802208:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80220b:	8b 15 0c 80 80 00    	mov    0x80800c,%edx
  802211:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802214:	39 cb                	cmp    %ecx,%ebx
  802216:	75 08                	jne    802220 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5f                   	pop    %edi
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802220:	83 f8 01             	cmp    $0x1,%eax
  802223:	75 bd                	jne    8021e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802225:	8b 42 58             	mov    0x58(%edx),%eax
  802228:	6a 01                	push   $0x1
  80222a:	50                   	push   %eax
  80222b:	53                   	push   %ebx
  80222c:	68 4d 2f 80 00       	push   $0x802f4d
  802231:	e8 fe e9 ff ff       	call   800c34 <cprintf>
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	eb a7                	jmp    8021e2 <_pipeisclosed+0xe>

0080223b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	57                   	push   %edi
  80223f:	56                   	push   %esi
  802240:	53                   	push   %ebx
  802241:	83 ec 28             	sub    $0x28,%esp
  802244:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802247:	56                   	push   %esi
  802248:	e8 2b f7 ff ff       	call   801978 <fd2data>
  80224d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224f:	83 c4 10             	add    $0x10,%esp
  802252:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802256:	75 4a                	jne    8022a2 <devpipe_write+0x67>
  802258:	bf 00 00 00 00       	mov    $0x0,%edi
  80225d:	eb 56                	jmp    8022b5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80225f:	89 da                	mov    %ebx,%edx
  802261:	89 f0                	mov    %esi,%eax
  802263:	e8 6c ff ff ff       	call   8021d4 <_pipeisclosed>
  802268:	85 c0                	test   %eax,%eax
  80226a:	75 4d                	jne    8022b9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80226c:	e8 d4 f3 ff ff       	call   801645 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802271:	8b 43 04             	mov    0x4(%ebx),%eax
  802274:	8b 13                	mov    (%ebx),%edx
  802276:	83 c2 20             	add    $0x20,%edx
  802279:	39 d0                	cmp    %edx,%eax
  80227b:	73 e2                	jae    80225f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80227d:	89 c2                	mov    %eax,%edx
  80227f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802285:	79 05                	jns    80228c <devpipe_write+0x51>
  802287:	4a                   	dec    %edx
  802288:	83 ca e0             	or     $0xffffffe0,%edx
  80228b:	42                   	inc    %edx
  80228c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80228f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802292:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802296:	40                   	inc    %eax
  802297:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80229a:	47                   	inc    %edi
  80229b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80229e:	77 07                	ja     8022a7 <devpipe_write+0x6c>
  8022a0:	eb 13                	jmp    8022b5 <devpipe_write+0x7a>
  8022a2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8022aa:	8b 13                	mov    (%ebx),%edx
  8022ac:	83 c2 20             	add    $0x20,%edx
  8022af:	39 d0                	cmp    %edx,%eax
  8022b1:	73 ac                	jae    80225f <devpipe_write+0x24>
  8022b3:	eb c8                	jmp    80227d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022b5:	89 f8                	mov    %edi,%eax
  8022b7:	eb 05                	jmp    8022be <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022b9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c1:	5b                   	pop    %ebx
  8022c2:	5e                   	pop    %esi
  8022c3:	5f                   	pop    %edi
  8022c4:	c9                   	leave  
  8022c5:	c3                   	ret    

008022c6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c6:	55                   	push   %ebp
  8022c7:	89 e5                	mov    %esp,%ebp
  8022c9:	57                   	push   %edi
  8022ca:	56                   	push   %esi
  8022cb:	53                   	push   %ebx
  8022cc:	83 ec 18             	sub    $0x18,%esp
  8022cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022d2:	57                   	push   %edi
  8022d3:	e8 a0 f6 ff ff       	call   801978 <fd2data>
  8022d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022e1:	75 44                	jne    802327 <devpipe_read+0x61>
  8022e3:	be 00 00 00 00       	mov    $0x0,%esi
  8022e8:	eb 4f                	jmp    802339 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8022ea:	89 f0                	mov    %esi,%eax
  8022ec:	eb 54                	jmp    802342 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022ee:	89 da                	mov    %ebx,%edx
  8022f0:	89 f8                	mov    %edi,%eax
  8022f2:	e8 dd fe ff ff       	call   8021d4 <_pipeisclosed>
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	75 42                	jne    80233d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022fb:	e8 45 f3 ff ff       	call   801645 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802300:	8b 03                	mov    (%ebx),%eax
  802302:	3b 43 04             	cmp    0x4(%ebx),%eax
  802305:	74 e7                	je     8022ee <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802307:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80230c:	79 05                	jns    802313 <devpipe_read+0x4d>
  80230e:	48                   	dec    %eax
  80230f:	83 c8 e0             	or     $0xffffffe0,%eax
  802312:	40                   	inc    %eax
  802313:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80231d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80231f:	46                   	inc    %esi
  802320:	39 75 10             	cmp    %esi,0x10(%ebp)
  802323:	77 07                	ja     80232c <devpipe_read+0x66>
  802325:	eb 12                	jmp    802339 <devpipe_read+0x73>
  802327:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80232c:	8b 03                	mov    (%ebx),%eax
  80232e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802331:	75 d4                	jne    802307 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802333:	85 f6                	test   %esi,%esi
  802335:	75 b3                	jne    8022ea <devpipe_read+0x24>
  802337:	eb b5                	jmp    8022ee <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802339:	89 f0                	mov    %esi,%eax
  80233b:	eb 05                	jmp    802342 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80233d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802345:	5b                   	pop    %ebx
  802346:	5e                   	pop    %esi
  802347:	5f                   	pop    %edi
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	57                   	push   %edi
  80234e:	56                   	push   %esi
  80234f:	53                   	push   %ebx
  802350:	83 ec 28             	sub    $0x28,%esp
  802353:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802356:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802359:	50                   	push   %eax
  80235a:	e8 31 f6 ff ff       	call   801990 <fd_alloc>
  80235f:	89 c3                	mov    %eax,%ebx
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	85 c0                	test   %eax,%eax
  802366:	0f 88 24 01 00 00    	js     802490 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236c:	83 ec 04             	sub    $0x4,%esp
  80236f:	68 07 04 00 00       	push   $0x407
  802374:	ff 75 e4             	pushl  -0x1c(%ebp)
  802377:	6a 00                	push   $0x0
  802379:	e8 ee f2 ff ff       	call   80166c <sys_page_alloc>
  80237e:	89 c3                	mov    %eax,%ebx
  802380:	83 c4 10             	add    $0x10,%esp
  802383:	85 c0                	test   %eax,%eax
  802385:	0f 88 05 01 00 00    	js     802490 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80238b:	83 ec 0c             	sub    $0xc,%esp
  80238e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802391:	50                   	push   %eax
  802392:	e8 f9 f5 ff ff       	call   801990 <fd_alloc>
  802397:	89 c3                	mov    %eax,%ebx
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	85 c0                	test   %eax,%eax
  80239e:	0f 88 dc 00 00 00    	js     802480 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a4:	83 ec 04             	sub    $0x4,%esp
  8023a7:	68 07 04 00 00       	push   $0x407
  8023ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8023af:	6a 00                	push   $0x0
  8023b1:	e8 b6 f2 ff ff       	call   80166c <sys_page_alloc>
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	0f 88 bd 00 00 00    	js     802480 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023c3:	83 ec 0c             	sub    $0xc,%esp
  8023c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023c9:	e8 aa f5 ff ff       	call   801978 <fd2data>
  8023ce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023d0:	83 c4 0c             	add    $0xc,%esp
  8023d3:	68 07 04 00 00       	push   $0x407
  8023d8:	50                   	push   %eax
  8023d9:	6a 00                	push   $0x0
  8023db:	e8 8c f2 ff ff       	call   80166c <sys_page_alloc>
  8023e0:	89 c3                	mov    %eax,%ebx
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	0f 88 83 00 00 00    	js     802470 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ed:	83 ec 0c             	sub    $0xc,%esp
  8023f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8023f3:	e8 80 f5 ff ff       	call   801978 <fd2data>
  8023f8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023ff:	50                   	push   %eax
  802400:	6a 00                	push   $0x0
  802402:	56                   	push   %esi
  802403:	6a 00                	push   $0x0
  802405:	e8 86 f2 ff ff       	call   801690 <sys_page_map>
  80240a:	89 c3                	mov    %eax,%ebx
  80240c:	83 c4 20             	add    $0x20,%esp
  80240f:	85 c0                	test   %eax,%eax
  802411:	78 4f                	js     802462 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802413:	8b 15 60 70 80 00    	mov    0x807060,%edx
  802419:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80241e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802421:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802428:	8b 15 60 70 80 00    	mov    0x807060,%edx
  80242e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802431:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802436:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	ff 75 e4             	pushl  -0x1c(%ebp)
  802443:	e8 20 f5 ff ff       	call   801968 <fd2num>
  802448:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80244a:	83 c4 04             	add    $0x4,%esp
  80244d:	ff 75 e0             	pushl  -0x20(%ebp)
  802450:	e8 13 f5 ff ff       	call   801968 <fd2num>
  802455:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802460:	eb 2e                	jmp    802490 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802462:	83 ec 08             	sub    $0x8,%esp
  802465:	56                   	push   %esi
  802466:	6a 00                	push   $0x0
  802468:	e8 49 f2 ff ff       	call   8016b6 <sys_page_unmap>
  80246d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802470:	83 ec 08             	sub    $0x8,%esp
  802473:	ff 75 e0             	pushl  -0x20(%ebp)
  802476:	6a 00                	push   $0x0
  802478:	e8 39 f2 ff ff       	call   8016b6 <sys_page_unmap>
  80247d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802480:	83 ec 08             	sub    $0x8,%esp
  802483:	ff 75 e4             	pushl  -0x1c(%ebp)
  802486:	6a 00                	push   $0x0
  802488:	e8 29 f2 ff ff       	call   8016b6 <sys_page_unmap>
  80248d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802490:	89 d8                	mov    %ebx,%eax
  802492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802495:	5b                   	pop    %ebx
  802496:	5e                   	pop    %esi
  802497:	5f                   	pop    %edi
  802498:	c9                   	leave  
  802499:	c3                   	ret    

0080249a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a3:	50                   	push   %eax
  8024a4:	ff 75 08             	pushl  0x8(%ebp)
  8024a7:	e8 57 f5 ff ff       	call   801a03 <fd_lookup>
  8024ac:	83 c4 10             	add    $0x10,%esp
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	78 18                	js     8024cb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024b3:	83 ec 0c             	sub    $0xc,%esp
  8024b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b9:	e8 ba f4 ff ff       	call   801978 <fd2data>
	return _pipeisclosed(fd, p);
  8024be:	89 c2                	mov    %eax,%edx
  8024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c3:	e8 0c fd ff ff       	call   8021d4 <_pipeisclosed>
  8024c8:	83 c4 10             	add    $0x10,%esp
}
  8024cb:	c9                   	leave  
  8024cc:	c3                   	ret    
  8024cd:	00 00                	add    %al,(%eax)
	...

008024d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024e0:	68 65 2f 80 00       	push   $0x802f65
  8024e5:	ff 75 0c             	pushl  0xc(%ebp)
  8024e8:	e8 fd ec ff ff       	call   8011ea <strcpy>
	return 0;
}
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f2:	c9                   	leave  
  8024f3:	c3                   	ret    

008024f4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	57                   	push   %edi
  8024f8:	56                   	push   %esi
  8024f9:	53                   	push   %ebx
  8024fa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802500:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802504:	74 45                	je     80254b <devcons_write+0x57>
  802506:	b8 00 00 00 00       	mov    $0x0,%eax
  80250b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802510:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802516:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802519:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80251b:	83 fb 7f             	cmp    $0x7f,%ebx
  80251e:	76 05                	jbe    802525 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802520:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802525:	83 ec 04             	sub    $0x4,%esp
  802528:	53                   	push   %ebx
  802529:	03 45 0c             	add    0xc(%ebp),%eax
  80252c:	50                   	push   %eax
  80252d:	57                   	push   %edi
  80252e:	e8 78 ee ff ff       	call   8013ab <memmove>
		sys_cputs(buf, m);
  802533:	83 c4 08             	add    $0x8,%esp
  802536:	53                   	push   %ebx
  802537:	57                   	push   %edi
  802538:	e8 78 f0 ff ff       	call   8015b5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80253d:	01 de                	add    %ebx,%esi
  80253f:	89 f0                	mov    %esi,%eax
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	3b 75 10             	cmp    0x10(%ebp),%esi
  802547:	72 cd                	jb     802516 <devcons_write+0x22>
  802549:	eb 05                	jmp    802550 <devcons_write+0x5c>
  80254b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802550:	89 f0                	mov    %esi,%eax
  802552:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802555:	5b                   	pop    %ebx
  802556:	5e                   	pop    %esi
  802557:	5f                   	pop    %edi
  802558:	c9                   	leave  
  802559:	c3                   	ret    

0080255a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802560:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802564:	75 07                	jne    80256d <devcons_read+0x13>
  802566:	eb 25                	jmp    80258d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802568:	e8 d8 f0 ff ff       	call   801645 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80256d:	e8 69 f0 ff ff       	call   8015db <sys_cgetc>
  802572:	85 c0                	test   %eax,%eax
  802574:	74 f2                	je     802568 <devcons_read+0xe>
  802576:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802578:	85 c0                	test   %eax,%eax
  80257a:	78 1d                	js     802599 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80257c:	83 f8 04             	cmp    $0x4,%eax
  80257f:	74 13                	je     802594 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802581:	8b 45 0c             	mov    0xc(%ebp),%eax
  802584:	88 10                	mov    %dl,(%eax)
	return 1;
  802586:	b8 01 00 00 00       	mov    $0x1,%eax
  80258b:	eb 0c                	jmp    802599 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80258d:	b8 00 00 00 00       	mov    $0x0,%eax
  802592:	eb 05                	jmp    802599 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802594:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802599:	c9                   	leave  
  80259a:	c3                   	ret    

0080259b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025a7:	6a 01                	push   $0x1
  8025a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ac:	50                   	push   %eax
  8025ad:	e8 03 f0 ff ff       	call   8015b5 <sys_cputs>
  8025b2:	83 c4 10             	add    $0x10,%esp
}
  8025b5:	c9                   	leave  
  8025b6:	c3                   	ret    

008025b7 <getchar>:

int
getchar(void)
{
  8025b7:	55                   	push   %ebp
  8025b8:	89 e5                	mov    %esp,%ebp
  8025ba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025bd:	6a 01                	push   $0x1
  8025bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c2:	50                   	push   %eax
  8025c3:	6a 00                	push   $0x0
  8025c5:	e8 ba f6 ff ff       	call   801c84 <read>
	if (r < 0)
  8025ca:	83 c4 10             	add    $0x10,%esp
  8025cd:	85 c0                	test   %eax,%eax
  8025cf:	78 0f                	js     8025e0 <getchar+0x29>
		return r;
	if (r < 1)
  8025d1:	85 c0                	test   %eax,%eax
  8025d3:	7e 06                	jle    8025db <getchar+0x24>
		return -E_EOF;
	return c;
  8025d5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025d9:	eb 05                	jmp    8025e0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025db:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025e0:	c9                   	leave  
  8025e1:	c3                   	ret    

008025e2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025eb:	50                   	push   %eax
  8025ec:	ff 75 08             	pushl  0x8(%ebp)
  8025ef:	e8 0f f4 ff ff       	call   801a03 <fd_lookup>
  8025f4:	83 c4 10             	add    $0x10,%esp
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	78 11                	js     80260c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fe:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  802604:	39 10                	cmp    %edx,(%eax)
  802606:	0f 94 c0             	sete   %al
  802609:	0f b6 c0             	movzbl %al,%eax
}
  80260c:	c9                   	leave  
  80260d:	c3                   	ret    

0080260e <opencons>:

int
opencons(void)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802617:	50                   	push   %eax
  802618:	e8 73 f3 ff ff       	call   801990 <fd_alloc>
  80261d:	83 c4 10             	add    $0x10,%esp
  802620:	85 c0                	test   %eax,%eax
  802622:	78 3a                	js     80265e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802624:	83 ec 04             	sub    $0x4,%esp
  802627:	68 07 04 00 00       	push   $0x407
  80262c:	ff 75 f4             	pushl  -0xc(%ebp)
  80262f:	6a 00                	push   $0x0
  802631:	e8 36 f0 ff ff       	call   80166c <sys_page_alloc>
  802636:	83 c4 10             	add    $0x10,%esp
  802639:	85 c0                	test   %eax,%eax
  80263b:	78 21                	js     80265e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80263d:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  802643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802646:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802652:	83 ec 0c             	sub    $0xc,%esp
  802655:	50                   	push   %eax
  802656:	e8 0d f3 ff ff       	call   801968 <fd2num>
  80265b:	83 c4 10             	add    $0x10,%esp
}
  80265e:	c9                   	leave  
  80265f:	c3                   	ret    

00802660 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	57                   	push   %edi
  802664:	56                   	push   %esi
  802665:	83 ec 10             	sub    $0x10,%esp
  802668:	8b 7d 08             	mov    0x8(%ebp),%edi
  80266b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80266e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802671:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802674:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802677:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80267a:	85 c0                	test   %eax,%eax
  80267c:	75 2e                	jne    8026ac <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80267e:	39 f1                	cmp    %esi,%ecx
  802680:	77 5a                	ja     8026dc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802682:	85 c9                	test   %ecx,%ecx
  802684:	75 0b                	jne    802691 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802686:	b8 01 00 00 00       	mov    $0x1,%eax
  80268b:	31 d2                	xor    %edx,%edx
  80268d:	f7 f1                	div    %ecx
  80268f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802691:	31 d2                	xor    %edx,%edx
  802693:	89 f0                	mov    %esi,%eax
  802695:	f7 f1                	div    %ecx
  802697:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802699:	89 f8                	mov    %edi,%eax
  80269b:	f7 f1                	div    %ecx
  80269d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80269f:	89 f8                	mov    %edi,%eax
  8026a1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026a3:	83 c4 10             	add    $0x10,%esp
  8026a6:	5e                   	pop    %esi
  8026a7:	5f                   	pop    %edi
  8026a8:	c9                   	leave  
  8026a9:	c3                   	ret    
  8026aa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026ac:	39 f0                	cmp    %esi,%eax
  8026ae:	77 1c                	ja     8026cc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026b0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8026b3:	83 f7 1f             	xor    $0x1f,%edi
  8026b6:	75 3c                	jne    8026f4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026b8:	39 f0                	cmp    %esi,%eax
  8026ba:	0f 82 90 00 00 00    	jb     802750 <__udivdi3+0xf0>
  8026c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026c3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8026c6:	0f 86 84 00 00 00    	jbe    802750 <__udivdi3+0xf0>
  8026cc:	31 f6                	xor    %esi,%esi
  8026ce:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026d0:	89 f8                	mov    %edi,%eax
  8026d2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026d4:	83 c4 10             	add    $0x10,%esp
  8026d7:	5e                   	pop    %esi
  8026d8:	5f                   	pop    %edi
  8026d9:	c9                   	leave  
  8026da:	c3                   	ret    
  8026db:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026dc:	89 f2                	mov    %esi,%edx
  8026de:	89 f8                	mov    %edi,%eax
  8026e0:	f7 f1                	div    %ecx
  8026e2:	89 c7                	mov    %eax,%edi
  8026e4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026e6:	89 f8                	mov    %edi,%eax
  8026e8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026ea:	83 c4 10             	add    $0x10,%esp
  8026ed:	5e                   	pop    %esi
  8026ee:	5f                   	pop    %edi
  8026ef:	c9                   	leave  
  8026f0:	c3                   	ret    
  8026f1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026f4:	89 f9                	mov    %edi,%ecx
  8026f6:	d3 e0                	shl    %cl,%eax
  8026f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8026fb:	b8 20 00 00 00       	mov    $0x20,%eax
  802700:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802702:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802705:	88 c1                	mov    %al,%cl
  802707:	d3 ea                	shr    %cl,%edx
  802709:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80270c:	09 ca                	or     %ecx,%edx
  80270e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802711:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802714:	89 f9                	mov    %edi,%ecx
  802716:	d3 e2                	shl    %cl,%edx
  802718:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80271b:	89 f2                	mov    %esi,%edx
  80271d:	88 c1                	mov    %al,%cl
  80271f:	d3 ea                	shr    %cl,%edx
  802721:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802724:	89 f2                	mov    %esi,%edx
  802726:	89 f9                	mov    %edi,%ecx
  802728:	d3 e2                	shl    %cl,%edx
  80272a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80272d:	88 c1                	mov    %al,%cl
  80272f:	d3 ee                	shr    %cl,%esi
  802731:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802733:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802736:	89 f0                	mov    %esi,%eax
  802738:	89 ca                	mov    %ecx,%edx
  80273a:	f7 75 ec             	divl   -0x14(%ebp)
  80273d:	89 d1                	mov    %edx,%ecx
  80273f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802741:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802744:	39 d1                	cmp    %edx,%ecx
  802746:	72 28                	jb     802770 <__udivdi3+0x110>
  802748:	74 1a                	je     802764 <__udivdi3+0x104>
  80274a:	89 f7                	mov    %esi,%edi
  80274c:	31 f6                	xor    %esi,%esi
  80274e:	eb 80                	jmp    8026d0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802750:	31 f6                	xor    %esi,%esi
  802752:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802757:	89 f8                	mov    %edi,%eax
  802759:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80275b:	83 c4 10             	add    $0x10,%esp
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	c9                   	leave  
  802761:	c3                   	ret    
  802762:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802764:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802767:	89 f9                	mov    %edi,%ecx
  802769:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80276b:	39 c2                	cmp    %eax,%edx
  80276d:	73 db                	jae    80274a <__udivdi3+0xea>
  80276f:	90                   	nop
		{
		  q0--;
  802770:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802773:	31 f6                	xor    %esi,%esi
  802775:	e9 56 ff ff ff       	jmp    8026d0 <__udivdi3+0x70>
	...

0080277c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80277c:	55                   	push   %ebp
  80277d:	89 e5                	mov    %esp,%ebp
  80277f:	57                   	push   %edi
  802780:	56                   	push   %esi
  802781:	83 ec 20             	sub    $0x20,%esp
  802784:	8b 45 08             	mov    0x8(%ebp),%eax
  802787:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80278a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80278d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802790:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802793:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802796:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802799:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80279b:	85 ff                	test   %edi,%edi
  80279d:	75 15                	jne    8027b4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80279f:	39 f1                	cmp    %esi,%ecx
  8027a1:	0f 86 99 00 00 00    	jbe    802840 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8027a9:	89 d0                	mov    %edx,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027ad:	83 c4 20             	add    $0x20,%esp
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	c9                   	leave  
  8027b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027b4:	39 f7                	cmp    %esi,%edi
  8027b6:	0f 87 a4 00 00 00    	ja     802860 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027bc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8027bf:	83 f0 1f             	xor    $0x1f,%eax
  8027c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027c5:	0f 84 a1 00 00 00    	je     80286c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027cb:	89 f8                	mov    %edi,%eax
  8027cd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027d0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027d2:	bf 20 00 00 00       	mov    $0x20,%edi
  8027d7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8027da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027dd:	89 f9                	mov    %edi,%ecx
  8027df:	d3 ea                	shr    %cl,%edx
  8027e1:	09 c2                	or     %eax,%edx
  8027e3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8027e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027ec:	d3 e0                	shl    %cl,%eax
  8027ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027f1:	89 f2                	mov    %esi,%edx
  8027f3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8027f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027f8:	d3 e0                	shl    %cl,%eax
  8027fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802800:	89 f9                	mov    %edi,%ecx
  802802:	d3 e8                	shr    %cl,%eax
  802804:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802806:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802808:	89 f2                	mov    %esi,%edx
  80280a:	f7 75 f0             	divl   -0x10(%ebp)
  80280d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80280f:	f7 65 f4             	mull   -0xc(%ebp)
  802812:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802815:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802817:	39 d6                	cmp    %edx,%esi
  802819:	72 71                	jb     80288c <__umoddi3+0x110>
  80281b:	74 7f                	je     80289c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80281d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802820:	29 c8                	sub    %ecx,%eax
  802822:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802824:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802827:	d3 e8                	shr    %cl,%eax
  802829:	89 f2                	mov    %esi,%edx
  80282b:	89 f9                	mov    %edi,%ecx
  80282d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80282f:	09 d0                	or     %edx,%eax
  802831:	89 f2                	mov    %esi,%edx
  802833:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802836:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802838:	83 c4 20             	add    $0x20,%esp
  80283b:	5e                   	pop    %esi
  80283c:	5f                   	pop    %edi
  80283d:	c9                   	leave  
  80283e:	c3                   	ret    
  80283f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802840:	85 c9                	test   %ecx,%ecx
  802842:	75 0b                	jne    80284f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802844:	b8 01 00 00 00       	mov    $0x1,%eax
  802849:	31 d2                	xor    %edx,%edx
  80284b:	f7 f1                	div    %ecx
  80284d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80284f:	89 f0                	mov    %esi,%eax
  802851:	31 d2                	xor    %edx,%edx
  802853:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802858:	f7 f1                	div    %ecx
  80285a:	e9 4a ff ff ff       	jmp    8027a9 <__umoddi3+0x2d>
  80285f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802860:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802862:	83 c4 20             	add    $0x20,%esp
  802865:	5e                   	pop    %esi
  802866:	5f                   	pop    %edi
  802867:	c9                   	leave  
  802868:	c3                   	ret    
  802869:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80286c:	39 f7                	cmp    %esi,%edi
  80286e:	72 05                	jb     802875 <__umoddi3+0xf9>
  802870:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802873:	77 0c                	ja     802881 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802875:	89 f2                	mov    %esi,%edx
  802877:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80287a:	29 c8                	sub    %ecx,%eax
  80287c:	19 fa                	sbb    %edi,%edx
  80287e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802884:	83 c4 20             	add    $0x20,%esp
  802887:	5e                   	pop    %esi
  802888:	5f                   	pop    %edi
  802889:	c9                   	leave  
  80288a:	c3                   	ret    
  80288b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80288c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80288f:	89 c1                	mov    %eax,%ecx
  802891:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802894:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802897:	eb 84                	jmp    80281d <__umoddi3+0xa1>
  802899:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80289c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80289f:	72 eb                	jb     80288c <__umoddi3+0x110>
  8028a1:	89 f2                	mov    %esi,%edx
  8028a3:	e9 75 ff ff ff       	jmp    80281d <__umoddi3+0xa1>
