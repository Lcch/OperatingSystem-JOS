
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
  800075:	68 20 26 80 00       	push   $0x802620
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
  8000a4:	68 e8 26 80 00       	push   $0x8026e8
  8000a9:	e8 4e 04 00 00       	call   8004fc <cprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	eb 10                	jmp    8000c3 <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	68 2f 26 80 00       	push   $0x80262f
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
  8000e0:	68 24 27 80 00       	push   $0x802724
  8000e5:	e8 12 04 00 00       	call   8004fc <cprintf>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	eb 10                	jmp    8000ff <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 46 26 80 00       	push   $0x802646
  8000f7:	e8 00 04 00 00       	call   8004fc <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 5c 26 80 00       	push   $0x80265c
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
  80012a:	68 68 26 80 00       	push   $0x802668
  80012f:	53                   	push   %ebx
  800130:	e8 9a 09 00 00       	call   800acf <strcat>
		strcat(args, argv[i]);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff 34 b7             	pushl  (%edi,%esi,4)
  80013b:	53                   	push   %ebx
  80013c:	e8 8e 09 00 00       	call   800acf <strcat>
		strcat(args, "'");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	68 69 26 80 00       	push   $0x802669
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
  800162:	68 6b 26 80 00       	push   $0x80266b
  800167:	e8 90 03 00 00       	call   8004fc <cprintf>

	cprintf("init: running sh\n");
  80016c:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
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
  800191:	68 81 26 80 00       	push   $0x802681
  800196:	6a 37                	push   $0x37
  800198:	68 8e 26 80 00       	push   $0x80268e
  80019d:	e8 82 02 00 00       	call   800424 <_panic>
	if (r != 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	74 12                	je     8001b8 <umain+0x152>
		panic("first opencons used fd %d", r);
  8001a6:	50                   	push   %eax
  8001a7:	68 9a 26 80 00       	push   $0x80269a
  8001ac:	6a 39                	push   $0x39
  8001ae:	68 8e 26 80 00       	push   $0x80268e
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
  8001cc:	68 b4 26 80 00       	push   $0x8026b4
  8001d1:	6a 3b                	push   $0x3b
  8001d3:	68 8e 26 80 00       	push   $0x80268e
  8001d8:	e8 47 02 00 00       	call   800424 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	68 bc 26 80 00       	push   $0x8026bc
  8001e5:	e8 12 03 00 00       	call   8004fc <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001ea:	83 c4 0c             	add    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	68 d0 26 80 00       	push   $0x8026d0
  8001f4:	68 cf 26 80 00       	push   $0x8026cf
  8001f9:	e8 d6 1b 00 00       	call   801dd4 <spawnl>
		if (r < 0) {
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	85 c0                	test   %eax,%eax
  800203:	79 13                	jns    800218 <umain+0x1b2>
			cprintf("init: spawn sh: %e\n", r);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	50                   	push   %eax
  800209:	68 d3 26 80 00       	push   $0x8026d3
  80020e:	e8 e9 02 00 00       	call   8004fc <cprintf>
			continue;
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	eb c5                	jmp    8001dd <umain+0x177>
		}
		wait(r);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	e8 af 1f 00 00       	call   8021d0 <wait>
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
  800238:	68 53 27 80 00       	push   $0x802753
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
  800442:	68 6c 27 80 00       	push   $0x80276c
  800447:	e8 b0 00 00 00       	call   8004fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	56                   	push   %esi
  800450:	ff 75 10             	pushl  0x10(%ebp)
  800453:	e8 53 00 00 00       	call   8004ab <vcprintf>
	cprintf("\n");
  800458:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
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
  800564:	e8 5b 1e 00 00       	call   8023c4 <__udivdi3>
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
  8005a0:	e8 3b 1f 00 00       	call   8024e0 <__umoddi3>
  8005a5:	83 c4 14             	add    $0x14,%esp
  8005a8:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
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
  8006ec:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
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
  800798:	8b 04 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%eax
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	75 1a                	jne    8007bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8007a3:	52                   	push   %edx
  8007a4:	68 a7 27 80 00       	push   $0x8027a7
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
  8007be:	68 71 2b 80 00       	push   $0x802b71
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
  8007f4:	c7 45 d0 a0 27 80 00 	movl   $0x8027a0,-0x30(%ebp)
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
  800e62:	68 9f 2a 80 00       	push   $0x802a9f
  800e67:	6a 42                	push   $0x42
  800e69:	68 bc 2a 80 00       	push   $0x802abc
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
  801196:	8b 14 85 48 2b 80 00 	mov    0x802b48(,%eax,4),%edx
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
  8011ae:	68 cc 2a 80 00       	push   $0x802acc
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
  8013de:	68 0d 2b 80 00       	push   $0x802b0d
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
  8014b5:	68 29 2b 80 00       	push   $0x802b29
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
  801560:	68 ec 2a 80 00       	push   $0x802aec
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
  801617:	e8 78 01 00 00       	call   801794 <open>
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
  801663:	e8 ba 0c 00 00       	call   802322 <ipc_find_env>
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
  80167e:	e8 4a 0c 00 00       	call   8022cd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801683:	83 c4 0c             	add    $0xc,%esp
  801686:	6a 00                	push   $0x0
  801688:	56                   	push   %esi
  801689:	6a 00                	push   $0x0
  80168b:	e8 c8 0b 00 00       	call   802258 <ipc_recv>
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
  8016bd:	78 2c                	js     8016eb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	68 00 70 80 00       	push   $0x807000
  8016c7:	53                   	push   %ebx
  8016c8:	e8 e5 f3 ff ff       	call   800ab2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cd:	a1 80 70 80 00       	mov    0x807080,%eax
  8016d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d8:	a1 84 70 80 00       	mov    0x807084,%eax
  8016dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fc:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 06 00 00 00       	mov    $0x6,%eax
  80170b:	e8 3c ff ff ff       	call   80164c <fsipc>
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 40 0c             	mov    0xc(%eax),%eax
  801720:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801725:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 03 00 00 00       	mov    $0x3,%eax
  801735:	e8 12 ff ff ff       	call   80164c <fsipc>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 4b                	js     80178b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801740:	39 c6                	cmp    %eax,%esi
  801742:	73 16                	jae    80175a <devfile_read+0x48>
  801744:	68 58 2b 80 00       	push   $0x802b58
  801749:	68 5f 2b 80 00       	push   $0x802b5f
  80174e:	6a 7d                	push   $0x7d
  801750:	68 74 2b 80 00       	push   $0x802b74
  801755:	e8 ca ec ff ff       	call   800424 <_panic>
	assert(r <= PGSIZE);
  80175a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80175f:	7e 16                	jle    801777 <devfile_read+0x65>
  801761:	68 7f 2b 80 00       	push   $0x802b7f
  801766:	68 5f 2b 80 00       	push   $0x802b5f
  80176b:	6a 7e                	push   $0x7e
  80176d:	68 74 2b 80 00       	push   $0x802b74
  801772:	e8 ad ec ff ff       	call   800424 <_panic>
	memmove(buf, &fsipcbuf, r);
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	50                   	push   %eax
  80177b:	68 00 70 80 00       	push   $0x807000
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	e8 eb f4 ff ff       	call   800c73 <memmove>
	return r;
  801788:	83 c4 10             	add    $0x10,%esp
}
  80178b:	89 d8                	mov    %ebx,%eax
  80178d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	83 ec 1c             	sub    $0x1c,%esp
  80179c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80179f:	56                   	push   %esi
  8017a0:	e8 bb f2 ff ff       	call   800a60 <strlen>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ad:	7f 65                	jg     801814 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	e8 e1 f8 ff ff       	call   80109c <fd_alloc>
  8017bb:	89 c3                	mov    %eax,%ebx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 55                	js     801819 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	56                   	push   %esi
  8017c8:	68 00 70 80 00       	push   $0x807000
  8017cd:	e8 e0 f2 ff ff       	call   800ab2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d5:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e2:	e8 65 fe ff ff       	call   80164c <fsipc>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	79 12                	jns    801802 <open+0x6e>
		fd_close(fd, 0);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	6a 00                	push   $0x0
  8017f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f8:	e8 ce f9 ff ff       	call   8011cb <fd_close>
		return r;
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	eb 17                	jmp    801819 <open+0x85>
	}

	return fd2num(fd);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 67 f8 ff ff       	call   801074 <fd2num>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	eb 05                	jmp    801819 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801814:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	c9                   	leave  
  801821:	c3                   	ret    
	...

00801824 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801830:	6a 00                	push   $0x0
  801832:	ff 75 08             	pushl  0x8(%ebp)
  801835:	e8 5a ff ff ff       	call   801794 <open>
  80183a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	0f 88 36 05 00 00    	js     801d81 <spawn+0x55d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	68 00 02 00 00       	push   $0x200
  801853:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801860:	e8 b2 fb ff ff       	call   801417 <readn>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	3d 00 02 00 00       	cmp    $0x200,%eax
  80186d:	75 0c                	jne    80187b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80186f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801876:	45 4c 46 
  801879:	74 38                	je     8018b3 <spawn+0x8f>
		close(fd);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801884:	e8 ca f9 ff ff       	call   801253 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801889:	83 c4 0c             	add    $0xc,%esp
  80188c:	68 7f 45 4c 46       	push   $0x464c457f
  801891:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801897:	68 8b 2b 80 00       	push   $0x802b8b
  80189c:	e8 5b ec ff ff       	call   8004fc <cprintf>
		return -E_NOT_EXEC;
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8018ab:	ff ff ff 
  8018ae:	e9 da 04 00 00       	jmp    801d8d <spawn+0x569>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018b3:	ba 07 00 00 00       	mov    $0x7,%edx
  8018b8:	89 d0                	mov    %edx,%eax
  8018ba:	cd 30                	int    $0x30
  8018bc:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8018c2:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 88 bd 04 00 00    	js     801d8d <spawn+0x569>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	c1 e6 07             	shl    $0x7,%esi
  8018e1:	29 d6                	sub    %edx,%esi
  8018e3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8018e9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018ef:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018f6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018fc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
  801905:	8b 02                	mov    (%edx),%eax
  801907:	85 c0                	test   %eax,%eax
  801909:	74 39                	je     801944 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80190b:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801910:	bb 00 00 00 00       	mov    $0x0,%ebx
  801915:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	50                   	push   %eax
  80191b:	e8 40 f1 ff ff       	call   800a60 <strlen>
  801920:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801924:	43                   	inc    %ebx
  801925:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80192c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	85 c0                	test   %eax,%eax
  801934:	75 e1                	jne    801917 <spawn+0xf3>
  801936:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  80193c:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801942:	eb 1e                	jmp    801962 <spawn+0x13e>
  801944:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80194b:	00 00 00 
  80194e:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801955:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801958:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80195d:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801962:	f7 de                	neg    %esi
  801964:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80196a:	89 fa                	mov    %edi,%edx
  80196c:	83 e2 fc             	and    $0xfffffffc,%edx
  80196f:	89 d8                	mov    %ebx,%eax
  801971:	f7 d0                	not    %eax
  801973:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801976:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80197c:	83 e8 08             	sub    $0x8,%eax
  80197f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801984:	0f 86 11 04 00 00    	jbe    801d9b <spawn+0x577>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	6a 07                	push   $0x7
  80198f:	68 00 00 40 00       	push   $0x400000
  801994:	6a 00                	push   $0x0
  801996:	e8 99 f5 ff ff       	call   800f34 <sys_page_alloc>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	0f 88 01 04 00 00    	js     801da7 <spawn+0x583>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019a6:	85 db                	test   %ebx,%ebx
  8019a8:	7e 44                	jle    8019ee <spawn+0x1ca>
  8019aa:	be 00 00 00 00       	mov    $0x0,%esi
  8019af:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8019b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8019b8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019be:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019c4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019cd:	57                   	push   %edi
  8019ce:	e8 df f0 ff ff       	call   800ab2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019d3:	83 c4 04             	add    $0x4,%esp
  8019d6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019d9:	e8 82 f0 ff ff       	call   800a60 <strlen>
  8019de:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019e2:	46                   	inc    %esi
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  8019ec:	7c ca                	jl     8019b8 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019ee:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019f4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8019fa:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a01:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a07:	74 19                	je     801a22 <spawn+0x1fe>
  801a09:	68 18 2c 80 00       	push   $0x802c18
  801a0e:	68 5f 2b 80 00       	push   $0x802b5f
  801a13:	68 f5 00 00 00       	push   $0xf5
  801a18:	68 a5 2b 80 00       	push   $0x802ba5
  801a1d:	e8 02 ea ff ff       	call   800424 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a22:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a28:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a2d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a33:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801a36:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a3c:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a3f:	89 d0                	mov    %edx,%eax
  801a41:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801a46:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	6a 07                	push   $0x7
  801a51:	68 00 d0 bf ee       	push   $0xeebfd000
  801a56:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a5c:	68 00 00 40 00       	push   $0x400000
  801a61:	6a 00                	push   $0x0
  801a63:	e8 f0 f4 ff ff       	call   800f58 <sys_page_map>
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	83 c4 20             	add    $0x20,%esp
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 18                	js     801a89 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	68 00 00 40 00       	push   $0x400000
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 fe f4 ff ff       	call   800f7e <sys_page_unmap>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	79 1d                	jns    801aa6 <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	68 00 00 40 00       	push   $0x400000
  801a91:	6a 00                	push   $0x0
  801a93:	e8 e6 f4 ff ff       	call   800f7e <sys_page_unmap>
  801a98:	83 c4 10             	add    $0x10,%esp
	return r;
  801a9b:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801aa1:	e9 e7 02 00 00       	jmp    801d8d <spawn+0x569>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801aa6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aac:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801ab3:	00 
  801ab4:	0f 84 c3 01 00 00    	je     801c7d <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801aba:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ac1:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ac7:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ace:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801ad1:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ad7:	83 3a 01             	cmpl   $0x1,(%edx)
  801ada:	0f 85 7c 01 00 00    	jne    801c5c <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ae0:	8b 42 18             	mov    0x18(%edx),%eax
  801ae3:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801ae6:	83 f8 01             	cmp    $0x1,%eax
  801ae9:	19 db                	sbb    %ebx,%ebx
  801aeb:	83 e3 fe             	and    $0xfffffffe,%ebx
  801aee:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801af1:	8b 42 04             	mov    0x4(%edx),%eax
  801af4:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801afa:	8b 52 10             	mov    0x10(%edx),%edx
  801afd:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801b03:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b09:	8b 40 14             	mov    0x14(%eax),%eax
  801b0c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b12:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b18:	8b 52 08             	mov    0x8(%edx),%edx
  801b1b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b21:	89 d0                	mov    %edx,%eax
  801b23:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b28:	74 1a                	je     801b44 <spawn+0x320>
		va -= i;
  801b2a:	29 c2                	sub    %eax,%edx
  801b2c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801b32:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801b38:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801b3e:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b44:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801b4b:	0f 84 0b 01 00 00    	je     801c5c <spawn+0x438>
  801b51:	bf 00 00 00 00       	mov    $0x0,%edi
  801b56:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801b5b:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801b61:	72 28                	jb     801b8b <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b63:	83 ec 04             	sub    $0x4,%esp
  801b66:	53                   	push   %ebx
  801b67:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801b6d:	57                   	push   %edi
  801b6e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b74:	e8 bb f3 ff ff       	call   800f34 <sys_page_alloc>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	0f 89 c4 00 00 00    	jns    801c48 <spawn+0x424>
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	e9 cf 01 00 00       	jmp    801d5a <spawn+0x536>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b8b:	83 ec 04             	sub    $0x4,%esp
  801b8e:	6a 07                	push   $0x7
  801b90:	68 00 00 40 00       	push   $0x400000
  801b95:	6a 00                	push   $0x0
  801b97:	e8 98 f3 ff ff       	call   800f34 <sys_page_alloc>
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	0f 88 a9 01 00 00    	js     801d50 <spawn+0x52c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ba7:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801baa:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801bb0:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb3:	50                   	push   %eax
  801bb4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bba:	e8 2f f9 ff ff       	call   8014ee <seek>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 8a 01 00 00    	js     801d54 <spawn+0x530>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bca:	83 ec 04             	sub    $0x4,%esp
  801bcd:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bd3:	29 f8                	sub    %edi,%eax
  801bd5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bda:	76 05                	jbe    801be1 <spawn+0x3bd>
  801bdc:	b8 00 10 00 00       	mov    $0x1000,%eax
  801be1:	50                   	push   %eax
  801be2:	68 00 00 40 00       	push   $0x400000
  801be7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bed:	e8 25 f8 ff ff       	call   801417 <readn>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 5b 01 00 00    	js     801d58 <spawn+0x534>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	53                   	push   %ebx
  801c01:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801c07:	57                   	push   %edi
  801c08:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c0e:	68 00 00 40 00       	push   $0x400000
  801c13:	6a 00                	push   $0x0
  801c15:	e8 3e f3 ff ff       	call   800f58 <sys_page_map>
  801c1a:	83 c4 20             	add    $0x20,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	79 15                	jns    801c36 <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  801c21:	50                   	push   %eax
  801c22:	68 b1 2b 80 00       	push   $0x802bb1
  801c27:	68 28 01 00 00       	push   $0x128
  801c2c:	68 a5 2b 80 00       	push   $0x802ba5
  801c31:	e8 ee e7 ff ff       	call   800424 <_panic>
			sys_page_unmap(0, UTEMP);
  801c36:	83 ec 08             	sub    $0x8,%esp
  801c39:	68 00 00 40 00       	push   $0x400000
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 39 f3 ff ff       	call   800f7e <sys_page_unmap>
  801c45:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c48:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c4e:	89 f7                	mov    %esi,%edi
  801c50:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801c56:	0f 87 ff fe ff ff    	ja     801b5b <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c5c:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801c62:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c69:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c6f:	7e 0c                	jle    801c7d <spawn+0x459>
  801c71:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801c78:	e9 54 fe ff ff       	jmp    801ad1 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c86:	e8 c8 f5 ff ff       	call   801253 <close>
  801c8b:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c93:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801c99:	89 d8                	mov    %ebx,%eax
  801c9b:	c1 e8 16             	shr    $0x16,%eax
  801c9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ca5:	a8 01                	test   $0x1,%al
  801ca7:	74 3e                	je     801ce7 <spawn+0x4c3>
  801ca9:	89 d8                	mov    %ebx,%eax
  801cab:	c1 e8 0c             	shr    $0xc,%eax
  801cae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cb5:	f6 c2 01             	test   $0x1,%dl
  801cb8:	74 2d                	je     801ce7 <spawn+0x4c3>
  801cba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cc1:	f6 c6 04             	test   $0x4,%dh
  801cc4:	74 21                	je     801ce7 <spawn+0x4c3>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801cc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ccd:	83 ec 0c             	sub    $0xc,%esp
  801cd0:	25 07 0e 00 00       	and    $0xe07,%eax
  801cd5:	50                   	push   %eax
  801cd6:	53                   	push   %ebx
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 78 f2 ff ff       	call   800f58 <sys_page_map>
        if (r < 0) return r;
  801ce0:	83 c4 20             	add    $0x20,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 13                	js     801cfa <spawn+0x4d6>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801ce7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ced:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801cf3:	75 a4                	jne    801c99 <spawn+0x475>
  801cf5:	e9 b5 00 00 00       	jmp    801daf <spawn+0x58b>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801cfa:	50                   	push   %eax
  801cfb:	68 ce 2b 80 00       	push   $0x802bce
  801d00:	68 86 00 00 00       	push   $0x86
  801d05:	68 a5 2b 80 00       	push   $0x802ba5
  801d0a:	e8 15 e7 ff ff       	call   800424 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d0f:	50                   	push   %eax
  801d10:	68 e4 2b 80 00       	push   $0x802be4
  801d15:	68 89 00 00 00       	push   $0x89
  801d1a:	68 a5 2b 80 00       	push   $0x802ba5
  801d1f:	e8 00 e7 ff ff       	call   800424 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	6a 02                	push   $0x2
  801d29:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d2f:	e8 6d f2 ff ff       	call   800fa1 <sys_env_set_status>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	79 52                	jns    801d8d <spawn+0x569>
		panic("sys_env_set_status: %e", r);
  801d3b:	50                   	push   %eax
  801d3c:	68 fe 2b 80 00       	push   $0x802bfe
  801d41:	68 8c 00 00 00       	push   $0x8c
  801d46:	68 a5 2b 80 00       	push   $0x802ba5
  801d4b:	e8 d4 e6 ff ff       	call   800424 <_panic>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	eb 06                	jmp    801d5a <spawn+0x536>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	eb 02                	jmp    801d5a <spawn+0x536>
  801d58:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d63:	e8 5f f1 ff ff       	call   800ec7 <sys_env_destroy>
	close(fd);
  801d68:	83 c4 04             	add    $0x4,%esp
  801d6b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d71:	e8 dd f4 ff ff       	call   801253 <close>
	return r;
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d7f:	eb 0c                	jmp    801d8d <spawn+0x569>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d81:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d87:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d8d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d9b:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801da2:	ff ff ff 
  801da5:	eb e6                	jmp    801d8d <spawn+0x569>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801da7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801dad:	eb de                	jmp    801d8d <spawn+0x569>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dbf:	e8 00 f2 ff ff       	call   800fc4 <sys_env_set_trapframe>
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	0f 89 55 ff ff ff    	jns    801d24 <spawn+0x500>
  801dcf:	e9 3b ff ff ff       	jmp    801d0f <spawn+0x4eb>

00801dd4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	56                   	push   %esi
  801dd8:	53                   	push   %ebx
  801dd9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ddc:	8d 45 14             	lea    0x14(%ebp),%eax
  801ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de3:	74 5f                	je     801e44 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801de5:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801dea:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801deb:	89 c2                	mov    %eax,%edx
  801ded:	83 c0 04             	add    $0x4,%eax
  801df0:	83 3a 00             	cmpl   $0x0,(%edx)
  801df3:	75 f5                	jne    801dea <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801df5:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801dfc:	83 e0 f0             	and    $0xfffffff0,%eax
  801dff:	29 c4                	sub    %eax,%esp
  801e01:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e05:	83 e0 f0             	and    $0xfffffff0,%eax
  801e08:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e0a:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e0c:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801e13:	00 

	va_start(vl, arg0);
  801e14:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801e17:	89 ce                	mov    %ecx,%esi
  801e19:	85 c9                	test   %ecx,%ecx
  801e1b:	74 14                	je     801e31 <spawnl+0x5d>
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801e22:	40                   	inc    %eax
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	83 c2 04             	add    $0x4,%edx
  801e28:	8b 09                	mov    (%ecx),%ecx
  801e2a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e2d:	39 f0                	cmp    %esi,%eax
  801e2f:	72 f1                	jb     801e22 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	53                   	push   %ebx
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 e7 f9 ff ff       	call   801824 <spawn>
}
  801e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e44:	83 ec 20             	sub    $0x20,%esp
  801e47:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e4b:	83 e0 f0             	and    $0xfffffff0,%eax
  801e4e:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e50:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e52:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801e59:	eb d6                	jmp    801e31 <spawnl+0x5d>
	...

00801e5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	ff 75 08             	pushl  0x8(%ebp)
  801e6a:	e8 15 f2 ff ff       	call   801084 <fd2data>
  801e6f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e71:	83 c4 08             	add    $0x8,%esp
  801e74:	68 40 2c 80 00       	push   $0x802c40
  801e79:	56                   	push   %esi
  801e7a:	e8 33 ec ff ff       	call   800ab2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e82:	2b 03                	sub    (%ebx),%eax
  801e84:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e8a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e91:	00 00 00 
	stat->st_dev = &devpipe;
  801e94:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  801e9b:	47 80 00 
	return 0;
}
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea6:	5b                   	pop    %ebx
  801ea7:	5e                   	pop    %esi
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	53                   	push   %ebx
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb4:	53                   	push   %ebx
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 c2 f0 ff ff       	call   800f7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ebc:	89 1c 24             	mov    %ebx,(%esp)
  801ebf:	e8 c0 f1 ff ff       	call   801084 <fd2data>
  801ec4:	83 c4 08             	add    $0x8,%esp
  801ec7:	50                   	push   %eax
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 af f0 ff ff       	call   800f7e <sys_page_unmap>
}
  801ecf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 1c             	sub    $0x1c,%esp
  801edd:	89 c7                	mov    %eax,%edi
  801edf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee2:	a1 90 67 80 00       	mov    0x806790,%eax
  801ee7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	57                   	push   %edi
  801eee:	e8 8d 04 00 00       	call   802380 <pageref>
  801ef3:	89 c6                	mov    %eax,%esi
  801ef5:	83 c4 04             	add    $0x4,%esp
  801ef8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801efb:	e8 80 04 00 00       	call   802380 <pageref>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	39 c6                	cmp    %eax,%esi
  801f05:	0f 94 c0             	sete   %al
  801f08:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f0b:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f14:	39 cb                	cmp    %ecx,%ebx
  801f16:	75 08                	jne    801f20 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1b:	5b                   	pop    %ebx
  801f1c:	5e                   	pop    %esi
  801f1d:	5f                   	pop    %edi
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f20:	83 f8 01             	cmp    $0x1,%eax
  801f23:	75 bd                	jne    801ee2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f25:	8b 42 58             	mov    0x58(%edx),%eax
  801f28:	6a 01                	push   $0x1
  801f2a:	50                   	push   %eax
  801f2b:	53                   	push   %ebx
  801f2c:	68 47 2c 80 00       	push   $0x802c47
  801f31:	e8 c6 e5 ff ff       	call   8004fc <cprintf>
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	eb a7                	jmp    801ee2 <_pipeisclosed+0xe>

00801f3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	57                   	push   %edi
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 28             	sub    $0x28,%esp
  801f44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f47:	56                   	push   %esi
  801f48:	e8 37 f1 ff ff       	call   801084 <fd2data>
  801f4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f56:	75 4a                	jne    801fa2 <devpipe_write+0x67>
  801f58:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5d:	eb 56                	jmp    801fb5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f5f:	89 da                	mov    %ebx,%edx
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	e8 6c ff ff ff       	call   801ed4 <_pipeisclosed>
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	75 4d                	jne    801fb9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f6c:	e8 9c ef ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f71:	8b 43 04             	mov    0x4(%ebx),%eax
  801f74:	8b 13                	mov    (%ebx),%edx
  801f76:	83 c2 20             	add    $0x20,%edx
  801f79:	39 d0                	cmp    %edx,%eax
  801f7b:	73 e2                	jae    801f5f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f7d:	89 c2                	mov    %eax,%edx
  801f7f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f85:	79 05                	jns    801f8c <devpipe_write+0x51>
  801f87:	4a                   	dec    %edx
  801f88:	83 ca e0             	or     $0xffffffe0,%edx
  801f8b:	42                   	inc    %edx
  801f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f8f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801f92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f96:	40                   	inc    %eax
  801f97:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f9a:	47                   	inc    %edi
  801f9b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801f9e:	77 07                	ja     801fa7 <devpipe_write+0x6c>
  801fa0:	eb 13                	jmp    801fb5 <devpipe_write+0x7a>
  801fa2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa7:	8b 43 04             	mov    0x4(%ebx),%eax
  801faa:	8b 13                	mov    (%ebx),%edx
  801fac:	83 c2 20             	add    $0x20,%edx
  801faf:	39 d0                	cmp    %edx,%eax
  801fb1:	73 ac                	jae    801f5f <devpipe_write+0x24>
  801fb3:	eb c8                	jmp    801f7d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fb5:	89 f8                	mov    %edi,%eax
  801fb7:	eb 05                	jmp    801fbe <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc1:	5b                   	pop    %ebx
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	57                   	push   %edi
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 18             	sub    $0x18,%esp
  801fcf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fd2:	57                   	push   %edi
  801fd3:	e8 ac f0 ff ff       	call   801084 <fd2data>
  801fd8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe1:	75 44                	jne    802027 <devpipe_read+0x61>
  801fe3:	be 00 00 00 00       	mov    $0x0,%esi
  801fe8:	eb 4f                	jmp    802039 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801fea:	89 f0                	mov    %esi,%eax
  801fec:	eb 54                	jmp    802042 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fee:	89 da                	mov    %ebx,%edx
  801ff0:	89 f8                	mov    %edi,%eax
  801ff2:	e8 dd fe ff ff       	call   801ed4 <_pipeisclosed>
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	75 42                	jne    80203d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ffb:	e8 0d ef ff ff       	call   800f0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802000:	8b 03                	mov    (%ebx),%eax
  802002:	3b 43 04             	cmp    0x4(%ebx),%eax
  802005:	74 e7                	je     801fee <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802007:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80200c:	79 05                	jns    802013 <devpipe_read+0x4d>
  80200e:	48                   	dec    %eax
  80200f:	83 c8 e0             	or     $0xffffffe0,%eax
  802012:	40                   	inc    %eax
  802013:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802017:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80201d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201f:	46                   	inc    %esi
  802020:	39 75 10             	cmp    %esi,0x10(%ebp)
  802023:	77 07                	ja     80202c <devpipe_read+0x66>
  802025:	eb 12                	jmp    802039 <devpipe_read+0x73>
  802027:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80202c:	8b 03                	mov    (%ebx),%eax
  80202e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802031:	75 d4                	jne    802007 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802033:	85 f6                	test   %esi,%esi
  802035:	75 b3                	jne    801fea <devpipe_read+0x24>
  802037:	eb b5                	jmp    801fee <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802039:	89 f0                	mov    %esi,%eax
  80203b:	eb 05                	jmp    802042 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	83 ec 28             	sub    $0x28,%esp
  802053:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802056:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802059:	50                   	push   %eax
  80205a:	e8 3d f0 ff ff       	call   80109c <fd_alloc>
  80205f:	89 c3                	mov    %eax,%ebx
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	0f 88 24 01 00 00    	js     802190 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206c:	83 ec 04             	sub    $0x4,%esp
  80206f:	68 07 04 00 00       	push   $0x407
  802074:	ff 75 e4             	pushl  -0x1c(%ebp)
  802077:	6a 00                	push   $0x0
  802079:	e8 b6 ee ff ff       	call   800f34 <sys_page_alloc>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	0f 88 05 01 00 00    	js     802190 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	e8 05 f0 ff ff       	call   80109c <fd_alloc>
  802097:	89 c3                	mov    %eax,%ebx
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 dc 00 00 00    	js     802180 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a4:	83 ec 04             	sub    $0x4,%esp
  8020a7:	68 07 04 00 00       	push   $0x407
  8020ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8020af:	6a 00                	push   $0x0
  8020b1:	e8 7e ee ff ff       	call   800f34 <sys_page_alloc>
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	0f 88 bd 00 00 00    	js     802180 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020c9:	e8 b6 ef ff ff       	call   801084 <fd2data>
  8020ce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d0:	83 c4 0c             	add    $0xc,%esp
  8020d3:	68 07 04 00 00       	push   $0x407
  8020d8:	50                   	push   %eax
  8020d9:	6a 00                	push   $0x0
  8020db:	e8 54 ee ff ff       	call   800f34 <sys_page_alloc>
  8020e0:	89 c3                	mov    %eax,%ebx
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	0f 88 83 00 00 00    	js     802170 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ed:	83 ec 0c             	sub    $0xc,%esp
  8020f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8020f3:	e8 8c ef ff ff       	call   801084 <fd2data>
  8020f8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020ff:	50                   	push   %eax
  802100:	6a 00                	push   $0x0
  802102:	56                   	push   %esi
  802103:	6a 00                	push   $0x0
  802105:	e8 4e ee ff ff       	call   800f58 <sys_page_map>
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	83 c4 20             	add    $0x20,%esp
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 4f                	js     802162 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802113:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802119:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80211c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80211e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802121:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802128:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80212e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802131:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802133:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802136:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80213d:	83 ec 0c             	sub    $0xc,%esp
  802140:	ff 75 e4             	pushl  -0x1c(%ebp)
  802143:	e8 2c ef ff ff       	call   801074 <fd2num>
  802148:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80214a:	83 c4 04             	add    $0x4,%esp
  80214d:	ff 75 e0             	pushl  -0x20(%ebp)
  802150:	e8 1f ef ff ff       	call   801074 <fd2num>
  802155:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802158:	83 c4 10             	add    $0x10,%esp
  80215b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802160:	eb 2e                	jmp    802190 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802162:	83 ec 08             	sub    $0x8,%esp
  802165:	56                   	push   %esi
  802166:	6a 00                	push   $0x0
  802168:	e8 11 ee ff ff       	call   800f7e <sys_page_unmap>
  80216d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802170:	83 ec 08             	sub    $0x8,%esp
  802173:	ff 75 e0             	pushl  -0x20(%ebp)
  802176:	6a 00                	push   $0x0
  802178:	e8 01 ee ff ff       	call   800f7e <sys_page_unmap>
  80217d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802180:	83 ec 08             	sub    $0x8,%esp
  802183:	ff 75 e4             	pushl  -0x1c(%ebp)
  802186:	6a 00                	push   $0x0
  802188:	e8 f1 ed ff ff       	call   800f7e <sys_page_unmap>
  80218d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802190:	89 d8                	mov    %ebx,%eax
  802192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5f                   	pop    %edi
  802198:	c9                   	leave  
  802199:	c3                   	ret    

0080219a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a3:	50                   	push   %eax
  8021a4:	ff 75 08             	pushl  0x8(%ebp)
  8021a7:	e8 63 ef ff ff       	call   80110f <fd_lookup>
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	78 18                	js     8021cb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b3:	83 ec 0c             	sub    $0xc,%esp
  8021b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b9:	e8 c6 ee ff ff       	call   801084 <fd2data>
	return _pipeisclosed(fd, p);
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c3:	e8 0c fd ff ff       	call   801ed4 <_pipeisclosed>
  8021c8:	83 c4 10             	add    $0x10,%esp
}
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    
  8021cd:	00 00                	add    %al,(%eax)
	...

008021d0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	57                   	push   %edi
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	83 ec 0c             	sub    $0xc,%esp
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	75 16                	jne    8021f6 <wait+0x26>
  8021e0:	68 5f 2c 80 00       	push   $0x802c5f
  8021e5:	68 5f 2b 80 00       	push   $0x802b5f
  8021ea:	6a 09                	push   $0x9
  8021ec:	68 6a 2c 80 00       	push   $0x802c6a
  8021f1:	e8 2e e2 ff ff       	call   800424 <_panic>
	e = &envs[ENVX(envid)];
  8021f6:	89 c6                	mov    %eax,%esi
  8021f8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021fe:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802205:	89 f2                	mov    %esi,%edx
  802207:	c1 e2 07             	shl    $0x7,%edx
  80220a:	29 ca                	sub    %ecx,%edx
  80220c:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  802212:	8b 7a 40             	mov    0x40(%edx),%edi
  802215:	39 c7                	cmp    %eax,%edi
  802217:	75 37                	jne    802250 <wait+0x80>
  802219:	89 f0                	mov    %esi,%eax
  80221b:	c1 e0 07             	shl    $0x7,%eax
  80221e:	29 c8                	sub    %ecx,%eax
  802220:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802225:	8b 40 50             	mov    0x50(%eax),%eax
  802228:	85 c0                	test   %eax,%eax
  80222a:	74 24                	je     802250 <wait+0x80>
  80222c:	c1 e6 07             	shl    $0x7,%esi
  80222f:	29 ce                	sub    %ecx,%esi
  802231:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  802237:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  80223d:	e8 cb ec ff ff       	call   800f0d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802242:	8b 43 40             	mov    0x40(%ebx),%eax
  802245:	39 f8                	cmp    %edi,%eax
  802247:	75 07                	jne    802250 <wait+0x80>
  802249:	8b 46 50             	mov    0x50(%esi),%eax
  80224c:	85 c0                	test   %eax,%eax
  80224e:	75 ed                	jne    80223d <wait+0x6d>
		sys_yield();
}
  802250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	8b 75 08             	mov    0x8(%ebp),%esi
  802260:	8b 45 0c             	mov    0xc(%ebp),%eax
  802263:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802266:	85 c0                	test   %eax,%eax
  802268:	74 0e                	je     802278 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80226a:	83 ec 0c             	sub    $0xc,%esp
  80226d:	50                   	push   %eax
  80226e:	e8 bc ed ff ff       	call   80102f <sys_ipc_recv>
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	eb 10                	jmp    802288 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802278:	83 ec 0c             	sub    $0xc,%esp
  80227b:	68 00 00 c0 ee       	push   $0xeec00000
  802280:	e8 aa ed ff ff       	call   80102f <sys_ipc_recv>
  802285:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802288:	85 c0                	test   %eax,%eax
  80228a:	75 26                	jne    8022b2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80228c:	85 f6                	test   %esi,%esi
  80228e:	74 0a                	je     80229a <ipc_recv+0x42>
  802290:	a1 90 67 80 00       	mov    0x806790,%eax
  802295:	8b 40 74             	mov    0x74(%eax),%eax
  802298:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80229a:	85 db                	test   %ebx,%ebx
  80229c:	74 0a                	je     8022a8 <ipc_recv+0x50>
  80229e:	a1 90 67 80 00       	mov    0x806790,%eax
  8022a3:	8b 40 78             	mov    0x78(%eax),%eax
  8022a6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8022a8:	a1 90 67 80 00       	mov    0x806790,%eax
  8022ad:	8b 40 70             	mov    0x70(%eax),%eax
  8022b0:	eb 14                	jmp    8022c6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8022b2:	85 f6                	test   %esi,%esi
  8022b4:	74 06                	je     8022bc <ipc_recv+0x64>
  8022b6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8022bc:	85 db                	test   %ebx,%ebx
  8022be:	74 06                	je     8022c6 <ipc_recv+0x6e>
  8022c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8022c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	c9                   	leave  
  8022cc:	c3                   	ret    

008022cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	57                   	push   %edi
  8022d1:	56                   	push   %esi
  8022d2:	53                   	push   %ebx
  8022d3:	83 ec 0c             	sub    $0xc,%esp
  8022d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022dc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8022df:	85 db                	test   %ebx,%ebx
  8022e1:	75 25                	jne    802308 <ipc_send+0x3b>
  8022e3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8022e8:	eb 1e                	jmp    802308 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8022ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ed:	75 07                	jne    8022f6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8022ef:	e8 19 ec ff ff       	call   800f0d <sys_yield>
  8022f4:	eb 12                	jmp    802308 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8022f6:	50                   	push   %eax
  8022f7:	68 75 2c 80 00       	push   $0x802c75
  8022fc:	6a 43                	push   $0x43
  8022fe:	68 88 2c 80 00       	push   $0x802c88
  802303:	e8 1c e1 ff ff       	call   800424 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802308:	56                   	push   %esi
  802309:	53                   	push   %ebx
  80230a:	57                   	push   %edi
  80230b:	ff 75 08             	pushl  0x8(%ebp)
  80230e:	e8 f7 ec ff ff       	call   80100a <sys_ipc_try_send>
  802313:	83 c4 10             	add    $0x10,%esp
  802316:	85 c0                	test   %eax,%eax
  802318:	75 d0                	jne    8022ea <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80231a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	c9                   	leave  
  802321:	c3                   	ret    

00802322 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	53                   	push   %ebx
  802326:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802329:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80232f:	74 22                	je     802353 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802336:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80233d:	89 c2                	mov    %eax,%edx
  80233f:	c1 e2 07             	shl    $0x7,%edx
  802342:	29 ca                	sub    %ecx,%edx
  802344:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80234a:	8b 52 50             	mov    0x50(%edx),%edx
  80234d:	39 da                	cmp    %ebx,%edx
  80234f:	75 1d                	jne    80236e <ipc_find_env+0x4c>
  802351:	eb 05                	jmp    802358 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802353:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802358:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80235f:	c1 e0 07             	shl    $0x7,%eax
  802362:	29 d0                	sub    %edx,%eax
  802364:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802369:	8b 40 40             	mov    0x40(%eax),%eax
  80236c:	eb 0c                	jmp    80237a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80236e:	40                   	inc    %eax
  80236f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802374:	75 c0                	jne    802336 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802376:	66 b8 00 00          	mov    $0x0,%ax
}
  80237a:	5b                   	pop    %ebx
  80237b:	c9                   	leave  
  80237c:	c3                   	ret    
  80237d:	00 00                	add    %al,(%eax)
	...

00802380 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802386:	89 c2                	mov    %eax,%edx
  802388:	c1 ea 16             	shr    $0x16,%edx
  80238b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802392:	f6 c2 01             	test   $0x1,%dl
  802395:	74 1e                	je     8023b5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802397:	c1 e8 0c             	shr    $0xc,%eax
  80239a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023a1:	a8 01                	test   $0x1,%al
  8023a3:	74 17                	je     8023bc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a5:	c1 e8 0c             	shr    $0xc,%eax
  8023a8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023af:	ef 
  8023b0:	0f b7 c0             	movzwl %ax,%eax
  8023b3:	eb 0c                	jmp    8023c1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ba:	eb 05                	jmp    8023c1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023c1:	c9                   	leave  
  8023c2:	c3                   	ret    
	...

008023c4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	57                   	push   %edi
  8023c8:	56                   	push   %esi
  8023c9:	83 ec 10             	sub    $0x10,%esp
  8023cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023d2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8023d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8023d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8023db:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	75 2e                	jne    802410 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023e2:	39 f1                	cmp    %esi,%ecx
  8023e4:	77 5a                	ja     802440 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023e6:	85 c9                	test   %ecx,%ecx
  8023e8:	75 0b                	jne    8023f5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ef:	31 d2                	xor    %edx,%edx
  8023f1:	f7 f1                	div    %ecx
  8023f3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023f5:	31 d2                	xor    %edx,%edx
  8023f7:	89 f0                	mov    %esi,%eax
  8023f9:	f7 f1                	div    %ecx
  8023fb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023fd:	89 f8                	mov    %edi,%eax
  8023ff:	f7 f1                	div    %ecx
  802401:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802403:	89 f8                	mov    %edi,%eax
  802405:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802407:	83 c4 10             	add    $0x10,%esp
  80240a:	5e                   	pop    %esi
  80240b:	5f                   	pop    %edi
  80240c:	c9                   	leave  
  80240d:	c3                   	ret    
  80240e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802410:	39 f0                	cmp    %esi,%eax
  802412:	77 1c                	ja     802430 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802414:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802417:	83 f7 1f             	xor    $0x1f,%edi
  80241a:	75 3c                	jne    802458 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80241c:	39 f0                	cmp    %esi,%eax
  80241e:	0f 82 90 00 00 00    	jb     8024b4 <__udivdi3+0xf0>
  802424:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802427:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80242a:	0f 86 84 00 00 00    	jbe    8024b4 <__udivdi3+0xf0>
  802430:	31 f6                	xor    %esi,%esi
  802432:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802434:	89 f8                	mov    %edi,%eax
  802436:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802438:	83 c4 10             	add    $0x10,%esp
  80243b:	5e                   	pop    %esi
  80243c:	5f                   	pop    %edi
  80243d:	c9                   	leave  
  80243e:	c3                   	ret    
  80243f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802440:	89 f2                	mov    %esi,%edx
  802442:	89 f8                	mov    %edi,%eax
  802444:	f7 f1                	div    %ecx
  802446:	89 c7                	mov    %eax,%edi
  802448:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80244a:	89 f8                	mov    %edi,%eax
  80244c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	c9                   	leave  
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802458:	89 f9                	mov    %edi,%ecx
  80245a:	d3 e0                	shl    %cl,%eax
  80245c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80245f:	b8 20 00 00 00       	mov    $0x20,%eax
  802464:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802466:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802469:	88 c1                	mov    %al,%cl
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802470:	09 ca                	or     %ecx,%edx
  802472:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802475:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802478:	89 f9                	mov    %edi,%ecx
  80247a:	d3 e2                	shl    %cl,%edx
  80247c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80247f:	89 f2                	mov    %esi,%edx
  802481:	88 c1                	mov    %al,%cl
  802483:	d3 ea                	shr    %cl,%edx
  802485:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802488:	89 f2                	mov    %esi,%edx
  80248a:	89 f9                	mov    %edi,%ecx
  80248c:	d3 e2                	shl    %cl,%edx
  80248e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802491:	88 c1                	mov    %al,%cl
  802493:	d3 ee                	shr    %cl,%esi
  802495:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802497:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80249a:	89 f0                	mov    %esi,%eax
  80249c:	89 ca                	mov    %ecx,%edx
  80249e:	f7 75 ec             	divl   -0x14(%ebp)
  8024a1:	89 d1                	mov    %edx,%ecx
  8024a3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024a5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024a8:	39 d1                	cmp    %edx,%ecx
  8024aa:	72 28                	jb     8024d4 <__udivdi3+0x110>
  8024ac:	74 1a                	je     8024c8 <__udivdi3+0x104>
  8024ae:	89 f7                	mov    %esi,%edi
  8024b0:	31 f6                	xor    %esi,%esi
  8024b2:	eb 80                	jmp    802434 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024b4:	31 f6                	xor    %esi,%esi
  8024b6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024bb:	89 f8                	mov    %edi,%eax
  8024bd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024bf:	83 c4 10             	add    $0x10,%esp
  8024c2:	5e                   	pop    %esi
  8024c3:	5f                   	pop    %edi
  8024c4:	c9                   	leave  
  8024c5:	c3                   	ret    
  8024c6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8024cb:	89 f9                	mov    %edi,%ecx
  8024cd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024cf:	39 c2                	cmp    %eax,%edx
  8024d1:	73 db                	jae    8024ae <__udivdi3+0xea>
  8024d3:	90                   	nop
		{
		  q0--;
  8024d4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024d7:	31 f6                	xor    %esi,%esi
  8024d9:	e9 56 ff ff ff       	jmp    802434 <__udivdi3+0x70>
	...

008024e0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	57                   	push   %edi
  8024e4:	56                   	push   %esi
  8024e5:	83 ec 20             	sub    $0x20,%esp
  8024e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8024f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8024f4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8024fd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024ff:	85 ff                	test   %edi,%edi
  802501:	75 15                	jne    802518 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802503:	39 f1                	cmp    %esi,%ecx
  802505:	0f 86 99 00 00 00    	jbe    8025a4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80250b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80250d:	89 d0                	mov    %edx,%eax
  80250f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802511:	83 c4 20             	add    $0x20,%esp
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	c9                   	leave  
  802517:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802518:	39 f7                	cmp    %esi,%edi
  80251a:	0f 87 a4 00 00 00    	ja     8025c4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802520:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802523:	83 f0 1f             	xor    $0x1f,%eax
  802526:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802529:	0f 84 a1 00 00 00    	je     8025d0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80252f:	89 f8                	mov    %edi,%eax
  802531:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802534:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802536:	bf 20 00 00 00       	mov    $0x20,%edi
  80253b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80253e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 ea                	shr    %cl,%edx
  802545:	09 c2                	or     %eax,%edx
  802547:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802550:	d3 e0                	shl    %cl,%eax
  802552:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802555:	89 f2                	mov    %esi,%edx
  802557:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802559:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80255c:	d3 e0                	shl    %cl,%eax
  80255e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802561:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802564:	89 f9                	mov    %edi,%ecx
  802566:	d3 e8                	shr    %cl,%eax
  802568:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80256a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	f7 75 f0             	divl   -0x10(%ebp)
  802571:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802573:	f7 65 f4             	mull   -0xc(%ebp)
  802576:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802579:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80257b:	39 d6                	cmp    %edx,%esi
  80257d:	72 71                	jb     8025f0 <__umoddi3+0x110>
  80257f:	74 7f                	je     802600 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802581:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802584:	29 c8                	sub    %ecx,%eax
  802586:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802588:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	89 f9                	mov    %edi,%ecx
  802591:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802593:	09 d0                	or     %edx,%eax
  802595:	89 f2                	mov    %esi,%edx
  802597:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80259a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80259c:	83 c4 20             	add    $0x20,%esp
  80259f:	5e                   	pop    %esi
  8025a0:	5f                   	pop    %edi
  8025a1:	c9                   	leave  
  8025a2:	c3                   	ret    
  8025a3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025a4:	85 c9                	test   %ecx,%ecx
  8025a6:	75 0b                	jne    8025b3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ad:	31 d2                	xor    %edx,%edx
  8025af:	f7 f1                	div    %ecx
  8025b1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025b3:	89 f0                	mov    %esi,%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025bc:	f7 f1                	div    %ecx
  8025be:	e9 4a ff ff ff       	jmp    80250d <__umoddi3+0x2d>
  8025c3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025c4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c6:	83 c4 20             	add    $0x20,%esp
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	c9                   	leave  
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025d0:	39 f7                	cmp    %esi,%edi
  8025d2:	72 05                	jb     8025d9 <__umoddi3+0xf9>
  8025d4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8025d7:	77 0c                	ja     8025e5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025d9:	89 f2                	mov    %esi,%edx
  8025db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025de:	29 c8                	sub    %ecx,%eax
  8025e0:	19 fa                	sbb    %edi,%edx
  8025e2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025e8:	83 c4 20             	add    $0x20,%esp
  8025eb:	5e                   	pop    %esi
  8025ec:	5f                   	pop    %edi
  8025ed:	c9                   	leave  
  8025ee:	c3                   	ret    
  8025ef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8025f3:	89 c1                	mov    %eax,%ecx
  8025f5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8025f8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8025fb:	eb 84                	jmp    802581 <__umoddi3+0xa1>
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802600:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802603:	72 eb                	jb     8025f0 <__umoddi3+0x110>
  802605:	89 f2                	mov    %esi,%edx
  802607:	e9 75 ff ff ff       	jmp    802581 <__umoddi3+0xa1>
