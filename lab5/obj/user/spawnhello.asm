
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 5b 00 00 00       	call   80008c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 40 26 80 00       	push   $0x802640
  800048:	e8 83 01 00 00       	call   8001d0 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004d:	83 c4 0c             	add    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	68 5e 26 80 00       	push   $0x80265e
  800057:	68 5e 26 80 00       	push   $0x80265e
  80005c:	e8 9b 1c 00 00       	call   801cfc <spawnl>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	85 c0                	test   %eax,%eax
  800066:	79 12                	jns    80007a <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800068:	50                   	push   %eax
  800069:	68 64 26 80 00       	push   $0x802664
  80006e:	6a 09                	push   $0x9
  800070:	68 7c 26 80 00       	push   $0x80267c
  800075:	e8 7e 00 00 00       	call   8000f8 <_panic>
	//if ((r = execl("hello", "hello", 0)) < 0)
	//	panic("spawn(hello) exec: %e", r);
	cprintf("I come back!\n");
  80007a:	83 ec 0c             	sub    $0xc,%esp
  80007d:	68 8e 26 80 00       	push   $0x80268e
  800082:	e8 49 01 00 00       	call   8001d0 <cprintf>
  800087:	83 c4 10             	add    $0x10,%esp
	
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 75 08             	mov    0x8(%ebp),%esi
  800094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800097:	e8 21 0b 00 00       	call   800bbd <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a8:	c1 e0 07             	shl    $0x7,%eax
  8000ab:	29 d0                	sub    %edx,%eax
  8000ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 f6                	test   %esi,%esi
  8000b9:	7e 07                	jle    8000c2 <libmain+0x36>
		binaryname = argv[0];
  8000bb:	8b 03                	mov    (%ebx),%eax
  8000bd:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	53                   	push   %ebx
  8000c6:	56                   	push   %esi
  8000c7:	e8 68 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
}
  8000d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e2:	e8 93 0e 00 00       	call   800f7a <close_all>
	sys_env_destroy(0);
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 aa 0a 00 00       	call   800b9b <sys_env_destroy>
  8000f1:	83 c4 10             	add    $0x10,%esp
}
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    
	...

008000f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000fd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800100:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800106:	e8 b2 0a 00 00       	call   800bbd <sys_getenvid>
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	ff 75 0c             	pushl  0xc(%ebp)
  800111:	ff 75 08             	pushl  0x8(%ebp)
  800114:	53                   	push   %ebx
  800115:	50                   	push   %eax
  800116:	68 a8 26 80 00       	push   $0x8026a8
  80011b:	e8 b0 00 00 00       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800120:	83 c4 18             	add    $0x18,%esp
  800123:	56                   	push   %esi
  800124:	ff 75 10             	pushl  0x10(%ebp)
  800127:	e8 53 00 00 00       	call   80017f <vcprintf>
	cprintf("\n");
  80012c:	c7 04 24 9a 26 80 00 	movl   $0x80269a,(%esp)
  800133:	e8 98 00 00 00       	call   8001d0 <cprintf>
  800138:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80013b:	cc                   	int3   
  80013c:	eb fd                	jmp    80013b <_panic+0x43>
	...

00800140 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	53                   	push   %ebx
  800144:	83 ec 04             	sub    $0x4,%esp
  800147:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014a:	8b 03                	mov    (%ebx),%eax
  80014c:	8b 55 08             	mov    0x8(%ebp),%edx
  80014f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800153:	40                   	inc    %eax
  800154:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800156:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015b:	75 1a                	jne    800177 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80015d:	83 ec 08             	sub    $0x8,%esp
  800160:	68 ff 00 00 00       	push   $0xff
  800165:	8d 43 08             	lea    0x8(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 e3 09 00 00       	call   800b51 <sys_cputs>
		b->idx = 0;
  80016e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800174:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800177:	ff 43 04             	incl   0x4(%ebx)
}
  80017a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	ff 75 0c             	pushl  0xc(%ebp)
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	68 40 01 80 00       	push   $0x800140
  8001ae:	e8 82 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	83 c4 08             	add    $0x8,%esp
  8001b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 89 09 00 00       	call   800b51 <sys_cputs>

	return b.cnt;
}
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d9:	50                   	push   %eax
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 9d ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 2c             	sub    $0x2c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d6                	mov    %edx,%esi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800201:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800204:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800207:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80020a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800211:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800214:	72 0c                	jb     800222 <printnum+0x3e>
  800216:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800219:	76 07                	jbe    800222 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021b:	4b                   	dec    %ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f 31                	jg     800251 <printnum+0x6d>
  800220:	eb 3f                	jmp    800261 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	57                   	push   %edi
  800226:	4b                   	dec    %ebx
  800227:	53                   	push   %ebx
  800228:	50                   	push   %eax
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022f:	ff 75 d0             	pushl  -0x30(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 b7 21 00 00       	call   8023f4 <__udivdi3>
  80023d:	83 c4 18             	add    $0x18,%esp
  800240:	52                   	push   %edx
  800241:	50                   	push   %eax
  800242:	89 f2                	mov    %esi,%edx
  800244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800247:	e8 98 ff ff ff       	call   8001e4 <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 10                	jmp    800261 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	57                   	push   %edi
  800256:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800259:	4b                   	dec    %ebx
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7f f0                	jg     800251 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	83 ec 04             	sub    $0x4,%esp
  800268:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026b:	ff 75 d0             	pushl  -0x30(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 97 22 00 00       	call   802510 <__umoddi3>
  800279:	83 c4 14             	add    $0x14,%esp
  80027c:	0f be 80 cb 26 80 00 	movsbl 0x8026cb(%eax),%eax
  800283:	50                   	push   %eax
  800284:	ff 55 e4             	call   *-0x1c(%ebp)
  800287:	83 c4 10             	add    $0x10,%esp
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cf:	83 fa 01             	cmp    $0x1,%edx
  8002d2:	7e 0e                	jle    8002e2 <getint+0x16>
		return va_arg(*ap, long long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	8b 52 04             	mov    0x4(%edx),%edx
  8002e0:	eb 1a                	jmp    8002fc <getint+0x30>
	else if (lflag)
  8002e2:	85 d2                	test   %edx,%edx
  8002e4:	74 0c                	je     8002f2 <getint+0x26>
		return va_arg(*ap, long);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	99                   	cltd   
  8002f0:	eb 0a                	jmp    8002fc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	99                   	cltd   
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800304:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 08                	jae    800316 <sprintputch+0x18>
		*b->buf++ = ch;
  80030e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800311:	88 0a                	mov    %cl,(%edx)
  800313:	42                   	inc    %edx
  800314:	89 10                	mov    %edx,(%eax)
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 05 00 00 00       	call   800335 <vprintfmt>
	va_end(ap);
  800330:	83 c4 10             	add    $0x10,%esp
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 2c             	sub    $0x2c,%esp
  80033e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800341:	8b 75 10             	mov    0x10(%ebp),%esi
  800344:	eb 13                	jmp    800359 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 6d 03 00 00    	je     8006bb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	57                   	push   %edi
  800352:	50                   	push   %eax
  800353:	ff 55 08             	call   *0x8(%ebp)
  800356:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	0f b6 06             	movzbl (%esi),%eax
  80035c:	46                   	inc    %esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e4                	jne    800346 <vprintfmt+0x11>
  800362:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800366:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80036d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800374:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80037b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800380:	eb 28                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800388:	eb 20                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800390:	eb 18                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800394:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039b:	eb 0d                	jmp    8003aa <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8a 06                	mov    (%esi),%al
  8003ac:	0f b6 d0             	movzbl %al,%edx
  8003af:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003b2:	83 e8 23             	sub    $0x23,%eax
  8003b5:	3c 55                	cmp    $0x55,%al
  8003b7:	0f 87 e0 02 00 00    	ja     80069d <vprintfmt+0x368>
  8003bd:	0f b6 c0             	movzbl %al,%eax
  8003c0:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c7:	83 ea 30             	sub    $0x30,%edx
  8003ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003cd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003d0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d3:	83 fa 09             	cmp    $0x9,%edx
  8003d6:	77 44                	ja     80041c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	89 de                	mov    %ebx,%esi
  8003da:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003de:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003e1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003e5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003eb:	83 fb 09             	cmp    $0x9,%ebx
  8003ee:	76 ed                	jbe    8003dd <vprintfmt+0xa8>
  8003f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003f3:	eb 29                	jmp    80041e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800405:	eb 17                	jmp    80041e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800407:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040b:	78 85                	js     800392 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	89 de                	mov    %ebx,%esi
  80040f:	eb 99                	jmp    8003aa <vprintfmt+0x75>
  800411:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800413:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80041a:	eb 8e                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800422:	79 86                	jns    8003aa <vprintfmt+0x75>
  800424:	e9 74 ff ff ff       	jmp    80039d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	89 de                	mov    %ebx,%esi
  80042c:	e9 79 ff ff ff       	jmp    8003aa <vprintfmt+0x75>
  800431:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	57                   	push   %edi
  800441:	ff 30                	pushl  (%eax)
  800443:	ff 55 08             	call   *0x8(%ebp)
			break;
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044c:	e9 08 ff ff ff       	jmp    800359 <vprintfmt+0x24>
  800451:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 02                	jns    800465 <vprintfmt+0x130>
  800463:	f7 d8                	neg    %eax
  800465:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 0f             	cmp    $0xf,%eax
  80046a:	7f 0b                	jg     800477 <vprintfmt+0x142>
  80046c:	8b 04 85 60 29 80 00 	mov    0x802960(,%eax,4),%eax
  800473:	85 c0                	test   %eax,%eax
  800475:	75 1a                	jne    800491 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800477:	52                   	push   %edx
  800478:	68 e3 26 80 00       	push   $0x8026e3
  80047d:	57                   	push   %edi
  80047e:	ff 75 08             	pushl  0x8(%ebp)
  800481:	e8 92 fe ff ff       	call   800318 <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 c8 fe ff ff       	jmp    800359 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	50                   	push   %eax
  800492:	68 91 2a 80 00       	push   $0x802a91
  800497:	57                   	push   %edi
  800498:	ff 75 08             	pushl  0x8(%ebp)
  80049b:	e8 78 fe ff ff       	call   800318 <printfmt>
  8004a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004a6:	e9 ae fe ff ff       	jmp    800359 <vprintfmt+0x24>
  8004ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ae:	89 de                	mov    %ebx,%esi
  8004b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 07                	jne    8004cf <vprintfmt+0x19a>
				p = "(null)";
  8004c8:	c7 45 d0 dc 26 80 00 	movl   $0x8026dc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004cf:	85 db                	test   %ebx,%ebx
  8004d1:	7e 42                	jle    800515 <vprintfmt+0x1e0>
  8004d3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004d7:	74 3c                	je     800515 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	51                   	push   %ecx
  8004dd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e0:	e8 6f 02 00 00       	call   800754 <strnlen>
  8004e5:	29 c3                	sub    %eax,%ebx
  8004e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	7e 24                	jle    800515 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004f1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004f5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	57                   	push   %edi
  8004ff:	53                   	push   %ebx
  800500:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	4e                   	dec    %esi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	85 f6                	test   %esi,%esi
  800509:	7f f0                	jg     8004fb <vprintfmt+0x1c6>
  80050b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80050e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800515:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800518:	0f be 02             	movsbl (%edx),%eax
  80051b:	85 c0                	test   %eax,%eax
  80051d:	75 47                	jne    800566 <vprintfmt+0x231>
  80051f:	eb 37                	jmp    800558 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800525:	74 16                	je     80053d <vprintfmt+0x208>
  800527:	8d 50 e0             	lea    -0x20(%eax),%edx
  80052a:	83 fa 5e             	cmp    $0x5e,%edx
  80052d:	76 0e                	jbe    80053d <vprintfmt+0x208>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	6a 3f                	push   $0x3f
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 0b                	jmp    800548 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	57                   	push   %edi
  800541:	50                   	push   %eax
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	ff 4d e4             	decl   -0x1c(%ebp)
  80054b:	0f be 03             	movsbl (%ebx),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 03                	je     800555 <vprintfmt+0x220>
  800552:	43                   	inc    %ebx
  800553:	eb 1b                	jmp    800570 <vprintfmt+0x23b>
  800555:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800558:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055c:	7f 1e                	jg     80057c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800561:	e9 f3 fd ff ff       	jmp    800359 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800569:	43                   	inc    %ebx
  80056a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80056d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800570:	85 f6                	test   %esi,%esi
  800572:	78 ad                	js     800521 <vprintfmt+0x1ec>
  800574:	4e                   	dec    %esi
  800575:	79 aa                	jns    800521 <vprintfmt+0x1ec>
  800577:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80057a:	eb dc                	jmp    800558 <vprintfmt+0x223>
  80057c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	6a 20                	push   $0x20
  800585:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800588:	4b                   	dec    %ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ef                	jg     80057f <vprintfmt+0x24a>
  800590:	e9 c4 fd ff ff       	jmp    800359 <vprintfmt+0x24>
  800595:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800598:	89 ca                	mov    %ecx,%edx
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 2a fd ff ff       	call   8002cc <getint>
  8005a2:	89 c3                	mov    %eax,%ebx
  8005a4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	78 0a                	js     8005b4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 b0 00 00 00       	jmp    800664 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	57                   	push   %edi
  8005b8:	6a 2d                	push   $0x2d
  8005ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bd:	f7 db                	neg    %ebx
  8005bf:	83 d6 00             	adc    $0x0,%esi
  8005c2:	f7 de                	neg    %esi
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 93 00 00 00       	jmp    800664 <vprintfmt+0x32f>
  8005d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 b4 fc ff ff       	call   800292 <getuint>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e7:	eb 7b                	jmp    800664 <vprintfmt+0x32f>
  8005e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005ec:	89 ca                	mov    %ecx,%edx
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 d6 fc ff ff       	call   8002cc <getint>
  8005f6:	89 c3                	mov    %eax,%ebx
  8005f8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	78 07                	js     800605 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800603:	eb 5f                	jmp    800664 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	57                   	push   %edi
  800609:	6a 2d                	push   $0x2d
  80060b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80060e:	f7 db                	neg    %ebx
  800610:	83 d6 00             	adc    $0x0,%esi
  800613:	f7 de                	neg    %esi
  800615:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800618:	b8 08 00 00 00       	mov    $0x8,%eax
  80061d:	eb 45                	jmp    800664 <vprintfmt+0x32f>
  80061f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 30                	push   $0x30
  800628:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 78                	push   $0x78
  800631:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063d:	8b 18                	mov    (%eax),%ebx
  80063f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800644:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064c:	eb 16                	jmp    800664 <vprintfmt+0x32f>
  80064e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800651:	89 ca                	mov    %ecx,%edx
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 37 fc ff ff       	call   800292 <getuint>
  80065b:	89 c3                	mov    %eax,%ebx
  80065d:	89 d6                	mov    %edx,%esi
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80066b:	52                   	push   %edx
  80066c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066f:	50                   	push   %eax
  800670:	56                   	push   %esi
  800671:	53                   	push   %ebx
  800672:	89 fa                	mov    %edi,%edx
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	e8 68 fb ff ff       	call   8001e4 <printnum>
			break;
  80067c:	83 c4 20             	add    $0x20,%esp
  80067f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800682:	e9 d2 fc ff ff       	jmp    800359 <vprintfmt+0x24>
  800687:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	57                   	push   %edi
  80068e:	52                   	push   %edx
  80068f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800692:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800698:	e9 bc fc ff ff       	jmp    800359 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	57                   	push   %edi
  8006a1:	6a 25                	push   $0x25
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	eb 02                	jmp    8006ad <vprintfmt+0x378>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006b0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b4:	75 f5                	jne    8006ab <vprintfmt+0x376>
  8006b6:	e9 9e fc ff ff       	jmp    800359 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5f                   	pop    %edi
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 18             	sub    $0x18,%esp
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 26                	je     80070a <vsnprintf+0x47>
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e 29                	jle    800711 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e8:	ff 75 14             	pushl  0x14(%ebp)
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	68 fe 02 80 00       	push   $0x8002fe
  8006f7:	e8 39 fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 0c                	jmp    800716 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb 05                	jmp    800716 <vsnprintf+0x53>
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800721:	50                   	push   %eax
  800722:	ff 75 10             	pushl  0x10(%ebp)
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	ff 75 08             	pushl  0x8(%ebp)
  80072b:	e8 93 ff ff ff       	call   8006c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    
	...

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3a 00             	cmpb   $0x0,(%edx)
  80073d:	74 0e                	je     80074d <strlen+0x19>
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800744:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800749:	75 f9                	jne    800744 <strlen+0x10>
  80074b:	eb 05                	jmp    800752 <strlen+0x1e>
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	85 d2                	test   %edx,%edx
  80075f:	74 17                	je     800778 <strnlen+0x24>
  800761:	80 39 00             	cmpb   $0x0,(%ecx)
  800764:	74 19                	je     80077f <strnlen+0x2b>
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80076b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 d0                	cmp    %edx,%eax
  80076e:	74 14                	je     800784 <strnlen+0x30>
  800770:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800774:	75 f5                	jne    80076b <strnlen+0x17>
  800776:	eb 0c                	jmp    800784 <strnlen+0x30>
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 05                	jmp    800784 <strnlen+0x30>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
  800795:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800798:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80079b:	42                   	inc    %edx
  80079c:	84 c9                	test   %cl,%cl
  80079e:	75 f5                	jne    800795 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 84 ff ff ff       	call   800734 <strlen>
  8007b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 c7 ff ff ff       	call   800786 <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	85 f6                	test   %esi,%esi
  8007d6:	74 15                	je     8007ed <strncpy+0x27>
  8007d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007dd:	8a 1a                	mov    (%edx),%bl
  8007df:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	41                   	inc    %ecx
  8007e9:	39 ce                	cmp    %ecx,%esi
  8007eb:	77 f0                	ja     8007dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	57                   	push   %edi
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	85 f6                	test   %esi,%esi
  800802:	74 32                	je     800836 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800804:	83 fe 01             	cmp    $0x1,%esi
  800807:	74 22                	je     80082b <strlcpy+0x3a>
  800809:	8a 0b                	mov    (%ebx),%cl
  80080b:	84 c9                	test   %cl,%cl
  80080d:	74 20                	je     80082f <strlcpy+0x3e>
  80080f:	89 f8                	mov    %edi,%eax
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800816:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800819:	88 08                	mov    %cl,(%eax)
  80081b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081c:	39 f2                	cmp    %esi,%edx
  80081e:	74 11                	je     800831 <strlcpy+0x40>
  800820:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f0                	jne    800819 <strlcpy+0x28>
  800829:	eb 06                	jmp    800831 <strlcpy+0x40>
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	eb 02                	jmp    800831 <strlcpy+0x40>
  80082f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800831:	c6 00 00             	movb   $0x0,(%eax)
  800834:	eb 02                	jmp    800838 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800838:	29 f8                	sub    %edi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5f                   	pop    %edi
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800848:	8a 01                	mov    (%ecx),%al
  80084a:	84 c0                	test   %al,%al
  80084c:	74 10                	je     80085e <strcmp+0x1f>
  80084e:	3a 02                	cmp    (%edx),%al
  800850:	75 0c                	jne    80085e <strcmp+0x1f>
		p++, q++;
  800852:	41                   	inc    %ecx
  800853:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800854:	8a 01                	mov    (%ecx),%al
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1f>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 f4                	je     800852 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800875:	85 c0                	test   %eax,%eax
  800877:	74 1b                	je     800894 <strncmp+0x2c>
  800879:	8a 1a                	mov    (%edx),%bl
  80087b:	84 db                	test   %bl,%bl
  80087d:	74 24                	je     8008a3 <strncmp+0x3b>
  80087f:	3a 19                	cmp    (%ecx),%bl
  800881:	75 20                	jne    8008a3 <strncmp+0x3b>
  800883:	48                   	dec    %eax
  800884:	74 15                	je     80089b <strncmp+0x33>
		n--, p++, q++;
  800886:	42                   	inc    %edx
  800887:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800888:	8a 1a                	mov    (%edx),%bl
  80088a:	84 db                	test   %bl,%bl
  80088c:	74 15                	je     8008a3 <strncmp+0x3b>
  80088e:	3a 19                	cmp    (%ecx),%bl
  800890:	74 f1                	je     800883 <strncmp+0x1b>
  800892:	eb 0f                	jmp    8008a3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	eb 05                	jmp    8008a0 <strncmp+0x38>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 02             	movzbl (%edx),%eax
  8008a6:	0f b6 11             	movzbl (%ecx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
  8008ab:	eb f3                	jmp    8008a0 <strncmp+0x38>

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	8a 10                	mov    (%eax),%dl
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 18                	je     8008d4 <strchr+0x27>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	75 06                	jne    8008c6 <strchr+0x19>
  8008c0:	eb 17                	jmp    8008d9 <strchr+0x2c>
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 13                	je     8008d9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c6:	40                   	inc    %eax
  8008c7:	8a 10                	mov    (%eax),%dl
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f5                	jne    8008c2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb 05                	jmp    8008d9 <strchr+0x2c>
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e4:	8a 10                	mov    (%eax),%dl
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 11                	je     8008fb <strfind+0x20>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	75 06                	jne    8008f4 <strfind+0x19>
  8008ee:	eb 0b                	jmp    8008fb <strfind+0x20>
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 07                	je     8008fb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	40                   	inc    %eax
  8008f5:	8a 10                	mov    (%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f5                	jne    8008f0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 30                	je     800940 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800916:	75 25                	jne    80093d <memset+0x40>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 20                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800920:	89 d3                	mov    %edx,%ebx
  800922:	c1 e3 08             	shl    $0x8,%ebx
  800925:	89 d6                	mov    %edx,%esi
  800927:	c1 e6 18             	shl    $0x18,%esi
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 10             	shl    $0x10,%eax
  80092f:	09 f0                	or     %esi,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800935:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 03                	jmp    800940 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 34                	jae    80098d <memmove+0x46>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2d                	jae    80098d <memmove+0x46>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	f6 c2 03             	test   $0x3,%dl
  800966:	75 1b                	jne    800983 <memmove+0x3c>
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 13                	jne    800983 <memmove+0x3c>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 07                	jmp    80098a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	4f                   	dec    %edi
  800984:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800987:	fd                   	std    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098a:	fc                   	cld    
  80098b:	eb 20                	jmp    8009ad <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800993:	75 13                	jne    8009a8 <memmove+0x61>
  800995:	a8 03                	test   $0x3,%al
  800997:	75 0f                	jne    8009a8 <memmove+0x61>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0a                	jne    8009a8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 05                	jmp    8009ad <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 85 ff ff ff       	call   800947 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	85 ff                	test   %edi,%edi
  8009d5:	74 32                	je     800a09 <memcmp+0x45>
		if (*s1 != *s2)
  8009d7:	8a 03                	mov    (%ebx),%al
  8009d9:	8a 0e                	mov    (%esi),%cl
  8009db:	38 c8                	cmp    %cl,%al
  8009dd:	74 19                	je     8009f8 <memcmp+0x34>
  8009df:	eb 0d                	jmp    8009ee <memcmp+0x2a>
  8009e1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009e5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009e9:	42                   	inc    %edx
  8009ea:	38 c8                	cmp    %cl,%al
  8009ec:	74 10                	je     8009fe <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ee:	0f b6 c0             	movzbl %al,%eax
  8009f1:	0f b6 c9             	movzbl %cl,%ecx
  8009f4:	29 c8                	sub    %ecx,%eax
  8009f6:	eb 16                	jmp    800a0e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	4f                   	dec    %edi
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	39 fa                	cmp    %edi,%edx
  800a00:	75 df                	jne    8009e1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 05                	jmp    800a0e <memcmp+0x4a>
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1e:	39 d0                	cmp    %edx,%eax
  800a20:	73 12                	jae    800a34 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a22:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a25:	38 08                	cmp    %cl,(%eax)
  800a27:	75 06                	jne    800a2f <memfind+0x1c>
  800a29:	eb 09                	jmp    800a34 <memfind+0x21>
  800a2b:	38 08                	cmp    %cl,(%eax)
  800a2d:	74 05                	je     800a34 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2f:	40                   	inc    %eax
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	77 f7                	ja     800a2b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	eb 01                	jmp    800a45 <strtol+0xf>
		s++;
  800a44:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	8a 02                	mov    (%edx),%al
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f9                	je     800a44 <strtol+0xe>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f5                	je     800a44 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	75 08                	jne    800a5b <strtol+0x25>
		s++;
  800a53:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
  800a59:	eb 13                	jmp    800a6e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5b:	3c 2d                	cmp    $0x2d,%al
  800a5d:	75 0a                	jne    800a69 <strtol+0x33>
		s++, neg = 1;
  800a5f:	8d 52 01             	lea    0x1(%edx),%edx
  800a62:	bf 01 00 00 00       	mov    $0x1,%edi
  800a67:	eb 05                	jmp    800a6e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	74 05                	je     800a77 <strtol+0x41>
  800a72:	83 fb 10             	cmp    $0x10,%ebx
  800a75:	75 28                	jne    800a9f <strtol+0x69>
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 30                	cmp    $0x30,%al
  800a7b:	75 10                	jne    800a8d <strtol+0x57>
  800a7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a81:	75 0a                	jne    800a8d <strtol+0x57>
		s += 2, base = 16;
  800a83:	83 c2 02             	add    $0x2,%edx
  800a86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8b:	eb 12                	jmp    800a9f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 0e                	jne    800a9f <strtol+0x69>
  800a91:	3c 30                	cmp    $0x30,%al
  800a93:	75 05                	jne    800a9a <strtol+0x64>
		s++, base = 8;
  800a95:	42                   	inc    %edx
  800a96:	b3 08                	mov    $0x8,%bl
  800a98:	eb 05                	jmp    800a9f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a9a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa6:	8a 0a                	mov    (%edx),%cl
  800aa8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aab:	80 fb 09             	cmp    $0x9,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0x82>
			dig = *s - '0';
  800ab0:	0f be c9             	movsbl %cl,%ecx
  800ab3:	83 e9 30             	sub    $0x30,%ecx
  800ab6:	eb 1e                	jmp    800ad6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ab8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800abb:	80 fb 19             	cmp    $0x19,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac0:	0f be c9             	movsbl %cl,%ecx
  800ac3:	83 e9 57             	sub    $0x57,%ecx
  800ac6:	eb 0e                	jmp    800ad6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ac8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 13                	ja     800ae3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ad0:	0f be c9             	movsbl %cl,%ecx
  800ad3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad6:	39 f1                	cmp    %esi,%ecx
  800ad8:	7d 0d                	jge    800ae7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ada:	42                   	inc    %edx
  800adb:	0f af c6             	imul   %esi,%eax
  800ade:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ae1:	eb c3                	jmp    800aa6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae3:	89 c1                	mov    %eax,%ecx
  800ae5:	eb 02                	jmp    800ae9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aed:	74 05                	je     800af4 <strtol+0xbe>
		*endptr = (char *) s;
  800aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af4:	85 ff                	test   %edi,%edi
  800af6:	74 04                	je     800afc <strtol+0xc6>
  800af8:	89 c8                	mov    %ecx,%eax
  800afa:	f7 d8                	neg    %eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    
  800b01:	00 00                	add    %al,(%eax)
	...

00800b04 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 1c             	sub    $0x1c,%esp
  800b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b10:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b13:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	8b 75 14             	mov    0x14(%ebp),%esi
  800b18:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	cd 30                	int    $0x30
  800b23:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b29:	74 1c                	je     800b47 <syscall+0x43>
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 18                	jle    800b47 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b36:	68 bf 29 80 00       	push   $0x8029bf
  800b3b:	6a 42                	push   $0x42
  800b3d:	68 dc 29 80 00       	push   $0x8029dc
  800b42:	e8 b1 f5 ff ff       	call   8000f8 <_panic>

	return ret;
}
  800b47:	89 d0                	mov    %edx,%eax
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	ff 75 0c             	pushl  0xc(%ebp)
  800b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	e8 92 ff ff ff       	call   800b04 <syscall>
  800b72:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	e8 6b ff ff ff       	call   800b04 <syscall>
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bac:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb6:	e8 49 ff ff ff       	call   800b04 <syscall>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	e8 25 ff ff ff       	call   800b04 <syscall>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_yield>:

void
sys_yield(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfe:	e8 01 ff ff ff       	call   800b04 <syscall>
  800c03:	83 c4 10             	add    $0x10,%esp
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	6a 00                	push   $0x0
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c20:	b8 04 00 00 00       	mov    $0x4,%eax
  800c25:	e8 da fe ff ff       	call   800b04 <syscall>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c32:	ff 75 18             	pushl  0x18(%ebp)
  800c35:	ff 75 14             	pushl  0x14(%ebp)
  800c38:	ff 75 10             	pushl  0x10(%ebp)
  800c3b:	ff 75 0c             	pushl  0xc(%ebp)
  800c3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c41:	ba 01 00 00 00       	mov    $0x1,%edx
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	e8 b4 fe ff ff       	call   800b04 <syscall>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 0c             	pushl  0xc(%ebp)
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	ba 01 00 00 00       	mov    $0x1,%edx
  800c69:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6e:	e8 91 fe ff ff       	call   800b04 <syscall>
}
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	6a 00                	push   $0x0
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c91:	e8 6e fe ff ff       	call   800b04 <syscall>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	ff 75 0c             	pushl  0xc(%ebp)
  800ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caa:	ba 01 00 00 00       	mov    $0x1,%edx
  800caf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb4:	e8 4b fe ff ff       	call   800b04 <syscall>
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd7:	e8 28 fe ff ff       	call   800b04 <syscall>
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ce4:	6a 00                	push   $0x0
  800ce6:	ff 75 14             	pushl  0x14(%ebp)
  800ce9:	ff 75 10             	pushl  0x10(%ebp)
  800cec:	ff 75 0c             	pushl  0xc(%ebp)
  800cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	e8 03 fe ff ff       	call   800b04 <syscall>
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d09:	6a 00                	push   $0x0
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d14:	ba 01 00 00 00       	mov    $0x1,%edx
  800d19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1e:	e8 e1 fd ff ff       	call   800b04 <syscall>
}
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    

00800d25 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d37:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d41:	e8 be fd ff ff       	call   800b04 <syscall>
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d4e:	6a 00                	push   $0x0
  800d50:	ff 75 14             	pushl  0x14(%ebp)
  800d53:	ff 75 10             	pushl  0x10(%ebp)
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d61:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d66:	e8 99 fd ff ff       	call   800b04 <syscall>
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    
  800d6d:	00 00                	add    %al,(%eax)
	...

00800d70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d83:	ff 75 08             	pushl  0x8(%ebp)
  800d86:	e8 e5 ff ff ff       	call   800d70 <fd2num>
  800d8b:	83 c4 04             	add    $0x4,%esp
  800d8e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d93:	c1 e0 0c             	shl    $0xc,%eax
}
  800d96:	c9                   	leave  
  800d97:	c3                   	ret    

00800d98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	53                   	push   %ebx
  800d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800da4:	a8 01                	test   $0x1,%al
  800da6:	74 34                	je     800ddc <fd_alloc+0x44>
  800da8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800dad:	a8 01                	test   $0x1,%al
  800daf:	74 32                	je     800de3 <fd_alloc+0x4b>
  800db1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800db6:	89 c1                	mov    %eax,%ecx
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	c1 ea 16             	shr    $0x16,%edx
  800dbd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc4:	f6 c2 01             	test   $0x1,%dl
  800dc7:	74 1f                	je     800de8 <fd_alloc+0x50>
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	c1 ea 0c             	shr    $0xc,%edx
  800dce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd5:	f6 c2 01             	test   $0x1,%dl
  800dd8:	75 17                	jne    800df1 <fd_alloc+0x59>
  800dda:	eb 0c                	jmp    800de8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ddc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800de1:	eb 05                	jmp    800de8 <fd_alloc+0x50>
  800de3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800de8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
  800def:	eb 17                	jmp    800e08 <fd_alloc+0x70>
  800df1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dfb:	75 b9                	jne    800db6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dfd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e08:	5b                   	pop    %ebx
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e11:	83 f8 1f             	cmp    $0x1f,%eax
  800e14:	77 36                	ja     800e4c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e16:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e1b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	c1 ea 16             	shr    $0x16,%edx
  800e23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	74 24                	je     800e53 <fd_lookup+0x48>
  800e2f:	89 c2                	mov    %eax,%edx
  800e31:	c1 ea 0c             	shr    $0xc,%edx
  800e34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3b:	f6 c2 01             	test   $0x1,%dl
  800e3e:	74 1a                	je     800e5a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e43:	89 02                	mov    %eax,(%edx)
	return 0;
  800e45:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4a:	eb 13                	jmp    800e5f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e51:	eb 0c                	jmp    800e5f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e58:	eb 05                	jmp    800e5f <fd_lookup+0x54>
  800e5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	53                   	push   %ebx
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e6e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e74:	74 0d                	je     800e83 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	eb 14                	jmp    800e91 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e7d:	39 0a                	cmp    %ecx,(%edx)
  800e7f:	75 10                	jne    800e91 <dev_lookup+0x30>
  800e81:	eb 05                	jmp    800e88 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e83:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e88:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8f:	eb 31                	jmp    800ec2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e91:	40                   	inc    %eax
  800e92:	8b 14 85 68 2a 80 00 	mov    0x802a68(,%eax,4),%edx
  800e99:	85 d2                	test   %edx,%edx
  800e9b:	75 e0                	jne    800e7d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e9d:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea2:	8b 40 48             	mov    0x48(%eax),%eax
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	51                   	push   %ecx
  800ea9:	50                   	push   %eax
  800eaa:	68 ec 29 80 00       	push   $0x8029ec
  800eaf:	e8 1c f3 ff ff       	call   8001d0 <cprintf>
	*dev = 0;
  800eb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 20             	sub    $0x20,%esp
  800ecf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed2:	8a 45 0c             	mov    0xc(%ebp),%al
  800ed5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed8:	56                   	push   %esi
  800ed9:	e8 92 fe ff ff       	call   800d70 <fd2num>
  800ede:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ee1:	89 14 24             	mov    %edx,(%esp)
  800ee4:	50                   	push   %eax
  800ee5:	e8 21 ff ff ff       	call   800e0b <fd_lookup>
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	83 c4 08             	add    $0x8,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 05                	js     800ef8 <fd_close+0x31>
	    || fd != fd2)
  800ef3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef6:	74 0d                	je     800f05 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ef8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800efc:	75 48                	jne    800f46 <fd_close+0x7f>
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f03:	eb 41                	jmp    800f46 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	ff 36                	pushl  (%esi)
  800f0e:	e8 4e ff ff ff       	call   800e61 <dev_lookup>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 1c                	js     800f38 <fd_close+0x71>
		if (dev->dev_close)
  800f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1f:	8b 40 10             	mov    0x10(%eax),%eax
  800f22:	85 c0                	test   %eax,%eax
  800f24:	74 0d                	je     800f33 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	56                   	push   %esi
  800f2a:	ff d0                	call   *%eax
  800f2c:	89 c3                	mov    %eax,%ebx
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	eb 05                	jmp    800f38 <fd_close+0x71>
		else
			r = 0;
  800f33:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	56                   	push   %esi
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 0f fd ff ff       	call   800c52 <sys_page_unmap>
	return r;
  800f43:	83 c4 10             	add    $0x10,%esp
}
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f58:	50                   	push   %eax
  800f59:	ff 75 08             	pushl  0x8(%ebp)
  800f5c:	e8 aa fe ff ff       	call   800e0b <fd_lookup>
  800f61:	83 c4 08             	add    $0x8,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 10                	js     800f78 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	6a 01                	push   $0x1
  800f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f70:	e8 52 ff ff ff       	call   800ec7 <fd_close>
  800f75:	83 c4 10             	add    $0x10,%esp
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <close_all>:

void
close_all(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f81:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	53                   	push   %ebx
  800f8a:	e8 c0 ff ff ff       	call   800f4f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8f:	43                   	inc    %ebx
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	83 fb 20             	cmp    $0x20,%ebx
  800f96:	75 ee                	jne    800f86 <close_all+0xc>
		close(i);
}
  800f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 2c             	sub    $0x2c,%esp
  800fa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 56 fe ff ff       	call   800e0b <fd_lookup>
  800fb5:	89 c3                	mov    %eax,%ebx
  800fb7:	83 c4 08             	add    $0x8,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	0f 88 c0 00 00 00    	js     801082 <dup+0xe5>
		return r;
	close(newfdnum);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	57                   	push   %edi
  800fc6:	e8 84 ff ff ff       	call   800f4f <close>

	newfd = INDEX2FD(newfdnum);
  800fcb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fd1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fd4:	83 c4 04             	add    $0x4,%esp
  800fd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fda:	e8 a1 fd ff ff       	call   800d80 <fd2data>
  800fdf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fe1:	89 34 24             	mov    %esi,(%esp)
  800fe4:	e8 97 fd ff ff       	call   800d80 <fd2data>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fef:	89 d8                	mov    %ebx,%eax
  800ff1:	c1 e8 16             	shr    $0x16,%eax
  800ff4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffb:	a8 01                	test   $0x1,%al
  800ffd:	74 37                	je     801036 <dup+0x99>
  800fff:	89 d8                	mov    %ebx,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100b:	f6 c2 01             	test   $0x1,%dl
  80100e:	74 26                	je     801036 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	ff 75 d4             	pushl  -0x2c(%ebp)
  801023:	6a 00                	push   $0x0
  801025:	53                   	push   %ebx
  801026:	6a 00                	push   $0x0
  801028:	e8 ff fb ff ff       	call   800c2c <sys_page_map>
  80102d:	89 c3                	mov    %eax,%ebx
  80102f:	83 c4 20             	add    $0x20,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 2d                	js     801063 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801036:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801039:	89 c2                	mov    %eax,%edx
  80103b:	c1 ea 0c             	shr    $0xc,%edx
  80103e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80104e:	52                   	push   %edx
  80104f:	56                   	push   %esi
  801050:	6a 00                	push   $0x0
  801052:	50                   	push   %eax
  801053:	6a 00                	push   $0x0
  801055:	e8 d2 fb ff ff       	call   800c2c <sys_page_map>
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 1d                	jns    801080 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	e8 e4 fb ff ff       	call   800c52 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	ff 75 d4             	pushl  -0x2c(%ebp)
  801074:	6a 00                	push   $0x0
  801076:	e8 d7 fb ff ff       	call   800c52 <sys_page_unmap>
	return r;
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	eb 02                	jmp    801082 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801080:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801082:	89 d8                	mov    %ebx,%eax
  801084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 14             	sub    $0x14,%esp
  801093:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801096:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	53                   	push   %ebx
  80109b:	e8 6b fd ff ff       	call   800e0b <fd_lookup>
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 67                	js     80110e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ad:	50                   	push   %eax
  8010ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b1:	ff 30                	pushl  (%eax)
  8010b3:	e8 a9 fd ff ff       	call   800e61 <dev_lookup>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 4f                	js     80110e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c2:	8b 50 08             	mov    0x8(%eax),%edx
  8010c5:	83 e2 03             	and    $0x3,%edx
  8010c8:	83 fa 01             	cmp    $0x1,%edx
  8010cb:	75 21                	jne    8010ee <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	53                   	push   %ebx
  8010d9:	50                   	push   %eax
  8010da:	68 2d 2a 80 00       	push   $0x802a2d
  8010df:	e8 ec f0 ff ff       	call   8001d0 <cprintf>
		return -E_INVAL;
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 20                	jmp    80110e <read+0x82>
	}
	if (!dev->dev_read)
  8010ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f1:	8b 52 08             	mov    0x8(%edx),%edx
  8010f4:	85 d2                	test   %edx,%edx
  8010f6:	74 11                	je     801109 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	ff 75 10             	pushl  0x10(%ebp)
  8010fe:	ff 75 0c             	pushl  0xc(%ebp)
  801101:	50                   	push   %eax
  801102:	ff d2                	call   *%edx
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	eb 05                	jmp    80110e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801109:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80110e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80111f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801122:	85 f6                	test   %esi,%esi
  801124:	74 31                	je     801157 <readn+0x44>
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	89 f2                	mov    %esi,%edx
  801135:	29 c2                	sub    %eax,%edx
  801137:	52                   	push   %edx
  801138:	03 45 0c             	add    0xc(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	57                   	push   %edi
  80113d:	e8 4a ff ff ff       	call   80108c <read>
		if (m < 0)
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	78 17                	js     801160 <readn+0x4d>
			return m;
		if (m == 0)
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 11                	je     80115e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114d:	01 c3                	add    %eax,%ebx
  80114f:	89 d8                	mov    %ebx,%eax
  801151:	39 f3                	cmp    %esi,%ebx
  801153:	72 db                	jb     801130 <readn+0x1d>
  801155:	eb 09                	jmp    801160 <readn+0x4d>
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	eb 02                	jmp    801160 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80115e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	53                   	push   %ebx
  80116c:	83 ec 14             	sub    $0x14,%esp
  80116f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801172:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	53                   	push   %ebx
  801177:	e8 8f fc ff ff       	call   800e0b <fd_lookup>
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 62                	js     8011e5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118d:	ff 30                	pushl  (%eax)
  80118f:	e8 cd fc ff ff       	call   800e61 <dev_lookup>
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 4a                	js     8011e5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a2:	75 21                	jne    8011c5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	53                   	push   %ebx
  8011b0:	50                   	push   %eax
  8011b1:	68 49 2a 80 00       	push   $0x802a49
  8011b6:	e8 15 f0 ff ff       	call   8001d0 <cprintf>
		return -E_INVAL;
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c3:	eb 20                	jmp    8011e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8011cb:	85 d2                	test   %edx,%edx
  8011cd:	74 11                	je     8011e0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	ff 75 10             	pushl  0x10(%ebp)
  8011d5:	ff 75 0c             	pushl  0xc(%ebp)
  8011d8:	50                   	push   %eax
  8011d9:	ff d2                	call   *%edx
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	eb 05                	jmp    8011e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 08             	pushl  0x8(%ebp)
  8011f7:	e8 0f fc ff ff       	call   800e0b <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 0e                	js     801211 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801203:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801206:	8b 55 0c             	mov    0xc(%ebp),%edx
  801209:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	53                   	push   %ebx
  801217:	83 ec 14             	sub    $0x14,%esp
  80121a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	53                   	push   %ebx
  801222:	e8 e4 fb ff ff       	call   800e0b <fd_lookup>
  801227:	83 c4 08             	add    $0x8,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 5f                	js     80128d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801238:	ff 30                	pushl  (%eax)
  80123a:	e8 22 fc ff ff       	call   800e61 <dev_lookup>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 47                	js     80128d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801249:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124d:	75 21                	jne    801270 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80124f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801254:	8b 40 48             	mov    0x48(%eax),%eax
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	53                   	push   %ebx
  80125b:	50                   	push   %eax
  80125c:	68 0c 2a 80 00       	push   $0x802a0c
  801261:	e8 6a ef ff ff       	call   8001d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb 1d                	jmp    80128d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801270:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801273:	8b 52 18             	mov    0x18(%edx),%edx
  801276:	85 d2                	test   %edx,%edx
  801278:	74 0e                	je     801288 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	ff 75 0c             	pushl  0xc(%ebp)
  801280:	50                   	push   %eax
  801281:	ff d2                	call   *%edx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 05                	jmp    80128d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801288:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80128d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	53                   	push   %ebx
  801296:	83 ec 14             	sub    $0x14,%esp
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 63 fb ff ff       	call   800e0b <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 52                	js     801301 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b5:	50                   	push   %eax
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	ff 30                	pushl  (%eax)
  8012bb:	e8 a1 fb ff ff       	call   800e61 <dev_lookup>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 3a                	js     801301 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ce:	74 2c                	je     8012fc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012da:	00 00 00 
	stat->st_isdir = 0;
  8012dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e4:	00 00 00 
	stat->st_dev = dev;
  8012e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f4:	ff 50 14             	call   *0x14(%eax)
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	eb 05                	jmp    801301 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	6a 00                	push   $0x0
  801310:	ff 75 08             	pushl  0x8(%ebp)
  801313:	e8 78 01 00 00       	call   801490 <open>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 1b                	js     80133c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	ff 75 0c             	pushl  0xc(%ebp)
  801327:	50                   	push   %eax
  801328:	e8 65 ff ff ff       	call   801292 <fstat>
  80132d:	89 c6                	mov    %eax,%esi
	close(fd);
  80132f:	89 1c 24             	mov    %ebx,(%esp)
  801332:	e8 18 fc ff ff       	call   800f4f <close>
	return r;
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	89 f3                	mov    %esi,%ebx
}
  80133c:	89 d8                	mov    %ebx,%eax
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	c9                   	leave  
  801344:	c3                   	ret    
  801345:	00 00                	add    %al,(%eax)
	...

00801348 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	89 c3                	mov    %eax,%ebx
  80134f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801351:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801358:	75 12                	jne    80136c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	6a 01                	push   $0x1
  80135f:	e8 ee 0f 00 00       	call   802352 <ipc_find_env>
  801364:	a3 00 40 80 00       	mov    %eax,0x804000
  801369:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80136c:	6a 07                	push   $0x7
  80136e:	68 00 50 80 00       	push   $0x805000
  801373:	53                   	push   %ebx
  801374:	ff 35 00 40 80 00    	pushl  0x804000
  80137a:	e8 7e 0f 00 00       	call   8022fd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80137f:	83 c4 0c             	add    $0xc,%esp
  801382:	6a 00                	push   $0x0
  801384:	56                   	push   %esi
  801385:	6a 00                	push   $0x0
  801387:	e8 fc 0e 00 00       	call   802288 <ipc_recv>
}
  80138c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	53                   	push   %ebx
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b2:	e8 91 ff ff ff       	call   801348 <fsipc>
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 2c                	js     8013e7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	68 00 50 80 00       	push   $0x805000
  8013c3:	53                   	push   %ebx
  8013c4:	e8 bd f3 ff ff       	call   800786 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801402:	b8 06 00 00 00       	mov    $0x6,%eax
  801407:	e8 3c ff ff ff       	call   801348 <fsipc>
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801416:	8b 45 08             	mov    0x8(%ebp),%eax
  801419:	8b 40 0c             	mov    0xc(%eax),%eax
  80141c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801421:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	b8 03 00 00 00       	mov    $0x3,%eax
  801431:	e8 12 ff ff ff       	call   801348 <fsipc>
  801436:	89 c3                	mov    %eax,%ebx
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 4b                	js     801487 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80143c:	39 c6                	cmp    %eax,%esi
  80143e:	73 16                	jae    801456 <devfile_read+0x48>
  801440:	68 78 2a 80 00       	push   $0x802a78
  801445:	68 7f 2a 80 00       	push   $0x802a7f
  80144a:	6a 7d                	push   $0x7d
  80144c:	68 94 2a 80 00       	push   $0x802a94
  801451:	e8 a2 ec ff ff       	call   8000f8 <_panic>
	assert(r <= PGSIZE);
  801456:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80145b:	7e 16                	jle    801473 <devfile_read+0x65>
  80145d:	68 9f 2a 80 00       	push   $0x802a9f
  801462:	68 7f 2a 80 00       	push   $0x802a7f
  801467:	6a 7e                	push   $0x7e
  801469:	68 94 2a 80 00       	push   $0x802a94
  80146e:	e8 85 ec ff ff       	call   8000f8 <_panic>
	memmove(buf, &fsipcbuf, r);
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	50                   	push   %eax
  801477:	68 00 50 80 00       	push   $0x805000
  80147c:	ff 75 0c             	pushl  0xc(%ebp)
  80147f:	e8 c3 f4 ff ff       	call   800947 <memmove>
	return r;
  801484:	83 c4 10             	add    $0x10,%esp
}
  801487:	89 d8                	mov    %ebx,%eax
  801489:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	83 ec 1c             	sub    $0x1c,%esp
  801498:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80149b:	56                   	push   %esi
  80149c:	e8 93 f2 ff ff       	call   800734 <strlen>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a9:	7f 65                	jg     801510 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	e8 e1 f8 ff ff       	call   800d98 <fd_alloc>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 55                	js     801515 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	56                   	push   %esi
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	e8 b8 f2 ff ff       	call   800786 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014de:	e8 65 fe ff ff       	call   801348 <fsipc>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	79 12                	jns    8014fe <open+0x6e>
		fd_close(fd, 0);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	6a 00                	push   $0x0
  8014f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f4:	e8 ce f9 ff ff       	call   800ec7 <fd_close>
		return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	eb 17                	jmp    801515 <open+0x85>
	}

	return fd2num(fd);
  8014fe:	83 ec 0c             	sub    $0xc,%esp
  801501:	ff 75 f4             	pushl  -0xc(%ebp)
  801504:	e8 67 f8 ff ff       	call   800d70 <fd2num>
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	eb 05                	jmp    801515 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801510:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801515:	89 d8                	mov    %ebx,%eax
  801517:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5e                   	pop    %esi
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    
	...

00801520 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	57                   	push   %edi
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	83 ec 1c             	sub    $0x1c,%esp
  801529:	89 c7                	mov    %eax,%edi
  80152b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80152e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801531:	89 d0                	mov    %edx,%eax
  801533:	25 ff 0f 00 00       	and    $0xfff,%eax
  801538:	74 0c                	je     801546 <map_segment+0x26>
		va -= i;
  80153a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  80153d:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801540:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801543:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801546:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80154a:	0f 84 ee 00 00 00    	je     80163e <map_segment+0x11e>
  801550:	be 00 00 00 00       	mov    $0x0,%esi
  801555:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  80155a:	39 75 0c             	cmp    %esi,0xc(%ebp)
  80155d:	77 20                	ja     80157f <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	ff 75 14             	pushl  0x14(%ebp)
  801565:	03 75 e4             	add    -0x1c(%ebp),%esi
  801568:	56                   	push   %esi
  801569:	57                   	push   %edi
  80156a:	e8 99 f6 ff ff       	call   800c08 <sys_page_alloc>
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	0f 89 ac 00 00 00    	jns    801626 <map_segment+0x106>
  80157a:	e9 c4 00 00 00       	jmp    801643 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	6a 07                	push   $0x7
  801584:	68 00 00 40 00       	push   $0x400000
  801589:	6a 00                	push   $0x0
  80158b:	e8 78 f6 ff ff       	call   800c08 <sys_page_alloc>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	0f 88 a8 00 00 00    	js     801643 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80159b:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  80159e:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a1:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8015a4:	50                   	push   %eax
  8015a5:	ff 75 08             	pushl  0x8(%ebp)
  8015a8:	e8 3d fc ff ff       	call   8011ea <seek>
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	0f 88 8b 00 00 00    	js     801643 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015be:	29 f0                	sub    %esi,%eax
  8015c0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c5:	76 05                	jbe    8015cc <map_segment+0xac>
  8015c7:	b8 00 10 00 00       	mov    $0x1000,%eax
  8015cc:	50                   	push   %eax
  8015cd:	68 00 00 40 00       	push   $0x400000
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	e8 39 fb ff ff       	call   801113 <readn>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 62                	js     801643 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	ff 75 14             	pushl  0x14(%ebp)
  8015e7:	03 75 e4             	add    -0x1c(%ebp),%esi
  8015ea:	56                   	push   %esi
  8015eb:	57                   	push   %edi
  8015ec:	68 00 00 40 00       	push   $0x400000
  8015f1:	6a 00                	push   $0x0
  8015f3:	e8 34 f6 ff ff       	call   800c2c <sys_page_map>
  8015f8:	83 c4 20             	add    $0x20,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	79 15                	jns    801614 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  8015ff:	50                   	push   %eax
  801600:	68 ab 2a 80 00       	push   $0x802aab
  801605:	68 84 01 00 00       	push   $0x184
  80160a:	68 c8 2a 80 00       	push   $0x802ac8
  80160f:	e8 e4 ea ff ff       	call   8000f8 <_panic>
			sys_page_unmap(0, UTEMP);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	68 00 00 40 00       	push   $0x400000
  80161c:	6a 00                	push   $0x0
  80161e:	e8 2f f6 ff ff       	call   800c52 <sys_page_unmap>
  801623:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801626:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80162c:	89 de                	mov    %ebx,%esi
  80162e:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801631:	0f 87 23 ff ff ff    	ja     80155a <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
  80163c:	eb 05                	jmp    801643 <map_segment+0x123>
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801643:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	57                   	push   %edi
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	83 ec 2c             	sub    $0x2c,%esp
  801654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801657:	89 d7                	mov    %edx,%edi
  801659:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80165c:	8b 02                	mov    (%edx),%eax
  80165e:	85 c0                	test   %eax,%eax
  801660:	74 31                	je     801693 <init_stack+0x48>
  801662:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801667:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	50                   	push   %eax
  801670:	e8 bf f0 ff ff       	call   800734 <strlen>
  801675:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801679:	43                   	inc    %ebx
  80167a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801681:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	75 e1                	jne    80166c <init_stack+0x21>
  80168b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80168e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801691:	eb 18                	jmp    8016ab <init_stack+0x60>
  801693:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80169a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016a6:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016ab:	f7 de                	neg    %esi
  8016ad:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8016b3:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016b6:	89 f2                	mov    %esi,%edx
  8016b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	f7 d0                	not    %eax
  8016bf:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8016c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016c5:	83 e8 08             	sub    $0x8,%eax
  8016c8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016cd:	0f 86 fb 00 00 00    	jbe    8017ce <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	6a 07                	push   $0x7
  8016d8:	68 00 00 40 00       	push   $0x400000
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 24 f5 ff ff       	call   800c08 <sys_page_alloc>
  8016e4:	89 c6                	mov    %eax,%esi
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	0f 88 e9 00 00 00    	js     8017da <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016f1:	85 db                	test   %ebx,%ebx
  8016f3:	7e 3e                	jle    801733 <init_stack+0xe8>
  8016f5:	be 00 00 00 00       	mov    $0x0,%esi
  8016fa:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8016fd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801700:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801706:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801709:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801712:	53                   	push   %ebx
  801713:	e8 6e f0 ff ff       	call   800786 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801718:	83 c4 04             	add    $0x4,%esp
  80171b:	ff 34 b7             	pushl  (%edi,%esi,4)
  80171e:	e8 11 f0 ff ff       	call   800734 <strlen>
  801723:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801727:	46                   	inc    %esi
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  80172e:	7c d0                	jl     801700 <init_stack+0xb5>
  801730:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801736:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801739:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801740:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801747:	74 19                	je     801762 <init_stack+0x117>
  801749:	68 38 2b 80 00       	push   $0x802b38
  80174e:	68 7f 2a 80 00       	push   $0x802a7f
  801753:	68 51 01 00 00       	push   $0x151
  801758:	68 c8 2a 80 00       	push   $0x802ac8
  80175d:	e8 96 e9 ff ff       	call   8000f8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801765:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80176a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80176d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801770:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801773:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801776:	89 d0                	mov    %edx,%eax
  801778:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80177d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801780:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	6a 07                	push   $0x7
  801787:	ff 75 08             	pushl  0x8(%ebp)
  80178a:	ff 75 d8             	pushl  -0x28(%ebp)
  80178d:	68 00 00 40 00       	push   $0x400000
  801792:	6a 00                	push   $0x0
  801794:	e8 93 f4 ff ff       	call   800c2c <sys_page_map>
  801799:	89 c6                	mov    %eax,%esi
  80179b:	83 c4 20             	add    $0x20,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 18                	js     8017ba <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	68 00 00 40 00       	push   $0x400000
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 a1 f4 ff ff       	call   800c52 <sys_page_unmap>
  8017b1:	89 c6                	mov    %eax,%esi
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	79 1b                	jns    8017d5 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	68 00 00 40 00       	push   $0x400000
  8017c2:	6a 00                	push   $0x0
  8017c4:	e8 89 f4 ff ff       	call   800c52 <sys_page_unmap>
	return r;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	eb 0c                	jmp    8017da <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8017ce:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  8017d3:	eb 05                	jmp    8017da <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  8017d5:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  8017da:	89 f0                	mov    %esi,%eax
  8017dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5f                   	pop    %edi
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	57                   	push   %edi
  8017e8:	56                   	push   %esi
  8017e9:	53                   	push   %ebx
  8017ea:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017f0:	6a 00                	push   $0x0
  8017f2:	ff 75 08             	pushl  0x8(%ebp)
  8017f5:	e8 96 fc ff ff       	call   801490 <open>
  8017fa:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 88 45 02 00 00    	js     801a50 <spawn+0x26c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	68 00 02 00 00       	push   $0x200
  801813:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801820:	e8 ee f8 ff ff       	call   801113 <readn>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	3d 00 02 00 00       	cmp    $0x200,%eax
  80182d:	75 0c                	jne    80183b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80182f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801836:	45 4c 46 
  801839:	74 38                	je     801873 <spawn+0x8f>
		close(fd);
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801844:	e8 06 f7 ff ff       	call   800f4f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801849:	83 c4 0c             	add    $0xc,%esp
  80184c:	68 7f 45 4c 46       	push   $0x464c457f
  801851:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801857:	68 d4 2a 80 00       	push   $0x802ad4
  80185c:	e8 6f e9 ff ff       	call   8001d0 <cprintf>
		return -E_NOT_EXEC;
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  80186b:	ff ff ff 
  80186e:	e9 f1 01 00 00       	jmp    801a64 <spawn+0x280>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801873:	ba 07 00 00 00       	mov    $0x7,%edx
  801878:	89 d0                	mov    %edx,%eax
  80187a:	cd 30                	int    $0x30
  80187c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801882:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801888:	85 c0                	test   %eax,%eax
  80188a:	0f 88 d4 01 00 00    	js     801a64 <spawn+0x280>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801890:	25 ff 03 00 00       	and    $0x3ff,%eax
  801895:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80189c:	c1 e0 07             	shl    $0x7,%eax
  80189f:	29 d0                	sub    %edx,%eax
  8018a1:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8018a7:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018ad:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018b4:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018ba:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  8018c9:	68 00 d0 bf ee       	push   $0xeebfd000
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8018d7:	e8 6f fd ff ff       	call   80164b <init_stack>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 77 01 00 00    	js     801a5e <spawn+0x27a>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018e7:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018ed:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8018f4:	00 
  8018f5:	74 5d                	je     801954 <spawn+0x170>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018f7:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018fe:	be 00 00 00 00       	mov    $0x0,%esi
  801903:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801909:	83 3b 01             	cmpl   $0x1,(%ebx)
  80190c:	75 35                	jne    801943 <spawn+0x15f>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80190e:	8b 43 18             	mov    0x18(%ebx),%eax
  801911:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801914:	83 f8 01             	cmp    $0x1,%eax
  801917:	19 c0                	sbb    %eax,%eax
  801919:	83 e0 fe             	and    $0xfffffffe,%eax
  80191c:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80191f:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801922:	8b 53 08             	mov    0x8(%ebx),%edx
  801925:	50                   	push   %eax
  801926:	ff 73 04             	pushl  0x4(%ebx)
  801929:	ff 73 10             	pushl  0x10(%ebx)
  80192c:	57                   	push   %edi
  80192d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801933:	e8 e8 fb ff ff       	call   801520 <map_segment>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	0f 88 e4 00 00 00    	js     801a27 <spawn+0x243>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801943:	46                   	inc    %esi
  801944:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80194b:	39 f0                	cmp    %esi,%eax
  80194d:	7e 05                	jle    801954 <spawn+0x170>
  80194f:	83 c3 20             	add    $0x20,%ebx
  801952:	eb b5                	jmp    801909 <spawn+0x125>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80195d:	e8 ed f5 ff ff       	call   800f4f <close>
  801962:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801965:	bb 00 00 00 00       	mov    $0x0,%ebx
  80196a:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801970:	89 d8                	mov    %ebx,%eax
  801972:	c1 e8 16             	shr    $0x16,%eax
  801975:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80197c:	a8 01                	test   $0x1,%al
  80197e:	74 3e                	je     8019be <spawn+0x1da>
  801980:	89 d8                	mov    %ebx,%eax
  801982:	c1 e8 0c             	shr    $0xc,%eax
  801985:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80198c:	f6 c2 01             	test   $0x1,%dl
  80198f:	74 2d                	je     8019be <spawn+0x1da>
  801991:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801998:	f6 c6 04             	test   $0x4,%dh
  80199b:	74 21                	je     8019be <spawn+0x1da>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  80199d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8019ac:	50                   	push   %eax
  8019ad:	53                   	push   %ebx
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 75 f2 ff ff       	call   800c2c <sys_page_map>
        if (r < 0) return r;
  8019b7:	83 c4 20             	add    $0x20,%esp
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 13                	js     8019d1 <spawn+0x1ed>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8019be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019c4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019ca:	75 a4                	jne    801970 <spawn+0x18c>
  8019cc:	e9 a1 00 00 00       	jmp    801a72 <spawn+0x28e>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8019d1:	50                   	push   %eax
  8019d2:	68 ee 2a 80 00       	push   $0x802aee
  8019d7:	68 85 00 00 00       	push   $0x85
  8019dc:	68 c8 2a 80 00       	push   $0x802ac8
  8019e1:	e8 12 e7 ff ff       	call   8000f8 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8019e6:	50                   	push   %eax
  8019e7:	68 04 2b 80 00       	push   $0x802b04
  8019ec:	68 88 00 00 00       	push   $0x88
  8019f1:	68 c8 2a 80 00       	push   $0x802ac8
  8019f6:	e8 fd e6 ff ff       	call   8000f8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	6a 02                	push   $0x2
  801a00:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a06:	e8 6a f2 ff ff       	call   800c75 <sys_env_set_status>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	79 52                	jns    801a64 <spawn+0x280>
		panic("sys_env_set_status: %e", r);
  801a12:	50                   	push   %eax
  801a13:	68 1e 2b 80 00       	push   $0x802b1e
  801a18:	68 8b 00 00 00       	push   $0x8b
  801a1d:	68 c8 2a 80 00       	push   $0x802ac8
  801a22:	e8 d1 e6 ff ff       	call   8000f8 <_panic>
  801a27:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a32:	e8 64 f1 ff ff       	call   800b9b <sys_env_destroy>
	close(fd);
  801a37:	83 c4 04             	add    $0x4,%esp
  801a3a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a40:	e8 0a f5 ff ff       	call   800f4f <close>
	return r;
  801a45:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a48:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801a4e:	eb 14                	jmp    801a64 <spawn+0x280>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a50:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801a56:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a5c:	eb 06                	jmp    801a64 <spawn+0x280>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801a5e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a64:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5f                   	pop    %edi
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a72:	83 ec 08             	sub    $0x8,%esp
  801a75:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a7b:	50                   	push   %eax
  801a7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a82:	e8 11 f2 ff ff       	call   800c98 <sys_env_set_trapframe>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	0f 89 69 ff ff ff    	jns    8019fb <spawn+0x217>
  801a92:	e9 4f ff ff ff       	jmp    8019e6 <spawn+0x202>

00801a97 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801aa3:	6a 00                	push   $0x0
  801aa5:	ff 75 08             	pushl  0x8(%ebp)
  801aa8:	e8 e3 f9 ff ff       	call   801490 <open>
  801aad:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	0f 88 a9 01 00 00    	js     801c67 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801abe:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ac4:	83 ec 04             	sub    $0x4,%esp
  801ac7:	68 00 02 00 00       	push   $0x200
  801acc:	57                   	push   %edi
  801acd:	50                   	push   %eax
  801ace:	e8 40 f6 ff ff       	call   801113 <readn>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	3d 00 02 00 00       	cmp    $0x200,%eax
  801adb:	75 0c                	jne    801ae9 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801add:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ae4:	45 4c 46 
  801ae7:	74 34                	je     801b1d <exec+0x86>
		close(fd);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801af2:	e8 58 f4 ff ff       	call   800f4f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801af7:	83 c4 0c             	add    $0xc,%esp
  801afa:	68 7f 45 4c 46       	push   $0x464c457f
  801aff:	ff 37                	pushl  (%edi)
  801b01:	68 d4 2a 80 00       	push   $0x802ad4
  801b06:	e8 c5 e6 ff ff       	call   8001d0 <cprintf>
		return -E_NOT_EXEC;
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801b15:	ff ff ff 
  801b18:	e9 4a 01 00 00       	jmp    801c67 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b1d:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b20:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801b25:	0f 84 8b 00 00 00    	je     801bb6 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b2b:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801b32:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801b39:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b3c:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801b41:	83 3b 01             	cmpl   $0x1,(%ebx)
  801b44:	75 62                	jne    801ba8 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b46:	8b 43 18             	mov    0x18(%ebx),%eax
  801b49:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801b4c:	83 f8 01             	cmp    $0x1,%eax
  801b4f:	19 c0                	sbb    %eax,%eax
  801b51:	83 e0 fe             	and    $0xfffffffe,%eax
  801b54:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801b57:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801b5a:	8b 53 08             	mov    0x8(%ebx),%edx
  801b5d:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801b63:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801b69:	50                   	push   %eax
  801b6a:	ff 73 04             	pushl  0x4(%ebx)
  801b6d:	ff 73 10             	pushl  0x10(%ebx)
  801b70:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7b:	e8 a0 f9 ff ff       	call   801520 <map_segment>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 a3 00 00 00    	js     801c2e <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801b8b:	8b 53 14             	mov    0x14(%ebx),%edx
  801b8e:	8b 43 08             	mov    0x8(%ebx),%eax
  801b91:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b96:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801b9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801ba2:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ba8:	46                   	inc    %esi
  801ba9:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801bad:	39 f0                	cmp    %esi,%eax
  801baf:	7e 0f                	jle    801bc0 <exec+0x129>
  801bb1:	83 c3 20             	add    $0x20,%ebx
  801bb4:	eb 8b                	jmp    801b41 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801bb6:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801bbd:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801bc9:	e8 81 f3 ff ff       	call   800f4f <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801bce:	83 c4 04             	add    $0x4,%esp
  801bd1:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801bd7:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801bdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
  801be5:	e8 61 fa ff ff       	call   80164b <init_stack>
  801bea:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 70                	js     801c67 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801bf7:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801bfb:	50                   	push   %eax
  801bfc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c02:	03 47 1c             	add    0x1c(%edi),%eax
  801c05:	50                   	push   %eax
  801c06:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801c0c:	ff 77 18             	pushl  0x18(%edi)
  801c0f:	e8 34 f1 ff ff       	call   800d48 <sys_exec>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	79 42                	jns    801c5d <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801c1b:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801c21:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801c27:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801c2c:	eb 0c                	jmp    801c3a <exec+0x1a3>
  801c2e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801c34:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	6a 00                	push   $0x0
  801c3f:	e8 57 ef ff ff       	call   800b9b <sys_env_destroy>
	close(fd);
  801c44:	89 1c 24             	mov    %ebx,(%esp)
  801c47:	e8 03 f3 ff ff       	call   800f4f <close>
	return r;
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801c55:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801c5b:	eb 0a                	jmp    801c67 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801c5d:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801c64:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801c67:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	56                   	push   %esi
  801c79:	53                   	push   %ebx
  801c7a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c7d:	8d 45 14             	lea    0x14(%ebp),%eax
  801c80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c84:	74 5f                	je     801ce5 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801c86:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801c8b:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	83 c0 04             	add    $0x4,%eax
  801c91:	83 3a 00             	cmpl   $0x0,(%edx)
  801c94:	75 f5                	jne    801c8b <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c96:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801c9d:	83 e0 f0             	and    $0xfffffff0,%eax
  801ca0:	29 c4                	sub    %eax,%esp
  801ca2:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801ca6:	83 e0 f0             	and    $0xfffffff0,%eax
  801ca9:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801cab:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801cad:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801cb4:	00 

	va_start(vl, arg0);
  801cb5:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801cb8:	89 ce                	mov    %ecx,%esi
  801cba:	85 c9                	test   %ecx,%ecx
  801cbc:	74 14                	je     801cd2 <execl+0x5d>
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801cc3:	40                   	inc    %eax
  801cc4:	89 d1                	mov    %edx,%ecx
  801cc6:	83 c2 04             	add    $0x4,%edx
  801cc9:	8b 09                	mov    (%ecx),%ecx
  801ccb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801cce:	39 f0                	cmp    %esi,%eax
  801cd0:	72 f1                	jb     801cc3 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  801cd2:	83 ec 08             	sub    $0x8,%esp
  801cd5:	53                   	push   %ebx
  801cd6:	ff 75 08             	pushl  0x8(%ebp)
  801cd9:	e8 b9 fd ff ff       	call   801a97 <exec>
}
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ce5:	83 ec 20             	sub    $0x20,%esp
  801ce8:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801cec:	83 e0 f0             	and    $0xfffffff0,%eax
  801cef:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801cf1:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801cf3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801cfa:	eb d6                	jmp    801cd2 <execl+0x5d>

00801cfc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d04:	8d 45 14             	lea    0x14(%ebp),%eax
  801d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0b:	74 5f                	je     801d6c <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d0d:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d12:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	83 c0 04             	add    $0x4,%eax
  801d18:	83 3a 00             	cmpl   $0x0,(%edx)
  801d1b:	75 f5                	jne    801d12 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d1d:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d24:	83 e0 f0             	and    $0xfffffff0,%eax
  801d27:	29 c4                	sub    %eax,%esp
  801d29:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d2d:	83 e0 f0             	and    $0xfffffff0,%eax
  801d30:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d32:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d34:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801d3b:	00 

	va_start(vl, arg0);
  801d3c:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d3f:	89 ce                	mov    %ecx,%esi
  801d41:	85 c9                	test   %ecx,%ecx
  801d43:	74 14                	je     801d59 <spawnl+0x5d>
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801d4a:	40                   	inc    %eax
  801d4b:	89 d1                	mov    %edx,%ecx
  801d4d:	83 c2 04             	add    $0x4,%edx
  801d50:	8b 09                	mov    (%ecx),%ecx
  801d52:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d55:	39 f0                	cmp    %esi,%eax
  801d57:	72 f1                	jb     801d4a <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	53                   	push   %ebx
  801d5d:	ff 75 08             	pushl  0x8(%ebp)
  801d60:	e8 7f fa ff ff       	call   8017e4 <spawn>
}
  801d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d6c:	83 ec 20             	sub    $0x20,%esp
  801d6f:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d73:	83 e0 f0             	and    $0xfffffff0,%eax
  801d76:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d78:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d7a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801d81:	eb d6                	jmp    801d59 <spawnl+0x5d>
	...

00801d84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d8c:	83 ec 0c             	sub    $0xc,%esp
  801d8f:	ff 75 08             	pushl  0x8(%ebp)
  801d92:	e8 e9 ef ff ff       	call   800d80 <fd2data>
  801d97:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d99:	83 c4 08             	add    $0x8,%esp
  801d9c:	68 60 2b 80 00       	push   $0x802b60
  801da1:	56                   	push   %esi
  801da2:	e8 df e9 ff ff       	call   800786 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801da7:	8b 43 04             	mov    0x4(%ebx),%eax
  801daa:	2b 03                	sub    (%ebx),%eax
  801dac:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801db2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801db9:	00 00 00 
	stat->st_dev = &devpipe;
  801dbc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dc3:	30 80 00 
	return 0;
}
  801dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	53                   	push   %ebx
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ddc:	53                   	push   %ebx
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 6e ee ff ff       	call   800c52 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801de4:	89 1c 24             	mov    %ebx,(%esp)
  801de7:	e8 94 ef ff ff       	call   800d80 <fd2data>
  801dec:	83 c4 08             	add    $0x8,%esp
  801def:	50                   	push   %eax
  801df0:	6a 00                	push   $0x0
  801df2:	e8 5b ee ff ff       	call   800c52 <sys_page_unmap>
}
  801df7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	83 ec 1c             	sub    $0x1c,%esp
  801e05:	89 c7                	mov    %eax,%edi
  801e07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	57                   	push   %edi
  801e16:	e8 95 05 00 00       	call   8023b0 <pageref>
  801e1b:	89 c6                	mov    %eax,%esi
  801e1d:	83 c4 04             	add    $0x4,%esp
  801e20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e23:	e8 88 05 00 00       	call   8023b0 <pageref>
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	39 c6                	cmp    %eax,%esi
  801e2d:	0f 94 c0             	sete   %al
  801e30:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e33:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e39:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e3c:	39 cb                	cmp    %ecx,%ebx
  801e3e:	75 08                	jne    801e48 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e48:	83 f8 01             	cmp    $0x1,%eax
  801e4b:	75 bd                	jne    801e0a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e4d:	8b 42 58             	mov    0x58(%edx),%eax
  801e50:	6a 01                	push   $0x1
  801e52:	50                   	push   %eax
  801e53:	53                   	push   %ebx
  801e54:	68 67 2b 80 00       	push   $0x802b67
  801e59:	e8 72 e3 ff ff       	call   8001d0 <cprintf>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	eb a7                	jmp    801e0a <_pipeisclosed+0xe>

00801e63 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	57                   	push   %edi
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	83 ec 28             	sub    $0x28,%esp
  801e6c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e6f:	56                   	push   %esi
  801e70:	e8 0b ef ff ff       	call   800d80 <fd2data>
  801e75:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7e:	75 4a                	jne    801eca <devpipe_write+0x67>
  801e80:	bf 00 00 00 00       	mov    $0x0,%edi
  801e85:	eb 56                	jmp    801edd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e87:	89 da                	mov    %ebx,%edx
  801e89:	89 f0                	mov    %esi,%eax
  801e8b:	e8 6c ff ff ff       	call   801dfc <_pipeisclosed>
  801e90:	85 c0                	test   %eax,%eax
  801e92:	75 4d                	jne    801ee1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e94:	e8 48 ed ff ff       	call   800be1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e99:	8b 43 04             	mov    0x4(%ebx),%eax
  801e9c:	8b 13                	mov    (%ebx),%edx
  801e9e:	83 c2 20             	add    $0x20,%edx
  801ea1:	39 d0                	cmp    %edx,%eax
  801ea3:	73 e2                	jae    801e87 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ea5:	89 c2                	mov    %eax,%edx
  801ea7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ead:	79 05                	jns    801eb4 <devpipe_write+0x51>
  801eaf:	4a                   	dec    %edx
  801eb0:	83 ca e0             	or     $0xffffffe0,%edx
  801eb3:	42                   	inc    %edx
  801eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801eba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ebe:	40                   	inc    %eax
  801ebf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec2:	47                   	inc    %edi
  801ec3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ec6:	77 07                	ja     801ecf <devpipe_write+0x6c>
  801ec8:	eb 13                	jmp    801edd <devpipe_write+0x7a>
  801eca:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ecf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ed2:	8b 13                	mov    (%ebx),%edx
  801ed4:	83 c2 20             	add    $0x20,%edx
  801ed7:	39 d0                	cmp    %edx,%eax
  801ed9:	73 ac                	jae    801e87 <devpipe_write+0x24>
  801edb:	eb c8                	jmp    801ea5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801edd:	89 f8                	mov    %edi,%eax
  801edf:	eb 05                	jmp    801ee6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee9:	5b                   	pop    %ebx
  801eea:	5e                   	pop    %esi
  801eeb:	5f                   	pop    %edi
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 18             	sub    $0x18,%esp
  801ef7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801efa:	57                   	push   %edi
  801efb:	e8 80 ee ff ff       	call   800d80 <fd2data>
  801f00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f09:	75 44                	jne    801f4f <devpipe_read+0x61>
  801f0b:	be 00 00 00 00       	mov    $0x0,%esi
  801f10:	eb 4f                	jmp    801f61 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f12:	89 f0                	mov    %esi,%eax
  801f14:	eb 54                	jmp    801f6a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f16:	89 da                	mov    %ebx,%edx
  801f18:	89 f8                	mov    %edi,%eax
  801f1a:	e8 dd fe ff ff       	call   801dfc <_pipeisclosed>
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	75 42                	jne    801f65 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f23:	e8 b9 ec ff ff       	call   800be1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f28:	8b 03                	mov    (%ebx),%eax
  801f2a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f2d:	74 e7                	je     801f16 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f2f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f34:	79 05                	jns    801f3b <devpipe_read+0x4d>
  801f36:	48                   	dec    %eax
  801f37:	83 c8 e0             	or     $0xffffffe0,%eax
  801f3a:	40                   	inc    %eax
  801f3b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f42:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f45:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f47:	46                   	inc    %esi
  801f48:	39 75 10             	cmp    %esi,0x10(%ebp)
  801f4b:	77 07                	ja     801f54 <devpipe_read+0x66>
  801f4d:	eb 12                	jmp    801f61 <devpipe_read+0x73>
  801f4f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801f54:	8b 03                	mov    (%ebx),%eax
  801f56:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f59:	75 d4                	jne    801f2f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f5b:	85 f6                	test   %esi,%esi
  801f5d:	75 b3                	jne    801f12 <devpipe_read+0x24>
  801f5f:	eb b5                	jmp    801f16 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	eb 05                	jmp    801f6a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 28             	sub    $0x28,%esp
  801f7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	e8 11 ee ff ff       	call   800d98 <fd_alloc>
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	0f 88 24 01 00 00    	js     8020b8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f94:	83 ec 04             	sub    $0x4,%esp
  801f97:	68 07 04 00 00       	push   $0x407
  801f9c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 62 ec ff ff       	call   800c08 <sys_page_alloc>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	0f 88 05 01 00 00    	js     8020b8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fb3:	83 ec 0c             	sub    $0xc,%esp
  801fb6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	e8 d9 ed ff ff       	call   800d98 <fd_alloc>
  801fbf:	89 c3                	mov    %eax,%ebx
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	0f 88 dc 00 00 00    	js     8020a8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fcc:	83 ec 04             	sub    $0x4,%esp
  801fcf:	68 07 04 00 00       	push   $0x407
  801fd4:	ff 75 e0             	pushl  -0x20(%ebp)
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 2a ec ff ff       	call   800c08 <sys_page_alloc>
  801fde:	89 c3                	mov    %eax,%ebx
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	0f 88 bd 00 00 00    	js     8020a8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801feb:	83 ec 0c             	sub    $0xc,%esp
  801fee:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ff1:	e8 8a ed ff ff       	call   800d80 <fd2data>
  801ff6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff8:	83 c4 0c             	add    $0xc,%esp
  801ffb:	68 07 04 00 00       	push   $0x407
  802000:	50                   	push   %eax
  802001:	6a 00                	push   $0x0
  802003:	e8 00 ec ff ff       	call   800c08 <sys_page_alloc>
  802008:	89 c3                	mov    %eax,%ebx
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	0f 88 83 00 00 00    	js     802098 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	ff 75 e0             	pushl  -0x20(%ebp)
  80201b:	e8 60 ed ff ff       	call   800d80 <fd2data>
  802020:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802027:	50                   	push   %eax
  802028:	6a 00                	push   $0x0
  80202a:	56                   	push   %esi
  80202b:	6a 00                	push   $0x0
  80202d:	e8 fa eb ff ff       	call   800c2c <sys_page_map>
  802032:	89 c3                	mov    %eax,%ebx
  802034:	83 c4 20             	add    $0x20,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	78 4f                	js     80208a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80203b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802044:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802046:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802049:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802050:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802056:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802059:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80205b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80205e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802065:	83 ec 0c             	sub    $0xc,%esp
  802068:	ff 75 e4             	pushl  -0x1c(%ebp)
  80206b:	e8 00 ed ff ff       	call   800d70 <fd2num>
  802070:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802072:	83 c4 04             	add    $0x4,%esp
  802075:	ff 75 e0             	pushl  -0x20(%ebp)
  802078:	e8 f3 ec ff ff       	call   800d70 <fd2num>
  80207d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	bb 00 00 00 00       	mov    $0x0,%ebx
  802088:	eb 2e                	jmp    8020b8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80208a:	83 ec 08             	sub    $0x8,%esp
  80208d:	56                   	push   %esi
  80208e:	6a 00                	push   $0x0
  802090:	e8 bd eb ff ff       	call   800c52 <sys_page_unmap>
  802095:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802098:	83 ec 08             	sub    $0x8,%esp
  80209b:	ff 75 e0             	pushl  -0x20(%ebp)
  80209e:	6a 00                	push   $0x0
  8020a0:	e8 ad eb ff ff       	call   800c52 <sys_page_unmap>
  8020a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020a8:	83 ec 08             	sub    $0x8,%esp
  8020ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 9d eb ff ff       	call   800c52 <sys_page_unmap>
  8020b5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cb:	50                   	push   %eax
  8020cc:	ff 75 08             	pushl  0x8(%ebp)
  8020cf:	e8 37 ed ff ff       	call   800e0b <fd_lookup>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 18                	js     8020f3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e1:	e8 9a ec ff ff       	call   800d80 <fd2data>
	return _pipeisclosed(fd, p);
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	e8 0c fd ff ff       	call   801dfc <_pipeisclosed>
  8020f0:	83 c4 10             	add    $0x10,%esp
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    
  8020f5:	00 00                	add    %al,(%eax)
	...

008020f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802100:	c9                   	leave  
  802101:	c3                   	ret    

00802102 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802108:	68 7f 2b 80 00       	push   $0x802b7f
  80210d:	ff 75 0c             	pushl  0xc(%ebp)
  802110:	e8 71 e6 ff ff       	call   800786 <strcpy>
	return 0;
}
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802128:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80212c:	74 45                	je     802173 <devcons_write+0x57>
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
  802133:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802138:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80213e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802141:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802143:	83 fb 7f             	cmp    $0x7f,%ebx
  802146:	76 05                	jbe    80214d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802148:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80214d:	83 ec 04             	sub    $0x4,%esp
  802150:	53                   	push   %ebx
  802151:	03 45 0c             	add    0xc(%ebp),%eax
  802154:	50                   	push   %eax
  802155:	57                   	push   %edi
  802156:	e8 ec e7 ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  80215b:	83 c4 08             	add    $0x8,%esp
  80215e:	53                   	push   %ebx
  80215f:	57                   	push   %edi
  802160:	e8 ec e9 ff ff       	call   800b51 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802165:	01 de                	add    %ebx,%esi
  802167:	89 f0                	mov    %esi,%eax
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80216f:	72 cd                	jb     80213e <devcons_write+0x22>
  802171:	eb 05                	jmp    802178 <devcons_write+0x5c>
  802173:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802178:	89 f0                	mov    %esi,%eax
  80217a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	c9                   	leave  
  802181:	c3                   	ret    

00802182 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802188:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80218c:	75 07                	jne    802195 <devcons_read+0x13>
  80218e:	eb 25                	jmp    8021b5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802190:	e8 4c ea ff ff       	call   800be1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802195:	e8 dd e9 ff ff       	call   800b77 <sys_cgetc>
  80219a:	85 c0                	test   %eax,%eax
  80219c:	74 f2                	je     802190 <devcons_read+0xe>
  80219e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	78 1d                	js     8021c1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021a4:	83 f8 04             	cmp    $0x4,%eax
  8021a7:	74 13                	je     8021bc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ac:	88 10                	mov    %dl,(%eax)
	return 1;
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	eb 0c                	jmp    8021c1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ba:	eb 05                	jmp    8021c1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    

008021c3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021cf:	6a 01                	push   $0x1
  8021d1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	e8 77 e9 ff ff       	call   800b51 <sys_cputs>
  8021da:	83 c4 10             	add    $0x10,%esp
}
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    

008021df <getchar>:

int
getchar(void)
{
  8021df:	55                   	push   %ebp
  8021e0:	89 e5                	mov    %esp,%ebp
  8021e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e5:	6a 01                	push   $0x1
  8021e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ea:	50                   	push   %eax
  8021eb:	6a 00                	push   $0x0
  8021ed:	e8 9a ee ff ff       	call   80108c <read>
	if (r < 0)
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	78 0f                	js     802208 <getchar+0x29>
		return r;
	if (r < 1)
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	7e 06                	jle    802203 <getchar+0x24>
		return -E_EOF;
	return c;
  8021fd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802201:	eb 05                	jmp    802208 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802203:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802208:	c9                   	leave  
  802209:	c3                   	ret    

0080220a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802213:	50                   	push   %eax
  802214:	ff 75 08             	pushl  0x8(%ebp)
  802217:	e8 ef eb ff ff       	call   800e0b <fd_lookup>
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	85 c0                	test   %eax,%eax
  802221:	78 11                	js     802234 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802223:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802226:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80222c:	39 10                	cmp    %edx,(%eax)
  80222e:	0f 94 c0             	sete   %al
  802231:	0f b6 c0             	movzbl %al,%eax
}
  802234:	c9                   	leave  
  802235:	c3                   	ret    

00802236 <opencons>:

int
opencons(void)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80223c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223f:	50                   	push   %eax
  802240:	e8 53 eb ff ff       	call   800d98 <fd_alloc>
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	85 c0                	test   %eax,%eax
  80224a:	78 3a                	js     802286 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224c:	83 ec 04             	sub    $0x4,%esp
  80224f:	68 07 04 00 00       	push   $0x407
  802254:	ff 75 f4             	pushl  -0xc(%ebp)
  802257:	6a 00                	push   $0x0
  802259:	e8 aa e9 ff ff       	call   800c08 <sys_page_alloc>
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	85 c0                	test   %eax,%eax
  802263:	78 21                	js     802286 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802265:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80226b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80227a:	83 ec 0c             	sub    $0xc,%esp
  80227d:	50                   	push   %eax
  80227e:	e8 ed ea ff ff       	call   800d70 <fd2num>
  802283:	83 c4 10             	add    $0x10,%esp
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	56                   	push   %esi
  80228c:	53                   	push   %ebx
  80228d:	8b 75 08             	mov    0x8(%ebp),%esi
  802290:	8b 45 0c             	mov    0xc(%ebp),%eax
  802293:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802296:	85 c0                	test   %eax,%eax
  802298:	74 0e                	je     8022a8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	50                   	push   %eax
  80229e:	e8 60 ea ff ff       	call   800d03 <sys_ipc_recv>
  8022a3:	83 c4 10             	add    $0x10,%esp
  8022a6:	eb 10                	jmp    8022b8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8022a8:	83 ec 0c             	sub    $0xc,%esp
  8022ab:	68 00 00 c0 ee       	push   $0xeec00000
  8022b0:	e8 4e ea ff ff       	call   800d03 <sys_ipc_recv>
  8022b5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	75 26                	jne    8022e2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8022bc:	85 f6                	test   %esi,%esi
  8022be:	74 0a                	je     8022ca <ipc_recv+0x42>
  8022c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8022c5:	8b 40 74             	mov    0x74(%eax),%eax
  8022c8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8022ca:	85 db                	test   %ebx,%ebx
  8022cc:	74 0a                	je     8022d8 <ipc_recv+0x50>
  8022ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8022d3:	8b 40 78             	mov    0x78(%eax),%eax
  8022d6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8022d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8022dd:	8b 40 70             	mov    0x70(%eax),%eax
  8022e0:	eb 14                	jmp    8022f6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8022e2:	85 f6                	test   %esi,%esi
  8022e4:	74 06                	je     8022ec <ipc_recv+0x64>
  8022e6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8022ec:	85 db                	test   %ebx,%ebx
  8022ee:	74 06                	je     8022f6 <ipc_recv+0x6e>
  8022f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8022f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f9:	5b                   	pop    %ebx
  8022fa:	5e                   	pop    %esi
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	57                   	push   %edi
  802301:	56                   	push   %esi
  802302:	53                   	push   %ebx
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80230c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80230f:	85 db                	test   %ebx,%ebx
  802311:	75 25                	jne    802338 <ipc_send+0x3b>
  802313:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802318:	eb 1e                	jmp    802338 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80231a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231d:	75 07                	jne    802326 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80231f:	e8 bd e8 ff ff       	call   800be1 <sys_yield>
  802324:	eb 12                	jmp    802338 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802326:	50                   	push   %eax
  802327:	68 8b 2b 80 00       	push   $0x802b8b
  80232c:	6a 43                	push   $0x43
  80232e:	68 9e 2b 80 00       	push   $0x802b9e
  802333:	e8 c0 dd ff ff       	call   8000f8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802338:	56                   	push   %esi
  802339:	53                   	push   %ebx
  80233a:	57                   	push   %edi
  80233b:	ff 75 08             	pushl  0x8(%ebp)
  80233e:	e8 9b e9 ff ff       	call   800cde <sys_ipc_try_send>
  802343:	83 c4 10             	add    $0x10,%esp
  802346:	85 c0                	test   %eax,%eax
  802348:	75 d0                	jne    80231a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80234a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	c9                   	leave  
  802351:	c3                   	ret    

00802352 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	53                   	push   %ebx
  802356:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802359:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80235f:	74 22                	je     802383 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802366:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80236d:	89 c2                	mov    %eax,%edx
  80236f:	c1 e2 07             	shl    $0x7,%edx
  802372:	29 ca                	sub    %ecx,%edx
  802374:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80237a:	8b 52 50             	mov    0x50(%edx),%edx
  80237d:	39 da                	cmp    %ebx,%edx
  80237f:	75 1d                	jne    80239e <ipc_find_env+0x4c>
  802381:	eb 05                	jmp    802388 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802383:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802388:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80238f:	c1 e0 07             	shl    $0x7,%eax
  802392:	29 d0                	sub    %edx,%eax
  802394:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802399:	8b 40 40             	mov    0x40(%eax),%eax
  80239c:	eb 0c                	jmp    8023aa <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80239e:	40                   	inc    %eax
  80239f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023a4:	75 c0                	jne    802366 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023a6:	66 b8 00 00          	mov    $0x0,%ax
}
  8023aa:	5b                   	pop    %ebx
  8023ab:	c9                   	leave  
  8023ac:	c3                   	ret    
  8023ad:	00 00                	add    %al,(%eax)
	...

008023b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b6:	89 c2                	mov    %eax,%edx
  8023b8:	c1 ea 16             	shr    $0x16,%edx
  8023bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023c2:	f6 c2 01             	test   $0x1,%dl
  8023c5:	74 1e                	je     8023e5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023c7:	c1 e8 0c             	shr    $0xc,%eax
  8023ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023d1:	a8 01                	test   $0x1,%al
  8023d3:	74 17                	je     8023ec <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d5:	c1 e8 0c             	shr    $0xc,%eax
  8023d8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023df:	ef 
  8023e0:	0f b7 c0             	movzwl %ax,%eax
  8023e3:	eb 0c                	jmp    8023f1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ea:	eb 05                	jmp    8023f1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023ec:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023f1:	c9                   	leave  
  8023f2:	c3                   	ret    
	...

008023f4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	57                   	push   %edi
  8023f8:	56                   	push   %esi
  8023f9:	83 ec 10             	sub    $0x10,%esp
  8023fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802402:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802405:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802408:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80240b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80240e:	85 c0                	test   %eax,%eax
  802410:	75 2e                	jne    802440 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802412:	39 f1                	cmp    %esi,%ecx
  802414:	77 5a                	ja     802470 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802416:	85 c9                	test   %ecx,%ecx
  802418:	75 0b                	jne    802425 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80241a:	b8 01 00 00 00       	mov    $0x1,%eax
  80241f:	31 d2                	xor    %edx,%edx
  802421:	f7 f1                	div    %ecx
  802423:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802425:	31 d2                	xor    %edx,%edx
  802427:	89 f0                	mov    %esi,%eax
  802429:	f7 f1                	div    %ecx
  80242b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80242d:	89 f8                	mov    %edi,%eax
  80242f:	f7 f1                	div    %ecx
  802431:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802433:	89 f8                	mov    %edi,%eax
  802435:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802437:	83 c4 10             	add    $0x10,%esp
  80243a:	5e                   	pop    %esi
  80243b:	5f                   	pop    %edi
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    
  80243e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802440:	39 f0                	cmp    %esi,%eax
  802442:	77 1c                	ja     802460 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802444:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	75 3c                	jne    802488 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80244c:	39 f0                	cmp    %esi,%eax
  80244e:	0f 82 90 00 00 00    	jb     8024e4 <__udivdi3+0xf0>
  802454:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802457:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80245a:	0f 86 84 00 00 00    	jbe    8024e4 <__udivdi3+0xf0>
  802460:	31 f6                	xor    %esi,%esi
  802462:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802464:	89 f8                	mov    %edi,%eax
  802466:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802468:	83 c4 10             	add    $0x10,%esp
  80246b:	5e                   	pop    %esi
  80246c:	5f                   	pop    %edi
  80246d:	c9                   	leave  
  80246e:	c3                   	ret    
  80246f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802470:	89 f2                	mov    %esi,%edx
  802472:	89 f8                	mov    %edi,%eax
  802474:	f7 f1                	div    %ecx
  802476:	89 c7                	mov    %eax,%edi
  802478:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80247a:	89 f8                	mov    %edi,%eax
  80247c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80247e:	83 c4 10             	add    $0x10,%esp
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	c9                   	leave  
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802488:	89 f9                	mov    %edi,%ecx
  80248a:	d3 e0                	shl    %cl,%eax
  80248c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80248f:	b8 20 00 00 00       	mov    $0x20,%eax
  802494:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802496:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802499:	88 c1                	mov    %al,%cl
  80249b:	d3 ea                	shr    %cl,%edx
  80249d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8024a0:	09 ca                	or     %ecx,%edx
  8024a2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8024a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024a8:	89 f9                	mov    %edi,%ecx
  8024aa:	d3 e2                	shl    %cl,%edx
  8024ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8024af:	89 f2                	mov    %esi,%edx
  8024b1:	88 c1                	mov    %al,%cl
  8024b3:	d3 ea                	shr    %cl,%edx
  8024b5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8024b8:	89 f2                	mov    %esi,%edx
  8024ba:	89 f9                	mov    %edi,%ecx
  8024bc:	d3 e2                	shl    %cl,%edx
  8024be:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8024c1:	88 c1                	mov    %al,%cl
  8024c3:	d3 ee                	shr    %cl,%esi
  8024c5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024c7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8024ca:	89 f0                	mov    %esi,%eax
  8024cc:	89 ca                	mov    %ecx,%edx
  8024ce:	f7 75 ec             	divl   -0x14(%ebp)
  8024d1:	89 d1                	mov    %edx,%ecx
  8024d3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024d5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024d8:	39 d1                	cmp    %edx,%ecx
  8024da:	72 28                	jb     802504 <__udivdi3+0x110>
  8024dc:	74 1a                	je     8024f8 <__udivdi3+0x104>
  8024de:	89 f7                	mov    %esi,%edi
  8024e0:	31 f6                	xor    %esi,%esi
  8024e2:	eb 80                	jmp    802464 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024e4:	31 f6                	xor    %esi,%esi
  8024e6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024eb:	89 f8                	mov    %edi,%eax
  8024ed:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024ef:	83 c4 10             	add    $0x10,%esp
  8024f2:	5e                   	pop    %esi
  8024f3:	5f                   	pop    %edi
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    
  8024f6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8024fb:	89 f9                	mov    %edi,%ecx
  8024fd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024ff:	39 c2                	cmp    %eax,%edx
  802501:	73 db                	jae    8024de <__udivdi3+0xea>
  802503:	90                   	nop
		{
		  q0--;
  802504:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802507:	31 f6                	xor    %esi,%esi
  802509:	e9 56 ff ff ff       	jmp    802464 <__udivdi3+0x70>
	...

00802510 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	57                   	push   %edi
  802514:	56                   	push   %esi
  802515:	83 ec 20             	sub    $0x20,%esp
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80251e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802521:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802524:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802527:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80252a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80252d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80252f:	85 ff                	test   %edi,%edi
  802531:	75 15                	jne    802548 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802533:	39 f1                	cmp    %esi,%ecx
  802535:	0f 86 99 00 00 00    	jbe    8025d4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80253b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80253d:	89 d0                	mov    %edx,%eax
  80253f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802541:	83 c4 20             	add    $0x20,%esp
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	c9                   	leave  
  802547:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802548:	39 f7                	cmp    %esi,%edi
  80254a:	0f 87 a4 00 00 00    	ja     8025f4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802550:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802553:	83 f0 1f             	xor    $0x1f,%eax
  802556:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802559:	0f 84 a1 00 00 00    	je     802600 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80255f:	89 f8                	mov    %edi,%eax
  802561:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802564:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802566:	bf 20 00 00 00       	mov    $0x20,%edi
  80256b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80256e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 ea                	shr    %cl,%edx
  802575:	09 c2                	or     %eax,%edx
  802577:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80257a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802580:	d3 e0                	shl    %cl,%eax
  802582:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802585:	89 f2                	mov    %esi,%edx
  802587:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802589:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80258c:	d3 e0                	shl    %cl,%eax
  80258e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802591:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802594:	89 f9                	mov    %edi,%ecx
  802596:	d3 e8                	shr    %cl,%eax
  802598:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80259a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80259c:	89 f2                	mov    %esi,%edx
  80259e:	f7 75 f0             	divl   -0x10(%ebp)
  8025a1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025a3:	f7 65 f4             	mull   -0xc(%ebp)
  8025a6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8025a9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025ab:	39 d6                	cmp    %edx,%esi
  8025ad:	72 71                	jb     802620 <__umoddi3+0x110>
  8025af:	74 7f                	je     802630 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025b4:	29 c8                	sub    %ecx,%eax
  8025b6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025b8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	89 f9                	mov    %edi,%ecx
  8025c1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025c3:	09 d0                	or     %edx,%eax
  8025c5:	89 f2                	mov    %esi,%edx
  8025c7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8025ca:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025cc:	83 c4 20             	add    $0x20,%esp
  8025cf:	5e                   	pop    %esi
  8025d0:	5f                   	pop    %edi
  8025d1:	c9                   	leave  
  8025d2:	c3                   	ret    
  8025d3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025d4:	85 c9                	test   %ecx,%ecx
  8025d6:	75 0b                	jne    8025e3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8025dd:	31 d2                	xor    %edx,%edx
  8025df:	f7 f1                	div    %ecx
  8025e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025e3:	89 f0                	mov    %esi,%eax
  8025e5:	31 d2                	xor    %edx,%edx
  8025e7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025ec:	f7 f1                	div    %ecx
  8025ee:	e9 4a ff ff ff       	jmp    80253d <__umoddi3+0x2d>
  8025f3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025f4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025f6:	83 c4 20             	add    $0x20,%esp
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	c9                   	leave  
  8025fc:	c3                   	ret    
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802600:	39 f7                	cmp    %esi,%edi
  802602:	72 05                	jb     802609 <__umoddi3+0xf9>
  802604:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802607:	77 0c                	ja     802615 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802609:	89 f2                	mov    %esi,%edx
  80260b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80260e:	29 c8                	sub    %ecx,%eax
  802610:	19 fa                	sbb    %edi,%edx
  802612:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802618:	83 c4 20             	add    $0x20,%esp
  80261b:	5e                   	pop    %esi
  80261c:	5f                   	pop    %edi
  80261d:	c9                   	leave  
  80261e:	c3                   	ret    
  80261f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802620:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802623:	89 c1                	mov    %eax,%ecx
  802625:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802628:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80262b:	eb 84                	jmp    8025b1 <__umoddi3+0xa1>
  80262d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802630:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802633:	72 eb                	jb     802620 <__umoddi3+0x110>
  802635:	89 f2                	mov    %esi,%edx
  802637:	e9 75 ff ff ff       	jmp    8025b1 <__umoddi3+0xa1>
