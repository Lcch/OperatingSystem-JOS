
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 4b 02 00 00       	call   80027c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 04             	sub    $0x4,%esp
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  80003b:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800040:	e8 6c 0e 00 00       	call   800eb1 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	43                   	inc    %ebx
  800046:	83 fb 0a             	cmp    $0xa,%ebx
  800049:	75 f5                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	6a 00                	push   $0x0
  800050:	e8 0e 12 00 00       	call   801263 <close>
	if ((r = opencons()) < 0)
  800055:	e8 d0 01 00 00       	call   80022a <opencons>
  80005a:	83 c4 10             	add    $0x10,%esp
  80005d:	85 c0                	test   %eax,%eax
  80005f:	79 12                	jns    800073 <umain+0x3f>
		panic("opencons: %e", r);
  800061:	50                   	push   %eax
  800062:	68 60 20 80 00       	push   $0x802060
  800067:	6a 0f                	push   $0xf
  800069:	68 6d 20 80 00       	push   $0x80206d
  80006e:	e8 71 02 00 00       	call   8002e4 <_panic>
	if (r != 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 12                	je     800089 <umain+0x55>
		panic("first opencons used fd %d", r);
  800077:	50                   	push   %eax
  800078:	68 7c 20 80 00       	push   $0x80207c
  80007d:	6a 11                	push   $0x11
  80007f:	68 6d 20 80 00       	push   $0x80206d
  800084:	e8 5b 02 00 00       	call   8002e4 <_panic>
	if ((r = dup(0, 1)) < 0)
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 01                	push   $0x1
  80008e:	6a 00                	push   $0x0
  800090:	e8 1c 12 00 00       	call   8012b1 <dup>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 12                	jns    8000ae <umain+0x7a>
		panic("dup: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 96 20 80 00       	push   $0x802096
  8000a2:	6a 13                	push   $0x13
  8000a4:	68 6d 20 80 00       	push   $0x80206d
  8000a9:	e8 36 02 00 00       	call   8002e4 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	68 9e 20 80 00       	push   $0x80209e
  8000b6:	e8 65 08 00 00       	call   800920 <readline>
		if (buf != NULL)
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	74 15                	je     8000d7 <umain+0xa3>
			fprintf(1, "%s\n", buf);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	50                   	push   %eax
  8000c6:	68 ac 20 80 00       	push   $0x8020ac
  8000cb:	6a 01                	push   $0x1
  8000cd:	e8 47 18 00 00       	call   801919 <fprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	eb d7                	jmp    8000ae <umain+0x7a>
		else
			fprintf(1, "(end of file received)\n");
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 b0 20 80 00       	push   $0x8020b0
  8000df:	6a 01                	push   $0x1
  8000e1:	e8 33 18 00 00       	call   801919 <fprintf>
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	eb c3                	jmp    8000ae <umain+0x7a>
	...

008000ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000fc:	68 c8 20 80 00       	push   $0x8020c8
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	e8 4d 09 00 00       	call   800a56 <strcpy>
	return 0;
}
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80011c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800120:	74 45                	je     800167 <devcons_write+0x57>
  800122:	b8 00 00 00 00       	mov    $0x0,%eax
  800127:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80012c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800132:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800135:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800137:	83 fb 7f             	cmp    $0x7f,%ebx
  80013a:	76 05                	jbe    800141 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  80013c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800141:	83 ec 04             	sub    $0x4,%esp
  800144:	53                   	push   %ebx
  800145:	03 45 0c             	add    0xc(%ebp),%eax
  800148:	50                   	push   %eax
  800149:	57                   	push   %edi
  80014a:	e8 c8 0a 00 00       	call   800c17 <memmove>
		sys_cputs(buf, m);
  80014f:	83 c4 08             	add    $0x8,%esp
  800152:	53                   	push   %ebx
  800153:	57                   	push   %edi
  800154:	e8 c8 0c 00 00       	call   800e21 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800159:	01 de                	add    %ebx,%esi
  80015b:	89 f0                	mov    %esi,%eax
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	3b 75 10             	cmp    0x10(%ebp),%esi
  800163:	72 cd                	jb     800132 <devcons_write+0x22>
  800165:	eb 05                	jmp    80016c <devcons_write+0x5c>
  800167:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80016c:	89 f0                	mov    %esi,%eax
  80016e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80017c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800180:	75 07                	jne    800189 <devcons_read+0x13>
  800182:	eb 25                	jmp    8001a9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800184:	e8 28 0d 00 00       	call   800eb1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800189:	e8 b9 0c 00 00       	call   800e47 <sys_cgetc>
  80018e:	85 c0                	test   %eax,%eax
  800190:	74 f2                	je     800184 <devcons_read+0xe>
  800192:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800194:	85 c0                	test   %eax,%eax
  800196:	78 1d                	js     8001b5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800198:	83 f8 04             	cmp    $0x4,%eax
  80019b:	74 13                	je     8001b0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80019d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a0:	88 10                	mov    %dl,(%eax)
	return 1;
  8001a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a7:	eb 0c                	jmp    8001b5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ae:	eb 05                	jmp    8001b5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001c3:	6a 01                	push   $0x1
  8001c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 53 0c 00 00       	call   800e21 <sys_cputs>
  8001ce:	83 c4 10             	add    $0x10,%esp
}
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <getchar>:

int
getchar(void)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001d9:	6a 01                	push   $0x1
  8001db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	6a 00                	push   $0x0
  8001e1:	e8 ba 11 00 00       	call   8013a0 <read>
	if (r < 0)
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	85 c0                	test   %eax,%eax
  8001eb:	78 0f                	js     8001fc <getchar+0x29>
		return r;
	if (r < 1)
  8001ed:	85 c0                	test   %eax,%eax
  8001ef:	7e 06                	jle    8001f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8001f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001f5:	eb 05                	jmp    8001fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	ff 75 08             	pushl  0x8(%ebp)
  80020b:	e8 0f 0f 00 00       	call   80111f <fd_lookup>
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	85 c0                	test   %eax,%eax
  800215:	78 11                	js     800228 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80021a:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800220:	39 10                	cmp    %edx,(%eax)
  800222:	0f 94 c0             	sete   %al
  800225:	0f b6 c0             	movzbl %al,%eax
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <opencons>:

int
opencons(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800230:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800233:	50                   	push   %eax
  800234:	e8 73 0e 00 00       	call   8010ac <fd_alloc>
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	85 c0                	test   %eax,%eax
  80023e:	78 3a                	js     80027a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	68 07 04 00 00       	push   $0x407
  800248:	ff 75 f4             	pushl  -0xc(%ebp)
  80024b:	6a 00                	push   $0x0
  80024d:	e8 86 0c 00 00       	call   800ed8 <sys_page_alloc>
  800252:	83 c4 10             	add    $0x10,%esp
  800255:	85 c0                	test   %eax,%eax
  800257:	78 21                	js     80027a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800259:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800262:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800267:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	50                   	push   %eax
  800272:	e8 0d 0e 00 00       	call   801084 <fd2num>
  800277:	83 c4 10             	add    $0x10,%esp
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800287:	e8 01 0c 00 00       	call   800e8d <sys_getenvid>
  80028c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800291:	89 c2                	mov    %eax,%edx
  800293:	c1 e2 07             	shl    $0x7,%edx
  800296:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80029d:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a2:	85 f6                	test   %esi,%esi
  8002a4:	7e 07                	jle    8002ad <libmain+0x31>
		binaryname = argv[0];
  8002a6:	8b 03                	mov    (%ebx),%eax
  8002a8:	a3 1c 30 80 00       	mov    %eax,0x80301c
	// call user main routine
	umain(argc, argv);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	56                   	push   %esi
  8002b2:	e8 7d fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002b7:	e8 0c 00 00 00       	call   8002c8 <exit>
  8002bc:	83 c4 10             	add    $0x10,%esp
}
  8002bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    
	...

008002c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002ce:	e8 bb 0f 00 00       	call   80128e <close_all>
	sys_env_destroy(0);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	6a 00                	push   $0x0
  8002d8:	e8 8e 0b 00 00       	call   800e6b <sys_env_destroy>
  8002dd:	83 c4 10             	add    $0x10,%esp
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    
	...

008002e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ec:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  8002f2:	e8 96 0b 00 00       	call   800e8d <sys_getenvid>
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	ff 75 08             	pushl  0x8(%ebp)
  800300:	53                   	push   %ebx
  800301:	50                   	push   %eax
  800302:	68 e0 20 80 00       	push   $0x8020e0
  800307:	e8 b0 00 00 00       	call   8003bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80030c:	83 c4 18             	add    $0x18,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	e8 53 00 00 00       	call   80036b <vcprintf>
	cprintf("\n");
  800318:	c7 04 24 c6 20 80 00 	movl   $0x8020c6,(%esp)
  80031f:	e8 98 00 00 00       	call   8003bc <cprintf>
  800324:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800327:	cc                   	int3   
  800328:	eb fd                	jmp    800327 <_panic+0x43>
	...

0080032c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	53                   	push   %ebx
  800330:	83 ec 04             	sub    $0x4,%esp
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800336:	8b 03                	mov    (%ebx),%eax
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80033f:	40                   	inc    %eax
  800340:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800342:	3d ff 00 00 00       	cmp    $0xff,%eax
  800347:	75 1a                	jne    800363 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	68 ff 00 00 00       	push   $0xff
  800351:	8d 43 08             	lea    0x8(%ebx),%eax
  800354:	50                   	push   %eax
  800355:	e8 c7 0a 00 00       	call   800e21 <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800360:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800363:	ff 43 04             	incl   0x4(%ebx)
}
  800366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800374:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037b:	00 00 00 
	b.cnt = 0;
  80037e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800385:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800388:	ff 75 0c             	pushl  0xc(%ebp)
  80038b:	ff 75 08             	pushl  0x8(%ebp)
  80038e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	68 2c 03 80 00       	push   $0x80032c
  80039a:	e8 82 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039f:	83 c4 08             	add    $0x8,%esp
  8003a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	e8 6d 0a 00 00       	call   800e21 <sys_cputs>

	return b.cnt;
}
  8003b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c5:	50                   	push   %eax
  8003c6:	ff 75 08             	pushl  0x8(%ebp)
  8003c9:	e8 9d ff ff ff       	call   80036b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 2c             	sub    $0x2c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003fd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800400:	72 0c                	jb     80040e <printnum+0x3e>
  800402:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800405:	76 07                	jbe    80040e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800407:	4b                   	dec    %ebx
  800408:	85 db                	test   %ebx,%ebx
  80040a:	7f 31                	jg     80043d <printnum+0x6d>
  80040c:	eb 3f                	jmp    80044d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040e:	83 ec 0c             	sub    $0xc,%esp
  800411:	57                   	push   %edi
  800412:	4b                   	dec    %ebx
  800413:	53                   	push   %ebx
  800414:	50                   	push   %eax
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041b:	ff 75 d0             	pushl  -0x30(%ebp)
  80041e:	ff 75 dc             	pushl  -0x24(%ebp)
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	e8 ef 19 00 00       	call   801e18 <__udivdi3>
  800429:	83 c4 18             	add    $0x18,%esp
  80042c:	52                   	push   %edx
  80042d:	50                   	push   %eax
  80042e:	89 f2                	mov    %esi,%edx
  800430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800433:	e8 98 ff ff ff       	call   8003d0 <printnum>
  800438:	83 c4 20             	add    $0x20,%esp
  80043b:	eb 10                	jmp    80044d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	56                   	push   %esi
  800441:	57                   	push   %edi
  800442:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800445:	4b                   	dec    %ebx
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 db                	test   %ebx,%ebx
  80044b:	7f f0                	jg     80043d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	56                   	push   %esi
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	ff 75 d4             	pushl  -0x2c(%ebp)
  800457:	ff 75 d0             	pushl  -0x30(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 cf 1a 00 00       	call   801f34 <__umoddi3>
  800465:	83 c4 14             	add    $0x14,%esp
  800468:	0f be 80 03 21 80 00 	movsbl 0x802103(%eax),%eax
  80046f:	50                   	push   %eax
  800470:	ff 55 e4             	call   *-0x1c(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
}
  800476:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	c9                   	leave  
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bb:	83 fa 01             	cmp    $0x1,%edx
  8004be:	7e 0e                	jle    8004ce <getint+0x16>
		return va_arg(*ap, long long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	8b 52 04             	mov    0x4(%edx),%edx
  8004cc:	eb 1a                	jmp    8004e8 <getint+0x30>
	else if (lflag)
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 0c                	je     8004de <getint+0x26>
		return va_arg(*ap, long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	99                   	cltd   
  8004dc:	eb 0a                	jmp    8004e8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	99                   	cltd   
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f8:	73 08                	jae    800502 <sprintputch+0x18>
		*b->buf++ = ch;
  8004fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004fd:	88 0a                	mov    %cl,(%edx)
  8004ff:	42                   	inc    %edx
  800500:	89 10                	mov    %edx,(%eax)
}
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
  80051c:	83 c4 10             	add    $0x10,%esp
}
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052d:	8b 75 10             	mov    0x10(%ebp),%esi
  800530:	eb 13                	jmp    800545 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800532:	85 c0                	test   %eax,%eax
  800534:	0f 84 6d 03 00 00    	je     8008a7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	57                   	push   %edi
  80053e:	50                   	push   %eax
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800545:	0f b6 06             	movzbl (%esi),%eax
  800548:	46                   	inc    %esi
  800549:	83 f8 25             	cmp    $0x25,%eax
  80054c:	75 e4                	jne    800532 <vprintfmt+0x11>
  80054e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800552:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800559:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800560:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056c:	eb 28                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800570:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800574:	eb 20                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800578:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80057c:	eb 18                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800580:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800587:	eb 0d                	jmp    800596 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8a 06                	mov    (%esi),%al
  800598:	0f b6 d0             	movzbl %al,%edx
  80059b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80059e:	83 e8 23             	sub    $0x23,%eax
  8005a1:	3c 55                	cmp    $0x55,%al
  8005a3:	0f 87 e0 02 00 00    	ja     800889 <vprintfmt+0x368>
  8005a9:	0f b6 c0             	movzbl %al,%eax
  8005ac:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b3:	83 ea 30             	sub    $0x30,%edx
  8005b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005b9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005bc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005bf:	83 fa 09             	cmp    $0x9,%edx
  8005c2:	77 44                	ja     800608 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	89 de                	mov    %ebx,%esi
  8005c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005ca:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005cd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005d7:	83 fb 09             	cmp    $0x9,%ebx
  8005da:	76 ed                	jbe    8005c9 <vprintfmt+0xa8>
  8005dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005df:	eb 29                	jmp    80060a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f1:	eb 17                	jmp    80060a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f7:	78 85                	js     80057e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	eb 99                	jmp    800596 <vprintfmt+0x75>
  8005fd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800606:	eb 8e                	jmp    800596 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80060a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060e:	79 86                	jns    800596 <vprintfmt+0x75>
  800610:	e9 74 ff ff ff       	jmp    800589 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800615:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	89 de                	mov    %ebx,%esi
  800618:	e9 79 ff ff ff       	jmp    800596 <vprintfmt+0x75>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	ff 30                	pushl  (%eax)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800638:	e9 08 ff ff ff       	jmp    800545 <vprintfmt+0x24>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	85 c0                	test   %eax,%eax
  80064d:	79 02                	jns    800651 <vprintfmt+0x130>
  80064f:	f7 d8                	neg    %eax
  800651:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800653:	83 f8 0f             	cmp    $0xf,%eax
  800656:	7f 0b                	jg     800663 <vprintfmt+0x142>
  800658:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	75 1a                	jne    80067d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800663:	52                   	push   %edx
  800664:	68 1b 21 80 00       	push   $0x80211b
  800669:	57                   	push   %edi
  80066a:	ff 75 08             	pushl  0x8(%ebp)
  80066d:	e8 92 fe ff ff       	call   800504 <printfmt>
  800672:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800678:	e9 c8 fe ff ff       	jmp    800545 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80067d:	50                   	push   %eax
  80067e:	68 e5 24 80 00       	push   $0x8024e5
  800683:	57                   	push   %edi
  800684:	ff 75 08             	pushl  0x8(%ebp)
  800687:	e8 78 fe ff ff       	call   800504 <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800692:	e9 ae fe ff ff       	jmp    800545 <vprintfmt+0x24>
  800697:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069a:	89 de                	mov    %ebx,%esi
  80069c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80069f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	75 07                	jne    8006bb <vprintfmt+0x19a>
				p = "(null)";
  8006b4:	c7 45 d0 14 21 80 00 	movl   $0x802114,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006bb:	85 db                	test   %ebx,%ebx
  8006bd:	7e 42                	jle    800701 <vprintfmt+0x1e0>
  8006bf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006c3:	74 3c                	je     800701 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	51                   	push   %ecx
  8006c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006cc:	e8 53 03 00 00       	call   800a24 <strnlen>
  8006d1:	29 c3                	sub    %eax,%ebx
  8006d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	85 db                	test   %ebx,%ebx
  8006db:	7e 24                	jle    800701 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006dd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006e1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	53                   	push   %ebx
  8006ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ef:	4e                   	dec    %esi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 f6                	test   %esi,%esi
  8006f5:	7f f0                	jg     8006e7 <vprintfmt+0x1c6>
  8006f7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800704:	0f be 02             	movsbl (%edx),%eax
  800707:	85 c0                	test   %eax,%eax
  800709:	75 47                	jne    800752 <vprintfmt+0x231>
  80070b:	eb 37                	jmp    800744 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80070d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800711:	74 16                	je     800729 <vprintfmt+0x208>
  800713:	8d 50 e0             	lea    -0x20(%eax),%edx
  800716:	83 fa 5e             	cmp    $0x5e,%edx
  800719:	76 0e                	jbe    800729 <vprintfmt+0x208>
					putch('?', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	57                   	push   %edi
  80071f:	6a 3f                	push   $0x3f
  800721:	ff 55 08             	call   *0x8(%ebp)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 0b                	jmp    800734 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	57                   	push   %edi
  80072d:	50                   	push   %eax
  80072e:	ff 55 08             	call   *0x8(%ebp)
  800731:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800734:	ff 4d e4             	decl   -0x1c(%ebp)
  800737:	0f be 03             	movsbl (%ebx),%eax
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 03                	je     800741 <vprintfmt+0x220>
  80073e:	43                   	inc    %ebx
  80073f:	eb 1b                	jmp    80075c <vprintfmt+0x23b>
  800741:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800748:	7f 1e                	jg     800768 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80074d:	e9 f3 fd ff ff       	jmp    800545 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800755:	43                   	inc    %ebx
  800756:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800759:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80075c:	85 f6                	test   %esi,%esi
  80075e:	78 ad                	js     80070d <vprintfmt+0x1ec>
  800760:	4e                   	dec    %esi
  800761:	79 aa                	jns    80070d <vprintfmt+0x1ec>
  800763:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800766:	eb dc                	jmp    800744 <vprintfmt+0x223>
  800768:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	57                   	push   %edi
  80076f:	6a 20                	push   $0x20
  800771:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800774:	4b                   	dec    %ebx
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 db                	test   %ebx,%ebx
  80077a:	7f ef                	jg     80076b <vprintfmt+0x24a>
  80077c:	e9 c4 fd ff ff       	jmp    800545 <vprintfmt+0x24>
  800781:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800784:	89 ca                	mov    %ecx,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 2a fd ff ff       	call   8004b8 <getint>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	78 0a                	js     8007a0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079b:	e9 b0 00 00 00       	jmp    800850 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	57                   	push   %edi
  8007a4:	6a 2d                	push   $0x2d
  8007a6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a9:	f7 db                	neg    %ebx
  8007ab:	83 d6 00             	adc    $0x0,%esi
  8007ae:	f7 de                	neg    %esi
  8007b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b8:	e9 93 00 00 00       	jmp    800850 <vprintfmt+0x32f>
  8007bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c0:	89 ca                	mov    %ecx,%edx
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 b4 fc ff ff       	call   80047e <getuint>
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	89 d6                	mov    %edx,%esi
			base = 10;
  8007ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d3:	eb 7b                	jmp    800850 <vprintfmt+0x32f>
  8007d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007d8:	89 ca                	mov    %ecx,%edx
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dd:	e8 d6 fc ff ff       	call   8004b8 <getint>
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007e6:	85 d2                	test   %edx,%edx
  8007e8:	78 07                	js     8007f1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8007ef:	eb 5f                	jmp    800850 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	57                   	push   %edi
  8007f5:	6a 2d                	push   $0x2d
  8007f7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007fa:	f7 db                	neg    %ebx
  8007fc:	83 d6 00             	adc    $0x0,%esi
  8007ff:	f7 de                	neg    %esi
  800801:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800804:	b8 08 00 00 00       	mov    $0x8,%eax
  800809:	eb 45                	jmp    800850 <vprintfmt+0x32f>
  80080b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	57                   	push   %edi
  800812:	6a 30                	push   $0x30
  800814:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	57                   	push   %edi
  80081b:	6a 78                	push   $0x78
  80081d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8d 50 04             	lea    0x4(%eax),%edx
  800826:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800829:	8b 18                	mov    (%eax),%ebx
  80082b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800830:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800833:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800838:	eb 16                	jmp    800850 <vprintfmt+0x32f>
  80083a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80083d:	89 ca                	mov    %ecx,%edx
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 37 fc ff ff       	call   80047e <getuint>
  800847:	89 c3                	mov    %eax,%ebx
  800849:	89 d6                	mov    %edx,%esi
			base = 16;
  80084b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800857:	52                   	push   %edx
  800858:	ff 75 e4             	pushl  -0x1c(%ebp)
  80085b:	50                   	push   %eax
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	89 fa                	mov    %edi,%edx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	e8 68 fb ff ff       	call   8003d0 <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
  80086b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80086e:	e9 d2 fc ff ff       	jmp    800545 <vprintfmt+0x24>
  800873:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	57                   	push   %edi
  80087a:	52                   	push   %edx
  80087b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80087e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800881:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800884:	e9 bc fc ff ff       	jmp    800545 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	57                   	push   %edi
  80088d:	6a 25                	push   $0x25
  80088f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	eb 02                	jmp    800899 <vprintfmt+0x378>
  800897:	89 c6                	mov    %eax,%esi
  800899:	8d 46 ff             	lea    -0x1(%esi),%eax
  80089c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a0:	75 f5                	jne    800897 <vprintfmt+0x376>
  8008a2:	e9 9e fc ff ff       	jmp    800545 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 18             	sub    $0x18,%esp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 26                	je     8008f6 <vsnprintf+0x47>
  8008d0:	85 d2                	test   %edx,%edx
  8008d2:	7e 29                	jle    8008fd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d4:	ff 75 14             	pushl  0x14(%ebp)
  8008d7:	ff 75 10             	pushl  0x10(%ebp)
  8008da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008dd:	50                   	push   %eax
  8008de:	68 ea 04 80 00       	push   $0x8004ea
  8008e3:	e8 39 fc ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb 0c                	jmp    800902 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008fb:	eb 05                	jmp    800902 <vsnprintf+0x53>
  8008fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090d:	50                   	push   %eax
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 93 ff ff ff       	call   8008af <vsnprintf>
	va_end(ap);

	return rc;
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    
	...

00800920 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80092c:	85 c0                	test   %eax,%eax
  80092e:	74 13                	je     800943 <readline+0x23>
		fprintf(1, "%s", prompt);
  800930:	83 ec 04             	sub    $0x4,%esp
  800933:	50                   	push   %eax
  800934:	68 e5 24 80 00       	push   $0x8024e5
  800939:	6a 01                	push   $0x1
  80093b:	e8 d9 0f 00 00       	call   801919 <fprintf>
  800940:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800943:	83 ec 0c             	sub    $0xc,%esp
  800946:	6a 00                	push   $0x0
  800948:	e8 b1 f8 ff ff       	call   8001fe <iscons>
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800952:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800957:	e8 77 f8 ff ff       	call   8001d3 <getchar>
  80095c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80095e:	85 c0                	test   %eax,%eax
  800960:	79 21                	jns    800983 <readline+0x63>
			if (c != -E_EOF)
  800962:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800965:	0f 84 89 00 00 00    	je     8009f4 <readline+0xd4>
				cprintf("read error: %e\n", c);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	50                   	push   %eax
  80096f:	68 ff 23 80 00       	push   $0x8023ff
  800974:	e8 43 fa ff ff       	call   8003bc <cprintf>
  800979:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	eb 76                	jmp    8009f9 <readline+0xd9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800983:	83 f8 08             	cmp    $0x8,%eax
  800986:	74 05                	je     80098d <readline+0x6d>
  800988:	83 f8 7f             	cmp    $0x7f,%eax
  80098b:	75 18                	jne    8009a5 <readline+0x85>
  80098d:	85 f6                	test   %esi,%esi
  80098f:	7e 14                	jle    8009a5 <readline+0x85>
			if (echoing)
  800991:	85 ff                	test   %edi,%edi
  800993:	74 0d                	je     8009a2 <readline+0x82>
				cputchar('\b');
  800995:	83 ec 0c             	sub    $0xc,%esp
  800998:	6a 08                	push   $0x8
  80099a:	e8 18 f8 ff ff       	call   8001b7 <cputchar>
  80099f:	83 c4 10             	add    $0x10,%esp
			i--;
  8009a2:	4e                   	dec    %esi
  8009a3:	eb b2                	jmp    800957 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009a5:	83 fb 1f             	cmp    $0x1f,%ebx
  8009a8:	7e 21                	jle    8009cb <readline+0xab>
  8009aa:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b0:	7f 19                	jg     8009cb <readline+0xab>
			if (echoing)
  8009b2:	85 ff                	test   %edi,%edi
  8009b4:	74 0c                	je     8009c2 <readline+0xa2>
				cputchar(c);
  8009b6:	83 ec 0c             	sub    $0xc,%esp
  8009b9:	53                   	push   %ebx
  8009ba:	e8 f8 f7 ff ff       	call   8001b7 <cputchar>
  8009bf:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c2:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009c8:	46                   	inc    %esi
  8009c9:	eb 8c                	jmp    800957 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009cb:	83 fb 0a             	cmp    $0xa,%ebx
  8009ce:	74 05                	je     8009d5 <readline+0xb5>
  8009d0:	83 fb 0d             	cmp    $0xd,%ebx
  8009d3:	75 82                	jne    800957 <readline+0x37>
			if (echoing)
  8009d5:	85 ff                	test   %edi,%edi
  8009d7:	74 0d                	je     8009e6 <readline+0xc6>
				cputchar('\n');
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	6a 0a                	push   $0xa
  8009de:	e8 d4 f7 ff ff       	call   8001b7 <cputchar>
  8009e3:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009e6:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009ed:	b8 00 40 80 00       	mov    $0x804000,%eax
  8009f2:	eb 05                	jmp    8009f9 <readline+0xd9>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8009f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
  800a01:	00 00                	add    %al,(%eax)
	...

00800a04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0a:	80 3a 00             	cmpb   $0x0,(%edx)
  800a0d:	74 0e                	je     800a1d <strlen+0x19>
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a14:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a15:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a19:	75 f9                	jne    800a14 <strlen+0x10>
  800a1b:	eb 05                	jmp    800a22 <strlen+0x1e>
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2d:	85 d2                	test   %edx,%edx
  800a2f:	74 17                	je     800a48 <strnlen+0x24>
  800a31:	80 39 00             	cmpb   $0x0,(%ecx)
  800a34:	74 19                	je     800a4f <strnlen+0x2b>
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a3b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3c:	39 d0                	cmp    %edx,%eax
  800a3e:	74 14                	je     800a54 <strnlen+0x30>
  800a40:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a44:	75 f5                	jne    800a3b <strnlen+0x17>
  800a46:	eb 0c                	jmp    800a54 <strnlen+0x30>
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	eb 05                	jmp    800a54 <strnlen+0x30>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a60:	ba 00 00 00 00       	mov    $0x0,%edx
  800a65:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a68:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a6b:	42                   	inc    %edx
  800a6c:	84 c9                	test   %cl,%cl
  800a6e:	75 f5                	jne    800a65 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a70:	5b                   	pop    %ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	53                   	push   %ebx
  800a77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a7a:	53                   	push   %ebx
  800a7b:	e8 84 ff ff ff       	call   800a04 <strlen>
  800a80:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a83:	ff 75 0c             	pushl  0xc(%ebp)
  800a86:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a89:	50                   	push   %eax
  800a8a:	e8 c7 ff ff ff       	call   800a56 <strcpy>
	return dst;
}
  800a8f:	89 d8                	mov    %ebx,%eax
  800a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa4:	85 f6                	test   %esi,%esi
  800aa6:	74 15                	je     800abd <strncpy+0x27>
  800aa8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800aad:	8a 1a                	mov    (%edx),%bl
  800aaf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab2:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab8:	41                   	inc    %ecx
  800ab9:	39 ce                	cmp    %ecx,%esi
  800abb:	77 f0                	ja     800aad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800acd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad0:	85 f6                	test   %esi,%esi
  800ad2:	74 32                	je     800b06 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800ad4:	83 fe 01             	cmp    $0x1,%esi
  800ad7:	74 22                	je     800afb <strlcpy+0x3a>
  800ad9:	8a 0b                	mov    (%ebx),%cl
  800adb:	84 c9                	test   %cl,%cl
  800add:	74 20                	je     800aff <strlcpy+0x3e>
  800adf:	89 f8                	mov    %edi,%eax
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ae6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae9:	88 08                	mov    %cl,(%eax)
  800aeb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aec:	39 f2                	cmp    %esi,%edx
  800aee:	74 11                	je     800b01 <strlcpy+0x40>
  800af0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800af4:	42                   	inc    %edx
  800af5:	84 c9                	test   %cl,%cl
  800af7:	75 f0                	jne    800ae9 <strlcpy+0x28>
  800af9:	eb 06                	jmp    800b01 <strlcpy+0x40>
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	eb 02                	jmp    800b01 <strlcpy+0x40>
  800aff:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b01:	c6 00 00             	movb   $0x0,(%eax)
  800b04:	eb 02                	jmp    800b08 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b06:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800b08:	29 f8                	sub    %edi,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b18:	8a 01                	mov    (%ecx),%al
  800b1a:	84 c0                	test   %al,%al
  800b1c:	74 10                	je     800b2e <strcmp+0x1f>
  800b1e:	3a 02                	cmp    (%edx),%al
  800b20:	75 0c                	jne    800b2e <strcmp+0x1f>
		p++, q++;
  800b22:	41                   	inc    %ecx
  800b23:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b24:	8a 01                	mov    (%ecx),%al
  800b26:	84 c0                	test   %al,%al
  800b28:	74 04                	je     800b2e <strcmp+0x1f>
  800b2a:	3a 02                	cmp    (%edx),%al
  800b2c:	74 f4                	je     800b22 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2e:	0f b6 c0             	movzbl %al,%eax
  800b31:	0f b6 12             	movzbl (%edx),%edx
  800b34:	29 d0                	sub    %edx,%eax
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	53                   	push   %ebx
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	74 1b                	je     800b64 <strncmp+0x2c>
  800b49:	8a 1a                	mov    (%edx),%bl
  800b4b:	84 db                	test   %bl,%bl
  800b4d:	74 24                	je     800b73 <strncmp+0x3b>
  800b4f:	3a 19                	cmp    (%ecx),%bl
  800b51:	75 20                	jne    800b73 <strncmp+0x3b>
  800b53:	48                   	dec    %eax
  800b54:	74 15                	je     800b6b <strncmp+0x33>
		n--, p++, q++;
  800b56:	42                   	inc    %edx
  800b57:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b58:	8a 1a                	mov    (%edx),%bl
  800b5a:	84 db                	test   %bl,%bl
  800b5c:	74 15                	je     800b73 <strncmp+0x3b>
  800b5e:	3a 19                	cmp    (%ecx),%bl
  800b60:	74 f1                	je     800b53 <strncmp+0x1b>
  800b62:	eb 0f                	jmp    800b73 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	eb 05                	jmp    800b70 <strncmp+0x38>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b70:	5b                   	pop    %ebx
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 02             	movzbl (%edx),%eax
  800b76:	0f b6 11             	movzbl (%ecx),%edx
  800b79:	29 d0                	sub    %edx,%eax
  800b7b:	eb f3                	jmp    800b70 <strncmp+0x38>

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b86:	8a 10                	mov    (%eax),%dl
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 18                	je     800ba4 <strchr+0x27>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	75 06                	jne    800b96 <strchr+0x19>
  800b90:	eb 17                	jmp    800ba9 <strchr+0x2c>
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	74 13                	je     800ba9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b96:	40                   	inc    %eax
  800b97:	8a 10                	mov    (%eax),%dl
  800b99:	84 d2                	test   %dl,%dl
  800b9b:	75 f5                	jne    800b92 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba2:	eb 05                	jmp    800ba9 <strchr+0x2c>
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb4:	8a 10                	mov    (%eax),%dl
  800bb6:	84 d2                	test   %dl,%dl
  800bb8:	74 11                	je     800bcb <strfind+0x20>
		if (*s == c)
  800bba:	38 ca                	cmp    %cl,%dl
  800bbc:	75 06                	jne    800bc4 <strfind+0x19>
  800bbe:	eb 0b                	jmp    800bcb <strfind+0x20>
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 07                	je     800bcb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc4:	40                   	inc    %eax
  800bc5:	8a 10                	mov    (%eax),%dl
  800bc7:	84 d2                	test   %dl,%dl
  800bc9:	75 f5                	jne    800bc0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bdc:	85 c9                	test   %ecx,%ecx
  800bde:	74 30                	je     800c10 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be6:	75 25                	jne    800c0d <memset+0x40>
  800be8:	f6 c1 03             	test   $0x3,%cl
  800beb:	75 20                	jne    800c0d <memset+0x40>
		c &= 0xFF;
  800bed:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	c1 e3 08             	shl    $0x8,%ebx
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	c1 e6 18             	shl    $0x18,%esi
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	c1 e0 10             	shl    $0x10,%eax
  800bff:	09 f0                	or     %esi,%eax
  800c01:	09 d0                	or     %edx,%eax
  800c03:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c05:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c08:	fc                   	cld    
  800c09:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0b:	eb 03                	jmp    800c10 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0d:	fc                   	cld    
  800c0e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c10:	89 f8                	mov    %edi,%eax
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c25:	39 c6                	cmp    %eax,%esi
  800c27:	73 34                	jae    800c5d <memmove+0x46>
  800c29:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c2c:	39 d0                	cmp    %edx,%eax
  800c2e:	73 2d                	jae    800c5d <memmove+0x46>
		s += n;
		d += n;
  800c30:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c33:	f6 c2 03             	test   $0x3,%dl
  800c36:	75 1b                	jne    800c53 <memmove+0x3c>
  800c38:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3e:	75 13                	jne    800c53 <memmove+0x3c>
  800c40:	f6 c1 03             	test   $0x3,%cl
  800c43:	75 0e                	jne    800c53 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c45:	83 ef 04             	sub    $0x4,%edi
  800c48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c4e:	fd                   	std    
  800c4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c51:	eb 07                	jmp    800c5a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c53:	4f                   	dec    %edi
  800c54:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c57:	fd                   	std    
  800c58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5a:	fc                   	cld    
  800c5b:	eb 20                	jmp    800c7d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c63:	75 13                	jne    800c78 <memmove+0x61>
  800c65:	a8 03                	test   $0x3,%al
  800c67:	75 0f                	jne    800c78 <memmove+0x61>
  800c69:	f6 c1 03             	test   $0x3,%cl
  800c6c:	75 0a                	jne    800c78 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	fc                   	cld    
  800c74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c76:	eb 05                	jmp    800c7d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c78:	89 c7                	mov    %eax,%edi
  800c7a:	fc                   	cld    
  800c7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c84:	ff 75 10             	pushl  0x10(%ebp)
  800c87:	ff 75 0c             	pushl  0xc(%ebp)
  800c8a:	ff 75 08             	pushl  0x8(%ebp)
  800c8d:	e8 85 ff ff ff       	call   800c17 <memmove>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca3:	85 ff                	test   %edi,%edi
  800ca5:	74 32                	je     800cd9 <memcmp+0x45>
		if (*s1 != *s2)
  800ca7:	8a 03                	mov    (%ebx),%al
  800ca9:	8a 0e                	mov    (%esi),%cl
  800cab:	38 c8                	cmp    %cl,%al
  800cad:	74 19                	je     800cc8 <memcmp+0x34>
  800caf:	eb 0d                	jmp    800cbe <memcmp+0x2a>
  800cb1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800cb5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800cb9:	42                   	inc    %edx
  800cba:	38 c8                	cmp    %cl,%al
  800cbc:	74 10                	je     800cce <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800cbe:	0f b6 c0             	movzbl %al,%eax
  800cc1:	0f b6 c9             	movzbl %cl,%ecx
  800cc4:	29 c8                	sub    %ecx,%eax
  800cc6:	eb 16                	jmp    800cde <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc8:	4f                   	dec    %edi
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	39 fa                	cmp    %edi,%edx
  800cd0:	75 df                	jne    800cb1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	eb 05                	jmp    800cde <memcmp+0x4a>
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cee:	39 d0                	cmp    %edx,%eax
  800cf0:	73 12                	jae    800d04 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800cf5:	38 08                	cmp    %cl,(%eax)
  800cf7:	75 06                	jne    800cff <memfind+0x1c>
  800cf9:	eb 09                	jmp    800d04 <memfind+0x21>
  800cfb:	38 08                	cmp    %cl,(%eax)
  800cfd:	74 05                	je     800d04 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cff:	40                   	inc    %eax
  800d00:	39 c2                	cmp    %eax,%edx
  800d02:	77 f7                	ja     800cfb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d12:	eb 01                	jmp    800d15 <strtol+0xf>
		s++;
  800d14:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d15:	8a 02                	mov    (%edx),%al
  800d17:	3c 20                	cmp    $0x20,%al
  800d19:	74 f9                	je     800d14 <strtol+0xe>
  800d1b:	3c 09                	cmp    $0x9,%al
  800d1d:	74 f5                	je     800d14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d1f:	3c 2b                	cmp    $0x2b,%al
  800d21:	75 08                	jne    800d2b <strtol+0x25>
		s++;
  800d23:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d24:	bf 00 00 00 00       	mov    $0x0,%edi
  800d29:	eb 13                	jmp    800d3e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2b:	3c 2d                	cmp    $0x2d,%al
  800d2d:	75 0a                	jne    800d39 <strtol+0x33>
		s++, neg = 1;
  800d2f:	8d 52 01             	lea    0x1(%edx),%edx
  800d32:	bf 01 00 00 00       	mov    $0x1,%edi
  800d37:	eb 05                	jmp    800d3e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3e:	85 db                	test   %ebx,%ebx
  800d40:	74 05                	je     800d47 <strtol+0x41>
  800d42:	83 fb 10             	cmp    $0x10,%ebx
  800d45:	75 28                	jne    800d6f <strtol+0x69>
  800d47:	8a 02                	mov    (%edx),%al
  800d49:	3c 30                	cmp    $0x30,%al
  800d4b:	75 10                	jne    800d5d <strtol+0x57>
  800d4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d51:	75 0a                	jne    800d5d <strtol+0x57>
		s += 2, base = 16;
  800d53:	83 c2 02             	add    $0x2,%edx
  800d56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5b:	eb 12                	jmp    800d6f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d5d:	85 db                	test   %ebx,%ebx
  800d5f:	75 0e                	jne    800d6f <strtol+0x69>
  800d61:	3c 30                	cmp    $0x30,%al
  800d63:	75 05                	jne    800d6a <strtol+0x64>
		s++, base = 8;
  800d65:	42                   	inc    %edx
  800d66:	b3 08                	mov    $0x8,%bl
  800d68:	eb 05                	jmp    800d6f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d74:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d76:	8a 0a                	mov    (%edx),%cl
  800d78:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d7b:	80 fb 09             	cmp    $0x9,%bl
  800d7e:	77 08                	ja     800d88 <strtol+0x82>
			dig = *s - '0';
  800d80:	0f be c9             	movsbl %cl,%ecx
  800d83:	83 e9 30             	sub    $0x30,%ecx
  800d86:	eb 1e                	jmp    800da6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d88:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d8b:	80 fb 19             	cmp    $0x19,%bl
  800d8e:	77 08                	ja     800d98 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d90:	0f be c9             	movsbl %cl,%ecx
  800d93:	83 e9 57             	sub    $0x57,%ecx
  800d96:	eb 0e                	jmp    800da6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d98:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d9b:	80 fb 19             	cmp    $0x19,%bl
  800d9e:	77 13                	ja     800db3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800da0:	0f be c9             	movsbl %cl,%ecx
  800da3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da6:	39 f1                	cmp    %esi,%ecx
  800da8:	7d 0d                	jge    800db7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800daa:	42                   	inc    %edx
  800dab:	0f af c6             	imul   %esi,%eax
  800dae:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800db1:	eb c3                	jmp    800d76 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db3:	89 c1                	mov    %eax,%ecx
  800db5:	eb 02                	jmp    800db9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbd:	74 05                	je     800dc4 <strtol+0xbe>
		*endptr = (char *) s;
  800dbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc4:	85 ff                	test   %edi,%edi
  800dc6:	74 04                	je     800dcc <strtol+0xc6>
  800dc8:	89 c8                	mov    %ecx,%eax
  800dca:	f7 d8                	neg    %eax
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	c9                   	leave  
  800dd0:	c3                   	ret    
  800dd1:	00 00                	add    %al,(%eax)
	...

00800dd4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 1c             	sub    $0x1c,%esp
  800ddd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800de0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800de3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	8b 75 14             	mov    0x14(%ebp),%esi
  800de8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800deb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df1:	cd 30                	int    $0x30
  800df3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800df9:	74 1c                	je     800e17 <syscall+0x43>
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 18                	jle    800e17 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	50                   	push   %eax
  800e03:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e06:	68 0f 24 80 00       	push   $0x80240f
  800e0b:	6a 42                	push   $0x42
  800e0d:	68 2c 24 80 00       	push   $0x80242c
  800e12:	e8 cd f4 ff ff       	call   8002e4 <_panic>

	return ret;
}
  800e17:	89 d0                	mov    %edx,%eax
  800e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e27:	6a 00                	push   $0x0
  800e29:	6a 00                	push   $0x0
  800e2b:	6a 00                	push   $0x0
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	ba 00 00 00 00       	mov    $0x0,%edx
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	e8 92 ff ff ff       	call   800dd4 <syscall>
  800e42:	83 c4 10             	add    $0x10,%esp
	return;
}
  800e45:	c9                   	leave  
  800e46:	c3                   	ret    

00800e47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e4d:	6a 00                	push   $0x0
  800e4f:	6a 00                	push   $0x0
  800e51:	6a 00                	push   $0x0
  800e53:	6a 00                	push   $0x0
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e64:	e8 6b ff ff ff       	call   800dd4 <syscall>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e71:	6a 00                	push   $0x0
  800e73:	6a 00                	push   $0x0
  800e75:	6a 00                	push   $0x0
  800e77:	6a 00                	push   $0x0
  800e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e81:	b8 03 00 00 00       	mov    $0x3,%eax
  800e86:	e8 49 ff ff ff       	call   800dd4 <syscall>
}
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800e93:	6a 00                	push   $0x0
  800e95:	6a 00                	push   $0x0
  800e97:	6a 00                	push   $0x0
  800e99:	6a 00                	push   $0x0
  800e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea5:	b8 02 00 00 00       	mov    $0x2,%eax
  800eaa:	e8 25 ff ff ff       	call   800dd4 <syscall>
}
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <sys_yield>:

void
sys_yield(void)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800eb7:	6a 00                	push   $0x0
  800eb9:	6a 00                	push   $0x0
  800ebb:	6a 00                	push   $0x0
  800ebd:	6a 00                	push   $0x0
  800ebf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ece:	e8 01 ff ff ff       	call   800dd4 <syscall>
  800ed3:	83 c4 10             	add    $0x10,%esp
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ede:	6a 00                	push   $0x0
  800ee0:	6a 00                	push   $0x0
  800ee2:	ff 75 10             	pushl  0x10(%ebp)
  800ee5:	ff 75 0c             	pushl  0xc(%ebp)
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef5:	e8 da fe ff ff       	call   800dd4 <syscall>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f02:	ff 75 18             	pushl  0x18(%ebp)
  800f05:	ff 75 14             	pushl  0x14(%ebp)
  800f08:	ff 75 10             	pushl  0x10(%ebp)
  800f0b:	ff 75 0c             	pushl  0xc(%ebp)
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	ba 01 00 00 00       	mov    $0x1,%edx
  800f16:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1b:	e8 b4 fe ff ff       	call   800dd4 <syscall>
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f28:	6a 00                	push   $0x0
  800f2a:	6a 00                	push   $0x0
  800f2c:	6a 00                	push   $0x0
  800f2e:	ff 75 0c             	pushl  0xc(%ebp)
  800f31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f34:	ba 01 00 00 00       	mov    $0x1,%edx
  800f39:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3e:	e8 91 fe ff ff       	call   800dd4 <syscall>
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f4b:	6a 00                	push   $0x0
  800f4d:	6a 00                	push   $0x0
  800f4f:	6a 00                	push   $0x0
  800f51:	ff 75 0c             	pushl  0xc(%ebp)
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	ba 01 00 00 00       	mov    $0x1,%edx
  800f5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f61:	e8 6e fe ff ff       	call   800dd4 <syscall>
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f6e:	6a 00                	push   $0x0
  800f70:	6a 00                	push   $0x0
  800f72:	6a 00                	push   $0x0
  800f74:	ff 75 0c             	pushl  0xc(%ebp)
  800f77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7a:	ba 01 00 00 00       	mov    $0x1,%edx
  800f7f:	b8 09 00 00 00       	mov    $0x9,%eax
  800f84:	e8 4b fe ff ff       	call   800dd4 <syscall>
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f91:	6a 00                	push   $0x0
  800f93:	6a 00                	push   $0x0
  800f95:	6a 00                	push   $0x0
  800f97:	ff 75 0c             	pushl  0xc(%ebp)
  800f9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa7:	e8 28 fe ff ff       	call   800dd4 <syscall>
}
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    

00800fae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800fb4:	6a 00                	push   $0x0
  800fb6:	ff 75 14             	pushl  0x14(%ebp)
  800fb9:	ff 75 10             	pushl  0x10(%ebp)
  800fbc:	ff 75 0c             	pushl  0xc(%ebp)
  800fbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fcc:	e8 03 fe ff ff       	call   800dd4 <syscall>
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800fd9:	6a 00                	push   $0x0
  800fdb:	6a 00                	push   $0x0
  800fdd:	6a 00                	push   $0x0
  800fdf:	6a 00                	push   $0x0
  800fe1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe4:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fee:	e8 e1 fd ff ff       	call   800dd4 <syscall>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ffb:	6a 00                	push   $0x0
  800ffd:	6a 00                	push   $0x0
  800fff:	6a 00                	push   $0x0
  801001:	ff 75 0c             	pushl  0xc(%ebp)
  801004:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801007:	ba 00 00 00 00       	mov    $0x0,%edx
  80100c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801011:	e8 be fd ff ff       	call   800dd4 <syscall>
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80101e:	6a 00                	push   $0x0
  801020:	ff 75 14             	pushl  0x14(%ebp)
  801023:	ff 75 10             	pushl  0x10(%ebp)
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80102c:	ba 00 00 00 00       	mov    $0x0,%edx
  801031:	b8 0f 00 00 00       	mov    $0xf,%eax
  801036:	e8 99 fd ff ff       	call   800dd4 <syscall>
} 
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  801043:	6a 00                	push   $0x0
  801045:	6a 00                	push   $0x0
  801047:	6a 00                	push   $0x0
  801049:	6a 00                	push   $0x0
  80104b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	b8 11 00 00 00       	mov    $0x11,%eax
  801058:	e8 77 fd ff ff       	call   800dd4 <syscall>
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <sys_getpid>:

envid_t
sys_getpid(void)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  801065:	6a 00                	push   $0x0
  801067:	6a 00                	push   $0x0
  801069:	6a 00                	push   $0x0
  80106b:	6a 00                	push   $0x0
  80106d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801072:	ba 00 00 00 00       	mov    $0x0,%edx
  801077:	b8 10 00 00 00       	mov    $0x10,%eax
  80107c:	e8 53 fd ff ff       	call   800dd4 <syscall>
  801081:	c9                   	leave  
  801082:	c3                   	ret    
	...

00801084 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	05 00 00 00 30       	add    $0x30000000,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801097:	ff 75 08             	pushl  0x8(%ebp)
  80109a:	e8 e5 ff ff ff       	call   801084 <fd2num>
  80109f:	83 c4 04             	add    $0x4,%esp
  8010a2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010a7:	c1 e0 0c             	shl    $0xc,%eax
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	53                   	push   %ebx
  8010b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010b8:	a8 01                	test   $0x1,%al
  8010ba:	74 34                	je     8010f0 <fd_alloc+0x44>
  8010bc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010c1:	a8 01                	test   $0x1,%al
  8010c3:	74 32                	je     8010f7 <fd_alloc+0x4b>
  8010c5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010ca:	89 c1                	mov    %eax,%ecx
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	c1 ea 16             	shr    $0x16,%edx
  8010d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d8:	f6 c2 01             	test   $0x1,%dl
  8010db:	74 1f                	je     8010fc <fd_alloc+0x50>
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	c1 ea 0c             	shr    $0xc,%edx
  8010e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e9:	f6 c2 01             	test   $0x1,%dl
  8010ec:	75 17                	jne    801105 <fd_alloc+0x59>
  8010ee:	eb 0c                	jmp    8010fc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010f0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010f5:	eb 05                	jmp    8010fc <fd_alloc+0x50>
  8010f7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010fc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	eb 17                	jmp    80111c <fd_alloc+0x70>
  801105:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80110a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110f:	75 b9                	jne    8010ca <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801117:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80111c:	5b                   	pop    %ebx
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801125:	83 f8 1f             	cmp    $0x1f,%eax
  801128:	77 36                	ja     801160 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80112f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 16             	shr    $0x16,%edx
  801137:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 24                	je     801167 <fd_lookup+0x48>
  801143:	89 c2                	mov    %eax,%edx
  801145:	c1 ea 0c             	shr    $0xc,%edx
  801148:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114f:	f6 c2 01             	test   $0x1,%dl
  801152:	74 1a                	je     80116e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801154:	8b 55 0c             	mov    0xc(%ebp),%edx
  801157:	89 02                	mov    %eax,(%edx)
	return 0;
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
  80115e:	eb 13                	jmp    801173 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801165:	eb 0c                	jmp    801173 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801167:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116c:	eb 05                	jmp    801173 <fd_lookup+0x54>
  80116e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	53                   	push   %ebx
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801182:	39 0d 20 30 80 00    	cmp    %ecx,0x803020
  801188:	74 0d                	je     801197 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
  80118f:	eb 14                	jmp    8011a5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801191:	39 0a                	cmp    %ecx,(%edx)
  801193:	75 10                	jne    8011a5 <dev_lookup+0x30>
  801195:	eb 05                	jmp    80119c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801197:	ba 20 30 80 00       	mov    $0x803020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80119c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb 31                	jmp    8011d6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a5:	40                   	inc    %eax
  8011a6:	8b 14 85 bc 24 80 00 	mov    0x8024bc(,%eax,4),%edx
  8011ad:	85 d2                	test   %edx,%edx
  8011af:	75 e0                	jne    801191 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b1:	a1 04 44 80 00       	mov    0x804404,%eax
  8011b6:	8b 40 48             	mov    0x48(%eax),%eax
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	51                   	push   %ecx
  8011bd:	50                   	push   %eax
  8011be:	68 3c 24 80 00       	push   $0x80243c
  8011c3:	e8 f4 f1 ff ff       	call   8003bc <cprintf>
	*dev = 0;
  8011c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 20             	sub    $0x20,%esp
  8011e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e6:	8a 45 0c             	mov    0xc(%ebp),%al
  8011e9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ec:	56                   	push   %esi
  8011ed:	e8 92 fe ff ff       	call   801084 <fd2num>
  8011f2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011f5:	89 14 24             	mov    %edx,(%esp)
  8011f8:	50                   	push   %eax
  8011f9:	e8 21 ff ff ff       	call   80111f <fd_lookup>
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 05                	js     80120c <fd_close+0x31>
	    || fd != fd2)
  801207:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80120a:	74 0d                	je     801219 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80120c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801210:	75 48                	jne    80125a <fd_close+0x7f>
  801212:	bb 00 00 00 00       	mov    $0x0,%ebx
  801217:	eb 41                	jmp    80125a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 36                	pushl  (%esi)
  801222:	e8 4e ff ff ff       	call   801175 <dev_lookup>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 1c                	js     80124c <fd_close+0x71>
		if (dev->dev_close)
  801230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801233:	8b 40 10             	mov    0x10(%eax),%eax
  801236:	85 c0                	test   %eax,%eax
  801238:	74 0d                	je     801247 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80123a:	83 ec 0c             	sub    $0xc,%esp
  80123d:	56                   	push   %esi
  80123e:	ff d0                	call   *%eax
  801240:	89 c3                	mov    %eax,%ebx
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	eb 05                	jmp    80124c <fd_close+0x71>
		else
			r = 0;
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	56                   	push   %esi
  801250:	6a 00                	push   $0x0
  801252:	e8 cb fc ff ff       	call   800f22 <sys_page_unmap>
	return r;
  801257:	83 c4 10             	add    $0x10,%esp
}
  80125a:	89 d8                	mov    %ebx,%eax
  80125c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 aa fe ff ff       	call   80111f <fd_lookup>
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 10                	js     80128c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	6a 01                	push   $0x1
  801281:	ff 75 f4             	pushl  -0xc(%ebp)
  801284:	e8 52 ff ff ff       	call   8011db <fd_close>
  801289:	83 c4 10             	add    $0x10,%esp
}
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <close_all>:

void
close_all(void)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	53                   	push   %ebx
  801292:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	53                   	push   %ebx
  80129e:	e8 c0 ff ff ff       	call   801263 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a3:	43                   	inc    %ebx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	83 fb 20             	cmp    $0x20,%ebx
  8012aa:	75 ee                	jne    80129a <close_all+0xc>
		close(i);
}
  8012ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 2c             	sub    $0x2c,%esp
  8012ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 08             	pushl  0x8(%ebp)
  8012c4:	e8 56 fe ff ff       	call   80111f <fd_lookup>
  8012c9:	89 c3                	mov    %eax,%ebx
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	0f 88 c0 00 00 00    	js     801396 <dup+0xe5>
		return r;
	close(newfdnum);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	57                   	push   %edi
  8012da:	e8 84 ff ff ff       	call   801263 <close>

	newfd = INDEX2FD(newfdnum);
  8012df:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012e5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8012e8:	83 c4 04             	add    $0x4,%esp
  8012eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ee:	e8 a1 fd ff ff       	call   801094 <fd2data>
  8012f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012f5:	89 34 24             	mov    %esi,(%esp)
  8012f8:	e8 97 fd ff ff       	call   801094 <fd2data>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 16             	shr    $0x16,%eax
  801308:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130f:	a8 01                	test   $0x1,%al
  801311:	74 37                	je     80134a <dup+0x99>
  801313:	89 d8                	mov    %ebx,%eax
  801315:	c1 e8 0c             	shr    $0xc,%eax
  801318:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131f:	f6 c2 01             	test   $0x1,%dl
  801322:	74 26                	je     80134a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801324:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	25 07 0e 00 00       	and    $0xe07,%eax
  801333:	50                   	push   %eax
  801334:	ff 75 d4             	pushl  -0x2c(%ebp)
  801337:	6a 00                	push   $0x0
  801339:	53                   	push   %ebx
  80133a:	6a 00                	push   $0x0
  80133c:	e8 bb fb ff ff       	call   800efc <sys_page_map>
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 20             	add    $0x20,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 2d                	js     801377 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	c1 ea 0c             	shr    $0xc,%edx
  801352:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801362:	52                   	push   %edx
  801363:	56                   	push   %esi
  801364:	6a 00                	push   $0x0
  801366:	50                   	push   %eax
  801367:	6a 00                	push   $0x0
  801369:	e8 8e fb ff ff       	call   800efc <sys_page_map>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 20             	add    $0x20,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	79 1d                	jns    801394 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	56                   	push   %esi
  80137b:	6a 00                	push   $0x0
  80137d:	e8 a0 fb ff ff       	call   800f22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801382:	83 c4 08             	add    $0x8,%esp
  801385:	ff 75 d4             	pushl  -0x2c(%ebp)
  801388:	6a 00                	push   $0x0
  80138a:	e8 93 fb ff ff       	call   800f22 <sys_page_unmap>
	return r;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	eb 02                	jmp    801396 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801394:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801396:	89 d8                	mov    %ebx,%eax
  801398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 14             	sub    $0x14,%esp
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	53                   	push   %ebx
  8013af:	e8 6b fd ff ff       	call   80111f <fd_lookup>
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 67                	js     801422 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c5:	ff 30                	pushl  (%eax)
  8013c7:	e8 a9 fd ff ff       	call   801175 <dev_lookup>
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 4f                	js     801422 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	8b 50 08             	mov    0x8(%eax),%edx
  8013d9:	83 e2 03             	and    $0x3,%edx
  8013dc:	83 fa 01             	cmp    $0x1,%edx
  8013df:	75 21                	jne    801402 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e1:	a1 04 44 80 00       	mov    0x804404,%eax
  8013e6:	8b 40 48             	mov    0x48(%eax),%eax
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	50                   	push   %eax
  8013ee:	68 80 24 80 00       	push   $0x802480
  8013f3:	e8 c4 ef ff ff       	call   8003bc <cprintf>
		return -E_INVAL;
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801400:	eb 20                	jmp    801422 <read+0x82>
	}
	if (!dev->dev_read)
  801402:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801405:	8b 52 08             	mov    0x8(%edx),%edx
  801408:	85 d2                	test   %edx,%edx
  80140a:	74 11                	je     80141d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80140c:	83 ec 04             	sub    $0x4,%esp
  80140f:	ff 75 10             	pushl  0x10(%ebp)
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	50                   	push   %eax
  801416:	ff d2                	call   *%edx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	eb 05                	jmp    801422 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80141d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
  801433:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801436:	85 f6                	test   %esi,%esi
  801438:	74 31                	je     80146b <readn+0x44>
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	89 f2                	mov    %esi,%edx
  801449:	29 c2                	sub    %eax,%edx
  80144b:	52                   	push   %edx
  80144c:	03 45 0c             	add    0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	57                   	push   %edi
  801451:	e8 4a ff ff ff       	call   8013a0 <read>
		if (m < 0)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 17                	js     801474 <readn+0x4d>
			return m;
		if (m == 0)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	74 11                	je     801472 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801461:	01 c3                	add    %eax,%ebx
  801463:	89 d8                	mov    %ebx,%eax
  801465:	39 f3                	cmp    %esi,%ebx
  801467:	72 db                	jb     801444 <readn+0x1d>
  801469:	eb 09                	jmp    801474 <readn+0x4d>
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
  801470:	eb 02                	jmp    801474 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801472:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 14             	sub    $0x14,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	e8 8f fc ff ff       	call   80111f <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 62                	js     8014f9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a1:	ff 30                	pushl  (%eax)
  8014a3:	e8 cd fc ff ff       	call   801175 <dev_lookup>
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 4a                	js     8014f9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b6:	75 21                	jne    8014d9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b8:	a1 04 44 80 00       	mov    0x804404,%eax
  8014bd:	8b 40 48             	mov    0x48(%eax),%eax
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	50                   	push   %eax
  8014c5:	68 9c 24 80 00       	push   $0x80249c
  8014ca:	e8 ed ee ff ff       	call   8003bc <cprintf>
		return -E_INVAL;
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d7:	eb 20                	jmp    8014f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	74 11                	je     8014f4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	50                   	push   %eax
  8014ed:	ff d2                	call   *%edx
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	eb 05                	jmp    8014f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801504:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	ff 75 08             	pushl  0x8(%ebp)
  80150b:	e8 0f fc ff ff       	call   80111f <fd_lookup>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 0e                	js     801525 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801517:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80151a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801520:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	53                   	push   %ebx
  80152b:	83 ec 14             	sub    $0x14,%esp
  80152e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	53                   	push   %ebx
  801536:	e8 e4 fb ff ff       	call   80111f <fd_lookup>
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 5f                	js     8015a1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	ff 30                	pushl  (%eax)
  80154e:	e8 22 fc ff ff       	call   801175 <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 47                	js     8015a1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801561:	75 21                	jne    801584 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801563:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801568:	8b 40 48             	mov    0x48(%eax),%eax
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	53                   	push   %ebx
  80156f:	50                   	push   %eax
  801570:	68 5c 24 80 00       	push   $0x80245c
  801575:	e8 42 ee ff ff       	call   8003bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801582:	eb 1d                	jmp    8015a1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801584:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801587:	8b 52 18             	mov    0x18(%edx),%edx
  80158a:	85 d2                	test   %edx,%edx
  80158c:	74 0e                	je     80159c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	50                   	push   %eax
  801595:	ff d2                	call   *%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 05                	jmp    8015a1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 08             	pushl  0x8(%ebp)
  8015b7:	e8 63 fb ff ff       	call   80111f <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 52                	js     801615 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	ff 30                	pushl  (%eax)
  8015cf:	e8 a1 fb ff ff       	call   801175 <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 3a                	js     801615 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e2:	74 2c                	je     801610 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ee:	00 00 00 
	stat->st_isdir = 0;
  8015f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f8:	00 00 00 
	stat->st_dev = dev;
  8015fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	53                   	push   %ebx
  801605:	ff 75 f0             	pushl  -0x10(%ebp)
  801608:	ff 50 14             	call   *0x14(%eax)
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801610:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	6a 00                	push   $0x0
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 78 01 00 00       	call   8017a4 <open>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 1b                	js     801650 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	ff 75 0c             	pushl  0xc(%ebp)
  80163b:	50                   	push   %eax
  80163c:	e8 65 ff ff ff       	call   8015a6 <fstat>
  801641:	89 c6                	mov    %eax,%esi
	close(fd);
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 18 fc ff ff       	call   801263 <close>
	return r;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	89 f3                	mov    %esi,%ebx
}
  801650:	89 d8                	mov    %ebx,%eax
  801652:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	c9                   	leave  
  801658:	c3                   	ret    
  801659:	00 00                	add    %al,(%eax)
	...

0080165c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	89 c3                	mov    %eax,%ebx
  801663:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801665:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80166c:	75 12                	jne    801680 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	6a 01                	push   $0x1
  801673:	e8 0e 07 00 00       	call   801d86 <ipc_find_env>
  801678:	a3 00 44 80 00       	mov    %eax,0x804400
  80167d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801680:	6a 07                	push   $0x7
  801682:	68 00 50 80 00       	push   $0x805000
  801687:	53                   	push   %ebx
  801688:	ff 35 00 44 80 00    	pushl  0x804400
  80168e:	e8 9e 06 00 00       	call   801d31 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801693:	83 c4 0c             	add    $0xc,%esp
  801696:	6a 00                	push   $0x0
  801698:	56                   	push   %esi
  801699:	6a 00                	push   $0x0
  80169b:	e8 1c 06 00 00       	call   801cbc <ipc_recv>
}
  8016a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a3:	5b                   	pop    %ebx
  8016a4:	5e                   	pop    %esi
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c6:	e8 91 ff ff ff       	call   80165c <fsipc>
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 2c                	js     8016fb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	68 00 50 80 00       	push   $0x805000
  8016d7:	53                   	push   %ebx
  8016d8:	e8 79 f3 ff ff       	call   800a56 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8016e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	8b 40 0c             	mov    0xc(%eax),%eax
  80170c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 06 00 00 00       	mov    $0x6,%eax
  80171b:	e8 3c ff ff ff       	call   80165c <fsipc>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	8b 40 0c             	mov    0xc(%eax),%eax
  801730:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801735:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
  801740:	b8 03 00 00 00       	mov    $0x3,%eax
  801745:	e8 12 ff ff ff       	call   80165c <fsipc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 4b                	js     80179b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801750:	39 c6                	cmp    %eax,%esi
  801752:	73 16                	jae    80176a <devfile_read+0x48>
  801754:	68 cc 24 80 00       	push   $0x8024cc
  801759:	68 d3 24 80 00       	push   $0x8024d3
  80175e:	6a 7d                	push   $0x7d
  801760:	68 e8 24 80 00       	push   $0x8024e8
  801765:	e8 7a eb ff ff       	call   8002e4 <_panic>
	assert(r <= PGSIZE);
  80176a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80176f:	7e 16                	jle    801787 <devfile_read+0x65>
  801771:	68 f3 24 80 00       	push   $0x8024f3
  801776:	68 d3 24 80 00       	push   $0x8024d3
  80177b:	6a 7e                	push   $0x7e
  80177d:	68 e8 24 80 00       	push   $0x8024e8
  801782:	e8 5d eb ff ff       	call   8002e4 <_panic>
	memmove(buf, &fsipcbuf, r);
  801787:	83 ec 04             	sub    $0x4,%esp
  80178a:	50                   	push   %eax
  80178b:	68 00 50 80 00       	push   $0x805000
  801790:	ff 75 0c             	pushl  0xc(%ebp)
  801793:	e8 7f f4 ff ff       	call   800c17 <memmove>
	return r;
  801798:	83 c4 10             	add    $0x10,%esp
}
  80179b:	89 d8                	mov    %ebx,%eax
  80179d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 1c             	sub    $0x1c,%esp
  8017ac:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017af:	56                   	push   %esi
  8017b0:	e8 4f f2 ff ff       	call   800a04 <strlen>
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017bd:	7f 65                	jg     801824 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	e8 e1 f8 ff ff       	call   8010ac <fd_alloc>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 55                	js     801829 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	56                   	push   %esi
  8017d8:	68 00 50 80 00       	push   $0x805000
  8017dd:	e8 74 f2 ff ff       	call   800a56 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f2:	e8 65 fe ff ff       	call   80165c <fsipc>
  8017f7:	89 c3                	mov    %eax,%ebx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	79 12                	jns    801812 <open+0x6e>
		fd_close(fd, 0);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	6a 00                	push   $0x0
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 ce f9 ff ff       	call   8011db <fd_close>
		return r;
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	eb 17                	jmp    801829 <open+0x85>
	}

	return fd2num(fd);
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	ff 75 f4             	pushl  -0xc(%ebp)
  801818:	e8 67 f8 ff ff       	call   801084 <fd2num>
  80181d:	89 c3                	mov    %eax,%ebx
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	eb 05                	jmp    801829 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801824:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801829:	89 d8                	mov    %ebx,%eax
  80182b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	c9                   	leave  
  801831:	c3                   	ret    
	...

00801834 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80183d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801841:	7e 2e                	jle    801871 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	ff 70 04             	pushl  0x4(%eax)
  801849:	8d 40 10             	lea    0x10(%eax),%eax
  80184c:	50                   	push   %eax
  80184d:	ff 33                	pushl  (%ebx)
  80184f:	e8 28 fc ff ff       	call   80147c <write>
		if (result > 0)
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	7e 03                	jle    80185e <writebuf+0x2a>
			b->result += result;
  80185b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80185e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801861:	74 0e                	je     801871 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  801863:	89 c2                	mov    %eax,%edx
  801865:	85 c0                	test   %eax,%eax
  801867:	7e 05                	jle    80186e <writebuf+0x3a>
  801869:	ba 00 00 00 00       	mov    $0x0,%edx
  80186e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <putch>:

static void
putch(int ch, void *thunk)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	53                   	push   %ebx
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801880:	8b 43 04             	mov    0x4(%ebx),%eax
  801883:	8b 55 08             	mov    0x8(%ebp),%edx
  801886:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80188a:	40                   	inc    %eax
  80188b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80188e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801893:	75 0e                	jne    8018a3 <putch+0x2d>
		writebuf(b);
  801895:	89 d8                	mov    %ebx,%eax
  801897:	e8 98 ff ff ff       	call   801834 <writebuf>
		b->idx = 0;
  80189c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018a3:	83 c4 04             	add    $0x4,%esp
  8018a6:	5b                   	pop    %ebx
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018bb:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018c2:	00 00 00 
	b.result = 0;
  8018c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018cc:	00 00 00 
	b.error = 1;
  8018cf:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018d6:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018d9:	ff 75 10             	pushl  0x10(%ebp)
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	68 76 18 80 00       	push   $0x801876
  8018eb:	e8 31 ec ff ff       	call   800521 <vprintfmt>
	if (b.idx > 0)
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018fa:	7e 0b                	jle    801907 <vfprintf+0x5e>
		writebuf(&b);
  8018fc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801902:	e8 2d ff ff ff       	call   801834 <writebuf>

	return (b.result ? b.result : b.error);
  801907:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80190d:	85 c0                	test   %eax,%eax
  80190f:	75 06                	jne    801917 <vfprintf+0x6e>
  801911:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80191f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801922:	50                   	push   %eax
  801923:	ff 75 0c             	pushl  0xc(%ebp)
  801926:	ff 75 08             	pushl  0x8(%ebp)
  801929:	e8 7b ff ff ff       	call   8018a9 <vfprintf>
	va_end(ap);

	return cnt;
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <printf>:

int
printf(const char *fmt, ...)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801936:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801939:	50                   	push   %eax
  80193a:	ff 75 08             	pushl  0x8(%ebp)
  80193d:	6a 01                	push   $0x1
  80193f:	e8 65 ff ff ff       	call   8018a9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    
	...

00801948 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	ff 75 08             	pushl  0x8(%ebp)
  801956:	e8 39 f7 ff ff       	call   801094 <fd2data>
  80195b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80195d:	83 c4 08             	add    $0x8,%esp
  801960:	68 ff 24 80 00       	push   $0x8024ff
  801965:	56                   	push   %esi
  801966:	e8 eb f0 ff ff       	call   800a56 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196b:	8b 43 04             	mov    0x4(%ebx),%eax
  80196e:	2b 03                	sub    (%ebx),%eax
  801970:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801976:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80197d:	00 00 00 
	stat->st_dev = &devpipe;
  801980:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801987:	30 80 00 
	return 0;
}
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a0:	53                   	push   %ebx
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 7a f5 ff ff       	call   800f22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a8:	89 1c 24             	mov    %ebx,(%esp)
  8019ab:	e8 e4 f6 ff ff       	call   801094 <fd2data>
  8019b0:	83 c4 08             	add    $0x8,%esp
  8019b3:	50                   	push   %eax
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 67 f5 ff ff       	call   800f22 <sys_page_unmap>
}
  8019bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 1c             	sub    $0x1c,%esp
  8019c9:	89 c7                	mov    %eax,%edi
  8019cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ce:	a1 04 44 80 00       	mov    0x804404,%eax
  8019d3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	57                   	push   %edi
  8019da:	e8 f5 03 00 00       	call   801dd4 <pageref>
  8019df:	89 c6                	mov    %eax,%esi
  8019e1:	83 c4 04             	add    $0x4,%esp
  8019e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e7:	e8 e8 03 00 00       	call   801dd4 <pageref>
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	39 c6                	cmp    %eax,%esi
  8019f1:	0f 94 c0             	sete   %al
  8019f4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019f7:	8b 15 04 44 80 00    	mov    0x804404,%edx
  8019fd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a00:	39 cb                	cmp    %ecx,%ebx
  801a02:	75 08                	jne    801a0c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a07:	5b                   	pop    %ebx
  801a08:	5e                   	pop    %esi
  801a09:	5f                   	pop    %edi
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a0c:	83 f8 01             	cmp    $0x1,%eax
  801a0f:	75 bd                	jne    8019ce <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a11:	8b 42 58             	mov    0x58(%edx),%eax
  801a14:	6a 01                	push   $0x1
  801a16:	50                   	push   %eax
  801a17:	53                   	push   %ebx
  801a18:	68 06 25 80 00       	push   $0x802506
  801a1d:	e8 9a e9 ff ff       	call   8003bc <cprintf>
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	eb a7                	jmp    8019ce <_pipeisclosed+0xe>

00801a27 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	57                   	push   %edi
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 28             	sub    $0x28,%esp
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a33:	56                   	push   %esi
  801a34:	e8 5b f6 ff ff       	call   801094 <fd2data>
  801a39:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a42:	75 4a                	jne    801a8e <devpipe_write+0x67>
  801a44:	bf 00 00 00 00       	mov    $0x0,%edi
  801a49:	eb 56                	jmp    801aa1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4b:	89 da                	mov    %ebx,%edx
  801a4d:	89 f0                	mov    %esi,%eax
  801a4f:	e8 6c ff ff ff       	call   8019c0 <_pipeisclosed>
  801a54:	85 c0                	test   %eax,%eax
  801a56:	75 4d                	jne    801aa5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a58:	e8 54 f4 ff ff       	call   800eb1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a5d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a60:	8b 13                	mov    (%ebx),%edx
  801a62:	83 c2 20             	add    $0x20,%edx
  801a65:	39 d0                	cmp    %edx,%eax
  801a67:	73 e2                	jae    801a4b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a71:	79 05                	jns    801a78 <devpipe_write+0x51>
  801a73:	4a                   	dec    %edx
  801a74:	83 ca e0             	or     $0xffffffe0,%edx
  801a77:	42                   	inc    %edx
  801a78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a82:	40                   	inc    %eax
  801a83:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a86:	47                   	inc    %edi
  801a87:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a8a:	77 07                	ja     801a93 <devpipe_write+0x6c>
  801a8c:	eb 13                	jmp    801aa1 <devpipe_write+0x7a>
  801a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a93:	8b 43 04             	mov    0x4(%ebx),%eax
  801a96:	8b 13                	mov    (%ebx),%edx
  801a98:	83 c2 20             	add    $0x20,%edx
  801a9b:	39 d0                	cmp    %edx,%eax
  801a9d:	73 ac                	jae    801a4b <devpipe_write+0x24>
  801a9f:	eb c8                	jmp    801a69 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa1:	89 f8                	mov    %edi,%eax
  801aa3:	eb 05                	jmp    801aaa <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	57                   	push   %edi
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 18             	sub    $0x18,%esp
  801abb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abe:	57                   	push   %edi
  801abf:	e8 d0 f5 ff ff       	call   801094 <fd2data>
  801ac4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801acd:	75 44                	jne    801b13 <devpipe_read+0x61>
  801acf:	be 00 00 00 00       	mov    $0x0,%esi
  801ad4:	eb 4f                	jmp    801b25 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ad6:	89 f0                	mov    %esi,%eax
  801ad8:	eb 54                	jmp    801b2e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ada:	89 da                	mov    %ebx,%edx
  801adc:	89 f8                	mov    %edi,%eax
  801ade:	e8 dd fe ff ff       	call   8019c0 <_pipeisclosed>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	75 42                	jne    801b29 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae7:	e8 c5 f3 ff ff       	call   800eb1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aec:	8b 03                	mov    (%ebx),%eax
  801aee:	3b 43 04             	cmp    0x4(%ebx),%eax
  801af1:	74 e7                	je     801ada <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801af8:	79 05                	jns    801aff <devpipe_read+0x4d>
  801afa:	48                   	dec    %eax
  801afb:	83 c8 e0             	or     $0xffffffe0,%eax
  801afe:	40                   	inc    %eax
  801aff:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b06:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b09:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	46                   	inc    %esi
  801b0c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b0f:	77 07                	ja     801b18 <devpipe_read+0x66>
  801b11:	eb 12                	jmp    801b25 <devpipe_read+0x73>
  801b13:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b18:	8b 03                	mov    (%ebx),%eax
  801b1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b1d:	75 d4                	jne    801af3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1f:	85 f6                	test   %esi,%esi
  801b21:	75 b3                	jne    801ad6 <devpipe_read+0x24>
  801b23:	eb b5                	jmp    801ada <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b25:	89 f0                	mov    %esi,%eax
  801b27:	eb 05                	jmp    801b2e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	57                   	push   %edi
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 28             	sub    $0x28,%esp
  801b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	e8 61 f5 ff ff       	call   8010ac <fd_alloc>
  801b4b:	89 c3                	mov    %eax,%ebx
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	0f 88 24 01 00 00    	js     801c7c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	68 07 04 00 00       	push   $0x407
  801b60:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b63:	6a 00                	push   $0x0
  801b65:	e8 6e f3 ff ff       	call   800ed8 <sys_page_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 05 01 00 00    	js     801c7c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	e8 29 f5 ff ff       	call   8010ac <fd_alloc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 dc 00 00 00    	js     801c6c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	68 07 04 00 00       	push   $0x407
  801b98:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 36 f3 ff ff       	call   800ed8 <sys_page_alloc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	0f 88 bd 00 00 00    	js     801c6c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb5:	e8 da f4 ff ff       	call   801094 <fd2data>
  801bba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 c4 0c             	add    $0xc,%esp
  801bbf:	68 07 04 00 00       	push   $0x407
  801bc4:	50                   	push   %eax
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 0c f3 ff ff       	call   800ed8 <sys_page_alloc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 83 00 00 00    	js     801c5c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bdf:	e8 b0 f4 ff ff       	call   801094 <fd2data>
  801be4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801beb:	50                   	push   %eax
  801bec:	6a 00                	push   $0x0
  801bee:	56                   	push   %esi
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 06 f3 ff ff       	call   800efc <sys_page_map>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 20             	add    $0x20,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 4f                	js     801c4e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2f:	e8 50 f4 ff ff       	call   801084 <fd2num>
  801c34:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c36:	83 c4 04             	add    $0x4,%esp
  801c39:	ff 75 e0             	pushl  -0x20(%ebp)
  801c3c:	e8 43 f4 ff ff       	call   801084 <fd2num>
  801c41:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4c:	eb 2e                	jmp    801c7c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c4e:	83 ec 08             	sub    $0x8,%esp
  801c51:	56                   	push   %esi
  801c52:	6a 00                	push   $0x0
  801c54:	e8 c9 f2 ff ff       	call   800f22 <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	ff 75 e0             	pushl  -0x20(%ebp)
  801c62:	6a 00                	push   $0x0
  801c64:	e8 b9 f2 ff ff       	call   800f22 <sys_page_unmap>
  801c69:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c6c:	83 ec 08             	sub    $0x8,%esp
  801c6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c72:	6a 00                	push   $0x0
  801c74:	e8 a9 f2 ff ff       	call   800f22 <sys_page_unmap>
  801c79:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	ff 75 08             	pushl  0x8(%ebp)
  801c93:	e8 87 f4 ff ff       	call   80111f <fd_lookup>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 18                	js     801cb7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca5:	e8 ea f3 ff ff       	call   801094 <fd2data>
	return _pipeisclosed(fd, p);
  801caa:	89 c2                	mov    %eax,%edx
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	e8 0c fd ff ff       	call   8019c0 <_pipeisclosed>
  801cb4:	83 c4 10             	add    $0x10,%esp
}
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    
  801cb9:	00 00                	add    %al,(%eax)
	...

00801cbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	74 0e                	je     801cdc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	50                   	push   %eax
  801cd2:	e8 fc f2 ff ff       	call   800fd3 <sys_ipc_recv>
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	eb 10                	jmp    801cec <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	68 00 00 c0 ee       	push   $0xeec00000
  801ce4:	e8 ea f2 ff ff       	call   800fd3 <sys_ipc_recv>
  801ce9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801cec:	85 c0                	test   %eax,%eax
  801cee:	75 26                	jne    801d16 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cf0:	85 f6                	test   %esi,%esi
  801cf2:	74 0a                	je     801cfe <ipc_recv+0x42>
  801cf4:	a1 04 44 80 00       	mov    0x804404,%eax
  801cf9:	8b 40 74             	mov    0x74(%eax),%eax
  801cfc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801cfe:	85 db                	test   %ebx,%ebx
  801d00:	74 0a                	je     801d0c <ipc_recv+0x50>
  801d02:	a1 04 44 80 00       	mov    0x804404,%eax
  801d07:	8b 40 78             	mov    0x78(%eax),%eax
  801d0a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801d0c:	a1 04 44 80 00       	mov    0x804404,%eax
  801d11:	8b 40 70             	mov    0x70(%eax),%eax
  801d14:	eb 14                	jmp    801d2a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801d16:	85 f6                	test   %esi,%esi
  801d18:	74 06                	je     801d20 <ipc_recv+0x64>
  801d1a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801d20:	85 db                	test   %ebx,%ebx
  801d22:	74 06                	je     801d2a <ipc_recv+0x6e>
  801d24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801d2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	57                   	push   %edi
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d40:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801d43:	85 db                	test   %ebx,%ebx
  801d45:	75 25                	jne    801d6c <ipc_send+0x3b>
  801d47:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801d4c:	eb 1e                	jmp    801d6c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801d4e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d51:	75 07                	jne    801d5a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801d53:	e8 59 f1 ff ff       	call   800eb1 <sys_yield>
  801d58:	eb 12                	jmp    801d6c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801d5a:	50                   	push   %eax
  801d5b:	68 1e 25 80 00       	push   $0x80251e
  801d60:	6a 43                	push   $0x43
  801d62:	68 31 25 80 00       	push   $0x802531
  801d67:	e8 78 e5 ff ff       	call   8002e4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	57                   	push   %edi
  801d6f:	ff 75 08             	pushl  0x8(%ebp)
  801d72:	e8 37 f2 ff ff       	call   800fae <sys_ipc_try_send>
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	75 d0                	jne    801d4e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d8c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801d92:	74 1a                	je     801dae <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d94:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d99:	89 c2                	mov    %eax,%edx
  801d9b:	c1 e2 07             	shl    $0x7,%edx
  801d9e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801da5:	8b 52 50             	mov    0x50(%edx),%edx
  801da8:	39 ca                	cmp    %ecx,%edx
  801daa:	75 18                	jne    801dc4 <ipc_find_env+0x3e>
  801dac:	eb 05                	jmp    801db3 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801db3:	89 c2                	mov    %eax,%edx
  801db5:	c1 e2 07             	shl    $0x7,%edx
  801db8:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801dbf:	8b 40 40             	mov    0x40(%eax),%eax
  801dc2:	eb 0c                	jmp    801dd0 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dc4:	40                   	inc    %eax
  801dc5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dca:	75 cd                	jne    801d99 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dcc:	66 b8 00 00          	mov    $0x0,%ax
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    
	...

00801dd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	c1 ea 16             	shr    $0x16,%edx
  801ddf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801de6:	f6 c2 01             	test   $0x1,%dl
  801de9:	74 1e                	je     801e09 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801deb:	c1 e8 0c             	shr    $0xc,%eax
  801dee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801df5:	a8 01                	test   $0x1,%al
  801df7:	74 17                	je     801e10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df9:	c1 e8 0c             	shr    $0xc,%eax
  801dfc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e03:	ef 
  801e04:	0f b7 c0             	movzwl %ax,%eax
  801e07:	eb 0c                	jmp    801e15 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0e:	eb 05                	jmp    801e15 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    
	...

00801e18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	57                   	push   %edi
  801e1c:	56                   	push   %esi
  801e1d:	83 ec 10             	sub    $0x10,%esp
  801e20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e26:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801e29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e2f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e32:	85 c0                	test   %eax,%eax
  801e34:	75 2e                	jne    801e64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e36:	39 f1                	cmp    %esi,%ecx
  801e38:	77 5a                	ja     801e94 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e3a:	85 c9                	test   %ecx,%ecx
  801e3c:	75 0b                	jne    801e49 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f1                	div    %ecx
  801e47:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e49:	31 d2                	xor    %edx,%edx
  801e4b:	89 f0                	mov    %esi,%eax
  801e4d:	f7 f1                	div    %ecx
  801e4f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e51:	89 f8                	mov    %edi,%eax
  801e53:	f7 f1                	div    %ecx
  801e55:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e57:	89 f8                	mov    %edi,%eax
  801e59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	5e                   	pop    %esi
  801e5f:	5f                   	pop    %edi
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    
  801e62:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e64:	39 f0                	cmp    %esi,%eax
  801e66:	77 1c                	ja     801e84 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e68:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801e6b:	83 f7 1f             	xor    $0x1f,%edi
  801e6e:	75 3c                	jne    801eac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e70:	39 f0                	cmp    %esi,%eax
  801e72:	0f 82 90 00 00 00    	jb     801f08 <__udivdi3+0xf0>
  801e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e7b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e7e:	0f 86 84 00 00 00    	jbe    801f08 <__udivdi3+0xf0>
  801e84:	31 f6                	xor    %esi,%esi
  801e86:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e88:	89 f8                	mov    %edi,%eax
  801e8a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    
  801e93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e94:	89 f2                	mov    %esi,%edx
  801e96:	89 f8                	mov    %edi,%eax
  801e98:	f7 f1                	div    %ecx
  801e9a:	89 c7                	mov    %eax,%edi
  801e9c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e9e:	89 f8                	mov    %edi,%eax
  801ea0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    
  801ea9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801eac:	89 f9                	mov    %edi,%ecx
  801eae:	d3 e0                	shl    %cl,%eax
  801eb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eb3:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ebd:	88 c1                	mov    %al,%cl
  801ebf:	d3 ea                	shr    %cl,%edx
  801ec1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ec4:	09 ca                	or     %ecx,%edx
  801ec6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ec9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ecc:	89 f9                	mov    %edi,%ecx
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	88 c1                	mov    %al,%cl
  801ed7:	d3 ea                	shr    %cl,%edx
  801ed9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801edc:	89 f2                	mov    %esi,%edx
  801ede:	89 f9                	mov    %edi,%ecx
  801ee0:	d3 e2                	shl    %cl,%edx
  801ee2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ee5:	88 c1                	mov    %al,%cl
  801ee7:	d3 ee                	shr    %cl,%esi
  801ee9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801eeb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801eee:	89 f0                	mov    %esi,%eax
  801ef0:	89 ca                	mov    %ecx,%edx
  801ef2:	f7 75 ec             	divl   -0x14(%ebp)
  801ef5:	89 d1                	mov    %edx,%ecx
  801ef7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ef9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801efc:	39 d1                	cmp    %edx,%ecx
  801efe:	72 28                	jb     801f28 <__udivdi3+0x110>
  801f00:	74 1a                	je     801f1c <__udivdi3+0x104>
  801f02:	89 f7                	mov    %esi,%edi
  801f04:	31 f6                	xor    %esi,%esi
  801f06:	eb 80                	jmp    801e88 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f08:	31 f6                	xor    %esi,%esi
  801f0a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f0f:	89 f8                	mov    %edi,%eax
  801f11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    
  801f1a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f1f:	89 f9                	mov    %edi,%ecx
  801f21:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f23:	39 c2                	cmp    %eax,%edx
  801f25:	73 db                	jae    801f02 <__udivdi3+0xea>
  801f27:	90                   	nop
		{
		  q0--;
  801f28:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f2b:	31 f6                	xor    %esi,%esi
  801f2d:	e9 56 ff ff ff       	jmp    801e88 <__udivdi3+0x70>
	...

00801f34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	57                   	push   %edi
  801f38:	56                   	push   %esi
  801f39:	83 ec 20             	sub    $0x20,%esp
  801f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801f45:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801f51:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f53:	85 ff                	test   %edi,%edi
  801f55:	75 15                	jne    801f6c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801f57:	39 f1                	cmp    %esi,%ecx
  801f59:	0f 86 99 00 00 00    	jbe    801ff8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f5f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f61:	89 d0                	mov    %edx,%eax
  801f63:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f65:	83 c4 20             	add    $0x20,%esp
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f6c:	39 f7                	cmp    %esi,%edi
  801f6e:	0f 87 a4 00 00 00    	ja     802018 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f74:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801f77:	83 f0 1f             	xor    $0x1f,%eax
  801f7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f7d:	0f 84 a1 00 00 00    	je     802024 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f83:	89 f8                	mov    %edi,%eax
  801f85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f88:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f8a:	bf 20 00 00 00       	mov    $0x20,%edi
  801f8f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 ea                	shr    %cl,%edx
  801f99:	09 c2                	or     %eax,%edx
  801f9b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fa4:	d3 e0                	shl    %cl,%eax
  801fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fa9:	89 f2                	mov    %esi,%edx
  801fab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fb0:	d3 e0                	shl    %cl,%eax
  801fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fb8:	89 f9                	mov    %edi,%ecx
  801fba:	d3 e8                	shr    %cl,%eax
  801fbc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801fbe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	f7 75 f0             	divl   -0x10(%ebp)
  801fc5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801fc7:	f7 65 f4             	mull   -0xc(%ebp)
  801fca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801fcd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fcf:	39 d6                	cmp    %edx,%esi
  801fd1:	72 71                	jb     802044 <__umoddi3+0x110>
  801fd3:	74 7f                	je     802054 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd8:	29 c8                	sub    %ecx,%eax
  801fda:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fdc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fdf:	d3 e8                	shr    %cl,%eax
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	89 f9                	mov    %edi,%ecx
  801fe5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fe7:	09 d0                	or     %edx,%eax
  801fe9:	89 f2                	mov    %esi,%edx
  801feb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ff0:	83 c4 20             	add    $0x20,%esp
  801ff3:	5e                   	pop    %esi
  801ff4:	5f                   	pop    %edi
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    
  801ff7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ff8:	85 c9                	test   %ecx,%ecx
  801ffa:	75 0b                	jne    802007 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ffc:	b8 01 00 00 00       	mov    $0x1,%eax
  802001:	31 d2                	xor    %edx,%edx
  802003:	f7 f1                	div    %ecx
  802005:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802007:	89 f0                	mov    %esi,%eax
  802009:	31 d2                	xor    %edx,%edx
  80200b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80200d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802010:	f7 f1                	div    %ecx
  802012:	e9 4a ff ff ff       	jmp    801f61 <__umoddi3+0x2d>
  802017:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802018:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80201a:	83 c4 20             	add    $0x20,%esp
  80201d:	5e                   	pop    %esi
  80201e:	5f                   	pop    %edi
  80201f:	c9                   	leave  
  802020:	c3                   	ret    
  802021:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802024:	39 f7                	cmp    %esi,%edi
  802026:	72 05                	jb     80202d <__umoddi3+0xf9>
  802028:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80202b:	77 0c                	ja     802039 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80202d:	89 f2                	mov    %esi,%edx
  80202f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802032:	29 c8                	sub    %ecx,%eax
  802034:	19 fa                	sbb    %edi,%edx
  802036:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802039:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80203c:	83 c4 20             	add    $0x20,%esp
  80203f:	5e                   	pop    %esi
  802040:	5f                   	pop    %edi
  802041:	c9                   	leave  
  802042:	c3                   	ret    
  802043:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802044:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802047:	89 c1                	mov    %eax,%ecx
  802049:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80204c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80204f:	eb 84                	jmp    801fd5 <__umoddi3+0xa1>
  802051:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802054:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802057:	72 eb                	jb     802044 <__umoddi3+0x110>
  802059:	89 f2                	mov    %esi,%edx
  80205b:	e9 75 ff ff ff       	jmp    801fd5 <__umoddi3+0xa1>
