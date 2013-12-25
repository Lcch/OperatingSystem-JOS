
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
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
  800039:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 20 	movl   $0x802720,0x803000
  800046:	27 80 00 

	cprintf("icode startup\n");
  800049:	68 26 27 80 00       	push   $0x802726
  80004e:	e8 25 02 00 00       	call   800278 <cprintf>

	cprintf("icode: open /motd\n");
  800053:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80005a:	e8 19 02 00 00       	call   800278 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005f:	83 c4 08             	add    $0x8,%esp
  800062:	6a 00                	push   $0x0
  800064:	68 48 27 80 00       	push   $0x802748
  800069:	e8 0e 15 00 00       	call   80157c <open>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	79 12                	jns    800089 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800077:	50                   	push   %eax
  800078:	68 4e 27 80 00       	push   $0x80274e
  80007d:	6a 0f                	push   $0xf
  80007f:	68 64 27 80 00       	push   $0x802764
  800084:	e8 17 01 00 00       	call   8001a0 <_panic>

	cprintf("icode: read /motd\n");
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	68 71 27 80 00       	push   $0x802771
  800091:	e8 e2 01 00 00       	call   800278 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009f:	eb 0d                	jmp    8000ae <umain+0x7a>
		sys_cputs(buf, n);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	50                   	push   %eax
  8000a5:	53                   	push   %ebx
  8000a6:	e8 4e 0b 00 00       	call   800bf9 <sys_cputs>
  8000ab:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	68 00 02 00 00       	push   $0x200
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 bb 10 00 00       	call   801178 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	7f dd                	jg     8000a1 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	68 84 27 80 00       	push   $0x802784
  8000cc:	e8 a7 01 00 00       	call   800278 <cprintf>
	close(fd);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 62 0f 00 00       	call   80103b <close>

	cprintf("icode: spawn /init\n");
  8000d9:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  8000e0:	e8 93 01 00 00       	call   800278 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	68 ac 27 80 00       	push   $0x8027ac
  8000f1:	68 b5 27 80 00       	push   $0x8027b5
  8000f6:	68 bf 27 80 00       	push   $0x8027bf
  8000fb:	68 be 27 80 00       	push   $0x8027be
  800100:	e8 dd 1c 00 00       	call   801de2 <spawnl>
  800105:	83 c4 20             	add    $0x20,%esp
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 12                	jns    80011e <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010c:	50                   	push   %eax
  80010d:	68 c4 27 80 00       	push   $0x8027c4
  800112:	6a 1a                	push   $0x1a
  800114:	68 64 27 80 00       	push   $0x802764
  800119:	e8 82 00 00 00       	call   8001a0 <_panic>

	cprintf("icode: exiting\n");
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 db 27 80 00       	push   $0x8027db
  800126:	e8 4d 01 00 00       	call   800278 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
}
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	8b 75 08             	mov    0x8(%ebp),%esi
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800143:	e8 1d 0b 00 00       	call   800c65 <sys_getenvid>
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	89 c2                	mov    %eax,%edx
  80014f:	c1 e2 07             	shl    $0x7,%edx
  800152:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800159:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015e:	85 f6                	test   %esi,%esi
  800160:	7e 07                	jle    800169 <libmain+0x31>
		binaryname = argv[0];
  800162:	8b 03                	mov    (%ebx),%eax
  800164:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	53                   	push   %ebx
  80016d:	56                   	push   %esi
  80016e:	e8 c1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800173:	e8 0c 00 00 00       	call   800184 <exit>
  800178:	83 c4 10             	add    $0x10,%esp
}
  80017b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018a:	e8 d7 0e 00 00       	call   801066 <close_all>
	sys_env_destroy(0);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	6a 00                	push   $0x0
  800194:	e8 aa 0a 00 00       	call   800c43 <sys_env_destroy>
  800199:	83 c4 10             	add    $0x10,%esp
}
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    
	...

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001ae:	e8 b2 0a 00 00       	call   800c65 <sys_getenvid>
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 0c             	pushl  0xc(%ebp)
  8001b9:	ff 75 08             	pushl  0x8(%ebp)
  8001bc:	53                   	push   %ebx
  8001bd:	50                   	push   %eax
  8001be:	68 f8 27 80 00       	push   $0x8027f8
  8001c3:	e8 b0 00 00 00       	call   800278 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	56                   	push   %esi
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	e8 53 00 00 00       	call   800227 <vcprintf>
	cprintf("\n");
  8001d4:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  8001db:	e8 98 00 00 00       	call   800278 <cprintf>
  8001e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e3:	cc                   	int3   
  8001e4:	eb fd                	jmp    8001e3 <_panic+0x43>
	...

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001fb:	40                   	inc    %eax
  8001fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800203:	75 1a                	jne    80021f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 43 08             	lea    0x8(%ebx),%eax
  800210:	50                   	push   %eax
  800211:	e8 e3 09 00 00       	call   800bf9 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021f:	ff 43 04             	incl   0x4(%ebx)
}
  800222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	68 e8 01 80 00       	push   $0x8001e8
  800256:	e8 82 01 00 00       	call   8003dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025b:	83 c4 08             	add    $0x8,%esp
  80025e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800264:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026a:	50                   	push   %eax
  80026b:	e8 89 09 00 00       	call   800bf9 <sys_cputs>

	return b.cnt;
}
  800270:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800281:	50                   	push   %eax
  800282:	ff 75 08             	pushl  0x8(%ebp)
  800285:	e8 9d ff ff ff       	call   800227 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 2c             	sub    $0x2c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d6                	mov    %edx,%esi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ac:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002b9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002bc:	72 0c                	jb     8002ca <printnum+0x3e>
  8002be:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002c1:	76 07                	jbe    8002ca <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c3:	4b                   	dec    %ebx
  8002c4:	85 db                	test   %ebx,%ebx
  8002c6:	7f 31                	jg     8002f9 <printnum+0x6d>
  8002c8:	eb 3f                	jmp    800309 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	57                   	push   %edi
  8002ce:	4b                   	dec    %ebx
  8002cf:	53                   	push   %ebx
  8002d0:	50                   	push   %eax
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e0:	e8 e7 21 00 00       	call   8024cc <__udivdi3>
  8002e5:	83 c4 18             	add    $0x18,%esp
  8002e8:	52                   	push   %edx
  8002e9:	50                   	push   %eax
  8002ea:	89 f2                	mov    %esi,%edx
  8002ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ef:	e8 98 ff ff ff       	call   80028c <printnum>
  8002f4:	83 c4 20             	add    $0x20,%esp
  8002f7:	eb 10                	jmp    800309 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	56                   	push   %esi
  8002fd:	57                   	push   %edi
  8002fe:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800301:	4b                   	dec    %ebx
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f f0                	jg     8002f9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 d4             	pushl  -0x2c(%ebp)
  800313:	ff 75 d0             	pushl  -0x30(%ebp)
  800316:	ff 75 dc             	pushl  -0x24(%ebp)
  800319:	ff 75 d8             	pushl  -0x28(%ebp)
  80031c:	e8 c7 22 00 00       	call   8025e8 <__umoddi3>
  800321:	83 c4 14             	add    $0x14,%esp
  800324:	0f be 80 1b 28 80 00 	movsbl 0x80281b(%eax),%eax
  80032b:	50                   	push   %eax
  80032c:	ff 55 e4             	call   *-0x1c(%ebp)
  80032f:	83 c4 10             	add    $0x10,%esp
}
  800332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033d:	83 fa 01             	cmp    $0x1,%edx
  800340:	7e 0e                	jle    800350 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 08             	lea    0x8(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	8b 52 04             	mov    0x4(%edx),%edx
  80034e:	eb 22                	jmp    800372 <getuint+0x38>
	else if (lflag)
  800350:	85 d2                	test   %edx,%edx
  800352:	74 10                	je     800364 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 0e                	jmp    800372 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getint+0x16>
		return va_arg(*ap, long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 1a                	jmp    8003a4 <getint+0x30>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 0c                	je     80039a <getint+0x26>
		return va_arg(*ap, long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	99                   	cltd   
  800398:	eb 0a                	jmp    8003a4 <getint+0x30>
	else
		return va_arg(*ap, int);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	99                   	cltd   
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ac:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b4:	73 08                	jae    8003be <sprintputch+0x18>
		*b->buf++ = ch;
  8003b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b9:	88 0a                	mov    %cl,(%edx)
  8003bb:	42                   	inc    %edx
  8003bc:	89 10                	mov    %edx,(%eax)
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c9:	50                   	push   %eax
  8003ca:	ff 75 10             	pushl  0x10(%ebp)
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	e8 05 00 00 00       	call   8003dd <vprintfmt>
	va_end(ap);
  8003d8:	83 c4 10             	add    $0x10,%esp
}
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    

008003dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	53                   	push   %ebx
  8003e3:	83 ec 2c             	sub    $0x2c,%esp
  8003e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ec:	eb 13                	jmp    800401 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	0f 84 6d 03 00 00    	je     800763 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	57                   	push   %edi
  8003fa:	50                   	push   %eax
  8003fb:	ff 55 08             	call   *0x8(%ebp)
  8003fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800401:	0f b6 06             	movzbl (%esi),%eax
  800404:	46                   	inc    %esi
  800405:	83 f8 25             	cmp    $0x25,%eax
  800408:	75 e4                	jne    8003ee <vprintfmt+0x11>
  80040a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80040e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800415:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80041c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800423:	b9 00 00 00 00       	mov    $0x0,%ecx
  800428:	eb 28                	jmp    800452 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80042c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800430:	eb 20                	jmp    800452 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800434:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800438:	eb 18                	jmp    800452 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80043c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800443:	eb 0d                	jmp    800452 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800445:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8a 06                	mov    (%esi),%al
  800454:	0f b6 d0             	movzbl %al,%edx
  800457:	8d 5e 01             	lea    0x1(%esi),%ebx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 e0 02 00 00    	ja     800745 <vprintfmt+0x368>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046f:	83 ea 30             	sub    $0x30,%edx
  800472:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800475:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800478:	8d 50 d0             	lea    -0x30(%eax),%edx
  80047b:	83 fa 09             	cmp    $0x9,%edx
  80047e:	77 44                	ja     8004c4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	89 de                	mov    %ebx,%esi
  800482:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800485:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800486:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800489:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80048d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800490:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800493:	83 fb 09             	cmp    $0x9,%ebx
  800496:	76 ed                	jbe    800485 <vprintfmt+0xa8>
  800498:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80049b:	eb 29                	jmp    8004c6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 00                	mov    (%eax),%eax
  8004a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ad:	eb 17                	jmp    8004c6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b3:	78 85                	js     80043a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	89 de                	mov    %ebx,%esi
  8004b7:	eb 99                	jmp    800452 <vprintfmt+0x75>
  8004b9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c2:	eb 8e                	jmp    800452 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ca:	79 86                	jns    800452 <vprintfmt+0x75>
  8004cc:	e9 74 ff ff ff       	jmp    800445 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	89 de                	mov    %ebx,%esi
  8004d4:	e9 79 ff ff ff       	jmp    800452 <vprintfmt+0x75>
  8004d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	57                   	push   %edi
  8004e9:	ff 30                	pushl  (%eax)
  8004eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f4:	e9 08 ff ff ff       	jmp    800401 <vprintfmt+0x24>
  8004f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 04             	lea    0x4(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	8b 00                	mov    (%eax),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	79 02                	jns    80050d <vprintfmt+0x130>
  80050b:	f7 d8                	neg    %eax
  80050d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050f:	83 f8 0f             	cmp    $0xf,%eax
  800512:	7f 0b                	jg     80051f <vprintfmt+0x142>
  800514:	8b 04 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%eax
  80051b:	85 c0                	test   %eax,%eax
  80051d:	75 1a                	jne    800539 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80051f:	52                   	push   %edx
  800520:	68 33 28 80 00       	push   $0x802833
  800525:	57                   	push   %edi
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 92 fe ff ff       	call   8003c0 <printfmt>
  80052e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800534:	e9 c8 fe ff ff       	jmp    800401 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800539:	50                   	push   %eax
  80053a:	68 f1 2b 80 00       	push   $0x802bf1
  80053f:	57                   	push   %edi
  800540:	ff 75 08             	pushl  0x8(%ebp)
  800543:	e8 78 fe ff ff       	call   8003c0 <printfmt>
  800548:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80054e:	e9 ae fe ff ff       	jmp    800401 <vprintfmt+0x24>
  800553:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800556:	89 de                	mov    %ebx,%esi
  800558:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056c:	85 c0                	test   %eax,%eax
  80056e:	75 07                	jne    800577 <vprintfmt+0x19a>
				p = "(null)";
  800570:	c7 45 d0 2c 28 80 00 	movl   $0x80282c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800577:	85 db                	test   %ebx,%ebx
  800579:	7e 42                	jle    8005bd <vprintfmt+0x1e0>
  80057b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80057f:	74 3c                	je     8005bd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	51                   	push   %ecx
  800585:	ff 75 d0             	pushl  -0x30(%ebp)
  800588:	e8 6f 02 00 00       	call   8007fc <strnlen>
  80058d:	29 c3                	sub    %eax,%ebx
  80058f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	85 db                	test   %ebx,%ebx
  800597:	7e 24                	jle    8005bd <vprintfmt+0x1e0>
					putch(padc, putdat);
  800599:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80059d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	57                   	push   %edi
  8005a7:	53                   	push   %ebx
  8005a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	4e                   	dec    %esi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	7f f0                	jg     8005a3 <vprintfmt+0x1c6>
  8005b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c0:	0f be 02             	movsbl (%edx),%eax
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	75 47                	jne    80060e <vprintfmt+0x231>
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005cd:	74 16                	je     8005e5 <vprintfmt+0x208>
  8005cf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d2:	83 fa 5e             	cmp    $0x5e,%edx
  8005d5:	76 0e                	jbe    8005e5 <vprintfmt+0x208>
					putch('?', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	57                   	push   %edi
  8005db:	6a 3f                	push   $0x3f
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	eb 0b                	jmp    8005f0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	57                   	push   %edi
  8005e9:	50                   	push   %eax
  8005ea:	ff 55 08             	call   *0x8(%ebp)
  8005ed:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005f3:	0f be 03             	movsbl (%ebx),%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 03                	je     8005fd <vprintfmt+0x220>
  8005fa:	43                   	inc    %ebx
  8005fb:	eb 1b                	jmp    800618 <vprintfmt+0x23b>
  8005fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800600:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800604:	7f 1e                	jg     800624 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800609:	e9 f3 fd ff ff       	jmp    800401 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800611:	43                   	inc    %ebx
  800612:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800615:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800618:	85 f6                	test   %esi,%esi
  80061a:	78 ad                	js     8005c9 <vprintfmt+0x1ec>
  80061c:	4e                   	dec    %esi
  80061d:	79 aa                	jns    8005c9 <vprintfmt+0x1ec>
  80061f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800622:	eb dc                	jmp    800600 <vprintfmt+0x223>
  800624:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 20                	push   $0x20
  80062d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800630:	4b                   	dec    %ebx
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	85 db                	test   %ebx,%ebx
  800636:	7f ef                	jg     800627 <vprintfmt+0x24a>
  800638:	e9 c4 fd ff ff       	jmp    800401 <vprintfmt+0x24>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 2a fd ff ff       	call   800374 <getint>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80064e:	85 d2                	test   %edx,%edx
  800650:	78 0a                	js     80065c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 b0 00 00 00       	jmp    80070c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	57                   	push   %edi
  800660:	6a 2d                	push   $0x2d
  800662:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800665:	f7 db                	neg    %ebx
  800667:	83 d6 00             	adc    $0x0,%esi
  80066a:	f7 de                	neg    %esi
  80066c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 93 00 00 00       	jmp    80070c <vprintfmt+0x32f>
  800679:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 b4 fc ff ff       	call   80033a <getuint>
  800686:	89 c3                	mov    %eax,%ebx
  800688:	89 d6                	mov    %edx,%esi
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068f:	eb 7b                	jmp    80070c <vprintfmt+0x32f>
  800691:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800694:	89 ca                	mov    %ecx,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 d6 fc ff ff       	call   800374 <getint>
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	78 07                	js     8006ad <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ab:	eb 5f                	jmp    80070c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	57                   	push   %edi
  8006b1:	6a 2d                	push   $0x2d
  8006b3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006b6:	f7 db                	neg    %ebx
  8006b8:	83 d6 00             	adc    $0x0,%esi
  8006bb:	f7 de                	neg    %esi
  8006bd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c5:	eb 45                	jmp    80070c <vprintfmt+0x32f>
  8006c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	57                   	push   %edi
  8006ce:	6a 30                	push   $0x30
  8006d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	57                   	push   %edi
  8006d7:	6a 78                	push   $0x78
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e5:	8b 18                	mov    (%eax),%ebx
  8006e7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f4:	eb 16                	jmp    80070c <vprintfmt+0x32f>
  8006f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 37 fc ff ff       	call   80033a <getuint>
  800703:	89 c3                	mov    %eax,%ebx
  800705:	89 d6                	mov    %edx,%esi
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800713:	52                   	push   %edx
  800714:	ff 75 e4             	pushl  -0x1c(%ebp)
  800717:	50                   	push   %eax
  800718:	56                   	push   %esi
  800719:	53                   	push   %ebx
  80071a:	89 fa                	mov    %edi,%edx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	e8 68 fb ff ff       	call   80028c <printnum>
			break;
  800724:	83 c4 20             	add    $0x20,%esp
  800727:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80072a:	e9 d2 fc ff ff       	jmp    800401 <vprintfmt+0x24>
  80072f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	57                   	push   %edi
  800736:	52                   	push   %edx
  800737:	ff 55 08             	call   *0x8(%ebp)
			break;
  80073a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800740:	e9 bc fc ff ff       	jmp    800401 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	57                   	push   %edi
  800749:	6a 25                	push   $0x25
  80074b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 02                	jmp    800755 <vprintfmt+0x378>
  800753:	89 c6                	mov    %eax,%esi
  800755:	8d 46 ff             	lea    -0x1(%esi),%eax
  800758:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075c:	75 f5                	jne    800753 <vprintfmt+0x376>
  80075e:	e9 9e fc ff ff       	jmp    800401 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 18             	sub    $0x18,%esp
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800777:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800788:	85 c0                	test   %eax,%eax
  80078a:	74 26                	je     8007b2 <vsnprintf+0x47>
  80078c:	85 d2                	test   %edx,%edx
  80078e:	7e 29                	jle    8007b9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800790:	ff 75 14             	pushl  0x14(%ebp)
  800793:	ff 75 10             	pushl  0x10(%ebp)
  800796:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800799:	50                   	push   %eax
  80079a:	68 a6 03 80 00       	push   $0x8003a6
  80079f:	e8 39 fc ff ff       	call   8003dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb 0c                	jmp    8007be <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb 05                	jmp    8007be <vsnprintf+0x53>
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	ff 75 08             	pushl  0x8(%ebp)
  8007d3:	e8 93 ff ff ff       	call   80076b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e5:	74 0e                	je     8007f5 <strlen+0x19>
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ec:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f1:	75 f9                	jne    8007ec <strlen+0x10>
  8007f3:	eb 05                	jmp    8007fa <strlen+0x1e>
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	85 d2                	test   %edx,%edx
  800807:	74 17                	je     800820 <strnlen+0x24>
  800809:	80 39 00             	cmpb   $0x0,(%ecx)
  80080c:	74 19                	je     800827 <strnlen+0x2b>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800813:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800814:	39 d0                	cmp    %edx,%eax
  800816:	74 14                	je     80082c <strnlen+0x30>
  800818:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081c:	75 f5                	jne    800813 <strnlen+0x17>
  80081e:	eb 0c                	jmp    80082c <strnlen+0x30>
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 05                	jmp    80082c <strnlen+0x30>
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800838:	ba 00 00 00 00       	mov    $0x0,%edx
  80083d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800840:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800843:	42                   	inc    %edx
  800844:	84 c9                	test   %cl,%cl
  800846:	75 f5                	jne    80083d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800848:	5b                   	pop    %ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800852:	53                   	push   %ebx
  800853:	e8 84 ff ff ff       	call   8007dc <strlen>
  800858:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085b:	ff 75 0c             	pushl  0xc(%ebp)
  80085e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800861:	50                   	push   %eax
  800862:	e8 c7 ff ff ff       	call   80082e <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	85 f6                	test   %esi,%esi
  80087e:	74 15                	je     800895 <strncpy+0x27>
  800880:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800885:	8a 1a                	mov    (%edx),%bl
  800887:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088a:	80 3a 01             	cmpb   $0x1,(%edx)
  80088d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800890:	41                   	inc    %ecx
  800891:	39 ce                	cmp    %ecx,%esi
  800893:	77 f0                	ja     800885 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	85 f6                	test   %esi,%esi
  8008aa:	74 32                	je     8008de <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008ac:	83 fe 01             	cmp    $0x1,%esi
  8008af:	74 22                	je     8008d3 <strlcpy+0x3a>
  8008b1:	8a 0b                	mov    (%ebx),%cl
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 20                	je     8008d7 <strlcpy+0x3e>
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008be:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	88 08                	mov    %cl,(%eax)
  8008c3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c4:	39 f2                	cmp    %esi,%edx
  8008c6:	74 11                	je     8008d9 <strlcpy+0x40>
  8008c8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008cc:	42                   	inc    %edx
  8008cd:	84 c9                	test   %cl,%cl
  8008cf:	75 f0                	jne    8008c1 <strlcpy+0x28>
  8008d1:	eb 06                	jmp    8008d9 <strlcpy+0x40>
  8008d3:	89 f8                	mov    %edi,%eax
  8008d5:	eb 02                	jmp    8008d9 <strlcpy+0x40>
  8008d7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d9:	c6 00 00             	movb   $0x0,(%eax)
  8008dc:	eb 02                	jmp    8008e0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008de:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008e0:	29 f8                	sub    %edi,%eax
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f0:	8a 01                	mov    (%ecx),%al
  8008f2:	84 c0                	test   %al,%al
  8008f4:	74 10                	je     800906 <strcmp+0x1f>
  8008f6:	3a 02                	cmp    (%edx),%al
  8008f8:	75 0c                	jne    800906 <strcmp+0x1f>
		p++, q++;
  8008fa:	41                   	inc    %ecx
  8008fb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fc:	8a 01                	mov    (%ecx),%al
  8008fe:	84 c0                	test   %al,%al
  800900:	74 04                	je     800906 <strcmp+0x1f>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	74 f4                	je     8008fa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 55 08             	mov    0x8(%ebp),%edx
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80091d:	85 c0                	test   %eax,%eax
  80091f:	74 1b                	je     80093c <strncmp+0x2c>
  800921:	8a 1a                	mov    (%edx),%bl
  800923:	84 db                	test   %bl,%bl
  800925:	74 24                	je     80094b <strncmp+0x3b>
  800927:	3a 19                	cmp    (%ecx),%bl
  800929:	75 20                	jne    80094b <strncmp+0x3b>
  80092b:	48                   	dec    %eax
  80092c:	74 15                	je     800943 <strncmp+0x33>
		n--, p++, q++;
  80092e:	42                   	inc    %edx
  80092f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800930:	8a 1a                	mov    (%edx),%bl
  800932:	84 db                	test   %bl,%bl
  800934:	74 15                	je     80094b <strncmp+0x3b>
  800936:	3a 19                	cmp    (%ecx),%bl
  800938:	74 f1                	je     80092b <strncmp+0x1b>
  80093a:	eb 0f                	jmp    80094b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	eb 05                	jmp    800948 <strncmp+0x38>
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800948:	5b                   	pop    %ebx
  800949:	c9                   	leave  
  80094a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 02             	movzbl (%edx),%eax
  80094e:	0f b6 11             	movzbl (%ecx),%edx
  800951:	29 d0                	sub    %edx,%eax
  800953:	eb f3                	jmp    800948 <strncmp+0x38>

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095e:	8a 10                	mov    (%eax),%dl
  800960:	84 d2                	test   %dl,%dl
  800962:	74 18                	je     80097c <strchr+0x27>
		if (*s == c)
  800964:	38 ca                	cmp    %cl,%dl
  800966:	75 06                	jne    80096e <strchr+0x19>
  800968:	eb 17                	jmp    800981 <strchr+0x2c>
  80096a:	38 ca                	cmp    %cl,%dl
  80096c:	74 13                	je     800981 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096e:	40                   	inc    %eax
  80096f:	8a 10                	mov    (%eax),%dl
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f5                	jne    80096a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	eb 05                	jmp    800981 <strchr+0x2c>
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80098c:	8a 10                	mov    (%eax),%dl
  80098e:	84 d2                	test   %dl,%dl
  800990:	74 11                	je     8009a3 <strfind+0x20>
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	75 06                	jne    80099c <strfind+0x19>
  800996:	eb 0b                	jmp    8009a3 <strfind+0x20>
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 07                	je     8009a3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099c:	40                   	inc    %eax
  80099d:	8a 10                	mov    (%eax),%dl
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	75 f5                	jne    800998 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 30                	je     8009e8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009be:	75 25                	jne    8009e5 <memset+0x40>
  8009c0:	f6 c1 03             	test   $0x3,%cl
  8009c3:	75 20                	jne    8009e5 <memset+0x40>
		c &= 0xFF;
  8009c5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d6                	mov    %edx,%esi
  8009cf:	c1 e6 18             	shl    $0x18,%esi
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	c1 e0 10             	shl    $0x10,%eax
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 d0                	or     %edx,%eax
  8009db:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e0:	fc                   	cld    
  8009e1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e3:	eb 03                	jmp    8009e8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e5:	fc                   	cld    
  8009e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e8:	89 f8                	mov    %edi,%eax
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fd:	39 c6                	cmp    %eax,%esi
  8009ff:	73 34                	jae    800a35 <memmove+0x46>
  800a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	73 2d                	jae    800a35 <memmove+0x46>
		s += n;
		d += n;
  800a08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	f6 c2 03             	test   $0x3,%dl
  800a0e:	75 1b                	jne    800a2b <memmove+0x3c>
  800a10:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a16:	75 13                	jne    800a2b <memmove+0x3c>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0e                	jne    800a2b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1d:	83 ef 04             	sub    $0x4,%edi
  800a20:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a23:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a26:	fd                   	std    
  800a27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a29:	eb 07                	jmp    800a32 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2b:	4f                   	dec    %edi
  800a2c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2f:	fd                   	std    
  800a30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a32:	fc                   	cld    
  800a33:	eb 20                	jmp    800a55 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a35:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3b:	75 13                	jne    800a50 <memmove+0x61>
  800a3d:	a8 03                	test   $0x3,%al
  800a3f:	75 0f                	jne    800a50 <memmove+0x61>
  800a41:	f6 c1 03             	test   $0x3,%cl
  800a44:	75 0a                	jne    800a50 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a46:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a49:	89 c7                	mov    %eax,%edi
  800a4b:	fc                   	cld    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 05                	jmp    800a55 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a50:	89 c7                	mov    %eax,%edi
  800a52:	fc                   	cld    
  800a53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a5c:	ff 75 10             	pushl  0x10(%ebp)
  800a5f:	ff 75 0c             	pushl  0xc(%ebp)
  800a62:	ff 75 08             	pushl  0x8(%ebp)
  800a65:	e8 85 ff ff ff       	call   8009ef <memmove>
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a78:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	74 32                	je     800ab1 <memcmp+0x45>
		if (*s1 != *s2)
  800a7f:	8a 03                	mov    (%ebx),%al
  800a81:	8a 0e                	mov    (%esi),%cl
  800a83:	38 c8                	cmp    %cl,%al
  800a85:	74 19                	je     800aa0 <memcmp+0x34>
  800a87:	eb 0d                	jmp    800a96 <memcmp+0x2a>
  800a89:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a8d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a91:	42                   	inc    %edx
  800a92:	38 c8                	cmp    %cl,%al
  800a94:	74 10                	je     800aa6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a96:	0f b6 c0             	movzbl %al,%eax
  800a99:	0f b6 c9             	movzbl %cl,%ecx
  800a9c:	29 c8                	sub    %ecx,%eax
  800a9e:	eb 16                	jmp    800ab6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa0:	4f                   	dec    %edi
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	39 fa                	cmp    %edi,%edx
  800aa8:	75 df                	jne    800a89 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	eb 05                	jmp    800ab6 <memcmp+0x4a>
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac6:	39 d0                	cmp    %edx,%eax
  800ac8:	73 12                	jae    800adc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aca:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800acd:	38 08                	cmp    %cl,(%eax)
  800acf:	75 06                	jne    800ad7 <memfind+0x1c>
  800ad1:	eb 09                	jmp    800adc <memfind+0x21>
  800ad3:	38 08                	cmp    %cl,(%eax)
  800ad5:	74 05                	je     800adc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad7:	40                   	inc    %eax
  800ad8:	39 c2                	cmp    %eax,%edx
  800ada:	77 f7                	ja     800ad3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	eb 01                	jmp    800aed <strtol+0xf>
		s++;
  800aec:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aed:	8a 02                	mov    (%edx),%al
  800aef:	3c 20                	cmp    $0x20,%al
  800af1:	74 f9                	je     800aec <strtol+0xe>
  800af3:	3c 09                	cmp    $0x9,%al
  800af5:	74 f5                	je     800aec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af7:	3c 2b                	cmp    $0x2b,%al
  800af9:	75 08                	jne    800b03 <strtol+0x25>
		s++;
  800afb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afc:	bf 00 00 00 00       	mov    $0x0,%edi
  800b01:	eb 13                	jmp    800b16 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b03:	3c 2d                	cmp    $0x2d,%al
  800b05:	75 0a                	jne    800b11 <strtol+0x33>
		s++, neg = 1;
  800b07:	8d 52 01             	lea    0x1(%edx),%edx
  800b0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0f:	eb 05                	jmp    800b16 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b16:	85 db                	test   %ebx,%ebx
  800b18:	74 05                	je     800b1f <strtol+0x41>
  800b1a:	83 fb 10             	cmp    $0x10,%ebx
  800b1d:	75 28                	jne    800b47 <strtol+0x69>
  800b1f:	8a 02                	mov    (%edx),%al
  800b21:	3c 30                	cmp    $0x30,%al
  800b23:	75 10                	jne    800b35 <strtol+0x57>
  800b25:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b29:	75 0a                	jne    800b35 <strtol+0x57>
		s += 2, base = 16;
  800b2b:	83 c2 02             	add    $0x2,%edx
  800b2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b33:	eb 12                	jmp    800b47 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b35:	85 db                	test   %ebx,%ebx
  800b37:	75 0e                	jne    800b47 <strtol+0x69>
  800b39:	3c 30                	cmp    $0x30,%al
  800b3b:	75 05                	jne    800b42 <strtol+0x64>
		s++, base = 8;
  800b3d:	42                   	inc    %edx
  800b3e:	b3 08                	mov    $0x8,%bl
  800b40:	eb 05                	jmp    800b47 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b4e:	8a 0a                	mov    (%edx),%cl
  800b50:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b53:	80 fb 09             	cmp    $0x9,%bl
  800b56:	77 08                	ja     800b60 <strtol+0x82>
			dig = *s - '0';
  800b58:	0f be c9             	movsbl %cl,%ecx
  800b5b:	83 e9 30             	sub    $0x30,%ecx
  800b5e:	eb 1e                	jmp    800b7e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b60:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 08                	ja     800b70 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b68:	0f be c9             	movsbl %cl,%ecx
  800b6b:	83 e9 57             	sub    $0x57,%ecx
  800b6e:	eb 0e                	jmp    800b7e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b70:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b73:	80 fb 19             	cmp    $0x19,%bl
  800b76:	77 13                	ja     800b8b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b78:	0f be c9             	movsbl %cl,%ecx
  800b7b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b7e:	39 f1                	cmp    %esi,%ecx
  800b80:	7d 0d                	jge    800b8f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b82:	42                   	inc    %edx
  800b83:	0f af c6             	imul   %esi,%eax
  800b86:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b89:	eb c3                	jmp    800b4e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b8b:	89 c1                	mov    %eax,%ecx
  800b8d:	eb 02                	jmp    800b91 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b95:	74 05                	je     800b9c <strtol+0xbe>
		*endptr = (char *) s;
  800b97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	74 04                	je     800ba4 <strtol+0xc6>
  800ba0:	89 c8                	mov    %ecx,%eax
  800ba2:	f7 d8                	neg    %eax
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    
  800ba9:	00 00                	add    %al,(%eax)
	...

00800bac <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 1c             	sub    $0x1c,%esp
  800bb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bb8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bbb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	8b 75 14             	mov    0x14(%ebp),%esi
  800bc0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc9:	cd 30                	int    $0x30
  800bcb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bd1:	74 1c                	je     800bef <syscall+0x43>
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 18                	jle    800bef <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	50                   	push   %eax
  800bdb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bde:	68 1f 2b 80 00       	push   $0x802b1f
  800be3:	6a 42                	push   $0x42
  800be5:	68 3c 2b 80 00       	push   $0x802b3c
  800bea:	e8 b1 f5 ff ff       	call   8001a0 <_panic>

	return ret;
}
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bff:	6a 00                	push   $0x0
  800c01:	6a 00                	push   $0x0
  800c03:	6a 00                	push   $0x0
  800c05:	ff 75 0c             	pushl  0xc(%ebp)
  800c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 00 00 00 00       	mov    $0x0,%eax
  800c15:	e8 92 ff ff ff       	call   800bac <syscall>
  800c1a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c25:	6a 00                	push   $0x0
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3c:	e8 6b ff ff ff       	call   800bac <syscall>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c49:	6a 00                	push   $0x0
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c54:	ba 01 00 00 00       	mov    $0x1,%edx
  800c59:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5e:	e8 49 ff ff ff       	call   800bac <syscall>
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c6b:	6a 00                	push   $0x0
  800c6d:	6a 00                	push   $0x0
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c82:	e8 25 ff ff ff       	call   800bac <syscall>
}
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <sys_yield>:

void
sys_yield(void)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c8f:	6a 00                	push   $0x0
  800c91:	6a 00                	push   $0x0
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca6:	e8 01 ff ff ff       	call   800bac <syscall>
  800cab:	83 c4 10             	add    $0x10,%esp
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cb6:	6a 00                	push   $0x0
  800cb8:	6a 00                	push   $0x0
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccd:	e8 da fe ff ff       	call   800bac <syscall>
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cda:	ff 75 18             	pushl  0x18(%ebp)
  800cdd:	ff 75 14             	pushl  0x14(%ebp)
  800ce0:	ff 75 10             	pushl  0x10(%ebp)
  800ce3:	ff 75 0c             	pushl  0xc(%ebp)
  800ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cee:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf3:	e8 b4 fe ff ff       	call   800bac <syscall>
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d00:	6a 00                	push   $0x0
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d11:	b8 06 00 00 00       	mov    $0x6,%eax
  800d16:	e8 91 fe ff ff       	call   800bac <syscall>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	ff 75 0c             	pushl  0xc(%ebp)
  800d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d34:	b8 08 00 00 00       	mov    $0x8,%eax
  800d39:	e8 6e fe ff ff       	call   800bac <syscall>
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d46:	6a 00                	push   $0x0
  800d48:	6a 00                	push   $0x0
  800d4a:	6a 00                	push   $0x0
  800d4c:	ff 75 0c             	pushl  0xc(%ebp)
  800d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d52:	ba 01 00 00 00       	mov    $0x1,%edx
  800d57:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5c:	e8 4b fe ff ff       	call   800bac <syscall>
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    

00800d63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d69:	6a 00                	push   $0x0
  800d6b:	6a 00                	push   $0x0
  800d6d:	6a 00                	push   $0x0
  800d6f:	ff 75 0c             	pushl  0xc(%ebp)
  800d72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d75:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7f:	e8 28 fe ff ff       	call   800bac <syscall>
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d8c:	6a 00                	push   $0x0
  800d8e:	ff 75 14             	pushl  0x14(%ebp)
  800d91:	ff 75 10             	pushl  0x10(%ebp)
  800d94:	ff 75 0c             	pushl  0xc(%ebp)
  800d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	e8 03 fe ff ff       	call   800bac <syscall>
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800db1:	6a 00                	push   $0x0
  800db3:	6a 00                	push   $0x0
  800db5:	6a 00                	push   $0x0
  800db7:	6a 00                	push   $0x0
  800db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbc:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc6:	e8 e1 fd ff ff       	call   800bac <syscall>
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800dd3:	6a 00                	push   $0x0
  800dd5:	6a 00                	push   $0x0
  800dd7:	6a 00                	push   $0x0
  800dd9:	ff 75 0c             	pushl  0xc(%ebp)
  800ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  800de4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de9:	e8 be fd ff ff       	call   800bac <syscall>
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800df6:	6a 00                	push   $0x0
  800df8:	ff 75 14             	pushl  0x14(%ebp)
  800dfb:	ff 75 10             	pushl  0x10(%ebp)
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e0e:	e8 99 fd ff ff       	call   800bac <syscall>
} 
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800e1b:	6a 00                	push   $0x0
  800e1d:	6a 00                	push   $0x0
  800e1f:	6a 00                	push   $0x0
  800e21:	6a 00                	push   $0x0
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2b:	b8 11 00 00 00       	mov    $0x11,%eax
  800e30:	e8 77 fd ff ff       	call   800bac <syscall>
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800e3d:	6a 00                	push   $0x0
  800e3f:	6a 00                	push   $0x0
  800e41:	6a 00                	push   $0x0
  800e43:	6a 00                	push   $0x0
  800e45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e54:	e8 53 fd ff ff       	call   800bac <syscall>
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    
	...

00800e5c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	05 00 00 00 30       	add    $0x30000000,%eax
  800e67:	c1 e8 0c             	shr    $0xc,%eax
}
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e6f:	ff 75 08             	pushl  0x8(%ebp)
  800e72:	e8 e5 ff ff ff       	call   800e5c <fd2num>
  800e77:	83 c4 04             	add    $0x4,%esp
  800e7a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e7f:	c1 e0 0c             	shl    $0xc,%eax
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e8b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e90:	a8 01                	test   $0x1,%al
  800e92:	74 34                	je     800ec8 <fd_alloc+0x44>
  800e94:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e99:	a8 01                	test   $0x1,%al
  800e9b:	74 32                	je     800ecf <fd_alloc+0x4b>
  800e9d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	c1 ea 16             	shr    $0x16,%edx
  800ea9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb0:	f6 c2 01             	test   $0x1,%dl
  800eb3:	74 1f                	je     800ed4 <fd_alloc+0x50>
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	c1 ea 0c             	shr    $0xc,%edx
  800eba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec1:	f6 c2 01             	test   $0x1,%dl
  800ec4:	75 17                	jne    800edd <fd_alloc+0x59>
  800ec6:	eb 0c                	jmp    800ed4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ec8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ecd:	eb 05                	jmp    800ed4 <fd_alloc+0x50>
  800ecf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ed4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	eb 17                	jmp    800ef4 <fd_alloc+0x70>
  800edd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee7:	75 b9                	jne    800ea2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efd:	83 f8 1f             	cmp    $0x1f,%eax
  800f00:	77 36                	ja     800f38 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f02:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f07:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0a:	89 c2                	mov    %eax,%edx
  800f0c:	c1 ea 16             	shr    $0x16,%edx
  800f0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f16:	f6 c2 01             	test   $0x1,%dl
  800f19:	74 24                	je     800f3f <fd_lookup+0x48>
  800f1b:	89 c2                	mov    %eax,%edx
  800f1d:	c1 ea 0c             	shr    $0xc,%edx
  800f20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f27:	f6 c2 01             	test   $0x1,%dl
  800f2a:	74 1a                	je     800f46 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	eb 13                	jmp    800f4b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3d:	eb 0c                	jmp    800f4b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f44:	eb 05                	jmp    800f4b <fd_lookup+0x54>
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	53                   	push   %ebx
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f5a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f60:	74 0d                	je     800f6f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb 14                	jmp    800f7d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f69:	39 0a                	cmp    %ecx,(%edx)
  800f6b:	75 10                	jne    800f7d <dev_lookup+0x30>
  800f6d:	eb 05                	jmp    800f74 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f6f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f74:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	eb 31                	jmp    800fae <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7d:	40                   	inc    %eax
  800f7e:	8b 14 85 c8 2b 80 00 	mov    0x802bc8(,%eax,4),%edx
  800f85:	85 d2                	test   %edx,%edx
  800f87:	75 e0                	jne    800f69 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f89:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8e:	8b 40 48             	mov    0x48(%eax),%eax
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	51                   	push   %ecx
  800f95:	50                   	push   %eax
  800f96:	68 4c 2b 80 00       	push   $0x802b4c
  800f9b:	e8 d8 f2 ff ff       	call   800278 <cprintf>
	*dev = 0;
  800fa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 20             	sub    $0x20,%esp
  800fbb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbe:	8a 45 0c             	mov    0xc(%ebp),%al
  800fc1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc4:	56                   	push   %esi
  800fc5:	e8 92 fe ff ff       	call   800e5c <fd2num>
  800fca:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fcd:	89 14 24             	mov    %edx,(%esp)
  800fd0:	50                   	push   %eax
  800fd1:	e8 21 ff ff ff       	call   800ef7 <fd_lookup>
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 05                	js     800fe4 <fd_close+0x31>
	    || fd != fd2)
  800fdf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fe2:	74 0d                	je     800ff1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fe4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fe8:	75 48                	jne    801032 <fd_close+0x7f>
  800fea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fef:	eb 41                	jmp    801032 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff1:	83 ec 08             	sub    $0x8,%esp
  800ff4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff7:	50                   	push   %eax
  800ff8:	ff 36                	pushl  (%esi)
  800ffa:	e8 4e ff ff ff       	call   800f4d <dev_lookup>
  800fff:	89 c3                	mov    %eax,%ebx
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 1c                	js     801024 <fd_close+0x71>
		if (dev->dev_close)
  801008:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100b:	8b 40 10             	mov    0x10(%eax),%eax
  80100e:	85 c0                	test   %eax,%eax
  801010:	74 0d                	je     80101f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	56                   	push   %esi
  801016:	ff d0                	call   *%eax
  801018:	89 c3                	mov    %eax,%ebx
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	eb 05                	jmp    801024 <fd_close+0x71>
		else
			r = 0;
  80101f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	56                   	push   %esi
  801028:	6a 00                	push   $0x0
  80102a:	e8 cb fc ff ff       	call   800cfa <sys_page_unmap>
	return r;
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	89 d8                	mov    %ebx,%eax
  801034:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801044:	50                   	push   %eax
  801045:	ff 75 08             	pushl  0x8(%ebp)
  801048:	e8 aa fe ff ff       	call   800ef7 <fd_lookup>
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 10                	js     801064 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	6a 01                	push   $0x1
  801059:	ff 75 f4             	pushl  -0xc(%ebp)
  80105c:	e8 52 ff ff ff       	call   800fb3 <fd_close>
  801061:	83 c4 10             	add    $0x10,%esp
}
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <close_all>:

void
close_all(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	53                   	push   %ebx
  80106a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80106d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	53                   	push   %ebx
  801076:	e8 c0 ff ff ff       	call   80103b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80107b:	43                   	inc    %ebx
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	83 fb 20             	cmp    $0x20,%ebx
  801082:	75 ee                	jne    801072 <close_all+0xc>
		close(i);
}
  801084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 2c             	sub    $0x2c,%esp
  801092:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801095:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801098:	50                   	push   %eax
  801099:	ff 75 08             	pushl  0x8(%ebp)
  80109c:	e8 56 fe ff ff       	call   800ef7 <fd_lookup>
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 88 c0 00 00 00    	js     80116e <dup+0xe5>
		return r;
	close(newfdnum);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	57                   	push   %edi
  8010b2:	e8 84 ff ff ff       	call   80103b <close>

	newfd = INDEX2FD(newfdnum);
  8010b7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010bd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010c0:	83 c4 04             	add    $0x4,%esp
  8010c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c6:	e8 a1 fd ff ff       	call   800e6c <fd2data>
  8010cb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010cd:	89 34 24             	mov    %esi,(%esp)
  8010d0:	e8 97 fd ff ff       	call   800e6c <fd2data>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	c1 e8 16             	shr    $0x16,%eax
  8010e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e7:	a8 01                	test   $0x1,%al
  8010e9:	74 37                	je     801122 <dup+0x99>
  8010eb:	89 d8                	mov    %ebx,%eax
  8010ed:	c1 e8 0c             	shr    $0xc,%eax
  8010f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 26                	je     801122 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110f:	6a 00                	push   $0x0
  801111:	53                   	push   %ebx
  801112:	6a 00                	push   $0x0
  801114:	e8 bb fb ff ff       	call   800cd4 <sys_page_map>
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	83 c4 20             	add    $0x20,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 2d                	js     80114f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801125:	89 c2                	mov    %eax,%edx
  801127:	c1 ea 0c             	shr    $0xc,%edx
  80112a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80113a:	52                   	push   %edx
  80113b:	56                   	push   %esi
  80113c:	6a 00                	push   $0x0
  80113e:	50                   	push   %eax
  80113f:	6a 00                	push   $0x0
  801141:	e8 8e fb ff ff       	call   800cd4 <sys_page_map>
  801146:	89 c3                	mov    %eax,%ebx
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	79 1d                	jns    80116c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	56                   	push   %esi
  801153:	6a 00                	push   $0x0
  801155:	e8 a0 fb ff ff       	call   800cfa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115a:	83 c4 08             	add    $0x8,%esp
  80115d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801160:	6a 00                	push   $0x0
  801162:	e8 93 fb ff ff       	call   800cfa <sys_page_unmap>
	return r;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb 02                	jmp    80116e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80116c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 14             	sub    $0x14,%esp
  80117f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801182:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	53                   	push   %ebx
  801187:	e8 6b fd ff ff       	call   800ef7 <fd_lookup>
  80118c:	83 c4 08             	add    $0x8,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 67                	js     8011fa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119d:	ff 30                	pushl  (%eax)
  80119f:	e8 a9 fd ff ff       	call   800f4d <dev_lookup>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 4f                	js     8011fa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ae:	8b 50 08             	mov    0x8(%eax),%edx
  8011b1:	83 e2 03             	and    $0x3,%edx
  8011b4:	83 fa 01             	cmp    $0x1,%edx
  8011b7:	75 21                	jne    8011da <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	53                   	push   %ebx
  8011c5:	50                   	push   %eax
  8011c6:	68 8d 2b 80 00       	push   $0x802b8d
  8011cb:	e8 a8 f0 ff ff       	call   800278 <cprintf>
		return -E_INVAL;
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d8:	eb 20                	jmp    8011fa <read+0x82>
	}
	if (!dev->dev_read)
  8011da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011dd:	8b 52 08             	mov    0x8(%edx),%edx
  8011e0:	85 d2                	test   %edx,%edx
  8011e2:	74 11                	je     8011f5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	ff 75 10             	pushl  0x10(%ebp)
  8011ea:	ff 75 0c             	pushl  0xc(%ebp)
  8011ed:	50                   	push   %eax
  8011ee:	ff d2                	call   *%edx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	eb 05                	jmp    8011fa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	57                   	push   %edi
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120e:	85 f6                	test   %esi,%esi
  801210:	74 31                	je     801243 <readn+0x44>
  801212:	b8 00 00 00 00       	mov    $0x0,%eax
  801217:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	89 f2                	mov    %esi,%edx
  801221:	29 c2                	sub    %eax,%edx
  801223:	52                   	push   %edx
  801224:	03 45 0c             	add    0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	57                   	push   %edi
  801229:	e8 4a ff ff ff       	call   801178 <read>
		if (m < 0)
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 17                	js     80124c <readn+0x4d>
			return m;
		if (m == 0)
  801235:	85 c0                	test   %eax,%eax
  801237:	74 11                	je     80124a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801239:	01 c3                	add    %eax,%ebx
  80123b:	89 d8                	mov    %ebx,%eax
  80123d:	39 f3                	cmp    %esi,%ebx
  80123f:	72 db                	jb     80121c <readn+0x1d>
  801241:	eb 09                	jmp    80124c <readn+0x4d>
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
  801248:	eb 02                	jmp    80124c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80124a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80124c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	83 ec 14             	sub    $0x14,%esp
  80125b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	53                   	push   %ebx
  801263:	e8 8f fc ff ff       	call   800ef7 <fd_lookup>
  801268:	83 c4 08             	add    $0x8,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 62                	js     8012d1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	ff 30                	pushl  (%eax)
  80127b:	e8 cd fc ff ff       	call   800f4d <dev_lookup>
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 4a                	js     8012d1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128e:	75 21                	jne    8012b1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801290:	a1 04 40 80 00       	mov    0x804004,%eax
  801295:	8b 40 48             	mov    0x48(%eax),%eax
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	53                   	push   %ebx
  80129c:	50                   	push   %eax
  80129d:	68 a9 2b 80 00       	push   $0x802ba9
  8012a2:	e8 d1 ef ff ff       	call   800278 <cprintf>
		return -E_INVAL;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012af:	eb 20                	jmp    8012d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b7:	85 d2                	test   %edx,%edx
  8012b9:	74 11                	je     8012cc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	ff 75 10             	pushl  0x10(%ebp)
  8012c1:	ff 75 0c             	pushl  0xc(%ebp)
  8012c4:	50                   	push   %eax
  8012c5:	ff d2                	call   *%edx
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	eb 05                	jmp    8012d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 0f fc ff ff       	call   800ef7 <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 0e                	js     8012fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	53                   	push   %ebx
  80130e:	e8 e4 fb ff ff       	call   800ef7 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 5f                	js     801379 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801324:	ff 30                	pushl  (%eax)
  801326:	e8 22 fc ff ff       	call   800f4d <dev_lookup>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 47                	js     801379 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801339:	75 21                	jne    80135c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801340:	8b 40 48             	mov    0x48(%eax),%eax
  801343:	83 ec 04             	sub    $0x4,%esp
  801346:	53                   	push   %ebx
  801347:	50                   	push   %eax
  801348:	68 6c 2b 80 00       	push   $0x802b6c
  80134d:	e8 26 ef ff ff       	call   800278 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135a:	eb 1d                	jmp    801379 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80135c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135f:	8b 52 18             	mov    0x18(%edx),%edx
  801362:	85 d2                	test   %edx,%edx
  801364:	74 0e                	je     801374 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 75 0c             	pushl  0xc(%ebp)
  80136c:	50                   	push   %eax
  80136d:	ff d2                	call   *%edx
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	eb 05                	jmp    801379 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801374:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	53                   	push   %ebx
  801382:	83 ec 14             	sub    $0x14,%esp
  801385:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801388:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 08             	pushl  0x8(%ebp)
  80138f:	e8 63 fb ff ff       	call   800ef7 <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 52                	js     8013ed <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a5:	ff 30                	pushl  (%eax)
  8013a7:	e8 a1 fb ff ff       	call   800f4d <dev_lookup>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 3a                	js     8013ed <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ba:	74 2c                	je     8013e8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c6:	00 00 00 
	stat->st_isdir = 0;
  8013c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d0:	00 00 00 
	stat->st_dev = dev;
  8013d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e0:	ff 50 14             	call   *0x14(%eax)
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb 05                	jmp    8013ed <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	6a 00                	push   $0x0
  8013fc:	ff 75 08             	pushl  0x8(%ebp)
  8013ff:	e8 78 01 00 00       	call   80157c <open>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 1b                	js     801428 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	ff 75 0c             	pushl  0xc(%ebp)
  801413:	50                   	push   %eax
  801414:	e8 65 ff ff ff       	call   80137e <fstat>
  801419:	89 c6                	mov    %eax,%esi
	close(fd);
  80141b:	89 1c 24             	mov    %ebx,(%esp)
  80141e:	e8 18 fc ff ff       	call   80103b <close>
	return r;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	89 f3                	mov    %esi,%ebx
}
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	c9                   	leave  
  801430:	c3                   	ret    
  801431:	00 00                	add    %al,(%eax)
	...

00801434 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80143d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801444:	75 12                	jne    801458 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	6a 01                	push   $0x1
  80144b:	e8 ea 0f 00 00       	call   80243a <ipc_find_env>
  801450:	a3 00 40 80 00       	mov    %eax,0x804000
  801455:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801458:	6a 07                	push   $0x7
  80145a:	68 00 50 80 00       	push   $0x805000
  80145f:	53                   	push   %ebx
  801460:	ff 35 00 40 80 00    	pushl  0x804000
  801466:	e8 7a 0f 00 00       	call   8023e5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80146b:	83 c4 0c             	add    $0xc,%esp
  80146e:	6a 00                	push   $0x0
  801470:	56                   	push   %esi
  801471:	6a 00                	push   $0x0
  801473:	e8 f8 0e 00 00       	call   802370 <ipc_recv>
}
  801478:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 05 00 00 00       	mov    $0x5,%eax
  80149e:	e8 91 ff ff ff       	call   801434 <fsipc>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 2c                	js     8014d3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	53                   	push   %ebx
  8014b0:	e8 79 f3 ff ff       	call   80082e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f3:	e8 3c ff ff ff       	call   801434 <fsipc>
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801502:	8b 45 08             	mov    0x8(%ebp),%eax
  801505:	8b 40 0c             	mov    0xc(%eax),%eax
  801508:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 03 00 00 00       	mov    $0x3,%eax
  80151d:	e8 12 ff ff ff       	call   801434 <fsipc>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 4b                	js     801573 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801528:	39 c6                	cmp    %eax,%esi
  80152a:	73 16                	jae    801542 <devfile_read+0x48>
  80152c:	68 d8 2b 80 00       	push   $0x802bd8
  801531:	68 df 2b 80 00       	push   $0x802bdf
  801536:	6a 7d                	push   $0x7d
  801538:	68 f4 2b 80 00       	push   $0x802bf4
  80153d:	e8 5e ec ff ff       	call   8001a0 <_panic>
	assert(r <= PGSIZE);
  801542:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801547:	7e 16                	jle    80155f <devfile_read+0x65>
  801549:	68 ff 2b 80 00       	push   $0x802bff
  80154e:	68 df 2b 80 00       	push   $0x802bdf
  801553:	6a 7e                	push   $0x7e
  801555:	68 f4 2b 80 00       	push   $0x802bf4
  80155a:	e8 41 ec ff ff       	call   8001a0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	50                   	push   %eax
  801563:	68 00 50 80 00       	push   $0x805000
  801568:	ff 75 0c             	pushl  0xc(%ebp)
  80156b:	e8 7f f4 ff ff       	call   8009ef <memmove>
	return r;
  801570:	83 c4 10             	add    $0x10,%esp
}
  801573:	89 d8                	mov    %ebx,%eax
  801575:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801587:	56                   	push   %esi
  801588:	e8 4f f2 ff ff       	call   8007dc <strlen>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801595:	7f 65                	jg     8015fc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 e1 f8 ff ff       	call   800e84 <fd_alloc>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 55                	js     801601 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	56                   	push   %esi
  8015b0:	68 00 50 80 00       	push   $0x805000
  8015b5:	e8 74 f2 ff ff       	call   80082e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ca:	e8 65 fe ff ff       	call   801434 <fsipc>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	79 12                	jns    8015ea <open+0x6e>
		fd_close(fd, 0);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	6a 00                	push   $0x0
  8015dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e0:	e8 ce f9 ff ff       	call   800fb3 <fd_close>
		return r;
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	eb 17                	jmp    801601 <open+0x85>
	}

	return fd2num(fd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 67 f8 ff ff       	call   800e5c <fd2num>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	eb 05                	jmp    801601 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015fc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801601:	89 d8                	mov    %ebx,%eax
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	c9                   	leave  
  801609:	c3                   	ret    
	...

0080160c <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 1c             	sub    $0x1c,%esp
  801615:	89 c7                	mov    %eax,%edi
  801617:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80161a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801624:	74 0c                	je     801632 <map_segment+0x26>
		va -= i;
  801626:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  801629:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  80162c:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  80162f:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801632:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801636:	0f 84 ee 00 00 00    	je     80172a <map_segment+0x11e>
  80163c:	be 00 00 00 00       	mov    $0x0,%esi
  801641:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801646:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801649:	77 20                	ja     80166b <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	ff 75 14             	pushl  0x14(%ebp)
  801651:	03 75 e4             	add    -0x1c(%ebp),%esi
  801654:	56                   	push   %esi
  801655:	57                   	push   %edi
  801656:	e8 55 f6 ff ff       	call   800cb0 <sys_page_alloc>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	0f 89 ac 00 00 00    	jns    801712 <map_segment+0x106>
  801666:	e9 c4 00 00 00       	jmp    80172f <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	6a 07                	push   $0x7
  801670:	68 00 00 40 00       	push   $0x400000
  801675:	6a 00                	push   $0x0
  801677:	e8 34 f6 ff ff       	call   800cb0 <sys_page_alloc>
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	0f 88 a8 00 00 00    	js     80172f <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801687:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  80168a:	8b 45 10             	mov    0x10(%ebp),%eax
  80168d:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 3d fc ff ff       	call   8012d6 <seek>
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	0f 88 8b 00 00 00    	js     80172f <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8016a4:	83 ec 04             	sub    $0x4,%esp
  8016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016aa:	29 f0                	sub    %esi,%eax
  8016ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016b1:	76 05                	jbe    8016b8 <map_segment+0xac>
  8016b3:	b8 00 10 00 00       	mov    $0x1000,%eax
  8016b8:	50                   	push   %eax
  8016b9:	68 00 00 40 00       	push   $0x400000
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 39 fb ff ff       	call   8011ff <readn>
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 62                	js     80172f <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8016cd:	83 ec 0c             	sub    $0xc,%esp
  8016d0:	ff 75 14             	pushl  0x14(%ebp)
  8016d3:	03 75 e4             	add    -0x1c(%ebp),%esi
  8016d6:	56                   	push   %esi
  8016d7:	57                   	push   %edi
  8016d8:	68 00 00 40 00       	push   $0x400000
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 f0 f5 ff ff       	call   800cd4 <sys_page_map>
  8016e4:	83 c4 20             	add    $0x20,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	79 15                	jns    801700 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  8016eb:	50                   	push   %eax
  8016ec:	68 0b 2c 80 00       	push   $0x802c0b
  8016f1:	68 84 01 00 00       	push   $0x184
  8016f6:	68 28 2c 80 00       	push   $0x802c28
  8016fb:	e8 a0 ea ff ff       	call   8001a0 <_panic>
			sys_page_unmap(0, UTEMP);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	68 00 00 40 00       	push   $0x400000
  801708:	6a 00                	push   $0x0
  80170a:	e8 eb f5 ff ff       	call   800cfa <sys_page_unmap>
  80170f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801712:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801718:	89 de                	mov    %ebx,%esi
  80171a:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  80171d:	0f 87 23 ff ff ff    	ja     801646 <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801723:	b8 00 00 00 00       	mov    $0x0,%eax
  801728:	eb 05                	jmp    80172f <map_segment+0x123>
  80172a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	57                   	push   %edi
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	83 ec 2c             	sub    $0x2c,%esp
  801740:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801743:	89 d7                	mov    %edx,%edi
  801745:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801748:	8b 02                	mov    (%edx),%eax
  80174a:	85 c0                	test   %eax,%eax
  80174c:	74 31                	je     80177f <init_stack+0x48>
  80174e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801753:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	50                   	push   %eax
  80175c:	e8 7b f0 ff ff       	call   8007dc <strlen>
  801761:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801765:	43                   	inc    %ebx
  801766:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80176d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	75 e1                	jne    801758 <init_stack+0x21>
  801777:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80177a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80177d:	eb 18                	jmp    801797 <init_stack+0x60>
  80177f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801786:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80178d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801792:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801797:	f7 de                	neg    %esi
  801799:	81 c6 00 10 40 00    	add    $0x401000,%esi
  80179f:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	83 e2 fc             	and    $0xfffffffc,%edx
  8017a7:	89 d8                	mov    %ebx,%eax
  8017a9:	f7 d0                	not    %eax
  8017ab:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8017ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017b1:	83 e8 08             	sub    $0x8,%eax
  8017b4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017b9:	0f 86 fb 00 00 00    	jbe    8018ba <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	6a 07                	push   $0x7
  8017c4:	68 00 00 40 00       	push   $0x400000
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 e0 f4 ff ff       	call   800cb0 <sys_page_alloc>
  8017d0:	89 c6                	mov    %eax,%esi
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	0f 88 e9 00 00 00    	js     8018c6 <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017dd:	85 db                	test   %ebx,%ebx
  8017df:	7e 3e                	jle    80181f <init_stack+0xe8>
  8017e1:	be 00 00 00 00       	mov    $0x0,%esi
  8017e6:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8017e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8017ec:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  8017f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017f5:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	ff 34 b7             	pushl  (%edi,%esi,4)
  8017fe:	53                   	push   %ebx
  8017ff:	e8 2a f0 ff ff       	call   80082e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801804:	83 c4 04             	add    $0x4,%esp
  801807:	ff 34 b7             	pushl  (%edi,%esi,4)
  80180a:	e8 cd ef ff ff       	call   8007dc <strlen>
  80180f:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801813:	46                   	inc    %esi
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  80181a:	7c d0                	jl     8017ec <init_stack+0xb5>
  80181c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80181f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801822:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801825:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80182c:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801833:	74 19                	je     80184e <init_stack+0x117>
  801835:	68 98 2c 80 00       	push   $0x802c98
  80183a:	68 df 2b 80 00       	push   $0x802bdf
  80183f:	68 51 01 00 00       	push   $0x151
  801844:	68 28 2c 80 00       	push   $0x802c28
  801849:	e8 52 e9 ff ff       	call   8001a0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80184e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801851:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801856:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801859:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80185c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80185f:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801862:	89 d0                	mov    %edx,%eax
  801864:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801869:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80186c:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	6a 07                	push   $0x7
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	ff 75 d8             	pushl  -0x28(%ebp)
  801879:	68 00 00 40 00       	push   $0x400000
  80187e:	6a 00                	push   $0x0
  801880:	e8 4f f4 ff ff       	call   800cd4 <sys_page_map>
  801885:	89 c6                	mov    %eax,%esi
  801887:	83 c4 20             	add    $0x20,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 18                	js     8018a6 <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	68 00 00 40 00       	push   $0x400000
  801896:	6a 00                	push   $0x0
  801898:	e8 5d f4 ff ff       	call   800cfa <sys_page_unmap>
  80189d:	89 c6                	mov    %eax,%esi
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	79 1b                	jns    8018c1 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	68 00 00 40 00       	push   $0x400000
  8018ae:	6a 00                	push   $0x0
  8018b0:	e8 45 f4 ff ff       	call   800cfa <sys_page_unmap>
	return r;
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 0c                	jmp    8018c6 <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8018ba:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  8018bf:	eb 05                	jmp    8018c6 <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  8018c1:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  8018c6:	89 f0                	mov    %esi,%eax
  8018c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018dc:	6a 00                	push   $0x0
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 96 fc ff ff       	call   80157c <open>
  8018e6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	0f 88 3f 02 00 00    	js     801b36 <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018f7:	83 ec 04             	sub    $0x4,%esp
  8018fa:	68 00 02 00 00       	push   $0x200
  8018ff:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80190c:	e8 ee f8 ff ff       	call   8011ff <readn>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	3d 00 02 00 00       	cmp    $0x200,%eax
  801919:	75 0c                	jne    801927 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80191b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801922:	45 4c 46 
  801925:	74 38                	je     80195f <spawn+0x8f>
		close(fd);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801930:	e8 06 f7 ff ff       	call   80103b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801935:	83 c4 0c             	add    $0xc,%esp
  801938:	68 7f 45 4c 46       	push   $0x464c457f
  80193d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801943:	68 34 2c 80 00       	push   $0x802c34
  801948:	e8 2b e9 ff ff       	call   800278 <cprintf>
		return -E_NOT_EXEC;
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801957:	ff ff ff 
  80195a:	e9 eb 01 00 00       	jmp    801b4a <spawn+0x27a>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80195f:	ba 07 00 00 00       	mov    $0x7,%edx
  801964:	89 d0                	mov    %edx,%eax
  801966:	cd 30                	int    $0x30
  801968:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80196e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801974:	85 c0                	test   %eax,%eax
  801976:	0f 88 ce 01 00 00    	js     801b4a <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80197c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801981:	89 c2                	mov    %eax,%edx
  801983:	c1 e2 07             	shl    $0x7,%edx
  801986:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  80198d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801993:	b9 11 00 00 00       	mov    $0x11,%ecx
  801998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80199a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019a0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  8019af:	68 00 d0 bf ee       	push   $0xeebfd000
  8019b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b7:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8019bd:	e8 75 fd ff ff       	call   801737 <init_stack>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	0f 88 77 01 00 00    	js     801b44 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8019cd:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019d3:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8019da:	00 
  8019db:	74 5d                	je     801a3a <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8019dd:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019e4:	be 00 00 00 00       	mov    $0x0,%esi
  8019e9:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  8019ef:	83 3b 01             	cmpl   $0x1,(%ebx)
  8019f2:	75 35                	jne    801a29 <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019f4:	8b 43 18             	mov    0x18(%ebx),%eax
  8019f7:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8019fa:	83 f8 01             	cmp    $0x1,%eax
  8019fd:	19 c0                	sbb    %eax,%eax
  8019ff:	83 e0 fe             	and    $0xfffffffe,%eax
  801a02:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a05:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801a08:	8b 53 08             	mov    0x8(%ebx),%edx
  801a0b:	50                   	push   %eax
  801a0c:	ff 73 04             	pushl  0x4(%ebx)
  801a0f:	ff 73 10             	pushl  0x10(%ebx)
  801a12:	57                   	push   %edi
  801a13:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a19:	e8 ee fb ff ff       	call   80160c <map_segment>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 88 e4 00 00 00    	js     801b0d <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a29:	46                   	inc    %esi
  801a2a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a31:	39 f0                	cmp    %esi,%eax
  801a33:	7e 05                	jle    801a3a <spawn+0x16a>
  801a35:	83 c3 20             	add    $0x20,%ebx
  801a38:	eb b5                	jmp    8019ef <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a43:	e8 f3 f5 ff ff       	call   80103b <close>
  801a48:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801a4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a50:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801a56:	89 d8                	mov    %ebx,%eax
  801a58:	c1 e8 16             	shr    $0x16,%eax
  801a5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a62:	a8 01                	test   $0x1,%al
  801a64:	74 3e                	je     801aa4 <spawn+0x1d4>
  801a66:	89 d8                	mov    %ebx,%eax
  801a68:	c1 e8 0c             	shr    $0xc,%eax
  801a6b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a72:	f6 c2 01             	test   $0x1,%dl
  801a75:	74 2d                	je     801aa4 <spawn+0x1d4>
  801a77:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a7e:	f6 c6 04             	test   $0x4,%dh
  801a81:	74 21                	je     801aa4 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801a83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	25 07 0e 00 00       	and    $0xe07,%eax
  801a92:	50                   	push   %eax
  801a93:	53                   	push   %ebx
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	6a 00                	push   $0x0
  801a98:	e8 37 f2 ff ff       	call   800cd4 <sys_page_map>
        if (r < 0) return r;
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 13                	js     801ab7 <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801aa4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aaa:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ab0:	75 a4                	jne    801a56 <spawn+0x186>
  801ab2:	e9 a1 00 00 00       	jmp    801b58 <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ab7:	50                   	push   %eax
  801ab8:	68 4e 2c 80 00       	push   $0x802c4e
  801abd:	68 85 00 00 00       	push   $0x85
  801ac2:	68 28 2c 80 00       	push   $0x802c28
  801ac7:	e8 d4 e6 ff ff       	call   8001a0 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801acc:	50                   	push   %eax
  801acd:	68 64 2c 80 00       	push   $0x802c64
  801ad2:	68 88 00 00 00       	push   $0x88
  801ad7:	68 28 2c 80 00       	push   $0x802c28
  801adc:	e8 bf e6 ff ff       	call   8001a0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	6a 02                	push   $0x2
  801ae6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801aec:	e8 2c f2 ff ff       	call   800d1d <sys_env_set_status>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	79 52                	jns    801b4a <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  801af8:	50                   	push   %eax
  801af9:	68 7e 2c 80 00       	push   $0x802c7e
  801afe:	68 8b 00 00 00       	push   $0x8b
  801b03:	68 28 2c 80 00       	push   $0x802c28
  801b08:	e8 93 e6 ff ff       	call   8001a0 <_panic>
  801b0d:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b18:	e8 26 f1 ff ff       	call   800c43 <sys_env_destroy>
	close(fd);
  801b1d:	83 c4 04             	add    $0x4,%esp
  801b20:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b26:	e8 10 f5 ff ff       	call   80103b <close>
	return r;
  801b2b:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b2e:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801b34:	eb 14                	jmp    801b4a <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b36:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b3c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b42:	eb 06                	jmp    801b4a <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801b44:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b4a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b61:	50                   	push   %eax
  801b62:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b68:	e8 d3 f1 ff ff       	call   800d40 <sys_env_set_trapframe>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 89 69 ff ff ff    	jns    801ae1 <spawn+0x211>
  801b78:	e9 4f ff ff ff       	jmp    801acc <spawn+0x1fc>

00801b7d <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	57                   	push   %edi
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801b89:	6a 00                	push   $0x0
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 e9 f9 ff ff       	call   80157c <open>
  801b93:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	0f 88 a9 01 00 00    	js     801d4d <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801ba4:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801baa:	83 ec 04             	sub    $0x4,%esp
  801bad:	68 00 02 00 00       	push   $0x200
  801bb2:	57                   	push   %edi
  801bb3:	50                   	push   %eax
  801bb4:	e8 46 f6 ff ff       	call   8011ff <readn>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bc1:	75 0c                	jne    801bcf <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801bc3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801bca:	45 4c 46 
  801bcd:	74 34                	je     801c03 <exec+0x86>
		close(fd);
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801bd8:	e8 5e f4 ff ff       	call   80103b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801bdd:	83 c4 0c             	add    $0xc,%esp
  801be0:	68 7f 45 4c 46       	push   $0x464c457f
  801be5:	ff 37                	pushl  (%edi)
  801be7:	68 34 2c 80 00       	push   $0x802c34
  801bec:	e8 87 e6 ff ff       	call   800278 <cprintf>
		return -E_NOT_EXEC;
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801bfb:	ff ff ff 
  801bfe:	e9 4a 01 00 00       	jmp    801d4d <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c03:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c06:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801c0b:	0f 84 8b 00 00 00    	je     801c9c <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c11:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801c18:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801c1f:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c22:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801c27:	83 3b 01             	cmpl   $0x1,(%ebx)
  801c2a:	75 62                	jne    801c8e <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c2c:	8b 43 18             	mov    0x18(%ebx),%eax
  801c2f:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c32:	83 f8 01             	cmp    $0x1,%eax
  801c35:	19 c0                	sbb    %eax,%eax
  801c37:	83 e0 fe             	and    $0xfffffffe,%eax
  801c3a:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801c3d:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801c40:	8b 53 08             	mov    0x8(%ebx),%edx
  801c43:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801c49:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801c4f:	50                   	push   %eax
  801c50:	ff 73 04             	pushl  0x4(%ebx)
  801c53:	ff 73 10             	pushl  0x10(%ebx)
  801c56:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c61:	e8 a6 f9 ff ff       	call   80160c <map_segment>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 a3 00 00 00    	js     801d14 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801c71:	8b 53 14             	mov    0x14(%ebx),%edx
  801c74:	8b 43 08             	mov    0x8(%ebx),%eax
  801c77:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c7c:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801c83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c88:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c8e:	46                   	inc    %esi
  801c8f:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801c93:	39 f0                	cmp    %esi,%eax
  801c95:	7e 0f                	jle    801ca6 <exec+0x129>
  801c97:	83 c3 20             	add    $0x20,%ebx
  801c9a:	eb 8b                	jmp    801c27 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801c9c:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801ca3:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801caf:	e8 87 f3 ff ff       	call   80103b <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801cb4:	83 c4 04             	add    $0x4,%esp
  801cb7:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801cbd:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801cc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccb:	e8 67 fa ff ff       	call   801737 <init_stack>
  801cd0:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	78 70                	js     801d4d <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801cdd:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801ce1:	50                   	push   %eax
  801ce2:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ce8:	03 47 1c             	add    0x1c(%edi),%eax
  801ceb:	50                   	push   %eax
  801cec:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801cf2:	ff 77 18             	pushl  0x18(%edi)
  801cf5:	e8 f6 f0 ff ff       	call   800df0 <sys_exec>
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	79 42                	jns    801d43 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801d01:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801d07:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801d0d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801d12:	eb 0c                	jmp    801d20 <exec+0x1a3>
  801d14:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801d1a:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801d20:	83 ec 0c             	sub    $0xc,%esp
  801d23:	6a 00                	push   $0x0
  801d25:	e8 19 ef ff ff       	call   800c43 <sys_env_destroy>
	close(fd);
  801d2a:	89 1c 24             	mov    %ebx,(%esp)
  801d2d:	e8 09 f3 ff ff       	call   80103b <close>
	return r;
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801d3b:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801d41:	eb 0a                	jmp    801d4d <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801d43:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801d4a:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801d4d:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d56:	5b                   	pop    %ebx
  801d57:	5e                   	pop    %esi
  801d58:	5f                   	pop    %edi
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d63:	8d 45 14             	lea    0x14(%ebp),%eax
  801d66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6a:	74 5f                	je     801dcb <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d71:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	83 c0 04             	add    $0x4,%eax
  801d77:	83 3a 00             	cmpl   $0x0,(%edx)
  801d7a:	75 f5                	jne    801d71 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d7c:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d83:	83 e0 f0             	and    $0xfffffff0,%eax
  801d86:	29 c4                	sub    %eax,%esp
  801d88:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d8c:	83 e0 f0             	and    $0xfffffff0,%eax
  801d8f:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d91:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d93:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801d9a:	00 

	va_start(vl, arg0);
  801d9b:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d9e:	89 ce                	mov    %ecx,%esi
  801da0:	85 c9                	test   %ecx,%ecx
  801da2:	74 14                	je     801db8 <execl+0x5d>
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801da9:	40                   	inc    %eax
  801daa:	89 d1                	mov    %edx,%ecx
  801dac:	83 c2 04             	add    $0x4,%edx
  801daf:	8b 09                	mov    (%ecx),%ecx
  801db1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801db4:	39 f0                	cmp    %esi,%eax
  801db6:	72 f1                	jb     801da9 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  801db8:	83 ec 08             	sub    $0x8,%esp
  801dbb:	53                   	push   %ebx
  801dbc:	ff 75 08             	pushl  0x8(%ebp)
  801dbf:	e8 b9 fd ff ff       	call   801b7d <exec>
}
  801dc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dcb:	83 ec 20             	sub    $0x20,%esp
  801dce:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801dd2:	83 e0 f0             	and    $0xfffffff0,%eax
  801dd5:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801dd7:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801dd9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801de0:	eb d6                	jmp    801db8 <execl+0x5d>

00801de2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	56                   	push   %esi
  801de6:	53                   	push   %ebx
  801de7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dea:	8d 45 14             	lea    0x14(%ebp),%eax
  801ded:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df1:	74 5f                	je     801e52 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801df3:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801df8:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	83 c0 04             	add    $0x4,%eax
  801dfe:	83 3a 00             	cmpl   $0x0,(%edx)
  801e01:	75 f5                	jne    801df8 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e03:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801e0a:	83 e0 f0             	and    $0xfffffff0,%eax
  801e0d:	29 c4                	sub    %eax,%esp
  801e0f:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e13:	83 e0 f0             	and    $0xfffffff0,%eax
  801e16:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e18:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e1a:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801e21:	00 

	va_start(vl, arg0);
  801e22:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801e25:	89 ce                	mov    %ecx,%esi
  801e27:	85 c9                	test   %ecx,%ecx
  801e29:	74 14                	je     801e3f <spawnl+0x5d>
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801e30:	40                   	inc    %eax
  801e31:	89 d1                	mov    %edx,%ecx
  801e33:	83 c2 04             	add    $0x4,%edx
  801e36:	8b 09                	mov    (%ecx),%ecx
  801e38:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e3b:	39 f0                	cmp    %esi,%eax
  801e3d:	72 f1                	jb     801e30 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	53                   	push   %ebx
  801e43:	ff 75 08             	pushl  0x8(%ebp)
  801e46:	e8 85 fa ff ff       	call   8018d0 <spawn>
}
  801e4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e52:	83 ec 20             	sub    $0x20,%esp
  801e55:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e59:	83 e0 f0             	and    $0xfffffff0,%eax
  801e5c:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e5e:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e60:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801e67:	eb d6                	jmp    801e3f <spawnl+0x5d>
  801e69:	00 00                	add    %al,(%eax)
	...

00801e6c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	ff 75 08             	pushl  0x8(%ebp)
  801e7a:	e8 ed ef ff ff       	call   800e6c <fd2data>
  801e7f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e81:	83 c4 08             	add    $0x8,%esp
  801e84:	68 c0 2c 80 00       	push   $0x802cc0
  801e89:	56                   	push   %esi
  801e8a:	e8 9f e9 ff ff       	call   80082e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e92:	2b 03                	sub    (%ebx),%eax
  801e94:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e9a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ea1:	00 00 00 
	stat->st_dev = &devpipe;
  801ea4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801eab:	30 80 00 
	return 0;
}
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ec4:	53                   	push   %ebx
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 2e ee ff ff       	call   800cfa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ecc:	89 1c 24             	mov    %ebx,(%esp)
  801ecf:	e8 98 ef ff ff       	call   800e6c <fd2data>
  801ed4:	83 c4 08             	add    $0x8,%esp
  801ed7:	50                   	push   %eax
  801ed8:	6a 00                	push   $0x0
  801eda:	e8 1b ee ff ff       	call   800cfa <sys_page_unmap>
}
  801edf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 1c             	sub    $0x1c,%esp
  801eed:	89 c7                	mov    %eax,%edi
  801eef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	57                   	push   %edi
  801efe:	e8 85 05 00 00       	call   802488 <pageref>
  801f03:	89 c6                	mov    %eax,%esi
  801f05:	83 c4 04             	add    $0x4,%esp
  801f08:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f0b:	e8 78 05 00 00       	call   802488 <pageref>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	39 c6                	cmp    %eax,%esi
  801f15:	0f 94 c0             	sete   %al
  801f18:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f1b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f21:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f24:	39 cb                	cmp    %ecx,%ebx
  801f26:	75 08                	jne    801f30 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5e                   	pop    %esi
  801f2d:	5f                   	pop    %edi
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f30:	83 f8 01             	cmp    $0x1,%eax
  801f33:	75 bd                	jne    801ef2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f35:	8b 42 58             	mov    0x58(%edx),%eax
  801f38:	6a 01                	push   $0x1
  801f3a:	50                   	push   %eax
  801f3b:	53                   	push   %ebx
  801f3c:	68 c7 2c 80 00       	push   $0x802cc7
  801f41:	e8 32 e3 ff ff       	call   800278 <cprintf>
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	eb a7                	jmp    801ef2 <_pipeisclosed+0xe>

00801f4b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	57                   	push   %edi
  801f4f:	56                   	push   %esi
  801f50:	53                   	push   %ebx
  801f51:	83 ec 28             	sub    $0x28,%esp
  801f54:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f57:	56                   	push   %esi
  801f58:	e8 0f ef ff ff       	call   800e6c <fd2data>
  801f5d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f66:	75 4a                	jne    801fb2 <devpipe_write+0x67>
  801f68:	bf 00 00 00 00       	mov    $0x0,%edi
  801f6d:	eb 56                	jmp    801fc5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f6f:	89 da                	mov    %ebx,%edx
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	e8 6c ff ff ff       	call   801ee4 <_pipeisclosed>
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	75 4d                	jne    801fc9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f7c:	e8 08 ed ff ff       	call   800c89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f81:	8b 43 04             	mov    0x4(%ebx),%eax
  801f84:	8b 13                	mov    (%ebx),%edx
  801f86:	83 c2 20             	add    $0x20,%edx
  801f89:	39 d0                	cmp    %edx,%eax
  801f8b:	73 e2                	jae    801f6f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f8d:	89 c2                	mov    %eax,%edx
  801f8f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f95:	79 05                	jns    801f9c <devpipe_write+0x51>
  801f97:	4a                   	dec    %edx
  801f98:	83 ca e0             	or     $0xffffffe0,%edx
  801f9b:	42                   	inc    %edx
  801f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f9f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801fa2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa6:	40                   	inc    %eax
  801fa7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801faa:	47                   	inc    %edi
  801fab:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801fae:	77 07                	ja     801fb7 <devpipe_write+0x6c>
  801fb0:	eb 13                	jmp    801fc5 <devpipe_write+0x7a>
  801fb2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801fba:	8b 13                	mov    (%ebx),%edx
  801fbc:	83 c2 20             	add    $0x20,%edx
  801fbf:	39 d0                	cmp    %edx,%eax
  801fc1:	73 ac                	jae    801f6f <devpipe_write+0x24>
  801fc3:	eb c8                	jmp    801f8d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	eb 05                	jmp    801fce <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	57                   	push   %edi
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 18             	sub    $0x18,%esp
  801fdf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe2:	57                   	push   %edi
  801fe3:	e8 84 ee ff ff       	call   800e6c <fd2data>
  801fe8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff1:	75 44                	jne    802037 <devpipe_read+0x61>
  801ff3:	be 00 00 00 00       	mov    $0x0,%esi
  801ff8:	eb 4f                	jmp    802049 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ffa:	89 f0                	mov    %esi,%eax
  801ffc:	eb 54                	jmp    802052 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ffe:	89 da                	mov    %ebx,%edx
  802000:	89 f8                	mov    %edi,%eax
  802002:	e8 dd fe ff ff       	call   801ee4 <_pipeisclosed>
  802007:	85 c0                	test   %eax,%eax
  802009:	75 42                	jne    80204d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80200b:	e8 79 ec ff ff       	call   800c89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802010:	8b 03                	mov    (%ebx),%eax
  802012:	3b 43 04             	cmp    0x4(%ebx),%eax
  802015:	74 e7                	je     801ffe <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802017:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80201c:	79 05                	jns    802023 <devpipe_read+0x4d>
  80201e:	48                   	dec    %eax
  80201f:	83 c8 e0             	or     $0xffffffe0,%eax
  802022:	40                   	inc    %eax
  802023:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802027:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80202d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202f:	46                   	inc    %esi
  802030:	39 75 10             	cmp    %esi,0x10(%ebp)
  802033:	77 07                	ja     80203c <devpipe_read+0x66>
  802035:	eb 12                	jmp    802049 <devpipe_read+0x73>
  802037:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80203c:	8b 03                	mov    (%ebx),%eax
  80203e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802041:	75 d4                	jne    802017 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802043:	85 f6                	test   %esi,%esi
  802045:	75 b3                	jne    801ffa <devpipe_read+0x24>
  802047:	eb b5                	jmp    801ffe <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802049:	89 f0                	mov    %esi,%eax
  80204b:	eb 05                	jmp    802052 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 28             	sub    $0x28,%esp
  802063:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802066:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	e8 15 ee ff ff       	call   800e84 <fd_alloc>
  80206f:	89 c3                	mov    %eax,%ebx
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	0f 88 24 01 00 00    	js     8021a0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207c:	83 ec 04             	sub    $0x4,%esp
  80207f:	68 07 04 00 00       	push   $0x407
  802084:	ff 75 e4             	pushl  -0x1c(%ebp)
  802087:	6a 00                	push   $0x0
  802089:	e8 22 ec ff ff       	call   800cb0 <sys_page_alloc>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 05 01 00 00    	js     8021a0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80209b:	83 ec 0c             	sub    $0xc,%esp
  80209e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020a1:	50                   	push   %eax
  8020a2:	e8 dd ed ff ff       	call   800e84 <fd_alloc>
  8020a7:	89 c3                	mov    %eax,%ebx
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	0f 88 dc 00 00 00    	js     802190 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b4:	83 ec 04             	sub    $0x4,%esp
  8020b7:	68 07 04 00 00       	push   $0x407
  8020bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8020bf:	6a 00                	push   $0x0
  8020c1:	e8 ea eb ff ff       	call   800cb0 <sys_page_alloc>
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	0f 88 bd 00 00 00    	js     802190 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020d9:	e8 8e ed ff ff       	call   800e6c <fd2data>
  8020de:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e0:	83 c4 0c             	add    $0xc,%esp
  8020e3:	68 07 04 00 00       	push   $0x407
  8020e8:	50                   	push   %eax
  8020e9:	6a 00                	push   $0x0
  8020eb:	e8 c0 eb ff ff       	call   800cb0 <sys_page_alloc>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	0f 88 83 00 00 00    	js     802180 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	ff 75 e0             	pushl  -0x20(%ebp)
  802103:	e8 64 ed ff ff       	call   800e6c <fd2data>
  802108:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80210f:	50                   	push   %eax
  802110:	6a 00                	push   $0x0
  802112:	56                   	push   %esi
  802113:	6a 00                	push   $0x0
  802115:	e8 ba eb ff ff       	call   800cd4 <sys_page_map>
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	83 c4 20             	add    $0x20,%esp
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 4f                	js     802172 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802123:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80212e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802131:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802138:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80213e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802141:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802143:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802146:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80214d:	83 ec 0c             	sub    $0xc,%esp
  802150:	ff 75 e4             	pushl  -0x1c(%ebp)
  802153:	e8 04 ed ff ff       	call   800e5c <fd2num>
  802158:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80215a:	83 c4 04             	add    $0x4,%esp
  80215d:	ff 75 e0             	pushl  -0x20(%ebp)
  802160:	e8 f7 ec ff ff       	call   800e5c <fd2num>
  802165:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802170:	eb 2e                	jmp    8021a0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802172:	83 ec 08             	sub    $0x8,%esp
  802175:	56                   	push   %esi
  802176:	6a 00                	push   $0x0
  802178:	e8 7d eb ff ff       	call   800cfa <sys_page_unmap>
  80217d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802180:	83 ec 08             	sub    $0x8,%esp
  802183:	ff 75 e0             	pushl  -0x20(%ebp)
  802186:	6a 00                	push   $0x0
  802188:	e8 6d eb ff ff       	call   800cfa <sys_page_unmap>
  80218d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	ff 75 e4             	pushl  -0x1c(%ebp)
  802196:	6a 00                	push   $0x0
  802198:	e8 5d eb ff ff       	call   800cfa <sys_page_unmap>
  80219d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5f                   	pop    %edi
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	ff 75 08             	pushl  0x8(%ebp)
  8021b7:	e8 3b ed ff ff       	call   800ef7 <fd_lookup>
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	78 18                	js     8021db <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021c3:	83 ec 0c             	sub    $0xc,%esp
  8021c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c9:	e8 9e ec ff ff       	call   800e6c <fd2data>
	return _pipeisclosed(fd, p);
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d3:	e8 0c fd ff ff       	call   801ee4 <_pipeisclosed>
  8021d8:	83 c4 10             	add    $0x10,%esp
}
  8021db:	c9                   	leave  
  8021dc:	c3                   	ret    
  8021dd:	00 00                	add    %al,(%eax)
	...

008021e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e8:	c9                   	leave  
  8021e9:	c3                   	ret    

008021ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021ea:	55                   	push   %ebp
  8021eb:	89 e5                	mov    %esp,%ebp
  8021ed:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021f0:	68 df 2c 80 00       	push   $0x802cdf
  8021f5:	ff 75 0c             	pushl  0xc(%ebp)
  8021f8:	e8 31 e6 ff ff       	call   80082e <strcpy>
	return 0;
}
  8021fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	57                   	push   %edi
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802210:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802214:	74 45                	je     80225b <devcons_write+0x57>
  802216:	b8 00 00 00 00       	mov    $0x0,%eax
  80221b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802220:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802226:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802229:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80222b:	83 fb 7f             	cmp    $0x7f,%ebx
  80222e:	76 05                	jbe    802235 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802230:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802235:	83 ec 04             	sub    $0x4,%esp
  802238:	53                   	push   %ebx
  802239:	03 45 0c             	add    0xc(%ebp),%eax
  80223c:	50                   	push   %eax
  80223d:	57                   	push   %edi
  80223e:	e8 ac e7 ff ff       	call   8009ef <memmove>
		sys_cputs(buf, m);
  802243:	83 c4 08             	add    $0x8,%esp
  802246:	53                   	push   %ebx
  802247:	57                   	push   %edi
  802248:	e8 ac e9 ff ff       	call   800bf9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80224d:	01 de                	add    %ebx,%esi
  80224f:	89 f0                	mov    %esi,%eax
  802251:	83 c4 10             	add    $0x10,%esp
  802254:	3b 75 10             	cmp    0x10(%ebp),%esi
  802257:	72 cd                	jb     802226 <devcons_write+0x22>
  802259:	eb 05                	jmp    802260 <devcons_write+0x5c>
  80225b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802260:	89 f0                	mov    %esi,%eax
  802262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802270:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802274:	75 07                	jne    80227d <devcons_read+0x13>
  802276:	eb 25                	jmp    80229d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802278:	e8 0c ea ff ff       	call   800c89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80227d:	e8 9d e9 ff ff       	call   800c1f <sys_cgetc>
  802282:	85 c0                	test   %eax,%eax
  802284:	74 f2                	je     802278 <devcons_read+0xe>
  802286:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802288:	85 c0                	test   %eax,%eax
  80228a:	78 1d                	js     8022a9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80228c:	83 f8 04             	cmp    $0x4,%eax
  80228f:	74 13                	je     8022a4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802291:	8b 45 0c             	mov    0xc(%ebp),%eax
  802294:	88 10                	mov    %dl,(%eax)
	return 1;
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	eb 0c                	jmp    8022a9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80229d:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a2:	eb 05                	jmp    8022a9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022b7:	6a 01                	push   $0x1
  8022b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022bc:	50                   	push   %eax
  8022bd:	e8 37 e9 ff ff       	call   800bf9 <sys_cputs>
  8022c2:	83 c4 10             	add    $0x10,%esp
}
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    

008022c7 <getchar>:

int
getchar(void)
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022cd:	6a 01                	push   $0x1
  8022cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d2:	50                   	push   %eax
  8022d3:	6a 00                	push   $0x0
  8022d5:	e8 9e ee ff ff       	call   801178 <read>
	if (r < 0)
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 0f                	js     8022f0 <getchar+0x29>
		return r;
	if (r < 1)
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	7e 06                	jle    8022eb <getchar+0x24>
		return -E_EOF;
	return c;
  8022e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e9:	eb 05                	jmp    8022f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fb:	50                   	push   %eax
  8022fc:	ff 75 08             	pushl  0x8(%ebp)
  8022ff:	e8 f3 eb ff ff       	call   800ef7 <fd_lookup>
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	85 c0                	test   %eax,%eax
  802309:	78 11                	js     80231c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802314:	39 10                	cmp    %edx,(%eax)
  802316:	0f 94 c0             	sete   %al
  802319:	0f b6 c0             	movzbl %al,%eax
}
  80231c:	c9                   	leave  
  80231d:	c3                   	ret    

0080231e <opencons>:

int
opencons(void)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802327:	50                   	push   %eax
  802328:	e8 57 eb ff ff       	call   800e84 <fd_alloc>
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	85 c0                	test   %eax,%eax
  802332:	78 3a                	js     80236e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802334:	83 ec 04             	sub    $0x4,%esp
  802337:	68 07 04 00 00       	push   $0x407
  80233c:	ff 75 f4             	pushl  -0xc(%ebp)
  80233f:	6a 00                	push   $0x0
  802341:	e8 6a e9 ff ff       	call   800cb0 <sys_page_alloc>
  802346:	83 c4 10             	add    $0x10,%esp
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 21                	js     80236e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802356:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802362:	83 ec 0c             	sub    $0xc,%esp
  802365:	50                   	push   %eax
  802366:	e8 f1 ea ff ff       	call   800e5c <fd2num>
  80236b:	83 c4 10             	add    $0x10,%esp
}
  80236e:	c9                   	leave  
  80236f:	c3                   	ret    

00802370 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	56                   	push   %esi
  802374:	53                   	push   %ebx
  802375:	8b 75 08             	mov    0x8(%ebp),%esi
  802378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  80237e:	85 c0                	test   %eax,%eax
  802380:	74 0e                	je     802390 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  802382:	83 ec 0c             	sub    $0xc,%esp
  802385:	50                   	push   %eax
  802386:	e8 20 ea ff ff       	call   800dab <sys_ipc_recv>
  80238b:	83 c4 10             	add    $0x10,%esp
  80238e:	eb 10                	jmp    8023a0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802390:	83 ec 0c             	sub    $0xc,%esp
  802393:	68 00 00 c0 ee       	push   $0xeec00000
  802398:	e8 0e ea ff ff       	call   800dab <sys_ipc_recv>
  80239d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	75 26                	jne    8023ca <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8023a4:	85 f6                	test   %esi,%esi
  8023a6:	74 0a                	je     8023b2 <ipc_recv+0x42>
  8023a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8023ad:	8b 40 74             	mov    0x74(%eax),%eax
  8023b0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8023b2:	85 db                	test   %ebx,%ebx
  8023b4:	74 0a                	je     8023c0 <ipc_recv+0x50>
  8023b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8023bb:	8b 40 78             	mov    0x78(%eax),%eax
  8023be:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8023c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8023c5:	8b 40 70             	mov    0x70(%eax),%eax
  8023c8:	eb 14                	jmp    8023de <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8023ca:	85 f6                	test   %esi,%esi
  8023cc:	74 06                	je     8023d4 <ipc_recv+0x64>
  8023ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8023d4:	85 db                	test   %ebx,%ebx
  8023d6:	74 06                	je     8023de <ipc_recv+0x6e>
  8023d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8023de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	c9                   	leave  
  8023e4:	c3                   	ret    

008023e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	57                   	push   %edi
  8023e9:	56                   	push   %esi
  8023ea:	53                   	push   %ebx
  8023eb:	83 ec 0c             	sub    $0xc,%esp
  8023ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023f4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8023f7:	85 db                	test   %ebx,%ebx
  8023f9:	75 25                	jne    802420 <ipc_send+0x3b>
  8023fb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802400:	eb 1e                	jmp    802420 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802402:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802405:	75 07                	jne    80240e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802407:	e8 7d e8 ff ff       	call   800c89 <sys_yield>
  80240c:	eb 12                	jmp    802420 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80240e:	50                   	push   %eax
  80240f:	68 eb 2c 80 00       	push   $0x802ceb
  802414:	6a 43                	push   $0x43
  802416:	68 fe 2c 80 00       	push   $0x802cfe
  80241b:	e8 80 dd ff ff       	call   8001a0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802420:	56                   	push   %esi
  802421:	53                   	push   %ebx
  802422:	57                   	push   %edi
  802423:	ff 75 08             	pushl  0x8(%ebp)
  802426:	e8 5b e9 ff ff       	call   800d86 <sys_ipc_try_send>
  80242b:	83 c4 10             	add    $0x10,%esp
  80242e:	85 c0                	test   %eax,%eax
  802430:	75 d0                	jne    802402 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802435:	5b                   	pop    %ebx
  802436:	5e                   	pop    %esi
  802437:	5f                   	pop    %edi
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802440:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  802446:	74 1a                	je     802462 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802448:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80244d:	89 c2                	mov    %eax,%edx
  80244f:	c1 e2 07             	shl    $0x7,%edx
  802452:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802459:	8b 52 50             	mov    0x50(%edx),%edx
  80245c:	39 ca                	cmp    %ecx,%edx
  80245e:	75 18                	jne    802478 <ipc_find_env+0x3e>
  802460:	eb 05                	jmp    802467 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802467:	89 c2                	mov    %eax,%edx
  802469:	c1 e2 07             	shl    $0x7,%edx
  80246c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  802473:	8b 40 40             	mov    0x40(%eax),%eax
  802476:	eb 0c                	jmp    802484 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802478:	40                   	inc    %eax
  802479:	3d 00 04 00 00       	cmp    $0x400,%eax
  80247e:	75 cd                	jne    80244d <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802480:	66 b8 00 00          	mov    $0x0,%ax
}
  802484:	c9                   	leave  
  802485:	c3                   	ret    
	...

00802488 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248e:	89 c2                	mov    %eax,%edx
  802490:	c1 ea 16             	shr    $0x16,%edx
  802493:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80249a:	f6 c2 01             	test   $0x1,%dl
  80249d:	74 1e                	je     8024bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80249f:	c1 e8 0c             	shr    $0xc,%eax
  8024a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024a9:	a8 01                	test   $0x1,%al
  8024ab:	74 17                	je     8024c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024ad:	c1 e8 0c             	shr    $0xc,%eax
  8024b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024b7:	ef 
  8024b8:	0f b7 c0             	movzwl %ax,%eax
  8024bb:	eb 0c                	jmp    8024c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c2:	eb 05                	jmp    8024c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024c9:	c9                   	leave  
  8024ca:	c3                   	ret    
	...

008024cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	57                   	push   %edi
  8024d0:	56                   	push   %esi
  8024d1:	83 ec 10             	sub    $0x10,%esp
  8024d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024da:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8024dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8024e0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024e3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024e6:	85 c0                	test   %eax,%eax
  8024e8:	75 2e                	jne    802518 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024ea:	39 f1                	cmp    %esi,%ecx
  8024ec:	77 5a                	ja     802548 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024ee:	85 c9                	test   %ecx,%ecx
  8024f0:	75 0b                	jne    8024fd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f7:	31 d2                	xor    %edx,%edx
  8024f9:	f7 f1                	div    %ecx
  8024fb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	89 f0                	mov    %esi,%eax
  802501:	f7 f1                	div    %ecx
  802503:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802505:	89 f8                	mov    %edi,%eax
  802507:	f7 f1                	div    %ecx
  802509:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80250b:	89 f8                	mov    %edi,%eax
  80250d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80250f:	83 c4 10             	add    $0x10,%esp
  802512:	5e                   	pop    %esi
  802513:	5f                   	pop    %edi
  802514:	c9                   	leave  
  802515:	c3                   	ret    
  802516:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802518:	39 f0                	cmp    %esi,%eax
  80251a:	77 1c                	ja     802538 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80251c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80251f:	83 f7 1f             	xor    $0x1f,%edi
  802522:	75 3c                	jne    802560 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802524:	39 f0                	cmp    %esi,%eax
  802526:	0f 82 90 00 00 00    	jb     8025bc <__udivdi3+0xf0>
  80252c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80252f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802532:	0f 86 84 00 00 00    	jbe    8025bc <__udivdi3+0xf0>
  802538:	31 f6                	xor    %esi,%esi
  80253a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80253c:	89 f8                	mov    %edi,%eax
  80253e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802540:	83 c4 10             	add    $0x10,%esp
  802543:	5e                   	pop    %esi
  802544:	5f                   	pop    %edi
  802545:	c9                   	leave  
  802546:	c3                   	ret    
  802547:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802548:	89 f2                	mov    %esi,%edx
  80254a:	89 f8                	mov    %edi,%eax
  80254c:	f7 f1                	div    %ecx
  80254e:	89 c7                	mov    %eax,%edi
  802550:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802552:	89 f8                	mov    %edi,%eax
  802554:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	5e                   	pop    %esi
  80255a:	5f                   	pop    %edi
  80255b:	c9                   	leave  
  80255c:	c3                   	ret    
  80255d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802560:	89 f9                	mov    %edi,%ecx
  802562:	d3 e0                	shl    %cl,%eax
  802564:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802567:	b8 20 00 00 00       	mov    $0x20,%eax
  80256c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80256e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802571:	88 c1                	mov    %al,%cl
  802573:	d3 ea                	shr    %cl,%edx
  802575:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802578:	09 ca                	or     %ecx,%edx
  80257a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80257d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802580:	89 f9                	mov    %edi,%ecx
  802582:	d3 e2                	shl    %cl,%edx
  802584:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802587:	89 f2                	mov    %esi,%edx
  802589:	88 c1                	mov    %al,%cl
  80258b:	d3 ea                	shr    %cl,%edx
  80258d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802590:	89 f2                	mov    %esi,%edx
  802592:	89 f9                	mov    %edi,%ecx
  802594:	d3 e2                	shl    %cl,%edx
  802596:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802599:	88 c1                	mov    %al,%cl
  80259b:	d3 ee                	shr    %cl,%esi
  80259d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80259f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8025a2:	89 f0                	mov    %esi,%eax
  8025a4:	89 ca                	mov    %ecx,%edx
  8025a6:	f7 75 ec             	divl   -0x14(%ebp)
  8025a9:	89 d1                	mov    %edx,%ecx
  8025ab:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025ad:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025b0:	39 d1                	cmp    %edx,%ecx
  8025b2:	72 28                	jb     8025dc <__udivdi3+0x110>
  8025b4:	74 1a                	je     8025d0 <__udivdi3+0x104>
  8025b6:	89 f7                	mov    %esi,%edi
  8025b8:	31 f6                	xor    %esi,%esi
  8025ba:	eb 80                	jmp    80253c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025bc:	31 f6                	xor    %esi,%esi
  8025be:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025c3:	89 f8                	mov    %edi,%eax
  8025c5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025c7:	83 c4 10             	add    $0x10,%esp
  8025ca:	5e                   	pop    %esi
  8025cb:	5f                   	pop    %edi
  8025cc:	c9                   	leave  
  8025cd:	c3                   	ret    
  8025ce:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025d7:	39 c2                	cmp    %eax,%edx
  8025d9:	73 db                	jae    8025b6 <__udivdi3+0xea>
  8025db:	90                   	nop
		{
		  q0--;
  8025dc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025df:	31 f6                	xor    %esi,%esi
  8025e1:	e9 56 ff ff ff       	jmp    80253c <__udivdi3+0x70>
	...

008025e8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025e8:	55                   	push   %ebp
  8025e9:	89 e5                	mov    %esp,%ebp
  8025eb:	57                   	push   %edi
  8025ec:	56                   	push   %esi
  8025ed:	83 ec 20             	sub    $0x20,%esp
  8025f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8025f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8025fc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8025ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802602:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802605:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802607:	85 ff                	test   %edi,%edi
  802609:	75 15                	jne    802620 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80260b:	39 f1                	cmp    %esi,%ecx
  80260d:	0f 86 99 00 00 00    	jbe    8026ac <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802613:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802615:	89 d0                	mov    %edx,%eax
  802617:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802619:	83 c4 20             	add    $0x20,%esp
  80261c:	5e                   	pop    %esi
  80261d:	5f                   	pop    %edi
  80261e:	c9                   	leave  
  80261f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802620:	39 f7                	cmp    %esi,%edi
  802622:	0f 87 a4 00 00 00    	ja     8026cc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802628:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80262b:	83 f0 1f             	xor    $0x1f,%eax
  80262e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802631:	0f 84 a1 00 00 00    	je     8026d8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802637:	89 f8                	mov    %edi,%eax
  802639:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80263c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80263e:	bf 20 00 00 00       	mov    $0x20,%edi
  802643:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802649:	89 f9                	mov    %edi,%ecx
  80264b:	d3 ea                	shr    %cl,%edx
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802655:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802658:	d3 e0                	shl    %cl,%eax
  80265a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80265d:	89 f2                	mov    %esi,%edx
  80265f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802661:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802664:	d3 e0                	shl    %cl,%eax
  802666:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802669:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80266c:	89 f9                	mov    %edi,%ecx
  80266e:	d3 e8                	shr    %cl,%eax
  802670:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802672:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802674:	89 f2                	mov    %esi,%edx
  802676:	f7 75 f0             	divl   -0x10(%ebp)
  802679:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80267b:	f7 65 f4             	mull   -0xc(%ebp)
  80267e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802681:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802683:	39 d6                	cmp    %edx,%esi
  802685:	72 71                	jb     8026f8 <__umoddi3+0x110>
  802687:	74 7f                	je     802708 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80268c:	29 c8                	sub    %ecx,%eax
  80268e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802690:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802693:	d3 e8                	shr    %cl,%eax
  802695:	89 f2                	mov    %esi,%edx
  802697:	89 f9                	mov    %edi,%ecx
  802699:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80269b:	09 d0                	or     %edx,%eax
  80269d:	89 f2                	mov    %esi,%edx
  80269f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8026a2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026a4:	83 c4 20             	add    $0x20,%esp
  8026a7:	5e                   	pop    %esi
  8026a8:	5f                   	pop    %edi
  8026a9:	c9                   	leave  
  8026aa:	c3                   	ret    
  8026ab:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026ac:	85 c9                	test   %ecx,%ecx
  8026ae:	75 0b                	jne    8026bb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8026b5:	31 d2                	xor    %edx,%edx
  8026b7:	f7 f1                	div    %ecx
  8026b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026bb:	89 f0                	mov    %esi,%eax
  8026bd:	31 d2                	xor    %edx,%edx
  8026bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026c4:	f7 f1                	div    %ecx
  8026c6:	e9 4a ff ff ff       	jmp    802615 <__umoddi3+0x2d>
  8026cb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026cc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026ce:	83 c4 20             	add    $0x20,%esp
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	c9                   	leave  
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026d8:	39 f7                	cmp    %esi,%edi
  8026da:	72 05                	jb     8026e1 <__umoddi3+0xf9>
  8026dc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8026df:	77 0c                	ja     8026ed <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026e1:	89 f2                	mov    %esi,%edx
  8026e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026e6:	29 c8                	sub    %ecx,%eax
  8026e8:	19 fa                	sbb    %edi,%edx
  8026ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026f0:	83 c4 20             	add    $0x20,%esp
  8026f3:	5e                   	pop    %esi
  8026f4:	5f                   	pop    %edi
  8026f5:	c9                   	leave  
  8026f6:	c3                   	ret    
  8026f7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8026fb:	89 c1                	mov    %eax,%ecx
  8026fd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802700:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802703:	eb 84                	jmp    802689 <__umoddi3+0xa1>
  802705:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802708:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80270b:	72 eb                	jb     8026f8 <__umoddi3+0x110>
  80270d:	89 f2                	mov    %esi,%edx
  80270f:	e9 75 ff ff ff       	jmp    802689 <__umoddi3+0xa1>
