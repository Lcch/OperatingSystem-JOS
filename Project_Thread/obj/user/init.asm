
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 87 03 00 00       	call   8003b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	85 db                	test   %ebx,%ebx
  800041:	7e 1a                	jle    80005d <sum+0x29>
char bss[6000];

int
sum(const char *s, int n)
{
	int i, tot = 0;
  800043:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800048:	ba 00 00 00 00       	mov    $0x0,%edx
		tot ^= i * s[i];
  80004d:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800051:	0f af ca             	imul   %edx,%ecx
  800054:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	42                   	inc    %edx
  800057:	39 da                	cmp    %ebx,%edx
  800059:	75 f2                	jne    80004d <sum+0x19>
  80005b:	eb 05                	jmp    800062 <sum+0x2e>
char bss[6000];

int
sum(const char *s, int n)
{
	int i, tot = 0;
  80005d:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
		tot ^= i * s[i];
	return tot;
}
  800062:	5b                   	pop    %ebx
  800063:	5e                   	pop    %esi
  800064:	c9                   	leave  
  800065:	c3                   	ret    

00800066 <umain>:

void
umain(int argc, char **argv)
{
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	57                   	push   %edi
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	81 ec 18 01 00 00    	sub    $0x118,%esp
  800072:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800075:	68 a0 28 80 00       	push   $0x8028a0
  80007a:	e8 79 04 00 00       	call   8004f8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007f:	83 c4 08             	add    $0x8,%esp
  800082:	68 70 17 00 00       	push   $0x1770
  800087:	68 00 30 80 00       	push   $0x803000
  80008c:	e8 a3 ff ff ff       	call   800034 <sum>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800099:	74 18                	je     8000b3 <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  80009b:	83 ec 04             	sub    $0x4,%esp
  80009e:	68 9e 98 0f 00       	push   $0xf989e
  8000a3:	50                   	push   %eax
  8000a4:	68 68 29 80 00       	push   $0x802968
  8000a9:	e8 4a 04 00 00       	call   8004f8 <cprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	eb 10                	jmp    8000c3 <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	68 af 28 80 00       	push   $0x8028af
  8000bb:	e8 38 04 00 00       	call   8004f8 <cprintf>
  8000c0:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	68 70 17 00 00       	push   $0x1770
  8000cb:	68 20 50 80 00       	push   $0x805020
  8000d0:	e8 5f ff ff ff       	call   800034 <sum>
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	74 13                	je     8000ef <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000dc:	83 ec 08             	sub    $0x8,%esp
  8000df:	50                   	push   %eax
  8000e0:	68 a4 29 80 00       	push   $0x8029a4
  8000e5:	e8 0e 04 00 00       	call   8004f8 <cprintf>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	eb 10                	jmp    8000ff <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 c6 28 80 00       	push   $0x8028c6
  8000f7:	e8 fc 03 00 00       	call   8004f8 <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 dc 28 80 00       	push   $0x8028dc
  800107:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010d:	50                   	push   %eax
  80010e:	e8 b8 09 00 00       	call   800acb <strcat>
	for (i = 0; i < argc; i++) {
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80011a:	7e 3c                	jle    800158 <umain+0xf2>
  80011c:	be 00 00 00 00       	mov    $0x0,%esi
		strcat(args, " '");
  800121:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	68 e8 28 80 00       	push   $0x8028e8
  80012f:	53                   	push   %ebx
  800130:	e8 96 09 00 00       	call   800acb <strcat>
		strcat(args, argv[i]);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff 34 b7             	pushl  (%edi,%esi,4)
  80013b:	53                   	push   %ebx
  80013c:	e8 8a 09 00 00       	call   800acb <strcat>
		strcat(args, "'");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	68 e9 28 80 00       	push   $0x8028e9
  800149:	53                   	push   %ebx
  80014a:	e8 7c 09 00 00       	call   800acb <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80014f:	46                   	inc    %esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	39 75 08             	cmp    %esi,0x8(%ebp)
  800156:	7f cf                	jg     800127 <umain+0xc1>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800161:	50                   	push   %eax
  800162:	68 eb 28 80 00       	push   $0x8028eb
  800167:	e8 8c 03 00 00       	call   8004f8 <cprintf>

	cprintf("init: running sh\n");
  80016c:	c7 04 24 ef 28 80 00 	movl   $0x8028ef,(%esp)
  800173:	e8 80 03 00 00       	call   8004f8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017f:	e8 37 11 00 00       	call   8012bb <close>
	if ((r = opencons()) < 0)
  800184:	e8 dd 01 00 00       	call   800366 <opencons>
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	85 c0                	test   %eax,%eax
  80018e:	79 12                	jns    8001a2 <umain+0x13c>
		panic("opencons: %e", r);
  800190:	50                   	push   %eax
  800191:	68 01 29 80 00       	push   $0x802901
  800196:	6a 37                	push   $0x37
  800198:	68 0e 29 80 00       	push   $0x80290e
  80019d:	e8 7e 02 00 00       	call   800420 <_panic>
	if (r != 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	74 12                	je     8001b8 <umain+0x152>
		panic("first opencons used fd %d", r);
  8001a6:	50                   	push   %eax
  8001a7:	68 1a 29 80 00       	push   $0x80291a
  8001ac:	6a 39                	push   $0x39
  8001ae:	68 0e 29 80 00       	push   $0x80290e
  8001b3:	e8 68 02 00 00       	call   800420 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	6a 01                	push   $0x1
  8001bd:	6a 00                	push   $0x0
  8001bf:	e8 45 11 00 00       	call   801309 <dup>
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	79 12                	jns    8001dd <umain+0x177>
		panic("dup: %e", r);
  8001cb:	50                   	push   %eax
  8001cc:	68 34 29 80 00       	push   $0x802934
  8001d1:	6a 3b                	push   $0x3b
  8001d3:	68 0e 29 80 00       	push   $0x80290e
  8001d8:	e8 43 02 00 00       	call   800420 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	68 3c 29 80 00       	push   $0x80293c
  8001e5:	e8 0e 03 00 00       	call   8004f8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001ea:	83 c4 0c             	add    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	68 50 29 80 00       	push   $0x802950
  8001f4:	68 4f 29 80 00       	push   $0x80294f
  8001f9:	e8 64 1e 00 00       	call   802062 <spawnl>
		if (r < 0) {
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	85 c0                	test   %eax,%eax
  800203:	79 13                	jns    800218 <umain+0x1b2>
			cprintf("init: spawn sh: %e\n", r);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	50                   	push   %eax
  800209:	68 53 29 80 00       	push   $0x802953
  80020e:	e8 e5 02 00 00       	call   8004f8 <cprintf>
			continue;
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	eb c5                	jmp    8001dd <umain+0x177>
		}
		wait(r);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	e8 3f 22 00 00       	call   802460 <wait>
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	eb b7                	jmp    8001dd <umain+0x177>
	...

00800228 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80022b:	b8 00 00 00 00       	mov    $0x0,%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800238:	68 d3 29 80 00       	push   $0x8029d3
  80023d:	ff 75 0c             	pushl  0xc(%ebp)
  800240:	e8 69 08 00 00       	call   800aae <strcpy>
	return 0;
}
  800245:	b8 00 00 00 00       	mov    $0x0,%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800258:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80025c:	74 45                	je     8002a3 <devcons_write+0x57>
  80025e:	b8 00 00 00 00       	mov    $0x0,%eax
  800263:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800268:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80026e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800271:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800273:	83 fb 7f             	cmp    $0x7f,%ebx
  800276:	76 05                	jbe    80027d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800278:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	53                   	push   %ebx
  800281:	03 45 0c             	add    0xc(%ebp),%eax
  800284:	50                   	push   %eax
  800285:	57                   	push   %edi
  800286:	e8 e4 09 00 00       	call   800c6f <memmove>
		sys_cputs(buf, m);
  80028b:	83 c4 08             	add    $0x8,%esp
  80028e:	53                   	push   %ebx
  80028f:	57                   	push   %edi
  800290:	e8 e4 0b 00 00       	call   800e79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800295:	01 de                	add    %ebx,%esi
  800297:	89 f0                	mov    %esi,%eax
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80029f:	72 cd                	jb     80026e <devcons_write+0x22>
  8002a1:	eb 05                	jmp    8002a8 <devcons_write+0x5c>
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002a8:	89 f0                	mov    %esi,%eax
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002bc:	75 07                	jne    8002c5 <devcons_read+0x13>
  8002be:	eb 25                	jmp    8002e5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002c0:	e8 44 0c 00 00       	call   800f09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002c5:	e8 d5 0b 00 00       	call   800e9f <sys_cgetc>
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	74 f2                	je     8002c0 <devcons_read+0xe>
  8002ce:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	78 1d                	js     8002f1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002d4:	83 f8 04             	cmp    $0x4,%eax
  8002d7:	74 13                	je     8002ec <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dc:	88 10                	mov    %dl,(%eax)
	return 1;
  8002de:	b8 01 00 00 00       	mov    $0x1,%eax
  8002e3:	eb 0c                	jmp    8002f1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	eb 05                	jmp    8002f1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002ff:	6a 01                	push   $0x1
  800301:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800304:	50                   	push   %eax
  800305:	e8 6f 0b 00 00       	call   800e79 <sys_cputs>
  80030a:	83 c4 10             	add    $0x10,%esp
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <getchar>:

int
getchar(void)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800315:	6a 01                	push   $0x1
  800317:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80031a:	50                   	push   %eax
  80031b:	6a 00                	push   $0x0
  80031d:	e8 d6 10 00 00       	call   8013f8 <read>
	if (r < 0)
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	85 c0                	test   %eax,%eax
  800327:	78 0f                	js     800338 <getchar+0x29>
		return r;
	if (r < 1)
  800329:	85 c0                	test   %eax,%eax
  80032b:	7e 06                	jle    800333 <getchar+0x24>
		return -E_EOF;
	return c;
  80032d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800331:	eb 05                	jmp    800338 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800333:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800343:	50                   	push   %eax
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 2b 0e 00 00       	call   801177 <fd_lookup>
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	85 c0                	test   %eax,%eax
  800351:	78 11                	js     800364 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800356:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80035c:	39 10                	cmp    %edx,(%eax)
  80035e:	0f 94 c0             	sete   %al
  800361:	0f b6 c0             	movzbl %al,%eax
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <opencons>:

int
opencons(void)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80036c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036f:	50                   	push   %eax
  800370:	e8 8f 0d 00 00       	call   801104 <fd_alloc>
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	85 c0                	test   %eax,%eax
  80037a:	78 3a                	js     8003b6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	68 07 04 00 00       	push   $0x407
  800384:	ff 75 f4             	pushl  -0xc(%ebp)
  800387:	6a 00                	push   $0x0
  800389:	e8 a2 0b 00 00       	call   800f30 <sys_page_alloc>
  80038e:	83 c4 10             	add    $0x10,%esp
  800391:	85 c0                	test   %eax,%eax
  800393:	78 21                	js     8003b6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800395:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80039b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80039e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	50                   	push   %eax
  8003ae:	e8 29 0d 00 00       	call   8010dc <fd2num>
  8003b3:	83 c4 10             	add    $0x10,%esp
}
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    

008003b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
  8003bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8003c3:	e8 1d 0b 00 00       	call   800ee5 <sys_getenvid>
  8003c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003cd:	89 c2                	mov    %eax,%edx
  8003cf:	c1 e2 07             	shl    $0x7,%edx
  8003d2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8003d9:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003de:	85 f6                	test   %esi,%esi
  8003e0:	7e 07                	jle    8003e9 <libmain+0x31>
		binaryname = argv[0];
  8003e2:	8b 03                	mov    (%ebx),%eax
  8003e4:	a3 8c 47 80 00       	mov    %eax,0x80478c
	// call user main routine
	umain(argc, argv);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	53                   	push   %ebx
  8003ed:	56                   	push   %esi
  8003ee:	e8 73 fc ff ff       	call   800066 <umain>

	// exit gracefully
	exit();
  8003f3:	e8 0c 00 00 00       	call   800404 <exit>
  8003f8:	83 c4 10             	add    $0x10,%esp
}
  8003fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003fe:	5b                   	pop    %ebx
  8003ff:	5e                   	pop    %esi
  800400:	c9                   	leave  
  800401:	c3                   	ret    
	...

00800404 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80040a:	e8 d7 0e 00 00       	call   8012e6 <close_all>
	sys_env_destroy(0);
  80040f:	83 ec 0c             	sub    $0xc,%esp
  800412:	6a 00                	push   $0x0
  800414:	e8 aa 0a 00 00       	call   800ec3 <sys_env_destroy>
  800419:	83 c4 10             	add    $0x10,%esp
}
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    
	...

00800420 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800425:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800428:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  80042e:	e8 b2 0a 00 00       	call   800ee5 <sys_getenvid>
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	53                   	push   %ebx
  80043d:	50                   	push   %eax
  80043e:	68 ec 29 80 00       	push   $0x8029ec
  800443:	e8 b0 00 00 00       	call   8004f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800448:	83 c4 18             	add    $0x18,%esp
  80044b:	56                   	push   %esi
  80044c:	ff 75 10             	pushl  0x10(%ebp)
  80044f:	e8 53 00 00 00       	call   8004a7 <vcprintf>
	cprintf("\n");
  800454:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
  80045b:	e8 98 00 00 00       	call   8004f8 <cprintf>
  800460:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800463:	cc                   	int3   
  800464:	eb fd                	jmp    800463 <_panic+0x43>
	...

00800468 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	53                   	push   %ebx
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800472:	8b 03                	mov    (%ebx),%eax
  800474:	8b 55 08             	mov    0x8(%ebp),%edx
  800477:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80047b:	40                   	inc    %eax
  80047c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80047e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800483:	75 1a                	jne    80049f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	68 ff 00 00 00       	push   $0xff
  80048d:	8d 43 08             	lea    0x8(%ebx),%eax
  800490:	50                   	push   %eax
  800491:	e8 e3 09 00 00       	call   800e79 <sys_cputs>
		b->idx = 0;
  800496:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80049c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80049f:	ff 43 04             	incl   0x4(%ebx)
}
  8004a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a5:	c9                   	leave  
  8004a6:	c3                   	ret    

008004a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
  8004aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004b7:	00 00 00 
	b.cnt = 0;
  8004ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	68 68 04 80 00       	push   $0x800468
  8004d6:	e8 82 01 00 00       	call   80065d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004db:	83 c4 08             	add    $0x8,%esp
  8004de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ea:	50                   	push   %eax
  8004eb:	e8 89 09 00 00       	call   800e79 <sys_cputs>

	return b.cnt;
}
  8004f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    

008004f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 08             	pushl  0x8(%ebp)
  800505:	e8 9d ff ff ff       	call   8004a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 2c             	sub    $0x2c,%esp
  800515:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800518:	89 d6                	mov    %edx,%esi
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	8b 45 10             	mov    0x10(%ebp),%eax
  800529:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80052c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80052f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800532:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800539:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80053c:	72 0c                	jb     80054a <printnum+0x3e>
  80053e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800541:	76 07                	jbe    80054a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800543:	4b                   	dec    %ebx
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f 31                	jg     800579 <printnum+0x6d>
  800548:	eb 3f                	jmp    800589 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	57                   	push   %edi
  80054e:	4b                   	dec    %ebx
  80054f:	53                   	push   %ebx
  800550:	50                   	push   %eax
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 d4             	pushl  -0x2c(%ebp)
  800557:	ff 75 d0             	pushl  -0x30(%ebp)
  80055a:	ff 75 dc             	pushl  -0x24(%ebp)
  80055d:	ff 75 d8             	pushl  -0x28(%ebp)
  800560:	e8 d7 20 00 00       	call   80263c <__udivdi3>
  800565:	83 c4 18             	add    $0x18,%esp
  800568:	52                   	push   %edx
  800569:	50                   	push   %eax
  80056a:	89 f2                	mov    %esi,%edx
  80056c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056f:	e8 98 ff ff ff       	call   80050c <printnum>
  800574:	83 c4 20             	add    $0x20,%esp
  800577:	eb 10                	jmp    800589 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	56                   	push   %esi
  80057d:	57                   	push   %edi
  80057e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800581:	4b                   	dec    %ebx
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	85 db                	test   %ebx,%ebx
  800587:	7f f0                	jg     800579 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	56                   	push   %esi
  80058d:	83 ec 04             	sub    $0x4,%esp
  800590:	ff 75 d4             	pushl  -0x2c(%ebp)
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	ff 75 dc             	pushl  -0x24(%ebp)
  800599:	ff 75 d8             	pushl  -0x28(%ebp)
  80059c:	e8 b7 21 00 00       	call   802758 <__umoddi3>
  8005a1:	83 c4 14             	add    $0x14,%esp
  8005a4:	0f be 80 0f 2a 80 00 	movsbl 0x802a0f(%eax),%eax
  8005ab:	50                   	push   %eax
  8005ac:	ff 55 e4             	call   *-0x1c(%ebp)
  8005af:	83 c4 10             	add    $0x10,%esp
}
  8005b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5f                   	pop    %edi
  8005b8:	c9                   	leave  
  8005b9:	c3                   	ret    

008005ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005bd:	83 fa 01             	cmp    $0x1,%edx
  8005c0:	7e 0e                	jle    8005d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c2:	8b 10                	mov    (%eax),%edx
  8005c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005c7:	89 08                	mov    %ecx,(%eax)
  8005c9:	8b 02                	mov    (%edx),%eax
  8005cb:	8b 52 04             	mov    0x4(%edx),%edx
  8005ce:	eb 22                	jmp    8005f2 <getuint+0x38>
	else if (lflag)
  8005d0:	85 d2                	test   %edx,%edx
  8005d2:	74 10                	je     8005e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d9:	89 08                	mov    %ecx,(%eax)
  8005db:	8b 02                	mov    (%edx),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e2:	eb 0e                	jmp    8005f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 02                	mov    (%edx),%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005f7:	83 fa 01             	cmp    $0x1,%edx
  8005fa:	7e 0e                	jle    80060a <getint+0x16>
		return va_arg(*ap, long long);
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800601:	89 08                	mov    %ecx,(%eax)
  800603:	8b 02                	mov    (%edx),%eax
  800605:	8b 52 04             	mov    0x4(%edx),%edx
  800608:	eb 1a                	jmp    800624 <getint+0x30>
	else if (lflag)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 0c                	je     80061a <getint+0x26>
		return va_arg(*ap, long);
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8d 4a 04             	lea    0x4(%edx),%ecx
  800613:	89 08                	mov    %ecx,(%eax)
  800615:	8b 02                	mov    (%edx),%eax
  800617:	99                   	cltd   
  800618:	eb 0a                	jmp    800624 <getint+0x30>
	else
		return va_arg(*ap, int);
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061f:	89 08                	mov    %ecx,(%eax)
  800621:	8b 02                	mov    (%edx),%eax
  800623:	99                   	cltd   
}
  800624:	c9                   	leave  
  800625:	c3                   	ret    

00800626 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80062c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	3b 50 04             	cmp    0x4(%eax),%edx
  800634:	73 08                	jae    80063e <sprintputch+0x18>
		*b->buf++ = ch;
  800636:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800639:	88 0a                	mov    %cl,(%edx)
  80063b:	42                   	inc    %edx
  80063c:	89 10                	mov    %edx,(%eax)
}
  80063e:	c9                   	leave  
  80063f:	c3                   	ret    

00800640 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800649:	50                   	push   %eax
  80064a:	ff 75 10             	pushl  0x10(%ebp)
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	ff 75 08             	pushl  0x8(%ebp)
  800653:	e8 05 00 00 00       	call   80065d <vprintfmt>
	va_end(ap);
  800658:	83 c4 10             	add    $0x10,%esp
}
  80065b:	c9                   	leave  
  80065c:	c3                   	ret    

0080065d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	57                   	push   %edi
  800661:	56                   	push   %esi
  800662:	53                   	push   %ebx
  800663:	83 ec 2c             	sub    $0x2c,%esp
  800666:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800669:	8b 75 10             	mov    0x10(%ebp),%esi
  80066c:	eb 13                	jmp    800681 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80066e:	85 c0                	test   %eax,%eax
  800670:	0f 84 6d 03 00 00    	je     8009e3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	57                   	push   %edi
  80067a:	50                   	push   %eax
  80067b:	ff 55 08             	call   *0x8(%ebp)
  80067e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800681:	0f b6 06             	movzbl (%esi),%eax
  800684:	46                   	inc    %esi
  800685:	83 f8 25             	cmp    $0x25,%eax
  800688:	75 e4                	jne    80066e <vprintfmt+0x11>
  80068a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80068e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800695:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80069c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a8:	eb 28                	jmp    8006d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8006b0:	eb 20                	jmp    8006d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006b4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8006b8:	eb 18                	jmp    8006d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006c3:	eb 0d                	jmp    8006d2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8a 06                	mov    (%esi),%al
  8006d4:	0f b6 d0             	movzbl %al,%edx
  8006d7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006da:	83 e8 23             	sub    $0x23,%eax
  8006dd:	3c 55                	cmp    $0x55,%al
  8006df:	0f 87 e0 02 00 00    	ja     8009c5 <vprintfmt+0x368>
  8006e5:	0f b6 c0             	movzbl %al,%eax
  8006e8:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006ef:	83 ea 30             	sub    $0x30,%edx
  8006f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8006f5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8006f8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006fb:	83 fa 09             	cmp    $0x9,%edx
  8006fe:	77 44                	ja     800744 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800700:	89 de                	mov    %ebx,%esi
  800702:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800705:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800706:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800709:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80070d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800710:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800713:	83 fb 09             	cmp    $0x9,%ebx
  800716:	76 ed                	jbe    800705 <vprintfmt+0xa8>
  800718:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80071b:	eb 29                	jmp    800746 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 50 04             	lea    0x4(%eax),%edx
  800723:	89 55 14             	mov    %edx,0x14(%ebp)
  800726:	8b 00                	mov    (%eax),%eax
  800728:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80072d:	eb 17                	jmp    800746 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80072f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800733:	78 85                	js     8006ba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800735:	89 de                	mov    %ebx,%esi
  800737:	eb 99                	jmp    8006d2 <vprintfmt+0x75>
  800739:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80073b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800742:	eb 8e                	jmp    8006d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800744:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800746:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074a:	79 86                	jns    8006d2 <vprintfmt+0x75>
  80074c:	e9 74 ff ff ff       	jmp    8006c5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800751:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	89 de                	mov    %ebx,%esi
  800754:	e9 79 ff ff ff       	jmp    8006d2 <vprintfmt+0x75>
  800759:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 50 04             	lea    0x4(%eax),%edx
  800762:	89 55 14             	mov    %edx,0x14(%ebp)
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	57                   	push   %edi
  800769:	ff 30                	pushl  (%eax)
  80076b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800771:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800774:	e9 08 ff ff ff       	jmp    800681 <vprintfmt+0x24>
  800779:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 04             	lea    0x4(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)
  800785:	8b 00                	mov    (%eax),%eax
  800787:	85 c0                	test   %eax,%eax
  800789:	79 02                	jns    80078d <vprintfmt+0x130>
  80078b:	f7 d8                	neg    %eax
  80078d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80078f:	83 f8 0f             	cmp    $0xf,%eax
  800792:	7f 0b                	jg     80079f <vprintfmt+0x142>
  800794:	8b 04 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%eax
  80079b:	85 c0                	test   %eax,%eax
  80079d:	75 1a                	jne    8007b9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80079f:	52                   	push   %edx
  8007a0:	68 27 2a 80 00       	push   $0x802a27
  8007a5:	57                   	push   %edi
  8007a6:	ff 75 08             	pushl  0x8(%ebp)
  8007a9:	e8 92 fe ff ff       	call   800640 <printfmt>
  8007ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007b4:	e9 c8 fe ff ff       	jmp    800681 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8007b9:	50                   	push   %eax
  8007ba:	68 f1 2d 80 00       	push   $0x802df1
  8007bf:	57                   	push   %edi
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 78 fe ff ff       	call   800640 <printfmt>
  8007c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007ce:	e9 ae fe ff ff       	jmp    800681 <vprintfmt+0x24>
  8007d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007d6:	89 de                	mov    %ebx,%esi
  8007d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e7:	8b 00                	mov    (%eax),%eax
  8007e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	75 07                	jne    8007f7 <vprintfmt+0x19a>
				p = "(null)";
  8007f0:	c7 45 d0 20 2a 80 00 	movl   $0x802a20,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007f7:	85 db                	test   %ebx,%ebx
  8007f9:	7e 42                	jle    80083d <vprintfmt+0x1e0>
  8007fb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8007ff:	74 3c                	je     80083d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	51                   	push   %ecx
  800805:	ff 75 d0             	pushl  -0x30(%ebp)
  800808:	e8 6f 02 00 00       	call   800a7c <strnlen>
  80080d:	29 c3                	sub    %eax,%ebx
  80080f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	85 db                	test   %ebx,%ebx
  800817:	7e 24                	jle    80083d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800819:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80081d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800820:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	57                   	push   %edi
  800827:	53                   	push   %ebx
  800828:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082b:	4e                   	dec    %esi
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 f6                	test   %esi,%esi
  800831:	7f f0                	jg     800823 <vprintfmt+0x1c6>
  800833:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800836:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800840:	0f be 02             	movsbl (%edx),%eax
  800843:	85 c0                	test   %eax,%eax
  800845:	75 47                	jne    80088e <vprintfmt+0x231>
  800847:	eb 37                	jmp    800880 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800849:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084d:	74 16                	je     800865 <vprintfmt+0x208>
  80084f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800852:	83 fa 5e             	cmp    $0x5e,%edx
  800855:	76 0e                	jbe    800865 <vprintfmt+0x208>
					putch('?', putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	57                   	push   %edi
  80085b:	6a 3f                	push   $0x3f
  80085d:	ff 55 08             	call   *0x8(%ebp)
  800860:	83 c4 10             	add    $0x10,%esp
  800863:	eb 0b                	jmp    800870 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	57                   	push   %edi
  800869:	50                   	push   %eax
  80086a:	ff 55 08             	call   *0x8(%ebp)
  80086d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800870:	ff 4d e4             	decl   -0x1c(%ebp)
  800873:	0f be 03             	movsbl (%ebx),%eax
  800876:	85 c0                	test   %eax,%eax
  800878:	74 03                	je     80087d <vprintfmt+0x220>
  80087a:	43                   	inc    %ebx
  80087b:	eb 1b                	jmp    800898 <vprintfmt+0x23b>
  80087d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800880:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800884:	7f 1e                	jg     8008a4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800889:	e9 f3 fd ff ff       	jmp    800681 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800891:	43                   	inc    %ebx
  800892:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800895:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800898:	85 f6                	test   %esi,%esi
  80089a:	78 ad                	js     800849 <vprintfmt+0x1ec>
  80089c:	4e                   	dec    %esi
  80089d:	79 aa                	jns    800849 <vprintfmt+0x1ec>
  80089f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008a2:	eb dc                	jmp    800880 <vprintfmt+0x223>
  8008a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	57                   	push   %edi
  8008ab:	6a 20                	push   $0x20
  8008ad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b0:	4b                   	dec    %ebx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	85 db                	test   %ebx,%ebx
  8008b6:	7f ef                	jg     8008a7 <vprintfmt+0x24a>
  8008b8:	e9 c4 fd ff ff       	jmp    800681 <vprintfmt+0x24>
  8008bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c0:	89 ca                	mov    %ecx,%edx
  8008c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c5:	e8 2a fd ff ff       	call   8005f4 <getint>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	78 0a                	js     8008dc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008d7:	e9 b0 00 00 00       	jmp    80098c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	57                   	push   %edi
  8008e0:	6a 2d                	push   $0x2d
  8008e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e5:	f7 db                	neg    %ebx
  8008e7:	83 d6 00             	adc    $0x0,%esi
  8008ea:	f7 de                	neg    %esi
  8008ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f4:	e9 93 00 00 00       	jmp    80098c <vprintfmt+0x32f>
  8008f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008fc:	89 ca                	mov    %ecx,%edx
  8008fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800901:	e8 b4 fc ff ff       	call   8005ba <getuint>
  800906:	89 c3                	mov    %eax,%ebx
  800908:	89 d6                	mov    %edx,%esi
			base = 10;
  80090a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80090f:	eb 7b                	jmp    80098c <vprintfmt+0x32f>
  800911:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800914:	89 ca                	mov    %ecx,%edx
  800916:	8d 45 14             	lea    0x14(%ebp),%eax
  800919:	e8 d6 fc ff ff       	call   8005f4 <getint>
  80091e:	89 c3                	mov    %eax,%ebx
  800920:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800922:	85 d2                	test   %edx,%edx
  800924:	78 07                	js     80092d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800926:	b8 08 00 00 00       	mov    $0x8,%eax
  80092b:	eb 5f                	jmp    80098c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80092d:	83 ec 08             	sub    $0x8,%esp
  800930:	57                   	push   %edi
  800931:	6a 2d                	push   $0x2d
  800933:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800936:	f7 db                	neg    %ebx
  800938:	83 d6 00             	adc    $0x0,%esi
  80093b:	f7 de                	neg    %esi
  80093d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800940:	b8 08 00 00 00       	mov    $0x8,%eax
  800945:	eb 45                	jmp    80098c <vprintfmt+0x32f>
  800947:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80094a:	83 ec 08             	sub    $0x8,%esp
  80094d:	57                   	push   %edi
  80094e:	6a 30                	push   $0x30
  800950:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800953:	83 c4 08             	add    $0x8,%esp
  800956:	57                   	push   %edi
  800957:	6a 78                	push   $0x78
  800959:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8d 50 04             	lea    0x4(%eax),%edx
  800962:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800965:	8b 18                	mov    (%eax),%ebx
  800967:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80096c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80096f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800974:	eb 16                	jmp    80098c <vprintfmt+0x32f>
  800976:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800979:	89 ca                	mov    %ecx,%edx
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
  80097e:	e8 37 fc ff ff       	call   8005ba <getuint>
  800983:	89 c3                	mov    %eax,%ebx
  800985:	89 d6                	mov    %edx,%esi
			base = 16;
  800987:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800993:	52                   	push   %edx
  800994:	ff 75 e4             	pushl  -0x1c(%ebp)
  800997:	50                   	push   %eax
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	89 fa                	mov    %edi,%edx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	e8 68 fb ff ff       	call   80050c <printnum>
			break;
  8009a4:	83 c4 20             	add    $0x20,%esp
  8009a7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009aa:	e9 d2 fc ff ff       	jmp    800681 <vprintfmt+0x24>
  8009af:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	57                   	push   %edi
  8009b6:	52                   	push   %edx
  8009b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009c0:	e9 bc fc ff ff       	jmp    800681 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	57                   	push   %edi
  8009c9:	6a 25                	push   $0x25
  8009cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	eb 02                	jmp    8009d5 <vprintfmt+0x378>
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8009d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009dc:	75 f5                	jne    8009d3 <vprintfmt+0x376>
  8009de:	e9 9e fc ff ff       	jmp    800681 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8009e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 18             	sub    $0x18,%esp
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a08:	85 c0                	test   %eax,%eax
  800a0a:	74 26                	je     800a32 <vsnprintf+0x47>
  800a0c:	85 d2                	test   %edx,%edx
  800a0e:	7e 29                	jle    800a39 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a10:	ff 75 14             	pushl  0x14(%ebp)
  800a13:	ff 75 10             	pushl  0x10(%ebp)
  800a16:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a19:	50                   	push   %eax
  800a1a:	68 26 06 80 00       	push   $0x800626
  800a1f:	e8 39 fc ff ff       	call   80065d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	eb 0c                	jmp    800a3e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a37:	eb 05                	jmp    800a3e <vsnprintf+0x53>
  800a39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a46:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a49:	50                   	push   %eax
  800a4a:	ff 75 10             	pushl  0x10(%ebp)
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	ff 75 08             	pushl  0x8(%ebp)
  800a53:	e8 93 ff ff ff       	call   8009eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    
	...

00800a5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a62:	80 3a 00             	cmpb   $0x0,(%edx)
  800a65:	74 0e                	je     800a75 <strlen+0x19>
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a6c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a71:	75 f9                	jne    800a6c <strlen+0x10>
  800a73:	eb 05                	jmp    800a7a <strlen+0x1e>
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a85:	85 d2                	test   %edx,%edx
  800a87:	74 17                	je     800aa0 <strnlen+0x24>
  800a89:	80 39 00             	cmpb   $0x0,(%ecx)
  800a8c:	74 19                	je     800aa7 <strnlen+0x2b>
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a93:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a94:	39 d0                	cmp    %edx,%eax
  800a96:	74 14                	je     800aac <strnlen+0x30>
  800a98:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a9c:	75 f5                	jne    800a93 <strnlen+0x17>
  800a9e:	eb 0c                	jmp    800aac <strnlen+0x30>
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa5:	eb 05                	jmp    800aac <strnlen+0x30>
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	53                   	push   %ebx
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ac0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac3:	42                   	inc    %edx
  800ac4:	84 c9                	test   %cl,%cl
  800ac6:	75 f5                	jne    800abd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad2:	53                   	push   %ebx
  800ad3:	e8 84 ff ff ff       	call   800a5c <strlen>
  800ad8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800adb:	ff 75 0c             	pushl  0xc(%ebp)
  800ade:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ae1:	50                   	push   %eax
  800ae2:	e8 c7 ff ff ff       	call   800aae <strcpy>
	return dst;
}
  800ae7:	89 d8                	mov    %ebx,%eax
  800ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800afc:	85 f6                	test   %esi,%esi
  800afe:	74 15                	je     800b15 <strncpy+0x27>
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b05:	8a 1a                	mov    (%edx),%bl
  800b07:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0a:	80 3a 01             	cmpb   $0x1,(%edx)
  800b0d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b10:	41                   	inc    %ecx
  800b11:	39 ce                	cmp    %ecx,%esi
  800b13:	77 f0                	ja     800b05 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    

00800b19 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b25:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b28:	85 f6                	test   %esi,%esi
  800b2a:	74 32                	je     800b5e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800b2c:	83 fe 01             	cmp    $0x1,%esi
  800b2f:	74 22                	je     800b53 <strlcpy+0x3a>
  800b31:	8a 0b                	mov    (%ebx),%cl
  800b33:	84 c9                	test   %cl,%cl
  800b35:	74 20                	je     800b57 <strlcpy+0x3e>
  800b37:	89 f8                	mov    %edi,%eax
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b3e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b41:	88 08                	mov    %cl,(%eax)
  800b43:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b44:	39 f2                	cmp    %esi,%edx
  800b46:	74 11                	je     800b59 <strlcpy+0x40>
  800b48:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800b4c:	42                   	inc    %edx
  800b4d:	84 c9                	test   %cl,%cl
  800b4f:	75 f0                	jne    800b41 <strlcpy+0x28>
  800b51:	eb 06                	jmp    800b59 <strlcpy+0x40>
  800b53:	89 f8                	mov    %edi,%eax
  800b55:	eb 02                	jmp    800b59 <strlcpy+0x40>
  800b57:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b59:	c6 00 00             	movb   $0x0,(%eax)
  800b5c:	eb 02                	jmp    800b60 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b5e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800b60:	29 f8                	sub    %edi,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b70:	8a 01                	mov    (%ecx),%al
  800b72:	84 c0                	test   %al,%al
  800b74:	74 10                	je     800b86 <strcmp+0x1f>
  800b76:	3a 02                	cmp    (%edx),%al
  800b78:	75 0c                	jne    800b86 <strcmp+0x1f>
		p++, q++;
  800b7a:	41                   	inc    %ecx
  800b7b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b7c:	8a 01                	mov    (%ecx),%al
  800b7e:	84 c0                	test   %al,%al
  800b80:	74 04                	je     800b86 <strcmp+0x1f>
  800b82:	3a 02                	cmp    (%edx),%al
  800b84:	74 f4                	je     800b7a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b86:	0f b6 c0             	movzbl %al,%eax
  800b89:	0f b6 12             	movzbl (%edx),%edx
  800b8c:	29 d0                	sub    %edx,%eax
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	53                   	push   %ebx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	74 1b                	je     800bbc <strncmp+0x2c>
  800ba1:	8a 1a                	mov    (%edx),%bl
  800ba3:	84 db                	test   %bl,%bl
  800ba5:	74 24                	je     800bcb <strncmp+0x3b>
  800ba7:	3a 19                	cmp    (%ecx),%bl
  800ba9:	75 20                	jne    800bcb <strncmp+0x3b>
  800bab:	48                   	dec    %eax
  800bac:	74 15                	je     800bc3 <strncmp+0x33>
		n--, p++, q++;
  800bae:	42                   	inc    %edx
  800baf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bb0:	8a 1a                	mov    (%edx),%bl
  800bb2:	84 db                	test   %bl,%bl
  800bb4:	74 15                	je     800bcb <strncmp+0x3b>
  800bb6:	3a 19                	cmp    (%ecx),%bl
  800bb8:	74 f1                	je     800bab <strncmp+0x1b>
  800bba:	eb 0f                	jmp    800bcb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	eb 05                	jmp    800bc8 <strncmp+0x38>
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bcb:	0f b6 02             	movzbl (%edx),%eax
  800bce:	0f b6 11             	movzbl (%ecx),%edx
  800bd1:	29 d0                	sub    %edx,%eax
  800bd3:	eb f3                	jmp    800bc8 <strncmp+0x38>

00800bd5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bde:	8a 10                	mov    (%eax),%dl
  800be0:	84 d2                	test   %dl,%dl
  800be2:	74 18                	je     800bfc <strchr+0x27>
		if (*s == c)
  800be4:	38 ca                	cmp    %cl,%dl
  800be6:	75 06                	jne    800bee <strchr+0x19>
  800be8:	eb 17                	jmp    800c01 <strchr+0x2c>
  800bea:	38 ca                	cmp    %cl,%dl
  800bec:	74 13                	je     800c01 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bee:	40                   	inc    %eax
  800bef:	8a 10                	mov    (%eax),%dl
  800bf1:	84 d2                	test   %dl,%dl
  800bf3:	75 f5                	jne    800bea <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfa:	eb 05                	jmp    800c01 <strchr+0x2c>
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c0c:	8a 10                	mov    (%eax),%dl
  800c0e:	84 d2                	test   %dl,%dl
  800c10:	74 11                	je     800c23 <strfind+0x20>
		if (*s == c)
  800c12:	38 ca                	cmp    %cl,%dl
  800c14:	75 06                	jne    800c1c <strfind+0x19>
  800c16:	eb 0b                	jmp    800c23 <strfind+0x20>
  800c18:	38 ca                	cmp    %cl,%dl
  800c1a:	74 07                	je     800c23 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c1c:	40                   	inc    %eax
  800c1d:	8a 10                	mov    (%eax),%dl
  800c1f:	84 d2                	test   %dl,%dl
  800c21:	75 f5                	jne    800c18 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c34:	85 c9                	test   %ecx,%ecx
  800c36:	74 30                	je     800c68 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c38:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3e:	75 25                	jne    800c65 <memset+0x40>
  800c40:	f6 c1 03             	test   $0x3,%cl
  800c43:	75 20                	jne    800c65 <memset+0x40>
		c &= 0xFF;
  800c45:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	c1 e3 08             	shl    $0x8,%ebx
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	c1 e6 18             	shl    $0x18,%esi
  800c52:	89 d0                	mov    %edx,%eax
  800c54:	c1 e0 10             	shl    $0x10,%eax
  800c57:	09 f0                	or     %esi,%eax
  800c59:	09 d0                	or     %edx,%eax
  800c5b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c5d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c60:	fc                   	cld    
  800c61:	f3 ab                	rep stos %eax,%es:(%edi)
  800c63:	eb 03                	jmp    800c68 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c65:	fc                   	cld    
  800c66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7d:	39 c6                	cmp    %eax,%esi
  800c7f:	73 34                	jae    800cb5 <memmove+0x46>
  800c81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	73 2d                	jae    800cb5 <memmove+0x46>
		s += n;
		d += n;
  800c88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8b:	f6 c2 03             	test   $0x3,%dl
  800c8e:	75 1b                	jne    800cab <memmove+0x3c>
  800c90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c96:	75 13                	jne    800cab <memmove+0x3c>
  800c98:	f6 c1 03             	test   $0x3,%cl
  800c9b:	75 0e                	jne    800cab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9d:	83 ef 04             	sub    $0x4,%edi
  800ca0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ca6:	fd                   	std    
  800ca7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca9:	eb 07                	jmp    800cb2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cab:	4f                   	dec    %edi
  800cac:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800caf:	fd                   	std    
  800cb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb2:	fc                   	cld    
  800cb3:	eb 20                	jmp    800cd5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbb:	75 13                	jne    800cd0 <memmove+0x61>
  800cbd:	a8 03                	test   $0x3,%al
  800cbf:	75 0f                	jne    800cd0 <memmove+0x61>
  800cc1:	f6 c1 03             	test   $0x3,%cl
  800cc4:	75 0a                	jne    800cd0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	fc                   	cld    
  800ccc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cce:	eb 05                	jmp    800cd5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd0:	89 c7                	mov    %eax,%edi
  800cd2:	fc                   	cld    
  800cd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cdc:	ff 75 10             	pushl  0x10(%ebp)
  800cdf:	ff 75 0c             	pushl  0xc(%ebp)
  800ce2:	ff 75 08             	pushl  0x8(%ebp)
  800ce5:	e8 85 ff ff ff       	call   800c6f <memmove>
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	74 32                	je     800d31 <memcmp+0x45>
		if (*s1 != *s2)
  800cff:	8a 03                	mov    (%ebx),%al
  800d01:	8a 0e                	mov    (%esi),%cl
  800d03:	38 c8                	cmp    %cl,%al
  800d05:	74 19                	je     800d20 <memcmp+0x34>
  800d07:	eb 0d                	jmp    800d16 <memcmp+0x2a>
  800d09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800d0d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800d11:	42                   	inc    %edx
  800d12:	38 c8                	cmp    %cl,%al
  800d14:	74 10                	je     800d26 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800d16:	0f b6 c0             	movzbl %al,%eax
  800d19:	0f b6 c9             	movzbl %cl,%ecx
  800d1c:	29 c8                	sub    %ecx,%eax
  800d1e:	eb 16                	jmp    800d36 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d20:	4f                   	dec    %edi
  800d21:	ba 00 00 00 00       	mov    $0x0,%edx
  800d26:	39 fa                	cmp    %edi,%edx
  800d28:	75 df                	jne    800d09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2f:	eb 05                	jmp    800d36 <memcmp+0x4a>
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d41:	89 c2                	mov    %eax,%edx
  800d43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d46:	39 d0                	cmp    %edx,%eax
  800d48:	73 12                	jae    800d5c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800d4d:	38 08                	cmp    %cl,(%eax)
  800d4f:	75 06                	jne    800d57 <memfind+0x1c>
  800d51:	eb 09                	jmp    800d5c <memfind+0x21>
  800d53:	38 08                	cmp    %cl,(%eax)
  800d55:	74 05                	je     800d5c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d57:	40                   	inc    %eax
  800d58:	39 c2                	cmp    %eax,%edx
  800d5a:	77 f7                	ja     800d53 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	eb 01                	jmp    800d6d <strtol+0xf>
		s++;
  800d6c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6d:	8a 02                	mov    (%edx),%al
  800d6f:	3c 20                	cmp    $0x20,%al
  800d71:	74 f9                	je     800d6c <strtol+0xe>
  800d73:	3c 09                	cmp    $0x9,%al
  800d75:	74 f5                	je     800d6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d77:	3c 2b                	cmp    $0x2b,%al
  800d79:	75 08                	jne    800d83 <strtol+0x25>
		s++;
  800d7b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d81:	eb 13                	jmp    800d96 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d83:	3c 2d                	cmp    $0x2d,%al
  800d85:	75 0a                	jne    800d91 <strtol+0x33>
		s++, neg = 1;
  800d87:	8d 52 01             	lea    0x1(%edx),%edx
  800d8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800d8f:	eb 05                	jmp    800d96 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d96:	85 db                	test   %ebx,%ebx
  800d98:	74 05                	je     800d9f <strtol+0x41>
  800d9a:	83 fb 10             	cmp    $0x10,%ebx
  800d9d:	75 28                	jne    800dc7 <strtol+0x69>
  800d9f:	8a 02                	mov    (%edx),%al
  800da1:	3c 30                	cmp    $0x30,%al
  800da3:	75 10                	jne    800db5 <strtol+0x57>
  800da5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800da9:	75 0a                	jne    800db5 <strtol+0x57>
		s += 2, base = 16;
  800dab:	83 c2 02             	add    $0x2,%edx
  800dae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db3:	eb 12                	jmp    800dc7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800db5:	85 db                	test   %ebx,%ebx
  800db7:	75 0e                	jne    800dc7 <strtol+0x69>
  800db9:	3c 30                	cmp    $0x30,%al
  800dbb:	75 05                	jne    800dc2 <strtol+0x64>
		s++, base = 8;
  800dbd:	42                   	inc    %edx
  800dbe:	b3 08                	mov    $0x8,%bl
  800dc0:	eb 05                	jmp    800dc7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dce:	8a 0a                	mov    (%edx),%cl
  800dd0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd3:	80 fb 09             	cmp    $0x9,%bl
  800dd6:	77 08                	ja     800de0 <strtol+0x82>
			dig = *s - '0';
  800dd8:	0f be c9             	movsbl %cl,%ecx
  800ddb:	83 e9 30             	sub    $0x30,%ecx
  800dde:	eb 1e                	jmp    800dfe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800de0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800de3:	80 fb 19             	cmp    $0x19,%bl
  800de6:	77 08                	ja     800df0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800de8:	0f be c9             	movsbl %cl,%ecx
  800deb:	83 e9 57             	sub    $0x57,%ecx
  800dee:	eb 0e                	jmp    800dfe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800df0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800df3:	80 fb 19             	cmp    $0x19,%bl
  800df6:	77 13                	ja     800e0b <strtol+0xad>
			dig = *s - 'A' + 10;
  800df8:	0f be c9             	movsbl %cl,%ecx
  800dfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dfe:	39 f1                	cmp    %esi,%ecx
  800e00:	7d 0d                	jge    800e0f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800e02:	42                   	inc    %edx
  800e03:	0f af c6             	imul   %esi,%eax
  800e06:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e09:	eb c3                	jmp    800dce <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e0b:	89 c1                	mov    %eax,%ecx
  800e0d:	eb 02                	jmp    800e11 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e0f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e15:	74 05                	je     800e1c <strtol+0xbe>
		*endptr = (char *) s;
  800e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e1a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e1c:	85 ff                	test   %edi,%edi
  800e1e:	74 04                	je     800e24 <strtol+0xc6>
  800e20:	89 c8                	mov    %ecx,%eax
  800e22:	f7 d8                	neg    %eax
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    
  800e29:	00 00                	add    %al,(%eax)
	...

00800e2c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 1c             	sub    $0x1c,%esp
  800e35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e38:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e3b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800e40:	8b 7d 10             	mov    0x10(%ebp),%edi
  800e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	cd 30                	int    $0x30
  800e4b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e51:	74 1c                	je     800e6f <syscall+0x43>
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7e 18                	jle    800e6f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	50                   	push   %eax
  800e5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e5e:	68 1f 2d 80 00       	push   $0x802d1f
  800e63:	6a 42                	push   $0x42
  800e65:	68 3c 2d 80 00       	push   $0x802d3c
  800e6a:	e8 b1 f5 ff ff       	call   800420 <_panic>

	return ret;
}
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e7f:	6a 00                	push   $0x0
  800e81:	6a 00                	push   $0x0
  800e83:	6a 00                	push   $0x0
  800e85:	ff 75 0c             	pushl  0xc(%ebp)
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	e8 92 ff ff ff       	call   800e2c <syscall>
  800e9a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ea5:	6a 00                	push   $0x0
  800ea7:	6a 00                	push   $0x0
  800ea9:	6a 00                	push   $0x0
  800eab:	6a 00                	push   $0x0
  800ead:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebc:	e8 6b ff ff ff       	call   800e2c <syscall>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ec9:	6a 00                	push   $0x0
  800ecb:	6a 00                	push   $0x0
  800ecd:	6a 00                	push   $0x0
  800ecf:	6a 00                	push   $0x0
  800ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ede:	e8 49 ff ff ff       	call   800e2c <syscall>
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800eeb:	6a 00                	push   $0x0
  800eed:	6a 00                	push   $0x0
  800eef:	6a 00                	push   $0x0
  800ef1:	6a 00                	push   $0x0
  800ef3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef8:	ba 00 00 00 00       	mov    $0x0,%edx
  800efd:	b8 02 00 00 00       	mov    $0x2,%eax
  800f02:	e8 25 ff ff ff       	call   800e2c <syscall>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <sys_yield>:

void
sys_yield(void)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f0f:	6a 00                	push   $0x0
  800f11:	6a 00                	push   $0x0
  800f13:	6a 00                	push   $0x0
  800f15:	6a 00                	push   $0x0
  800f17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f26:	e8 01 ff ff ff       	call   800e2c <syscall>
  800f2b:	83 c4 10             	add    $0x10,%esp
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f36:	6a 00                	push   $0x0
  800f38:	6a 00                	push   $0x0
  800f3a:	ff 75 10             	pushl  0x10(%ebp)
  800f3d:	ff 75 0c             	pushl  0xc(%ebp)
  800f40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f43:	ba 01 00 00 00       	mov    $0x1,%edx
  800f48:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4d:	e8 da fe ff ff       	call   800e2c <syscall>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f5a:	ff 75 18             	pushl  0x18(%ebp)
  800f5d:	ff 75 14             	pushl  0x14(%ebp)
  800f60:	ff 75 10             	pushl  0x10(%ebp)
  800f63:	ff 75 0c             	pushl  0xc(%ebp)
  800f66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f69:	ba 01 00 00 00       	mov    $0x1,%edx
  800f6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f73:	e8 b4 fe ff ff       	call   800e2c <syscall>
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f80:	6a 00                	push   $0x0
  800f82:	6a 00                	push   $0x0
  800f84:	6a 00                	push   $0x0
  800f86:	ff 75 0c             	pushl  0xc(%ebp)
  800f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f91:	b8 06 00 00 00       	mov    $0x6,%eax
  800f96:	e8 91 fe ff ff       	call   800e2c <syscall>
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800fa3:	6a 00                	push   $0x0
  800fa5:	6a 00                	push   $0x0
  800fa7:	6a 00                	push   $0x0
  800fa9:	ff 75 0c             	pushl  0xc(%ebp)
  800fac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faf:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb9:	e8 6e fe ff ff       	call   800e2c <syscall>
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800fc6:	6a 00                	push   $0x0
  800fc8:	6a 00                	push   $0x0
  800fca:	6a 00                	push   $0x0
  800fcc:	ff 75 0c             	pushl  0xc(%ebp)
  800fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800fd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fdc:	e8 4b fe ff ff       	call   800e2c <syscall>
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800fe9:	6a 00                	push   $0x0
  800feb:	6a 00                	push   $0x0
  800fed:	6a 00                	push   $0x0
  800fef:	ff 75 0c             	pushl  0xc(%ebp)
  800ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff5:	ba 01 00 00 00       	mov    $0x1,%edx
  800ffa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fff:	e8 28 fe ff ff       	call   800e2c <syscall>
}
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80100c:	6a 00                	push   $0x0
  80100e:	ff 75 14             	pushl  0x14(%ebp)
  801011:	ff 75 10             	pushl  0x10(%ebp)
  801014:	ff 75 0c             	pushl  0xc(%ebp)
  801017:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801024:	e8 03 fe ff ff       	call   800e2c <syscall>
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801031:	6a 00                	push   $0x0
  801033:	6a 00                	push   $0x0
  801035:	6a 00                	push   $0x0
  801037:	6a 00                	push   $0x0
  801039:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103c:	ba 01 00 00 00       	mov    $0x1,%edx
  801041:	b8 0d 00 00 00       	mov    $0xd,%eax
  801046:	e8 e1 fd ff ff       	call   800e2c <syscall>
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  801053:	6a 00                	push   $0x0
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	ff 75 0c             	pushl  0xc(%ebp)
  80105c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105f:	ba 00 00 00 00       	mov    $0x0,%edx
  801064:	b8 0e 00 00 00       	mov    $0xe,%eax
  801069:	e8 be fd ff ff       	call   800e2c <syscall>
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  801076:	6a 00                	push   $0x0
  801078:	ff 75 14             	pushl  0x14(%ebp)
  80107b:	ff 75 10             	pushl  0x10(%ebp)
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801084:	ba 00 00 00 00       	mov    $0x0,%edx
  801089:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108e:	e8 99 fd ff ff       	call   800e2c <syscall>
} 
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80109b:	6a 00                	push   $0x0
  80109d:	6a 00                	push   $0x0
  80109f:	6a 00                	push   $0x0
  8010a1:	6a 00                	push   $0x0
  8010a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ab:	b8 11 00 00 00       	mov    $0x11,%eax
  8010b0:	e8 77 fd ff ff       	call   800e2c <syscall>
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  8010bd:	6a 00                	push   $0x0
  8010bf:	6a 00                	push   $0x0
  8010c1:	6a 00                	push   $0x0
  8010c3:	6a 00                	push   $0x0
  8010c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8010d4:	e8 53 fd ff ff       	call   800e2c <syscall>
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    
	...

008010dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ef:	ff 75 08             	pushl  0x8(%ebp)
  8010f2:	e8 e5 ff ff ff       	call   8010dc <fd2num>
  8010f7:	83 c4 04             	add    $0x4,%esp
  8010fa:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010ff:	c1 e0 0c             	shl    $0xc,%eax
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	53                   	push   %ebx
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80110b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801110:	a8 01                	test   $0x1,%al
  801112:	74 34                	je     801148 <fd_alloc+0x44>
  801114:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801119:	a8 01                	test   $0x1,%al
  80111b:	74 32                	je     80114f <fd_alloc+0x4b>
  80111d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801122:	89 c1                	mov    %eax,%ecx
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 ea 16             	shr    $0x16,%edx
  801129:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801130:	f6 c2 01             	test   $0x1,%dl
  801133:	74 1f                	je     801154 <fd_alloc+0x50>
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	f6 c2 01             	test   $0x1,%dl
  801144:	75 17                	jne    80115d <fd_alloc+0x59>
  801146:	eb 0c                	jmp    801154 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801148:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80114d:	eb 05                	jmp    801154 <fd_alloc+0x50>
  80114f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801154:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
  80115b:	eb 17                	jmp    801174 <fd_alloc+0x70>
  80115d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801162:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801167:	75 b9                	jne    801122 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80116f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801174:	5b                   	pop    %ebx
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117d:	83 f8 1f             	cmp    $0x1f,%eax
  801180:	77 36                	ja     8011b8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801182:	05 00 00 0d 00       	add    $0xd0000,%eax
  801187:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	c1 ea 16             	shr    $0x16,%edx
  80118f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801196:	f6 c2 01             	test   $0x1,%dl
  801199:	74 24                	je     8011bf <fd_lookup+0x48>
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 0c             	shr    $0xc,%edx
  8011a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 1a                	je     8011c6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 13                	jmp    8011cb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bd:	eb 0c                	jmp    8011cb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c4:	eb 05                	jmp    8011cb <fd_lookup+0x54>
  8011c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011da:	39 0d 90 47 80 00    	cmp    %ecx,0x804790
  8011e0:	74 0d                	je     8011ef <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e7:	eb 14                	jmp    8011fd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011e9:	39 0a                	cmp    %ecx,(%edx)
  8011eb:	75 10                	jne    8011fd <dev_lookup+0x30>
  8011ed:	eb 05                	jmp    8011f4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ef:	ba 90 47 80 00       	mov    $0x804790,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011f4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fb:	eb 31                	jmp    80122e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011fd:	40                   	inc    %eax
  8011fe:	8b 14 85 c8 2d 80 00 	mov    0x802dc8(,%eax,4),%edx
  801205:	85 d2                	test   %edx,%edx
  801207:	75 e0                	jne    8011e9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801209:	a1 90 67 80 00       	mov    0x806790,%eax
  80120e:	8b 40 48             	mov    0x48(%eax),%eax
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	51                   	push   %ecx
  801215:	50                   	push   %eax
  801216:	68 4c 2d 80 00       	push   $0x802d4c
  80121b:	e8 d8 f2 ff ff       	call   8004f8 <cprintf>
	*dev = 0;
  801220:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 20             	sub    $0x20,%esp
  80123b:	8b 75 08             	mov    0x8(%ebp),%esi
  80123e:	8a 45 0c             	mov    0xc(%ebp),%al
  801241:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801244:	56                   	push   %esi
  801245:	e8 92 fe ff ff       	call   8010dc <fd2num>
  80124a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80124d:	89 14 24             	mov    %edx,(%esp)
  801250:	50                   	push   %eax
  801251:	e8 21 ff ff ff       	call   801177 <fd_lookup>
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 05                	js     801264 <fd_close+0x31>
	    || fd != fd2)
  80125f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801262:	74 0d                	je     801271 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801264:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801268:	75 48                	jne    8012b2 <fd_close+0x7f>
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126f:	eb 41                	jmp    8012b2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 36                	pushl  (%esi)
  80127a:	e8 4e ff ff ff       	call   8011cd <dev_lookup>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 1c                	js     8012a4 <fd_close+0x71>
		if (dev->dev_close)
  801288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128b:	8b 40 10             	mov    0x10(%eax),%eax
  80128e:	85 c0                	test   %eax,%eax
  801290:	74 0d                	je     80129f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	56                   	push   %esi
  801296:	ff d0                	call   *%eax
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	eb 05                	jmp    8012a4 <fd_close+0x71>
		else
			r = 0;
  80129f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	56                   	push   %esi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 cb fc ff ff       	call   800f7a <sys_page_unmap>
	return r;
  8012af:	83 c4 10             	add    $0x10,%esp
}
  8012b2:	89 d8                	mov    %ebx,%eax
  8012b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 aa fe ff ff       	call   801177 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 10                	js     8012e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	6a 01                	push   $0x1
  8012d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012dc:	e8 52 ff ff ff       	call   801233 <fd_close>
  8012e1:	83 c4 10             	add    $0x10,%esp
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <close_all>:

void
close_all(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	53                   	push   %ebx
  8012f6:	e8 c0 ff ff ff       	call   8012bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fb:	43                   	inc    %ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	83 fb 20             	cmp    $0x20,%ebx
  801302:	75 ee                	jne    8012f2 <close_all+0xc>
		close(i);
}
  801304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 2c             	sub    $0x2c,%esp
  801312:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801315:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 56 fe ff ff       	call   801177 <fd_lookup>
  801321:	89 c3                	mov    %eax,%ebx
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	0f 88 c0 00 00 00    	js     8013ee <dup+0xe5>
		return r;
	close(newfdnum);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	57                   	push   %edi
  801332:	e8 84 ff ff ff       	call   8012bb <close>

	newfd = INDEX2FD(newfdnum);
  801337:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80133d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801340:	83 c4 04             	add    $0x4,%esp
  801343:	ff 75 e4             	pushl  -0x1c(%ebp)
  801346:	e8 a1 fd ff ff       	call   8010ec <fd2data>
  80134b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80134d:	89 34 24             	mov    %esi,(%esp)
  801350:	e8 97 fd ff ff       	call   8010ec <fd2data>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80135b:	89 d8                	mov    %ebx,%eax
  80135d:	c1 e8 16             	shr    $0x16,%eax
  801360:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801367:	a8 01                	test   $0x1,%al
  801369:	74 37                	je     8013a2 <dup+0x99>
  80136b:	89 d8                	mov    %ebx,%eax
  80136d:	c1 e8 0c             	shr    $0xc,%eax
  801370:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801377:	f6 c2 01             	test   $0x1,%dl
  80137a:	74 26                	je     8013a2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	25 07 0e 00 00       	and    $0xe07,%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138f:	6a 00                	push   $0x0
  801391:	53                   	push   %ebx
  801392:	6a 00                	push   $0x0
  801394:	e8 bb fb ff ff       	call   800f54 <sys_page_map>
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	83 c4 20             	add    $0x20,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 2d                	js     8013cf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 0c             	shr    $0xc,%edx
  8013aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013ba:	52                   	push   %edx
  8013bb:	56                   	push   %esi
  8013bc:	6a 00                	push   $0x0
  8013be:	50                   	push   %eax
  8013bf:	6a 00                	push   $0x0
  8013c1:	e8 8e fb ff ff       	call   800f54 <sys_page_map>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	83 c4 20             	add    $0x20,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	79 1d                	jns    8013ec <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	56                   	push   %esi
  8013d3:	6a 00                	push   $0x0
  8013d5:	e8 a0 fb ff ff       	call   800f7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e0:	6a 00                	push   $0x0
  8013e2:	e8 93 fb ff ff       	call   800f7a <sys_page_unmap>
	return r;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb 02                	jmp    8013ee <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013ec:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013ee:	89 d8                	mov    %ebx,%eax
  8013f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 14             	sub    $0x14,%esp
  8013ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801402:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	53                   	push   %ebx
  801407:	e8 6b fd ff ff       	call   801177 <fd_lookup>
  80140c:	83 c4 08             	add    $0x8,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 67                	js     80147a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	ff 30                	pushl  (%eax)
  80141f:	e8 a9 fd ff ff       	call   8011cd <dev_lookup>
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 4f                	js     80147a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	8b 50 08             	mov    0x8(%eax),%edx
  801431:	83 e2 03             	and    $0x3,%edx
  801434:	83 fa 01             	cmp    $0x1,%edx
  801437:	75 21                	jne    80145a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801439:	a1 90 67 80 00       	mov    0x806790,%eax
  80143e:	8b 40 48             	mov    0x48(%eax),%eax
  801441:	83 ec 04             	sub    $0x4,%esp
  801444:	53                   	push   %ebx
  801445:	50                   	push   %eax
  801446:	68 8d 2d 80 00       	push   $0x802d8d
  80144b:	e8 a8 f0 ff ff       	call   8004f8 <cprintf>
		return -E_INVAL;
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801458:	eb 20                	jmp    80147a <read+0x82>
	}
	if (!dev->dev_read)
  80145a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145d:	8b 52 08             	mov    0x8(%edx),%edx
  801460:	85 d2                	test   %edx,%edx
  801462:	74 11                	je     801475 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	ff 75 10             	pushl  0x10(%ebp)
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	50                   	push   %eax
  80146e:	ff d2                	call   *%edx
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	eb 05                	jmp    80147a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801475:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148e:	85 f6                	test   %esi,%esi
  801490:	74 31                	je     8014c3 <readn+0x44>
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
  801497:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	89 f2                	mov    %esi,%edx
  8014a1:	29 c2                	sub    %eax,%edx
  8014a3:	52                   	push   %edx
  8014a4:	03 45 0c             	add    0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	57                   	push   %edi
  8014a9:	e8 4a ff ff ff       	call   8013f8 <read>
		if (m < 0)
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 17                	js     8014cc <readn+0x4d>
			return m;
		if (m == 0)
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 11                	je     8014ca <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b9:	01 c3                	add    %eax,%ebx
  8014bb:	89 d8                	mov    %ebx,%eax
  8014bd:	39 f3                	cmp    %esi,%ebx
  8014bf:	72 db                	jb     80149c <readn+0x1d>
  8014c1:	eb 09                	jmp    8014cc <readn+0x4d>
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c8:	eb 02                	jmp    8014cc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014ca:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cf:	5b                   	pop    %ebx
  8014d0:	5e                   	pop    %esi
  8014d1:	5f                   	pop    %edi
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	53                   	push   %ebx
  8014d8:	83 ec 14             	sub    $0x14,%esp
  8014db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	53                   	push   %ebx
  8014e3:	e8 8f fc ff ff       	call   801177 <fd_lookup>
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 62                	js     801551 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	ff 30                	pushl  (%eax)
  8014fb:	e8 cd fc ff ff       	call   8011cd <dev_lookup>
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 4a                	js     801551 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150e:	75 21                	jne    801531 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801510:	a1 90 67 80 00       	mov    0x806790,%eax
  801515:	8b 40 48             	mov    0x48(%eax),%eax
  801518:	83 ec 04             	sub    $0x4,%esp
  80151b:	53                   	push   %ebx
  80151c:	50                   	push   %eax
  80151d:	68 a9 2d 80 00       	push   $0x802da9
  801522:	e8 d1 ef ff ff       	call   8004f8 <cprintf>
		return -E_INVAL;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152f:	eb 20                	jmp    801551 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801531:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801534:	8b 52 0c             	mov    0xc(%edx),%edx
  801537:	85 d2                	test   %edx,%edx
  801539:	74 11                	je     80154c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80153b:	83 ec 04             	sub    $0x4,%esp
  80153e:	ff 75 10             	pushl  0x10(%ebp)
  801541:	ff 75 0c             	pushl  0xc(%ebp)
  801544:	50                   	push   %eax
  801545:	ff d2                	call   *%edx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb 05                	jmp    801551 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80154c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <seek>:

int
seek(int fdnum, off_t offset)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 0f fc ff ff       	call   801177 <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 0e                	js     80157d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801572:	8b 55 0c             	mov    0xc(%ebp),%edx
  801575:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 14             	sub    $0x14,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801589:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	53                   	push   %ebx
  80158e:	e8 e4 fb ff ff       	call   801177 <fd_lookup>
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 5f                	js     8015f9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	ff 30                	pushl  (%eax)
  8015a6:	e8 22 fc ff ff       	call   8011cd <dev_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 47                	js     8015f9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b9:	75 21                	jne    8015dc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bb:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c0:	8b 40 48             	mov    0x48(%eax),%eax
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	50                   	push   %eax
  8015c8:	68 6c 2d 80 00       	push   $0x802d6c
  8015cd:	e8 26 ef ff ff       	call   8004f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015da:	eb 1d                	jmp    8015f9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	8b 52 18             	mov    0x18(%edx),%edx
  8015e2:	85 d2                	test   %edx,%edx
  8015e4:	74 0e                	je     8015f4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	ff d2                	call   *%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb 05                	jmp    8015f9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	53                   	push   %ebx
  801602:	83 ec 14             	sub    $0x14,%esp
  801605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 63 fb ff ff       	call   801177 <fd_lookup>
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 52                	js     80166d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801625:	ff 30                	pushl  (%eax)
  801627:	e8 a1 fb ff ff       	call   8011cd <dev_lookup>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 3a                	js     80166d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801633:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801636:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163a:	74 2c                	je     801668 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80163f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801646:	00 00 00 
	stat->st_isdir = 0;
  801649:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801650:	00 00 00 
	stat->st_dev = dev;
  801653:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	53                   	push   %ebx
  80165d:	ff 75 f0             	pushl  -0x10(%ebp)
  801660:	ff 50 14             	call   *0x14(%eax)
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	eb 05                	jmp    80166d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801668:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	6a 00                	push   $0x0
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 78 01 00 00       	call   8017fc <open>
  801684:	89 c3                	mov    %eax,%ebx
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 1b                	js     8016a8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	ff 75 0c             	pushl  0xc(%ebp)
  801693:	50                   	push   %eax
  801694:	e8 65 ff ff ff       	call   8015fe <fstat>
  801699:	89 c6                	mov    %eax,%esi
	close(fd);
  80169b:	89 1c 24             	mov    %ebx,(%esp)
  80169e:	e8 18 fc ff ff       	call   8012bb <close>
	return r;
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	89 f3                	mov    %esi,%ebx
}
  8016a8:	89 d8                	mov    %ebx,%eax
  8016aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ad:	5b                   	pop    %ebx
  8016ae:	5e                   	pop    %esi
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    
  8016b1:	00 00                	add    %al,(%eax)
	...

008016b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	89 c3                	mov    %eax,%ebx
  8016bb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016bd:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8016c4:	75 12                	jne    8016d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	6a 01                	push   $0x1
  8016cb:	e8 da 0e 00 00       	call   8025aa <ipc_find_env>
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
  8016d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d8:	6a 07                	push   $0x7
  8016da:	68 00 70 80 00       	push   $0x807000
  8016df:	53                   	push   %ebx
  8016e0:	ff 35 00 50 80 00    	pushl  0x805000
  8016e6:	e8 6a 0e 00 00       	call   802555 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016eb:	83 c4 0c             	add    $0xc,%esp
  8016ee:	6a 00                	push   $0x0
  8016f0:	56                   	push   %esi
  8016f1:	6a 00                	push   $0x0
  8016f3:	e8 e8 0d 00 00       	call   8024e0 <ipc_recv>
}
  8016f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	83 ec 04             	sub    $0x4,%esp
  801706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	8b 40 0c             	mov    0xc(%eax),%eax
  80170f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	b8 05 00 00 00       	mov    $0x5,%eax
  80171e:	e8 91 ff ff ff       	call   8016b4 <fsipc>
  801723:	85 c0                	test   %eax,%eax
  801725:	78 2c                	js     801753 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	68 00 70 80 00       	push   $0x807000
  80172f:	53                   	push   %ebx
  801730:	e8 79 f3 ff ff       	call   800aae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801735:	a1 80 70 80 00       	mov    0x807080,%eax
  80173a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801740:	a1 84 70 80 00       	mov    0x807084,%eax
  801745:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	8b 40 0c             	mov    0xc(%eax),%eax
  801764:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801769:	ba 00 00 00 00       	mov    $0x0,%edx
  80176e:	b8 06 00 00 00       	mov    $0x6,%eax
  801773:	e8 3c ff ff ff       	call   8016b4 <fsipc>
}
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	8b 40 0c             	mov    0xc(%eax),%eax
  801788:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80178d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801793:	ba 00 00 00 00       	mov    $0x0,%edx
  801798:	b8 03 00 00 00       	mov    $0x3,%eax
  80179d:	e8 12 ff ff ff       	call   8016b4 <fsipc>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 4b                	js     8017f3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017a8:	39 c6                	cmp    %eax,%esi
  8017aa:	73 16                	jae    8017c2 <devfile_read+0x48>
  8017ac:	68 d8 2d 80 00       	push   $0x802dd8
  8017b1:	68 df 2d 80 00       	push   $0x802ddf
  8017b6:	6a 7d                	push   $0x7d
  8017b8:	68 f4 2d 80 00       	push   $0x802df4
  8017bd:	e8 5e ec ff ff       	call   800420 <_panic>
	assert(r <= PGSIZE);
  8017c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c7:	7e 16                	jle    8017df <devfile_read+0x65>
  8017c9:	68 ff 2d 80 00       	push   $0x802dff
  8017ce:	68 df 2d 80 00       	push   $0x802ddf
  8017d3:	6a 7e                	push   $0x7e
  8017d5:	68 f4 2d 80 00       	push   $0x802df4
  8017da:	e8 41 ec ff ff       	call   800420 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	50                   	push   %eax
  8017e3:	68 00 70 80 00       	push   $0x807000
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	e8 7f f4 ff ff       	call   800c6f <memmove>
	return r;
  8017f0:	83 c4 10             	add    $0x10,%esp
}
  8017f3:	89 d8                	mov    %ebx,%eax
  8017f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 1c             	sub    $0x1c,%esp
  801804:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801807:	56                   	push   %esi
  801808:	e8 4f f2 ff ff       	call   800a5c <strlen>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801815:	7f 65                	jg     80187c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	e8 e1 f8 ff ff       	call   801104 <fd_alloc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 55                	js     801881 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	56                   	push   %esi
  801830:	68 00 70 80 00       	push   $0x807000
  801835:	e8 74 f2 ff ff       	call   800aae <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183d:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801842:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801845:	b8 01 00 00 00       	mov    $0x1,%eax
  80184a:	e8 65 fe ff ff       	call   8016b4 <fsipc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	79 12                	jns    80186a <open+0x6e>
		fd_close(fd, 0);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	6a 00                	push   $0x0
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	e8 ce f9 ff ff       	call   801233 <fd_close>
		return r;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	eb 17                	jmp    801881 <open+0x85>
	}

	return fd2num(fd);
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	e8 67 f8 ff ff       	call   8010dc <fd2num>
  801875:	89 c3                	mov    %eax,%ebx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 05                	jmp    801881 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80187c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801881:	89 d8                	mov    %ebx,%eax
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	c9                   	leave  
  801889:	c3                   	ret    
	...

0080188c <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	57                   	push   %edi
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	83 ec 1c             	sub    $0x1c,%esp
  801895:	89 c7                	mov    %eax,%edi
  801897:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80189a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80189d:	89 d0                	mov    %edx,%eax
  80189f:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018a4:	74 0c                	je     8018b2 <map_segment+0x26>
		va -= i;
  8018a6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  8018a9:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  8018ac:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  8018af:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018b6:	0f 84 ee 00 00 00    	je     8019aa <map_segment+0x11e>
  8018bc:	be 00 00 00 00       	mov    $0x0,%esi
  8018c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  8018c6:	39 75 0c             	cmp    %esi,0xc(%ebp)
  8018c9:	77 20                	ja     8018eb <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	ff 75 14             	pushl  0x14(%ebp)
  8018d1:	03 75 e4             	add    -0x1c(%ebp),%esi
  8018d4:	56                   	push   %esi
  8018d5:	57                   	push   %edi
  8018d6:	e8 55 f6 ff ff       	call   800f30 <sys_page_alloc>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	0f 89 ac 00 00 00    	jns    801992 <map_segment+0x106>
  8018e6:	e9 c4 00 00 00       	jmp    8019af <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	6a 07                	push   $0x7
  8018f0:	68 00 00 40 00       	push   $0x400000
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 34 f6 ff ff       	call   800f30 <sys_page_alloc>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 a8 00 00 00    	js     8019af <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801907:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  80190a:	8b 45 10             	mov    0x10(%ebp),%eax
  80190d:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801910:	50                   	push   %eax
  801911:	ff 75 08             	pushl  0x8(%ebp)
  801914:	e8 3d fc ff ff       	call   801556 <seek>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	0f 88 8b 00 00 00    	js     8019af <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	29 f0                	sub    %esi,%eax
  80192c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801931:	76 05                	jbe    801938 <map_segment+0xac>
  801933:	b8 00 10 00 00       	mov    $0x1000,%eax
  801938:	50                   	push   %eax
  801939:	68 00 00 40 00       	push   $0x400000
  80193e:	ff 75 08             	pushl  0x8(%ebp)
  801941:	e8 39 fb ff ff       	call   80147f <readn>
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 62                	js     8019af <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff 75 14             	pushl  0x14(%ebp)
  801953:	03 75 e4             	add    -0x1c(%ebp),%esi
  801956:	56                   	push   %esi
  801957:	57                   	push   %edi
  801958:	68 00 00 40 00       	push   $0x400000
  80195d:	6a 00                	push   $0x0
  80195f:	e8 f0 f5 ff ff       	call   800f54 <sys_page_map>
  801964:	83 c4 20             	add    $0x20,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	79 15                	jns    801980 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  80196b:	50                   	push   %eax
  80196c:	68 0b 2e 80 00       	push   $0x802e0b
  801971:	68 84 01 00 00       	push   $0x184
  801976:	68 28 2e 80 00       	push   $0x802e28
  80197b:	e8 a0 ea ff ff       	call   800420 <_panic>
			sys_page_unmap(0, UTEMP);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	68 00 00 40 00       	push   $0x400000
  801988:	6a 00                	push   $0x0
  80198a:	e8 eb f5 ff ff       	call   800f7a <sys_page_unmap>
  80198f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801992:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801998:	89 de                	mov    %ebx,%esi
  80199a:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  80199d:	0f 87 23 ff ff ff    	ja     8018c6 <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a8:	eb 05                	jmp    8019af <map_segment+0x123>
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5f                   	pop    %edi
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 2c             	sub    $0x2c,%esp
  8019c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c3:	89 d7                	mov    %edx,%edi
  8019c5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019c8:	8b 02                	mov    (%edx),%eax
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	74 31                	je     8019ff <init_stack+0x48>
  8019ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019d3:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	50                   	push   %eax
  8019dc:	e8 7b f0 ff ff       	call   800a5c <strlen>
  8019e1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019e5:	43                   	inc    %ebx
  8019e6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019ed:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	75 e1                	jne    8019d8 <init_stack+0x21>
  8019f7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8019fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019fd:	eb 18                	jmp    801a17 <init_stack+0x60>
  8019ff:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801a06:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801a0d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a12:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a17:	f7 de                	neg    %esi
  801a19:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801a1f:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a22:	89 f2                	mov    %esi,%edx
  801a24:	83 e2 fc             	and    $0xfffffffc,%edx
  801a27:	89 d8                	mov    %ebx,%eax
  801a29:	f7 d0                	not    %eax
  801a2b:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801a2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a31:	83 e8 08             	sub    $0x8,%eax
  801a34:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a39:	0f 86 fb 00 00 00    	jbe    801b3a <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	6a 07                	push   $0x7
  801a44:	68 00 00 40 00       	push   $0x400000
  801a49:	6a 00                	push   $0x0
  801a4b:	e8 e0 f4 ff ff       	call   800f30 <sys_page_alloc>
  801a50:	89 c6                	mov    %eax,%esi
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	85 c0                	test   %eax,%eax
  801a57:	0f 88 e9 00 00 00    	js     801b46 <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a5d:	85 db                	test   %ebx,%ebx
  801a5f:	7e 3e                	jle    801a9f <init_stack+0xe8>
  801a61:	be 00 00 00 00       	mov    $0x0,%esi
  801a66:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801a69:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801a6c:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801a72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a75:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	ff 34 b7             	pushl  (%edi,%esi,4)
  801a7e:	53                   	push   %ebx
  801a7f:	e8 2a f0 ff ff       	call   800aae <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a84:	83 c4 04             	add    $0x4,%esp
  801a87:	ff 34 b7             	pushl  (%edi,%esi,4)
  801a8a:	e8 cd ef ff ff       	call   800a5c <strlen>
  801a8f:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a93:	46                   	inc    %esi
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801a9a:	7c d0                	jl     801a6c <init_stack+0xb5>
  801a9c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801aa2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801aa5:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aac:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801ab3:	74 19                	je     801ace <init_stack+0x117>
  801ab5:	68 98 2e 80 00       	push   $0x802e98
  801aba:	68 df 2d 80 00       	push   $0x802ddf
  801abf:	68 51 01 00 00       	push   $0x151
  801ac4:	68 28 2e 80 00       	push   $0x802e28
  801ac9:	e8 52 e9 ff ff       	call   800420 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad1:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ad6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ad9:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801adc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801adf:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ae2:	89 d0                	mov    %edx,%eax
  801ae4:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ae9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801aec:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	6a 07                	push   $0x7
  801af3:	ff 75 08             	pushl  0x8(%ebp)
  801af6:	ff 75 d8             	pushl  -0x28(%ebp)
  801af9:	68 00 00 40 00       	push   $0x400000
  801afe:	6a 00                	push   $0x0
  801b00:	e8 4f f4 ff ff       	call   800f54 <sys_page_map>
  801b05:	89 c6                	mov    %eax,%esi
  801b07:	83 c4 20             	add    $0x20,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 18                	js     801b26 <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	68 00 00 40 00       	push   $0x400000
  801b16:	6a 00                	push   $0x0
  801b18:	e8 5d f4 ff ff       	call   800f7a <sys_page_unmap>
  801b1d:	89 c6                	mov    %eax,%esi
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	85 c0                	test   %eax,%eax
  801b24:	79 1b                	jns    801b41 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	68 00 00 40 00       	push   $0x400000
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 45 f4 ff ff       	call   800f7a <sys_page_unmap>
	return r;
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	eb 0c                	jmp    801b46 <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b3a:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801b3f:	eb 05                	jmp    801b46 <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801b41:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801b46:	89 f0                	mov    %esi,%eax
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b5c:	6a 00                	push   $0x0
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 96 fc ff ff       	call   8017fc <open>
  801b66:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 3f 02 00 00    	js     801db6 <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b77:	83 ec 04             	sub    $0x4,%esp
  801b7a:	68 00 02 00 00       	push   $0x200
  801b7f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801b85:	50                   	push   %eax
  801b86:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b8c:	e8 ee f8 ff ff       	call   80147f <readn>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b99:	75 0c                	jne    801ba7 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801b9b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ba2:	45 4c 46 
  801ba5:	74 38                	je     801bdf <spawn+0x8f>
		close(fd);
  801ba7:	83 ec 0c             	sub    $0xc,%esp
  801baa:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801bb0:	e8 06 f7 ff ff       	call   8012bb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801bb5:	83 c4 0c             	add    $0xc,%esp
  801bb8:	68 7f 45 4c 46       	push   $0x464c457f
  801bbd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801bc3:	68 34 2e 80 00       	push   $0x802e34
  801bc8:	e8 2b e9 ff ff       	call   8004f8 <cprintf>
		return -E_NOT_EXEC;
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801bd7:	ff ff ff 
  801bda:	e9 eb 01 00 00       	jmp    801dca <spawn+0x27a>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801bdf:	ba 07 00 00 00       	mov    $0x7,%edx
  801be4:	89 d0                	mov    %edx,%eax
  801be6:	cd 30                	int    $0x30
  801be8:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bee:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	0f 88 ce 01 00 00    	js     801dca <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801bfc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	c1 e2 07             	shl    $0x7,%edx
  801c06:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  801c0d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c13:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c1a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c20:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801c2f:	68 00 d0 bf ee       	push   $0xeebfd000
  801c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c37:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801c3d:	e8 75 fd ff ff       	call   8019b7 <init_stack>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 88 77 01 00 00    	js     801dc4 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c4d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c53:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801c5a:	00 
  801c5b:	74 5d                	je     801cba <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c5d:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c64:	be 00 00 00 00       	mov    $0x0,%esi
  801c69:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801c6f:	83 3b 01             	cmpl   $0x1,(%ebx)
  801c72:	75 35                	jne    801ca9 <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c74:	8b 43 18             	mov    0x18(%ebx),%eax
  801c77:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c7a:	83 f8 01             	cmp    $0x1,%eax
  801c7d:	19 c0                	sbb    %eax,%eax
  801c7f:	83 e0 fe             	and    $0xfffffffe,%eax
  801c82:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c85:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801c88:	8b 53 08             	mov    0x8(%ebx),%edx
  801c8b:	50                   	push   %eax
  801c8c:	ff 73 04             	pushl  0x4(%ebx)
  801c8f:	ff 73 10             	pushl  0x10(%ebx)
  801c92:	57                   	push   %edi
  801c93:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c99:	e8 ee fb ff ff       	call   80188c <map_segment>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	0f 88 e4 00 00 00    	js     801d8d <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ca9:	46                   	inc    %esi
  801caa:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cb1:	39 f0                	cmp    %esi,%eax
  801cb3:	7e 05                	jle    801cba <spawn+0x16a>
  801cb5:	83 c3 20             	add    $0x20,%ebx
  801cb8:	eb b5                	jmp    801c6f <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801cc3:	e8 f3 f5 ff ff       	call   8012bb <close>
  801cc8:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd0:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	c1 e8 16             	shr    $0x16,%eax
  801cdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ce2:	a8 01                	test   $0x1,%al
  801ce4:	74 3e                	je     801d24 <spawn+0x1d4>
  801ce6:	89 d8                	mov    %ebx,%eax
  801ce8:	c1 e8 0c             	shr    $0xc,%eax
  801ceb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cf2:	f6 c2 01             	test   $0x1,%dl
  801cf5:	74 2d                	je     801d24 <spawn+0x1d4>
  801cf7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cfe:	f6 c6 04             	test   $0x4,%dh
  801d01:	74 21                	je     801d24 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801d03:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	25 07 0e 00 00       	and    $0xe07,%eax
  801d12:	50                   	push   %eax
  801d13:	53                   	push   %ebx
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	6a 00                	push   $0x0
  801d18:	e8 37 f2 ff ff       	call   800f54 <sys_page_map>
        if (r < 0) return r;
  801d1d:	83 c4 20             	add    $0x20,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 13                	js     801d37 <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801d24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d2a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d30:	75 a4                	jne    801cd6 <spawn+0x186>
  801d32:	e9 a1 00 00 00       	jmp    801dd8 <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801d37:	50                   	push   %eax
  801d38:	68 4e 2e 80 00       	push   $0x802e4e
  801d3d:	68 85 00 00 00       	push   $0x85
  801d42:	68 28 2e 80 00       	push   $0x802e28
  801d47:	e8 d4 e6 ff ff       	call   800420 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d4c:	50                   	push   %eax
  801d4d:	68 64 2e 80 00       	push   $0x802e64
  801d52:	68 88 00 00 00       	push   $0x88
  801d57:	68 28 2e 80 00       	push   $0x802e28
  801d5c:	e8 bf e6 ff ff       	call   800420 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	6a 02                	push   $0x2
  801d66:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d6c:	e8 2c f2 ff ff       	call   800f9d <sys_env_set_status>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	79 52                	jns    801dca <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  801d78:	50                   	push   %eax
  801d79:	68 7e 2e 80 00       	push   $0x802e7e
  801d7e:	68 8b 00 00 00       	push   $0x8b
  801d83:	68 28 2e 80 00       	push   $0x802e28
  801d88:	e8 93 e6 ff ff       	call   800420 <_panic>
  801d8d:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d98:	e8 26 f1 ff ff       	call   800ec3 <sys_env_destroy>
	close(fd);
  801d9d:	83 c4 04             	add    $0x4,%esp
  801da0:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801da6:	e8 10 f5 ff ff       	call   8012bb <close>
	return r;
  801dab:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801dae:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801db4:	eb 14                	jmp    801dca <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801db6:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801dbc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801dc2:	eb 06                	jmp    801dca <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801dc4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dca:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dd8:	83 ec 08             	sub    $0x8,%esp
  801ddb:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801de1:	50                   	push   %eax
  801de2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801de8:	e8 d3 f1 ff ff       	call   800fc0 <sys_env_set_trapframe>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 89 69 ff ff ff    	jns    801d61 <spawn+0x211>
  801df8:	e9 4f ff ff ff       	jmp    801d4c <spawn+0x1fc>

00801dfd <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801e09:	6a 00                	push   $0x0
  801e0b:	ff 75 08             	pushl  0x8(%ebp)
  801e0e:	e8 e9 f9 ff ff       	call   8017fc <open>
  801e13:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 a9 01 00 00    	js     801fcd <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801e24:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	68 00 02 00 00       	push   $0x200
  801e32:	57                   	push   %edi
  801e33:	50                   	push   %eax
  801e34:	e8 46 f6 ff ff       	call   80147f <readn>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801e41:	75 0c                	jne    801e4f <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801e43:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e4a:	45 4c 46 
  801e4d:	74 34                	je     801e83 <exec+0x86>
		close(fd);
  801e4f:	83 ec 0c             	sub    $0xc,%esp
  801e52:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801e58:	e8 5e f4 ff ff       	call   8012bb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e5d:	83 c4 0c             	add    $0xc,%esp
  801e60:	68 7f 45 4c 46       	push   $0x464c457f
  801e65:	ff 37                	pushl  (%edi)
  801e67:	68 34 2e 80 00       	push   $0x802e34
  801e6c:	e8 87 e6 ff ff       	call   8004f8 <cprintf>
		return -E_NOT_EXEC;
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801e7b:	ff ff ff 
  801e7e:	e9 4a 01 00 00       	jmp    801fcd <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e83:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e86:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801e8b:	0f 84 8b 00 00 00    	je     801f1c <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e91:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801e98:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801e9f:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ea2:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801ea7:	83 3b 01             	cmpl   $0x1,(%ebx)
  801eaa:	75 62                	jne    801f0e <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801eac:	8b 43 18             	mov    0x18(%ebx),%eax
  801eaf:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801eb2:	83 f8 01             	cmp    $0x1,%eax
  801eb5:	19 c0                	sbb    %eax,%eax
  801eb7:	83 e0 fe             	and    $0xfffffffe,%eax
  801eba:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801ebd:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801ec0:	8b 53 08             	mov    0x8(%ebx),%edx
  801ec3:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801ec9:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801ecf:	50                   	push   %eax
  801ed0:	ff 73 04             	pushl  0x4(%ebx)
  801ed3:	ff 73 10             	pushl  0x10(%ebx)
  801ed6:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee1:	e8 a6 f9 ff ff       	call   80188c <map_segment>
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 a3 00 00 00    	js     801f94 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801ef1:	8b 53 14             	mov    0x14(%ebx),%edx
  801ef4:	8b 43 08             	mov    0x8(%ebx),%eax
  801ef7:	25 ff 0f 00 00       	and    $0xfff,%eax
  801efc:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801f03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801f08:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f0e:	46                   	inc    %esi
  801f0f:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801f13:	39 f0                	cmp    %esi,%eax
  801f15:	7e 0f                	jle    801f26 <exec+0x129>
  801f17:	83 c3 20             	add    $0x20,%ebx
  801f1a:	eb 8b                	jmp    801ea7 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801f1c:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801f23:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801f2f:	e8 87 f3 ff ff       	call   8012bb <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801f34:	83 c4 04             	add    $0x4,%esp
  801f37:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801f3d:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801f43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4b:	e8 67 fa ff ff       	call   8019b7 <init_stack>
  801f50:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 70                	js     801fcd <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801f5d:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801f61:	50                   	push   %eax
  801f62:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f68:	03 47 1c             	add    0x1c(%edi),%eax
  801f6b:	50                   	push   %eax
  801f6c:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801f72:	ff 77 18             	pushl  0x18(%edi)
  801f75:	e8 f6 f0 ff ff       	call   801070 <sys_exec>
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	79 42                	jns    801fc3 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801f81:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801f87:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801f8d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801f92:	eb 0c                	jmp    801fa0 <exec+0x1a3>
  801f94:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801f9a:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801fa0:	83 ec 0c             	sub    $0xc,%esp
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 19 ef ff ff       	call   800ec3 <sys_env_destroy>
	close(fd);
  801faa:	89 1c 24             	mov    %ebx,(%esp)
  801fad:	e8 09 f3 ff ff       	call   8012bb <close>
	return r;
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801fbb:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801fc1:	eb 0a                	jmp    801fcd <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801fc3:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801fca:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801fcd:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801fd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5e                   	pop    %esi
  801fd8:	5f                   	pop    %edi
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fe3:	8d 45 14             	lea    0x14(%ebp),%eax
  801fe6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fea:	74 5f                	je     80204b <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801fec:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801ff1:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ff2:	89 c2                	mov    %eax,%edx
  801ff4:	83 c0 04             	add    $0x4,%eax
  801ff7:	83 3a 00             	cmpl   $0x0,(%edx)
  801ffa:	75 f5                	jne    801ff1 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ffc:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802003:	83 e0 f0             	and    $0xfffffff0,%eax
  802006:	29 c4                	sub    %eax,%esp
  802008:	8d 44 24 0f          	lea    0xf(%esp),%eax
  80200c:	83 e0 f0             	and    $0xfffffff0,%eax
  80200f:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802011:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802013:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  80201a:	00 

	va_start(vl, arg0);
  80201b:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80201e:	89 ce                	mov    %ecx,%esi
  802020:	85 c9                	test   %ecx,%ecx
  802022:	74 14                	je     802038 <execl+0x5d>
  802024:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802029:	40                   	inc    %eax
  80202a:	89 d1                	mov    %edx,%ecx
  80202c:	83 c2 04             	add    $0x4,%edx
  80202f:	8b 09                	mov    (%ecx),%ecx
  802031:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802034:	39 f0                	cmp    %esi,%eax
  802036:	72 f1                	jb     802029 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  802038:	83 ec 08             	sub    $0x8,%esp
  80203b:	53                   	push   %ebx
  80203c:	ff 75 08             	pushl  0x8(%ebp)
  80203f:	e8 b9 fd ff ff       	call   801dfd <exec>
}
  802044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	c9                   	leave  
  80204a:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80204b:	83 ec 20             	sub    $0x20,%esp
  80204e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802052:	83 e0 f0             	and    $0xfffffff0,%eax
  802055:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802057:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802059:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802060:	eb d6                	jmp    802038 <execl+0x5d>

00802062 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	56                   	push   %esi
  802066:	53                   	push   %ebx
  802067:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80206a:	8d 45 14             	lea    0x14(%ebp),%eax
  80206d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802071:	74 5f                	je     8020d2 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802073:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802078:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802079:	89 c2                	mov    %eax,%edx
  80207b:	83 c0 04             	add    $0x4,%eax
  80207e:	83 3a 00             	cmpl   $0x0,(%edx)
  802081:	75 f5                	jne    802078 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802083:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80208a:	83 e0 f0             	and    $0xfffffff0,%eax
  80208d:	29 c4                	sub    %eax,%esp
  80208f:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802093:	83 e0 f0             	and    $0xfffffff0,%eax
  802096:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802098:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80209a:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8020a1:	00 

	va_start(vl, arg0);
  8020a2:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8020a5:	89 ce                	mov    %ecx,%esi
  8020a7:	85 c9                	test   %ecx,%ecx
  8020a9:	74 14                	je     8020bf <spawnl+0x5d>
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8020b0:	40                   	inc    %eax
  8020b1:	89 d1                	mov    %edx,%ecx
  8020b3:	83 c2 04             	add    $0x4,%edx
  8020b6:	8b 09                	mov    (%ecx),%ecx
  8020b8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8020bb:	39 f0                	cmp    %esi,%eax
  8020bd:	72 f1                	jb     8020b0 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8020bf:	83 ec 08             	sub    $0x8,%esp
  8020c2:	53                   	push   %ebx
  8020c3:	ff 75 08             	pushl  0x8(%ebp)
  8020c6:	e8 85 fa ff ff       	call   801b50 <spawn>
}
  8020cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ce:	5b                   	pop    %ebx
  8020cf:	5e                   	pop    %esi
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020d2:	83 ec 20             	sub    $0x20,%esp
  8020d5:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8020d9:	83 e0 f0             	and    $0xfffffff0,%eax
  8020dc:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8020de:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8020e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8020e7:	eb d6                	jmp    8020bf <spawnl+0x5d>
  8020e9:	00 00                	add    %al,(%eax)
	...

008020ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	ff 75 08             	pushl  0x8(%ebp)
  8020fa:	e8 ed ef ff ff       	call   8010ec <fd2data>
  8020ff:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802101:	83 c4 08             	add    $0x8,%esp
  802104:	68 c0 2e 80 00       	push   $0x802ec0
  802109:	56                   	push   %esi
  80210a:	e8 9f e9 ff ff       	call   800aae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80210f:	8b 43 04             	mov    0x4(%ebx),%eax
  802112:	2b 03                	sub    (%ebx),%eax
  802114:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80211a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802121:	00 00 00 
	stat->st_dev = &devpipe;
  802124:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  80212b:	47 80 00 
	return 0;
}
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
  802133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802136:	5b                   	pop    %ebx
  802137:	5e                   	pop    %esi
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	53                   	push   %ebx
  80213e:	83 ec 0c             	sub    $0xc,%esp
  802141:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802144:	53                   	push   %ebx
  802145:	6a 00                	push   $0x0
  802147:	e8 2e ee ff ff       	call   800f7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80214c:	89 1c 24             	mov    %ebx,(%esp)
  80214f:	e8 98 ef ff ff       	call   8010ec <fd2data>
  802154:	83 c4 08             	add    $0x8,%esp
  802157:	50                   	push   %eax
  802158:	6a 00                	push   $0x0
  80215a:	e8 1b ee ff ff       	call   800f7a <sys_page_unmap>
}
  80215f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	57                   	push   %edi
  802168:	56                   	push   %esi
  802169:	53                   	push   %ebx
  80216a:	83 ec 1c             	sub    $0x1c,%esp
  80216d:	89 c7                	mov    %eax,%edi
  80216f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802172:	a1 90 67 80 00       	mov    0x806790,%eax
  802177:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80217a:	83 ec 0c             	sub    $0xc,%esp
  80217d:	57                   	push   %edi
  80217e:	e8 75 04 00 00       	call   8025f8 <pageref>
  802183:	89 c6                	mov    %eax,%esi
  802185:	83 c4 04             	add    $0x4,%esp
  802188:	ff 75 e4             	pushl  -0x1c(%ebp)
  80218b:	e8 68 04 00 00       	call   8025f8 <pageref>
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	39 c6                	cmp    %eax,%esi
  802195:	0f 94 c0             	sete   %al
  802198:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80219b:	8b 15 90 67 80 00    	mov    0x806790,%edx
  8021a1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021a4:	39 cb                	cmp    %ecx,%ebx
  8021a6:	75 08                	jne    8021b0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5f                   	pop    %edi
  8021ae:	c9                   	leave  
  8021af:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021b0:	83 f8 01             	cmp    $0x1,%eax
  8021b3:	75 bd                	jne    802172 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b5:	8b 42 58             	mov    0x58(%edx),%eax
  8021b8:	6a 01                	push   $0x1
  8021ba:	50                   	push   %eax
  8021bb:	53                   	push   %ebx
  8021bc:	68 c7 2e 80 00       	push   $0x802ec7
  8021c1:	e8 32 e3 ff ff       	call   8004f8 <cprintf>
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	eb a7                	jmp    802172 <_pipeisclosed+0xe>

008021cb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	57                   	push   %edi
  8021cf:	56                   	push   %esi
  8021d0:	53                   	push   %ebx
  8021d1:	83 ec 28             	sub    $0x28,%esp
  8021d4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021d7:	56                   	push   %esi
  8021d8:	e8 0f ef ff ff       	call   8010ec <fd2data>
  8021dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e6:	75 4a                	jne    802232 <devpipe_write+0x67>
  8021e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8021ed:	eb 56                	jmp    802245 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021ef:	89 da                	mov    %ebx,%edx
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	e8 6c ff ff ff       	call   802164 <_pipeisclosed>
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	75 4d                	jne    802249 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021fc:	e8 08 ed ff ff       	call   800f09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802201:	8b 43 04             	mov    0x4(%ebx),%eax
  802204:	8b 13                	mov    (%ebx),%edx
  802206:	83 c2 20             	add    $0x20,%edx
  802209:	39 d0                	cmp    %edx,%eax
  80220b:	73 e2                	jae    8021ef <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80220d:	89 c2                	mov    %eax,%edx
  80220f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802215:	79 05                	jns    80221c <devpipe_write+0x51>
  802217:	4a                   	dec    %edx
  802218:	83 ca e0             	or     $0xffffffe0,%edx
  80221b:	42                   	inc    %edx
  80221c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802222:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802226:	40                   	inc    %eax
  802227:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80222a:	47                   	inc    %edi
  80222b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80222e:	77 07                	ja     802237 <devpipe_write+0x6c>
  802230:	eb 13                	jmp    802245 <devpipe_write+0x7a>
  802232:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802237:	8b 43 04             	mov    0x4(%ebx),%eax
  80223a:	8b 13                	mov    (%ebx),%edx
  80223c:	83 c2 20             	add    $0x20,%edx
  80223f:	39 d0                	cmp    %edx,%eax
  802241:	73 ac                	jae    8021ef <devpipe_write+0x24>
  802243:	eb c8                	jmp    80220d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802245:	89 f8                	mov    %edi,%eax
  802247:	eb 05                	jmp    80224e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802249:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80224e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802251:	5b                   	pop    %ebx
  802252:	5e                   	pop    %esi
  802253:	5f                   	pop    %edi
  802254:	c9                   	leave  
  802255:	c3                   	ret    

00802256 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	57                   	push   %edi
  80225a:	56                   	push   %esi
  80225b:	53                   	push   %ebx
  80225c:	83 ec 18             	sub    $0x18,%esp
  80225f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802262:	57                   	push   %edi
  802263:	e8 84 ee ff ff       	call   8010ec <fd2data>
  802268:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802271:	75 44                	jne    8022b7 <devpipe_read+0x61>
  802273:	be 00 00 00 00       	mov    $0x0,%esi
  802278:	eb 4f                	jmp    8022c9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80227a:	89 f0                	mov    %esi,%eax
  80227c:	eb 54                	jmp    8022d2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80227e:	89 da                	mov    %ebx,%edx
  802280:	89 f8                	mov    %edi,%eax
  802282:	e8 dd fe ff ff       	call   802164 <_pipeisclosed>
  802287:	85 c0                	test   %eax,%eax
  802289:	75 42                	jne    8022cd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80228b:	e8 79 ec ff ff       	call   800f09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802290:	8b 03                	mov    (%ebx),%eax
  802292:	3b 43 04             	cmp    0x4(%ebx),%eax
  802295:	74 e7                	je     80227e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802297:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80229c:	79 05                	jns    8022a3 <devpipe_read+0x4d>
  80229e:	48                   	dec    %eax
  80229f:	83 c8 e0             	or     $0xffffffe0,%eax
  8022a2:	40                   	inc    %eax
  8022a3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022aa:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022ad:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022af:	46                   	inc    %esi
  8022b0:	39 75 10             	cmp    %esi,0x10(%ebp)
  8022b3:	77 07                	ja     8022bc <devpipe_read+0x66>
  8022b5:	eb 12                	jmp    8022c9 <devpipe_read+0x73>
  8022b7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8022bc:	8b 03                	mov    (%ebx),%eax
  8022be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022c1:	75 d4                	jne    802297 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022c3:	85 f6                	test   %esi,%esi
  8022c5:	75 b3                	jne    80227a <devpipe_read+0x24>
  8022c7:	eb b5                	jmp    80227e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022c9:	89 f0                	mov    %esi,%eax
  8022cb:	eb 05                	jmp    8022d2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022cd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5f                   	pop    %edi
  8022d8:	c9                   	leave  
  8022d9:	c3                   	ret    

008022da <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022da:	55                   	push   %ebp
  8022db:	89 e5                	mov    %esp,%ebp
  8022dd:	57                   	push   %edi
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 28             	sub    $0x28,%esp
  8022e3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022e9:	50                   	push   %eax
  8022ea:	e8 15 ee ff ff       	call   801104 <fd_alloc>
  8022ef:	89 c3                	mov    %eax,%ebx
  8022f1:	83 c4 10             	add    $0x10,%esp
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	0f 88 24 01 00 00    	js     802420 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022fc:	83 ec 04             	sub    $0x4,%esp
  8022ff:	68 07 04 00 00       	push   $0x407
  802304:	ff 75 e4             	pushl  -0x1c(%ebp)
  802307:	6a 00                	push   $0x0
  802309:	e8 22 ec ff ff       	call   800f30 <sys_page_alloc>
  80230e:	89 c3                	mov    %eax,%ebx
  802310:	83 c4 10             	add    $0x10,%esp
  802313:	85 c0                	test   %eax,%eax
  802315:	0f 88 05 01 00 00    	js     802420 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802321:	50                   	push   %eax
  802322:	e8 dd ed ff ff       	call   801104 <fd_alloc>
  802327:	89 c3                	mov    %eax,%ebx
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	85 c0                	test   %eax,%eax
  80232e:	0f 88 dc 00 00 00    	js     802410 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802334:	83 ec 04             	sub    $0x4,%esp
  802337:	68 07 04 00 00       	push   $0x407
  80233c:	ff 75 e0             	pushl  -0x20(%ebp)
  80233f:	6a 00                	push   $0x0
  802341:	e8 ea eb ff ff       	call   800f30 <sys_page_alloc>
  802346:	89 c3                	mov    %eax,%ebx
  802348:	83 c4 10             	add    $0x10,%esp
  80234b:	85 c0                	test   %eax,%eax
  80234d:	0f 88 bd 00 00 00    	js     802410 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	ff 75 e4             	pushl  -0x1c(%ebp)
  802359:	e8 8e ed ff ff       	call   8010ec <fd2data>
  80235e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802360:	83 c4 0c             	add    $0xc,%esp
  802363:	68 07 04 00 00       	push   $0x407
  802368:	50                   	push   %eax
  802369:	6a 00                	push   $0x0
  80236b:	e8 c0 eb ff ff       	call   800f30 <sys_page_alloc>
  802370:	89 c3                	mov    %eax,%ebx
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	85 c0                	test   %eax,%eax
  802377:	0f 88 83 00 00 00    	js     802400 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80237d:	83 ec 0c             	sub    $0xc,%esp
  802380:	ff 75 e0             	pushl  -0x20(%ebp)
  802383:	e8 64 ed ff ff       	call   8010ec <fd2data>
  802388:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80238f:	50                   	push   %eax
  802390:	6a 00                	push   $0x0
  802392:	56                   	push   %esi
  802393:	6a 00                	push   $0x0
  802395:	e8 ba eb ff ff       	call   800f54 <sys_page_map>
  80239a:	89 c3                	mov    %eax,%ebx
  80239c:	83 c4 20             	add    $0x20,%esp
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	78 4f                	js     8023f2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023a3:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8023a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023b8:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8023be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023cd:	83 ec 0c             	sub    $0xc,%esp
  8023d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023d3:	e8 04 ed ff ff       	call   8010dc <fd2num>
  8023d8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023da:	83 c4 04             	add    $0x4,%esp
  8023dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8023e0:	e8 f7 ec ff ff       	call   8010dc <fd2num>
  8023e5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023f0:	eb 2e                	jmp    802420 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8023f2:	83 ec 08             	sub    $0x8,%esp
  8023f5:	56                   	push   %esi
  8023f6:	6a 00                	push   $0x0
  8023f8:	e8 7d eb ff ff       	call   800f7a <sys_page_unmap>
  8023fd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802400:	83 ec 08             	sub    $0x8,%esp
  802403:	ff 75 e0             	pushl  -0x20(%ebp)
  802406:	6a 00                	push   $0x0
  802408:	e8 6d eb ff ff       	call   800f7a <sys_page_unmap>
  80240d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802410:	83 ec 08             	sub    $0x8,%esp
  802413:	ff 75 e4             	pushl  -0x1c(%ebp)
  802416:	6a 00                	push   $0x0
  802418:	e8 5d eb ff ff       	call   800f7a <sys_page_unmap>
  80241d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802420:	89 d8                	mov    %ebx,%eax
  802422:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802425:	5b                   	pop    %ebx
  802426:	5e                   	pop    %esi
  802427:	5f                   	pop    %edi
  802428:	c9                   	leave  
  802429:	c3                   	ret    

0080242a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802433:	50                   	push   %eax
  802434:	ff 75 08             	pushl  0x8(%ebp)
  802437:	e8 3b ed ff ff       	call   801177 <fd_lookup>
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	85 c0                	test   %eax,%eax
  802441:	78 18                	js     80245b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802443:	83 ec 0c             	sub    $0xc,%esp
  802446:	ff 75 f4             	pushl  -0xc(%ebp)
  802449:	e8 9e ec ff ff       	call   8010ec <fd2data>
	return _pipeisclosed(fd, p);
  80244e:	89 c2                	mov    %eax,%edx
  802450:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802453:	e8 0c fd ff ff       	call   802164 <_pipeisclosed>
  802458:	83 c4 10             	add    $0x10,%esp
}
  80245b:	c9                   	leave  
  80245c:	c3                   	ret    
  80245d:	00 00                	add    %al,(%eax)
	...

00802460 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	57                   	push   %edi
  802464:	56                   	push   %esi
  802465:	53                   	push   %ebx
  802466:	83 ec 0c             	sub    $0xc,%esp
  802469:	8b 55 08             	mov    0x8(%ebp),%edx
	const volatile struct Env *e;

	assert(envid != 0);
  80246c:	85 d2                	test   %edx,%edx
  80246e:	75 16                	jne    802486 <wait+0x26>
  802470:	68 df 2e 80 00       	push   $0x802edf
  802475:	68 df 2d 80 00       	push   $0x802ddf
  80247a:	6a 09                	push   $0x9
  80247c:	68 ea 2e 80 00       	push   $0x802eea
  802481:	e8 9a df ff ff       	call   800420 <_panic>
	e = &envs[ENVX(envid)];
  802486:	89 d0                	mov    %edx,%eax
  802488:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80248d:	89 c1                	mov    %eax,%ecx
  80248f:	c1 e1 07             	shl    $0x7,%ecx
  802492:	8d 8c 81 08 00 c0 ee 	lea    -0x113ffff8(%ecx,%eax,4),%ecx
  802499:	8b 79 40             	mov    0x40(%ecx),%edi
  80249c:	39 d7                	cmp    %edx,%edi
  80249e:	75 36                	jne    8024d6 <wait+0x76>
  8024a0:	89 c2                	mov    %eax,%edx
  8024a2:	c1 e2 07             	shl    $0x7,%edx
  8024a5:	8d 94 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%edx
  8024ac:	8b 52 50             	mov    0x50(%edx),%edx
  8024af:	85 d2                	test   %edx,%edx
  8024b1:	74 23                	je     8024d6 <wait+0x76>
  8024b3:	89 c2                	mov    %eax,%edx
  8024b5:	c1 e2 07             	shl    $0x7,%edx
  8024b8:	8d 34 82             	lea    (%edx,%eax,4),%esi
  8024bb:	89 cb                	mov    %ecx,%ebx
  8024bd:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  8024c3:	e8 41 ea ff ff       	call   800f09 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024c8:	8b 43 40             	mov    0x40(%ebx),%eax
  8024cb:	39 f8                	cmp    %edi,%eax
  8024cd:	75 07                	jne    8024d6 <wait+0x76>
  8024cf:	8b 46 50             	mov    0x50(%esi),%eax
  8024d2:	85 c0                	test   %eax,%eax
  8024d4:	75 ed                	jne    8024c3 <wait+0x63>
		sys_yield();
}
  8024d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d9:	5b                   	pop    %ebx
  8024da:	5e                   	pop    %esi
  8024db:	5f                   	pop    %edi
  8024dc:	c9                   	leave  
  8024dd:	c3                   	ret    
	...

008024e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	56                   	push   %esi
  8024e4:	53                   	push   %ebx
  8024e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8024e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	74 0e                	je     802500 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8024f2:	83 ec 0c             	sub    $0xc,%esp
  8024f5:	50                   	push   %eax
  8024f6:	e8 30 eb ff ff       	call   80102b <sys_ipc_recv>
  8024fb:	83 c4 10             	add    $0x10,%esp
  8024fe:	eb 10                	jmp    802510 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802500:	83 ec 0c             	sub    $0xc,%esp
  802503:	68 00 00 c0 ee       	push   $0xeec00000
  802508:	e8 1e eb ff ff       	call   80102b <sys_ipc_recv>
  80250d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802510:	85 c0                	test   %eax,%eax
  802512:	75 26                	jne    80253a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802514:	85 f6                	test   %esi,%esi
  802516:	74 0a                	je     802522 <ipc_recv+0x42>
  802518:	a1 90 67 80 00       	mov    0x806790,%eax
  80251d:	8b 40 74             	mov    0x74(%eax),%eax
  802520:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802522:	85 db                	test   %ebx,%ebx
  802524:	74 0a                	je     802530 <ipc_recv+0x50>
  802526:	a1 90 67 80 00       	mov    0x806790,%eax
  80252b:	8b 40 78             	mov    0x78(%eax),%eax
  80252e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802530:	a1 90 67 80 00       	mov    0x806790,%eax
  802535:	8b 40 70             	mov    0x70(%eax),%eax
  802538:	eb 14                	jmp    80254e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80253a:	85 f6                	test   %esi,%esi
  80253c:	74 06                	je     802544 <ipc_recv+0x64>
  80253e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802544:	85 db                	test   %ebx,%ebx
  802546:	74 06                	je     80254e <ipc_recv+0x6e>
  802548:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  80254e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	c9                   	leave  
  802554:	c3                   	ret    

00802555 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	57                   	push   %edi
  802559:	56                   	push   %esi
  80255a:	53                   	push   %ebx
  80255b:	83 ec 0c             	sub    $0xc,%esp
  80255e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802561:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802564:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802567:	85 db                	test   %ebx,%ebx
  802569:	75 25                	jne    802590 <ipc_send+0x3b>
  80256b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802570:	eb 1e                	jmp    802590 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802572:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802575:	75 07                	jne    80257e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802577:	e8 8d e9 ff ff       	call   800f09 <sys_yield>
  80257c:	eb 12                	jmp    802590 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80257e:	50                   	push   %eax
  80257f:	68 f5 2e 80 00       	push   $0x802ef5
  802584:	6a 43                	push   $0x43
  802586:	68 08 2f 80 00       	push   $0x802f08
  80258b:	e8 90 de ff ff       	call   800420 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802590:	56                   	push   %esi
  802591:	53                   	push   %ebx
  802592:	57                   	push   %edi
  802593:	ff 75 08             	pushl  0x8(%ebp)
  802596:	e8 6b ea ff ff       	call   801006 <sys_ipc_try_send>
  80259b:	83 c4 10             	add    $0x10,%esp
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	75 d0                	jne    802572 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8025a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a5:	5b                   	pop    %ebx
  8025a6:	5e                   	pop    %esi
  8025a7:	5f                   	pop    %edi
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    

008025aa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8025b0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8025b6:	74 1a                	je     8025d2 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025b8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8025bd:	89 c2                	mov    %eax,%edx
  8025bf:	c1 e2 07             	shl    $0x7,%edx
  8025c2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8025c9:	8b 52 50             	mov    0x50(%edx),%edx
  8025cc:	39 ca                	cmp    %ecx,%edx
  8025ce:	75 18                	jne    8025e8 <ipc_find_env+0x3e>
  8025d0:	eb 05                	jmp    8025d7 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8025d7:	89 c2                	mov    %eax,%edx
  8025d9:	c1 e2 07             	shl    $0x7,%edx
  8025dc:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8025e3:	8b 40 40             	mov    0x40(%eax),%eax
  8025e6:	eb 0c                	jmp    8025f4 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025e8:	40                   	inc    %eax
  8025e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ee:	75 cd                	jne    8025bd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025f0:	66 b8 00 00          	mov    $0x0,%ax
}
  8025f4:	c9                   	leave  
  8025f5:	c3                   	ret    
	...

008025f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025fe:	89 c2                	mov    %eax,%edx
  802600:	c1 ea 16             	shr    $0x16,%edx
  802603:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80260a:	f6 c2 01             	test   $0x1,%dl
  80260d:	74 1e                	je     80262d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80260f:	c1 e8 0c             	shr    $0xc,%eax
  802612:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802619:	a8 01                	test   $0x1,%al
  80261b:	74 17                	je     802634 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80261d:	c1 e8 0c             	shr    $0xc,%eax
  802620:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802627:	ef 
  802628:	0f b7 c0             	movzwl %ax,%eax
  80262b:	eb 0c                	jmp    802639 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80262d:	b8 00 00 00 00       	mov    $0x0,%eax
  802632:	eb 05                	jmp    802639 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802634:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802639:	c9                   	leave  
  80263a:	c3                   	ret    
	...

0080263c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80263c:	55                   	push   %ebp
  80263d:	89 e5                	mov    %esp,%ebp
  80263f:	57                   	push   %edi
  802640:	56                   	push   %esi
  802641:	83 ec 10             	sub    $0x10,%esp
  802644:	8b 7d 08             	mov    0x8(%ebp),%edi
  802647:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80264a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  80264d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802650:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802653:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802656:	85 c0                	test   %eax,%eax
  802658:	75 2e                	jne    802688 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80265a:	39 f1                	cmp    %esi,%ecx
  80265c:	77 5a                	ja     8026b8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80265e:	85 c9                	test   %ecx,%ecx
  802660:	75 0b                	jne    80266d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802662:	b8 01 00 00 00       	mov    $0x1,%eax
  802667:	31 d2                	xor    %edx,%edx
  802669:	f7 f1                	div    %ecx
  80266b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	89 f0                	mov    %esi,%eax
  802671:	f7 f1                	div    %ecx
  802673:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802675:	89 f8                	mov    %edi,%eax
  802677:	f7 f1                	div    %ecx
  802679:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80267b:	89 f8                	mov    %edi,%eax
  80267d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80267f:	83 c4 10             	add    $0x10,%esp
  802682:	5e                   	pop    %esi
  802683:	5f                   	pop    %edi
  802684:	c9                   	leave  
  802685:	c3                   	ret    
  802686:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802688:	39 f0                	cmp    %esi,%eax
  80268a:	77 1c                	ja     8026a8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80268c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80268f:	83 f7 1f             	xor    $0x1f,%edi
  802692:	75 3c                	jne    8026d0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802694:	39 f0                	cmp    %esi,%eax
  802696:	0f 82 90 00 00 00    	jb     80272c <__udivdi3+0xf0>
  80269c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80269f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8026a2:	0f 86 84 00 00 00    	jbe    80272c <__udivdi3+0xf0>
  8026a8:	31 f6                	xor    %esi,%esi
  8026aa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026ac:	89 f8                	mov    %edi,%eax
  8026ae:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026b0:	83 c4 10             	add    $0x10,%esp
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	c9                   	leave  
  8026b6:	c3                   	ret    
  8026b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026b8:	89 f2                	mov    %esi,%edx
  8026ba:	89 f8                	mov    %edi,%eax
  8026bc:	f7 f1                	div    %ecx
  8026be:	89 c7                	mov    %eax,%edi
  8026c0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026c2:	89 f8                	mov    %edi,%eax
  8026c4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026c6:	83 c4 10             	add    $0x10,%esp
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	c9                   	leave  
  8026cc:	c3                   	ret    
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026d0:	89 f9                	mov    %edi,%ecx
  8026d2:	d3 e0                	shl    %cl,%eax
  8026d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8026d7:	b8 20 00 00 00       	mov    $0x20,%eax
  8026dc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8026de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026e1:	88 c1                	mov    %al,%cl
  8026e3:	d3 ea                	shr    %cl,%edx
  8026e5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8026e8:	09 ca                	or     %ecx,%edx
  8026ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8026ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026f0:	89 f9                	mov    %edi,%ecx
  8026f2:	d3 e2                	shl    %cl,%edx
  8026f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8026f7:	89 f2                	mov    %esi,%edx
  8026f9:	88 c1                	mov    %al,%cl
  8026fb:	d3 ea                	shr    %cl,%edx
  8026fd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802700:	89 f2                	mov    %esi,%edx
  802702:	89 f9                	mov    %edi,%ecx
  802704:	d3 e2                	shl    %cl,%edx
  802706:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802709:	88 c1                	mov    %al,%cl
  80270b:	d3 ee                	shr    %cl,%esi
  80270d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80270f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802712:	89 f0                	mov    %esi,%eax
  802714:	89 ca                	mov    %ecx,%edx
  802716:	f7 75 ec             	divl   -0x14(%ebp)
  802719:	89 d1                	mov    %edx,%ecx
  80271b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80271d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802720:	39 d1                	cmp    %edx,%ecx
  802722:	72 28                	jb     80274c <__udivdi3+0x110>
  802724:	74 1a                	je     802740 <__udivdi3+0x104>
  802726:	89 f7                	mov    %esi,%edi
  802728:	31 f6                	xor    %esi,%esi
  80272a:	eb 80                	jmp    8026ac <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80272c:	31 f6                	xor    %esi,%esi
  80272e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802733:	89 f8                	mov    %edi,%eax
  802735:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802737:	83 c4 10             	add    $0x10,%esp
  80273a:	5e                   	pop    %esi
  80273b:	5f                   	pop    %edi
  80273c:	c9                   	leave  
  80273d:	c3                   	ret    
  80273e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802740:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802743:	89 f9                	mov    %edi,%ecx
  802745:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802747:	39 c2                	cmp    %eax,%edx
  802749:	73 db                	jae    802726 <__udivdi3+0xea>
  80274b:	90                   	nop
		{
		  q0--;
  80274c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80274f:	31 f6                	xor    %esi,%esi
  802751:	e9 56 ff ff ff       	jmp    8026ac <__udivdi3+0x70>
	...

00802758 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	57                   	push   %edi
  80275c:	56                   	push   %esi
  80275d:	83 ec 20             	sub    $0x20,%esp
  802760:	8b 45 08             	mov    0x8(%ebp),%eax
  802763:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802766:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802769:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80276c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80276f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802775:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802777:	85 ff                	test   %edi,%edi
  802779:	75 15                	jne    802790 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80277b:	39 f1                	cmp    %esi,%ecx
  80277d:	0f 86 99 00 00 00    	jbe    80281c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802783:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802785:	89 d0                	mov    %edx,%eax
  802787:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802789:	83 c4 20             	add    $0x20,%esp
  80278c:	5e                   	pop    %esi
  80278d:	5f                   	pop    %edi
  80278e:	c9                   	leave  
  80278f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802790:	39 f7                	cmp    %esi,%edi
  802792:	0f 87 a4 00 00 00    	ja     80283c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802798:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80279b:	83 f0 1f             	xor    $0x1f,%eax
  80279e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027a1:	0f 84 a1 00 00 00    	je     802848 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027a7:	89 f8                	mov    %edi,%eax
  8027a9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027ac:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027ae:	bf 20 00 00 00       	mov    $0x20,%edi
  8027b3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8027b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027b9:	89 f9                	mov    %edi,%ecx
  8027bb:	d3 ea                	shr    %cl,%edx
  8027bd:	09 c2                	or     %eax,%edx
  8027bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8027c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027c8:	d3 e0                	shl    %cl,%eax
  8027ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027cd:	89 f2                	mov    %esi,%edx
  8027cf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8027d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027d4:	d3 e0                	shl    %cl,%eax
  8027d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027dc:	89 f9                	mov    %edi,%ecx
  8027de:	d3 e8                	shr    %cl,%eax
  8027e0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8027e2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027e4:	89 f2                	mov    %esi,%edx
  8027e6:	f7 75 f0             	divl   -0x10(%ebp)
  8027e9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8027eb:	f7 65 f4             	mull   -0xc(%ebp)
  8027ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8027f1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027f3:	39 d6                	cmp    %edx,%esi
  8027f5:	72 71                	jb     802868 <__umoddi3+0x110>
  8027f7:	74 7f                	je     802878 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8027f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027fc:	29 c8                	sub    %ecx,%eax
  8027fe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802800:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802803:	d3 e8                	shr    %cl,%eax
  802805:	89 f2                	mov    %esi,%edx
  802807:	89 f9                	mov    %edi,%ecx
  802809:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80280b:	09 d0                	or     %edx,%eax
  80280d:	89 f2                	mov    %esi,%edx
  80280f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802812:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802814:	83 c4 20             	add    $0x20,%esp
  802817:	5e                   	pop    %esi
  802818:	5f                   	pop    %edi
  802819:	c9                   	leave  
  80281a:	c3                   	ret    
  80281b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80281c:	85 c9                	test   %ecx,%ecx
  80281e:	75 0b                	jne    80282b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802820:	b8 01 00 00 00       	mov    $0x1,%eax
  802825:	31 d2                	xor    %edx,%edx
  802827:	f7 f1                	div    %ecx
  802829:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80282b:	89 f0                	mov    %esi,%eax
  80282d:	31 d2                	xor    %edx,%edx
  80282f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802834:	f7 f1                	div    %ecx
  802836:	e9 4a ff ff ff       	jmp    802785 <__umoddi3+0x2d>
  80283b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80283c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80283e:	83 c4 20             	add    $0x20,%esp
  802841:	5e                   	pop    %esi
  802842:	5f                   	pop    %edi
  802843:	c9                   	leave  
  802844:	c3                   	ret    
  802845:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802848:	39 f7                	cmp    %esi,%edi
  80284a:	72 05                	jb     802851 <__umoddi3+0xf9>
  80284c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80284f:	77 0c                	ja     80285d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802851:	89 f2                	mov    %esi,%edx
  802853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802856:	29 c8                	sub    %ecx,%eax
  802858:	19 fa                	sbb    %edi,%edx
  80285a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80285d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802860:	83 c4 20             	add    $0x20,%esp
  802863:	5e                   	pop    %esi
  802864:	5f                   	pop    %edi
  802865:	c9                   	leave  
  802866:	c3                   	ret    
  802867:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802868:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80286b:	89 c1                	mov    %eax,%ecx
  80286d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802870:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802873:	eb 84                	jmp    8027f9 <__umoddi3+0xa1>
  802875:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802878:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80287b:	72 eb                	jb     802868 <__umoddi3+0x110>
  80287d:	89 f2                	mov    %esi,%edx
  80287f:	e9 75 ff ff ff       	jmp    8027f9 <__umoddi3+0xa1>
