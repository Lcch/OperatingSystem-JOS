
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 db 01 00 00       	call   80020c <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 06 03 00 00       	call   80034c <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 f1 1c 00 00       	call   801d42 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 59 23 80 00       	push   $0x802359
  80005e:	6a 0d                	push   $0xd
  800060:	68 62 23 80 00       	push   $0x802362
  800065:	e8 0a 02 00 00       	call   800274 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  80006a:	e8 93 0f 00 00       	call   801002 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 76 23 80 00       	push   $0x802376
  80007b:	6a 10                	push   $0x10
  80007d:	68 62 23 80 00       	push   $0x802362
  800082:	e8 ed 01 00 00       	call   800274 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 59                	jne    8000e4 <umain+0xb0>
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	e8 a9 14 00 00       	call   80153f <close>
  800096:	83 c4 10             	add    $0x10,%esp
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if(pipeisclosed(p[0])){
  80009e:	83 ec 0c             	sub    $0xc,%esp
  8000a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a4:	e8 e9 1d 00 00       	call   801e92 <pipeisclosed>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	85 c0                	test   %eax,%eax
  8000ae:	74 15                	je     8000c5 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000b0:	83 ec 0c             	sub    $0xc,%esp
  8000b3:	68 7f 23 80 00       	push   $0x80237f
  8000b8:	e8 8f 02 00 00       	call   80034c <cprintf>
				exit();
  8000bd:	e8 96 01 00 00       	call   800258 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c5:	e8 93 0c 00 00       	call   800d5d <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000ca:	43                   	inc    %ebx
  8000cb:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000d1:	75 cb                	jne    80009e <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	6a 00                	push   $0x0
  8000d8:	6a 00                	push   $0x0
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 67 11 00 00       	call   801248 <ipc_recv>
  8000e1:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	56                   	push   %esi
  8000e8:	68 9a 23 80 00       	push   $0x80239a
  8000ed:	e8 5a 02 00 00       	call   80034c <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8000f8:	89 f0                	mov    %esi,%eax
  8000fa:	c1 e0 07             	shl    $0x7,%eax
  8000fd:	8d 1c b0             	lea    (%eax,%esi,4),%ebx
	cprintf("kid is %d\n", kid-envs);
  800100:	83 c4 08             	add    $0x8,%esp
  800103:	89 d8                	mov    %ebx,%eax
  800105:	c1 e8 02             	shr    $0x2,%eax
  800108:	89 c1                	mov    %eax,%ecx
  80010a:	c1 e1 05             	shl    $0x5,%ecx
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 0a             	shl    $0xa,%edx
  800112:	29 ca                	sub    %ecx,%edx
  800114:	01 c2                	add    %eax,%edx
  800116:	89 d1                	mov    %edx,%ecx
  800118:	c1 e1 0f             	shl    $0xf,%ecx
  80011b:	29 d1                	sub    %edx,%ecx
  80011d:	89 ca                	mov    %ecx,%edx
  80011f:	c1 e2 05             	shl    $0x5,%edx
  800122:	8d 04 02             	lea    (%edx,%eax,1),%eax
  800125:	50                   	push   %eax
  800126:	68 a5 23 80 00       	push   $0x8023a5
  80012b:	e8 1c 02 00 00       	call   80034c <cprintf>
	dup(p[0], 10);
  800130:	83 c4 08             	add    $0x8,%esp
  800133:	6a 0a                	push   $0xa
  800135:	ff 75 f0             	pushl  -0x10(%ebp)
  800138:	e8 50 14 00 00       	call   80158d <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80013d:	81 c3 04 00 c0 ee    	add    $0xeec00004,%ebx
  800143:	8b 43 50             	mov    0x50(%ebx),%eax
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	83 f8 02             	cmp    $0x2,%eax
  80014c:	75 18                	jne    800166 <umain+0x132>
		dup(p[0], 10);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	6a 0a                	push   $0xa
  800153:	ff 75 f0             	pushl  -0x10(%ebp)
  800156:	e8 32 14 00 00       	call   80158d <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  80015b:	8b 43 50             	mov    0x50(%ebx),%eax
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	83 f8 02             	cmp    $0x2,%eax
  800164:	74 e8                	je     80014e <umain+0x11a>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	68 b0 23 80 00       	push   $0x8023b0
  80016e:	e8 d9 01 00 00       	call   80034c <cprintf>
	if (pipeisclosed(p[0]))
  800173:	83 c4 04             	add    $0x4,%esp
  800176:	ff 75 f0             	pushl  -0x10(%ebp)
  800179:	e8 14 1d 00 00       	call   801e92 <pipeisclosed>
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	85 c0                	test   %eax,%eax
  800183:	74 14                	je     800199 <umain+0x165>
		panic("somehow the other end of p[0] got closed!");
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	68 0c 24 80 00       	push   $0x80240c
  80018d:	6a 3a                	push   $0x3a
  80018f:	68 62 23 80 00       	push   $0x802362
  800194:	e8 db 00 00 00       	call   800274 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8001a3:	e8 53 12 00 00       	call   8013fb <fd_lookup>
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	79 12                	jns    8001c1 <umain+0x18d>
		panic("cannot look up p[0]: %e", r);
  8001af:	50                   	push   %eax
  8001b0:	68 c6 23 80 00       	push   $0x8023c6
  8001b5:	6a 3c                	push   $0x3c
  8001b7:	68 62 23 80 00       	push   $0x802362
  8001bc:	e8 b3 00 00 00       	call   800274 <_panic>
	va = fd2data(fd);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	ff 75 ec             	pushl  -0x14(%ebp)
  8001c7:	e8 a4 11 00 00       	call   801370 <fd2data>
	if (pageref(va) != 3+1)
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 3c 19 00 00       	call   801b10 <pageref>
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	83 f8 04             	cmp    $0x4,%eax
  8001da:	74 12                	je     8001ee <umain+0x1ba>
		cprintf("\nchild detected race\n");
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	68 de 23 80 00       	push   $0x8023de
  8001e4:	e8 63 01 00 00       	call   80034c <cprintf>
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	eb 15                	jmp    800203 <umain+0x1cf>
	else
		cprintf("\nrace didn't happen\n", max);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	68 c8 00 00 00       	push   $0xc8
  8001f6:	68 f4 23 80 00       	push   $0x8023f4
  8001fb:	e8 4c 01 00 00       	call   80034c <cprintf>
  800200:	83 c4 10             	add    $0x10,%esp
}
  800203:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	c9                   	leave  
  800209:	c3                   	ret    
	...

0080020c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	8b 75 08             	mov    0x8(%ebp),%esi
  800214:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800217:	e8 1d 0b 00 00       	call   800d39 <sys_getenvid>
  80021c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800221:	89 c2                	mov    %eax,%edx
  800223:	c1 e2 07             	shl    $0x7,%edx
  800226:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80022d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800232:	85 f6                	test   %esi,%esi
  800234:	7e 07                	jle    80023d <libmain+0x31>
		binaryname = argv[0];
  800236:	8b 03                	mov    (%ebx),%eax
  800238:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	53                   	push   %ebx
  800241:	56                   	push   %esi
  800242:	e8 ed fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800247:	e8 0c 00 00 00       	call   800258 <exit>
  80024c:	83 c4 10             	add    $0x10,%esp
}
  80024f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	c9                   	leave  
  800255:	c3                   	ret    
	...

00800258 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80025e:	e8 07 13 00 00       	call   80156a <close_all>
	sys_env_destroy(0);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	6a 00                	push   $0x0
  800268:	e8 aa 0a 00 00       	call   800d17 <sys_env_destroy>
  80026d:	83 c4 10             	add    $0x10,%esp
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
	...

00800274 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800279:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80027c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800282:	e8 b2 0a 00 00       	call   800d39 <sys_getenvid>
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	53                   	push   %ebx
  800291:	50                   	push   %eax
  800292:	68 40 24 80 00       	push   $0x802440
  800297:	e8 b0 00 00 00       	call   80034c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	56                   	push   %esi
  8002a0:	ff 75 10             	pushl  0x10(%ebp)
  8002a3:	e8 53 00 00 00       	call   8002fb <vcprintf>
	cprintf("\n");
  8002a8:	c7 04 24 57 23 80 00 	movl   $0x802357,(%esp)
  8002af:	e8 98 00 00 00       	call   80034c <cprintf>
  8002b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002b7:	cc                   	int3   
  8002b8:	eb fd                	jmp    8002b7 <_panic+0x43>
	...

008002bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c6:	8b 03                	mov    (%ebx),%eax
  8002c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002cf:	40                   	inc    %eax
  8002d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002d7:	75 1a                	jne    8002f3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	68 ff 00 00 00       	push   $0xff
  8002e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e4:	50                   	push   %eax
  8002e5:	e8 e3 09 00 00       	call   800ccd <sys_cputs>
		b->idx = 0;
  8002ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002f0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002f3:	ff 43 04             	incl   0x4(%ebx)
}
  8002f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800304:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80030b:	00 00 00 
	b.cnt = 0;
  80030e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800315:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800324:	50                   	push   %eax
  800325:	68 bc 02 80 00       	push   $0x8002bc
  80032a:	e8 82 01 00 00       	call   8004b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80032f:	83 c4 08             	add    $0x8,%esp
  800332:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800338:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80033e:	50                   	push   %eax
  80033f:	e8 89 09 00 00       	call   800ccd <sys_cputs>

	return b.cnt;
}
  800344:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800352:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	e8 9d ff ff ff       	call   8002fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d6                	mov    %edx,%esi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	8b 55 0c             	mov    0xc(%ebp),%edx
  800374:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800377:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80037a:	8b 45 10             	mov    0x10(%ebp),%eax
  80037d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800380:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800383:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800386:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80038d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800390:	72 0c                	jb     80039e <printnum+0x3e>
  800392:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800395:	76 07                	jbe    80039e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800397:	4b                   	dec    %ebx
  800398:	85 db                	test   %ebx,%ebx
  80039a:	7f 31                	jg     8003cd <printnum+0x6d>
  80039c:	eb 3f                	jmp    8003dd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80039e:	83 ec 0c             	sub    $0xc,%esp
  8003a1:	57                   	push   %edi
  8003a2:	4b                   	dec    %ebx
  8003a3:	53                   	push   %ebx
  8003a4:	50                   	push   %eax
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003ab:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b4:	e8 33 1d 00 00       	call   8020ec <__udivdi3>
  8003b9:	83 c4 18             	add    $0x18,%esp
  8003bc:	52                   	push   %edx
  8003bd:	50                   	push   %eax
  8003be:	89 f2                	mov    %esi,%edx
  8003c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c3:	e8 98 ff ff ff       	call   800360 <printnum>
  8003c8:	83 c4 20             	add    $0x20,%esp
  8003cb:	eb 10                	jmp    8003dd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	57                   	push   %edi
  8003d2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d5:	4b                   	dec    %ebx
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	85 db                	test   %ebx,%ebx
  8003db:	7f f0                	jg     8003cd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	56                   	push   %esi
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f0:	e8 13 1e 00 00       	call   802208 <__umoddi3>
  8003f5:	83 c4 14             	add    $0x14,%esp
  8003f8:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  8003ff:	50                   	push   %eax
  800400:	ff 55 e4             	call   *-0x1c(%ebp)
  800403:	83 c4 10             	add    $0x10,%esp
}
  800406:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80044b:	83 fa 01             	cmp    $0x1,%edx
  80044e:	7e 0e                	jle    80045e <getint+0x16>
		return va_arg(*ap, long long);
  800450:	8b 10                	mov    (%eax),%edx
  800452:	8d 4a 08             	lea    0x8(%edx),%ecx
  800455:	89 08                	mov    %ecx,(%eax)
  800457:	8b 02                	mov    (%edx),%eax
  800459:	8b 52 04             	mov    0x4(%edx),%edx
  80045c:	eb 1a                	jmp    800478 <getint+0x30>
	else if (lflag)
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 0c                	je     80046e <getint+0x26>
		return va_arg(*ap, long);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 04             	lea    0x4(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	99                   	cltd   
  80046c:	eb 0a                	jmp    800478 <getint+0x30>
	else
		return va_arg(*ap, int);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 04             	lea    0x4(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	99                   	cltd   
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800480:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800483:	8b 10                	mov    (%eax),%edx
  800485:	3b 50 04             	cmp    0x4(%eax),%edx
  800488:	73 08                	jae    800492 <sprintputch+0x18>
		*b->buf++ = ch;
  80048a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048d:	88 0a                	mov    %cl,(%edx)
  80048f:	42                   	inc    %edx
  800490:	89 10                	mov    %edx,(%eax)
}
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80049a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049d:	50                   	push   %eax
  80049e:	ff 75 10             	pushl  0x10(%ebp)
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	ff 75 08             	pushl  0x8(%ebp)
  8004a7:	e8 05 00 00 00       	call   8004b1 <vprintfmt>
	va_end(ap);
  8004ac:	83 c4 10             	add    $0x10,%esp
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	57                   	push   %edi
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	83 ec 2c             	sub    $0x2c,%esp
  8004ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8004c0:	eb 13                	jmp    8004d5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	0f 84 6d 03 00 00    	je     800837 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	57                   	push   %edi
  8004ce:	50                   	push   %eax
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d5:	0f b6 06             	movzbl (%esi),%eax
  8004d8:	46                   	inc    %esi
  8004d9:	83 f8 25             	cmp    $0x25,%eax
  8004dc:	75 e4                	jne    8004c2 <vprintfmt+0x11>
  8004de:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004e9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004f0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004fc:	eb 28                	jmp    800526 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800500:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800504:	eb 20                	jmp    800526 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800508:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80050c:	eb 18                	jmp    800526 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800510:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800517:	eb 0d                	jmp    800526 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8a 06                	mov    (%esi),%al
  800528:	0f b6 d0             	movzbl %al,%edx
  80052b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80052e:	83 e8 23             	sub    $0x23,%eax
  800531:	3c 55                	cmp    $0x55,%al
  800533:	0f 87 e0 02 00 00    	ja     800819 <vprintfmt+0x368>
  800539:	0f b6 c0             	movzbl %al,%eax
  80053c:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800543:	83 ea 30             	sub    $0x30,%edx
  800546:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800549:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80054c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80054f:	83 fa 09             	cmp    $0x9,%edx
  800552:	77 44                	ja     800598 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	89 de                	mov    %ebx,%esi
  800556:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800559:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80055a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80055d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800561:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800564:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800567:	83 fb 09             	cmp    $0x9,%ebx
  80056a:	76 ed                	jbe    800559 <vprintfmt+0xa8>
  80056c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80056f:	eb 29                	jmp    80059a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800581:	eb 17                	jmp    80059a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800587:	78 85                	js     80050e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	89 de                	mov    %ebx,%esi
  80058b:	eb 99                	jmp    800526 <vprintfmt+0x75>
  80058d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80058f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800596:	eb 8e                	jmp    800526 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80059a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059e:	79 86                	jns    800526 <vprintfmt+0x75>
  8005a0:	e9 74 ff ff ff       	jmp    800519 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	89 de                	mov    %ebx,%esi
  8005a8:	e9 79 ff ff ff       	jmp    800526 <vprintfmt+0x75>
  8005ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	57                   	push   %edi
  8005bd:	ff 30                	pushl  (%eax)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c8:	e9 08 ff ff ff       	jmp    8004d5 <vprintfmt+0x24>
  8005cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	79 02                	jns    8005e1 <vprintfmt+0x130>
  8005df:	f7 d8                	neg    %eax
  8005e1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e3:	83 f8 0f             	cmp    $0xf,%eax
  8005e6:	7f 0b                	jg     8005f3 <vprintfmt+0x142>
  8005e8:	8b 04 85 00 27 80 00 	mov    0x802700(,%eax,4),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	75 1a                	jne    80060d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005f3:	52                   	push   %edx
  8005f4:	68 7b 24 80 00       	push   $0x80247b
  8005f9:	57                   	push   %edi
  8005fa:	ff 75 08             	pushl  0x8(%ebp)
  8005fd:	e8 92 fe ff ff       	call   800494 <printfmt>
  800602:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800608:	e9 c8 fe ff ff       	jmp    8004d5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80060d:	50                   	push   %eax
  80060e:	68 d1 29 80 00       	push   $0x8029d1
  800613:	57                   	push   %edi
  800614:	ff 75 08             	pushl  0x8(%ebp)
  800617:	e8 78 fe ff ff       	call   800494 <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800622:	e9 ae fe ff ff       	jmp    8004d5 <vprintfmt+0x24>
  800627:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80062a:	89 de                	mov    %ebx,%esi
  80062c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80062f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800640:	85 c0                	test   %eax,%eax
  800642:	75 07                	jne    80064b <vprintfmt+0x19a>
				p = "(null)";
  800644:	c7 45 d0 74 24 80 00 	movl   $0x802474,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80064b:	85 db                	test   %ebx,%ebx
  80064d:	7e 42                	jle    800691 <vprintfmt+0x1e0>
  80064f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800653:	74 3c                	je     800691 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	51                   	push   %ecx
  800659:	ff 75 d0             	pushl  -0x30(%ebp)
  80065c:	e8 6f 02 00 00       	call   8008d0 <strnlen>
  800661:	29 c3                	sub    %eax,%ebx
  800663:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	85 db                	test   %ebx,%ebx
  80066b:	7e 24                	jle    800691 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80066d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800671:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800674:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	57                   	push   %edi
  80067b:	53                   	push   %ebx
  80067c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067f:	4e                   	dec    %esi
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 f6                	test   %esi,%esi
  800685:	7f f0                	jg     800677 <vprintfmt+0x1c6>
  800687:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80068a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800691:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800694:	0f be 02             	movsbl (%edx),%eax
  800697:	85 c0                	test   %eax,%eax
  800699:	75 47                	jne    8006e2 <vprintfmt+0x231>
  80069b:	eb 37                	jmp    8006d4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80069d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a1:	74 16                	je     8006b9 <vprintfmt+0x208>
  8006a3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006a6:	83 fa 5e             	cmp    $0x5e,%edx
  8006a9:	76 0e                	jbe    8006b9 <vprintfmt+0x208>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	6a 3f                	push   $0x3f
  8006b1:	ff 55 08             	call   *0x8(%ebp)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 0b                	jmp    8006c4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	57                   	push   %edi
  8006bd:	50                   	push   %eax
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c4:	ff 4d e4             	decl   -0x1c(%ebp)
  8006c7:	0f be 03             	movsbl (%ebx),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	74 03                	je     8006d1 <vprintfmt+0x220>
  8006ce:	43                   	inc    %ebx
  8006cf:	eb 1b                	jmp    8006ec <vprintfmt+0x23b>
  8006d1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d8:	7f 1e                	jg     8006f8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006dd:	e9 f3 fd ff ff       	jmp    8004d5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e5:	43                   	inc    %ebx
  8006e6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006ec:	85 f6                	test   %esi,%esi
  8006ee:	78 ad                	js     80069d <vprintfmt+0x1ec>
  8006f0:	4e                   	dec    %esi
  8006f1:	79 aa                	jns    80069d <vprintfmt+0x1ec>
  8006f3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006f6:	eb dc                	jmp    8006d4 <vprintfmt+0x223>
  8006f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	57                   	push   %edi
  8006ff:	6a 20                	push   $0x20
  800701:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800704:	4b                   	dec    %ebx
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 db                	test   %ebx,%ebx
  80070a:	7f ef                	jg     8006fb <vprintfmt+0x24a>
  80070c:	e9 c4 fd ff ff       	jmp    8004d5 <vprintfmt+0x24>
  800711:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800714:	89 ca                	mov    %ecx,%edx
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 2a fd ff ff       	call   800448 <getint>
  80071e:	89 c3                	mov    %eax,%ebx
  800720:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800722:	85 d2                	test   %edx,%edx
  800724:	78 0a                	js     800730 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800726:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072b:	e9 b0 00 00 00       	jmp    8007e0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	57                   	push   %edi
  800734:	6a 2d                	push   $0x2d
  800736:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800739:	f7 db                	neg    %ebx
  80073b:	83 d6 00             	adc    $0x0,%esi
  80073e:	f7 de                	neg    %esi
  800740:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800743:	b8 0a 00 00 00       	mov    $0xa,%eax
  800748:	e9 93 00 00 00       	jmp    8007e0 <vprintfmt+0x32f>
  80074d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800750:	89 ca                	mov    %ecx,%edx
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	e8 b4 fc ff ff       	call   80040e <getuint>
  80075a:	89 c3                	mov    %eax,%ebx
  80075c:	89 d6                	mov    %edx,%esi
			base = 10;
  80075e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800763:	eb 7b                	jmp    8007e0 <vprintfmt+0x32f>
  800765:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800768:	89 ca                	mov    %ecx,%edx
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 d6 fc ff ff       	call   800448 <getint>
  800772:	89 c3                	mov    %eax,%ebx
  800774:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800776:	85 d2                	test   %edx,%edx
  800778:	78 07                	js     800781 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80077a:	b8 08 00 00 00       	mov    $0x8,%eax
  80077f:	eb 5f                	jmp    8007e0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	57                   	push   %edi
  800785:	6a 2d                	push   $0x2d
  800787:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80078a:	f7 db                	neg    %ebx
  80078c:	83 d6 00             	adc    $0x0,%esi
  80078f:	f7 de                	neg    %esi
  800791:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800794:	b8 08 00 00 00       	mov    $0x8,%eax
  800799:	eb 45                	jmp    8007e0 <vprintfmt+0x32f>
  80079b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	57                   	push   %edi
  8007a2:	6a 30                	push   $0x30
  8007a4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	57                   	push   %edi
  8007ab:	6a 78                	push   $0x78
  8007ad:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 04             	lea    0x4(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b9:	8b 18                	mov    (%eax),%ebx
  8007bb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007c8:	eb 16                	jmp    8007e0 <vprintfmt+0x32f>
  8007ca:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cd:	89 ca                	mov    %ecx,%edx
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 37 fc ff ff       	call   80040e <getuint>
  8007d7:	89 c3                	mov    %eax,%ebx
  8007d9:	89 d6                	mov    %edx,%esi
			base = 16;
  8007db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e0:	83 ec 0c             	sub    $0xc,%esp
  8007e3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007e7:	52                   	push   %edx
  8007e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007eb:	50                   	push   %eax
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	89 fa                	mov    %edi,%edx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	e8 68 fb ff ff       	call   800360 <printnum>
			break;
  8007f8:	83 c4 20             	add    $0x20,%esp
  8007fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007fe:	e9 d2 fc ff ff       	jmp    8004d5 <vprintfmt+0x24>
  800803:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	57                   	push   %edi
  80080a:	52                   	push   %edx
  80080b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80080e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800814:	e9 bc fc ff ff       	jmp    8004d5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	57                   	push   %edi
  80081d:	6a 25                	push   $0x25
  80081f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	eb 02                	jmp    800829 <vprintfmt+0x378>
  800827:	89 c6                	mov    %eax,%esi
  800829:	8d 46 ff             	lea    -0x1(%esi),%eax
  80082c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800830:	75 f5                	jne    800827 <vprintfmt+0x376>
  800832:	e9 9e fc ff ff       	jmp    8004d5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800837:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5f                   	pop    %edi
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800852:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085c:	85 c0                	test   %eax,%eax
  80085e:	74 26                	je     800886 <vsnprintf+0x47>
  800860:	85 d2                	test   %edx,%edx
  800862:	7e 29                	jle    80088d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800864:	ff 75 14             	pushl  0x14(%ebp)
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	68 7a 04 80 00       	push   $0x80047a
  800873:	e8 39 fc ff ff       	call   8004b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
  800884:	eb 0c                	jmp    800892 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb 05                	jmp    800892 <vsnprintf+0x53>
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089d:	50                   	push   %eax
  80089e:	ff 75 10             	pushl  0x10(%ebp)
  8008a1:	ff 75 0c             	pushl  0xc(%ebp)
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 93 ff ff ff       	call   80083f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    
	...

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008b9:	74 0e                	je     8008c9 <strlen+0x19>
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c5:	75 f9                	jne    8008c0 <strlen+0x10>
  8008c7:	eb 05                	jmp    8008ce <strlen+0x1e>
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 17                	je     8008f4 <strnlen+0x24>
  8008dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8008e0:	74 19                	je     8008fb <strnlen+0x2b>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 d0                	cmp    %edx,%eax
  8008ea:	74 14                	je     800900 <strnlen+0x30>
  8008ec:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f0:	75 f5                	jne    8008e7 <strnlen+0x17>
  8008f2:	eb 0c                	jmp    800900 <strnlen+0x30>
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb 05                	jmp    800900 <strnlen+0x30>
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090c:	ba 00 00 00 00       	mov    $0x0,%edx
  800911:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800914:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800917:	42                   	inc    %edx
  800918:	84 c9                	test   %cl,%cl
  80091a:	75 f5                	jne    800911 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80091c:	5b                   	pop    %ebx
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800926:	53                   	push   %ebx
  800927:	e8 84 ff ff ff       	call   8008b0 <strlen>
  80092c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800935:	50                   	push   %eax
  800936:	e8 c7 ff ff ff       	call   800902 <strcpy>
	return dst;
}
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800950:	85 f6                	test   %esi,%esi
  800952:	74 15                	je     800969 <strncpy+0x27>
  800954:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800959:	8a 1a                	mov    (%edx),%bl
  80095b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095e:	80 3a 01             	cmpb   $0x1,(%edx)
  800961:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800964:	41                   	inc    %ecx
  800965:	39 ce                	cmp    %ecx,%esi
  800967:	77 f0                	ja     800959 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 7d 08             	mov    0x8(%ebp),%edi
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800979:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	85 f6                	test   %esi,%esi
  80097e:	74 32                	je     8009b2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800980:	83 fe 01             	cmp    $0x1,%esi
  800983:	74 22                	je     8009a7 <strlcpy+0x3a>
  800985:	8a 0b                	mov    (%ebx),%cl
  800987:	84 c9                	test   %cl,%cl
  800989:	74 20                	je     8009ab <strlcpy+0x3e>
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800992:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800995:	88 08                	mov    %cl,(%eax)
  800997:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800998:	39 f2                	cmp    %esi,%edx
  80099a:	74 11                	je     8009ad <strlcpy+0x40>
  80099c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009a0:	42                   	inc    %edx
  8009a1:	84 c9                	test   %cl,%cl
  8009a3:	75 f0                	jne    800995 <strlcpy+0x28>
  8009a5:	eb 06                	jmp    8009ad <strlcpy+0x40>
  8009a7:	89 f8                	mov    %edi,%eax
  8009a9:	eb 02                	jmp    8009ad <strlcpy+0x40>
  8009ab:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ad:	c6 00 00             	movb   $0x0,(%eax)
  8009b0:	eb 02                	jmp    8009b4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009b4:	29 f8                	sub    %edi,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c4:	8a 01                	mov    (%ecx),%al
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 10                	je     8009da <strcmp+0x1f>
  8009ca:	3a 02                	cmp    (%edx),%al
  8009cc:	75 0c                	jne    8009da <strcmp+0x1f>
		p++, q++;
  8009ce:	41                   	inc    %ecx
  8009cf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d0:	8a 01                	mov    (%ecx),%al
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 04                	je     8009da <strcmp+0x1f>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	74 f4                	je     8009ce <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 c0             	movzbl %al,%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	74 1b                	je     800a10 <strncmp+0x2c>
  8009f5:	8a 1a                	mov    (%edx),%bl
  8009f7:	84 db                	test   %bl,%bl
  8009f9:	74 24                	je     800a1f <strncmp+0x3b>
  8009fb:	3a 19                	cmp    (%ecx),%bl
  8009fd:	75 20                	jne    800a1f <strncmp+0x3b>
  8009ff:	48                   	dec    %eax
  800a00:	74 15                	je     800a17 <strncmp+0x33>
		n--, p++, q++;
  800a02:	42                   	inc    %edx
  800a03:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a04:	8a 1a                	mov    (%edx),%bl
  800a06:	84 db                	test   %bl,%bl
  800a08:	74 15                	je     800a1f <strncmp+0x3b>
  800a0a:	3a 19                	cmp    (%ecx),%bl
  800a0c:	74 f1                	je     8009ff <strncmp+0x1b>
  800a0e:	eb 0f                	jmp    800a1f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	eb 05                	jmp    800a1c <strncmp+0x38>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 11             	movzbl (%ecx),%edx
  800a25:	29 d0                	sub    %edx,%eax
  800a27:	eb f3                	jmp    800a1c <strncmp+0x38>

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a32:	8a 10                	mov    (%eax),%dl
  800a34:	84 d2                	test   %dl,%dl
  800a36:	74 18                	je     800a50 <strchr+0x27>
		if (*s == c)
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	75 06                	jne    800a42 <strchr+0x19>
  800a3c:	eb 17                	jmp    800a55 <strchr+0x2c>
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 13                	je     800a55 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	40                   	inc    %eax
  800a43:	8a 10                	mov    (%eax),%dl
  800a45:	84 d2                	test   %dl,%dl
  800a47:	75 f5                	jne    800a3e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4e:	eb 05                	jmp    800a55 <strchr+0x2c>
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a60:	8a 10                	mov    (%eax),%dl
  800a62:	84 d2                	test   %dl,%dl
  800a64:	74 11                	je     800a77 <strfind+0x20>
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	75 06                	jne    800a70 <strfind+0x19>
  800a6a:	eb 0b                	jmp    800a77 <strfind+0x20>
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	74 07                	je     800a77 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a70:	40                   	inc    %eax
  800a71:	8a 10                	mov    (%eax),%dl
  800a73:	84 d2                	test   %dl,%dl
  800a75:	75 f5                	jne    800a6c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a88:	85 c9                	test   %ecx,%ecx
  800a8a:	74 30                	je     800abc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a92:	75 25                	jne    800ab9 <memset+0x40>
  800a94:	f6 c1 03             	test   $0x3,%cl
  800a97:	75 20                	jne    800ab9 <memset+0x40>
		c &= 0xFF;
  800a99:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	c1 e3 08             	shl    $0x8,%ebx
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	c1 e6 18             	shl    $0x18,%esi
  800aa6:	89 d0                	mov    %edx,%eax
  800aa8:	c1 e0 10             	shl    $0x10,%eax
  800aab:	09 f0                	or     %esi,%eax
  800aad:	09 d0                	or     %edx,%eax
  800aaf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab4:	fc                   	cld    
  800ab5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab7:	eb 03                	jmp    800abc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab9:	fc                   	cld    
  800aba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abc:	89 f8                	mov    %edi,%eax
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad1:	39 c6                	cmp    %eax,%esi
  800ad3:	73 34                	jae    800b09 <memmove+0x46>
  800ad5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad8:	39 d0                	cmp    %edx,%eax
  800ada:	73 2d                	jae    800b09 <memmove+0x46>
		s += n;
		d += n;
  800adc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	f6 c2 03             	test   $0x3,%dl
  800ae2:	75 1b                	jne    800aff <memmove+0x3c>
  800ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aea:	75 13                	jne    800aff <memmove+0x3c>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0e                	jne    800aff <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af1:	83 ef 04             	sub    $0x4,%edi
  800af4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800afa:	fd                   	std    
  800afb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afd:	eb 07                	jmp    800b06 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aff:	4f                   	dec    %edi
  800b00:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b03:	fd                   	std    
  800b04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b06:	fc                   	cld    
  800b07:	eb 20                	jmp    800b29 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b09:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0f:	75 13                	jne    800b24 <memmove+0x61>
  800b11:	a8 03                	test   $0x3,%al
  800b13:	75 0f                	jne    800b24 <memmove+0x61>
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 0a                	jne    800b24 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	fc                   	cld    
  800b20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b22:	eb 05                	jmp    800b29 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	fc                   	cld    
  800b27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b30:	ff 75 10             	pushl  0x10(%ebp)
  800b33:	ff 75 0c             	pushl  0xc(%ebp)
  800b36:	ff 75 08             	pushl  0x8(%ebp)
  800b39:	e8 85 ff ff ff       	call   800ac3 <memmove>
}
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4f:	85 ff                	test   %edi,%edi
  800b51:	74 32                	je     800b85 <memcmp+0x45>
		if (*s1 != *s2)
  800b53:	8a 03                	mov    (%ebx),%al
  800b55:	8a 0e                	mov    (%esi),%cl
  800b57:	38 c8                	cmp    %cl,%al
  800b59:	74 19                	je     800b74 <memcmp+0x34>
  800b5b:	eb 0d                	jmp    800b6a <memcmp+0x2a>
  800b5d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b61:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b65:	42                   	inc    %edx
  800b66:	38 c8                	cmp    %cl,%al
  800b68:	74 10                	je     800b7a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b6a:	0f b6 c0             	movzbl %al,%eax
  800b6d:	0f b6 c9             	movzbl %cl,%ecx
  800b70:	29 c8                	sub    %ecx,%eax
  800b72:	eb 16                	jmp    800b8a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b74:	4f                   	dec    %edi
  800b75:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7a:	39 fa                	cmp    %edi,%edx
  800b7c:	75 df                	jne    800b5d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	eb 05                	jmp    800b8a <memcmp+0x4a>
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 12                	jae    800bb0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ba1:	38 08                	cmp    %cl,(%eax)
  800ba3:	75 06                	jne    800bab <memfind+0x1c>
  800ba5:	eb 09                	jmp    800bb0 <memfind+0x21>
  800ba7:	38 08                	cmp    %cl,(%eax)
  800ba9:	74 05                	je     800bb0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bab:	40                   	inc    %eax
  800bac:	39 c2                	cmp    %eax,%edx
  800bae:	77 f7                	ja     800ba7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbe:	eb 01                	jmp    800bc1 <strtol+0xf>
		s++;
  800bc0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc1:	8a 02                	mov    (%edx),%al
  800bc3:	3c 20                	cmp    $0x20,%al
  800bc5:	74 f9                	je     800bc0 <strtol+0xe>
  800bc7:	3c 09                	cmp    $0x9,%al
  800bc9:	74 f5                	je     800bc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcb:	3c 2b                	cmp    $0x2b,%al
  800bcd:	75 08                	jne    800bd7 <strtol+0x25>
		s++;
  800bcf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd5:	eb 13                	jmp    800bea <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd7:	3c 2d                	cmp    $0x2d,%al
  800bd9:	75 0a                	jne    800be5 <strtol+0x33>
		s++, neg = 1;
  800bdb:	8d 52 01             	lea    0x1(%edx),%edx
  800bde:	bf 01 00 00 00       	mov    $0x1,%edi
  800be3:	eb 05                	jmp    800bea <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	74 05                	je     800bf3 <strtol+0x41>
  800bee:	83 fb 10             	cmp    $0x10,%ebx
  800bf1:	75 28                	jne    800c1b <strtol+0x69>
  800bf3:	8a 02                	mov    (%edx),%al
  800bf5:	3c 30                	cmp    $0x30,%al
  800bf7:	75 10                	jne    800c09 <strtol+0x57>
  800bf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfd:	75 0a                	jne    800c09 <strtol+0x57>
		s += 2, base = 16;
  800bff:	83 c2 02             	add    $0x2,%edx
  800c02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c07:	eb 12                	jmp    800c1b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c09:	85 db                	test   %ebx,%ebx
  800c0b:	75 0e                	jne    800c1b <strtol+0x69>
  800c0d:	3c 30                	cmp    $0x30,%al
  800c0f:	75 05                	jne    800c16 <strtol+0x64>
		s++, base = 8;
  800c11:	42                   	inc    %edx
  800c12:	b3 08                	mov    $0x8,%bl
  800c14:	eb 05                	jmp    800c1b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c16:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c22:	8a 0a                	mov    (%edx),%cl
  800c24:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c27:	80 fb 09             	cmp    $0x9,%bl
  800c2a:	77 08                	ja     800c34 <strtol+0x82>
			dig = *s - '0';
  800c2c:	0f be c9             	movsbl %cl,%ecx
  800c2f:	83 e9 30             	sub    $0x30,%ecx
  800c32:	eb 1e                	jmp    800c52 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c34:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c37:	80 fb 19             	cmp    $0x19,%bl
  800c3a:	77 08                	ja     800c44 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c3c:	0f be c9             	movsbl %cl,%ecx
  800c3f:	83 e9 57             	sub    $0x57,%ecx
  800c42:	eb 0e                	jmp    800c52 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c44:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c47:	80 fb 19             	cmp    $0x19,%bl
  800c4a:	77 13                	ja     800c5f <strtol+0xad>
			dig = *s - 'A' + 10;
  800c4c:	0f be c9             	movsbl %cl,%ecx
  800c4f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c52:	39 f1                	cmp    %esi,%ecx
  800c54:	7d 0d                	jge    800c63 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c56:	42                   	inc    %edx
  800c57:	0f af c6             	imul   %esi,%eax
  800c5a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c5d:	eb c3                	jmp    800c22 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c5f:	89 c1                	mov    %eax,%ecx
  800c61:	eb 02                	jmp    800c65 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c63:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c69:	74 05                	je     800c70 <strtol+0xbe>
		*endptr = (char *) s;
  800c6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c70:	85 ff                	test   %edi,%edi
  800c72:	74 04                	je     800c78 <strtol+0xc6>
  800c74:	89 c8                	mov    %ecx,%eax
  800c76:	f7 d8                	neg    %eax
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    
  800c7d:	00 00                	add    %al,(%eax)
	...

00800c80 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 1c             	sub    $0x1c,%esp
  800c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c8f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	8b 75 14             	mov    0x14(%ebp),%esi
  800c94:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9d:	cd 30                	int    $0x30
  800c9f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ca5:	74 1c                	je     800cc3 <syscall+0x43>
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 18                	jle    800cc3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cb2:	68 5f 27 80 00       	push   $0x80275f
  800cb7:	6a 42                	push   $0x42
  800cb9:	68 7c 27 80 00       	push   $0x80277c
  800cbe:	e8 b1 f5 ff ff       	call   800274 <_panic>

	return ret;
}
  800cc3:	89 d0                	mov    %edx,%eax
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce9:	e8 92 ff ff ff       	call   800c80 <syscall>
  800cee:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d10:	e8 6b ff ff ff       	call   800c80 <syscall>
}
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d1d:	6a 00                	push   $0x0
  800d1f:	6a 00                	push   $0x0
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800d32:	e8 49 ff ff ff       	call   800c80 <syscall>
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d3f:	6a 00                	push   $0x0
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	b8 02 00 00 00       	mov    $0x2,%eax
  800d56:	e8 25 ff ff ff       	call   800c80 <syscall>
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <sys_yield>:

void
sys_yield(void)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d63:	6a 00                	push   $0x0
  800d65:	6a 00                	push   $0x0
  800d67:	6a 00                	push   $0x0
  800d69:	6a 00                	push   $0x0
  800d6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7a:	e8 01 ff ff ff       	call   800c80 <syscall>
  800d7f:	83 c4 10             	add    $0x10,%esp
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d8a:	6a 00                	push   $0x0
  800d8c:	6a 00                	push   $0x0
  800d8e:	ff 75 10             	pushl  0x10(%ebp)
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d97:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800da1:	e8 da fe ff ff       	call   800c80 <syscall>
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800dae:	ff 75 18             	pushl  0x18(%ebp)
  800db1:	ff 75 14             	pushl  0x14(%ebp)
  800db4:	ff 75 10             	pushl  0x10(%ebp)
  800db7:	ff 75 0c             	pushl  0xc(%ebp)
  800dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbd:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc7:	e8 b4 fe ff ff       	call   800c80 <syscall>
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800dd4:	6a 00                	push   $0x0
  800dd6:	6a 00                	push   $0x0
  800dd8:	6a 00                	push   $0x0
  800dda:	ff 75 0c             	pushl  0xc(%ebp)
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	ba 01 00 00 00       	mov    $0x1,%edx
  800de5:	b8 06 00 00 00       	mov    $0x6,%eax
  800dea:	e8 91 fe ff ff       	call   800c80 <syscall>
}
  800def:	c9                   	leave  
  800df0:	c3                   	ret    

00800df1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800df7:	6a 00                	push   $0x0
  800df9:	6a 00                	push   $0x0
  800dfb:	6a 00                	push   $0x0
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	ba 01 00 00 00       	mov    $0x1,%edx
  800e08:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0d:	e8 6e fe ff ff       	call   800c80 <syscall>
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e1a:	6a 00                	push   $0x0
  800e1c:	6a 00                	push   $0x0
  800e1e:	6a 00                	push   $0x0
  800e20:	ff 75 0c             	pushl  0xc(%ebp)
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	ba 01 00 00 00       	mov    $0x1,%edx
  800e2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800e30:	e8 4b fe ff ff       	call   800c80 <syscall>
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e3d:	6a 00                	push   $0x0
  800e3f:	6a 00                	push   $0x0
  800e41:	6a 00                	push   $0x0
  800e43:	ff 75 0c             	pushl  0xc(%ebp)
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e53:	e8 28 fe ff ff       	call   800c80 <syscall>
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e60:	6a 00                	push   $0x0
  800e62:	ff 75 14             	pushl  0x14(%ebp)
  800e65:	ff 75 10             	pushl  0x10(%ebp)
  800e68:	ff 75 0c             	pushl  0xc(%ebp)
  800e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e78:	e8 03 fe ff ff       	call   800c80 <syscall>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e85:	6a 00                	push   $0x0
  800e87:	6a 00                	push   $0x0
  800e89:	6a 00                	push   $0x0
  800e8b:	6a 00                	push   $0x0
  800e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e90:	ba 01 00 00 00       	mov    $0x1,%edx
  800e95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9a:	e8 e1 fd ff ff       	call   800c80 <syscall>
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ea7:	6a 00                	push   $0x0
  800ea9:	6a 00                	push   $0x0
  800eab:	6a 00                	push   $0x0
  800ead:	ff 75 0c             	pushl  0xc(%ebp)
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ebd:	e8 be fd ff ff       	call   800c80 <syscall>
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800eca:	6a 00                	push   $0x0
  800ecc:	ff 75 14             	pushl  0x14(%ebp)
  800ecf:	ff 75 10             	pushl  0x10(%ebp)
  800ed2:	ff 75 0c             	pushl  0xc(%ebp)
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	ba 00 00 00 00       	mov    $0x0,%edx
  800edd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ee2:	e8 99 fd ff ff       	call   800c80 <syscall>
} 
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800eef:	6a 00                	push   $0x0
  800ef1:	6a 00                	push   $0x0
  800ef3:	6a 00                	push   $0x0
  800ef5:	6a 00                	push   $0x0
  800ef7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 11 00 00 00       	mov    $0x11,%eax
  800f04:	e8 77 fd ff ff       	call   800c80 <syscall>
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800f11:	6a 00                	push   $0x0
  800f13:	6a 00                	push   $0x0
  800f15:	6a 00                	push   $0x0
  800f17:	6a 00                	push   $0x0
  800f19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 10 00 00 00       	mov    $0x10,%eax
  800f28:	e8 53 fd ff ff       	call   800c80 <syscall>
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    
	...

00800f30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	53                   	push   %ebx
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800f3c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f40:	75 14                	jne    800f56 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 8c 27 80 00       	push   $0x80278c
  800f4a:	6a 20                	push   $0x20
  800f4c:	68 d0 28 80 00       	push   $0x8028d0
  800f51:	e8 1e f3 ff ff       	call   800274 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f56:	89 d8                	mov    %ebx,%eax
  800f58:	c1 e8 16             	shr    $0x16,%eax
  800f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f62:	a8 01                	test   $0x1,%al
  800f64:	74 11                	je     800f77 <pgfault+0x47>
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
  800f6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f72:	f6 c4 08             	test   $0x8,%ah
  800f75:	75 14                	jne    800f8b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	68 b0 27 80 00       	push   $0x8027b0
  800f7f:	6a 24                	push   $0x24
  800f81:	68 d0 28 80 00       	push   $0x8028d0
  800f86:	e8 e9 f2 ff ff       	call   800274 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	6a 07                	push   $0x7
  800f90:	68 00 f0 7f 00       	push   $0x7ff000
  800f95:	6a 00                	push   $0x0
  800f97:	e8 e8 fd ff ff       	call   800d84 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 12                	jns    800fb5 <pgfault+0x85>
  800fa3:	50                   	push   %eax
  800fa4:	68 d4 27 80 00       	push   $0x8027d4
  800fa9:	6a 32                	push   $0x32
  800fab:	68 d0 28 80 00       	push   $0x8028d0
  800fb0:	e8 bf f2 ff ff       	call   800274 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800fb5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 00 10 00 00       	push   $0x1000
  800fc3:	53                   	push   %ebx
  800fc4:	68 00 f0 7f 00       	push   $0x7ff000
  800fc9:	e8 5f fb ff ff       	call   800b2d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800fce:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fd5:	53                   	push   %ebx
  800fd6:	6a 00                	push   $0x0
  800fd8:	68 00 f0 7f 00       	push   $0x7ff000
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 c4 fd ff ff       	call   800da8 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800fe4:	83 c4 20             	add    $0x20,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 12                	jns    800ffd <pgfault+0xcd>
  800feb:	50                   	push   %eax
  800fec:	68 f8 27 80 00       	push   $0x8027f8
  800ff1:	6a 3a                	push   $0x3a
  800ff3:	68 d0 28 80 00       	push   $0x8028d0
  800ff8:	e8 77 f2 ff ff       	call   800274 <_panic>

	return;
}
  800ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	57                   	push   %edi
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80100b:	68 30 0f 80 00       	push   $0x800f30
  801010:	e8 43 10 00 00       	call   802058 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801015:	ba 07 00 00 00       	mov    $0x7,%edx
  80101a:	89 d0                	mov    %edx,%eax
  80101c:	cd 30                	int    $0x30
  80101e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801021:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 12                	jns    80103c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  80102a:	50                   	push   %eax
  80102b:	68 db 28 80 00       	push   $0x8028db
  801030:	6a 7f                	push   $0x7f
  801032:	68 d0 28 80 00       	push   $0x8028d0
  801037:	e8 38 f2 ff ff       	call   800274 <_panic>
	}
	int r;

	if (childpid == 0) {
  80103c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801040:	75 20                	jne    801062 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  801042:	e8 f2 fc ff ff       	call   800d39 <sys_getenvid>
  801047:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	c1 e2 07             	shl    $0x7,%edx
  801051:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801058:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  80105d:	e9 be 01 00 00       	jmp    801220 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801062:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  801067:	89 d8                	mov    %ebx,%eax
  801069:	c1 e8 16             	shr    $0x16,%eax
  80106c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801073:	a8 01                	test   $0x1,%al
  801075:	0f 84 10 01 00 00    	je     80118b <fork+0x189>
  80107b:	89 d8                	mov    %ebx,%eax
  80107d:	c1 e8 0c             	shr    $0xc,%eax
  801080:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801087:	f6 c2 01             	test   $0x1,%dl
  80108a:	0f 84 fb 00 00 00    	je     80118b <fork+0x189>
  801090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801097:	f6 c2 04             	test   $0x4,%dl
  80109a:	0f 84 eb 00 00 00    	je     80118b <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8010a0:	89 c6                	mov    %eax,%esi
  8010a2:	c1 e6 0c             	shl    $0xc,%esi
  8010a5:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8010ab:	0f 84 da 00 00 00    	je     80118b <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  8010b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b8:	f6 c6 04             	test   $0x4,%dh
  8010bb:	74 37                	je     8010f4 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cc:	50                   	push   %eax
  8010cd:	56                   	push   %esi
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 d1 fc ff ff       	call   800da8 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	0f 89 a9 00 00 00    	jns    80118b <fork+0x189>
  8010e2:	50                   	push   %eax
  8010e3:	68 1c 28 80 00       	push   $0x80281c
  8010e8:	6a 54                	push   $0x54
  8010ea:	68 d0 28 80 00       	push   $0x8028d0
  8010ef:	e8 80 f1 ff ff       	call   800274 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fb:	f6 c2 02             	test   $0x2,%dl
  8010fe:	75 0c                	jne    80110c <fork+0x10a>
  801100:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801107:	f6 c4 08             	test   $0x8,%ah
  80110a:	74 57                	je     801163 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	68 05 08 00 00       	push   $0x805
  801114:	56                   	push   %esi
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	6a 00                	push   $0x0
  801119:	e8 8a fc ff ff       	call   800da8 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80111e:	83 c4 20             	add    $0x20,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 12                	jns    801137 <fork+0x135>
  801125:	50                   	push   %eax
  801126:	68 1c 28 80 00       	push   $0x80281c
  80112b:	6a 59                	push   $0x59
  80112d:	68 d0 28 80 00       	push   $0x8028d0
  801132:	e8 3d f1 ff ff       	call   800274 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	68 05 08 00 00       	push   $0x805
  80113f:	56                   	push   %esi
  801140:	6a 00                	push   $0x0
  801142:	56                   	push   %esi
  801143:	6a 00                	push   $0x0
  801145:	e8 5e fc ff ff       	call   800da8 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 3a                	jns    80118b <fork+0x189>
  801151:	50                   	push   %eax
  801152:	68 1c 28 80 00       	push   $0x80281c
  801157:	6a 5c                	push   $0x5c
  801159:	68 d0 28 80 00       	push   $0x8028d0
  80115e:	e8 11 f1 ff ff       	call   800274 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	6a 05                	push   $0x5
  801168:	56                   	push   %esi
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	6a 00                	push   $0x0
  80116d:	e8 36 fc ff ff       	call   800da8 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801172:	83 c4 20             	add    $0x20,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	79 12                	jns    80118b <fork+0x189>
  801179:	50                   	push   %eax
  80117a:	68 1c 28 80 00       	push   $0x80281c
  80117f:	6a 60                	push   $0x60
  801181:	68 d0 28 80 00       	push   $0x8028d0
  801186:	e8 e9 f0 ff ff       	call   800274 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80118b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801191:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801197:	0f 85 ca fe ff ff    	jne    801067 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	6a 07                	push   $0x7
  8011a2:	68 00 f0 bf ee       	push   $0xeebff000
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	e8 d5 fb ff ff       	call   800d84 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 15                	jns    8011cb <fork+0x1c9>
  8011b6:	50                   	push   %eax
  8011b7:	68 40 28 80 00       	push   $0x802840
  8011bc:	68 94 00 00 00       	push   $0x94
  8011c1:	68 d0 28 80 00       	push   $0x8028d0
  8011c6:	e8 a9 f0 ff ff       	call   800274 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	68 c4 20 80 00       	push   $0x8020c4
  8011d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d6:	e8 5c fc ff ff       	call   800e37 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	79 15                	jns    8011f7 <fork+0x1f5>
  8011e2:	50                   	push   %eax
  8011e3:	68 78 28 80 00       	push   $0x802878
  8011e8:	68 99 00 00 00       	push   $0x99
  8011ed:	68 d0 28 80 00       	push   $0x8028d0
  8011f2:	e8 7d f0 ff ff       	call   800274 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	6a 02                	push   $0x2
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	e8 ed fb ff ff       	call   800df1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	79 15                	jns    801220 <fork+0x21e>
  80120b:	50                   	push   %eax
  80120c:	68 9c 28 80 00       	push   $0x80289c
  801211:	68 a4 00 00 00       	push   $0xa4
  801216:	68 d0 28 80 00       	push   $0x8028d0
  80121b:	e8 54 f0 ff ff       	call   800274 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <sfork>:

// Challenge!
int
sfork(void)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801231:	68 f8 28 80 00       	push   $0x8028f8
  801236:	68 b1 00 00 00       	push   $0xb1
  80123b:	68 d0 28 80 00       	push   $0x8028d0
  801240:	e8 2f f0 ff ff       	call   800274 <_panic>
  801245:	00 00                	add    %al,(%eax)
	...

00801248 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	8b 75 08             	mov    0x8(%ebp),%esi
  801250:	8b 45 0c             	mov    0xc(%ebp),%eax
  801253:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801256:	85 c0                	test   %eax,%eax
  801258:	74 0e                	je     801268 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	50                   	push   %eax
  80125e:	e8 1c fc ff ff       	call   800e7f <sys_ipc_recv>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 10                	jmp    801278 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	68 00 00 c0 ee       	push   $0xeec00000
  801270:	e8 0a fc ff ff       	call   800e7f <sys_ipc_recv>
  801275:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801278:	85 c0                	test   %eax,%eax
  80127a:	75 26                	jne    8012a2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80127c:	85 f6                	test   %esi,%esi
  80127e:	74 0a                	je     80128a <ipc_recv+0x42>
  801280:	a1 04 40 80 00       	mov    0x804004,%eax
  801285:	8b 40 74             	mov    0x74(%eax),%eax
  801288:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80128a:	85 db                	test   %ebx,%ebx
  80128c:	74 0a                	je     801298 <ipc_recv+0x50>
  80128e:	a1 04 40 80 00       	mov    0x804004,%eax
  801293:	8b 40 78             	mov    0x78(%eax),%eax
  801296:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801298:	a1 04 40 80 00       	mov    0x804004,%eax
  80129d:	8b 40 70             	mov    0x70(%eax),%eax
  8012a0:	eb 14                	jmp    8012b6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8012a2:	85 f6                	test   %esi,%esi
  8012a4:	74 06                	je     8012ac <ipc_recv+0x64>
  8012a6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8012ac:	85 db                	test   %ebx,%ebx
  8012ae:	74 06                	je     8012b6 <ipc_recv+0x6e>
  8012b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8012b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012cc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8012cf:	85 db                	test   %ebx,%ebx
  8012d1:	75 25                	jne    8012f8 <ipc_send+0x3b>
  8012d3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8012d8:	eb 1e                	jmp    8012f8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8012da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012dd:	75 07                	jne    8012e6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8012df:	e8 79 fa ff ff       	call   800d5d <sys_yield>
  8012e4:	eb 12                	jmp    8012f8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8012e6:	50                   	push   %eax
  8012e7:	68 0e 29 80 00       	push   $0x80290e
  8012ec:	6a 43                	push   $0x43
  8012ee:	68 21 29 80 00       	push   $0x802921
  8012f3:	e8 7c ef ff ff       	call   800274 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8012f8:	56                   	push   %esi
  8012f9:	53                   	push   %ebx
  8012fa:	57                   	push   %edi
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	e8 57 fb ff ff       	call   800e5a <sys_ipc_try_send>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	75 d0                	jne    8012da <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80130a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801318:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80131e:	74 1a                	je     80133a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801320:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 e2 07             	shl    $0x7,%edx
  80132a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801331:	8b 52 50             	mov    0x50(%edx),%edx
  801334:	39 ca                	cmp    %ecx,%edx
  801336:	75 18                	jne    801350 <ipc_find_env+0x3e>
  801338:	eb 05                	jmp    80133f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80133f:	89 c2                	mov    %eax,%edx
  801341:	c1 e2 07             	shl    $0x7,%edx
  801344:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  80134b:	8b 40 40             	mov    0x40(%eax),%eax
  80134e:	eb 0c                	jmp    80135c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801350:	40                   	inc    %eax
  801351:	3d 00 04 00 00       	cmp    $0x400,%eax
  801356:	75 cd                	jne    801325 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801358:	66 b8 00 00          	mov    $0x0,%ax
}
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    
	...

00801360 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	05 00 00 00 30       	add    $0x30000000,%eax
  80136b:	c1 e8 0c             	shr    $0xc,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 e5 ff ff ff       	call   801360 <fd2num>
  80137b:	83 c4 04             	add    $0x4,%esp
  80137e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801383:	c1 e0 0c             	shl    $0xc,%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80138f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801394:	a8 01                	test   $0x1,%al
  801396:	74 34                	je     8013cc <fd_alloc+0x44>
  801398:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80139d:	a8 01                	test   $0x1,%al
  80139f:	74 32                	je     8013d3 <fd_alloc+0x4b>
  8013a1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8013a6:	89 c1                	mov    %eax,%ecx
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	c1 ea 16             	shr    $0x16,%edx
  8013ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b4:	f6 c2 01             	test   $0x1,%dl
  8013b7:	74 1f                	je     8013d8 <fd_alloc+0x50>
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	c1 ea 0c             	shr    $0xc,%edx
  8013be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c5:	f6 c2 01             	test   $0x1,%dl
  8013c8:	75 17                	jne    8013e1 <fd_alloc+0x59>
  8013ca:	eb 0c                	jmp    8013d8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013cc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8013d1:	eb 05                	jmp    8013d8 <fd_alloc+0x50>
  8013d3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8013d8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013da:	b8 00 00 00 00       	mov    $0x0,%eax
  8013df:	eb 17                	jmp    8013f8 <fd_alloc+0x70>
  8013e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013eb:	75 b9                	jne    8013a6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f8:	5b                   	pop    %ebx
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801401:	83 f8 1f             	cmp    $0x1f,%eax
  801404:	77 36                	ja     80143c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801406:	05 00 00 0d 00       	add    $0xd0000,%eax
  80140b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80140e:	89 c2                	mov    %eax,%edx
  801410:	c1 ea 16             	shr    $0x16,%edx
  801413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141a:	f6 c2 01             	test   $0x1,%dl
  80141d:	74 24                	je     801443 <fd_lookup+0x48>
  80141f:	89 c2                	mov    %eax,%edx
  801421:	c1 ea 0c             	shr    $0xc,%edx
  801424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142b:	f6 c2 01             	test   $0x1,%dl
  80142e:	74 1a                	je     80144a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801430:	8b 55 0c             	mov    0xc(%ebp),%edx
  801433:	89 02                	mov    %eax,(%edx)
	return 0;
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	eb 13                	jmp    80144f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80143c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801441:	eb 0c                	jmp    80144f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801448:	eb 05                	jmp    80144f <fd_lookup+0x54>
  80144a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80145e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801464:	74 0d                	je     801473 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 14                	jmp    801481 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80146d:	39 0a                	cmp    %ecx,(%edx)
  80146f:	75 10                	jne    801481 <dev_lookup+0x30>
  801471:	eb 05                	jmp    801478 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801473:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801478:	89 13                	mov    %edx,(%ebx)
			return 0;
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
  80147f:	eb 31                	jmp    8014b2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	40                   	inc    %eax
  801482:	8b 14 85 a8 29 80 00 	mov    0x8029a8(,%eax,4),%edx
  801489:	85 d2                	test   %edx,%edx
  80148b:	75 e0                	jne    80146d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80148d:	a1 04 40 80 00       	mov    0x804004,%eax
  801492:	8b 40 48             	mov    0x48(%eax),%eax
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	51                   	push   %ecx
  801499:	50                   	push   %eax
  80149a:	68 2c 29 80 00       	push   $0x80292c
  80149f:	e8 a8 ee ff ff       	call   80034c <cprintf>
	*dev = 0;
  8014a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 20             	sub    $0x20,%esp
  8014bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c2:	8a 45 0c             	mov    0xc(%ebp),%al
  8014c5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c8:	56                   	push   %esi
  8014c9:	e8 92 fe ff ff       	call   801360 <fd2num>
  8014ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014d1:	89 14 24             	mov    %edx,(%esp)
  8014d4:	50                   	push   %eax
  8014d5:	e8 21 ff ff ff       	call   8013fb <fd_lookup>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 05                	js     8014e8 <fd_close+0x31>
	    || fd != fd2)
  8014e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014e6:	74 0d                	je     8014f5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8014e8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014ec:	75 48                	jne    801536 <fd_close+0x7f>
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f3:	eb 41                	jmp    801536 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	ff 36                	pushl  (%esi)
  8014fe:	e8 4e ff ff ff       	call   801451 <dev_lookup>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 1c                	js     801528 <fd_close+0x71>
		if (dev->dev_close)
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	8b 40 10             	mov    0x10(%eax),%eax
  801512:	85 c0                	test   %eax,%eax
  801514:	74 0d                	je     801523 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	56                   	push   %esi
  80151a:	ff d0                	call   *%eax
  80151c:	89 c3                	mov    %eax,%ebx
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	eb 05                	jmp    801528 <fd_close+0x71>
		else
			r = 0;
  801523:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	56                   	push   %esi
  80152c:	6a 00                	push   $0x0
  80152e:	e8 9b f8 ff ff       	call   800dce <sys_page_unmap>
	return r;
  801533:	83 c4 10             	add    $0x10,%esp
}
  801536:	89 d8                	mov    %ebx,%eax
  801538:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153b:	5b                   	pop    %ebx
  80153c:	5e                   	pop    %esi
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 75 08             	pushl  0x8(%ebp)
  80154c:	e8 aa fe ff ff       	call   8013fb <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 10                	js     801568 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	6a 01                	push   $0x1
  80155d:	ff 75 f4             	pushl  -0xc(%ebp)
  801560:	e8 52 ff ff ff       	call   8014b7 <fd_close>
  801565:	83 c4 10             	add    $0x10,%esp
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <close_all>:

void
close_all(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801571:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	53                   	push   %ebx
  80157a:	e8 c0 ff ff ff       	call   80153f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80157f:	43                   	inc    %ebx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	83 fb 20             	cmp    $0x20,%ebx
  801586:	75 ee                	jne    801576 <close_all+0xc>
		close(i);
}
  801588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	57                   	push   %edi
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 2c             	sub    $0x2c,%esp
  801596:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801599:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 56 fe ff ff       	call   8013fb <fd_lookup>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	0f 88 c0 00 00 00    	js     801672 <dup+0xe5>
		return r;
	close(newfdnum);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	57                   	push   %edi
  8015b6:	e8 84 ff ff ff       	call   80153f <close>

	newfd = INDEX2FD(newfdnum);
  8015bb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015c1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015c4:	83 c4 04             	add    $0x4,%esp
  8015c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ca:	e8 a1 fd ff ff       	call   801370 <fd2data>
  8015cf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015d1:	89 34 24             	mov    %esi,(%esp)
  8015d4:	e8 97 fd ff ff       	call   801370 <fd2data>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015df:	89 d8                	mov    %ebx,%eax
  8015e1:	c1 e8 16             	shr    $0x16,%eax
  8015e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015eb:	a8 01                	test   $0x1,%al
  8015ed:	74 37                	je     801626 <dup+0x99>
  8015ef:	89 d8                	mov    %ebx,%eax
  8015f1:	c1 e8 0c             	shr    $0xc,%eax
  8015f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015fb:	f6 c2 01             	test   $0x1,%dl
  8015fe:	74 26                	je     801626 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801600:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	25 07 0e 00 00       	and    $0xe07,%eax
  80160f:	50                   	push   %eax
  801610:	ff 75 d4             	pushl  -0x2c(%ebp)
  801613:	6a 00                	push   $0x0
  801615:	53                   	push   %ebx
  801616:	6a 00                	push   $0x0
  801618:	e8 8b f7 ff ff       	call   800da8 <sys_page_map>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	83 c4 20             	add    $0x20,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 2d                	js     801653 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801629:	89 c2                	mov    %eax,%edx
  80162b:	c1 ea 0c             	shr    $0xc,%edx
  80162e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80163e:	52                   	push   %edx
  80163f:	56                   	push   %esi
  801640:	6a 00                	push   $0x0
  801642:	50                   	push   %eax
  801643:	6a 00                	push   $0x0
  801645:	e8 5e f7 ff ff       	call   800da8 <sys_page_map>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 20             	add    $0x20,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	79 1d                	jns    801670 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	56                   	push   %esi
  801657:	6a 00                	push   $0x0
  801659:	e8 70 f7 ff ff       	call   800dce <sys_page_unmap>
	sys_page_unmap(0, nva);
  80165e:	83 c4 08             	add    $0x8,%esp
  801661:	ff 75 d4             	pushl  -0x2c(%ebp)
  801664:	6a 00                	push   $0x0
  801666:	e8 63 f7 ff ff       	call   800dce <sys_page_unmap>
	return r;
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	eb 02                	jmp    801672 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801670:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801672:	89 d8                	mov    %ebx,%eax
  801674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 14             	sub    $0x14,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	53                   	push   %ebx
  80168b:	e8 6b fd ff ff       	call   8013fb <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 67                	js     8016fe <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a1:	ff 30                	pushl  (%eax)
  8016a3:	e8 a9 fd ff ff       	call   801451 <dev_lookup>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 4f                	js     8016fe <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	8b 50 08             	mov    0x8(%eax),%edx
  8016b5:	83 e2 03             	and    $0x3,%edx
  8016b8:	83 fa 01             	cmp    $0x1,%edx
  8016bb:	75 21                	jne    8016de <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c2:	8b 40 48             	mov    0x48(%eax),%eax
  8016c5:	83 ec 04             	sub    $0x4,%esp
  8016c8:	53                   	push   %ebx
  8016c9:	50                   	push   %eax
  8016ca:	68 6d 29 80 00       	push   $0x80296d
  8016cf:	e8 78 ec ff ff       	call   80034c <cprintf>
		return -E_INVAL;
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016dc:	eb 20                	jmp    8016fe <read+0x82>
	}
	if (!dev->dev_read)
  8016de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e1:	8b 52 08             	mov    0x8(%edx),%edx
  8016e4:	85 d2                	test   %edx,%edx
  8016e6:	74 11                	je     8016f9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016e8:	83 ec 04             	sub    $0x4,%esp
  8016eb:	ff 75 10             	pushl  0x10(%ebp)
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	50                   	push   %eax
  8016f2:	ff d2                	call   *%edx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb 05                	jmp    8016fe <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801712:	85 f6                	test   %esi,%esi
  801714:	74 31                	je     801747 <readn+0x44>
  801716:	b8 00 00 00 00       	mov    $0x0,%eax
  80171b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801720:	83 ec 04             	sub    $0x4,%esp
  801723:	89 f2                	mov    %esi,%edx
  801725:	29 c2                	sub    %eax,%edx
  801727:	52                   	push   %edx
  801728:	03 45 0c             	add    0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	57                   	push   %edi
  80172d:	e8 4a ff ff ff       	call   80167c <read>
		if (m < 0)
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 17                	js     801750 <readn+0x4d>
			return m;
		if (m == 0)
  801739:	85 c0                	test   %eax,%eax
  80173b:	74 11                	je     80174e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80173d:	01 c3                	add    %eax,%ebx
  80173f:	89 d8                	mov    %ebx,%eax
  801741:	39 f3                	cmp    %esi,%ebx
  801743:	72 db                	jb     801720 <readn+0x1d>
  801745:	eb 09                	jmp    801750 <readn+0x4d>
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
  80174c:	eb 02                	jmp    801750 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80174e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 14             	sub    $0x14,%esp
  80175f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	53                   	push   %ebx
  801767:	e8 8f fc ff ff       	call   8013fb <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 62                	js     8017d5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177d:	ff 30                	pushl  (%eax)
  80177f:	e8 cd fc ff ff       	call   801451 <dev_lookup>
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	78 4a                	js     8017d5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801792:	75 21                	jne    8017b5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801794:	a1 04 40 80 00       	mov    0x804004,%eax
  801799:	8b 40 48             	mov    0x48(%eax),%eax
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	53                   	push   %ebx
  8017a0:	50                   	push   %eax
  8017a1:	68 89 29 80 00       	push   $0x802989
  8017a6:	e8 a1 eb ff ff       	call   80034c <cprintf>
		return -E_INVAL;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b3:	eb 20                	jmp    8017d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bb:	85 d2                	test   %edx,%edx
  8017bd:	74 11                	je     8017d0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	ff 75 10             	pushl  0x10(%ebp)
  8017c5:	ff 75 0c             	pushl  0xc(%ebp)
  8017c8:	50                   	push   %eax
  8017c9:	ff d2                	call   *%edx
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	eb 05                	jmp    8017d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <seek>:

int
seek(int fdnum, off_t offset)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	ff 75 08             	pushl  0x8(%ebp)
  8017e7:	e8 0f fc ff ff       	call   8013fb <fd_lookup>
  8017ec:	83 c4 08             	add    $0x8,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 0e                	js     801801 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 14             	sub    $0x14,%esp
  80180a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	53                   	push   %ebx
  801812:	e8 e4 fb ff ff       	call   8013fb <fd_lookup>
  801817:	83 c4 08             	add    $0x8,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 5f                	js     80187d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801828:	ff 30                	pushl  (%eax)
  80182a:	e8 22 fc ff ff       	call   801451 <dev_lookup>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 c0                	test   %eax,%eax
  801834:	78 47                	js     80187d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183d:	75 21                	jne    801860 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80183f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801844:	8b 40 48             	mov    0x48(%eax),%eax
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	53                   	push   %ebx
  80184b:	50                   	push   %eax
  80184c:	68 4c 29 80 00       	push   $0x80294c
  801851:	e8 f6 ea ff ff       	call   80034c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185e:	eb 1d                	jmp    80187d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801863:	8b 52 18             	mov    0x18(%edx),%edx
  801866:	85 d2                	test   %edx,%edx
  801868:	74 0e                	je     801878 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	ff 75 0c             	pushl  0xc(%ebp)
  801870:	50                   	push   %eax
  801871:	ff d2                	call   *%edx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	eb 05                	jmp    80187d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80187d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 14             	sub    $0x14,%esp
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188f:	50                   	push   %eax
  801890:	ff 75 08             	pushl  0x8(%ebp)
  801893:	e8 63 fb ff ff       	call   8013fb <fd_lookup>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 52                	js     8018f1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a9:	ff 30                	pushl  (%eax)
  8018ab:	e8 a1 fb ff ff       	call   801451 <dev_lookup>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 3a                	js     8018f1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018be:	74 2c                	je     8018ec <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ca:	00 00 00 
	stat->st_isdir = 0;
  8018cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d4:	00 00 00 
	stat->st_dev = dev;
  8018d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e4:	ff 50 14             	call   *0x14(%eax)
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	eb 05                	jmp    8018f1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	6a 00                	push   $0x0
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 78 01 00 00       	call   801a80 <open>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 1b                	js     80192c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	50                   	push   %eax
  801918:	e8 65 ff ff ff       	call   801882 <fstat>
  80191d:	89 c6                	mov    %eax,%esi
	close(fd);
  80191f:	89 1c 24             	mov    %ebx,(%esp)
  801922:	e8 18 fc ff ff       	call   80153f <close>
	return r;
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 f3                	mov    %esi,%ebx
}
  80192c:	89 d8                	mov    %ebx,%eax
  80192e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	c9                   	leave  
  801934:	c3                   	ret    
  801935:	00 00                	add    %al,(%eax)
	...

00801938 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801941:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801948:	75 12                	jne    80195c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	6a 01                	push   $0x1
  80194f:	e8 be f9 ff ff       	call   801312 <ipc_find_env>
  801954:	a3 00 40 80 00       	mov    %eax,0x804000
  801959:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80195c:	6a 07                	push   $0x7
  80195e:	68 00 50 80 00       	push   $0x805000
  801963:	53                   	push   %ebx
  801964:	ff 35 00 40 80 00    	pushl  0x804000
  80196a:	e8 4e f9 ff ff       	call   8012bd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80196f:	83 c4 0c             	add    $0xc,%esp
  801972:	6a 00                	push   $0x0
  801974:	56                   	push   %esi
  801975:	6a 00                	push   $0x0
  801977:	e8 cc f8 ff ff       	call   801248 <ipc_recv>
}
  80197c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 04             	sub    $0x4,%esp
  80198a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	8b 40 0c             	mov    0xc(%eax),%eax
  801993:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801998:	ba 00 00 00 00       	mov    $0x0,%edx
  80199d:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a2:	e8 91 ff ff ff       	call   801938 <fsipc>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 2c                	js     8019d7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	68 00 50 80 00       	push   $0x805000
  8019b3:	53                   	push   %ebx
  8019b4:	e8 49 ef ff ff       	call   800902 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8019be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8019c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f7:	e8 3c ff ff ff       	call   801938 <fsipc>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a21:	e8 12 ff ff ff       	call   801938 <fsipc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 4b                	js     801a77 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2c:	39 c6                	cmp    %eax,%esi
  801a2e:	73 16                	jae    801a46 <devfile_read+0x48>
  801a30:	68 b8 29 80 00       	push   $0x8029b8
  801a35:	68 bf 29 80 00       	push   $0x8029bf
  801a3a:	6a 7d                	push   $0x7d
  801a3c:	68 d4 29 80 00       	push   $0x8029d4
  801a41:	e8 2e e8 ff ff       	call   800274 <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 16                	jle    801a63 <devfile_read+0x65>
  801a4d:	68 df 29 80 00       	push   $0x8029df
  801a52:	68 bf 29 80 00       	push   $0x8029bf
  801a57:	6a 7e                	push   $0x7e
  801a59:	68 d4 29 80 00       	push   $0x8029d4
  801a5e:	e8 11 e8 ff ff       	call   800274 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	50                   	push   %eax
  801a67:	68 00 50 80 00       	push   $0x805000
  801a6c:	ff 75 0c             	pushl  0xc(%ebp)
  801a6f:	e8 4f f0 ff ff       	call   800ac3 <memmove>
	return r;
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 1c             	sub    $0x1c,%esp
  801a88:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8b:	56                   	push   %esi
  801a8c:	e8 1f ee ff ff       	call   8008b0 <strlen>
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a99:	7f 65                	jg     801b00 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 e1 f8 ff ff       	call   801388 <fd_alloc>
  801aa7:	89 c3                	mov    %eax,%ebx
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 55                	js     801b05 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	56                   	push   %esi
  801ab4:	68 00 50 80 00       	push   $0x805000
  801ab9:	e8 44 ee ff ff       	call   800902 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ace:	e8 65 fe ff ff       	call   801938 <fsipc>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	79 12                	jns    801aee <open+0x6e>
		fd_close(fd, 0);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	6a 00                	push   $0x0
  801ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae4:	e8 ce f9 ff ff       	call   8014b7 <fd_close>
		return r;
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	eb 17                	jmp    801b05 <open+0x85>
	}

	return fd2num(fd);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 f4             	pushl  -0xc(%ebp)
  801af4:	e8 67 f8 ff ff       	call   801360 <fd2num>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb 05                	jmp    801b05 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b05:	89 d8                	mov    %ebx,%eax
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    
	...

00801b10 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 ea 16             	shr    $0x16,%edx
  801b1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b22:	f6 c2 01             	test   $0x1,%dl
  801b25:	74 1e                	je     801b45 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b27:	c1 e8 0c             	shr    $0xc,%eax
  801b2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b31:	a8 01                	test   $0x1,%al
  801b33:	74 17                	je     801b4c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
  801b43:	eb 0c                	jmp    801b51 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4a:	eb 05                	jmp    801b51 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    
	...

00801b54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	ff 75 08             	pushl  0x8(%ebp)
  801b62:	e8 09 f8 ff ff       	call   801370 <fd2data>
  801b67:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	68 eb 29 80 00       	push   $0x8029eb
  801b71:	56                   	push   %esi
  801b72:	e8 8b ed ff ff       	call   800902 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b77:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7a:	2b 03                	sub    (%ebx),%eax
  801b7c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b82:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b89:	00 00 00 
	stat->st_dev = &devpipe;
  801b8c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b93:	30 80 00 
	return 0;
}
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bac:	53                   	push   %ebx
  801bad:	6a 00                	push   $0x0
  801baf:	e8 1a f2 ff ff       	call   800dce <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb4:	89 1c 24             	mov    %ebx,(%esp)
  801bb7:	e8 b4 f7 ff ff       	call   801370 <fd2data>
  801bbc:	83 c4 08             	add    $0x8,%esp
  801bbf:	50                   	push   %eax
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 07 f2 ff ff       	call   800dce <sys_page_unmap>
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 1c             	sub    $0x1c,%esp
  801bd5:	89 c7                	mov    %eax,%edi
  801bd7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bda:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	57                   	push   %edi
  801be6:	e8 25 ff ff ff       	call   801b10 <pageref>
  801beb:	89 c6                	mov    %eax,%esi
  801bed:	83 c4 04             	add    $0x4,%esp
  801bf0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf3:	e8 18 ff ff ff       	call   801b10 <pageref>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	39 c6                	cmp    %eax,%esi
  801bfd:	0f 94 c0             	sete   %al
  801c00:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c03:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c09:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0c:	39 cb                	cmp    %ecx,%ebx
  801c0e:	75 08                	jne    801c18 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c18:	83 f8 01             	cmp    $0x1,%eax
  801c1b:	75 bd                	jne    801bda <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c1d:	8b 42 58             	mov    0x58(%edx),%eax
  801c20:	6a 01                	push   $0x1
  801c22:	50                   	push   %eax
  801c23:	53                   	push   %ebx
  801c24:	68 f2 29 80 00       	push   $0x8029f2
  801c29:	e8 1e e7 ff ff       	call   80034c <cprintf>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	eb a7                	jmp    801bda <_pipeisclosed+0xe>

00801c33 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	57                   	push   %edi
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 28             	sub    $0x28,%esp
  801c3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c3f:	56                   	push   %esi
  801c40:	e8 2b f7 ff ff       	call   801370 <fd2data>
  801c45:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4e:	75 4a                	jne    801c9a <devpipe_write+0x67>
  801c50:	bf 00 00 00 00       	mov    $0x0,%edi
  801c55:	eb 56                	jmp    801cad <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c57:	89 da                	mov    %ebx,%edx
  801c59:	89 f0                	mov    %esi,%eax
  801c5b:	e8 6c ff ff ff       	call   801bcc <_pipeisclosed>
  801c60:	85 c0                	test   %eax,%eax
  801c62:	75 4d                	jne    801cb1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c64:	e8 f4 f0 ff ff       	call   800d5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c69:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6c:	8b 13                	mov    (%ebx),%edx
  801c6e:	83 c2 20             	add    $0x20,%edx
  801c71:	39 d0                	cmp    %edx,%eax
  801c73:	73 e2                	jae    801c57 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c75:	89 c2                	mov    %eax,%edx
  801c77:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c7d:	79 05                	jns    801c84 <devpipe_write+0x51>
  801c7f:	4a                   	dec    %edx
  801c80:	83 ca e0             	or     $0xffffffe0,%edx
  801c83:	42                   	inc    %edx
  801c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c87:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801c8a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c8e:	40                   	inc    %eax
  801c8f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	47                   	inc    %edi
  801c93:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c96:	77 07                	ja     801c9f <devpipe_write+0x6c>
  801c98:	eb 13                	jmp    801cad <devpipe_write+0x7a>
  801c9a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9f:	8b 43 04             	mov    0x4(%ebx),%eax
  801ca2:	8b 13                	mov    (%ebx),%edx
  801ca4:	83 c2 20             	add    $0x20,%edx
  801ca7:	39 d0                	cmp    %edx,%eax
  801ca9:	73 ac                	jae    801c57 <devpipe_write+0x24>
  801cab:	eb c8                	jmp    801c75 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cad:	89 f8                	mov    %edi,%eax
  801caf:	eb 05                	jmp    801cb6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 18             	sub    $0x18,%esp
  801cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cca:	57                   	push   %edi
  801ccb:	e8 a0 f6 ff ff       	call   801370 <fd2data>
  801cd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd9:	75 44                	jne    801d1f <devpipe_read+0x61>
  801cdb:	be 00 00 00 00       	mov    $0x0,%esi
  801ce0:	eb 4f                	jmp    801d31 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ce2:	89 f0                	mov    %esi,%eax
  801ce4:	eb 54                	jmp    801d3a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce6:	89 da                	mov    %ebx,%edx
  801ce8:	89 f8                	mov    %edi,%eax
  801cea:	e8 dd fe ff ff       	call   801bcc <_pipeisclosed>
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	75 42                	jne    801d35 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf3:	e8 65 f0 ff ff       	call   800d5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf8:	8b 03                	mov    (%ebx),%eax
  801cfa:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cfd:	74 e7                	je     801ce6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cff:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d04:	79 05                	jns    801d0b <devpipe_read+0x4d>
  801d06:	48                   	dec    %eax
  801d07:	83 c8 e0             	or     $0xffffffe0,%eax
  801d0a:	40                   	inc    %eax
  801d0b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d12:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d15:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d17:	46                   	inc    %esi
  801d18:	39 75 10             	cmp    %esi,0x10(%ebp)
  801d1b:	77 07                	ja     801d24 <devpipe_read+0x66>
  801d1d:	eb 12                	jmp    801d31 <devpipe_read+0x73>
  801d1f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801d24:	8b 03                	mov    (%ebx),%eax
  801d26:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d29:	75 d4                	jne    801cff <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d2b:	85 f6                	test   %esi,%esi
  801d2d:	75 b3                	jne    801ce2 <devpipe_read+0x24>
  801d2f:	eb b5                	jmp    801ce6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	eb 05                	jmp    801d3a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 28             	sub    $0x28,%esp
  801d4b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d4e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	e8 31 f6 ff ff       	call   801388 <fd_alloc>
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	0f 88 24 01 00 00    	js     801e88 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d64:	83 ec 04             	sub    $0x4,%esp
  801d67:	68 07 04 00 00       	push   $0x407
  801d6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 0e f0 ff ff       	call   800d84 <sys_page_alloc>
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	0f 88 05 01 00 00    	js     801e88 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	e8 f9 f5 ff ff       	call   801388 <fd_alloc>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	0f 88 dc 00 00 00    	js     801e78 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	68 07 04 00 00       	push   $0x407
  801da4:	ff 75 e0             	pushl  -0x20(%ebp)
  801da7:	6a 00                	push   $0x0
  801da9:	e8 d6 ef ff ff       	call   800d84 <sys_page_alloc>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	0f 88 bd 00 00 00    	js     801e78 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dbb:	83 ec 0c             	sub    $0xc,%esp
  801dbe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dc1:	e8 aa f5 ff ff       	call   801370 <fd2data>
  801dc6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc8:	83 c4 0c             	add    $0xc,%esp
  801dcb:	68 07 04 00 00       	push   $0x407
  801dd0:	50                   	push   %eax
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 ac ef ff ff       	call   800d84 <sys_page_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 83 00 00 00    	js     801e68 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 e0             	pushl  -0x20(%ebp)
  801deb:	e8 80 f5 ff ff       	call   801370 <fd2data>
  801df0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df7:	50                   	push   %eax
  801df8:	6a 00                	push   $0x0
  801dfa:	56                   	push   %esi
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 a6 ef ff ff       	call   800da8 <sys_page_map>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	83 c4 20             	add    $0x20,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 4f                	js     801e5a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e0b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e14:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e26:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e29:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e3b:	e8 20 f5 ff ff       	call   801360 <fd2num>
  801e40:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e42:	83 c4 04             	add    $0x4,%esp
  801e45:	ff 75 e0             	pushl  -0x20(%ebp)
  801e48:	e8 13 f5 ff ff       	call   801360 <fd2num>
  801e4d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e58:	eb 2e                	jmp    801e88 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e5a:	83 ec 08             	sub    $0x8,%esp
  801e5d:	56                   	push   %esi
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 69 ef ff ff       	call   800dce <sys_page_unmap>
  801e65:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 59 ef ff ff       	call   800dce <sys_page_unmap>
  801e75:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 49 ef ff ff       	call   800dce <sys_page_unmap>
  801e85:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    

00801e92 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9b:	50                   	push   %eax
  801e9c:	ff 75 08             	pushl  0x8(%ebp)
  801e9f:	e8 57 f5 ff ff       	call   8013fb <fd_lookup>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 18                	js     801ec3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eab:	83 ec 0c             	sub    $0xc,%esp
  801eae:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb1:	e8 ba f4 ff ff       	call   801370 <fd2data>
	return _pipeisclosed(fd, p);
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	e8 0c fd ff ff       	call   801bcc <_pipeisclosed>
  801ec0:	83 c4 10             	add    $0x10,%esp
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    
  801ec5:	00 00                	add    %al,(%eax)
	...

00801ec8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed8:	68 0a 2a 80 00       	push   $0x802a0a
  801edd:	ff 75 0c             	pushl  0xc(%ebp)
  801ee0:	e8 1d ea ff ff       	call   800902 <strcpy>
	return 0;
}
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801efc:	74 45                	je     801f43 <devcons_write+0x57>
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
  801f03:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f08:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f11:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801f13:	83 fb 7f             	cmp    $0x7f,%ebx
  801f16:	76 05                	jbe    801f1d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801f18:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f1d:	83 ec 04             	sub    $0x4,%esp
  801f20:	53                   	push   %ebx
  801f21:	03 45 0c             	add    0xc(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	57                   	push   %edi
  801f26:	e8 98 eb ff ff       	call   800ac3 <memmove>
		sys_cputs(buf, m);
  801f2b:	83 c4 08             	add    $0x8,%esp
  801f2e:	53                   	push   %ebx
  801f2f:	57                   	push   %edi
  801f30:	e8 98 ed ff ff       	call   800ccd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f35:	01 de                	add    %ebx,%esi
  801f37:	89 f0                	mov    %esi,%eax
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f3f:	72 cd                	jb     801f0e <devcons_write+0x22>
  801f41:	eb 05                	jmp    801f48 <devcons_write+0x5c>
  801f43:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f48:	89 f0                	mov    %esi,%eax
  801f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f5c:	75 07                	jne    801f65 <devcons_read+0x13>
  801f5e:	eb 25                	jmp    801f85 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f60:	e8 f8 ed ff ff       	call   800d5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f65:	e8 89 ed ff ff       	call   800cf3 <sys_cgetc>
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	74 f2                	je     801f60 <devcons_read+0xe>
  801f6e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f70:	85 c0                	test   %eax,%eax
  801f72:	78 1d                	js     801f91 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f74:	83 f8 04             	cmp    $0x4,%eax
  801f77:	74 13                	je     801f8c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7c:	88 10                	mov    %dl,(%eax)
	return 1;
  801f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f83:	eb 0c                	jmp    801f91 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8a:	eb 05                	jmp    801f91 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f99:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f9f:	6a 01                	push   $0x1
  801fa1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	e8 23 ed ff ff       	call   800ccd <sys_cputs>
  801faa:	83 c4 10             	add    $0x10,%esp
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <getchar>:

int
getchar(void)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fb5:	6a 01                	push   $0x1
  801fb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	6a 00                	push   $0x0
  801fbd:	e8 ba f6 ff ff       	call   80167c <read>
	if (r < 0)
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 0f                	js     801fd8 <getchar+0x29>
		return r;
	if (r < 1)
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	7e 06                	jle    801fd3 <getchar+0x24>
		return -E_EOF;
	return c;
  801fcd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fd1:	eb 05                	jmp    801fd8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fd3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe3:	50                   	push   %eax
  801fe4:	ff 75 08             	pushl  0x8(%ebp)
  801fe7:	e8 0f f4 ff ff       	call   8013fb <fd_lookup>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 11                	js     802004 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffc:	39 10                	cmp    %edx,(%eax)
  801ffe:	0f 94 c0             	sete   %al
  802001:	0f b6 c0             	movzbl %al,%eax
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <opencons>:

int
opencons(void)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80200c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	e8 73 f3 ff ff       	call   801388 <fd_alloc>
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 3a                	js     802056 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80201c:	83 ec 04             	sub    $0x4,%esp
  80201f:	68 07 04 00 00       	push   $0x407
  802024:	ff 75 f4             	pushl  -0xc(%ebp)
  802027:	6a 00                	push   $0x0
  802029:	e8 56 ed ff ff       	call   800d84 <sys_page_alloc>
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	78 21                	js     802056 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802035:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80203b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802043:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80204a:	83 ec 0c             	sub    $0xc,%esp
  80204d:	50                   	push   %eax
  80204e:	e8 0d f3 ff ff       	call   801360 <fd2num>
  802053:	83 c4 10             	add    $0x10,%esp
}
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80205e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802065:	75 52                	jne    8020b9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802067:	83 ec 04             	sub    $0x4,%esp
  80206a:	6a 07                	push   $0x7
  80206c:	68 00 f0 bf ee       	push   $0xeebff000
  802071:	6a 00                	push   $0x0
  802073:	e8 0c ed ff ff       	call   800d84 <sys_page_alloc>
		if (r < 0) {
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	79 12                	jns    802091 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80207f:	50                   	push   %eax
  802080:	68 16 2a 80 00       	push   $0x802a16
  802085:	6a 24                	push   $0x24
  802087:	68 31 2a 80 00       	push   $0x802a31
  80208c:	e8 e3 e1 ff ff       	call   800274 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	68 c4 20 80 00       	push   $0x8020c4
  802099:	6a 00                	push   $0x0
  80209b:	e8 97 ed ff ff       	call   800e37 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	79 12                	jns    8020b9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8020a7:	50                   	push   %eax
  8020a8:	68 40 2a 80 00       	push   $0x802a40
  8020ad:	6a 2a                	push   $0x2a
  8020af:	68 31 2a 80 00       	push   $0x802a31
  8020b4:	e8 bb e1 ff ff       	call   800274 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    
	...

008020c4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020c4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020c5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020ca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020cc:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8020cf:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8020d3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8020d6:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8020da:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8020de:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8020e0:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8020e3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8020e4:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8020e7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020e8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020e9:	c3                   	ret    
	...

008020ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	57                   	push   %edi
  8020f0:	56                   	push   %esi
  8020f1:	83 ec 10             	sub    $0x10,%esp
  8020f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020fa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802100:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802103:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802106:	85 c0                	test   %eax,%eax
  802108:	75 2e                	jne    802138 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80210a:	39 f1                	cmp    %esi,%ecx
  80210c:	77 5a                	ja     802168 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80210e:	85 c9                	test   %ecx,%ecx
  802110:	75 0b                	jne    80211d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802112:	b8 01 00 00 00       	mov    $0x1,%eax
  802117:	31 d2                	xor    %edx,%edx
  802119:	f7 f1                	div    %ecx
  80211b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80211d:	31 d2                	xor    %edx,%edx
  80211f:	89 f0                	mov    %esi,%eax
  802121:	f7 f1                	div    %ecx
  802123:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802125:	89 f8                	mov    %edi,%eax
  802127:	f7 f1                	div    %ecx
  802129:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80212b:	89 f8                	mov    %edi,%eax
  80212d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	c9                   	leave  
  802135:	c3                   	ret    
  802136:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802138:	39 f0                	cmp    %esi,%eax
  80213a:	77 1c                	ja     802158 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80213c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80213f:	83 f7 1f             	xor    $0x1f,%edi
  802142:	75 3c                	jne    802180 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802144:	39 f0                	cmp    %esi,%eax
  802146:	0f 82 90 00 00 00    	jb     8021dc <__udivdi3+0xf0>
  80214c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80214f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802152:	0f 86 84 00 00 00    	jbe    8021dc <__udivdi3+0xf0>
  802158:	31 f6                	xor    %esi,%esi
  80215a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80215c:	89 f8                	mov    %edi,%eax
  80215e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	5e                   	pop    %esi
  802164:	5f                   	pop    %edi
  802165:	c9                   	leave  
  802166:	c3                   	ret    
  802167:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802168:	89 f2                	mov    %esi,%edx
  80216a:	89 f8                	mov    %edi,%eax
  80216c:	f7 f1                	div    %ecx
  80216e:	89 c7                	mov    %eax,%edi
  802170:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802172:	89 f8                	mov    %edi,%eax
  802174:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802176:	83 c4 10             	add    $0x10,%esp
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	c9                   	leave  
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802180:	89 f9                	mov    %edi,%ecx
  802182:	d3 e0                	shl    %cl,%eax
  802184:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802187:	b8 20 00 00 00       	mov    $0x20,%eax
  80218c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80218e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802191:	88 c1                	mov    %al,%cl
  802193:	d3 ea                	shr    %cl,%edx
  802195:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802198:	09 ca                	or     %ecx,%edx
  80219a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80219d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a0:	89 f9                	mov    %edi,%ecx
  8021a2:	d3 e2                	shl    %cl,%edx
  8021a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021a7:	89 f2                	mov    %esi,%edx
  8021a9:	88 c1                	mov    %al,%cl
  8021ab:	d3 ea                	shr    %cl,%edx
  8021ad:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	89 f9                	mov    %edi,%ecx
  8021b4:	d3 e2                	shl    %cl,%edx
  8021b6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021b9:	88 c1                	mov    %al,%cl
  8021bb:	d3 ee                	shr    %cl,%esi
  8021bd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021c2:	89 f0                	mov    %esi,%eax
  8021c4:	89 ca                	mov    %ecx,%edx
  8021c6:	f7 75 ec             	divl   -0x14(%ebp)
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021cd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021d0:	39 d1                	cmp    %edx,%ecx
  8021d2:	72 28                	jb     8021fc <__udivdi3+0x110>
  8021d4:	74 1a                	je     8021f0 <__udivdi3+0x104>
  8021d6:	89 f7                	mov    %esi,%edi
  8021d8:	31 f6                	xor    %esi,%esi
  8021da:	eb 80                	jmp    80215c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021dc:	31 f6                	xor    %esi,%esi
  8021de:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021e7:	83 c4 10             	add    $0x10,%esp
  8021ea:	5e                   	pop    %esi
  8021eb:	5f                   	pop    %edi
  8021ec:	c9                   	leave  
  8021ed:	c3                   	ret    
  8021ee:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021f7:	39 c2                	cmp    %eax,%edx
  8021f9:	73 db                	jae    8021d6 <__udivdi3+0xea>
  8021fb:	90                   	nop
		{
		  q0--;
  8021fc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021ff:	31 f6                	xor    %esi,%esi
  802201:	e9 56 ff ff ff       	jmp    80215c <__udivdi3+0x70>
	...

00802208 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	57                   	push   %edi
  80220c:	56                   	push   %esi
  80220d:	83 ec 20             	sub    $0x20,%esp
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802216:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802219:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80221c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80221f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802222:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802225:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802227:	85 ff                	test   %edi,%edi
  802229:	75 15                	jne    802240 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80222b:	39 f1                	cmp    %esi,%ecx
  80222d:	0f 86 99 00 00 00    	jbe    8022cc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802233:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802235:	89 d0                	mov    %edx,%eax
  802237:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802239:	83 c4 20             	add    $0x20,%esp
  80223c:	5e                   	pop    %esi
  80223d:	5f                   	pop    %edi
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802240:	39 f7                	cmp    %esi,%edi
  802242:	0f 87 a4 00 00 00    	ja     8022ec <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802248:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80224b:	83 f0 1f             	xor    $0x1f,%eax
  80224e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802251:	0f 84 a1 00 00 00    	je     8022f8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802257:	89 f8                	mov    %edi,%eax
  802259:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80225c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80225e:	bf 20 00 00 00       	mov    $0x20,%edi
  802263:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802266:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802269:	89 f9                	mov    %edi,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802278:	d3 e0                	shl    %cl,%eax
  80227a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802281:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802284:	d3 e0                	shl    %cl,%eax
  802286:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802289:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80228c:	89 f9                	mov    %edi,%ecx
  80228e:	d3 e8                	shr    %cl,%eax
  802290:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802292:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802294:	89 f2                	mov    %esi,%edx
  802296:	f7 75 f0             	divl   -0x10(%ebp)
  802299:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80229b:	f7 65 f4             	mull   -0xc(%ebp)
  80229e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022a1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	72 71                	jb     802318 <__umoddi3+0x110>
  8022a7:	74 7f                	je     802328 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ac:	29 c8                	sub    %ecx,%eax
  8022ae:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022b0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022b3:	d3 e8                	shr    %cl,%eax
  8022b5:	89 f2                	mov    %esi,%edx
  8022b7:	89 f9                	mov    %edi,%ecx
  8022b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022bb:	09 d0                	or     %edx,%eax
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022c2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022c4:	83 c4 20             	add    $0x20,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022cc:	85 c9                	test   %ecx,%ecx
  8022ce:	75 0b                	jne    8022db <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d5:	31 d2                	xor    %edx,%edx
  8022d7:	f7 f1                	div    %ecx
  8022d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022db:	89 f0                	mov    %esi,%eax
  8022dd:	31 d2                	xor    %edx,%edx
  8022df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e4:	f7 f1                	div    %ecx
  8022e6:	e9 4a ff ff ff       	jmp    802235 <__umoddi3+0x2d>
  8022eb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022ec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ee:	83 c4 20             	add    $0x20,%esp
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022f8:	39 f7                	cmp    %esi,%edi
  8022fa:	72 05                	jb     802301 <__umoddi3+0xf9>
  8022fc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022ff:	77 0c                	ja     80230d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802301:	89 f2                	mov    %esi,%edx
  802303:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802306:	29 c8                	sub    %ecx,%eax
  802308:	19 fa                	sbb    %edi,%edx
  80230a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80230d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802310:	83 c4 20             	add    $0x20,%esp
  802313:	5e                   	pop    %esi
  802314:	5f                   	pop    %edi
  802315:	c9                   	leave  
  802316:	c3                   	ret    
  802317:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802318:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80231b:	89 c1                	mov    %eax,%ecx
  80231d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802320:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802323:	eb 84                	jmp    8022a9 <__umoddi3+0xa1>
  802325:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802328:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80232b:	72 eb                	jb     802318 <__umoddi3+0x110>
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	e9 75 ff ff ff       	jmp    8022a9 <__umoddi3+0xa1>
