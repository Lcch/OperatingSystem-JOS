
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
  80003d:	68 c0 22 80 00       	push   $0x8022c0
  800042:	e8 c1 02 00 00       	call   800308 <cprintf>
	if ((r = pipe(p)) < 0)
  800047:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004a:	89 04 24             	mov    %eax,(%esp)
  80004d:	e8 10 1b 00 00       	call   801b62 <pipe>
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	85 c0                	test   %eax,%eax
  800057:	79 12                	jns    80006b <umain+0x37>
		panic("pipe: %e", r);
  800059:	50                   	push   %eax
  80005a:	68 0e 23 80 00       	push   $0x80230e
  80005f:	6a 0d                	push   $0xd
  800061:	68 17 23 80 00       	push   $0x802317
  800066:	e8 c5 01 00 00       	call   800230 <_panic>
	if ((r = fork()) < 0)
  80006b:	e8 0a 0f 00 00       	call   800f7a <fork>
  800070:	89 c7                	mov    %eax,%edi
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x54>
		panic("fork: %e", r);
  800076:	50                   	push   %eax
  800077:	68 2c 23 80 00       	push   $0x80232c
  80007c:	6a 0f                	push   $0xf
  80007e:	68 17 23 80 00       	push   $0x802317
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
  800092:	e8 0c 13 00 00       	call   8013a3 <close>
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
  8000b1:	68 35 23 80 00       	push   $0x802335
  8000b6:	e8 4d 02 00 00       	call   800308 <cprintf>
  8000bb:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	6a 0a                	push   $0xa
  8000c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c6:	e8 26 13 00 00       	call   8013f1 <dup>
			sys_yield();
  8000cb:	e8 49 0c 00 00       	call   800d19 <sys_yield>
			close(10);
  8000d0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000d7:	e8 c7 12 00 00       	call   8013a3 <close>
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
  800113:	e8 9a 1b 00 00       	call   801cb2 <pipeisclosed>
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	85 c0                	test   %eax,%eax
  80011d:	74 1d                	je     80013c <umain+0x108>
			cprintf("\nRACE: pipe appears closed\n");
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	68 39 23 80 00       	push   $0x802339
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
  800147:	68 55 23 80 00       	push   $0x802355
  80014c:	e8 b7 01 00 00       	call   800308 <cprintf>
	if (pipeisclosed(p[0]))
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 e0             	pushl  -0x20(%ebp)
  800157:	e8 56 1b 00 00       	call   801cb2 <pipeisclosed>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	85 c0                	test   %eax,%eax
  800161:	74 14                	je     800177 <umain+0x143>
		panic("somehow the other end of p[0] got closed!");
  800163:	83 ec 04             	sub    $0x4,%esp
  800166:	68 e4 22 80 00       	push   $0x8022e4
  80016b:	6a 40                	push   $0x40
  80016d:	68 17 23 80 00       	push   $0x802317
  800172:	e8 b9 00 00 00       	call   800230 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800177:	83 ec 08             	sub    $0x8,%esp
  80017a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017d:	50                   	push   %eax
  80017e:	ff 75 e0             	pushl  -0x20(%ebp)
  800181:	e8 d9 10 00 00       	call   80125f <fd_lookup>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	85 c0                	test   %eax,%eax
  80018b:	79 12                	jns    80019f <umain+0x16b>
		panic("cannot look up p[0]: %e", r);
  80018d:	50                   	push   %eax
  80018e:	68 6b 23 80 00       	push   $0x80236b
  800193:	6a 42                	push   $0x42
  800195:	68 17 23 80 00       	push   $0x802317
  80019a:	e8 91 00 00 00       	call   800230 <_panic>
	(void) fd2data(fd);
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a5:	e8 2a 10 00 00       	call   8011d4 <fd2data>
	cprintf("race didn't happen\n");
  8001aa:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
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
  80021a:	e8 af 11 00 00       	call   8013ce <close_all>
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
  80024e:	68 a4 23 80 00       	push   $0x8023a4
  800253:	e8 b0 00 00 00       	call   800308 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	56                   	push   %esi
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	e8 53 00 00 00       	call   8002b7 <vcprintf>
	cprintf("\n");
  800264:	c7 04 24 47 29 80 00 	movl   $0x802947,(%esp)
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
  800370:	e8 03 1d 00 00       	call   802078 <__udivdi3>
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
  8003ac:	e8 e3 1d 00 00       	call   802194 <__umoddi3>
  8003b1:	83 c4 14             	add    $0x14,%esp
  8003b4:	0f be 80 c7 23 80 00 	movsbl 0x8023c7(%eax),%eax
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
  8004f8:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
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
  8005a4:	8b 04 85 60 26 80 00 	mov    0x802660(,%eax,4),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 1a                	jne    8005c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005af:	52                   	push   %edx
  8005b0:	68 df 23 80 00       	push   $0x8023df
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
  8005ca:	68 15 29 80 00       	push   $0x802915
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
  800600:	c7 45 d0 d8 23 80 00 	movl   $0x8023d8,-0x30(%ebp)
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
  800c6e:	68 bf 26 80 00       	push   $0x8026bf
  800c73:	6a 42                	push   $0x42
  800c75:	68 dc 26 80 00       	push   $0x8026dc
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

00800e80 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e86:	6a 00                	push   $0x0
  800e88:	ff 75 14             	pushl  0x14(%ebp)
  800e8b:	ff 75 10             	pushl  0x10(%ebp)
  800e8e:	ff 75 0c             	pushl  0xc(%ebp)
  800e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e94:	ba 00 00 00 00       	mov    $0x0,%edx
  800e99:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e9e:	e8 99 fd ff ff       	call   800c3c <syscall>
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    
  800ea5:	00 00                	add    %al,(%eax)
	...

00800ea8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	53                   	push   %ebx
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800eb4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb8:	75 14                	jne    800ece <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	68 ec 26 80 00       	push   $0x8026ec
  800ec2:	6a 20                	push   $0x20
  800ec4:	68 30 28 80 00       	push   $0x802830
  800ec9:	e8 62 f3 ff ff       	call   800230 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ece:	89 d8                	mov    %ebx,%eax
  800ed0:	c1 e8 16             	shr    $0x16,%eax
  800ed3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eda:	a8 01                	test   $0x1,%al
  800edc:	74 11                	je     800eef <pgfault+0x47>
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	c1 e8 0c             	shr    $0xc,%eax
  800ee3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eea:	f6 c4 08             	test   $0x8,%ah
  800eed:	75 14                	jne    800f03 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	68 10 27 80 00       	push   $0x802710
  800ef7:	6a 24                	push   $0x24
  800ef9:	68 30 28 80 00       	push   $0x802830
  800efe:	e8 2d f3 ff ff       	call   800230 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	6a 07                	push   $0x7
  800f08:	68 00 f0 7f 00       	push   $0x7ff000
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 2c fe ff ff       	call   800d40 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	79 12                	jns    800f2d <pgfault+0x85>
  800f1b:	50                   	push   %eax
  800f1c:	68 34 27 80 00       	push   $0x802734
  800f21:	6a 32                	push   $0x32
  800f23:	68 30 28 80 00       	push   $0x802830
  800f28:	e8 03 f3 ff ff       	call   800230 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f2d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f33:	83 ec 04             	sub    $0x4,%esp
  800f36:	68 00 10 00 00       	push   $0x1000
  800f3b:	53                   	push   %ebx
  800f3c:	68 00 f0 7f 00       	push   $0x7ff000
  800f41:	e8 a3 fb ff ff       	call   800ae9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f46:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4d:	53                   	push   %ebx
  800f4e:	6a 00                	push   $0x0
  800f50:	68 00 f0 7f 00       	push   $0x7ff000
  800f55:	6a 00                	push   $0x0
  800f57:	e8 08 fe ff ff       	call   800d64 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <pgfault+0xcd>
  800f63:	50                   	push   %eax
  800f64:	68 58 27 80 00       	push   $0x802758
  800f69:	6a 3a                	push   $0x3a
  800f6b:	68 30 28 80 00       	push   $0x802830
  800f70:	e8 bb f2 ff ff       	call   800230 <_panic>

	return;
}
  800f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f83:	68 a8 0e 80 00       	push   $0x800ea8
  800f88:	e8 eb 0e 00 00       	call   801e78 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f8d:	ba 07 00 00 00       	mov    $0x7,%edx
  800f92:	89 d0                	mov    %edx,%eax
  800f94:	cd 30                	int    $0x30
  800f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f99:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 12                	jns    800fb4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800fa2:	50                   	push   %eax
  800fa3:	68 3b 28 80 00       	push   $0x80283b
  800fa8:	6a 7f                	push   $0x7f
  800faa:	68 30 28 80 00       	push   $0x802830
  800faf:	e8 7c f2 ff ff       	call   800230 <_panic>
	}
	int r;

	if (childpid == 0) {
  800fb4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb8:	75 25                	jne    800fdf <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800fba:	e8 36 fd ff ff       	call   800cf5 <sys_getenvid>
  800fbf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fcb:	c1 e0 07             	shl    $0x7,%eax
  800fce:	29 d0                	sub    %edx,%eax
  800fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd5:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800fda:	e9 be 01 00 00       	jmp    80119d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 16             	shr    $0x16,%eax
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	0f 84 10 01 00 00    	je     801108 <fork+0x18e>
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801004:	f6 c2 01             	test   $0x1,%dl
  801007:	0f 84 fb 00 00 00    	je     801108 <fork+0x18e>
  80100d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801014:	f6 c2 04             	test   $0x4,%dl
  801017:	0f 84 eb 00 00 00    	je     801108 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80101d:	89 c6                	mov    %eax,%esi
  80101f:	c1 e6 0c             	shl    $0xc,%esi
  801022:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801028:	0f 84 da 00 00 00    	je     801108 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  80102e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801035:	f6 c6 04             	test   $0x4,%dh
  801038:	74 37                	je     801071 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80103a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	25 07 0e 00 00       	and    $0xe07,%eax
  801049:	50                   	push   %eax
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 10 fd ff ff       	call   800d64 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	0f 89 a9 00 00 00    	jns    801108 <fork+0x18e>
  80105f:	50                   	push   %eax
  801060:	68 7c 27 80 00       	push   $0x80277c
  801065:	6a 54                	push   $0x54
  801067:	68 30 28 80 00       	push   $0x802830
  80106c:	e8 bf f1 ff ff       	call   800230 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801071:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801078:	f6 c2 02             	test   $0x2,%dl
  80107b:	75 0c                	jne    801089 <fork+0x10f>
  80107d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801084:	f6 c4 08             	test   $0x8,%ah
  801087:	74 57                	je     8010e0 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	68 05 08 00 00       	push   $0x805
  801091:	56                   	push   %esi
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	6a 00                	push   $0x0
  801096:	e8 c9 fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80109b:	83 c4 20             	add    $0x20,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 12                	jns    8010b4 <fork+0x13a>
  8010a2:	50                   	push   %eax
  8010a3:	68 7c 27 80 00       	push   $0x80277c
  8010a8:	6a 59                	push   $0x59
  8010aa:	68 30 28 80 00       	push   $0x802830
  8010af:	e8 7c f1 ff ff       	call   800230 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	68 05 08 00 00       	push   $0x805
  8010bc:	56                   	push   %esi
  8010bd:	6a 00                	push   $0x0
  8010bf:	56                   	push   %esi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 9d fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010c7:	83 c4 20             	add    $0x20,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 3a                	jns    801108 <fork+0x18e>
  8010ce:	50                   	push   %eax
  8010cf:	68 7c 27 80 00       	push   $0x80277c
  8010d4:	6a 5c                	push   $0x5c
  8010d6:	68 30 28 80 00       	push   $0x802830
  8010db:	e8 50 f1 ff ff       	call   800230 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	6a 05                	push   $0x5
  8010e5:	56                   	push   %esi
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 75 fc ff ff       	call   800d64 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 12                	jns    801108 <fork+0x18e>
  8010f6:	50                   	push   %eax
  8010f7:	68 7c 27 80 00       	push   $0x80277c
  8010fc:	6a 60                	push   $0x60
  8010fe:	68 30 28 80 00       	push   $0x802830
  801103:	e8 28 f1 ff ff       	call   800230 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801108:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80110e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801114:	0f 85 ca fe ff ff    	jne    800fe4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	6a 07                	push   $0x7
  80111f:	68 00 f0 bf ee       	push   $0xeebff000
  801124:	ff 75 e4             	pushl  -0x1c(%ebp)
  801127:	e8 14 fc ff ff       	call   800d40 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	79 15                	jns    801148 <fork+0x1ce>
  801133:	50                   	push   %eax
  801134:	68 a0 27 80 00       	push   $0x8027a0
  801139:	68 94 00 00 00       	push   $0x94
  80113e:	68 30 28 80 00       	push   $0x802830
  801143:	e8 e8 f0 ff ff       	call   800230 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801148:	83 ec 08             	sub    $0x8,%esp
  80114b:	68 e4 1e 80 00       	push   $0x801ee4
  801150:	ff 75 e4             	pushl  -0x1c(%ebp)
  801153:	e8 9b fc ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	79 15                	jns    801174 <fork+0x1fa>
  80115f:	50                   	push   %eax
  801160:	68 d8 27 80 00       	push   $0x8027d8
  801165:	68 99 00 00 00       	push   $0x99
  80116a:	68 30 28 80 00       	push   $0x802830
  80116f:	e8 bc f0 ff ff       	call   800230 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801174:	83 ec 08             	sub    $0x8,%esp
  801177:	6a 02                	push   $0x2
  801179:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117c:	e8 2c fc ff ff       	call   800dad <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	79 15                	jns    80119d <fork+0x223>
  801188:	50                   	push   %eax
  801189:	68 fc 27 80 00       	push   $0x8027fc
  80118e:	68 a4 00 00 00       	push   $0xa4
  801193:	68 30 28 80 00       	push   $0x802830
  801198:	e8 93 f0 ff ff       	call   800230 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80119d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ae:	68 58 28 80 00       	push   $0x802858
  8011b3:	68 b1 00 00 00       	push   $0xb1
  8011b8:	68 30 28 80 00       	push   $0x802830
  8011bd:	e8 6e f0 ff ff       	call   800230 <_panic>
	...

008011c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d7:	ff 75 08             	pushl  0x8(%ebp)
  8011da:	e8 e5 ff ff ff       	call   8011c4 <fd2num>
  8011df:	83 c4 04             	add    $0x4,%esp
  8011e2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011e7:	c1 e0 0c             	shl    $0xc,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011f8:	a8 01                	test   $0x1,%al
  8011fa:	74 34                	je     801230 <fd_alloc+0x44>
  8011fc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801201:	a8 01                	test   $0x1,%al
  801203:	74 32                	je     801237 <fd_alloc+0x4b>
  801205:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80120a:	89 c1                	mov    %eax,%ecx
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 16             	shr    $0x16,%edx
  801211:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 1f                	je     80123c <fd_alloc+0x50>
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 0c             	shr    $0xc,%edx
  801222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	75 17                	jne    801245 <fd_alloc+0x59>
  80122e:	eb 0c                	jmp    80123c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801230:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801235:	eb 05                	jmp    80123c <fd_alloc+0x50>
  801237:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80123c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80123e:	b8 00 00 00 00       	mov    $0x0,%eax
  801243:	eb 17                	jmp    80125c <fd_alloc+0x70>
  801245:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80124a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124f:	75 b9                	jne    80120a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801251:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801257:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125c:	5b                   	pop    %ebx
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801265:	83 f8 1f             	cmp    $0x1f,%eax
  801268:	77 36                	ja     8012a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80126f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 24                	je     8012a7 <fd_lookup+0x48>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 1a                	je     8012ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801294:	8b 55 0c             	mov    0xc(%ebp),%edx
  801297:	89 02                	mov    %eax,(%edx)
	return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	eb 13                	jmp    8012b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a5:	eb 0c                	jmp    8012b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 05                	jmp    8012b3 <fd_lookup+0x54>
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012c2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012c8:	74 0d                	je     8012d7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cf:	eb 14                	jmp    8012e5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012d1:	39 0a                	cmp    %ecx,(%edx)
  8012d3:	75 10                	jne    8012e5 <dev_lookup+0x30>
  8012d5:	eb 05                	jmp    8012dc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012dc:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	eb 31                	jmp    801316 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e5:	40                   	inc    %eax
  8012e6:	8b 14 85 ec 28 80 00 	mov    0x8028ec(,%eax,4),%edx
  8012ed:	85 d2                	test   %edx,%edx
  8012ef:	75 e0                	jne    8012d1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f6:	8b 40 48             	mov    0x48(%eax),%eax
  8012f9:	83 ec 04             	sub    $0x4,%esp
  8012fc:	51                   	push   %ecx
  8012fd:	50                   	push   %eax
  8012fe:	68 70 28 80 00       	push   $0x802870
  801303:	e8 00 f0 ff ff       	call   800308 <cprintf>
	*dev = 0;
  801308:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	56                   	push   %esi
  80131f:	53                   	push   %ebx
  801320:	83 ec 20             	sub    $0x20,%esp
  801323:	8b 75 08             	mov    0x8(%ebp),%esi
  801326:	8a 45 0c             	mov    0xc(%ebp),%al
  801329:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132c:	56                   	push   %esi
  80132d:	e8 92 fe ff ff       	call   8011c4 <fd2num>
  801332:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801335:	89 14 24             	mov    %edx,(%esp)
  801338:	50                   	push   %eax
  801339:	e8 21 ff ff ff       	call   80125f <fd_lookup>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 05                	js     80134c <fd_close+0x31>
	    || fd != fd2)
  801347:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80134a:	74 0d                	je     801359 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80134c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801350:	75 48                	jne    80139a <fd_close+0x7f>
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
  801357:	eb 41                	jmp    80139a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 36                	pushl  (%esi)
  801362:	e8 4e ff ff ff       	call   8012b5 <dev_lookup>
  801367:	89 c3                	mov    %eax,%ebx
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 1c                	js     80138c <fd_close+0x71>
		if (dev->dev_close)
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	8b 40 10             	mov    0x10(%eax),%eax
  801376:	85 c0                	test   %eax,%eax
  801378:	74 0d                	je     801387 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	56                   	push   %esi
  80137e:	ff d0                	call   *%eax
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	eb 05                	jmp    80138c <fd_close+0x71>
		else
			r = 0;
  801387:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	56                   	push   %esi
  801390:	6a 00                	push   $0x0
  801392:	e8 f3 f9 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  801397:	83 c4 10             	add    $0x10,%esp
}
  80139a:	89 d8                	mov    %ebx,%eax
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 aa fe ff ff       	call   80125f <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 10                	js     8013cc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	6a 01                	push   $0x1
  8013c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c4:	e8 52 ff ff ff       	call   80131b <fd_close>
  8013c9:	83 c4 10             	add    $0x10,%esp
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <close_all>:

void
close_all(void)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	53                   	push   %ebx
  8013de:	e8 c0 ff ff ff       	call   8013a3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e3:	43                   	inc    %ebx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	83 fb 20             	cmp    $0x20,%ebx
  8013ea:	75 ee                	jne    8013da <close_all+0xc>
		close(i);
}
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	57                   	push   %edi
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 2c             	sub    $0x2c,%esp
  8013fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	ff 75 08             	pushl  0x8(%ebp)
  801404:	e8 56 fe ff ff       	call   80125f <fd_lookup>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	0f 88 c0 00 00 00    	js     8014d6 <dup+0xe5>
		return r;
	close(newfdnum);
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	57                   	push   %edi
  80141a:	e8 84 ff ff ff       	call   8013a3 <close>

	newfd = INDEX2FD(newfdnum);
  80141f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801425:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801428:	83 c4 04             	add    $0x4,%esp
  80142b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142e:	e8 a1 fd ff ff       	call   8011d4 <fd2data>
  801433:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801435:	89 34 24             	mov    %esi,(%esp)
  801438:	e8 97 fd ff ff       	call   8011d4 <fd2data>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801443:	89 d8                	mov    %ebx,%eax
  801445:	c1 e8 16             	shr    $0x16,%eax
  801448:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144f:	a8 01                	test   $0x1,%al
  801451:	74 37                	je     80148a <dup+0x99>
  801453:	89 d8                	mov    %ebx,%eax
  801455:	c1 e8 0c             	shr    $0xc,%eax
  801458:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145f:	f6 c2 01             	test   $0x1,%dl
  801462:	74 26                	je     80148a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801464:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	25 07 0e 00 00       	and    $0xe07,%eax
  801473:	50                   	push   %eax
  801474:	ff 75 d4             	pushl  -0x2c(%ebp)
  801477:	6a 00                	push   $0x0
  801479:	53                   	push   %ebx
  80147a:	6a 00                	push   $0x0
  80147c:	e8 e3 f8 ff ff       	call   800d64 <sys_page_map>
  801481:	89 c3                	mov    %eax,%ebx
  801483:	83 c4 20             	add    $0x20,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 2d                	js     8014b7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	c1 ea 0c             	shr    $0xc,%edx
  801492:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014a2:	52                   	push   %edx
  8014a3:	56                   	push   %esi
  8014a4:	6a 00                	push   $0x0
  8014a6:	50                   	push   %eax
  8014a7:	6a 00                	push   $0x0
  8014a9:	e8 b6 f8 ff ff       	call   800d64 <sys_page_map>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	83 c4 20             	add    $0x20,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	79 1d                	jns    8014d4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	56                   	push   %esi
  8014bb:	6a 00                	push   $0x0
  8014bd:	e8 c8 f8 ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 bb f8 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 02                	jmp    8014d6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014d4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 14             	sub    $0x14,%esp
  8014e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	53                   	push   %ebx
  8014ef:	e8 6b fd ff ff       	call   80125f <fd_lookup>
  8014f4:	83 c4 08             	add    $0x8,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 67                	js     801562 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801505:	ff 30                	pushl  (%eax)
  801507:	e8 a9 fd ff ff       	call   8012b5 <dev_lookup>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 4f                	js     801562 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	8b 50 08             	mov    0x8(%eax),%edx
  801519:	83 e2 03             	and    $0x3,%edx
  80151c:	83 fa 01             	cmp    $0x1,%edx
  80151f:	75 21                	jne    801542 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801521:	a1 04 40 80 00       	mov    0x804004,%eax
  801526:	8b 40 48             	mov    0x48(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	53                   	push   %ebx
  80152d:	50                   	push   %eax
  80152e:	68 b1 28 80 00       	push   $0x8028b1
  801533:	e8 d0 ed ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801540:	eb 20                	jmp    801562 <read+0x82>
	}
	if (!dev->dev_read)
  801542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801545:	8b 52 08             	mov    0x8(%edx),%edx
  801548:	85 d2                	test   %edx,%edx
  80154a:	74 11                	je     80155d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	ff 75 10             	pushl  0x10(%ebp)
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	50                   	push   %eax
  801556:	ff d2                	call   *%edx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	eb 05                	jmp    801562 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	57                   	push   %edi
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	8b 7d 08             	mov    0x8(%ebp),%edi
  801573:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	85 f6                	test   %esi,%esi
  801578:	74 31                	je     8015ab <readn+0x44>
  80157a:	b8 00 00 00 00       	mov    $0x0,%eax
  80157f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	89 f2                	mov    %esi,%edx
  801589:	29 c2                	sub    %eax,%edx
  80158b:	52                   	push   %edx
  80158c:	03 45 0c             	add    0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	57                   	push   %edi
  801591:	e8 4a ff ff ff       	call   8014e0 <read>
		if (m < 0)
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 17                	js     8015b4 <readn+0x4d>
			return m;
		if (m == 0)
  80159d:	85 c0                	test   %eax,%eax
  80159f:	74 11                	je     8015b2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a1:	01 c3                	add    %eax,%ebx
  8015a3:	89 d8                	mov    %ebx,%eax
  8015a5:	39 f3                	cmp    %esi,%ebx
  8015a7:	72 db                	jb     801584 <readn+0x1d>
  8015a9:	eb 09                	jmp    8015b4 <readn+0x4d>
  8015ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b0:	eb 02                	jmp    8015b4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015b2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b7:	5b                   	pop    %ebx
  8015b8:	5e                   	pop    %esi
  8015b9:	5f                   	pop    %edi
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 14             	sub    $0x14,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 8f fc ff ff       	call   80125f <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 62                	js     801639 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 cd fc ff ff       	call   8012b5 <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 4a                	js     801639 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f6:	75 21                	jne    801619 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015fd:	8b 40 48             	mov    0x48(%eax),%eax
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	53                   	push   %ebx
  801604:	50                   	push   %eax
  801605:	68 cd 28 80 00       	push   $0x8028cd
  80160a:	e8 f9 ec ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801617:	eb 20                	jmp    801639 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	8b 52 0c             	mov    0xc(%edx),%edx
  80161f:	85 d2                	test   %edx,%edx
  801621:	74 11                	je     801634 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801623:	83 ec 04             	sub    $0x4,%esp
  801626:	ff 75 10             	pushl  0x10(%ebp)
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	50                   	push   %eax
  80162d:	ff d2                	call   *%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 05                	jmp    801639 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <seek>:

int
seek(int fdnum, off_t offset)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801644:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 0f fc ff ff       	call   80125f <fd_lookup>
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 0e                	js     801665 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801657:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801660:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801665:	c9                   	leave  
  801666:	c3                   	ret    

00801667 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	53                   	push   %ebx
  80166b:	83 ec 14             	sub    $0x14,%esp
  80166e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801671:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	53                   	push   %ebx
  801676:	e8 e4 fb ff ff       	call   80125f <fd_lookup>
  80167b:	83 c4 08             	add    $0x8,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 5f                	js     8016e1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	ff 30                	pushl  (%eax)
  80168e:	e8 22 fc ff ff       	call   8012b5 <dev_lookup>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 47                	js     8016e1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a1:	75 21                	jne    8016c4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a8:	8b 40 48             	mov    0x48(%eax),%eax
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	53                   	push   %ebx
  8016af:	50                   	push   %eax
  8016b0:	68 90 28 80 00       	push   $0x802890
  8016b5:	e8 4e ec ff ff       	call   800308 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c2:	eb 1d                	jmp    8016e1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	74 0e                	je     8016dc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	ff d2                	call   *%edx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb 05                	jmp    8016e1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 14             	sub    $0x14,%esp
  8016ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 63 fb ff ff       	call   80125f <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 52                	js     801755 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 a1 fb ff ff       	call   8012b5 <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 3a                	js     801755 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801722:	74 2c                	je     801750 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801724:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801727:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172e:	00 00 00 
	stat->st_isdir = 0;
  801731:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801738:	00 00 00 
	stat->st_dev = dev;
  80173b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	53                   	push   %ebx
  801745:	ff 75 f0             	pushl  -0x10(%ebp)
  801748:	ff 50 14             	call   *0x14(%eax)
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	eb 05                	jmp    801755 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801750:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	6a 00                	push   $0x0
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 78 01 00 00       	call   8018e4 <open>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 1b                	js     801790 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	ff 75 0c             	pushl  0xc(%ebp)
  80177b:	50                   	push   %eax
  80177c:	e8 65 ff ff ff       	call   8016e6 <fstat>
  801781:	89 c6                	mov    %eax,%esi
	close(fd);
  801783:	89 1c 24             	mov    %ebx,(%esp)
  801786:	e8 18 fc ff ff       	call   8013a3 <close>
	return r;
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	89 f3                	mov    %esi,%ebx
}
  801790:	89 d8                	mov    %ebx,%eax
  801792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	c9                   	leave  
  801798:	c3                   	ret    
  801799:	00 00                	add    %al,(%eax)
	...

0080179c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ac:	75 12                	jne    8017c0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	6a 01                	push   $0x1
  8017b3:	e8 1e 08 00 00       	call   801fd6 <ipc_find_env>
  8017b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c0:	6a 07                	push   $0x7
  8017c2:	68 00 50 80 00       	push   $0x805000
  8017c7:	53                   	push   %ebx
  8017c8:	ff 35 00 40 80 00    	pushl  0x804000
  8017ce:	e8 ae 07 00 00       	call   801f81 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017d3:	83 c4 0c             	add    $0xc,%esp
  8017d6:	6a 00                	push   $0x0
  8017d8:	56                   	push   %esi
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 2c 07 00 00       	call   801f0c <ipc_recv>
}
  8017e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5e                   	pop    %esi
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801801:	b8 05 00 00 00       	mov    $0x5,%eax
  801806:	e8 91 ff ff ff       	call   80179c <fsipc>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 2c                	js     80183b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	68 00 50 80 00       	push   $0x805000
  801817:	53                   	push   %ebx
  801818:	e8 a1 f0 ff ff       	call   8008be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80181d:	a1 80 50 80 00       	mov    0x805080,%eax
  801822:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801828:	a1 84 50 80 00       	mov    0x805084,%eax
  80182d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 06 00 00 00       	mov    $0x6,%eax
  80185b:	e8 3c ff ff ff       	call   80179c <fsipc>
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801875:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 03 00 00 00       	mov    $0x3,%eax
  801885:	e8 12 ff ff ff       	call   80179c <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 4b                	js     8018db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801890:	39 c6                	cmp    %eax,%esi
  801892:	73 16                	jae    8018aa <devfile_read+0x48>
  801894:	68 fc 28 80 00       	push   $0x8028fc
  801899:	68 03 29 80 00       	push   $0x802903
  80189e:	6a 7d                	push   $0x7d
  8018a0:	68 18 29 80 00       	push   $0x802918
  8018a5:	e8 86 e9 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  8018aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018af:	7e 16                	jle    8018c7 <devfile_read+0x65>
  8018b1:	68 23 29 80 00       	push   $0x802923
  8018b6:	68 03 29 80 00       	push   $0x802903
  8018bb:	6a 7e                	push   $0x7e
  8018bd:	68 18 29 80 00       	push   $0x802918
  8018c2:	e8 69 e9 ff ff       	call   800230 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	50                   	push   %eax
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	e8 a7 f1 ff ff       	call   800a7f <memmove>
	return r;
  8018d8:	83 c4 10             	add    $0x10,%esp
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 1c             	sub    $0x1c,%esp
  8018ec:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ef:	56                   	push   %esi
  8018f0:	e8 77 ef ff ff       	call   80086c <strlen>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fd:	7f 65                	jg     801964 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	e8 e1 f8 ff ff       	call   8011ec <fd_alloc>
  80190b:	89 c3                	mov    %eax,%ebx
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	78 55                	js     801969 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	56                   	push   %esi
  801918:	68 00 50 80 00       	push   $0x805000
  80191d:	e8 9c ef ff ff       	call   8008be <strcpy>
	fsipcbuf.open.req_omode = mode;
  801922:	8b 45 0c             	mov    0xc(%ebp),%eax
  801925:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192d:	b8 01 00 00 00       	mov    $0x1,%eax
  801932:	e8 65 fe ff ff       	call   80179c <fsipc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	79 12                	jns    801952 <open+0x6e>
		fd_close(fd, 0);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	6a 00                	push   $0x0
  801945:	ff 75 f4             	pushl  -0xc(%ebp)
  801948:	e8 ce f9 ff ff       	call   80131b <fd_close>
		return r;
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	eb 17                	jmp    801969 <open+0x85>
	}

	return fd2num(fd);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 67 f8 ff ff       	call   8011c4 <fd2num>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 05                	jmp    801969 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801964:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801969:	89 d8                	mov    %ebx,%eax
  80196b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	c9                   	leave  
  801971:	c3                   	ret    
	...

00801974 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff 75 08             	pushl  0x8(%ebp)
  801982:	e8 4d f8 ff ff       	call   8011d4 <fd2data>
  801987:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801989:	83 c4 08             	add    $0x8,%esp
  80198c:	68 2f 29 80 00       	push   $0x80292f
  801991:	56                   	push   %esi
  801992:	e8 27 ef ff ff       	call   8008be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801997:	8b 43 04             	mov    0x4(%ebx),%eax
  80199a:	2b 03                	sub    (%ebx),%eax
  80199c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019a2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019a9:	00 00 00 
	stat->st_dev = &devpipe;
  8019ac:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019b3:	30 80 00 
	return 0;
}
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019cc:	53                   	push   %ebx
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 b6 f3 ff ff       	call   800d8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d4:	89 1c 24             	mov    %ebx,(%esp)
  8019d7:	e8 f8 f7 ff ff       	call   8011d4 <fd2data>
  8019dc:	83 c4 08             	add    $0x8,%esp
  8019df:	50                   	push   %eax
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 a3 f3 ff ff       	call   800d8a <sys_page_unmap>
}
  8019e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	57                   	push   %edi
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 1c             	sub    $0x1c,%esp
  8019f5:	89 c7                	mov    %eax,%edi
  8019f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8019ff:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	57                   	push   %edi
  801a06:	e8 29 06 00 00       	call   802034 <pageref>
  801a0b:	89 c6                	mov    %eax,%esi
  801a0d:	83 c4 04             	add    $0x4,%esp
  801a10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a13:	e8 1c 06 00 00       	call   802034 <pageref>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	39 c6                	cmp    %eax,%esi
  801a1d:	0f 94 c0             	sete   %al
  801a20:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a23:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2c:	39 cb                	cmp    %ecx,%ebx
  801a2e:	75 08                	jne    801a38 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5f                   	pop    %edi
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a38:	83 f8 01             	cmp    $0x1,%eax
  801a3b:	75 bd                	jne    8019fa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3d:	8b 42 58             	mov    0x58(%edx),%eax
  801a40:	6a 01                	push   $0x1
  801a42:	50                   	push   %eax
  801a43:	53                   	push   %ebx
  801a44:	68 36 29 80 00       	push   $0x802936
  801a49:	e8 ba e8 ff ff       	call   800308 <cprintf>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	eb a7                	jmp    8019fa <_pipeisclosed+0xe>

00801a53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 28             	sub    $0x28,%esp
  801a5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5f:	56                   	push   %esi
  801a60:	e8 6f f7 ff ff       	call   8011d4 <fd2data>
  801a65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a6e:	75 4a                	jne    801aba <devpipe_write+0x67>
  801a70:	bf 00 00 00 00       	mov    $0x0,%edi
  801a75:	eb 56                	jmp    801acd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a77:	89 da                	mov    %ebx,%edx
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	e8 6c ff ff ff       	call   8019ec <_pipeisclosed>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	75 4d                	jne    801ad1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a84:	e8 90 f2 ff ff       	call   800d19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a89:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8c:	8b 13                	mov    (%ebx),%edx
  801a8e:	83 c2 20             	add    $0x20,%edx
  801a91:	39 d0                	cmp    %edx,%eax
  801a93:	73 e2                	jae    801a77 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a9d:	79 05                	jns    801aa4 <devpipe_write+0x51>
  801a9f:	4a                   	dec    %edx
  801aa0:	83 ca e0             	or     $0xffffffe0,%edx
  801aa3:	42                   	inc    %edx
  801aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801aaa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aae:	40                   	inc    %eax
  801aaf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab2:	47                   	inc    %edi
  801ab3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ab6:	77 07                	ja     801abf <devpipe_write+0x6c>
  801ab8:	eb 13                	jmp    801acd <devpipe_write+0x7a>
  801aba:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac2:	8b 13                	mov    (%ebx),%edx
  801ac4:	83 c2 20             	add    $0x20,%edx
  801ac7:	39 d0                	cmp    %edx,%eax
  801ac9:	73 ac                	jae    801a77 <devpipe_write+0x24>
  801acb:	eb c8                	jmp    801a95 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acd:	89 f8                	mov    %edi,%eax
  801acf:	eb 05                	jmp    801ad6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aea:	57                   	push   %edi
  801aeb:	e8 e4 f6 ff ff       	call   8011d4 <fd2data>
  801af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af9:	75 44                	jne    801b3f <devpipe_read+0x61>
  801afb:	be 00 00 00 00       	mov    $0x0,%esi
  801b00:	eb 4f                	jmp    801b51 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b02:	89 f0                	mov    %esi,%eax
  801b04:	eb 54                	jmp    801b5a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b06:	89 da                	mov    %ebx,%edx
  801b08:	89 f8                	mov    %edi,%eax
  801b0a:	e8 dd fe ff ff       	call   8019ec <_pipeisclosed>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	75 42                	jne    801b55 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b13:	e8 01 f2 ff ff       	call   800d19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b18:	8b 03                	mov    (%ebx),%eax
  801b1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b1d:	74 e7                	je     801b06 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b24:	79 05                	jns    801b2b <devpipe_read+0x4d>
  801b26:	48                   	dec    %eax
  801b27:	83 c8 e0             	or     $0xffffffe0,%eax
  801b2a:	40                   	inc    %eax
  801b2b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b32:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b35:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b37:	46                   	inc    %esi
  801b38:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b3b:	77 07                	ja     801b44 <devpipe_read+0x66>
  801b3d:	eb 12                	jmp    801b51 <devpipe_read+0x73>
  801b3f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b44:	8b 03                	mov    (%ebx),%eax
  801b46:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b49:	75 d4                	jne    801b1f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4b:	85 f6                	test   %esi,%esi
  801b4d:	75 b3                	jne    801b02 <devpipe_read+0x24>
  801b4f:	eb b5                	jmp    801b06 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b51:	89 f0                	mov    %esi,%eax
  801b53:	eb 05                	jmp    801b5a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 28             	sub    $0x28,%esp
  801b6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	e8 75 f6 ff ff       	call   8011ec <fd_alloc>
  801b77:	89 c3                	mov    %eax,%ebx
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	0f 88 24 01 00 00    	js     801ca8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 aa f1 ff ff       	call   800d40 <sys_page_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 05 01 00 00    	js     801ca8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	e8 3d f6 ff ff       	call   8011ec <fd_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 dc 00 00 00    	js     801c98 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	68 07 04 00 00       	push   $0x407
  801bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc7:	6a 00                	push   $0x0
  801bc9:	e8 72 f1 ff ff       	call   800d40 <sys_page_alloc>
  801bce:	89 c3                	mov    %eax,%ebx
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 bd 00 00 00    	js     801c98 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be1:	e8 ee f5 ff ff       	call   8011d4 <fd2data>
  801be6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 c4 0c             	add    $0xc,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	50                   	push   %eax
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 48 f1 ff ff       	call   800d40 <sys_page_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 83 00 00 00    	js     801c88 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0b:	e8 c4 f5 ff ff       	call   8011d4 <fd2data>
  801c10:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c17:	50                   	push   %eax
  801c18:	6a 00                	push   $0x0
  801c1a:	56                   	push   %esi
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 42 f1 ff ff       	call   800d64 <sys_page_map>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 4f                	js     801c7a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c34:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c49:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5b:	e8 64 f5 ff ff       	call   8011c4 <fd2num>
  801c60:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c62:	83 c4 04             	add    $0x4,%esp
  801c65:	ff 75 e0             	pushl  -0x20(%ebp)
  801c68:	e8 57 f5 ff ff       	call   8011c4 <fd2num>
  801c6d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c78:	eb 2e                	jmp    801ca8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	56                   	push   %esi
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 05 f1 ff ff       	call   800d8a <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 f5 f0 ff ff       	call   800d8a <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 e5 f0 ff ff       	call   800d8a <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	ff 75 08             	pushl  0x8(%ebp)
  801cbf:	e8 9b f5 ff ff       	call   80125f <fd_lookup>
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 18                	js     801ce3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 fe f4 ff ff       	call   8011d4 <fd2data>
	return _pipeisclosed(fd, p);
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	e8 0c fd ff ff       	call   8019ec <_pipeisclosed>
  801ce0:	83 c4 10             	add    $0x10,%esp
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    
  801ce5:	00 00                	add    %al,(%eax)
	...

00801ce8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf8:	68 4e 29 80 00       	push   $0x80294e
  801cfd:	ff 75 0c             	pushl  0xc(%ebp)
  801d00:	e8 b9 eb ff ff       	call   8008be <strcpy>
	return 0;
}
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d1c:	74 45                	je     801d63 <devcons_write+0x57>
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d31:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d33:	83 fb 7f             	cmp    $0x7f,%ebx
  801d36:	76 05                	jbe    801d3d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d38:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d3d:	83 ec 04             	sub    $0x4,%esp
  801d40:	53                   	push   %ebx
  801d41:	03 45 0c             	add    0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	57                   	push   %edi
  801d46:	e8 34 ed ff ff       	call   800a7f <memmove>
		sys_cputs(buf, m);
  801d4b:	83 c4 08             	add    $0x8,%esp
  801d4e:	53                   	push   %ebx
  801d4f:	57                   	push   %edi
  801d50:	e8 34 ef ff ff       	call   800c89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d55:	01 de                	add    %ebx,%esi
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5f:	72 cd                	jb     801d2e <devcons_write+0x22>
  801d61:	eb 05                	jmp    801d68 <devcons_write+0x5c>
  801d63:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	75 07                	jne    801d85 <devcons_read+0x13>
  801d7e:	eb 25                	jmp    801da5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d80:	e8 94 ef ff ff       	call   800d19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d85:	e8 25 ef ff ff       	call   800caf <sys_cgetc>
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	74 f2                	je     801d80 <devcons_read+0xe>
  801d8e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 1d                	js     801db1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d94:	83 f8 04             	cmp    $0x4,%eax
  801d97:	74 13                	je     801dac <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9c:	88 10                	mov    %dl,(%eax)
	return 1;
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	eb 0c                	jmp    801db1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
  801daa:	eb 05                	jmp    801db1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dbf:	6a 01                	push   $0x1
  801dc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc4:	50                   	push   %eax
  801dc5:	e8 bf ee ff ff       	call   800c89 <sys_cputs>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <getchar>:

int
getchar(void)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd5:	6a 01                	push   $0x1
  801dd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 fe f6 ff ff       	call   8014e0 <read>
	if (r < 0)
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 0f                	js     801df8 <getchar+0x29>
		return r;
	if (r < 1)
  801de9:	85 c0                	test   %eax,%eax
  801deb:	7e 06                	jle    801df3 <getchar+0x24>
		return -E_EOF;
	return c;
  801ded:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df1:	eb 05                	jmp    801df8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	ff 75 08             	pushl  0x8(%ebp)
  801e07:	e8 53 f4 ff ff       	call   80125f <fd_lookup>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 11                	js     801e24 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1c:	39 10                	cmp    %edx,(%eax)
  801e1e:	0f 94 c0             	sete   %al
  801e21:	0f b6 c0             	movzbl %al,%eax
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <opencons>:

int
opencons(void)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	e8 b7 f3 ff ff       	call   8011ec <fd_alloc>
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 3a                	js     801e76 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	68 07 04 00 00       	push   $0x407
  801e44:	ff 75 f4             	pushl  -0xc(%ebp)
  801e47:	6a 00                	push   $0x0
  801e49:	e8 f2 ee ff ff       	call   800d40 <sys_page_alloc>
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 21                	js     801e76 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e63:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	50                   	push   %eax
  801e6e:	e8 51 f3 ff ff       	call   8011c4 <fd2num>
  801e73:	83 c4 10             	add    $0x10,%esp
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e85:	75 52                	jne    801ed9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	6a 07                	push   $0x7
  801e8c:	68 00 f0 bf ee       	push   $0xeebff000
  801e91:	6a 00                	push   $0x0
  801e93:	e8 a8 ee ff ff       	call   800d40 <sys_page_alloc>
		if (r < 0) {
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	79 12                	jns    801eb1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801e9f:	50                   	push   %eax
  801ea0:	68 5a 29 80 00       	push   $0x80295a
  801ea5:	6a 24                	push   $0x24
  801ea7:	68 75 29 80 00       	push   $0x802975
  801eac:	e8 7f e3 ff ff       	call   800230 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801eb1:	83 ec 08             	sub    $0x8,%esp
  801eb4:	68 e4 1e 80 00       	push   $0x801ee4
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 33 ef ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	79 12                	jns    801ed9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801ec7:	50                   	push   %eax
  801ec8:	68 84 29 80 00       	push   $0x802984
  801ecd:	6a 2a                	push   $0x2a
  801ecf:	68 75 29 80 00       	push   $0x802975
  801ed4:	e8 57 e3 ff ff       	call   800230 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  801edc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    
	...

00801ee4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ee4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ee5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801eea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eec:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801eef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801ef3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801ef6:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801efa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801efe:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f00:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f03:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f04:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f07:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f08:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f09:	c3                   	ret    
	...

00801f0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	8b 75 08             	mov    0x8(%ebp),%esi
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	74 0e                	je     801f2c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	50                   	push   %eax
  801f22:	e8 14 ef ff ff       	call   800e3b <sys_ipc_recv>
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	eb 10                	jmp    801f3c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	68 00 00 c0 ee       	push   $0xeec00000
  801f34:	e8 02 ef ff ff       	call   800e3b <sys_ipc_recv>
  801f39:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	75 26                	jne    801f66 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f40:	85 f6                	test   %esi,%esi
  801f42:	74 0a                	je     801f4e <ipc_recv+0x42>
  801f44:	a1 04 40 80 00       	mov    0x804004,%eax
  801f49:	8b 40 74             	mov    0x74(%eax),%eax
  801f4c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f4e:	85 db                	test   %ebx,%ebx
  801f50:	74 0a                	je     801f5c <ipc_recv+0x50>
  801f52:	a1 04 40 80 00       	mov    0x804004,%eax
  801f57:	8b 40 78             	mov    0x78(%eax),%eax
  801f5a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f61:	8b 40 70             	mov    0x70(%eax),%eax
  801f64:	eb 14                	jmp    801f7a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801f66:	85 f6                	test   %esi,%esi
  801f68:	74 06                	je     801f70 <ipc_recv+0x64>
  801f6a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801f70:	85 db                	test   %ebx,%ebx
  801f72:	74 06                	je     801f7a <ipc_recv+0x6e>
  801f74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f90:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801f93:	85 db                	test   %ebx,%ebx
  801f95:	75 25                	jne    801fbc <ipc_send+0x3b>
  801f97:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f9c:	eb 1e                	jmp    801fbc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801f9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa1:	75 07                	jne    801faa <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801fa3:	e8 71 ed ff ff       	call   800d19 <sys_yield>
  801fa8:	eb 12                	jmp    801fbc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801faa:	50                   	push   %eax
  801fab:	68 ac 29 80 00       	push   $0x8029ac
  801fb0:	6a 43                	push   $0x43
  801fb2:	68 bf 29 80 00       	push   $0x8029bf
  801fb7:	e8 74 e2 ff ff       	call   800230 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	57                   	push   %edi
  801fbf:	ff 75 08             	pushl  0x8(%ebp)
  801fc2:	e8 4f ee ff ff       	call   800e16 <sys_ipc_try_send>
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	75 d0                	jne    801f9e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	53                   	push   %ebx
  801fda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fdd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801fe3:	74 22                	je     802007 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fea:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ff1:	89 c2                	mov    %eax,%edx
  801ff3:	c1 e2 07             	shl    $0x7,%edx
  801ff6:	29 ca                	sub    %ecx,%edx
  801ff8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ffe:	8b 52 50             	mov    0x50(%edx),%edx
  802001:	39 da                	cmp    %ebx,%edx
  802003:	75 1d                	jne    802022 <ipc_find_env+0x4c>
  802005:	eb 05                	jmp    80200c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80200c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802013:	c1 e0 07             	shl    $0x7,%eax
  802016:	29 d0                	sub    %edx,%eax
  802018:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80201d:	8b 40 40             	mov    0x40(%eax),%eax
  802020:	eb 0c                	jmp    80202e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802022:	40                   	inc    %eax
  802023:	3d 00 04 00 00       	cmp    $0x400,%eax
  802028:	75 c0                	jne    801fea <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202a:	66 b8 00 00          	mov    $0x0,%ax
}
  80202e:	5b                   	pop    %ebx
  80202f:	c9                   	leave  
  802030:	c3                   	ret    
  802031:	00 00                	add    %al,(%eax)
	...

00802034 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203a:	89 c2                	mov    %eax,%edx
  80203c:	c1 ea 16             	shr    $0x16,%edx
  80203f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802046:	f6 c2 01             	test   $0x1,%dl
  802049:	74 1e                	je     802069 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204b:	c1 e8 0c             	shr    $0xc,%eax
  80204e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802055:	a8 01                	test   $0x1,%al
  802057:	74 17                	je     802070 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802059:	c1 e8 0c             	shr    $0xc,%eax
  80205c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802063:	ef 
  802064:	0f b7 c0             	movzwl %ax,%eax
  802067:	eb 0c                	jmp    802075 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	eb 05                	jmp    802075 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802070:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    
	...

00802078 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	57                   	push   %edi
  80207c:	56                   	push   %esi
  80207d:	83 ec 10             	sub    $0x10,%esp
  802080:	8b 7d 08             	mov    0x8(%ebp),%edi
  802083:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802086:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802089:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80208c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80208f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802092:	85 c0                	test   %eax,%eax
  802094:	75 2e                	jne    8020c4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802096:	39 f1                	cmp    %esi,%ecx
  802098:	77 5a                	ja     8020f4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80209a:	85 c9                	test   %ecx,%ecx
  80209c:	75 0b                	jne    8020a9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80209e:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f1                	div    %ecx
  8020a7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020a9:	31 d2                	xor    %edx,%edx
  8020ab:	89 f0                	mov    %esi,%eax
  8020ad:	f7 f1                	div    %ecx
  8020af:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020b1:	89 f8                	mov    %edi,%eax
  8020b3:	f7 f1                	div    %ecx
  8020b5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020b7:	89 f8                	mov    %edi,%eax
  8020b9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    
  8020c2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c4:	39 f0                	cmp    %esi,%eax
  8020c6:	77 1c                	ja     8020e4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020c8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020cb:	83 f7 1f             	xor    $0x1f,%edi
  8020ce:	75 3c                	jne    80210c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020d0:	39 f0                	cmp    %esi,%eax
  8020d2:	0f 82 90 00 00 00    	jb     802168 <__udivdi3+0xf0>
  8020d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020db:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020de:	0f 86 84 00 00 00    	jbe    802168 <__udivdi3+0xf0>
  8020e4:	31 f6                	xor    %esi,%esi
  8020e6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020e8:	89 f8                	mov    %edi,%eax
  8020ea:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    
  8020f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f4:	89 f2                	mov    %esi,%edx
  8020f6:	89 f8                	mov    %edi,%eax
  8020f8:	f7 f1                	div    %ecx
  8020fa:	89 c7                	mov    %eax,%edi
  8020fc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020fe:	89 f8                	mov    %edi,%eax
  802100:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	c9                   	leave  
  802108:	c3                   	ret    
  802109:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80210c:	89 f9                	mov    %edi,%ecx
  80210e:	d3 e0                	shl    %cl,%eax
  802110:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802113:	b8 20 00 00 00       	mov    $0x20,%eax
  802118:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80211a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80211d:	88 c1                	mov    %al,%cl
  80211f:	d3 ea                	shr    %cl,%edx
  802121:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802124:	09 ca                	or     %ecx,%edx
  802126:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802129:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80212c:	89 f9                	mov    %edi,%ecx
  80212e:	d3 e2                	shl    %cl,%edx
  802130:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802133:	89 f2                	mov    %esi,%edx
  802135:	88 c1                	mov    %al,%cl
  802137:	d3 ea                	shr    %cl,%edx
  802139:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	89 f9                	mov    %edi,%ecx
  802140:	d3 e2                	shl    %cl,%edx
  802142:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802145:	88 c1                	mov    %al,%cl
  802147:	d3 ee                	shr    %cl,%esi
  802149:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80214b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80214e:	89 f0                	mov    %esi,%eax
  802150:	89 ca                	mov    %ecx,%edx
  802152:	f7 75 ec             	divl   -0x14(%ebp)
  802155:	89 d1                	mov    %edx,%ecx
  802157:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802159:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80215c:	39 d1                	cmp    %edx,%ecx
  80215e:	72 28                	jb     802188 <__udivdi3+0x110>
  802160:	74 1a                	je     80217c <__udivdi3+0x104>
  802162:	89 f7                	mov    %esi,%edi
  802164:	31 f6                	xor    %esi,%esi
  802166:	eb 80                	jmp    8020e8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802168:	31 f6                	xor    %esi,%esi
  80216a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80216f:	89 f8                	mov    %edi,%eax
  802171:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	5e                   	pop    %esi
  802177:	5f                   	pop    %edi
  802178:	c9                   	leave  
  802179:	c3                   	ret    
  80217a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80217c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802183:	39 c2                	cmp    %eax,%edx
  802185:	73 db                	jae    802162 <__udivdi3+0xea>
  802187:	90                   	nop
		{
		  q0--;
  802188:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80218b:	31 f6                	xor    %esi,%esi
  80218d:	e9 56 ff ff ff       	jmp    8020e8 <__udivdi3+0x70>
	...

00802194 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	57                   	push   %edi
  802198:	56                   	push   %esi
  802199:	83 ec 20             	sub    $0x20,%esp
  80219c:	8b 45 08             	mov    0x8(%ebp),%eax
  80219f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021ab:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021b1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021b3:	85 ff                	test   %edi,%edi
  8021b5:	75 15                	jne    8021cc <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021b7:	39 f1                	cmp    %esi,%ecx
  8021b9:	0f 86 99 00 00 00    	jbe    802258 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021bf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021c1:	89 d0                	mov    %edx,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c5:	83 c4 20             	add    $0x20,%esp
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	0f 87 a4 00 00 00    	ja     802278 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021d4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021d7:	83 f0 1f             	xor    $0x1f,%eax
  8021da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021dd:	0f 84 a1 00 00 00    	je     802284 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021e8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021ea:	bf 20 00 00 00       	mov    $0x20,%edi
  8021ef:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8021f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 ea                	shr    %cl,%edx
  8021f9:	09 c2                	or     %eax,%edx
  8021fb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802204:	d3 e0                	shl    %cl,%eax
  802206:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802209:	89 f2                	mov    %esi,%edx
  80220b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80220d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802210:	d3 e0                	shl    %cl,%eax
  802212:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802215:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802218:	89 f9                	mov    %edi,%ecx
  80221a:	d3 e8                	shr    %cl,%eax
  80221c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80221e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802220:	89 f2                	mov    %esi,%edx
  802222:	f7 75 f0             	divl   -0x10(%ebp)
  802225:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802227:	f7 65 f4             	mull   -0xc(%ebp)
  80222a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80222d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80222f:	39 d6                	cmp    %edx,%esi
  802231:	72 71                	jb     8022a4 <__umoddi3+0x110>
  802233:	74 7f                	je     8022b4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802238:	29 c8                	sub    %ecx,%eax
  80223a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80223c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80223f:	d3 e8                	shr    %cl,%eax
  802241:	89 f2                	mov    %esi,%edx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802247:	09 d0                	or     %edx,%eax
  802249:	89 f2                	mov    %esi,%edx
  80224b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80224e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802250:	83 c4 20             	add    $0x20,%esp
  802253:	5e                   	pop    %esi
  802254:	5f                   	pop    %edi
  802255:	c9                   	leave  
  802256:	c3                   	ret    
  802257:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802258:	85 c9                	test   %ecx,%ecx
  80225a:	75 0b                	jne    802267 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80225c:	b8 01 00 00 00       	mov    $0x1,%eax
  802261:	31 d2                	xor    %edx,%edx
  802263:	f7 f1                	div    %ecx
  802265:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802267:	89 f0                	mov    %esi,%eax
  802269:	31 d2                	xor    %edx,%edx
  80226b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80226d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802270:	f7 f1                	div    %ecx
  802272:	e9 4a ff ff ff       	jmp    8021c1 <__umoddi3+0x2d>
  802277:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802278:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80227a:	83 c4 20             	add    $0x20,%esp
  80227d:	5e                   	pop    %esi
  80227e:	5f                   	pop    %edi
  80227f:	c9                   	leave  
  802280:	c3                   	ret    
  802281:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802284:	39 f7                	cmp    %esi,%edi
  802286:	72 05                	jb     80228d <__umoddi3+0xf9>
  802288:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80228b:	77 0c                	ja     802299 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802292:	29 c8                	sub    %ecx,%eax
  802294:	19 fa                	sbb    %edi,%edx
  802296:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80229c:	83 c4 20             	add    $0x20,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022a7:	89 c1                	mov    %eax,%ecx
  8022a9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022ac:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022af:	eb 84                	jmp    802235 <__umoddi3+0xa1>
  8022b1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022b4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022b7:	72 eb                	jb     8022a4 <__umoddi3+0x110>
  8022b9:	89 f2                	mov    %esi,%edx
  8022bb:	e9 75 ff ff ff       	jmp    802235 <__umoddi3+0xa1>
