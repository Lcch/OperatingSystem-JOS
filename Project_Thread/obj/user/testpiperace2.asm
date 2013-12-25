
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	68 00 23 80 00       	push   $0x802300
  800042:	e8 b5 02 00 00       	call   8002fc <cprintf>
	if ((r = pipe(p)) < 0)
  800047:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004a:	89 04 24             	mov    %eax,(%esp)
  80004d:	e8 44 1b 00 00       	call   801b96 <pipe>
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	85 c0                	test   %eax,%eax
  800057:	79 12                	jns    80006b <umain+0x37>
		panic("pipe: %e", r);
  800059:	50                   	push   %eax
  80005a:	68 4e 23 80 00       	push   $0x80234e
  80005f:	6a 0d                	push   $0xd
  800061:	68 57 23 80 00       	push   $0x802357
  800066:	e8 b9 01 00 00       	call   800224 <_panic>
	if ((r = fork()) < 0)
  80006b:	e8 42 0f 00 00       	call   800fb2 <fork>
  800070:	89 c7                	mov    %eax,%edi
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x54>
		panic("fork: %e", r);
  800076:	50                   	push   %eax
  800077:	68 6c 23 80 00       	push   $0x80236c
  80007c:	6a 0f                	push   $0xf
  80007e:	68 57 23 80 00       	push   $0x802357
  800083:	e8 9c 01 00 00       	call   800224 <_panic>
	if (r == 0) {
  800088:	85 c0                	test   %eax,%eax
  80008a:	75 66                	jne    8000f2 <umain+0xbe>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800092:	e8 40 13 00 00       	call   8013d7 <close>
  800097:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  80009a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009f:	be 0a 00 00 00       	mov    $0xa,%esi
  8000a4:	89 d8                	mov    %ebx,%eax
  8000a6:	99                   	cltd   
  8000a7:	f7 fe                	idiv   %esi
  8000a9:	85 d2                	test   %edx,%edx
  8000ab:	75 11                	jne    8000be <umain+0x8a>
				cprintf("%d.", i);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	53                   	push   %ebx
  8000b1:	68 75 23 80 00       	push   $0x802375
  8000b6:	e8 41 02 00 00       	call   8002fc <cprintf>
  8000bb:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	6a 0a                	push   $0xa
  8000c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c6:	e8 5a 13 00 00       	call   801425 <dup>
			sys_yield();
  8000cb:	e8 3d 0c 00 00       	call   800d0d <sys_yield>
			close(10);
  8000d0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000d7:	e8 fb 12 00 00       	call   8013d7 <close>
			sys_yield();
  8000dc:	e8 2c 0c 00 00       	call   800d0d <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000e1:	43                   	inc    %ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000eb:	75 b7                	jne    8000a4 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ed:	e8 16 01 00 00       	call   800208 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  8000f2:	89 f8                	mov    %edi,%eax
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  8000f9:	89 c2                	mov    %eax,%edx
  8000fb:	c1 e2 07             	shl    $0x7,%edx
  8000fe:	8d 9c 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%ebx
  800105:	eb 2f                	jmp    800136 <umain+0x102>
		if (pipeisclosed(p[0]) != 0) {
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	ff 75 e0             	pushl  -0x20(%ebp)
  80010d:	e8 d4 1b 00 00       	call   801ce6 <pipeisclosed>
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 c0                	test   %eax,%eax
  800117:	74 1d                	je     800136 <umain+0x102>
			cprintf("\nRACE: pipe appears closed\n");
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	68 79 23 80 00       	push   $0x802379
  800121:	e8 d6 01 00 00       	call   8002fc <cprintf>
			sys_env_destroy(r);
  800126:	89 3c 24             	mov    %edi,(%esp)
  800129:	e8 99 0b 00 00       	call   800cc7 <sys_env_destroy>
			exit();
  80012e:	e8 d5 00 00 00       	call   800208 <exit>
  800133:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800136:	8b 43 50             	mov    0x50(%ebx),%eax
  800139:	83 f8 02             	cmp    $0x2,%eax
  80013c:	74 c9                	je     800107 <umain+0xd3>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	68 95 23 80 00       	push   $0x802395
  800146:	e8 b1 01 00 00       	call   8002fc <cprintf>
	if (pipeisclosed(p[0]))
  80014b:	83 c4 04             	add    $0x4,%esp
  80014e:	ff 75 e0             	pushl  -0x20(%ebp)
  800151:	e8 90 1b 00 00       	call   801ce6 <pipeisclosed>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 14                	je     800171 <umain+0x13d>
		panic("somehow the other end of p[0] got closed!");
  80015d:	83 ec 04             	sub    $0x4,%esp
  800160:	68 24 23 80 00       	push   $0x802324
  800165:	6a 40                	push   $0x40
  800167:	68 57 23 80 00       	push   $0x802357
  80016c:	e8 b3 00 00 00       	call   800224 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800171:	83 ec 08             	sub    $0x8,%esp
  800174:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	ff 75 e0             	pushl  -0x20(%ebp)
  80017b:	e8 13 11 00 00       	call   801293 <fd_lookup>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	79 12                	jns    800199 <umain+0x165>
		panic("cannot look up p[0]: %e", r);
  800187:	50                   	push   %eax
  800188:	68 ab 23 80 00       	push   $0x8023ab
  80018d:	6a 42                	push   $0x42
  80018f:	68 57 23 80 00       	push   $0x802357
  800194:	e8 8b 00 00 00       	call   800224 <_panic>
	(void) fd2data(fd);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 dc             	pushl  -0x24(%ebp)
  80019f:	e8 64 10 00 00       	call   801208 <fd2data>
	cprintf("race didn't happen\n");
  8001a4:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  8001ab:	e8 4c 01 00 00       	call   8002fc <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
}
  8001b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001c7:	e8 1d 0b 00 00       	call   800ce9 <sys_getenvid>
  8001cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d1:	89 c2                	mov    %eax,%edx
  8001d3:	c1 e2 07             	shl    $0x7,%edx
  8001d6:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8001dd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e2:	85 f6                	test   %esi,%esi
  8001e4:	7e 07                	jle    8001ed <libmain+0x31>
		binaryname = argv[0];
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	53                   	push   %ebx
  8001f1:	56                   	push   %esi
  8001f2:	e8 3d fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001f7:	e8 0c 00 00 00       	call   800208 <exit>
  8001fc:	83 c4 10             	add    $0x10,%esp
}
  8001ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	c9                   	leave  
  800205:	c3                   	ret    
	...

00800208 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020e:	e8 ef 11 00 00       	call   801402 <close_all>
	sys_env_destroy(0);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	6a 00                	push   $0x0
  800218:	e8 aa 0a 00 00       	call   800cc7 <sys_env_destroy>
  80021d:	83 c4 10             	add    $0x10,%esp
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    
	...

00800224 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800229:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800232:	e8 b2 0a 00 00       	call   800ce9 <sys_getenvid>
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	53                   	push   %ebx
  800241:	50                   	push   %eax
  800242:	68 e4 23 80 00       	push   $0x8023e4
  800247:	e8 b0 00 00 00       	call   8002fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024c:	83 c4 18             	add    $0x18,%esp
  80024f:	56                   	push   %esi
  800250:	ff 75 10             	pushl  0x10(%ebp)
  800253:	e8 53 00 00 00       	call   8002ab <vcprintf>
	cprintf("\n");
  800258:	c7 04 24 87 29 80 00 	movl   $0x802987,(%esp)
  80025f:	e8 98 00 00 00       	call   8002fc <cprintf>
  800264:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800267:	cc                   	int3   
  800268:	eb fd                	jmp    800267 <_panic+0x43>
	...

0080026c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	53                   	push   %ebx
  800270:	83 ec 04             	sub    $0x4,%esp
  800273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800276:	8b 03                	mov    (%ebx),%eax
  800278:	8b 55 08             	mov    0x8(%ebp),%edx
  80027b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80027f:	40                   	inc    %eax
  800280:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800282:	3d ff 00 00 00       	cmp    $0xff,%eax
  800287:	75 1a                	jne    8002a3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	68 ff 00 00 00       	push   $0xff
  800291:	8d 43 08             	lea    0x8(%ebx),%eax
  800294:	50                   	push   %eax
  800295:	e8 e3 09 00 00       	call   800c7d <sys_cputs>
		b->idx = 0;
  80029a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a3:	ff 43 04             	incl   0x4(%ebx)
}
  8002a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bb:	00 00 00 
	b.cnt = 0;
  8002be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c8:	ff 75 0c             	pushl  0xc(%ebp)
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d4:	50                   	push   %eax
  8002d5:	68 6c 02 80 00       	push   $0x80026c
  8002da:	e8 82 01 00 00       	call   800461 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002df:	83 c4 08             	add    $0x8,%esp
  8002e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ee:	50                   	push   %eax
  8002ef:	e8 89 09 00 00       	call   800c7d <sys_cputs>

	return b.cnt;
}
  8002f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800302:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800305:	50                   	push   %eax
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	e8 9d ff ff ff       	call   8002ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 2c             	sub    $0x2c,%esp
  800319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031c:	89 d6                	mov    %edx,%esi
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	8b 55 0c             	mov    0xc(%ebp),%edx
  800324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800327:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80032a:	8b 45 10             	mov    0x10(%ebp),%eax
  80032d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800330:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800333:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800336:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80033d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800340:	72 0c                	jb     80034e <printnum+0x3e>
  800342:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800345:	76 07                	jbe    80034e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800347:	4b                   	dec    %ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f 31                	jg     80037d <printnum+0x6d>
  80034c:	eb 3f                	jmp    80038d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	57                   	push   %edi
  800352:	4b                   	dec    %ebx
  800353:	53                   	push   %ebx
  800354:	50                   	push   %eax
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	ff 75 d4             	pushl  -0x2c(%ebp)
  80035b:	ff 75 d0             	pushl  -0x30(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 33 1d 00 00       	call   80209c <__udivdi3>
  800369:	83 c4 18             	add    $0x18,%esp
  80036c:	52                   	push   %edx
  80036d:	50                   	push   %eax
  80036e:	89 f2                	mov    %esi,%edx
  800370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800373:	e8 98 ff ff ff       	call   800310 <printnum>
  800378:	83 c4 20             	add    $0x20,%esp
  80037b:	eb 10                	jmp    80038d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	56                   	push   %esi
  800381:	57                   	push   %edi
  800382:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800385:	4b                   	dec    %ebx
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	85 db                	test   %ebx,%ebx
  80038b:	7f f0                	jg     80037d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	56                   	push   %esi
  800391:	83 ec 04             	sub    $0x4,%esp
  800394:	ff 75 d4             	pushl  -0x2c(%ebp)
  800397:	ff 75 d0             	pushl  -0x30(%ebp)
  80039a:	ff 75 dc             	pushl  -0x24(%ebp)
  80039d:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a0:	e8 13 1e 00 00       	call   8021b8 <__umoddi3>
  8003a5:	83 c4 14             	add    $0x14,%esp
  8003a8:	0f be 80 07 24 80 00 	movsbl 0x802407(%eax),%eax
  8003af:	50                   	push   %eax
  8003b0:	ff 55 e4             	call   *-0x1c(%ebp)
  8003b3:	83 c4 10             	add    $0x10,%esp
}
  8003b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5f                   	pop    %edi
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c1:	83 fa 01             	cmp    $0x1,%edx
  8003c4:	7e 0e                	jle    8003d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cb:	89 08                	mov    %ecx,(%eax)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	8b 52 04             	mov    0x4(%edx),%edx
  8003d2:	eb 22                	jmp    8003f6 <getuint+0x38>
	else if (lflag)
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	74 10                	je     8003e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 02                	mov    (%edx),%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	eb 0e                	jmp    8003f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fb:	83 fa 01             	cmp    $0x1,%edx
  8003fe:	7e 0e                	jle    80040e <getint+0x16>
		return va_arg(*ap, long long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 08             	lea    0x8(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	8b 52 04             	mov    0x4(%edx),%edx
  80040c:	eb 1a                	jmp    800428 <getint+0x30>
	else if (lflag)
  80040e:	85 d2                	test   %edx,%edx
  800410:	74 0c                	je     80041e <getint+0x26>
		return va_arg(*ap, long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 4a 04             	lea    0x4(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	99                   	cltd   
  80041c:	eb 0a                	jmp    800428 <getint+0x30>
	else
		return va_arg(*ap, int);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 04             	lea    0x4(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	99                   	cltd   
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800430:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800433:	8b 10                	mov    (%eax),%edx
  800435:	3b 50 04             	cmp    0x4(%eax),%edx
  800438:	73 08                	jae    800442 <sprintputch+0x18>
		*b->buf++ = ch;
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	88 0a                	mov    %cl,(%edx)
  80043f:	42                   	inc    %edx
  800440:	89 10                	mov    %edx,(%eax)
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80044a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044d:	50                   	push   %eax
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	ff 75 0c             	pushl  0xc(%ebp)
  800454:	ff 75 08             	pushl  0x8(%ebp)
  800457:	e8 05 00 00 00       	call   800461 <vprintfmt>
	va_end(ap);
  80045c:	83 c4 10             	add    $0x10,%esp
}
  80045f:	c9                   	leave  
  800460:	c3                   	ret    

00800461 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 2c             	sub    $0x2c,%esp
  80046a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80046d:	8b 75 10             	mov    0x10(%ebp),%esi
  800470:	eb 13                	jmp    800485 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800472:	85 c0                	test   %eax,%eax
  800474:	0f 84 6d 03 00 00    	je     8007e7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	57                   	push   %edi
  80047e:	50                   	push   %eax
  80047f:	ff 55 08             	call   *0x8(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800485:	0f b6 06             	movzbl (%esi),%eax
  800488:	46                   	inc    %esi
  800489:	83 f8 25             	cmp    $0x25,%eax
  80048c:	75 e4                	jne    800472 <vprintfmt+0x11>
  80048e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800492:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800499:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ac:	eb 28                	jmp    8004d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004b4:	eb 20                	jmp    8004d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004bc:	eb 18                	jmp    8004d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c7:	eb 0d                	jmp    8004d6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8a 06                	mov    (%esi),%al
  8004d8:	0f b6 d0             	movzbl %al,%edx
  8004db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004de:	83 e8 23             	sub    $0x23,%eax
  8004e1:	3c 55                	cmp    $0x55,%al
  8004e3:	0f 87 e0 02 00 00    	ja     8007c9 <vprintfmt+0x368>
  8004e9:	0f b6 c0             	movzbl %al,%eax
  8004ec:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f3:	83 ea 30             	sub    $0x30,%edx
  8004f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004f9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8004fc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004ff:	83 fa 09             	cmp    $0x9,%edx
  800502:	77 44                	ja     800548 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	89 de                	mov    %ebx,%esi
  800506:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800509:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80050a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80050d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800511:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800514:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800517:	83 fb 09             	cmp    $0x9,%ebx
  80051a:	76 ed                	jbe    800509 <vprintfmt+0xa8>
  80051c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80051f:	eb 29                	jmp    80054a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800531:	eb 17                	jmp    80054a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800533:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800537:	78 85                	js     8004be <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	89 de                	mov    %ebx,%esi
  80053b:	eb 99                	jmp    8004d6 <vprintfmt+0x75>
  80053d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80053f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800546:	eb 8e                	jmp    8004d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80054a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054e:	79 86                	jns    8004d6 <vprintfmt+0x75>
  800550:	e9 74 ff ff ff       	jmp    8004c9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800555:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi
  800558:	e9 79 ff ff ff       	jmp    8004d6 <vprintfmt+0x75>
  80055d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	57                   	push   %edi
  80056d:	ff 30                	pushl  (%eax)
  80056f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800572:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800578:	e9 08 ff ff ff       	jmp    800485 <vprintfmt+0x24>
  80057d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	85 c0                	test   %eax,%eax
  80058d:	79 02                	jns    800591 <vprintfmt+0x130>
  80058f:	f7 d8                	neg    %eax
  800591:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800593:	83 f8 0f             	cmp    $0xf,%eax
  800596:	7f 0b                	jg     8005a3 <vprintfmt+0x142>
  800598:	8b 04 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	75 1a                	jne    8005bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005a3:	52                   	push   %edx
  8005a4:	68 1f 24 80 00       	push   $0x80241f
  8005a9:	57                   	push   %edi
  8005aa:	ff 75 08             	pushl  0x8(%ebp)
  8005ad:	e8 92 fe ff ff       	call   800444 <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b8:	e9 c8 fe ff ff       	jmp    800485 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005bd:	50                   	push   %eax
  8005be:	68 55 29 80 00       	push   $0x802955
  8005c3:	57                   	push   %edi
  8005c4:	ff 75 08             	pushl  0x8(%ebp)
  8005c7:	e8 78 fe ff ff       	call   800444 <printfmt>
  8005cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005d2:	e9 ae fe ff ff       	jmp    800485 <vprintfmt+0x24>
  8005d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005da:	89 de                	mov    %ebx,%esi
  8005dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	75 07                	jne    8005fb <vprintfmt+0x19a>
				p = "(null)";
  8005f4:	c7 45 d0 18 24 80 00 	movl   $0x802418,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005fb:	85 db                	test   %ebx,%ebx
  8005fd:	7e 42                	jle    800641 <vprintfmt+0x1e0>
  8005ff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800603:	74 3c                	je     800641 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	51                   	push   %ecx
  800609:	ff 75 d0             	pushl  -0x30(%ebp)
  80060c:	e8 6f 02 00 00       	call   800880 <strnlen>
  800611:	29 c3                	sub    %eax,%ebx
  800613:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	85 db                	test   %ebx,%ebx
  80061b:	7e 24                	jle    800641 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80061d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800621:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800624:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	53                   	push   %ebx
  80062c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	4e                   	dec    %esi
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	85 f6                	test   %esi,%esi
  800635:	7f f0                	jg     800627 <vprintfmt+0x1c6>
  800637:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80063a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800644:	0f be 02             	movsbl (%edx),%eax
  800647:	85 c0                	test   %eax,%eax
  800649:	75 47                	jne    800692 <vprintfmt+0x231>
  80064b:	eb 37                	jmp    800684 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80064d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800651:	74 16                	je     800669 <vprintfmt+0x208>
  800653:	8d 50 e0             	lea    -0x20(%eax),%edx
  800656:	83 fa 5e             	cmp    $0x5e,%edx
  800659:	76 0e                	jbe    800669 <vprintfmt+0x208>
					putch('?', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	6a 3f                	push   $0x3f
  800661:	ff 55 08             	call   *0x8(%ebp)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb 0b                	jmp    800674 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	50                   	push   %eax
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	ff 4d e4             	decl   -0x1c(%ebp)
  800677:	0f be 03             	movsbl (%ebx),%eax
  80067a:	85 c0                	test   %eax,%eax
  80067c:	74 03                	je     800681 <vprintfmt+0x220>
  80067e:	43                   	inc    %ebx
  80067f:	eb 1b                	jmp    80069c <vprintfmt+0x23b>
  800681:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800688:	7f 1e                	jg     8006a8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80068d:	e9 f3 fd ff ff       	jmp    800485 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800692:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800695:	43                   	inc    %ebx
  800696:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800699:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80069c:	85 f6                	test   %esi,%esi
  80069e:	78 ad                	js     80064d <vprintfmt+0x1ec>
  8006a0:	4e                   	dec    %esi
  8006a1:	79 aa                	jns    80064d <vprintfmt+0x1ec>
  8006a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006a6:	eb dc                	jmp    800684 <vprintfmt+0x223>
  8006a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	6a 20                	push   $0x20
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b4:	4b                   	dec    %ebx
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	85 db                	test   %ebx,%ebx
  8006ba:	7f ef                	jg     8006ab <vprintfmt+0x24a>
  8006bc:	e9 c4 fd ff ff       	jmp    800485 <vprintfmt+0x24>
  8006c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c4:	89 ca                	mov    %ecx,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 2a fd ff ff       	call   8003f8 <getint>
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006d2:	85 d2                	test   %edx,%edx
  8006d4:	78 0a                	js     8006e0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006db:	e9 b0 00 00 00       	jmp    800790 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	57                   	push   %edi
  8006e4:	6a 2d                	push   $0x2d
  8006e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e9:	f7 db                	neg    %ebx
  8006eb:	83 d6 00             	adc    $0x0,%esi
  8006ee:	f7 de                	neg    %esi
  8006f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f8:	e9 93 00 00 00       	jmp    800790 <vprintfmt+0x32f>
  8006fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	89 ca                	mov    %ecx,%edx
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 b4 fc ff ff       	call   8003be <getuint>
  80070a:	89 c3                	mov    %eax,%ebx
  80070c:	89 d6                	mov    %edx,%esi
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800713:	eb 7b                	jmp    800790 <vprintfmt+0x32f>
  800715:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800718:	89 ca                	mov    %ecx,%edx
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 d6 fc ff ff       	call   8003f8 <getint>
  800722:	89 c3                	mov    %eax,%ebx
  800724:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800726:	85 d2                	test   %edx,%edx
  800728:	78 07                	js     800731 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80072a:	b8 08 00 00 00       	mov    $0x8,%eax
  80072f:	eb 5f                	jmp    800790 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	57                   	push   %edi
  800735:	6a 2d                	push   $0x2d
  800737:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80073a:	f7 db                	neg    %ebx
  80073c:	83 d6 00             	adc    $0x0,%esi
  80073f:	f7 de                	neg    %esi
  800741:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800744:	b8 08 00 00 00       	mov    $0x8,%eax
  800749:	eb 45                	jmp    800790 <vprintfmt+0x32f>
  80074b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	57                   	push   %edi
  800752:	6a 30                	push   $0x30
  800754:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800757:	83 c4 08             	add    $0x8,%esp
  80075a:	57                   	push   %edi
  80075b:	6a 78                	push   $0x78
  80075d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800769:	8b 18                	mov    (%eax),%ebx
  80076b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800770:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800773:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800778:	eb 16                	jmp    800790 <vprintfmt+0x32f>
  80077a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077d:	89 ca                	mov    %ecx,%edx
  80077f:	8d 45 14             	lea    0x14(%ebp),%eax
  800782:	e8 37 fc ff ff       	call   8003be <getuint>
  800787:	89 c3                	mov    %eax,%ebx
  800789:	89 d6                	mov    %edx,%esi
			base = 16;
  80078b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800790:	83 ec 0c             	sub    $0xc,%esp
  800793:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800797:	52                   	push   %edx
  800798:	ff 75 e4             	pushl  -0x1c(%ebp)
  80079b:	50                   	push   %eax
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	89 fa                	mov    %edi,%edx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	e8 68 fb ff ff       	call   800310 <printnum>
			break;
  8007a8:	83 c4 20             	add    $0x20,%esp
  8007ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007ae:	e9 d2 fc ff ff       	jmp    800485 <vprintfmt+0x24>
  8007b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	57                   	push   %edi
  8007ba:	52                   	push   %edx
  8007bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c4:	e9 bc fc ff ff       	jmp    800485 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	57                   	push   %edi
  8007cd:	6a 25                	push   $0x25
  8007cf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	eb 02                	jmp    8007d9 <vprintfmt+0x378>
  8007d7:	89 c6                	mov    %eax,%esi
  8007d9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e0:	75 f5                	jne    8007d7 <vprintfmt+0x376>
  8007e2:	e9 9e fc ff ff       	jmp    800485 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 29                	jle    80083d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 2a 04 80 00       	push   $0x80042a
  800823:	e8 39 fc ff ff       	call   800461 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb 0c                	jmp    800842 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083b:	eb 05                	jmp    800842 <vsnprintf+0x53>
  80083d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084d:	50                   	push   %eax
  80084e:	ff 75 10             	pushl  0x10(%ebp)
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	ff 75 08             	pushl  0x8(%ebp)
  800857:	e8 93 ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	80 3a 00             	cmpb   $0x0,(%edx)
  800869:	74 0e                	je     800879 <strlen+0x19>
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800870:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800871:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800875:	75 f9                	jne    800870 <strlen+0x10>
  800877:	eb 05                	jmp    80087e <strlen+0x1e>
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 17                	je     8008a4 <strnlen+0x24>
  80088d:	80 39 00             	cmpb   $0x0,(%ecx)
  800890:	74 19                	je     8008ab <strnlen+0x2b>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800897:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800898:	39 d0                	cmp    %edx,%eax
  80089a:	74 14                	je     8008b0 <strnlen+0x30>
  80089c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a0:	75 f5                	jne    800897 <strnlen+0x17>
  8008a2:	eb 0c                	jmp    8008b0 <strnlen+0x30>
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a9:	eb 05                	jmp    8008b0 <strnlen+0x30>
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c7:	42                   	inc    %edx
  8008c8:	84 c9                	test   %cl,%cl
  8008ca:	75 f5                	jne    8008c1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d6:	53                   	push   %ebx
  8008d7:	e8 84 ff ff ff       	call   800860 <strlen>
  8008dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008e5:	50                   	push   %eax
  8008e6:	e8 c7 ff ff ff       	call   8008b2 <strcpy>
	return dst;
}
  8008eb:	89 d8                	mov    %ebx,%eax
  8008ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800900:	85 f6                	test   %esi,%esi
  800902:	74 15                	je     800919 <strncpy+0x27>
  800904:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800909:	8a 1a                	mov    (%edx),%bl
  80090b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090e:	80 3a 01             	cmpb   $0x1,(%edx)
  800911:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	41                   	inc    %ecx
  800915:	39 ce                	cmp    %ecx,%esi
  800917:	77 f0                	ja     800909 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800929:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092c:	85 f6                	test   %esi,%esi
  80092e:	74 32                	je     800962 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800930:	83 fe 01             	cmp    $0x1,%esi
  800933:	74 22                	je     800957 <strlcpy+0x3a>
  800935:	8a 0b                	mov    (%ebx),%cl
  800937:	84 c9                	test   %cl,%cl
  800939:	74 20                	je     80095b <strlcpy+0x3e>
  80093b:	89 f8                	mov    %edi,%eax
  80093d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800942:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800945:	88 08                	mov    %cl,(%eax)
  800947:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800948:	39 f2                	cmp    %esi,%edx
  80094a:	74 11                	je     80095d <strlcpy+0x40>
  80094c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800950:	42                   	inc    %edx
  800951:	84 c9                	test   %cl,%cl
  800953:	75 f0                	jne    800945 <strlcpy+0x28>
  800955:	eb 06                	jmp    80095d <strlcpy+0x40>
  800957:	89 f8                	mov    %edi,%eax
  800959:	eb 02                	jmp    80095d <strlcpy+0x40>
  80095b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80095d:	c6 00 00             	movb   $0x0,(%eax)
  800960:	eb 02                	jmp    800964 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800962:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800964:	29 f8                	sub    %edi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	8a 01                	mov    (%ecx),%al
  800976:	84 c0                	test   %al,%al
  800978:	74 10                	je     80098a <strcmp+0x1f>
  80097a:	3a 02                	cmp    (%edx),%al
  80097c:	75 0c                	jne    80098a <strcmp+0x1f>
		p++, q++;
  80097e:	41                   	inc    %ecx
  80097f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800980:	8a 01                	mov    (%ecx),%al
  800982:	84 c0                	test   %al,%al
  800984:	74 04                	je     80098a <strcmp+0x1f>
  800986:	3a 02                	cmp    (%edx),%al
  800988:	74 f4                	je     80097e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 c0             	movzbl %al,%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	53                   	push   %ebx
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	74 1b                	je     8009c0 <strncmp+0x2c>
  8009a5:	8a 1a                	mov    (%edx),%bl
  8009a7:	84 db                	test   %bl,%bl
  8009a9:	74 24                	je     8009cf <strncmp+0x3b>
  8009ab:	3a 19                	cmp    (%ecx),%bl
  8009ad:	75 20                	jne    8009cf <strncmp+0x3b>
  8009af:	48                   	dec    %eax
  8009b0:	74 15                	je     8009c7 <strncmp+0x33>
		n--, p++, q++;
  8009b2:	42                   	inc    %edx
  8009b3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b4:	8a 1a                	mov    (%edx),%bl
  8009b6:	84 db                	test   %bl,%bl
  8009b8:	74 15                	je     8009cf <strncmp+0x3b>
  8009ba:	3a 19                	cmp    (%ecx),%bl
  8009bc:	74 f1                	je     8009af <strncmp+0x1b>
  8009be:	eb 0f                	jmp    8009cf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	eb 05                	jmp    8009cc <strncmp+0x38>
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cf:	0f b6 02             	movzbl (%edx),%eax
  8009d2:	0f b6 11             	movzbl (%ecx),%edx
  8009d5:	29 d0                	sub    %edx,%eax
  8009d7:	eb f3                	jmp    8009cc <strncmp+0x38>

008009d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009e2:	8a 10                	mov    (%eax),%dl
  8009e4:	84 d2                	test   %dl,%dl
  8009e6:	74 18                	je     800a00 <strchr+0x27>
		if (*s == c)
  8009e8:	38 ca                	cmp    %cl,%dl
  8009ea:	75 06                	jne    8009f2 <strchr+0x19>
  8009ec:	eb 17                	jmp    800a05 <strchr+0x2c>
  8009ee:	38 ca                	cmp    %cl,%dl
  8009f0:	74 13                	je     800a05 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	40                   	inc    %eax
  8009f3:	8a 10                	mov    (%eax),%dl
  8009f5:	84 d2                	test   %dl,%dl
  8009f7:	75 f5                	jne    8009ee <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	eb 05                	jmp    800a05 <strchr+0x2c>
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a10:	8a 10                	mov    (%eax),%dl
  800a12:	84 d2                	test   %dl,%dl
  800a14:	74 11                	je     800a27 <strfind+0x20>
		if (*s == c)
  800a16:	38 ca                	cmp    %cl,%dl
  800a18:	75 06                	jne    800a20 <strfind+0x19>
  800a1a:	eb 0b                	jmp    800a27 <strfind+0x20>
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 07                	je     800a27 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a20:	40                   	inc    %eax
  800a21:	8a 10                	mov    (%eax),%dl
  800a23:	84 d2                	test   %dl,%dl
  800a25:	75 f5                	jne    800a1c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a38:	85 c9                	test   %ecx,%ecx
  800a3a:	74 30                	je     800a6c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a42:	75 25                	jne    800a69 <memset+0x40>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 20                	jne    800a69 <memset+0x40>
		c &= 0xFF;
  800a49:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4c:	89 d3                	mov    %edx,%ebx
  800a4e:	c1 e3 08             	shl    $0x8,%ebx
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	c1 e6 18             	shl    $0x18,%esi
  800a56:	89 d0                	mov    %edx,%eax
  800a58:	c1 e0 10             	shl    $0x10,%eax
  800a5b:	09 f0                	or     %esi,%eax
  800a5d:	09 d0                	or     %edx,%eax
  800a5f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a61:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a64:	fc                   	cld    
  800a65:	f3 ab                	rep stos %eax,%es:(%edi)
  800a67:	eb 03                	jmp    800a6c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a69:	fc                   	cld    
  800a6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6c:	89 f8                	mov    %edi,%eax
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a81:	39 c6                	cmp    %eax,%esi
  800a83:	73 34                	jae    800ab9 <memmove+0x46>
  800a85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a88:	39 d0                	cmp    %edx,%eax
  800a8a:	73 2d                	jae    800ab9 <memmove+0x46>
		s += n;
		d += n;
  800a8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 1b                	jne    800aaf <memmove+0x3c>
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 13                	jne    800aaf <memmove+0x3c>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 0e                	jne    800aaf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa1:	83 ef 04             	sub    $0x4,%edi
  800aa4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aaa:	fd                   	std    
  800aab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aad:	eb 07                	jmp    800ab6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aaf:	4f                   	dec    %edi
  800ab0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab3:	fd                   	std    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab6:	fc                   	cld    
  800ab7:	eb 20                	jmp    800ad9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abf:	75 13                	jne    800ad4 <memmove+0x61>
  800ac1:	a8 03                	test   $0x3,%al
  800ac3:	75 0f                	jne    800ad4 <memmove+0x61>
  800ac5:	f6 c1 03             	test   $0x3,%cl
  800ac8:	75 0a                	jne    800ad4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad2:	eb 05                	jmp    800ad9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae0:	ff 75 10             	pushl  0x10(%ebp)
  800ae3:	ff 75 0c             	pushl  0xc(%ebp)
  800ae6:	ff 75 08             	pushl  0x8(%ebp)
  800ae9:	e8 85 ff ff ff       	call   800a73 <memmove>
}
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	85 ff                	test   %edi,%edi
  800b01:	74 32                	je     800b35 <memcmp+0x45>
		if (*s1 != *s2)
  800b03:	8a 03                	mov    (%ebx),%al
  800b05:	8a 0e                	mov    (%esi),%cl
  800b07:	38 c8                	cmp    %cl,%al
  800b09:	74 19                	je     800b24 <memcmp+0x34>
  800b0b:	eb 0d                	jmp    800b1a <memcmp+0x2a>
  800b0d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b11:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b15:	42                   	inc    %edx
  800b16:	38 c8                	cmp    %cl,%al
  800b18:	74 10                	je     800b2a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b1a:	0f b6 c0             	movzbl %al,%eax
  800b1d:	0f b6 c9             	movzbl %cl,%ecx
  800b20:	29 c8                	sub    %ecx,%eax
  800b22:	eb 16                	jmp    800b3a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b24:	4f                   	dec    %edi
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	39 fa                	cmp    %edi,%edx
  800b2c:	75 df                	jne    800b0d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	eb 05                	jmp    800b3a <memcmp+0x4a>
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b45:	89 c2                	mov    %eax,%edx
  800b47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4a:	39 d0                	cmp    %edx,%eax
  800b4c:	73 12                	jae    800b60 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b51:	38 08                	cmp    %cl,(%eax)
  800b53:	75 06                	jne    800b5b <memfind+0x1c>
  800b55:	eb 09                	jmp    800b60 <memfind+0x21>
  800b57:	38 08                	cmp    %cl,(%eax)
  800b59:	74 05                	je     800b60 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5b:	40                   	inc    %eax
  800b5c:	39 c2                	cmp    %eax,%edx
  800b5e:	77 f7                	ja     800b57 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6e:	eb 01                	jmp    800b71 <strtol+0xf>
		s++;
  800b70:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b71:	8a 02                	mov    (%edx),%al
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f9                	je     800b70 <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f5                	je     800b70 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 08                	jne    800b87 <strtol+0x25>
		s++;
  800b7f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
  800b85:	eb 13                	jmp    800b9a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b87:	3c 2d                	cmp    $0x2d,%al
  800b89:	75 0a                	jne    800b95 <strtol+0x33>
		s++, neg = 1;
  800b8b:	8d 52 01             	lea    0x1(%edx),%edx
  800b8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b93:	eb 05                	jmp    800b9a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	85 db                	test   %ebx,%ebx
  800b9c:	74 05                	je     800ba3 <strtol+0x41>
  800b9e:	83 fb 10             	cmp    $0x10,%ebx
  800ba1:	75 28                	jne    800bcb <strtol+0x69>
  800ba3:	8a 02                	mov    (%edx),%al
  800ba5:	3c 30                	cmp    $0x30,%al
  800ba7:	75 10                	jne    800bb9 <strtol+0x57>
  800ba9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bad:	75 0a                	jne    800bb9 <strtol+0x57>
		s += 2, base = 16;
  800baf:	83 c2 02             	add    $0x2,%edx
  800bb2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb7:	eb 12                	jmp    800bcb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bb9:	85 db                	test   %ebx,%ebx
  800bbb:	75 0e                	jne    800bcb <strtol+0x69>
  800bbd:	3c 30                	cmp    $0x30,%al
  800bbf:	75 05                	jne    800bc6 <strtol+0x64>
		s++, base = 8;
  800bc1:	42                   	inc    %edx
  800bc2:	b3 08                	mov    $0x8,%bl
  800bc4:	eb 05                	jmp    800bcb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bc6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd2:	8a 0a                	mov    (%edx),%cl
  800bd4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd7:	80 fb 09             	cmp    $0x9,%bl
  800bda:	77 08                	ja     800be4 <strtol+0x82>
			dig = *s - '0';
  800bdc:	0f be c9             	movsbl %cl,%ecx
  800bdf:	83 e9 30             	sub    $0x30,%ecx
  800be2:	eb 1e                	jmp    800c02 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800be4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bec:	0f be c9             	movsbl %cl,%ecx
  800bef:	83 e9 57             	sub    $0x57,%ecx
  800bf2:	eb 0e                	jmp    800c02 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bf7:	80 fb 19             	cmp    $0x19,%bl
  800bfa:	77 13                	ja     800c0f <strtol+0xad>
			dig = *s - 'A' + 10;
  800bfc:	0f be c9             	movsbl %cl,%ecx
  800bff:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c02:	39 f1                	cmp    %esi,%ecx
  800c04:	7d 0d                	jge    800c13 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c06:	42                   	inc    %edx
  800c07:	0f af c6             	imul   %esi,%eax
  800c0a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c0d:	eb c3                	jmp    800bd2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c0f:	89 c1                	mov    %eax,%ecx
  800c11:	eb 02                	jmp    800c15 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c13:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c19:	74 05                	je     800c20 <strtol+0xbe>
		*endptr = (char *) s;
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c20:	85 ff                	test   %edi,%edi
  800c22:	74 04                	je     800c28 <strtol+0xc6>
  800c24:	89 c8                	mov    %ecx,%eax
  800c26:	f7 d8                	neg    %eax
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    
  800c2d:	00 00                	add    %al,(%eax)
	...

00800c30 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 1c             	sub    $0x1c,%esp
  800c39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c3f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	8b 75 14             	mov    0x14(%ebp),%esi
  800c44:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4d:	cd 30                	int    $0x30
  800c4f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c55:	74 1c                	je     800c73 <syscall+0x43>
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 18                	jle    800c73 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c62:	68 ff 26 80 00       	push   $0x8026ff
  800c67:	6a 42                	push   $0x42
  800c69:	68 1c 27 80 00       	push   $0x80271c
  800c6e:	e8 b1 f5 ff ff       	call   800224 <_panic>

	return ret;
}
  800c73:	89 d0                	mov    %edx,%eax
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	ff 75 0c             	pushl  0xc(%ebp)
  800c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 00 00 00 00       	mov    $0x0,%eax
  800c99:	e8 92 ff ff ff       	call   800c30 <syscall>
  800c9e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	6a 00                	push   $0x0
  800caf:	6a 00                	push   $0x0
  800cb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc0:	e8 6b ff ff ff       	call   800c30 <syscall>
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ccd:	6a 00                	push   $0x0
  800ccf:	6a 00                	push   $0x0
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce2:	e8 49 ff ff ff       	call   800c30 <syscall>
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	6a 00                	push   $0x0
  800cf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800d01:	b8 02 00 00 00       	mov    $0x2,%eax
  800d06:	e8 25 ff ff ff       	call   800c30 <syscall>
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <sys_yield>:

void
sys_yield(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d13:	6a 00                	push   $0x0
  800d15:	6a 00                	push   $0x0
  800d17:	6a 00                	push   $0x0
  800d19:	6a 00                	push   $0x0
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2a:	e8 01 ff ff ff       	call   800c30 <syscall>
  800d2f:	83 c4 10             	add    $0x10,%esp
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d3a:	6a 00                	push   $0x0
  800d3c:	6a 00                	push   $0x0
  800d3e:	ff 75 10             	pushl  0x10(%ebp)
  800d41:	ff 75 0c             	pushl  0xc(%ebp)
  800d44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d47:	ba 01 00 00 00       	mov    $0x1,%edx
  800d4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d51:	e8 da fe ff ff       	call   800c30 <syscall>
}
  800d56:	c9                   	leave  
  800d57:	c3                   	ret    

00800d58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d5e:	ff 75 18             	pushl  0x18(%ebp)
  800d61:	ff 75 14             	pushl  0x14(%ebp)
  800d64:	ff 75 10             	pushl  0x10(%ebp)
  800d67:	ff 75 0c             	pushl  0xc(%ebp)
  800d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d72:	b8 05 00 00 00       	mov    $0x5,%eax
  800d77:	e8 b4 fe ff ff       	call   800c30 <syscall>
}
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d84:	6a 00                	push   $0x0
  800d86:	6a 00                	push   $0x0
  800d88:	6a 00                	push   $0x0
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	ba 01 00 00 00       	mov    $0x1,%edx
  800d95:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9a:	e8 91 fe ff ff       	call   800c30 <syscall>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800da7:	6a 00                	push   $0x0
  800da9:	6a 00                	push   $0x0
  800dab:	6a 00                	push   $0x0
  800dad:	ff 75 0c             	pushl  0xc(%ebp)
  800db0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db3:	ba 01 00 00 00       	mov    $0x1,%edx
  800db8:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbd:	e8 6e fe ff ff       	call   800c30 <syscall>
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dca:	6a 00                	push   $0x0
  800dcc:	6a 00                	push   $0x0
  800dce:	6a 00                	push   $0x0
  800dd0:	ff 75 0c             	pushl  0xc(%ebp)
  800dd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ddb:	b8 09 00 00 00       	mov    $0x9,%eax
  800de0:	e8 4b fe ff ff       	call   800c30 <syscall>
}
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	ff 75 0c             	pushl  0xc(%ebp)
  800df6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	e8 28 fe ff ff       	call   800c30 <syscall>
}
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e10:	6a 00                	push   $0x0
  800e12:	ff 75 14             	pushl  0x14(%ebp)
  800e15:	ff 75 10             	pushl  0x10(%ebp)
  800e18:	ff 75 0c             	pushl  0xc(%ebp)
  800e1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e28:	e8 03 fe ff ff       	call   800c30 <syscall>
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e35:	6a 00                	push   $0x0
  800e37:	6a 00                	push   $0x0
  800e39:	6a 00                	push   $0x0
  800e3b:	6a 00                	push   $0x0
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	ba 01 00 00 00       	mov    $0x1,%edx
  800e45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4a:	e8 e1 fd ff ff       	call   800c30 <syscall>
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e57:	6a 00                	push   $0x0
  800e59:	6a 00                	push   $0x0
  800e5b:	6a 00                	push   $0x0
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 00 00 00 00       	mov    $0x0,%edx
  800e68:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e6d:	e8 be fd ff ff       	call   800c30 <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e7a:	6a 00                	push   $0x0
  800e7c:	ff 75 14             	pushl  0x14(%ebp)
  800e7f:	ff 75 10             	pushl  0x10(%ebp)
  800e82:	ff 75 0c             	pushl  0xc(%ebp)
  800e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e92:	e8 99 fd ff ff       	call   800c30 <syscall>
} 
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800e9f:	6a 00                	push   $0x0
  800ea1:	6a 00                	push   $0x0
  800ea3:	6a 00                	push   $0x0
  800ea5:	6a 00                	push   $0x0
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 11 00 00 00       	mov    $0x11,%eax
  800eb4:	e8 77 fd ff ff       	call   800c30 <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <sys_getpid>:

envid_t
sys_getpid(void)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800ec1:	6a 00                	push   $0x0
  800ec3:	6a 00                	push   $0x0
  800ec5:	6a 00                	push   $0x0
  800ec7:	6a 00                	push   $0x0
  800ec9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ece:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed3:	b8 10 00 00 00       	mov    $0x10,%eax
  800ed8:	e8 53 fd ff ff       	call   800c30 <syscall>
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    
	...

00800ee0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eea:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800eec:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef0:	75 14                	jne    800f06 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	68 2c 27 80 00       	push   $0x80272c
  800efa:	6a 20                	push   $0x20
  800efc:	68 70 28 80 00       	push   $0x802870
  800f01:	e8 1e f3 ff ff       	call   800224 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f06:	89 d8                	mov    %ebx,%eax
  800f08:	c1 e8 16             	shr    $0x16,%eax
  800f0b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f12:	a8 01                	test   $0x1,%al
  800f14:	74 11                	je     800f27 <pgfault+0x47>
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	c1 e8 0c             	shr    $0xc,%eax
  800f1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f22:	f6 c4 08             	test   $0x8,%ah
  800f25:	75 14                	jne    800f3b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	68 50 27 80 00       	push   $0x802750
  800f2f:	6a 24                	push   $0x24
  800f31:	68 70 28 80 00       	push   $0x802870
  800f36:	e8 e9 f2 ff ff       	call   800224 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	6a 07                	push   $0x7
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	6a 00                	push   $0x0
  800f47:	e8 e8 fd ff ff       	call   800d34 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 12                	jns    800f65 <pgfault+0x85>
  800f53:	50                   	push   %eax
  800f54:	68 74 27 80 00       	push   $0x802774
  800f59:	6a 32                	push   $0x32
  800f5b:	68 70 28 80 00       	push   $0x802870
  800f60:	e8 bf f2 ff ff       	call   800224 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f65:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	68 00 10 00 00       	push   $0x1000
  800f73:	53                   	push   %ebx
  800f74:	68 00 f0 7f 00       	push   $0x7ff000
  800f79:	e8 5f fb ff ff       	call   800add <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f7e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f85:	53                   	push   %ebx
  800f86:	6a 00                	push   $0x0
  800f88:	68 00 f0 7f 00       	push   $0x7ff000
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 c4 fd ff ff       	call   800d58 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 12                	jns    800fad <pgfault+0xcd>
  800f9b:	50                   	push   %eax
  800f9c:	68 98 27 80 00       	push   $0x802798
  800fa1:	6a 3a                	push   $0x3a
  800fa3:	68 70 28 80 00       	push   $0x802870
  800fa8:	e8 77 f2 ff ff       	call   800224 <_panic>

	return;
}
  800fad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fbb:	68 e0 0e 80 00       	push   $0x800ee0
  800fc0:	e8 e7 0e 00 00       	call   801eac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc5:	ba 07 00 00 00       	mov    $0x7,%edx
  800fca:	89 d0                	mov    %edx,%eax
  800fcc:	cd 30                	int    $0x30
  800fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd1:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	79 12                	jns    800fec <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800fda:	50                   	push   %eax
  800fdb:	68 7b 28 80 00       	push   $0x80287b
  800fe0:	6a 7f                	push   $0x7f
  800fe2:	68 70 28 80 00       	push   $0x802870
  800fe7:	e8 38 f2 ff ff       	call   800224 <_panic>
	}
	int r;

	if (childpid == 0) {
  800fec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ff0:	75 20                	jne    801012 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff2:	e8 f2 fc ff ff       	call   800ce9 <sys_getenvid>
  800ff7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	c1 e2 07             	shl    $0x7,%edx
  801001:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801008:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  80100d:	e9 be 01 00 00       	jmp    8011d0 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  801017:	89 d8                	mov    %ebx,%eax
  801019:	c1 e8 16             	shr    $0x16,%eax
  80101c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801023:	a8 01                	test   $0x1,%al
  801025:	0f 84 10 01 00 00    	je     80113b <fork+0x189>
  80102b:	89 d8                	mov    %ebx,%eax
  80102d:	c1 e8 0c             	shr    $0xc,%eax
  801030:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801037:	f6 c2 01             	test   $0x1,%dl
  80103a:	0f 84 fb 00 00 00    	je     80113b <fork+0x189>
  801040:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801047:	f6 c2 04             	test   $0x4,%dl
  80104a:	0f 84 eb 00 00 00    	je     80113b <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801050:	89 c6                	mov    %eax,%esi
  801052:	c1 e6 0c             	shl    $0xc,%esi
  801055:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  80105b:	0f 84 da 00 00 00    	je     80113b <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801061:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801068:	f6 c6 04             	test   $0x4,%dh
  80106b:	74 37                	je     8010a4 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80106d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	25 07 0e 00 00       	and    $0xe07,%eax
  80107c:	50                   	push   %eax
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	e8 d1 fc ff ff       	call   800d58 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	0f 89 a9 00 00 00    	jns    80113b <fork+0x189>
  801092:	50                   	push   %eax
  801093:	68 bc 27 80 00       	push   $0x8027bc
  801098:	6a 54                	push   $0x54
  80109a:	68 70 28 80 00       	push   $0x802870
  80109f:	e8 80 f1 ff ff       	call   800224 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ab:	f6 c2 02             	test   $0x2,%dl
  8010ae:	75 0c                	jne    8010bc <fork+0x10a>
  8010b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b7:	f6 c4 08             	test   $0x8,%ah
  8010ba:	74 57                	je     801113 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	68 05 08 00 00       	push   $0x805
  8010c4:	56                   	push   %esi
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 8a fc ff ff       	call   800d58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ce:	83 c4 20             	add    $0x20,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 12                	jns    8010e7 <fork+0x135>
  8010d5:	50                   	push   %eax
  8010d6:	68 bc 27 80 00       	push   $0x8027bc
  8010db:	6a 59                	push   $0x59
  8010dd:	68 70 28 80 00       	push   $0x802870
  8010e2:	e8 3d f1 ff ff       	call   800224 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	68 05 08 00 00       	push   $0x805
  8010ef:	56                   	push   %esi
  8010f0:	6a 00                	push   $0x0
  8010f2:	56                   	push   %esi
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 5e fc ff ff       	call   800d58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	79 3a                	jns    80113b <fork+0x189>
  801101:	50                   	push   %eax
  801102:	68 bc 27 80 00       	push   $0x8027bc
  801107:	6a 5c                	push   $0x5c
  801109:	68 70 28 80 00       	push   $0x802870
  80110e:	e8 11 f1 ff ff       	call   800224 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	6a 05                	push   $0x5
  801118:	56                   	push   %esi
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	6a 00                	push   $0x0
  80111d:	e8 36 fc ff ff       	call   800d58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801122:	83 c4 20             	add    $0x20,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	79 12                	jns    80113b <fork+0x189>
  801129:	50                   	push   %eax
  80112a:	68 bc 27 80 00       	push   $0x8027bc
  80112f:	6a 60                	push   $0x60
  801131:	68 70 28 80 00       	push   $0x802870
  801136:	e8 e9 f0 ff ff       	call   800224 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80113b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801141:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801147:	0f 85 ca fe ff ff    	jne    801017 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	6a 07                	push   $0x7
  801152:	68 00 f0 bf ee       	push   $0xeebff000
  801157:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115a:	e8 d5 fb ff ff       	call   800d34 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	79 15                	jns    80117b <fork+0x1c9>
  801166:	50                   	push   %eax
  801167:	68 e0 27 80 00       	push   $0x8027e0
  80116c:	68 94 00 00 00       	push   $0x94
  801171:	68 70 28 80 00       	push   $0x802870
  801176:	e8 a9 f0 ff ff       	call   800224 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	68 18 1f 80 00       	push   $0x801f18
  801183:	ff 75 e4             	pushl  -0x1c(%ebp)
  801186:	e8 5c fc ff ff       	call   800de7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 15                	jns    8011a7 <fork+0x1f5>
  801192:	50                   	push   %eax
  801193:	68 18 28 80 00       	push   $0x802818
  801198:	68 99 00 00 00       	push   $0x99
  80119d:	68 70 28 80 00       	push   $0x802870
  8011a2:	e8 7d f0 ff ff       	call   800224 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	6a 02                	push   $0x2
  8011ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011af:	e8 ed fb ff ff       	call   800da1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	79 15                	jns    8011d0 <fork+0x21e>
  8011bb:	50                   	push   %eax
  8011bc:	68 3c 28 80 00       	push   $0x80283c
  8011c1:	68 a4 00 00 00       	push   $0xa4
  8011c6:	68 70 28 80 00       	push   $0x802870
  8011cb:	e8 54 f0 ff ff       	call   800224 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8011d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <sfork>:

// Challenge!
int
sfork(void)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011e1:	68 98 28 80 00       	push   $0x802898
  8011e6:	68 b1 00 00 00       	push   $0xb1
  8011eb:	68 70 28 80 00       	push   $0x802870
  8011f0:	e8 2f f0 ff ff       	call   800224 <_panic>
  8011f5:	00 00                	add    %al,(%eax)
	...

008011f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801203:	c1 e8 0c             	shr    $0xc,%eax
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80120b:	ff 75 08             	pushl  0x8(%ebp)
  80120e:	e8 e5 ff ff ff       	call   8011f8 <fd2num>
  801213:	83 c4 04             	add    $0x4,%esp
  801216:	05 20 00 0d 00       	add    $0xd0020,%eax
  80121b:	c1 e0 0c             	shl    $0xc,%eax
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801227:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80122c:	a8 01                	test   $0x1,%al
  80122e:	74 34                	je     801264 <fd_alloc+0x44>
  801230:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801235:	a8 01                	test   $0x1,%al
  801237:	74 32                	je     80126b <fd_alloc+0x4b>
  801239:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80123e:	89 c1                	mov    %eax,%ecx
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 16             	shr    $0x16,%edx
  801245:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	74 1f                	je     801270 <fd_alloc+0x50>
  801251:	89 c2                	mov    %eax,%edx
  801253:	c1 ea 0c             	shr    $0xc,%edx
  801256:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125d:	f6 c2 01             	test   $0x1,%dl
  801260:	75 17                	jne    801279 <fd_alloc+0x59>
  801262:	eb 0c                	jmp    801270 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801264:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801269:	eb 05                	jmp    801270 <fd_alloc+0x50>
  80126b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801270:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
  801277:	eb 17                	jmp    801290 <fd_alloc+0x70>
  801279:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801283:	75 b9                	jne    80123e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801285:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80128b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801290:	5b                   	pop    %ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801299:	83 f8 1f             	cmp    $0x1f,%eax
  80129c:	77 36                	ja     8012d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129e:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012a3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 16             	shr    $0x16,%edx
  8012ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 24                	je     8012db <fd_lookup+0x48>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 1a                	je     8012e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	eb 13                	jmp    8012e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb 0c                	jmp    8012e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 05                	jmp    8012e7 <fd_lookup+0x54>
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012f6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012fc:	74 0d                	je     80130b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 14                	jmp    801319 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801305:	39 0a                	cmp    %ecx,(%edx)
  801307:	75 10                	jne    801319 <dev_lookup+0x30>
  801309:	eb 05                	jmp    801310 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80130b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801310:	89 13                	mov    %edx,(%ebx)
			return 0;
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
  801317:	eb 31                	jmp    80134a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801319:	40                   	inc    %eax
  80131a:	8b 14 85 2c 29 80 00 	mov    0x80292c(,%eax,4),%edx
  801321:	85 d2                	test   %edx,%edx
  801323:	75 e0                	jne    801305 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801325:	a1 04 40 80 00       	mov    0x804004,%eax
  80132a:	8b 40 48             	mov    0x48(%eax),%eax
  80132d:	83 ec 04             	sub    $0x4,%esp
  801330:	51                   	push   %ecx
  801331:	50                   	push   %eax
  801332:	68 b0 28 80 00       	push   $0x8028b0
  801337:	e8 c0 ef ff ff       	call   8002fc <cprintf>
	*dev = 0;
  80133c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
  801354:	83 ec 20             	sub    $0x20,%esp
  801357:	8b 75 08             	mov    0x8(%ebp),%esi
  80135a:	8a 45 0c             	mov    0xc(%ebp),%al
  80135d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801360:	56                   	push   %esi
  801361:	e8 92 fe ff ff       	call   8011f8 <fd2num>
  801366:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801369:	89 14 24             	mov    %edx,(%esp)
  80136c:	50                   	push   %eax
  80136d:	e8 21 ff ff ff       	call   801293 <fd_lookup>
  801372:	89 c3                	mov    %eax,%ebx
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 05                	js     801380 <fd_close+0x31>
	    || fd != fd2)
  80137b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80137e:	74 0d                	je     80138d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801380:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801384:	75 48                	jne    8013ce <fd_close+0x7f>
  801386:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138b:	eb 41                	jmp    8013ce <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	ff 36                	pushl  (%esi)
  801396:	e8 4e ff ff ff       	call   8012e9 <dev_lookup>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 1c                	js     8013c0 <fd_close+0x71>
		if (dev->dev_close)
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	8b 40 10             	mov    0x10(%eax),%eax
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	74 0d                	je     8013bb <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	56                   	push   %esi
  8013b2:	ff d0                	call   *%eax
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	eb 05                	jmp    8013c0 <fd_close+0x71>
		else
			r = 0;
  8013bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	56                   	push   %esi
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 b3 f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8013cb:	83 c4 10             	add    $0x10,%esp
}
  8013ce:	89 d8                	mov    %ebx,%eax
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 aa fe ff ff       	call   801293 <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 10                	js     801400 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	6a 01                	push   $0x1
  8013f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f8:	e8 52 ff ff ff       	call   80134f <fd_close>
  8013fd:	83 c4 10             	add    $0x10,%esp
}
  801400:	c9                   	leave  
  801401:	c3                   	ret    

00801402 <close_all>:

void
close_all(void)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	53                   	push   %ebx
  801406:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801409:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	53                   	push   %ebx
  801412:	e8 c0 ff ff ff       	call   8013d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801417:	43                   	inc    %ebx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	83 fb 20             	cmp    $0x20,%ebx
  80141e:	75 ee                	jne    80140e <close_all+0xc>
		close(i);
}
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 2c             	sub    $0x2c,%esp
  80142e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801431:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 56 fe ff ff       	call   801293 <fd_lookup>
  80143d:	89 c3                	mov    %eax,%ebx
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	0f 88 c0 00 00 00    	js     80150a <dup+0xe5>
		return r;
	close(newfdnum);
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	57                   	push   %edi
  80144e:	e8 84 ff ff ff       	call   8013d7 <close>

	newfd = INDEX2FD(newfdnum);
  801453:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801459:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80145c:	83 c4 04             	add    $0x4,%esp
  80145f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801462:	e8 a1 fd ff ff       	call   801208 <fd2data>
  801467:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801469:	89 34 24             	mov    %esi,(%esp)
  80146c:	e8 97 fd ff ff       	call   801208 <fd2data>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801477:	89 d8                	mov    %ebx,%eax
  801479:	c1 e8 16             	shr    $0x16,%eax
  80147c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801483:	a8 01                	test   $0x1,%al
  801485:	74 37                	je     8014be <dup+0x99>
  801487:	89 d8                	mov    %ebx,%eax
  801489:	c1 e8 0c             	shr    $0xc,%eax
  80148c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 26                	je     8014be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801498:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149f:	83 ec 0c             	sub    $0xc,%esp
  8014a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ab:	6a 00                	push   $0x0
  8014ad:	53                   	push   %ebx
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 a3 f8 ff ff       	call   800d58 <sys_page_map>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 20             	add    $0x20,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 2d                	js     8014eb <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 0c             	shr    $0xc,%edx
  8014c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014d6:	52                   	push   %edx
  8014d7:	56                   	push   %esi
  8014d8:	6a 00                	push   $0x0
  8014da:	50                   	push   %eax
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 76 f8 ff ff       	call   800d58 <sys_page_map>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	83 c4 20             	add    $0x20,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	79 1d                	jns    801508 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	56                   	push   %esi
  8014ef:	6a 00                	push   $0x0
  8014f1:	e8 88 f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014fc:	6a 00                	push   $0x0
  8014fe:	e8 7b f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	eb 02                	jmp    80150a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801508:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80150a:	89 d8                	mov    %ebx,%eax
  80150c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5f                   	pop    %edi
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 14             	sub    $0x14,%esp
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	53                   	push   %ebx
  801523:	e8 6b fd ff ff       	call   801293 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 67                	js     801596 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801539:	ff 30                	pushl  (%eax)
  80153b:	e8 a9 fd ff ff       	call   8012e9 <dev_lookup>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 4f                	js     801596 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	8b 50 08             	mov    0x8(%eax),%edx
  80154d:	83 e2 03             	and    $0x3,%edx
  801550:	83 fa 01             	cmp    $0x1,%edx
  801553:	75 21                	jne    801576 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801555:	a1 04 40 80 00       	mov    0x804004,%eax
  80155a:	8b 40 48             	mov    0x48(%eax),%eax
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	53                   	push   %ebx
  801561:	50                   	push   %eax
  801562:	68 f1 28 80 00       	push   $0x8028f1
  801567:	e8 90 ed ff ff       	call   8002fc <cprintf>
		return -E_INVAL;
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801574:	eb 20                	jmp    801596 <read+0x82>
	}
	if (!dev->dev_read)
  801576:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801579:	8b 52 08             	mov    0x8(%edx),%edx
  80157c:	85 d2                	test   %edx,%edx
  80157e:	74 11                	je     801591 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	ff 75 10             	pushl  0x10(%ebp)
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	50                   	push   %eax
  80158a:	ff d2                	call   *%edx
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	eb 05                	jmp    801596 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801591:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801596:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 0c             	sub    $0xc,%esp
  8015a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015aa:	85 f6                	test   %esi,%esi
  8015ac:	74 31                	je     8015df <readn+0x44>
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	89 f2                	mov    %esi,%edx
  8015bd:	29 c2                	sub    %eax,%edx
  8015bf:	52                   	push   %edx
  8015c0:	03 45 0c             	add    0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	57                   	push   %edi
  8015c5:	e8 4a ff ff ff       	call   801514 <read>
		if (m < 0)
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 17                	js     8015e8 <readn+0x4d>
			return m;
		if (m == 0)
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	74 11                	je     8015e6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d5:	01 c3                	add    %eax,%ebx
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	39 f3                	cmp    %esi,%ebx
  8015db:	72 db                	jb     8015b8 <readn+0x1d>
  8015dd:	eb 09                	jmp    8015e8 <readn+0x4d>
  8015df:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e4:	eb 02                	jmp    8015e8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015e6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	53                   	push   %ebx
  8015ff:	e8 8f fc ff ff       	call   801293 <fd_lookup>
  801604:	83 c4 08             	add    $0x8,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 62                	js     80166d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 cd fc ff ff       	call   8012e9 <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 4a                	js     80166d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162a:	75 21                	jne    80164d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162c:	a1 04 40 80 00       	mov    0x804004,%eax
  801631:	8b 40 48             	mov    0x48(%eax),%eax
  801634:	83 ec 04             	sub    $0x4,%esp
  801637:	53                   	push   %ebx
  801638:	50                   	push   %eax
  801639:	68 0d 29 80 00       	push   $0x80290d
  80163e:	e8 b9 ec ff ff       	call   8002fc <cprintf>
		return -E_INVAL;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb 20                	jmp    80166d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 0c             	mov    0xc(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 11                	je     801668 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801657:	83 ec 04             	sub    $0x4,%esp
  80165a:	ff 75 10             	pushl  0x10(%ebp)
  80165d:	ff 75 0c             	pushl  0xc(%ebp)
  801660:	50                   	push   %eax
  801661:	ff d2                	call   *%edx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	eb 05                	jmp    80166d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801668:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <seek>:

int
seek(int fdnum, off_t offset)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801678:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 0f fc ff ff       	call   801293 <fd_lookup>
  801684:	83 c4 08             	add    $0x8,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 0e                	js     801699 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80168b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801691:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	53                   	push   %ebx
  80169f:	83 ec 14             	sub    $0x14,%esp
  8016a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	53                   	push   %ebx
  8016aa:	e8 e4 fb ff ff       	call   801293 <fd_lookup>
  8016af:	83 c4 08             	add    $0x8,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 5f                	js     801715 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	50                   	push   %eax
  8016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c0:	ff 30                	pushl  (%eax)
  8016c2:	e8 22 fc ff ff       	call   8012e9 <dev_lookup>
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 47                	js     801715 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d5:	75 21                	jne    8016f8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016dc:	8b 40 48             	mov    0x48(%eax),%eax
  8016df:	83 ec 04             	sub    $0x4,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	50                   	push   %eax
  8016e4:	68 d0 28 80 00       	push   $0x8028d0
  8016e9:	e8 0e ec ff ff       	call   8002fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f6:	eb 1d                	jmp    801715 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fb:	8b 52 18             	mov    0x18(%edx),%edx
  8016fe:	85 d2                	test   %edx,%edx
  801700:	74 0e                	je     801710 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	ff 75 0c             	pushl  0xc(%ebp)
  801708:	50                   	push   %eax
  801709:	ff d2                	call   *%edx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 05                	jmp    801715 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801710:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 14             	sub    $0x14,%esp
  801721:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801724:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801727:	50                   	push   %eax
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 63 fb ff ff       	call   801293 <fd_lookup>
  801730:	83 c4 08             	add    $0x8,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 52                	js     801789 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801741:	ff 30                	pushl  (%eax)
  801743:	e8 a1 fb ff ff       	call   8012e9 <dev_lookup>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 3a                	js     801789 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801756:	74 2c                	je     801784 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801758:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801762:	00 00 00 
	stat->st_isdir = 0;
  801765:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176c:	00 00 00 
	stat->st_dev = dev;
  80176f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	53                   	push   %ebx
  801779:	ff 75 f0             	pushl  -0x10(%ebp)
  80177c:	ff 50 14             	call   *0x14(%eax)
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	eb 05                	jmp    801789 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	6a 00                	push   $0x0
  801798:	ff 75 08             	pushl  0x8(%ebp)
  80179b:	e8 78 01 00 00       	call   801918 <open>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 1b                	js     8017c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	50                   	push   %eax
  8017b0:	e8 65 ff ff ff       	call   80171a <fstat>
  8017b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b7:	89 1c 24             	mov    %ebx,(%esp)
  8017ba:	e8 18 fc ff ff       	call   8013d7 <close>
	return r;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	89 f3                	mov    %esi,%ebx
}
  8017c4:	89 d8                	mov    %ebx,%eax
  8017c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    
  8017cd:	00 00                	add    %al,(%eax)
	...

008017d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e0:	75 12                	jne    8017f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	6a 01                	push   $0x1
  8017e7:	e8 1e 08 00 00       	call   80200a <ipc_find_env>
  8017ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f4:	6a 07                	push   $0x7
  8017f6:	68 00 50 80 00       	push   $0x805000
  8017fb:	53                   	push   %ebx
  8017fc:	ff 35 00 40 80 00    	pushl  0x804000
  801802:	e8 ae 07 00 00       	call   801fb5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801807:	83 c4 0c             	add    $0xc,%esp
  80180a:	6a 00                	push   $0x0
  80180c:	56                   	push   %esi
  80180d:	6a 00                	push   $0x0
  80180f:	e8 2c 07 00 00       	call   801f40 <ipc_recv>
}
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	8b 40 0c             	mov    0xc(%eax),%eax
  80182b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 05 00 00 00       	mov    $0x5,%eax
  80183a:	e8 91 ff ff ff       	call   8017d0 <fsipc>
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 2c                	js     80186f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	68 00 50 80 00       	push   $0x805000
  80184b:	53                   	push   %ebx
  80184c:	e8 61 f0 ff ff       	call   8008b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801851:	a1 80 50 80 00       	mov    0x805080,%eax
  801856:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185c:	a1 84 50 80 00       	mov    0x805084,%eax
  801861:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 06 00 00 00       	mov    $0x6,%eax
  80188f:	e8 3c ff ff ff       	call   8017d0 <fsipc>
}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b9:	e8 12 ff ff ff       	call   8017d0 <fsipc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 4b                	js     80190f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c4:	39 c6                	cmp    %eax,%esi
  8018c6:	73 16                	jae    8018de <devfile_read+0x48>
  8018c8:	68 3c 29 80 00       	push   $0x80293c
  8018cd:	68 43 29 80 00       	push   $0x802943
  8018d2:	6a 7d                	push   $0x7d
  8018d4:	68 58 29 80 00       	push   $0x802958
  8018d9:	e8 46 e9 ff ff       	call   800224 <_panic>
	assert(r <= PGSIZE);
  8018de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e3:	7e 16                	jle    8018fb <devfile_read+0x65>
  8018e5:	68 63 29 80 00       	push   $0x802963
  8018ea:	68 43 29 80 00       	push   $0x802943
  8018ef:	6a 7e                	push   $0x7e
  8018f1:	68 58 29 80 00       	push   $0x802958
  8018f6:	e8 29 e9 ff ff       	call   800224 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	50                   	push   %eax
  8018ff:	68 00 50 80 00       	push   $0x805000
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	e8 67 f1 ff ff       	call   800a73 <memmove>
	return r;
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	83 ec 1c             	sub    $0x1c,%esp
  801920:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801923:	56                   	push   %esi
  801924:	e8 37 ef ff ff       	call   800860 <strlen>
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801931:	7f 65                	jg     801998 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801933:	83 ec 0c             	sub    $0xc,%esp
  801936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801939:	50                   	push   %eax
  80193a:	e8 e1 f8 ff ff       	call   801220 <fd_alloc>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 55                	js     80199d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	56                   	push   %esi
  80194c:	68 00 50 80 00       	push   $0x805000
  801951:	e8 5c ef ff ff       	call   8008b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801956:	8b 45 0c             	mov    0xc(%ebp),%eax
  801959:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801961:	b8 01 00 00 00       	mov    $0x1,%eax
  801966:	e8 65 fe ff ff       	call   8017d0 <fsipc>
  80196b:	89 c3                	mov    %eax,%ebx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	79 12                	jns    801986 <open+0x6e>
		fd_close(fd, 0);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	6a 00                	push   $0x0
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	e8 ce f9 ff ff       	call   80134f <fd_close>
		return r;
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	eb 17                	jmp    80199d <open+0x85>
	}

	return fd2num(fd);
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	ff 75 f4             	pushl  -0xc(%ebp)
  80198c:	e8 67 f8 ff ff       	call   8011f8 <fd2num>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	eb 05                	jmp    80199d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801998:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80199d:	89 d8                	mov    %ebx,%eax
  80199f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    
	...

008019a8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	ff 75 08             	pushl  0x8(%ebp)
  8019b6:	e8 4d f8 ff ff       	call   801208 <fd2data>
  8019bb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019bd:	83 c4 08             	add    $0x8,%esp
  8019c0:	68 6f 29 80 00       	push   $0x80296f
  8019c5:	56                   	push   %esi
  8019c6:	e8 e7 ee ff ff       	call   8008b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ce:	2b 03                	sub    (%ebx),%eax
  8019d0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019d6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019dd:	00 00 00 
	stat->st_dev = &devpipe;
  8019e0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019e7:	30 80 00 
	return 0;
}
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a00:	53                   	push   %ebx
  801a01:	6a 00                	push   $0x0
  801a03:	e8 76 f3 ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 f8 f7 ff ff       	call   801208 <fd2data>
  801a10:	83 c4 08             	add    $0x8,%esp
  801a13:	50                   	push   %eax
  801a14:	6a 00                	push   $0x0
  801a16:	e8 63 f3 ff ff       	call   800d7e <sys_page_unmap>
}
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	57                   	push   %edi
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	83 ec 1c             	sub    $0x1c,%esp
  801a29:	89 c7                	mov    %eax,%edi
  801a2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a33:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	57                   	push   %edi
  801a3a:	e8 19 06 00 00       	call   802058 <pageref>
  801a3f:	89 c6                	mov    %eax,%esi
  801a41:	83 c4 04             	add    $0x4,%esp
  801a44:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a47:	e8 0c 06 00 00       	call   802058 <pageref>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	39 c6                	cmp    %eax,%esi
  801a51:	0f 94 c0             	sete   %al
  801a54:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a60:	39 cb                	cmp    %ecx,%ebx
  801a62:	75 08                	jne    801a6c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a6c:	83 f8 01             	cmp    $0x1,%eax
  801a6f:	75 bd                	jne    801a2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a71:	8b 42 58             	mov    0x58(%edx),%eax
  801a74:	6a 01                	push   $0x1
  801a76:	50                   	push   %eax
  801a77:	53                   	push   %ebx
  801a78:	68 76 29 80 00       	push   $0x802976
  801a7d:	e8 7a e8 ff ff       	call   8002fc <cprintf>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	eb a7                	jmp    801a2e <_pipeisclosed+0xe>

00801a87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	57                   	push   %edi
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 28             	sub    $0x28,%esp
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a93:	56                   	push   %esi
  801a94:	e8 6f f7 ff ff       	call   801208 <fd2data>
  801a99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aa2:	75 4a                	jne    801aee <devpipe_write+0x67>
  801aa4:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa9:	eb 56                	jmp    801b01 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aab:	89 da                	mov    %ebx,%edx
  801aad:	89 f0                	mov    %esi,%eax
  801aaf:	e8 6c ff ff ff       	call   801a20 <_pipeisclosed>
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	75 4d                	jne    801b05 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab8:	e8 50 f2 ff ff       	call   800d0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abd:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac0:	8b 13                	mov    (%ebx),%edx
  801ac2:	83 c2 20             	add    $0x20,%edx
  801ac5:	39 d0                	cmp    %edx,%eax
  801ac7:	73 e2                	jae    801aab <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ad1:	79 05                	jns    801ad8 <devpipe_write+0x51>
  801ad3:	4a                   	dec    %edx
  801ad4:	83 ca e0             	or     $0xffffffe0,%edx
  801ad7:	42                   	inc    %edx
  801ad8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801adb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ade:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae2:	40                   	inc    %eax
  801ae3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae6:	47                   	inc    %edi
  801ae7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801aea:	77 07                	ja     801af3 <devpipe_write+0x6c>
  801aec:	eb 13                	jmp    801b01 <devpipe_write+0x7a>
  801aee:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af3:	8b 43 04             	mov    0x4(%ebx),%eax
  801af6:	8b 13                	mov    (%ebx),%edx
  801af8:	83 c2 20             	add    $0x20,%edx
  801afb:	39 d0                	cmp    %edx,%eax
  801afd:	73 ac                	jae    801aab <devpipe_write+0x24>
  801aff:	eb c8                	jmp    801ac9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b01:	89 f8                	mov    %edi,%eax
  801b03:	eb 05                	jmp    801b0a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	57                   	push   %edi
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 18             	sub    $0x18,%esp
  801b1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1e:	57                   	push   %edi
  801b1f:	e8 e4 f6 ff ff       	call   801208 <fd2data>
  801b24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b2d:	75 44                	jne    801b73 <devpipe_read+0x61>
  801b2f:	be 00 00 00 00       	mov    $0x0,%esi
  801b34:	eb 4f                	jmp    801b85 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b36:	89 f0                	mov    %esi,%eax
  801b38:	eb 54                	jmp    801b8e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3a:	89 da                	mov    %ebx,%edx
  801b3c:	89 f8                	mov    %edi,%eax
  801b3e:	e8 dd fe ff ff       	call   801a20 <_pipeisclosed>
  801b43:	85 c0                	test   %eax,%eax
  801b45:	75 42                	jne    801b89 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b47:	e8 c1 f1 ff ff       	call   800d0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b4c:	8b 03                	mov    (%ebx),%eax
  801b4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b51:	74 e7                	je     801b3a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b53:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b58:	79 05                	jns    801b5f <devpipe_read+0x4d>
  801b5a:	48                   	dec    %eax
  801b5b:	83 c8 e0             	or     $0xffffffe0,%eax
  801b5e:	40                   	inc    %eax
  801b5f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b66:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b69:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6b:	46                   	inc    %esi
  801b6c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b6f:	77 07                	ja     801b78 <devpipe_read+0x66>
  801b71:	eb 12                	jmp    801b85 <devpipe_read+0x73>
  801b73:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b78:	8b 03                	mov    (%ebx),%eax
  801b7a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b7d:	75 d4                	jne    801b53 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7f:	85 f6                	test   %esi,%esi
  801b81:	75 b3                	jne    801b36 <devpipe_read+0x24>
  801b83:	eb b5                	jmp    801b3a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b85:	89 f0                	mov    %esi,%eax
  801b87:	eb 05                	jmp    801b8e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 28             	sub    $0x28,%esp
  801b9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 75 f6 ff ff       	call   801220 <fd_alloc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 24 01 00 00    	js     801cdc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 6a f1 ff ff       	call   800d34 <sys_page_alloc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 05 01 00 00    	js     801cdc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 3d f6 ff ff       	call   801220 <fd_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 dc 00 00 00    	js     801ccc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 32 f1 ff ff       	call   800d34 <sys_page_alloc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 bd 00 00 00    	js     801ccc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c15:	e8 ee f5 ff ff       	call   801208 <fd2data>
  801c1a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 c4 0c             	add    $0xc,%esp
  801c1f:	68 07 04 00 00       	push   $0x407
  801c24:	50                   	push   %eax
  801c25:	6a 00                	push   $0x0
  801c27:	e8 08 f1 ff ff       	call   800d34 <sys_page_alloc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 83 00 00 00    	js     801cbc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c3f:	e8 c4 f5 ff ff       	call   801208 <fd2data>
  801c44:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4b:	50                   	push   %eax
  801c4c:	6a 00                	push   $0x0
  801c4e:	56                   	push   %esi
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 02 f1 ff ff       	call   800d58 <sys_page_map>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 20             	add    $0x20,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 4f                	js     801cae <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c68:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c6d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c8f:	e8 64 f5 ff ff       	call   8011f8 <fd2num>
  801c94:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c96:	83 c4 04             	add    $0x4,%esp
  801c99:	ff 75 e0             	pushl  -0x20(%ebp)
  801c9c:	e8 57 f5 ff ff       	call   8011f8 <fd2num>
  801ca1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cac:	eb 2e                	jmp    801cdc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cae:	83 ec 08             	sub    $0x8,%esp
  801cb1:	56                   	push   %esi
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 c5 f0 ff ff       	call   800d7e <sys_page_unmap>
  801cb9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	ff 75 e0             	pushl  -0x20(%ebp)
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 b5 f0 ff ff       	call   800d7e <sys_page_unmap>
  801cc9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ccc:	83 ec 08             	sub    $0x8,%esp
  801ccf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 a5 f0 ff ff       	call   800d7e <sys_page_unmap>
  801cd9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	ff 75 08             	pushl  0x8(%ebp)
  801cf3:	e8 9b f5 ff ff       	call   801293 <fd_lookup>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 18                	js     801d17 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cff:	83 ec 0c             	sub    $0xc,%esp
  801d02:	ff 75 f4             	pushl  -0xc(%ebp)
  801d05:	e8 fe f4 ff ff       	call   801208 <fd2data>
	return _pipeisclosed(fd, p);
  801d0a:	89 c2                	mov    %eax,%edx
  801d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0f:	e8 0c fd ff ff       	call   801a20 <_pipeisclosed>
  801d14:	83 c4 10             	add    $0x10,%esp
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    
  801d19:	00 00                	add    %al,(%eax)
	...

00801d1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2c:	68 8e 29 80 00       	push   $0x80298e
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	e8 79 eb ff ff       	call   8008b2 <strcpy>
	return 0;
}
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	57                   	push   %edi
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d50:	74 45                	je     801d97 <devcons_write+0x57>
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
  801d57:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d65:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d67:	83 fb 7f             	cmp    $0x7f,%ebx
  801d6a:	76 05                	jbe    801d71 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d6c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	53                   	push   %ebx
  801d75:	03 45 0c             	add    0xc(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	57                   	push   %edi
  801d7a:	e8 f4 ec ff ff       	call   800a73 <memmove>
		sys_cputs(buf, m);
  801d7f:	83 c4 08             	add    $0x8,%esp
  801d82:	53                   	push   %ebx
  801d83:	57                   	push   %edi
  801d84:	e8 f4 ee ff ff       	call   800c7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d89:	01 de                	add    %ebx,%esi
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d93:	72 cd                	jb     801d62 <devcons_write+0x22>
  801d95:	eb 05                	jmp    801d9c <devcons_write+0x5c>
  801d97:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9c:	89 f0                	mov    %esi,%eax
  801d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db0:	75 07                	jne    801db9 <devcons_read+0x13>
  801db2:	eb 25                	jmp    801dd9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db4:	e8 54 ef ff ff       	call   800d0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db9:	e8 e5 ee ff ff       	call   800ca3 <sys_cgetc>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	74 f2                	je     801db4 <devcons_read+0xe>
  801dc2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 1d                	js     801de5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc8:	83 f8 04             	cmp    $0x4,%eax
  801dcb:	74 13                	je     801de0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd0:	88 10                	mov    %dl,(%eax)
	return 1;
  801dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd7:	eb 0c                	jmp    801de5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	eb 05                	jmp    801de5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df3:	6a 01                	push   $0x1
  801df5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df8:	50                   	push   %eax
  801df9:	e8 7f ee ff ff       	call   800c7d <sys_cputs>
  801dfe:	83 c4 10             	add    $0x10,%esp
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <getchar>:

int
getchar(void)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e09:	6a 01                	push   $0x1
  801e0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0e:	50                   	push   %eax
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 fe f6 ff ff       	call   801514 <read>
	if (r < 0)
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 0f                	js     801e2c <getchar+0x29>
		return r;
	if (r < 1)
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	7e 06                	jle    801e27 <getchar+0x24>
		return -E_EOF;
	return c;
  801e21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e25:	eb 05                	jmp    801e2c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	ff 75 08             	pushl  0x8(%ebp)
  801e3b:	e8 53 f4 ff ff       	call   801293 <fd_lookup>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 11                	js     801e58 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e50:	39 10                	cmp    %edx,(%eax)
  801e52:	0f 94 c0             	sete   %al
  801e55:	0f b6 c0             	movzbl %al,%eax
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <opencons>:

int
opencons(void)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	e8 b7 f3 ff ff       	call   801220 <fd_alloc>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 3a                	js     801eaa <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	68 07 04 00 00       	push   $0x407
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 b2 ee ff ff       	call   800d34 <sys_page_alloc>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 21                	js     801eaa <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	50                   	push   %eax
  801ea2:	e8 51 f3 ff ff       	call   8011f8 <fd2num>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb9:	75 52                	jne    801f0d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	6a 07                	push   $0x7
  801ec0:	68 00 f0 bf ee       	push   $0xeebff000
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 68 ee ff ff       	call   800d34 <sys_page_alloc>
		if (r < 0) {
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	79 12                	jns    801ee5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ed3:	50                   	push   %eax
  801ed4:	68 9a 29 80 00       	push   $0x80299a
  801ed9:	6a 24                	push   $0x24
  801edb:	68 b5 29 80 00       	push   $0x8029b5
  801ee0:	e8 3f e3 ff ff       	call   800224 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ee5:	83 ec 08             	sub    $0x8,%esp
  801ee8:	68 18 1f 80 00       	push   $0x801f18
  801eed:	6a 00                	push   $0x0
  801eef:	e8 f3 ee ff ff       	call   800de7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	79 12                	jns    801f0d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801efb:	50                   	push   %eax
  801efc:	68 c4 29 80 00       	push   $0x8029c4
  801f01:	6a 2a                	push   $0x2a
  801f03:	68 b5 29 80 00       	push   $0x8029b5
  801f08:	e8 17 e3 ff ff       	call   800224 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    
	...

00801f18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f19:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f20:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f23:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f27:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f2a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f2e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f32:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f34:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f37:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f38:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f3b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f3c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f3d:	c3                   	ret    
	...

00801f40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	56                   	push   %esi
  801f44:	53                   	push   %ebx
  801f45:	8b 75 08             	mov    0x8(%ebp),%esi
  801f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	74 0e                	je     801f60 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f52:	83 ec 0c             	sub    $0xc,%esp
  801f55:	50                   	push   %eax
  801f56:	e8 d4 ee ff ff       	call   800e2f <sys_ipc_recv>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	eb 10                	jmp    801f70 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	68 00 00 c0 ee       	push   $0xeec00000
  801f68:	e8 c2 ee ff ff       	call   800e2f <sys_ipc_recv>
  801f6d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f70:	85 c0                	test   %eax,%eax
  801f72:	75 26                	jne    801f9a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f74:	85 f6                	test   %esi,%esi
  801f76:	74 0a                	je     801f82 <ipc_recv+0x42>
  801f78:	a1 04 40 80 00       	mov    0x804004,%eax
  801f7d:	8b 40 74             	mov    0x74(%eax),%eax
  801f80:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f82:	85 db                	test   %ebx,%ebx
  801f84:	74 0a                	je     801f90 <ipc_recv+0x50>
  801f86:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8b:	8b 40 78             	mov    0x78(%eax),%eax
  801f8e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f90:	a1 04 40 80 00       	mov    0x804004,%eax
  801f95:	8b 40 70             	mov    0x70(%eax),%eax
  801f98:	eb 14                	jmp    801fae <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f9a:	85 f6                	test   %esi,%esi
  801f9c:	74 06                	je     801fa4 <ipc_recv+0x64>
  801f9e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801fa4:	85 db                	test   %ebx,%ebx
  801fa6:	74 06                	je     801fae <ipc_recv+0x6e>
  801fa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801fae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	57                   	push   %edi
  801fb9:	56                   	push   %esi
  801fba:	53                   	push   %ebx
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801fc7:	85 db                	test   %ebx,%ebx
  801fc9:	75 25                	jne    801ff0 <ipc_send+0x3b>
  801fcb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fd0:	eb 1e                	jmp    801ff0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801fd2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd5:	75 07                	jne    801fde <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fd7:	e8 31 ed ff ff       	call   800d0d <sys_yield>
  801fdc:	eb 12                	jmp    801ff0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801fde:	50                   	push   %eax
  801fdf:	68 ec 29 80 00       	push   $0x8029ec
  801fe4:	6a 43                	push   $0x43
  801fe6:	68 ff 29 80 00       	push   $0x8029ff
  801feb:	e8 34 e2 ff ff       	call   800224 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ff0:	56                   	push   %esi
  801ff1:	53                   	push   %ebx
  801ff2:	57                   	push   %edi
  801ff3:	ff 75 08             	pushl  0x8(%ebp)
  801ff6:	e8 0f ee ff ff       	call   800e0a <sys_ipc_try_send>
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	85 c0                	test   %eax,%eax
  802000:	75 d0                	jne    801fd2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802010:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  802016:	74 1a                	je     802032 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802018:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80201d:	89 c2                	mov    %eax,%edx
  80201f:	c1 e2 07             	shl    $0x7,%edx
  802022:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802029:	8b 52 50             	mov    0x50(%edx),%edx
  80202c:	39 ca                	cmp    %ecx,%edx
  80202e:	75 18                	jne    802048 <ipc_find_env+0x3e>
  802030:	eb 05                	jmp    802037 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802032:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802037:	89 c2                	mov    %eax,%edx
  802039:	c1 e2 07             	shl    $0x7,%edx
  80203c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  802043:	8b 40 40             	mov    0x40(%eax),%eax
  802046:	eb 0c                	jmp    802054 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802048:	40                   	inc    %eax
  802049:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204e:	75 cd                	jne    80201d <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802050:	66 b8 00 00          	mov    $0x0,%ax
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    
	...

00802058 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205e:	89 c2                	mov    %eax,%edx
  802060:	c1 ea 16             	shr    $0x16,%edx
  802063:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80206a:	f6 c2 01             	test   $0x1,%dl
  80206d:	74 1e                	je     80208d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80206f:	c1 e8 0c             	shr    $0xc,%eax
  802072:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802079:	a8 01                	test   $0x1,%al
  80207b:	74 17                	je     802094 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207d:	c1 e8 0c             	shr    $0xc,%eax
  802080:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802087:	ef 
  802088:	0f b7 c0             	movzwl %ax,%eax
  80208b:	eb 0c                	jmp    802099 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
  802092:	eb 05                	jmp    802099 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802099:	c9                   	leave  
  80209a:	c3                   	ret    
	...

0080209c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	57                   	push   %edi
  8020a0:	56                   	push   %esi
  8020a1:	83 ec 10             	sub    $0x10,%esp
  8020a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020aa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020b0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020b3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	75 2e                	jne    8020e8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020ba:	39 f1                	cmp    %esi,%ecx
  8020bc:	77 5a                	ja     802118 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020be:	85 c9                	test   %ecx,%ecx
  8020c0:	75 0b                	jne    8020cd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c7:	31 d2                	xor    %edx,%edx
  8020c9:	f7 f1                	div    %ecx
  8020cb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020cd:	31 d2                	xor    %edx,%edx
  8020cf:	89 f0                	mov    %esi,%eax
  8020d1:	f7 f1                	div    %ecx
  8020d3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020d5:	89 f8                	mov    %edi,%eax
  8020d7:	f7 f1                	div    %ecx
  8020d9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020db:	89 f8                	mov    %edi,%eax
  8020dd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	5e                   	pop    %esi
  8020e3:	5f                   	pop    %edi
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    
  8020e6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	77 1c                	ja     802108 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020ec:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020ef:	83 f7 1f             	xor    $0x1f,%edi
  8020f2:	75 3c                	jne    802130 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020f4:	39 f0                	cmp    %esi,%eax
  8020f6:	0f 82 90 00 00 00    	jb     80218c <__udivdi3+0xf0>
  8020fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020ff:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802102:	0f 86 84 00 00 00    	jbe    80218c <__udivdi3+0xf0>
  802108:	31 f6                	xor    %esi,%esi
  80210a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80210c:	89 f8                	mov    %edi,%eax
  80210e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	5e                   	pop    %esi
  802114:	5f                   	pop    %edi
  802115:	c9                   	leave  
  802116:	c3                   	ret    
  802117:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802118:	89 f2                	mov    %esi,%edx
  80211a:	89 f8                	mov    %edi,%eax
  80211c:	f7 f1                	div    %ecx
  80211e:	89 c7                	mov    %eax,%edi
  802120:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802122:	89 f8                	mov    %edi,%eax
  802124:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    
  80212d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802130:	89 f9                	mov    %edi,%ecx
  802132:	d3 e0                	shl    %cl,%eax
  802134:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802137:	b8 20 00 00 00       	mov    $0x20,%eax
  80213c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80213e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802141:	88 c1                	mov    %al,%cl
  802143:	d3 ea                	shr    %cl,%edx
  802145:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802148:	09 ca                	or     %ecx,%edx
  80214a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80214d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802150:	89 f9                	mov    %edi,%ecx
  802152:	d3 e2                	shl    %cl,%edx
  802154:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802157:	89 f2                	mov    %esi,%edx
  802159:	88 c1                	mov    %al,%cl
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802160:	89 f2                	mov    %esi,%edx
  802162:	89 f9                	mov    %edi,%ecx
  802164:	d3 e2                	shl    %cl,%edx
  802166:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802169:	88 c1                	mov    %al,%cl
  80216b:	d3 ee                	shr    %cl,%esi
  80216d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80216f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802172:	89 f0                	mov    %esi,%eax
  802174:	89 ca                	mov    %ecx,%edx
  802176:	f7 75 ec             	divl   -0x14(%ebp)
  802179:	89 d1                	mov    %edx,%ecx
  80217b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80217d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802180:	39 d1                	cmp    %edx,%ecx
  802182:	72 28                	jb     8021ac <__udivdi3+0x110>
  802184:	74 1a                	je     8021a0 <__udivdi3+0x104>
  802186:	89 f7                	mov    %esi,%edi
  802188:	31 f6                	xor    %esi,%esi
  80218a:	eb 80                	jmp    80210c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80218c:	31 f6                	xor    %esi,%esi
  80218e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802193:	89 f8                	mov    %edi,%eax
  802195:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	5e                   	pop    %esi
  80219b:	5f                   	pop    %edi
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    
  80219e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a7:	39 c2                	cmp    %eax,%edx
  8021a9:	73 db                	jae    802186 <__udivdi3+0xea>
  8021ab:	90                   	nop
		{
		  q0--;
  8021ac:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021af:	31 f6                	xor    %esi,%esi
  8021b1:	e9 56 ff ff ff       	jmp    80210c <__udivdi3+0x70>
	...

008021b8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	57                   	push   %edi
  8021bc:	56                   	push   %esi
  8021bd:	83 ec 20             	sub    $0x20,%esp
  8021c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021cc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021d5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021d7:	85 ff                	test   %edi,%edi
  8021d9:	75 15                	jne    8021f0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021db:	39 f1                	cmp    %esi,%ecx
  8021dd:	0f 86 99 00 00 00    	jbe    80227c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021e3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e9:	83 c4 20             	add    $0x20,%esp
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021f0:	39 f7                	cmp    %esi,%edi
  8021f2:	0f 87 a4 00 00 00    	ja     80229c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021f8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021fb:	83 f0 1f             	xor    $0x1f,%eax
  8021fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802201:	0f 84 a1 00 00 00    	je     8022a8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802207:	89 f8                	mov    %edi,%eax
  802209:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80220c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80220e:	bf 20 00 00 00       	mov    $0x20,%edi
  802213:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802216:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802219:	89 f9                	mov    %edi,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802225:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802228:	d3 e0                	shl    %cl,%eax
  80222a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802231:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802234:	d3 e0                	shl    %cl,%eax
  802236:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802239:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80223c:	89 f9                	mov    %edi,%ecx
  80223e:	d3 e8                	shr    %cl,%eax
  802240:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802242:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802244:	89 f2                	mov    %esi,%edx
  802246:	f7 75 f0             	divl   -0x10(%ebp)
  802249:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80224b:	f7 65 f4             	mull   -0xc(%ebp)
  80224e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802251:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802253:	39 d6                	cmp    %edx,%esi
  802255:	72 71                	jb     8022c8 <__umoddi3+0x110>
  802257:	74 7f                	je     8022d8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80225c:	29 c8                	sub    %ecx,%eax
  80225e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802260:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802263:	d3 e8                	shr    %cl,%eax
  802265:	89 f2                	mov    %esi,%edx
  802267:	89 f9                	mov    %edi,%ecx
  802269:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80226b:	09 d0                	or     %edx,%eax
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802272:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802274:	83 c4 20             	add    $0x20,%esp
  802277:	5e                   	pop    %esi
  802278:	5f                   	pop    %edi
  802279:	c9                   	leave  
  80227a:	c3                   	ret    
  80227b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80227c:	85 c9                	test   %ecx,%ecx
  80227e:	75 0b                	jne    80228b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802280:	b8 01 00 00 00       	mov    $0x1,%eax
  802285:	31 d2                	xor    %edx,%edx
  802287:	f7 f1                	div    %ecx
  802289:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80228b:	89 f0                	mov    %esi,%eax
  80228d:	31 d2                	xor    %edx,%edx
  80228f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802294:	f7 f1                	div    %ecx
  802296:	e9 4a ff ff ff       	jmp    8021e5 <__umoddi3+0x2d>
  80229b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80229c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80229e:	83 c4 20             	add    $0x20,%esp
  8022a1:	5e                   	pop    %esi
  8022a2:	5f                   	pop    %edi
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    
  8022a5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a8:	39 f7                	cmp    %esi,%edi
  8022aa:	72 05                	jb     8022b1 <__umoddi3+0xf9>
  8022ac:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022af:	77 0c                	ja     8022bd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022b1:	89 f2                	mov    %esi,%edx
  8022b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b6:	29 c8                	sub    %ecx,%eax
  8022b8:	19 fa                	sbb    %edi,%edx
  8022ba:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022c0:	83 c4 20             	add    $0x20,%esp
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    
  8022c7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022cb:	89 c1                	mov    %eax,%ecx
  8022cd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022d0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022d3:	eb 84                	jmp    802259 <__umoddi3+0xa1>
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022d8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022db:	72 eb                	jb     8022c8 <__umoddi3+0x110>
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	e9 75 ff ff ff       	jmp    802259 <__umoddi3+0xa1>
