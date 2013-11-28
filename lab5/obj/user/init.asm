
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
  800075:	68 60 28 80 00       	push   $0x802860
  80007a:	e8 7d 04 00 00       	call   8004fc <cprintf>

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
  8000a4:	68 28 29 80 00       	push   $0x802928
  8000a9:	e8 4e 04 00 00       	call   8004fc <cprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	eb 10                	jmp    8000c3 <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	68 6f 28 80 00       	push   $0x80286f
  8000bb:	e8 3c 04 00 00       	call   8004fc <cprintf>
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
  8000e0:	68 64 29 80 00       	push   $0x802964
  8000e5:	e8 12 04 00 00       	call   8004fc <cprintf>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	eb 10                	jmp    8000ff <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 86 28 80 00       	push   $0x802886
  8000f7:	e8 00 04 00 00       	call   8004fc <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 9c 28 80 00       	push   $0x80289c
  800107:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010d:	50                   	push   %eax
  80010e:	e8 bc 09 00 00       	call   800acf <strcat>
	for (i = 0; i < argc; i++) {
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80011a:	7e 3c                	jle    800158 <umain+0xf2>
  80011c:	be 00 00 00 00       	mov    $0x0,%esi
		strcat(args, " '");
  800121:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	68 a8 28 80 00       	push   $0x8028a8
  80012f:	53                   	push   %ebx
  800130:	e8 9a 09 00 00       	call   800acf <strcat>
		strcat(args, argv[i]);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff 34 b7             	pushl  (%edi,%esi,4)
  80013b:	53                   	push   %ebx
  80013c:	e8 8e 09 00 00       	call   800acf <strcat>
		strcat(args, "'");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	68 a9 28 80 00       	push   $0x8028a9
  800149:	53                   	push   %ebx
  80014a:	e8 80 09 00 00       	call   800acf <strcat>
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
  800162:	68 ab 28 80 00       	push   $0x8028ab
  800167:	e8 90 03 00 00       	call   8004fc <cprintf>

	cprintf("init: running sh\n");
  80016c:	c7 04 24 af 28 80 00 	movl   $0x8028af,(%esp)
  800173:	e8 84 03 00 00       	call   8004fc <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017f:	e8 f7 10 00 00       	call   80127b <close>
	if ((r = opencons()) < 0)
  800184:	e8 dd 01 00 00       	call   800366 <opencons>
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	85 c0                	test   %eax,%eax
  80018e:	79 12                	jns    8001a2 <umain+0x13c>
		panic("opencons: %e", r);
  800190:	50                   	push   %eax
  800191:	68 c1 28 80 00       	push   $0x8028c1
  800196:	6a 37                	push   $0x37
  800198:	68 ce 28 80 00       	push   $0x8028ce
  80019d:	e8 82 02 00 00       	call   800424 <_panic>
	if (r != 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	74 12                	je     8001b8 <umain+0x152>
		panic("first opencons used fd %d", r);
  8001a6:	50                   	push   %eax
  8001a7:	68 da 28 80 00       	push   $0x8028da
  8001ac:	6a 39                	push   $0x39
  8001ae:	68 ce 28 80 00       	push   $0x8028ce
  8001b3:	e8 6c 02 00 00       	call   800424 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	6a 01                	push   $0x1
  8001bd:	6a 00                	push   $0x0
  8001bf:	e8 05 11 00 00       	call   8012c9 <dup>
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	79 12                	jns    8001dd <umain+0x177>
		panic("dup: %e", r);
  8001cb:	50                   	push   %eax
  8001cc:	68 f4 28 80 00       	push   $0x8028f4
  8001d1:	6a 3b                	push   $0x3b
  8001d3:	68 ce 28 80 00       	push   $0x8028ce
  8001d8:	e8 47 02 00 00       	call   800424 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	68 fc 28 80 00       	push   $0x8028fc
  8001e5:	e8 12 03 00 00       	call   8004fc <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001ea:	83 c4 0c             	add    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	68 10 29 80 00       	push   $0x802910
  8001f4:	68 0f 29 80 00       	push   $0x80290f
  8001f9:	e8 2a 1e 00 00       	call   802028 <spawnl>
		if (r < 0) {
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	85 c0                	test   %eax,%eax
  800203:	79 13                	jns    800218 <umain+0x1b2>
			cprintf("init: spawn sh: %e\n", r);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	50                   	push   %eax
  800209:	68 13 29 80 00       	push   $0x802913
  80020e:	e8 e9 02 00 00       	call   8004fc <cprintf>
			continue;
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	eb c5                	jmp    8001dd <umain+0x177>
		}
		wait(r);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	e8 03 22 00 00       	call   802424 <wait>
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
  800238:	68 93 29 80 00       	push   $0x802993
  80023d:	ff 75 0c             	pushl  0xc(%ebp)
  800240:	e8 6d 08 00 00       	call   800ab2 <strcpy>
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
  800286:	e8 e8 09 00 00       	call   800c73 <memmove>
		sys_cputs(buf, m);
  80028b:	83 c4 08             	add    $0x8,%esp
  80028e:	53                   	push   %ebx
  80028f:	57                   	push   %edi
  800290:	e8 e8 0b 00 00       	call   800e7d <sys_cputs>
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
  8002c0:	e8 48 0c 00 00       	call   800f0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002c5:	e8 d9 0b 00 00       	call   800ea3 <sys_cgetc>
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
  800305:	e8 73 0b 00 00       	call   800e7d <sys_cputs>
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
  80031d:	e8 96 10 00 00       	call   8013b8 <read>
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
  800347:	e8 eb 0d 00 00       	call   801137 <fd_lookup>
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
  800370:	e8 4f 0d 00 00       	call   8010c4 <fd_alloc>
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	85 c0                	test   %eax,%eax
  80037a:	78 3a                	js     8003b6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	68 07 04 00 00       	push   $0x407
  800384:	ff 75 f4             	pushl  -0xc(%ebp)
  800387:	6a 00                	push   $0x0
  800389:	e8 a6 0b 00 00       	call   800f34 <sys_page_alloc>
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
  8003ae:	e8 e9 0c 00 00       	call   80109c <fd2num>
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
  8003c3:	e8 21 0b 00 00       	call   800ee9 <sys_getenvid>
  8003c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003d4:	c1 e0 07             	shl    $0x7,%eax
  8003d7:	29 d0                	sub    %edx,%eax
  8003d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003de:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003e3:	85 f6                	test   %esi,%esi
  8003e5:	7e 07                	jle    8003ee <libmain+0x36>
		binaryname = argv[0];
  8003e7:	8b 03                	mov    (%ebx),%eax
  8003e9:	a3 8c 47 80 00       	mov    %eax,0x80478c
	// call user main routine
	umain(argc, argv);
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	56                   	push   %esi
  8003f3:	e8 6e fc ff ff       	call   800066 <umain>

	// exit gracefully
	exit();
  8003f8:	e8 0b 00 00 00       	call   800408 <exit>
  8003fd:	83 c4 10             	add    $0x10,%esp
}
  800400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800403:	5b                   	pop    %ebx
  800404:	5e                   	pop    %esi
  800405:	c9                   	leave  
  800406:	c3                   	ret    
	...

00800408 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80040e:	e8 93 0e 00 00       	call   8012a6 <close_all>
	sys_env_destroy(0);
  800413:	83 ec 0c             	sub    $0xc,%esp
  800416:	6a 00                	push   $0x0
  800418:	e8 aa 0a 00 00       	call   800ec7 <sys_env_destroy>
  80041d:	83 c4 10             	add    $0x10,%esp
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    
	...

00800424 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800429:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042c:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  800432:	e8 b2 0a 00 00       	call   800ee9 <sys_getenvid>
  800437:	83 ec 0c             	sub    $0xc,%esp
  80043a:	ff 75 0c             	pushl  0xc(%ebp)
  80043d:	ff 75 08             	pushl  0x8(%ebp)
  800440:	53                   	push   %ebx
  800441:	50                   	push   %eax
  800442:	68 ac 29 80 00       	push   $0x8029ac
  800447:	e8 b0 00 00 00       	call   8004fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	56                   	push   %esi
  800450:	ff 75 10             	pushl  0x10(%ebp)
  800453:	e8 53 00 00 00       	call   8004ab <vcprintf>
	cprintf("\n");
  800458:	c7 04 24 98 2e 80 00 	movl   $0x802e98,(%esp)
  80045f:	e8 98 00 00 00       	call   8004fc <cprintf>
  800464:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800467:	cc                   	int3   
  800468:	eb fd                	jmp    800467 <_panic+0x43>
	...

0080046c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	53                   	push   %ebx
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800476:	8b 03                	mov    (%ebx),%eax
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80047f:	40                   	inc    %eax
  800480:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800482:	3d ff 00 00 00       	cmp    $0xff,%eax
  800487:	75 1a                	jne    8004a3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	68 ff 00 00 00       	push   $0xff
  800491:	8d 43 08             	lea    0x8(%ebx),%eax
  800494:	50                   	push   %eax
  800495:	e8 e3 09 00 00       	call   800e7d <sys_cputs>
		b->idx = 0;
  80049a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004a3:	ff 43 04             	incl   0x4(%ebx)
}
  8004a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004bb:	00 00 00 
	b.cnt = 0;
  8004be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	68 6c 04 80 00       	push   $0x80046c
  8004da:	e8 82 01 00 00       	call   800661 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004df:	83 c4 08             	add    $0x8,%esp
  8004e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 89 09 00 00       	call   800e7d <sys_cputs>

	return b.cnt;
}
  8004f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004fa:	c9                   	leave  
  8004fb:	c3                   	ret    

008004fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800502:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800505:	50                   	push   %eax
  800506:	ff 75 08             	pushl  0x8(%ebp)
  800509:	e8 9d ff ff ff       	call   8004ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	57                   	push   %edi
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 2c             	sub    $0x2c,%esp
  800519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051c:	89 d6                	mov    %edx,%esi
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	8b 55 0c             	mov    0xc(%ebp),%edx
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052a:	8b 45 10             	mov    0x10(%ebp),%eax
  80052d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800530:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800533:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800536:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80053d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800540:	72 0c                	jb     80054e <printnum+0x3e>
  800542:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800545:	76 07                	jbe    80054e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800547:	4b                   	dec    %ebx
  800548:	85 db                	test   %ebx,%ebx
  80054a:	7f 31                	jg     80057d <printnum+0x6d>
  80054c:	eb 3f                	jmp    80058d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80054e:	83 ec 0c             	sub    $0xc,%esp
  800551:	57                   	push   %edi
  800552:	4b                   	dec    %ebx
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 d4             	pushl  -0x2c(%ebp)
  80055b:	ff 75 d0             	pushl  -0x30(%ebp)
  80055e:	ff 75 dc             	pushl  -0x24(%ebp)
  800561:	ff 75 d8             	pushl  -0x28(%ebp)
  800564:	e8 af 20 00 00       	call   802618 <__udivdi3>
  800569:	83 c4 18             	add    $0x18,%esp
  80056c:	52                   	push   %edx
  80056d:	50                   	push   %eax
  80056e:	89 f2                	mov    %esi,%edx
  800570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800573:	e8 98 ff ff ff       	call   800510 <printnum>
  800578:	83 c4 20             	add    $0x20,%esp
  80057b:	eb 10                	jmp    80058d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	56                   	push   %esi
  800581:	57                   	push   %edi
  800582:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800585:	4b                   	dec    %ebx
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 db                	test   %ebx,%ebx
  80058b:	7f f0                	jg     80057d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	56                   	push   %esi
  800591:	83 ec 04             	sub    $0x4,%esp
  800594:	ff 75 d4             	pushl  -0x2c(%ebp)
  800597:	ff 75 d0             	pushl  -0x30(%ebp)
  80059a:	ff 75 dc             	pushl  -0x24(%ebp)
  80059d:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a0:	e8 8f 21 00 00       	call   802734 <__umoddi3>
  8005a5:	83 c4 14             	add    $0x14,%esp
  8005a8:	0f be 80 cf 29 80 00 	movsbl 0x8029cf(%eax),%eax
  8005af:	50                   	push   %eax
  8005b0:	ff 55 e4             	call   *-0x1c(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
}
  8005b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b9:	5b                   	pop    %ebx
  8005ba:	5e                   	pop    %esi
  8005bb:	5f                   	pop    %edi
  8005bc:	c9                   	leave  
  8005bd:	c3                   	ret    

008005be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c1:	83 fa 01             	cmp    $0x1,%edx
  8005c4:	7e 0e                	jle    8005d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005cb:	89 08                	mov    %ecx,(%eax)
  8005cd:	8b 02                	mov    (%edx),%eax
  8005cf:	8b 52 04             	mov    0x4(%edx),%edx
  8005d2:	eb 22                	jmp    8005f6 <getuint+0x38>
	else if (lflag)
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	74 10                	je     8005e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 02                	mov    (%edx),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e6:	eb 0e                	jmp    8005f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ed:	89 08                	mov    %ecx,(%eax)
  8005ef:	8b 02                	mov    (%edx),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005fb:	83 fa 01             	cmp    $0x1,%edx
  8005fe:	7e 0e                	jle    80060e <getint+0x16>
		return va_arg(*ap, long long);
  800600:	8b 10                	mov    (%eax),%edx
  800602:	8d 4a 08             	lea    0x8(%edx),%ecx
  800605:	89 08                	mov    %ecx,(%eax)
  800607:	8b 02                	mov    (%edx),%eax
  800609:	8b 52 04             	mov    0x4(%edx),%edx
  80060c:	eb 1a                	jmp    800628 <getint+0x30>
	else if (lflag)
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 0c                	je     80061e <getint+0x26>
		return va_arg(*ap, long);
  800612:	8b 10                	mov    (%eax),%edx
  800614:	8d 4a 04             	lea    0x4(%edx),%ecx
  800617:	89 08                	mov    %ecx,(%eax)
  800619:	8b 02                	mov    (%edx),%eax
  80061b:	99                   	cltd   
  80061c:	eb 0a                	jmp    800628 <getint+0x30>
	else
		return va_arg(*ap, int);
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	8d 4a 04             	lea    0x4(%edx),%ecx
  800623:	89 08                	mov    %ecx,(%eax)
  800625:	8b 02                	mov    (%edx),%eax
  800627:	99                   	cltd   
}
  800628:	c9                   	leave  
  800629:	c3                   	ret    

0080062a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800630:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800633:	8b 10                	mov    (%eax),%edx
  800635:	3b 50 04             	cmp    0x4(%eax),%edx
  800638:	73 08                	jae    800642 <sprintputch+0x18>
		*b->buf++ = ch;
  80063a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80063d:	88 0a                	mov    %cl,(%edx)
  80063f:	42                   	inc    %edx
  800640:	89 10                	mov    %edx,(%eax)
}
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80064d:	50                   	push   %eax
  80064e:	ff 75 10             	pushl  0x10(%ebp)
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	ff 75 08             	pushl  0x8(%ebp)
  800657:	e8 05 00 00 00       	call   800661 <vprintfmt>
	va_end(ap);
  80065c:	83 c4 10             	add    $0x10,%esp
}
  80065f:	c9                   	leave  
  800660:	c3                   	ret    

00800661 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	57                   	push   %edi
  800665:	56                   	push   %esi
  800666:	53                   	push   %ebx
  800667:	83 ec 2c             	sub    $0x2c,%esp
  80066a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80066d:	8b 75 10             	mov    0x10(%ebp),%esi
  800670:	eb 13                	jmp    800685 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800672:	85 c0                	test   %eax,%eax
  800674:	0f 84 6d 03 00 00    	je     8009e7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	57                   	push   %edi
  80067e:	50                   	push   %eax
  80067f:	ff 55 08             	call   *0x8(%ebp)
  800682:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800685:	0f b6 06             	movzbl (%esi),%eax
  800688:	46                   	inc    %esi
  800689:	83 f8 25             	cmp    $0x25,%eax
  80068c:	75 e4                	jne    800672 <vprintfmt+0x11>
  80068e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800692:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800699:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8006a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ac:	eb 28                	jmp    8006d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8006b4:	eb 20                	jmp    8006d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006b8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8006bc:	eb 18                	jmp    8006d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006c7:	eb 0d                	jmp    8006d6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8a 06                	mov    (%esi),%al
  8006d8:	0f b6 d0             	movzbl %al,%edx
  8006db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006de:	83 e8 23             	sub    $0x23,%eax
  8006e1:	3c 55                	cmp    $0x55,%al
  8006e3:	0f 87 e0 02 00 00    	ja     8009c9 <vprintfmt+0x368>
  8006e9:	0f b6 c0             	movzbl %al,%eax
  8006ec:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006f3:	83 ea 30             	sub    $0x30,%edx
  8006f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8006f9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8006fc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006ff:	83 fa 09             	cmp    $0x9,%edx
  800702:	77 44                	ja     800748 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	89 de                	mov    %ebx,%esi
  800706:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800709:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80070a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80070d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800711:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800714:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800717:	83 fb 09             	cmp    $0x9,%ebx
  80071a:	76 ed                	jbe    800709 <vprintfmt+0xa8>
  80071c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80071f:	eb 29                	jmp    80074a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8d 50 04             	lea    0x4(%eax),%edx
  800727:	89 55 14             	mov    %edx,0x14(%ebp)
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800731:	eb 17                	jmp    80074a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800733:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800737:	78 85                	js     8006be <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	89 de                	mov    %ebx,%esi
  80073b:	eb 99                	jmp    8006d6 <vprintfmt+0x75>
  80073d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80073f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800746:	eb 8e                	jmp    8006d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80074a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074e:	79 86                	jns    8006d6 <vprintfmt+0x75>
  800750:	e9 74 ff ff ff       	jmp    8006c9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800755:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	89 de                	mov    %ebx,%esi
  800758:	e9 79 ff ff ff       	jmp    8006d6 <vprintfmt+0x75>
  80075d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	57                   	push   %edi
  80076d:	ff 30                	pushl  (%eax)
  80076f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800772:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800778:	e9 08 ff ff ff       	jmp    800685 <vprintfmt+0x24>
  80077d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	85 c0                	test   %eax,%eax
  80078d:	79 02                	jns    800791 <vprintfmt+0x130>
  80078f:	f7 d8                	neg    %eax
  800791:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800793:	83 f8 0f             	cmp    $0xf,%eax
  800796:	7f 0b                	jg     8007a3 <vprintfmt+0x142>
  800798:	8b 04 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%eax
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	75 1a                	jne    8007bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8007a3:	52                   	push   %edx
  8007a4:	68 e7 29 80 00       	push   $0x8029e7
  8007a9:	57                   	push   %edi
  8007aa:	ff 75 08             	pushl  0x8(%ebp)
  8007ad:	e8 92 fe ff ff       	call   800644 <printfmt>
  8007b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007b8:	e9 c8 fe ff ff       	jmp    800685 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8007bd:	50                   	push   %eax
  8007be:	68 b1 2d 80 00       	push   $0x802db1
  8007c3:	57                   	push   %edi
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 78 fe ff ff       	call   800644 <printfmt>
  8007cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007d2:	e9 ae fe ff ff       	jmp    800685 <vprintfmt+0x24>
  8007d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007da:	89 de                	mov    %ebx,%esi
  8007dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	75 07                	jne    8007fb <vprintfmt+0x19a>
				p = "(null)";
  8007f4:	c7 45 d0 e0 29 80 00 	movl   $0x8029e0,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007fb:	85 db                	test   %ebx,%ebx
  8007fd:	7e 42                	jle    800841 <vprintfmt+0x1e0>
  8007ff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800803:	74 3c                	je     800841 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	51                   	push   %ecx
  800809:	ff 75 d0             	pushl  -0x30(%ebp)
  80080c:	e8 6f 02 00 00       	call   800a80 <strnlen>
  800811:	29 c3                	sub    %eax,%ebx
  800813:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	85 db                	test   %ebx,%ebx
  80081b:	7e 24                	jle    800841 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80081d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800821:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800824:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	57                   	push   %edi
  80082b:	53                   	push   %ebx
  80082c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082f:	4e                   	dec    %esi
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	85 f6                	test   %esi,%esi
  800835:	7f f0                	jg     800827 <vprintfmt+0x1c6>
  800837:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80083a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800841:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800844:	0f be 02             	movsbl (%edx),%eax
  800847:	85 c0                	test   %eax,%eax
  800849:	75 47                	jne    800892 <vprintfmt+0x231>
  80084b:	eb 37                	jmp    800884 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80084d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800851:	74 16                	je     800869 <vprintfmt+0x208>
  800853:	8d 50 e0             	lea    -0x20(%eax),%edx
  800856:	83 fa 5e             	cmp    $0x5e,%edx
  800859:	76 0e                	jbe    800869 <vprintfmt+0x208>
					putch('?', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	57                   	push   %edi
  80085f:	6a 3f                	push   $0x3f
  800861:	ff 55 08             	call   *0x8(%ebp)
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 0b                	jmp    800874 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	57                   	push   %edi
  80086d:	50                   	push   %eax
  80086e:	ff 55 08             	call   *0x8(%ebp)
  800871:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800874:	ff 4d e4             	decl   -0x1c(%ebp)
  800877:	0f be 03             	movsbl (%ebx),%eax
  80087a:	85 c0                	test   %eax,%eax
  80087c:	74 03                	je     800881 <vprintfmt+0x220>
  80087e:	43                   	inc    %ebx
  80087f:	eb 1b                	jmp    80089c <vprintfmt+0x23b>
  800881:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800884:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800888:	7f 1e                	jg     8008a8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80088d:	e9 f3 fd ff ff       	jmp    800685 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800892:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800895:	43                   	inc    %ebx
  800896:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800899:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80089c:	85 f6                	test   %esi,%esi
  80089e:	78 ad                	js     80084d <vprintfmt+0x1ec>
  8008a0:	4e                   	dec    %esi
  8008a1:	79 aa                	jns    80084d <vprintfmt+0x1ec>
  8008a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008a6:	eb dc                	jmp    800884 <vprintfmt+0x223>
  8008a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	57                   	push   %edi
  8008af:	6a 20                	push   $0x20
  8008b1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b4:	4b                   	dec    %ebx
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	85 db                	test   %ebx,%ebx
  8008ba:	7f ef                	jg     8008ab <vprintfmt+0x24a>
  8008bc:	e9 c4 fd ff ff       	jmp    800685 <vprintfmt+0x24>
  8008c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c4:	89 ca                	mov    %ecx,%edx
  8008c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c9:	e8 2a fd ff ff       	call   8005f8 <getint>
  8008ce:	89 c3                	mov    %eax,%ebx
  8008d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	78 0a                	js     8008e0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008db:	e9 b0 00 00 00       	jmp    800990 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	57                   	push   %edi
  8008e4:	6a 2d                	push   $0x2d
  8008e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e9:	f7 db                	neg    %ebx
  8008eb:	83 d6 00             	adc    $0x0,%esi
  8008ee:	f7 de                	neg    %esi
  8008f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f8:	e9 93 00 00 00       	jmp    800990 <vprintfmt+0x32f>
  8008fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800900:	89 ca                	mov    %ecx,%edx
  800902:	8d 45 14             	lea    0x14(%ebp),%eax
  800905:	e8 b4 fc ff ff       	call   8005be <getuint>
  80090a:	89 c3                	mov    %eax,%ebx
  80090c:	89 d6                	mov    %edx,%esi
			base = 10;
  80090e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800913:	eb 7b                	jmp    800990 <vprintfmt+0x32f>
  800915:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800918:	89 ca                	mov    %ecx,%edx
  80091a:	8d 45 14             	lea    0x14(%ebp),%eax
  80091d:	e8 d6 fc ff ff       	call   8005f8 <getint>
  800922:	89 c3                	mov    %eax,%ebx
  800924:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800926:	85 d2                	test   %edx,%edx
  800928:	78 07                	js     800931 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80092a:	b8 08 00 00 00       	mov    $0x8,%eax
  80092f:	eb 5f                	jmp    800990 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	57                   	push   %edi
  800935:	6a 2d                	push   $0x2d
  800937:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80093a:	f7 db                	neg    %ebx
  80093c:	83 d6 00             	adc    $0x0,%esi
  80093f:	f7 de                	neg    %esi
  800941:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800944:	b8 08 00 00 00       	mov    $0x8,%eax
  800949:	eb 45                	jmp    800990 <vprintfmt+0x32f>
  80094b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	57                   	push   %edi
  800952:	6a 30                	push   $0x30
  800954:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800957:	83 c4 08             	add    $0x8,%esp
  80095a:	57                   	push   %edi
  80095b:	6a 78                	push   $0x78
  80095d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8d 50 04             	lea    0x4(%eax),%edx
  800966:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800969:	8b 18                	mov    (%eax),%ebx
  80096b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800970:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800978:	eb 16                	jmp    800990 <vprintfmt+0x32f>
  80097a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80097d:	89 ca                	mov    %ecx,%edx
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 37 fc ff ff       	call   8005be <getuint>
  800987:	89 c3                	mov    %eax,%ebx
  800989:	89 d6                	mov    %edx,%esi
			base = 16;
  80098b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800990:	83 ec 0c             	sub    $0xc,%esp
  800993:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800997:	52                   	push   %edx
  800998:	ff 75 e4             	pushl  -0x1c(%ebp)
  80099b:	50                   	push   %eax
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	89 fa                	mov    %edi,%edx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	e8 68 fb ff ff       	call   800510 <printnum>
			break;
  8009a8:	83 c4 20             	add    $0x20,%esp
  8009ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8009ae:	e9 d2 fc ff ff       	jmp    800685 <vprintfmt+0x24>
  8009b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	57                   	push   %edi
  8009ba:	52                   	push   %edx
  8009bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009c4:	e9 bc fc ff ff       	jmp    800685 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	57                   	push   %edi
  8009cd:	6a 25                	push   $0x25
  8009cf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	eb 02                	jmp    8009d9 <vprintfmt+0x378>
  8009d7:	89 c6                	mov    %eax,%esi
  8009d9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8009dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009e0:	75 f5                	jne    8009d7 <vprintfmt+0x376>
  8009e2:	e9 9e fc ff ff       	jmp    800685 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8009e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 18             	sub    $0x18,%esp
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a02:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a0c:	85 c0                	test   %eax,%eax
  800a0e:	74 26                	je     800a36 <vsnprintf+0x47>
  800a10:	85 d2                	test   %edx,%edx
  800a12:	7e 29                	jle    800a3d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a14:	ff 75 14             	pushl  0x14(%ebp)
  800a17:	ff 75 10             	pushl  0x10(%ebp)
  800a1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a1d:	50                   	push   %eax
  800a1e:	68 2a 06 80 00       	push   $0x80062a
  800a23:	e8 39 fc ff ff       	call   800661 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a31:	83 c4 10             	add    $0x10,%esp
  800a34:	eb 0c                	jmp    800a42 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a3b:	eb 05                	jmp    800a42 <vsnprintf+0x53>
  800a3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a4a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a4d:	50                   	push   %eax
  800a4e:	ff 75 10             	pushl  0x10(%ebp)
  800a51:	ff 75 0c             	pushl  0xc(%ebp)
  800a54:	ff 75 08             	pushl  0x8(%ebp)
  800a57:	e8 93 ff ff ff       	call   8009ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    
	...

00800a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a66:	80 3a 00             	cmpb   $0x0,(%edx)
  800a69:	74 0e                	je     800a79 <strlen+0x19>
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a70:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a71:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a75:	75 f9                	jne    800a70 <strlen+0x10>
  800a77:	eb 05                	jmp    800a7e <strlen+0x1e>
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a89:	85 d2                	test   %edx,%edx
  800a8b:	74 17                	je     800aa4 <strnlen+0x24>
  800a8d:	80 39 00             	cmpb   $0x0,(%ecx)
  800a90:	74 19                	je     800aab <strnlen+0x2b>
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a97:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a98:	39 d0                	cmp    %edx,%eax
  800a9a:	74 14                	je     800ab0 <strnlen+0x30>
  800a9c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aa0:	75 f5                	jne    800a97 <strnlen+0x17>
  800aa2:	eb 0c                	jmp    800ab0 <strnlen+0x30>
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	eb 05                	jmp    800ab0 <strnlen+0x30>
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ac4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac7:	42                   	inc    %edx
  800ac8:	84 c9                	test   %cl,%cl
  800aca:	75 f5                	jne    800ac1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800acc:	5b                   	pop    %ebx
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	53                   	push   %ebx
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad6:	53                   	push   %ebx
  800ad7:	e8 84 ff ff ff       	call   800a60 <strlen>
  800adc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800adf:	ff 75 0c             	pushl  0xc(%ebp)
  800ae2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ae5:	50                   	push   %eax
  800ae6:	e8 c7 ff ff ff       	call   800ab2 <strcpy>
	return dst;
}
  800aeb:	89 d8                	mov    %ebx,%eax
  800aed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b00:	85 f6                	test   %esi,%esi
  800b02:	74 15                	je     800b19 <strncpy+0x27>
  800b04:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b09:	8a 1a                	mov    (%edx),%bl
  800b0b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0e:	80 3a 01             	cmpb   $0x1,(%edx)
  800b11:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b14:	41                   	inc    %ecx
  800b15:	39 ce                	cmp    %ecx,%esi
  800b17:	77 f0                	ja     800b09 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b29:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b2c:	85 f6                	test   %esi,%esi
  800b2e:	74 32                	je     800b62 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800b30:	83 fe 01             	cmp    $0x1,%esi
  800b33:	74 22                	je     800b57 <strlcpy+0x3a>
  800b35:	8a 0b                	mov    (%ebx),%cl
  800b37:	84 c9                	test   %cl,%cl
  800b39:	74 20                	je     800b5b <strlcpy+0x3e>
  800b3b:	89 f8                	mov    %edi,%eax
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800b42:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b45:	88 08                	mov    %cl,(%eax)
  800b47:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b48:	39 f2                	cmp    %esi,%edx
  800b4a:	74 11                	je     800b5d <strlcpy+0x40>
  800b4c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800b50:	42                   	inc    %edx
  800b51:	84 c9                	test   %cl,%cl
  800b53:	75 f0                	jne    800b45 <strlcpy+0x28>
  800b55:	eb 06                	jmp    800b5d <strlcpy+0x40>
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	eb 02                	jmp    800b5d <strlcpy+0x40>
  800b5b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b5d:	c6 00 00             	movb   $0x0,(%eax)
  800b60:	eb 02                	jmp    800b64 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b62:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800b64:	29 f8                	sub    %edi,%eax
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b74:	8a 01                	mov    (%ecx),%al
  800b76:	84 c0                	test   %al,%al
  800b78:	74 10                	je     800b8a <strcmp+0x1f>
  800b7a:	3a 02                	cmp    (%edx),%al
  800b7c:	75 0c                	jne    800b8a <strcmp+0x1f>
		p++, q++;
  800b7e:	41                   	inc    %ecx
  800b7f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b80:	8a 01                	mov    (%ecx),%al
  800b82:	84 c0                	test   %al,%al
  800b84:	74 04                	je     800b8a <strcmp+0x1f>
  800b86:	3a 02                	cmp    (%edx),%al
  800b88:	74 f4                	je     800b7e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8a:	0f b6 c0             	movzbl %al,%eax
  800b8d:	0f b6 12             	movzbl (%edx),%edx
  800b90:	29 d0                	sub    %edx,%eax
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	53                   	push   %ebx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	74 1b                	je     800bc0 <strncmp+0x2c>
  800ba5:	8a 1a                	mov    (%edx),%bl
  800ba7:	84 db                	test   %bl,%bl
  800ba9:	74 24                	je     800bcf <strncmp+0x3b>
  800bab:	3a 19                	cmp    (%ecx),%bl
  800bad:	75 20                	jne    800bcf <strncmp+0x3b>
  800baf:	48                   	dec    %eax
  800bb0:	74 15                	je     800bc7 <strncmp+0x33>
		n--, p++, q++;
  800bb2:	42                   	inc    %edx
  800bb3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bb4:	8a 1a                	mov    (%edx),%bl
  800bb6:	84 db                	test   %bl,%bl
  800bb8:	74 15                	je     800bcf <strncmp+0x3b>
  800bba:	3a 19                	cmp    (%ecx),%bl
  800bbc:	74 f1                	je     800baf <strncmp+0x1b>
  800bbe:	eb 0f                	jmp    800bcf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc5:	eb 05                	jmp    800bcc <strncmp+0x38>
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bcf:	0f b6 02             	movzbl (%edx),%eax
  800bd2:	0f b6 11             	movzbl (%ecx),%edx
  800bd5:	29 d0                	sub    %edx,%eax
  800bd7:	eb f3                	jmp    800bcc <strncmp+0x38>

00800bd9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800be2:	8a 10                	mov    (%eax),%dl
  800be4:	84 d2                	test   %dl,%dl
  800be6:	74 18                	je     800c00 <strchr+0x27>
		if (*s == c)
  800be8:	38 ca                	cmp    %cl,%dl
  800bea:	75 06                	jne    800bf2 <strchr+0x19>
  800bec:	eb 17                	jmp    800c05 <strchr+0x2c>
  800bee:	38 ca                	cmp    %cl,%dl
  800bf0:	74 13                	je     800c05 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bf2:	40                   	inc    %eax
  800bf3:	8a 10                	mov    (%eax),%dl
  800bf5:	84 d2                	test   %dl,%dl
  800bf7:	75 f5                	jne    800bee <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfe:	eb 05                	jmp    800c05 <strchr+0x2c>
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c10:	8a 10                	mov    (%eax),%dl
  800c12:	84 d2                	test   %dl,%dl
  800c14:	74 11                	je     800c27 <strfind+0x20>
		if (*s == c)
  800c16:	38 ca                	cmp    %cl,%dl
  800c18:	75 06                	jne    800c20 <strfind+0x19>
  800c1a:	eb 0b                	jmp    800c27 <strfind+0x20>
  800c1c:	38 ca                	cmp    %cl,%dl
  800c1e:	74 07                	je     800c27 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c20:	40                   	inc    %eax
  800c21:	8a 10                	mov    (%eax),%dl
  800c23:	84 d2                	test   %dl,%dl
  800c25:	75 f5                	jne    800c1c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c38:	85 c9                	test   %ecx,%ecx
  800c3a:	74 30                	je     800c6c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c42:	75 25                	jne    800c69 <memset+0x40>
  800c44:	f6 c1 03             	test   $0x3,%cl
  800c47:	75 20                	jne    800c69 <memset+0x40>
		c &= 0xFF;
  800c49:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	c1 e3 08             	shl    $0x8,%ebx
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	c1 e6 18             	shl    $0x18,%esi
  800c56:	89 d0                	mov    %edx,%eax
  800c58:	c1 e0 10             	shl    $0x10,%eax
  800c5b:	09 f0                	or     %esi,%eax
  800c5d:	09 d0                	or     %edx,%eax
  800c5f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c61:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c64:	fc                   	cld    
  800c65:	f3 ab                	rep stos %eax,%es:(%edi)
  800c67:	eb 03                	jmp    800c6c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c69:	fc                   	cld    
  800c6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c6c:	89 f8                	mov    %edi,%eax
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c81:	39 c6                	cmp    %eax,%esi
  800c83:	73 34                	jae    800cb9 <memmove+0x46>
  800c85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c88:	39 d0                	cmp    %edx,%eax
  800c8a:	73 2d                	jae    800cb9 <memmove+0x46>
		s += n;
		d += n;
  800c8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8f:	f6 c2 03             	test   $0x3,%dl
  800c92:	75 1b                	jne    800caf <memmove+0x3c>
  800c94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9a:	75 13                	jne    800caf <memmove+0x3c>
  800c9c:	f6 c1 03             	test   $0x3,%cl
  800c9f:	75 0e                	jne    800caf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ca1:	83 ef 04             	sub    $0x4,%edi
  800ca4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800caa:	fd                   	std    
  800cab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cad:	eb 07                	jmp    800cb6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800caf:	4f                   	dec    %edi
  800cb0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb3:	fd                   	std    
  800cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb6:	fc                   	cld    
  800cb7:	eb 20                	jmp    800cd9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbf:	75 13                	jne    800cd4 <memmove+0x61>
  800cc1:	a8 03                	test   $0x3,%al
  800cc3:	75 0f                	jne    800cd4 <memmove+0x61>
  800cc5:	f6 c1 03             	test   $0x3,%cl
  800cc8:	75 0a                	jne    800cd4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ccd:	89 c7                	mov    %eax,%edi
  800ccf:	fc                   	cld    
  800cd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd2:	eb 05                	jmp    800cd9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd4:	89 c7                	mov    %eax,%edi
  800cd6:	fc                   	cld    
  800cd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ce0:	ff 75 10             	pushl  0x10(%ebp)
  800ce3:	ff 75 0c             	pushl  0xc(%ebp)
  800ce6:	ff 75 08             	pushl  0x8(%ebp)
  800ce9:	e8 85 ff ff ff       	call   800c73 <memmove>
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cff:	85 ff                	test   %edi,%edi
  800d01:	74 32                	je     800d35 <memcmp+0x45>
		if (*s1 != *s2)
  800d03:	8a 03                	mov    (%ebx),%al
  800d05:	8a 0e                	mov    (%esi),%cl
  800d07:	38 c8                	cmp    %cl,%al
  800d09:	74 19                	je     800d24 <memcmp+0x34>
  800d0b:	eb 0d                	jmp    800d1a <memcmp+0x2a>
  800d0d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800d11:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800d15:	42                   	inc    %edx
  800d16:	38 c8                	cmp    %cl,%al
  800d18:	74 10                	je     800d2a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800d1a:	0f b6 c0             	movzbl %al,%eax
  800d1d:	0f b6 c9             	movzbl %cl,%ecx
  800d20:	29 c8                	sub    %ecx,%eax
  800d22:	eb 16                	jmp    800d3a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d24:	4f                   	dec    %edi
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	39 fa                	cmp    %edi,%edx
  800d2c:	75 df                	jne    800d0d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d33:	eb 05                	jmp    800d3a <memcmp+0x4a>
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	73 12                	jae    800d60 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800d51:	38 08                	cmp    %cl,(%eax)
  800d53:	75 06                	jne    800d5b <memfind+0x1c>
  800d55:	eb 09                	jmp    800d60 <memfind+0x21>
  800d57:	38 08                	cmp    %cl,(%eax)
  800d59:	74 05                	je     800d60 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5b:	40                   	inc    %eax
  800d5c:	39 c2                	cmp    %eax,%edx
  800d5e:	77 f7                	ja     800d57 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6e:	eb 01                	jmp    800d71 <strtol+0xf>
		s++;
  800d70:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d71:	8a 02                	mov    (%edx),%al
  800d73:	3c 20                	cmp    $0x20,%al
  800d75:	74 f9                	je     800d70 <strtol+0xe>
  800d77:	3c 09                	cmp    $0x9,%al
  800d79:	74 f5                	je     800d70 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d7b:	3c 2b                	cmp    $0x2b,%al
  800d7d:	75 08                	jne    800d87 <strtol+0x25>
		s++;
  800d7f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d80:	bf 00 00 00 00       	mov    $0x0,%edi
  800d85:	eb 13                	jmp    800d9a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d87:	3c 2d                	cmp    $0x2d,%al
  800d89:	75 0a                	jne    800d95 <strtol+0x33>
		s++, neg = 1;
  800d8b:	8d 52 01             	lea    0x1(%edx),%edx
  800d8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800d93:	eb 05                	jmp    800d9a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d9a:	85 db                	test   %ebx,%ebx
  800d9c:	74 05                	je     800da3 <strtol+0x41>
  800d9e:	83 fb 10             	cmp    $0x10,%ebx
  800da1:	75 28                	jne    800dcb <strtol+0x69>
  800da3:	8a 02                	mov    (%edx),%al
  800da5:	3c 30                	cmp    $0x30,%al
  800da7:	75 10                	jne    800db9 <strtol+0x57>
  800da9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dad:	75 0a                	jne    800db9 <strtol+0x57>
		s += 2, base = 16;
  800daf:	83 c2 02             	add    $0x2,%edx
  800db2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db7:	eb 12                	jmp    800dcb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800db9:	85 db                	test   %ebx,%ebx
  800dbb:	75 0e                	jne    800dcb <strtol+0x69>
  800dbd:	3c 30                	cmp    $0x30,%al
  800dbf:	75 05                	jne    800dc6 <strtol+0x64>
		s++, base = 8;
  800dc1:	42                   	inc    %edx
  800dc2:	b3 08                	mov    $0x8,%bl
  800dc4:	eb 05                	jmp    800dcb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dc6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd2:	8a 0a                	mov    (%edx),%cl
  800dd4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd7:	80 fb 09             	cmp    $0x9,%bl
  800dda:	77 08                	ja     800de4 <strtol+0x82>
			dig = *s - '0';
  800ddc:	0f be c9             	movsbl %cl,%ecx
  800ddf:	83 e9 30             	sub    $0x30,%ecx
  800de2:	eb 1e                	jmp    800e02 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800de4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800de7:	80 fb 19             	cmp    $0x19,%bl
  800dea:	77 08                	ja     800df4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dec:	0f be c9             	movsbl %cl,%ecx
  800def:	83 e9 57             	sub    $0x57,%ecx
  800df2:	eb 0e                	jmp    800e02 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800df4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800df7:	80 fb 19             	cmp    $0x19,%bl
  800dfa:	77 13                	ja     800e0f <strtol+0xad>
			dig = *s - 'A' + 10;
  800dfc:	0f be c9             	movsbl %cl,%ecx
  800dff:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e02:	39 f1                	cmp    %esi,%ecx
  800e04:	7d 0d                	jge    800e13 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800e06:	42                   	inc    %edx
  800e07:	0f af c6             	imul   %esi,%eax
  800e0a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e0d:	eb c3                	jmp    800dd2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	eb 02                	jmp    800e15 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e13:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e19:	74 05                	je     800e20 <strtol+0xbe>
		*endptr = (char *) s;
  800e1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e1e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e20:	85 ff                	test   %edi,%edi
  800e22:	74 04                	je     800e28 <strtol+0xc6>
  800e24:	89 c8                	mov    %ecx,%eax
  800e26:	f7 d8                	neg    %eax
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    
  800e2d:	00 00                	add    %al,(%eax)
	...

00800e30 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 1c             	sub    $0x1c,%esp
  800e39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e3f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	8b 75 14             	mov    0x14(%ebp),%esi
  800e44:	8b 7d 10             	mov    0x10(%ebp),%edi
  800e47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	cd 30                	int    $0x30
  800e4f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e55:	74 1c                	je     800e73 <syscall+0x43>
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7e 18                	jle    800e73 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e62:	68 df 2c 80 00       	push   $0x802cdf
  800e67:	6a 42                	push   $0x42
  800e69:	68 fc 2c 80 00       	push   $0x802cfc
  800e6e:	e8 b1 f5 ff ff       	call   800424 <_panic>

	return ret;
}
  800e73:	89 d0                	mov    %edx,%eax
  800e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e83:	6a 00                	push   $0x0
  800e85:	6a 00                	push   $0x0
  800e87:	6a 00                	push   $0x0
  800e89:	ff 75 0c             	pushl  0xc(%ebp)
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	e8 92 ff ff ff       	call   800e30 <syscall>
  800e9e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ea9:	6a 00                	push   $0x0
  800eab:	6a 00                	push   $0x0
  800ead:	6a 00                	push   $0x0
  800eaf:	6a 00                	push   $0x0
  800eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec0:	e8 6b ff ff ff       	call   800e30 <syscall>
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ecd:	6a 00                	push   $0x0
  800ecf:	6a 00                	push   $0x0
  800ed1:	6a 00                	push   $0x0
  800ed3:	6a 00                	push   $0x0
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	ba 01 00 00 00       	mov    $0x1,%edx
  800edd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee2:	e8 49 ff ff ff       	call   800e30 <syscall>
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800eef:	6a 00                	push   $0x0
  800ef1:	6a 00                	push   $0x0
  800ef3:	6a 00                	push   $0x0
  800ef5:	6a 00                	push   $0x0
  800ef7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efc:	ba 00 00 00 00       	mov    $0x0,%edx
  800f01:	b8 02 00 00 00       	mov    $0x2,%eax
  800f06:	e8 25 ff ff ff       	call   800e30 <syscall>
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <sys_yield>:

void
sys_yield(void)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f13:	6a 00                	push   $0x0
  800f15:	6a 00                	push   $0x0
  800f17:	6a 00                	push   $0x0
  800f19:	6a 00                	push   $0x0
  800f1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f20:	ba 00 00 00 00       	mov    $0x0,%edx
  800f25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f2a:	e8 01 ff ff ff       	call   800e30 <syscall>
  800f2f:	83 c4 10             	add    $0x10,%esp
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f3a:	6a 00                	push   $0x0
  800f3c:	6a 00                	push   $0x0
  800f3e:	ff 75 10             	pushl  0x10(%ebp)
  800f41:	ff 75 0c             	pushl  0xc(%ebp)
  800f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f47:	ba 01 00 00 00       	mov    $0x1,%edx
  800f4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800f51:	e8 da fe ff ff       	call   800e30 <syscall>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f5e:	ff 75 18             	pushl  0x18(%ebp)
  800f61:	ff 75 14             	pushl  0x14(%ebp)
  800f64:	ff 75 10             	pushl  0x10(%ebp)
  800f67:	ff 75 0c             	pushl  0xc(%ebp)
  800f6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800f72:	b8 05 00 00 00       	mov    $0x5,%eax
  800f77:	e8 b4 fe ff ff       	call   800e30 <syscall>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f84:	6a 00                	push   $0x0
  800f86:	6a 00                	push   $0x0
  800f88:	6a 00                	push   $0x0
  800f8a:	ff 75 0c             	pushl  0xc(%ebp)
  800f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f90:	ba 01 00 00 00       	mov    $0x1,%edx
  800f95:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9a:	e8 91 fe ff ff       	call   800e30 <syscall>
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800fa7:	6a 00                	push   $0x0
  800fa9:	6a 00                	push   $0x0
  800fab:	6a 00                	push   $0x0
  800fad:	ff 75 0c             	pushl  0xc(%ebp)
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbd:	e8 6e fe ff ff       	call   800e30 <syscall>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800fca:	6a 00                	push   $0x0
  800fcc:	6a 00                	push   $0x0
  800fce:	6a 00                	push   $0x0
  800fd0:	ff 75 0c             	pushl  0xc(%ebp)
  800fd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800fdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe0:	e8 4b fe ff ff       	call   800e30 <syscall>
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800fed:	6a 00                	push   $0x0
  800fef:	6a 00                	push   $0x0
  800ff1:	6a 00                	push   $0x0
  800ff3:	ff 75 0c             	pushl  0xc(%ebp)
  800ff6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff9:	ba 01 00 00 00       	mov    $0x1,%edx
  800ffe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801003:	e8 28 fe ff ff       	call   800e30 <syscall>
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801010:	6a 00                	push   $0x0
  801012:	ff 75 14             	pushl  0x14(%ebp)
  801015:	ff 75 10             	pushl  0x10(%ebp)
  801018:	ff 75 0c             	pushl  0xc(%ebp)
  80101b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 0c 00 00 00       	mov    $0xc,%eax
  801028:	e8 03 fe ff ff       	call   800e30 <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801035:	6a 00                	push   $0x0
  801037:	6a 00                	push   $0x0
  801039:	6a 00                	push   $0x0
  80103b:	6a 00                	push   $0x0
  80103d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801040:	ba 01 00 00 00       	mov    $0x1,%edx
  801045:	b8 0d 00 00 00       	mov    $0xd,%eax
  80104a:	e8 e1 fd ff ff       	call   800e30 <syscall>
}
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	6a 00                	push   $0x0
  80105d:	ff 75 0c             	pushl  0xc(%ebp)
  801060:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801063:	ba 00 00 00 00       	mov    $0x0,%edx
  801068:	b8 0e 00 00 00       	mov    $0xe,%eax
  80106d:	e8 be fd ff ff       	call   800e30 <syscall>
}
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80107a:	6a 00                	push   $0x0
  80107c:	ff 75 14             	pushl  0x14(%ebp)
  80107f:	ff 75 10             	pushl  0x10(%ebp)
  801082:	ff 75 0c             	pushl  0xc(%ebp)
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	ba 00 00 00 00       	mov    $0x0,%edx
  80108d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801092:	e8 99 fd ff ff       	call   800e30 <syscall>
  801097:	c9                   	leave  
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
	...

0080109c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	e8 e5 ff ff ff       	call   80109c <fd2num>
  8010b7:	83 c4 04             	add    $0x4,%esp
  8010ba:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010bf:	c1 e0 0c             	shl    $0xc,%eax
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010cb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 34                	je     801108 <fd_alloc+0x44>
  8010d4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010d9:	a8 01                	test   $0x1,%al
  8010db:	74 32                	je     80110f <fd_alloc+0x4b>
  8010dd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010e2:	89 c1                	mov    %eax,%ecx
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 1f                	je     801114 <fd_alloc+0x50>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	75 17                	jne    80111d <fd_alloc+0x59>
  801106:	eb 0c                	jmp    801114 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801108:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80110d:	eb 05                	jmp    801114 <fd_alloc+0x50>
  80110f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801114:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
  80111b:	eb 17                	jmp    801134 <fd_alloc+0x70>
  80111d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801122:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801127:	75 b9                	jne    8010e2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80112f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801134:	5b                   	pop    %ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80113d:	83 f8 1f             	cmp    $0x1f,%eax
  801140:	77 36                	ja     801178 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801142:	05 00 00 0d 00       	add    $0xd0000,%eax
  801147:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80114a:	89 c2                	mov    %eax,%edx
  80114c:	c1 ea 16             	shr    $0x16,%edx
  80114f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801156:	f6 c2 01             	test   $0x1,%dl
  801159:	74 24                	je     80117f <fd_lookup+0x48>
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 0c             	shr    $0xc,%edx
  801160:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801167:	f6 c2 01             	test   $0x1,%dl
  80116a:	74 1a                	je     801186 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 02                	mov    %eax,(%edx)
	return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
  801176:	eb 13                	jmp    80118b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801178:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117d:	eb 0c                	jmp    80118b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801184:	eb 05                	jmp    80118b <fd_lookup+0x54>
  801186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	53                   	push   %ebx
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80119a:	39 0d 90 47 80 00    	cmp    %ecx,0x804790
  8011a0:	74 0d                	je     8011af <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	eb 14                	jmp    8011bd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011a9:	39 0a                	cmp    %ecx,(%edx)
  8011ab:	75 10                	jne    8011bd <dev_lookup+0x30>
  8011ad:	eb 05                	jmp    8011b4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011af:	ba 90 47 80 00       	mov    $0x804790,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011b4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	eb 31                	jmp    8011ee <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bd:	40                   	inc    %eax
  8011be:	8b 14 85 88 2d 80 00 	mov    0x802d88(,%eax,4),%edx
  8011c5:	85 d2                	test   %edx,%edx
  8011c7:	75 e0                	jne    8011a9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c9:	a1 90 67 80 00       	mov    0x806790,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	51                   	push   %ecx
  8011d5:	50                   	push   %eax
  8011d6:	68 0c 2d 80 00       	push   $0x802d0c
  8011db:	e8 1c f3 ff ff       	call   8004fc <cprintf>
	*dev = 0;
  8011e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 20             	sub    $0x20,%esp
  8011fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fe:	8a 45 0c             	mov    0xc(%ebp),%al
  801201:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801204:	56                   	push   %esi
  801205:	e8 92 fe ff ff       	call   80109c <fd2num>
  80120a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80120d:	89 14 24             	mov    %edx,(%esp)
  801210:	50                   	push   %eax
  801211:	e8 21 ff ff ff       	call   801137 <fd_lookup>
  801216:	89 c3                	mov    %eax,%ebx
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 05                	js     801224 <fd_close+0x31>
	    || fd != fd2)
  80121f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801222:	74 0d                	je     801231 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801224:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801228:	75 48                	jne    801272 <fd_close+0x7f>
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122f:	eb 41                	jmp    801272 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 36                	pushl  (%esi)
  80123a:	e8 4e ff ff ff       	call   80118d <dev_lookup>
  80123f:	89 c3                	mov    %eax,%ebx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 1c                	js     801264 <fd_close+0x71>
		if (dev->dev_close)
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	8b 40 10             	mov    0x10(%eax),%eax
  80124e:	85 c0                	test   %eax,%eax
  801250:	74 0d                	je     80125f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	56                   	push   %esi
  801256:	ff d0                	call   *%eax
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	eb 05                	jmp    801264 <fd_close+0x71>
		else
			r = 0;
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	56                   	push   %esi
  801268:	6a 00                	push   $0x0
  80126a:	e8 0f fd ff ff       	call   800f7e <sys_page_unmap>
	return r;
  80126f:	83 c4 10             	add    $0x10,%esp
}
  801272:	89 d8                	mov    %ebx,%eax
  801274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 aa fe ff ff       	call   801137 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 10                	js     8012a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	6a 01                	push   $0x1
  801299:	ff 75 f4             	pushl  -0xc(%ebp)
  80129c:	e8 52 ff ff ff       	call   8011f3 <fd_close>
  8012a1:	83 c4 10             	add    $0x10,%esp
}
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <close_all>:

void
close_all(void)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012b2:	83 ec 0c             	sub    $0xc,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	e8 c0 ff ff ff       	call   80127b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bb:	43                   	inc    %ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	83 fb 20             	cmp    $0x20,%ebx
  8012c2:	75 ee                	jne    8012b2 <close_all+0xc>
		close(i);
}
  8012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 2c             	sub    $0x2c,%esp
  8012d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 56 fe ff ff       	call   801137 <fd_lookup>
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	0f 88 c0 00 00 00    	js     8013ae <dup+0xe5>
		return r;
	close(newfdnum);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	57                   	push   %edi
  8012f2:	e8 84 ff ff ff       	call   80127b <close>

	newfd = INDEX2FD(newfdnum);
  8012f7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012fd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801300:	83 c4 04             	add    $0x4,%esp
  801303:	ff 75 e4             	pushl  -0x1c(%ebp)
  801306:	e8 a1 fd ff ff       	call   8010ac <fd2data>
  80130b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80130d:	89 34 24             	mov    %esi,(%esp)
  801310:	e8 97 fd ff ff       	call   8010ac <fd2data>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80131b:	89 d8                	mov    %ebx,%eax
  80131d:	c1 e8 16             	shr    $0x16,%eax
  801320:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801327:	a8 01                	test   $0x1,%al
  801329:	74 37                	je     801362 <dup+0x99>
  80132b:	89 d8                	mov    %ebx,%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
  801330:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 26                	je     801362 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80133c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	25 07 0e 00 00       	and    $0xe07,%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	53                   	push   %ebx
  801352:	6a 00                	push   $0x0
  801354:	e8 ff fb ff ff       	call   800f58 <sys_page_map>
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 20             	add    $0x20,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 2d                	js     80138f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	89 c2                	mov    %eax,%edx
  801367:	c1 ea 0c             	shr    $0xc,%edx
  80136a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80137a:	52                   	push   %edx
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	50                   	push   %eax
  80137f:	6a 00                	push   $0x0
  801381:	e8 d2 fb ff ff       	call   800f58 <sys_page_map>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 20             	add    $0x20,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	79 1d                	jns    8013ac <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	56                   	push   %esi
  801393:	6a 00                	push   $0x0
  801395:	e8 e4 fb ff ff       	call   800f7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 d7 fb ff ff       	call   800f7e <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb 02                	jmp    8013ae <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013ac:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013ae:	89 d8                	mov    %ebx,%eax
  8013b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	53                   	push   %ebx
  8013bc:	83 ec 14             	sub    $0x14,%esp
  8013bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	53                   	push   %ebx
  8013c7:	e8 6b fd ff ff       	call   801137 <fd_lookup>
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 67                	js     80143a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	ff 30                	pushl  (%eax)
  8013df:	e8 a9 fd ff ff       	call   80118d <dev_lookup>
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 4f                	js     80143a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	8b 50 08             	mov    0x8(%eax),%edx
  8013f1:	83 e2 03             	and    $0x3,%edx
  8013f4:	83 fa 01             	cmp    $0x1,%edx
  8013f7:	75 21                	jne    80141a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f9:	a1 90 67 80 00       	mov    0x806790,%eax
  8013fe:	8b 40 48             	mov    0x48(%eax),%eax
  801401:	83 ec 04             	sub    $0x4,%esp
  801404:	53                   	push   %ebx
  801405:	50                   	push   %eax
  801406:	68 4d 2d 80 00       	push   $0x802d4d
  80140b:	e8 ec f0 ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801418:	eb 20                	jmp    80143a <read+0x82>
	}
	if (!dev->dev_read)
  80141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141d:	8b 52 08             	mov    0x8(%edx),%edx
  801420:	85 d2                	test   %edx,%edx
  801422:	74 11                	je     801435 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	ff 75 10             	pushl  0x10(%ebp)
  80142a:	ff 75 0c             	pushl  0xc(%ebp)
  80142d:	50                   	push   %eax
  80142e:	ff d2                	call   *%edx
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	eb 05                	jmp    80143a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801435:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144e:	85 f6                	test   %esi,%esi
  801450:	74 31                	je     801483 <readn+0x44>
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
  801457:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	89 f2                	mov    %esi,%edx
  801461:	29 c2                	sub    %eax,%edx
  801463:	52                   	push   %edx
  801464:	03 45 0c             	add    0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	57                   	push   %edi
  801469:	e8 4a ff ff ff       	call   8013b8 <read>
		if (m < 0)
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 17                	js     80148c <readn+0x4d>
			return m;
		if (m == 0)
  801475:	85 c0                	test   %eax,%eax
  801477:	74 11                	je     80148a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801479:	01 c3                	add    %eax,%ebx
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	39 f3                	cmp    %esi,%ebx
  80147f:	72 db                	jb     80145c <readn+0x1d>
  801481:	eb 09                	jmp    80148c <readn+0x4d>
  801483:	b8 00 00 00 00       	mov    $0x0,%eax
  801488:	eb 02                	jmp    80148c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80148a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80148c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5f                   	pop    %edi
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 14             	sub    $0x14,%esp
  80149b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	53                   	push   %ebx
  8014a3:	e8 8f fc ff ff       	call   801137 <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 62                	js     801511 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	ff 30                	pushl  (%eax)
  8014bb:	e8 cd fc ff ff       	call   80118d <dev_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4a                	js     801511 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ce:	75 21                	jne    8014f1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d0:	a1 90 67 80 00       	mov    0x806790,%eax
  8014d5:	8b 40 48             	mov    0x48(%eax),%eax
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	53                   	push   %ebx
  8014dc:	50                   	push   %eax
  8014dd:	68 69 2d 80 00       	push   $0x802d69
  8014e2:	e8 15 f0 ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ef:	eb 20                	jmp    801511 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f7:	85 d2                	test   %edx,%edx
  8014f9:	74 11                	je     80150c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	ff 75 10             	pushl  0x10(%ebp)
  801501:	ff 75 0c             	pushl  0xc(%ebp)
  801504:	50                   	push   %eax
  801505:	ff d2                	call   *%edx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 05                	jmp    801511 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80150c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <seek>:

int
seek(int fdnum, off_t offset)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 0f fc ff ff       	call   801137 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 0e                	js     80153d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801532:	8b 55 0c             	mov    0xc(%ebp),%edx
  801535:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	53                   	push   %ebx
  801543:	83 ec 14             	sub    $0x14,%esp
  801546:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801549:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	53                   	push   %ebx
  80154e:	e8 e4 fb ff ff       	call   801137 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 5f                	js     8015b9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 22 fc ff ff       	call   80118d <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 47                	js     8015b9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801579:	75 21                	jne    80159c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157b:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801580:	8b 40 48             	mov    0x48(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 2c 2d 80 00       	push   $0x802d2c
  80158d:	e8 6a ef ff ff       	call   8004fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159a:	eb 1d                	jmp    8015b9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	8b 52 18             	mov    0x18(%edx),%edx
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 0e                	je     8015b4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 05                	jmp    8015b9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 63 fb ff ff       	call   801137 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 52                	js     80162d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 a1 fb ff ff       	call   80118d <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 3a                	js     80162d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fa:	74 2c                	je     801628 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801606:	00 00 00 
	stat->st_isdir = 0;
  801609:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801610:	00 00 00 
	stat->st_dev = dev;
  801613:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	53                   	push   %ebx
  80161d:	ff 75 f0             	pushl  -0x10(%ebp)
  801620:	ff 50 14             	call   *0x14(%eax)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 05                	jmp    80162d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801628:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	6a 00                	push   $0x0
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 78 01 00 00       	call   8017bc <open>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 1b                	js     801668 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	50                   	push   %eax
  801654:	e8 65 ff ff ff       	call   8015be <fstat>
  801659:	89 c6                	mov    %eax,%esi
	close(fd);
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 18 fc ff ff       	call   80127b <close>
	return r;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 f3                	mov    %esi,%ebx
}
  801668:	89 d8                	mov    %ebx,%eax
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	c9                   	leave  
  801670:	c3                   	ret    
  801671:	00 00                	add    %al,(%eax)
	...

00801674 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80167d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801684:	75 12                	jne    801698 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	6a 01                	push   $0x1
  80168b:	e8 e6 0e 00 00       	call   802576 <ipc_find_env>
  801690:	a3 00 50 80 00       	mov    %eax,0x805000
  801695:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801698:	6a 07                	push   $0x7
  80169a:	68 00 70 80 00       	push   $0x807000
  80169f:	53                   	push   %ebx
  8016a0:	ff 35 00 50 80 00    	pushl  0x805000
  8016a6:	e8 76 0e 00 00       	call   802521 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016ab:	83 c4 0c             	add    $0xc,%esp
  8016ae:	6a 00                	push   $0x0
  8016b0:	56                   	push   %esi
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 f4 0d 00 00       	call   8024ac <ipc_recv>
}
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016de:	e8 91 ff ff ff       	call   801674 <fsipc>
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 2c                	js     801713 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	68 00 70 80 00       	push   $0x807000
  8016ef:	53                   	push   %ebx
  8016f0:	e8 bd f3 ff ff       	call   800ab2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f5:	a1 80 70 80 00       	mov    0x807080,%eax
  8016fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801700:	a1 84 70 80 00       	mov    0x807084,%eax
  801705:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	8b 40 0c             	mov    0xc(%eax),%eax
  801724:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	b8 06 00 00 00       	mov    $0x6,%eax
  801733:	e8 3c ff ff ff       	call   801674 <fsipc>
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 40 0c             	mov    0xc(%eax),%eax
  801748:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80174d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 03 00 00 00       	mov    $0x3,%eax
  80175d:	e8 12 ff ff ff       	call   801674 <fsipc>
  801762:	89 c3                	mov    %eax,%ebx
  801764:	85 c0                	test   %eax,%eax
  801766:	78 4b                	js     8017b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801768:	39 c6                	cmp    %eax,%esi
  80176a:	73 16                	jae    801782 <devfile_read+0x48>
  80176c:	68 98 2d 80 00       	push   $0x802d98
  801771:	68 9f 2d 80 00       	push   $0x802d9f
  801776:	6a 7d                	push   $0x7d
  801778:	68 b4 2d 80 00       	push   $0x802db4
  80177d:	e8 a2 ec ff ff       	call   800424 <_panic>
	assert(r <= PGSIZE);
  801782:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801787:	7e 16                	jle    80179f <devfile_read+0x65>
  801789:	68 bf 2d 80 00       	push   $0x802dbf
  80178e:	68 9f 2d 80 00       	push   $0x802d9f
  801793:	6a 7e                	push   $0x7e
  801795:	68 b4 2d 80 00       	push   $0x802db4
  80179a:	e8 85 ec ff ff       	call   800424 <_panic>
	memmove(buf, &fsipcbuf, r);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	50                   	push   %eax
  8017a3:	68 00 70 80 00       	push   $0x807000
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	e8 c3 f4 ff ff       	call   800c73 <memmove>
	return r;
  8017b0:	83 c4 10             	add    $0x10,%esp
}
  8017b3:	89 d8                	mov    %ebx,%eax
  8017b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 1c             	sub    $0x1c,%esp
  8017c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c7:	56                   	push   %esi
  8017c8:	e8 93 f2 ff ff       	call   800a60 <strlen>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d5:	7f 65                	jg     80183c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 e1 f8 ff ff       	call   8010c4 <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 55                	js     801841 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	56                   	push   %esi
  8017f0:	68 00 70 80 00       	push   $0x807000
  8017f5:	e8 b8 f2 ff ff       	call   800ab2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801802:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801805:	b8 01 00 00 00       	mov    $0x1,%eax
  80180a:	e8 65 fe ff ff       	call   801674 <fsipc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	79 12                	jns    80182a <open+0x6e>
		fd_close(fd, 0);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	6a 00                	push   $0x0
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 ce f9 ff ff       	call   8011f3 <fd_close>
		return r;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	eb 17                	jmp    801841 <open+0x85>
	}

	return fd2num(fd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	e8 67 f8 ff ff       	call   80109c <fd2num>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 05                	jmp    801841 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801841:	89 d8                	mov    %ebx,%eax
  801843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	c9                   	leave  
  801849:	c3                   	ret    
	...

0080184c <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
  801852:	83 ec 1c             	sub    $0x1c,%esp
  801855:	89 c7                	mov    %eax,%edi
  801857:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80185a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80185d:	89 d0                	mov    %edx,%eax
  80185f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801864:	74 0c                	je     801872 <map_segment+0x26>
		va -= i;
  801866:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  801869:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  80186c:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  80186f:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801872:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801876:	0f 84 ee 00 00 00    	je     80196a <map_segment+0x11e>
  80187c:	be 00 00 00 00       	mov    $0x0,%esi
  801881:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801886:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801889:	77 20                	ja     8018ab <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	ff 75 14             	pushl  0x14(%ebp)
  801891:	03 75 e4             	add    -0x1c(%ebp),%esi
  801894:	56                   	push   %esi
  801895:	57                   	push   %edi
  801896:	e8 99 f6 ff ff       	call   800f34 <sys_page_alloc>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	0f 89 ac 00 00 00    	jns    801952 <map_segment+0x106>
  8018a6:	e9 c4 00 00 00       	jmp    80196f <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	6a 07                	push   $0x7
  8018b0:	68 00 00 40 00       	push   $0x400000
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 78 f6 ff ff       	call   800f34 <sys_page_alloc>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	0f 88 a8 00 00 00    	js     80196f <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018c7:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  8018ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cd:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018d0:	50                   	push   %eax
  8018d1:	ff 75 08             	pushl  0x8(%ebp)
  8018d4:	e8 3d fc ff ff       	call   801516 <seek>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	0f 88 8b 00 00 00    	js     80196f <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ea:	29 f0                	sub    %esi,%eax
  8018ec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f1:	76 05                	jbe    8018f8 <map_segment+0xac>
  8018f3:	b8 00 10 00 00       	mov    $0x1000,%eax
  8018f8:	50                   	push   %eax
  8018f9:	68 00 00 40 00       	push   $0x400000
  8018fe:	ff 75 08             	pushl  0x8(%ebp)
  801901:	e8 39 fb ff ff       	call   80143f <readn>
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 62                	js     80196f <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	ff 75 14             	pushl  0x14(%ebp)
  801913:	03 75 e4             	add    -0x1c(%ebp),%esi
  801916:	56                   	push   %esi
  801917:	57                   	push   %edi
  801918:	68 00 00 40 00       	push   $0x400000
  80191d:	6a 00                	push   $0x0
  80191f:	e8 34 f6 ff ff       	call   800f58 <sys_page_map>
  801924:	83 c4 20             	add    $0x20,%esp
  801927:	85 c0                	test   %eax,%eax
  801929:	79 15                	jns    801940 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  80192b:	50                   	push   %eax
  80192c:	68 cb 2d 80 00       	push   $0x802dcb
  801931:	68 84 01 00 00       	push   $0x184
  801936:	68 e8 2d 80 00       	push   $0x802de8
  80193b:	e8 e4 ea ff ff       	call   800424 <_panic>
			sys_page_unmap(0, UTEMP);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	68 00 00 40 00       	push   $0x400000
  801948:	6a 00                	push   $0x0
  80194a:	e8 2f f6 ff ff       	call   800f7e <sys_page_unmap>
  80194f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801952:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801958:	89 de                	mov    %ebx,%esi
  80195a:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  80195d:	0f 87 23 ff ff ff    	ja     801886 <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
  801968:	eb 05                	jmp    80196f <map_segment+0x123>
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5f                   	pop    %edi
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	57                   	push   %edi
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	83 ec 2c             	sub    $0x2c,%esp
  801980:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801983:	89 d7                	mov    %edx,%edi
  801985:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801988:	8b 02                	mov    (%edx),%eax
  80198a:	85 c0                	test   %eax,%eax
  80198c:	74 31                	je     8019bf <init_stack+0x48>
  80198e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801993:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	50                   	push   %eax
  80199c:	e8 bf f0 ff ff       	call   800a60 <strlen>
  8019a1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a5:	43                   	inc    %ebx
  8019a6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019ad:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	75 e1                	jne    801998 <init_stack+0x21>
  8019b7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8019ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019bd:	eb 18                	jmp    8019d7 <init_stack+0x60>
  8019bf:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8019c6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8019cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019d2:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019d7:	f7 de                	neg    %esi
  8019d9:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8019df:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019e2:	89 f2                	mov    %esi,%edx
  8019e4:	83 e2 fc             	and    $0xfffffffc,%edx
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	f7 d0                	not    %eax
  8019eb:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8019ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019f1:	83 e8 08             	sub    $0x8,%eax
  8019f4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019f9:	0f 86 fb 00 00 00    	jbe    801afa <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019ff:	83 ec 04             	sub    $0x4,%esp
  801a02:	6a 07                	push   $0x7
  801a04:	68 00 00 40 00       	push   $0x400000
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 24 f5 ff ff       	call   800f34 <sys_page_alloc>
  801a10:	89 c6                	mov    %eax,%esi
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	0f 88 e9 00 00 00    	js     801b06 <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a1d:	85 db                	test   %ebx,%ebx
  801a1f:	7e 3e                	jle    801a5f <init_stack+0xe8>
  801a21:	be 00 00 00 00       	mov    $0x0,%esi
  801a26:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801a29:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801a2c:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801a32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a35:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	ff 34 b7             	pushl  (%edi,%esi,4)
  801a3e:	53                   	push   %ebx
  801a3f:	e8 6e f0 ff ff       	call   800ab2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a44:	83 c4 04             	add    $0x4,%esp
  801a47:	ff 34 b7             	pushl  (%edi,%esi,4)
  801a4a:	e8 11 f0 ff ff       	call   800a60 <strlen>
  801a4f:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a53:	46                   	inc    %esi
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801a5a:	7c d0                	jl     801a2c <init_stack+0xb5>
  801a5c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a62:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801a65:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a6c:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801a73:	74 19                	je     801a8e <init_stack+0x117>
  801a75:	68 58 2e 80 00       	push   $0x802e58
  801a7a:	68 9f 2d 80 00       	push   $0x802d9f
  801a7f:	68 51 01 00 00       	push   $0x151
  801a84:	68 e8 2d 80 00       	push   $0x802de8
  801a89:	e8 96 e9 ff ff       	call   800424 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a91:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a99:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801a9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801a9f:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801aa2:	89 d0                	mov    %edx,%eax
  801aa4:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801aa9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801aac:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	6a 07                	push   $0x7
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab9:	68 00 00 40 00       	push   $0x400000
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 93 f4 ff ff       	call   800f58 <sys_page_map>
  801ac5:	89 c6                	mov    %eax,%esi
  801ac7:	83 c4 20             	add    $0x20,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 18                	js     801ae6 <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	68 00 00 40 00       	push   $0x400000
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 a1 f4 ff ff       	call   800f7e <sys_page_unmap>
  801add:	89 c6                	mov    %eax,%esi
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	79 1b                	jns    801b01 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	68 00 00 40 00       	push   $0x400000
  801aee:	6a 00                	push   $0x0
  801af0:	e8 89 f4 ff ff       	call   800f7e <sys_page_unmap>
	return r;
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	eb 0c                	jmp    801b06 <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801afa:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801aff:	eb 05                	jmp    801b06 <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801b01:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801b06:	89 f0                	mov    %esi,%eax
  801b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	57                   	push   %edi
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b1c:	6a 00                	push   $0x0
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 96 fc ff ff       	call   8017bc <open>
  801b26:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 45 02 00 00    	js     801d7c <spawn+0x26c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	68 00 02 00 00       	push   $0x200
  801b3f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b4c:	e8 ee f8 ff ff       	call   80143f <readn>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b59:	75 0c                	jne    801b67 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801b5b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b62:	45 4c 46 
  801b65:	74 38                	je     801b9f <spawn+0x8f>
		close(fd);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b70:	e8 06 f7 ff ff       	call   80127b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b75:	83 c4 0c             	add    $0xc,%esp
  801b78:	68 7f 45 4c 46       	push   $0x464c457f
  801b7d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801b83:	68 f4 2d 80 00       	push   $0x802df4
  801b88:	e8 6f e9 ff ff       	call   8004fc <cprintf>
		return -E_NOT_EXEC;
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801b97:	ff ff ff 
  801b9a:	e9 f1 01 00 00       	jmp    801d90 <spawn+0x280>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801b9f:	ba 07 00 00 00       	mov    $0x7,%edx
  801ba4:	89 d0                	mov    %edx,%eax
  801ba6:	cd 30                	int    $0x30
  801ba8:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bae:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 d4 01 00 00    	js     801d90 <spawn+0x280>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801bbc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bc8:	c1 e0 07             	shl    $0x7,%eax
  801bcb:	29 d0                	sub    %edx,%eax
  801bcd:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801bd3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801bd9:	b9 11 00 00 00       	mov    $0x11,%ecx
  801bde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801be0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801be6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801bf5:	68 00 d0 bf ee       	push   $0xeebfd000
  801bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfd:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801c03:	e8 6f fd ff ff       	call   801977 <init_stack>
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	0f 88 77 01 00 00    	js     801d8a <spawn+0x27a>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c13:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c19:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801c20:	00 
  801c21:	74 5d                	je     801c80 <spawn+0x170>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c23:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c2a:	be 00 00 00 00       	mov    $0x0,%esi
  801c2f:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801c35:	83 3b 01             	cmpl   $0x1,(%ebx)
  801c38:	75 35                	jne    801c6f <spawn+0x15f>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c3a:	8b 43 18             	mov    0x18(%ebx),%eax
  801c3d:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c40:	83 f8 01             	cmp    $0x1,%eax
  801c43:	19 c0                	sbb    %eax,%eax
  801c45:	83 e0 fe             	and    $0xfffffffe,%eax
  801c48:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c4b:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801c4e:	8b 53 08             	mov    0x8(%ebx),%edx
  801c51:	50                   	push   %eax
  801c52:	ff 73 04             	pushl  0x4(%ebx)
  801c55:	ff 73 10             	pushl  0x10(%ebx)
  801c58:	57                   	push   %edi
  801c59:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c5f:	e8 e8 fb ff ff       	call   80184c <map_segment>
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 e4 00 00 00    	js     801d53 <spawn+0x243>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c6f:	46                   	inc    %esi
  801c70:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c77:	39 f0                	cmp    %esi,%eax
  801c79:	7e 05                	jle    801c80 <spawn+0x170>
  801c7b:	83 c3 20             	add    $0x20,%ebx
  801c7e:	eb b5                	jmp    801c35 <spawn+0x125>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c89:	e8 ed f5 ff ff       	call   80127b <close>
  801c8e:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c96:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	c1 e8 16             	shr    $0x16,%eax
  801ca1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ca8:	a8 01                	test   $0x1,%al
  801caa:	74 3e                	je     801cea <spawn+0x1da>
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	c1 e8 0c             	shr    $0xc,%eax
  801cb1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cb8:	f6 c2 01             	test   $0x1,%dl
  801cbb:	74 2d                	je     801cea <spawn+0x1da>
  801cbd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cc4:	f6 c6 04             	test   $0x4,%dh
  801cc7:	74 21                	je     801cea <spawn+0x1da>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801cc9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	25 07 0e 00 00       	and    $0xe07,%eax
  801cd8:	50                   	push   %eax
  801cd9:	53                   	push   %ebx
  801cda:	56                   	push   %esi
  801cdb:	53                   	push   %ebx
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 75 f2 ff ff       	call   800f58 <sys_page_map>
        if (r < 0) return r;
  801ce3:	83 c4 20             	add    $0x20,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 13                	js     801cfd <spawn+0x1ed>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801cea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cf0:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801cf6:	75 a4                	jne    801c9c <spawn+0x18c>
  801cf8:	e9 a1 00 00 00       	jmp    801d9e <spawn+0x28e>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801cfd:	50                   	push   %eax
  801cfe:	68 0e 2e 80 00       	push   $0x802e0e
  801d03:	68 85 00 00 00       	push   $0x85
  801d08:	68 e8 2d 80 00       	push   $0x802de8
  801d0d:	e8 12 e7 ff ff       	call   800424 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d12:	50                   	push   %eax
  801d13:	68 24 2e 80 00       	push   $0x802e24
  801d18:	68 88 00 00 00       	push   $0x88
  801d1d:	68 e8 2d 80 00       	push   $0x802de8
  801d22:	e8 fd e6 ff ff       	call   800424 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d27:	83 ec 08             	sub    $0x8,%esp
  801d2a:	6a 02                	push   $0x2
  801d2c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d32:	e8 6a f2 ff ff       	call   800fa1 <sys_env_set_status>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	79 52                	jns    801d90 <spawn+0x280>
		panic("sys_env_set_status: %e", r);
  801d3e:	50                   	push   %eax
  801d3f:	68 3e 2e 80 00       	push   $0x802e3e
  801d44:	68 8b 00 00 00       	push   $0x8b
  801d49:	68 e8 2d 80 00       	push   $0x802de8
  801d4e:	e8 d1 e6 ff ff       	call   800424 <_panic>
  801d53:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d5e:	e8 64 f1 ff ff       	call   800ec7 <sys_env_destroy>
	close(fd);
  801d63:	83 c4 04             	add    $0x4,%esp
  801d66:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d6c:	e8 0a f5 ff ff       	call   80127b <close>
	return r;
  801d71:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d74:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801d7a:	eb 14                	jmp    801d90 <spawn+0x280>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d7c:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d82:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d88:	eb 06                	jmp    801d90 <spawn+0x280>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801d8a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d90:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5f                   	pop    %edi
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801da7:	50                   	push   %eax
  801da8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dae:	e8 11 f2 ff ff       	call   800fc4 <sys_env_set_trapframe>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	0f 89 69 ff ff ff    	jns    801d27 <spawn+0x217>
  801dbe:	e9 4f ff ff ff       	jmp    801d12 <spawn+0x202>

00801dc3 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801dcf:	6a 00                	push   $0x0
  801dd1:	ff 75 08             	pushl  0x8(%ebp)
  801dd4:	e8 e3 f9 ff ff       	call   8017bc <open>
  801dd9:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	0f 88 a9 01 00 00    	js     801f93 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801dea:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801df0:	83 ec 04             	sub    $0x4,%esp
  801df3:	68 00 02 00 00       	push   $0x200
  801df8:	57                   	push   %edi
  801df9:	50                   	push   %eax
  801dfa:	e8 40 f6 ff ff       	call   80143f <readn>
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	3d 00 02 00 00       	cmp    $0x200,%eax
  801e07:	75 0c                	jne    801e15 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801e09:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e10:	45 4c 46 
  801e13:	74 34                	je     801e49 <exec+0x86>
		close(fd);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801e1e:	e8 58 f4 ff ff       	call   80127b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e23:	83 c4 0c             	add    $0xc,%esp
  801e26:	68 7f 45 4c 46       	push   $0x464c457f
  801e2b:	ff 37                	pushl  (%edi)
  801e2d:	68 f4 2d 80 00       	push   $0x802df4
  801e32:	e8 c5 e6 ff ff       	call   8004fc <cprintf>
		return -E_NOT_EXEC;
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801e41:	ff ff ff 
  801e44:	e9 4a 01 00 00       	jmp    801f93 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e49:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e4c:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801e51:	0f 84 8b 00 00 00    	je     801ee2 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e57:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801e5e:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801e65:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e68:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801e6d:	83 3b 01             	cmpl   $0x1,(%ebx)
  801e70:	75 62                	jne    801ed4 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e72:	8b 43 18             	mov    0x18(%ebx),%eax
  801e75:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801e78:	83 f8 01             	cmp    $0x1,%eax
  801e7b:	19 c0                	sbb    %eax,%eax
  801e7d:	83 e0 fe             	and    $0xfffffffe,%eax
  801e80:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801e83:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801e86:	8b 53 08             	mov    0x8(%ebx),%edx
  801e89:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e8f:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801e95:	50                   	push   %eax
  801e96:	ff 73 04             	pushl  0x4(%ebx)
  801e99:	ff 73 10             	pushl  0x10(%ebx)
  801e9c:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea7:	e8 a0 f9 ff ff       	call   80184c <map_segment>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	0f 88 a3 00 00 00    	js     801f5a <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801eb7:	8b 53 14             	mov    0x14(%ebx),%edx
  801eba:	8b 43 08             	mov    0x8(%ebx),%eax
  801ebd:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ec2:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801ec9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801ece:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ed4:	46                   	inc    %esi
  801ed5:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801ed9:	39 f0                	cmp    %esi,%eax
  801edb:	7e 0f                	jle    801eec <exec+0x129>
  801edd:	83 c3 20             	add    $0x20,%ebx
  801ee0:	eb 8b                	jmp    801e6d <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801ee2:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801ee9:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801ef5:	e8 81 f3 ff ff       	call   80127b <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801efa:	83 c4 04             	add    $0x4,%esp
  801efd:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801f03:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f11:	e8 61 fa ff ff       	call   801977 <init_stack>
  801f16:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 70                	js     801f93 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801f23:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801f27:	50                   	push   %eax
  801f28:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f2e:	03 47 1c             	add    0x1c(%edi),%eax
  801f31:	50                   	push   %eax
  801f32:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801f38:	ff 77 18             	pushl  0x18(%edi)
  801f3b:	e8 34 f1 ff ff       	call   801074 <sys_exec>
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	85 c0                	test   %eax,%eax
  801f45:	79 42                	jns    801f89 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801f47:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801f4d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801f53:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801f58:	eb 0c                	jmp    801f66 <exec+0x1a3>
  801f5a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801f60:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801f66:	83 ec 0c             	sub    $0xc,%esp
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 57 ef ff ff       	call   800ec7 <sys_env_destroy>
	close(fd);
  801f70:	89 1c 24             	mov    %ebx,(%esp)
  801f73:	e8 03 f3 ff ff       	call   80127b <close>
	return r;
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801f81:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801f87:	eb 0a                	jmp    801f93 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801f89:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801f90:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801f93:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fa9:	8d 45 14             	lea    0x14(%ebp),%eax
  801fac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb0:	74 5f                	je     802011 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801fb2:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801fb7:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fb8:	89 c2                	mov    %eax,%edx
  801fba:	83 c0 04             	add    $0x4,%eax
  801fbd:	83 3a 00             	cmpl   $0x0,(%edx)
  801fc0:	75 f5                	jne    801fb7 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801fc2:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801fc9:	83 e0 f0             	and    $0xfffffff0,%eax
  801fcc:	29 c4                	sub    %eax,%esp
  801fce:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801fd2:	83 e0 f0             	and    $0xfffffff0,%eax
  801fd5:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801fd7:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801fd9:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801fe0:	00 

	va_start(vl, arg0);
  801fe1:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801fe4:	89 ce                	mov    %ecx,%esi
  801fe6:	85 c9                	test   %ecx,%ecx
  801fe8:	74 14                	je     801ffe <execl+0x5d>
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801fef:	40                   	inc    %eax
  801ff0:	89 d1                	mov    %edx,%ecx
  801ff2:	83 c2 04             	add    $0x4,%edx
  801ff5:	8b 09                	mov    (%ecx),%ecx
  801ff7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ffa:	39 f0                	cmp    %esi,%eax
  801ffc:	72 f1                	jb     801fef <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	53                   	push   %ebx
  802002:	ff 75 08             	pushl  0x8(%ebp)
  802005:	e8 b9 fd ff ff       	call   801dc3 <exec>
}
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	c9                   	leave  
  802010:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802011:	83 ec 20             	sub    $0x20,%esp
  802014:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802018:	83 e0 f0             	and    $0xfffffff0,%eax
  80201b:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80201d:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80201f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802026:	eb d6                	jmp    801ffe <execl+0x5d>

00802028 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	56                   	push   %esi
  80202c:	53                   	push   %ebx
  80202d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802030:	8d 45 14             	lea    0x14(%ebp),%eax
  802033:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802037:	74 5f                	je     802098 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802039:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80203e:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80203f:	89 c2                	mov    %eax,%edx
  802041:	83 c0 04             	add    $0x4,%eax
  802044:	83 3a 00             	cmpl   $0x0,(%edx)
  802047:	75 f5                	jne    80203e <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802049:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802050:	83 e0 f0             	and    $0xfffffff0,%eax
  802053:	29 c4                	sub    %eax,%esp
  802055:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802059:	83 e0 f0             	and    $0xfffffff0,%eax
  80205c:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80205e:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802060:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802067:	00 

	va_start(vl, arg0);
  802068:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80206b:	89 ce                	mov    %ecx,%esi
  80206d:	85 c9                	test   %ecx,%ecx
  80206f:	74 14                	je     802085 <spawnl+0x5d>
  802071:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802076:	40                   	inc    %eax
  802077:	89 d1                	mov    %edx,%ecx
  802079:	83 c2 04             	add    $0x4,%edx
  80207c:	8b 09                	mov    (%ecx),%ecx
  80207e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802081:	39 f0                	cmp    %esi,%eax
  802083:	72 f1                	jb     802076 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802085:	83 ec 08             	sub    $0x8,%esp
  802088:	53                   	push   %ebx
  802089:	ff 75 08             	pushl  0x8(%ebp)
  80208c:	e8 7f fa ff ff       	call   801b10 <spawn>
}
  802091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	c9                   	leave  
  802097:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802098:	83 ec 20             	sub    $0x20,%esp
  80209b:	8d 44 24 0f          	lea    0xf(%esp),%eax
  80209f:	83 e0 f0             	and    $0xfffffff0,%eax
  8020a2:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8020a4:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8020a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8020ad:	eb d6                	jmp    802085 <spawnl+0x5d>
	...

008020b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	56                   	push   %esi
  8020b4:	53                   	push   %ebx
  8020b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	ff 75 08             	pushl  0x8(%ebp)
  8020be:	e8 e9 ef ff ff       	call   8010ac <fd2data>
  8020c3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8020c5:	83 c4 08             	add    $0x8,%esp
  8020c8:	68 80 2e 80 00       	push   $0x802e80
  8020cd:	56                   	push   %esi
  8020ce:	e8 df e9 ff ff       	call   800ab2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d6:	2b 03                	sub    (%ebx),%eax
  8020d8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8020de:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8020e5:	00 00 00 
	stat->st_dev = &devpipe;
  8020e8:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  8020ef:	47 80 00 
	return 0;
}
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	53                   	push   %ebx
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802108:	53                   	push   %ebx
  802109:	6a 00                	push   $0x0
  80210b:	e8 6e ee ff ff       	call   800f7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802110:	89 1c 24             	mov    %ebx,(%esp)
  802113:	e8 94 ef ff ff       	call   8010ac <fd2data>
  802118:	83 c4 08             	add    $0x8,%esp
  80211b:	50                   	push   %eax
  80211c:	6a 00                	push   $0x0
  80211e:	e8 5b ee ff ff       	call   800f7e <sys_page_unmap>
}
  802123:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	57                   	push   %edi
  80212c:	56                   	push   %esi
  80212d:	53                   	push   %ebx
  80212e:	83 ec 1c             	sub    $0x1c,%esp
  802131:	89 c7                	mov    %eax,%edi
  802133:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802136:	a1 90 67 80 00       	mov    0x806790,%eax
  80213b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80213e:	83 ec 0c             	sub    $0xc,%esp
  802141:	57                   	push   %edi
  802142:	e8 8d 04 00 00       	call   8025d4 <pageref>
  802147:	89 c6                	mov    %eax,%esi
  802149:	83 c4 04             	add    $0x4,%esp
  80214c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80214f:	e8 80 04 00 00       	call   8025d4 <pageref>
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	39 c6                	cmp    %eax,%esi
  802159:	0f 94 c0             	sete   %al
  80215c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80215f:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802165:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802168:	39 cb                	cmp    %ecx,%ebx
  80216a:	75 08                	jne    802174 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80216c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	c9                   	leave  
  802173:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802174:	83 f8 01             	cmp    $0x1,%eax
  802177:	75 bd                	jne    802136 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802179:	8b 42 58             	mov    0x58(%edx),%eax
  80217c:	6a 01                	push   $0x1
  80217e:	50                   	push   %eax
  80217f:	53                   	push   %ebx
  802180:	68 87 2e 80 00       	push   $0x802e87
  802185:	e8 72 e3 ff ff       	call   8004fc <cprintf>
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	eb a7                	jmp    802136 <_pipeisclosed+0xe>

0080218f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	57                   	push   %edi
  802193:	56                   	push   %esi
  802194:	53                   	push   %ebx
  802195:	83 ec 28             	sub    $0x28,%esp
  802198:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80219b:	56                   	push   %esi
  80219c:	e8 0b ef ff ff       	call   8010ac <fd2data>
  8021a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021aa:	75 4a                	jne    8021f6 <devpipe_write+0x67>
  8021ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8021b1:	eb 56                	jmp    802209 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021b3:	89 da                	mov    %ebx,%edx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	e8 6c ff ff ff       	call   802128 <_pipeisclosed>
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	75 4d                	jne    80220d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021c0:	e8 48 ed ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c8:	8b 13                	mov    (%ebx),%edx
  8021ca:	83 c2 20             	add    $0x20,%edx
  8021cd:	39 d0                	cmp    %edx,%eax
  8021cf:	73 e2                	jae    8021b3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021d1:	89 c2                	mov    %eax,%edx
  8021d3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8021d9:	79 05                	jns    8021e0 <devpipe_write+0x51>
  8021db:	4a                   	dec    %edx
  8021dc:	83 ca e0             	or     $0xffffffe0,%edx
  8021df:	42                   	inc    %edx
  8021e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021e3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8021e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021ea:	40                   	inc    %eax
  8021eb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ee:	47                   	inc    %edi
  8021ef:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8021f2:	77 07                	ja     8021fb <devpipe_write+0x6c>
  8021f4:	eb 13                	jmp    802209 <devpipe_write+0x7a>
  8021f6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8021fe:	8b 13                	mov    (%ebx),%edx
  802200:	83 c2 20             	add    $0x20,%edx
  802203:	39 d0                	cmp    %edx,%eax
  802205:	73 ac                	jae    8021b3 <devpipe_write+0x24>
  802207:	eb c8                	jmp    8021d1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802209:	89 f8                	mov    %edi,%eax
  80220b:	eb 05                	jmp    802212 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80220d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802215:	5b                   	pop    %ebx
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	c9                   	leave  
  802219:	c3                   	ret    

0080221a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	57                   	push   %edi
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	83 ec 18             	sub    $0x18,%esp
  802223:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802226:	57                   	push   %edi
  802227:	e8 80 ee ff ff       	call   8010ac <fd2data>
  80222c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80222e:	83 c4 10             	add    $0x10,%esp
  802231:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802235:	75 44                	jne    80227b <devpipe_read+0x61>
  802237:	be 00 00 00 00       	mov    $0x0,%esi
  80223c:	eb 4f                	jmp    80228d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80223e:	89 f0                	mov    %esi,%eax
  802240:	eb 54                	jmp    802296 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802242:	89 da                	mov    %ebx,%edx
  802244:	89 f8                	mov    %edi,%eax
  802246:	e8 dd fe ff ff       	call   802128 <_pipeisclosed>
  80224b:	85 c0                	test   %eax,%eax
  80224d:	75 42                	jne    802291 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80224f:	e8 b9 ec ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802254:	8b 03                	mov    (%ebx),%eax
  802256:	3b 43 04             	cmp    0x4(%ebx),%eax
  802259:	74 e7                	je     802242 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80225b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802260:	79 05                	jns    802267 <devpipe_read+0x4d>
  802262:	48                   	dec    %eax
  802263:	83 c8 e0             	or     $0xffffffe0,%eax
  802266:	40                   	inc    %eax
  802267:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80226b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802271:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802273:	46                   	inc    %esi
  802274:	39 75 10             	cmp    %esi,0x10(%ebp)
  802277:	77 07                	ja     802280 <devpipe_read+0x66>
  802279:	eb 12                	jmp    80228d <devpipe_read+0x73>
  80227b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802280:	8b 03                	mov    (%ebx),%eax
  802282:	3b 43 04             	cmp    0x4(%ebx),%eax
  802285:	75 d4                	jne    80225b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802287:	85 f6                	test   %esi,%esi
  802289:	75 b3                	jne    80223e <devpipe_read+0x24>
  80228b:	eb b5                	jmp    802242 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80228d:	89 f0                	mov    %esi,%eax
  80228f:	eb 05                	jmp    802296 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802291:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802299:	5b                   	pop    %ebx
  80229a:	5e                   	pop    %esi
  80229b:	5f                   	pop    %edi
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 28             	sub    $0x28,%esp
  8022a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022ad:	50                   	push   %eax
  8022ae:	e8 11 ee ff ff       	call   8010c4 <fd_alloc>
  8022b3:	89 c3                	mov    %eax,%ebx
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	0f 88 24 01 00 00    	js     8023e4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c0:	83 ec 04             	sub    $0x4,%esp
  8022c3:	68 07 04 00 00       	push   $0x407
  8022c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022cb:	6a 00                	push   $0x0
  8022cd:	e8 62 ec ff ff       	call   800f34 <sys_page_alloc>
  8022d2:	89 c3                	mov    %eax,%ebx
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	0f 88 05 01 00 00    	js     8023e4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022df:	83 ec 0c             	sub    $0xc,%esp
  8022e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8022e5:	50                   	push   %eax
  8022e6:	e8 d9 ed ff ff       	call   8010c4 <fd_alloc>
  8022eb:	89 c3                	mov    %eax,%ebx
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	85 c0                	test   %eax,%eax
  8022f2:	0f 88 dc 00 00 00    	js     8023d4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022f8:	83 ec 04             	sub    $0x4,%esp
  8022fb:	68 07 04 00 00       	push   $0x407
  802300:	ff 75 e0             	pushl  -0x20(%ebp)
  802303:	6a 00                	push   $0x0
  802305:	e8 2a ec ff ff       	call   800f34 <sys_page_alloc>
  80230a:	89 c3                	mov    %eax,%ebx
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	85 c0                	test   %eax,%eax
  802311:	0f 88 bd 00 00 00    	js     8023d4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802317:	83 ec 0c             	sub    $0xc,%esp
  80231a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80231d:	e8 8a ed ff ff       	call   8010ac <fd2data>
  802322:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802324:	83 c4 0c             	add    $0xc,%esp
  802327:	68 07 04 00 00       	push   $0x407
  80232c:	50                   	push   %eax
  80232d:	6a 00                	push   $0x0
  80232f:	e8 00 ec ff ff       	call   800f34 <sys_page_alloc>
  802334:	89 c3                	mov    %eax,%ebx
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	85 c0                	test   %eax,%eax
  80233b:	0f 88 83 00 00 00    	js     8023c4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802341:	83 ec 0c             	sub    $0xc,%esp
  802344:	ff 75 e0             	pushl  -0x20(%ebp)
  802347:	e8 60 ed ff ff       	call   8010ac <fd2data>
  80234c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802353:	50                   	push   %eax
  802354:	6a 00                	push   $0x0
  802356:	56                   	push   %esi
  802357:	6a 00                	push   $0x0
  802359:	e8 fa eb ff ff       	call   800f58 <sys_page_map>
  80235e:	89 c3                	mov    %eax,%ebx
  802360:	83 c4 20             	add    $0x20,%esp
  802363:	85 c0                	test   %eax,%eax
  802365:	78 4f                	js     8023b6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802367:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80236d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802370:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802375:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80237c:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802385:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802387:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80238a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802391:	83 ec 0c             	sub    $0xc,%esp
  802394:	ff 75 e4             	pushl  -0x1c(%ebp)
  802397:	e8 00 ed ff ff       	call   80109c <fd2num>
  80239c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80239e:	83 c4 04             	add    $0x4,%esp
  8023a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8023a4:	e8 f3 ec ff ff       	call   80109c <fd2num>
  8023a9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023b4:	eb 2e                	jmp    8023e4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8023b6:	83 ec 08             	sub    $0x8,%esp
  8023b9:	56                   	push   %esi
  8023ba:	6a 00                	push   $0x0
  8023bc:	e8 bd eb ff ff       	call   800f7e <sys_page_unmap>
  8023c1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023c4:	83 ec 08             	sub    $0x8,%esp
  8023c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8023ca:	6a 00                	push   $0x0
  8023cc:	e8 ad eb ff ff       	call   800f7e <sys_page_unmap>
  8023d1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023d4:	83 ec 08             	sub    $0x8,%esp
  8023d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023da:	6a 00                	push   $0x0
  8023dc:	e8 9d eb ff ff       	call   800f7e <sys_page_unmap>
  8023e1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8023e4:	89 d8                	mov    %ebx,%eax
  8023e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e9:	5b                   	pop    %ebx
  8023ea:	5e                   	pop    %esi
  8023eb:	5f                   	pop    %edi
  8023ec:	c9                   	leave  
  8023ed:	c3                   	ret    

008023ee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f7:	50                   	push   %eax
  8023f8:	ff 75 08             	pushl  0x8(%ebp)
  8023fb:	e8 37 ed ff ff       	call   801137 <fd_lookup>
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	85 c0                	test   %eax,%eax
  802405:	78 18                	js     80241f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802407:	83 ec 0c             	sub    $0xc,%esp
  80240a:	ff 75 f4             	pushl  -0xc(%ebp)
  80240d:	e8 9a ec ff ff       	call   8010ac <fd2data>
	return _pipeisclosed(fd, p);
  802412:	89 c2                	mov    %eax,%edx
  802414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802417:	e8 0c fd ff ff       	call   802128 <_pipeisclosed>
  80241c:	83 c4 10             	add    $0x10,%esp
}
  80241f:	c9                   	leave  
  802420:	c3                   	ret    
  802421:	00 00                	add    %al,(%eax)
	...

00802424 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802424:	55                   	push   %ebp
  802425:	89 e5                	mov    %esp,%ebp
  802427:	57                   	push   %edi
  802428:	56                   	push   %esi
  802429:	53                   	push   %ebx
  80242a:	83 ec 0c             	sub    $0xc,%esp
  80242d:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802430:	85 c0                	test   %eax,%eax
  802432:	75 16                	jne    80244a <wait+0x26>
  802434:	68 9f 2e 80 00       	push   $0x802e9f
  802439:	68 9f 2d 80 00       	push   $0x802d9f
  80243e:	6a 09                	push   $0x9
  802440:	68 aa 2e 80 00       	push   $0x802eaa
  802445:	e8 da df ff ff       	call   800424 <_panic>
	e = &envs[ENVX(envid)];
  80244a:	89 c6                	mov    %eax,%esi
  80244c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802452:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802459:	89 f2                	mov    %esi,%edx
  80245b:	c1 e2 07             	shl    $0x7,%edx
  80245e:	29 ca                	sub    %ecx,%edx
  802460:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  802466:	8b 7a 40             	mov    0x40(%edx),%edi
  802469:	39 c7                	cmp    %eax,%edi
  80246b:	75 37                	jne    8024a4 <wait+0x80>
  80246d:	89 f0                	mov    %esi,%eax
  80246f:	c1 e0 07             	shl    $0x7,%eax
  802472:	29 c8                	sub    %ecx,%eax
  802474:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802479:	8b 40 50             	mov    0x50(%eax),%eax
  80247c:	85 c0                	test   %eax,%eax
  80247e:	74 24                	je     8024a4 <wait+0x80>
  802480:	c1 e6 07             	shl    $0x7,%esi
  802483:	29 ce                	sub    %ecx,%esi
  802485:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  80248b:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802491:	e8 77 ea ff ff       	call   800f0d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802496:	8b 43 40             	mov    0x40(%ebx),%eax
  802499:	39 f8                	cmp    %edi,%eax
  80249b:	75 07                	jne    8024a4 <wait+0x80>
  80249d:	8b 46 50             	mov    0x50(%esi),%eax
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	75 ed                	jne    802491 <wait+0x6d>
		sys_yield();
}
  8024a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5e                   	pop    %esi
  8024a9:	5f                   	pop    %edi
  8024aa:	c9                   	leave  
  8024ab:	c3                   	ret    

008024ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8024ba:	85 c0                	test   %eax,%eax
  8024bc:	74 0e                	je     8024cc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8024be:	83 ec 0c             	sub    $0xc,%esp
  8024c1:	50                   	push   %eax
  8024c2:	e8 68 eb ff ff       	call   80102f <sys_ipc_recv>
  8024c7:	83 c4 10             	add    $0x10,%esp
  8024ca:	eb 10                	jmp    8024dc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8024cc:	83 ec 0c             	sub    $0xc,%esp
  8024cf:	68 00 00 c0 ee       	push   $0xeec00000
  8024d4:	e8 56 eb ff ff       	call   80102f <sys_ipc_recv>
  8024d9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	75 26                	jne    802506 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8024e0:	85 f6                	test   %esi,%esi
  8024e2:	74 0a                	je     8024ee <ipc_recv+0x42>
  8024e4:	a1 90 67 80 00       	mov    0x806790,%eax
  8024e9:	8b 40 74             	mov    0x74(%eax),%eax
  8024ec:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8024ee:	85 db                	test   %ebx,%ebx
  8024f0:	74 0a                	je     8024fc <ipc_recv+0x50>
  8024f2:	a1 90 67 80 00       	mov    0x806790,%eax
  8024f7:	8b 40 78             	mov    0x78(%eax),%eax
  8024fa:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8024fc:	a1 90 67 80 00       	mov    0x806790,%eax
  802501:	8b 40 70             	mov    0x70(%eax),%eax
  802504:	eb 14                	jmp    80251a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802506:	85 f6                	test   %esi,%esi
  802508:	74 06                	je     802510 <ipc_recv+0x64>
  80250a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802510:	85 db                	test   %ebx,%ebx
  802512:	74 06                	je     80251a <ipc_recv+0x6e>
  802514:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  80251a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	c9                   	leave  
  802520:	c3                   	ret    

00802521 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	57                   	push   %edi
  802525:	56                   	push   %esi
  802526:	53                   	push   %ebx
  802527:	83 ec 0c             	sub    $0xc,%esp
  80252a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80252d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802530:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802533:	85 db                	test   %ebx,%ebx
  802535:	75 25                	jne    80255c <ipc_send+0x3b>
  802537:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80253c:	eb 1e                	jmp    80255c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80253e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802541:	75 07                	jne    80254a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802543:	e8 c5 e9 ff ff       	call   800f0d <sys_yield>
  802548:	eb 12                	jmp    80255c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80254a:	50                   	push   %eax
  80254b:	68 b5 2e 80 00       	push   $0x802eb5
  802550:	6a 43                	push   $0x43
  802552:	68 c8 2e 80 00       	push   $0x802ec8
  802557:	e8 c8 de ff ff       	call   800424 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80255c:	56                   	push   %esi
  80255d:	53                   	push   %ebx
  80255e:	57                   	push   %edi
  80255f:	ff 75 08             	pushl  0x8(%ebp)
  802562:	e8 a3 ea ff ff       	call   80100a <sys_ipc_try_send>
  802567:	83 c4 10             	add    $0x10,%esp
  80256a:	85 c0                	test   %eax,%eax
  80256c:	75 d0                	jne    80253e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80256e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802571:	5b                   	pop    %ebx
  802572:	5e                   	pop    %esi
  802573:	5f                   	pop    %edi
  802574:	c9                   	leave  
  802575:	c3                   	ret    

00802576 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	53                   	push   %ebx
  80257a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80257d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802583:	74 22                	je     8025a7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802585:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80258a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802591:	89 c2                	mov    %eax,%edx
  802593:	c1 e2 07             	shl    $0x7,%edx
  802596:	29 ca                	sub    %ecx,%edx
  802598:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80259e:	8b 52 50             	mov    0x50(%edx),%edx
  8025a1:	39 da                	cmp    %ebx,%edx
  8025a3:	75 1d                	jne    8025c2 <ipc_find_env+0x4c>
  8025a5:	eb 05                	jmp    8025ac <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8025ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8025b3:	c1 e0 07             	shl    $0x7,%eax
  8025b6:	29 d0                	sub    %edx,%eax
  8025b8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8025bd:	8b 40 40             	mov    0x40(%eax),%eax
  8025c0:	eb 0c                	jmp    8025ce <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025c2:	40                   	inc    %eax
  8025c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025c8:	75 c0                	jne    80258a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025ca:	66 b8 00 00          	mov    $0x0,%ax
}
  8025ce:	5b                   	pop    %ebx
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    
  8025d1:	00 00                	add    %al,(%eax)
	...

008025d4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025da:	89 c2                	mov    %eax,%edx
  8025dc:	c1 ea 16             	shr    $0x16,%edx
  8025df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025e6:	f6 c2 01             	test   $0x1,%dl
  8025e9:	74 1e                	je     802609 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025eb:	c1 e8 0c             	shr    $0xc,%eax
  8025ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025f5:	a8 01                	test   $0x1,%al
  8025f7:	74 17                	je     802610 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025f9:	c1 e8 0c             	shr    $0xc,%eax
  8025fc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802603:	ef 
  802604:	0f b7 c0             	movzwl %ax,%eax
  802607:	eb 0c                	jmp    802615 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802609:	b8 00 00 00 00       	mov    $0x0,%eax
  80260e:	eb 05                	jmp    802615 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802610:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802615:	c9                   	leave  
  802616:	c3                   	ret    
	...

00802618 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802618:	55                   	push   %ebp
  802619:	89 e5                	mov    %esp,%ebp
  80261b:	57                   	push   %edi
  80261c:	56                   	push   %esi
  80261d:	83 ec 10             	sub    $0x10,%esp
  802620:	8b 7d 08             	mov    0x8(%ebp),%edi
  802623:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802626:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802629:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80262c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80262f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802632:	85 c0                	test   %eax,%eax
  802634:	75 2e                	jne    802664 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802636:	39 f1                	cmp    %esi,%ecx
  802638:	77 5a                	ja     802694 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80263a:	85 c9                	test   %ecx,%ecx
  80263c:	75 0b                	jne    802649 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80263e:	b8 01 00 00 00       	mov    $0x1,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f1                	div    %ecx
  802647:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802649:	31 d2                	xor    %edx,%edx
  80264b:	89 f0                	mov    %esi,%eax
  80264d:	f7 f1                	div    %ecx
  80264f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802651:	89 f8                	mov    %edi,%eax
  802653:	f7 f1                	div    %ecx
  802655:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802657:	89 f8                	mov    %edi,%eax
  802659:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80265b:	83 c4 10             	add    $0x10,%esp
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	c9                   	leave  
  802661:	c3                   	ret    
  802662:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802664:	39 f0                	cmp    %esi,%eax
  802666:	77 1c                	ja     802684 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802668:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80266b:	83 f7 1f             	xor    $0x1f,%edi
  80266e:	75 3c                	jne    8026ac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802670:	39 f0                	cmp    %esi,%eax
  802672:	0f 82 90 00 00 00    	jb     802708 <__udivdi3+0xf0>
  802678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80267b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80267e:	0f 86 84 00 00 00    	jbe    802708 <__udivdi3+0xf0>
  802684:	31 f6                	xor    %esi,%esi
  802686:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802688:	89 f8                	mov    %edi,%eax
  80268a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80268c:	83 c4 10             	add    $0x10,%esp
  80268f:	5e                   	pop    %esi
  802690:	5f                   	pop    %edi
  802691:	c9                   	leave  
  802692:	c3                   	ret    
  802693:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802694:	89 f2                	mov    %esi,%edx
  802696:	89 f8                	mov    %edi,%eax
  802698:	f7 f1                	div    %ecx
  80269a:	89 c7                	mov    %eax,%edi
  80269c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80269e:	89 f8                	mov    %edi,%eax
  8026a0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026a2:	83 c4 10             	add    $0x10,%esp
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	c9                   	leave  
  8026a8:	c3                   	ret    
  8026a9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026ac:	89 f9                	mov    %edi,%ecx
  8026ae:	d3 e0                	shl    %cl,%eax
  8026b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8026b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026b8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8026ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026bd:	88 c1                	mov    %al,%cl
  8026bf:	d3 ea                	shr    %cl,%edx
  8026c1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8026c4:	09 ca                	or     %ecx,%edx
  8026c6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8026c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026cc:	89 f9                	mov    %edi,%ecx
  8026ce:	d3 e2                	shl    %cl,%edx
  8026d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	88 c1                	mov    %al,%cl
  8026d7:	d3 ea                	shr    %cl,%edx
  8026d9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8026dc:	89 f2                	mov    %esi,%edx
  8026de:	89 f9                	mov    %edi,%ecx
  8026e0:	d3 e2                	shl    %cl,%edx
  8026e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8026e5:	88 c1                	mov    %al,%cl
  8026e7:	d3 ee                	shr    %cl,%esi
  8026e9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026eb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8026ee:	89 f0                	mov    %esi,%eax
  8026f0:	89 ca                	mov    %ecx,%edx
  8026f2:	f7 75 ec             	divl   -0x14(%ebp)
  8026f5:	89 d1                	mov    %edx,%ecx
  8026f7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8026f9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026fc:	39 d1                	cmp    %edx,%ecx
  8026fe:	72 28                	jb     802728 <__udivdi3+0x110>
  802700:	74 1a                	je     80271c <__udivdi3+0x104>
  802702:	89 f7                	mov    %esi,%edi
  802704:	31 f6                	xor    %esi,%esi
  802706:	eb 80                	jmp    802688 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802708:	31 f6                	xor    %esi,%esi
  80270a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80270f:	89 f8                	mov    %edi,%eax
  802711:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802713:	83 c4 10             	add    $0x10,%esp
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	c9                   	leave  
  802719:	c3                   	ret    
  80271a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80271c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80271f:	89 f9                	mov    %edi,%ecx
  802721:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802723:	39 c2                	cmp    %eax,%edx
  802725:	73 db                	jae    802702 <__udivdi3+0xea>
  802727:	90                   	nop
		{
		  q0--;
  802728:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80272b:	31 f6                	xor    %esi,%esi
  80272d:	e9 56 ff ff ff       	jmp    802688 <__udivdi3+0x70>
	...

00802734 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802734:	55                   	push   %ebp
  802735:	89 e5                	mov    %esp,%ebp
  802737:	57                   	push   %edi
  802738:	56                   	push   %esi
  802739:	83 ec 20             	sub    $0x20,%esp
  80273c:	8b 45 08             	mov    0x8(%ebp),%eax
  80273f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802742:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802745:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802748:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80274b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80274e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802751:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802753:	85 ff                	test   %edi,%edi
  802755:	75 15                	jne    80276c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802757:	39 f1                	cmp    %esi,%ecx
  802759:	0f 86 99 00 00 00    	jbe    8027f8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80275f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802761:	89 d0                	mov    %edx,%eax
  802763:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802765:	83 c4 20             	add    $0x20,%esp
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	c9                   	leave  
  80276b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80276c:	39 f7                	cmp    %esi,%edi
  80276e:	0f 87 a4 00 00 00    	ja     802818 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802774:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802777:	83 f0 1f             	xor    $0x1f,%eax
  80277a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80277d:	0f 84 a1 00 00 00    	je     802824 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802783:	89 f8                	mov    %edi,%eax
  802785:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802788:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80278a:	bf 20 00 00 00       	mov    $0x20,%edi
  80278f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802792:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802795:	89 f9                	mov    %edi,%ecx
  802797:	d3 ea                	shr    %cl,%edx
  802799:	09 c2                	or     %eax,%edx
  80279b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80279e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027a4:	d3 e0                	shl    %cl,%eax
  8027a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027a9:	89 f2                	mov    %esi,%edx
  8027ab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8027ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027b0:	d3 e0                	shl    %cl,%eax
  8027b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027b8:	89 f9                	mov    %edi,%ecx
  8027ba:	d3 e8                	shr    %cl,%eax
  8027bc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8027be:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027c0:	89 f2                	mov    %esi,%edx
  8027c2:	f7 75 f0             	divl   -0x10(%ebp)
  8027c5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8027c7:	f7 65 f4             	mull   -0xc(%ebp)
  8027ca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8027cd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027cf:	39 d6                	cmp    %edx,%esi
  8027d1:	72 71                	jb     802844 <__umoddi3+0x110>
  8027d3:	74 7f                	je     802854 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8027d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027d8:	29 c8                	sub    %ecx,%eax
  8027da:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8027dc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027df:	d3 e8                	shr    %cl,%eax
  8027e1:	89 f2                	mov    %esi,%edx
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8027e7:	09 d0                	or     %edx,%eax
  8027e9:	89 f2                	mov    %esi,%edx
  8027eb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027ee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027f0:	83 c4 20             	add    $0x20,%esp
  8027f3:	5e                   	pop    %esi
  8027f4:	5f                   	pop    %edi
  8027f5:	c9                   	leave  
  8027f6:	c3                   	ret    
  8027f7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027f8:	85 c9                	test   %ecx,%ecx
  8027fa:	75 0b                	jne    802807 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802801:	31 d2                	xor    %edx,%edx
  802803:	f7 f1                	div    %ecx
  802805:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802807:	89 f0                	mov    %esi,%eax
  802809:	31 d2                	xor    %edx,%edx
  80280b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80280d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802810:	f7 f1                	div    %ecx
  802812:	e9 4a ff ff ff       	jmp    802761 <__umoddi3+0x2d>
  802817:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802818:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80281a:	83 c4 20             	add    $0x20,%esp
  80281d:	5e                   	pop    %esi
  80281e:	5f                   	pop    %edi
  80281f:	c9                   	leave  
  802820:	c3                   	ret    
  802821:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802824:	39 f7                	cmp    %esi,%edi
  802826:	72 05                	jb     80282d <__umoddi3+0xf9>
  802828:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80282b:	77 0c                	ja     802839 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80282d:	89 f2                	mov    %esi,%edx
  80282f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802832:	29 c8                	sub    %ecx,%eax
  802834:	19 fa                	sbb    %edi,%edx
  802836:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80283c:	83 c4 20             	add    $0x20,%esp
  80283f:	5e                   	pop    %esi
  802840:	5f                   	pop    %edi
  802841:	c9                   	leave  
  802842:	c3                   	ret    
  802843:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802844:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802847:	89 c1                	mov    %eax,%ecx
  802849:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80284c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80284f:	eb 84                	jmp    8027d5 <__umoddi3+0xa1>
  802851:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802854:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802857:	72 eb                	jb     802844 <__umoddi3+0x110>
  802859:	89 f2                	mov    %esi,%edx
  80285b:	e9 75 ff ff ff       	jmp    8027d5 <__umoddi3+0xa1>
