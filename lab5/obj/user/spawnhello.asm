
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
  80002c:	e8 4b 00 00 00       	call   80007c <libmain>
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
  800043:	68 a0 23 80 00       	push   $0x8023a0
  800048:	e8 73 01 00 00       	call   8001c0 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004d:	83 c4 0c             	add    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	68 be 23 80 00       	push   $0x8023be
  800057:	68 be 23 80 00       	push   $0x8023be
  80005c:	e8 ca 19 00 00       	call   801a2b <spawnl>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	85 c0                	test   %eax,%eax
  800066:	79 12                	jns    80007a <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800068:	50                   	push   %eax
  800069:	68 c4 23 80 00       	push   $0x8023c4
  80006e:	6a 09                	push   $0x9
  800070:	68 dc 23 80 00       	push   $0x8023dc
  800075:	e8 6e 00 00 00       	call   8000e8 <_panic>
}
  80007a:	c9                   	leave  
  80007b:	c3                   	ret    

0080007c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	8b 75 08             	mov    0x8(%ebp),%esi
  800084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800087:	e8 21 0b 00 00       	call   800bad <sys_getenvid>
  80008c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800091:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800098:	c1 e0 07             	shl    $0x7,%eax
  80009b:	29 d0                	sub    %edx,%eax
  80009d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	85 f6                	test   %esi,%esi
  8000a9:	7e 07                	jle    8000b2 <libmain+0x36>
		binaryname = argv[0];
  8000ab:	8b 03                	mov    (%ebx),%eax
  8000ad:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 78 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0b 00 00 00       	call   8000cc <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
}
  8000c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d2:	e8 6b 0e 00 00       	call   800f42 <close_all>
	sys_env_destroy(0);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 aa 0a 00 00       	call   800b8b <sys_env_destroy>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
	...

008000e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000ed:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000f0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8000f6:	e8 b2 0a 00 00       	call   800bad <sys_getenvid>
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	ff 75 08             	pushl  0x8(%ebp)
  800104:	53                   	push   %ebx
  800105:	50                   	push   %eax
  800106:	68 f8 23 80 00       	push   $0x8023f8
  80010b:	e8 b0 00 00 00       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800110:	83 c4 18             	add    $0x18,%esp
  800113:	56                   	push   %esi
  800114:	ff 75 10             	pushl  0x10(%ebp)
  800117:	e8 53 00 00 00       	call   80016f <vcprintf>
	cprintf("\n");
  80011c:	c7 04 24 15 28 80 00 	movl   $0x802815,(%esp)
  800123:	e8 98 00 00 00       	call   8001c0 <cprintf>
  800128:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80012b:	cc                   	int3   
  80012c:	eb fd                	jmp    80012b <_panic+0x43>
	...

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800143:	40                   	inc    %eax
  800144:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800146:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014b:	75 1a                	jne    800167 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	68 ff 00 00 00       	push   $0xff
  800155:	8d 43 08             	lea    0x8(%ebx),%eax
  800158:	50                   	push   %eax
  800159:	e8 e3 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  80015e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800164:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800167:	ff 43 04             	incl   0x4(%ebx)
}
  80016a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800178:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017f:	00 00 00 
	b.cnt = 0;
  800182:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800189:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018c:	ff 75 0c             	pushl  0xc(%ebp)
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	68 30 01 80 00       	push   $0x800130
  80019e:	e8 82 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	83 c4 08             	add    $0x8,%esp
  8001a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 89 09 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	50                   	push   %eax
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	e8 9d ff ff ff       	call   80016f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 2c             	sub    $0x2c,%esp
  8001dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e0:	89 d6                	mov    %edx,%esi
  8001e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800201:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800204:	72 0c                	jb     800212 <printnum+0x3e>
  800206:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800209:	76 07                	jbe    800212 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020b:	4b                   	dec    %ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7f 31                	jg     800241 <printnum+0x6d>
  800210:	eb 3f                	jmp    800251 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	57                   	push   %edi
  800216:	4b                   	dec    %ebx
  800217:	53                   	push   %ebx
  800218:	50                   	push   %eax
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021f:	ff 75 d0             	pushl  -0x30(%ebp)
  800222:	ff 75 dc             	pushl  -0x24(%ebp)
  800225:	ff 75 d8             	pushl  -0x28(%ebp)
  800228:	e8 27 1f 00 00       	call   802154 <__udivdi3>
  80022d:	83 c4 18             	add    $0x18,%esp
  800230:	52                   	push   %edx
  800231:	50                   	push   %eax
  800232:	89 f2                	mov    %esi,%edx
  800234:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800237:	e8 98 ff ff ff       	call   8001d4 <printnum>
  80023c:	83 c4 20             	add    $0x20,%esp
  80023f:	eb 10                	jmp    800251 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	56                   	push   %esi
  800245:	57                   	push   %edi
  800246:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800249:	4b                   	dec    %ebx
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	7f f0                	jg     800241 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	83 ec 04             	sub    $0x4,%esp
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 07 20 00 00       	call   802270 <__umoddi3>
  800269:	83 c4 14             	add    $0x14,%esp
  80026c:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  800273:	50                   	push   %eax
  800274:	ff 55 e4             	call   *-0x1c(%ebp)
  800277:	83 c4 10             	add    $0x10,%esp
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800285:	83 fa 01             	cmp    $0x1,%edx
  800288:	7e 0e                	jle    800298 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	8b 52 04             	mov    0x4(%edx),%edx
  800296:	eb 22                	jmp    8002ba <getuint+0x38>
	else if (lflag)
  800298:	85 d2                	test   %edx,%edx
  80029a:	74 10                	je     8002ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	eb 0e                	jmp    8002ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bf:	83 fa 01             	cmp    $0x1,%edx
  8002c2:	7e 0e                	jle    8002d2 <getint+0x16>
		return va_arg(*ap, long long);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	8b 52 04             	mov    0x4(%edx),%edx
  8002d0:	eb 1a                	jmp    8002ec <getint+0x30>
	else if (lflag)
  8002d2:	85 d2                	test   %edx,%edx
  8002d4:	74 0c                	je     8002e2 <getint+0x26>
		return va_arg(*ap, long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	99                   	cltd   
  8002e0:	eb 0a                	jmp    8002ec <getint+0x30>
	else
		return va_arg(*ap, int);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	99                   	cltd   
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fc:	73 08                	jae    800306 <sprintputch+0x18>
		*b->buf++ = ch;
  8002fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800301:	88 0a                	mov    %cl,(%edx)
  800303:	42                   	inc    %edx
  800304:	89 10                	mov    %edx,(%eax)
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
  800320:	83 c4 10             	add    $0x10,%esp
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800331:	8b 75 10             	mov    0x10(%ebp),%esi
  800334:	eb 13                	jmp    800349 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800336:	85 c0                	test   %eax,%eax
  800338:	0f 84 6d 03 00 00    	je     8006ab <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80033e:	83 ec 08             	sub    $0x8,%esp
  800341:	57                   	push   %edi
  800342:	50                   	push   %eax
  800343:	ff 55 08             	call   *0x8(%ebp)
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 06             	movzbl (%esi),%eax
  80034c:	46                   	inc    %esi
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e4                	jne    800336 <vprintfmt+0x11>
  800352:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800356:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80035d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800364:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	eb 28                	jmp    80039a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800374:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800378:	eb 20                	jmp    80039a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800380:	eb 18                	jmp    80039a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800384:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038b:	eb 0d                	jmp    80039a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800393:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8a 06                	mov    (%esi),%al
  80039c:	0f b6 d0             	movzbl %al,%edx
  80039f:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003a2:	83 e8 23             	sub    $0x23,%eax
  8003a5:	3c 55                	cmp    $0x55,%al
  8003a7:	0f 87 e0 02 00 00    	ja     80068d <vprintfmt+0x368>
  8003ad:	0f b6 c0             	movzbl %al,%eax
  8003b0:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b7:	83 ea 30             	sub    $0x30,%edx
  8003ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003bd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003c0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 44                	ja     80040c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	89 de                	mov    %ebx,%esi
  8003ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ce:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003d1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003d5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003db:	83 fb 09             	cmp    $0x9,%ebx
  8003de:	76 ed                	jbe    8003cd <vprintfmt+0xa8>
  8003e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003e3:	eb 29                	jmp    80040e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f5:	eb 17                	jmp    80040e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	78 85                	js     800382 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	89 de                	mov    %ebx,%esi
  8003ff:	eb 99                	jmp    80039a <vprintfmt+0x75>
  800401:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800403:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80040a:	eb 8e                	jmp    80039a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800412:	79 86                	jns    80039a <vprintfmt+0x75>
  800414:	e9 74 ff ff ff       	jmp    80038d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800419:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	e9 79 ff ff ff       	jmp    80039a <vprintfmt+0x75>
  800421:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	57                   	push   %edi
  800431:	ff 30                	pushl  (%eax)
  800433:	ff 55 08             	call   *0x8(%ebp)
			break;
  800436:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043c:	e9 08 ff ff ff       	jmp    800349 <vprintfmt+0x24>
  800441:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	79 02                	jns    800455 <vprintfmt+0x130>
  800453:	f7 d8                	neg    %eax
  800455:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 04 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 1a                	jne    800481 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800467:	52                   	push   %edx
  800468:	68 33 24 80 00       	push   $0x802433
  80046d:	57                   	push   %edi
  80046e:	ff 75 08             	pushl  0x8(%ebp)
  800471:	e8 92 fe ff ff       	call   800308 <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047c:	e9 c8 fe ff ff       	jmp    800349 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800481:	50                   	push   %eax
  800482:	68 f7 27 80 00       	push   $0x8027f7
  800487:	57                   	push   %edi
  800488:	ff 75 08             	pushl  0x8(%ebp)
  80048b:	e8 78 fe ff ff       	call   800308 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800496:	e9 ae fe ff ff       	jmp    800349 <vprintfmt+0x24>
  80049b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80049e:	89 de                	mov    %ebx,%esi
  8004a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	75 07                	jne    8004bf <vprintfmt+0x19a>
				p = "(null)";
  8004b8:	c7 45 d0 2c 24 80 00 	movl   $0x80242c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004bf:	85 db                	test   %ebx,%ebx
  8004c1:	7e 42                	jle    800505 <vprintfmt+0x1e0>
  8004c3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004c7:	74 3c                	je     800505 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	51                   	push   %ecx
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	e8 6f 02 00 00       	call   800744 <strnlen>
  8004d5:	29 c3                	sub    %eax,%ebx
  8004d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 db                	test   %ebx,%ebx
  8004df:	7e 24                	jle    800505 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004e1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004e5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	57                   	push   %edi
  8004ef:	53                   	push   %ebx
  8004f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	4e                   	dec    %esi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	7f f0                	jg     8004eb <vprintfmt+0x1c6>
  8004fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800505:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800508:	0f be 02             	movsbl (%edx),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	75 47                	jne    800556 <vprintfmt+0x231>
  80050f:	eb 37                	jmp    800548 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800515:	74 16                	je     80052d <vprintfmt+0x208>
  800517:	8d 50 e0             	lea    -0x20(%eax),%edx
  80051a:	83 fa 5e             	cmp    $0x5e,%edx
  80051d:	76 0e                	jbe    80052d <vprintfmt+0x208>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	57                   	push   %edi
  800523:	6a 3f                	push   $0x3f
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb 0b                	jmp    800538 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	57                   	push   %edi
  800531:	50                   	push   %eax
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	ff 4d e4             	decl   -0x1c(%ebp)
  80053b:	0f be 03             	movsbl (%ebx),%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	74 03                	je     800545 <vprintfmt+0x220>
  800542:	43                   	inc    %ebx
  800543:	eb 1b                	jmp    800560 <vprintfmt+0x23b>
  800545:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	7f 1e                	jg     80056c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800551:	e9 f3 fd ff ff       	jmp    800349 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800559:	43                   	inc    %ebx
  80055a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80055d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800560:	85 f6                	test   %esi,%esi
  800562:	78 ad                	js     800511 <vprintfmt+0x1ec>
  800564:	4e                   	dec    %esi
  800565:	79 aa                	jns    800511 <vprintfmt+0x1ec>
  800567:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80056a:	eb dc                	jmp    800548 <vprintfmt+0x223>
  80056c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	57                   	push   %edi
  800573:	6a 20                	push   $0x20
  800575:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800578:	4b                   	dec    %ebx
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f ef                	jg     80056f <vprintfmt+0x24a>
  800580:	e9 c4 fd ff ff       	jmp    800349 <vprintfmt+0x24>
  800585:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800588:	89 ca                	mov    %ecx,%edx
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 2a fd ff ff       	call   8002bc <getint>
  800592:	89 c3                	mov    %eax,%ebx
  800594:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800596:	85 d2                	test   %edx,%edx
  800598:	78 0a                	js     8005a4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	e9 b0 00 00 00       	jmp    800654 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	57                   	push   %edi
  8005a8:	6a 2d                	push   $0x2d
  8005aa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ad:	f7 db                	neg    %ebx
  8005af:	83 d6 00             	adc    $0x0,%esi
  8005b2:	f7 de                	neg    %esi
  8005b4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 93 00 00 00       	jmp    800654 <vprintfmt+0x32f>
  8005c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c4:	89 ca                	mov    %ecx,%edx
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 b4 fc ff ff       	call   800282 <getuint>
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d7:	eb 7b                	jmp    800654 <vprintfmt+0x32f>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 d6 fc ff ff       	call   8002bc <getint>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	78 07                	js     8005f5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f3:	eb 5f                	jmp    800654 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	57                   	push   %edi
  8005f9:	6a 2d                	push   $0x2d
  8005fb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005fe:	f7 db                	neg    %ebx
  800600:	83 d6 00             	adc    $0x0,%esi
  800603:	f7 de                	neg    %esi
  800605:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
  80060d:	eb 45                	jmp    800654 <vprintfmt+0x32f>
  80060f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	57                   	push   %edi
  800616:	6a 30                	push   $0x30
  800618:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80061b:	83 c4 08             	add    $0x8,%esp
  80061e:	57                   	push   %edi
  80061f:	6a 78                	push   $0x78
  800621:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062d:	8b 18                	mov    (%eax),%ebx
  80062f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800634:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063c:	eb 16                	jmp    800654 <vprintfmt+0x32f>
  80063e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 37 fc ff ff       	call   800282 <getuint>
  80064b:	89 c3                	mov    %eax,%ebx
  80064d:	89 d6                	mov    %edx,%esi
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80065b:	52                   	push   %edx
  80065c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065f:	50                   	push   %eax
  800660:	56                   	push   %esi
  800661:	53                   	push   %ebx
  800662:	89 fa                	mov    %edi,%edx
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	e8 68 fb ff ff       	call   8001d4 <printnum>
			break;
  80066c:	83 c4 20             	add    $0x20,%esp
  80066f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800672:	e9 d2 fc ff ff       	jmp    800349 <vprintfmt+0x24>
  800677:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	57                   	push   %edi
  80067e:	52                   	push   %edx
  80067f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800682:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800688:	e9 bc fc ff ff       	jmp    800349 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	57                   	push   %edi
  800691:	6a 25                	push   $0x25
  800693:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb 02                	jmp    80069d <vprintfmt+0x378>
  80069b:	89 c6                	mov    %eax,%esi
  80069d:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006a0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a4:	75 f5                	jne    80069b <vprintfmt+0x376>
  8006a6:	e9 9e fc ff ff       	jmp    800349 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5f                   	pop    %edi
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x47>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 29                	jle    800701 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 ee 02 80 00       	push   $0x8002ee
  8006e7:	e8 39 fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 0c                	jmp    800706 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb 05                	jmp    800706 <vsnprintf+0x53>
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	50                   	push   %eax
  800712:	ff 75 10             	pushl  0x10(%ebp)
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	ff 75 08             	pushl  0x8(%ebp)
  80071b:	e8 93 ff ff ff       	call   8006b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    
	...

00800724 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	80 3a 00             	cmpb   $0x0,(%edx)
  80072d:	74 0e                	je     80073d <strlen+0x19>
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800734:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800735:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800739:	75 f9                	jne    800734 <strlen+0x10>
  80073b:	eb 05                	jmp    800742 <strlen+0x1e>
  80073d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	85 d2                	test   %edx,%edx
  80074f:	74 17                	je     800768 <strnlen+0x24>
  800751:	80 39 00             	cmpb   $0x0,(%ecx)
  800754:	74 19                	je     80076f <strnlen+0x2b>
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80075b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	39 d0                	cmp    %edx,%eax
  80075e:	74 14                	je     800774 <strnlen+0x30>
  800760:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800764:	75 f5                	jne    80075b <strnlen+0x17>
  800766:	eb 0c                	jmp    800774 <strnlen+0x30>
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	eb 05                	jmp    800774 <strnlen+0x30>
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800788:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80078b:	42                   	inc    %edx
  80078c:	84 c9                	test   %cl,%cl
  80078e:	75 f5                	jne    800785 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 84 ff ff ff       	call   800724 <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007a9:	50                   	push   %eax
  8007aa:	e8 c7 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	85 f6                	test   %esi,%esi
  8007c6:	74 15                	je     8007dd <strncpy+0x27>
  8007c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007cd:	8a 1a                	mov    (%edx),%bl
  8007cf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	41                   	inc    %ecx
  8007d9:	39 ce                	cmp    %ecx,%esi
  8007db:	77 f0                	ja     8007cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	57                   	push   %edi
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ed:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	85 f6                	test   %esi,%esi
  8007f2:	74 32                	je     800826 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007f4:	83 fe 01             	cmp    $0x1,%esi
  8007f7:	74 22                	je     80081b <strlcpy+0x3a>
  8007f9:	8a 0b                	mov    (%ebx),%cl
  8007fb:	84 c9                	test   %cl,%cl
  8007fd:	74 20                	je     80081f <strlcpy+0x3e>
  8007ff:	89 f8                	mov    %edi,%eax
  800801:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800806:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800809:	88 08                	mov    %cl,(%eax)
  80080b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080c:	39 f2                	cmp    %esi,%edx
  80080e:	74 11                	je     800821 <strlcpy+0x40>
  800810:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800814:	42                   	inc    %edx
  800815:	84 c9                	test   %cl,%cl
  800817:	75 f0                	jne    800809 <strlcpy+0x28>
  800819:	eb 06                	jmp    800821 <strlcpy+0x40>
  80081b:	89 f8                	mov    %edi,%eax
  80081d:	eb 02                	jmp    800821 <strlcpy+0x40>
  80081f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
  800824:	eb 02                	jmp    800828 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800828:	29 f8                	sub    %edi,%eax
}
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5f                   	pop    %edi
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	8a 01                	mov    (%ecx),%al
  80083a:	84 c0                	test   %al,%al
  80083c:	74 10                	je     80084e <strcmp+0x1f>
  80083e:	3a 02                	cmp    (%edx),%al
  800840:	75 0c                	jne    80084e <strcmp+0x1f>
		p++, q++;
  800842:	41                   	inc    %ecx
  800843:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800844:	8a 01                	mov    (%ecx),%al
  800846:	84 c0                	test   %al,%al
  800848:	74 04                	je     80084e <strcmp+0x1f>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	74 f4                	je     800842 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 55 08             	mov    0x8(%ebp),%edx
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800865:	85 c0                	test   %eax,%eax
  800867:	74 1b                	je     800884 <strncmp+0x2c>
  800869:	8a 1a                	mov    (%edx),%bl
  80086b:	84 db                	test   %bl,%bl
  80086d:	74 24                	je     800893 <strncmp+0x3b>
  80086f:	3a 19                	cmp    (%ecx),%bl
  800871:	75 20                	jne    800893 <strncmp+0x3b>
  800873:	48                   	dec    %eax
  800874:	74 15                	je     80088b <strncmp+0x33>
		n--, p++, q++;
  800876:	42                   	inc    %edx
  800877:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800878:	8a 1a                	mov    (%edx),%bl
  80087a:	84 db                	test   %bl,%bl
  80087c:	74 15                	je     800893 <strncmp+0x3b>
  80087e:	3a 19                	cmp    (%ecx),%bl
  800880:	74 f1                	je     800873 <strncmp+0x1b>
  800882:	eb 0f                	jmp    800893 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	eb 05                	jmp    800890 <strncmp+0x38>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800890:	5b                   	pop    %ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 02             	movzbl (%edx),%eax
  800896:	0f b6 11             	movzbl (%ecx),%edx
  800899:	29 d0                	sub    %edx,%eax
  80089b:	eb f3                	jmp    800890 <strncmp+0x38>

0080089d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a6:	8a 10                	mov    (%eax),%dl
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	74 18                	je     8008c4 <strchr+0x27>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	75 06                	jne    8008b6 <strchr+0x19>
  8008b0:	eb 17                	jmp    8008c9 <strchr+0x2c>
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 13                	je     8008c9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b6:	40                   	inc    %eax
  8008b7:	8a 10                	mov    (%eax),%dl
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f5                	jne    8008b2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	eb 05                	jmp    8008c9 <strchr+0x2c>
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d4:	8a 10                	mov    (%eax),%dl
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	74 11                	je     8008eb <strfind+0x20>
		if (*s == c)
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	75 06                	jne    8008e4 <strfind+0x19>
  8008de:	eb 0b                	jmp    8008eb <strfind+0x20>
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 07                	je     8008eb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e4:	40                   	inc    %eax
  8008e5:	8a 10                	mov    (%eax),%dl
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f5                	jne    8008e0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 30                	je     800930 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 25                	jne    80092d <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 20                	jne    80092d <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800910:	89 d3                	mov    %edx,%ebx
  800912:	c1 e3 08             	shl    $0x8,%ebx
  800915:	89 d6                	mov    %edx,%esi
  800917:	c1 e6 18             	shl    $0x18,%esi
  80091a:	89 d0                	mov    %edx,%eax
  80091c:	c1 e0 10             	shl    $0x10,%eax
  80091f:	09 f0                	or     %esi,%eax
  800921:	09 d0                	or     %edx,%eax
  800923:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800925:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800928:	fc                   	cld    
  800929:	f3 ab                	rep stos %eax,%es:(%edi)
  80092b:	eb 03                	jmp    800930 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092d:	fc                   	cld    
  80092e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800930:	89 f8                	mov    %edi,%eax
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800945:	39 c6                	cmp    %eax,%esi
  800947:	73 34                	jae    80097d <memmove+0x46>
  800949:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094c:	39 d0                	cmp    %edx,%eax
  80094e:	73 2d                	jae    80097d <memmove+0x46>
		s += n;
		d += n;
  800950:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 1b                	jne    800973 <memmove+0x3c>
  800958:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095e:	75 13                	jne    800973 <memmove+0x3c>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 0e                	jne    800973 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800965:	83 ef 04             	sub    $0x4,%edi
  800968:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096e:	fd                   	std    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 07                	jmp    80097a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800973:	4f                   	dec    %edi
  800974:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800977:	fd                   	std    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097a:	fc                   	cld    
  80097b:	eb 20                	jmp    80099d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800983:	75 13                	jne    800998 <memmove+0x61>
  800985:	a8 03                	test   $0x3,%al
  800987:	75 0f                	jne    800998 <memmove+0x61>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0a                	jne    800998 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800991:	89 c7                	mov    %eax,%edi
  800993:	fc                   	cld    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 05                	jmp    80099d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800998:	89 c7                	mov    %eax,%edi
  80099a:	fc                   	cld    
  80099b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a4:	ff 75 10             	pushl  0x10(%ebp)
  8009a7:	ff 75 0c             	pushl  0xc(%ebp)
  8009aa:	ff 75 08             	pushl  0x8(%ebp)
  8009ad:	e8 85 ff ff ff       	call   800937 <memmove>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	85 ff                	test   %edi,%edi
  8009c5:	74 32                	je     8009f9 <memcmp+0x45>
		if (*s1 != *s2)
  8009c7:	8a 03                	mov    (%ebx),%al
  8009c9:	8a 0e                	mov    (%esi),%cl
  8009cb:	38 c8                	cmp    %cl,%al
  8009cd:	74 19                	je     8009e8 <memcmp+0x34>
  8009cf:	eb 0d                	jmp    8009de <memcmp+0x2a>
  8009d1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009d5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009d9:	42                   	inc    %edx
  8009da:	38 c8                	cmp    %cl,%al
  8009dc:	74 10                	je     8009ee <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c0             	movzbl %al,%eax
  8009e1:	0f b6 c9             	movzbl %cl,%ecx
  8009e4:	29 c8                	sub    %ecx,%eax
  8009e6:	eb 16                	jmp    8009fe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	4f                   	dec    %edi
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	39 fa                	cmp    %edi,%edx
  8009f0:	75 df                	jne    8009d1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	eb 05                	jmp    8009fe <memcmp+0x4a>
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0e:	39 d0                	cmp    %edx,%eax
  800a10:	73 12                	jae    800a24 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a15:	38 08                	cmp    %cl,(%eax)
  800a17:	75 06                	jne    800a1f <memfind+0x1c>
  800a19:	eb 09                	jmp    800a24 <memfind+0x21>
  800a1b:	38 08                	cmp    %cl,(%eax)
  800a1d:	74 05                	je     800a24 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	40                   	inc    %eax
  800a20:	39 c2                	cmp    %eax,%edx
  800a22:	77 f7                	ja     800a1b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 01                	jmp    800a35 <strtol+0xf>
		s++;
  800a34:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	8a 02                	mov    (%edx),%al
  800a37:	3c 20                	cmp    $0x20,%al
  800a39:	74 f9                	je     800a34 <strtol+0xe>
  800a3b:	3c 09                	cmp    $0x9,%al
  800a3d:	74 f5                	je     800a34 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3f:	3c 2b                	cmp    $0x2b,%al
  800a41:	75 08                	jne    800a4b <strtol+0x25>
		s++;
  800a43:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb 13                	jmp    800a5e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	75 0a                	jne    800a59 <strtol+0x33>
		s++, neg = 1;
  800a4f:	8d 52 01             	lea    0x1(%edx),%edx
  800a52:	bf 01 00 00 00       	mov    $0x1,%edi
  800a57:	eb 05                	jmp    800a5e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	74 05                	je     800a67 <strtol+0x41>
  800a62:	83 fb 10             	cmp    $0x10,%ebx
  800a65:	75 28                	jne    800a8f <strtol+0x69>
  800a67:	8a 02                	mov    (%edx),%al
  800a69:	3c 30                	cmp    $0x30,%al
  800a6b:	75 10                	jne    800a7d <strtol+0x57>
  800a6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a71:	75 0a                	jne    800a7d <strtol+0x57>
		s += 2, base = 16;
  800a73:	83 c2 02             	add    $0x2,%edx
  800a76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7b:	eb 12                	jmp    800a8f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	75 0e                	jne    800a8f <strtol+0x69>
  800a81:	3c 30                	cmp    $0x30,%al
  800a83:	75 05                	jne    800a8a <strtol+0x64>
		s++, base = 8;
  800a85:	42                   	inc    %edx
  800a86:	b3 08                	mov    $0x8,%bl
  800a88:	eb 05                	jmp    800a8f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a8a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a96:	8a 0a                	mov    (%edx),%cl
  800a98:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a9b:	80 fb 09             	cmp    $0x9,%bl
  800a9e:	77 08                	ja     800aa8 <strtol+0x82>
			dig = *s - '0';
  800aa0:	0f be c9             	movsbl %cl,%ecx
  800aa3:	83 e9 30             	sub    $0x30,%ecx
  800aa6:	eb 1e                	jmp    800ac6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ab0:	0f be c9             	movsbl %cl,%ecx
  800ab3:	83 e9 57             	sub    $0x57,%ecx
  800ab6:	eb 0e                	jmp    800ac6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800abb:	80 fb 19             	cmp    $0x19,%bl
  800abe:	77 13                	ja     800ad3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ac0:	0f be c9             	movsbl %cl,%ecx
  800ac3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac6:	39 f1                	cmp    %esi,%ecx
  800ac8:	7d 0d                	jge    800ad7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aca:	42                   	inc    %edx
  800acb:	0f af c6             	imul   %esi,%eax
  800ace:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ad1:	eb c3                	jmp    800a96 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad3:	89 c1                	mov    %eax,%ecx
  800ad5:	eb 02                	jmp    800ad9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 05                	je     800ae4 <strtol+0xbe>
		*endptr = (char *) s;
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	74 04                	je     800aec <strtol+0xc6>
  800ae8:	89 c8                	mov    %ecx,%eax
  800aea:	f7 d8                	neg    %eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    
  800af1:	00 00                	add    %al,(%eax)
	...

00800af4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	83 ec 1c             	sub    $0x1c,%esp
  800afd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b00:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b03:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	8b 75 14             	mov    0x14(%ebp),%esi
  800b08:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b11:	cd 30                	int    $0x30
  800b13:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b15:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b19:	74 1c                	je     800b37 <syscall+0x43>
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 18                	jle    800b37 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b26:	68 1f 27 80 00       	push   $0x80271f
  800b2b:	6a 42                	push   $0x42
  800b2d:	68 3c 27 80 00       	push   $0x80273c
  800b32:	e8 b1 f5 ff ff       	call   8000e8 <_panic>

	return ret;
}
  800b37:	89 d0                	mov    %edx,%eax
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	ff 75 0c             	pushl  0xc(%ebp)
  800b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5d:	e8 92 ff ff ff       	call   800af4 <syscall>
  800b62:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	e8 6b ff ff ff       	call   800af4 <syscall>
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba6:	e8 49 ff ff ff       	call   800af4 <syscall>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	6a 00                	push   $0x0
  800bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bca:	e8 25 ff ff ff       	call   800af4 <syscall>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	6a 00                	push   $0x0
  800bdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	e8 01 ff ff ff       	call   800af4 <syscall>
  800bf3:	83 c4 10             	add    $0x10,%esp
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	ff 75 10             	pushl  0x10(%ebp)
  800c05:	ff 75 0c             	pushl  0xc(%ebp)
  800c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c10:	b8 04 00 00 00       	mov    $0x4,%eax
  800c15:	e8 da fe ff ff       	call   800af4 <syscall>
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c22:	ff 75 18             	pushl  0x18(%ebp)
  800c25:	ff 75 14             	pushl  0x14(%ebp)
  800c28:	ff 75 10             	pushl  0x10(%ebp)
  800c2b:	ff 75 0c             	pushl  0xc(%ebp)
  800c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c31:	ba 01 00 00 00       	mov    $0x1,%edx
  800c36:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3b:	e8 b4 fe ff ff       	call   800af4 <syscall>
}
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c48:	6a 00                	push   $0x0
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	ff 75 0c             	pushl  0xc(%ebp)
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c54:	ba 01 00 00 00       	mov    $0x1,%edx
  800c59:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5e:	e8 91 fe ff ff       	call   800af4 <syscall>
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c6b:	6a 00                	push   $0x0
  800c6d:	6a 00                	push   $0x0
  800c6f:	6a 00                	push   $0x0
  800c71:	ff 75 0c             	pushl  0xc(%ebp)
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c81:	e8 6e fe ff ff       	call   800af4 <syscall>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	ff 75 0c             	pushl  0xc(%ebp)
  800c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca4:	e8 4b fe ff ff       	call   800af4 <syscall>
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	6a 00                	push   $0x0
  800cb7:	ff 75 0c             	pushl  0xc(%ebp)
  800cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc7:	e8 28 fe ff ff       	call   800af4 <syscall>
}
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cd4:	6a 00                	push   $0x0
  800cd6:	ff 75 14             	pushl  0x14(%ebp)
  800cd9:	ff 75 10             	pushl  0x10(%ebp)
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cec:	e8 03 fe ff ff       	call   800af4 <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d04:	ba 01 00 00 00       	mov    $0x1,%edx
  800d09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0e:	e8 e1 fd ff ff       	call   800af4 <syscall>
}
  800d13:	c9                   	leave  
  800d14:	c3                   	ret    

00800d15 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d1b:	6a 00                	push   $0x0
  800d1d:	6a 00                	push   $0x0
  800d1f:	6a 00                	push   $0x0
  800d21:	ff 75 0c             	pushl  0xc(%ebp)
  800d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d27:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d31:	e8 be fd ff ff       	call   800af4 <syscall>
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d43:	c1 e8 0c             	shr    $0xc,%eax
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d4b:	ff 75 08             	pushl  0x8(%ebp)
  800d4e:	e8 e5 ff ff ff       	call   800d38 <fd2num>
  800d53:	83 c4 04             	add    $0x4,%esp
  800d56:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d5b:	c1 e0 0c             	shl    $0xc,%eax
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	53                   	push   %ebx
  800d64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d67:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d6c:	a8 01                	test   $0x1,%al
  800d6e:	74 34                	je     800da4 <fd_alloc+0x44>
  800d70:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d75:	a8 01                	test   $0x1,%al
  800d77:	74 32                	je     800dab <fd_alloc+0x4b>
  800d79:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d7e:	89 c1                	mov    %eax,%ecx
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	c1 ea 16             	shr    $0x16,%edx
  800d85:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8c:	f6 c2 01             	test   $0x1,%dl
  800d8f:	74 1f                	je     800db0 <fd_alloc+0x50>
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	c1 ea 0c             	shr    $0xc,%edx
  800d96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9d:	f6 c2 01             	test   $0x1,%dl
  800da0:	75 17                	jne    800db9 <fd_alloc+0x59>
  800da2:	eb 0c                	jmp    800db0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800da4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800da9:	eb 05                	jmp    800db0 <fd_alloc+0x50>
  800dab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800db0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
  800db7:	eb 17                	jmp    800dd0 <fd_alloc+0x70>
  800db9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dbe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc3:	75 b9                	jne    800d7e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800dcb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd9:	83 f8 1f             	cmp    $0x1f,%eax
  800ddc:	77 36                	ja     800e14 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dde:	05 00 00 0d 00       	add    $0xd0000,%eax
  800de3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 16             	shr    $0x16,%edx
  800deb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 24                	je     800e1b <fd_lookup+0x48>
  800df7:	89 c2                	mov    %eax,%edx
  800df9:	c1 ea 0c             	shr    $0xc,%edx
  800dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e03:	f6 c2 01             	test   $0x1,%dl
  800e06:	74 1a                	je     800e22 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	eb 13                	jmp    800e27 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e19:	eb 0c                	jmp    800e27 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e20:	eb 05                	jmp    800e27 <fd_lookup+0x54>
  800e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 04             	sub    $0x4,%esp
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e36:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e3c:	74 0d                	je     800e4b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e43:	eb 14                	jmp    800e59 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e45:	39 0a                	cmp    %ecx,(%edx)
  800e47:	75 10                	jne    800e59 <dev_lookup+0x30>
  800e49:	eb 05                	jmp    800e50 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e4b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e50:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	eb 31                	jmp    800e8a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e59:	40                   	inc    %eax
  800e5a:	8b 14 85 c8 27 80 00 	mov    0x8027c8(,%eax,4),%edx
  800e61:	85 d2                	test   %edx,%edx
  800e63:	75 e0                	jne    800e45 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e65:	a1 04 40 80 00       	mov    0x804004,%eax
  800e6a:	8b 40 48             	mov    0x48(%eax),%eax
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	51                   	push   %ecx
  800e71:	50                   	push   %eax
  800e72:	68 4c 27 80 00       	push   $0x80274c
  800e77:	e8 44 f3 ff ff       	call   8001c0 <cprintf>
	*dev = 0;
  800e7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 20             	sub    $0x20,%esp
  800e97:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9a:	8a 45 0c             	mov    0xc(%ebp),%al
  800e9d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea0:	56                   	push   %esi
  800ea1:	e8 92 fe ff ff       	call   800d38 <fd2num>
  800ea6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ea9:	89 14 24             	mov    %edx,(%esp)
  800eac:	50                   	push   %eax
  800ead:	e8 21 ff ff ff       	call   800dd3 <fd_lookup>
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	83 c4 08             	add    $0x8,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 05                	js     800ec0 <fd_close+0x31>
	    || fd != fd2)
  800ebb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ebe:	74 0d                	je     800ecd <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ec0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ec4:	75 48                	jne    800f0e <fd_close+0x7f>
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecb:	eb 41                	jmp    800f0e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 36                	pushl  (%esi)
  800ed6:	e8 4e ff ff ff       	call   800e29 <dev_lookup>
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 1c                	js     800f00 <fd_close+0x71>
		if (dev->dev_close)
  800ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee7:	8b 40 10             	mov    0x10(%eax),%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	74 0d                	je     800efb <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	56                   	push   %esi
  800ef2:	ff d0                	call   *%eax
  800ef4:	89 c3                	mov    %eax,%ebx
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	eb 05                	jmp    800f00 <fd_close+0x71>
		else
			r = 0;
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	56                   	push   %esi
  800f04:	6a 00                	push   $0x0
  800f06:	e8 37 fd ff ff       	call   800c42 <sys_page_unmap>
	return r;
  800f0b:	83 c4 10             	add    $0x10,%esp
}
  800f0e:	89 d8                	mov    %ebx,%eax
  800f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	ff 75 08             	pushl  0x8(%ebp)
  800f24:	e8 aa fe ff ff       	call   800dd3 <fd_lookup>
  800f29:	83 c4 08             	add    $0x8,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 10                	js     800f40 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	6a 01                	push   $0x1
  800f35:	ff 75 f4             	pushl  -0xc(%ebp)
  800f38:	e8 52 ff ff ff       	call   800e8f <fd_close>
  800f3d:	83 c4 10             	add    $0x10,%esp
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <close_all>:

void
close_all(void)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	53                   	push   %ebx
  800f46:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	53                   	push   %ebx
  800f52:	e8 c0 ff ff ff       	call   800f17 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f57:	43                   	inc    %ebx
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	83 fb 20             	cmp    $0x20,%ebx
  800f5e:	75 ee                	jne    800f4e <close_all+0xc>
		close(i);
}
  800f60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 2c             	sub    $0x2c,%esp
  800f6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 08             	pushl  0x8(%ebp)
  800f78:	e8 56 fe ff ff       	call   800dd3 <fd_lookup>
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	0f 88 c0 00 00 00    	js     80104a <dup+0xe5>
		return r;
	close(newfdnum);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	57                   	push   %edi
  800f8e:	e8 84 ff ff ff       	call   800f17 <close>

	newfd = INDEX2FD(newfdnum);
  800f93:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f99:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f9c:	83 c4 04             	add    $0x4,%esp
  800f9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa2:	e8 a1 fd ff ff       	call   800d48 <fd2data>
  800fa7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fa9:	89 34 24             	mov    %esi,(%esp)
  800fac:	e8 97 fd ff ff       	call   800d48 <fd2data>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb7:	89 d8                	mov    %ebx,%eax
  800fb9:	c1 e8 16             	shr    $0x16,%eax
  800fbc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc3:	a8 01                	test   $0x1,%al
  800fc5:	74 37                	je     800ffe <dup+0x99>
  800fc7:	89 d8                	mov    %ebx,%eax
  800fc9:	c1 e8 0c             	shr    $0xc,%eax
  800fcc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd3:	f6 c2 01             	test   $0x1,%dl
  800fd6:	74 26                	je     800ffe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800feb:	6a 00                	push   $0x0
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 27 fc ff ff       	call   800c1c <sys_page_map>
  800ff5:	89 c3                	mov    %eax,%ebx
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 2d                	js     80102b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801001:	89 c2                	mov    %eax,%edx
  801003:	c1 ea 0c             	shr    $0xc,%edx
  801006:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801016:	52                   	push   %edx
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	50                   	push   %eax
  80101b:	6a 00                	push   $0x0
  80101d:	e8 fa fb ff ff       	call   800c1c <sys_page_map>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 1d                	jns    801048 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	56                   	push   %esi
  80102f:	6a 00                	push   $0x0
  801031:	e8 0c fc ff ff       	call   800c42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801036:	83 c4 08             	add    $0x8,%esp
  801039:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103c:	6a 00                	push   $0x0
  80103e:	e8 ff fb ff ff       	call   800c42 <sys_page_unmap>
	return r;
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	eb 02                	jmp    80104a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801048:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 14             	sub    $0x14,%esp
  80105b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	53                   	push   %ebx
  801063:	e8 6b fd ff ff       	call   800dd3 <fd_lookup>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 67                	js     8010d6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801079:	ff 30                	pushl  (%eax)
  80107b:	e8 a9 fd ff ff       	call   800e29 <dev_lookup>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 4f                	js     8010d6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801087:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108a:	8b 50 08             	mov    0x8(%eax),%edx
  80108d:	83 e2 03             	and    $0x3,%edx
  801090:	83 fa 01             	cmp    $0x1,%edx
  801093:	75 21                	jne    8010b6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801095:	a1 04 40 80 00       	mov    0x804004,%eax
  80109a:	8b 40 48             	mov    0x48(%eax),%eax
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	50                   	push   %eax
  8010a2:	68 8d 27 80 00       	push   $0x80278d
  8010a7:	e8 14 f1 ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b4:	eb 20                	jmp    8010d6 <read+0x82>
	}
	if (!dev->dev_read)
  8010b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010b9:	8b 52 08             	mov    0x8(%edx),%edx
  8010bc:	85 d2                	test   %edx,%edx
  8010be:	74 11                	je     8010d1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	ff 75 10             	pushl  0x10(%ebp)
  8010c6:	ff 75 0c             	pushl  0xc(%ebp)
  8010c9:	50                   	push   %eax
  8010ca:	ff d2                	call   *%edx
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	eb 05                	jmp    8010d6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ea:	85 f6                	test   %esi,%esi
  8010ec:	74 31                	je     80111f <readn+0x44>
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	89 f2                	mov    %esi,%edx
  8010fd:	29 c2                	sub    %eax,%edx
  8010ff:	52                   	push   %edx
  801100:	03 45 0c             	add    0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	57                   	push   %edi
  801105:	e8 4a ff ff ff       	call   801054 <read>
		if (m < 0)
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 17                	js     801128 <readn+0x4d>
			return m;
		if (m == 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	74 11                	je     801126 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801115:	01 c3                	add    %eax,%ebx
  801117:	89 d8                	mov    %ebx,%eax
  801119:	39 f3                	cmp    %esi,%ebx
  80111b:	72 db                	jb     8010f8 <readn+0x1d>
  80111d:	eb 09                	jmp    801128 <readn+0x4d>
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
  801124:	eb 02                	jmp    801128 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801126:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	53                   	push   %ebx
  801134:	83 ec 14             	sub    $0x14,%esp
  801137:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	53                   	push   %ebx
  80113f:	e8 8f fc ff ff       	call   800dd3 <fd_lookup>
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 62                	js     8011ad <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	ff 30                	pushl  (%eax)
  801157:	e8 cd fc ff ff       	call   800e29 <dev_lookup>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 4a                	js     8011ad <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116a:	75 21                	jne    80118d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116c:	a1 04 40 80 00       	mov    0x804004,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	53                   	push   %ebx
  801178:	50                   	push   %eax
  801179:	68 a9 27 80 00       	push   $0x8027a9
  80117e:	e8 3d f0 ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118b:	eb 20                	jmp    8011ad <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801190:	8b 52 0c             	mov    0xc(%edx),%edx
  801193:	85 d2                	test   %edx,%edx
  801195:	74 11                	je     8011a8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801197:	83 ec 04             	sub    $0x4,%esp
  80119a:	ff 75 10             	pushl  0x10(%ebp)
  80119d:	ff 75 0c             	pushl  0xc(%ebp)
  8011a0:	50                   	push   %eax
  8011a1:	ff d2                	call   *%edx
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb 05                	jmp    8011ad <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 75 08             	pushl  0x8(%ebp)
  8011bf:	e8 0f fc ff ff       	call   800dd3 <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 0e                	js     8011d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 14             	sub    $0x14,%esp
  8011e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	53                   	push   %ebx
  8011ea:	e8 e4 fb ff ff       	call   800dd3 <fd_lookup>
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	78 5f                	js     801255 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	ff 30                	pushl  (%eax)
  801202:	e8 22 fc ff ff       	call   800e29 <dev_lookup>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 47                	js     801255 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801211:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801215:	75 21                	jne    801238 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801217:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121c:	8b 40 48             	mov    0x48(%eax),%eax
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	53                   	push   %ebx
  801223:	50                   	push   %eax
  801224:	68 6c 27 80 00       	push   $0x80276c
  801229:	e8 92 ef ff ff       	call   8001c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801236:	eb 1d                	jmp    801255 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801238:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123b:	8b 52 18             	mov    0x18(%edx),%edx
  80123e:	85 d2                	test   %edx,%edx
  801240:	74 0e                	je     801250 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	50                   	push   %eax
  801249:	ff d2                	call   *%edx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	eb 05                	jmp    801255 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801250:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 14             	sub    $0x14,%esp
  801261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	ff 75 08             	pushl  0x8(%ebp)
  80126b:	e8 63 fb ff ff       	call   800dd3 <fd_lookup>
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 52                	js     8012c9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 a1 fb ff ff       	call   800e29 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 3a                	js     8012c9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80128f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801292:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801296:	74 2c                	je     8012c4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801298:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80129b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a2:	00 00 00 
	stat->st_isdir = 0;
  8012a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ac:	00 00 00 
	stat->st_dev = dev;
  8012af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012bc:	ff 50 14             	call   *0x14(%eax)
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	eb 05                	jmp    8012c9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	56                   	push   %esi
  8012d2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	6a 00                	push   $0x0
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 8b 01 00 00       	call   80146b <open>
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 1b                	js     801304 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	ff 75 0c             	pushl  0xc(%ebp)
  8012ef:	50                   	push   %eax
  8012f0:	e8 65 ff ff ff       	call   80125a <fstat>
  8012f5:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f7:	89 1c 24             	mov    %ebx,(%esp)
  8012fa:	e8 18 fc ff ff       	call   800f17 <close>
	return r;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	89 f3                	mov    %esi,%ebx
}
  801304:	89 d8                	mov    %ebx,%eax
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    
  80130d:	00 00                	add    %al,(%eax)
	...

00801310 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	56                   	push   %esi
  801314:	53                   	push   %ebx
  801315:	89 c3                	mov    %eax,%ebx
  801317:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801319:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801320:	75 12                	jne    801334 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	6a 01                	push   $0x1
  801327:	e8 89 0d 00 00       	call   8020b5 <ipc_find_env>
  80132c:	a3 00 40 80 00       	mov    %eax,0x804000
  801331:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801334:	6a 07                	push   $0x7
  801336:	68 00 50 80 00       	push   $0x805000
  80133b:	53                   	push   %ebx
  80133c:	ff 35 00 40 80 00    	pushl  0x804000
  801342:	e8 19 0d 00 00       	call   802060 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801347:	83 c4 0c             	add    $0xc,%esp
  80134a:	6a 00                	push   $0x0
  80134c:	56                   	push   %esi
  80134d:	6a 00                	push   $0x0
  80134f:	e8 64 0c 00 00       	call   801fb8 <ipc_recv>
}
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	53                   	push   %ebx
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801365:	8b 45 08             	mov    0x8(%ebp),%eax
  801368:	8b 40 0c             	mov    0xc(%eax),%eax
  80136b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801370:	ba 00 00 00 00       	mov    $0x0,%edx
  801375:	b8 05 00 00 00       	mov    $0x5,%eax
  80137a:	e8 91 ff ff ff       	call   801310 <fsipc>
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 39                	js     8013bc <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	68 d8 27 80 00       	push   $0x8027d8
  80138b:	e8 30 ee ff ff       	call   8001c0 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	68 00 50 80 00       	push   $0x805000
  801398:	53                   	push   %ebx
  801399:	e8 d8 f3 ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80139e:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8013ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013dc:	e8 2f ff ff ff       	call   801310 <fsipc>
}
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801401:	b8 03 00 00 00       	mov    $0x3,%eax
  801406:	e8 05 ff ff ff       	call   801310 <fsipc>
  80140b:	89 c3                	mov    %eax,%ebx
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 51                	js     801462 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801411:	39 c6                	cmp    %eax,%esi
  801413:	73 19                	jae    80142e <devfile_read+0x4b>
  801415:	68 de 27 80 00       	push   $0x8027de
  80141a:	68 e5 27 80 00       	push   $0x8027e5
  80141f:	68 80 00 00 00       	push   $0x80
  801424:	68 fa 27 80 00       	push   $0x8027fa
  801429:	e8 ba ec ff ff       	call   8000e8 <_panic>
	assert(r <= PGSIZE);
  80142e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801433:	7e 19                	jle    80144e <devfile_read+0x6b>
  801435:	68 05 28 80 00       	push   $0x802805
  80143a:	68 e5 27 80 00       	push   $0x8027e5
  80143f:	68 81 00 00 00       	push   $0x81
  801444:	68 fa 27 80 00       	push   $0x8027fa
  801449:	e8 9a ec ff ff       	call   8000e8 <_panic>
	memmove(buf, &fsipcbuf, r);
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	50                   	push   %eax
  801452:	68 00 50 80 00       	push   $0x805000
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	e8 d8 f4 ff ff       	call   800937 <memmove>
	return r;
  80145f:	83 c4 10             	add    $0x10,%esp
}
  801462:	89 d8                	mov    %ebx,%eax
  801464:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	83 ec 1c             	sub    $0x1c,%esp
  801473:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801476:	56                   	push   %esi
  801477:	e8 a8 f2 ff ff       	call   800724 <strlen>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801484:	7f 72                	jg     8014f8 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	e8 ce f8 ff ff       	call   800d60 <fd_alloc>
  801492:	89 c3                	mov    %eax,%ebx
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 62                	js     8014fd <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	56                   	push   %esi
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	e8 cd f2 ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ac:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b9:	e8 52 fe ff ff       	call   801310 <fsipc>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 12                	jns    8014d9 <open+0x6e>
		fd_close(fd, 0);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	6a 00                	push   $0x0
  8014cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cf:	e8 bb f9 ff ff       	call   800e8f <fd_close>
		return r;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	eb 24                	jmp    8014fd <open+0x92>
	}


	cprintf("OPEN\n");
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	68 11 28 80 00       	push   $0x802811
  8014e1:	e8 da ec ff ff       	call   8001c0 <cprintf>

	return fd2num(fd);
  8014e6:	83 c4 04             	add    $0x4,%esp
  8014e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ec:	e8 47 f8 ff ff       	call   800d38 <fd2num>
  8014f1:	89 c3                	mov    %eax,%ebx
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	eb 05                	jmp    8014fd <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014f8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8014fd:	89 d8                	mov    %ebx,%eax
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	c9                   	leave  
  801505:	c3                   	ret    
	...

00801508 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801514:	6a 00                	push   $0x0
  801516:	ff 75 08             	pushl  0x8(%ebp)
  801519:	e8 4d ff ff ff       	call   80146b <open>
  80151e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	0f 88 ce 04 00 00    	js     8019fd <spawn+0x4f5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	68 00 02 00 00       	push   $0x200
  801537:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801544:	e8 92 fb ff ff       	call   8010db <readn>
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801551:	75 0c                	jne    80155f <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801553:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80155a:	45 4c 46 
  80155d:	74 38                	je     801597 <spawn+0x8f>
		close(fd);
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801568:	e8 aa f9 ff ff       	call   800f17 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80156d:	83 c4 0c             	add    $0xc,%esp
  801570:	68 7f 45 4c 46       	push   $0x464c457f
  801575:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80157b:	68 17 28 80 00       	push   $0x802817
  801580:	e8 3b ec ff ff       	call   8001c0 <cprintf>
		return -E_NOT_EXEC;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80158f:	ff ff ff 
  801592:	e9 72 04 00 00       	jmp    801a09 <spawn+0x501>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801597:	ba 07 00 00 00       	mov    $0x7,%edx
  80159c:	89 d0                	mov    %edx,%eax
  80159e:	cd 30                	int    $0x30
  8015a0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8015a6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	0f 88 55 04 00 00    	js     801a09 <spawn+0x501>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8015b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8015c0:	89 c6                	mov    %eax,%esi
  8015c2:	c1 e6 07             	shl    $0x7,%esi
  8015c5:	29 d6                	sub    %edx,%esi
  8015c7:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8015cd:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8015d3:	b9 11 00 00 00       	mov    $0x11,%ecx
  8015d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8015da:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8015e0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8015e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e9:	8b 02                	mov    (%edx),%eax
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 39                	je     801628 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8015ef:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8015f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f9:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  8015fb:	83 ec 0c             	sub    $0xc,%esp
  8015fe:	50                   	push   %eax
  8015ff:	e8 20 f1 ff ff       	call   800724 <strlen>
  801604:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801608:	43                   	inc    %ebx
  801609:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801610:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	75 e1                	jne    8015fb <spawn+0xf3>
  80161a:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  801620:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801626:	eb 1e                	jmp    801646 <spawn+0x13e>
  801628:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80162f:	00 00 00 
  801632:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801639:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80163c:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801641:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801646:	f7 de                	neg    %esi
  801648:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80164e:	89 fa                	mov    %edi,%edx
  801650:	83 e2 fc             	and    $0xfffffffc,%edx
  801653:	89 d8                	mov    %ebx,%eax
  801655:	f7 d0                	not    %eax
  801657:	8d 04 82             	lea    (%edx,%eax,4),%eax
  80165a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801660:	83 e8 08             	sub    $0x8,%eax
  801663:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801668:	0f 86 a9 03 00 00    	jbe    801a17 <spawn+0x50f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80166e:	83 ec 04             	sub    $0x4,%esp
  801671:	6a 07                	push   $0x7
  801673:	68 00 00 40 00       	push   $0x400000
  801678:	6a 00                	push   $0x0
  80167a:	e8 79 f5 ff ff       	call   800bf8 <sys_page_alloc>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	0f 88 99 03 00 00    	js     801a23 <spawn+0x51b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80168a:	85 db                	test   %ebx,%ebx
  80168c:	7e 44                	jle    8016d2 <spawn+0x1ca>
  80168e:	be 00 00 00 00       	mov    $0x0,%esi
  801693:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801699:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  80169c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016a2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8016a8:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016b1:	57                   	push   %edi
  8016b2:	e8 bf f0 ff ff       	call   800776 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016b7:	83 c4 04             	add    $0x4,%esp
  8016ba:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016bd:	e8 62 f0 ff ff       	call   800724 <strlen>
  8016c2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016c6:	46                   	inc    %esi
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  8016d0:	7c ca                	jl     80169c <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8016d2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8016d8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8016de:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8016e5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8016eb:	74 19                	je     801706 <spawn+0x1fe>
  8016ed:	68 8c 28 80 00       	push   $0x80288c
  8016f2:	68 e5 27 80 00       	push   $0x8027e5
  8016f7:	68 f5 00 00 00       	push   $0xf5
  8016fc:	68 31 28 80 00       	push   $0x802831
  801701:	e8 e2 e9 ff ff       	call   8000e8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801706:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80170c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801711:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801717:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80171a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801720:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801723:	89 d0                	mov    %edx,%eax
  801725:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80172a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	6a 07                	push   $0x7
  801735:	68 00 d0 bf ee       	push   $0xeebfd000
  80173a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801740:	68 00 00 40 00       	push   $0x400000
  801745:	6a 00                	push   $0x0
  801747:	e8 d0 f4 ff ff       	call   800c1c <sys_page_map>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 20             	add    $0x20,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 18                	js     80176d <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	68 00 00 40 00       	push   $0x400000
  80175d:	6a 00                	push   $0x0
  80175f:	e8 de f4 ff ff       	call   800c42 <sys_page_unmap>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	79 1d                	jns    80178a <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	68 00 00 40 00       	push   $0x400000
  801775:	6a 00                	push   $0x0
  801777:	e8 c6 f4 ff ff       	call   800c42 <sys_page_unmap>
  80177c:	83 c4 10             	add    $0x10,%esp
	return r;
  80177f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801785:	e9 7f 02 00 00       	jmp    801a09 <spawn+0x501>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80178a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801790:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801797:	00 
  801798:	0f 84 c3 01 00 00    	je     801961 <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80179e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017a5:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017ab:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8017b2:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  8017b5:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8017bb:	83 3a 01             	cmpl   $0x1,(%edx)
  8017be:	0f 85 7c 01 00 00    	jne    801940 <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017c4:	8b 42 18             	mov    0x18(%edx),%eax
  8017c7:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8017ca:	83 f8 01             	cmp    $0x1,%eax
  8017cd:	19 db                	sbb    %ebx,%ebx
  8017cf:	83 e3 fe             	and    $0xfffffffe,%ebx
  8017d2:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8017d5:	8b 42 04             	mov    0x4(%edx),%eax
  8017d8:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  8017de:	8b 52 10             	mov    0x10(%edx),%edx
  8017e1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  8017e7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8017ed:	8b 40 14             	mov    0x14(%eax),%eax
  8017f0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8017f6:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8017fc:	8b 52 08             	mov    0x8(%edx),%edx
  8017ff:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801805:	89 d0                	mov    %edx,%eax
  801807:	25 ff 0f 00 00       	and    $0xfff,%eax
  80180c:	74 1a                	je     801828 <spawn+0x320>
		va -= i;
  80180e:	29 c2                	sub    %eax,%edx
  801810:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801816:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  80181c:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801822:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801828:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  80182f:	0f 84 0b 01 00 00    	je     801940 <spawn+0x438>
  801835:	bf 00 00 00 00       	mov    $0x0,%edi
  80183a:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  80183f:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801845:	72 28                	jb     80186f <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	53                   	push   %ebx
  80184b:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801851:	57                   	push   %edi
  801852:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801858:	e8 9b f3 ff ff       	call   800bf8 <sys_page_alloc>
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	0f 89 c4 00 00 00    	jns    80192c <spawn+0x424>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	e9 67 01 00 00       	jmp    8019d6 <spawn+0x4ce>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	6a 07                	push   $0x7
  801874:	68 00 00 40 00       	push   $0x400000
  801879:	6a 00                	push   $0x0
  80187b:	e8 78 f3 ff ff       	call   800bf8 <sys_page_alloc>
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	0f 88 41 01 00 00    	js     8019cc <spawn+0x4c4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80188b:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80188e:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801894:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801897:	50                   	push   %eax
  801898:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80189e:	e8 0f f9 ff ff       	call   8011b2 <seek>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	0f 88 22 01 00 00    	js     8019d0 <spawn+0x4c8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8018b7:	29 f8                	sub    %edi,%eax
  8018b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018be:	76 05                	jbe    8018c5 <spawn+0x3bd>
  8018c0:	b8 00 10 00 00       	mov    $0x1000,%eax
  8018c5:	50                   	push   %eax
  8018c6:	68 00 00 40 00       	push   $0x400000
  8018cb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018d1:	e8 05 f8 ff ff       	call   8010db <readn>
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	0f 88 f3 00 00 00    	js     8019d4 <spawn+0x4cc>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	53                   	push   %ebx
  8018e5:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8018eb:	57                   	push   %edi
  8018ec:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018f2:	68 00 00 40 00       	push   $0x400000
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 1e f3 ff ff       	call   800c1c <sys_page_map>
  8018fe:	83 c4 20             	add    $0x20,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	79 15                	jns    80191a <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  801905:	50                   	push   %eax
  801906:	68 3d 28 80 00       	push   $0x80283d
  80190b:	68 28 01 00 00       	push   $0x128
  801910:	68 31 28 80 00       	push   $0x802831
  801915:	e8 ce e7 ff ff       	call   8000e8 <_panic>
			sys_page_unmap(0, UTEMP);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	68 00 00 40 00       	push   $0x400000
  801922:	6a 00                	push   $0x0
  801924:	e8 19 f3 ff ff       	call   800c42 <sys_page_unmap>
  801929:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80192c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801932:	89 f7                	mov    %esi,%edi
  801934:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  80193a:	0f 82 ff fe ff ff    	jb     80183f <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801940:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801946:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80194d:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801953:	7e 0c                	jle    801961 <spawn+0x459>
  801955:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80195c:	e9 54 fe ff ff       	jmp    8017b5 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80196a:	e8 a8 f5 ff ff       	call   800f17 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80196f:	83 c4 08             	add    $0x8,%esp
  801972:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80197f:	e8 04 f3 ff ff       	call   800c88 <sys_env_set_trapframe>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	79 15                	jns    8019a0 <spawn+0x498>
		panic("sys_env_set_trapframe: %e", r);
  80198b:	50                   	push   %eax
  80198c:	68 5a 28 80 00       	push   $0x80285a
  801991:	68 89 00 00 00       	push   $0x89
  801996:	68 31 28 80 00       	push   $0x802831
  80199b:	e8 48 e7 ff ff       	call   8000e8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	6a 02                	push   $0x2
  8019a5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019ab:	e8 b5 f2 ff ff       	call   800c65 <sys_env_set_status>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	79 52                	jns    801a09 <spawn+0x501>
		panic("sys_env_set_status: %e", r);
  8019b7:	50                   	push   %eax
  8019b8:	68 74 28 80 00       	push   $0x802874
  8019bd:	68 8c 00 00 00       	push   $0x8c
  8019c2:	68 31 28 80 00       	push   $0x802831
  8019c7:	e8 1c e7 ff ff       	call   8000e8 <_panic>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	eb 06                	jmp    8019d6 <spawn+0x4ce>
  8019d0:	89 c3                	mov    %eax,%ebx
  8019d2:	eb 02                	jmp    8019d6 <spawn+0x4ce>
  8019d4:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019df:	e8 a7 f1 ff ff       	call   800b8b <sys_env_destroy>
	close(fd);
  8019e4:	83 c4 04             	add    $0x4,%esp
  8019e7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019ed:	e8 25 f5 ff ff       	call   800f17 <close>
	return r;
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019fb:	eb 0c                	jmp    801a09 <spawn+0x501>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8019fd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a03:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a09:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	5f                   	pop    %edi
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a17:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801a1e:	ff ff ff 
  801a21:	eb e6                	jmp    801a09 <spawn+0x501>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a23:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801a29:	eb de                	jmp    801a09 <spawn+0x501>

00801a2b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a33:	8d 45 14             	lea    0x14(%ebp),%eax
  801a36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3a:	74 5f                	je     801a9b <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801a3c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801a41:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	83 c0 04             	add    $0x4,%eax
  801a47:	83 3a 00             	cmpl   $0x0,(%edx)
  801a4a:	75 f5                	jne    801a41 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801a4c:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801a53:	83 e0 f0             	and    $0xfffffff0,%eax
  801a56:	29 c4                	sub    %eax,%esp
  801a58:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801a5c:	83 e0 f0             	and    $0xfffffff0,%eax
  801a5f:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801a61:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801a63:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801a6a:	00 

	va_start(vl, arg0);
  801a6b:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801a6e:	89 ce                	mov    %ecx,%esi
  801a70:	85 c9                	test   %ecx,%ecx
  801a72:	74 14                	je     801a88 <spawnl+0x5d>
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801a79:	40                   	inc    %eax
  801a7a:	89 d1                	mov    %edx,%ecx
  801a7c:	83 c2 04             	add    $0x4,%edx
  801a7f:	8b 09                	mov    (%ecx),%ecx
  801a81:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801a84:	39 f0                	cmp    %esi,%eax
  801a86:	72 f1                	jb     801a79 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	ff 75 08             	pushl  0x8(%ebp)
  801a8f:	e8 74 fa ff ff       	call   801508 <spawn>
}
  801a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801a9b:	83 ec 20             	sub    $0x20,%esp
  801a9e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801aa2:	83 e0 f0             	and    $0xfffffff0,%eax
  801aa5:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801aa7:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801aa9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801ab0:	eb d6                	jmp    801a88 <spawnl+0x5d>
	...

00801ab4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	e8 81 f2 ff ff       	call   800d48 <fd2data>
  801ac7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ac9:	83 c4 08             	add    $0x8,%esp
  801acc:	68 b4 28 80 00       	push   $0x8028b4
  801ad1:	56                   	push   %esi
  801ad2:	e8 9f ec ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ad7:	8b 43 04             	mov    0x4(%ebx),%eax
  801ada:	2b 03                	sub    (%ebx),%eax
  801adc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ae2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ae9:	00 00 00 
	stat->st_dev = &devpipe;
  801aec:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801af3:	30 80 00 
	return 0;
}
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
  801afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5e                   	pop    %esi
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	53                   	push   %ebx
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b0c:	53                   	push   %ebx
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 2e f1 ff ff       	call   800c42 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b14:	89 1c 24             	mov    %ebx,(%esp)
  801b17:	e8 2c f2 ff ff       	call   800d48 <fd2data>
  801b1c:	83 c4 08             	add    $0x8,%esp
  801b1f:	50                   	push   %eax
  801b20:	6a 00                	push   $0x0
  801b22:	e8 1b f1 ff ff       	call   800c42 <sys_page_unmap>
}
  801b27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 1c             	sub    $0x1c,%esp
  801b35:	89 c7                	mov    %eax,%edi
  801b37:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	57                   	push   %edi
  801b46:	e8 c5 05 00 00       	call   802110 <pageref>
  801b4b:	89 c6                	mov    %eax,%esi
  801b4d:	83 c4 04             	add    $0x4,%esp
  801b50:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b53:	e8 b8 05 00 00       	call   802110 <pageref>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	39 c6                	cmp    %eax,%esi
  801b5d:	0f 94 c0             	sete   %al
  801b60:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b63:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6c:	39 cb                	cmp    %ecx,%ebx
  801b6e:	75 08                	jne    801b78 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b78:	83 f8 01             	cmp    $0x1,%eax
  801b7b:	75 bd                	jne    801b3a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b7d:	8b 42 58             	mov    0x58(%edx),%eax
  801b80:	6a 01                	push   $0x1
  801b82:	50                   	push   %eax
  801b83:	53                   	push   %ebx
  801b84:	68 bb 28 80 00       	push   $0x8028bb
  801b89:	e8 32 e6 ff ff       	call   8001c0 <cprintf>
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	eb a7                	jmp    801b3a <_pipeisclosed+0xe>

00801b93 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 28             	sub    $0x28,%esp
  801b9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b9f:	56                   	push   %esi
  801ba0:	e8 a3 f1 ff ff       	call   800d48 <fd2data>
  801ba5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bae:	75 4a                	jne    801bfa <devpipe_write+0x67>
  801bb0:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb5:	eb 56                	jmp    801c0d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bb7:	89 da                	mov    %ebx,%edx
  801bb9:	89 f0                	mov    %esi,%eax
  801bbb:	e8 6c ff ff ff       	call   801b2c <_pipeisclosed>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	75 4d                	jne    801c11 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc4:	e8 08 f0 ff ff       	call   800bd1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc9:	8b 43 04             	mov    0x4(%ebx),%eax
  801bcc:	8b 13                	mov    (%ebx),%edx
  801bce:	83 c2 20             	add    $0x20,%edx
  801bd1:	39 d0                	cmp    %edx,%eax
  801bd3:	73 e2                	jae    801bb7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bdd:	79 05                	jns    801be4 <devpipe_write+0x51>
  801bdf:	4a                   	dec    %edx
  801be0:	83 ca e0             	or     $0xffffffe0,%edx
  801be3:	42                   	inc    %edx
  801be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801bea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bee:	40                   	inc    %eax
  801bef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf2:	47                   	inc    %edi
  801bf3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801bf6:	77 07                	ja     801bff <devpipe_write+0x6c>
  801bf8:	eb 13                	jmp    801c0d <devpipe_write+0x7a>
  801bfa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bff:	8b 43 04             	mov    0x4(%ebx),%eax
  801c02:	8b 13                	mov    (%ebx),%edx
  801c04:	83 c2 20             	add    $0x20,%edx
  801c07:	39 d0                	cmp    %edx,%eax
  801c09:	73 ac                	jae    801bb7 <devpipe_write+0x24>
  801c0b:	eb c8                	jmp    801bd5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c0d:	89 f8                	mov    %edi,%eax
  801c0f:	eb 05                	jmp    801c16 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c19:	5b                   	pop    %ebx
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 18             	sub    $0x18,%esp
  801c27:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2a:	57                   	push   %edi
  801c2b:	e8 18 f1 ff ff       	call   800d48 <fd2data>
  801c30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c39:	75 44                	jne    801c7f <devpipe_read+0x61>
  801c3b:	be 00 00 00 00       	mov    $0x0,%esi
  801c40:	eb 4f                	jmp    801c91 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c42:	89 f0                	mov    %esi,%eax
  801c44:	eb 54                	jmp    801c9a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c46:	89 da                	mov    %ebx,%edx
  801c48:	89 f8                	mov    %edi,%eax
  801c4a:	e8 dd fe ff ff       	call   801b2c <_pipeisclosed>
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	75 42                	jne    801c95 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c53:	e8 79 ef ff ff       	call   800bd1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c58:	8b 03                	mov    (%ebx),%eax
  801c5a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c5d:	74 e7                	je     801c46 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c5f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c64:	79 05                	jns    801c6b <devpipe_read+0x4d>
  801c66:	48                   	dec    %eax
  801c67:	83 c8 e0             	or     $0xffffffe0,%eax
  801c6a:	40                   	inc    %eax
  801c6b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c72:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c75:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c77:	46                   	inc    %esi
  801c78:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c7b:	77 07                	ja     801c84 <devpipe_read+0x66>
  801c7d:	eb 12                	jmp    801c91 <devpipe_read+0x73>
  801c7f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801c84:	8b 03                	mov    (%ebx),%eax
  801c86:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c89:	75 d4                	jne    801c5f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8b:	85 f6                	test   %esi,%esi
  801c8d:	75 b3                	jne    801c42 <devpipe_read+0x24>
  801c8f:	eb b5                	jmp    801c46 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c91:	89 f0                	mov    %esi,%eax
  801c93:	eb 05                	jmp    801c9a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 28             	sub    $0x28,%esp
  801cab:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cb1:	50                   	push   %eax
  801cb2:	e8 a9 f0 ff ff       	call   800d60 <fd_alloc>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	0f 88 24 01 00 00    	js     801de8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	68 07 04 00 00       	push   $0x407
  801ccc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 22 ef ff ff       	call   800bf8 <sys_page_alloc>
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	0f 88 05 01 00 00    	js     801de8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	e8 71 f0 ff ff       	call   800d60 <fd_alloc>
  801cef:	89 c3                	mov    %eax,%ebx
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	0f 88 dc 00 00 00    	js     801dd8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfc:	83 ec 04             	sub    $0x4,%esp
  801cff:	68 07 04 00 00       	push   $0x407
  801d04:	ff 75 e0             	pushl  -0x20(%ebp)
  801d07:	6a 00                	push   $0x0
  801d09:	e8 ea ee ff ff       	call   800bf8 <sys_page_alloc>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	85 c0                	test   %eax,%eax
  801d15:	0f 88 bd 00 00 00    	js     801dd8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d21:	e8 22 f0 ff ff       	call   800d48 <fd2data>
  801d26:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d28:	83 c4 0c             	add    $0xc,%esp
  801d2b:	68 07 04 00 00       	push   $0x407
  801d30:	50                   	push   %eax
  801d31:	6a 00                	push   $0x0
  801d33:	e8 c0 ee ff ff       	call   800bf8 <sys_page_alloc>
  801d38:	89 c3                	mov    %eax,%ebx
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	0f 88 83 00 00 00    	js     801dc8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	ff 75 e0             	pushl  -0x20(%ebp)
  801d4b:	e8 f8 ef ff ff       	call   800d48 <fd2data>
  801d50:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d57:	50                   	push   %eax
  801d58:	6a 00                	push   $0x0
  801d5a:	56                   	push   %esi
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 ba ee ff ff       	call   800c1c <sys_page_map>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 4f                	js     801dba <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d6b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d74:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d79:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d80:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d89:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d8e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d9b:	e8 98 ef ff ff       	call   800d38 <fd2num>
  801da0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801da2:	83 c4 04             	add    $0x4,%esp
  801da5:	ff 75 e0             	pushl  -0x20(%ebp)
  801da8:	e8 8b ef ff ff       	call   800d38 <fd2num>
  801dad:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db8:	eb 2e                	jmp    801de8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	56                   	push   %esi
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 7d ee ff ff       	call   800c42 <sys_page_unmap>
  801dc5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc8:	83 ec 08             	sub    $0x8,%esp
  801dcb:	ff 75 e0             	pushl  -0x20(%ebp)
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 6d ee ff ff       	call   800c42 <sys_page_unmap>
  801dd5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd8:	83 ec 08             	sub    $0x8,%esp
  801ddb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dde:	6a 00                	push   $0x0
  801de0:	e8 5d ee ff ff       	call   800c42 <sys_page_unmap>
  801de5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	ff 75 08             	pushl  0x8(%ebp)
  801dff:	e8 cf ef ff ff       	call   800dd3 <fd_lookup>
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 18                	js     801e23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e11:	e8 32 ef ff ff       	call   800d48 <fd2data>
	return _pipeisclosed(fd, p);
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1b:	e8 0c fd ff ff       	call   801b2c <_pipeisclosed>
  801e20:	83 c4 10             	add    $0x10,%esp
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    
  801e25:	00 00                	add    %al,(%eax)
	...

00801e28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e38:	68 d3 28 80 00       	push   $0x8028d3
  801e3d:	ff 75 0c             	pushl  0xc(%ebp)
  801e40:	e8 31 e9 ff ff       	call   800776 <strcpy>
	return 0;
}
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5c:	74 45                	je     801ea3 <devcons_write+0x57>
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e63:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e68:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e71:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e73:	83 fb 7f             	cmp    $0x7f,%ebx
  801e76:	76 05                	jbe    801e7d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801e78:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e7d:	83 ec 04             	sub    $0x4,%esp
  801e80:	53                   	push   %ebx
  801e81:	03 45 0c             	add    0xc(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	57                   	push   %edi
  801e86:	e8 ac ea ff ff       	call   800937 <memmove>
		sys_cputs(buf, m);
  801e8b:	83 c4 08             	add    $0x8,%esp
  801e8e:	53                   	push   %ebx
  801e8f:	57                   	push   %edi
  801e90:	e8 ac ec ff ff       	call   800b41 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e95:	01 de                	add    %ebx,%esi
  801e97:	89 f0                	mov    %esi,%eax
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e9f:	72 cd                	jb     801e6e <devcons_write+0x22>
  801ea1:	eb 05                	jmp    801ea8 <devcons_write+0x5c>
  801ea3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea8:	89 f0                	mov    %esi,%eax
  801eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801eb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebc:	75 07                	jne    801ec5 <devcons_read+0x13>
  801ebe:	eb 25                	jmp    801ee5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec0:	e8 0c ed ff ff       	call   800bd1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec5:	e8 9d ec ff ff       	call   800b67 <sys_cgetc>
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	74 f2                	je     801ec0 <devcons_read+0xe>
  801ece:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 1d                	js     801ef1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed4:	83 f8 04             	cmp    $0x4,%eax
  801ed7:	74 13                	je     801eec <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	88 10                	mov    %dl,(%eax)
	return 1;
  801ede:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee3:	eb 0c                	jmp    801ef1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eea:	eb 05                	jmp    801ef1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  801efc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eff:	6a 01                	push   $0x1
  801f01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	e8 37 ec ff ff       	call   800b41 <sys_cputs>
  801f0a:	83 c4 10             	add    $0x10,%esp
}
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    

00801f0f <getchar>:

int
getchar(void)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f15:	6a 01                	push   $0x1
  801f17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1a:	50                   	push   %eax
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 32 f1 ff ff       	call   801054 <read>
	if (r < 0)
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 0f                	js     801f38 <getchar+0x29>
		return r;
	if (r < 1)
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	7e 06                	jle    801f33 <getchar+0x24>
		return -E_EOF;
	return c;
  801f2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f31:	eb 05                	jmp    801f38 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f33:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	ff 75 08             	pushl  0x8(%ebp)
  801f47:	e8 87 ee ff ff       	call   800dd3 <fd_lookup>
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 11                	js     801f64 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f5c:	39 10                	cmp    %edx,(%eax)
  801f5e:	0f 94 c0             	sete   %al
  801f61:	0f b6 c0             	movzbl %al,%eax
}
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <opencons>:

int
opencons(void)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6f:	50                   	push   %eax
  801f70:	e8 eb ed ff ff       	call   800d60 <fd_alloc>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 3a                	js     801fb6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	68 07 04 00 00       	push   $0x407
  801f84:	ff 75 f4             	pushl  -0xc(%ebp)
  801f87:	6a 00                	push   $0x0
  801f89:	e8 6a ec ff ff       	call   800bf8 <sys_page_alloc>
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 21                	js     801fb6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	50                   	push   %eax
  801fae:	e8 85 ed ff ff       	call   800d38 <fd2num>
  801fb3:	83 c4 10             	add    $0x10,%esp
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	57                   	push   %edi
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fc7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	57                   	push   %edi
  801fcd:	68 df 28 80 00       	push   $0x8028df
  801fd2:	e8 e9 e1 ff ff       	call   8001c0 <cprintf>
	int r;
	if (pg != NULL) {
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	74 28                	je     802006 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801fde:	83 ec 0c             	sub    $0xc,%esp
  801fe1:	68 ef 28 80 00       	push   $0x8028ef
  801fe6:	e8 d5 e1 ff ff       	call   8001c0 <cprintf>
		r = sys_ipc_recv(pg);
  801feb:	89 1c 24             	mov    %ebx,(%esp)
  801fee:	e8 00 ed ff ff       	call   800cf3 <sys_ipc_recv>
  801ff3:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801ff5:	c7 04 24 d8 27 80 00 	movl   $0x8027d8,(%esp)
  801ffc:	e8 bf e1 ff ff       	call   8001c0 <cprintf>
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	eb 12                	jmp    802018 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802006:	83 ec 0c             	sub    $0xc,%esp
  802009:	68 00 00 c0 ee       	push   $0xeec00000
  80200e:	e8 e0 ec ff ff       	call   800cf3 <sys_ipc_recv>
  802013:	89 c3                	mov    %eax,%ebx
  802015:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802018:	85 db                	test   %ebx,%ebx
  80201a:	75 26                	jne    802042 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80201c:	85 ff                	test   %edi,%edi
  80201e:	74 0a                	je     80202a <ipc_recv+0x72>
  802020:	a1 04 40 80 00       	mov    0x804004,%eax
  802025:	8b 40 74             	mov    0x74(%eax),%eax
  802028:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80202a:	85 f6                	test   %esi,%esi
  80202c:	74 0a                	je     802038 <ipc_recv+0x80>
  80202e:	a1 04 40 80 00       	mov    0x804004,%eax
  802033:	8b 40 78             	mov    0x78(%eax),%eax
  802036:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  802038:	a1 04 40 80 00       	mov    0x804004,%eax
  80203d:	8b 58 70             	mov    0x70(%eax),%ebx
  802040:	eb 14                	jmp    802056 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802042:	85 ff                	test   %edi,%edi
  802044:	74 06                	je     80204c <ipc_recv+0x94>
  802046:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  80204c:	85 f6                	test   %esi,%esi
  80204e:	74 06                	je     802056 <ipc_recv+0x9e>
  802050:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  802056:	89 d8                	mov    %ebx,%eax
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	53                   	push   %ebx
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80206c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80206f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 25                	jne    80209b <ipc_send+0x3b>
  802076:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80207b:	eb 1e                	jmp    80209b <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80207d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802080:	75 07                	jne    802089 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802082:	e8 4a eb ff ff       	call   800bd1 <sys_yield>
  802087:	eb 12                	jmp    80209b <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802089:	50                   	push   %eax
  80208a:	68 f6 28 80 00       	push   $0x8028f6
  80208f:	6a 45                	push   $0x45
  802091:	68 09 29 80 00       	push   $0x802909
  802096:	e8 4d e0 ff ff       	call   8000e8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	57                   	push   %edi
  80209e:	ff 75 08             	pushl  0x8(%ebp)
  8020a1:	e8 28 ec ff ff       	call   800cce <sys_ipc_try_send>
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	75 d0                	jne    80207d <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8020ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b0:	5b                   	pop    %ebx
  8020b1:	5e                   	pop    %esi
  8020b2:	5f                   	pop    %edi
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	53                   	push   %ebx
  8020b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020bc:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8020c2:	74 22                	je     8020e6 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8020c9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	c1 e2 07             	shl    $0x7,%edx
  8020d5:	29 ca                	sub    %ecx,%edx
  8020d7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020dd:	8b 52 50             	mov    0x50(%edx),%edx
  8020e0:	39 da                	cmp    %ebx,%edx
  8020e2:	75 1d                	jne    802101 <ipc_find_env+0x4c>
  8020e4:	eb 05                	jmp    8020eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8020f2:	c1 e0 07             	shl    $0x7,%eax
  8020f5:	29 d0                	sub    %edx,%eax
  8020f7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020fc:	8b 40 40             	mov    0x40(%eax),%eax
  8020ff:	eb 0c                	jmp    80210d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802101:	40                   	inc    %eax
  802102:	3d 00 04 00 00       	cmp    $0x400,%eax
  802107:	75 c0                	jne    8020c9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802109:	66 b8 00 00          	mov    $0x0,%ax
}
  80210d:	5b                   	pop    %ebx
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802116:	89 c2                	mov    %eax,%edx
  802118:	c1 ea 16             	shr    $0x16,%edx
  80211b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802122:	f6 c2 01             	test   $0x1,%dl
  802125:	74 1e                	je     802145 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802127:	c1 e8 0c             	shr    $0xc,%eax
  80212a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802131:	a8 01                	test   $0x1,%al
  802133:	74 17                	je     80214c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802135:	c1 e8 0c             	shr    $0xc,%eax
  802138:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80213f:	ef 
  802140:	0f b7 c0             	movzwl %ax,%eax
  802143:	eb 0c                	jmp    802151 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
  80214a:	eb 05                	jmp    802151 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80214c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802151:	c9                   	leave  
  802152:	c3                   	ret    
	...

00802154 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	57                   	push   %edi
  802158:	56                   	push   %esi
  802159:	83 ec 10             	sub    $0x10,%esp
  80215c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802162:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802165:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802168:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80216b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80216e:	85 c0                	test   %eax,%eax
  802170:	75 2e                	jne    8021a0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802172:	39 f1                	cmp    %esi,%ecx
  802174:	77 5a                	ja     8021d0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802176:	85 c9                	test   %ecx,%ecx
  802178:	75 0b                	jne    802185 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80217a:	b8 01 00 00 00       	mov    $0x1,%eax
  80217f:	31 d2                	xor    %edx,%edx
  802181:	f7 f1                	div    %ecx
  802183:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802185:	31 d2                	xor    %edx,%edx
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f1                	div    %ecx
  80218b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80218d:	89 f8                	mov    %edi,%eax
  80218f:	f7 f1                	div    %ecx
  802191:	89 c7                	mov    %eax,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021a0:	39 f0                	cmp    %esi,%eax
  8021a2:	77 1c                	ja     8021c0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021a4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8021a7:	83 f7 1f             	xor    $0x1f,%edi
  8021aa:	75 3c                	jne    8021e8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021ac:	39 f0                	cmp    %esi,%eax
  8021ae:	0f 82 90 00 00 00    	jb     802244 <__udivdi3+0xf0>
  8021b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021b7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8021ba:	0f 86 84 00 00 00    	jbe    802244 <__udivdi3+0xf0>
  8021c0:	31 f6                	xor    %esi,%esi
  8021c2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021c4:	89 f8                	mov    %edi,%eax
  8021c6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	5e                   	pop    %esi
  8021cc:	5f                   	pop    %edi
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    
  8021cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	89 f8                	mov    %edi,%eax
  8021d4:	f7 f1                	div    %ecx
  8021d6:	89 c7                	mov    %eax,%edi
  8021d8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021da:	89 f8                	mov    %edi,%eax
  8021dc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	c9                   	leave  
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021e8:	89 f9                	mov    %edi,%ecx
  8021ea:	d3 e0                	shl    %cl,%eax
  8021ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021ef:	b8 20 00 00 00       	mov    $0x20,%eax
  8021f4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8021f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f9:	88 c1                	mov    %al,%cl
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802200:	09 ca                	or     %ecx,%edx
  802202:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802205:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802208:	89 f9                	mov    %edi,%ecx
  80220a:	d3 e2                	shl    %cl,%edx
  80220c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80220f:	89 f2                	mov    %esi,%edx
  802211:	88 c1                	mov    %al,%cl
  802213:	d3 ea                	shr    %cl,%edx
  802215:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802218:	89 f2                	mov    %esi,%edx
  80221a:	89 f9                	mov    %edi,%ecx
  80221c:	d3 e2                	shl    %cl,%edx
  80221e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802221:	88 c1                	mov    %al,%cl
  802223:	d3 ee                	shr    %cl,%esi
  802225:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802227:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80222a:	89 f0                	mov    %esi,%eax
  80222c:	89 ca                	mov    %ecx,%edx
  80222e:	f7 75 ec             	divl   -0x14(%ebp)
  802231:	89 d1                	mov    %edx,%ecx
  802233:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802235:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802238:	39 d1                	cmp    %edx,%ecx
  80223a:	72 28                	jb     802264 <__udivdi3+0x110>
  80223c:	74 1a                	je     802258 <__udivdi3+0x104>
  80223e:	89 f7                	mov    %esi,%edi
  802240:	31 f6                	xor    %esi,%esi
  802242:	eb 80                	jmp    8021c4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802244:	31 f6                	xor    %esi,%esi
  802246:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80224b:	89 f8                	mov    %edi,%eax
  80224d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80224f:	83 c4 10             	add    $0x10,%esp
  802252:	5e                   	pop    %esi
  802253:	5f                   	pop    %edi
  802254:	c9                   	leave  
  802255:	c3                   	ret    
  802256:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802258:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80225f:	39 c2                	cmp    %eax,%edx
  802261:	73 db                	jae    80223e <__udivdi3+0xea>
  802263:	90                   	nop
		{
		  q0--;
  802264:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802267:	31 f6                	xor    %esi,%esi
  802269:	e9 56 ff ff ff       	jmp    8021c4 <__udivdi3+0x70>
	...

00802270 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	57                   	push   %edi
  802274:	56                   	push   %esi
  802275:	83 ec 20             	sub    $0x20,%esp
  802278:	8b 45 08             	mov    0x8(%ebp),%eax
  80227b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80227e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802281:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802284:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802287:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80228a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80228d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80228f:	85 ff                	test   %edi,%edi
  802291:	75 15                	jne    8022a8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802293:	39 f1                	cmp    %esi,%ecx
  802295:	0f 86 99 00 00 00    	jbe    802334 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80229b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80229d:	89 d0                	mov    %edx,%eax
  80229f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a1:	83 c4 20             	add    $0x20,%esp
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	c9                   	leave  
  8022a7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022a8:	39 f7                	cmp    %esi,%edi
  8022aa:	0f 87 a4 00 00 00    	ja     802354 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022b0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8022b3:	83 f0 1f             	xor    $0x1f,%eax
  8022b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022b9:	0f 84 a1 00 00 00    	je     802360 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022bf:	89 f8                	mov    %edi,%eax
  8022c1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022c4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022c6:	bf 20 00 00 00       	mov    $0x20,%edi
  8022cb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8022ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 ea                	shr    %cl,%edx
  8022d5:	09 c2                	or     %eax,%edx
  8022d7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022e0:	d3 e0                	shl    %cl,%eax
  8022e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022e5:	89 f2                	mov    %esi,%edx
  8022e7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8022e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022ec:	d3 e0                	shl    %cl,%eax
  8022ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022f4:	89 f9                	mov    %edi,%ecx
  8022f6:	d3 e8                	shr    %cl,%eax
  8022f8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8022fa:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022fc:	89 f2                	mov    %esi,%edx
  8022fe:	f7 75 f0             	divl   -0x10(%ebp)
  802301:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802303:	f7 65 f4             	mull   -0xc(%ebp)
  802306:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802309:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80230b:	39 d6                	cmp    %edx,%esi
  80230d:	72 71                	jb     802380 <__umoddi3+0x110>
  80230f:	74 7f                	je     802390 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802314:	29 c8                	sub    %ecx,%eax
  802316:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802318:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	89 f9                	mov    %edi,%ecx
  802321:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802323:	09 d0                	or     %edx,%eax
  802325:	89 f2                	mov    %esi,%edx
  802327:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80232a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80232c:	83 c4 20             	add    $0x20,%esp
  80232f:	5e                   	pop    %esi
  802330:	5f                   	pop    %edi
  802331:	c9                   	leave  
  802332:	c3                   	ret    
  802333:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802334:	85 c9                	test   %ecx,%ecx
  802336:	75 0b                	jne    802343 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802338:	b8 01 00 00 00       	mov    $0x1,%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	f7 f1                	div    %ecx
  802341:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802343:	89 f0                	mov    %esi,%eax
  802345:	31 d2                	xor    %edx,%edx
  802347:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80234c:	f7 f1                	div    %ecx
  80234e:	e9 4a ff ff ff       	jmp    80229d <__umoddi3+0x2d>
  802353:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802354:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802356:	83 c4 20             	add    $0x20,%esp
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802360:	39 f7                	cmp    %esi,%edi
  802362:	72 05                	jb     802369 <__umoddi3+0xf9>
  802364:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802367:	77 0c                	ja     802375 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802369:	89 f2                	mov    %esi,%edx
  80236b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80236e:	29 c8                	sub    %ecx,%eax
  802370:	19 fa                	sbb    %edi,%edx
  802372:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802378:	83 c4 20             	add    $0x20,%esp
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	c9                   	leave  
  80237e:	c3                   	ret    
  80237f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802380:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802383:	89 c1                	mov    %eax,%ecx
  802385:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802388:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80238b:	eb 84                	jmp    802311 <__umoddi3+0xa1>
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802390:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802393:	72 eb                	jb     802380 <__umoddi3+0x110>
  802395:	89 f2                	mov    %esi,%edx
  802397:	e9 75 ff ff ff       	jmp    802311 <__umoddi3+0xa1>
