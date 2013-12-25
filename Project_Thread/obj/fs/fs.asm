
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
  8000c6:	e8 65 0b 00 00       	call   800c30 <cprintf>
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
  8000f9:	e8 5a 0a 00 00       	call   800b58 <_panic>
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
  800130:	e8 23 0a 00 00       	call   800b58 <_panic>

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
  8001e5:	e8 6e 09 00 00       	call   800b58 <_panic>

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
  80029e:	e8 b5 08 00 00       	call   800b58 <_panic>
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
  8002c7:	e8 8c 08 00 00       	call   800b58 <_panic>
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
  8002da:	e8 89 13 00 00       	call   801668 <sys_page_alloc>
	if (r < 0) panic("bc_pgfault sys_page_alloc error : %e\n", r);
  8002df:	83 c4 10             	add    $0x10,%esp
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	79 12                	jns    8002f8 <bc_pgfault+0x88>
  8002e6:	50                   	push   %eax
  8002e7:	68 a8 29 80 00       	push   $0x8029a8
  8002ec:	6a 27                	push   $0x27
  8002ee:	68 12 2a 80 00       	push   $0x802a12
  8002f3:	e8 60 08 00 00       	call   800b58 <_panic>

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
  80031b:	e8 38 08 00 00       	call   800b58 <_panic>
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
  800350:	e8 03 08 00 00       	call   800b58 <_panic>
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
  80036d:	e8 a2 14 00 00       	call   801814 <set_pgfault_handler>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800372:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800379:	e8 a9 ff ff ff       	call   800327 <diskaddr>
  80037e:	83 c4 0c             	add    $0xc,%esp
  800381:	68 08 01 00 00       	push   $0x108
  800386:	50                   	push   %eax
  800387:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038d:	50                   	push   %eax
  80038e:	e8 14 10 00 00       	call   8013a7 <memmove>
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
  8003ca:	e8 89 07 00 00       	call   800b58 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8003cf:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8003d6:	76 14                	jbe    8003ec <check_super+0x44>
		panic("file system is too large");
  8003d8:	83 ec 04             	sub    $0x4,%esp
  8003db:	68 3f 2a 80 00       	push   $0x802a3f
  8003e0:	6a 11                	push   $0x11
  8003e2:	68 37 2a 80 00       	push   $0x802a37
  8003e7:	e8 6c 07 00 00       	call   800b58 <_panic>

	cprintf("superblock is good\n");
  8003ec:	83 ec 0c             	sub    $0xc,%esp
  8003ef:	68 58 2a 80 00       	push   $0x802a58
  8003f4:	e8 37 08 00 00       	call   800c30 <cprintf>
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
  80052c:	e8 76 0e 00 00       	call   8013a7 <memmove>
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
  80057a:	e8 d9 05 00 00       	call   800b58 <_panic>
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
  8005d7:	e8 c3 0c 00 00       	call   80129f <strcmp>
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
  80070b:	e8 97 0c 00 00       	call   8013a7 <memmove>
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
  800783:	e8 e8 19 00 00       	call   802170 <pageref>
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
  8007a8:	e8 bb 0e 00 00       	call   801668 <sys_page_alloc>
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
  8007d9:	e8 7f 0b 00 00       	call   80135d <memset>
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
  80081e:	e8 4d 19 00 00       	call   802170 <pageref>
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
  800888:	e8 59 09 00 00       	call   8011e6 <strcpy>
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
  800932:	e8 70 0a 00 00       	call   8013a7 <memmove>
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
  800a00:	e8 a3 0e 00 00       	call   8018a8 <ipc_recv>
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
  800a19:	e8 12 02 00 00       	call   800c30 <cprintf>
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
  800a73:	e8 b8 01 00 00       	call   800c30 <cprintf>
  800a78:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800a7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800a80:	ff 75 e0             	pushl  -0x20(%ebp)
  800a83:	ff 75 dc             	pushl  -0x24(%ebp)
  800a86:	50                   	push   %eax
  800a87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a8a:	e8 8e 0e 00 00       	call   80191d <ipc_send>
		sys_page_unmap(0, fsreq);
  800a8f:	83 c4 08             	add    $0x8,%esp
  800a92:	ff 35 20 70 80 00    	pushl  0x807020
  800a98:	6a 00                	push   $0x0
  800a9a:	e8 13 0c 00 00       	call   8016b2 <sys_page_unmap>
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
  800abc:	e8 6f 01 00 00       	call   800c30 <cprintf>
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
  800ad4:	e8 57 01 00 00       	call   800c30 <cprintf>

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
  800afb:	e8 1d 0b 00 00       	call   80161d <sys_getenvid>
  800b00:	25 ff 03 00 00       	and    $0x3ff,%eax
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	c1 e2 07             	shl    $0x7,%edx
  800b0a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800b11:	a3 0c 80 80 00       	mov    %eax,0x80800c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800b16:	85 f6                	test   %esi,%esi
  800b18:	7e 07                	jle    800b21 <libmain+0x31>
		binaryname = argv[0];
  800b1a:	8b 03                	mov    (%ebx),%eax
  800b1c:	a3 40 70 80 00       	mov    %eax,0x807040
	// call user main routine
	umain(argc, argv);
  800b21:	83 ec 08             	sub    $0x8,%esp
  800b24:	53                   	push   %ebx
  800b25:	56                   	push   %esi
  800b26:	e8 7c ff ff ff       	call   800aa7 <umain>

	// exit gracefully
	exit();
  800b2b:	e8 0c 00 00 00       	call   800b3c <exit>
  800b30:	83 c4 10             	add    $0x10,%esp
}
  800b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    
	...

00800b3c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800b42:	e8 83 10 00 00       	call   801bca <close_all>
	sys_env_destroy(0);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	6a 00                	push   $0x0
  800b4c:	e8 aa 0a 00 00       	call   8015fb <sys_env_destroy>
  800b51:	83 c4 10             	add    $0x10,%esp
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    
	...

00800b58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b5d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b60:	8b 1d 40 70 80 00    	mov    0x807040,%ebx
  800b66:	e8 b2 0a 00 00       	call   80161d <sys_getenvid>
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	ff 75 0c             	pushl  0xc(%ebp)
  800b71:	ff 75 08             	pushl  0x8(%ebp)
  800b74:	53                   	push   %ebx
  800b75:	50                   	push   %eax
  800b76:	68 0c 2b 80 00       	push   $0x802b0c
  800b7b:	e8 b0 00 00 00       	call   800c30 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b80:	83 c4 18             	add    $0x18,%esp
  800b83:	56                   	push   %esi
  800b84:	ff 75 10             	pushl  0x10(%ebp)
  800b87:	e8 53 00 00 00       	call   800bdf <vcprintf>
	cprintf("\n");
  800b8c:	c7 04 24 fe 2a 80 00 	movl   $0x802afe,(%esp)
  800b93:	e8 98 00 00 00       	call   800c30 <cprintf>
  800b98:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b9b:	cc                   	int3   
  800b9c:	eb fd                	jmp    800b9b <_panic+0x43>
	...

00800ba0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 04             	sub    $0x4,%esp
  800ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800baa:	8b 03                	mov    (%ebx),%eax
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800bb3:	40                   	inc    %eax
  800bb4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800bb6:	3d ff 00 00 00       	cmp    $0xff,%eax
  800bbb:	75 1a                	jne    800bd7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800bbd:	83 ec 08             	sub    $0x8,%esp
  800bc0:	68 ff 00 00 00       	push   $0xff
  800bc5:	8d 43 08             	lea    0x8(%ebx),%eax
  800bc8:	50                   	push   %eax
  800bc9:	e8 e3 09 00 00       	call   8015b1 <sys_cputs>
		b->idx = 0;
  800bce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800bd4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800bd7:	ff 43 04             	incl   0x4(%ebx)
}
  800bda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800be8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800bef:	00 00 00 
	b.cnt = 0;
  800bf2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800bf9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800bfc:	ff 75 0c             	pushl  0xc(%ebp)
  800bff:	ff 75 08             	pushl  0x8(%ebp)
  800c02:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800c08:	50                   	push   %eax
  800c09:	68 a0 0b 80 00       	push   $0x800ba0
  800c0e:	e8 82 01 00 00       	call   800d95 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800c13:	83 c4 08             	add    $0x8,%esp
  800c16:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800c1c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800c22:	50                   	push   %eax
  800c23:	e8 89 09 00 00       	call   8015b1 <sys_cputs>

	return b.cnt;
}
  800c28:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800c36:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800c39:	50                   	push   %eax
  800c3a:	ff 75 08             	pushl  0x8(%ebp)
  800c3d:	e8 9d ff ff ff       	call   800bdf <vcprintf>
	va_end(ap);

	return cnt;
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 2c             	sub    $0x2c,%esp
  800c4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c5b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c61:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800c64:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c6a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800c71:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800c74:	72 0c                	jb     800c82 <printnum+0x3e>
  800c76:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800c79:	76 07                	jbe    800c82 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c7b:	4b                   	dec    %ebx
  800c7c:	85 db                	test   %ebx,%ebx
  800c7e:	7f 31                	jg     800cb1 <printnum+0x6d>
  800c80:	eb 3f                	jmp    800cc1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	57                   	push   %edi
  800c86:	4b                   	dec    %ebx
  800c87:	53                   	push   %ebx
  800c88:	50                   	push   %eax
  800c89:	83 ec 08             	sub    $0x8,%esp
  800c8c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c8f:	ff 75 d0             	pushl  -0x30(%ebp)
  800c92:	ff 75 dc             	pushl  -0x24(%ebp)
  800c95:	ff 75 d8             	pushl  -0x28(%ebp)
  800c98:	e8 1b 1a 00 00       	call   8026b8 <__udivdi3>
  800c9d:	83 c4 18             	add    $0x18,%esp
  800ca0:	52                   	push   %edx
  800ca1:	50                   	push   %eax
  800ca2:	89 f2                	mov    %esi,%edx
  800ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca7:	e8 98 ff ff ff       	call   800c44 <printnum>
  800cac:	83 c4 20             	add    $0x20,%esp
  800caf:	eb 10                	jmp    800cc1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800cb1:	83 ec 08             	sub    $0x8,%esp
  800cb4:	56                   	push   %esi
  800cb5:	57                   	push   %edi
  800cb6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800cb9:	4b                   	dec    %ebx
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	85 db                	test   %ebx,%ebx
  800cbf:	7f f0                	jg     800cb1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cc1:	83 ec 08             	sub    $0x8,%esp
  800cc4:	56                   	push   %esi
  800cc5:	83 ec 04             	sub    $0x4,%esp
  800cc8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ccb:	ff 75 d0             	pushl  -0x30(%ebp)
  800cce:	ff 75 dc             	pushl  -0x24(%ebp)
  800cd1:	ff 75 d8             	pushl  -0x28(%ebp)
  800cd4:	e8 fb 1a 00 00       	call   8027d4 <__umoddi3>
  800cd9:	83 c4 14             	add    $0x14,%esp
  800cdc:	0f be 80 2f 2b 80 00 	movsbl 0x802b2f(%eax),%eax
  800ce3:	50                   	push   %eax
  800ce4:	ff 55 e4             	call   *-0x1c(%ebp)
  800ce7:	83 c4 10             	add    $0x10,%esp
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800cf5:	83 fa 01             	cmp    $0x1,%edx
  800cf8:	7e 0e                	jle    800d08 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800cfa:	8b 10                	mov    (%eax),%edx
  800cfc:	8d 4a 08             	lea    0x8(%edx),%ecx
  800cff:	89 08                	mov    %ecx,(%eax)
  800d01:	8b 02                	mov    (%edx),%eax
  800d03:	8b 52 04             	mov    0x4(%edx),%edx
  800d06:	eb 22                	jmp    800d2a <getuint+0x38>
	else if (lflag)
  800d08:	85 d2                	test   %edx,%edx
  800d0a:	74 10                	je     800d1c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800d0c:	8b 10                	mov    (%eax),%edx
  800d0e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d11:	89 08                	mov    %ecx,(%eax)
  800d13:	8b 02                	mov    (%edx),%eax
  800d15:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1a:	eb 0e                	jmp    800d2a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800d1c:	8b 10                	mov    (%eax),%edx
  800d1e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d21:	89 08                	mov    %ecx,(%eax)
  800d23:	8b 02                	mov    (%edx),%eax
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800d2f:	83 fa 01             	cmp    $0x1,%edx
  800d32:	7e 0e                	jle    800d42 <getint+0x16>
		return va_arg(*ap, long long);
  800d34:	8b 10                	mov    (%eax),%edx
  800d36:	8d 4a 08             	lea    0x8(%edx),%ecx
  800d39:	89 08                	mov    %ecx,(%eax)
  800d3b:	8b 02                	mov    (%edx),%eax
  800d3d:	8b 52 04             	mov    0x4(%edx),%edx
  800d40:	eb 1a                	jmp    800d5c <getint+0x30>
	else if (lflag)
  800d42:	85 d2                	test   %edx,%edx
  800d44:	74 0c                	je     800d52 <getint+0x26>
		return va_arg(*ap, long);
  800d46:	8b 10                	mov    (%eax),%edx
  800d48:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d4b:	89 08                	mov    %ecx,(%eax)
  800d4d:	8b 02                	mov    (%edx),%eax
  800d4f:	99                   	cltd   
  800d50:	eb 0a                	jmp    800d5c <getint+0x30>
	else
		return va_arg(*ap, int);
  800d52:	8b 10                	mov    (%eax),%edx
  800d54:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d57:	89 08                	mov    %ecx,(%eax)
  800d59:	8b 02                	mov    (%edx),%eax
  800d5b:	99                   	cltd   
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800d64:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800d67:	8b 10                	mov    (%eax),%edx
  800d69:	3b 50 04             	cmp    0x4(%eax),%edx
  800d6c:	73 08                	jae    800d76 <sprintputch+0x18>
		*b->buf++ = ch;
  800d6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d71:	88 0a                	mov    %cl,(%edx)
  800d73:	42                   	inc    %edx
  800d74:	89 10                	mov    %edx,(%eax)
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800d7e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800d81:	50                   	push   %eax
  800d82:	ff 75 10             	pushl  0x10(%ebp)
  800d85:	ff 75 0c             	pushl  0xc(%ebp)
  800d88:	ff 75 08             	pushl  0x8(%ebp)
  800d8b:	e8 05 00 00 00       	call   800d95 <vprintfmt>
	va_end(ap);
  800d90:	83 c4 10             	add    $0x10,%esp
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
  800d9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da1:	8b 75 10             	mov    0x10(%ebp),%esi
  800da4:	eb 13                	jmp    800db9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800da6:	85 c0                	test   %eax,%eax
  800da8:	0f 84 6d 03 00 00    	je     80111b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800dae:	83 ec 08             	sub    $0x8,%esp
  800db1:	57                   	push   %edi
  800db2:	50                   	push   %eax
  800db3:	ff 55 08             	call   *0x8(%ebp)
  800db6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800db9:	0f b6 06             	movzbl (%esi),%eax
  800dbc:	46                   	inc    %esi
  800dbd:	83 f8 25             	cmp    $0x25,%eax
  800dc0:	75 e4                	jne    800da6 <vprintfmt+0x11>
  800dc2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800dc6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800dcd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800dd4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ddb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de0:	eb 28                	jmp    800e0a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800de2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800de4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800de8:	eb 20                	jmp    800e0a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dea:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800dec:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800df0:	eb 18                	jmp    800e0a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800df4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800dfb:	eb 0d                	jmp    800e0a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800dfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800e00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e03:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e0a:	8a 06                	mov    (%esi),%al
  800e0c:	0f b6 d0             	movzbl %al,%edx
  800e0f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800e12:	83 e8 23             	sub    $0x23,%eax
  800e15:	3c 55                	cmp    $0x55,%al
  800e17:	0f 87 e0 02 00 00    	ja     8010fd <vprintfmt+0x368>
  800e1d:	0f b6 c0             	movzbl %al,%eax
  800e20:	ff 24 85 80 2c 80 00 	jmp    *0x802c80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800e27:	83 ea 30             	sub    $0x30,%edx
  800e2a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800e2d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800e30:	8d 50 d0             	lea    -0x30(%eax),%edx
  800e33:	83 fa 09             	cmp    $0x9,%edx
  800e36:	77 44                	ja     800e7c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800e3d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800e3e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800e41:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800e45:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800e48:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800e4b:	83 fb 09             	cmp    $0x9,%ebx
  800e4e:	76 ed                	jbe    800e3d <vprintfmt+0xa8>
  800e50:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800e53:	eb 29                	jmp    800e7e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800e55:	8b 45 14             	mov    0x14(%ebp),%eax
  800e58:	8d 50 04             	lea    0x4(%eax),%edx
  800e5b:	89 55 14             	mov    %edx,0x14(%ebp)
  800e5e:	8b 00                	mov    (%eax),%eax
  800e60:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e63:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800e65:	eb 17                	jmp    800e7e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800e67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e6b:	78 85                	js     800df2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e6d:	89 de                	mov    %ebx,%esi
  800e6f:	eb 99                	jmp    800e0a <vprintfmt+0x75>
  800e71:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800e73:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800e7a:	eb 8e                	jmp    800e0a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e7c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800e7e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e82:	79 86                	jns    800e0a <vprintfmt+0x75>
  800e84:	e9 74 ff ff ff       	jmp    800dfd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800e89:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	e9 79 ff ff ff       	jmp    800e0a <vprintfmt+0x75>
  800e91:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800e94:	8b 45 14             	mov    0x14(%ebp),%eax
  800e97:	8d 50 04             	lea    0x4(%eax),%edx
  800e9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	57                   	push   %edi
  800ea1:	ff 30                	pushl  (%eax)
  800ea3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ea6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800eac:	e9 08 ff ff ff       	jmp    800db9 <vprintfmt+0x24>
  800eb1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800eb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb7:	8d 50 04             	lea    0x4(%eax),%edx
  800eba:	89 55 14             	mov    %edx,0x14(%ebp)
  800ebd:	8b 00                	mov    (%eax),%eax
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 02                	jns    800ec5 <vprintfmt+0x130>
  800ec3:	f7 d8                	neg    %eax
  800ec5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ec7:	83 f8 0f             	cmp    $0xf,%eax
  800eca:	7f 0b                	jg     800ed7 <vprintfmt+0x142>
  800ecc:	8b 04 85 e0 2d 80 00 	mov    0x802de0(,%eax,4),%eax
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	75 1a                	jne    800ef1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800ed7:	52                   	push   %edx
  800ed8:	68 47 2b 80 00       	push   $0x802b47
  800edd:	57                   	push   %edi
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	e8 92 fe ff ff       	call   800d78 <printfmt>
  800ee6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ee9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800eec:	e9 c8 fe ff ff       	jmp    800db9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800ef1:	50                   	push   %eax
  800ef2:	68 4f 29 80 00       	push   $0x80294f
  800ef7:	57                   	push   %edi
  800ef8:	ff 75 08             	pushl  0x8(%ebp)
  800efb:	e8 78 fe ff ff       	call   800d78 <printfmt>
  800f00:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f03:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800f06:	e9 ae fe ff ff       	jmp    800db9 <vprintfmt+0x24>
  800f0b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f13:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800f16:	8b 45 14             	mov    0x14(%ebp),%eax
  800f19:	8d 50 04             	lea    0x4(%eax),%edx
  800f1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800f1f:	8b 00                	mov    (%eax),%eax
  800f21:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	75 07                	jne    800f2f <vprintfmt+0x19a>
				p = "(null)";
  800f28:	c7 45 d0 40 2b 80 00 	movl   $0x802b40,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800f2f:	85 db                	test   %ebx,%ebx
  800f31:	7e 42                	jle    800f75 <vprintfmt+0x1e0>
  800f33:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800f37:	74 3c                	je     800f75 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	51                   	push   %ecx
  800f3d:	ff 75 d0             	pushl  -0x30(%ebp)
  800f40:	e8 6f 02 00 00       	call   8011b4 <strnlen>
  800f45:	29 c3                	sub    %eax,%ebx
  800f47:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	85 db                	test   %ebx,%ebx
  800f4f:	7e 24                	jle    800f75 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800f51:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800f55:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800f58:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	57                   	push   %edi
  800f5f:	53                   	push   %ebx
  800f60:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800f63:	4e                   	dec    %esi
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 f6                	test   %esi,%esi
  800f69:	7f f0                	jg     800f5b <vprintfmt+0x1c6>
  800f6b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800f6e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f75:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f78:	0f be 02             	movsbl (%edx),%eax
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 47                	jne    800fc6 <vprintfmt+0x231>
  800f7f:	eb 37                	jmp    800fb8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800f81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f85:	74 16                	je     800f9d <vprintfmt+0x208>
  800f87:	8d 50 e0             	lea    -0x20(%eax),%edx
  800f8a:	83 fa 5e             	cmp    $0x5e,%edx
  800f8d:	76 0e                	jbe    800f9d <vprintfmt+0x208>
					putch('?', putdat);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	57                   	push   %edi
  800f93:	6a 3f                	push   $0x3f
  800f95:	ff 55 08             	call   *0x8(%ebp)
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	eb 0b                	jmp    800fa8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	57                   	push   %edi
  800fa1:	50                   	push   %eax
  800fa2:	ff 55 08             	call   *0x8(%ebp)
  800fa5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fa8:	ff 4d e4             	decl   -0x1c(%ebp)
  800fab:	0f be 03             	movsbl (%ebx),%eax
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	74 03                	je     800fb5 <vprintfmt+0x220>
  800fb2:	43                   	inc    %ebx
  800fb3:	eb 1b                	jmp    800fd0 <vprintfmt+0x23b>
  800fb5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800fb8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fbc:	7f 1e                	jg     800fdc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fbe:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fc1:	e9 f3 fd ff ff       	jmp    800db9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fc6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800fc9:	43                   	inc    %ebx
  800fca:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800fcd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800fd0:	85 f6                	test   %esi,%esi
  800fd2:	78 ad                	js     800f81 <vprintfmt+0x1ec>
  800fd4:	4e                   	dec    %esi
  800fd5:	79 aa                	jns    800f81 <vprintfmt+0x1ec>
  800fd7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800fda:	eb dc                	jmp    800fb8 <vprintfmt+0x223>
  800fdc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	57                   	push   %edi
  800fe3:	6a 20                	push   $0x20
  800fe5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800fe8:	4b                   	dec    %ebx
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 db                	test   %ebx,%ebx
  800fee:	7f ef                	jg     800fdf <vprintfmt+0x24a>
  800ff0:	e9 c4 fd ff ff       	jmp    800db9 <vprintfmt+0x24>
  800ff5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ff8:	89 ca                	mov    %ecx,%edx
  800ffa:	8d 45 14             	lea    0x14(%ebp),%eax
  800ffd:	e8 2a fd ff ff       	call   800d2c <getint>
  801002:	89 c3                	mov    %eax,%ebx
  801004:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801006:	85 d2                	test   %edx,%edx
  801008:	78 0a                	js     801014 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80100a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80100f:	e9 b0 00 00 00       	jmp    8010c4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	57                   	push   %edi
  801018:	6a 2d                	push   $0x2d
  80101a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80101d:	f7 db                	neg    %ebx
  80101f:	83 d6 00             	adc    $0x0,%esi
  801022:	f7 de                	neg    %esi
  801024:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801027:	b8 0a 00 00 00       	mov    $0xa,%eax
  80102c:	e9 93 00 00 00       	jmp    8010c4 <vprintfmt+0x32f>
  801031:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801034:	89 ca                	mov    %ecx,%edx
  801036:	8d 45 14             	lea    0x14(%ebp),%eax
  801039:	e8 b4 fc ff ff       	call   800cf2 <getuint>
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 d6                	mov    %edx,%esi
			base = 10;
  801042:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801047:	eb 7b                	jmp    8010c4 <vprintfmt+0x32f>
  801049:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80104c:	89 ca                	mov    %ecx,%edx
  80104e:	8d 45 14             	lea    0x14(%ebp),%eax
  801051:	e8 d6 fc ff ff       	call   800d2c <getint>
  801056:	89 c3                	mov    %eax,%ebx
  801058:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80105a:	85 d2                	test   %edx,%edx
  80105c:	78 07                	js     801065 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80105e:	b8 08 00 00 00       	mov    $0x8,%eax
  801063:	eb 5f                	jmp    8010c4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	57                   	push   %edi
  801069:	6a 2d                	push   $0x2d
  80106b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80106e:	f7 db                	neg    %ebx
  801070:	83 d6 00             	adc    $0x0,%esi
  801073:	f7 de                	neg    %esi
  801075:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801078:	b8 08 00 00 00       	mov    $0x8,%eax
  80107d:	eb 45                	jmp    8010c4 <vprintfmt+0x32f>
  80107f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	57                   	push   %edi
  801086:	6a 30                	push   $0x30
  801088:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	57                   	push   %edi
  80108f:	6a 78                	push   $0x78
  801091:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801094:	8b 45 14             	mov    0x14(%ebp),%eax
  801097:	8d 50 04             	lea    0x4(%eax),%edx
  80109a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80109d:	8b 18                	mov    (%eax),%ebx
  80109f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8010a4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8010a7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8010ac:	eb 16                	jmp    8010c4 <vprintfmt+0x32f>
  8010ae:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8010b1:	89 ca                	mov    %ecx,%edx
  8010b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8010b6:	e8 37 fc ff ff       	call   800cf2 <getuint>
  8010bb:	89 c3                	mov    %eax,%ebx
  8010bd:	89 d6                	mov    %edx,%esi
			base = 16;
  8010bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8010cb:	52                   	push   %edx
  8010cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cf:	50                   	push   %eax
  8010d0:	56                   	push   %esi
  8010d1:	53                   	push   %ebx
  8010d2:	89 fa                	mov    %edi,%edx
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	e8 68 fb ff ff       	call   800c44 <printnum>
			break;
  8010dc:	83 c4 20             	add    $0x20,%esp
  8010df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010e2:	e9 d2 fc ff ff       	jmp    800db9 <vprintfmt+0x24>
  8010e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	57                   	push   %edi
  8010ee:	52                   	push   %edx
  8010ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8010f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8010f8:	e9 bc fc ff ff       	jmp    800db9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	57                   	push   %edi
  801101:	6a 25                	push   $0x25
  801103:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb 02                	jmp    80110d <vprintfmt+0x378>
  80110b:	89 c6                	mov    %eax,%esi
  80110d:	8d 46 ff             	lea    -0x1(%esi),%eax
  801110:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801114:	75 f5                	jne    80110b <vprintfmt+0x376>
  801116:	e9 9e fc ff ff       	jmp    800db9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 18             	sub    $0x18,%esp
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80112f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801132:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801136:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801139:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801140:	85 c0                	test   %eax,%eax
  801142:	74 26                	je     80116a <vsnprintf+0x47>
  801144:	85 d2                	test   %edx,%edx
  801146:	7e 29                	jle    801171 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801148:	ff 75 14             	pushl  0x14(%ebp)
  80114b:	ff 75 10             	pushl  0x10(%ebp)
  80114e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	68 5e 0d 80 00       	push   $0x800d5e
  801157:	e8 39 fc ff ff       	call   800d95 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80115c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80115f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	eb 0c                	jmp    801176 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116f:	eb 05                	jmp    801176 <vsnprintf+0x53>
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80117e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801181:	50                   	push   %eax
  801182:	ff 75 10             	pushl  0x10(%ebp)
  801185:	ff 75 0c             	pushl  0xc(%ebp)
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	e8 93 ff ff ff       	call   801123 <vsnprintf>
	va_end(ap);

	return rc;
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    
	...

00801194 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80119a:	80 3a 00             	cmpb   $0x0,(%edx)
  80119d:	74 0e                	je     8011ad <strlen+0x19>
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011a4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011a9:	75 f9                	jne    8011a4 <strlen+0x10>
  8011ab:	eb 05                	jmp    8011b2 <strlen+0x1e>
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011bd:	85 d2                	test   %edx,%edx
  8011bf:	74 17                	je     8011d8 <strnlen+0x24>
  8011c1:	80 39 00             	cmpb   $0x0,(%ecx)
  8011c4:	74 19                	je     8011df <strnlen+0x2b>
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011cb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011cc:	39 d0                	cmp    %edx,%eax
  8011ce:	74 14                	je     8011e4 <strnlen+0x30>
  8011d0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011d4:	75 f5                	jne    8011cb <strnlen+0x17>
  8011d6:	eb 0c                	jmp    8011e4 <strnlen+0x30>
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011dd:	eb 05                	jmp    8011e4 <strnlen+0x30>
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011f8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011fb:	42                   	inc    %edx
  8011fc:	84 c9                	test   %cl,%cl
  8011fe:	75 f5                	jne    8011f5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801200:	5b                   	pop    %ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	53                   	push   %ebx
  801207:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120a:	53                   	push   %ebx
  80120b:	e8 84 ff ff ff       	call   801194 <strlen>
  801210:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801213:	ff 75 0c             	pushl  0xc(%ebp)
  801216:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801219:	50                   	push   %eax
  80121a:	e8 c7 ff ff ff       	call   8011e6 <strcpy>
	return dst;
}
  80121f:	89 d8                	mov    %ebx,%eax
  801221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801234:	85 f6                	test   %esi,%esi
  801236:	74 15                	je     80124d <strncpy+0x27>
  801238:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80123d:	8a 1a                	mov    (%edx),%bl
  80123f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801242:	80 3a 01             	cmpb   $0x1,(%edx)
  801245:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801248:	41                   	inc    %ecx
  801249:	39 ce                	cmp    %ecx,%esi
  80124b:	77 f0                	ja     80123d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
  801257:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801260:	85 f6                	test   %esi,%esi
  801262:	74 32                	je     801296 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801264:	83 fe 01             	cmp    $0x1,%esi
  801267:	74 22                	je     80128b <strlcpy+0x3a>
  801269:	8a 0b                	mov    (%ebx),%cl
  80126b:	84 c9                	test   %cl,%cl
  80126d:	74 20                	je     80128f <strlcpy+0x3e>
  80126f:	89 f8                	mov    %edi,%eax
  801271:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801276:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801279:	88 08                	mov    %cl,(%eax)
  80127b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80127c:	39 f2                	cmp    %esi,%edx
  80127e:	74 11                	je     801291 <strlcpy+0x40>
  801280:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801284:	42                   	inc    %edx
  801285:	84 c9                	test   %cl,%cl
  801287:	75 f0                	jne    801279 <strlcpy+0x28>
  801289:	eb 06                	jmp    801291 <strlcpy+0x40>
  80128b:	89 f8                	mov    %edi,%eax
  80128d:	eb 02                	jmp    801291 <strlcpy+0x40>
  80128f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801291:	c6 00 00             	movb   $0x0,(%eax)
  801294:	eb 02                	jmp    801298 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801296:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801298:	29 f8                	sub    %edi,%eax
}
  80129a:	5b                   	pop    %ebx
  80129b:	5e                   	pop    %esi
  80129c:	5f                   	pop    %edi
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012a8:	8a 01                	mov    (%ecx),%al
  8012aa:	84 c0                	test   %al,%al
  8012ac:	74 10                	je     8012be <strcmp+0x1f>
  8012ae:	3a 02                	cmp    (%edx),%al
  8012b0:	75 0c                	jne    8012be <strcmp+0x1f>
		p++, q++;
  8012b2:	41                   	inc    %ecx
  8012b3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012b4:	8a 01                	mov    (%ecx),%al
  8012b6:	84 c0                	test   %al,%al
  8012b8:	74 04                	je     8012be <strcmp+0x1f>
  8012ba:	3a 02                	cmp    (%edx),%al
  8012bc:	74 f4                	je     8012b2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012be:	0f b6 c0             	movzbl %al,%eax
  8012c1:	0f b6 12             	movzbl (%edx),%edx
  8012c4:	29 d0                	sub    %edx,%eax
}
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    

008012c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 1b                	je     8012f4 <strncmp+0x2c>
  8012d9:	8a 1a                	mov    (%edx),%bl
  8012db:	84 db                	test   %bl,%bl
  8012dd:	74 24                	je     801303 <strncmp+0x3b>
  8012df:	3a 19                	cmp    (%ecx),%bl
  8012e1:	75 20                	jne    801303 <strncmp+0x3b>
  8012e3:	48                   	dec    %eax
  8012e4:	74 15                	je     8012fb <strncmp+0x33>
		n--, p++, q++;
  8012e6:	42                   	inc    %edx
  8012e7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012e8:	8a 1a                	mov    (%edx),%bl
  8012ea:	84 db                	test   %bl,%bl
  8012ec:	74 15                	je     801303 <strncmp+0x3b>
  8012ee:	3a 19                	cmp    (%ecx),%bl
  8012f0:	74 f1                	je     8012e3 <strncmp+0x1b>
  8012f2:	eb 0f                	jmp    801303 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f9:	eb 05                	jmp    801300 <strncmp+0x38>
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801300:	5b                   	pop    %ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801303:	0f b6 02             	movzbl (%edx),%eax
  801306:	0f b6 11             	movzbl (%ecx),%edx
  801309:	29 d0                	sub    %edx,%eax
  80130b:	eb f3                	jmp    801300 <strncmp+0x38>

0080130d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801316:	8a 10                	mov    (%eax),%dl
  801318:	84 d2                	test   %dl,%dl
  80131a:	74 18                	je     801334 <strchr+0x27>
		if (*s == c)
  80131c:	38 ca                	cmp    %cl,%dl
  80131e:	75 06                	jne    801326 <strchr+0x19>
  801320:	eb 17                	jmp    801339 <strchr+0x2c>
  801322:	38 ca                	cmp    %cl,%dl
  801324:	74 13                	je     801339 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801326:	40                   	inc    %eax
  801327:	8a 10                	mov    (%eax),%dl
  801329:	84 d2                	test   %dl,%dl
  80132b:	75 f5                	jne    801322 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80132d:	b8 00 00 00 00       	mov    $0x0,%eax
  801332:	eb 05                	jmp    801339 <strchr+0x2c>
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801344:	8a 10                	mov    (%eax),%dl
  801346:	84 d2                	test   %dl,%dl
  801348:	74 11                	je     80135b <strfind+0x20>
		if (*s == c)
  80134a:	38 ca                	cmp    %cl,%dl
  80134c:	75 06                	jne    801354 <strfind+0x19>
  80134e:	eb 0b                	jmp    80135b <strfind+0x20>
  801350:	38 ca                	cmp    %cl,%dl
  801352:	74 07                	je     80135b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801354:	40                   	inc    %eax
  801355:	8a 10                	mov    (%eax),%dl
  801357:	84 d2                	test   %dl,%dl
  801359:	75 f5                	jne    801350 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	8b 7d 08             	mov    0x8(%ebp),%edi
  801366:	8b 45 0c             	mov    0xc(%ebp),%eax
  801369:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80136c:	85 c9                	test   %ecx,%ecx
  80136e:	74 30                	je     8013a0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801370:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801376:	75 25                	jne    80139d <memset+0x40>
  801378:	f6 c1 03             	test   $0x3,%cl
  80137b:	75 20                	jne    80139d <memset+0x40>
		c &= 0xFF;
  80137d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801380:	89 d3                	mov    %edx,%ebx
  801382:	c1 e3 08             	shl    $0x8,%ebx
  801385:	89 d6                	mov    %edx,%esi
  801387:	c1 e6 18             	shl    $0x18,%esi
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	c1 e0 10             	shl    $0x10,%eax
  80138f:	09 f0                	or     %esi,%eax
  801391:	09 d0                	or     %edx,%eax
  801393:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801395:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801398:	fc                   	cld    
  801399:	f3 ab                	rep stos %eax,%es:(%edi)
  80139b:	eb 03                	jmp    8013a0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80139d:	fc                   	cld    
  80139e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013a0:	89 f8                	mov    %edi,%eax
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5f                   	pop    %edi
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013b5:	39 c6                	cmp    %eax,%esi
  8013b7:	73 34                	jae    8013ed <memmove+0x46>
  8013b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013bc:	39 d0                	cmp    %edx,%eax
  8013be:	73 2d                	jae    8013ed <memmove+0x46>
		s += n;
		d += n;
  8013c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c3:	f6 c2 03             	test   $0x3,%dl
  8013c6:	75 1b                	jne    8013e3 <memmove+0x3c>
  8013c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013ce:	75 13                	jne    8013e3 <memmove+0x3c>
  8013d0:	f6 c1 03             	test   $0x3,%cl
  8013d3:	75 0e                	jne    8013e3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013d5:	83 ef 04             	sub    $0x4,%edi
  8013d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013db:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8013de:	fd                   	std    
  8013df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013e1:	eb 07                	jmp    8013ea <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013e3:	4f                   	dec    %edi
  8013e4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013e7:	fd                   	std    
  8013e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013ea:	fc                   	cld    
  8013eb:	eb 20                	jmp    80140d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013f3:	75 13                	jne    801408 <memmove+0x61>
  8013f5:	a8 03                	test   $0x3,%al
  8013f7:	75 0f                	jne    801408 <memmove+0x61>
  8013f9:	f6 c1 03             	test   $0x3,%cl
  8013fc:	75 0a                	jne    801408 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013fe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801401:	89 c7                	mov    %eax,%edi
  801403:	fc                   	cld    
  801404:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801406:	eb 05                	jmp    80140d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801408:	89 c7                	mov    %eax,%edi
  80140a:	fc                   	cld    
  80140b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80140d:	5e                   	pop    %esi
  80140e:	5f                   	pop    %edi
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801414:	ff 75 10             	pushl  0x10(%ebp)
  801417:	ff 75 0c             	pushl  0xc(%ebp)
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 85 ff ff ff       	call   8013a7 <memmove>
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	57                   	push   %edi
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80142d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801430:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801433:	85 ff                	test   %edi,%edi
  801435:	74 32                	je     801469 <memcmp+0x45>
		if (*s1 != *s2)
  801437:	8a 03                	mov    (%ebx),%al
  801439:	8a 0e                	mov    (%esi),%cl
  80143b:	38 c8                	cmp    %cl,%al
  80143d:	74 19                	je     801458 <memcmp+0x34>
  80143f:	eb 0d                	jmp    80144e <memcmp+0x2a>
  801441:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801445:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801449:	42                   	inc    %edx
  80144a:	38 c8                	cmp    %cl,%al
  80144c:	74 10                	je     80145e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80144e:	0f b6 c0             	movzbl %al,%eax
  801451:	0f b6 c9             	movzbl %cl,%ecx
  801454:	29 c8                	sub    %ecx,%eax
  801456:	eb 16                	jmp    80146e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801458:	4f                   	dec    %edi
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	39 fa                	cmp    %edi,%edx
  801460:	75 df                	jne    801441 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	eb 05                	jmp    80146e <memcmp+0x4a>
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801479:	89 c2                	mov    %eax,%edx
  80147b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80147e:	39 d0                	cmp    %edx,%eax
  801480:	73 12                	jae    801494 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801482:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801485:	38 08                	cmp    %cl,(%eax)
  801487:	75 06                	jne    80148f <memfind+0x1c>
  801489:	eb 09                	jmp    801494 <memfind+0x21>
  80148b:	38 08                	cmp    %cl,(%eax)
  80148d:	74 05                	je     801494 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80148f:	40                   	inc    %eax
  801490:	39 c2                	cmp    %eax,%edx
  801492:	77 f7                	ja     80148b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	57                   	push   %edi
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	8b 55 08             	mov    0x8(%ebp),%edx
  80149f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014a2:	eb 01                	jmp    8014a5 <strtol+0xf>
		s++;
  8014a4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014a5:	8a 02                	mov    (%edx),%al
  8014a7:	3c 20                	cmp    $0x20,%al
  8014a9:	74 f9                	je     8014a4 <strtol+0xe>
  8014ab:	3c 09                	cmp    $0x9,%al
  8014ad:	74 f5                	je     8014a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8014af:	3c 2b                	cmp    $0x2b,%al
  8014b1:	75 08                	jne    8014bb <strtol+0x25>
		s++;
  8014b3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014b9:	eb 13                	jmp    8014ce <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014bb:	3c 2d                	cmp    $0x2d,%al
  8014bd:	75 0a                	jne    8014c9 <strtol+0x33>
		s++, neg = 1;
  8014bf:	8d 52 01             	lea    0x1(%edx),%edx
  8014c2:	bf 01 00 00 00       	mov    $0x1,%edi
  8014c7:	eb 05                	jmp    8014ce <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014ce:	85 db                	test   %ebx,%ebx
  8014d0:	74 05                	je     8014d7 <strtol+0x41>
  8014d2:	83 fb 10             	cmp    $0x10,%ebx
  8014d5:	75 28                	jne    8014ff <strtol+0x69>
  8014d7:	8a 02                	mov    (%edx),%al
  8014d9:	3c 30                	cmp    $0x30,%al
  8014db:	75 10                	jne    8014ed <strtol+0x57>
  8014dd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014e1:	75 0a                	jne    8014ed <strtol+0x57>
		s += 2, base = 16;
  8014e3:	83 c2 02             	add    $0x2,%edx
  8014e6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014eb:	eb 12                	jmp    8014ff <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8014ed:	85 db                	test   %ebx,%ebx
  8014ef:	75 0e                	jne    8014ff <strtol+0x69>
  8014f1:	3c 30                	cmp    $0x30,%al
  8014f3:	75 05                	jne    8014fa <strtol+0x64>
		s++, base = 8;
  8014f5:	42                   	inc    %edx
  8014f6:	b3 08                	mov    $0x8,%bl
  8014f8:	eb 05                	jmp    8014ff <strtol+0x69>
	else if (base == 0)
		base = 10;
  8014fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801504:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801506:	8a 0a                	mov    (%edx),%cl
  801508:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80150b:	80 fb 09             	cmp    $0x9,%bl
  80150e:	77 08                	ja     801518 <strtol+0x82>
			dig = *s - '0';
  801510:	0f be c9             	movsbl %cl,%ecx
  801513:	83 e9 30             	sub    $0x30,%ecx
  801516:	eb 1e                	jmp    801536 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801518:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80151b:	80 fb 19             	cmp    $0x19,%bl
  80151e:	77 08                	ja     801528 <strtol+0x92>
			dig = *s - 'a' + 10;
  801520:	0f be c9             	movsbl %cl,%ecx
  801523:	83 e9 57             	sub    $0x57,%ecx
  801526:	eb 0e                	jmp    801536 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801528:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80152b:	80 fb 19             	cmp    $0x19,%bl
  80152e:	77 13                	ja     801543 <strtol+0xad>
			dig = *s - 'A' + 10;
  801530:	0f be c9             	movsbl %cl,%ecx
  801533:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801536:	39 f1                	cmp    %esi,%ecx
  801538:	7d 0d                	jge    801547 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80153a:	42                   	inc    %edx
  80153b:	0f af c6             	imul   %esi,%eax
  80153e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801541:	eb c3                	jmp    801506 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801543:	89 c1                	mov    %eax,%ecx
  801545:	eb 02                	jmp    801549 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801547:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801549:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80154d:	74 05                	je     801554 <strtol+0xbe>
		*endptr = (char *) s;
  80154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801552:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801554:	85 ff                	test   %edi,%edi
  801556:	74 04                	je     80155c <strtol+0xc6>
  801558:	89 c8                	mov    %ecx,%eax
  80155a:	f7 d8                	neg    %eax
}
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	c9                   	leave  
  801560:	c3                   	ret    
  801561:	00 00                	add    %al,(%eax)
	...

00801564 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	57                   	push   %edi
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
  80156a:	83 ec 1c             	sub    $0x1c,%esp
  80156d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801570:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801573:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801575:	8b 75 14             	mov    0x14(%ebp),%esi
  801578:	8b 7d 10             	mov    0x10(%ebp),%edi
  80157b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80157e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801581:	cd 30                	int    $0x30
  801583:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801589:	74 1c                	je     8015a7 <syscall+0x43>
  80158b:	85 c0                	test   %eax,%eax
  80158d:	7e 18                	jle    8015a7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	50                   	push   %eax
  801593:	ff 75 e4             	pushl  -0x1c(%ebp)
  801596:	68 3f 2e 80 00       	push   $0x802e3f
  80159b:	6a 42                	push   $0x42
  80159d:	68 5c 2e 80 00       	push   $0x802e5c
  8015a2:	e8 b1 f5 ff ff       	call   800b58 <_panic>

	return ret;
}
  8015a7:	89 d0                	mov    %edx,%eax
  8015a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8015b7:	6a 00                	push   $0x0
  8015b9:	6a 00                	push   $0x0
  8015bb:	6a 00                	push   $0x0
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cd:	e8 92 ff ff ff       	call   801564 <syscall>
  8015d2:	83 c4 10             	add    $0x10,%esp
	return;
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8015dd:	6a 00                	push   $0x0
  8015df:	6a 00                	push   $0x0
  8015e1:	6a 00                	push   $0x0
  8015e3:	6a 00                	push   $0x0
  8015e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f4:	e8 6b ff ff ff       	call   801564 <syscall>
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801601:	6a 00                	push   $0x0
  801603:	6a 00                	push   $0x0
  801605:	6a 00                	push   $0x0
  801607:	6a 00                	push   $0x0
  801609:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80160c:	ba 01 00 00 00       	mov    $0x1,%edx
  801611:	b8 03 00 00 00       	mov    $0x3,%eax
  801616:	e8 49 ff ff ff       	call   801564 <syscall>
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801623:	6a 00                	push   $0x0
  801625:	6a 00                	push   $0x0
  801627:	6a 00                	push   $0x0
  801629:	6a 00                	push   $0x0
  80162b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801630:	ba 00 00 00 00       	mov    $0x0,%edx
  801635:	b8 02 00 00 00       	mov    $0x2,%eax
  80163a:	e8 25 ff ff ff       	call   801564 <syscall>
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <sys_yield>:

void
sys_yield(void)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801647:	6a 00                	push   $0x0
  801649:	6a 00                	push   $0x0
  80164b:	6a 00                	push   $0x0
  80164d:	6a 00                	push   $0x0
  80164f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801654:	ba 00 00 00 00       	mov    $0x0,%edx
  801659:	b8 0b 00 00 00       	mov    $0xb,%eax
  80165e:	e8 01 ff ff ff       	call   801564 <syscall>
  801663:	83 c4 10             	add    $0x10,%esp
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80166e:	6a 00                	push   $0x0
  801670:	6a 00                	push   $0x0
  801672:	ff 75 10             	pushl  0x10(%ebp)
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167b:	ba 01 00 00 00       	mov    $0x1,%edx
  801680:	b8 04 00 00 00       	mov    $0x4,%eax
  801685:	e8 da fe ff ff       	call   801564 <syscall>
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801692:	ff 75 18             	pushl  0x18(%ebp)
  801695:	ff 75 14             	pushl  0x14(%ebp)
  801698:	ff 75 10             	pushl  0x10(%ebp)
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a1:	ba 01 00 00 00       	mov    $0x1,%edx
  8016a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ab:	e8 b4 fe ff ff       	call   801564 <syscall>
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8016b8:	6a 00                	push   $0x0
  8016ba:	6a 00                	push   $0x0
  8016bc:	6a 00                	push   $0x0
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8016c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ce:	e8 91 fe ff ff       	call   801564 <syscall>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8016db:	6a 00                	push   $0x0
  8016dd:	6a 00                	push   $0x0
  8016df:	6a 00                	push   $0x0
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e7:	ba 01 00 00 00       	mov    $0x1,%edx
  8016ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f1:	e8 6e fe ff ff       	call   801564 <syscall>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8016fe:	6a 00                	push   $0x0
  801700:	6a 00                	push   $0x0
  801702:	6a 00                	push   $0x0
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170a:	ba 01 00 00 00       	mov    $0x1,%edx
  80170f:	b8 09 00 00 00       	mov    $0x9,%eax
  801714:	e8 4b fe ff ff       	call   801564 <syscall>
}
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801721:	6a 00                	push   $0x0
  801723:	6a 00                	push   $0x0
  801725:	6a 00                	push   $0x0
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172d:	ba 01 00 00 00       	mov    $0x1,%edx
  801732:	b8 0a 00 00 00       	mov    $0xa,%eax
  801737:	e8 28 fe ff ff       	call   801564 <syscall>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801744:	6a 00                	push   $0x0
  801746:	ff 75 14             	pushl  0x14(%ebp)
  801749:	ff 75 10             	pushl  0x10(%ebp)
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801752:	ba 00 00 00 00       	mov    $0x0,%edx
  801757:	b8 0c 00 00 00       	mov    $0xc,%eax
  80175c:	e8 03 fe ff ff       	call   801564 <syscall>
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801769:	6a 00                	push   $0x0
  80176b:	6a 00                	push   $0x0
  80176d:	6a 00                	push   $0x0
  80176f:	6a 00                	push   $0x0
  801771:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801774:	ba 01 00 00 00       	mov    $0x1,%edx
  801779:	b8 0d 00 00 00       	mov    $0xd,%eax
  80177e:	e8 e1 fd ff ff       	call   801564 <syscall>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80178b:	6a 00                	push   $0x0
  80178d:	6a 00                	push   $0x0
  80178f:	6a 00                	push   $0x0
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 0e 00 00 00       	mov    $0xe,%eax
  8017a1:	e8 be fd ff ff       	call   801564 <syscall>
}
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8017ae:	6a 00                	push   $0x0
  8017b0:	ff 75 14             	pushl  0x14(%ebp)
  8017b3:	ff 75 10             	pushl  0x10(%ebp)
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8017c6:	e8 99 fd ff ff       	call   801564 <syscall>
} 
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  8017d3:	6a 00                	push   $0x0
  8017d5:	6a 00                	push   $0x0
  8017d7:	6a 00                	push   $0x0
  8017d9:	6a 00                	push   $0x0
  8017db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 11 00 00 00       	mov    $0x11,%eax
  8017e8:	e8 77 fd ff ff       	call   801564 <syscall>
}
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <sys_getpid>:

envid_t
sys_getpid(void)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  8017f5:	6a 00                	push   $0x0
  8017f7:	6a 00                	push   $0x0
  8017f9:	6a 00                	push   $0x0
  8017fb:	6a 00                	push   $0x0
  8017fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801802:	ba 00 00 00 00       	mov    $0x0,%edx
  801807:	b8 10 00 00 00       	mov    $0x10,%eax
  80180c:	e8 53 fd ff ff       	call   801564 <syscall>
  801811:	c9                   	leave  
  801812:	c3                   	ret    
	...

00801814 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80181a:	83 3d 10 80 80 00 00 	cmpl   $0x0,0x808010
  801821:	75 52                	jne    801875 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	6a 07                	push   $0x7
  801828:	68 00 f0 bf ee       	push   $0xeebff000
  80182d:	6a 00                	push   $0x0
  80182f:	e8 34 fe ff ff       	call   801668 <sys_page_alloc>
		if (r < 0) {
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	79 12                	jns    80184d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80183b:	50                   	push   %eax
  80183c:	68 6a 2e 80 00       	push   $0x802e6a
  801841:	6a 24                	push   $0x24
  801843:	68 85 2e 80 00       	push   $0x802e85
  801848:	e8 0b f3 ff ff       	call   800b58 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	68 80 18 80 00       	push   $0x801880
  801855:	6a 00                	push   $0x0
  801857:	e8 bf fe ff ff       	call   80171b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	79 12                	jns    801875 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801863:	50                   	push   %eax
  801864:	68 94 2e 80 00       	push   $0x802e94
  801869:	6a 2a                	push   $0x2a
  80186b:	68 85 2e 80 00       	push   $0x802e85
  801870:	e8 e3 f2 ff ff       	call   800b58 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	a3 10 80 80 00       	mov    %eax,0x808010
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    
	...

00801880 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801880:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801881:	a1 10 80 80 00       	mov    0x808010,%eax
	call *%eax
  801886:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801888:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80188b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80188f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801892:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801896:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80189a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80189c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80189f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8018a0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8018a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8018a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8018a5:	c3                   	ret    
	...

008018a8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	74 0e                	je     8018c8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	50                   	push   %eax
  8018be:	e8 a0 fe ff ff       	call   801763 <sys_ipc_recv>
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	eb 10                	jmp    8018d8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	68 00 00 c0 ee       	push   $0xeec00000
  8018d0:	e8 8e fe ff ff       	call   801763 <sys_ipc_recv>
  8018d5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	75 26                	jne    801902 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8018dc:	85 f6                	test   %esi,%esi
  8018de:	74 0a                	je     8018ea <ipc_recv+0x42>
  8018e0:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018e5:	8b 40 74             	mov    0x74(%eax),%eax
  8018e8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8018ea:	85 db                	test   %ebx,%ebx
  8018ec:	74 0a                	je     8018f8 <ipc_recv+0x50>
  8018ee:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018f3:	8b 40 78             	mov    0x78(%eax),%eax
  8018f6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8018f8:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8018fd:	8b 40 70             	mov    0x70(%eax),%eax
  801900:	eb 14                	jmp    801916 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801902:	85 f6                	test   %esi,%esi
  801904:	74 06                	je     80190c <ipc_recv+0x64>
  801906:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80190c:	85 db                	test   %ebx,%ebx
  80190e:	74 06                	je     801916 <ipc_recv+0x6e>
  801910:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	57                   	push   %edi
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801929:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80192c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80192f:	85 db                	test   %ebx,%ebx
  801931:	75 25                	jne    801958 <ipc_send+0x3b>
  801933:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801938:	eb 1e                	jmp    801958 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80193a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80193d:	75 07                	jne    801946 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80193f:	e8 fd fc ff ff       	call   801641 <sys_yield>
  801944:	eb 12                	jmp    801958 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801946:	50                   	push   %eax
  801947:	68 bb 2e 80 00       	push   $0x802ebb
  80194c:	6a 43                	push   $0x43
  80194e:	68 ce 2e 80 00       	push   $0x802ece
  801953:	e8 00 f2 ff ff       	call   800b58 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	57                   	push   %edi
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 db fd ff ff       	call   80173e <sys_ipc_try_send>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	75 d0                	jne    80193a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80196a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5f                   	pop    %edi
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801978:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80197e:	74 1a                	je     80199a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801980:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801985:	89 c2                	mov    %eax,%edx
  801987:	c1 e2 07             	shl    $0x7,%edx
  80198a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801991:	8b 52 50             	mov    0x50(%edx),%edx
  801994:	39 ca                	cmp    %ecx,%edx
  801996:	75 18                	jne    8019b0 <ipc_find_env+0x3e>
  801998:	eb 05                	jmp    80199f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	c1 e2 07             	shl    $0x7,%edx
  8019a4:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8019ab:	8b 40 40             	mov    0x40(%eax),%eax
  8019ae:	eb 0c                	jmp    8019bc <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019b0:	40                   	inc    %eax
  8019b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019b6:	75 cd                	jne    801985 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019b8:	66 b8 00 00          	mov    $0x0,%ax
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    
	...

008019c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8019cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8019d3:	ff 75 08             	pushl  0x8(%ebp)
  8019d6:	e8 e5 ff ff ff       	call   8019c0 <fd2num>
  8019db:	83 c4 04             	add    $0x4,%esp
  8019de:	05 20 00 0d 00       	add    $0xd0020,%eax
  8019e3:	c1 e0 0c             	shl    $0xc,%eax
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8019ef:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8019f4:	a8 01                	test   $0x1,%al
  8019f6:	74 34                	je     801a2c <fd_alloc+0x44>
  8019f8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8019fd:	a8 01                	test   $0x1,%al
  8019ff:	74 32                	je     801a33 <fd_alloc+0x4b>
  801a01:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801a06:	89 c1                	mov    %eax,%ecx
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	c1 ea 16             	shr    $0x16,%edx
  801a0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a14:	f6 c2 01             	test   $0x1,%dl
  801a17:	74 1f                	je     801a38 <fd_alloc+0x50>
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	c1 ea 0c             	shr    $0xc,%edx
  801a1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a25:	f6 c2 01             	test   $0x1,%dl
  801a28:	75 17                	jne    801a41 <fd_alloc+0x59>
  801a2a:	eb 0c                	jmp    801a38 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801a2c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801a31:	eb 05                	jmp    801a38 <fd_alloc+0x50>
  801a33:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801a38:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3f:	eb 17                	jmp    801a58 <fd_alloc+0x70>
  801a41:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a46:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a4b:	75 b9                	jne    801a06 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801a4d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801a53:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801a58:	5b                   	pop    %ebx
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801a61:	83 f8 1f             	cmp    $0x1f,%eax
  801a64:	77 36                	ja     801a9c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801a66:	05 00 00 0d 00       	add    $0xd0000,%eax
  801a6b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a6e:	89 c2                	mov    %eax,%edx
  801a70:	c1 ea 16             	shr    $0x16,%edx
  801a73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a7a:	f6 c2 01             	test   $0x1,%dl
  801a7d:	74 24                	je     801aa3 <fd_lookup+0x48>
  801a7f:	89 c2                	mov    %eax,%edx
  801a81:	c1 ea 0c             	shr    $0xc,%edx
  801a84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a8b:	f6 c2 01             	test   $0x1,%dl
  801a8e:	74 1a                	je     801aaa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a90:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a93:	89 02                	mov    %eax,(%edx)
	return 0;
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9a:	eb 13                	jmp    801aaf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aa1:	eb 0c                	jmp    801aaf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801aa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aa8:	eb 05                	jmp    801aaf <fd_lookup+0x54>
  801aaa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801abe:	39 0d 44 70 80 00    	cmp    %ecx,0x807044
  801ac4:	74 0d                	je     801ad3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  801acb:	eb 14                	jmp    801ae1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801acd:	39 0a                	cmp    %ecx,(%edx)
  801acf:	75 10                	jne    801ae1 <dev_lookup+0x30>
  801ad1:	eb 05                	jmp    801ad8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ad3:	ba 44 70 80 00       	mov    $0x807044,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801ad8:	89 13                	mov    %edx,(%ebx)
			return 0;
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
  801adf:	eb 31                	jmp    801b12 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ae1:	40                   	inc    %eax
  801ae2:	8b 14 85 58 2f 80 00 	mov    0x802f58(,%eax,4),%edx
  801ae9:	85 d2                	test   %edx,%edx
  801aeb:	75 e0                	jne    801acd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801aed:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801af2:	8b 40 48             	mov    0x48(%eax),%eax
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	51                   	push   %ecx
  801af9:	50                   	push   %eax
  801afa:	68 d8 2e 80 00       	push   $0x802ed8
  801aff:	e8 2c f1 ff ff       	call   800c30 <cprintf>
	*dev = 0;
  801b04:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 20             	sub    $0x20,%esp
  801b1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b22:	8a 45 0c             	mov    0xc(%ebp),%al
  801b25:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b28:	56                   	push   %esi
  801b29:	e8 92 fe ff ff       	call   8019c0 <fd2num>
  801b2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b31:	89 14 24             	mov    %edx,(%esp)
  801b34:	50                   	push   %eax
  801b35:	e8 21 ff ff ff       	call   801a5b <fd_lookup>
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	83 c4 08             	add    $0x8,%esp
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 05                	js     801b48 <fd_close+0x31>
	    || fd != fd2)
  801b43:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b46:	74 0d                	je     801b55 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801b48:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801b4c:	75 48                	jne    801b96 <fd_close+0x7f>
  801b4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b53:	eb 41                	jmp    801b96 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b55:	83 ec 08             	sub    $0x8,%esp
  801b58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	ff 36                	pushl  (%esi)
  801b5e:	e8 4e ff ff ff       	call   801ab1 <dev_lookup>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 1c                	js     801b88 <fd_close+0x71>
		if (dev->dev_close)
  801b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6f:	8b 40 10             	mov    0x10(%eax),%eax
  801b72:	85 c0                	test   %eax,%eax
  801b74:	74 0d                	je     801b83 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	56                   	push   %esi
  801b7a:	ff d0                	call   *%eax
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	eb 05                	jmp    801b88 <fd_close+0x71>
		else
			r = 0;
  801b83:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	56                   	push   %esi
  801b8c:	6a 00                	push   $0x0
  801b8e:	e8 1f fb ff ff       	call   8016b2 <sys_page_unmap>
	return r;
  801b93:	83 c4 10             	add    $0x10,%esp
}
  801b96:	89 d8                	mov    %ebx,%eax
  801b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	ff 75 08             	pushl  0x8(%ebp)
  801bac:	e8 aa fe ff ff       	call   801a5b <fd_lookup>
  801bb1:	83 c4 08             	add    $0x8,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 10                	js     801bc8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	6a 01                	push   $0x1
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	e8 52 ff ff ff       	call   801b17 <fd_close>
  801bc5:	83 c4 10             	add    $0x10,%esp
}
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <close_all>:

void
close_all(void)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	53                   	push   %ebx
  801bce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	53                   	push   %ebx
  801bda:	e8 c0 ff ff ff       	call   801b9f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bdf:	43                   	inc    %ebx
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	83 fb 20             	cmp    $0x20,%ebx
  801be6:	75 ee                	jne    801bd6 <close_all+0xc>
		close(i);
}
  801be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	57                   	push   %edi
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 2c             	sub    $0x2c,%esp
  801bf6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bf9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bfc:	50                   	push   %eax
  801bfd:	ff 75 08             	pushl  0x8(%ebp)
  801c00:	e8 56 fe ff ff       	call   801a5b <fd_lookup>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 08             	add    $0x8,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	0f 88 c0 00 00 00    	js     801cd2 <dup+0xe5>
		return r;
	close(newfdnum);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	57                   	push   %edi
  801c16:	e8 84 ff ff ff       	call   801b9f <close>

	newfd = INDEX2FD(newfdnum);
  801c1b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c21:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c24:	83 c4 04             	add    $0x4,%esp
  801c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2a:	e8 a1 fd ff ff       	call   8019d0 <fd2data>
  801c2f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c31:	89 34 24             	mov    %esi,(%esp)
  801c34:	e8 97 fd ff ff       	call   8019d0 <fd2data>
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801c3f:	89 d8                	mov    %ebx,%eax
  801c41:	c1 e8 16             	shr    $0x16,%eax
  801c44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c4b:	a8 01                	test   $0x1,%al
  801c4d:	74 37                	je     801c86 <dup+0x99>
  801c4f:	89 d8                	mov    %ebx,%eax
  801c51:	c1 e8 0c             	shr    $0xc,%eax
  801c54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c5b:	f6 c2 01             	test   $0x1,%dl
  801c5e:	74 26                	je     801c86 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	25 07 0e 00 00       	and    $0xe07,%eax
  801c6f:	50                   	push   %eax
  801c70:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c73:	6a 00                	push   $0x0
  801c75:	53                   	push   %ebx
  801c76:	6a 00                	push   $0x0
  801c78:	e8 0f fa ff ff       	call   80168c <sys_page_map>
  801c7d:	89 c3                	mov    %eax,%ebx
  801c7f:	83 c4 20             	add    $0x20,%esp
  801c82:	85 c0                	test   %eax,%eax
  801c84:	78 2d                	js     801cb3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	c1 ea 0c             	shr    $0xc,%edx
  801c8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c9e:	52                   	push   %edx
  801c9f:	56                   	push   %esi
  801ca0:	6a 00                	push   $0x0
  801ca2:	50                   	push   %eax
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 e2 f9 ff ff       	call   80168c <sys_page_map>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 20             	add    $0x20,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	79 1d                	jns    801cd0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	56                   	push   %esi
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 f4 f9 ff ff       	call   8016b2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801cbe:	83 c4 08             	add    $0x8,%esp
  801cc1:	ff 75 d4             	pushl  -0x2c(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 e7 f9 ff ff       	call   8016b2 <sys_page_unmap>
	return r;
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	eb 02                	jmp    801cd2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801cd0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801cd2:	89 d8                	mov    %ebx,%eax
  801cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 14             	sub    $0x14,%esp
  801ce3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ce6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	53                   	push   %ebx
  801ceb:	e8 6b fd ff ff       	call   801a5b <fd_lookup>
  801cf0:	83 c4 08             	add    $0x8,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 67                	js     801d5e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d01:	ff 30                	pushl  (%eax)
  801d03:	e8 a9 fd ff ff       	call   801ab1 <dev_lookup>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 4f                	js     801d5e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d12:	8b 50 08             	mov    0x8(%eax),%edx
  801d15:	83 e2 03             	and    $0x3,%edx
  801d18:	83 fa 01             	cmp    $0x1,%edx
  801d1b:	75 21                	jne    801d3e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d1d:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801d22:	8b 40 48             	mov    0x48(%eax),%eax
  801d25:	83 ec 04             	sub    $0x4,%esp
  801d28:	53                   	push   %ebx
  801d29:	50                   	push   %eax
  801d2a:	68 1c 2f 80 00       	push   $0x802f1c
  801d2f:	e8 fc ee ff ff       	call   800c30 <cprintf>
		return -E_INVAL;
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d3c:	eb 20                	jmp    801d5e <read+0x82>
	}
	if (!dev->dev_read)
  801d3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d41:	8b 52 08             	mov    0x8(%edx),%edx
  801d44:	85 d2                	test   %edx,%edx
  801d46:	74 11                	je     801d59 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	ff 75 10             	pushl  0x10(%ebp)
  801d4e:	ff 75 0c             	pushl  0xc(%ebp)
  801d51:	50                   	push   %eax
  801d52:	ff d2                	call   *%edx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	eb 05                	jmp    801d5e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801d59:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801d5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	57                   	push   %edi
  801d67:	56                   	push   %esi
  801d68:	53                   	push   %ebx
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d6f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d72:	85 f6                	test   %esi,%esi
  801d74:	74 31                	je     801da7 <readn+0x44>
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d80:	83 ec 04             	sub    $0x4,%esp
  801d83:	89 f2                	mov    %esi,%edx
  801d85:	29 c2                	sub    %eax,%edx
  801d87:	52                   	push   %edx
  801d88:	03 45 0c             	add    0xc(%ebp),%eax
  801d8b:	50                   	push   %eax
  801d8c:	57                   	push   %edi
  801d8d:	e8 4a ff ff ff       	call   801cdc <read>
		if (m < 0)
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 17                	js     801db0 <readn+0x4d>
			return m;
		if (m == 0)
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	74 11                	je     801dae <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d9d:	01 c3                	add    %eax,%ebx
  801d9f:	89 d8                	mov    %ebx,%eax
  801da1:	39 f3                	cmp    %esi,%ebx
  801da3:	72 db                	jb     801d80 <readn+0x1d>
  801da5:	eb 09                	jmp    801db0 <readn+0x4d>
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dac:	eb 02                	jmp    801db0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801dae:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 14             	sub    $0x14,%esp
  801dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	53                   	push   %ebx
  801dc7:	e8 8f fc ff ff       	call   801a5b <fd_lookup>
  801dcc:	83 c4 08             	add    $0x8,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 62                	js     801e35 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd9:	50                   	push   %eax
  801dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddd:	ff 30                	pushl  (%eax)
  801ddf:	e8 cd fc ff ff       	call   801ab1 <dev_lookup>
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 4a                	js     801e35 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801df2:	75 21                	jne    801e15 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801df4:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801df9:	8b 40 48             	mov    0x48(%eax),%eax
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	53                   	push   %ebx
  801e00:	50                   	push   %eax
  801e01:	68 38 2f 80 00       	push   $0x802f38
  801e06:	e8 25 ee ff ff       	call   800c30 <cprintf>
		return -E_INVAL;
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e13:	eb 20                	jmp    801e35 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e18:	8b 52 0c             	mov    0xc(%edx),%edx
  801e1b:	85 d2                	test   %edx,%edx
  801e1d:	74 11                	je     801e30 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e1f:	83 ec 04             	sub    $0x4,%esp
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	50                   	push   %eax
  801e29:	ff d2                	call   *%edx
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	eb 05                	jmp    801e35 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801e30:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801e35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <seek>:

int
seek(int fdnum, off_t offset)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e40:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	e8 0f fc ff ff       	call   801a5b <fd_lookup>
  801e4c:	83 c4 08             	add    $0x8,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 0e                	js     801e61 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801e53:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e59:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	53                   	push   %ebx
  801e67:	83 ec 14             	sub    $0x14,%esp
  801e6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	53                   	push   %ebx
  801e72:	e8 e4 fb ff ff       	call   801a5b <fd_lookup>
  801e77:	83 c4 08             	add    $0x8,%esp
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 5f                	js     801edd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e7e:	83 ec 08             	sub    $0x8,%esp
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e88:	ff 30                	pushl  (%eax)
  801e8a:	e8 22 fc ff ff       	call   801ab1 <dev_lookup>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 47                	js     801edd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e99:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e9d:	75 21                	jne    801ec0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e9f:	a1 0c 80 80 00       	mov    0x80800c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ea4:	8b 40 48             	mov    0x48(%eax),%eax
  801ea7:	83 ec 04             	sub    $0x4,%esp
  801eaa:	53                   	push   %ebx
  801eab:	50                   	push   %eax
  801eac:	68 f8 2e 80 00       	push   $0x802ef8
  801eb1:	e8 7a ed ff ff       	call   800c30 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ebe:	eb 1d                	jmp    801edd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec3:	8b 52 18             	mov    0x18(%edx),%edx
  801ec6:	85 d2                	test   %edx,%edx
  801ec8:	74 0e                	je     801ed8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	ff 75 0c             	pushl  0xc(%ebp)
  801ed0:	50                   	push   %eax
  801ed1:	ff d2                	call   *%edx
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	eb 05                	jmp    801edd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801ed8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 14             	sub    $0x14,%esp
  801ee9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	ff 75 08             	pushl  0x8(%ebp)
  801ef3:	e8 63 fb ff ff       	call   801a5b <fd_lookup>
  801ef8:	83 c4 08             	add    $0x8,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 52                	js     801f51 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eff:	83 ec 08             	sub    $0x8,%esp
  801f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f09:	ff 30                	pushl  (%eax)
  801f0b:	e8 a1 fb ff ff       	call   801ab1 <dev_lookup>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 3a                	js     801f51 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801f1e:	74 2c                	je     801f4c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801f20:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801f23:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801f2a:	00 00 00 
	stat->st_isdir = 0;
  801f2d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f34:	00 00 00 
	stat->st_dev = dev;
  801f37:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801f3d:	83 ec 08             	sub    $0x8,%esp
  801f40:	53                   	push   %ebx
  801f41:	ff 75 f0             	pushl  -0x10(%ebp)
  801f44:	ff 50 14             	call   *0x14(%eax)
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	eb 05                	jmp    801f51 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801f4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	6a 00                	push   $0x0
  801f60:	ff 75 08             	pushl  0x8(%ebp)
  801f63:	e8 78 01 00 00       	call   8020e0 <open>
  801f68:	89 c3                	mov    %eax,%ebx
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 1b                	js     801f8c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801f71:	83 ec 08             	sub    $0x8,%esp
  801f74:	ff 75 0c             	pushl  0xc(%ebp)
  801f77:	50                   	push   %eax
  801f78:	e8 65 ff ff ff       	call   801ee2 <fstat>
  801f7d:	89 c6                	mov    %eax,%esi
	close(fd);
  801f7f:	89 1c 24             	mov    %ebx,(%esp)
  801f82:	e8 18 fc ff ff       	call   801b9f <close>
	return r;
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	89 f3                	mov    %esi,%ebx
}
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    
  801f95:	00 00                	add    %al,(%eax)
	...

00801f98 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801fa1:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801fa8:	75 12                	jne    801fbc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	6a 01                	push   $0x1
  801faf:	e8 be f9 ff ff       	call   801972 <ipc_find_env>
  801fb4:	a3 00 80 80 00       	mov    %eax,0x808000
  801fb9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801fbc:	6a 07                	push   $0x7
  801fbe:	68 00 90 80 00       	push   $0x809000
  801fc3:	53                   	push   %ebx
  801fc4:	ff 35 00 80 80 00    	pushl  0x808000
  801fca:	e8 4e f9 ff ff       	call   80191d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801fcf:	83 c4 0c             	add    $0xc,%esp
  801fd2:	6a 00                	push   $0x0
  801fd4:	56                   	push   %esi
  801fd5:	6a 00                	push   $0x0
  801fd7:	e8 cc f8 ff ff       	call   8018a8 <ipc_recv>
}
  801fdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	53                   	push   %ebx
  801fe7:	83 ec 04             	sub    $0x4,%esp
  801fea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ff3:	a3 00 90 80 00       	mov    %eax,0x809000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801ff8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffd:	b8 05 00 00 00       	mov    $0x5,%eax
  802002:	e8 91 ff ff ff       	call   801f98 <fsipc>
  802007:	85 c0                	test   %eax,%eax
  802009:	78 2c                	js     802037 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80200b:	83 ec 08             	sub    $0x8,%esp
  80200e:	68 00 90 80 00       	push   $0x809000
  802013:	53                   	push   %ebx
  802014:	e8 cd f1 ff ff       	call   8011e6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802019:	a1 80 90 80 00       	mov    0x809080,%eax
  80201e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802024:	a1 84 90 80 00       	mov    0x809084,%eax
  802029:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802037:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	8b 40 0c             	mov    0xc(%eax),%eax
  802048:	a3 00 90 80 00       	mov    %eax,0x809000
	return fsipc(FSREQ_FLUSH, NULL);
  80204d:	ba 00 00 00 00       	mov    $0x0,%edx
  802052:	b8 06 00 00 00       	mov    $0x6,%eax
  802057:	e8 3c ff ff ff       	call   801f98 <fsipc>
}
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	56                   	push   %esi
  802062:	53                   	push   %ebx
  802063:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	8b 40 0c             	mov    0xc(%eax),%eax
  80206c:	a3 00 90 80 00       	mov    %eax,0x809000
	fsipcbuf.read.req_n = n;
  802071:	89 35 04 90 80 00    	mov    %esi,0x809004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802077:	ba 00 00 00 00       	mov    $0x0,%edx
  80207c:	b8 03 00 00 00       	mov    $0x3,%eax
  802081:	e8 12 ff ff ff       	call   801f98 <fsipc>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 4b                	js     8020d7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80208c:	39 c6                	cmp    %eax,%esi
  80208e:	73 16                	jae    8020a6 <devfile_read+0x48>
  802090:	68 68 2f 80 00       	push   $0x802f68
  802095:	68 3d 29 80 00       	push   $0x80293d
  80209a:	6a 7d                	push   $0x7d
  80209c:	68 6f 2f 80 00       	push   $0x802f6f
  8020a1:	e8 b2 ea ff ff       	call   800b58 <_panic>
	assert(r <= PGSIZE);
  8020a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020ab:	7e 16                	jle    8020c3 <devfile_read+0x65>
  8020ad:	68 7a 2f 80 00       	push   $0x802f7a
  8020b2:	68 3d 29 80 00       	push   $0x80293d
  8020b7:	6a 7e                	push   $0x7e
  8020b9:	68 6f 2f 80 00       	push   $0x802f6f
  8020be:	e8 95 ea ff ff       	call   800b58 <_panic>
	memmove(buf, &fsipcbuf, r);
  8020c3:	83 ec 04             	sub    $0x4,%esp
  8020c6:	50                   	push   %eax
  8020c7:	68 00 90 80 00       	push   $0x809000
  8020cc:	ff 75 0c             	pushl  0xc(%ebp)
  8020cf:	e8 d3 f2 ff ff       	call   8013a7 <memmove>
	return r;
  8020d4:	83 c4 10             	add    $0x10,%esp
}
  8020d7:	89 d8                	mov    %ebx,%eax
  8020d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	56                   	push   %esi
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 1c             	sub    $0x1c,%esp
  8020e8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8020eb:	56                   	push   %esi
  8020ec:	e8 a3 f0 ff ff       	call   801194 <strlen>
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020f9:	7f 65                	jg     802160 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8020fb:	83 ec 0c             	sub    $0xc,%esp
  8020fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802101:	50                   	push   %eax
  802102:	e8 e1 f8 ff ff       	call   8019e8 <fd_alloc>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	85 c0                	test   %eax,%eax
  80210e:	78 55                	js     802165 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	56                   	push   %esi
  802114:	68 00 90 80 00       	push   $0x809000
  802119:	e8 c8 f0 ff ff       	call   8011e6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80211e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802121:	a3 00 94 80 00       	mov    %eax,0x809400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802126:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802129:	b8 01 00 00 00       	mov    $0x1,%eax
  80212e:	e8 65 fe ff ff       	call   801f98 <fsipc>
  802133:	89 c3                	mov    %eax,%ebx
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	85 c0                	test   %eax,%eax
  80213a:	79 12                	jns    80214e <open+0x6e>
		fd_close(fd, 0);
  80213c:	83 ec 08             	sub    $0x8,%esp
  80213f:	6a 00                	push   $0x0
  802141:	ff 75 f4             	pushl  -0xc(%ebp)
  802144:	e8 ce f9 ff ff       	call   801b17 <fd_close>
		return r;
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	eb 17                	jmp    802165 <open+0x85>
	}

	return fd2num(fd);
  80214e:	83 ec 0c             	sub    $0xc,%esp
  802151:	ff 75 f4             	pushl  -0xc(%ebp)
  802154:	e8 67 f8 ff ff       	call   8019c0 <fd2num>
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	eb 05                	jmp    802165 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802160:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802165:	89 d8                	mov    %ebx,%eax
  802167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    
	...

00802170 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802176:	89 c2                	mov    %eax,%edx
  802178:	c1 ea 16             	shr    $0x16,%edx
  80217b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802182:	f6 c2 01             	test   $0x1,%dl
  802185:	74 1e                	je     8021a5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802187:	c1 e8 0c             	shr    $0xc,%eax
  80218a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802191:	a8 01                	test   $0x1,%al
  802193:	74 17                	je     8021ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802195:	c1 e8 0c             	shr    $0xc,%eax
  802198:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80219f:	ef 
  8021a0:	0f b7 c0             	movzwl %ax,%eax
  8021a3:	eb 0c                	jmp    8021b1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8021a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021aa:	eb 05                	jmp    8021b1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021b1:	c9                   	leave  
  8021b2:	c3                   	ret    
	...

008021b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	56                   	push   %esi
  8021b8:	53                   	push   %ebx
  8021b9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021bc:	83 ec 0c             	sub    $0xc,%esp
  8021bf:	ff 75 08             	pushl  0x8(%ebp)
  8021c2:	e8 09 f8 ff ff       	call   8019d0 <fd2data>
  8021c7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021c9:	83 c4 08             	add    $0x8,%esp
  8021cc:	68 86 2f 80 00       	push   $0x802f86
  8021d1:	56                   	push   %esi
  8021d2:	e8 0f f0 ff ff       	call   8011e6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021d7:	8b 43 04             	mov    0x4(%ebx),%eax
  8021da:	2b 03                	sub    (%ebx),%eax
  8021dc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021e2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021e9:	00 00 00 
	stat->st_dev = &devpipe;
  8021ec:	c7 86 88 00 00 00 60 	movl   $0x807060,0x88(%esi)
  8021f3:	70 80 00 
	return 0;
}
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fe:	5b                   	pop    %ebx
  8021ff:	5e                   	pop    %esi
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	53                   	push   %ebx
  802206:	83 ec 0c             	sub    $0xc,%esp
  802209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80220c:	53                   	push   %ebx
  80220d:	6a 00                	push   $0x0
  80220f:	e8 9e f4 ff ff       	call   8016b2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802214:	89 1c 24             	mov    %ebx,(%esp)
  802217:	e8 b4 f7 ff ff       	call   8019d0 <fd2data>
  80221c:	83 c4 08             	add    $0x8,%esp
  80221f:	50                   	push   %eax
  802220:	6a 00                	push   $0x0
  802222:	e8 8b f4 ff ff       	call   8016b2 <sys_page_unmap>
}
  802227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	57                   	push   %edi
  802230:	56                   	push   %esi
  802231:	53                   	push   %ebx
  802232:	83 ec 1c             	sub    $0x1c,%esp
  802235:	89 c7                	mov    %eax,%edi
  802237:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80223a:	a1 0c 80 80 00       	mov    0x80800c,%eax
  80223f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802242:	83 ec 0c             	sub    $0xc,%esp
  802245:	57                   	push   %edi
  802246:	e8 25 ff ff ff       	call   802170 <pageref>
  80224b:	89 c6                	mov    %eax,%esi
  80224d:	83 c4 04             	add    $0x4,%esp
  802250:	ff 75 e4             	pushl  -0x1c(%ebp)
  802253:	e8 18 ff ff ff       	call   802170 <pageref>
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	39 c6                	cmp    %eax,%esi
  80225d:	0f 94 c0             	sete   %al
  802260:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802263:	8b 15 0c 80 80 00    	mov    0x80800c,%edx
  802269:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80226c:	39 cb                	cmp    %ecx,%ebx
  80226e:	75 08                	jne    802278 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	c9                   	leave  
  802277:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802278:	83 f8 01             	cmp    $0x1,%eax
  80227b:	75 bd                	jne    80223a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80227d:	8b 42 58             	mov    0x58(%edx),%eax
  802280:	6a 01                	push   $0x1
  802282:	50                   	push   %eax
  802283:	53                   	push   %ebx
  802284:	68 8d 2f 80 00       	push   $0x802f8d
  802289:	e8 a2 e9 ff ff       	call   800c30 <cprintf>
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	eb a7                	jmp    80223a <_pipeisclosed+0xe>

00802293 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	57                   	push   %edi
  802297:	56                   	push   %esi
  802298:	53                   	push   %ebx
  802299:	83 ec 28             	sub    $0x28,%esp
  80229c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80229f:	56                   	push   %esi
  8022a0:	e8 2b f7 ff ff       	call   8019d0 <fd2data>
  8022a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022a7:	83 c4 10             	add    $0x10,%esp
  8022aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ae:	75 4a                	jne    8022fa <devpipe_write+0x67>
  8022b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8022b5:	eb 56                	jmp    80230d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022b7:	89 da                	mov    %ebx,%edx
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	e8 6c ff ff ff       	call   80222c <_pipeisclosed>
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	75 4d                	jne    802311 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022c4:	e8 78 f3 ff ff       	call   801641 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c9:	8b 43 04             	mov    0x4(%ebx),%eax
  8022cc:	8b 13                	mov    (%ebx),%edx
  8022ce:	83 c2 20             	add    $0x20,%edx
  8022d1:	39 d0                	cmp    %edx,%eax
  8022d3:	73 e2                	jae    8022b7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022d5:	89 c2                	mov    %eax,%edx
  8022d7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022dd:	79 05                	jns    8022e4 <devpipe_write+0x51>
  8022df:	4a                   	dec    %edx
  8022e0:	83 ca e0             	or     $0xffffffe0,%edx
  8022e3:	42                   	inc    %edx
  8022e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022e7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8022ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022ee:	40                   	inc    %eax
  8022ef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022f2:	47                   	inc    %edi
  8022f3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8022f6:	77 07                	ja     8022ff <devpipe_write+0x6c>
  8022f8:	eb 13                	jmp    80230d <devpipe_write+0x7a>
  8022fa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022ff:	8b 43 04             	mov    0x4(%ebx),%eax
  802302:	8b 13                	mov    (%ebx),%edx
  802304:	83 c2 20             	add    $0x20,%edx
  802307:	39 d0                	cmp    %edx,%eax
  802309:	73 ac                	jae    8022b7 <devpipe_write+0x24>
  80230b:	eb c8                	jmp    8022d5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80230d:	89 f8                	mov    %edi,%eax
  80230f:	eb 05                	jmp    802316 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802311:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802319:	5b                   	pop    %ebx
  80231a:	5e                   	pop    %esi
  80231b:	5f                   	pop    %edi
  80231c:	c9                   	leave  
  80231d:	c3                   	ret    

0080231e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 18             	sub    $0x18,%esp
  802327:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80232a:	57                   	push   %edi
  80232b:	e8 a0 f6 ff ff       	call   8019d0 <fd2data>
  802330:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802339:	75 44                	jne    80237f <devpipe_read+0x61>
  80233b:	be 00 00 00 00       	mov    $0x0,%esi
  802340:	eb 4f                	jmp    802391 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802342:	89 f0                	mov    %esi,%eax
  802344:	eb 54                	jmp    80239a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802346:	89 da                	mov    %ebx,%edx
  802348:	89 f8                	mov    %edi,%eax
  80234a:	e8 dd fe ff ff       	call   80222c <_pipeisclosed>
  80234f:	85 c0                	test   %eax,%eax
  802351:	75 42                	jne    802395 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802353:	e8 e9 f2 ff ff       	call   801641 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802358:	8b 03                	mov    (%ebx),%eax
  80235a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80235d:	74 e7                	je     802346 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80235f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802364:	79 05                	jns    80236b <devpipe_read+0x4d>
  802366:	48                   	dec    %eax
  802367:	83 c8 e0             	or     $0xffffffe0,%eax
  80236a:	40                   	inc    %eax
  80236b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80236f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802372:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802375:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802377:	46                   	inc    %esi
  802378:	39 75 10             	cmp    %esi,0x10(%ebp)
  80237b:	77 07                	ja     802384 <devpipe_read+0x66>
  80237d:	eb 12                	jmp    802391 <devpipe_read+0x73>
  80237f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802384:	8b 03                	mov    (%ebx),%eax
  802386:	3b 43 04             	cmp    0x4(%ebx),%eax
  802389:	75 d4                	jne    80235f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80238b:	85 f6                	test   %esi,%esi
  80238d:	75 b3                	jne    802342 <devpipe_read+0x24>
  80238f:	eb b5                	jmp    802346 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802391:	89 f0                	mov    %esi,%eax
  802393:	eb 05                	jmp    80239a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802395:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80239a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239d:	5b                   	pop    %ebx
  80239e:	5e                   	pop    %esi
  80239f:	5f                   	pop    %edi
  8023a0:	c9                   	leave  
  8023a1:	c3                   	ret    

008023a2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	57                   	push   %edi
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	83 ec 28             	sub    $0x28,%esp
  8023ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023b1:	50                   	push   %eax
  8023b2:	e8 31 f6 ff ff       	call   8019e8 <fd_alloc>
  8023b7:	89 c3                	mov    %eax,%ebx
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	0f 88 24 01 00 00    	js     8024e8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c4:	83 ec 04             	sub    $0x4,%esp
  8023c7:	68 07 04 00 00       	push   $0x407
  8023cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023cf:	6a 00                	push   $0x0
  8023d1:	e8 92 f2 ff ff       	call   801668 <sys_page_alloc>
  8023d6:	89 c3                	mov    %eax,%ebx
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	0f 88 05 01 00 00    	js     8024e8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023e9:	50                   	push   %eax
  8023ea:	e8 f9 f5 ff ff       	call   8019e8 <fd_alloc>
  8023ef:	89 c3                	mov    %eax,%ebx
  8023f1:	83 c4 10             	add    $0x10,%esp
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	0f 88 dc 00 00 00    	js     8024d8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023fc:	83 ec 04             	sub    $0x4,%esp
  8023ff:	68 07 04 00 00       	push   $0x407
  802404:	ff 75 e0             	pushl  -0x20(%ebp)
  802407:	6a 00                	push   $0x0
  802409:	e8 5a f2 ff ff       	call   801668 <sys_page_alloc>
  80240e:	89 c3                	mov    %eax,%ebx
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	85 c0                	test   %eax,%eax
  802415:	0f 88 bd 00 00 00    	js     8024d8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80241b:	83 ec 0c             	sub    $0xc,%esp
  80241e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802421:	e8 aa f5 ff ff       	call   8019d0 <fd2data>
  802426:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802428:	83 c4 0c             	add    $0xc,%esp
  80242b:	68 07 04 00 00       	push   $0x407
  802430:	50                   	push   %eax
  802431:	6a 00                	push   $0x0
  802433:	e8 30 f2 ff ff       	call   801668 <sys_page_alloc>
  802438:	89 c3                	mov    %eax,%ebx
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	85 c0                	test   %eax,%eax
  80243f:	0f 88 83 00 00 00    	js     8024c8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802445:	83 ec 0c             	sub    $0xc,%esp
  802448:	ff 75 e0             	pushl  -0x20(%ebp)
  80244b:	e8 80 f5 ff ff       	call   8019d0 <fd2data>
  802450:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802457:	50                   	push   %eax
  802458:	6a 00                	push   $0x0
  80245a:	56                   	push   %esi
  80245b:	6a 00                	push   $0x0
  80245d:	e8 2a f2 ff ff       	call   80168c <sys_page_map>
  802462:	89 c3                	mov    %eax,%ebx
  802464:	83 c4 20             	add    $0x20,%esp
  802467:	85 c0                	test   %eax,%eax
  802469:	78 4f                	js     8024ba <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80246b:	8b 15 60 70 80 00    	mov    0x807060,%edx
  802471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802474:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802476:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802479:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802480:	8b 15 60 70 80 00    	mov    0x807060,%edx
  802486:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802489:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80248b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80248e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802495:	83 ec 0c             	sub    $0xc,%esp
  802498:	ff 75 e4             	pushl  -0x1c(%ebp)
  80249b:	e8 20 f5 ff ff       	call   8019c0 <fd2num>
  8024a0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8024a2:	83 c4 04             	add    $0x4,%esp
  8024a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8024a8:	e8 13 f5 ff ff       	call   8019c0 <fd2num>
  8024ad:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b8:	eb 2e                	jmp    8024e8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8024ba:	83 ec 08             	sub    $0x8,%esp
  8024bd:	56                   	push   %esi
  8024be:	6a 00                	push   $0x0
  8024c0:	e8 ed f1 ff ff       	call   8016b2 <sys_page_unmap>
  8024c5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024c8:	83 ec 08             	sub    $0x8,%esp
  8024cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8024ce:	6a 00                	push   $0x0
  8024d0:	e8 dd f1 ff ff       	call   8016b2 <sys_page_unmap>
  8024d5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024d8:	83 ec 08             	sub    $0x8,%esp
  8024db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024de:	6a 00                	push   $0x0
  8024e0:	e8 cd f1 ff ff       	call   8016b2 <sys_page_unmap>
  8024e5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	c9                   	leave  
  8024f1:	c3                   	ret    

008024f2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024fb:	50                   	push   %eax
  8024fc:	ff 75 08             	pushl  0x8(%ebp)
  8024ff:	e8 57 f5 ff ff       	call   801a5b <fd_lookup>
  802504:	83 c4 10             	add    $0x10,%esp
  802507:	85 c0                	test   %eax,%eax
  802509:	78 18                	js     802523 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80250b:	83 ec 0c             	sub    $0xc,%esp
  80250e:	ff 75 f4             	pushl  -0xc(%ebp)
  802511:	e8 ba f4 ff ff       	call   8019d0 <fd2data>
	return _pipeisclosed(fd, p);
  802516:	89 c2                	mov    %eax,%edx
  802518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251b:	e8 0c fd ff ff       	call   80222c <_pipeisclosed>
  802520:	83 c4 10             	add    $0x10,%esp
}
  802523:	c9                   	leave  
  802524:	c3                   	ret    
  802525:	00 00                	add    %al,(%eax)
	...

00802528 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802528:	55                   	push   %ebp
  802529:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80252b:	b8 00 00 00 00       	mov    $0x0,%eax
  802530:	c9                   	leave  
  802531:	c3                   	ret    

00802532 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802538:	68 a5 2f 80 00       	push   $0x802fa5
  80253d:	ff 75 0c             	pushl  0xc(%ebp)
  802540:	e8 a1 ec ff ff       	call   8011e6 <strcpy>
	return 0;
}
  802545:	b8 00 00 00 00       	mov    $0x0,%eax
  80254a:	c9                   	leave  
  80254b:	c3                   	ret    

0080254c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	57                   	push   %edi
  802550:	56                   	push   %esi
  802551:	53                   	push   %ebx
  802552:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802558:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80255c:	74 45                	je     8025a3 <devcons_write+0x57>
  80255e:	b8 00 00 00 00       	mov    $0x0,%eax
  802563:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802568:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80256e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802571:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802573:	83 fb 7f             	cmp    $0x7f,%ebx
  802576:	76 05                	jbe    80257d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802578:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80257d:	83 ec 04             	sub    $0x4,%esp
  802580:	53                   	push   %ebx
  802581:	03 45 0c             	add    0xc(%ebp),%eax
  802584:	50                   	push   %eax
  802585:	57                   	push   %edi
  802586:	e8 1c ee ff ff       	call   8013a7 <memmove>
		sys_cputs(buf, m);
  80258b:	83 c4 08             	add    $0x8,%esp
  80258e:	53                   	push   %ebx
  80258f:	57                   	push   %edi
  802590:	e8 1c f0 ff ff       	call   8015b1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802595:	01 de                	add    %ebx,%esi
  802597:	89 f0                	mov    %esi,%eax
  802599:	83 c4 10             	add    $0x10,%esp
  80259c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80259f:	72 cd                	jb     80256e <devcons_write+0x22>
  8025a1:	eb 05                	jmp    8025a8 <devcons_write+0x5c>
  8025a3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025a8:	89 f0                	mov    %esi,%eax
  8025aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	c9                   	leave  
  8025b1:	c3                   	ret    

008025b2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025b2:	55                   	push   %ebp
  8025b3:	89 e5                	mov    %esp,%ebp
  8025b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025bc:	75 07                	jne    8025c5 <devcons_read+0x13>
  8025be:	eb 25                	jmp    8025e5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025c0:	e8 7c f0 ff ff       	call   801641 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025c5:	e8 0d f0 ff ff       	call   8015d7 <sys_cgetc>
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	74 f2                	je     8025c0 <devcons_read+0xe>
  8025ce:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025d0:	85 c0                	test   %eax,%eax
  8025d2:	78 1d                	js     8025f1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025d4:	83 f8 04             	cmp    $0x4,%eax
  8025d7:	74 13                	je     8025ec <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8025d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025dc:	88 10                	mov    %dl,(%eax)
	return 1;
  8025de:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e3:	eb 0c                	jmp    8025f1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8025e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ea:	eb 05                	jmp    8025f1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025f1:	c9                   	leave  
  8025f2:	c3                   	ret    

008025f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025f3:	55                   	push   %ebp
  8025f4:	89 e5                	mov    %esp,%ebp
  8025f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025ff:	6a 01                	push   $0x1
  802601:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802604:	50                   	push   %eax
  802605:	e8 a7 ef ff ff       	call   8015b1 <sys_cputs>
  80260a:	83 c4 10             	add    $0x10,%esp
}
  80260d:	c9                   	leave  
  80260e:	c3                   	ret    

0080260f <getchar>:

int
getchar(void)
{
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802615:	6a 01                	push   $0x1
  802617:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80261a:	50                   	push   %eax
  80261b:	6a 00                	push   $0x0
  80261d:	e8 ba f6 ff ff       	call   801cdc <read>
	if (r < 0)
  802622:	83 c4 10             	add    $0x10,%esp
  802625:	85 c0                	test   %eax,%eax
  802627:	78 0f                	js     802638 <getchar+0x29>
		return r;
	if (r < 1)
  802629:	85 c0                	test   %eax,%eax
  80262b:	7e 06                	jle    802633 <getchar+0x24>
		return -E_EOF;
	return c;
  80262d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802631:	eb 05                	jmp    802638 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802633:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802638:	c9                   	leave  
  802639:	c3                   	ret    

0080263a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80263a:	55                   	push   %ebp
  80263b:	89 e5                	mov    %esp,%ebp
  80263d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802643:	50                   	push   %eax
  802644:	ff 75 08             	pushl  0x8(%ebp)
  802647:	e8 0f f4 ff ff       	call   801a5b <fd_lookup>
  80264c:	83 c4 10             	add    $0x10,%esp
  80264f:	85 c0                	test   %eax,%eax
  802651:	78 11                	js     802664 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802656:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  80265c:	39 10                	cmp    %edx,(%eax)
  80265e:	0f 94 c0             	sete   %al
  802661:	0f b6 c0             	movzbl %al,%eax
}
  802664:	c9                   	leave  
  802665:	c3                   	ret    

00802666 <opencons>:

int
opencons(void)
{
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80266c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80266f:	50                   	push   %eax
  802670:	e8 73 f3 ff ff       	call   8019e8 <fd_alloc>
  802675:	83 c4 10             	add    $0x10,%esp
  802678:	85 c0                	test   %eax,%eax
  80267a:	78 3a                	js     8026b6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80267c:	83 ec 04             	sub    $0x4,%esp
  80267f:	68 07 04 00 00       	push   $0x407
  802684:	ff 75 f4             	pushl  -0xc(%ebp)
  802687:	6a 00                	push   $0x0
  802689:	e8 da ef ff ff       	call   801668 <sys_page_alloc>
  80268e:	83 c4 10             	add    $0x10,%esp
  802691:	85 c0                	test   %eax,%eax
  802693:	78 21                	js     8026b6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802695:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  80269b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026aa:	83 ec 0c             	sub    $0xc,%esp
  8026ad:	50                   	push   %eax
  8026ae:	e8 0d f3 ff ff       	call   8019c0 <fd2num>
  8026b3:	83 c4 10             	add    $0x10,%esp
}
  8026b6:	c9                   	leave  
  8026b7:	c3                   	ret    

008026b8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	57                   	push   %edi
  8026bc:	56                   	push   %esi
  8026bd:	83 ec 10             	sub    $0x10,%esp
  8026c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026c6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8026c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8026cc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026cf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026d2:	85 c0                	test   %eax,%eax
  8026d4:	75 2e                	jne    802704 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8026d6:	39 f1                	cmp    %esi,%ecx
  8026d8:	77 5a                	ja     802734 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026da:	85 c9                	test   %ecx,%ecx
  8026dc:	75 0b                	jne    8026e9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026de:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e3:	31 d2                	xor    %edx,%edx
  8026e5:	f7 f1                	div    %ecx
  8026e7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026e9:	31 d2                	xor    %edx,%edx
  8026eb:	89 f0                	mov    %esi,%eax
  8026ed:	f7 f1                	div    %ecx
  8026ef:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026f1:	89 f8                	mov    %edi,%eax
  8026f3:	f7 f1                	div    %ecx
  8026f5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026f7:	89 f8                	mov    %edi,%eax
  8026f9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026fb:	83 c4 10             	add    $0x10,%esp
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	c9                   	leave  
  802701:	c3                   	ret    
  802702:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802704:	39 f0                	cmp    %esi,%eax
  802706:	77 1c                	ja     802724 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802708:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80270b:	83 f7 1f             	xor    $0x1f,%edi
  80270e:	75 3c                	jne    80274c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802710:	39 f0                	cmp    %esi,%eax
  802712:	0f 82 90 00 00 00    	jb     8027a8 <__udivdi3+0xf0>
  802718:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80271b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80271e:	0f 86 84 00 00 00    	jbe    8027a8 <__udivdi3+0xf0>
  802724:	31 f6                	xor    %esi,%esi
  802726:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802728:	89 f8                	mov    %edi,%eax
  80272a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80272c:	83 c4 10             	add    $0x10,%esp
  80272f:	5e                   	pop    %esi
  802730:	5f                   	pop    %edi
  802731:	c9                   	leave  
  802732:	c3                   	ret    
  802733:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802734:	89 f2                	mov    %esi,%edx
  802736:	89 f8                	mov    %edi,%eax
  802738:	f7 f1                	div    %ecx
  80273a:	89 c7                	mov    %eax,%edi
  80273c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80273e:	89 f8                	mov    %edi,%eax
  802740:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802742:	83 c4 10             	add    $0x10,%esp
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	c9                   	leave  
  802748:	c3                   	ret    
  802749:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80274c:	89 f9                	mov    %edi,%ecx
  80274e:	d3 e0                	shl    %cl,%eax
  802750:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802753:	b8 20 00 00 00       	mov    $0x20,%eax
  802758:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80275a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80275d:	88 c1                	mov    %al,%cl
  80275f:	d3 ea                	shr    %cl,%edx
  802761:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802764:	09 ca                	or     %ecx,%edx
  802766:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80276c:	89 f9                	mov    %edi,%ecx
  80276e:	d3 e2                	shl    %cl,%edx
  802770:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802773:	89 f2                	mov    %esi,%edx
  802775:	88 c1                	mov    %al,%cl
  802777:	d3 ea                	shr    %cl,%edx
  802779:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80277c:	89 f2                	mov    %esi,%edx
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	d3 e2                	shl    %cl,%edx
  802782:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802785:	88 c1                	mov    %al,%cl
  802787:	d3 ee                	shr    %cl,%esi
  802789:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80278b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80278e:	89 f0                	mov    %esi,%eax
  802790:	89 ca                	mov    %ecx,%edx
  802792:	f7 75 ec             	divl   -0x14(%ebp)
  802795:	89 d1                	mov    %edx,%ecx
  802797:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802799:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80279c:	39 d1                	cmp    %edx,%ecx
  80279e:	72 28                	jb     8027c8 <__udivdi3+0x110>
  8027a0:	74 1a                	je     8027bc <__udivdi3+0x104>
  8027a2:	89 f7                	mov    %esi,%edi
  8027a4:	31 f6                	xor    %esi,%esi
  8027a6:	eb 80                	jmp    802728 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027a8:	31 f6                	xor    %esi,%esi
  8027aa:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027af:	89 f8                	mov    %edi,%eax
  8027b1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027b3:	83 c4 10             	add    $0x10,%esp
  8027b6:	5e                   	pop    %esi
  8027b7:	5f                   	pop    %edi
  8027b8:	c9                   	leave  
  8027b9:	c3                   	ret    
  8027ba:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8027bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027bf:	89 f9                	mov    %edi,%ecx
  8027c1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027c3:	39 c2                	cmp    %eax,%edx
  8027c5:	73 db                	jae    8027a2 <__udivdi3+0xea>
  8027c7:	90                   	nop
		{
		  q0--;
  8027c8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027cb:	31 f6                	xor    %esi,%esi
  8027cd:	e9 56 ff ff ff       	jmp    802728 <__udivdi3+0x70>
	...

008027d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027d4:	55                   	push   %ebp
  8027d5:	89 e5                	mov    %esp,%ebp
  8027d7:	57                   	push   %edi
  8027d8:	56                   	push   %esi
  8027d9:	83 ec 20             	sub    $0x20,%esp
  8027dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8027df:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8027e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8027e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8027eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8027ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8027f1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027f3:	85 ff                	test   %edi,%edi
  8027f5:	75 15                	jne    80280c <__umoddi3+0x38>
    {
      if (d0 > n1)
  8027f7:	39 f1                	cmp    %esi,%ecx
  8027f9:	0f 86 99 00 00 00    	jbe    802898 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027ff:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802801:	89 d0                	mov    %edx,%eax
  802803:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802805:	83 c4 20             	add    $0x20,%esp
  802808:	5e                   	pop    %esi
  802809:	5f                   	pop    %edi
  80280a:	c9                   	leave  
  80280b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80280c:	39 f7                	cmp    %esi,%edi
  80280e:	0f 87 a4 00 00 00    	ja     8028b8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802814:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802817:	83 f0 1f             	xor    $0x1f,%eax
  80281a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80281d:	0f 84 a1 00 00 00    	je     8028c4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802823:	89 f8                	mov    %edi,%eax
  802825:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802828:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80282a:	bf 20 00 00 00       	mov    $0x20,%edi
  80282f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802832:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 ea                	shr    %cl,%edx
  802839:	09 c2                	or     %eax,%edx
  80283b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80283e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802841:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802844:	d3 e0                	shl    %cl,%eax
  802846:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802849:	89 f2                	mov    %esi,%edx
  80284b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80284d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802850:	d3 e0                	shl    %cl,%eax
  802852:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802855:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802858:	89 f9                	mov    %edi,%ecx
  80285a:	d3 e8                	shr    %cl,%eax
  80285c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80285e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802860:	89 f2                	mov    %esi,%edx
  802862:	f7 75 f0             	divl   -0x10(%ebp)
  802865:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802867:	f7 65 f4             	mull   -0xc(%ebp)
  80286a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80286d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80286f:	39 d6                	cmp    %edx,%esi
  802871:	72 71                	jb     8028e4 <__umoddi3+0x110>
  802873:	74 7f                	je     8028f4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802875:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802878:	29 c8                	sub    %ecx,%eax
  80287a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80287c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80287f:	d3 e8                	shr    %cl,%eax
  802881:	89 f2                	mov    %esi,%edx
  802883:	89 f9                	mov    %edi,%ecx
  802885:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802887:	09 d0                	or     %edx,%eax
  802889:	89 f2                	mov    %esi,%edx
  80288b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80288e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802890:	83 c4 20             	add    $0x20,%esp
  802893:	5e                   	pop    %esi
  802894:	5f                   	pop    %edi
  802895:	c9                   	leave  
  802896:	c3                   	ret    
  802897:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802898:	85 c9                	test   %ecx,%ecx
  80289a:	75 0b                	jne    8028a7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80289c:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a1:	31 d2                	xor    %edx,%edx
  8028a3:	f7 f1                	div    %ecx
  8028a5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028a7:	89 f0                	mov    %esi,%eax
  8028a9:	31 d2                	xor    %edx,%edx
  8028ab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028b0:	f7 f1                	div    %ecx
  8028b2:	e9 4a ff ff ff       	jmp    802801 <__umoddi3+0x2d>
  8028b7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028b8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028ba:	83 c4 20             	add    $0x20,%esp
  8028bd:	5e                   	pop    %esi
  8028be:	5f                   	pop    %edi
  8028bf:	c9                   	leave  
  8028c0:	c3                   	ret    
  8028c1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028c4:	39 f7                	cmp    %esi,%edi
  8028c6:	72 05                	jb     8028cd <__umoddi3+0xf9>
  8028c8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8028cb:	77 0c                	ja     8028d9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028cd:	89 f2                	mov    %esi,%edx
  8028cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028d2:	29 c8                	sub    %ecx,%eax
  8028d4:	19 fa                	sbb    %edi,%edx
  8028d6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8028d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028dc:	83 c4 20             	add    $0x20,%esp
  8028df:	5e                   	pop    %esi
  8028e0:	5f                   	pop    %edi
  8028e1:	c9                   	leave  
  8028e2:	c3                   	ret    
  8028e3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028e4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8028e7:	89 c1                	mov    %eax,%ecx
  8028e9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8028ec:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8028ef:	eb 84                	jmp    802875 <__umoddi3+0xa1>
  8028f1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028f4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8028f7:	72 eb                	jb     8028e4 <__umoddi3+0x110>
  8028f9:	89 f2                	mov    %esi,%edx
  8028fb:	e9 75 ff ff ff       	jmp    802875 <__umoddi3+0xa1>
