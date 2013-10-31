
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
  80002c:	e8 93 01 00 00       	call   8001c4 <libmain>
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
  80003d:	68 a0 22 80 00       	push   $0x8022a0
  800042:	e8 c1 02 00 00       	call   800308 <cprintf>
	if ((r = pipe(p)) < 0)
  800047:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004a:	89 04 24             	mov    %eax,(%esp)
  80004d:	e8 e8 1a 00 00       	call   801b3a <pipe>
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	85 c0                	test   %eax,%eax
  800057:	79 12                	jns    80006b <umain+0x37>
		panic("pipe: %e", r);
  800059:	50                   	push   %eax
  80005a:	68 ee 22 80 00       	push   $0x8022ee
  80005f:	6a 0d                	push   $0xd
  800061:	68 f7 22 80 00       	push   $0x8022f7
  800066:	e8 c5 01 00 00       	call   800230 <_panic>
	if ((r = fork()) < 0)
  80006b:	e8 e2 0e 00 00       	call   800f52 <fork>
  800070:	89 c7                	mov    %eax,%edi
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x54>
		panic("fork: %e", r);
  800076:	50                   	push   %eax
  800077:	68 0c 23 80 00       	push   $0x80230c
  80007c:	6a 0f                	push   $0xf
  80007e:	68 f7 22 80 00       	push   $0x8022f7
  800083:	e8 a8 01 00 00       	call   800230 <_panic>
	if (r == 0) {
  800088:	85 c0                	test   %eax,%eax
  80008a:	75 66                	jne    8000f2 <umain+0xbe>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800092:	e8 e4 12 00 00       	call   80137b <close>
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
  8000b1:	68 15 23 80 00       	push   $0x802315
  8000b6:	e8 4d 02 00 00       	call   800308 <cprintf>
  8000bb:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	6a 0a                	push   $0xa
  8000c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c6:	e8 fe 12 00 00       	call   8013c9 <dup>
			sys_yield();
  8000cb:	e8 49 0c 00 00       	call   800d19 <sys_yield>
			close(10);
  8000d0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000d7:	e8 9f 12 00 00       	call   80137b <close>
			sys_yield();
  8000dc:	e8 38 0c 00 00       	call   800d19 <sys_yield>
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
  8000ed:	e8 22 01 00 00       	call   800214 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  8000f2:	89 f8                	mov    %edi,%eax
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  8000f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	29 d0                	sub    %edx,%eax
  800105:	8d 98 04 00 c0 ee    	lea    -0x113ffffc(%eax),%ebx
  80010b:	eb 2f                	jmp    80013c <umain+0x108>
		if (pipeisclosed(p[0]) != 0) {
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	ff 75 e0             	pushl  -0x20(%ebp)
  800113:	e8 72 1b 00 00       	call   801c8a <pipeisclosed>
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	85 c0                	test   %eax,%eax
  80011d:	74 1d                	je     80013c <umain+0x108>
			cprintf("\nRACE: pipe appears closed\n");
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	68 19 23 80 00       	push   $0x802319
  800127:	e8 dc 01 00 00       	call   800308 <cprintf>
			sys_env_destroy(r);
  80012c:	89 3c 24             	mov    %edi,(%esp)
  80012f:	e8 9f 0b 00 00       	call   800cd3 <sys_env_destroy>
			exit();
  800134:	e8 db 00 00 00       	call   800214 <exit>
  800139:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  80013c:	8b 43 50             	mov    0x50(%ebx),%eax
  80013f:	83 f8 02             	cmp    $0x2,%eax
  800142:	74 c9                	je     80010d <umain+0xd9>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	68 35 23 80 00       	push   $0x802335
  80014c:	e8 b7 01 00 00       	call   800308 <cprintf>
	if (pipeisclosed(p[0]))
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 e0             	pushl  -0x20(%ebp)
  800157:	e8 2e 1b 00 00       	call   801c8a <pipeisclosed>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	85 c0                	test   %eax,%eax
  800161:	74 14                	je     800177 <umain+0x143>
		panic("somehow the other end of p[0] got closed!");
  800163:	83 ec 04             	sub    $0x4,%esp
  800166:	68 c4 22 80 00       	push   $0x8022c4
  80016b:	6a 40                	push   $0x40
  80016d:	68 f7 22 80 00       	push   $0x8022f7
  800172:	e8 b9 00 00 00       	call   800230 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800177:	83 ec 08             	sub    $0x8,%esp
  80017a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017d:	50                   	push   %eax
  80017e:	ff 75 e0             	pushl  -0x20(%ebp)
  800181:	e8 b1 10 00 00       	call   801237 <fd_lookup>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	85 c0                	test   %eax,%eax
  80018b:	79 12                	jns    80019f <umain+0x16b>
		panic("cannot look up p[0]: %e", r);
  80018d:	50                   	push   %eax
  80018e:	68 4b 23 80 00       	push   $0x80234b
  800193:	6a 42                	push   $0x42
  800195:	68 f7 22 80 00       	push   $0x8022f7
  80019a:	e8 91 00 00 00       	call   800230 <_panic>
	(void) fd2data(fd);
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a5:	e8 02 10 00 00       	call   8011ac <fd2data>
	cprintf("race didn't happen\n");
  8001aa:	c7 04 24 63 23 80 00 	movl   $0x802363,(%esp)
  8001b1:	e8 52 01 00 00       	call   800308 <cprintf>
  8001b6:	83 c4 10             	add    $0x10,%esp
}
  8001b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
  8001c1:	00 00                	add    %al,(%eax)
	...

008001c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001cf:	e8 21 0b 00 00       	call   800cf5 <sys_getenvid>
  8001d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001e0:	c1 e0 07             	shl    $0x7,%eax
  8001e3:	29 d0                	sub    %edx,%eax
  8001e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ea:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ef:	85 f6                	test   %esi,%esi
  8001f1:	7e 07                	jle    8001fa <libmain+0x36>
		binaryname = argv[0];
  8001f3:	8b 03                	mov    (%ebx),%eax
  8001f5:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	53                   	push   %ebx
  8001fe:	56                   	push   %esi
  8001ff:	e8 30 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800204:	e8 0b 00 00 00       	call   800214 <exit>
  800209:	83 c4 10             	add    $0x10,%esp
}
  80020c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	c9                   	leave  
  800212:	c3                   	ret    
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021a:	e8 87 11 00 00       	call   8013a6 <close_all>
	sys_env_destroy(0);
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	6a 00                	push   $0x0
  800224:	e8 aa 0a 00 00       	call   800cd3 <sys_env_destroy>
  800229:	83 c4 10             	add    $0x10,%esp
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800235:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800238:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80023e:	e8 b2 0a 00 00       	call   800cf5 <sys_getenvid>
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	ff 75 0c             	pushl  0xc(%ebp)
  800249:	ff 75 08             	pushl  0x8(%ebp)
  80024c:	53                   	push   %ebx
  80024d:	50                   	push   %eax
  80024e:	68 84 23 80 00       	push   $0x802384
  800253:	e8 b0 00 00 00       	call   800308 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	56                   	push   %esi
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	e8 53 00 00 00       	call   8002b7 <vcprintf>
	cprintf("\n");
  800264:	c7 04 24 27 29 80 00 	movl   $0x802927,(%esp)
  80026b:	e8 98 00 00 00       	call   800308 <cprintf>
  800270:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800273:	cc                   	int3   
  800274:	eb fd                	jmp    800273 <_panic+0x43>
	...

00800278 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	53                   	push   %ebx
  80027c:	83 ec 04             	sub    $0x4,%esp
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800282:	8b 03                	mov    (%ebx),%eax
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80028b:	40                   	inc    %eax
  80028c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80028e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800293:	75 1a                	jne    8002af <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	68 ff 00 00 00       	push   $0xff
  80029d:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a0:	50                   	push   %eax
  8002a1:	e8 e3 09 00 00       	call   800c89 <sys_cputs>
		b->idx = 0;
  8002a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002af:	ff 43 04             	incl   0x4(%ebx)
}
  8002b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c7:	00 00 00 
	b.cnt = 0;
  8002ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d4:	ff 75 0c             	pushl  0xc(%ebp)
  8002d7:	ff 75 08             	pushl  0x8(%ebp)
  8002da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e0:	50                   	push   %eax
  8002e1:	68 78 02 80 00       	push   $0x800278
  8002e6:	e8 82 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002eb:	83 c4 08             	add    $0x8,%esp
  8002ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fa:	50                   	push   %eax
  8002fb:	e8 89 09 00 00       	call   800c89 <sys_cputs>

	return b.cnt;
}
  800300:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 08             	pushl  0x8(%ebp)
  800315:	e8 9d ff ff ff       	call   8002b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 2c             	sub    $0x2c,%esp
  800325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800328:	89 d6                	mov    %edx,%esi
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800330:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800333:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800336:	8b 45 10             	mov    0x10(%ebp),%eax
  800339:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80033c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800342:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800349:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80034c:	72 0c                	jb     80035a <printnum+0x3e>
  80034e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800351:	76 07                	jbe    80035a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800353:	4b                   	dec    %ebx
  800354:	85 db                	test   %ebx,%ebx
  800356:	7f 31                	jg     800389 <printnum+0x6d>
  800358:	eb 3f                	jmp    800399 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035a:	83 ec 0c             	sub    $0xc,%esp
  80035d:	57                   	push   %edi
  80035e:	4b                   	dec    %ebx
  80035f:	53                   	push   %ebx
  800360:	50                   	push   %eax
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	ff 75 d4             	pushl  -0x2c(%ebp)
  800367:	ff 75 d0             	pushl  -0x30(%ebp)
  80036a:	ff 75 dc             	pushl  -0x24(%ebp)
  80036d:	ff 75 d8             	pushl  -0x28(%ebp)
  800370:	e8 db 1c 00 00       	call   802050 <__udivdi3>
  800375:	83 c4 18             	add    $0x18,%esp
  800378:	52                   	push   %edx
  800379:	50                   	push   %eax
  80037a:	89 f2                	mov    %esi,%edx
  80037c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037f:	e8 98 ff ff ff       	call   80031c <printnum>
  800384:	83 c4 20             	add    $0x20,%esp
  800387:	eb 10                	jmp    800399 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	56                   	push   %esi
  80038d:	57                   	push   %edi
  80038e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800391:	4b                   	dec    %ebx
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	85 db                	test   %ebx,%ebx
  800397:	7f f0                	jg     800389 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	83 ec 04             	sub    $0x4,%esp
  8003a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ac:	e8 bb 1d 00 00       	call   80216c <__umoddi3>
  8003b1:	83 c4 14             	add    $0x14,%esp
  8003b4:	0f be 80 a7 23 80 00 	movsbl 0x8023a7(%eax),%eax
  8003bb:	50                   	push   %eax
  8003bc:	ff 55 e4             	call   *-0x1c(%ebp)
  8003bf:	83 c4 10             	add    $0x10,%esp
}
  8003c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 fa 01             	cmp    $0x1,%edx
  8003d0:	7e 0e                	jle    8003e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	8b 52 04             	mov    0x4(%edx),%edx
  8003de:	eb 22                	jmp    800402 <getuint+0x38>
	else if (lflag)
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 10                	je     8003f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	eb 0e                	jmp    800402 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800407:	83 fa 01             	cmp    $0x1,%edx
  80040a:	7e 0e                	jle    80041a <getint+0x16>
		return va_arg(*ap, long long);
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800411:	89 08                	mov    %ecx,(%eax)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	8b 52 04             	mov    0x4(%edx),%edx
  800418:	eb 1a                	jmp    800434 <getint+0x30>
	else if (lflag)
  80041a:	85 d2                	test   %edx,%edx
  80041c:	74 0c                	je     80042a <getint+0x26>
		return va_arg(*ap, long);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 04             	lea    0x4(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	99                   	cltd   
  800428:	eb 0a                	jmp    800434 <getint+0x30>
	else
		return va_arg(*ap, int);
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	99                   	cltd   
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    

00800436 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	3b 50 04             	cmp    0x4(%eax),%edx
  800444:	73 08                	jae    80044e <sprintputch+0x18>
		*b->buf++ = ch;
  800446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800449:	88 0a                	mov    %cl,(%edx)
  80044b:	42                   	inc    %edx
  80044c:	89 10                	mov    %edx,(%eax)
}
  80044e:	c9                   	leave  
  80044f:	c3                   	ret    

00800450 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800459:	50                   	push   %eax
  80045a:	ff 75 10             	pushl  0x10(%ebp)
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	e8 05 00 00 00       	call   80046d <vprintfmt>
	va_end(ap);
  800468:	83 c4 10             	add    $0x10,%esp
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 2c             	sub    $0x2c,%esp
  800476:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800479:	8b 75 10             	mov    0x10(%ebp),%esi
  80047c:	eb 13                	jmp    800491 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80047e:	85 c0                	test   %eax,%eax
  800480:	0f 84 6d 03 00 00    	je     8007f3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	57                   	push   %edi
  80048a:	50                   	push   %eax
  80048b:	ff 55 08             	call   *0x8(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800491:	0f b6 06             	movzbl (%esi),%eax
  800494:	46                   	inc    %esi
  800495:	83 f8 25             	cmp    $0x25,%eax
  800498:	75 e4                	jne    80047e <vprintfmt+0x11>
  80049a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80049e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004a5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b8:	eb 28                	jmp    8004e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004c0:	eb 20                	jmp    8004e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004c8:	eb 18                	jmp    8004e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004d3:	eb 0d                	jmp    8004e2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8a 06                	mov    (%esi),%al
  8004e4:	0f b6 d0             	movzbl %al,%edx
  8004e7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004ea:	83 e8 23             	sub    $0x23,%eax
  8004ed:	3c 55                	cmp    $0x55,%al
  8004ef:	0f 87 e0 02 00 00    	ja     8007d5 <vprintfmt+0x368>
  8004f5:	0f b6 c0             	movzbl %al,%eax
  8004f8:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ff:	83 ea 30             	sub    $0x30,%edx
  800502:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800505:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800508:	8d 50 d0             	lea    -0x30(%eax),%edx
  80050b:	83 fa 09             	cmp    $0x9,%edx
  80050e:	77 44                	ja     800554 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	89 de                	mov    %ebx,%esi
  800512:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800515:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800516:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800519:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80051d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800520:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800523:	83 fb 09             	cmp    $0x9,%ebx
  800526:	76 ed                	jbe    800515 <vprintfmt+0xa8>
  800528:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80052b:	eb 29                	jmp    800556 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053d:	eb 17                	jmp    800556 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80053f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800543:	78 85                	js     8004ca <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	89 de                	mov    %ebx,%esi
  800547:	eb 99                	jmp    8004e2 <vprintfmt+0x75>
  800549:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800552:	eb 8e                	jmp    8004e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800556:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055a:	79 86                	jns    8004e2 <vprintfmt+0x75>
  80055c:	e9 74 ff ff ff       	jmp    8004d5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800561:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	89 de                	mov    %ebx,%esi
  800564:	e9 79 ff ff ff       	jmp    8004e2 <vprintfmt+0x75>
  800569:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 04             	lea    0x4(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	ff 30                	pushl  (%eax)
  80057b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80057e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800584:	e9 08 ff ff ff       	jmp    800491 <vprintfmt+0x24>
  800589:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	79 02                	jns    80059d <vprintfmt+0x130>
  80059b:	f7 d8                	neg    %eax
  80059d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059f:	83 f8 0f             	cmp    $0xf,%eax
  8005a2:	7f 0b                	jg     8005af <vprintfmt+0x142>
  8005a4:	8b 04 85 40 26 80 00 	mov    0x802640(,%eax,4),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 1a                	jne    8005c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005af:	52                   	push   %edx
  8005b0:	68 bf 23 80 00       	push   $0x8023bf
  8005b5:	57                   	push   %edi
  8005b6:	ff 75 08             	pushl  0x8(%ebp)
  8005b9:	e8 92 fe ff ff       	call   800450 <printfmt>
  8005be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c4:	e9 c8 fe ff ff       	jmp    800491 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005c9:	50                   	push   %eax
  8005ca:	68 f5 28 80 00       	push   $0x8028f5
  8005cf:	57                   	push   %edi
  8005d0:	ff 75 08             	pushl  0x8(%ebp)
  8005d3:	e8 78 fe ff ff       	call   800450 <printfmt>
  8005d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005de:	e9 ae fe ff ff       	jmp    800491 <vprintfmt+0x24>
  8005e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005e6:	89 de                	mov    %ebx,%esi
  8005e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	75 07                	jne    800607 <vprintfmt+0x19a>
				p = "(null)";
  800600:	c7 45 d0 b8 23 80 00 	movl   $0x8023b8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800607:	85 db                	test   %ebx,%ebx
  800609:	7e 42                	jle    80064d <vprintfmt+0x1e0>
  80060b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80060f:	74 3c                	je     80064d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	51                   	push   %ecx
  800615:	ff 75 d0             	pushl  -0x30(%ebp)
  800618:	e8 6f 02 00 00       	call   80088c <strnlen>
  80061d:	29 c3                	sub    %eax,%ebx
  80061f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	85 db                	test   %ebx,%ebx
  800627:	7e 24                	jle    80064d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800629:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80062d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800630:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	57                   	push   %edi
  800637:	53                   	push   %ebx
  800638:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	4e                   	dec    %esi
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	85 f6                	test   %esi,%esi
  800641:	7f f0                	jg     800633 <vprintfmt+0x1c6>
  800643:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800646:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800650:	0f be 02             	movsbl (%edx),%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	75 47                	jne    80069e <vprintfmt+0x231>
  800657:	eb 37                	jmp    800690 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	74 16                	je     800675 <vprintfmt+0x208>
  80065f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800662:	83 fa 5e             	cmp    $0x5e,%edx
  800665:	76 0e                	jbe    800675 <vprintfmt+0x208>
					putch('?', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	57                   	push   %edi
  80066b:	6a 3f                	push   $0x3f
  80066d:	ff 55 08             	call   *0x8(%ebp)
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb 0b                	jmp    800680 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	57                   	push   %edi
  800679:	50                   	push   %eax
  80067a:	ff 55 08             	call   *0x8(%ebp)
  80067d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	ff 4d e4             	decl   -0x1c(%ebp)
  800683:	0f be 03             	movsbl (%ebx),%eax
  800686:	85 c0                	test   %eax,%eax
  800688:	74 03                	je     80068d <vprintfmt+0x220>
  80068a:	43                   	inc    %ebx
  80068b:	eb 1b                	jmp    8006a8 <vprintfmt+0x23b>
  80068d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800694:	7f 1e                	jg     8006b4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800699:	e9 f3 fd ff ff       	jmp    800491 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006a1:	43                   	inc    %ebx
  8006a2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a8:	85 f6                	test   %esi,%esi
  8006aa:	78 ad                	js     800659 <vprintfmt+0x1ec>
  8006ac:	4e                   	dec    %esi
  8006ad:	79 aa                	jns    800659 <vprintfmt+0x1ec>
  8006af:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006b2:	eb dc                	jmp    800690 <vprintfmt+0x223>
  8006b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	57                   	push   %edi
  8006bb:	6a 20                	push   $0x20
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c0:	4b                   	dec    %ebx
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	85 db                	test   %ebx,%ebx
  8006c6:	7f ef                	jg     8006b7 <vprintfmt+0x24a>
  8006c8:	e9 c4 fd ff ff       	jmp    800491 <vprintfmt+0x24>
  8006cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d0:	89 ca                	mov    %ecx,%edx
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 2a fd ff ff       	call   800404 <getint>
  8006da:	89 c3                	mov    %eax,%ebx
  8006dc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	78 0a                	js     8006ec <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e7:	e9 b0 00 00 00       	jmp    80079c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	57                   	push   %edi
  8006f0:	6a 2d                	push   $0x2d
  8006f2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f5:	f7 db                	neg    %ebx
  8006f7:	83 d6 00             	adc    $0x0,%esi
  8006fa:	f7 de                	neg    %esi
  8006fc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800704:	e9 93 00 00 00       	jmp    80079c <vprintfmt+0x32f>
  800709:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	89 ca                	mov    %ecx,%edx
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 b4 fc ff ff       	call   8003ca <getuint>
  800716:	89 c3                	mov    %eax,%ebx
  800718:	89 d6                	mov    %edx,%esi
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80071f:	eb 7b                	jmp    80079c <vprintfmt+0x32f>
  800721:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 d6 fc ff ff       	call   800404 <getint>
  80072e:	89 c3                	mov    %eax,%ebx
  800730:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800732:	85 d2                	test   %edx,%edx
  800734:	78 07                	js     80073d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800736:	b8 08 00 00 00       	mov    $0x8,%eax
  80073b:	eb 5f                	jmp    80079c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	57                   	push   %edi
  800741:	6a 2d                	push   $0x2d
  800743:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800746:	f7 db                	neg    %ebx
  800748:	83 d6 00             	adc    $0x0,%esi
  80074b:	f7 de                	neg    %esi
  80074d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800750:	b8 08 00 00 00       	mov    $0x8,%eax
  800755:	eb 45                	jmp    80079c <vprintfmt+0x32f>
  800757:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	57                   	push   %edi
  80075e:	6a 30                	push   $0x30
  800760:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	57                   	push   %edi
  800767:	6a 78                	push   $0x78
  800769:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800775:	8b 18                	mov    (%eax),%ebx
  800777:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800784:	eb 16                	jmp    80079c <vprintfmt+0x32f>
  800786:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800789:	89 ca                	mov    %ecx,%edx
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 37 fc ff ff       	call   8003ca <getuint>
  800793:	89 c3                	mov    %eax,%ebx
  800795:	89 d6                	mov    %edx,%esi
			base = 16;
  800797:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007a3:	52                   	push   %edx
  8007a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007a7:	50                   	push   %eax
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	89 fa                	mov    %edi,%edx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	e8 68 fb ff ff       	call   80031c <printnum>
			break;
  8007b4:	83 c4 20             	add    $0x20,%esp
  8007b7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007ba:	e9 d2 fc ff ff       	jmp    800491 <vprintfmt+0x24>
  8007bf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	57                   	push   %edi
  8007c6:	52                   	push   %edx
  8007c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d0:	e9 bc fc ff ff       	jmp    800491 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	57                   	push   %edi
  8007d9:	6a 25                	push   $0x25
  8007db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb 02                	jmp    8007e5 <vprintfmt+0x378>
  8007e3:	89 c6                	mov    %eax,%esi
  8007e5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007e8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ec:	75 f5                	jne    8007e3 <vprintfmt+0x376>
  8007ee:	e9 9e fc ff ff       	jmp    800491 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 18             	sub    $0x18,%esp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800807:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800811:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800818:	85 c0                	test   %eax,%eax
  80081a:	74 26                	je     800842 <vsnprintf+0x47>
  80081c:	85 d2                	test   %edx,%edx
  80081e:	7e 29                	jle    800849 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800820:	ff 75 14             	pushl  0x14(%ebp)
  800823:	ff 75 10             	pushl  0x10(%ebp)
  800826:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800829:	50                   	push   %eax
  80082a:	68 36 04 80 00       	push   $0x800436
  80082f:	e8 39 fc ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800834:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800837:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	eb 0c                	jmp    80084e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800847:	eb 05                	jmp    80084e <vsnprintf+0x53>
  800849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800859:	50                   	push   %eax
  80085a:	ff 75 10             	pushl  0x10(%ebp)
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	ff 75 08             	pushl  0x8(%ebp)
  800863:	e8 93 ff ff ff       	call   8007fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800868:	c9                   	leave  
  800869:	c3                   	ret    
	...

0080086c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	80 3a 00             	cmpb   $0x0,(%edx)
  800875:	74 0e                	je     800885 <strlen+0x19>
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80087c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800881:	75 f9                	jne    80087c <strlen+0x10>
  800883:	eb 05                	jmp    80088a <strlen+0x1e>
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	85 d2                	test   %edx,%edx
  800897:	74 17                	je     8008b0 <strnlen+0x24>
  800899:	80 39 00             	cmpb   $0x0,(%ecx)
  80089c:	74 19                	je     8008b7 <strnlen+0x2b>
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a4:	39 d0                	cmp    %edx,%eax
  8008a6:	74 14                	je     8008bc <strnlen+0x30>
  8008a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ac:	75 f5                	jne    8008a3 <strnlen+0x17>
  8008ae:	eb 0c                	jmp    8008bc <strnlen+0x30>
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 05                	jmp    8008bc <strnlen+0x30>
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008d0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d3:	42                   	inc    %edx
  8008d4:	84 c9                	test   %cl,%cl
  8008d6:	75 f5                	jne    8008cd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e2:	53                   	push   %ebx
  8008e3:	e8 84 ff ff ff       	call   80086c <strlen>
  8008e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008f1:	50                   	push   %eax
  8008f2:	e8 c7 ff ff ff       	call   8008be <strcpy>
	return dst;
}
  8008f7:	89 d8                	mov    %ebx,%eax
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090c:	85 f6                	test   %esi,%esi
  80090e:	74 15                	je     800925 <strncpy+0x27>
  800910:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800915:	8a 1a                	mov    (%edx),%bl
  800917:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091a:	80 3a 01             	cmpb   $0x1,(%edx)
  80091d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800920:	41                   	inc    %ecx
  800921:	39 ce                	cmp    %ecx,%esi
  800923:	77 f0                	ja     800915 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800935:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800938:	85 f6                	test   %esi,%esi
  80093a:	74 32                	je     80096e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80093c:	83 fe 01             	cmp    $0x1,%esi
  80093f:	74 22                	je     800963 <strlcpy+0x3a>
  800941:	8a 0b                	mov    (%ebx),%cl
  800943:	84 c9                	test   %cl,%cl
  800945:	74 20                	je     800967 <strlcpy+0x3e>
  800947:	89 f8                	mov    %edi,%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80094e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800951:	88 08                	mov    %cl,(%eax)
  800953:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800954:	39 f2                	cmp    %esi,%edx
  800956:	74 11                	je     800969 <strlcpy+0x40>
  800958:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80095c:	42                   	inc    %edx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	75 f0                	jne    800951 <strlcpy+0x28>
  800961:	eb 06                	jmp    800969 <strlcpy+0x40>
  800963:	89 f8                	mov    %edi,%eax
  800965:	eb 02                	jmp    800969 <strlcpy+0x40>
  800967:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800969:	c6 00 00             	movb   $0x0,(%eax)
  80096c:	eb 02                	jmp    800970 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800970:	29 f8                	sub    %edi,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800980:	8a 01                	mov    (%ecx),%al
  800982:	84 c0                	test   %al,%al
  800984:	74 10                	je     800996 <strcmp+0x1f>
  800986:	3a 02                	cmp    (%edx),%al
  800988:	75 0c                	jne    800996 <strcmp+0x1f>
		p++, q++;
  80098a:	41                   	inc    %ecx
  80098b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098c:	8a 01                	mov    (%ecx),%al
  80098e:	84 c0                	test   %al,%al
  800990:	74 04                	je     800996 <strcmp+0x1f>
  800992:	3a 02                	cmp    (%edx),%al
  800994:	74 f4                	je     80098a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 c0             	movzbl %al,%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009ad:	85 c0                	test   %eax,%eax
  8009af:	74 1b                	je     8009cc <strncmp+0x2c>
  8009b1:	8a 1a                	mov    (%edx),%bl
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	74 24                	je     8009db <strncmp+0x3b>
  8009b7:	3a 19                	cmp    (%ecx),%bl
  8009b9:	75 20                	jne    8009db <strncmp+0x3b>
  8009bb:	48                   	dec    %eax
  8009bc:	74 15                	je     8009d3 <strncmp+0x33>
		n--, p++, q++;
  8009be:	42                   	inc    %edx
  8009bf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c0:	8a 1a                	mov    (%edx),%bl
  8009c2:	84 db                	test   %bl,%bl
  8009c4:	74 15                	je     8009db <strncmp+0x3b>
  8009c6:	3a 19                	cmp    (%ecx),%bl
  8009c8:	74 f1                	je     8009bb <strncmp+0x1b>
  8009ca:	eb 0f                	jmp    8009db <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	eb 05                	jmp    8009d8 <strncmp+0x38>
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009db:	0f b6 02             	movzbl (%edx),%eax
  8009de:	0f b6 11             	movzbl (%ecx),%edx
  8009e1:	29 d0                	sub    %edx,%eax
  8009e3:	eb f3                	jmp    8009d8 <strncmp+0x38>

008009e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ee:	8a 10                	mov    (%eax),%dl
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	74 18                	je     800a0c <strchr+0x27>
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	75 06                	jne    8009fe <strchr+0x19>
  8009f8:	eb 17                	jmp    800a11 <strchr+0x2c>
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 13                	je     800a11 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fe:	40                   	inc    %eax
  8009ff:	8a 10                	mov    (%eax),%dl
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f5                	jne    8009fa <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	eb 05                	jmp    800a11 <strchr+0x2c>
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a1c:	8a 10                	mov    (%eax),%dl
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	74 11                	je     800a33 <strfind+0x20>
		if (*s == c)
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	75 06                	jne    800a2c <strfind+0x19>
  800a26:	eb 0b                	jmp    800a33 <strfind+0x20>
  800a28:	38 ca                	cmp    %cl,%dl
  800a2a:	74 07                	je     800a33 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2c:	40                   	inc    %eax
  800a2d:	8a 10                	mov    (%eax),%dl
  800a2f:	84 d2                	test   %dl,%dl
  800a31:	75 f5                	jne    800a28 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a44:	85 c9                	test   %ecx,%ecx
  800a46:	74 30                	je     800a78 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4e:	75 25                	jne    800a75 <memset+0x40>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 20                	jne    800a75 <memset+0x40>
		c &= 0xFF;
  800a55:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 18             	shl    $0x18,%esi
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 d0                	or     %edx,%eax
  800a6b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a6d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a70:	fc                   	cld    
  800a71:	f3 ab                	rep stos %eax,%es:(%edi)
  800a73:	eb 03                	jmp    800a78 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a75:	fc                   	cld    
  800a76:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a78:	89 f8                	mov    %edi,%eax
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8d:	39 c6                	cmp    %eax,%esi
  800a8f:	73 34                	jae    800ac5 <memmove+0x46>
  800a91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a94:	39 d0                	cmp    %edx,%eax
  800a96:	73 2d                	jae    800ac5 <memmove+0x46>
		s += n;
		d += n;
  800a98:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	f6 c2 03             	test   $0x3,%dl
  800a9e:	75 1b                	jne    800abb <memmove+0x3c>
  800aa0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa6:	75 13                	jne    800abb <memmove+0x3c>
  800aa8:	f6 c1 03             	test   $0x3,%cl
  800aab:	75 0e                	jne    800abb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aad:	83 ef 04             	sub    $0x4,%edi
  800ab0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ab6:	fd                   	std    
  800ab7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab9:	eb 07                	jmp    800ac2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abb:	4f                   	dec    %edi
  800abc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800abf:	fd                   	std    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac2:	fc                   	cld    
  800ac3:	eb 20                	jmp    800ae5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800acb:	75 13                	jne    800ae0 <memmove+0x61>
  800acd:	a8 03                	test   $0x3,%al
  800acf:	75 0f                	jne    800ae0 <memmove+0x61>
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 0a                	jne    800ae0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	fc                   	cld    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 05                	jmp    800ae5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aec:	ff 75 10             	pushl  0x10(%ebp)
  800aef:	ff 75 0c             	pushl  0xc(%ebp)
  800af2:	ff 75 08             	pushl  0x8(%ebp)
  800af5:	e8 85 ff ff ff       	call   800a7f <memmove>
}
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	74 32                	je     800b41 <memcmp+0x45>
		if (*s1 != *s2)
  800b0f:	8a 03                	mov    (%ebx),%al
  800b11:	8a 0e                	mov    (%esi),%cl
  800b13:	38 c8                	cmp    %cl,%al
  800b15:	74 19                	je     800b30 <memcmp+0x34>
  800b17:	eb 0d                	jmp    800b26 <memcmp+0x2a>
  800b19:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b1d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b21:	42                   	inc    %edx
  800b22:	38 c8                	cmp    %cl,%al
  800b24:	74 10                	je     800b36 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b26:	0f b6 c0             	movzbl %al,%eax
  800b29:	0f b6 c9             	movzbl %cl,%ecx
  800b2c:	29 c8                	sub    %ecx,%eax
  800b2e:	eb 16                	jmp    800b46 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b30:	4f                   	dec    %edi
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	39 fa                	cmp    %edi,%edx
  800b38:	75 df                	jne    800b19 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	eb 05                	jmp    800b46 <memcmp+0x4a>
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b51:	89 c2                	mov    %eax,%edx
  800b53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b56:	39 d0                	cmp    %edx,%eax
  800b58:	73 12                	jae    800b6c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b5d:	38 08                	cmp    %cl,(%eax)
  800b5f:	75 06                	jne    800b67 <memfind+0x1c>
  800b61:	eb 09                	jmp    800b6c <memfind+0x21>
  800b63:	38 08                	cmp    %cl,(%eax)
  800b65:	74 05                	je     800b6c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b67:	40                   	inc    %eax
  800b68:	39 c2                	cmp    %eax,%edx
  800b6a:	77 f7                	ja     800b63 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	eb 01                	jmp    800b7d <strtol+0xf>
		s++;
  800b7c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7d:	8a 02                	mov    (%edx),%al
  800b7f:	3c 20                	cmp    $0x20,%al
  800b81:	74 f9                	je     800b7c <strtol+0xe>
  800b83:	3c 09                	cmp    $0x9,%al
  800b85:	74 f5                	je     800b7c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b87:	3c 2b                	cmp    $0x2b,%al
  800b89:	75 08                	jne    800b93 <strtol+0x25>
		s++;
  800b8b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	eb 13                	jmp    800ba6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b93:	3c 2d                	cmp    $0x2d,%al
  800b95:	75 0a                	jne    800ba1 <strtol+0x33>
		s++, neg = 1;
  800b97:	8d 52 01             	lea    0x1(%edx),%edx
  800b9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9f:	eb 05                	jmp    800ba6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba6:	85 db                	test   %ebx,%ebx
  800ba8:	74 05                	je     800baf <strtol+0x41>
  800baa:	83 fb 10             	cmp    $0x10,%ebx
  800bad:	75 28                	jne    800bd7 <strtol+0x69>
  800baf:	8a 02                	mov    (%edx),%al
  800bb1:	3c 30                	cmp    $0x30,%al
  800bb3:	75 10                	jne    800bc5 <strtol+0x57>
  800bb5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb9:	75 0a                	jne    800bc5 <strtol+0x57>
		s += 2, base = 16;
  800bbb:	83 c2 02             	add    $0x2,%edx
  800bbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc3:	eb 12                	jmp    800bd7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bc5:	85 db                	test   %ebx,%ebx
  800bc7:	75 0e                	jne    800bd7 <strtol+0x69>
  800bc9:	3c 30                	cmp    $0x30,%al
  800bcb:	75 05                	jne    800bd2 <strtol+0x64>
		s++, base = 8;
  800bcd:	42                   	inc    %edx
  800bce:	b3 08                	mov    $0x8,%bl
  800bd0:	eb 05                	jmp    800bd7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bde:	8a 0a                	mov    (%edx),%cl
  800be0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be3:	80 fb 09             	cmp    $0x9,%bl
  800be6:	77 08                	ja     800bf0 <strtol+0x82>
			dig = *s - '0';
  800be8:	0f be c9             	movsbl %cl,%ecx
  800beb:	83 e9 30             	sub    $0x30,%ecx
  800bee:	eb 1e                	jmp    800c0e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bf0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bf8:	0f be c9             	movsbl %cl,%ecx
  800bfb:	83 e9 57             	sub    $0x57,%ecx
  800bfe:	eb 0e                	jmp    800c0e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c00:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 13                	ja     800c1b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c08:	0f be c9             	movsbl %cl,%ecx
  800c0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0e:	39 f1                	cmp    %esi,%ecx
  800c10:	7d 0d                	jge    800c1f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c12:	42                   	inc    %edx
  800c13:	0f af c6             	imul   %esi,%eax
  800c16:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c19:	eb c3                	jmp    800bde <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c1b:	89 c1                	mov    %eax,%ecx
  800c1d:	eb 02                	jmp    800c21 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c25:	74 05                	je     800c2c <strtol+0xbe>
		*endptr = (char *) s;
  800c27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c2a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c2c:	85 ff                	test   %edi,%edi
  800c2e:	74 04                	je     800c34 <strtol+0xc6>
  800c30:	89 c8                	mov    %ecx,%eax
  800c32:	f7 d8                	neg    %eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    
  800c39:	00 00                	add    %al,(%eax)
	...

00800c3c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 1c             	sub    $0x1c,%esp
  800c45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c48:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c4b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c50:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c59:	cd 30                	int    $0x30
  800c5b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c61:	74 1c                	je     800c7f <syscall+0x43>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 18                	jle    800c7f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6e:	68 9f 26 80 00       	push   $0x80269f
  800c73:	6a 42                	push   $0x42
  800c75:	68 bc 26 80 00       	push   $0x8026bc
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

	return ret;
}
  800c7f:	89 d0                	mov    %edx,%eax
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c8f:	6a 00                	push   $0x0
  800c91:	6a 00                	push   $0x0
  800c93:	6a 00                	push   $0x0
  800c95:	ff 75 0c             	pushl  0xc(%ebp)
  800c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca5:	e8 92 ff ff ff       	call   800c3c <syscall>
  800caa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_cgetc>:

int
sys_cgetc(void)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cb5:	6a 00                	push   $0x0
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccc:	e8 6b ff ff ff       	call   800c3c <syscall>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	6a 00                	push   $0x0
  800ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cee:	e8 49 ff ff ff       	call   800c3c <syscall>
}
  800cf3:	c9                   	leave  
  800cf4:	c3                   	ret    

00800cf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d12:	e8 25 ff ff ff       	call   800c3c <syscall>
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_yield>:

void
sys_yield(void)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d1f:	6a 00                	push   $0x0
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d36:	e8 01 ff ff ff       	call   800c3c <syscall>
  800d3b:	83 c4 10             	add    $0x10,%esp
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d46:	6a 00                	push   $0x0
  800d48:	6a 00                	push   $0x0
  800d4a:	ff 75 10             	pushl  0x10(%ebp)
  800d4d:	ff 75 0c             	pushl  0xc(%ebp)
  800d50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d53:	ba 01 00 00 00       	mov    $0x1,%edx
  800d58:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5d:	e8 da fe ff ff       	call   800c3c <syscall>
}
  800d62:	c9                   	leave  
  800d63:	c3                   	ret    

00800d64 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d6a:	ff 75 18             	pushl  0x18(%ebp)
  800d6d:	ff 75 14             	pushl  0x14(%ebp)
  800d70:	ff 75 10             	pushl  0x10(%ebp)
  800d73:	ff 75 0c             	pushl  0xc(%ebp)
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d83:	e8 b4 fe ff ff       	call   800c3c <syscall>
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d90:	6a 00                	push   $0x0
  800d92:	6a 00                	push   $0x0
  800d94:	6a 00                	push   $0x0
  800d96:	ff 75 0c             	pushl  0xc(%ebp)
  800d99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800da1:	b8 06 00 00 00       	mov    $0x6,%eax
  800da6:	e8 91 fe ff ff       	call   800c3c <syscall>
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800db3:	6a 00                	push   $0x0
  800db5:	6a 00                	push   $0x0
  800db7:	6a 00                	push   $0x0
  800db9:	ff 75 0c             	pushl  0xc(%ebp)
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc9:	e8 6e fe ff ff       	call   800c3c <syscall>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dd6:	6a 00                	push   $0x0
  800dd8:	6a 00                	push   $0x0
  800dda:	6a 00                	push   $0x0
  800ddc:	ff 75 0c             	pushl  0xc(%ebp)
  800ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de2:	ba 01 00 00 00       	mov    $0x1,%edx
  800de7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dec:	e8 4b fe ff ff       	call   800c3c <syscall>
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800df9:	6a 00                	push   $0x0
  800dfb:	6a 00                	push   $0x0
  800dfd:	6a 00                	push   $0x0
  800dff:	ff 75 0c             	pushl  0xc(%ebp)
  800e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e05:	ba 01 00 00 00       	mov    $0x1,%edx
  800e0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0f:	e8 28 fe ff ff       	call   800c3c <syscall>
}
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e1c:	6a 00                	push   $0x0
  800e1e:	ff 75 14             	pushl  0x14(%ebp)
  800e21:	ff 75 10             	pushl  0x10(%ebp)
  800e24:	ff 75 0c             	pushl  0xc(%ebp)
  800e27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	e8 03 fe ff ff       	call   800c3c <syscall>
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e41:	6a 00                	push   $0x0
  800e43:	6a 00                	push   $0x0
  800e45:	6a 00                	push   $0x0
  800e47:	6a 00                	push   $0x0
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	e8 e1 fd ff ff       	call   800c3c <syscall>
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e63:	6a 00                	push   $0x0
  800e65:	6a 00                	push   $0x0
  800e67:	6a 00                	push   $0x0
  800e69:	ff 75 0c             	pushl  0xc(%ebp)
  800e6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e74:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e79:	e8 be fd ff ff       	call   800c3c <syscall>
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	53                   	push   %ebx
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e8c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e90:	75 14                	jne    800ea6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 cc 26 80 00       	push   $0x8026cc
  800e9a:	6a 20                	push   $0x20
  800e9c:	68 10 28 80 00       	push   $0x802810
  800ea1:	e8 8a f3 ff ff       	call   800230 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	c1 e8 16             	shr    $0x16,%eax
  800eab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb2:	a8 01                	test   $0x1,%al
  800eb4:	74 11                	je     800ec7 <pgfault+0x47>
  800eb6:	89 d8                	mov    %ebx,%eax
  800eb8:	c1 e8 0c             	shr    $0xc,%eax
  800ebb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec2:	f6 c4 08             	test   $0x8,%ah
  800ec5:	75 14                	jne    800edb <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	68 f0 26 80 00       	push   $0x8026f0
  800ecf:	6a 24                	push   $0x24
  800ed1:	68 10 28 80 00       	push   $0x802810
  800ed6:	e8 55 f3 ff ff       	call   800230 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800edb:	83 ec 04             	sub    $0x4,%esp
  800ede:	6a 07                	push   $0x7
  800ee0:	68 00 f0 7f 00       	push   $0x7ff000
  800ee5:	6a 00                	push   $0x0
  800ee7:	e8 54 fe ff ff       	call   800d40 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	79 12                	jns    800f05 <pgfault+0x85>
  800ef3:	50                   	push   %eax
  800ef4:	68 14 27 80 00       	push   $0x802714
  800ef9:	6a 32                	push   $0x32
  800efb:	68 10 28 80 00       	push   $0x802810
  800f00:	e8 2b f3 ff ff       	call   800230 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f05:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	68 00 10 00 00       	push   $0x1000
  800f13:	53                   	push   %ebx
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	e8 cb fb ff ff       	call   800ae9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f1e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f25:	53                   	push   %ebx
  800f26:	6a 00                	push   $0x0
  800f28:	68 00 f0 7f 00       	push   $0x7ff000
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 30 fe ff ff       	call   800d64 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 12                	jns    800f4d <pgfault+0xcd>
  800f3b:	50                   	push   %eax
  800f3c:	68 38 27 80 00       	push   $0x802738
  800f41:	6a 3a                	push   $0x3a
  800f43:	68 10 28 80 00       	push   $0x802810
  800f48:	e8 e3 f2 ff ff       	call   800230 <_panic>

	return;
}
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f5b:	68 80 0e 80 00       	push   $0x800e80
  800f60:	e8 eb 0e 00 00       	call   801e50 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f65:	ba 07 00 00 00       	mov    $0x7,%edx
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	cd 30                	int    $0x30
  800f6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f71:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 12                	jns    800f8c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f7a:	50                   	push   %eax
  800f7b:	68 1b 28 80 00       	push   $0x80281b
  800f80:	6a 7f                	push   $0x7f
  800f82:	68 10 28 80 00       	push   $0x802810
  800f87:	e8 a4 f2 ff ff       	call   800230 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f90:	75 25                	jne    800fb7 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f92:	e8 5e fd ff ff       	call   800cf5 <sys_getenvid>
  800f97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa3:	c1 e0 07             	shl    $0x7,%eax
  800fa6:	29 d0                	sub    %edx,%eax
  800fa8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fad:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800fb2:	e9 be 01 00 00       	jmp    801175 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	c1 e8 16             	shr    $0x16,%eax
  800fc1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc8:	a8 01                	test   $0x1,%al
  800fca:	0f 84 10 01 00 00    	je     8010e0 <fork+0x18e>
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
  800fd5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdc:	f6 c2 01             	test   $0x1,%dl
  800fdf:	0f 84 fb 00 00 00    	je     8010e0 <fork+0x18e>
  800fe5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fec:	f6 c2 04             	test   $0x4,%dl
  800fef:	0f 84 eb 00 00 00    	je     8010e0 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	c1 e6 0c             	shl    $0xc,%esi
  800ffa:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801000:	0f 84 da 00 00 00    	je     8010e0 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801006:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100d:	f6 c6 04             	test   $0x4,%dh
  801010:	74 37                	je     801049 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801012:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	25 07 0e 00 00       	and    $0xe07,%eax
  801021:	50                   	push   %eax
  801022:	56                   	push   %esi
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	6a 00                	push   $0x0
  801027:	e8 38 fd ff ff       	call   800d64 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	0f 89 a9 00 00 00    	jns    8010e0 <fork+0x18e>
  801037:	50                   	push   %eax
  801038:	68 5c 27 80 00       	push   $0x80275c
  80103d:	6a 54                	push   $0x54
  80103f:	68 10 28 80 00       	push   $0x802810
  801044:	e8 e7 f1 ff ff       	call   800230 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801049:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801050:	f6 c2 02             	test   $0x2,%dl
  801053:	75 0c                	jne    801061 <fork+0x10f>
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	f6 c4 08             	test   $0x8,%ah
  80105f:	74 57                	je     8010b8 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	68 05 08 00 00       	push   $0x805
  801069:	56                   	push   %esi
  80106a:	57                   	push   %edi
  80106b:	56                   	push   %esi
  80106c:	6a 00                	push   $0x0
  80106e:	e8 f1 fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	79 12                	jns    80108c <fork+0x13a>
  80107a:	50                   	push   %eax
  80107b:	68 5c 27 80 00       	push   $0x80275c
  801080:	6a 59                	push   $0x59
  801082:	68 10 28 80 00       	push   $0x802810
  801087:	e8 a4 f1 ff ff       	call   800230 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	68 05 08 00 00       	push   $0x805
  801094:	56                   	push   %esi
  801095:	6a 00                	push   $0x0
  801097:	56                   	push   %esi
  801098:	6a 00                	push   $0x0
  80109a:	e8 c5 fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80109f:	83 c4 20             	add    $0x20,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 3a                	jns    8010e0 <fork+0x18e>
  8010a6:	50                   	push   %eax
  8010a7:	68 5c 27 80 00       	push   $0x80275c
  8010ac:	6a 5c                	push   $0x5c
  8010ae:	68 10 28 80 00       	push   $0x802810
  8010b3:	e8 78 f1 ff ff       	call   800230 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	6a 05                	push   $0x5
  8010bd:	56                   	push   %esi
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 9d fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010c7:	83 c4 20             	add    $0x20,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 12                	jns    8010e0 <fork+0x18e>
  8010ce:	50                   	push   %eax
  8010cf:	68 5c 27 80 00       	push   $0x80275c
  8010d4:	6a 60                	push   $0x60
  8010d6:	68 10 28 80 00       	push   $0x802810
  8010db:	e8 50 f1 ff ff       	call   800230 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8010e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010ec:	0f 85 ca fe ff ff    	jne    800fbc <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	6a 07                	push   $0x7
  8010f7:	68 00 f0 bf ee       	push   $0xeebff000
  8010fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ff:	e8 3c fc ff ff       	call   800d40 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	79 15                	jns    801120 <fork+0x1ce>
  80110b:	50                   	push   %eax
  80110c:	68 80 27 80 00       	push   $0x802780
  801111:	68 94 00 00 00       	push   $0x94
  801116:	68 10 28 80 00       	push   $0x802810
  80111b:	e8 10 f1 ff ff       	call   800230 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	68 bc 1e 80 00       	push   $0x801ebc
  801128:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112b:	e8 c3 fc ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	79 15                	jns    80114c <fork+0x1fa>
  801137:	50                   	push   %eax
  801138:	68 b8 27 80 00       	push   $0x8027b8
  80113d:	68 99 00 00 00       	push   $0x99
  801142:	68 10 28 80 00       	push   $0x802810
  801147:	e8 e4 f0 ff ff       	call   800230 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	6a 02                	push   $0x2
  801151:	ff 75 e4             	pushl  -0x1c(%ebp)
  801154:	e8 54 fc ff ff       	call   800dad <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	79 15                	jns    801175 <fork+0x223>
  801160:	50                   	push   %eax
  801161:	68 dc 27 80 00       	push   $0x8027dc
  801166:	68 a4 00 00 00       	push   $0xa4
  80116b:	68 10 28 80 00       	push   $0x802810
  801170:	e8 bb f0 ff ff       	call   800230 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <sfork>:

// Challenge!
int
sfork(void)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801186:	68 38 28 80 00       	push   $0x802838
  80118b:	68 b1 00 00 00       	push   $0xb1
  801190:	68 10 28 80 00       	push   $0x802810
  801195:	e8 96 f0 ff ff       	call   800230 <_panic>
	...

0080119c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011af:	ff 75 08             	pushl  0x8(%ebp)
  8011b2:	e8 e5 ff ff ff       	call   80119c <fd2num>
  8011b7:	83 c4 04             	add    $0x4,%esp
  8011ba:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011bf:	c1 e0 0c             	shl    $0xc,%eax
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011d0:	a8 01                	test   $0x1,%al
  8011d2:	74 34                	je     801208 <fd_alloc+0x44>
  8011d4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011d9:	a8 01                	test   $0x1,%al
  8011db:	74 32                	je     80120f <fd_alloc+0x4b>
  8011dd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011e2:	89 c1                	mov    %eax,%ecx
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 16             	shr    $0x16,%edx
  8011e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	74 1f                	je     801214 <fd_alloc+0x50>
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 0c             	shr    $0xc,%edx
  8011fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	75 17                	jne    80121d <fd_alloc+0x59>
  801206:	eb 0c                	jmp    801214 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801208:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80120d:	eb 05                	jmp    801214 <fd_alloc+0x50>
  80120f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801214:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
  80121b:	eb 17                	jmp    801234 <fd_alloc+0x70>
  80121d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801222:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801227:	75 b9                	jne    8011e2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80122f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801234:	5b                   	pop    %ebx
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123d:	83 f8 1f             	cmp    $0x1f,%eax
  801240:	77 36                	ja     801278 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801242:	05 00 00 0d 00       	add    $0xd0000,%eax
  801247:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	c1 ea 16             	shr    $0x16,%edx
  80124f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 24                	je     80127f <fd_lookup+0x48>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 1a                	je     801286 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126f:	89 02                	mov    %eax,(%edx)
	return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	eb 13                	jmp    80128b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127d:	eb 0c                	jmp    80128b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801284:	eb 05                	jmp    80128b <fd_lookup+0x54>
  801286:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	53                   	push   %ebx
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80129a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012a0:	74 0d                	je     8012af <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 14                	jmp    8012bd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012a9:	39 0a                	cmp    %ecx,(%edx)
  8012ab:	75 10                	jne    8012bd <dev_lookup+0x30>
  8012ad:	eb 05                	jmp    8012b4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012af:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012b4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bb:	eb 31                	jmp    8012ee <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012bd:	40                   	inc    %eax
  8012be:	8b 14 85 cc 28 80 00 	mov    0x8028cc(,%eax,4),%edx
  8012c5:	85 d2                	test   %edx,%edx
  8012c7:	75 e0                	jne    8012a9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	51                   	push   %ecx
  8012d5:	50                   	push   %eax
  8012d6:	68 50 28 80 00       	push   $0x802850
  8012db:	e8 28 f0 ff ff       	call   800308 <cprintf>
	*dev = 0;
  8012e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 20             	sub    $0x20,%esp
  8012fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fe:	8a 45 0c             	mov    0xc(%ebp),%al
  801301:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801304:	56                   	push   %esi
  801305:	e8 92 fe ff ff       	call   80119c <fd2num>
  80130a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80130d:	89 14 24             	mov    %edx,(%esp)
  801310:	50                   	push   %eax
  801311:	e8 21 ff ff ff       	call   801237 <fd_lookup>
  801316:	89 c3                	mov    %eax,%ebx
  801318:	83 c4 08             	add    $0x8,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 05                	js     801324 <fd_close+0x31>
	    || fd != fd2)
  80131f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801322:	74 0d                	je     801331 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801324:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801328:	75 48                	jne    801372 <fd_close+0x7f>
  80132a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132f:	eb 41                	jmp    801372 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 36                	pushl  (%esi)
  80133a:	e8 4e ff ff ff       	call   80128d <dev_lookup>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 1c                	js     801364 <fd_close+0x71>
		if (dev->dev_close)
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	8b 40 10             	mov    0x10(%eax),%eax
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 0d                	je     80135f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	56                   	push   %esi
  801356:	ff d0                	call   *%eax
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	eb 05                	jmp    801364 <fd_close+0x71>
		else
			r = 0;
  80135f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 1b fa ff ff       	call   800d8a <sys_page_unmap>
	return r;
  80136f:	83 c4 10             	add    $0x10,%esp
}
  801372:	89 d8                	mov    %ebx,%eax
  801374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 aa fe ff ff       	call   801237 <fd_lookup>
  80138d:	83 c4 08             	add    $0x8,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 10                	js     8013a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	6a 01                	push   $0x1
  801399:	ff 75 f4             	pushl  -0xc(%ebp)
  80139c:	e8 52 ff ff ff       	call   8012f3 <fd_close>
  8013a1:	83 c4 10             	add    $0x10,%esp
}
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <close_all>:

void
close_all(void)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	e8 c0 ff ff ff       	call   80137b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bb:	43                   	inc    %ebx
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	83 fb 20             	cmp    $0x20,%ebx
  8013c2:	75 ee                	jne    8013b2 <close_all+0xc>
		close(i);
}
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 2c             	sub    $0x2c,%esp
  8013d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 08             	pushl  0x8(%ebp)
  8013dc:	e8 56 fe ff ff       	call   801237 <fd_lookup>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 08             	add    $0x8,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	0f 88 c0 00 00 00    	js     8014ae <dup+0xe5>
		return r;
	close(newfdnum);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	57                   	push   %edi
  8013f2:	e8 84 ff ff ff       	call   80137b <close>

	newfd = INDEX2FD(newfdnum);
  8013f7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013fd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801400:	83 c4 04             	add    $0x4,%esp
  801403:	ff 75 e4             	pushl  -0x1c(%ebp)
  801406:	e8 a1 fd ff ff       	call   8011ac <fd2data>
  80140b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80140d:	89 34 24             	mov    %esi,(%esp)
  801410:	e8 97 fd ff ff       	call   8011ac <fd2data>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	c1 e8 16             	shr    $0x16,%eax
  801420:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801427:	a8 01                	test   $0x1,%al
  801429:	74 37                	je     801462 <dup+0x99>
  80142b:	89 d8                	mov    %ebx,%eax
  80142d:	c1 e8 0c             	shr    $0xc,%eax
  801430:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801437:	f6 c2 01             	test   $0x1,%dl
  80143a:	74 26                	je     801462 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	25 07 0e 00 00       	and    $0xe07,%eax
  80144b:	50                   	push   %eax
  80144c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144f:	6a 00                	push   $0x0
  801451:	53                   	push   %ebx
  801452:	6a 00                	push   $0x0
  801454:	e8 0b f9 ff ff       	call   800d64 <sys_page_map>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 20             	add    $0x20,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 2d                	js     80148f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801462:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801465:	89 c2                	mov    %eax,%edx
  801467:	c1 ea 0c             	shr    $0xc,%edx
  80146a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80147a:	52                   	push   %edx
  80147b:	56                   	push   %esi
  80147c:	6a 00                	push   $0x0
  80147e:	50                   	push   %eax
  80147f:	6a 00                	push   $0x0
  801481:	e8 de f8 ff ff       	call   800d64 <sys_page_map>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	83 c4 20             	add    $0x20,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	79 1d                	jns    8014ac <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	56                   	push   %esi
  801493:	6a 00                	push   $0x0
  801495:	e8 f0 f8 ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149a:	83 c4 08             	add    $0x8,%esp
  80149d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a0:	6a 00                	push   $0x0
  8014a2:	e8 e3 f8 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 02                	jmp    8014ae <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014ac:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ae:	89 d8                	mov    %ebx,%eax
  8014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 14             	sub    $0x14,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	53                   	push   %ebx
  8014c7:	e8 6b fd ff ff       	call   801237 <fd_lookup>
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 67                	js     80153a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	ff 30                	pushl  (%eax)
  8014df:	e8 a9 fd ff ff       	call   80128d <dev_lookup>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 4f                	js     80153a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ee:	8b 50 08             	mov    0x8(%eax),%edx
  8014f1:	83 e2 03             	and    $0x3,%edx
  8014f4:	83 fa 01             	cmp    $0x1,%edx
  8014f7:	75 21                	jne    80151a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 91 28 80 00       	push   $0x802891
  80150b:	e8 f8 ed ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801518:	eb 20                	jmp    80153a <read+0x82>
	}
	if (!dev->dev_read)
  80151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151d:	8b 52 08             	mov    0x8(%edx),%edx
  801520:	85 d2                	test   %edx,%edx
  801522:	74 11                	je     801535 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	ff 75 10             	pushl  0x10(%ebp)
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	50                   	push   %eax
  80152e:	ff d2                	call   *%edx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	eb 05                	jmp    80153a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801535:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	57                   	push   %edi
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154e:	85 f6                	test   %esi,%esi
  801550:	74 31                	je     801583 <readn+0x44>
  801552:	b8 00 00 00 00       	mov    $0x0,%eax
  801557:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	89 f2                	mov    %esi,%edx
  801561:	29 c2                	sub    %eax,%edx
  801563:	52                   	push   %edx
  801564:	03 45 0c             	add    0xc(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	57                   	push   %edi
  801569:	e8 4a ff ff ff       	call   8014b8 <read>
		if (m < 0)
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 17                	js     80158c <readn+0x4d>
			return m;
		if (m == 0)
  801575:	85 c0                	test   %eax,%eax
  801577:	74 11                	je     80158a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801579:	01 c3                	add    %eax,%ebx
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	39 f3                	cmp    %esi,%ebx
  80157f:	72 db                	jb     80155c <readn+0x1d>
  801581:	eb 09                	jmp    80158c <readn+0x4d>
  801583:	b8 00 00 00 00       	mov    $0x0,%eax
  801588:	eb 02                	jmp    80158c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80158a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80158c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5f                   	pop    %edi
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	53                   	push   %ebx
  801598:	83 ec 14             	sub    $0x14,%esp
  80159b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	53                   	push   %ebx
  8015a3:	e8 8f fc ff ff       	call   801237 <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 62                	js     801611 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 cd fc ff ff       	call   80128d <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 4a                	js     801611 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ce:	75 21                	jne    8015f1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d5:	8b 40 48             	mov    0x48(%eax),%eax
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	53                   	push   %ebx
  8015dc:	50                   	push   %eax
  8015dd:	68 ad 28 80 00       	push   $0x8028ad
  8015e2:	e8 21 ed ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ef:	eb 20                	jmp    801611 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	74 11                	je     80160c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	50                   	push   %eax
  801605:	ff d2                	call   *%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 05                	jmp    801611 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <seek>:

int
seek(int fdnum, off_t offset)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 0f fc ff ff       	call   801237 <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 0e                	js     80163d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
  801635:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	53                   	push   %ebx
  80164e:	e8 e4 fb ff ff       	call   801237 <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 5f                	js     8016b9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 22 fc ff ff       	call   80128d <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 47                	js     8016b9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801679:	75 21                	jne    80169c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801680:	8b 40 48             	mov    0x48(%eax),%eax
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	53                   	push   %ebx
  801687:	50                   	push   %eax
  801688:	68 70 28 80 00       	push   $0x802870
  80168d:	e8 76 ec ff ff       	call   800308 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169a:	eb 1d                	jmp    8016b9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80169c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169f:	8b 52 18             	mov    0x18(%edx),%edx
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	74 0e                	je     8016b4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	ff d2                	call   *%edx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 05                	jmp    8016b9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 14             	sub    $0x14,%esp
  8016c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 63 fb ff ff       	call   801237 <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 52                	js     80172d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	ff 30                	pushl  (%eax)
  8016e7:	e8 a1 fb ff ff       	call   80128d <dev_lookup>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 3a                	js     80172d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016fa:	74 2c                	je     801728 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801706:	00 00 00 
	stat->st_isdir = 0;
  801709:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801710:	00 00 00 
	stat->st_dev = dev;
  801713:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	53                   	push   %ebx
  80171d:	ff 75 f0             	pushl  -0x10(%ebp)
  801720:	ff 50 14             	call   *0x14(%eax)
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	eb 05                	jmp    80172d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801728:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	6a 00                	push   $0x0
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 78 01 00 00       	call   8018bc <open>
  801744:	89 c3                	mov    %eax,%ebx
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 1b                	js     801768 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	50                   	push   %eax
  801754:	e8 65 ff ff ff       	call   8016be <fstat>
  801759:	89 c6                	mov    %eax,%esi
	close(fd);
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 18 fc ff ff       	call   80137b <close>
	return r;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	89 f3                	mov    %esi,%ebx
}
  801768:	89 d8                	mov    %ebx,%eax
  80176a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	c9                   	leave  
  801770:	c3                   	ret    
  801771:	00 00                	add    %al,(%eax)
	...

00801774 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	56                   	push   %esi
  801778:	53                   	push   %ebx
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80177d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801784:	75 12                	jne    801798 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	6a 01                	push   $0x1
  80178b:	e8 1e 08 00 00       	call   801fae <ipc_find_env>
  801790:	a3 00 40 80 00       	mov    %eax,0x804000
  801795:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801798:	6a 07                	push   $0x7
  80179a:	68 00 50 80 00       	push   $0x805000
  80179f:	53                   	push   %ebx
  8017a0:	ff 35 00 40 80 00    	pushl  0x804000
  8017a6:	e8 ae 07 00 00       	call   801f59 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017ab:	83 c4 0c             	add    $0xc,%esp
  8017ae:	6a 00                	push   $0x0
  8017b0:	56                   	push   %esi
  8017b1:	6a 00                	push   $0x0
  8017b3:	e8 2c 07 00 00       	call   801ee4 <ipc_recv>
}
  8017b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 04             	sub    $0x4,%esp
  8017c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017de:	e8 91 ff ff ff       	call   801774 <fsipc>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 2c                	js     801813 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	68 00 50 80 00       	push   $0x805000
  8017ef:	53                   	push   %ebx
  8017f0:	e8 c9 f0 ff ff       	call   8008be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801800:	a1 84 50 80 00       	mov    0x805084,%eax
  801805:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	8b 40 0c             	mov    0xc(%eax),%eax
  801824:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	b8 06 00 00 00       	mov    $0x6,%eax
  801833:	e8 3c ff ff ff       	call   801774 <fsipc>
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	8b 40 0c             	mov    0xc(%eax),%eax
  801848:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80184d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 03 00 00 00       	mov    $0x3,%eax
  80185d:	e8 12 ff ff ff       	call   801774 <fsipc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	85 c0                	test   %eax,%eax
  801866:	78 4b                	js     8018b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801868:	39 c6                	cmp    %eax,%esi
  80186a:	73 16                	jae    801882 <devfile_read+0x48>
  80186c:	68 dc 28 80 00       	push   $0x8028dc
  801871:	68 e3 28 80 00       	push   $0x8028e3
  801876:	6a 7d                	push   $0x7d
  801878:	68 f8 28 80 00       	push   $0x8028f8
  80187d:	e8 ae e9 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801882:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801887:	7e 16                	jle    80189f <devfile_read+0x65>
  801889:	68 03 29 80 00       	push   $0x802903
  80188e:	68 e3 28 80 00       	push   $0x8028e3
  801893:	6a 7e                	push   $0x7e
  801895:	68 f8 28 80 00       	push   $0x8028f8
  80189a:	e8 91 e9 ff ff       	call   800230 <_panic>
	memmove(buf, &fsipcbuf, r);
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	50                   	push   %eax
  8018a3:	68 00 50 80 00       	push   $0x805000
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	e8 cf f1 ff ff       	call   800a7f <memmove>
	return r;
  8018b0:	83 c4 10             	add    $0x10,%esp
}
  8018b3:	89 d8                	mov    %ebx,%eax
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	83 ec 1c             	sub    $0x1c,%esp
  8018c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c7:	56                   	push   %esi
  8018c8:	e8 9f ef ff ff       	call   80086c <strlen>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d5:	7f 65                	jg     80193c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	e8 e1 f8 ff ff       	call   8011c4 <fd_alloc>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 55                	js     801941 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	56                   	push   %esi
  8018f0:	68 00 50 80 00       	push   $0x805000
  8018f5:	e8 c4 ef ff ff       	call   8008be <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801902:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801905:	b8 01 00 00 00       	mov    $0x1,%eax
  80190a:	e8 65 fe ff ff       	call   801774 <fsipc>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	79 12                	jns    80192a <open+0x6e>
		fd_close(fd, 0);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	6a 00                	push   $0x0
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	e8 ce f9 ff ff       	call   8012f3 <fd_close>
		return r;
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 17                	jmp    801941 <open+0x85>
	}

	return fd2num(fd);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	ff 75 f4             	pushl  -0xc(%ebp)
  801930:	e8 67 f8 ff ff       	call   80119c <fd2num>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb 05                	jmp    801941 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80193c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801941:	89 d8                	mov    %ebx,%eax
  801943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	c9                   	leave  
  801949:	c3                   	ret    
	...

0080194c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 4d f8 ff ff       	call   8011ac <fd2data>
  80195f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801961:	83 c4 08             	add    $0x8,%esp
  801964:	68 0f 29 80 00       	push   $0x80290f
  801969:	56                   	push   %esi
  80196a:	e8 4f ef ff ff       	call   8008be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196f:	8b 43 04             	mov    0x4(%ebx),%eax
  801972:	2b 03                	sub    (%ebx),%eax
  801974:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80197a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801981:	00 00 00 
	stat->st_dev = &devpipe;
  801984:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80198b:	30 80 00 
	return 0;
}
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
  801993:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a4:	53                   	push   %ebx
  8019a5:	6a 00                	push   $0x0
  8019a7:	e8 de f3 ff ff       	call   800d8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ac:	89 1c 24             	mov    %ebx,(%esp)
  8019af:	e8 f8 f7 ff ff       	call   8011ac <fd2data>
  8019b4:	83 c4 08             	add    $0x8,%esp
  8019b7:	50                   	push   %eax
  8019b8:	6a 00                	push   $0x0
  8019ba:	e8 cb f3 ff ff       	call   800d8a <sys_page_unmap>
}
  8019bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	57                   	push   %edi
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 1c             	sub    $0x1c,%esp
  8019cd:	89 c7                	mov    %eax,%edi
  8019cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019d7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	57                   	push   %edi
  8019de:	e8 29 06 00 00       	call   80200c <pageref>
  8019e3:	89 c6                	mov    %eax,%esi
  8019e5:	83 c4 04             	add    $0x4,%esp
  8019e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019eb:	e8 1c 06 00 00       	call   80200c <pageref>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	39 c6                	cmp    %eax,%esi
  8019f5:	0f 94 c0             	sete   %al
  8019f8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019fb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a01:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a04:	39 cb                	cmp    %ecx,%ebx
  801a06:	75 08                	jne    801a10 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a10:	83 f8 01             	cmp    $0x1,%eax
  801a13:	75 bd                	jne    8019d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a15:	8b 42 58             	mov    0x58(%edx),%eax
  801a18:	6a 01                	push   $0x1
  801a1a:	50                   	push   %eax
  801a1b:	53                   	push   %ebx
  801a1c:	68 16 29 80 00       	push   $0x802916
  801a21:	e8 e2 e8 ff ff       	call   800308 <cprintf>
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	eb a7                	jmp    8019d2 <_pipeisclosed+0xe>

00801a2b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	57                   	push   %edi
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	83 ec 28             	sub    $0x28,%esp
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a37:	56                   	push   %esi
  801a38:	e8 6f f7 ff ff       	call   8011ac <fd2data>
  801a3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a46:	75 4a                	jne    801a92 <devpipe_write+0x67>
  801a48:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4d:	eb 56                	jmp    801aa5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	89 f0                	mov    %esi,%eax
  801a53:	e8 6c ff ff ff       	call   8019c4 <_pipeisclosed>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	75 4d                	jne    801aa9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5c:	e8 b8 f2 ff ff       	call   800d19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a61:	8b 43 04             	mov    0x4(%ebx),%eax
  801a64:	8b 13                	mov    (%ebx),%edx
  801a66:	83 c2 20             	add    $0x20,%edx
  801a69:	39 d0                	cmp    %edx,%eax
  801a6b:	73 e2                	jae    801a4f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6d:	89 c2                	mov    %eax,%edx
  801a6f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a75:	79 05                	jns    801a7c <devpipe_write+0x51>
  801a77:	4a                   	dec    %edx
  801a78:	83 ca e0             	or     $0xffffffe0,%edx
  801a7b:	42                   	inc    %edx
  801a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a82:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a86:	40                   	inc    %eax
  801a87:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8a:	47                   	inc    %edi
  801a8b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a8e:	77 07                	ja     801a97 <devpipe_write+0x6c>
  801a90:	eb 13                	jmp    801aa5 <devpipe_write+0x7a>
  801a92:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a97:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9a:	8b 13                	mov    (%ebx),%edx
  801a9c:	83 c2 20             	add    $0x20,%edx
  801a9f:	39 d0                	cmp    %edx,%eax
  801aa1:	73 ac                	jae    801a4f <devpipe_write+0x24>
  801aa3:	eb c8                	jmp    801a6d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa5:	89 f8                	mov    %edi,%eax
  801aa7:	eb 05                	jmp    801aae <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5f                   	pop    %edi
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 18             	sub    $0x18,%esp
  801abf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac2:	57                   	push   %edi
  801ac3:	e8 e4 f6 ff ff       	call   8011ac <fd2data>
  801ac8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad1:	75 44                	jne    801b17 <devpipe_read+0x61>
  801ad3:	be 00 00 00 00       	mov    $0x0,%esi
  801ad8:	eb 4f                	jmp    801b29 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ada:	89 f0                	mov    %esi,%eax
  801adc:	eb 54                	jmp    801b32 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ade:	89 da                	mov    %ebx,%edx
  801ae0:	89 f8                	mov    %edi,%eax
  801ae2:	e8 dd fe ff ff       	call   8019c4 <_pipeisclosed>
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	75 42                	jne    801b2d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aeb:	e8 29 f2 ff ff       	call   800d19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af0:	8b 03                	mov    (%ebx),%eax
  801af2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801af5:	74 e7                	je     801ade <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801afc:	79 05                	jns    801b03 <devpipe_read+0x4d>
  801afe:	48                   	dec    %eax
  801aff:	83 c8 e0             	or     $0xffffffe0,%eax
  801b02:	40                   	inc    %eax
  801b03:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b0d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	46                   	inc    %esi
  801b10:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b13:	77 07                	ja     801b1c <devpipe_read+0x66>
  801b15:	eb 12                	jmp    801b29 <devpipe_read+0x73>
  801b17:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b1c:	8b 03                	mov    (%ebx),%eax
  801b1e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b21:	75 d4                	jne    801af7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b23:	85 f6                	test   %esi,%esi
  801b25:	75 b3                	jne    801ada <devpipe_read+0x24>
  801b27:	eb b5                	jmp    801ade <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b29:	89 f0                	mov    %esi,%eax
  801b2b:	eb 05                	jmp    801b32 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 28             	sub    $0x28,%esp
  801b43:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b49:	50                   	push   %eax
  801b4a:	e8 75 f6 ff ff       	call   8011c4 <fd_alloc>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	85 c0                	test   %eax,%eax
  801b56:	0f 88 24 01 00 00    	js     801c80 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5c:	83 ec 04             	sub    $0x4,%esp
  801b5f:	68 07 04 00 00       	push   $0x407
  801b64:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b67:	6a 00                	push   $0x0
  801b69:	e8 d2 f1 ff ff       	call   800d40 <sys_page_alloc>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 05 01 00 00    	js     801c80 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	e8 3d f6 ff ff       	call   8011c4 <fd_alloc>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 dc 00 00 00    	js     801c70 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	68 07 04 00 00       	push   $0x407
  801b9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 9a f1 ff ff       	call   800d40 <sys_page_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 bd 00 00 00    	js     801c70 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb9:	e8 ee f5 ff ff       	call   8011ac <fd2data>
  801bbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	83 c4 0c             	add    $0xc,%esp
  801bc3:	68 07 04 00 00       	push   $0x407
  801bc8:	50                   	push   %eax
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 70 f1 ff ff       	call   800d40 <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 83 00 00 00    	js     801c60 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	ff 75 e0             	pushl  -0x20(%ebp)
  801be3:	e8 c4 f5 ff ff       	call   8011ac <fd2data>
  801be8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bef:	50                   	push   %eax
  801bf0:	6a 00                	push   $0x0
  801bf2:	56                   	push   %esi
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 6a f1 ff ff       	call   800d64 <sys_page_map>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 20             	add    $0x20,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 4f                	js     801c52 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c33:	e8 64 f5 ff ff       	call   80119c <fd2num>
  801c38:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c3a:	83 c4 04             	add    $0x4,%esp
  801c3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c40:	e8 57 f5 ff ff       	call   80119c <fd2num>
  801c45:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c50:	eb 2e                	jmp    801c80 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c52:	83 ec 08             	sub    $0x8,%esp
  801c55:	56                   	push   %esi
  801c56:	6a 00                	push   $0x0
  801c58:	e8 2d f1 ff ff       	call   800d8a <sys_page_unmap>
  801c5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	ff 75 e0             	pushl  -0x20(%ebp)
  801c66:	6a 00                	push   $0x0
  801c68:	e8 1d f1 ff ff       	call   800d8a <sys_page_unmap>
  801c6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c76:	6a 00                	push   $0x0
  801c78:	e8 0d f1 ff ff       	call   800d8a <sys_page_unmap>
  801c7d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5f                   	pop    %edi
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	ff 75 08             	pushl  0x8(%ebp)
  801c97:	e8 9b f5 ff ff       	call   801237 <fd_lookup>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 18                	js     801cbb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ca3:	83 ec 0c             	sub    $0xc,%esp
  801ca6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca9:	e8 fe f4 ff ff       	call   8011ac <fd2data>
	return _pipeisclosed(fd, p);
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb3:	e8 0c fd ff ff       	call   8019c4 <_pipeisclosed>
  801cb8:	83 c4 10             	add    $0x10,%esp
}
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    
  801cbd:	00 00                	add    %al,(%eax)
	...

00801cc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd0:	68 2e 29 80 00       	push   $0x80292e
  801cd5:	ff 75 0c             	pushl  0xc(%ebp)
  801cd8:	e8 e1 eb ff ff       	call   8008be <strcpy>
	return 0;
}
  801cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf4:	74 45                	je     801d3b <devcons_write+0x57>
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d00:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d09:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d0b:	83 fb 7f             	cmp    $0x7f,%ebx
  801d0e:	76 05                	jbe    801d15 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d10:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d15:	83 ec 04             	sub    $0x4,%esp
  801d18:	53                   	push   %ebx
  801d19:	03 45 0c             	add    0xc(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	57                   	push   %edi
  801d1e:	e8 5c ed ff ff       	call   800a7f <memmove>
		sys_cputs(buf, m);
  801d23:	83 c4 08             	add    $0x8,%esp
  801d26:	53                   	push   %ebx
  801d27:	57                   	push   %edi
  801d28:	e8 5c ef ff ff       	call   800c89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2d:	01 de                	add    %ebx,%esi
  801d2f:	89 f0                	mov    %esi,%eax
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d37:	72 cd                	jb     801d06 <devcons_write+0x22>
  801d39:	eb 05                	jmp    801d40 <devcons_write+0x5c>
  801d3b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d40:	89 f0                	mov    %esi,%eax
  801d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5f                   	pop    %edi
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d54:	75 07                	jne    801d5d <devcons_read+0x13>
  801d56:	eb 25                	jmp    801d7d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d58:	e8 bc ef ff ff       	call   800d19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d5d:	e8 4d ef ff ff       	call   800caf <sys_cgetc>
  801d62:	85 c0                	test   %eax,%eax
  801d64:	74 f2                	je     801d58 <devcons_read+0xe>
  801d66:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 1d                	js     801d89 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d6c:	83 f8 04             	cmp    $0x4,%eax
  801d6f:	74 13                	je     801d84 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d74:	88 10                	mov    %dl,(%eax)
	return 1;
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	eb 0c                	jmp    801d89 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d82:	eb 05                	jmp    801d89 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d84:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d91:	8b 45 08             	mov    0x8(%ebp),%eax
  801d94:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d97:	6a 01                	push   $0x1
  801d99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9c:	50                   	push   %eax
  801d9d:	e8 e7 ee ff ff       	call   800c89 <sys_cputs>
  801da2:	83 c4 10             	add    $0x10,%esp
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <getchar>:

int
getchar(void)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dad:	6a 01                	push   $0x1
  801daf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db2:	50                   	push   %eax
  801db3:	6a 00                	push   $0x0
  801db5:	e8 fe f6 ff ff       	call   8014b8 <read>
	if (r < 0)
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 0f                	js     801dd0 <getchar+0x29>
		return r;
	if (r < 1)
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	7e 06                	jle    801dcb <getchar+0x24>
		return -E_EOF;
	return c;
  801dc5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dc9:	eb 05                	jmp    801dd0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dcb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddb:	50                   	push   %eax
  801ddc:	ff 75 08             	pushl  0x8(%ebp)
  801ddf:	e8 53 f4 ff ff       	call   801237 <fd_lookup>
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 11                	js     801dfc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df4:	39 10                	cmp    %edx,(%eax)
  801df6:	0f 94 c0             	sete   %al
  801df9:	0f b6 c0             	movzbl %al,%eax
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <opencons>:

int
opencons(void)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	e8 b7 f3 ff ff       	call   8011c4 <fd_alloc>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 3a                	js     801e4e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	68 07 04 00 00       	push   $0x407
  801e1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 1a ef ff ff       	call   800d40 <sys_page_alloc>
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 21                	js     801e4e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e36:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	50                   	push   %eax
  801e46:	e8 51 f3 ff ff       	call   80119c <fd2num>
  801e4b:	83 c4 10             	add    $0x10,%esp
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e56:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e5d:	75 52                	jne    801eb1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	6a 07                	push   $0x7
  801e64:	68 00 f0 bf ee       	push   $0xeebff000
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 d0 ee ff ff       	call   800d40 <sys_page_alloc>
		if (r < 0) {
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	79 12                	jns    801e89 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801e77:	50                   	push   %eax
  801e78:	68 3a 29 80 00       	push   $0x80293a
  801e7d:	6a 24                	push   $0x24
  801e7f:	68 55 29 80 00       	push   $0x802955
  801e84:	e8 a7 e3 ff ff       	call   800230 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801e89:	83 ec 08             	sub    $0x8,%esp
  801e8c:	68 bc 1e 80 00       	push   $0x801ebc
  801e91:	6a 00                	push   $0x0
  801e93:	e8 5b ef ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	79 12                	jns    801eb1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801e9f:	50                   	push   %eax
  801ea0:	68 64 29 80 00       	push   $0x802964
  801ea5:	6a 2a                	push   $0x2a
  801ea7:	68 55 29 80 00       	push   $0x802955
  801eac:	e8 7f e3 ff ff       	call   800230 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    
	...

00801ebc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ebc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ebd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801ec7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801ecb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801ece:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801ed2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801ed6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801ed8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801edb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801edc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801edf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801ee0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ee1:	c3                   	ret    
	...

00801ee4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	8b 75 08             	mov    0x8(%ebp),%esi
  801eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	74 0e                	je     801f04 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ef6:	83 ec 0c             	sub    $0xc,%esp
  801ef9:	50                   	push   %eax
  801efa:	e8 3c ef ff ff       	call   800e3b <sys_ipc_recv>
  801eff:	83 c4 10             	add    $0x10,%esp
  801f02:	eb 10                	jmp    801f14 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	68 00 00 c0 ee       	push   $0xeec00000
  801f0c:	e8 2a ef ff ff       	call   800e3b <sys_ipc_recv>
  801f11:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f14:	85 c0                	test   %eax,%eax
  801f16:	75 26                	jne    801f3e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f18:	85 f6                	test   %esi,%esi
  801f1a:	74 0a                	je     801f26 <ipc_recv+0x42>
  801f1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f21:	8b 40 74             	mov    0x74(%eax),%eax
  801f24:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f26:	85 db                	test   %ebx,%ebx
  801f28:	74 0a                	je     801f34 <ipc_recv+0x50>
  801f2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f2f:	8b 40 78             	mov    0x78(%eax),%eax
  801f32:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f34:	a1 04 40 80 00       	mov    0x804004,%eax
  801f39:	8b 40 70             	mov    0x70(%eax),%eax
  801f3c:	eb 14                	jmp    801f52 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f3e:	85 f6                	test   %esi,%esi
  801f40:	74 06                	je     801f48 <ipc_recv+0x64>
  801f42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801f48:	85 db                	test   %ebx,%ebx
  801f4a:	74 06                	je     801f52 <ipc_recv+0x6e>
  801f4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	57                   	push   %edi
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f68:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801f6b:	85 db                	test   %ebx,%ebx
  801f6d:	75 25                	jne    801f94 <ipc_send+0x3b>
  801f6f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f74:	eb 1e                	jmp    801f94 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801f76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f79:	75 07                	jne    801f82 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801f7b:	e8 99 ed ff ff       	call   800d19 <sys_yield>
  801f80:	eb 12                	jmp    801f94 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801f82:	50                   	push   %eax
  801f83:	68 8c 29 80 00       	push   $0x80298c
  801f88:	6a 43                	push   $0x43
  801f8a:	68 9f 29 80 00       	push   $0x80299f
  801f8f:	e8 9c e2 ff ff       	call   800230 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801f94:	56                   	push   %esi
  801f95:	53                   	push   %ebx
  801f96:	57                   	push   %edi
  801f97:	ff 75 08             	pushl  0x8(%ebp)
  801f9a:	e8 77 ee ff ff       	call   800e16 <sys_ipc_try_send>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	75 d0                	jne    801f76 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5f                   	pop    %edi
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    

00801fae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	53                   	push   %ebx
  801fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fb5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801fbb:	74 22                	je     801fdf <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fbd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fc2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	c1 e2 07             	shl    $0x7,%edx
  801fce:	29 ca                	sub    %ecx,%edx
  801fd0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fd6:	8b 52 50             	mov    0x50(%edx),%edx
  801fd9:	39 da                	cmp    %ebx,%edx
  801fdb:	75 1d                	jne    801ffa <ipc_find_env+0x4c>
  801fdd:	eb 05                	jmp    801fe4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801fe4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801feb:	c1 e0 07             	shl    $0x7,%eax
  801fee:	29 d0                	sub    %edx,%eax
  801ff0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ff5:	8b 40 40             	mov    0x40(%eax),%eax
  801ff8:	eb 0c                	jmp    802006 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffa:	40                   	inc    %eax
  801ffb:	3d 00 04 00 00       	cmp    $0x400,%eax
  802000:	75 c0                	jne    801fc2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802002:	66 b8 00 00          	mov    $0x0,%ax
}
  802006:	5b                   	pop    %ebx
  802007:	c9                   	leave  
  802008:	c3                   	ret    
  802009:	00 00                	add    %al,(%eax)
	...

0080200c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802012:	89 c2                	mov    %eax,%edx
  802014:	c1 ea 16             	shr    $0x16,%edx
  802017:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80201e:	f6 c2 01             	test   $0x1,%dl
  802021:	74 1e                	je     802041 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802023:	c1 e8 0c             	shr    $0xc,%eax
  802026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80202d:	a8 01                	test   $0x1,%al
  80202f:	74 17                	je     802048 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802031:	c1 e8 0c             	shr    $0xc,%eax
  802034:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80203b:	ef 
  80203c:	0f b7 c0             	movzwl %ax,%eax
  80203f:	eb 0c                	jmp    80204d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
  802046:	eb 05                	jmp    80204d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    
	...

00802050 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	57                   	push   %edi
  802054:	56                   	push   %esi
  802055:	83 ec 10             	sub    $0x10,%esp
  802058:	8b 7d 08             	mov    0x8(%ebp),%edi
  80205b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80205e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802061:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802064:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802067:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 2e                	jne    80209c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80206e:	39 f1                	cmp    %esi,%ecx
  802070:	77 5a                	ja     8020cc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802072:	85 c9                	test   %ecx,%ecx
  802074:	75 0b                	jne    802081 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f1                	div    %ecx
  80207f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802089:	89 f8                	mov    %edi,%eax
  80208b:	f7 f1                	div    %ecx
  80208d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80208f:	89 f8                	mov    %edi,%eax
  802091:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	c9                   	leave  
  802099:	c3                   	ret    
  80209a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80209c:	39 f0                	cmp    %esi,%eax
  80209e:	77 1c                	ja     8020bc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020a0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020a3:	83 f7 1f             	xor    $0x1f,%edi
  8020a6:	75 3c                	jne    8020e4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020a8:	39 f0                	cmp    %esi,%eax
  8020aa:	0f 82 90 00 00 00    	jb     802140 <__udivdi3+0xf0>
  8020b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020b3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020b6:	0f 86 84 00 00 00    	jbe    802140 <__udivdi3+0xf0>
  8020bc:	31 f6                	xor    %esi,%esi
  8020be:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020c0:	89 f8                	mov    %edi,%eax
  8020c2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	5e                   	pop    %esi
  8020c8:	5f                   	pop    %edi
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    
  8020cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020cc:	89 f2                	mov    %esi,%edx
  8020ce:	89 f8                	mov    %edi,%eax
  8020d0:	f7 f1                	div    %ecx
  8020d2:	89 c7                	mov    %eax,%edi
  8020d4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020d6:	89 f8                	mov    %edi,%eax
  8020d8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	5e                   	pop    %esi
  8020de:	5f                   	pop    %edi
  8020df:	c9                   	leave  
  8020e0:	c3                   	ret    
  8020e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020e4:	89 f9                	mov    %edi,%ecx
  8020e6:	d3 e0                	shl    %cl,%eax
  8020e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020eb:	b8 20 00 00 00       	mov    $0x20,%eax
  8020f0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8020f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f5:	88 c1                	mov    %al,%cl
  8020f7:	d3 ea                	shr    %cl,%edx
  8020f9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8020fc:	09 ca                	or     %ecx,%edx
  8020fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802101:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802104:	89 f9                	mov    %edi,%ecx
  802106:	d3 e2                	shl    %cl,%edx
  802108:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80210b:	89 f2                	mov    %esi,%edx
  80210d:	88 c1                	mov    %al,%cl
  80210f:	d3 ea                	shr    %cl,%edx
  802111:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802114:	89 f2                	mov    %esi,%edx
  802116:	89 f9                	mov    %edi,%ecx
  802118:	d3 e2                	shl    %cl,%edx
  80211a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80211d:	88 c1                	mov    %al,%cl
  80211f:	d3 ee                	shr    %cl,%esi
  802121:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802123:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802126:	89 f0                	mov    %esi,%eax
  802128:	89 ca                	mov    %ecx,%edx
  80212a:	f7 75 ec             	divl   -0x14(%ebp)
  80212d:	89 d1                	mov    %edx,%ecx
  80212f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802131:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802134:	39 d1                	cmp    %edx,%ecx
  802136:	72 28                	jb     802160 <__udivdi3+0x110>
  802138:	74 1a                	je     802154 <__udivdi3+0x104>
  80213a:	89 f7                	mov    %esi,%edi
  80213c:	31 f6                	xor    %esi,%esi
  80213e:	eb 80                	jmp    8020c0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802140:	31 f6                	xor    %esi,%esi
  802142:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802147:	89 f8                	mov    %edi,%eax
  802149:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	c9                   	leave  
  802151:	c3                   	ret    
  802152:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802154:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802157:	89 f9                	mov    %edi,%ecx
  802159:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80215b:	39 c2                	cmp    %eax,%edx
  80215d:	73 db                	jae    80213a <__udivdi3+0xea>
  80215f:	90                   	nop
		{
		  q0--;
  802160:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802163:	31 f6                	xor    %esi,%esi
  802165:	e9 56 ff ff ff       	jmp    8020c0 <__udivdi3+0x70>
	...

0080216c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	83 ec 20             	sub    $0x20,%esp
  802174:	8b 45 08             	mov    0x8(%ebp),%eax
  802177:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80217a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80217d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802180:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802183:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802186:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802189:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80218b:	85 ff                	test   %edi,%edi
  80218d:	75 15                	jne    8021a4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80218f:	39 f1                	cmp    %esi,%ecx
  802191:	0f 86 99 00 00 00    	jbe    802230 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802197:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802199:	89 d0                	mov    %edx,%eax
  80219b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80219d:	83 c4 20             	add    $0x20,%esp
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	c9                   	leave  
  8021a3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021a4:	39 f7                	cmp    %esi,%edi
  8021a6:	0f 87 a4 00 00 00    	ja     802250 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021ac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021af:	83 f0 1f             	xor    $0x1f,%eax
  8021b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021b5:	0f 84 a1 00 00 00    	je     80225c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021bb:	89 f8                	mov    %edi,%eax
  8021bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021c0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8021ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021cd:	89 f9                	mov    %edi,%ecx
  8021cf:	d3 ea                	shr    %cl,%edx
  8021d1:	09 c2                	or     %eax,%edx
  8021d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8021d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8021e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021e8:	d3 e0                	shl    %cl,%eax
  8021ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021f0:	89 f9                	mov    %edi,%ecx
  8021f2:	d3 e8                	shr    %cl,%eax
  8021f4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8021f6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	f7 75 f0             	divl   -0x10(%ebp)
  8021fd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021ff:	f7 65 f4             	mull   -0xc(%ebp)
  802202:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802205:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802207:	39 d6                	cmp    %edx,%esi
  802209:	72 71                	jb     80227c <__umoddi3+0x110>
  80220b:	74 7f                	je     80228c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80220d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802210:	29 c8                	sub    %ecx,%eax
  802212:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802214:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 f2                	mov    %esi,%edx
  80221b:	89 f9                	mov    %edi,%ecx
  80221d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80221f:	09 d0                	or     %edx,%eax
  802221:	89 f2                	mov    %esi,%edx
  802223:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802226:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802228:	83 c4 20             	add    $0x20,%esp
  80222b:	5e                   	pop    %esi
  80222c:	5f                   	pop    %edi
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    
  80222f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802230:	85 c9                	test   %ecx,%ecx
  802232:	75 0b                	jne    80223f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802234:	b8 01 00 00 00       	mov    $0x1,%eax
  802239:	31 d2                	xor    %edx,%edx
  80223b:	f7 f1                	div    %ecx
  80223d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80223f:	89 f0                	mov    %esi,%eax
  802241:	31 d2                	xor    %edx,%edx
  802243:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802245:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802248:	f7 f1                	div    %ecx
  80224a:	e9 4a ff ff ff       	jmp    802199 <__umoddi3+0x2d>
  80224f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802250:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802252:	83 c4 20             	add    $0x20,%esp
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	c9                   	leave  
  802258:	c3                   	ret    
  802259:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80225c:	39 f7                	cmp    %esi,%edi
  80225e:	72 05                	jb     802265 <__umoddi3+0xf9>
  802260:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802263:	77 0c                	ja     802271 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802265:	89 f2                	mov    %esi,%edx
  802267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80226a:	29 c8                	sub    %ecx,%eax
  80226c:	19 fa                	sbb    %edi,%edx
  80226e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802271:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80227c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802284:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802287:	eb 84                	jmp    80220d <__umoddi3+0xa1>
  802289:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80228c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80228f:	72 eb                	jb     80227c <__umoddi3+0x110>
  802291:	89 f2                	mov    %esi,%edx
  802293:	e9 75 ff ff ff       	jmp    80220d <__umoddi3+0xa1>
