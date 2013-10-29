
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
  8000c1:	68 00 29 80 00       	push   $0x802900
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
  8000ed:	68 17 29 80 00       	push   $0x802917
  8000f2:	6a 3a                	push   $0x3a
  8000f4:	68 27 29 80 00       	push   $0x802927
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
  80011f:	68 30 29 80 00       	push   $0x802930
  800124:	68 3d 29 80 00       	push   $0x80293d
  800129:	6a 43                	push   $0x43
  80012b:	68 27 29 80 00       	push   $0x802927
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
  8001d4:	68 30 29 80 00       	push   $0x802930
  8001d9:	68 3d 29 80 00       	push   $0x80293d
  8001de:	6a 5c                	push   $0x5c
  8001e0:	68 27 29 80 00       	push   $0x802927
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
  800292:	68 54 29 80 00       	push   $0x802954
  800297:	6a 19                	push   $0x19
  800299:	68 12 2a 80 00       	push   $0x802a12
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
  8002bb:	68 84 29 80 00       	push   $0x802984
  8002c0:	6a 1d                	push   $0x1d
  8002c2:	68 12 2a 80 00       	push   $0x802a12
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
  8002e7:	68 a8 29 80 00       	push   $0x8029a8
  8002ec:	6a 27                	push   $0x27
  8002ee:	68 12 2a 80 00       	push   $0x802a12
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
  80030f:	68 d0 29 80 00       	push   $0x8029d0
  800314:	6a 2a                	push   $0x2a
  800316:	68 12 2a 80 00       	push   $0x802a12
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
  800344:	68 f0 29 80 00       	push   $0x8029f0
  800349:	6a 09                	push   $0x9
  80034b:	68 12 2a 80 00       	push   $0x802a12
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
  8003be:	68 1a 2a 80 00       	push   $0x802a1a
  8003c3:	6a 0e                	push   $0xe
  8003c5:	68 37 2a 80 00       	push   $0x802a37
  8003ca:	e8 8d 07 00 00       	call   800b5c <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8003cf:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8003d6:	76 14                	jbe    8003ec <check_super+0x44>
		panic("file system is too large");
  8003d8:	83 ec 04             	sub    $0x4,%esp
  8003db:	68 3f 2a 80 00       	push   $0x802a3f
  8003e0:	6a 11                	push   $0x11
  8003e2:	68 37 2a 80 00       	push   $0x802a37
  8003e7:	e8 70 07 00 00       	call   800b5c <_panic>

	cprintf("superblock is good\n");
  8003ec:	83 ec 0c             	sub    $0xc,%esp
  8003ef:	68 58 2a 80 00       	push   $0x802a58
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
  800569:	68 6c 2a 80 00       	push   $0x802a6c
  80056e:	68 3d 29 80 00       	push   $0x80293d
  800573:	6a 78                	push   $0x78
  800575:	68 37 2a 80 00       	push   $0x802a37
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
  800783:	e8 e0 19 00 00       	call   802168 <pageref>
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
  80081e:	e8 45 19 00 00       	call   802168 <pageref>
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
  800a14:	68 8c 2a 80 00       	push   $0x802a8c
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
  800a6e:	68 bc 2a 80 00       	push   $0x802abc
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
  800a8a:	e8 59 0e 00 00       	call   8018e8 <ipc_send>
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
  800aad:	c7 05 40 70 80 00 df 	movl   $0x802adf,0x807040
  800ab4:	2a 80 00 
	cprintf("FS is running\n");
  800ab7:	68 e2 2a 80 00       	push   $0x802ae2
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
  800acd:	c7 04 24 f1 2a 80 00 	movl   $0x802af1,(%esp)
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
  800b46:	e8 57 10 00 00       	call   801ba2 <close_all>
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
  800b7a:	68 0c 2b 80 00       	push   $0x802b0c
  800b7f:	e8 b0 00 00 00       	call   800c34 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b84:	83 c4 18             	add    $0x18,%esp
  800b87:	56                   	push   %esi
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	e8 53 00 00 00       	call   800be3 <vcprintf>
	cprintf("\n");
  800b90:	c7 04 24 aa 2f 80 00 	movl   $0x802faa,(%esp)
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
  800c9c:	e8 0f 1a 00 00       	call   8026b0 <__udivdi3>
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
  800cd8:	e8 ef 1a 00 00       	call   8027cc <__umoddi3>
  800cdd:	83 c4 14             	add    $0x14,%esp
  800ce0:	0f be 80 2f 2b 80 00 	movsbl 0x802b2f(%eax),%eax
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
  800e24:	ff 24 85 80 2c 80 00 	jmp    *0x802c80(,%eax,4)
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
  800ed0:	8b 04 85 e0 2d 80 00 	mov    0x802de0(,%eax,4),%eax
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	75 1a                	jne    800ef5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800edb:	52                   	push   %edx
  800edc:	68 47 2b 80 00       	push   $0x802b47
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
  800ef6:	68 4f 29 80 00       	push   $0x80294f
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
  800f2c:	c7 45 d0 40 2b 80 00 	movl   $0x802b40,-0x30(%ebp)
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
  80159a:	68 3f 2e 80 00       	push   $0x802e3f
  80159f:	6a 42                	push   $0x42
  8015a1:	68 5c 2e 80 00       	push   $0x802e5c
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
  8017d4:	68 6a 2e 80 00       	push   $0x802e6a
  8017d9:	6a 24                	push   $0x24
  8017db:	68 85 2e 80 00       	push   $0x802e85
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
  8017fc:	68 94 2e 80 00       	push   $0x802e94
  801801:	6a 2a                	push   $0x2a
  801803:	68 85 2e 80 00       	push   $0x802e85
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
  801843:	57                   	push   %edi
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
  801846:	83 ec 0c             	sub    $0xc,%esp
  801849:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80184f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	57                   	push   %edi
  801855:	68 bb 2e 80 00       	push   $0x802ebb
  80185a:	e8 d5 f3 ff ff       	call   800c34 <cprintf>
	int r;
	if (pg != NULL) {
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 db                	test   %ebx,%ebx
  801864:	74 28                	je     80188e <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	68 cb 2e 80 00       	push   $0x802ecb
  80186e:	e8 c1 f3 ff ff       	call   800c34 <cprintf>
		r = sys_ipc_recv(pg);
  801873:	89 1c 24             	mov    %ebx,(%esp)
  801876:	e8 ec fe ff ff       	call   801767 <sys_ipc_recv>
  80187b:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  80187d:	c7 04 24 d2 2e 80 00 	movl   $0x802ed2,(%esp)
  801884:	e8 ab f3 ff ff       	call   800c34 <cprintf>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	eb 12                	jmp    8018a0 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	68 00 00 c0 ee       	push   $0xeec00000
  801896:	e8 cc fe ff ff       	call   801767 <sys_ipc_recv>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8018a0:	85 db                	test   %ebx,%ebx
  8018a2:	75 26                	jne    8018ca <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8018a4:	85 ff                	test   %edi,%edi
  8018a6:	74 0a                	je     8018b2 <ipc_recv+0x72>
  8018a8:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018ad:	8b 40 74             	mov    0x74(%eax),%eax
  8018b0:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8018b2:	85 f6                	test   %esi,%esi
  8018b4:	74 0a                	je     8018c0 <ipc_recv+0x80>
  8018b6:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018bb:	8b 40 78             	mov    0x78(%eax),%eax
  8018be:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  8018c0:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018c5:	8b 58 70             	mov    0x70(%eax),%ebx
  8018c8:	eb 14                	jmp    8018de <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8018ca:	85 ff                	test   %edi,%edi
  8018cc:	74 06                	je     8018d4 <ipc_recv+0x94>
  8018ce:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  8018d4:	85 f6                	test   %esi,%esi
  8018d6:	74 06                	je     8018de <ipc_recv+0x9e>
  8018d8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  8018de:	89 d8                	mov    %ebx,%eax
  8018e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f7:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8018fa:	85 db                	test   %ebx,%ebx
  8018fc:	75 25                	jne    801923 <ipc_send+0x3b>
  8018fe:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801903:	eb 1e                	jmp    801923 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801905:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801908:	75 07                	jne    801911 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80190a:	e8 36 fd ff ff       	call   801645 <sys_yield>
  80190f:	eb 12                	jmp    801923 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801911:	50                   	push   %eax
  801912:	68 d8 2e 80 00       	push   $0x802ed8
  801917:	6a 45                	push   $0x45
  801919:	68 eb 2e 80 00       	push   $0x802eeb
  80191e:	e8 39 f2 ff ff       	call   800b5c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	57                   	push   %edi
  801926:	ff 75 08             	pushl  0x8(%ebp)
  801929:	e8 14 fe ff ff       	call   801742 <sys_ipc_try_send>
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	85 c0                	test   %eax,%eax
  801933:	75 d0                	jne    801905 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801935:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5f                   	pop    %edi
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	53                   	push   %ebx
  801941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801944:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80194a:	74 22                	je     80196e <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80194c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801951:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801958:	89 c2                	mov    %eax,%edx
  80195a:	c1 e2 07             	shl    $0x7,%edx
  80195d:	29 ca                	sub    %ecx,%edx
  80195f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801965:	8b 52 50             	mov    0x50(%edx),%edx
  801968:	39 da                	cmp    %ebx,%edx
  80196a:	75 1d                	jne    801989 <ipc_find_env+0x4c>
  80196c:	eb 05                	jmp    801973 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801973:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80197a:	c1 e0 07             	shl    $0x7,%eax
  80197d:	29 d0                	sub    %edx,%eax
  80197f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801984:	8b 40 40             	mov    0x40(%eax),%eax
  801987:	eb 0c                	jmp    801995 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801989:	40                   	inc    %eax
  80198a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80198f:	75 c0                	jne    801951 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801991:	66 b8 00 00          	mov    $0x0,%ax
}
  801995:	5b                   	pop    %ebx
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	05 00 00 00 30       	add    $0x30000000,%eax
  8019a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 e5 ff ff ff       	call   801998 <fd2num>
  8019b3:	83 c4 04             	add    $0x4,%esp
  8019b6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8019bb:	c1 e0 0c             	shl    $0xc,%eax
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8019c7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8019cc:	a8 01                	test   $0x1,%al
  8019ce:	74 34                	je     801a04 <fd_alloc+0x44>
  8019d0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8019d5:	a8 01                	test   $0x1,%al
  8019d7:	74 32                	je     801a0b <fd_alloc+0x4b>
  8019d9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8019de:	89 c1                	mov    %eax,%ecx
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	c1 ea 16             	shr    $0x16,%edx
  8019e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019ec:	f6 c2 01             	test   $0x1,%dl
  8019ef:	74 1f                	je     801a10 <fd_alloc+0x50>
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	c1 ea 0c             	shr    $0xc,%edx
  8019f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019fd:	f6 c2 01             	test   $0x1,%dl
  801a00:	75 17                	jne    801a19 <fd_alloc+0x59>
  801a02:	eb 0c                	jmp    801a10 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801a04:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801a09:	eb 05                	jmp    801a10 <fd_alloc+0x50>
  801a0b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801a10:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801a12:	b8 00 00 00 00       	mov    $0x0,%eax
  801a17:	eb 17                	jmp    801a30 <fd_alloc+0x70>
  801a19:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a1e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a23:	75 b9                	jne    8019de <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801a25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801a2b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801a30:	5b                   	pop    %ebx
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801a39:	83 f8 1f             	cmp    $0x1f,%eax
  801a3c:	77 36                	ja     801a74 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801a3e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801a43:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	c1 ea 16             	shr    $0x16,%edx
  801a4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a52:	f6 c2 01             	test   $0x1,%dl
  801a55:	74 24                	je     801a7b <fd_lookup+0x48>
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	c1 ea 0c             	shr    $0xc,%edx
  801a5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a63:	f6 c2 01             	test   $0x1,%dl
  801a66:	74 1a                	je     801a82 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6b:	89 02                	mov    %eax,(%edx)
	return 0;
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	eb 13                	jmp    801a87 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a79:	eb 0c                	jmp    801a87 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a80:	eb 05                	jmp    801a87 <fd_lookup+0x54>
  801a82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 04             	sub    $0x4,%esp
  801a90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801a96:	39 0d 44 70 80 00    	cmp    %ecx,0x807044
  801a9c:	74 0d                	je     801aab <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa3:	eb 14                	jmp    801ab9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801aa5:	39 0a                	cmp    %ecx,(%edx)
  801aa7:	75 10                	jne    801ab9 <dev_lookup+0x30>
  801aa9:	eb 05                	jmp    801ab0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801aab:	ba 44 70 80 00       	mov    $0x807044,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801ab0:	89 13                	mov    %edx,(%ebx)
			return 0;
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab7:	eb 31                	jmp    801aea <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ab9:	40                   	inc    %eax
  801aba:	8b 14 85 78 2f 80 00 	mov    0x802f78(,%eax,4),%edx
  801ac1:	85 d2                	test   %edx,%edx
  801ac3:	75 e0                	jne    801aa5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ac5:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801aca:	8b 40 48             	mov    0x48(%eax),%eax
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	51                   	push   %ecx
  801ad1:	50                   	push   %eax
  801ad2:	68 f8 2e 80 00       	push   $0x802ef8
  801ad7:	e8 58 f1 ff ff       	call   800c34 <cprintf>
	*dev = 0;
  801adc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 20             	sub    $0x20,%esp
  801af7:	8b 75 08             	mov    0x8(%ebp),%esi
  801afa:	8a 45 0c             	mov    0xc(%ebp),%al
  801afd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b00:	56                   	push   %esi
  801b01:	e8 92 fe ff ff       	call   801998 <fd2num>
  801b06:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b09:	89 14 24             	mov    %edx,(%esp)
  801b0c:	50                   	push   %eax
  801b0d:	e8 21 ff ff ff       	call   801a33 <fd_lookup>
  801b12:	89 c3                	mov    %eax,%ebx
  801b14:	83 c4 08             	add    $0x8,%esp
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 05                	js     801b20 <fd_close+0x31>
	    || fd != fd2)
  801b1b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b1e:	74 0d                	je     801b2d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801b20:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801b24:	75 48                	jne    801b6e <fd_close+0x7f>
  801b26:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b2b:	eb 41                	jmp    801b6e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b2d:	83 ec 08             	sub    $0x8,%esp
  801b30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b33:	50                   	push   %eax
  801b34:	ff 36                	pushl  (%esi)
  801b36:	e8 4e ff ff ff       	call   801a89 <dev_lookup>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 1c                	js     801b60 <fd_close+0x71>
		if (dev->dev_close)
  801b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b47:	8b 40 10             	mov    0x10(%eax),%eax
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	74 0d                	je     801b5b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	56                   	push   %esi
  801b52:	ff d0                	call   *%eax
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	eb 05                	jmp    801b60 <fd_close+0x71>
		else
			r = 0;
  801b5b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	56                   	push   %esi
  801b64:	6a 00                	push   $0x0
  801b66:	e8 4b fb ff ff       	call   8016b6 <sys_page_unmap>
	return r;
  801b6b:	83 c4 10             	add    $0x10,%esp
}
  801b6e:	89 d8                	mov    %ebx,%eax
  801b70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b80:	50                   	push   %eax
  801b81:	ff 75 08             	pushl  0x8(%ebp)
  801b84:	e8 aa fe ff ff       	call   801a33 <fd_lookup>
  801b89:	83 c4 08             	add    $0x8,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 10                	js     801ba0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801b90:	83 ec 08             	sub    $0x8,%esp
  801b93:	6a 01                	push   $0x1
  801b95:	ff 75 f4             	pushl  -0xc(%ebp)
  801b98:	e8 52 ff ff ff       	call   801aef <fd_close>
  801b9d:	83 c4 10             	add    $0x10,%esp
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <close_all>:

void
close_all(void)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	53                   	push   %ebx
  801bb2:	e8 c0 ff ff ff       	call   801b77 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bb7:	43                   	inc    %ebx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	83 fb 20             	cmp    $0x20,%ebx
  801bbe:	75 ee                	jne    801bae <close_all+0xc>
		close(i);
}
  801bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	57                   	push   %edi
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 2c             	sub    $0x2c,%esp
  801bce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bd1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bd4:	50                   	push   %eax
  801bd5:	ff 75 08             	pushl  0x8(%ebp)
  801bd8:	e8 56 fe ff ff       	call   801a33 <fd_lookup>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 08             	add    $0x8,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	0f 88 c0 00 00 00    	js     801caa <dup+0xe5>
		return r;
	close(newfdnum);
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	57                   	push   %edi
  801bee:	e8 84 ff ff ff       	call   801b77 <close>

	newfd = INDEX2FD(newfdnum);
  801bf3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bf9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bfc:	83 c4 04             	add    $0x4,%esp
  801bff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c02:	e8 a1 fd ff ff       	call   8019a8 <fd2data>
  801c07:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c09:	89 34 24             	mov    %esi,(%esp)
  801c0c:	e8 97 fd ff ff       	call   8019a8 <fd2data>
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801c17:	89 d8                	mov    %ebx,%eax
  801c19:	c1 e8 16             	shr    $0x16,%eax
  801c1c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c23:	a8 01                	test   $0x1,%al
  801c25:	74 37                	je     801c5e <dup+0x99>
  801c27:	89 d8                	mov    %ebx,%eax
  801c29:	c1 e8 0c             	shr    $0xc,%eax
  801c2c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c33:	f6 c2 01             	test   $0x1,%dl
  801c36:	74 26                	je     801c5e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	25 07 0e 00 00       	and    $0xe07,%eax
  801c47:	50                   	push   %eax
  801c48:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c4b:	6a 00                	push   $0x0
  801c4d:	53                   	push   %ebx
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 3b fa ff ff       	call   801690 <sys_page_map>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	83 c4 20             	add    $0x20,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 2d                	js     801c8b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c61:	89 c2                	mov    %eax,%edx
  801c63:	c1 ea 0c             	shr    $0xc,%edx
  801c66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c76:	52                   	push   %edx
  801c77:	56                   	push   %esi
  801c78:	6a 00                	push   $0x0
  801c7a:	50                   	push   %eax
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 0e fa ff ff       	call   801690 <sys_page_map>
  801c82:	89 c3                	mov    %eax,%ebx
  801c84:	83 c4 20             	add    $0x20,%esp
  801c87:	85 c0                	test   %eax,%eax
  801c89:	79 1d                	jns    801ca8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c8b:	83 ec 08             	sub    $0x8,%esp
  801c8e:	56                   	push   %esi
  801c8f:	6a 00                	push   $0x0
  801c91:	e8 20 fa ff ff       	call   8016b6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c96:	83 c4 08             	add    $0x8,%esp
  801c99:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 13 fa ff ff       	call   8016b6 <sys_page_unmap>
	return r;
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	eb 02                	jmp    801caa <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801ca8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801caa:	89 d8                	mov    %ebx,%eax
  801cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 14             	sub    $0x14,%esp
  801cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc1:	50                   	push   %eax
  801cc2:	53                   	push   %ebx
  801cc3:	e8 6b fd ff ff       	call   801a33 <fd_lookup>
  801cc8:	83 c4 08             	add    $0x8,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 67                	js     801d36 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd9:	ff 30                	pushl  (%eax)
  801cdb:	e8 a9 fd ff ff       	call   801a89 <dev_lookup>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 4f                	js     801d36 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cea:	8b 50 08             	mov    0x8(%eax),%edx
  801ced:	83 e2 03             	and    $0x3,%edx
  801cf0:	83 fa 01             	cmp    $0x1,%edx
  801cf3:	75 21                	jne    801d16 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801cf5:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801cfa:	8b 40 48             	mov    0x48(%eax),%eax
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	53                   	push   %ebx
  801d01:	50                   	push   %eax
  801d02:	68 3c 2f 80 00       	push   $0x802f3c
  801d07:	e8 28 ef ff ff       	call   800c34 <cprintf>
		return -E_INVAL;
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d14:	eb 20                	jmp    801d36 <read+0x82>
	}
	if (!dev->dev_read)
  801d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d19:	8b 52 08             	mov    0x8(%edx),%edx
  801d1c:	85 d2                	test   %edx,%edx
  801d1e:	74 11                	je     801d31 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801d20:	83 ec 04             	sub    $0x4,%esp
  801d23:	ff 75 10             	pushl  0x10(%ebp)
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	50                   	push   %eax
  801d2a:	ff d2                	call   *%edx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	eb 05                	jmp    801d36 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801d31:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801d36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	57                   	push   %edi
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d47:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d4a:	85 f6                	test   %esi,%esi
  801d4c:	74 31                	je     801d7f <readn+0x44>
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d53:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d58:	83 ec 04             	sub    $0x4,%esp
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	29 c2                	sub    %eax,%edx
  801d5f:	52                   	push   %edx
  801d60:	03 45 0c             	add    0xc(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	57                   	push   %edi
  801d65:	e8 4a ff ff ff       	call   801cb4 <read>
		if (m < 0)
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 17                	js     801d88 <readn+0x4d>
			return m;
		if (m == 0)
  801d71:	85 c0                	test   %eax,%eax
  801d73:	74 11                	je     801d86 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d75:	01 c3                	add    %eax,%ebx
  801d77:	89 d8                	mov    %ebx,%eax
  801d79:	39 f3                	cmp    %esi,%ebx
  801d7b:	72 db                	jb     801d58 <readn+0x1d>
  801d7d:	eb 09                	jmp    801d88 <readn+0x4d>
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d84:	eb 02                	jmp    801d88 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801d86:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 14             	sub    $0x14,%esp
  801d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d9d:	50                   	push   %eax
  801d9e:	53                   	push   %ebx
  801d9f:	e8 8f fc ff ff       	call   801a33 <fd_lookup>
  801da4:	83 c4 08             	add    $0x8,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 62                	js     801e0d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db1:	50                   	push   %eax
  801db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db5:	ff 30                	pushl  (%eax)
  801db7:	e8 cd fc ff ff       	call   801a89 <dev_lookup>
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 4a                	js     801e0d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801dca:	75 21                	jne    801ded <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801dcc:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801dd1:	8b 40 48             	mov    0x48(%eax),%eax
  801dd4:	83 ec 04             	sub    $0x4,%esp
  801dd7:	53                   	push   %ebx
  801dd8:	50                   	push   %eax
  801dd9:	68 58 2f 80 00       	push   $0x802f58
  801dde:	e8 51 ee ff ff       	call   800c34 <cprintf>
		return -E_INVAL;
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801deb:	eb 20                	jmp    801e0d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df0:	8b 52 0c             	mov    0xc(%edx),%edx
  801df3:	85 d2                	test   %edx,%edx
  801df5:	74 11                	je     801e08 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	ff 75 10             	pushl  0x10(%ebp)
  801dfd:	ff 75 0c             	pushl  0xc(%ebp)
  801e00:	50                   	push   %eax
  801e01:	ff d2                	call   *%edx
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	eb 05                	jmp    801e0d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801e08:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801e0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <seek>:

int
seek(int fdnum, off_t offset)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e18:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	ff 75 08             	pushl  0x8(%ebp)
  801e1f:	e8 0f fc ff ff       	call   801a33 <fd_lookup>
  801e24:	83 c4 08             	add    $0x8,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 0e                	js     801e39 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801e2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e31:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 14             	sub    $0x14,%esp
  801e42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e48:	50                   	push   %eax
  801e49:	53                   	push   %ebx
  801e4a:	e8 e4 fb ff ff       	call   801a33 <fd_lookup>
  801e4f:	83 c4 08             	add    $0x8,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 5f                	js     801eb5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e60:	ff 30                	pushl  (%eax)
  801e62:	e8 22 fc ff ff       	call   801a89 <dev_lookup>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 47                	js     801eb5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e71:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e75:	75 21                	jne    801e98 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e77:	a1 0c 80 80 00       	mov    0x80800c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e7c:	8b 40 48             	mov    0x48(%eax),%eax
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	53                   	push   %ebx
  801e83:	50                   	push   %eax
  801e84:	68 18 2f 80 00       	push   $0x802f18
  801e89:	e8 a6 ed ff ff       	call   800c34 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e96:	eb 1d                	jmp    801eb5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e9b:	8b 52 18             	mov    0x18(%edx),%edx
  801e9e:	85 d2                	test   %edx,%edx
  801ea0:	74 0e                	je     801eb0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ea2:	83 ec 08             	sub    $0x8,%esp
  801ea5:	ff 75 0c             	pushl  0xc(%ebp)
  801ea8:	50                   	push   %eax
  801ea9:	ff d2                	call   *%edx
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	eb 05                	jmp    801eb5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801eb0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 14             	sub    $0x14,%esp
  801ec1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec7:	50                   	push   %eax
  801ec8:	ff 75 08             	pushl  0x8(%ebp)
  801ecb:	e8 63 fb ff ff       	call   801a33 <fd_lookup>
  801ed0:	83 c4 08             	add    $0x8,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 52                	js     801f29 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed7:	83 ec 08             	sub    $0x8,%esp
  801eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee1:	ff 30                	pushl  (%eax)
  801ee3:	e8 a1 fb ff ff       	call   801a89 <dev_lookup>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 3a                	js     801f29 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ef6:	74 2c                	je     801f24 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ef8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801efb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801f02:	00 00 00 
	stat->st_isdir = 0;
  801f05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f0c:	00 00 00 
	stat->st_dev = dev;
  801f0f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	53                   	push   %ebx
  801f19:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1c:	ff 50 14             	call   *0x14(%eax)
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	eb 05                	jmp    801f29 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801f24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801f29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f33:	83 ec 08             	sub    $0x8,%esp
  801f36:	6a 00                	push   $0x0
  801f38:	ff 75 08             	pushl  0x8(%ebp)
  801f3b:	e8 8b 01 00 00       	call   8020cb <open>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 1b                	js     801f64 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801f49:	83 ec 08             	sub    $0x8,%esp
  801f4c:	ff 75 0c             	pushl  0xc(%ebp)
  801f4f:	50                   	push   %eax
  801f50:	e8 65 ff ff ff       	call   801eba <fstat>
  801f55:	89 c6                	mov    %eax,%esi
	close(fd);
  801f57:	89 1c 24             	mov    %ebx,(%esp)
  801f5a:	e8 18 fc ff ff       	call   801b77 <close>
	return r;
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	89 f3                	mov    %esi,%ebx
}
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    
  801f6d:	00 00                	add    %al,(%eax)
	...

00801f70 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	56                   	push   %esi
  801f74:	53                   	push   %ebx
  801f75:	89 c3                	mov    %eax,%ebx
  801f77:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f79:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801f80:	75 12                	jne    801f94 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f82:	83 ec 0c             	sub    $0xc,%esp
  801f85:	6a 01                	push   $0x1
  801f87:	e8 b1 f9 ff ff       	call   80193d <ipc_find_env>
  801f8c:	a3 00 80 80 00       	mov    %eax,0x808000
  801f91:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f94:	6a 07                	push   $0x7
  801f96:	68 00 90 80 00       	push   $0x809000
  801f9b:	53                   	push   %ebx
  801f9c:	ff 35 00 80 80 00    	pushl  0x808000
  801fa2:	e8 41 f9 ff ff       	call   8018e8 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801fa7:	83 c4 0c             	add    $0xc,%esp
  801faa:	6a 00                	push   $0x0
  801fac:	56                   	push   %esi
  801fad:	6a 00                	push   $0x0
  801faf:	e8 8c f8 ff ff       	call   801840 <ipc_recv>
}
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 04             	sub    $0x4,%esp
  801fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	8b 40 0c             	mov    0xc(%eax),%eax
  801fcb:	a3 00 90 80 00       	mov    %eax,0x809000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd5:	b8 05 00 00 00       	mov    $0x5,%eax
  801fda:	e8 91 ff ff ff       	call   801f70 <fsipc>
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 39                	js     80201c <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	68 d2 2e 80 00       	push   $0x802ed2
  801feb:	e8 44 ec ff ff       	call   800c34 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ff0:	83 c4 08             	add    $0x8,%esp
  801ff3:	68 00 90 80 00       	push   $0x809000
  801ff8:	53                   	push   %ebx
  801ff9:	e8 ec f1 ff ff       	call   8011ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ffe:	a1 80 90 80 00       	mov    0x809080,%eax
  802003:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802009:	a1 84 90 80 00       	mov    0x809084,%eax
  80200e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201f:	c9                   	leave  
  802020:	c3                   	ret    

00802021 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	8b 40 0c             	mov    0xc(%eax),%eax
  80202d:	a3 00 90 80 00       	mov    %eax,0x809000
	return fsipc(FSREQ_FLUSH, NULL);
  802032:	ba 00 00 00 00       	mov    $0x0,%edx
  802037:	b8 06 00 00 00       	mov    $0x6,%eax
  80203c:	e8 2f ff ff ff       	call   801f70 <fsipc>
}
  802041:	c9                   	leave  
  802042:	c3                   	ret    

00802043 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	8b 40 0c             	mov    0xc(%eax),%eax
  802051:	a3 00 90 80 00       	mov    %eax,0x809000
	fsipcbuf.read.req_n = n;
  802056:	89 35 04 90 80 00    	mov    %esi,0x809004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80205c:	ba 00 00 00 00       	mov    $0x0,%edx
  802061:	b8 03 00 00 00       	mov    $0x3,%eax
  802066:	e8 05 ff ff ff       	call   801f70 <fsipc>
  80206b:	89 c3                	mov    %eax,%ebx
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 51                	js     8020c2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  802071:	39 c6                	cmp    %eax,%esi
  802073:	73 19                	jae    80208e <devfile_read+0x4b>
  802075:	68 88 2f 80 00       	push   $0x802f88
  80207a:	68 3d 29 80 00       	push   $0x80293d
  80207f:	68 80 00 00 00       	push   $0x80
  802084:	68 8f 2f 80 00       	push   $0x802f8f
  802089:	e8 ce ea ff ff       	call   800b5c <_panic>
	assert(r <= PGSIZE);
  80208e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802093:	7e 19                	jle    8020ae <devfile_read+0x6b>
  802095:	68 9a 2f 80 00       	push   $0x802f9a
  80209a:	68 3d 29 80 00       	push   $0x80293d
  80209f:	68 81 00 00 00       	push   $0x81
  8020a4:	68 8f 2f 80 00       	push   $0x802f8f
  8020a9:	e8 ae ea ff ff       	call   800b5c <_panic>
	memmove(buf, &fsipcbuf, r);
  8020ae:	83 ec 04             	sub    $0x4,%esp
  8020b1:	50                   	push   %eax
  8020b2:	68 00 90 80 00       	push   $0x809000
  8020b7:	ff 75 0c             	pushl  0xc(%ebp)
  8020ba:	e8 ec f2 ff ff       	call   8013ab <memmove>
	return r;
  8020bf:	83 c4 10             	add    $0x10,%esp
}
  8020c2:	89 d8                	mov    %ebx,%eax
  8020c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c7:	5b                   	pop    %ebx
  8020c8:	5e                   	pop    %esi
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	56                   	push   %esi
  8020cf:	53                   	push   %ebx
  8020d0:	83 ec 1c             	sub    $0x1c,%esp
  8020d3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8020d6:	56                   	push   %esi
  8020d7:	e8 bc f0 ff ff       	call   801198 <strlen>
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020e4:	7f 72                	jg     802158 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	e8 ce f8 ff ff       	call   8019c0 <fd_alloc>
  8020f2:	89 c3                	mov    %eax,%ebx
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 62                	js     80215d <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8020fb:	83 ec 08             	sub    $0x8,%esp
  8020fe:	56                   	push   %esi
  8020ff:	68 00 90 80 00       	push   $0x809000
  802104:	e8 e1 f0 ff ff       	call   8011ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  802109:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210c:	a3 00 94 80 00       	mov    %eax,0x809400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802111:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802114:	b8 01 00 00 00       	mov    $0x1,%eax
  802119:	e8 52 fe ff ff       	call   801f70 <fsipc>
  80211e:	89 c3                	mov    %eax,%ebx
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	79 12                	jns    802139 <open+0x6e>
		fd_close(fd, 0);
  802127:	83 ec 08             	sub    $0x8,%esp
  80212a:	6a 00                	push   $0x0
  80212c:	ff 75 f4             	pushl  -0xc(%ebp)
  80212f:	e8 bb f9 ff ff       	call   801aef <fd_close>
		return r;
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	eb 24                	jmp    80215d <open+0x92>
	}


	cprintf("OPEN\n");
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	68 a6 2f 80 00       	push   $0x802fa6
  802141:	e8 ee ea ff ff       	call   800c34 <cprintf>

	return fd2num(fd);
  802146:	83 c4 04             	add    $0x4,%esp
  802149:	ff 75 f4             	pushl  -0xc(%ebp)
  80214c:	e8 47 f8 ff ff       	call   801998 <fd2num>
  802151:	89 c3                	mov    %eax,%ebx
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	eb 05                	jmp    80215d <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802158:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  80215d:	89 d8                	mov    %ebx,%eax
  80215f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	c9                   	leave  
  802165:	c3                   	ret    
	...

00802168 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216e:	89 c2                	mov    %eax,%edx
  802170:	c1 ea 16             	shr    $0x16,%edx
  802173:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80217a:	f6 c2 01             	test   $0x1,%dl
  80217d:	74 1e                	je     80219d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80217f:	c1 e8 0c             	shr    $0xc,%eax
  802182:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802189:	a8 01                	test   $0x1,%al
  80218b:	74 17                	je     8021a4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80218d:	c1 e8 0c             	shr    $0xc,%eax
  802190:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802197:	ef 
  802198:	0f b7 c0             	movzwl %ax,%eax
  80219b:	eb 0c                	jmp    8021a9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a2:	eb 05                	jmp    8021a9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021a9:	c9                   	leave  
  8021aa:	c3                   	ret    
	...

008021ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	56                   	push   %esi
  8021b0:	53                   	push   %ebx
  8021b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021b4:	83 ec 0c             	sub    $0xc,%esp
  8021b7:	ff 75 08             	pushl  0x8(%ebp)
  8021ba:	e8 e9 f7 ff ff       	call   8019a8 <fd2data>
  8021bf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021c1:	83 c4 08             	add    $0x8,%esp
  8021c4:	68 ac 2f 80 00       	push   $0x802fac
  8021c9:	56                   	push   %esi
  8021ca:	e8 1b f0 ff ff       	call   8011ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8021d2:	2b 03                	sub    (%ebx),%eax
  8021d4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021da:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021e1:	00 00 00 
	stat->st_dev = &devpipe;
  8021e4:	c7 86 88 00 00 00 60 	movl   $0x807060,0x88(%esi)
  8021eb:	70 80 00 
	return 0;
}
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f6:	5b                   	pop    %ebx
  8021f7:	5e                   	pop    %esi
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 0c             	sub    $0xc,%esp
  802201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802204:	53                   	push   %ebx
  802205:	6a 00                	push   $0x0
  802207:	e8 aa f4 ff ff       	call   8016b6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80220c:	89 1c 24             	mov    %ebx,(%esp)
  80220f:	e8 94 f7 ff ff       	call   8019a8 <fd2data>
  802214:	83 c4 08             	add    $0x8,%esp
  802217:	50                   	push   %eax
  802218:	6a 00                	push   $0x0
  80221a:	e8 97 f4 ff ff       	call   8016b6 <sys_page_unmap>
}
  80221f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802222:	c9                   	leave  
  802223:	c3                   	ret    

00802224 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	57                   	push   %edi
  802228:	56                   	push   %esi
  802229:	53                   	push   %ebx
  80222a:	83 ec 1c             	sub    $0x1c,%esp
  80222d:	89 c7                	mov    %eax,%edi
  80222f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802232:	a1 0c 80 80 00       	mov    0x80800c,%eax
  802237:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80223a:	83 ec 0c             	sub    $0xc,%esp
  80223d:	57                   	push   %edi
  80223e:	e8 25 ff ff ff       	call   802168 <pageref>
  802243:	89 c6                	mov    %eax,%esi
  802245:	83 c4 04             	add    $0x4,%esp
  802248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80224b:	e8 18 ff ff ff       	call   802168 <pageref>
  802250:	83 c4 10             	add    $0x10,%esp
  802253:	39 c6                	cmp    %eax,%esi
  802255:	0f 94 c0             	sete   %al
  802258:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80225b:	8b 15 0c 80 80 00    	mov    0x80800c,%edx
  802261:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802264:	39 cb                	cmp    %ecx,%ebx
  802266:	75 08                	jne    802270 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226b:	5b                   	pop    %ebx
  80226c:	5e                   	pop    %esi
  80226d:	5f                   	pop    %edi
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802270:	83 f8 01             	cmp    $0x1,%eax
  802273:	75 bd                	jne    802232 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802275:	8b 42 58             	mov    0x58(%edx),%eax
  802278:	6a 01                	push   $0x1
  80227a:	50                   	push   %eax
  80227b:	53                   	push   %ebx
  80227c:	68 b3 2f 80 00       	push   $0x802fb3
  802281:	e8 ae e9 ff ff       	call   800c34 <cprintf>
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	eb a7                	jmp    802232 <_pipeisclosed+0xe>

0080228b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	57                   	push   %edi
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	83 ec 28             	sub    $0x28,%esp
  802294:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802297:	56                   	push   %esi
  802298:	e8 0b f7 ff ff       	call   8019a8 <fd2data>
  80229d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022a6:	75 4a                	jne    8022f2 <devpipe_write+0x67>
  8022a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ad:	eb 56                	jmp    802305 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022af:	89 da                	mov    %ebx,%edx
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	e8 6c ff ff ff       	call   802224 <_pipeisclosed>
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	75 4d                	jne    802309 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022bc:	e8 84 f3 ff ff       	call   801645 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8022c4:	8b 13                	mov    (%ebx),%edx
  8022c6:	83 c2 20             	add    $0x20,%edx
  8022c9:	39 d0                	cmp    %edx,%eax
  8022cb:	73 e2                	jae    8022af <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022cd:	89 c2                	mov    %eax,%edx
  8022cf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022d5:	79 05                	jns    8022dc <devpipe_write+0x51>
  8022d7:	4a                   	dec    %edx
  8022d8:	83 ca e0             	or     $0xffffffe0,%edx
  8022db:	42                   	inc    %edx
  8022dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022df:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8022e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022e6:	40                   	inc    %eax
  8022e7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ea:	47                   	inc    %edi
  8022eb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8022ee:	77 07                	ja     8022f7 <devpipe_write+0x6c>
  8022f0:	eb 13                	jmp    802305 <devpipe_write+0x7a>
  8022f2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8022fa:	8b 13                	mov    (%ebx),%edx
  8022fc:	83 c2 20             	add    $0x20,%edx
  8022ff:	39 d0                	cmp    %edx,%eax
  802301:	73 ac                	jae    8022af <devpipe_write+0x24>
  802303:	eb c8                	jmp    8022cd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802305:	89 f8                	mov    %edi,%eax
  802307:	eb 05                	jmp    80230e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802309:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80230e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	57                   	push   %edi
  80231a:	56                   	push   %esi
  80231b:	53                   	push   %ebx
  80231c:	83 ec 18             	sub    $0x18,%esp
  80231f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802322:	57                   	push   %edi
  802323:	e8 80 f6 ff ff       	call   8019a8 <fd2data>
  802328:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80232a:	83 c4 10             	add    $0x10,%esp
  80232d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802331:	75 44                	jne    802377 <devpipe_read+0x61>
  802333:	be 00 00 00 00       	mov    $0x0,%esi
  802338:	eb 4f                	jmp    802389 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80233a:	89 f0                	mov    %esi,%eax
  80233c:	eb 54                	jmp    802392 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80233e:	89 da                	mov    %ebx,%edx
  802340:	89 f8                	mov    %edi,%eax
  802342:	e8 dd fe ff ff       	call   802224 <_pipeisclosed>
  802347:	85 c0                	test   %eax,%eax
  802349:	75 42                	jne    80238d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80234b:	e8 f5 f2 ff ff       	call   801645 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802350:	8b 03                	mov    (%ebx),%eax
  802352:	3b 43 04             	cmp    0x4(%ebx),%eax
  802355:	74 e7                	je     80233e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802357:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80235c:	79 05                	jns    802363 <devpipe_read+0x4d>
  80235e:	48                   	dec    %eax
  80235f:	83 c8 e0             	or     $0xffffffe0,%eax
  802362:	40                   	inc    %eax
  802363:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802367:	8b 55 0c             	mov    0xc(%ebp),%edx
  80236a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80236d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236f:	46                   	inc    %esi
  802370:	39 75 10             	cmp    %esi,0x10(%ebp)
  802373:	77 07                	ja     80237c <devpipe_read+0x66>
  802375:	eb 12                	jmp    802389 <devpipe_read+0x73>
  802377:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80237c:	8b 03                	mov    (%ebx),%eax
  80237e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802381:	75 d4                	jne    802357 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802383:	85 f6                	test   %esi,%esi
  802385:	75 b3                	jne    80233a <devpipe_read+0x24>
  802387:	eb b5                	jmp    80233e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802389:	89 f0                	mov    %esi,%eax
  80238b:	eb 05                	jmp    802392 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80238d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802392:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802395:	5b                   	pop    %ebx
  802396:	5e                   	pop    %esi
  802397:	5f                   	pop    %edi
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	57                   	push   %edi
  80239e:	56                   	push   %esi
  80239f:	53                   	push   %ebx
  8023a0:	83 ec 28             	sub    $0x28,%esp
  8023a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023a9:	50                   	push   %eax
  8023aa:	e8 11 f6 ff ff       	call   8019c0 <fd_alloc>
  8023af:	89 c3                	mov    %eax,%ebx
  8023b1:	83 c4 10             	add    $0x10,%esp
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	0f 88 24 01 00 00    	js     8024e0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023bc:	83 ec 04             	sub    $0x4,%esp
  8023bf:	68 07 04 00 00       	push   $0x407
  8023c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023c7:	6a 00                	push   $0x0
  8023c9:	e8 9e f2 ff ff       	call   80166c <sys_page_alloc>
  8023ce:	89 c3                	mov    %eax,%ebx
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	0f 88 05 01 00 00    	js     8024e0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023db:	83 ec 0c             	sub    $0xc,%esp
  8023de:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	e8 d9 f5 ff ff       	call   8019c0 <fd_alloc>
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	83 c4 10             	add    $0x10,%esp
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	0f 88 dc 00 00 00    	js     8024d0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f4:	83 ec 04             	sub    $0x4,%esp
  8023f7:	68 07 04 00 00       	push   $0x407
  8023fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8023ff:	6a 00                	push   $0x0
  802401:	e8 66 f2 ff ff       	call   80166c <sys_page_alloc>
  802406:	89 c3                	mov    %eax,%ebx
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	85 c0                	test   %eax,%eax
  80240d:	0f 88 bd 00 00 00    	js     8024d0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802413:	83 ec 0c             	sub    $0xc,%esp
  802416:	ff 75 e4             	pushl  -0x1c(%ebp)
  802419:	e8 8a f5 ff ff       	call   8019a8 <fd2data>
  80241e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802420:	83 c4 0c             	add    $0xc,%esp
  802423:	68 07 04 00 00       	push   $0x407
  802428:	50                   	push   %eax
  802429:	6a 00                	push   $0x0
  80242b:	e8 3c f2 ff ff       	call   80166c <sys_page_alloc>
  802430:	89 c3                	mov    %eax,%ebx
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	85 c0                	test   %eax,%eax
  802437:	0f 88 83 00 00 00    	js     8024c0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	ff 75 e0             	pushl  -0x20(%ebp)
  802443:	e8 60 f5 ff ff       	call   8019a8 <fd2data>
  802448:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80244f:	50                   	push   %eax
  802450:	6a 00                	push   $0x0
  802452:	56                   	push   %esi
  802453:	6a 00                	push   $0x0
  802455:	e8 36 f2 ff ff       	call   801690 <sys_page_map>
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	83 c4 20             	add    $0x20,%esp
  80245f:	85 c0                	test   %eax,%eax
  802461:	78 4f                	js     8024b2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802463:	8b 15 60 70 80 00    	mov    0x807060,%edx
  802469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80246c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80246e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802471:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802478:	8b 15 60 70 80 00    	mov    0x807060,%edx
  80247e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802481:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802483:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802486:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80248d:	83 ec 0c             	sub    $0xc,%esp
  802490:	ff 75 e4             	pushl  -0x1c(%ebp)
  802493:	e8 00 f5 ff ff       	call   801998 <fd2num>
  802498:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80249a:	83 c4 04             	add    $0x4,%esp
  80249d:	ff 75 e0             	pushl  -0x20(%ebp)
  8024a0:	e8 f3 f4 ff ff       	call   801998 <fd2num>
  8024a5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024a8:	83 c4 10             	add    $0x10,%esp
  8024ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b0:	eb 2e                	jmp    8024e0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8024b2:	83 ec 08             	sub    $0x8,%esp
  8024b5:	56                   	push   %esi
  8024b6:	6a 00                	push   $0x0
  8024b8:	e8 f9 f1 ff ff       	call   8016b6 <sys_page_unmap>
  8024bd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024c0:	83 ec 08             	sub    $0x8,%esp
  8024c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8024c6:	6a 00                	push   $0x0
  8024c8:	e8 e9 f1 ff ff       	call   8016b6 <sys_page_unmap>
  8024cd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024d0:	83 ec 08             	sub    $0x8,%esp
  8024d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024d6:	6a 00                	push   $0x0
  8024d8:	e8 d9 f1 ff ff       	call   8016b6 <sys_page_unmap>
  8024dd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8024e0:	89 d8                	mov    %ebx,%eax
  8024e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    

008024ea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f3:	50                   	push   %eax
  8024f4:	ff 75 08             	pushl  0x8(%ebp)
  8024f7:	e8 37 f5 ff ff       	call   801a33 <fd_lookup>
  8024fc:	83 c4 10             	add    $0x10,%esp
  8024ff:	85 c0                	test   %eax,%eax
  802501:	78 18                	js     80251b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802503:	83 ec 0c             	sub    $0xc,%esp
  802506:	ff 75 f4             	pushl  -0xc(%ebp)
  802509:	e8 9a f4 ff ff       	call   8019a8 <fd2data>
	return _pipeisclosed(fd, p);
  80250e:	89 c2                	mov    %eax,%edx
  802510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802513:	e8 0c fd ff ff       	call   802224 <_pipeisclosed>
  802518:	83 c4 10             	add    $0x10,%esp
}
  80251b:	c9                   	leave  
  80251c:	c3                   	ret    
  80251d:	00 00                	add    %al,(%eax)
	...

00802520 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802523:	b8 00 00 00 00       	mov    $0x0,%eax
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802530:	68 cb 2f 80 00       	push   $0x802fcb
  802535:	ff 75 0c             	pushl  0xc(%ebp)
  802538:	e8 ad ec ff ff       	call   8011ea <strcpy>
	return 0;
}
  80253d:	b8 00 00 00 00       	mov    $0x0,%eax
  802542:	c9                   	leave  
  802543:	c3                   	ret    

00802544 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	57                   	push   %edi
  802548:	56                   	push   %esi
  802549:	53                   	push   %ebx
  80254a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802550:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802554:	74 45                	je     80259b <devcons_write+0x57>
  802556:	b8 00 00 00 00       	mov    $0x0,%eax
  80255b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802560:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802566:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802569:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80256b:	83 fb 7f             	cmp    $0x7f,%ebx
  80256e:	76 05                	jbe    802575 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802570:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802575:	83 ec 04             	sub    $0x4,%esp
  802578:	53                   	push   %ebx
  802579:	03 45 0c             	add    0xc(%ebp),%eax
  80257c:	50                   	push   %eax
  80257d:	57                   	push   %edi
  80257e:	e8 28 ee ff ff       	call   8013ab <memmove>
		sys_cputs(buf, m);
  802583:	83 c4 08             	add    $0x8,%esp
  802586:	53                   	push   %ebx
  802587:	57                   	push   %edi
  802588:	e8 28 f0 ff ff       	call   8015b5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80258d:	01 de                	add    %ebx,%esi
  80258f:	89 f0                	mov    %esi,%eax
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	3b 75 10             	cmp    0x10(%ebp),%esi
  802597:	72 cd                	jb     802566 <devcons_write+0x22>
  802599:	eb 05                	jmp    8025a0 <devcons_write+0x5c>
  80259b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025a0:	89 f0                	mov    %esi,%eax
  8025a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a5:	5b                   	pop    %ebx
  8025a6:	5e                   	pop    %esi
  8025a7:	5f                   	pop    %edi
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    

008025aa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025b4:	75 07                	jne    8025bd <devcons_read+0x13>
  8025b6:	eb 25                	jmp    8025dd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025b8:	e8 88 f0 ff ff       	call   801645 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025bd:	e8 19 f0 ff ff       	call   8015db <sys_cgetc>
  8025c2:	85 c0                	test   %eax,%eax
  8025c4:	74 f2                	je     8025b8 <devcons_read+0xe>
  8025c6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025c8:	85 c0                	test   %eax,%eax
  8025ca:	78 1d                	js     8025e9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025cc:	83 f8 04             	cmp    $0x4,%eax
  8025cf:	74 13                	je     8025e4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8025d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d4:	88 10                	mov    %dl,(%eax)
	return 1;
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	eb 0c                	jmp    8025e9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8025dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e2:	eb 05                	jmp    8025e9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025e4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025e9:	c9                   	leave  
  8025ea:	c3                   	ret    

008025eb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025eb:	55                   	push   %ebp
  8025ec:	89 e5                	mov    %esp,%ebp
  8025ee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025f7:	6a 01                	push   $0x1
  8025f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025fc:	50                   	push   %eax
  8025fd:	e8 b3 ef ff ff       	call   8015b5 <sys_cputs>
  802602:	83 c4 10             	add    $0x10,%esp
}
  802605:	c9                   	leave  
  802606:	c3                   	ret    

00802607 <getchar>:

int
getchar(void)
{
  802607:	55                   	push   %ebp
  802608:	89 e5                	mov    %esp,%ebp
  80260a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80260d:	6a 01                	push   $0x1
  80260f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802612:	50                   	push   %eax
  802613:	6a 00                	push   $0x0
  802615:	e8 9a f6 ff ff       	call   801cb4 <read>
	if (r < 0)
  80261a:	83 c4 10             	add    $0x10,%esp
  80261d:	85 c0                	test   %eax,%eax
  80261f:	78 0f                	js     802630 <getchar+0x29>
		return r;
	if (r < 1)
  802621:	85 c0                	test   %eax,%eax
  802623:	7e 06                	jle    80262b <getchar+0x24>
		return -E_EOF;
	return c;
  802625:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802629:	eb 05                	jmp    802630 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80262b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802630:	c9                   	leave  
  802631:	c3                   	ret    

00802632 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802632:	55                   	push   %ebp
  802633:	89 e5                	mov    %esp,%ebp
  802635:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802638:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263b:	50                   	push   %eax
  80263c:	ff 75 08             	pushl  0x8(%ebp)
  80263f:	e8 ef f3 ff ff       	call   801a33 <fd_lookup>
  802644:	83 c4 10             	add    $0x10,%esp
  802647:	85 c0                	test   %eax,%eax
  802649:	78 11                	js     80265c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80264b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264e:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  802654:	39 10                	cmp    %edx,(%eax)
  802656:	0f 94 c0             	sete   %al
  802659:	0f b6 c0             	movzbl %al,%eax
}
  80265c:	c9                   	leave  
  80265d:	c3                   	ret    

0080265e <opencons>:

int
opencons(void)
{
  80265e:	55                   	push   %ebp
  80265f:	89 e5                	mov    %esp,%ebp
  802661:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802667:	50                   	push   %eax
  802668:	e8 53 f3 ff ff       	call   8019c0 <fd_alloc>
  80266d:	83 c4 10             	add    $0x10,%esp
  802670:	85 c0                	test   %eax,%eax
  802672:	78 3a                	js     8026ae <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802674:	83 ec 04             	sub    $0x4,%esp
  802677:	68 07 04 00 00       	push   $0x407
  80267c:	ff 75 f4             	pushl  -0xc(%ebp)
  80267f:	6a 00                	push   $0x0
  802681:	e8 e6 ef ff ff       	call   80166c <sys_page_alloc>
  802686:	83 c4 10             	add    $0x10,%esp
  802689:	85 c0                	test   %eax,%eax
  80268b:	78 21                	js     8026ae <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80268d:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  802693:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802696:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026a2:	83 ec 0c             	sub    $0xc,%esp
  8026a5:	50                   	push   %eax
  8026a6:	e8 ed f2 ff ff       	call   801998 <fd2num>
  8026ab:	83 c4 10             	add    $0x10,%esp
}
  8026ae:	c9                   	leave  
  8026af:	c3                   	ret    

008026b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	57                   	push   %edi
  8026b4:	56                   	push   %esi
  8026b5:	83 ec 10             	sub    $0x10,%esp
  8026b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026be:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8026c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8026c4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026c7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ca:	85 c0                	test   %eax,%eax
  8026cc:	75 2e                	jne    8026fc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8026ce:	39 f1                	cmp    %esi,%ecx
  8026d0:	77 5a                	ja     80272c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026d2:	85 c9                	test   %ecx,%ecx
  8026d4:	75 0b                	jne    8026e1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026db:	31 d2                	xor    %edx,%edx
  8026dd:	f7 f1                	div    %ecx
  8026df:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026e1:	31 d2                	xor    %edx,%edx
  8026e3:	89 f0                	mov    %esi,%eax
  8026e5:	f7 f1                	div    %ecx
  8026e7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026e9:	89 f8                	mov    %edi,%eax
  8026eb:	f7 f1                	div    %ecx
  8026ed:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026ef:	89 f8                	mov    %edi,%eax
  8026f1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026f3:	83 c4 10             	add    $0x10,%esp
  8026f6:	5e                   	pop    %esi
  8026f7:	5f                   	pop    %edi
  8026f8:	c9                   	leave  
  8026f9:	c3                   	ret    
  8026fa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026fc:	39 f0                	cmp    %esi,%eax
  8026fe:	77 1c                	ja     80271c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802700:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802703:	83 f7 1f             	xor    $0x1f,%edi
  802706:	75 3c                	jne    802744 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802708:	39 f0                	cmp    %esi,%eax
  80270a:	0f 82 90 00 00 00    	jb     8027a0 <__udivdi3+0xf0>
  802710:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802713:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802716:	0f 86 84 00 00 00    	jbe    8027a0 <__udivdi3+0xf0>
  80271c:	31 f6                	xor    %esi,%esi
  80271e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802720:	89 f8                	mov    %edi,%eax
  802722:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802724:	83 c4 10             	add    $0x10,%esp
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	c9                   	leave  
  80272a:	c3                   	ret    
  80272b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80272c:	89 f2                	mov    %esi,%edx
  80272e:	89 f8                	mov    %edi,%eax
  802730:	f7 f1                	div    %ecx
  802732:	89 c7                	mov    %eax,%edi
  802734:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802736:	89 f8                	mov    %edi,%eax
  802738:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80273a:	83 c4 10             	add    $0x10,%esp
  80273d:	5e                   	pop    %esi
  80273e:	5f                   	pop    %edi
  80273f:	c9                   	leave  
  802740:	c3                   	ret    
  802741:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802744:	89 f9                	mov    %edi,%ecx
  802746:	d3 e0                	shl    %cl,%eax
  802748:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80274b:	b8 20 00 00 00       	mov    $0x20,%eax
  802750:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802752:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802755:	88 c1                	mov    %al,%cl
  802757:	d3 ea                	shr    %cl,%edx
  802759:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80275c:	09 ca                	or     %ecx,%edx
  80275e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802761:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802764:	89 f9                	mov    %edi,%ecx
  802766:	d3 e2                	shl    %cl,%edx
  802768:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80276b:	89 f2                	mov    %esi,%edx
  80276d:	88 c1                	mov    %al,%cl
  80276f:	d3 ea                	shr    %cl,%edx
  802771:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802774:	89 f2                	mov    %esi,%edx
  802776:	89 f9                	mov    %edi,%ecx
  802778:	d3 e2                	shl    %cl,%edx
  80277a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80277d:	88 c1                	mov    %al,%cl
  80277f:	d3 ee                	shr    %cl,%esi
  802781:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802783:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802786:	89 f0                	mov    %esi,%eax
  802788:	89 ca                	mov    %ecx,%edx
  80278a:	f7 75 ec             	divl   -0x14(%ebp)
  80278d:	89 d1                	mov    %edx,%ecx
  80278f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802791:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802794:	39 d1                	cmp    %edx,%ecx
  802796:	72 28                	jb     8027c0 <__udivdi3+0x110>
  802798:	74 1a                	je     8027b4 <__udivdi3+0x104>
  80279a:	89 f7                	mov    %esi,%edi
  80279c:	31 f6                	xor    %esi,%esi
  80279e:	eb 80                	jmp    802720 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027a0:	31 f6                	xor    %esi,%esi
  8027a2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027a7:	89 f8                	mov    %edi,%eax
  8027a9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ab:	83 c4 10             	add    $0x10,%esp
  8027ae:	5e                   	pop    %esi
  8027af:	5f                   	pop    %edi
  8027b0:	c9                   	leave  
  8027b1:	c3                   	ret    
  8027b2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8027b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027b7:	89 f9                	mov    %edi,%ecx
  8027b9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027bb:	39 c2                	cmp    %eax,%edx
  8027bd:	73 db                	jae    80279a <__udivdi3+0xea>
  8027bf:	90                   	nop
		{
		  q0--;
  8027c0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027c3:	31 f6                	xor    %esi,%esi
  8027c5:	e9 56 ff ff ff       	jmp    802720 <__udivdi3+0x70>
	...

008027cc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027cc:	55                   	push   %ebp
  8027cd:	89 e5                	mov    %esp,%ebp
  8027cf:	57                   	push   %edi
  8027d0:	56                   	push   %esi
  8027d1:	83 ec 20             	sub    $0x20,%esp
  8027d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027da:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8027dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8027e0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8027e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8027e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8027e9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027eb:	85 ff                	test   %edi,%edi
  8027ed:	75 15                	jne    802804 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8027ef:	39 f1                	cmp    %esi,%ecx
  8027f1:	0f 86 99 00 00 00    	jbe    802890 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027f7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8027f9:	89 d0                	mov    %edx,%eax
  8027fb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027fd:	83 c4 20             	add    $0x20,%esp
  802800:	5e                   	pop    %esi
  802801:	5f                   	pop    %edi
  802802:	c9                   	leave  
  802803:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802804:	39 f7                	cmp    %esi,%edi
  802806:	0f 87 a4 00 00 00    	ja     8028b0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80280c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80280f:	83 f0 1f             	xor    $0x1f,%eax
  802812:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802815:	0f 84 a1 00 00 00    	je     8028bc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80281b:	89 f8                	mov    %edi,%eax
  80281d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802820:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802822:	bf 20 00 00 00       	mov    $0x20,%edi
  802827:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80282a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80282d:	89 f9                	mov    %edi,%ecx
  80282f:	d3 ea                	shr    %cl,%edx
  802831:	09 c2                	or     %eax,%edx
  802833:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802839:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802841:	89 f2                	mov    %esi,%edx
  802843:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802845:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802848:	d3 e0                	shl    %cl,%eax
  80284a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80284d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802850:	89 f9                	mov    %edi,%ecx
  802852:	d3 e8                	shr    %cl,%eax
  802854:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802856:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802858:	89 f2                	mov    %esi,%edx
  80285a:	f7 75 f0             	divl   -0x10(%ebp)
  80285d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80285f:	f7 65 f4             	mull   -0xc(%ebp)
  802862:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802865:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802867:	39 d6                	cmp    %edx,%esi
  802869:	72 71                	jb     8028dc <__umoddi3+0x110>
  80286b:	74 7f                	je     8028ec <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80286d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802870:	29 c8                	sub    %ecx,%eax
  802872:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802874:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802877:	d3 e8                	shr    %cl,%eax
  802879:	89 f2                	mov    %esi,%edx
  80287b:	89 f9                	mov    %edi,%ecx
  80287d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80287f:	09 d0                	or     %edx,%eax
  802881:	89 f2                	mov    %esi,%edx
  802883:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802886:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802888:	83 c4 20             	add    $0x20,%esp
  80288b:	5e                   	pop    %esi
  80288c:	5f                   	pop    %edi
  80288d:	c9                   	leave  
  80288e:	c3                   	ret    
  80288f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802890:	85 c9                	test   %ecx,%ecx
  802892:	75 0b                	jne    80289f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802894:	b8 01 00 00 00       	mov    $0x1,%eax
  802899:	31 d2                	xor    %edx,%edx
  80289b:	f7 f1                	div    %ecx
  80289d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80289f:	89 f0                	mov    %esi,%eax
  8028a1:	31 d2                	xor    %edx,%edx
  8028a3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028a8:	f7 f1                	div    %ecx
  8028aa:	e9 4a ff ff ff       	jmp    8027f9 <__umoddi3+0x2d>
  8028af:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028b0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028b2:	83 c4 20             	add    $0x20,%esp
  8028b5:	5e                   	pop    %esi
  8028b6:	5f                   	pop    %edi
  8028b7:	c9                   	leave  
  8028b8:	c3                   	ret    
  8028b9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028bc:	39 f7                	cmp    %esi,%edi
  8028be:	72 05                	jb     8028c5 <__umoddi3+0xf9>
  8028c0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8028c3:	77 0c                	ja     8028d1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028c5:	89 f2                	mov    %esi,%edx
  8028c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028ca:	29 c8                	sub    %ecx,%eax
  8028cc:	19 fa                	sbb    %edi,%edx
  8028ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8028d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028d4:	83 c4 20             	add    $0x20,%esp
  8028d7:	5e                   	pop    %esi
  8028d8:	5f                   	pop    %edi
  8028d9:	c9                   	leave  
  8028da:	c3                   	ret    
  8028db:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8028df:	89 c1                	mov    %eax,%ecx
  8028e1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8028e4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8028e7:	eb 84                	jmp    80286d <__umoddi3+0xa1>
  8028e9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8028ef:	72 eb                	jb     8028dc <__umoddi3+0x110>
  8028f1:	89 f2                	mov    %esi,%edx
  8028f3:	e9 75 ff ff ff       	jmp    80286d <__umoddi3+0xa1>
