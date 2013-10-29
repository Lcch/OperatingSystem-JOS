
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
  800040:	e8 70 0e 00 00       	call   800eb5 <sys_yield>
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
  800050:	e8 a6 11 00 00       	call   8011fb <close>
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
  80006e:	e8 75 02 00 00       	call   8002e8 <_panic>
	if (r != 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 12                	je     800089 <umain+0x55>
		panic("first opencons used fd %d", r);
  800077:	50                   	push   %eax
  800078:	68 7c 20 80 00       	push   $0x80207c
  80007d:	6a 11                	push   $0x11
  80007f:	68 6d 20 80 00       	push   $0x80206d
  800084:	e8 5f 02 00 00       	call   8002e8 <_panic>
	if ((r = dup(0, 1)) < 0)
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 01                	push   $0x1
  80008e:	6a 00                	push   $0x0
  800090:	e8 b4 11 00 00       	call   801249 <dup>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 12                	jns    8000ae <umain+0x7a>
		panic("dup: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 96 20 80 00       	push   $0x802096
  8000a2:	6a 13                	push   $0x13
  8000a4:	68 6d 20 80 00       	push   $0x80206d
  8000a9:	e8 3a 02 00 00       	call   8002e8 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	68 9e 20 80 00       	push   $0x80209e
  8000b6:	e8 69 08 00 00       	call   800924 <readline>
		if (buf != NULL)
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	74 15                	je     8000d7 <umain+0xa3>
			fprintf(1, "%s\n", buf);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	50                   	push   %eax
  8000c6:	68 ac 20 80 00       	push   $0x8020ac
  8000cb:	6a 01                	push   $0x1
  8000cd:	e8 ff 17 00 00       	call   8018d1 <fprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	eb d7                	jmp    8000ae <umain+0x7a>
		else
			fprintf(1, "(end of file received)\n");
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 b0 20 80 00       	push   $0x8020b0
  8000df:	6a 01                	push   $0x1
  8000e1:	e8 eb 17 00 00       	call   8018d1 <fprintf>
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
  800104:	e8 51 09 00 00       	call   800a5a <strcpy>
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
  80014a:	e8 cc 0a 00 00       	call   800c1b <memmove>
		sys_cputs(buf, m);
  80014f:	83 c4 08             	add    $0x8,%esp
  800152:	53                   	push   %ebx
  800153:	57                   	push   %edi
  800154:	e8 cc 0c 00 00       	call   800e25 <sys_cputs>
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
  800184:	e8 2c 0d 00 00       	call   800eb5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800189:	e8 bd 0c 00 00       	call   800e4b <sys_cgetc>
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
  8001c9:	e8 57 0c 00 00       	call   800e25 <sys_cputs>
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
  8001e1:	e8 52 11 00 00       	call   801338 <read>
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
  80020b:	e8 a7 0e 00 00       	call   8010b7 <fd_lookup>
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
  800234:	e8 0b 0e 00 00       	call   801044 <fd_alloc>
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	85 c0                	test   %eax,%eax
  80023e:	78 3a                	js     80027a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	68 07 04 00 00       	push   $0x407
  800248:	ff 75 f4             	pushl  -0xc(%ebp)
  80024b:	6a 00                	push   $0x0
  80024d:	e8 8a 0c 00 00       	call   800edc <sys_page_alloc>
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
  800272:	e8 a5 0d 00 00       	call   80101c <fd2num>
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
  800287:	e8 05 0c 00 00       	call   800e91 <sys_getenvid>
  80028c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800291:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800298:	c1 e0 07             	shl    $0x7,%eax
  80029b:	29 d0                	sub    %edx,%eax
  80029d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002a2:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a7:	85 f6                	test   %esi,%esi
  8002a9:	7e 07                	jle    8002b2 <libmain+0x36>
		binaryname = argv[0];
  8002ab:	8b 03                	mov    (%ebx),%eax
  8002ad:	a3 1c 30 80 00       	mov    %eax,0x80301c
	// call user main routine
	umain(argc, argv);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	53                   	push   %ebx
  8002b6:	56                   	push   %esi
  8002b7:	e8 78 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002bc:	e8 0b 00 00 00       	call   8002cc <exit>
  8002c1:	83 c4 10             	add    $0x10,%esp
}
  8002c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    
	...

008002cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002d2:	e8 4f 0f 00 00       	call   801226 <close_all>
	sys_env_destroy(0);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	6a 00                	push   $0x0
  8002dc:	e8 8e 0b 00 00       	call   800e6f <sys_env_destroy>
  8002e1:	83 c4 10             	add    $0x10,%esp
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
	...

008002e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ed:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f0:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  8002f6:	e8 96 0b 00 00       	call   800e91 <sys_getenvid>
  8002fb:	83 ec 0c             	sub    $0xc,%esp
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	ff 75 08             	pushl  0x8(%ebp)
  800304:	53                   	push   %ebx
  800305:	50                   	push   %eax
  800306:	68 e0 20 80 00       	push   $0x8020e0
  80030b:	e8 b0 00 00 00       	call   8003c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	56                   	push   %esi
  800314:	ff 75 10             	pushl  0x10(%ebp)
  800317:	e8 53 00 00 00       	call   80036f <vcprintf>
	cprintf("\n");
  80031c:	c7 04 24 c6 20 80 00 	movl   $0x8020c6,(%esp)
  800323:	e8 98 00 00 00       	call   8003c0 <cprintf>
  800328:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032b:	cc                   	int3   
  80032c:	eb fd                	jmp    80032b <_panic+0x43>
	...

00800330 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	53                   	push   %ebx
  800334:	83 ec 04             	sub    $0x4,%esp
  800337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033a:	8b 03                	mov    (%ebx),%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800343:	40                   	inc    %eax
  800344:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800346:	3d ff 00 00 00       	cmp    $0xff,%eax
  80034b:	75 1a                	jne    800367 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	68 ff 00 00 00       	push   $0xff
  800355:	8d 43 08             	lea    0x8(%ebx),%eax
  800358:	50                   	push   %eax
  800359:	e8 c7 0a 00 00       	call   800e25 <sys_cputs>
		b->idx = 0;
  80035e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800364:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800367:	ff 43 04             	incl   0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800378:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037f:	00 00 00 
	b.cnt = 0;
  800382:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800389:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800398:	50                   	push   %eax
  800399:	68 30 03 80 00       	push   $0x800330
  80039e:	e8 82 01 00 00       	call   800525 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a3:	83 c4 08             	add    $0x8,%esp
  8003a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	e8 6d 0a 00 00       	call   800e25 <sys_cputs>

	return b.cnt;
}
  8003b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c9:	50                   	push   %eax
  8003ca:	ff 75 08             	pushl  0x8(%ebp)
  8003cd:	e8 9d ff ff ff       	call   80036f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 2c             	sub    $0x2c,%esp
  8003dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e0:	89 d6                	mov    %edx,%esi
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800401:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800404:	72 0c                	jb     800412 <printnum+0x3e>
  800406:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800409:	76 07                	jbe    800412 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040b:	4b                   	dec    %ebx
  80040c:	85 db                	test   %ebx,%ebx
  80040e:	7f 31                	jg     800441 <printnum+0x6d>
  800410:	eb 3f                	jmp    800451 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	57                   	push   %edi
  800416:	4b                   	dec    %ebx
  800417:	53                   	push   %ebx
  800418:	50                   	push   %eax
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	e8 e3 19 00 00       	call   801e10 <__udivdi3>
  80042d:	83 c4 18             	add    $0x18,%esp
  800430:	52                   	push   %edx
  800431:	50                   	push   %eax
  800432:	89 f2                	mov    %esi,%edx
  800434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800437:	e8 98 ff ff ff       	call   8003d4 <printnum>
  80043c:	83 c4 20             	add    $0x20,%esp
  80043f:	eb 10                	jmp    800451 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	56                   	push   %esi
  800445:	57                   	push   %edi
  800446:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800449:	4b                   	dec    %ebx
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	7f f0                	jg     800441 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	ff 75 d4             	pushl  -0x2c(%ebp)
  80045b:	ff 75 d0             	pushl  -0x30(%ebp)
  80045e:	ff 75 dc             	pushl  -0x24(%ebp)
  800461:	ff 75 d8             	pushl  -0x28(%ebp)
  800464:	e8 c3 1a 00 00       	call   801f2c <__umoddi3>
  800469:	83 c4 14             	add    $0x14,%esp
  80046c:	0f be 80 03 21 80 00 	movsbl 0x802103(%eax),%eax
  800473:	50                   	push   %eax
  800474:	ff 55 e4             	call   *-0x1c(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
}
  80047a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047d:	5b                   	pop    %ebx
  80047e:	5e                   	pop    %esi
  80047f:	5f                   	pop    %edi
  800480:	c9                   	leave  
  800481:	c3                   	ret    

00800482 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800485:	83 fa 01             	cmp    $0x1,%edx
  800488:	7e 0e                	jle    800498 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	8b 52 04             	mov    0x4(%edx),%edx
  800496:	eb 22                	jmp    8004ba <getuint+0x38>
	else if (lflag)
  800498:	85 d2                	test   %edx,%edx
  80049a:	74 10                	je     8004ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	eb 0e                	jmp    8004ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bf:	83 fa 01             	cmp    $0x1,%edx
  8004c2:	7e 0e                	jle    8004d2 <getint+0x16>
		return va_arg(*ap, long long);
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 02                	mov    (%edx),%eax
  8004cd:	8b 52 04             	mov    0x4(%edx),%edx
  8004d0:	eb 1a                	jmp    8004ec <getint+0x30>
	else if (lflag)
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 0c                	je     8004e2 <getint+0x26>
		return va_arg(*ap, long);
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004db:	89 08                	mov    %ecx,(%eax)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	99                   	cltd   
  8004e0:	eb 0a                	jmp    8004ec <getint+0x30>
	else
		return va_arg(*ap, int);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	99                   	cltd   
}
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fc:	73 08                	jae    800506 <sprintputch+0x18>
		*b->buf++ = ch;
  8004fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800501:	88 0a                	mov    %cl,(%edx)
  800503:	42                   	inc    %edx
  800504:	89 10                	mov    %edx,(%eax)
}
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800511:	50                   	push   %eax
  800512:	ff 75 10             	pushl  0x10(%ebp)
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	e8 05 00 00 00       	call   800525 <vprintfmt>
	va_end(ap);
  800520:	83 c4 10             	add    $0x10,%esp
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 2c             	sub    $0x2c,%esp
  80052e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800531:	8b 75 10             	mov    0x10(%ebp),%esi
  800534:	eb 13                	jmp    800549 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 6d 03 00 00    	je     8008ab <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	57                   	push   %edi
  800542:	50                   	push   %eax
  800543:	ff 55 08             	call   *0x8(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	0f b6 06             	movzbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	83 f8 25             	cmp    $0x25,%eax
  800550:	75 e4                	jne    800536 <vprintfmt+0x11>
  800552:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800556:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80055d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800564:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800570:	eb 28                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800574:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800578:	eb 20                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800580:	eb 18                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800584:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80058b:	eb 0d                	jmp    80059a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80058d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8a 06                	mov    (%esi),%al
  80059c:	0f b6 d0             	movzbl %al,%edx
  80059f:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005a2:	83 e8 23             	sub    $0x23,%eax
  8005a5:	3c 55                	cmp    $0x55,%al
  8005a7:	0f 87 e0 02 00 00    	ja     80088d <vprintfmt+0x368>
  8005ad:	0f b6 c0             	movzbl %al,%eax
  8005b0:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b7:	83 ea 30             	sub    $0x30,%edx
  8005ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005bd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005c0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005c3:	83 fa 09             	cmp    $0x9,%edx
  8005c6:	77 44                	ja     80060c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	89 de                	mov    %ebx,%esi
  8005ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005ce:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005d1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005d5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005db:	83 fb 09             	cmp    $0x9,%ebx
  8005de:	76 ed                	jbe    8005cd <vprintfmt+0xa8>
  8005e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e3:	eb 29                	jmp    80060e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f5:	eb 17                	jmp    80060e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fb:	78 85                	js     800582 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	eb 99                	jmp    80059a <vprintfmt+0x75>
  800601:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800603:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80060a:	eb 8e                	jmp    80059a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80060e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800612:	79 86                	jns    80059a <vprintfmt+0x75>
  800614:	e9 74 ff ff ff       	jmp    80058d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800619:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	e9 79 ff ff ff       	jmp    80059a <vprintfmt+0x75>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	ff 30                	pushl  (%eax)
  800633:	ff 55 08             	call   *0x8(%ebp)
			break;
  800636:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063c:	e9 08 ff ff ff       	jmp    800549 <vprintfmt+0x24>
  800641:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	85 c0                	test   %eax,%eax
  800651:	79 02                	jns    800655 <vprintfmt+0x130>
  800653:	f7 d8                	neg    %eax
  800655:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800657:	83 f8 0f             	cmp    $0xf,%eax
  80065a:	7f 0b                	jg     800667 <vprintfmt+0x142>
  80065c:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	75 1a                	jne    800681 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800667:	52                   	push   %edx
  800668:	68 1b 21 80 00       	push   $0x80211b
  80066d:	57                   	push   %edi
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	e8 92 fe ff ff       	call   800508 <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067c:	e9 c8 fe ff ff       	jmp    800549 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800681:	50                   	push   %eax
  800682:	68 eb 24 80 00       	push   $0x8024eb
  800687:	57                   	push   %edi
  800688:	ff 75 08             	pushl  0x8(%ebp)
  80068b:	e8 78 fe ff ff       	call   800508 <printfmt>
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800696:	e9 ae fe ff ff       	jmp    800549 <vprintfmt+0x24>
  80069b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	75 07                	jne    8006bf <vprintfmt+0x19a>
				p = "(null)";
  8006b8:	c7 45 d0 14 21 80 00 	movl   $0x802114,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006bf:	85 db                	test   %ebx,%ebx
  8006c1:	7e 42                	jle    800705 <vprintfmt+0x1e0>
  8006c3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006c7:	74 3c                	je     800705 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	51                   	push   %ecx
  8006cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d0:	e8 53 03 00 00       	call   800a28 <strnlen>
  8006d5:	29 c3                	sub    %eax,%ebx
  8006d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	85 db                	test   %ebx,%ebx
  8006df:	7e 24                	jle    800705 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006e1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006e5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	53                   	push   %ebx
  8006f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f3:	4e                   	dec    %esi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	7f f0                	jg     8006eb <vprintfmt+0x1c6>
  8006fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800708:	0f be 02             	movsbl (%edx),%eax
  80070b:	85 c0                	test   %eax,%eax
  80070d:	75 47                	jne    800756 <vprintfmt+0x231>
  80070f:	eb 37                	jmp    800748 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	74 16                	je     80072d <vprintfmt+0x208>
  800717:	8d 50 e0             	lea    -0x20(%eax),%edx
  80071a:	83 fa 5e             	cmp    $0x5e,%edx
  80071d:	76 0e                	jbe    80072d <vprintfmt+0x208>
					putch('?', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 3f                	push   $0x3f
  800725:	ff 55 08             	call   *0x8(%ebp)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 0b                	jmp    800738 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	50                   	push   %eax
  800732:	ff 55 08             	call   *0x8(%ebp)
  800735:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800738:	ff 4d e4             	decl   -0x1c(%ebp)
  80073b:	0f be 03             	movsbl (%ebx),%eax
  80073e:	85 c0                	test   %eax,%eax
  800740:	74 03                	je     800745 <vprintfmt+0x220>
  800742:	43                   	inc    %ebx
  800743:	eb 1b                	jmp    800760 <vprintfmt+0x23b>
  800745:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800748:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074c:	7f 1e                	jg     80076c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800751:	e9 f3 fd ff ff       	jmp    800549 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800759:	43                   	inc    %ebx
  80075a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80075d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800760:	85 f6                	test   %esi,%esi
  800762:	78 ad                	js     800711 <vprintfmt+0x1ec>
  800764:	4e                   	dec    %esi
  800765:	79 aa                	jns    800711 <vprintfmt+0x1ec>
  800767:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80076a:	eb dc                	jmp    800748 <vprintfmt+0x223>
  80076c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	57                   	push   %edi
  800773:	6a 20                	push   $0x20
  800775:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800778:	4b                   	dec    %ebx
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 db                	test   %ebx,%ebx
  80077e:	7f ef                	jg     80076f <vprintfmt+0x24a>
  800780:	e9 c4 fd ff ff       	jmp    800549 <vprintfmt+0x24>
  800785:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 2a fd ff ff       	call   8004bc <getint>
  800792:	89 c3                	mov    %eax,%ebx
  800794:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	78 0a                	js     8007a4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80079a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079f:	e9 b0 00 00 00       	jmp    800854 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	57                   	push   %edi
  8007a8:	6a 2d                	push   $0x2d
  8007aa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ad:	f7 db                	neg    %ebx
  8007af:	83 d6 00             	adc    $0x0,%esi
  8007b2:	f7 de                	neg    %esi
  8007b4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bc:	e9 93 00 00 00       	jmp    800854 <vprintfmt+0x32f>
  8007c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 b4 fc ff ff       	call   800482 <getuint>
  8007ce:	89 c3                	mov    %eax,%ebx
  8007d0:	89 d6                	mov    %edx,%esi
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d7:	eb 7b                	jmp    800854 <vprintfmt+0x32f>
  8007d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007dc:	89 ca                	mov    %ecx,%edx
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e1:	e8 d6 fc ff ff       	call   8004bc <getint>
  8007e6:	89 c3                	mov    %eax,%ebx
  8007e8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	78 07                	js     8007f5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8007f3:	eb 5f                	jmp    800854 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	57                   	push   %edi
  8007f9:	6a 2d                	push   $0x2d
  8007fb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007fe:	f7 db                	neg    %ebx
  800800:	83 d6 00             	adc    $0x0,%esi
  800803:	f7 de                	neg    %esi
  800805:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800808:	b8 08 00 00 00       	mov    $0x8,%eax
  80080d:	eb 45                	jmp    800854 <vprintfmt+0x32f>
  80080f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	57                   	push   %edi
  800816:	6a 30                	push   $0x30
  800818:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	57                   	push   %edi
  80081f:	6a 78                	push   $0x78
  800821:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082d:	8b 18                	mov    (%eax),%ebx
  80082f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800834:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80083c:	eb 16                	jmp    800854 <vprintfmt+0x32f>
  80083e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800841:	89 ca                	mov    %ecx,%edx
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 37 fc ff ff       	call   800482 <getuint>
  80084b:	89 c3                	mov    %eax,%ebx
  80084d:	89 d6                	mov    %edx,%esi
			base = 16;
  80084f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800854:	83 ec 0c             	sub    $0xc,%esp
  800857:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80085b:	52                   	push   %edx
  80085c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80085f:	50                   	push   %eax
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	89 fa                	mov    %edi,%edx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	e8 68 fb ff ff       	call   8003d4 <printnum>
			break;
  80086c:	83 c4 20             	add    $0x20,%esp
  80086f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800872:	e9 d2 fc ff ff       	jmp    800549 <vprintfmt+0x24>
  800877:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	57                   	push   %edi
  80087e:	52                   	push   %edx
  80087f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800882:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800888:	e9 bc fc ff ff       	jmp    800549 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	57                   	push   %edi
  800891:	6a 25                	push   $0x25
  800893:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 02                	jmp    80089d <vprintfmt+0x378>
  80089b:	89 c6                	mov    %eax,%esi
  80089d:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008a0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a4:	75 f5                	jne    80089b <vprintfmt+0x376>
  8008a6:	e9 9e fc ff ff       	jmp    800549 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 18             	sub    $0x18,%esp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	74 26                	je     8008fa <vsnprintf+0x47>
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	7e 29                	jle    800901 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d8:	ff 75 14             	pushl  0x14(%ebp)
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e1:	50                   	push   %eax
  8008e2:	68 ee 04 80 00       	push   $0x8004ee
  8008e7:	e8 39 fc ff ff       	call   800525 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	eb 0c                	jmp    800906 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ff:	eb 05                	jmp    800906 <vsnprintf+0x53>
  800901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800911:	50                   	push   %eax
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 93 ff ff ff       	call   8008b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    
	...

00800924 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	83 ec 0c             	sub    $0xc,%esp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 13                	je     800947 <readline+0x23>
		fprintf(1, "%s", prompt);
  800934:	83 ec 04             	sub    $0x4,%esp
  800937:	50                   	push   %eax
  800938:	68 eb 24 80 00       	push   $0x8024eb
  80093d:	6a 01                	push   $0x1
  80093f:	e8 8d 0f 00 00       	call   8018d1 <fprintf>
  800944:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 00                	push   $0x0
  80094c:	e8 ad f8 ff ff       	call   8001fe <iscons>
  800951:	89 c7                	mov    %eax,%edi
  800953:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800956:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80095b:	e8 73 f8 ff ff       	call   8001d3 <getchar>
  800960:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800962:	85 c0                	test   %eax,%eax
  800964:	79 21                	jns    800987 <readline+0x63>
			if (c != -E_EOF)
  800966:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800969:	0f 84 89 00 00 00    	je     8009f8 <readline+0xd4>
				cprintf("read error: %e\n", c);
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	50                   	push   %eax
  800973:	68 ff 23 80 00       	push   $0x8023ff
  800978:	e8 43 fa ff ff       	call   8003c0 <cprintf>
  80097d:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	eb 76                	jmp    8009fd <readline+0xd9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800987:	83 f8 08             	cmp    $0x8,%eax
  80098a:	74 05                	je     800991 <readline+0x6d>
  80098c:	83 f8 7f             	cmp    $0x7f,%eax
  80098f:	75 18                	jne    8009a9 <readline+0x85>
  800991:	85 f6                	test   %esi,%esi
  800993:	7e 14                	jle    8009a9 <readline+0x85>
			if (echoing)
  800995:	85 ff                	test   %edi,%edi
  800997:	74 0d                	je     8009a6 <readline+0x82>
				cputchar('\b');
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	6a 08                	push   $0x8
  80099e:	e8 14 f8 ff ff       	call   8001b7 <cputchar>
  8009a3:	83 c4 10             	add    $0x10,%esp
			i--;
  8009a6:	4e                   	dec    %esi
  8009a7:	eb b2                	jmp    80095b <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009a9:	83 fb 1f             	cmp    $0x1f,%ebx
  8009ac:	7e 21                	jle    8009cf <readline+0xab>
  8009ae:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b4:	7f 19                	jg     8009cf <readline+0xab>
			if (echoing)
  8009b6:	85 ff                	test   %edi,%edi
  8009b8:	74 0c                	je     8009c6 <readline+0xa2>
				cputchar(c);
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	53                   	push   %ebx
  8009be:	e8 f4 f7 ff ff       	call   8001b7 <cputchar>
  8009c3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c6:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009cc:	46                   	inc    %esi
  8009cd:	eb 8c                	jmp    80095b <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009cf:	83 fb 0a             	cmp    $0xa,%ebx
  8009d2:	74 05                	je     8009d9 <readline+0xb5>
  8009d4:	83 fb 0d             	cmp    $0xd,%ebx
  8009d7:	75 82                	jne    80095b <readline+0x37>
			if (echoing)
  8009d9:	85 ff                	test   %edi,%edi
  8009db:	74 0d                	je     8009ea <readline+0xc6>
				cputchar('\n');
  8009dd:	83 ec 0c             	sub    $0xc,%esp
  8009e0:	6a 0a                	push   $0xa
  8009e2:	e8 d0 f7 ff ff       	call   8001b7 <cputchar>
  8009e7:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009ea:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009f1:	b8 00 40 80 00       	mov    $0x804000,%eax
  8009f6:	eb 05                	jmp    8009fd <readline+0xd9>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8009fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    
  800a05:	00 00                	add    %al,(%eax)
	...

00800a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	80 3a 00             	cmpb   $0x0,(%edx)
  800a11:	74 0e                	je     800a21 <strlen+0x19>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a18:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1d:	75 f9                	jne    800a18 <strlen+0x10>
  800a1f:	eb 05                	jmp    800a26 <strlen+0x1e>
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a31:	85 d2                	test   %edx,%edx
  800a33:	74 17                	je     800a4c <strnlen+0x24>
  800a35:	80 39 00             	cmpb   $0x0,(%ecx)
  800a38:	74 19                	je     800a53 <strnlen+0x2b>
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a3f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	74 14                	je     800a58 <strnlen+0x30>
  800a44:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a48:	75 f5                	jne    800a3f <strnlen+0x17>
  800a4a:	eb 0c                	jmp    800a58 <strnlen+0x30>
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strnlen+0x30>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a6c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a6f:	42                   	inc    %edx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	75 f5                	jne    800a69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a74:	5b                   	pop    %ebx
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	53                   	push   %ebx
  800a7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a7e:	53                   	push   %ebx
  800a7f:	e8 84 ff ff ff       	call   800a08 <strlen>
  800a84:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a87:	ff 75 0c             	pushl  0xc(%ebp)
  800a8a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a8d:	50                   	push   %eax
  800a8e:	e8 c7 ff ff ff       	call   800a5a <strcpy>
	return dst;
}
  800a93:	89 d8                	mov    %ebx,%eax
  800a95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa8:	85 f6                	test   %esi,%esi
  800aaa:	74 15                	je     800ac1 <strncpy+0x27>
  800aac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800ab1:	8a 1a                	mov    (%edx),%bl
  800ab3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab6:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abc:	41                   	inc    %ecx
  800abd:	39 ce                	cmp    %ecx,%esi
  800abf:	77 f0                	ja     800ab1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ace:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad4:	85 f6                	test   %esi,%esi
  800ad6:	74 32                	je     800b0a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800ad8:	83 fe 01             	cmp    $0x1,%esi
  800adb:	74 22                	je     800aff <strlcpy+0x3a>
  800add:	8a 0b                	mov    (%ebx),%cl
  800adf:	84 c9                	test   %cl,%cl
  800ae1:	74 20                	je     800b03 <strlcpy+0x3e>
  800ae3:	89 f8                	mov    %edi,%eax
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800aea:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aed:	88 08                	mov    %cl,(%eax)
  800aef:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af0:	39 f2                	cmp    %esi,%edx
  800af2:	74 11                	je     800b05 <strlcpy+0x40>
  800af4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800af8:	42                   	inc    %edx
  800af9:	84 c9                	test   %cl,%cl
  800afb:	75 f0                	jne    800aed <strlcpy+0x28>
  800afd:	eb 06                	jmp    800b05 <strlcpy+0x40>
  800aff:	89 f8                	mov    %edi,%eax
  800b01:	eb 02                	jmp    800b05 <strlcpy+0x40>
  800b03:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b05:	c6 00 00             	movb   $0x0,(%eax)
  800b08:	eb 02                	jmp    800b0c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800b0c:	29 f8                	sub    %edi,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1c:	8a 01                	mov    (%ecx),%al
  800b1e:	84 c0                	test   %al,%al
  800b20:	74 10                	je     800b32 <strcmp+0x1f>
  800b22:	3a 02                	cmp    (%edx),%al
  800b24:	75 0c                	jne    800b32 <strcmp+0x1f>
		p++, q++;
  800b26:	41                   	inc    %ecx
  800b27:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b28:	8a 01                	mov    (%ecx),%al
  800b2a:	84 c0                	test   %al,%al
  800b2c:	74 04                	je     800b32 <strcmp+0x1f>
  800b2e:	3a 02                	cmp    (%edx),%al
  800b30:	74 f4                	je     800b26 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b32:	0f b6 c0             	movzbl %al,%eax
  800b35:	0f b6 12             	movzbl (%edx),%edx
  800b38:	29 d0                	sub    %edx,%eax
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	74 1b                	je     800b68 <strncmp+0x2c>
  800b4d:	8a 1a                	mov    (%edx),%bl
  800b4f:	84 db                	test   %bl,%bl
  800b51:	74 24                	je     800b77 <strncmp+0x3b>
  800b53:	3a 19                	cmp    (%ecx),%bl
  800b55:	75 20                	jne    800b77 <strncmp+0x3b>
  800b57:	48                   	dec    %eax
  800b58:	74 15                	je     800b6f <strncmp+0x33>
		n--, p++, q++;
  800b5a:	42                   	inc    %edx
  800b5b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b5c:	8a 1a                	mov    (%edx),%bl
  800b5e:	84 db                	test   %bl,%bl
  800b60:	74 15                	je     800b77 <strncmp+0x3b>
  800b62:	3a 19                	cmp    (%ecx),%bl
  800b64:	74 f1                	je     800b57 <strncmp+0x1b>
  800b66:	eb 0f                	jmp    800b77 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	eb 05                	jmp    800b74 <strncmp+0x38>
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b74:	5b                   	pop    %ebx
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 02             	movzbl (%edx),%eax
  800b7a:	0f b6 11             	movzbl (%ecx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
  800b7f:	eb f3                	jmp    800b74 <strncmp+0x38>

00800b81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b8a:	8a 10                	mov    (%eax),%dl
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	74 18                	je     800ba8 <strchr+0x27>
		if (*s == c)
  800b90:	38 ca                	cmp    %cl,%dl
  800b92:	75 06                	jne    800b9a <strchr+0x19>
  800b94:	eb 17                	jmp    800bad <strchr+0x2c>
  800b96:	38 ca                	cmp    %cl,%dl
  800b98:	74 13                	je     800bad <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	40                   	inc    %eax
  800b9b:	8a 10                	mov    (%eax),%dl
  800b9d:	84 d2                	test   %dl,%dl
  800b9f:	75 f5                	jne    800b96 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	eb 05                	jmp    800bad <strchr+0x2c>
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb8:	8a 10                	mov    (%eax),%dl
  800bba:	84 d2                	test   %dl,%dl
  800bbc:	74 11                	je     800bcf <strfind+0x20>
		if (*s == c)
  800bbe:	38 ca                	cmp    %cl,%dl
  800bc0:	75 06                	jne    800bc8 <strfind+0x19>
  800bc2:	eb 0b                	jmp    800bcf <strfind+0x20>
  800bc4:	38 ca                	cmp    %cl,%dl
  800bc6:	74 07                	je     800bcf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc8:	40                   	inc    %eax
  800bc9:	8a 10                	mov    (%eax),%dl
  800bcb:	84 d2                	test   %dl,%dl
  800bcd:	75 f5                	jne    800bc4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be0:	85 c9                	test   %ecx,%ecx
  800be2:	74 30                	je     800c14 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bea:	75 25                	jne    800c11 <memset+0x40>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	75 20                	jne    800c11 <memset+0x40>
		c &= 0xFF;
  800bf1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	c1 e3 08             	shl    $0x8,%ebx
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	c1 e6 18             	shl    $0x18,%esi
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	c1 e0 10             	shl    $0x10,%eax
  800c03:	09 f0                	or     %esi,%eax
  800c05:	09 d0                	or     %edx,%eax
  800c07:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c09:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c0c:	fc                   	cld    
  800c0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0f:	eb 03                	jmp    800c14 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c11:	fc                   	cld    
  800c12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c14:	89 f8                	mov    %edi,%eax
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c29:	39 c6                	cmp    %eax,%esi
  800c2b:	73 34                	jae    800c61 <memmove+0x46>
  800c2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c30:	39 d0                	cmp    %edx,%eax
  800c32:	73 2d                	jae    800c61 <memmove+0x46>
		s += n;
		d += n;
  800c34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c37:	f6 c2 03             	test   $0x3,%dl
  800c3a:	75 1b                	jne    800c57 <memmove+0x3c>
  800c3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c42:	75 13                	jne    800c57 <memmove+0x3c>
  800c44:	f6 c1 03             	test   $0x3,%cl
  800c47:	75 0e                	jne    800c57 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c49:	83 ef 04             	sub    $0x4,%edi
  800c4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c52:	fd                   	std    
  800c53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c55:	eb 07                	jmp    800c5e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c57:	4f                   	dec    %edi
  800c58:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c5b:	fd                   	std    
  800c5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5e:	fc                   	cld    
  800c5f:	eb 20                	jmp    800c81 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c67:	75 13                	jne    800c7c <memmove+0x61>
  800c69:	a8 03                	test   $0x3,%al
  800c6b:	75 0f                	jne    800c7c <memmove+0x61>
  800c6d:	f6 c1 03             	test   $0x3,%cl
  800c70:	75 0a                	jne    800c7c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c72:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	fc                   	cld    
  800c78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7a:	eb 05                	jmp    800c81 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	fc                   	cld    
  800c7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c88:	ff 75 10             	pushl  0x10(%ebp)
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	ff 75 08             	pushl  0x8(%ebp)
  800c91:	e8 85 ff ff ff       	call   800c1b <memmove>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca7:	85 ff                	test   %edi,%edi
  800ca9:	74 32                	je     800cdd <memcmp+0x45>
		if (*s1 != *s2)
  800cab:	8a 03                	mov    (%ebx),%al
  800cad:	8a 0e                	mov    (%esi),%cl
  800caf:	38 c8                	cmp    %cl,%al
  800cb1:	74 19                	je     800ccc <memcmp+0x34>
  800cb3:	eb 0d                	jmp    800cc2 <memcmp+0x2a>
  800cb5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800cb9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800cbd:	42                   	inc    %edx
  800cbe:	38 c8                	cmp    %cl,%al
  800cc0:	74 10                	je     800cd2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800cc2:	0f b6 c0             	movzbl %al,%eax
  800cc5:	0f b6 c9             	movzbl %cl,%ecx
  800cc8:	29 c8                	sub    %ecx,%eax
  800cca:	eb 16                	jmp    800ce2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccc:	4f                   	dec    %edi
  800ccd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd2:	39 fa                	cmp    %edi,%edx
  800cd4:	75 df                	jne    800cb5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	eb 05                	jmp    800ce2 <memcmp+0x4a>
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ced:	89 c2                	mov    %eax,%edx
  800cef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf2:	39 d0                	cmp    %edx,%eax
  800cf4:	73 12                	jae    800d08 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800cf9:	38 08                	cmp    %cl,(%eax)
  800cfb:	75 06                	jne    800d03 <memfind+0x1c>
  800cfd:	eb 09                	jmp    800d08 <memfind+0x21>
  800cff:	38 08                	cmp    %cl,(%eax)
  800d01:	74 05                	je     800d08 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d03:	40                   	inc    %eax
  800d04:	39 c2                	cmp    %eax,%edx
  800d06:	77 f7                	ja     800cff <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d16:	eb 01                	jmp    800d19 <strtol+0xf>
		s++;
  800d18:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d19:	8a 02                	mov    (%edx),%al
  800d1b:	3c 20                	cmp    $0x20,%al
  800d1d:	74 f9                	je     800d18 <strtol+0xe>
  800d1f:	3c 09                	cmp    $0x9,%al
  800d21:	74 f5                	je     800d18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d23:	3c 2b                	cmp    $0x2b,%al
  800d25:	75 08                	jne    800d2f <strtol+0x25>
		s++;
  800d27:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d28:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2d:	eb 13                	jmp    800d42 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2f:	3c 2d                	cmp    $0x2d,%al
  800d31:	75 0a                	jne    800d3d <strtol+0x33>
		s++, neg = 1;
  800d33:	8d 52 01             	lea    0x1(%edx),%edx
  800d36:	bf 01 00 00 00       	mov    $0x1,%edi
  800d3b:	eb 05                	jmp    800d42 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d42:	85 db                	test   %ebx,%ebx
  800d44:	74 05                	je     800d4b <strtol+0x41>
  800d46:	83 fb 10             	cmp    $0x10,%ebx
  800d49:	75 28                	jne    800d73 <strtol+0x69>
  800d4b:	8a 02                	mov    (%edx),%al
  800d4d:	3c 30                	cmp    $0x30,%al
  800d4f:	75 10                	jne    800d61 <strtol+0x57>
  800d51:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d55:	75 0a                	jne    800d61 <strtol+0x57>
		s += 2, base = 16;
  800d57:	83 c2 02             	add    $0x2,%edx
  800d5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5f:	eb 12                	jmp    800d73 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d61:	85 db                	test   %ebx,%ebx
  800d63:	75 0e                	jne    800d73 <strtol+0x69>
  800d65:	3c 30                	cmp    $0x30,%al
  800d67:	75 05                	jne    800d6e <strtol+0x64>
		s++, base = 8;
  800d69:	42                   	inc    %edx
  800d6a:	b3 08                	mov    $0x8,%bl
  800d6c:	eb 05                	jmp    800d73 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d7a:	8a 0a                	mov    (%edx),%cl
  800d7c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d7f:	80 fb 09             	cmp    $0x9,%bl
  800d82:	77 08                	ja     800d8c <strtol+0x82>
			dig = *s - '0';
  800d84:	0f be c9             	movsbl %cl,%ecx
  800d87:	83 e9 30             	sub    $0x30,%ecx
  800d8a:	eb 1e                	jmp    800daa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d8c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d8f:	80 fb 19             	cmp    $0x19,%bl
  800d92:	77 08                	ja     800d9c <strtol+0x92>
			dig = *s - 'a' + 10;
  800d94:	0f be c9             	movsbl %cl,%ecx
  800d97:	83 e9 57             	sub    $0x57,%ecx
  800d9a:	eb 0e                	jmp    800daa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d9c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d9f:	80 fb 19             	cmp    $0x19,%bl
  800da2:	77 13                	ja     800db7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800da4:	0f be c9             	movsbl %cl,%ecx
  800da7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800daa:	39 f1                	cmp    %esi,%ecx
  800dac:	7d 0d                	jge    800dbb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800dae:	42                   	inc    %edx
  800daf:	0f af c6             	imul   %esi,%eax
  800db2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800db5:	eb c3                	jmp    800d7a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db7:	89 c1                	mov    %eax,%ecx
  800db9:	eb 02                	jmp    800dbd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dbb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc1:	74 05                	je     800dc8 <strtol+0xbe>
		*endptr = (char *) s;
  800dc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc8:	85 ff                	test   %edi,%edi
  800dca:	74 04                	je     800dd0 <strtol+0xc6>
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	f7 d8                	neg    %eax
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    
  800dd5:	00 00                	add    %al,(%eax)
	...

00800dd8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 1c             	sub    $0x1c,%esp
  800de1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800de4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800de7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	8b 75 14             	mov    0x14(%ebp),%esi
  800dec:	8b 7d 10             	mov    0x10(%ebp),%edi
  800def:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df5:	cd 30                	int    $0x30
  800df7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dfd:	74 1c                	je     800e1b <syscall+0x43>
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 18                	jle    800e1b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e0a:	68 0f 24 80 00       	push   $0x80240f
  800e0f:	6a 42                	push   $0x42
  800e11:	68 2c 24 80 00       	push   $0x80242c
  800e16:	e8 cd f4 ff ff       	call   8002e8 <_panic>

	return ret;
}
  800e1b:	89 d0                	mov    %edx,%eax
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e2b:	6a 00                	push   $0x0
  800e2d:	6a 00                	push   $0x0
  800e2f:	6a 00                	push   $0x0
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	e8 92 ff ff ff       	call   800dd8 <syscall>
  800e46:	83 c4 10             	add    $0x10,%esp
	return;
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e51:	6a 00                	push   $0x0
  800e53:	6a 00                	push   $0x0
  800e55:	6a 00                	push   $0x0
  800e57:	6a 00                	push   $0x0
  800e59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e63:	b8 01 00 00 00       	mov    $0x1,%eax
  800e68:	e8 6b ff ff ff       	call   800dd8 <syscall>
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e75:	6a 00                	push   $0x0
  800e77:	6a 00                	push   $0x0
  800e79:	6a 00                	push   $0x0
  800e7b:	6a 00                	push   $0x0
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	ba 01 00 00 00       	mov    $0x1,%edx
  800e85:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8a:	e8 49 ff ff ff       	call   800dd8 <syscall>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800e97:	6a 00                	push   $0x0
  800e99:	6a 00                	push   $0x0
  800e9b:	6a 00                	push   $0x0
  800e9d:	6a 00                	push   $0x0
  800e9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea9:	b8 02 00 00 00       	mov    $0x2,%eax
  800eae:	e8 25 ff ff ff       	call   800dd8 <syscall>
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <sys_yield>:

void
sys_yield(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ebb:	6a 00                	push   $0x0
  800ebd:	6a 00                	push   $0x0
  800ebf:	6a 00                	push   $0x0
  800ec1:	6a 00                	push   $0x0
  800ec3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed2:	e8 01 ff ff ff       	call   800dd8 <syscall>
  800ed7:	83 c4 10             	add    $0x10,%esp
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ee2:	6a 00                	push   $0x0
  800ee4:	6a 00                	push   $0x0
  800ee6:	ff 75 10             	pushl  0x10(%ebp)
  800ee9:	ff 75 0c             	pushl  0xc(%ebp)
  800eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eef:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef9:	e8 da fe ff ff       	call   800dd8 <syscall>
}
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f06:	ff 75 18             	pushl  0x18(%ebp)
  800f09:	ff 75 14             	pushl  0x14(%ebp)
  800f0c:	ff 75 10             	pushl  0x10(%ebp)
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f15:	ba 01 00 00 00       	mov    $0x1,%edx
  800f1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1f:	e8 b4 fe ff ff       	call   800dd8 <syscall>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f2c:	6a 00                	push   $0x0
  800f2e:	6a 00                	push   $0x0
  800f30:	6a 00                	push   $0x0
  800f32:	ff 75 0c             	pushl  0xc(%ebp)
  800f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f38:	ba 01 00 00 00       	mov    $0x1,%edx
  800f3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f42:	e8 91 fe ff ff       	call   800dd8 <syscall>
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f4f:	6a 00                	push   $0x0
  800f51:	6a 00                	push   $0x0
  800f53:	6a 00                	push   $0x0
  800f55:	ff 75 0c             	pushl  0xc(%ebp)
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f60:	b8 08 00 00 00       	mov    $0x8,%eax
  800f65:	e8 6e fe ff ff       	call   800dd8 <syscall>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f72:	6a 00                	push   $0x0
  800f74:	6a 00                	push   $0x0
  800f76:	6a 00                	push   $0x0
  800f78:	ff 75 0c             	pushl  0xc(%ebp)
  800f7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7e:	ba 01 00 00 00       	mov    $0x1,%edx
  800f83:	b8 09 00 00 00       	mov    $0x9,%eax
  800f88:	e8 4b fe ff ff       	call   800dd8 <syscall>
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f95:	6a 00                	push   $0x0
  800f97:	6a 00                	push   $0x0
  800f99:	6a 00                	push   $0x0
  800f9b:	ff 75 0c             	pushl  0xc(%ebp)
  800f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa1:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fab:	e8 28 fe ff ff       	call   800dd8 <syscall>
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800fb8:	6a 00                	push   $0x0
  800fba:	ff 75 14             	pushl  0x14(%ebp)
  800fbd:	ff 75 10             	pushl  0x10(%ebp)
  800fc0:	ff 75 0c             	pushl  0xc(%ebp)
  800fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	e8 03 fe ff ff       	call   800dd8 <syscall>
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800fdd:	6a 00                	push   $0x0
  800fdf:	6a 00                	push   $0x0
  800fe1:	6a 00                	push   $0x0
  800fe3:	6a 00                	push   $0x0
  800fe5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe8:	ba 01 00 00 00       	mov    $0x1,%edx
  800fed:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ff2:	e8 e1 fd ff ff       	call   800dd8 <syscall>
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800fff:	6a 00                	push   $0x0
  801001:	6a 00                	push   $0x0
  801003:	6a 00                	push   $0x0
  801005:	ff 75 0c             	pushl  0xc(%ebp)
  801008:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100b:	ba 00 00 00 00       	mov    $0x0,%edx
  801010:	b8 0e 00 00 00       	mov    $0xe,%eax
  801015:	e8 be fd ff ff       	call   800dd8 <syscall>
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
  801022:	05 00 00 00 30       	add    $0x30000000,%eax
  801027:	c1 e8 0c             	shr    $0xc,%eax
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	e8 e5 ff ff ff       	call   80101c <fd2num>
  801037:	83 c4 04             	add    $0x4,%esp
  80103a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80103f:	c1 e0 0c             	shl    $0xc,%eax
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80104b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801050:	a8 01                	test   $0x1,%al
  801052:	74 34                	je     801088 <fd_alloc+0x44>
  801054:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801059:	a8 01                	test   $0x1,%al
  80105b:	74 32                	je     80108f <fd_alloc+0x4b>
  80105d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801062:	89 c1                	mov    %eax,%ecx
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 16             	shr    $0x16,%edx
  801069:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801070:	f6 c2 01             	test   $0x1,%dl
  801073:	74 1f                	je     801094 <fd_alloc+0x50>
  801075:	89 c2                	mov    %eax,%edx
  801077:	c1 ea 0c             	shr    $0xc,%edx
  80107a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801081:	f6 c2 01             	test   $0x1,%dl
  801084:	75 17                	jne    80109d <fd_alloc+0x59>
  801086:	eb 0c                	jmp    801094 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801088:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80108d:	eb 05                	jmp    801094 <fd_alloc+0x50>
  80108f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801094:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb 17                	jmp    8010b4 <fd_alloc+0x70>
  80109d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a7:	75 b9                	jne    801062 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8010af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b4:	5b                   	pop    %ebx
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010bd:	83 f8 1f             	cmp    $0x1f,%eax
  8010c0:	77 36                	ja     8010f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010c7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 16             	shr    $0x16,%edx
  8010cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 24                	je     8010ff <fd_lookup+0x48>
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
  8010e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	74 1a                	je     801106 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	eb 13                	jmp    80110b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fd:	eb 0c                	jmp    80110b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801104:	eb 05                	jmp    80110b <fd_lookup+0x54>
  801106:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80111a:	39 0d 20 30 80 00    	cmp    %ecx,0x803020
  801120:	74 0d                	je     80112f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
  801127:	eb 14                	jmp    80113d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801129:	39 0a                	cmp    %ecx,(%edx)
  80112b:	75 10                	jne    80113d <dev_lookup+0x30>
  80112d:	eb 05                	jmp    801134 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80112f:	ba 20 30 80 00       	mov    $0x803020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801134:	89 13                	mov    %edx,(%ebx)
			return 0;
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
  80113b:	eb 31                	jmp    80116e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113d:	40                   	inc    %eax
  80113e:	8b 14 85 bc 24 80 00 	mov    0x8024bc(,%eax,4),%edx
  801145:	85 d2                	test   %edx,%edx
  801147:	75 e0                	jne    801129 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801149:	a1 04 44 80 00       	mov    0x804404,%eax
  80114e:	8b 40 48             	mov    0x48(%eax),%eax
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	51                   	push   %ecx
  801155:	50                   	push   %eax
  801156:	68 3c 24 80 00       	push   $0x80243c
  80115b:	e8 60 f2 ff ff       	call   8003c0 <cprintf>
	*dev = 0;
  801160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 20             	sub    $0x20,%esp
  80117b:	8b 75 08             	mov    0x8(%ebp),%esi
  80117e:	8a 45 0c             	mov    0xc(%ebp),%al
  801181:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801184:	56                   	push   %esi
  801185:	e8 92 fe ff ff       	call   80101c <fd2num>
  80118a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80118d:	89 14 24             	mov    %edx,(%esp)
  801190:	50                   	push   %eax
  801191:	e8 21 ff ff ff       	call   8010b7 <fd_lookup>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 08             	add    $0x8,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 05                	js     8011a4 <fd_close+0x31>
	    || fd != fd2)
  80119f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a2:	74 0d                	je     8011b1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011a4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011a8:	75 48                	jne    8011f2 <fd_close+0x7f>
  8011aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011af:	eb 41                	jmp    8011f2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 36                	pushl  (%esi)
  8011ba:	e8 4e ff ff ff       	call   80110d <dev_lookup>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 1c                	js     8011e4 <fd_close+0x71>
		if (dev->dev_close)
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	8b 40 10             	mov    0x10(%eax),%eax
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0d                	je     8011df <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	56                   	push   %esi
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 05                	jmp    8011e4 <fd_close+0x71>
		else
			r = 0;
  8011df:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 37 fd ff ff       	call   800f26 <sys_page_unmap>
	return r;
  8011ef:	83 c4 10             	add    $0x10,%esp
}
  8011f2:	89 d8                	mov    %ebx,%eax
  8011f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 75 08             	pushl  0x8(%ebp)
  801208:	e8 aa fe ff ff       	call   8010b7 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 10                	js     801224 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	6a 01                	push   $0x1
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 52 ff ff ff       	call   801173 <fd_close>
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	53                   	push   %ebx
  801236:	e8 c0 ff ff ff       	call   8011fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123b:	43                   	inc    %ebx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	83 fb 20             	cmp    $0x20,%ebx
  801242:	75 ee                	jne    801232 <close_all+0xc>
		close(i);
}
  801244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 2c             	sub    $0x2c,%esp
  801252:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801255:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 56 fe ff ff       	call   8010b7 <fd_lookup>
  801261:	89 c3                	mov    %eax,%ebx
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 c0 00 00 00    	js     80132e <dup+0xe5>
		return r;
	close(newfdnum);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	57                   	push   %edi
  801272:	e8 84 ff ff ff       	call   8011fb <close>

	newfd = INDEX2FD(newfdnum);
  801277:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80127d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801280:	83 c4 04             	add    $0x4,%esp
  801283:	ff 75 e4             	pushl  -0x1c(%ebp)
  801286:	e8 a1 fd ff ff       	call   80102c <fd2data>
  80128b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80128d:	89 34 24             	mov    %esi,(%esp)
  801290:	e8 97 fd ff ff       	call   80102c <fd2data>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129b:	89 d8                	mov    %ebx,%eax
  80129d:	c1 e8 16             	shr    $0x16,%eax
  8012a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a7:	a8 01                	test   $0x1,%al
  8012a9:	74 37                	je     8012e2 <dup+0x99>
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
  8012b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 26                	je     8012e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012cf:	6a 00                	push   $0x0
  8012d1:	53                   	push   %ebx
  8012d2:	6a 00                	push   $0x0
  8012d4:	e8 27 fc ff ff       	call   800f00 <sys_page_map>
  8012d9:	89 c3                	mov    %eax,%ebx
  8012db:	83 c4 20             	add    $0x20,%esp
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 2d                	js     80130f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	c1 ea 0c             	shr    $0xc,%edx
  8012ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012fa:	52                   	push   %edx
  8012fb:	56                   	push   %esi
  8012fc:	6a 00                	push   $0x0
  8012fe:	50                   	push   %eax
  8012ff:	6a 00                	push   $0x0
  801301:	e8 fa fb ff ff       	call   800f00 <sys_page_map>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 20             	add    $0x20,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 1d                	jns    80132c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	56                   	push   %esi
  801313:	6a 00                	push   $0x0
  801315:	e8 0c fc ff ff       	call   800f26 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801320:	6a 00                	push   $0x0
  801322:	e8 ff fb ff ff       	call   800f26 <sys_page_unmap>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	eb 02                	jmp    80132e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80132c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80132e:	89 d8                	mov    %ebx,%eax
  801330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	53                   	push   %ebx
  801347:	e8 6b fd ff ff       	call   8010b7 <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 67                	js     8013ba <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	ff 30                	pushl  (%eax)
  80135f:	e8 a9 fd ff ff       	call   80110d <dev_lookup>
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 4f                	js     8013ba <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	8b 50 08             	mov    0x8(%eax),%edx
  801371:	83 e2 03             	and    $0x3,%edx
  801374:	83 fa 01             	cmp    $0x1,%edx
  801377:	75 21                	jne    80139a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801379:	a1 04 44 80 00       	mov    0x804404,%eax
  80137e:	8b 40 48             	mov    0x48(%eax),%eax
  801381:	83 ec 04             	sub    $0x4,%esp
  801384:	53                   	push   %ebx
  801385:	50                   	push   %eax
  801386:	68 80 24 80 00       	push   $0x802480
  80138b:	e8 30 f0 ff ff       	call   8003c0 <cprintf>
		return -E_INVAL;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb 20                	jmp    8013ba <read+0x82>
	}
	if (!dev->dev_read)
  80139a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139d:	8b 52 08             	mov    0x8(%edx),%edx
  8013a0:	85 d2                	test   %edx,%edx
  8013a2:	74 11                	je     8013b5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a4:	83 ec 04             	sub    $0x4,%esp
  8013a7:	ff 75 10             	pushl  0x10(%ebp)
  8013aa:	ff 75 0c             	pushl  0xc(%ebp)
  8013ad:	50                   	push   %eax
  8013ae:	ff d2                	call   *%edx
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb 05                	jmp    8013ba <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	57                   	push   %edi
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ce:	85 f6                	test   %esi,%esi
  8013d0:	74 31                	je     801403 <readn+0x44>
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	89 f2                	mov    %esi,%edx
  8013e1:	29 c2                	sub    %eax,%edx
  8013e3:	52                   	push   %edx
  8013e4:	03 45 0c             	add    0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	57                   	push   %edi
  8013e9:	e8 4a ff ff ff       	call   801338 <read>
		if (m < 0)
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 17                	js     80140c <readn+0x4d>
			return m;
		if (m == 0)
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	74 11                	je     80140a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f9:	01 c3                	add    %eax,%ebx
  8013fb:	89 d8                	mov    %ebx,%eax
  8013fd:	39 f3                	cmp    %esi,%ebx
  8013ff:	72 db                	jb     8013dc <readn+0x1d>
  801401:	eb 09                	jmp    80140c <readn+0x4d>
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
  801408:	eb 02                	jmp    80140c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80140a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80140c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 14             	sub    $0x14,%esp
  80141b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	53                   	push   %ebx
  801423:	e8 8f fc ff ff       	call   8010b7 <fd_lookup>
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 62                	js     801491 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	ff 30                	pushl  (%eax)
  80143b:	e8 cd fc ff ff       	call   80110d <dev_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 4a                	js     801491 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144e:	75 21                	jne    801471 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801450:	a1 04 44 80 00       	mov    0x804404,%eax
  801455:	8b 40 48             	mov    0x48(%eax),%eax
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	53                   	push   %ebx
  80145c:	50                   	push   %eax
  80145d:	68 9c 24 80 00       	push   $0x80249c
  801462:	e8 59 ef ff ff       	call   8003c0 <cprintf>
		return -E_INVAL;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146f:	eb 20                	jmp    801491 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801471:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801474:	8b 52 0c             	mov    0xc(%edx),%edx
  801477:	85 d2                	test   %edx,%edx
  801479:	74 11                	je     80148c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	ff 75 10             	pushl  0x10(%ebp)
  801481:	ff 75 0c             	pushl  0xc(%ebp)
  801484:	50                   	push   %eax
  801485:	ff d2                	call   *%edx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb 05                	jmp    801491 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <seek>:

int
seek(int fdnum, off_t offset)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	ff 75 08             	pushl  0x8(%ebp)
  8014a3:	e8 0f fc ff ff       	call   8010b7 <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 0e                	js     8014bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 e4 fb ff ff       	call   8010b7 <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 5f                	js     801539 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	ff 30                	pushl  (%eax)
  8014e6:	e8 22 fc ff ff       	call   80110d <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 47                	js     801539 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f9:	75 21                	jne    80151c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fb:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801500:	8b 40 48             	mov    0x48(%eax),%eax
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	53                   	push   %ebx
  801507:	50                   	push   %eax
  801508:	68 5c 24 80 00       	push   $0x80245c
  80150d:	e8 ae ee ff ff       	call   8003c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151a:	eb 1d                	jmp    801539 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80151c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151f:	8b 52 18             	mov    0x18(%edx),%edx
  801522:	85 d2                	test   %edx,%edx
  801524:	74 0e                	je     801534 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	50                   	push   %eax
  80152d:	ff d2                	call   *%edx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb 05                	jmp    801539 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801534:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 14             	sub    $0x14,%esp
  801545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	ff 75 08             	pushl  0x8(%ebp)
  80154f:	e8 63 fb ff ff       	call   8010b7 <fd_lookup>
  801554:	83 c4 08             	add    $0x8,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 52                	js     8015ad <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	ff 30                	pushl  (%eax)
  801567:	e8 a1 fb ff ff       	call   80110d <dev_lookup>
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 3a                	js     8015ad <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801576:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80157a:	74 2c                	je     8015a8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80157c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80157f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801586:	00 00 00 
	stat->st_isdir = 0;
  801589:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801590:	00 00 00 
	stat->st_dev = dev;
  801593:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a0:	ff 50 14             	call   *0x14(%eax)
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb 05                	jmp    8015ad <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	6a 00                	push   $0x0
  8015bc:	ff 75 08             	pushl  0x8(%ebp)
  8015bf:	e8 8b 01 00 00       	call   80174f <open>
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 1b                	js     8015e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	ff 75 0c             	pushl  0xc(%ebp)
  8015d3:	50                   	push   %eax
  8015d4:	e8 65 ff ff ff       	call   80153e <fstat>
  8015d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015db:	89 1c 24             	mov    %ebx,(%esp)
  8015de:	e8 18 fc ff ff       	call   8011fb <close>
	return r;
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	89 f3                	mov    %esi,%ebx
}
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    
  8015f1:	00 00                	add    %al,(%eax)
	...

008015f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015fd:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801604:	75 12                	jne    801618 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	6a 01                	push   $0x1
  80160b:	e8 61 07 00 00       	call   801d71 <ipc_find_env>
  801610:	a3 00 44 80 00       	mov    %eax,0x804400
  801615:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801618:	6a 07                	push   $0x7
  80161a:	68 00 50 80 00       	push   $0x805000
  80161f:	53                   	push   %ebx
  801620:	ff 35 00 44 80 00    	pushl  0x804400
  801626:	e8 f1 06 00 00       	call   801d1c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80162b:	83 c4 0c             	add    $0xc,%esp
  80162e:	6a 00                	push   $0x0
  801630:	56                   	push   %esi
  801631:	6a 00                	push   $0x0
  801633:	e8 3c 06 00 00       	call   801c74 <ipc_recv>
}
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 40 0c             	mov    0xc(%eax),%eax
  80164f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801654:	ba 00 00 00 00       	mov    $0x0,%edx
  801659:	b8 05 00 00 00       	mov    $0x5,%eax
  80165e:	e8 91 ff ff ff       	call   8015f4 <fsipc>
  801663:	85 c0                	test   %eax,%eax
  801665:	78 39                	js     8016a0 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	68 cc 24 80 00       	push   $0x8024cc
  80166f:	e8 4c ed ff ff       	call   8003c0 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801674:	83 c4 08             	add    $0x8,%esp
  801677:	68 00 50 80 00       	push   $0x805000
  80167c:	53                   	push   %ebx
  80167d:	e8 d8 f3 ff ff       	call   800a5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801682:	a1 80 50 80 00       	mov    0x805080,%eax
  801687:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80168d:	a1 84 50 80 00       	mov    0x805084,%eax
  801692:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c0:	e8 2f ff ff ff       	call   8015f4 <fsipc>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016da:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ea:	e8 05 ff ff ff       	call   8015f4 <fsipc>
  8016ef:	89 c3                	mov    %eax,%ebx
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 51                	js     801746 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8016f5:	39 c6                	cmp    %eax,%esi
  8016f7:	73 19                	jae    801712 <devfile_read+0x4b>
  8016f9:	68 d2 24 80 00       	push   $0x8024d2
  8016fe:	68 d9 24 80 00       	push   $0x8024d9
  801703:	68 80 00 00 00       	push   $0x80
  801708:	68 ee 24 80 00       	push   $0x8024ee
  80170d:	e8 d6 eb ff ff       	call   8002e8 <_panic>
	assert(r <= PGSIZE);
  801712:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801717:	7e 19                	jle    801732 <devfile_read+0x6b>
  801719:	68 f9 24 80 00       	push   $0x8024f9
  80171e:	68 d9 24 80 00       	push   $0x8024d9
  801723:	68 81 00 00 00       	push   $0x81
  801728:	68 ee 24 80 00       	push   $0x8024ee
  80172d:	e8 b6 eb ff ff       	call   8002e8 <_panic>
	memmove(buf, &fsipcbuf, r);
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	50                   	push   %eax
  801736:	68 00 50 80 00       	push   $0x805000
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	e8 d8 f4 ff ff       	call   800c1b <memmove>
	return r;
  801743:	83 c4 10             	add    $0x10,%esp
}
  801746:	89 d8                	mov    %ebx,%eax
  801748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	83 ec 1c             	sub    $0x1c,%esp
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80175a:	56                   	push   %esi
  80175b:	e8 a8 f2 ff ff       	call   800a08 <strlen>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801768:	7f 72                	jg     8017dc <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	e8 ce f8 ff ff       	call   801044 <fd_alloc>
  801776:	89 c3                	mov    %eax,%ebx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 62                	js     8017e1 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	56                   	push   %esi
  801783:	68 00 50 80 00       	push   $0x805000
  801788:	e8 cd f2 ff ff       	call   800a5a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80178d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801790:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801795:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801798:	b8 01 00 00 00       	mov    $0x1,%eax
  80179d:	e8 52 fe ff ff       	call   8015f4 <fsipc>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	79 12                	jns    8017bd <open+0x6e>
		fd_close(fd, 0);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	6a 00                	push   $0x0
  8017b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b3:	e8 bb f9 ff ff       	call   801173 <fd_close>
		return r;
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	eb 24                	jmp    8017e1 <open+0x92>
	}


	cprintf("OPEN\n");
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	68 05 25 80 00       	push   $0x802505
  8017c5:	e8 f6 eb ff ff       	call   8003c0 <cprintf>

	return fd2num(fd);
  8017ca:	83 c4 04             	add    $0x4,%esp
  8017cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d0:	e8 47 f8 ff ff       	call   80101c <fd2num>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	eb 05                	jmp    8017e1 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017dc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8017e1:	89 d8                	mov    %ebx,%eax
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    
	...

008017ec <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017f5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017f9:	7e 2e                	jle    801829 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	ff 70 04             	pushl  0x4(%eax)
  801801:	8d 40 10             	lea    0x10(%eax),%eax
  801804:	50                   	push   %eax
  801805:	ff 33                	pushl  (%ebx)
  801807:	e8 08 fc ff ff       	call   801414 <write>
		if (result > 0)
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	7e 03                	jle    801816 <writebuf+0x2a>
			b->result += result;
  801813:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801816:	39 43 04             	cmp    %eax,0x4(%ebx)
  801819:	74 0e                	je     801829 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	85 c0                	test   %eax,%eax
  80181f:	7e 05                	jle    801826 <writebuf+0x3a>
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <putch>:

static void
putch(int ch, void *thunk)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	53                   	push   %ebx
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801838:	8b 43 04             	mov    0x4(%ebx),%eax
  80183b:	8b 55 08             	mov    0x8(%ebp),%edx
  80183e:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801842:	40                   	inc    %eax
  801843:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801846:	3d 00 01 00 00       	cmp    $0x100,%eax
  80184b:	75 0e                	jne    80185b <putch+0x2d>
		writebuf(b);
  80184d:	89 d8                	mov    %ebx,%eax
  80184f:	e8 98 ff ff ff       	call   8017ec <writebuf>
		b->idx = 0;
  801854:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80185b:	83 c4 04             	add    $0x4,%esp
  80185e:	5b                   	pop    %ebx
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801873:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80187a:	00 00 00 
	b.result = 0;
  80187d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801884:	00 00 00 
	b.error = 1;
  801887:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80188e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801891:	ff 75 10             	pushl  0x10(%ebp)
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80189d:	50                   	push   %eax
  80189e:	68 2e 18 80 00       	push   $0x80182e
  8018a3:	e8 7d ec ff ff       	call   800525 <vprintfmt>
	if (b.idx > 0)
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018b2:	7e 0b                	jle    8018bf <vfprintf+0x5e>
		writebuf(&b);
  8018b4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018ba:	e8 2d ff ff ff       	call   8017ec <writebuf>

	return (b.result ? b.result : b.error);
  8018bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	75 06                	jne    8018cf <vfprintf+0x6e>
  8018c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018d7:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018da:	50                   	push   %eax
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 7b ff ff ff       	call   801861 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <printf>:

int
printf(const char *fmt, ...)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018f1:	50                   	push   %eax
  8018f2:	ff 75 08             	pushl  0x8(%ebp)
  8018f5:	6a 01                	push   $0x1
  8018f7:	e8 65 ff ff ff       	call   801861 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    
	...

00801900 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 08             	pushl  0x8(%ebp)
  80190e:	e8 19 f7 ff ff       	call   80102c <fd2data>
  801913:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801915:	83 c4 08             	add    $0x8,%esp
  801918:	68 0b 25 80 00       	push   $0x80250b
  80191d:	56                   	push   %esi
  80191e:	e8 37 f1 ff ff       	call   800a5a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801923:	8b 43 04             	mov    0x4(%ebx),%eax
  801926:	2b 03                	sub    (%ebx),%eax
  801928:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80192e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801935:	00 00 00 
	stat->st_dev = &devpipe;
  801938:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  80193f:	30 80 00 
	return 0;
}
  801942:	b8 00 00 00 00       	mov    $0x0,%eax
  801947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801958:	53                   	push   %ebx
  801959:	6a 00                	push   $0x0
  80195b:	e8 c6 f5 ff ff       	call   800f26 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801960:	89 1c 24             	mov    %ebx,(%esp)
  801963:	e8 c4 f6 ff ff       	call   80102c <fd2data>
  801968:	83 c4 08             	add    $0x8,%esp
  80196b:	50                   	push   %eax
  80196c:	6a 00                	push   $0x0
  80196e:	e8 b3 f5 ff ff       	call   800f26 <sys_page_unmap>
}
  801973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	57                   	push   %edi
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
  80197e:	83 ec 1c             	sub    $0x1c,%esp
  801981:	89 c7                	mov    %eax,%edi
  801983:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801986:	a1 04 44 80 00       	mov    0x804404,%eax
  80198b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	57                   	push   %edi
  801992:	e8 35 04 00 00       	call   801dcc <pageref>
  801997:	89 c6                	mov    %eax,%esi
  801999:	83 c4 04             	add    $0x4,%esp
  80199c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80199f:	e8 28 04 00 00       	call   801dcc <pageref>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	39 c6                	cmp    %eax,%esi
  8019a9:	0f 94 c0             	sete   %al
  8019ac:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019af:	8b 15 04 44 80 00    	mov    0x804404,%edx
  8019b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019b8:	39 cb                	cmp    %ecx,%ebx
  8019ba:	75 08                	jne    8019c4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5e                   	pop    %esi
  8019c1:	5f                   	pop    %edi
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019c4:	83 f8 01             	cmp    $0x1,%eax
  8019c7:	75 bd                	jne    801986 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c9:	8b 42 58             	mov    0x58(%edx),%eax
  8019cc:	6a 01                	push   $0x1
  8019ce:	50                   	push   %eax
  8019cf:	53                   	push   %ebx
  8019d0:	68 12 25 80 00       	push   $0x802512
  8019d5:	e8 e6 e9 ff ff       	call   8003c0 <cprintf>
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	eb a7                	jmp    801986 <_pipeisclosed+0xe>

008019df <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	57                   	push   %edi
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 28             	sub    $0x28,%esp
  8019e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019eb:	56                   	push   %esi
  8019ec:	e8 3b f6 ff ff       	call   80102c <fd2data>
  8019f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fa:	75 4a                	jne    801a46 <devpipe_write+0x67>
  8019fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801a01:	eb 56                	jmp    801a59 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a03:	89 da                	mov    %ebx,%edx
  801a05:	89 f0                	mov    %esi,%eax
  801a07:	e8 6c ff ff ff       	call   801978 <_pipeisclosed>
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	75 4d                	jne    801a5d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a10:	e8 a0 f4 ff ff       	call   800eb5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a15:	8b 43 04             	mov    0x4(%ebx),%eax
  801a18:	8b 13                	mov    (%ebx),%edx
  801a1a:	83 c2 20             	add    $0x20,%edx
  801a1d:	39 d0                	cmp    %edx,%eax
  801a1f:	73 e2                	jae    801a03 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a29:	79 05                	jns    801a30 <devpipe_write+0x51>
  801a2b:	4a                   	dec    %edx
  801a2c:	83 ca e0             	or     $0xffffffe0,%edx
  801a2f:	42                   	inc    %edx
  801a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a33:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a36:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a3a:	40                   	inc    %eax
  801a3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3e:	47                   	inc    %edi
  801a3f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a42:	77 07                	ja     801a4b <devpipe_write+0x6c>
  801a44:	eb 13                	jmp    801a59 <devpipe_write+0x7a>
  801a46:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a4b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a4e:	8b 13                	mov    (%ebx),%edx
  801a50:	83 c2 20             	add    $0x20,%edx
  801a53:	39 d0                	cmp    %edx,%eax
  801a55:	73 ac                	jae    801a03 <devpipe_write+0x24>
  801a57:	eb c8                	jmp    801a21 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a59:	89 f8                	mov    %edi,%eax
  801a5b:	eb 05                	jmp    801a62 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5f                   	pop    %edi
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 18             	sub    $0x18,%esp
  801a73:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a76:	57                   	push   %edi
  801a77:	e8 b0 f5 ff ff       	call   80102c <fd2data>
  801a7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a85:	75 44                	jne    801acb <devpipe_read+0x61>
  801a87:	be 00 00 00 00       	mov    $0x0,%esi
  801a8c:	eb 4f                	jmp    801add <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	eb 54                	jmp    801ae6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a92:	89 da                	mov    %ebx,%edx
  801a94:	89 f8                	mov    %edi,%eax
  801a96:	e8 dd fe ff ff       	call   801978 <_pipeisclosed>
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	75 42                	jne    801ae1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a9f:	e8 11 f4 ff ff       	call   800eb5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aa4:	8b 03                	mov    (%ebx),%eax
  801aa6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aa9:	74 e7                	je     801a92 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aab:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ab0:	79 05                	jns    801ab7 <devpipe_read+0x4d>
  801ab2:	48                   	dec    %eax
  801ab3:	83 c8 e0             	or     $0xffffffe0,%eax
  801ab6:	40                   	inc    %eax
  801ab7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abe:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ac1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac3:	46                   	inc    %esi
  801ac4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801ac7:	77 07                	ja     801ad0 <devpipe_read+0x66>
  801ac9:	eb 12                	jmp    801add <devpipe_read+0x73>
  801acb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801ad0:	8b 03                	mov    (%ebx),%eax
  801ad2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ad5:	75 d4                	jne    801aab <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad7:	85 f6                	test   %esi,%esi
  801ad9:	75 b3                	jne    801a8e <devpipe_read+0x24>
  801adb:	eb b5                	jmp    801a92 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801add:	89 f0                	mov    %esi,%eax
  801adf:	eb 05                	jmp    801ae6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 28             	sub    $0x28,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801afa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	e8 41 f5 ff ff       	call   801044 <fd_alloc>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 24 01 00 00    	js     801c34 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	68 07 04 00 00       	push   $0x407
  801b18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1b:	6a 00                	push   $0x0
  801b1d:	e8 ba f3 ff ff       	call   800edc <sys_page_alloc>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	85 c0                	test   %eax,%eax
  801b29:	0f 88 05 01 00 00    	js     801c34 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	e8 09 f5 ff ff       	call   801044 <fd_alloc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	0f 88 dc 00 00 00    	js     801c24 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	68 07 04 00 00       	push   $0x407
  801b50:	ff 75 e0             	pushl  -0x20(%ebp)
  801b53:	6a 00                	push   $0x0
  801b55:	e8 82 f3 ff ff       	call   800edc <sys_page_alloc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	0f 88 bd 00 00 00    	js     801c24 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b6d:	e8 ba f4 ff ff       	call   80102c <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b74:	83 c4 0c             	add    $0xc,%esp
  801b77:	68 07 04 00 00       	push   $0x407
  801b7c:	50                   	push   %eax
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 58 f3 ff ff       	call   800edc <sys_page_alloc>
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	0f 88 83 00 00 00    	js     801c14 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	ff 75 e0             	pushl  -0x20(%ebp)
  801b97:	e8 90 f4 ff ff       	call   80102c <fd2data>
  801b9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba3:	50                   	push   %eax
  801ba4:	6a 00                	push   $0x0
  801ba6:	56                   	push   %esi
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 52 f3 ff ff       	call   800f00 <sys_page_map>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 20             	add    $0x20,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 4f                	js     801c06 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be7:	e8 30 f4 ff ff       	call   80101c <fd2num>
  801bec:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bee:	83 c4 04             	add    $0x4,%esp
  801bf1:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf4:	e8 23 f4 ff ff       	call   80101c <fd2num>
  801bf9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c04:	eb 2e                	jmp    801c34 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c06:	83 ec 08             	sub    $0x8,%esp
  801c09:	56                   	push   %esi
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 15 f3 ff ff       	call   800f26 <sys_page_unmap>
  801c11:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	ff 75 e0             	pushl  -0x20(%ebp)
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 05 f3 ff ff       	call   800f26 <sys_page_unmap>
  801c21:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 f5 f2 ff ff       	call   800f26 <sys_page_unmap>
  801c31:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c47:	50                   	push   %eax
  801c48:	ff 75 08             	pushl  0x8(%ebp)
  801c4b:	e8 67 f4 ff ff       	call   8010b7 <fd_lookup>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 18                	js     801c6f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 ca f3 ff ff       	call   80102c <fd2data>
	return _pipeisclosed(fd, p);
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	e8 0c fd ff ff       	call   801978 <_pipeisclosed>
  801c6c:	83 c4 10             	add    $0x10,%esp
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    
  801c71:	00 00                	add    %al,(%eax)
	...

00801c74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	57                   	push   %edi
  801c78:	56                   	push   %esi
  801c79:	53                   	push   %ebx
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c83:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	57                   	push   %edi
  801c89:	68 2a 25 80 00       	push   $0x80252a
  801c8e:	e8 2d e7 ff ff       	call   8003c0 <cprintf>
	int r;
	if (pg != NULL) {
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 db                	test   %ebx,%ebx
  801c98:	74 28                	je     801cc2 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	68 3a 25 80 00       	push   $0x80253a
  801ca2:	e8 19 e7 ff ff       	call   8003c0 <cprintf>
		r = sys_ipc_recv(pg);
  801ca7:	89 1c 24             	mov    %ebx,(%esp)
  801caa:	e8 28 f3 ff ff       	call   800fd7 <sys_ipc_recv>
  801caf:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801cb1:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  801cb8:	e8 03 e7 ff ff       	call   8003c0 <cprintf>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	eb 12                	jmp    801cd4 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801cc2:	83 ec 0c             	sub    $0xc,%esp
  801cc5:	68 00 00 c0 ee       	push   $0xeec00000
  801cca:	e8 08 f3 ff ff       	call   800fd7 <sys_ipc_recv>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801cd4:	85 db                	test   %ebx,%ebx
  801cd6:	75 26                	jne    801cfe <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cd8:	85 ff                	test   %edi,%edi
  801cda:	74 0a                	je     801ce6 <ipc_recv+0x72>
  801cdc:	a1 04 44 80 00       	mov    0x804404,%eax
  801ce1:	8b 40 74             	mov    0x74(%eax),%eax
  801ce4:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ce6:	85 f6                	test   %esi,%esi
  801ce8:	74 0a                	je     801cf4 <ipc_recv+0x80>
  801cea:	a1 04 44 80 00       	mov    0x804404,%eax
  801cef:	8b 40 78             	mov    0x78(%eax),%eax
  801cf2:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801cf4:	a1 04 44 80 00       	mov    0x804404,%eax
  801cf9:	8b 58 70             	mov    0x70(%eax),%ebx
  801cfc:	eb 14                	jmp    801d12 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801cfe:	85 ff                	test   %edi,%edi
  801d00:	74 06                	je     801d08 <ipc_recv+0x94>
  801d02:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801d08:	85 f6                	test   %esi,%esi
  801d0a:	74 06                	je     801d12 <ipc_recv+0x9e>
  801d0c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	57                   	push   %edi
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d2b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801d2e:	85 db                	test   %ebx,%ebx
  801d30:	75 25                	jne    801d57 <ipc_send+0x3b>
  801d32:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801d37:	eb 1e                	jmp    801d57 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801d39:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d3c:	75 07                	jne    801d45 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801d3e:	e8 72 f1 ff ff       	call   800eb5 <sys_yield>
  801d43:	eb 12                	jmp    801d57 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801d45:	50                   	push   %eax
  801d46:	68 41 25 80 00       	push   $0x802541
  801d4b:	6a 45                	push   $0x45
  801d4d:	68 54 25 80 00       	push   $0x802554
  801d52:	e8 91 e5 ff ff       	call   8002e8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	57                   	push   %edi
  801d5a:	ff 75 08             	pushl  0x8(%ebp)
  801d5d:	e8 50 f2 ff ff       	call   800fb2 <sys_ipc_try_send>
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	75 d0                	jne    801d39 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	53                   	push   %ebx
  801d75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d78:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801d7e:	74 22                	je     801da2 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d80:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d85:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	c1 e2 07             	shl    $0x7,%edx
  801d91:	29 ca                	sub    %ecx,%edx
  801d93:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d99:	8b 52 50             	mov    0x50(%edx),%edx
  801d9c:	39 da                	cmp    %ebx,%edx
  801d9e:	75 1d                	jne    801dbd <ipc_find_env+0x4c>
  801da0:	eb 05                	jmp    801da7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801dae:	c1 e0 07             	shl    $0x7,%eax
  801db1:	29 d0                	sub    %edx,%eax
  801db3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801db8:	8b 40 40             	mov    0x40(%eax),%eax
  801dbb:	eb 0c                	jmp    801dc9 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dbd:	40                   	inc    %eax
  801dbe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc3:	75 c0                	jne    801d85 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dc5:	66 b8 00 00          	mov    $0x0,%ax
}
  801dc9:	5b                   	pop    %ebx
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dd2:	89 c2                	mov    %eax,%edx
  801dd4:	c1 ea 16             	shr    $0x16,%edx
  801dd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dde:	f6 c2 01             	test   $0x1,%dl
  801de1:	74 1e                	je     801e01 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801de3:	c1 e8 0c             	shr    $0xc,%eax
  801de6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ded:	a8 01                	test   $0x1,%al
  801def:	74 17                	je     801e08 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df1:	c1 e8 0c             	shr    $0xc,%eax
  801df4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dfb:	ef 
  801dfc:	0f b7 c0             	movzwl %ax,%eax
  801dff:	eb 0c                	jmp    801e0d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
  801e06:	eb 05                	jmp    801e0d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    
	...

00801e10 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	57                   	push   %edi
  801e14:	56                   	push   %esi
  801e15:	83 ec 10             	sub    $0x10,%esp
  801e18:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e1e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801e21:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e24:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e27:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	75 2e                	jne    801e5c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e2e:	39 f1                	cmp    %esi,%ecx
  801e30:	77 5a                	ja     801e8c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e32:	85 c9                	test   %ecx,%ecx
  801e34:	75 0b                	jne    801e41 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f1                	div    %ecx
  801e3f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e41:	31 d2                	xor    %edx,%edx
  801e43:	89 f0                	mov    %esi,%eax
  801e45:	f7 f1                	div    %ecx
  801e47:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	f7 f1                	div    %ecx
  801e4d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e4f:	89 f8                	mov    %edi,%eax
  801e51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    
  801e5a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e5c:	39 f0                	cmp    %esi,%eax
  801e5e:	77 1c                	ja     801e7c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e60:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801e63:	83 f7 1f             	xor    $0x1f,%edi
  801e66:	75 3c                	jne    801ea4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e68:	39 f0                	cmp    %esi,%eax
  801e6a:	0f 82 90 00 00 00    	jb     801f00 <__udivdi3+0xf0>
  801e70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e73:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e76:	0f 86 84 00 00 00    	jbe    801f00 <__udivdi3+0xf0>
  801e7c:	31 f6                	xor    %esi,%esi
  801e7e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e80:	89 f8                	mov    %edi,%eax
  801e82:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	5e                   	pop    %esi
  801e88:	5f                   	pop    %edi
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    
  801e8b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e8c:	89 f2                	mov    %esi,%edx
  801e8e:	89 f8                	mov    %edi,%eax
  801e90:	f7 f1                	div    %ecx
  801e92:	89 c7                	mov    %eax,%edi
  801e94:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e96:	89 f8                	mov    %edi,%eax
  801e98:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    
  801ea1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea4:	89 f9                	mov    %edi,%ecx
  801ea6:	d3 e0                	shl    %cl,%eax
  801ea8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eab:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eb5:	88 c1                	mov    %al,%cl
  801eb7:	d3 ea                	shr    %cl,%edx
  801eb9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ebc:	09 ca                	or     %ecx,%edx
  801ebe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ec1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec4:	89 f9                	mov    %edi,%ecx
  801ec6:	d3 e2                	shl    %cl,%edx
  801ec8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801ecb:	89 f2                	mov    %esi,%edx
  801ecd:	88 c1                	mov    %al,%cl
  801ecf:	d3 ea                	shr    %cl,%edx
  801ed1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	89 f9                	mov    %edi,%ecx
  801ed8:	d3 e2                	shl    %cl,%edx
  801eda:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801edd:	88 c1                	mov    %al,%cl
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ee3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ee6:	89 f0                	mov    %esi,%eax
  801ee8:	89 ca                	mov    %ecx,%edx
  801eea:	f7 75 ec             	divl   -0x14(%ebp)
  801eed:	89 d1                	mov    %edx,%ecx
  801eef:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ef1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ef4:	39 d1                	cmp    %edx,%ecx
  801ef6:	72 28                	jb     801f20 <__udivdi3+0x110>
  801ef8:	74 1a                	je     801f14 <__udivdi3+0x104>
  801efa:	89 f7                	mov    %esi,%edi
  801efc:	31 f6                	xor    %esi,%esi
  801efe:	eb 80                	jmp    801e80 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f00:	31 f6                	xor    %esi,%esi
  801f02:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f07:	89 f8                	mov    %edi,%eax
  801f09:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    
  801f12:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f17:	89 f9                	mov    %edi,%ecx
  801f19:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f1b:	39 c2                	cmp    %eax,%edx
  801f1d:	73 db                	jae    801efa <__udivdi3+0xea>
  801f1f:	90                   	nop
		{
		  q0--;
  801f20:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f23:	31 f6                	xor    %esi,%esi
  801f25:	e9 56 ff ff ff       	jmp    801e80 <__udivdi3+0x70>
	...

00801f2c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	57                   	push   %edi
  801f30:	56                   	push   %esi
  801f31:	83 ec 20             	sub    $0x20,%esp
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801f3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f40:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f43:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801f49:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	75 15                	jne    801f64 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801f4f:	39 f1                	cmp    %esi,%ecx
  801f51:	0f 86 99 00 00 00    	jbe    801ff0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f57:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f5d:	83 c4 20             	add    $0x20,%esp
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f64:	39 f7                	cmp    %esi,%edi
  801f66:	0f 87 a4 00 00 00    	ja     802010 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f6c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801f6f:	83 f0 1f             	xor    $0x1f,%eax
  801f72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f75:	0f 84 a1 00 00 00    	je     80201c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f7b:	89 f8                	mov    %edi,%eax
  801f7d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f80:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f82:	bf 20 00 00 00       	mov    $0x20,%edi
  801f87:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f8d:	89 f9                	mov    %edi,%ecx
  801f8f:	d3 ea                	shr    %cl,%edx
  801f91:	09 c2                	or     %eax,%edx
  801f93:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f99:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f9c:	d3 e0                	shl    %cl,%eax
  801f9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fa1:	89 f2                	mov    %esi,%edx
  801fa3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fa8:	d3 e0                	shl    %cl,%eax
  801faa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fb0:	89 f9                	mov    %edi,%ecx
  801fb2:	d3 e8                	shr    %cl,%eax
  801fb4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801fb6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fb8:	89 f2                	mov    %esi,%edx
  801fba:	f7 75 f0             	divl   -0x10(%ebp)
  801fbd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801fbf:	f7 65 f4             	mull   -0xc(%ebp)
  801fc2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801fc5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fc7:	39 d6                	cmp    %edx,%esi
  801fc9:	72 71                	jb     80203c <__umoddi3+0x110>
  801fcb:	74 7f                	je     80204c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd0:	29 c8                	sub    %ecx,%eax
  801fd2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fd4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fd7:	d3 e8                	shr    %cl,%eax
  801fd9:	89 f2                	mov    %esi,%edx
  801fdb:	89 f9                	mov    %edi,%ecx
  801fdd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fdf:	09 d0                	or     %edx,%eax
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fe6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fe8:	83 c4 20             	add    $0x20,%esp
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    
  801fef:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ff0:	85 c9                	test   %ecx,%ecx
  801ff2:	75 0b                	jne    801fff <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ff4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff9:	31 d2                	xor    %edx,%edx
  801ffb:	f7 f1                	div    %ecx
  801ffd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fff:	89 f0                	mov    %esi,%eax
  802001:	31 d2                	xor    %edx,%edx
  802003:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802005:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802008:	f7 f1                	div    %ecx
  80200a:	e9 4a ff ff ff       	jmp    801f59 <__umoddi3+0x2d>
  80200f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802010:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802012:	83 c4 20             	add    $0x20,%esp
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	c9                   	leave  
  802018:	c3                   	ret    
  802019:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80201c:	39 f7                	cmp    %esi,%edi
  80201e:	72 05                	jb     802025 <__umoddi3+0xf9>
  802020:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802023:	77 0c                	ja     802031 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802025:	89 f2                	mov    %esi,%edx
  802027:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80202a:	29 c8                	sub    %ecx,%eax
  80202c:	19 fa                	sbb    %edi,%edx
  80202e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802031:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802034:	83 c4 20             	add    $0x20,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	c9                   	leave  
  80203a:	c3                   	ret    
  80203b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80203c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802044:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802047:	eb 84                	jmp    801fcd <__umoddi3+0xa1>
  802049:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80204c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80204f:	72 eb                	jb     80203c <__umoddi3+0x110>
  802051:	89 f2                	mov    %esi,%edx
  802053:	e9 75 ff ff ff       	jmp    801fcd <__umoddi3+0xa1>
