
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
  800075:	68 e0 25 80 00       	push   $0x8025e0
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
  8000a4:	68 a8 26 80 00       	push   $0x8026a8
  8000a9:	e8 4e 04 00 00       	call   8004fc <cprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	eb 10                	jmp    8000c3 <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	68 ef 25 80 00       	push   $0x8025ef
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
  8000e0:	68 e4 26 80 00       	push   $0x8026e4
  8000e5:	e8 12 04 00 00       	call   8004fc <cprintf>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	eb 10                	jmp    8000ff <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 06 26 80 00       	push   $0x802606
  8000f7:	e8 00 04 00 00       	call   8004fc <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 1c 26 80 00       	push   $0x80261c
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
  80012a:	68 28 26 80 00       	push   $0x802628
  80012f:	53                   	push   %ebx
  800130:	e8 9a 09 00 00       	call   800acf <strcat>
		strcat(args, argv[i]);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff 34 b7             	pushl  (%edi,%esi,4)
  80013b:	53                   	push   %ebx
  80013c:	e8 8e 09 00 00       	call   800acf <strcat>
		strcat(args, "'");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	68 29 26 80 00       	push   $0x802629
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
  800162:	68 2b 26 80 00       	push   $0x80262b
  800167:	e8 90 03 00 00       	call   8004fc <cprintf>

	cprintf("init: running sh\n");
  80016c:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  800173:	e8 84 03 00 00       	call   8004fc <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017f:	e8 cf 10 00 00       	call   801253 <close>
	if ((r = opencons()) < 0)
  800184:	e8 dd 01 00 00       	call   800366 <opencons>
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	85 c0                	test   %eax,%eax
  80018e:	79 12                	jns    8001a2 <umain+0x13c>
		panic("opencons: %e", r);
  800190:	50                   	push   %eax
  800191:	68 41 26 80 00       	push   $0x802641
  800196:	6a 37                	push   $0x37
  800198:	68 4e 26 80 00       	push   $0x80264e
  80019d:	e8 82 02 00 00       	call   800424 <_panic>
	if (r != 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	74 12                	je     8001b8 <umain+0x152>
		panic("first opencons used fd %d", r);
  8001a6:	50                   	push   %eax
  8001a7:	68 5a 26 80 00       	push   $0x80265a
  8001ac:	6a 39                	push   $0x39
  8001ae:	68 4e 26 80 00       	push   $0x80264e
  8001b3:	e8 6c 02 00 00       	call   800424 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	6a 01                	push   $0x1
  8001bd:	6a 00                	push   $0x0
  8001bf:	e8 dd 10 00 00       	call   8012a1 <dup>
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	79 12                	jns    8001dd <umain+0x177>
		panic("dup: %e", r);
  8001cb:	50                   	push   %eax
  8001cc:	68 74 26 80 00       	push   $0x802674
  8001d1:	6a 3b                	push   $0x3b
  8001d3:	68 4e 26 80 00       	push   $0x80264e
  8001d8:	e8 47 02 00 00       	call   800424 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	68 7c 26 80 00       	push   $0x80267c
  8001e5:	e8 12 03 00 00       	call   8004fc <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001ea:	83 c4 0c             	add    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	68 90 26 80 00       	push   $0x802690
  8001f4:	68 8f 26 80 00       	push   $0x80268f
  8001f9:	e8 69 1b 00 00       	call   801d67 <spawnl>
		if (r < 0) {
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	85 c0                	test   %eax,%eax
  800203:	79 13                	jns    800218 <umain+0x1b2>
			cprintf("init: spawn sh: %e\n", r);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	50                   	push   %eax
  800209:	68 93 26 80 00       	push   $0x802693
  80020e:	e8 e9 02 00 00       	call   8004fc <cprintf>
			continue;
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	eb c5                	jmp    8001dd <umain+0x177>
		}
		wait(r);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	e8 43 1f 00 00       	call   802164 <wait>
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
  800238:	68 13 27 80 00       	push   $0x802713
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
  80031d:	e8 6e 10 00 00       	call   801390 <read>
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
  800347:	e8 c3 0d 00 00       	call   80110f <fd_lookup>
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
  800370:	e8 27 0d 00 00       	call   80109c <fd_alloc>
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
  8003ae:	e8 c1 0c 00 00       	call   801074 <fd2num>
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
  80040e:	e8 6b 0e 00 00       	call   80127e <close_all>
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
  800442:	68 2c 27 80 00       	push   $0x80272c
  800447:	e8 b0 00 00 00       	call   8004fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	56                   	push   %esi
  800450:	ff 75 10             	pushl  0x10(%ebp)
  800453:	e8 53 00 00 00       	call   8004ab <vcprintf>
	cprintf("\n");
  800458:	c7 04 24 55 2b 80 00 	movl   $0x802b55,(%esp)
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
  800564:	e8 1f 1e 00 00       	call   802388 <__udivdi3>
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
  8005a0:	e8 ff 1e 00 00       	call   8024a4 <__umoddi3>
  8005a5:	83 c4 14             	add    $0x14,%esp
  8005a8:	0f be 80 4f 27 80 00 	movsbl 0x80274f(%eax),%eax
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
  8006ec:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
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
  800798:	8b 04 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%eax
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	75 1a                	jne    8007bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8007a3:	52                   	push   %edx
  8007a4:	68 67 27 80 00       	push   $0x802767
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
  8007be:	68 37 2b 80 00       	push   $0x802b37
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
  8007f4:	c7 45 d0 60 27 80 00 	movl   $0x802760,-0x30(%ebp)
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
  800e62:	68 5f 2a 80 00       	push   $0x802a5f
  800e67:	6a 42                	push   $0x42
  800e69:	68 7c 2a 80 00       	push   $0x802a7c
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

00801074 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	05 00 00 00 30       	add    $0x30000000,%eax
  80107f:	c1 e8 0c             	shr    $0xc,%eax
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801087:	ff 75 08             	pushl  0x8(%ebp)
  80108a:	e8 e5 ff ff ff       	call   801074 <fd2num>
  80108f:	83 c4 04             	add    $0x4,%esp
  801092:	05 20 00 0d 00       	add    $0xd0020,%eax
  801097:	c1 e0 0c             	shl    $0xc,%eax
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	53                   	push   %ebx
  8010a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010a8:	a8 01                	test   $0x1,%al
  8010aa:	74 34                	je     8010e0 <fd_alloc+0x44>
  8010ac:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010b1:	a8 01                	test   $0x1,%al
  8010b3:	74 32                	je     8010e7 <fd_alloc+0x4b>
  8010b5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010ba:	89 c1                	mov    %eax,%ecx
  8010bc:	89 c2                	mov    %eax,%edx
  8010be:	c1 ea 16             	shr    $0x16,%edx
  8010c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c8:	f6 c2 01             	test   $0x1,%dl
  8010cb:	74 1f                	je     8010ec <fd_alloc+0x50>
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	c1 ea 0c             	shr    $0xc,%edx
  8010d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d9:	f6 c2 01             	test   $0x1,%dl
  8010dc:	75 17                	jne    8010f5 <fd_alloc+0x59>
  8010de:	eb 0c                	jmp    8010ec <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010e0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010e5:	eb 05                	jmp    8010ec <fd_alloc+0x50>
  8010e7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010ec:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f3:	eb 17                	jmp    80110c <fd_alloc+0x70>
  8010f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ff:	75 b9                	jne    8010ba <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801107:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110c:	5b                   	pop    %ebx
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801115:	83 f8 1f             	cmp    $0x1f,%eax
  801118:	77 36                	ja     801150 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80111f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801122:	89 c2                	mov    %eax,%edx
  801124:	c1 ea 16             	shr    $0x16,%edx
  801127:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112e:	f6 c2 01             	test   $0x1,%dl
  801131:	74 24                	je     801157 <fd_lookup+0x48>
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 0c             	shr    $0xc,%edx
  801138:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 1a                	je     80115e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
  801147:	89 02                	mov    %eax,(%edx)
	return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	eb 13                	jmp    801163 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801155:	eb 0c                	jmp    801163 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115c:	eb 05                	jmp    801163 <fd_lookup+0x54>
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	53                   	push   %ebx
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801172:	39 0d 90 47 80 00    	cmp    %ecx,0x804790
  801178:	74 0d                	je     801187 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 14                	jmp    801195 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801181:	39 0a                	cmp    %ecx,(%edx)
  801183:	75 10                	jne    801195 <dev_lookup+0x30>
  801185:	eb 05                	jmp    80118c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801187:	ba 90 47 80 00       	mov    $0x804790,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80118c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	eb 31                	jmp    8011c6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801195:	40                   	inc    %eax
  801196:	8b 14 85 08 2b 80 00 	mov    0x802b08(,%eax,4),%edx
  80119d:	85 d2                	test   %edx,%edx
  80119f:	75 e0                	jne    801181 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a1:	a1 90 67 80 00       	mov    0x806790,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	51                   	push   %ecx
  8011ad:	50                   	push   %eax
  8011ae:	68 8c 2a 80 00       	push   $0x802a8c
  8011b3:	e8 44 f3 ff ff       	call   8004fc <cprintf>
	*dev = 0;
  8011b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 20             	sub    $0x20,%esp
  8011d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d6:	8a 45 0c             	mov    0xc(%ebp),%al
  8011d9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011dc:	56                   	push   %esi
  8011dd:	e8 92 fe ff ff       	call   801074 <fd2num>
  8011e2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011e5:	89 14 24             	mov    %edx,(%esp)
  8011e8:	50                   	push   %eax
  8011e9:	e8 21 ff ff ff       	call   80110f <fd_lookup>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 05                	js     8011fc <fd_close+0x31>
	    || fd != fd2)
  8011f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fa:	74 0d                	je     801209 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011fc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801200:	75 48                	jne    80124a <fd_close+0x7f>
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	eb 41                	jmp    80124a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 36                	pushl  (%esi)
  801212:	e8 4e ff ff ff       	call   801165 <dev_lookup>
  801217:	89 c3                	mov    %eax,%ebx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 1c                	js     80123c <fd_close+0x71>
		if (dev->dev_close)
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	8b 40 10             	mov    0x10(%eax),%eax
  801226:	85 c0                	test   %eax,%eax
  801228:	74 0d                	je     801237 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	56                   	push   %esi
  80122e:	ff d0                	call   *%eax
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	eb 05                	jmp    80123c <fd_close+0x71>
		else
			r = 0;
  801237:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	56                   	push   %esi
  801240:	6a 00                	push   $0x0
  801242:	e8 37 fd ff ff       	call   800f7e <sys_page_unmap>
	return r;
  801247:	83 c4 10             	add    $0x10,%esp
}
  80124a:	89 d8                	mov    %ebx,%eax
  80124c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 aa fe ff ff       	call   80110f <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 10                	js     80127c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	6a 01                	push   $0x1
  801271:	ff 75 f4             	pushl  -0xc(%ebp)
  801274:	e8 52 ff ff ff       	call   8011cb <fd_close>
  801279:	83 c4 10             	add    $0x10,%esp
}
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <close_all>:

void
close_all(void)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801285:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	53                   	push   %ebx
  80128e:	e8 c0 ff ff ff       	call   801253 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801293:	43                   	inc    %ebx
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	83 fb 20             	cmp    $0x20,%ebx
  80129a:	75 ee                	jne    80128a <close_all+0xc>
		close(i);
}
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 2c             	sub    $0x2c,%esp
  8012aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	e8 56 fe ff ff       	call   80110f <fd_lookup>
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	0f 88 c0 00 00 00    	js     801386 <dup+0xe5>
		return r;
	close(newfdnum);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	57                   	push   %edi
  8012ca:	e8 84 ff ff ff       	call   801253 <close>

	newfd = INDEX2FD(newfdnum);
  8012cf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012d5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8012d8:	83 c4 04             	add    $0x4,%esp
  8012db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012de:	e8 a1 fd ff ff       	call   801084 <fd2data>
  8012e3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e5:	89 34 24             	mov    %esi,(%esp)
  8012e8:	e8 97 fd ff ff       	call   801084 <fd2data>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f3:	89 d8                	mov    %ebx,%eax
  8012f5:	c1 e8 16             	shr    $0x16,%eax
  8012f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	74 37                	je     80133a <dup+0x99>
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 26                	je     80133a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801314:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	25 07 0e 00 00       	and    $0xe07,%eax
  801323:	50                   	push   %eax
  801324:	ff 75 d4             	pushl  -0x2c(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	53                   	push   %ebx
  80132a:	6a 00                	push   $0x0
  80132c:	e8 27 fc ff ff       	call   800f58 <sys_page_map>
  801331:	89 c3                	mov    %eax,%ebx
  801333:	83 c4 20             	add    $0x20,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 2d                	js     801367 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	c1 ea 0c             	shr    $0xc,%edx
  801342:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801352:	52                   	push   %edx
  801353:	56                   	push   %esi
  801354:	6a 00                	push   $0x0
  801356:	50                   	push   %eax
  801357:	6a 00                	push   $0x0
  801359:	e8 fa fb ff ff       	call   800f58 <sys_page_map>
  80135e:	89 c3                	mov    %eax,%ebx
  801360:	83 c4 20             	add    $0x20,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	79 1d                	jns    801384 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	56                   	push   %esi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 0c fc ff ff       	call   800f7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801372:	83 c4 08             	add    $0x8,%esp
  801375:	ff 75 d4             	pushl  -0x2c(%ebp)
  801378:	6a 00                	push   $0x0
  80137a:	e8 ff fb ff ff       	call   800f7e <sys_page_unmap>
	return r;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 02                	jmp    801386 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801384:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801386:	89 d8                	mov    %ebx,%eax
  801388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	53                   	push   %ebx
  801394:	83 ec 14             	sub    $0x14,%esp
  801397:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	53                   	push   %ebx
  80139f:	e8 6b fd ff ff       	call   80110f <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 67                	js     801412 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 a9 fd ff ff       	call   801165 <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 4f                	js     801412 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	8b 50 08             	mov    0x8(%eax),%edx
  8013c9:	83 e2 03             	and    $0x3,%edx
  8013cc:	83 fa 01             	cmp    $0x1,%edx
  8013cf:	75 21                	jne    8013f2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d1:	a1 90 67 80 00       	mov    0x806790,%eax
  8013d6:	8b 40 48             	mov    0x48(%eax),%eax
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	50                   	push   %eax
  8013de:	68 cd 2a 80 00       	push   $0x802acd
  8013e3:	e8 14 f1 ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f0:	eb 20                	jmp    801412 <read+0x82>
	}
	if (!dev->dev_read)
  8013f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f5:	8b 52 08             	mov    0x8(%edx),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 11                	je     80140d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	ff 75 10             	pushl  0x10(%ebp)
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	50                   	push   %eax
  801406:	ff d2                	call   *%edx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb 05                	jmp    801412 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80140d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	57                   	push   %edi
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	8b 7d 08             	mov    0x8(%ebp),%edi
  801423:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801426:	85 f6                	test   %esi,%esi
  801428:	74 31                	je     80145b <readn+0x44>
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	89 f2                	mov    %esi,%edx
  801439:	29 c2                	sub    %eax,%edx
  80143b:	52                   	push   %edx
  80143c:	03 45 0c             	add    0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	57                   	push   %edi
  801441:	e8 4a ff ff ff       	call   801390 <read>
		if (m < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 17                	js     801464 <readn+0x4d>
			return m;
		if (m == 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 11                	je     801462 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801451:	01 c3                	add    %eax,%ebx
  801453:	89 d8                	mov    %ebx,%eax
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	72 db                	jb     801434 <readn+0x1d>
  801459:	eb 09                	jmp    801464 <readn+0x4d>
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	eb 02                	jmp    801464 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801462:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801464:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5f                   	pop    %edi
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 14             	sub    $0x14,%esp
  801473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	53                   	push   %ebx
  80147b:	e8 8f fc ff ff       	call   80110f <fd_lookup>
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 62                	js     8014e9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 cd fc ff ff       	call   801165 <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4a                	js     8014e9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a6:	75 21                	jne    8014c9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a8:	a1 90 67 80 00       	mov    0x806790,%eax
  8014ad:	8b 40 48             	mov    0x48(%eax),%eax
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	53                   	push   %ebx
  8014b4:	50                   	push   %eax
  8014b5:	68 e9 2a 80 00       	push   $0x802ae9
  8014ba:	e8 3d f0 ff ff       	call   8004fc <cprintf>
		return -E_INVAL;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c7:	eb 20                	jmp    8014e9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cf:	85 d2                	test   %edx,%edx
  8014d1:	74 11                	je     8014e4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	ff 75 10             	pushl  0x10(%ebp)
  8014d9:	ff 75 0c             	pushl  0xc(%ebp)
  8014dc:	50                   	push   %eax
  8014dd:	ff d2                	call   *%edx
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	eb 05                	jmp    8014e9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	e8 0f fc ff ff       	call   80110f <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 0e                	js     801515 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801507:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80150a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801510:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	53                   	push   %ebx
  80151b:	83 ec 14             	sub    $0x14,%esp
  80151e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	53                   	push   %ebx
  801526:	e8 e4 fb ff ff       	call   80110f <fd_lookup>
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 5f                	js     801591 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 22 fc ff ff       	call   801165 <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 47                	js     801591 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801551:	75 21                	jne    801574 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801553:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	53                   	push   %ebx
  80155f:	50                   	push   %eax
  801560:	68 ac 2a 80 00       	push   $0x802aac
  801565:	e8 92 ef ff ff       	call   8004fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801572:	eb 1d                	jmp    801591 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801574:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801577:	8b 52 18             	mov    0x18(%edx),%edx
  80157a:	85 d2                	test   %edx,%edx
  80157c:	74 0e                	je     80158c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	50                   	push   %eax
  801585:	ff d2                	call   *%edx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb 05                	jmp    801591 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 63 fb ff ff       	call   80110f <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 52                	js     801605 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 a1 fb ff ff       	call   801165 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 3a                	js     801605 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d2:	74 2c                	je     801600 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015de:	00 00 00 
	stat->st_isdir = 0;
  8015e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e8:	00 00 00 
	stat->st_dev = dev;
  8015eb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f8:	ff 50 14             	call   *0x14(%eax)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 05                	jmp    801605 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801600:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	6a 00                	push   $0x0
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 8b 01 00 00       	call   8017a7 <open>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 1b                	js     801640 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	e8 65 ff ff ff       	call   801596 <fstat>
  801631:	89 c6                	mov    %eax,%esi
	close(fd);
  801633:	89 1c 24             	mov    %ebx,(%esp)
  801636:	e8 18 fc ff ff       	call   801253 <close>
	return r;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	89 f3                	mov    %esi,%ebx
}
  801640:	89 d8                	mov    %ebx,%eax
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	c9                   	leave  
  801648:	c3                   	ret    
  801649:	00 00                	add    %al,(%eax)
	...

0080164c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	89 c3                	mov    %eax,%ebx
  801653:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801655:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80165c:	75 12                	jne    801670 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	6a 01                	push   $0x1
  801663:	e8 81 0c 00 00       	call   8022e9 <ipc_find_env>
  801668:	a3 00 50 80 00       	mov    %eax,0x805000
  80166d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801670:	6a 07                	push   $0x7
  801672:	68 00 70 80 00       	push   $0x807000
  801677:	53                   	push   %ebx
  801678:	ff 35 00 50 80 00    	pushl  0x805000
  80167e:	e8 11 0c 00 00       	call   802294 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801683:	83 c4 0c             	add    $0xc,%esp
  801686:	6a 00                	push   $0x0
  801688:	56                   	push   %esi
  801689:	6a 00                	push   $0x0
  80168b:	e8 5c 0b 00 00       	call   8021ec <ipc_recv>
}
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b6:	e8 91 ff ff ff       	call   80164c <fsipc>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 39                	js     8016f8 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	68 18 2b 80 00       	push   $0x802b18
  8016c7:	e8 30 ee ff ff       	call   8004fc <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016cc:	83 c4 08             	add    $0x8,%esp
  8016cf:	68 00 70 80 00       	push   $0x807000
  8016d4:	53                   	push   %ebx
  8016d5:	e8 d8 f3 ff ff       	call   800ab2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016da:	a1 80 70 80 00       	mov    0x807080,%eax
  8016df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e5:	a1 84 70 80 00       	mov    0x807084,%eax
  8016ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 06 00 00 00       	mov    $0x6,%eax
  801718:	e8 2f ff ff ff       	call   80164c <fsipc>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	8b 40 0c             	mov    0xc(%eax),%eax
  80172d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801732:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801738:	ba 00 00 00 00       	mov    $0x0,%edx
  80173d:	b8 03 00 00 00       	mov    $0x3,%eax
  801742:	e8 05 ff ff ff       	call   80164c <fsipc>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 51                	js     80179e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80174d:	39 c6                	cmp    %eax,%esi
  80174f:	73 19                	jae    80176a <devfile_read+0x4b>
  801751:	68 1e 2b 80 00       	push   $0x802b1e
  801756:	68 25 2b 80 00       	push   $0x802b25
  80175b:	68 80 00 00 00       	push   $0x80
  801760:	68 3a 2b 80 00       	push   $0x802b3a
  801765:	e8 ba ec ff ff       	call   800424 <_panic>
	assert(r <= PGSIZE);
  80176a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80176f:	7e 19                	jle    80178a <devfile_read+0x6b>
  801771:	68 45 2b 80 00       	push   $0x802b45
  801776:	68 25 2b 80 00       	push   $0x802b25
  80177b:	68 81 00 00 00       	push   $0x81
  801780:	68 3a 2b 80 00       	push   $0x802b3a
  801785:	e8 9a ec ff ff       	call   800424 <_panic>
	memmove(buf, &fsipcbuf, r);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	50                   	push   %eax
  80178e:	68 00 70 80 00       	push   $0x807000
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	e8 d8 f4 ff ff       	call   800c73 <memmove>
	return r;
  80179b:	83 c4 10             	add    $0x10,%esp
}
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	56                   	push   %esi
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 1c             	sub    $0x1c,%esp
  8017af:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b2:	56                   	push   %esi
  8017b3:	e8 a8 f2 ff ff       	call   800a60 <strlen>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017c0:	7f 72                	jg     801834 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c8:	50                   	push   %eax
  8017c9:	e8 ce f8 ff ff       	call   80109c <fd_alloc>
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 62                	js     801839 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	56                   	push   %esi
  8017db:	68 00 70 80 00       	push   $0x807000
  8017e0:	e8 cd f2 ff ff       	call   800ab2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f5:	e8 52 fe ff ff       	call   80164c <fsipc>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	79 12                	jns    801815 <open+0x6e>
		fd_close(fd, 0);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	6a 00                	push   $0x0
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 bb f9 ff ff       	call   8011cb <fd_close>
		return r;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	eb 24                	jmp    801839 <open+0x92>
	}


	cprintf("OPEN\n");
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	68 51 2b 80 00       	push   $0x802b51
  80181d:	e8 da ec ff ff       	call   8004fc <cprintf>

	return fd2num(fd);
  801822:	83 c4 04             	add    $0x4,%esp
  801825:	ff 75 f4             	pushl  -0xc(%ebp)
  801828:	e8 47 f8 ff ff       	call   801074 <fd2num>
  80182d:	89 c3                	mov    %eax,%ebx
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	eb 05                	jmp    801839 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801834:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	c9                   	leave  
  801841:	c3                   	ret    
	...

00801844 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801850:	6a 00                	push   $0x0
  801852:	ff 75 08             	pushl  0x8(%ebp)
  801855:	e8 4d ff ff ff       	call   8017a7 <open>
  80185a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	0f 88 ce 04 00 00    	js     801d39 <spawn+0x4f5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	68 00 02 00 00       	push   $0x200
  801873:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801879:	50                   	push   %eax
  80187a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801880:	e8 92 fb ff ff       	call   801417 <readn>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	3d 00 02 00 00       	cmp    $0x200,%eax
  80188d:	75 0c                	jne    80189b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80188f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801896:	45 4c 46 
  801899:	74 38                	je     8018d3 <spawn+0x8f>
		close(fd);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018a4:	e8 aa f9 ff ff       	call   801253 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018a9:	83 c4 0c             	add    $0xc,%esp
  8018ac:	68 7f 45 4c 46       	push   $0x464c457f
  8018b1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018b7:	68 57 2b 80 00       	push   $0x802b57
  8018bc:	e8 3b ec ff ff       	call   8004fc <cprintf>
		return -E_NOT_EXEC;
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8018cb:	ff ff ff 
  8018ce:	e9 72 04 00 00       	jmp    801d45 <spawn+0x501>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018d3:	ba 07 00 00 00       	mov    $0x7,%edx
  8018d8:	89 d0                	mov    %edx,%eax
  8018da:	cd 30                	int    $0x30
  8018dc:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8018e2:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	0f 88 55 04 00 00    	js     801d45 <spawn+0x501>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8018fc:	89 c6                	mov    %eax,%esi
  8018fe:	c1 e6 07             	shl    $0x7,%esi
  801901:	29 d6                	sub    %edx,%esi
  801903:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801909:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80190f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801916:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80191c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801922:	8b 55 0c             	mov    0xc(%ebp),%edx
  801925:	8b 02                	mov    (%edx),%eax
  801927:	85 c0                	test   %eax,%eax
  801929:	74 39                	je     801964 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80192b:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801930:	bb 00 00 00 00       	mov    $0x0,%ebx
  801935:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	50                   	push   %eax
  80193b:	e8 20 f1 ff ff       	call   800a60 <strlen>
  801940:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801944:	43                   	inc    %ebx
  801945:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80194c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	75 e1                	jne    801937 <spawn+0xf3>
  801956:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  80195c:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801962:	eb 1e                	jmp    801982 <spawn+0x13e>
  801964:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80196b:	00 00 00 
  80196e:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801975:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801978:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80197d:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801982:	f7 de                	neg    %esi
  801984:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80198a:	89 fa                	mov    %edi,%edx
  80198c:	83 e2 fc             	and    $0xfffffffc,%edx
  80198f:	89 d8                	mov    %ebx,%eax
  801991:	f7 d0                	not    %eax
  801993:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801996:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80199c:	83 e8 08             	sub    $0x8,%eax
  80199f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019a4:	0f 86 a9 03 00 00    	jbe    801d53 <spawn+0x50f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	6a 07                	push   $0x7
  8019af:	68 00 00 40 00       	push   $0x400000
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 79 f5 ff ff       	call   800f34 <sys_page_alloc>
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 99 03 00 00    	js     801d5f <spawn+0x51b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019c6:	85 db                	test   %ebx,%ebx
  8019c8:	7e 44                	jle    801a0e <spawn+0x1ca>
  8019ca:	be 00 00 00 00       	mov    $0x0,%esi
  8019cf:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8019d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8019d8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019de:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019e4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019e7:	83 ec 08             	sub    $0x8,%esp
  8019ea:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019ed:	57                   	push   %edi
  8019ee:	e8 bf f0 ff ff       	call   800ab2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019f3:	83 c4 04             	add    $0x4,%esp
  8019f6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019f9:	e8 62 f0 ff ff       	call   800a60 <strlen>
  8019fe:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a02:	46                   	inc    %esi
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801a0c:	7c ca                	jl     8019d8 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a0e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a14:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801a1a:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a21:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a27:	74 19                	je     801a42 <spawn+0x1fe>
  801a29:	68 cc 2b 80 00       	push   $0x802bcc
  801a2e:	68 25 2b 80 00       	push   $0x802b25
  801a33:	68 f5 00 00 00       	push   $0xf5
  801a38:	68 71 2b 80 00       	push   $0x802b71
  801a3d:	e8 e2 e9 ff ff       	call   800424 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a42:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a48:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a4d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a53:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801a56:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a5c:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a5f:	89 d0                	mov    %edx,%eax
  801a61:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801a66:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	6a 07                	push   $0x7
  801a71:	68 00 d0 bf ee       	push   $0xeebfd000
  801a76:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a7c:	68 00 00 40 00       	push   $0x400000
  801a81:	6a 00                	push   $0x0
  801a83:	e8 d0 f4 ff ff       	call   800f58 <sys_page_map>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	83 c4 20             	add    $0x20,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	78 18                	js     801aa9 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a91:	83 ec 08             	sub    $0x8,%esp
  801a94:	68 00 00 40 00       	push   $0x400000
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 de f4 ff ff       	call   800f7e <sys_page_unmap>
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	79 1d                	jns    801ac6 <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	68 00 00 40 00       	push   $0x400000
  801ab1:	6a 00                	push   $0x0
  801ab3:	e8 c6 f4 ff ff       	call   800f7e <sys_page_unmap>
  801ab8:	83 c4 10             	add    $0x10,%esp
	return r;
  801abb:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801ac1:	e9 7f 02 00 00       	jmp    801d45 <spawn+0x501>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ac6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801acc:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801ad3:	00 
  801ad4:	0f 84 c3 01 00 00    	je     801c9d <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ada:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae1:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ae7:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801aee:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801af1:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801af7:	83 3a 01             	cmpl   $0x1,(%edx)
  801afa:	0f 85 7c 01 00 00    	jne    801c7c <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b00:	8b 42 18             	mov    0x18(%edx),%eax
  801b03:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801b06:	83 f8 01             	cmp    $0x1,%eax
  801b09:	19 db                	sbb    %ebx,%ebx
  801b0b:	83 e3 fe             	and    $0xfffffffe,%ebx
  801b0e:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b11:	8b 42 04             	mov    0x4(%edx),%eax
  801b14:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801b1a:	8b 52 10             	mov    0x10(%edx),%edx
  801b1d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801b23:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b29:	8b 40 14             	mov    0x14(%eax),%eax
  801b2c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b32:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b38:	8b 52 08             	mov    0x8(%edx),%edx
  801b3b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b41:	89 d0                	mov    %edx,%eax
  801b43:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b48:	74 1a                	je     801b64 <spawn+0x320>
		va -= i;
  801b4a:	29 c2                	sub    %eax,%edx
  801b4c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801b52:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801b58:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801b5e:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b64:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801b6b:	0f 84 0b 01 00 00    	je     801c7c <spawn+0x438>
  801b71:	bf 00 00 00 00       	mov    $0x0,%edi
  801b76:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801b7b:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801b81:	72 28                	jb     801bab <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	53                   	push   %ebx
  801b87:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801b8d:	57                   	push   %edi
  801b8e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b94:	e8 9b f3 ff ff       	call   800f34 <sys_page_alloc>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	0f 89 c4 00 00 00    	jns    801c68 <spawn+0x424>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	e9 67 01 00 00       	jmp    801d12 <spawn+0x4ce>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bab:	83 ec 04             	sub    $0x4,%esp
  801bae:	6a 07                	push   $0x7
  801bb0:	68 00 00 40 00       	push   $0x400000
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 78 f3 ff ff       	call   800f34 <sys_page_alloc>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 41 01 00 00    	js     801d08 <spawn+0x4c4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bc7:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801bca:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801bd0:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bd3:	50                   	push   %eax
  801bd4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bda:	e8 0f f9 ff ff       	call   8014ee <seek>
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	0f 88 22 01 00 00    	js     801d0c <spawn+0x4c8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bea:	83 ec 04             	sub    $0x4,%esp
  801bed:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bf3:	29 f8                	sub    %edi,%eax
  801bf5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bfa:	76 05                	jbe    801c01 <spawn+0x3bd>
  801bfc:	b8 00 10 00 00       	mov    $0x1000,%eax
  801c01:	50                   	push   %eax
  801c02:	68 00 00 40 00       	push   $0x400000
  801c07:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c0d:	e8 05 f8 ff ff       	call   801417 <readn>
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 88 f3 00 00 00    	js     801d10 <spawn+0x4cc>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	53                   	push   %ebx
  801c21:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801c27:	57                   	push   %edi
  801c28:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c2e:	68 00 00 40 00       	push   $0x400000
  801c33:	6a 00                	push   $0x0
  801c35:	e8 1e f3 ff ff       	call   800f58 <sys_page_map>
  801c3a:	83 c4 20             	add    $0x20,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	79 15                	jns    801c56 <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  801c41:	50                   	push   %eax
  801c42:	68 7d 2b 80 00       	push   $0x802b7d
  801c47:	68 28 01 00 00       	push   $0x128
  801c4c:	68 71 2b 80 00       	push   $0x802b71
  801c51:	e8 ce e7 ff ff       	call   800424 <_panic>
			sys_page_unmap(0, UTEMP);
  801c56:	83 ec 08             	sub    $0x8,%esp
  801c59:	68 00 00 40 00       	push   $0x400000
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 19 f3 ff ff       	call   800f7e <sys_page_unmap>
  801c65:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c68:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c6e:	89 f7                	mov    %esi,%edi
  801c70:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801c76:	0f 82 ff fe ff ff    	jb     801b7b <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c7c:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801c82:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c89:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c8f:	7e 0c                	jle    801c9d <spawn+0x459>
  801c91:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801c98:	e9 54 fe ff ff       	jmp    801af1 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ca6:	e8 a8 f5 ff ff       	call   801253 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cab:	83 c4 08             	add    $0x8,%esp
  801cae:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801cb4:	50                   	push   %eax
  801cb5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cbb:	e8 04 f3 ff ff       	call   800fc4 <sys_env_set_trapframe>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	79 15                	jns    801cdc <spawn+0x498>
		panic("sys_env_set_trapframe: %e", r);
  801cc7:	50                   	push   %eax
  801cc8:	68 9a 2b 80 00       	push   $0x802b9a
  801ccd:	68 89 00 00 00       	push   $0x89
  801cd2:	68 71 2b 80 00       	push   $0x802b71
  801cd7:	e8 48 e7 ff ff       	call   800424 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	6a 02                	push   $0x2
  801ce1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ce7:	e8 b5 f2 ff ff       	call   800fa1 <sys_env_set_status>
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	79 52                	jns    801d45 <spawn+0x501>
		panic("sys_env_set_status: %e", r);
  801cf3:	50                   	push   %eax
  801cf4:	68 b4 2b 80 00       	push   $0x802bb4
  801cf9:	68 8c 00 00 00       	push   $0x8c
  801cfe:	68 71 2b 80 00       	push   $0x802b71
  801d03:	e8 1c e7 ff ff       	call   800424 <_panic>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	eb 06                	jmp    801d12 <spawn+0x4ce>
  801d0c:	89 c3                	mov    %eax,%ebx
  801d0e:	eb 02                	jmp    801d12 <spawn+0x4ce>
  801d10:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d1b:	e8 a7 f1 ff ff       	call   800ec7 <sys_env_destroy>
	close(fd);
  801d20:	83 c4 04             	add    $0x4,%esp
  801d23:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d29:	e8 25 f5 ff ff       	call   801253 <close>
	return r;
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d37:	eb 0c                	jmp    801d45 <spawn+0x501>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d39:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d3f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d45:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d53:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801d5a:	ff ff ff 
  801d5d:	eb e6                	jmp    801d45 <spawn+0x501>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d5f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801d65:	eb de                	jmp    801d45 <spawn+0x501>

00801d67 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d6f:	8d 45 14             	lea    0x14(%ebp),%eax
  801d72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d76:	74 5f                	je     801dd7 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d78:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d7d:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d7e:	89 c2                	mov    %eax,%edx
  801d80:	83 c0 04             	add    $0x4,%eax
  801d83:	83 3a 00             	cmpl   $0x0,(%edx)
  801d86:	75 f5                	jne    801d7d <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d88:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d8f:	83 e0 f0             	and    $0xfffffff0,%eax
  801d92:	29 c4                	sub    %eax,%esp
  801d94:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d98:	83 e0 f0             	and    $0xfffffff0,%eax
  801d9b:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d9d:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d9f:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801da6:	00 

	va_start(vl, arg0);
  801da7:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801daa:	89 ce                	mov    %ecx,%esi
  801dac:	85 c9                	test   %ecx,%ecx
  801dae:	74 14                	je     801dc4 <spawnl+0x5d>
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801db5:	40                   	inc    %eax
  801db6:	89 d1                	mov    %edx,%ecx
  801db8:	83 c2 04             	add    $0x4,%edx
  801dbb:	8b 09                	mov    (%ecx),%ecx
  801dbd:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801dc0:	39 f0                	cmp    %esi,%eax
  801dc2:	72 f1                	jb     801db5 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	53                   	push   %ebx
  801dc8:	ff 75 08             	pushl  0x8(%ebp)
  801dcb:	e8 74 fa ff ff       	call   801844 <spawn>
}
  801dd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dd7:	83 ec 20             	sub    $0x20,%esp
  801dda:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801dde:	83 e0 f0             	and    $0xfffffff0,%eax
  801de1:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801de3:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801de5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801dec:	eb d6                	jmp    801dc4 <spawnl+0x5d>
	...

00801df0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	ff 75 08             	pushl  0x8(%ebp)
  801dfe:	e8 81 f2 ff ff       	call   801084 <fd2data>
  801e03:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e05:	83 c4 08             	add    $0x8,%esp
  801e08:	68 f4 2b 80 00       	push   $0x802bf4
  801e0d:	56                   	push   %esi
  801e0e:	e8 9f ec ff ff       	call   800ab2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e13:	8b 43 04             	mov    0x4(%ebx),%eax
  801e16:	2b 03                	sub    (%ebx),%eax
  801e18:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e1e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e25:	00 00 00 
	stat->st_dev = &devpipe;
  801e28:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  801e2f:	47 80 00 
	return 0;
}
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
  801e37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e48:	53                   	push   %ebx
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 2e f1 ff ff       	call   800f7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e50:	89 1c 24             	mov    %ebx,(%esp)
  801e53:	e8 2c f2 ff ff       	call   801084 <fd2data>
  801e58:	83 c4 08             	add    $0x8,%esp
  801e5b:	50                   	push   %eax
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 1b f1 ff ff       	call   800f7e <sys_page_unmap>
}
  801e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	57                   	push   %edi
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 1c             	sub    $0x1c,%esp
  801e71:	89 c7                	mov    %eax,%edi
  801e73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e76:	a1 90 67 80 00       	mov    0x806790,%eax
  801e7b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	57                   	push   %edi
  801e82:	e8 bd 04 00 00       	call   802344 <pageref>
  801e87:	89 c6                	mov    %eax,%esi
  801e89:	83 c4 04             	add    $0x4,%esp
  801e8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e8f:	e8 b0 04 00 00       	call   802344 <pageref>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	39 c6                	cmp    %eax,%esi
  801e99:	0f 94 c0             	sete   %al
  801e9c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e9f:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801ea5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ea8:	39 cb                	cmp    %ecx,%ebx
  801eaa:	75 08                	jne    801eb4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801eb4:	83 f8 01             	cmp    $0x1,%eax
  801eb7:	75 bd                	jne    801e76 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb9:	8b 42 58             	mov    0x58(%edx),%eax
  801ebc:	6a 01                	push   $0x1
  801ebe:	50                   	push   %eax
  801ebf:	53                   	push   %ebx
  801ec0:	68 fb 2b 80 00       	push   $0x802bfb
  801ec5:	e8 32 e6 ff ff       	call   8004fc <cprintf>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	eb a7                	jmp    801e76 <_pipeisclosed+0xe>

00801ecf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	57                   	push   %edi
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 28             	sub    $0x28,%esp
  801ed8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801edb:	56                   	push   %esi
  801edc:	e8 a3 f1 ff ff       	call   801084 <fd2data>
  801ee1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eea:	75 4a                	jne    801f36 <devpipe_write+0x67>
  801eec:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef1:	eb 56                	jmp    801f49 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef3:	89 da                	mov    %ebx,%edx
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	e8 6c ff ff ff       	call   801e68 <_pipeisclosed>
  801efc:	85 c0                	test   %eax,%eax
  801efe:	75 4d                	jne    801f4d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f00:	e8 08 f0 ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f05:	8b 43 04             	mov    0x4(%ebx),%eax
  801f08:	8b 13                	mov    (%ebx),%edx
  801f0a:	83 c2 20             	add    $0x20,%edx
  801f0d:	39 d0                	cmp    %edx,%eax
  801f0f:	73 e2                	jae    801ef3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f11:	89 c2                	mov    %eax,%edx
  801f13:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f19:	79 05                	jns    801f20 <devpipe_write+0x51>
  801f1b:	4a                   	dec    %edx
  801f1c:	83 ca e0             	or     $0xffffffe0,%edx
  801f1f:	42                   	inc    %edx
  801f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f23:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801f26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f2a:	40                   	inc    %eax
  801f2b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2e:	47                   	inc    %edi
  801f2f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801f32:	77 07                	ja     801f3b <devpipe_write+0x6c>
  801f34:	eb 13                	jmp    801f49 <devpipe_write+0x7a>
  801f36:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f3b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f3e:	8b 13                	mov    (%ebx),%edx
  801f40:	83 c2 20             	add    $0x20,%edx
  801f43:	39 d0                	cmp    %edx,%eax
  801f45:	73 ac                	jae    801ef3 <devpipe_write+0x24>
  801f47:	eb c8                	jmp    801f11 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	eb 05                	jmp    801f52 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 18             	sub    $0x18,%esp
  801f63:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f66:	57                   	push   %edi
  801f67:	e8 18 f1 ff ff       	call   801084 <fd2data>
  801f6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f75:	75 44                	jne    801fbb <devpipe_read+0x61>
  801f77:	be 00 00 00 00       	mov    $0x0,%esi
  801f7c:	eb 4f                	jmp    801fcd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f7e:	89 f0                	mov    %esi,%eax
  801f80:	eb 54                	jmp    801fd6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f82:	89 da                	mov    %ebx,%edx
  801f84:	89 f8                	mov    %edi,%eax
  801f86:	e8 dd fe ff ff       	call   801e68 <_pipeisclosed>
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	75 42                	jne    801fd1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f8f:	e8 79 ef ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f94:	8b 03                	mov    (%ebx),%eax
  801f96:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f99:	74 e7                	je     801f82 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f9b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fa0:	79 05                	jns    801fa7 <devpipe_read+0x4d>
  801fa2:	48                   	dec    %eax
  801fa3:	83 c8 e0             	or     $0xffffffe0,%eax
  801fa6:	40                   	inc    %eax
  801fa7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801fab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fae:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fb1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb3:	46                   	inc    %esi
  801fb4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801fb7:	77 07                	ja     801fc0 <devpipe_read+0x66>
  801fb9:	eb 12                	jmp    801fcd <devpipe_read+0x73>
  801fbb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801fc0:	8b 03                	mov    (%ebx),%eax
  801fc2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fc5:	75 d4                	jne    801f9b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	75 b3                	jne    801f7e <devpipe_read+0x24>
  801fcb:	eb b5                	jmp    801f82 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fcd:	89 f0                	mov    %esi,%eax
  801fcf:	eb 05                	jmp    801fd6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 28             	sub    $0x28,%esp
  801fe7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fed:	50                   	push   %eax
  801fee:	e8 a9 f0 ff ff       	call   80109c <fd_alloc>
  801ff3:	89 c3                	mov    %eax,%ebx
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	0f 88 24 01 00 00    	js     802124 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	68 07 04 00 00       	push   $0x407
  802008:	ff 75 e4             	pushl  -0x1c(%ebp)
  80200b:	6a 00                	push   $0x0
  80200d:	e8 22 ef ff ff       	call   800f34 <sys_page_alloc>
  802012:	89 c3                	mov    %eax,%ebx
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 88 05 01 00 00    	js     802124 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80201f:	83 ec 0c             	sub    $0xc,%esp
  802022:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	e8 71 f0 ff ff       	call   80109c <fd_alloc>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	85 c0                	test   %eax,%eax
  802032:	0f 88 dc 00 00 00    	js     802114 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	68 07 04 00 00       	push   $0x407
  802040:	ff 75 e0             	pushl  -0x20(%ebp)
  802043:	6a 00                	push   $0x0
  802045:	e8 ea ee ff ff       	call   800f34 <sys_page_alloc>
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	85 c0                	test   %eax,%eax
  802051:	0f 88 bd 00 00 00    	js     802114 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802057:	83 ec 0c             	sub    $0xc,%esp
  80205a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80205d:	e8 22 f0 ff ff       	call   801084 <fd2data>
  802062:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802064:	83 c4 0c             	add    $0xc,%esp
  802067:	68 07 04 00 00       	push   $0x407
  80206c:	50                   	push   %eax
  80206d:	6a 00                	push   $0x0
  80206f:	e8 c0 ee ff ff       	call   800f34 <sys_page_alloc>
  802074:	89 c3                	mov    %eax,%ebx
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	0f 88 83 00 00 00    	js     802104 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	ff 75 e0             	pushl  -0x20(%ebp)
  802087:	e8 f8 ef ff ff       	call   801084 <fd2data>
  80208c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802093:	50                   	push   %eax
  802094:	6a 00                	push   $0x0
  802096:	56                   	push   %esi
  802097:	6a 00                	push   $0x0
  802099:	e8 ba ee ff ff       	call   800f58 <sys_page_map>
  80209e:	89 c3                	mov    %eax,%ebx
  8020a0:	83 c4 20             	add    $0x20,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 4f                	js     8020f6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020a7:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020bc:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020d7:	e8 98 ef ff ff       	call   801074 <fd2num>
  8020dc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020de:	83 c4 04             	add    $0x4,%esp
  8020e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8020e4:	e8 8b ef ff ff       	call   801074 <fd2num>
  8020e9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f4:	eb 2e                	jmp    802124 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8020f6:	83 ec 08             	sub    $0x8,%esp
  8020f9:	56                   	push   %esi
  8020fa:	6a 00                	push   $0x0
  8020fc:	e8 7d ee ff ff       	call   800f7e <sys_page_unmap>
  802101:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802104:	83 ec 08             	sub    $0x8,%esp
  802107:	ff 75 e0             	pushl  -0x20(%ebp)
  80210a:	6a 00                	push   $0x0
  80210c:	e8 6d ee ff ff       	call   800f7e <sys_page_unmap>
  802111:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802114:	83 ec 08             	sub    $0x8,%esp
  802117:	ff 75 e4             	pushl  -0x1c(%ebp)
  80211a:	6a 00                	push   $0x0
  80211c:	e8 5d ee ff ff       	call   800f7e <sys_page_unmap>
  802121:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802124:	89 d8                	mov    %ebx,%eax
  802126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802129:	5b                   	pop    %ebx
  80212a:	5e                   	pop    %esi
  80212b:	5f                   	pop    %edi
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802137:	50                   	push   %eax
  802138:	ff 75 08             	pushl  0x8(%ebp)
  80213b:	e8 cf ef ff ff       	call   80110f <fd_lookup>
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	85 c0                	test   %eax,%eax
  802145:	78 18                	js     80215f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	e8 32 ef ff ff       	call   801084 <fd2data>
	return _pipeisclosed(fd, p);
  802152:	89 c2                	mov    %eax,%edx
  802154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802157:	e8 0c fd ff ff       	call   801e68 <_pipeisclosed>
  80215c:	83 c4 10             	add    $0x10,%esp
}
  80215f:	c9                   	leave  
  802160:	c3                   	ret    
  802161:	00 00                	add    %al,(%eax)
	...

00802164 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	57                   	push   %edi
  802168:	56                   	push   %esi
  802169:	53                   	push   %ebx
  80216a:	83 ec 0c             	sub    $0xc,%esp
  80216d:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802170:	85 c0                	test   %eax,%eax
  802172:	75 16                	jne    80218a <wait+0x26>
  802174:	68 13 2c 80 00       	push   $0x802c13
  802179:	68 25 2b 80 00       	push   $0x802b25
  80217e:	6a 09                	push   $0x9
  802180:	68 1e 2c 80 00       	push   $0x802c1e
  802185:	e8 9a e2 ff ff       	call   800424 <_panic>
	e = &envs[ENVX(envid)];
  80218a:	89 c6                	mov    %eax,%esi
  80218c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802192:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802199:	89 f2                	mov    %esi,%edx
  80219b:	c1 e2 07             	shl    $0x7,%edx
  80219e:	29 ca                	sub    %ecx,%edx
  8021a0:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  8021a6:	8b 7a 40             	mov    0x40(%edx),%edi
  8021a9:	39 c7                	cmp    %eax,%edi
  8021ab:	75 37                	jne    8021e4 <wait+0x80>
  8021ad:	89 f0                	mov    %esi,%eax
  8021af:	c1 e0 07             	shl    $0x7,%eax
  8021b2:	29 c8                	sub    %ecx,%eax
  8021b4:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  8021b9:	8b 40 50             	mov    0x50(%eax),%eax
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	74 24                	je     8021e4 <wait+0x80>
  8021c0:	c1 e6 07             	shl    $0x7,%esi
  8021c3:	29 ce                	sub    %ecx,%esi
  8021c5:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  8021cb:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  8021d1:	e8 37 ed ff ff       	call   800f0d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021d6:	8b 43 40             	mov    0x40(%ebx),%eax
  8021d9:	39 f8                	cmp    %edi,%eax
  8021db:	75 07                	jne    8021e4 <wait+0x80>
  8021dd:	8b 46 50             	mov    0x50(%esi),%eax
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	75 ed                	jne    8021d1 <wait+0x6d>
		sys_yield();
}
  8021e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	57                   	push   %edi
  8021f0:	56                   	push   %esi
  8021f1:	53                   	push   %ebx
  8021f2:	83 ec 0c             	sub    $0xc,%esp
  8021f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8021fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8021fe:	56                   	push   %esi
  8021ff:	53                   	push   %ebx
  802200:	57                   	push   %edi
  802201:	68 29 2c 80 00       	push   $0x802c29
  802206:	e8 f1 e2 ff ff       	call   8004fc <cprintf>
	int r;
	if (pg != NULL) {
  80220b:	83 c4 10             	add    $0x10,%esp
  80220e:	85 db                	test   %ebx,%ebx
  802210:	74 28                	je     80223a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  802212:	83 ec 0c             	sub    $0xc,%esp
  802215:	68 39 2c 80 00       	push   $0x802c39
  80221a:	e8 dd e2 ff ff       	call   8004fc <cprintf>
		r = sys_ipc_recv(pg);
  80221f:	89 1c 24             	mov    %ebx,(%esp)
  802222:	e8 08 ee ff ff       	call   80102f <sys_ipc_recv>
  802227:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  802229:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  802230:	e8 c7 e2 ff ff       	call   8004fc <cprintf>
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	eb 12                	jmp    80224c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80223a:	83 ec 0c             	sub    $0xc,%esp
  80223d:	68 00 00 c0 ee       	push   $0xeec00000
  802242:	e8 e8 ed ff ff       	call   80102f <sys_ipc_recv>
  802247:	89 c3                	mov    %eax,%ebx
  802249:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  80224c:	85 db                	test   %ebx,%ebx
  80224e:	75 26                	jne    802276 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802250:	85 ff                	test   %edi,%edi
  802252:	74 0a                	je     80225e <ipc_recv+0x72>
  802254:	a1 90 67 80 00       	mov    0x806790,%eax
  802259:	8b 40 74             	mov    0x74(%eax),%eax
  80225c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80225e:	85 f6                	test   %esi,%esi
  802260:	74 0a                	je     80226c <ipc_recv+0x80>
  802262:	a1 90 67 80 00       	mov    0x806790,%eax
  802267:	8b 40 78             	mov    0x78(%eax),%eax
  80226a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  80226c:	a1 90 67 80 00       	mov    0x806790,%eax
  802271:	8b 58 70             	mov    0x70(%eax),%ebx
  802274:	eb 14                	jmp    80228a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802276:	85 ff                	test   %edi,%edi
  802278:	74 06                	je     802280 <ipc_recv+0x94>
  80227a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  802280:	85 f6                	test   %esi,%esi
  802282:	74 06                	je     80228a <ipc_recv+0x9e>
  802284:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  80228a:	89 d8                	mov    %ebx,%eax
  80228c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	c9                   	leave  
  802293:	c3                   	ret    

00802294 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	57                   	push   %edi
  802298:	56                   	push   %esi
  802299:	53                   	push   %ebx
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a3:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8022a6:	85 db                	test   %ebx,%ebx
  8022a8:	75 25                	jne    8022cf <ipc_send+0x3b>
  8022aa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8022af:	eb 1e                	jmp    8022cf <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8022b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b4:	75 07                	jne    8022bd <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8022b6:	e8 52 ec ff ff       	call   800f0d <sys_yield>
  8022bb:	eb 12                	jmp    8022cf <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8022bd:	50                   	push   %eax
  8022be:	68 40 2c 80 00       	push   $0x802c40
  8022c3:	6a 45                	push   $0x45
  8022c5:	68 53 2c 80 00       	push   $0x802c53
  8022ca:	e8 55 e1 ff ff       	call   800424 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8022cf:	56                   	push   %esi
  8022d0:	53                   	push   %ebx
  8022d1:	57                   	push   %edi
  8022d2:	ff 75 08             	pushl  0x8(%ebp)
  8022d5:	e8 30 ed ff ff       	call   80100a <sys_ipc_try_send>
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	75 d0                	jne    8022b1 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8022e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	53                   	push   %ebx
  8022ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8022f0:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8022f6:	74 22                	je     80231a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022f8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8022fd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802304:	89 c2                	mov    %eax,%edx
  802306:	c1 e2 07             	shl    $0x7,%edx
  802309:	29 ca                	sub    %ecx,%edx
  80230b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802311:	8b 52 50             	mov    0x50(%edx),%edx
  802314:	39 da                	cmp    %ebx,%edx
  802316:	75 1d                	jne    802335 <ipc_find_env+0x4c>
  802318:	eb 05                	jmp    80231f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80231a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80231f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802326:	c1 e0 07             	shl    $0x7,%eax
  802329:	29 d0                	sub    %edx,%eax
  80232b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802330:	8b 40 40             	mov    0x40(%eax),%eax
  802333:	eb 0c                	jmp    802341 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802335:	40                   	inc    %eax
  802336:	3d 00 04 00 00       	cmp    $0x400,%eax
  80233b:	75 c0                	jne    8022fd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80233d:	66 b8 00 00          	mov    $0x0,%ax
}
  802341:	5b                   	pop    %ebx
  802342:	c9                   	leave  
  802343:	c3                   	ret    

00802344 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234a:	89 c2                	mov    %eax,%edx
  80234c:	c1 ea 16             	shr    $0x16,%edx
  80234f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802356:	f6 c2 01             	test   $0x1,%dl
  802359:	74 1e                	je     802379 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235b:	c1 e8 0c             	shr    $0xc,%eax
  80235e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802365:	a8 01                	test   $0x1,%al
  802367:	74 17                	je     802380 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802369:	c1 e8 0c             	shr    $0xc,%eax
  80236c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802373:	ef 
  802374:	0f b7 c0             	movzwl %ax,%eax
  802377:	eb 0c                	jmp    802385 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
  80237e:	eb 05                	jmp    802385 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802380:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802385:	c9                   	leave  
  802386:	c3                   	ret    
	...

00802388 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	57                   	push   %edi
  80238c:	56                   	push   %esi
  80238d:	83 ec 10             	sub    $0x10,%esp
  802390:	8b 7d 08             	mov    0x8(%ebp),%edi
  802393:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802396:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802399:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80239c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80239f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	75 2e                	jne    8023d4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023a6:	39 f1                	cmp    %esi,%ecx
  8023a8:	77 5a                	ja     802404 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023aa:	85 c9                	test   %ecx,%ecx
  8023ac:	75 0b                	jne    8023b9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f1                	div    %ecx
  8023b7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023b9:	31 d2                	xor    %edx,%edx
  8023bb:	89 f0                	mov    %esi,%eax
  8023bd:	f7 f1                	div    %ecx
  8023bf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023c1:	89 f8                	mov    %edi,%eax
  8023c3:	f7 f1                	div    %ecx
  8023c5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023c7:	89 f8                	mov    %edi,%eax
  8023c9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023cb:	83 c4 10             	add    $0x10,%esp
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	c9                   	leave  
  8023d1:	c3                   	ret    
  8023d2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023d4:	39 f0                	cmp    %esi,%eax
  8023d6:	77 1c                	ja     8023f4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023d8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8023db:	83 f7 1f             	xor    $0x1f,%edi
  8023de:	75 3c                	jne    80241c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023e0:	39 f0                	cmp    %esi,%eax
  8023e2:	0f 82 90 00 00 00    	jb     802478 <__udivdi3+0xf0>
  8023e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023eb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8023ee:	0f 86 84 00 00 00    	jbe    802478 <__udivdi3+0xf0>
  8023f4:	31 f6                	xor    %esi,%esi
  8023f6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023f8:	89 f8                	mov    %edi,%eax
  8023fa:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023fc:	83 c4 10             	add    $0x10,%esp
  8023ff:	5e                   	pop    %esi
  802400:	5f                   	pop    %edi
  802401:	c9                   	leave  
  802402:	c3                   	ret    
  802403:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802404:	89 f2                	mov    %esi,%edx
  802406:	89 f8                	mov    %edi,%eax
  802408:	f7 f1                	div    %ecx
  80240a:	89 c7                	mov    %eax,%edi
  80240c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80240e:	89 f8                	mov    %edi,%eax
  802410:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802412:	83 c4 10             	add    $0x10,%esp
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	c9                   	leave  
  802418:	c3                   	ret    
  802419:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80241c:	89 f9                	mov    %edi,%ecx
  80241e:	d3 e0                	shl    %cl,%eax
  802420:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802423:	b8 20 00 00 00       	mov    $0x20,%eax
  802428:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80242a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80242d:	88 c1                	mov    %al,%cl
  80242f:	d3 ea                	shr    %cl,%edx
  802431:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802434:	09 ca                	or     %ecx,%edx
  802436:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802439:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80243c:	89 f9                	mov    %edi,%ecx
  80243e:	d3 e2                	shl    %cl,%edx
  802440:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802443:	89 f2                	mov    %esi,%edx
  802445:	88 c1                	mov    %al,%cl
  802447:	d3 ea                	shr    %cl,%edx
  802449:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	d3 e2                	shl    %cl,%edx
  802452:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802455:	88 c1                	mov    %al,%cl
  802457:	d3 ee                	shr    %cl,%esi
  802459:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80245b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80245e:	89 f0                	mov    %esi,%eax
  802460:	89 ca                	mov    %ecx,%edx
  802462:	f7 75 ec             	divl   -0x14(%ebp)
  802465:	89 d1                	mov    %edx,%ecx
  802467:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802469:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80246c:	39 d1                	cmp    %edx,%ecx
  80246e:	72 28                	jb     802498 <__udivdi3+0x110>
  802470:	74 1a                	je     80248c <__udivdi3+0x104>
  802472:	89 f7                	mov    %esi,%edi
  802474:	31 f6                	xor    %esi,%esi
  802476:	eb 80                	jmp    8023f8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802478:	31 f6                	xor    %esi,%esi
  80247a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80247f:	89 f8                	mov    %edi,%eax
  802481:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802483:	83 c4 10             	add    $0x10,%esp
  802486:	5e                   	pop    %esi
  802487:	5f                   	pop    %edi
  802488:	c9                   	leave  
  802489:	c3                   	ret    
  80248a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80248c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80248f:	89 f9                	mov    %edi,%ecx
  802491:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802493:	39 c2                	cmp    %eax,%edx
  802495:	73 db                	jae    802472 <__udivdi3+0xea>
  802497:	90                   	nop
		{
		  q0--;
  802498:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80249b:	31 f6                	xor    %esi,%esi
  80249d:	e9 56 ff ff ff       	jmp    8023f8 <__udivdi3+0x70>
	...

008024a4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	83 ec 20             	sub    $0x20,%esp
  8024ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8024af:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8024b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8024b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8024c1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024c3:	85 ff                	test   %edi,%edi
  8024c5:	75 15                	jne    8024dc <__umoddi3+0x38>
    {
      if (d0 > n1)
  8024c7:	39 f1                	cmp    %esi,%ecx
  8024c9:	0f 86 99 00 00 00    	jbe    802568 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024cf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8024d1:	89 d0                	mov    %edx,%eax
  8024d3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d5:	83 c4 20             	add    $0x20,%esp
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	c9                   	leave  
  8024db:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	0f 87 a4 00 00 00    	ja     802588 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024e4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8024e7:	83 f0 1f             	xor    $0x1f,%eax
  8024ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8024ed:	0f 84 a1 00 00 00    	je     802594 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024f3:	89 f8                	mov    %edi,%eax
  8024f5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8024f8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024fa:	bf 20 00 00 00       	mov    $0x20,%edi
  8024ff:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802502:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 ea                	shr    %cl,%edx
  802509:	09 c2                	or     %eax,%edx
  80250b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802511:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802514:	d3 e0                	shl    %cl,%eax
  802516:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802519:	89 f2                	mov    %esi,%edx
  80251b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80251d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802520:	d3 e0                	shl    %cl,%eax
  802522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802525:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802528:	89 f9                	mov    %edi,%ecx
  80252a:	d3 e8                	shr    %cl,%eax
  80252c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80252e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802530:	89 f2                	mov    %esi,%edx
  802532:	f7 75 f0             	divl   -0x10(%ebp)
  802535:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802537:	f7 65 f4             	mull   -0xc(%ebp)
  80253a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80253d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80253f:	39 d6                	cmp    %edx,%esi
  802541:	72 71                	jb     8025b4 <__umoddi3+0x110>
  802543:	74 7f                	je     8025c4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802545:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802548:	29 c8                	sub    %ecx,%eax
  80254a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80254c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80254f:	d3 e8                	shr    %cl,%eax
  802551:	89 f2                	mov    %esi,%edx
  802553:	89 f9                	mov    %edi,%ecx
  802555:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802557:	09 d0                	or     %edx,%eax
  802559:	89 f2                	mov    %esi,%edx
  80255b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80255e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802560:	83 c4 20             	add    $0x20,%esp
  802563:	5e                   	pop    %esi
  802564:	5f                   	pop    %edi
  802565:	c9                   	leave  
  802566:	c3                   	ret    
  802567:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802568:	85 c9                	test   %ecx,%ecx
  80256a:	75 0b                	jne    802577 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80256c:	b8 01 00 00 00       	mov    $0x1,%eax
  802571:	31 d2                	xor    %edx,%edx
  802573:	f7 f1                	div    %ecx
  802575:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802577:	89 f0                	mov    %esi,%eax
  802579:	31 d2                	xor    %edx,%edx
  80257b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80257d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802580:	f7 f1                	div    %ecx
  802582:	e9 4a ff ff ff       	jmp    8024d1 <__umoddi3+0x2d>
  802587:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802588:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80258a:	83 c4 20             	add    $0x20,%esp
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	c9                   	leave  
  802590:	c3                   	ret    
  802591:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802594:	39 f7                	cmp    %esi,%edi
  802596:	72 05                	jb     80259d <__umoddi3+0xf9>
  802598:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80259b:	77 0c                	ja     8025a9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80259d:	89 f2                	mov    %esi,%edx
  80259f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025a2:	29 c8                	sub    %ecx,%eax
  8025a4:	19 fa                	sbb    %edi,%edx
  8025a6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025ac:	83 c4 20             	add    $0x20,%esp
  8025af:	5e                   	pop    %esi
  8025b0:	5f                   	pop    %edi
  8025b1:	c9                   	leave  
  8025b2:	c3                   	ret    
  8025b3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025b4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8025b7:	89 c1                	mov    %eax,%ecx
  8025b9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8025bc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8025bf:	eb 84                	jmp    802545 <__umoddi3+0xa1>
  8025c1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025c4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8025c7:	72 eb                	jb     8025b4 <__umoddi3+0x110>
  8025c9:	89 f2                	mov    %esi,%edx
  8025cb:	e9 75 ff ff ff       	jmp    802545 <__umoddi3+0xa1>
