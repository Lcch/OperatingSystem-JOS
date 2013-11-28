
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
  80002c:	e8 e3 01 00 00       	call   800214 <libmain>
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
  80003c:	68 20 23 80 00       	push   $0x802320
  800041:	e8 12 03 00 00       	call   800358 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 cd 1c 00 00       	call   801d1e <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 39 23 80 00       	push   $0x802339
  80005e:	6a 0d                	push   $0xd
  800060:	68 42 23 80 00       	push   $0x802342
  800065:	e8 16 02 00 00       	call   800280 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  80006a:	e8 5b 0f 00 00       	call   800fca <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 56 23 80 00       	push   $0x802356
  80007b:	6a 10                	push   $0x10
  80007d:	68 42 23 80 00       	push   $0x802342
  800082:	e8 f9 01 00 00       	call   800280 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 59                	jne    8000e4 <umain+0xb0>
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	e8 85 14 00 00       	call   80151b <close>
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
  8000a4:	e8 c5 1d 00 00       	call   801e6e <pipeisclosed>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	85 c0                	test   %eax,%eax
  8000ae:	74 15                	je     8000c5 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000b0:	83 ec 0c             	sub    $0xc,%esp
  8000b3:	68 5f 23 80 00       	push   $0x80235f
  8000b8:	e8 9b 02 00 00       	call   800358 <cprintf>
				exit();
  8000bd:	e8 a2 01 00 00       	call   800264 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c5:	e8 9f 0c 00 00       	call   800d69 <sys_yield>
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
  8000dc:	e8 33 11 00 00       	call   801214 <ipc_recv>
  8000e1:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	56                   	push   %esi
  8000e8:	68 7a 23 80 00       	push   $0x80237a
  8000ed:	e8 66 02 00 00       	call   800358 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8000f8:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  8000ff:	89 f3                	mov    %esi,%ebx
  800101:	c1 e3 07             	shl    $0x7,%ebx
  800104:	29 c3                	sub    %eax,%ebx
	cprintf("kid is %d\n", kid-envs);
  800106:	83 c4 08             	add    $0x8,%esp
  800109:	89 d8                	mov    %ebx,%eax
  80010b:	c1 f8 02             	sar    $0x2,%eax
  80010e:	89 c1                	mov    %eax,%ecx
  800110:	c1 e1 05             	shl    $0x5,%ecx
  800113:	89 c2                	mov    %eax,%edx
  800115:	c1 e2 0a             	shl    $0xa,%edx
  800118:	8d 14 11             	lea    (%ecx,%edx,1),%edx
  80011b:	01 c2                	add    %eax,%edx
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	c1 e1 0f             	shl    $0xf,%ecx
  800122:	01 ca                	add    %ecx,%edx
  800124:	c1 e2 05             	shl    $0x5,%edx
  800127:	8d 04 02             	lea    (%edx,%eax,1),%eax
  80012a:	f7 d8                	neg    %eax
  80012c:	50                   	push   %eax
  80012d:	68 85 23 80 00       	push   $0x802385
  800132:	e8 21 02 00 00       	call   800358 <cprintf>
	dup(p[0], 10);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	6a 0a                	push   $0xa
  80013c:	ff 75 f0             	pushl  -0x10(%ebp)
  80013f:	e8 25 14 00 00       	call   801569 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800144:	81 c3 04 00 c0 ee    	add    $0xeec00004,%ebx
  80014a:	8b 43 50             	mov    0x50(%ebx),%eax
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	83 f8 02             	cmp    $0x2,%eax
  800153:	75 18                	jne    80016d <umain+0x139>
		dup(p[0], 10);
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	6a 0a                	push   $0xa
  80015a:	ff 75 f0             	pushl  -0x10(%ebp)
  80015d:	e8 07 14 00 00       	call   801569 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800162:	8b 43 50             	mov    0x50(%ebx),%eax
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	83 f8 02             	cmp    $0x2,%eax
  80016b:	74 e8                	je     800155 <umain+0x121>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	68 90 23 80 00       	push   $0x802390
  800175:	e8 de 01 00 00       	call   800358 <cprintf>
	if (pipeisclosed(p[0]))
  80017a:	83 c4 04             	add    $0x4,%esp
  80017d:	ff 75 f0             	pushl  -0x10(%ebp)
  800180:	e8 e9 1c 00 00       	call   801e6e <pipeisclosed>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	85 c0                	test   %eax,%eax
  80018a:	74 14                	je     8001a0 <umain+0x16c>
		panic("somehow the other end of p[0] got closed!");
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	68 ec 23 80 00       	push   $0x8023ec
  800194:	6a 3a                	push   $0x3a
  800196:	68 42 23 80 00       	push   $0x802342
  80019b:	e8 e0 00 00 00       	call   800280 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8001aa:	e8 28 12 00 00       	call   8013d7 <fd_lookup>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	85 c0                	test   %eax,%eax
  8001b4:	79 12                	jns    8001c8 <umain+0x194>
		panic("cannot look up p[0]: %e", r);
  8001b6:	50                   	push   %eax
  8001b7:	68 a6 23 80 00       	push   $0x8023a6
  8001bc:	6a 3c                	push   $0x3c
  8001be:	68 42 23 80 00       	push   $0x802342
  8001c3:	e8 b8 00 00 00       	call   800280 <_panic>
	va = fd2data(fd);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ce:	e8 79 11 00 00       	call   80134c <fd2data>
	if (pageref(va) != 3+1)
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 11 19 00 00       	call   801aec <pageref>
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	83 f8 04             	cmp    $0x4,%eax
  8001e1:	74 12                	je     8001f5 <umain+0x1c1>
		cprintf("\nchild detected race\n");
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	68 be 23 80 00       	push   $0x8023be
  8001eb:	e8 68 01 00 00       	call   800358 <cprintf>
  8001f0:	83 c4 10             	add    $0x10,%esp
  8001f3:	eb 15                	jmp    80020a <umain+0x1d6>
	else
		cprintf("\nrace didn't happen\n", max);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	68 c8 00 00 00       	push   $0xc8
  8001fd:	68 d4 23 80 00       	push   $0x8023d4
  800202:	e8 51 01 00 00       	call   800358 <cprintf>
  800207:	83 c4 10             	add    $0x10,%esp
}
  80020a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	c9                   	leave  
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	8b 75 08             	mov    0x8(%ebp),%esi
  80021c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80021f:	e8 21 0b 00 00       	call   800d45 <sys_getenvid>
  800224:	25 ff 03 00 00       	and    $0x3ff,%eax
  800229:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800230:	c1 e0 07             	shl    $0x7,%eax
  800233:	29 d0                	sub    %edx,%eax
  800235:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023f:	85 f6                	test   %esi,%esi
  800241:	7e 07                	jle    80024a <libmain+0x36>
		binaryname = argv[0];
  800243:	8b 03                	mov    (%ebx),%eax
  800245:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	53                   	push   %ebx
  80024e:	56                   	push   %esi
  80024f:	e8 e0 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800254:	e8 0b 00 00 00       	call   800264 <exit>
  800259:	83 c4 10             	add    $0x10,%esp
}
  80025c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	c9                   	leave  
  800262:	c3                   	ret    
	...

00800264 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026a:	e8 d7 12 00 00       	call   801546 <close_all>
	sys_env_destroy(0);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	6a 00                	push   $0x0
  800274:	e8 aa 0a 00 00       	call   800d23 <sys_env_destroy>
  800279:	83 c4 10             	add    $0x10,%esp
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800285:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800288:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80028e:	e8 b2 0a 00 00       	call   800d45 <sys_getenvid>
  800293:	83 ec 0c             	sub    $0xc,%esp
  800296:	ff 75 0c             	pushl  0xc(%ebp)
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	68 20 24 80 00       	push   $0x802420
  8002a3:	e8 b0 00 00 00       	call   800358 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a8:	83 c4 18             	add    $0x18,%esp
  8002ab:	56                   	push   %esi
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	e8 53 00 00 00       	call   800307 <vcprintf>
	cprintf("\n");
  8002b4:	c7 04 24 37 23 80 00 	movl   $0x802337,(%esp)
  8002bb:	e8 98 00 00 00       	call   800358 <cprintf>
  8002c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c3:	cc                   	int3   
  8002c4:	eb fd                	jmp    8002c3 <_panic+0x43>
	...

008002c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 04             	sub    $0x4,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002d2:	8b 03                	mov    (%ebx),%eax
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002db:	40                   	inc    %eax
  8002dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e3:	75 1a                	jne    8002ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	68 ff 00 00 00       	push   $0xff
  8002ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f0:	50                   	push   %eax
  8002f1:	e8 e3 09 00 00       	call   800cd9 <sys_cputs>
		b->idx = 0;
  8002f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ff:	ff 43 04             	incl   0x4(%ebx)
}
  800302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800310:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800317:	00 00 00 
	b.cnt = 0;
  80031a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800321:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800324:	ff 75 0c             	pushl  0xc(%ebp)
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800330:	50                   	push   %eax
  800331:	68 c8 02 80 00       	push   $0x8002c8
  800336:	e8 82 01 00 00       	call   8004bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80033b:	83 c4 08             	add    $0x8,%esp
  80033e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800344:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80034a:	50                   	push   %eax
  80034b:	e8 89 09 00 00       	call   800cd9 <sys_cputs>

	return b.cnt;
}
  800350:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80035e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 9d ff ff ff       	call   800307 <vcprintf>
	va_end(ap);

	return cnt;
}
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 2c             	sub    $0x2c,%esp
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	89 d6                	mov    %edx,%esi
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800380:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800383:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800386:	8b 45 10             	mov    0x10(%ebp),%eax
  800389:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80038c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800392:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800399:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80039c:	72 0c                	jb     8003aa <printnum+0x3e>
  80039e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003a1:	76 07                	jbe    8003aa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a3:	4b                   	dec    %ebx
  8003a4:	85 db                	test   %ebx,%ebx
  8003a6:	7f 31                	jg     8003d9 <printnum+0x6d>
  8003a8:	eb 3f                	jmp    8003e9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	57                   	push   %edi
  8003ae:	4b                   	dec    %ebx
  8003af:	53                   	push   %ebx
  8003b0:	50                   	push   %eax
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c0:	e8 03 1d 00 00       	call   8020c8 <__udivdi3>
  8003c5:	83 c4 18             	add    $0x18,%esp
  8003c8:	52                   	push   %edx
  8003c9:	50                   	push   %eax
  8003ca:	89 f2                	mov    %esi,%edx
  8003cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003cf:	e8 98 ff ff ff       	call   80036c <printnum>
  8003d4:	83 c4 20             	add    $0x20,%esp
  8003d7:	eb 10                	jmp    8003e9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	56                   	push   %esi
  8003dd:	57                   	push   %edi
  8003de:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e1:	4b                   	dec    %ebx
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	85 db                	test   %ebx,%ebx
  8003e7:	7f f0                	jg     8003d9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	83 ec 04             	sub    $0x4,%esp
  8003f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fc:	e8 e3 1d 00 00       	call   8021e4 <__umoddi3>
  800401:	83 c4 14             	add    $0x14,%esp
  800404:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  80040b:	50                   	push   %eax
  80040c:	ff 55 e4             	call   *-0x1c(%ebp)
  80040f:	83 c4 10             	add    $0x10,%esp
}
  800412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800415:	5b                   	pop    %ebx
  800416:	5e                   	pop    %esi
  800417:	5f                   	pop    %edi
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80041d:	83 fa 01             	cmp    $0x1,%edx
  800420:	7e 0e                	jle    800430 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 08             	lea    0x8(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	8b 52 04             	mov    0x4(%edx),%edx
  80042e:	eb 22                	jmp    800452 <getuint+0x38>
	else if (lflag)
  800430:	85 d2                	test   %edx,%edx
  800432:	74 10                	je     800444 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 0e                	jmp    800452 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800457:	83 fa 01             	cmp    $0x1,%edx
  80045a:	7e 0e                	jle    80046a <getint+0x16>
		return va_arg(*ap, long long);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	8b 52 04             	mov    0x4(%edx),%edx
  800468:	eb 1a                	jmp    800484 <getint+0x30>
	else if (lflag)
  80046a:	85 d2                	test   %edx,%edx
  80046c:	74 0c                	je     80047a <getint+0x26>
		return va_arg(*ap, long);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 04             	lea    0x4(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	99                   	cltd   
  800478:	eb 0a                	jmp    800484 <getint+0x30>
	else
		return va_arg(*ap, int);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	99                   	cltd   
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80048f:	8b 10                	mov    (%eax),%edx
  800491:	3b 50 04             	cmp    0x4(%eax),%edx
  800494:	73 08                	jae    80049e <sprintputch+0x18>
		*b->buf++ = ch;
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	88 0a                	mov    %cl,(%edx)
  80049b:	42                   	inc    %edx
  80049c:	89 10                	mov    %edx,(%eax)
}
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a9:	50                   	push   %eax
  8004aa:	ff 75 10             	pushl  0x10(%ebp)
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	ff 75 08             	pushl  0x8(%ebp)
  8004b3:	e8 05 00 00 00       	call   8004bd <vprintfmt>
	va_end(ap);
  8004b8:	83 c4 10             	add    $0x10,%esp
}
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    

008004bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	57                   	push   %edi
  8004c1:	56                   	push   %esi
  8004c2:	53                   	push   %ebx
  8004c3:	83 ec 2c             	sub    $0x2c,%esp
  8004c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8004cc:	eb 13                	jmp    8004e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	0f 84 6d 03 00 00    	je     800843 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	57                   	push   %edi
  8004da:	50                   	push   %eax
  8004db:	ff 55 08             	call   *0x8(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e1:	0f b6 06             	movzbl (%esi),%eax
  8004e4:	46                   	inc    %esi
  8004e5:	83 f8 25             	cmp    $0x25,%eax
  8004e8:	75 e4                	jne    8004ce <vprintfmt+0x11>
  8004ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	eb 28                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80050c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800510:	eb 20                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800514:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800518:	eb 18                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80051c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800523:	eb 0d                	jmp    800532 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800525:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800528:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8a 06                	mov    (%esi),%al
  800534:	0f b6 d0             	movzbl %al,%edx
  800537:	8d 5e 01             	lea    0x1(%esi),%ebx
  80053a:	83 e8 23             	sub    $0x23,%eax
  80053d:	3c 55                	cmp    $0x55,%al
  80053f:	0f 87 e0 02 00 00    	ja     800825 <vprintfmt+0x368>
  800545:	0f b6 c0             	movzbl %al,%eax
  800548:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80054f:	83 ea 30             	sub    $0x30,%edx
  800552:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800555:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800558:	8d 50 d0             	lea    -0x30(%eax),%edx
  80055b:	83 fa 09             	cmp    $0x9,%edx
  80055e:	77 44                	ja     8005a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	89 de                	mov    %ebx,%esi
  800562:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800565:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800566:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800569:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80056d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800570:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800573:	83 fb 09             	cmp    $0x9,%ebx
  800576:	76 ed                	jbe    800565 <vprintfmt+0xa8>
  800578:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80057b:	eb 29                	jmp    8005a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058d:	eb 17                	jmp    8005a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800593:	78 85                	js     80051a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	89 de                	mov    %ebx,%esi
  800597:	eb 99                	jmp    800532 <vprintfmt+0x75>
  800599:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005a2:	eb 8e                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005aa:	79 86                	jns    800532 <vprintfmt+0x75>
  8005ac:	e9 74 ff ff ff       	jmp    800525 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	89 de                	mov    %ebx,%esi
  8005b4:	e9 79 ff ff ff       	jmp    800532 <vprintfmt+0x75>
  8005b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	ff 30                	pushl  (%eax)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005d4:	e9 08 ff ff ff       	jmp    8004e1 <vprintfmt+0x24>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 02                	jns    8005ed <vprintfmt+0x130>
  8005eb:	f7 d8                	neg    %eax
  8005ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ef:	83 f8 0f             	cmp    $0xf,%eax
  8005f2:	7f 0b                	jg     8005ff <vprintfmt+0x142>
  8005f4:	8b 04 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%eax
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	75 1a                	jne    800619 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005ff:	52                   	push   %edx
  800600:	68 5b 24 80 00       	push   $0x80245b
  800605:	57                   	push   %edi
  800606:	ff 75 08             	pushl  0x8(%ebp)
  800609:	e8 92 fe ff ff       	call   8004a0 <printfmt>
  80060e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800614:	e9 c8 fe ff ff       	jmp    8004e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800619:	50                   	push   %eax
  80061a:	68 b1 29 80 00       	push   $0x8029b1
  80061f:	57                   	push   %edi
  800620:	ff 75 08             	pushl  0x8(%ebp)
  800623:	e8 78 fe ff ff       	call   8004a0 <printfmt>
  800628:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062e:	e9 ae fe ff ff       	jmp    8004e1 <vprintfmt+0x24>
  800633:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800636:	89 de                	mov    %ebx,%esi
  800638:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80063b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	75 07                	jne    800657 <vprintfmt+0x19a>
				p = "(null)";
  800650:	c7 45 d0 54 24 80 00 	movl   $0x802454,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800657:	85 db                	test   %ebx,%ebx
  800659:	7e 42                	jle    80069d <vprintfmt+0x1e0>
  80065b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80065f:	74 3c                	je     80069d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	51                   	push   %ecx
  800665:	ff 75 d0             	pushl  -0x30(%ebp)
  800668:	e8 6f 02 00 00       	call   8008dc <strnlen>
  80066d:	29 c3                	sub    %eax,%ebx
  80066f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	85 db                	test   %ebx,%ebx
  800677:	7e 24                	jle    80069d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800679:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80067d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800680:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	57                   	push   %edi
  800687:	53                   	push   %ebx
  800688:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	4e                   	dec    %esi
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	85 f6                	test   %esi,%esi
  800691:	7f f0                	jg     800683 <vprintfmt+0x1c6>
  800693:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a0:	0f be 02             	movsbl (%edx),%eax
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	75 47                	jne    8006ee <vprintfmt+0x231>
  8006a7:	eb 37                	jmp    8006e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	74 16                	je     8006c5 <vprintfmt+0x208>
  8006af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b2:	83 fa 5e             	cmp    $0x5e,%edx
  8006b5:	76 0e                	jbe    8006c5 <vprintfmt+0x208>
					putch('?', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	57                   	push   %edi
  8006bb:	6a 3f                	push   $0x3f
  8006bd:	ff 55 08             	call   *0x8(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 0b                	jmp    8006d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	57                   	push   %edi
  8006c9:	50                   	push   %eax
  8006ca:	ff 55 08             	call   *0x8(%ebp)
  8006cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d3:	0f be 03             	movsbl (%ebx),%eax
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 03                	je     8006dd <vprintfmt+0x220>
  8006da:	43                   	inc    %ebx
  8006db:	eb 1b                	jmp    8006f8 <vprintfmt+0x23b>
  8006dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e4:	7f 1e                	jg     800704 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006e9:	e9 f3 fd ff ff       	jmp    8004e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006f1:	43                   	inc    %ebx
  8006f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006f8:	85 f6                	test   %esi,%esi
  8006fa:	78 ad                	js     8006a9 <vprintfmt+0x1ec>
  8006fc:	4e                   	dec    %esi
  8006fd:	79 aa                	jns    8006a9 <vprintfmt+0x1ec>
  8006ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800702:	eb dc                	jmp    8006e0 <vprintfmt+0x223>
  800704:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	57                   	push   %edi
  80070b:	6a 20                	push   $0x20
  80070d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	4b                   	dec    %ebx
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 db                	test   %ebx,%ebx
  800716:	7f ef                	jg     800707 <vprintfmt+0x24a>
  800718:	e9 c4 fd ff ff       	jmp    8004e1 <vprintfmt+0x24>
  80071d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800720:	89 ca                	mov    %ecx,%edx
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	e8 2a fd ff ff       	call   800454 <getint>
  80072a:	89 c3                	mov    %eax,%ebx
  80072c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80072e:	85 d2                	test   %edx,%edx
  800730:	78 0a                	js     80073c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800732:	b8 0a 00 00 00       	mov    $0xa,%eax
  800737:	e9 b0 00 00 00       	jmp    8007ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	57                   	push   %edi
  800740:	6a 2d                	push   $0x2d
  800742:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800745:	f7 db                	neg    %ebx
  800747:	83 d6 00             	adc    $0x0,%esi
  80074a:	f7 de                	neg    %esi
  80074c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800754:	e9 93 00 00 00       	jmp    8007ec <vprintfmt+0x32f>
  800759:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 b4 fc ff ff       	call   80041a <getuint>
  800766:	89 c3                	mov    %eax,%ebx
  800768:	89 d6                	mov    %edx,%esi
			base = 10;
  80076a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80076f:	eb 7b                	jmp    8007ec <vprintfmt+0x32f>
  800771:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800774:	89 ca                	mov    %ecx,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 d6 fc ff ff       	call   800454 <getint>
  80077e:	89 c3                	mov    %eax,%ebx
  800780:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800782:	85 d2                	test   %edx,%edx
  800784:	78 07                	js     80078d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800786:	b8 08 00 00 00       	mov    $0x8,%eax
  80078b:	eb 5f                	jmp    8007ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	57                   	push   %edi
  800791:	6a 2d                	push   $0x2d
  800793:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800796:	f7 db                	neg    %ebx
  800798:	83 d6 00             	adc    $0x0,%esi
  80079b:	f7 de                	neg    %esi
  80079d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a5:	eb 45                	jmp    8007ec <vprintfmt+0x32f>
  8007a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	57                   	push   %edi
  8007ae:	6a 30                	push   $0x30
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b3:	83 c4 08             	add    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	6a 78                	push   $0x78
  8007b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 50 04             	lea    0x4(%eax),%edx
  8007c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c5:	8b 18                	mov    (%eax),%ebx
  8007c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d4:	eb 16                	jmp    8007ec <vprintfmt+0x32f>
  8007d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 37 fc ff ff       	call   80041a <getuint>
  8007e3:	89 c3                	mov    %eax,%ebx
  8007e5:	89 d6                	mov    %edx,%esi
			base = 16;
  8007e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ec:	83 ec 0c             	sub    $0xc,%esp
  8007ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007f3:	52                   	push   %edx
  8007f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f7:	50                   	push   %eax
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	89 fa                	mov    %edi,%edx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	e8 68 fb ff ff       	call   80036c <printnum>
			break;
  800804:	83 c4 20             	add    $0x20,%esp
  800807:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80080a:	e9 d2 fc ff ff       	jmp    8004e1 <vprintfmt+0x24>
  80080f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	57                   	push   %edi
  800816:	52                   	push   %edx
  800817:	ff 55 08             	call   *0x8(%ebp)
			break;
  80081a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800820:	e9 bc fc ff ff       	jmp    8004e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	57                   	push   %edi
  800829:	6a 25                	push   $0x25
  80082b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 02                	jmp    800835 <vprintfmt+0x378>
  800833:	89 c6                	mov    %eax,%esi
  800835:	8d 46 ff             	lea    -0x1(%esi),%eax
  800838:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80083c:	75 f5                	jne    800833 <vprintfmt+0x376>
  80083e:	e9 9e fc ff ff       	jmp    8004e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800843:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 18             	sub    $0x18,%esp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800868:	85 c0                	test   %eax,%eax
  80086a:	74 26                	je     800892 <vsnprintf+0x47>
  80086c:	85 d2                	test   %edx,%edx
  80086e:	7e 29                	jle    800899 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800870:	ff 75 14             	pushl  0x14(%ebp)
  800873:	ff 75 10             	pushl  0x10(%ebp)
  800876:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800879:	50                   	push   %eax
  80087a:	68 86 04 80 00       	push   $0x800486
  80087f:	e8 39 fc ff ff       	call   8004bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800884:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800887:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	eb 0c                	jmp    80089e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800897:	eb 05                	jmp    80089e <vsnprintf+0x53>
  800899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 10             	pushl  0x10(%ebp)
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	ff 75 08             	pushl  0x8(%ebp)
  8008b3:	e8 93 ff ff ff       	call   80084b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    
	...

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8008c5:	74 0e                	je     8008d5 <strlen+0x19>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008cc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f9                	jne    8008cc <strlen+0x10>
  8008d3:	eb 05                	jmp    8008da <strlen+0x1e>
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 17                	je     800900 <strnlen+0x24>
  8008e9:	80 39 00             	cmpb   $0x0,(%ecx)
  8008ec:	74 19                	je     800907 <strnlen+0x2b>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f4:	39 d0                	cmp    %edx,%eax
  8008f6:	74 14                	je     80090c <strnlen+0x30>
  8008f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008fc:	75 f5                	jne    8008f3 <strnlen+0x17>
  8008fe:	eb 0c                	jmp    80090c <strnlen+0x30>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 05                	jmp    80090c <strnlen+0x30>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800918:	ba 00 00 00 00       	mov    $0x0,%edx
  80091d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800920:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800923:	42                   	inc    %edx
  800924:	84 c9                	test   %cl,%cl
  800926:	75 f5                	jne    80091d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800928:	5b                   	pop    %ebx
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800932:	53                   	push   %ebx
  800933:	e8 84 ff ff ff       	call   8008bc <strlen>
  800938:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80093b:	ff 75 0c             	pushl  0xc(%ebp)
  80093e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800941:	50                   	push   %eax
  800942:	e8 c7 ff ff ff       	call   80090e <strcpy>
	return dst;
}
  800947:	89 d8                	mov    %ebx,%eax
  800949:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
  800959:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095c:	85 f6                	test   %esi,%esi
  80095e:	74 15                	je     800975 <strncpy+0x27>
  800960:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800965:	8a 1a                	mov    (%edx),%bl
  800967:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096a:	80 3a 01             	cmpb   $0x1,(%edx)
  80096d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800970:	41                   	inc    %ecx
  800971:	39 ce                	cmp    %ecx,%esi
  800973:	77 f0                	ja     800965 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800985:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800988:	85 f6                	test   %esi,%esi
  80098a:	74 32                	je     8009be <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80098c:	83 fe 01             	cmp    $0x1,%esi
  80098f:	74 22                	je     8009b3 <strlcpy+0x3a>
  800991:	8a 0b                	mov    (%ebx),%cl
  800993:	84 c9                	test   %cl,%cl
  800995:	74 20                	je     8009b7 <strlcpy+0x3e>
  800997:	89 f8                	mov    %edi,%eax
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80099e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a1:	88 08                	mov    %cl,(%eax)
  8009a3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a4:	39 f2                	cmp    %esi,%edx
  8009a6:	74 11                	je     8009b9 <strlcpy+0x40>
  8009a8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009ac:	42                   	inc    %edx
  8009ad:	84 c9                	test   %cl,%cl
  8009af:	75 f0                	jne    8009a1 <strlcpy+0x28>
  8009b1:	eb 06                	jmp    8009b9 <strlcpy+0x40>
  8009b3:	89 f8                	mov    %edi,%eax
  8009b5:	eb 02                	jmp    8009b9 <strlcpy+0x40>
  8009b7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b9:	c6 00 00             	movb   $0x0,(%eax)
  8009bc:	eb 02                	jmp    8009c0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009be:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009c0:	29 f8                	sub    %edi,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d0:	8a 01                	mov    (%ecx),%al
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 10                	je     8009e6 <strcmp+0x1f>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	75 0c                	jne    8009e6 <strcmp+0x1f>
		p++, q++;
  8009da:	41                   	inc    %ecx
  8009db:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	84 c0                	test   %al,%al
  8009e0:	74 04                	je     8009e6 <strcmp+0x1f>
  8009e2:	3a 02                	cmp    (%edx),%al
  8009e4:	74 f4                	je     8009da <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e6:	0f b6 c0             	movzbl %al,%eax
  8009e9:	0f b6 12             	movzbl (%edx),%edx
  8009ec:	29 d0                	sub    %edx,%eax
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	74 1b                	je     800a1c <strncmp+0x2c>
  800a01:	8a 1a                	mov    (%edx),%bl
  800a03:	84 db                	test   %bl,%bl
  800a05:	74 24                	je     800a2b <strncmp+0x3b>
  800a07:	3a 19                	cmp    (%ecx),%bl
  800a09:	75 20                	jne    800a2b <strncmp+0x3b>
  800a0b:	48                   	dec    %eax
  800a0c:	74 15                	je     800a23 <strncmp+0x33>
		n--, p++, q++;
  800a0e:	42                   	inc    %edx
  800a0f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a10:	8a 1a                	mov    (%edx),%bl
  800a12:	84 db                	test   %bl,%bl
  800a14:	74 15                	je     800a2b <strncmp+0x3b>
  800a16:	3a 19                	cmp    (%ecx),%bl
  800a18:	74 f1                	je     800a0b <strncmp+0x1b>
  800a1a:	eb 0f                	jmp    800a2b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	eb 05                	jmp    800a28 <strncmp+0x38>
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a28:	5b                   	pop    %ebx
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2b:	0f b6 02             	movzbl (%edx),%eax
  800a2e:	0f b6 11             	movzbl (%ecx),%edx
  800a31:	29 d0                	sub    %edx,%eax
  800a33:	eb f3                	jmp    800a28 <strncmp+0x38>

00800a35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3e:	8a 10                	mov    (%eax),%dl
  800a40:	84 d2                	test   %dl,%dl
  800a42:	74 18                	je     800a5c <strchr+0x27>
		if (*s == c)
  800a44:	38 ca                	cmp    %cl,%dl
  800a46:	75 06                	jne    800a4e <strchr+0x19>
  800a48:	eb 17                	jmp    800a61 <strchr+0x2c>
  800a4a:	38 ca                	cmp    %cl,%dl
  800a4c:	74 13                	je     800a61 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4e:	40                   	inc    %eax
  800a4f:	8a 10                	mov    (%eax),%dl
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f5                	jne    800a4a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	eb 05                	jmp    800a61 <strchr+0x2c>
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6c:	8a 10                	mov    (%eax),%dl
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	74 11                	je     800a83 <strfind+0x20>
		if (*s == c)
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	75 06                	jne    800a7c <strfind+0x19>
  800a76:	eb 0b                	jmp    800a83 <strfind+0x20>
  800a78:	38 ca                	cmp    %cl,%dl
  800a7a:	74 07                	je     800a83 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7c:	40                   	inc    %eax
  800a7d:	8a 10                	mov    (%eax),%dl
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f5                	jne    800a78 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 30                	je     800ac8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a98:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9e:	75 25                	jne    800ac5 <memset+0x40>
  800aa0:	f6 c1 03             	test   $0x3,%cl
  800aa3:	75 20                	jne    800ac5 <memset+0x40>
		c &= 0xFF;
  800aa5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	c1 e3 08             	shl    $0x8,%ebx
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	c1 e6 18             	shl    $0x18,%esi
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 10             	shl    $0x10,%eax
  800ab7:	09 f0                	or     %esi,%eax
  800ab9:	09 d0                	or     %edx,%eax
  800abb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac0:	fc                   	cld    
  800ac1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac3:	eb 03                	jmp    800ac8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac5:	fc                   	cld    
  800ac6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac8:	89 f8                	mov    %edi,%eax
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800add:	39 c6                	cmp    %eax,%esi
  800adf:	73 34                	jae    800b15 <memmove+0x46>
  800ae1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae4:	39 d0                	cmp    %edx,%eax
  800ae6:	73 2d                	jae    800b15 <memmove+0x46>
		s += n;
		d += n;
  800ae8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aeb:	f6 c2 03             	test   $0x3,%dl
  800aee:	75 1b                	jne    800b0b <memmove+0x3c>
  800af0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af6:	75 13                	jne    800b0b <memmove+0x3c>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 0e                	jne    800b0b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800afd:	83 ef 04             	sub    $0x4,%edi
  800b00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b03:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b06:	fd                   	std    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 07                	jmp    800b12 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0b:	4f                   	dec    %edi
  800b0c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0f:	fd                   	std    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b12:	fc                   	cld    
  800b13:	eb 20                	jmp    800b35 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1b:	75 13                	jne    800b30 <memmove+0x61>
  800b1d:	a8 03                	test   $0x3,%al
  800b1f:	75 0f                	jne    800b30 <memmove+0x61>
  800b21:	f6 c1 03             	test   $0x3,%cl
  800b24:	75 0a                	jne    800b30 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b26:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	fc                   	cld    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 05                	jmp    800b35 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b30:	89 c7                	mov    %eax,%edi
  800b32:	fc                   	cld    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	ff 75 08             	pushl  0x8(%ebp)
  800b45:	e8 85 ff ff ff       	call   800acf <memmove>
}
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	85 ff                	test   %edi,%edi
  800b5d:	74 32                	je     800b91 <memcmp+0x45>
		if (*s1 != *s2)
  800b5f:	8a 03                	mov    (%ebx),%al
  800b61:	8a 0e                	mov    (%esi),%cl
  800b63:	38 c8                	cmp    %cl,%al
  800b65:	74 19                	je     800b80 <memcmp+0x34>
  800b67:	eb 0d                	jmp    800b76 <memcmp+0x2a>
  800b69:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b6d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b71:	42                   	inc    %edx
  800b72:	38 c8                	cmp    %cl,%al
  800b74:	74 10                	je     800b86 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b76:	0f b6 c0             	movzbl %al,%eax
  800b79:	0f b6 c9             	movzbl %cl,%ecx
  800b7c:	29 c8                	sub    %ecx,%eax
  800b7e:	eb 16                	jmp    800b96 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b80:	4f                   	dec    %edi
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	39 fa                	cmp    %edi,%edx
  800b88:	75 df                	jne    800b69 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	eb 05                	jmp    800b96 <memcmp+0x4a>
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba1:	89 c2                	mov    %eax,%edx
  800ba3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba6:	39 d0                	cmp    %edx,%eax
  800ba8:	73 12                	jae    800bbc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800baa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bad:	38 08                	cmp    %cl,(%eax)
  800baf:	75 06                	jne    800bb7 <memfind+0x1c>
  800bb1:	eb 09                	jmp    800bbc <memfind+0x21>
  800bb3:	38 08                	cmp    %cl,(%eax)
  800bb5:	74 05                	je     800bbc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb7:	40                   	inc    %eax
  800bb8:	39 c2                	cmp    %eax,%edx
  800bba:	77 f7                	ja     800bb3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bca:	eb 01                	jmp    800bcd <strtol+0xf>
		s++;
  800bcc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcd:	8a 02                	mov    (%edx),%al
  800bcf:	3c 20                	cmp    $0x20,%al
  800bd1:	74 f9                	je     800bcc <strtol+0xe>
  800bd3:	3c 09                	cmp    $0x9,%al
  800bd5:	74 f5                	je     800bcc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd7:	3c 2b                	cmp    $0x2b,%al
  800bd9:	75 08                	jne    800be3 <strtol+0x25>
		s++;
  800bdb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800be1:	eb 13                	jmp    800bf6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be3:	3c 2d                	cmp    $0x2d,%al
  800be5:	75 0a                	jne    800bf1 <strtol+0x33>
		s++, neg = 1;
  800be7:	8d 52 01             	lea    0x1(%edx),%edx
  800bea:	bf 01 00 00 00       	mov    $0x1,%edi
  800bef:	eb 05                	jmp    800bf6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf6:	85 db                	test   %ebx,%ebx
  800bf8:	74 05                	je     800bff <strtol+0x41>
  800bfa:	83 fb 10             	cmp    $0x10,%ebx
  800bfd:	75 28                	jne    800c27 <strtol+0x69>
  800bff:	8a 02                	mov    (%edx),%al
  800c01:	3c 30                	cmp    $0x30,%al
  800c03:	75 10                	jne    800c15 <strtol+0x57>
  800c05:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c09:	75 0a                	jne    800c15 <strtol+0x57>
		s += 2, base = 16;
  800c0b:	83 c2 02             	add    $0x2,%edx
  800c0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c13:	eb 12                	jmp    800c27 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c15:	85 db                	test   %ebx,%ebx
  800c17:	75 0e                	jne    800c27 <strtol+0x69>
  800c19:	3c 30                	cmp    $0x30,%al
  800c1b:	75 05                	jne    800c22 <strtol+0x64>
		s++, base = 8;
  800c1d:	42                   	inc    %edx
  800c1e:	b3 08                	mov    $0x8,%bl
  800c20:	eb 05                	jmp    800c27 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c27:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c2e:	8a 0a                	mov    (%edx),%cl
  800c30:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c33:	80 fb 09             	cmp    $0x9,%bl
  800c36:	77 08                	ja     800c40 <strtol+0x82>
			dig = *s - '0';
  800c38:	0f be c9             	movsbl %cl,%ecx
  800c3b:	83 e9 30             	sub    $0x30,%ecx
  800c3e:	eb 1e                	jmp    800c5e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c40:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 08                	ja     800c50 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c48:	0f be c9             	movsbl %cl,%ecx
  800c4b:	83 e9 57             	sub    $0x57,%ecx
  800c4e:	eb 0e                	jmp    800c5e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c50:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 13                	ja     800c6b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c58:	0f be c9             	movsbl %cl,%ecx
  800c5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5e:	39 f1                	cmp    %esi,%ecx
  800c60:	7d 0d                	jge    800c6f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c62:	42                   	inc    %edx
  800c63:	0f af c6             	imul   %esi,%eax
  800c66:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c69:	eb c3                	jmp    800c2e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c6b:	89 c1                	mov    %eax,%ecx
  800c6d:	eb 02                	jmp    800c71 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c6f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c75:	74 05                	je     800c7c <strtol+0xbe>
		*endptr = (char *) s;
  800c77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c7c:	85 ff                	test   %edi,%edi
  800c7e:	74 04                	je     800c84 <strtol+0xc6>
  800c80:	89 c8                	mov    %ecx,%eax
  800c82:	f7 d8                	neg    %eax
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    
  800c89:	00 00                	add    %al,(%eax)
	...

00800c8c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 1c             	sub    $0x1c,%esp
  800c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c9b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	8b 75 14             	mov    0x14(%ebp),%esi
  800ca0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca9:	cd 30                	int    $0x30
  800cab:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cb1:	74 1c                	je     800ccf <syscall+0x43>
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 18                	jle    800ccf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cbe:	68 3f 27 80 00       	push   $0x80273f
  800cc3:	6a 42                	push   $0x42
  800cc5:	68 5c 27 80 00       	push   $0x80275c
  800cca:	e8 b1 f5 ff ff       	call   800280 <_panic>

	return ret;
}
  800ccf:	89 d0                	mov    %edx,%eax
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	6a 00                	push   $0x0
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf5:	e8 92 ff ff ff       	call   800c8c <syscall>
  800cfa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <sys_cgetc>:

int
sys_cgetc(void)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	6a 00                	push   $0x0
  800d0b:	6a 00                	push   $0x0
  800d0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d12:	ba 00 00 00 00       	mov    $0x0,%edx
  800d17:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1c:	e8 6b ff ff ff       	call   800c8c <syscall>
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d34:	ba 01 00 00 00       	mov    $0x1,%edx
  800d39:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3e:	e8 49 ff ff ff       	call   800c8c <syscall>
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d4b:	6a 00                	push   $0x0
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	6a 00                	push   $0x0
  800d53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d62:	e8 25 ff ff ff       	call   800c8c <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_yield>:

void
sys_yield(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d86:	e8 01 ff ff ff       	call   800c8c <syscall>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d96:	6a 00                	push   $0x0
  800d98:	6a 00                	push   $0x0
  800d9a:	ff 75 10             	pushl  0x10(%ebp)
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	ba 01 00 00 00       	mov    $0x1,%edx
  800da8:	b8 04 00 00 00       	mov    $0x4,%eax
  800dad:	e8 da fe ff ff       	call   800c8c <syscall>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800dba:	ff 75 18             	pushl  0x18(%ebp)
  800dbd:	ff 75 14             	pushl  0x14(%ebp)
  800dc0:	ff 75 10             	pushl  0x10(%ebp)
  800dc3:	ff 75 0c             	pushl  0xc(%ebp)
  800dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dce:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd3:	e8 b4 fe ff ff       	call   800c8c <syscall>
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800de0:	6a 00                	push   $0x0
  800de2:	6a 00                	push   $0x0
  800de4:	6a 00                	push   $0x0
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dec:	ba 01 00 00 00       	mov    $0x1,%edx
  800df1:	b8 06 00 00 00       	mov    $0x6,%eax
  800df6:	e8 91 fe ff ff       	call   800c8c <syscall>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	ff 75 0c             	pushl  0xc(%ebp)
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800e14:	b8 08 00 00 00       	mov    $0x8,%eax
  800e19:	e8 6e fe ff ff       	call   800c8c <syscall>
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e26:	6a 00                	push   $0x0
  800e28:	6a 00                	push   $0x0
  800e2a:	6a 00                	push   $0x0
  800e2c:	ff 75 0c             	pushl  0xc(%ebp)
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	ba 01 00 00 00       	mov    $0x1,%edx
  800e37:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3c:	e8 4b fe ff ff       	call   800c8c <syscall>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e49:	6a 00                	push   $0x0
  800e4b:	6a 00                	push   $0x0
  800e4d:	6a 00                	push   $0x0
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5f:	e8 28 fe ff ff       	call   800c8c <syscall>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e6c:	6a 00                	push   $0x0
  800e6e:	ff 75 14             	pushl  0x14(%ebp)
  800e71:	ff 75 10             	pushl  0x10(%ebp)
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e84:	e8 03 fe ff ff       	call   800c8c <syscall>
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e91:	6a 00                	push   $0x0
  800e93:	6a 00                	push   $0x0
  800e95:	6a 00                	push   $0x0
  800e97:	6a 00                	push   $0x0
  800e99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ea1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea6:	e8 e1 fd ff ff       	call   800c8c <syscall>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800eb3:	6a 00                	push   $0x0
  800eb5:	6a 00                	push   $0x0
  800eb7:	6a 00                	push   $0x0
  800eb9:	ff 75 0c             	pushl  0xc(%ebp)
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec9:	e8 be fd ff ff       	call   800c8c <syscall>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800ed6:	6a 00                	push   $0x0
  800ed8:	ff 75 14             	pushl  0x14(%ebp)
  800edb:	ff 75 10             	pushl  0x10(%ebp)
  800ede:	ff 75 0c             	pushl  0xc(%ebp)
  800ee1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eee:	e8 99 fd ff ff       	call   800c8c <syscall>
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
  800ef5:	00 00                	add    %al,(%eax)
	...

00800ef8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f02:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800f04:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f08:	75 14                	jne    800f1e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 6c 27 80 00       	push   $0x80276c
  800f12:	6a 20                	push   $0x20
  800f14:	68 b0 28 80 00       	push   $0x8028b0
  800f19:	e8 62 f3 ff ff       	call   800280 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f1e:	89 d8                	mov    %ebx,%eax
  800f20:	c1 e8 16             	shr    $0x16,%eax
  800f23:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2a:	a8 01                	test   $0x1,%al
  800f2c:	74 11                	je     800f3f <pgfault+0x47>
  800f2e:	89 d8                	mov    %ebx,%eax
  800f30:	c1 e8 0c             	shr    $0xc,%eax
  800f33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3a:	f6 c4 08             	test   $0x8,%ah
  800f3d:	75 14                	jne    800f53 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 90 27 80 00       	push   $0x802790
  800f47:	6a 24                	push   $0x24
  800f49:	68 b0 28 80 00       	push   $0x8028b0
  800f4e:	e8 2d f3 ff ff       	call   800280 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	6a 07                	push   $0x7
  800f58:	68 00 f0 7f 00       	push   $0x7ff000
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 2c fe ff ff       	call   800d90 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 12                	jns    800f7d <pgfault+0x85>
  800f6b:	50                   	push   %eax
  800f6c:	68 b4 27 80 00       	push   $0x8027b4
  800f71:	6a 32                	push   $0x32
  800f73:	68 b0 28 80 00       	push   $0x8028b0
  800f78:	e8 03 f3 ff ff       	call   800280 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f7d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	68 00 10 00 00       	push   $0x1000
  800f8b:	53                   	push   %ebx
  800f8c:	68 00 f0 7f 00       	push   $0x7ff000
  800f91:	e8 a3 fb ff ff       	call   800b39 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f96:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f9d:	53                   	push   %ebx
  800f9e:	6a 00                	push   $0x0
  800fa0:	68 00 f0 7f 00       	push   $0x7ff000
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 08 fe ff ff       	call   800db4 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 12                	jns    800fc5 <pgfault+0xcd>
  800fb3:	50                   	push   %eax
  800fb4:	68 d8 27 80 00       	push   $0x8027d8
  800fb9:	6a 3a                	push   $0x3a
  800fbb:	68 b0 28 80 00       	push   $0x8028b0
  800fc0:	e8 bb f2 ff ff       	call   800280 <_panic>

	return;
}
  800fc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fd3:	68 f8 0e 80 00       	push   $0x800ef8
  800fd8:	e8 57 10 00 00       	call   802034 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fdd:	ba 07 00 00 00       	mov    $0x7,%edx
  800fe2:	89 d0                	mov    %edx,%eax
  800fe4:	cd 30                	int    $0x30
  800fe6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe9:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 12                	jns    801004 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800ff2:	50                   	push   %eax
  800ff3:	68 bb 28 80 00       	push   $0x8028bb
  800ff8:	6a 7f                	push   $0x7f
  800ffa:	68 b0 28 80 00       	push   $0x8028b0
  800fff:	e8 7c f2 ff ff       	call   800280 <_panic>
	}
	int r;

	if (childpid == 0) {
  801004:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801008:	75 25                	jne    80102f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  80100a:	e8 36 fd ff ff       	call   800d45 <sys_getenvid>
  80100f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801014:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80101b:	c1 e0 07             	shl    $0x7,%eax
  80101e:	29 d0                	sub    %edx,%eax
  801020:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801025:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  80102a:	e9 be 01 00 00       	jmp    8011ed <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  801034:	89 d8                	mov    %ebx,%eax
  801036:	c1 e8 16             	shr    $0x16,%eax
  801039:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801040:	a8 01                	test   $0x1,%al
  801042:	0f 84 10 01 00 00    	je     801158 <fork+0x18e>
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	c1 e8 0c             	shr    $0xc,%eax
  80104d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801054:	f6 c2 01             	test   $0x1,%dl
  801057:	0f 84 fb 00 00 00    	je     801158 <fork+0x18e>
  80105d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801064:	f6 c2 04             	test   $0x4,%dl
  801067:	0f 84 eb 00 00 00    	je     801158 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80106d:	89 c6                	mov    %eax,%esi
  80106f:	c1 e6 0c             	shl    $0xc,%esi
  801072:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801078:	0f 84 da 00 00 00    	je     801158 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  80107e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801085:	f6 c6 04             	test   $0x4,%dh
  801088:	74 37                	je     8010c1 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80108a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	25 07 0e 00 00       	and    $0xe07,%eax
  801099:	50                   	push   %eax
  80109a:	56                   	push   %esi
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	6a 00                	push   $0x0
  80109f:	e8 10 fd ff ff       	call   800db4 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	0f 89 a9 00 00 00    	jns    801158 <fork+0x18e>
  8010af:	50                   	push   %eax
  8010b0:	68 fc 27 80 00       	push   $0x8027fc
  8010b5:	6a 54                	push   $0x54
  8010b7:	68 b0 28 80 00       	push   $0x8028b0
  8010bc:	e8 bf f1 ff ff       	call   800280 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c8:	f6 c2 02             	test   $0x2,%dl
  8010cb:	75 0c                	jne    8010d9 <fork+0x10f>
  8010cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d4:	f6 c4 08             	test   $0x8,%ah
  8010d7:	74 57                	je     801130 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	68 05 08 00 00       	push   $0x805
  8010e1:	56                   	push   %esi
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	6a 00                	push   $0x0
  8010e6:	e8 c9 fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010eb:	83 c4 20             	add    $0x20,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	79 12                	jns    801104 <fork+0x13a>
  8010f2:	50                   	push   %eax
  8010f3:	68 fc 27 80 00       	push   $0x8027fc
  8010f8:	6a 59                	push   $0x59
  8010fa:	68 b0 28 80 00       	push   $0x8028b0
  8010ff:	e8 7c f1 ff ff       	call   800280 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	68 05 08 00 00       	push   $0x805
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	e8 9d fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801117:	83 c4 20             	add    $0x20,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 3a                	jns    801158 <fork+0x18e>
  80111e:	50                   	push   %eax
  80111f:	68 fc 27 80 00       	push   $0x8027fc
  801124:	6a 5c                	push   $0x5c
  801126:	68 b0 28 80 00       	push   $0x8028b0
  80112b:	e8 50 f1 ff ff       	call   800280 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	6a 05                	push   $0x5
  801135:	56                   	push   %esi
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	6a 00                	push   $0x0
  80113a:	e8 75 fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80113f:	83 c4 20             	add    $0x20,%esp
  801142:	85 c0                	test   %eax,%eax
  801144:	79 12                	jns    801158 <fork+0x18e>
  801146:	50                   	push   %eax
  801147:	68 fc 27 80 00       	push   $0x8027fc
  80114c:	6a 60                	push   $0x60
  80114e:	68 b0 28 80 00       	push   $0x8028b0
  801153:	e8 28 f1 ff ff       	call   800280 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801158:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80115e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801164:	0f 85 ca fe ff ff    	jne    801034 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	6a 07                	push   $0x7
  80116f:	68 00 f0 bf ee       	push   $0xeebff000
  801174:	ff 75 e4             	pushl  -0x1c(%ebp)
  801177:	e8 14 fc ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 15                	jns    801198 <fork+0x1ce>
  801183:	50                   	push   %eax
  801184:	68 20 28 80 00       	push   $0x802820
  801189:	68 94 00 00 00       	push   $0x94
  80118e:	68 b0 28 80 00       	push   $0x8028b0
  801193:	e8 e8 f0 ff ff       	call   800280 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	68 a0 20 80 00       	push   $0x8020a0
  8011a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a3:	e8 9b fc ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 15                	jns    8011c4 <fork+0x1fa>
  8011af:	50                   	push   %eax
  8011b0:	68 58 28 80 00       	push   $0x802858
  8011b5:	68 99 00 00 00       	push   $0x99
  8011ba:	68 b0 28 80 00       	push   $0x8028b0
  8011bf:	e8 bc f0 ff ff       	call   800280 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	6a 02                	push   $0x2
  8011c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cc:	e8 2c fc ff ff       	call   800dfd <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	79 15                	jns    8011ed <fork+0x223>
  8011d8:	50                   	push   %eax
  8011d9:	68 7c 28 80 00       	push   $0x80287c
  8011de:	68 a4 00 00 00       	push   $0xa4
  8011e3:	68 b0 28 80 00       	push   $0x8028b0
  8011e8:	e8 93 f0 ff ff       	call   800280 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8011ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <sfork>:

// Challenge!
int
sfork(void)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011fe:	68 d8 28 80 00       	push   $0x8028d8
  801203:	68 b1 00 00 00       	push   $0xb1
  801208:	68 b0 28 80 00       	push   $0x8028b0
  80120d:	e8 6e f0 ff ff       	call   800280 <_panic>
	...

00801214 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	8b 75 08             	mov    0x8(%ebp),%esi
  80121c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801222:	85 c0                	test   %eax,%eax
  801224:	74 0e                	je     801234 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	50                   	push   %eax
  80122a:	e8 5c fc ff ff       	call   800e8b <sys_ipc_recv>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 10                	jmp    801244 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	68 00 00 c0 ee       	push   $0xeec00000
  80123c:	e8 4a fc ff ff       	call   800e8b <sys_ipc_recv>
  801241:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801244:	85 c0                	test   %eax,%eax
  801246:	75 26                	jne    80126e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801248:	85 f6                	test   %esi,%esi
  80124a:	74 0a                	je     801256 <ipc_recv+0x42>
  80124c:	a1 04 40 80 00       	mov    0x804004,%eax
  801251:	8b 40 74             	mov    0x74(%eax),%eax
  801254:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801256:	85 db                	test   %ebx,%ebx
  801258:	74 0a                	je     801264 <ipc_recv+0x50>
  80125a:	a1 04 40 80 00       	mov    0x804004,%eax
  80125f:	8b 40 78             	mov    0x78(%eax),%eax
  801262:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801264:	a1 04 40 80 00       	mov    0x804004,%eax
  801269:	8b 40 70             	mov    0x70(%eax),%eax
  80126c:	eb 14                	jmp    801282 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80126e:	85 f6                	test   %esi,%esi
  801270:	74 06                	je     801278 <ipc_recv+0x64>
  801272:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801278:	85 db                	test   %ebx,%ebx
  80127a:	74 06                	je     801282 <ipc_recv+0x6e>
  80127c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801282:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801295:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801298:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80129b:	85 db                	test   %ebx,%ebx
  80129d:	75 25                	jne    8012c4 <ipc_send+0x3b>
  80129f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8012a4:	eb 1e                	jmp    8012c4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8012a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012a9:	75 07                	jne    8012b2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8012ab:	e8 b9 fa ff ff       	call   800d69 <sys_yield>
  8012b0:	eb 12                	jmp    8012c4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8012b2:	50                   	push   %eax
  8012b3:	68 ee 28 80 00       	push   $0x8028ee
  8012b8:	6a 43                	push   $0x43
  8012ba:	68 01 29 80 00       	push   $0x802901
  8012bf:	e8 bc ef ff ff       	call   800280 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	57                   	push   %edi
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 97 fb ff ff       	call   800e66 <sys_ipc_try_send>
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	75 d0                	jne    8012a6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8012d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8012e5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8012eb:	74 22                	je     80130f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012ed:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8012f2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 e2 07             	shl    $0x7,%edx
  8012fe:	29 ca                	sub    %ecx,%edx
  801300:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801306:	8b 52 50             	mov    0x50(%edx),%edx
  801309:	39 da                	cmp    %ebx,%edx
  80130b:	75 1d                	jne    80132a <ipc_find_env+0x4c>
  80130d:	eb 05                	jmp    801314 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80131b:	c1 e0 07             	shl    $0x7,%eax
  80131e:	29 d0                	sub    %edx,%eax
  801320:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801325:	8b 40 40             	mov    0x40(%eax),%eax
  801328:	eb 0c                	jmp    801336 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80132a:	40                   	inc    %eax
  80132b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801330:	75 c0                	jne    8012f2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801332:	66 b8 00 00          	mov    $0x0,%ax
}
  801336:	5b                   	pop    %ebx
  801337:	c9                   	leave  
  801338:	c3                   	ret    
  801339:	00 00                	add    %al,(%eax)
	...

0080133c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
  801342:	05 00 00 00 30       	add    $0x30000000,%eax
  801347:	c1 e8 0c             	shr    $0xc,%eax
}
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80134f:	ff 75 08             	pushl  0x8(%ebp)
  801352:	e8 e5 ff ff ff       	call   80133c <fd2num>
  801357:	83 c4 04             	add    $0x4,%esp
  80135a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80135f:	c1 e0 0c             	shl    $0xc,%eax
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801370:	a8 01                	test   $0x1,%al
  801372:	74 34                	je     8013a8 <fd_alloc+0x44>
  801374:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801379:	a8 01                	test   $0x1,%al
  80137b:	74 32                	je     8013af <fd_alloc+0x4b>
  80137d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801382:	89 c1                	mov    %eax,%ecx
  801384:	89 c2                	mov    %eax,%edx
  801386:	c1 ea 16             	shr    $0x16,%edx
  801389:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801390:	f6 c2 01             	test   $0x1,%dl
  801393:	74 1f                	je     8013b4 <fd_alloc+0x50>
  801395:	89 c2                	mov    %eax,%edx
  801397:	c1 ea 0c             	shr    $0xc,%edx
  80139a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a1:	f6 c2 01             	test   $0x1,%dl
  8013a4:	75 17                	jne    8013bd <fd_alloc+0x59>
  8013a6:	eb 0c                	jmp    8013b4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013a8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8013ad:	eb 05                	jmp    8013b4 <fd_alloc+0x50>
  8013af:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8013b4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	eb 17                	jmp    8013d4 <fd_alloc+0x70>
  8013bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c7:	75 b9                	jne    801382 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d4:	5b                   	pop    %ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013dd:	83 f8 1f             	cmp    $0x1f,%eax
  8013e0:	77 36                	ja     801418 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013e7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 16             	shr    $0x16,%edx
  8013ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 24                	je     80141f <fd_lookup+0x48>
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	c1 ea 0c             	shr    $0xc,%edx
  801400:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801407:	f6 c2 01             	test   $0x1,%dl
  80140a:	74 1a                	je     801426 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140f:	89 02                	mov    %eax,(%edx)
	return 0;
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
  801416:	eb 13                	jmp    80142b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801418:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141d:	eb 0c                	jmp    80142b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801424:	eb 05                	jmp    80142b <fd_lookup+0x54>
  801426:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80143a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801440:	74 0d                	je     80144f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
  801447:	eb 14                	jmp    80145d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801449:	39 0a                	cmp    %ecx,(%edx)
  80144b:	75 10                	jne    80145d <dev_lookup+0x30>
  80144d:	eb 05                	jmp    801454 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80144f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801454:	89 13                	mov    %edx,(%ebx)
			return 0;
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
  80145b:	eb 31                	jmp    80148e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80145d:	40                   	inc    %eax
  80145e:	8b 14 85 88 29 80 00 	mov    0x802988(,%eax,4),%edx
  801465:	85 d2                	test   %edx,%edx
  801467:	75 e0                	jne    801449 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801469:	a1 04 40 80 00       	mov    0x804004,%eax
  80146e:	8b 40 48             	mov    0x48(%eax),%eax
  801471:	83 ec 04             	sub    $0x4,%esp
  801474:	51                   	push   %ecx
  801475:	50                   	push   %eax
  801476:	68 0c 29 80 00       	push   $0x80290c
  80147b:	e8 d8 ee ff ff       	call   800358 <cprintf>
	*dev = 0;
  801480:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80148e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	56                   	push   %esi
  801497:	53                   	push   %ebx
  801498:	83 ec 20             	sub    $0x20,%esp
  80149b:	8b 75 08             	mov    0x8(%ebp),%esi
  80149e:	8a 45 0c             	mov    0xc(%ebp),%al
  8014a1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a4:	56                   	push   %esi
  8014a5:	e8 92 fe ff ff       	call   80133c <fd2num>
  8014aa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014ad:	89 14 24             	mov    %edx,(%esp)
  8014b0:	50                   	push   %eax
  8014b1:	e8 21 ff ff ff       	call   8013d7 <fd_lookup>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 05                	js     8014c4 <fd_close+0x31>
	    || fd != fd2)
  8014bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c2:	74 0d                	je     8014d1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8014c4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014c8:	75 48                	jne    801512 <fd_close+0x7f>
  8014ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014cf:	eb 41                	jmp    801512 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	ff 36                	pushl  (%esi)
  8014da:	e8 4e ff ff ff       	call   80142d <dev_lookup>
  8014df:	89 c3                	mov    %eax,%ebx
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 1c                	js     801504 <fd_close+0x71>
		if (dev->dev_close)
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	8b 40 10             	mov    0x10(%eax),%eax
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 0d                	je     8014ff <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	56                   	push   %esi
  8014f6:	ff d0                	call   *%eax
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	eb 05                	jmp    801504 <fd_close+0x71>
		else
			r = 0;
  8014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	56                   	push   %esi
  801508:	6a 00                	push   $0x0
  80150a:	e8 cb f8 ff ff       	call   800dda <sys_page_unmap>
	return r;
  80150f:	83 c4 10             	add    $0x10,%esp
}
  801512:	89 d8                	mov    %ebx,%eax
  801514:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801521:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 aa fe ff ff       	call   8013d7 <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 10                	js     801544 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	6a 01                	push   $0x1
  801539:	ff 75 f4             	pushl  -0xc(%ebp)
  80153c:	e8 52 ff ff ff       	call   801493 <fd_close>
  801541:	83 c4 10             	add    $0x10,%esp
}
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <close_all>:

void
close_all(void)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80154d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	53                   	push   %ebx
  801556:	e8 c0 ff ff ff       	call   80151b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155b:	43                   	inc    %ebx
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	83 fb 20             	cmp    $0x20,%ebx
  801562:	75 ee                	jne    801552 <close_all+0xc>
		close(i);
}
  801564:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 2c             	sub    $0x2c,%esp
  801572:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801575:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	ff 75 08             	pushl  0x8(%ebp)
  80157c:	e8 56 fe ff ff       	call   8013d7 <fd_lookup>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	83 c4 08             	add    $0x8,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	0f 88 c0 00 00 00    	js     80164e <dup+0xe5>
		return r;
	close(newfdnum);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	57                   	push   %edi
  801592:	e8 84 ff ff ff       	call   80151b <close>

	newfd = INDEX2FD(newfdnum);
  801597:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80159d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015a0:	83 c4 04             	add    $0x4,%esp
  8015a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a6:	e8 a1 fd ff ff       	call   80134c <fd2data>
  8015ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ad:	89 34 24             	mov    %esi,(%esp)
  8015b0:	e8 97 fd ff ff       	call   80134c <fd2data>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	c1 e8 16             	shr    $0x16,%eax
  8015c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c7:	a8 01                	test   $0x1,%al
  8015c9:	74 37                	je     801602 <dup+0x99>
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	c1 e8 0c             	shr    $0xc,%eax
  8015d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d7:	f6 c2 01             	test   $0x1,%dl
  8015da:	74 26                	je     801602 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015eb:	50                   	push   %eax
  8015ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ef:	6a 00                	push   $0x0
  8015f1:	53                   	push   %ebx
  8015f2:	6a 00                	push   $0x0
  8015f4:	e8 bb f7 ff ff       	call   800db4 <sys_page_map>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	83 c4 20             	add    $0x20,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 2d                	js     80162f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801605:	89 c2                	mov    %eax,%edx
  801607:	c1 ea 0c             	shr    $0xc,%edx
  80160a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80161a:	52                   	push   %edx
  80161b:	56                   	push   %esi
  80161c:	6a 00                	push   $0x0
  80161e:	50                   	push   %eax
  80161f:	6a 00                	push   $0x0
  801621:	e8 8e f7 ff ff       	call   800db4 <sys_page_map>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 20             	add    $0x20,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	79 1d                	jns    80164c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	56                   	push   %esi
  801633:	6a 00                	push   $0x0
  801635:	e8 a0 f7 ff ff       	call   800dda <sys_page_unmap>
	sys_page_unmap(0, nva);
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801640:	6a 00                	push   $0x0
  801642:	e8 93 f7 ff ff       	call   800dda <sys_page_unmap>
	return r;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 02                	jmp    80164e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80164c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5f                   	pop    %edi
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	53                   	push   %ebx
  80165c:	83 ec 14             	sub    $0x14,%esp
  80165f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801662:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	53                   	push   %ebx
  801667:	e8 6b fd ff ff       	call   8013d7 <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 67                	js     8016da <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	ff 30                	pushl  (%eax)
  80167f:	e8 a9 fd ff ff       	call   80142d <dev_lookup>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 4f                	js     8016da <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168e:	8b 50 08             	mov    0x8(%eax),%edx
  801691:	83 e2 03             	and    $0x3,%edx
  801694:	83 fa 01             	cmp    $0x1,%edx
  801697:	75 21                	jne    8016ba <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801699:	a1 04 40 80 00       	mov    0x804004,%eax
  80169e:	8b 40 48             	mov    0x48(%eax),%eax
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	50                   	push   %eax
  8016a6:	68 4d 29 80 00       	push   $0x80294d
  8016ab:	e8 a8 ec ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b8:	eb 20                	jmp    8016da <read+0x82>
	}
	if (!dev->dev_read)
  8016ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bd:	8b 52 08             	mov    0x8(%edx),%edx
  8016c0:	85 d2                	test   %edx,%edx
  8016c2:	74 11                	je     8016d5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	ff 75 10             	pushl  0x10(%ebp)
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	50                   	push   %eax
  8016ce:	ff d2                	call   *%edx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	eb 05                	jmp    8016da <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	57                   	push   %edi
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ee:	85 f6                	test   %esi,%esi
  8016f0:	74 31                	je     801723 <readn+0x44>
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	89 f2                	mov    %esi,%edx
  801701:	29 c2                	sub    %eax,%edx
  801703:	52                   	push   %edx
  801704:	03 45 0c             	add    0xc(%ebp),%eax
  801707:	50                   	push   %eax
  801708:	57                   	push   %edi
  801709:	e8 4a ff ff ff       	call   801658 <read>
		if (m < 0)
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 17                	js     80172c <readn+0x4d>
			return m;
		if (m == 0)
  801715:	85 c0                	test   %eax,%eax
  801717:	74 11                	je     80172a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801719:	01 c3                	add    %eax,%ebx
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	39 f3                	cmp    %esi,%ebx
  80171f:	72 db                	jb     8016fc <readn+0x1d>
  801721:	eb 09                	jmp    80172c <readn+0x4d>
  801723:	b8 00 00 00 00       	mov    $0x0,%eax
  801728:	eb 02                	jmp    80172c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80172a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80172c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5f                   	pop    %edi
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	53                   	push   %ebx
  801743:	e8 8f fc ff ff       	call   8013d7 <fd_lookup>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 62                	js     8017b1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	ff 30                	pushl  (%eax)
  80175b:	e8 cd fc ff ff       	call   80142d <dev_lookup>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 4a                	js     8017b1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176e:	75 21                	jne    801791 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801770:	a1 04 40 80 00       	mov    0x804004,%eax
  801775:	8b 40 48             	mov    0x48(%eax),%eax
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	53                   	push   %ebx
  80177c:	50                   	push   %eax
  80177d:	68 69 29 80 00       	push   $0x802969
  801782:	e8 d1 eb ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178f:	eb 20                	jmp    8017b1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801791:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801794:	8b 52 0c             	mov    0xc(%edx),%edx
  801797:	85 d2                	test   %edx,%edx
  801799:	74 11                	je     8017ac <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	50                   	push   %eax
  8017a5:	ff d2                	call   *%edx
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	eb 05                	jmp    8017b1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	ff 75 08             	pushl  0x8(%ebp)
  8017c3:	e8 0f fc ff ff       	call   8013d7 <fd_lookup>
  8017c8:	83 c4 08             	add    $0x8,%esp
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 0e                	js     8017dd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 14             	sub    $0x14,%esp
  8017e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ec:	50                   	push   %eax
  8017ed:	53                   	push   %ebx
  8017ee:	e8 e4 fb ff ff       	call   8013d7 <fd_lookup>
  8017f3:	83 c4 08             	add    $0x8,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 5f                	js     801859 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	ff 30                	pushl  (%eax)
  801806:	e8 22 fc ff ff       	call   80142d <dev_lookup>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 47                	js     801859 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801819:	75 21                	jne    80183c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80181b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801820:	8b 40 48             	mov    0x48(%eax),%eax
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	53                   	push   %ebx
  801827:	50                   	push   %eax
  801828:	68 2c 29 80 00       	push   $0x80292c
  80182d:	e8 26 eb ff ff       	call   800358 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183a:	eb 1d                	jmp    801859 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	8b 52 18             	mov    0x18(%edx),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	74 0e                	je     801854 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	ff d2                	call   *%edx
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	eb 05                	jmp    801859 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 14             	sub    $0x14,%esp
  801865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	pushl  0x8(%ebp)
  80186f:	e8 63 fb ff ff       	call   8013d7 <fd_lookup>
  801874:	83 c4 08             	add    $0x8,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 52                	js     8018cd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801885:	ff 30                	pushl  (%eax)
  801887:	e8 a1 fb ff ff       	call   80142d <dev_lookup>
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 3a                	js     8018cd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801896:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80189a:	74 2c                	je     8018c8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80189c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80189f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a6:	00 00 00 
	stat->st_isdir = 0;
  8018a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b0:	00 00 00 
	stat->st_dev = dev;
  8018b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c0:	ff 50 14             	call   *0x14(%eax)
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	eb 05                	jmp    8018cd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	6a 00                	push   $0x0
  8018dc:	ff 75 08             	pushl  0x8(%ebp)
  8018df:	e8 78 01 00 00       	call   801a5c <open>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 1b                	js     801908 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	50                   	push   %eax
  8018f4:	e8 65 ff ff ff       	call   80185e <fstat>
  8018f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8018fb:	89 1c 24             	mov    %ebx,(%esp)
  8018fe:	e8 18 fc ff ff       	call   80151b <close>
	return r;
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	89 f3                	mov    %esi,%ebx
}
  801908:	89 d8                	mov    %ebx,%eax
  80190a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5e                   	pop    %esi
  80190f:	c9                   	leave  
  801910:	c3                   	ret    
  801911:	00 00                	add    %al,(%eax)
	...

00801914 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80191d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801924:	75 12                	jne    801938 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	6a 01                	push   $0x1
  80192b:	e8 ae f9 ff ff       	call   8012de <ipc_find_env>
  801930:	a3 00 40 80 00       	mov    %eax,0x804000
  801935:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801938:	6a 07                	push   $0x7
  80193a:	68 00 50 80 00       	push   $0x805000
  80193f:	53                   	push   %ebx
  801940:	ff 35 00 40 80 00    	pushl  0x804000
  801946:	e8 3e f9 ff ff       	call   801289 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80194b:	83 c4 0c             	add    $0xc,%esp
  80194e:	6a 00                	push   $0x0
  801950:	56                   	push   %esi
  801951:	6a 00                	push   $0x0
  801953:	e8 bc f8 ff ff       	call   801214 <ipc_recv>
}
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 40 0c             	mov    0xc(%eax),%eax
  80196f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 05 00 00 00       	mov    $0x5,%eax
  80197e:	e8 91 ff ff ff       	call   801914 <fsipc>
  801983:	85 c0                	test   %eax,%eax
  801985:	78 2c                	js     8019b3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	68 00 50 80 00       	push   $0x805000
  80198f:	53                   	push   %ebx
  801990:	e8 79 ef ff ff       	call   80090e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801995:	a1 80 50 80 00       	mov    0x805080,%eax
  80199a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d3:	e8 3c ff ff ff       	call   801914 <fsipc>
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
  8019df:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019ed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8019fd:	e8 12 ff ff ff       	call   801914 <fsipc>
  801a02:	89 c3                	mov    %eax,%ebx
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 4b                	js     801a53 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a08:	39 c6                	cmp    %eax,%esi
  801a0a:	73 16                	jae    801a22 <devfile_read+0x48>
  801a0c:	68 98 29 80 00       	push   $0x802998
  801a11:	68 9f 29 80 00       	push   $0x80299f
  801a16:	6a 7d                	push   $0x7d
  801a18:	68 b4 29 80 00       	push   $0x8029b4
  801a1d:	e8 5e e8 ff ff       	call   800280 <_panic>
	assert(r <= PGSIZE);
  801a22:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a27:	7e 16                	jle    801a3f <devfile_read+0x65>
  801a29:	68 bf 29 80 00       	push   $0x8029bf
  801a2e:	68 9f 29 80 00       	push   $0x80299f
  801a33:	6a 7e                	push   $0x7e
  801a35:	68 b4 29 80 00       	push   $0x8029b4
  801a3a:	e8 41 e8 ff ff       	call   800280 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	50                   	push   %eax
  801a43:	68 00 50 80 00       	push   $0x805000
  801a48:	ff 75 0c             	pushl  0xc(%ebp)
  801a4b:	e8 7f f0 ff ff       	call   800acf <memmove>
	return r;
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	89 d8                	mov    %ebx,%eax
  801a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 1c             	sub    $0x1c,%esp
  801a64:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a67:	56                   	push   %esi
  801a68:	e8 4f ee ff ff       	call   8008bc <strlen>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a75:	7f 65                	jg     801adc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	e8 e1 f8 ff ff       	call   801364 <fd_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 55                	js     801ae1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	56                   	push   %esi
  801a90:	68 00 50 80 00       	push   $0x805000
  801a95:	e8 74 ee ff ff       	call   80090e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa5:	b8 01 00 00 00       	mov    $0x1,%eax
  801aaa:	e8 65 fe ff ff       	call   801914 <fsipc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	79 12                	jns    801aca <open+0x6e>
		fd_close(fd, 0);
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	6a 00                	push   $0x0
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	e8 ce f9 ff ff       	call   801493 <fd_close>
		return r;
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	eb 17                	jmp    801ae1 <open+0x85>
	}

	return fd2num(fd);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad0:	e8 67 f8 ff ff       	call   80133c <fd2num>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	eb 05                	jmp    801ae1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801adc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae1:	89 d8                	mov    %ebx,%eax
  801ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    
	...

00801aec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	c1 ea 16             	shr    $0x16,%edx
  801af7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801afe:	f6 c2 01             	test   $0x1,%dl
  801b01:	74 1e                	je     801b21 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b03:	c1 e8 0c             	shr    $0xc,%eax
  801b06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b0d:	a8 01                	test   $0x1,%al
  801b0f:	74 17                	je     801b28 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b11:	c1 e8 0c             	shr    $0xc,%eax
  801b14:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b1b:	ef 
  801b1c:	0f b7 c0             	movzwl %ax,%eax
  801b1f:	eb 0c                	jmp    801b2d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b21:	b8 00 00 00 00       	mov    $0x0,%eax
  801b26:	eb 05                	jmp    801b2d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    
	...

00801b30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	ff 75 08             	pushl  0x8(%ebp)
  801b3e:	e8 09 f8 ff ff       	call   80134c <fd2data>
  801b43:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b45:	83 c4 08             	add    $0x8,%esp
  801b48:	68 cb 29 80 00       	push   $0x8029cb
  801b4d:	56                   	push   %esi
  801b4e:	e8 bb ed ff ff       	call   80090e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b53:	8b 43 04             	mov    0x4(%ebx),%eax
  801b56:	2b 03                	sub    (%ebx),%eax
  801b58:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b5e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b65:	00 00 00 
	stat->st_dev = &devpipe;
  801b68:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b6f:	30 80 00 
	return 0;
}
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
  801b77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	53                   	push   %ebx
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b88:	53                   	push   %ebx
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 4a f2 ff ff       	call   800dda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b90:	89 1c 24             	mov    %ebx,(%esp)
  801b93:	e8 b4 f7 ff ff       	call   80134c <fd2data>
  801b98:	83 c4 08             	add    $0x8,%esp
  801b9b:	50                   	push   %eax
  801b9c:	6a 00                	push   $0x0
  801b9e:	e8 37 f2 ff ff       	call   800dda <sys_page_unmap>
}
  801ba3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	57                   	push   %edi
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
  801bae:	83 ec 1c             	sub    $0x1c,%esp
  801bb1:	89 c7                	mov    %eax,%edi
  801bb3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb6:	a1 04 40 80 00       	mov    0x804004,%eax
  801bbb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	57                   	push   %edi
  801bc2:	e8 25 ff ff ff       	call   801aec <pageref>
  801bc7:	89 c6                	mov    %eax,%esi
  801bc9:	83 c4 04             	add    $0x4,%esp
  801bcc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bcf:	e8 18 ff ff ff       	call   801aec <pageref>
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	39 c6                	cmp    %eax,%esi
  801bd9:	0f 94 c0             	sete   %al
  801bdc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bdf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801be5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be8:	39 cb                	cmp    %ecx,%ebx
  801bea:	75 08                	jne    801bf4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5f                   	pop    %edi
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801bf4:	83 f8 01             	cmp    $0x1,%eax
  801bf7:	75 bd                	jne    801bb6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf9:	8b 42 58             	mov    0x58(%edx),%eax
  801bfc:	6a 01                	push   $0x1
  801bfe:	50                   	push   %eax
  801bff:	53                   	push   %ebx
  801c00:	68 d2 29 80 00       	push   $0x8029d2
  801c05:	e8 4e e7 ff ff       	call   800358 <cprintf>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	eb a7                	jmp    801bb6 <_pipeisclosed+0xe>

00801c0f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	57                   	push   %edi
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	83 ec 28             	sub    $0x28,%esp
  801c18:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1b:	56                   	push   %esi
  801c1c:	e8 2b f7 ff ff       	call   80134c <fd2data>
  801c21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c2a:	75 4a                	jne    801c76 <devpipe_write+0x67>
  801c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801c31:	eb 56                	jmp    801c89 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c33:	89 da                	mov    %ebx,%edx
  801c35:	89 f0                	mov    %esi,%eax
  801c37:	e8 6c ff ff ff       	call   801ba8 <_pipeisclosed>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	75 4d                	jne    801c8d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c40:	e8 24 f1 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c45:	8b 43 04             	mov    0x4(%ebx),%eax
  801c48:	8b 13                	mov    (%ebx),%edx
  801c4a:	83 c2 20             	add    $0x20,%edx
  801c4d:	39 d0                	cmp    %edx,%eax
  801c4f:	73 e2                	jae    801c33 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c51:	89 c2                	mov    %eax,%edx
  801c53:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c59:	79 05                	jns    801c60 <devpipe_write+0x51>
  801c5b:	4a                   	dec    %edx
  801c5c:	83 ca e0             	or     $0xffffffe0,%edx
  801c5f:	42                   	inc    %edx
  801c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c63:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801c66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c6a:	40                   	inc    %eax
  801c6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6e:	47                   	inc    %edi
  801c6f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c72:	77 07                	ja     801c7b <devpipe_write+0x6c>
  801c74:	eb 13                	jmp    801c89 <devpipe_write+0x7a>
  801c76:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7e:	8b 13                	mov    (%ebx),%edx
  801c80:	83 c2 20             	add    $0x20,%edx
  801c83:	39 d0                	cmp    %edx,%eax
  801c85:	73 ac                	jae    801c33 <devpipe_write+0x24>
  801c87:	eb c8                	jmp    801c51 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c89:	89 f8                	mov    %edi,%eax
  801c8b:	eb 05                	jmp    801c92 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	57                   	push   %edi
  801c9e:	56                   	push   %esi
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 18             	sub    $0x18,%esp
  801ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ca6:	57                   	push   %edi
  801ca7:	e8 a0 f6 ff ff       	call   80134c <fd2data>
  801cac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb5:	75 44                	jne    801cfb <devpipe_read+0x61>
  801cb7:	be 00 00 00 00       	mov    $0x0,%esi
  801cbc:	eb 4f                	jmp    801d0d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	eb 54                	jmp    801d16 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cc2:	89 da                	mov    %ebx,%edx
  801cc4:	89 f8                	mov    %edi,%eax
  801cc6:	e8 dd fe ff ff       	call   801ba8 <_pipeisclosed>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	75 42                	jne    801d11 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ccf:	e8 95 f0 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cd4:	8b 03                	mov    (%ebx),%eax
  801cd6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cd9:	74 e7                	je     801cc2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cdb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ce0:	79 05                	jns    801ce7 <devpipe_read+0x4d>
  801ce2:	48                   	dec    %eax
  801ce3:	83 c8 e0             	or     $0xffffffe0,%eax
  801ce6:	40                   	inc    %eax
  801ce7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cee:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cf1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf3:	46                   	inc    %esi
  801cf4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801cf7:	77 07                	ja     801d00 <devpipe_read+0x66>
  801cf9:	eb 12                	jmp    801d0d <devpipe_read+0x73>
  801cfb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801d00:	8b 03                	mov    (%ebx),%eax
  801d02:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d05:	75 d4                	jne    801cdb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d07:	85 f6                	test   %esi,%esi
  801d09:	75 b3                	jne    801cbe <devpipe_read+0x24>
  801d0b:	eb b5                	jmp    801cc2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d0d:	89 f0                	mov    %esi,%eax
  801d0f:	eb 05                	jmp    801d16 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 28             	sub    $0x28,%esp
  801d27:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d2d:	50                   	push   %eax
  801d2e:	e8 31 f6 ff ff       	call   801364 <fd_alloc>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 24 01 00 00    	js     801e64 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	68 07 04 00 00       	push   $0x407
  801d48:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 3e f0 ff ff       	call   800d90 <sys_page_alloc>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 88 05 01 00 00    	js     801e64 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	e8 f9 f5 ff ff       	call   801364 <fd_alloc>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	0f 88 dc 00 00 00    	js     801e54 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	68 07 04 00 00       	push   $0x407
  801d80:	ff 75 e0             	pushl  -0x20(%ebp)
  801d83:	6a 00                	push   $0x0
  801d85:	e8 06 f0 ff ff       	call   800d90 <sys_page_alloc>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	0f 88 bd 00 00 00    	js     801e54 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d97:	83 ec 0c             	sub    $0xc,%esp
  801d9a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d9d:	e8 aa f5 ff ff       	call   80134c <fd2data>
  801da2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da4:	83 c4 0c             	add    $0xc,%esp
  801da7:	68 07 04 00 00       	push   $0x407
  801dac:	50                   	push   %eax
  801dad:	6a 00                	push   $0x0
  801daf:	e8 dc ef ff ff       	call   800d90 <sys_page_alloc>
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	0f 88 83 00 00 00    	js     801e44 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc1:	83 ec 0c             	sub    $0xc,%esp
  801dc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801dc7:	e8 80 f5 ff ff       	call   80134c <fd2data>
  801dcc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd3:	50                   	push   %eax
  801dd4:	6a 00                	push   $0x0
  801dd6:	56                   	push   %esi
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 d6 ef ff ff       	call   800db4 <sys_page_map>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	83 c4 20             	add    $0x20,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 4f                	js     801e36 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e11:	83 ec 0c             	sub    $0xc,%esp
  801e14:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e17:	e8 20 f5 ff ff       	call   80133c <fd2num>
  801e1c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e1e:	83 c4 04             	add    $0x4,%esp
  801e21:	ff 75 e0             	pushl  -0x20(%ebp)
  801e24:	e8 13 f5 ff ff       	call   80133c <fd2num>
  801e29:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e34:	eb 2e                	jmp    801e64 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e36:	83 ec 08             	sub    $0x8,%esp
  801e39:	56                   	push   %esi
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 99 ef ff ff       	call   800dda <sys_page_unmap>
  801e41:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	ff 75 e0             	pushl  -0x20(%ebp)
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 89 ef ff ff       	call   800dda <sys_page_unmap>
  801e51:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e54:	83 ec 08             	sub    $0x8,%esp
  801e57:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 79 ef ff ff       	call   800dda <sys_page_unmap>
  801e61:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801e64:	89 d8                	mov    %ebx,%eax
  801e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e69:	5b                   	pop    %ebx
  801e6a:	5e                   	pop    %esi
  801e6b:	5f                   	pop    %edi
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	ff 75 08             	pushl  0x8(%ebp)
  801e7b:	e8 57 f5 ff ff       	call   8013d7 <fd_lookup>
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 18                	js     801e9f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8d:	e8 ba f4 ff ff       	call   80134c <fd2data>
	return _pipeisclosed(fd, p);
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	e8 0c fd ff ff       	call   801ba8 <_pipeisclosed>
  801e9c:	83 c4 10             	add    $0x10,%esp
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    
  801ea1:	00 00                	add    %al,(%eax)
	...

00801ea4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb4:	68 ea 29 80 00       	push   $0x8029ea
  801eb9:	ff 75 0c             	pushl  0xc(%ebp)
  801ebc:	e8 4d ea ff ff       	call   80090e <strcpy>
	return 0;
}
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed8:	74 45                	je     801f1f <devcons_write+0x57>
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
  801edf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eed:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801eef:	83 fb 7f             	cmp    $0x7f,%ebx
  801ef2:	76 05                	jbe    801ef9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ef4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	53                   	push   %ebx
  801efd:	03 45 0c             	add    0xc(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	57                   	push   %edi
  801f02:	e8 c8 eb ff ff       	call   800acf <memmove>
		sys_cputs(buf, m);
  801f07:	83 c4 08             	add    $0x8,%esp
  801f0a:	53                   	push   %ebx
  801f0b:	57                   	push   %edi
  801f0c:	e8 c8 ed ff ff       	call   800cd9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f11:	01 de                	add    %ebx,%esi
  801f13:	89 f0                	mov    %esi,%eax
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1b:	72 cd                	jb     801eea <devcons_write+0x22>
  801f1d:	eb 05                	jmp    801f24 <devcons_write+0x5c>
  801f1f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f24:	89 f0                	mov    %esi,%eax
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f38:	75 07                	jne    801f41 <devcons_read+0x13>
  801f3a:	eb 25                	jmp    801f61 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f3c:	e8 28 ee ff ff       	call   800d69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f41:	e8 b9 ed ff ff       	call   800cff <sys_cgetc>
  801f46:	85 c0                	test   %eax,%eax
  801f48:	74 f2                	je     801f3c <devcons_read+0xe>
  801f4a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 1d                	js     801f6d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f50:	83 f8 04             	cmp    $0x4,%eax
  801f53:	74 13                	je     801f68 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f58:	88 10                	mov    %dl,(%eax)
	return 1;
  801f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5f:	eb 0c                	jmp    801f6d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f61:	b8 00 00 00 00       	mov    $0x0,%eax
  801f66:	eb 05                	jmp    801f6d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f75:	8b 45 08             	mov    0x8(%ebp),%eax
  801f78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f7b:	6a 01                	push   $0x1
  801f7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	e8 53 ed ff ff       	call   800cd9 <sys_cputs>
  801f86:	83 c4 10             	add    $0x10,%esp
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <getchar>:

int
getchar(void)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f91:	6a 01                	push   $0x1
  801f93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	6a 00                	push   $0x0
  801f99:	e8 ba f6 ff ff       	call   801658 <read>
	if (r < 0)
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 0f                	js     801fb4 <getchar+0x29>
		return r;
	if (r < 1)
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	7e 06                	jle    801faf <getchar+0x24>
		return -E_EOF;
	return c;
  801fa9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fad:	eb 05                	jmp    801fb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801faf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbf:	50                   	push   %eax
  801fc0:	ff 75 08             	pushl  0x8(%ebp)
  801fc3:	e8 0f f4 ff ff       	call   8013d7 <fd_lookup>
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	78 11                	js     801fe0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd8:	39 10                	cmp    %edx,(%eax)
  801fda:	0f 94 c0             	sete   %al
  801fdd:	0f b6 c0             	movzbl %al,%eax
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <opencons>:

int
opencons(void)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801feb:	50                   	push   %eax
  801fec:	e8 73 f3 ff ff       	call   801364 <fd_alloc>
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 3a                	js     802032 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff8:	83 ec 04             	sub    $0x4,%esp
  801ffb:	68 07 04 00 00       	push   $0x407
  802000:	ff 75 f4             	pushl  -0xc(%ebp)
  802003:	6a 00                	push   $0x0
  802005:	e8 86 ed ff ff       	call   800d90 <sys_page_alloc>
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 21                	js     802032 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802011:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	50                   	push   %eax
  80202a:	e8 0d f3 ff ff       	call   80133c <fd2num>
  80202f:	83 c4 10             	add    $0x10,%esp
}
  802032:	c9                   	leave  
  802033:	c3                   	ret    

00802034 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80203a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802041:	75 52                	jne    802095 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	6a 07                	push   $0x7
  802048:	68 00 f0 bf ee       	push   $0xeebff000
  80204d:	6a 00                	push   $0x0
  80204f:	e8 3c ed ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) {
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	79 12                	jns    80206d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80205b:	50                   	push   %eax
  80205c:	68 f6 29 80 00       	push   $0x8029f6
  802061:	6a 24                	push   $0x24
  802063:	68 11 2a 80 00       	push   $0x802a11
  802068:	e8 13 e2 ff ff       	call   800280 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80206d:	83 ec 08             	sub    $0x8,%esp
  802070:	68 a0 20 80 00       	push   $0x8020a0
  802075:	6a 00                	push   $0x0
  802077:	e8 c7 ed ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	85 c0                	test   %eax,%eax
  802081:	79 12                	jns    802095 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802083:	50                   	push   %eax
  802084:	68 20 2a 80 00       	push   $0x802a20
  802089:	6a 2a                	push   $0x2a
  80208b:	68 11 2a 80 00       	push   $0x802a11
  802090:	e8 eb e1 ff ff       	call   800280 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802095:	8b 45 08             	mov    0x8(%ebp),%eax
  802098:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80209d:	c9                   	leave  
  80209e:	c3                   	ret    
	...

008020a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020a1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020a8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8020ab:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8020af:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8020b2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8020b6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8020ba:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8020bc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8020bf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8020c0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8020c3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020c4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020c5:	c3                   	ret    
	...

008020c8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	57                   	push   %edi
  8020cc:	56                   	push   %esi
  8020cd:	83 ec 10             	sub    $0x10,%esp
  8020d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020d6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020dc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020df:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 2e                	jne    802114 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020e6:	39 f1                	cmp    %esi,%ecx
  8020e8:	77 5a                	ja     802144 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020ea:	85 c9                	test   %ecx,%ecx
  8020ec:	75 0b                	jne    8020f9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f1                	div    %ecx
  8020f7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020f9:	31 d2                	xor    %edx,%edx
  8020fb:	89 f0                	mov    %esi,%eax
  8020fd:	f7 f1                	div    %ecx
  8020ff:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802101:	89 f8                	mov    %edi,%eax
  802103:	f7 f1                	div    %ecx
  802105:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802107:	89 f8                	mov    %edi,%eax
  802109:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80210b:	83 c4 10             	add    $0x10,%esp
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	c9                   	leave  
  802111:	c3                   	ret    
  802112:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802114:	39 f0                	cmp    %esi,%eax
  802116:	77 1c                	ja     802134 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802118:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80211b:	83 f7 1f             	xor    $0x1f,%edi
  80211e:	75 3c                	jne    80215c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802120:	39 f0                	cmp    %esi,%eax
  802122:	0f 82 90 00 00 00    	jb     8021b8 <__udivdi3+0xf0>
  802128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80212e:	0f 86 84 00 00 00    	jbe    8021b8 <__udivdi3+0xf0>
  802134:	31 f6                	xor    %esi,%esi
  802136:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802138:	89 f8                	mov    %edi,%eax
  80213a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	c9                   	leave  
  802142:	c3                   	ret    
  802143:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802144:	89 f2                	mov    %esi,%edx
  802146:	89 f8                	mov    %edi,%eax
  802148:	f7 f1                	div    %ecx
  80214a:	89 c7                	mov    %eax,%edi
  80214c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80214e:	89 f8                	mov    %edi,%eax
  802150:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	c9                   	leave  
  802158:	c3                   	ret    
  802159:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80215c:	89 f9                	mov    %edi,%ecx
  80215e:	d3 e0                	shl    %cl,%eax
  802160:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802163:	b8 20 00 00 00       	mov    $0x20,%eax
  802168:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80216a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80216d:	88 c1                	mov    %al,%cl
  80216f:	d3 ea                	shr    %cl,%edx
  802171:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802174:	09 ca                	or     %ecx,%edx
  802176:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802179:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217c:	89 f9                	mov    %edi,%ecx
  80217e:	d3 e2                	shl    %cl,%edx
  802180:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802183:	89 f2                	mov    %esi,%edx
  802185:	88 c1                	mov    %al,%cl
  802187:	d3 ea                	shr    %cl,%edx
  802189:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	d3 e2                	shl    %cl,%edx
  802192:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802195:	88 c1                	mov    %al,%cl
  802197:	d3 ee                	shr    %cl,%esi
  802199:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80219b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80219e:	89 f0                	mov    %esi,%eax
  8021a0:	89 ca                	mov    %ecx,%edx
  8021a2:	f7 75 ec             	divl   -0x14(%ebp)
  8021a5:	89 d1                	mov    %edx,%ecx
  8021a7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021a9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ac:	39 d1                	cmp    %edx,%ecx
  8021ae:	72 28                	jb     8021d8 <__udivdi3+0x110>
  8021b0:	74 1a                	je     8021cc <__udivdi3+0x104>
  8021b2:	89 f7                	mov    %esi,%edi
  8021b4:	31 f6                	xor    %esi,%esi
  8021b6:	eb 80                	jmp    802138 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021b8:	31 f6                	xor    %esi,%esi
  8021ba:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    
  8021ca:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021cf:	89 f9                	mov    %edi,%ecx
  8021d1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021d3:	39 c2                	cmp    %eax,%edx
  8021d5:	73 db                	jae    8021b2 <__udivdi3+0xea>
  8021d7:	90                   	nop
		{
		  q0--;
  8021d8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021db:	31 f6                	xor    %esi,%esi
  8021dd:	e9 56 ff ff ff       	jmp    802138 <__udivdi3+0x70>
	...

008021e4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	57                   	push   %edi
  8021e8:	56                   	push   %esi
  8021e9:	83 ec 20             	sub    $0x20,%esp
  8021ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802201:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802203:	85 ff                	test   %edi,%edi
  802205:	75 15                	jne    80221c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802207:	39 f1                	cmp    %esi,%ecx
  802209:	0f 86 99 00 00 00    	jbe    8022a8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80220f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802211:	89 d0                	mov    %edx,%eax
  802213:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802215:	83 c4 20             	add    $0x20,%esp
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	0f 87 a4 00 00 00    	ja     8022c8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802224:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802227:	83 f0 1f             	xor    $0x1f,%eax
  80222a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80222d:	0f 84 a1 00 00 00    	je     8022d4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802233:	89 f8                	mov    %edi,%eax
  802235:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802238:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80223a:	bf 20 00 00 00       	mov    $0x20,%edi
  80223f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 ea                	shr    %cl,%edx
  802249:	09 c2                	or     %eax,%edx
  80224b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80224e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802251:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802254:	d3 e0                	shl    %cl,%eax
  802256:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802259:	89 f2                	mov    %esi,%edx
  80225b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80225d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802260:	d3 e0                	shl    %cl,%eax
  802262:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802265:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802268:	89 f9                	mov    %edi,%ecx
  80226a:	d3 e8                	shr    %cl,%eax
  80226c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80226e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802270:	89 f2                	mov    %esi,%edx
  802272:	f7 75 f0             	divl   -0x10(%ebp)
  802275:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802277:	f7 65 f4             	mull   -0xc(%ebp)
  80227a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80227d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80227f:	39 d6                	cmp    %edx,%esi
  802281:	72 71                	jb     8022f4 <__umoddi3+0x110>
  802283:	74 7f                	je     802304 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802288:	29 c8                	sub    %ecx,%eax
  80228a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80228c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80228f:	d3 e8                	shr    %cl,%eax
  802291:	89 f2                	mov    %esi,%edx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802297:	09 d0                	or     %edx,%eax
  802299:	89 f2                	mov    %esi,%edx
  80229b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80229e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a0:	83 c4 20             	add    $0x20,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    
  8022a7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022a8:	85 c9                	test   %ecx,%ecx
  8022aa:	75 0b                	jne    8022b7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b1:	31 d2                	xor    %edx,%edx
  8022b3:	f7 f1                	div    %ecx
  8022b5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022b7:	89 f0                	mov    %esi,%eax
  8022b9:	31 d2                	xor    %edx,%edx
  8022bb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c0:	f7 f1                	div    %ecx
  8022c2:	e9 4a ff ff ff       	jmp    802211 <__umoddi3+0x2d>
  8022c7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ca:	83 c4 20             	add    $0x20,%esp
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    
  8022d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022d4:	39 f7                	cmp    %esi,%edi
  8022d6:	72 05                	jb     8022dd <__umoddi3+0xf9>
  8022d8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022db:	77 0c                	ja     8022e9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e2:	29 c8                	sub    %ecx,%eax
  8022e4:	19 fa                	sbb    %edi,%edx
  8022e6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ec:	83 c4 20             	add    $0x20,%esp
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    
  8022f3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022f7:	89 c1                	mov    %eax,%ecx
  8022f9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022fc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022ff:	eb 84                	jmp    802285 <__umoddi3+0xa1>
  802301:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802304:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802307:	72 eb                	jb     8022f4 <__umoddi3+0x110>
  802309:	89 f2                	mov    %esi,%edx
  80230b:	e9 75 ff ff ff       	jmp    802285 <__umoddi3+0xa1>
