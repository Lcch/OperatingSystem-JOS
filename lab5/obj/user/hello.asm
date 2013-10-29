
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 e0 1d 80 00       	push   $0x801de0
  80003f:	e8 18 01 00 00       	call   80015c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 40 80 00       	mov    0x804004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 ee 1d 80 00       	push   $0x801dee
  800055:	e8 02 01 00 00       	call   80015c <cprintf>
  80005a:	83 c4 10             	add    $0x10,%esp
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    
	...

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
  800068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 d9 0a 00 00       	call   800b49 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	29 d0                	sub    %edx,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 f6                	test   %esi,%esi
  80008d:	7e 07                	jle    800096 <libmain+0x36>
		binaryname = argv[0];
  80008f:	8b 03                	mov    (%ebx),%eax
  800091:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	53                   	push   %ebx
  80009a:	56                   	push   %esi
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 23 0e 00 00       	call   800ede <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 62 0a 00 00       	call   800b27 <sys_env_destroy>
  8000c5:	83 c4 10             	add    $0x10,%esp
}
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    
	...

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 04             	sub    $0x4,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	40                   	inc    %eax
  8000e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e7:	75 1a                	jne    800103 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	68 ff 00 00 00       	push   $0xff
  8000f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f4:	50                   	push   %eax
  8000f5:	e8 e3 09 00 00       	call   800add <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800100:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800103:	ff 43 04             	incl   0x4(%ebx)
}
  800106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	ff 75 08             	pushl  0x8(%ebp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	50                   	push   %eax
  800135:	68 cc 00 80 00       	push   $0x8000cc
  80013a:	e8 82 01 00 00       	call   8002c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800148:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 89 09 00 00       	call   800add <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800162:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800165:	50                   	push   %eax
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	e8 9d ff ff ff       	call   80010b <vcprintf>
	va_end(ap);

	return cnt;
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	8b 55 0c             	mov    0xc(%ebp),%edx
  800184:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800187:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80018a:	8b 45 10             	mov    0x10(%ebp),%eax
  80018d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800190:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800193:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800196:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80019d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001a0:	72 0c                	jb     8001ae <printnum+0x3e>
  8001a2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001a5:	76 07                	jbe    8001ae <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a7:	4b                   	dec    %ebx
  8001a8:	85 db                	test   %ebx,%ebx
  8001aa:	7f 31                	jg     8001dd <printnum+0x6d>
  8001ac:	eb 3f                	jmp    8001ed <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	57                   	push   %edi
  8001b2:	4b                   	dec    %ebx
  8001b3:	53                   	push   %ebx
  8001b4:	50                   	push   %eax
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8001be:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c4:	e8 c3 19 00 00       	call   801b8c <__udivdi3>
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	52                   	push   %edx
  8001cd:	50                   	push   %eax
  8001ce:	89 f2                	mov    %esi,%edx
  8001d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001d3:	e8 98 ff ff ff       	call   800170 <printnum>
  8001d8:	83 c4 20             	add    $0x20,%esp
  8001db:	eb 10                	jmp    8001ed <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	56                   	push   %esi
  8001e1:	57                   	push   %edi
  8001e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e5:	4b                   	dec    %ebx
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	85 db                	test   %ebx,%ebx
  8001eb:	7f f0                	jg     8001dd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	56                   	push   %esi
  8001f1:	83 ec 04             	sub    $0x4,%esp
  8001f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 a3 1a 00 00       	call   801ca8 <__umoddi3>
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	0f be 80 0f 1e 80 00 	movsbl 0x801e0f(%eax),%eax
  80020f:	50                   	push   %eax
  800210:	ff 55 e4             	call   *-0x1c(%ebp)
  800213:	83 c4 10             	add    $0x10,%esp
}
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800221:	83 fa 01             	cmp    $0x1,%edx
  800224:	7e 0e                	jle    800234 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	8b 52 04             	mov    0x4(%edx),%edx
  800232:	eb 22                	jmp    800256 <getuint+0x38>
	else if (lflag)
  800234:	85 d2                	test   %edx,%edx
  800236:	74 10                	je     800248 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
  800246:	eb 0e                	jmp    800256 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025b:	83 fa 01             	cmp    $0x1,%edx
  80025e:	7e 0e                	jle    80026e <getint+0x16>
		return va_arg(*ap, long long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 08             	lea    0x8(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	8b 52 04             	mov    0x4(%edx),%edx
  80026c:	eb 1a                	jmp    800288 <getint+0x30>
	else if (lflag)
  80026e:	85 d2                	test   %edx,%edx
  800270:	74 0c                	je     80027e <getint+0x26>
		return va_arg(*ap, long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	99                   	cltd   
  80027c:	eb 0a                	jmp    800288 <getint+0x30>
	else
		return va_arg(*ap, int);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 04             	lea    0x4(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	99                   	cltd   
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 08                	jae    8002a2 <sprintputch+0x18>
		*b->buf++ = ch;
  80029a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029d:	88 0a                	mov    %cl,(%edx)
  80029f:	42                   	inc    %edx
  8002a0:	89 10                	mov    %edx,(%eax)
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ad:	50                   	push   %eax
  8002ae:	ff 75 10             	pushl  0x10(%ebp)
  8002b1:	ff 75 0c             	pushl  0xc(%ebp)
  8002b4:	ff 75 08             	pushl  0x8(%ebp)
  8002b7:	e8 05 00 00 00       	call   8002c1 <vprintfmt>
	va_end(ap);
  8002bc:	83 c4 10             	add    $0x10,%esp
}
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    

008002c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	57                   	push   %edi
  8002c5:	56                   	push   %esi
  8002c6:	53                   	push   %ebx
  8002c7:	83 ec 2c             	sub    $0x2c,%esp
  8002ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002cd:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d0:	eb 13                	jmp    8002e5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	0f 84 6d 03 00 00    	je     800647 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002da:	83 ec 08             	sub    $0x8,%esp
  8002dd:	57                   	push   %edi
  8002de:	50                   	push   %eax
  8002df:	ff 55 08             	call   *0x8(%ebp)
  8002e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	0f b6 06             	movzbl (%esi),%eax
  8002e8:	46                   	inc    %esi
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 e4                	jne    8002d2 <vprintfmt+0x11>
  8002ee:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800300:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800307:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030c:	eb 28                	jmp    800336 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800310:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800314:	eb 20                	jmp    800336 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800318:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80031c:	eb 18                	jmp    800336 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800320:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800327:	eb 0d                	jmp    800336 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800329:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8a 06                	mov    (%esi),%al
  800338:	0f b6 d0             	movzbl %al,%edx
  80033b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80033e:	83 e8 23             	sub    $0x23,%eax
  800341:	3c 55                	cmp    $0x55,%al
  800343:	0f 87 e0 02 00 00    	ja     800629 <vprintfmt+0x368>
  800349:	0f b6 c0             	movzbl %al,%eax
  80034c:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800353:	83 ea 30             	sub    $0x30,%edx
  800356:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800359:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80035c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 44                	ja     8003a8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	89 de                	mov    %ebx,%esi
  800366:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800369:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80036a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80036d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800371:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800374:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800377:	83 fb 09             	cmp    $0x9,%ebx
  80037a:	76 ed                	jbe    800369 <vprintfmt+0xa8>
  80037c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80037f:	eb 29                	jmp    8003aa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 50 04             	lea    0x4(%eax),%edx
  800387:	89 55 14             	mov    %edx,0x14(%ebp)
  80038a:	8b 00                	mov    (%eax),%eax
  80038c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800391:	eb 17                	jmp    8003aa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800393:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800397:	78 85                	js     80031e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	89 de                	mov    %ebx,%esi
  80039b:	eb 99                	jmp    800336 <vprintfmt+0x75>
  80039d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003a6:	eb 8e                	jmp    800336 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ae:	79 86                	jns    800336 <vprintfmt+0x75>
  8003b0:	e9 74 ff ff ff       	jmp    800329 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi
  8003b8:	e9 79 ff ff ff       	jmp    800336 <vprintfmt+0x75>
  8003bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	57                   	push   %edi
  8003cd:	ff 30                	pushl  (%eax)
  8003cf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d8:	e9 08 ff ff ff       	jmp    8002e5 <vprintfmt+0x24>
  8003dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	79 02                	jns    8003f1 <vprintfmt+0x130>
  8003ef:	f7 d8                	neg    %eax
  8003f1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f3:	83 f8 0f             	cmp    $0xf,%eax
  8003f6:	7f 0b                	jg     800403 <vprintfmt+0x142>
  8003f8:	8b 04 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%eax
  8003ff:	85 c0                	test   %eax,%eax
  800401:	75 1a                	jne    80041d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800403:	52                   	push   %edx
  800404:	68 27 1e 80 00       	push   $0x801e27
  800409:	57                   	push   %edi
  80040a:	ff 75 08             	pushl  0x8(%ebp)
  80040d:	e8 92 fe ff ff       	call   8002a4 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800418:	e9 c8 fe ff ff       	jmp    8002e5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80041d:	50                   	push   %eax
  80041e:	68 f7 21 80 00       	push   $0x8021f7
  800423:	57                   	push   %edi
  800424:	ff 75 08             	pushl  0x8(%ebp)
  800427:	e8 78 fe ff ff       	call   8002a4 <printfmt>
  80042c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800432:	e9 ae fe ff ff       	jmp    8002e5 <vprintfmt+0x24>
  800437:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80043a:	89 de                	mov    %ebx,%esi
  80043c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80043f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800450:	85 c0                	test   %eax,%eax
  800452:	75 07                	jne    80045b <vprintfmt+0x19a>
				p = "(null)";
  800454:	c7 45 d0 20 1e 80 00 	movl   $0x801e20,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80045b:	85 db                	test   %ebx,%ebx
  80045d:	7e 42                	jle    8004a1 <vprintfmt+0x1e0>
  80045f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800463:	74 3c                	je     8004a1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	51                   	push   %ecx
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	e8 6f 02 00 00       	call   8006e0 <strnlen>
  800471:	29 c3                	sub    %eax,%ebx
  800473:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7e 24                	jle    8004a1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80047d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800481:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800484:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
  80048b:	53                   	push   %ebx
  80048c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	4e                   	dec    %esi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 f6                	test   %esi,%esi
  800495:	7f f0                	jg     800487 <vprintfmt+0x1c6>
  800497:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80049a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a4:	0f be 02             	movsbl (%edx),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	75 47                	jne    8004f2 <vprintfmt+0x231>
  8004ab:	eb 37                	jmp    8004e4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b1:	74 16                	je     8004c9 <vprintfmt+0x208>
  8004b3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b6:	83 fa 5e             	cmp    $0x5e,%edx
  8004b9:	76 0e                	jbe    8004c9 <vprintfmt+0x208>
					putch('?', putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	57                   	push   %edi
  8004bf:	6a 3f                	push   $0x3f
  8004c1:	ff 55 08             	call   *0x8(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	eb 0b                	jmp    8004d4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	57                   	push   %edi
  8004cd:	50                   	push   %eax
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d7:	0f be 03             	movsbl (%ebx),%eax
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	74 03                	je     8004e1 <vprintfmt+0x220>
  8004de:	43                   	inc    %ebx
  8004df:	eb 1b                	jmp    8004fc <vprintfmt+0x23b>
  8004e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e8:	7f 1e                	jg     800508 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ed:	e9 f3 fd ff ff       	jmp    8002e5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f5:	43                   	inc    %ebx
  8004f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004fc:	85 f6                	test   %esi,%esi
  8004fe:	78 ad                	js     8004ad <vprintfmt+0x1ec>
  800500:	4e                   	dec    %esi
  800501:	79 aa                	jns    8004ad <vprintfmt+0x1ec>
  800503:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800506:	eb dc                	jmp    8004e4 <vprintfmt+0x223>
  800508:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	57                   	push   %edi
  80050f:	6a 20                	push   $0x20
  800511:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800514:	4b                   	dec    %ebx
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	85 db                	test   %ebx,%ebx
  80051a:	7f ef                	jg     80050b <vprintfmt+0x24a>
  80051c:	e9 c4 fd ff ff       	jmp    8002e5 <vprintfmt+0x24>
  800521:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800524:	89 ca                	mov    %ecx,%edx
  800526:	8d 45 14             	lea    0x14(%ebp),%eax
  800529:	e8 2a fd ff ff       	call   800258 <getint>
  80052e:	89 c3                	mov    %eax,%ebx
  800530:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800532:	85 d2                	test   %edx,%edx
  800534:	78 0a                	js     800540 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053b:	e9 b0 00 00 00       	jmp    8005f0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	57                   	push   %edi
  800544:	6a 2d                	push   $0x2d
  800546:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800549:	f7 db                	neg    %ebx
  80054b:	83 d6 00             	adc    $0x0,%esi
  80054e:	f7 de                	neg    %esi
  800550:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800553:	b8 0a 00 00 00       	mov    $0xa,%eax
  800558:	e9 93 00 00 00       	jmp    8005f0 <vprintfmt+0x32f>
  80055d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800560:	89 ca                	mov    %ecx,%edx
  800562:	8d 45 14             	lea    0x14(%ebp),%eax
  800565:	e8 b4 fc ff ff       	call   80021e <getuint>
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	89 d6                	mov    %edx,%esi
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800573:	eb 7b                	jmp    8005f0 <vprintfmt+0x32f>
  800575:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800578:	89 ca                	mov    %ecx,%edx
  80057a:	8d 45 14             	lea    0x14(%ebp),%eax
  80057d:	e8 d6 fc ff ff       	call   800258 <getint>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800586:	85 d2                	test   %edx,%edx
  800588:	78 07                	js     800591 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80058a:	b8 08 00 00 00       	mov    $0x8,%eax
  80058f:	eb 5f                	jmp    8005f0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	57                   	push   %edi
  800595:	6a 2d                	push   $0x2d
  800597:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80059a:	f7 db                	neg    %ebx
  80059c:	83 d6 00             	adc    $0x0,%esi
  80059f:	f7 de                	neg    %esi
  8005a1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a9:	eb 45                	jmp    8005f0 <vprintfmt+0x32f>
  8005ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	57                   	push   %edi
  8005b2:	6a 30                	push   $0x30
  8005b4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 78                	push   $0x78
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c9:	8b 18                	mov    (%eax),%ebx
  8005cb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d8:	eb 16                	jmp    8005f0 <vprintfmt+0x32f>
  8005da:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dd:	89 ca                	mov    %ecx,%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 37 fc ff ff       	call   80021e <getuint>
  8005e7:	89 c3                	mov    %eax,%ebx
  8005e9:	89 d6                	mov    %edx,%esi
			base = 16;
  8005eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005f7:	52                   	push   %edx
  8005f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005fb:	50                   	push   %eax
  8005fc:	56                   	push   %esi
  8005fd:	53                   	push   %ebx
  8005fe:	89 fa                	mov    %edi,%edx
  800600:	8b 45 08             	mov    0x8(%ebp),%eax
  800603:	e8 68 fb ff ff       	call   800170 <printnum>
			break;
  800608:	83 c4 20             	add    $0x20,%esp
  80060b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060e:	e9 d2 fc ff ff       	jmp    8002e5 <vprintfmt+0x24>
  800613:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	57                   	push   %edi
  80061a:	52                   	push   %edx
  80061b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800624:	e9 bc fc ff ff       	jmp    8002e5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	6a 25                	push   $0x25
  80062f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 02                	jmp    800639 <vprintfmt+0x378>
  800637:	89 c6                	mov    %eax,%esi
  800639:	8d 46 ff             	lea    -0x1(%esi),%eax
  80063c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800640:	75 f5                	jne    800637 <vprintfmt+0x376>
  800642:	e9 9e fc ff ff       	jmp    8002e5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	c9                   	leave  
  80064e:	c3                   	ret    

0080064f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	83 ec 18             	sub    $0x18,%esp
  800655:	8b 45 08             	mov    0x8(%ebp),%eax
  800658:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800662:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066c:	85 c0                	test   %eax,%eax
  80066e:	74 26                	je     800696 <vsnprintf+0x47>
  800670:	85 d2                	test   %edx,%edx
  800672:	7e 29                	jle    80069d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800674:	ff 75 14             	pushl  0x14(%ebp)
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	68 8a 02 80 00       	push   $0x80028a
  800683:	e8 39 fc ff ff       	call   8002c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 0c                	jmp    8006a2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069b:	eb 05                	jmp    8006a2 <vsnprintf+0x53>
  80069d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ad:	50                   	push   %eax
  8006ae:	ff 75 10             	pushl  0x10(%ebp)
  8006b1:	ff 75 0c             	pushl  0xc(%ebp)
  8006b4:	ff 75 08             	pushl  0x8(%ebp)
  8006b7:	e8 93 ff ff ff       	call   80064f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    
	...

008006c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c9:	74 0e                	je     8006d9 <strlen+0x19>
  8006cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006d0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d5:	75 f9                	jne    8006d0 <strlen+0x10>
  8006d7:	eb 05                	jmp    8006de <strlen+0x1e>
  8006d9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	74 17                	je     800704 <strnlen+0x24>
  8006ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8006f0:	74 19                	je     80070b <strnlen+0x2b>
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f8:	39 d0                	cmp    %edx,%eax
  8006fa:	74 14                	je     800710 <strnlen+0x30>
  8006fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800700:	75 f5                	jne    8006f7 <strnlen+0x17>
  800702:	eb 0c                	jmp    800710 <strnlen+0x30>
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	eb 05                	jmp    800710 <strnlen+0x30>
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	ba 00 00 00 00       	mov    $0x0,%edx
  800721:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800724:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800727:	42                   	inc    %edx
  800728:	84 c9                	test   %cl,%cl
  80072a:	75 f5                	jne    800721 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072c:	5b                   	pop    %ebx
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800736:	53                   	push   %ebx
  800737:	e8 84 ff ff ff       	call   8006c0 <strlen>
  80073c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800745:	50                   	push   %eax
  800746:	e8 c7 ff ff ff       	call   800712 <strcpy>
	return dst;
}
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	56                   	push   %esi
  800756:	53                   	push   %ebx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800760:	85 f6                	test   %esi,%esi
  800762:	74 15                	je     800779 <strncpy+0x27>
  800764:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800769:	8a 1a                	mov    (%edx),%bl
  80076b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076e:	80 3a 01             	cmpb   $0x1,(%edx)
  800771:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800774:	41                   	inc    %ecx
  800775:	39 ce                	cmp    %ecx,%esi
  800777:	77 f0                	ja     800769 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	57                   	push   %edi
  800781:	56                   	push   %esi
  800782:	53                   	push   %ebx
  800783:	8b 7d 08             	mov    0x8(%ebp),%edi
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800789:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078c:	85 f6                	test   %esi,%esi
  80078e:	74 32                	je     8007c2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800790:	83 fe 01             	cmp    $0x1,%esi
  800793:	74 22                	je     8007b7 <strlcpy+0x3a>
  800795:	8a 0b                	mov    (%ebx),%cl
  800797:	84 c9                	test   %cl,%cl
  800799:	74 20                	je     8007bb <strlcpy+0x3e>
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007a2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a5:	88 08                	mov    %cl,(%eax)
  8007a7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a8:	39 f2                	cmp    %esi,%edx
  8007aa:	74 11                	je     8007bd <strlcpy+0x40>
  8007ac:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007b0:	42                   	inc    %edx
  8007b1:	84 c9                	test   %cl,%cl
  8007b3:	75 f0                	jne    8007a5 <strlcpy+0x28>
  8007b5:	eb 06                	jmp    8007bd <strlcpy+0x40>
  8007b7:	89 f8                	mov    %edi,%eax
  8007b9:	eb 02                	jmp    8007bd <strlcpy+0x40>
  8007bb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 00 00             	movb   $0x0,(%eax)
  8007c0:	eb 02                	jmp    8007c4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007c4:	29 f8                	sub    %edi,%eax
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5f                   	pop    %edi
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d4:	8a 01                	mov    (%ecx),%al
  8007d6:	84 c0                	test   %al,%al
  8007d8:	74 10                	je     8007ea <strcmp+0x1f>
  8007da:	3a 02                	cmp    (%edx),%al
  8007dc:	75 0c                	jne    8007ea <strcmp+0x1f>
		p++, q++;
  8007de:	41                   	inc    %ecx
  8007df:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e0:	8a 01                	mov    (%ecx),%al
  8007e2:	84 c0                	test   %al,%al
  8007e4:	74 04                	je     8007ea <strcmp+0x1f>
  8007e6:	3a 02                	cmp    (%edx),%al
  8007e8:	74 f4                	je     8007de <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 c0             	movzbl %al,%eax
  8007ed:	0f b6 12             	movzbl (%edx),%edx
  8007f0:	29 d0                	sub    %edx,%eax
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800801:	85 c0                	test   %eax,%eax
  800803:	74 1b                	je     800820 <strncmp+0x2c>
  800805:	8a 1a                	mov    (%edx),%bl
  800807:	84 db                	test   %bl,%bl
  800809:	74 24                	je     80082f <strncmp+0x3b>
  80080b:	3a 19                	cmp    (%ecx),%bl
  80080d:	75 20                	jne    80082f <strncmp+0x3b>
  80080f:	48                   	dec    %eax
  800810:	74 15                	je     800827 <strncmp+0x33>
		n--, p++, q++;
  800812:	42                   	inc    %edx
  800813:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800814:	8a 1a                	mov    (%edx),%bl
  800816:	84 db                	test   %bl,%bl
  800818:	74 15                	je     80082f <strncmp+0x3b>
  80081a:	3a 19                	cmp    (%ecx),%bl
  80081c:	74 f1                	je     80080f <strncmp+0x1b>
  80081e:	eb 0f                	jmp    80082f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 05                	jmp    80082c <strncmp+0x38>
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082c:	5b                   	pop    %ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 02             	movzbl (%edx),%eax
  800832:	0f b6 11             	movzbl (%ecx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb f3                	jmp    80082c <strncmp+0x38>

00800839 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800842:	8a 10                	mov    (%eax),%dl
  800844:	84 d2                	test   %dl,%dl
  800846:	74 18                	je     800860 <strchr+0x27>
		if (*s == c)
  800848:	38 ca                	cmp    %cl,%dl
  80084a:	75 06                	jne    800852 <strchr+0x19>
  80084c:	eb 17                	jmp    800865 <strchr+0x2c>
  80084e:	38 ca                	cmp    %cl,%dl
  800850:	74 13                	je     800865 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800852:	40                   	inc    %eax
  800853:	8a 10                	mov    (%eax),%dl
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f5                	jne    80084e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 05                	jmp    800865 <strchr+0x2c>
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800870:	8a 10                	mov    (%eax),%dl
  800872:	84 d2                	test   %dl,%dl
  800874:	74 11                	je     800887 <strfind+0x20>
		if (*s == c)
  800876:	38 ca                	cmp    %cl,%dl
  800878:	75 06                	jne    800880 <strfind+0x19>
  80087a:	eb 0b                	jmp    800887 <strfind+0x20>
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	74 07                	je     800887 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800880:	40                   	inc    %eax
  800881:	8a 10                	mov    (%eax),%dl
  800883:	84 d2                	test   %dl,%dl
  800885:	75 f5                	jne    80087c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	57                   	push   %edi
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800892:	8b 45 0c             	mov    0xc(%ebp),%eax
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800898:	85 c9                	test   %ecx,%ecx
  80089a:	74 30                	je     8008cc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a2:	75 25                	jne    8008c9 <memset+0x40>
  8008a4:	f6 c1 03             	test   $0x3,%cl
  8008a7:	75 20                	jne    8008c9 <memset+0x40>
		c &= 0xFF;
  8008a9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ac:	89 d3                	mov    %edx,%ebx
  8008ae:	c1 e3 08             	shl    $0x8,%ebx
  8008b1:	89 d6                	mov    %edx,%esi
  8008b3:	c1 e6 18             	shl    $0x18,%esi
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	c1 e0 10             	shl    $0x10,%eax
  8008bb:	09 f0                	or     %esi,%eax
  8008bd:	09 d0                	or     %edx,%eax
  8008bf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c4:	fc                   	cld    
  8008c5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c7:	eb 03                	jmp    8008cc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c9:	fc                   	cld    
  8008ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cc:	89 f8                	mov    %edi,%eax
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5f                   	pop    %edi
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	57                   	push   %edi
  8008d7:	56                   	push   %esi
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e1:	39 c6                	cmp    %eax,%esi
  8008e3:	73 34                	jae    800919 <memmove+0x46>
  8008e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e8:	39 d0                	cmp    %edx,%eax
  8008ea:	73 2d                	jae    800919 <memmove+0x46>
		s += n;
		d += n;
  8008ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ef:	f6 c2 03             	test   $0x3,%dl
  8008f2:	75 1b                	jne    80090f <memmove+0x3c>
  8008f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fa:	75 13                	jne    80090f <memmove+0x3c>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 0e                	jne    80090f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800901:	83 ef 04             	sub    $0x4,%edi
  800904:	8d 72 fc             	lea    -0x4(%edx),%esi
  800907:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090a:	fd                   	std    
  80090b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090d:	eb 07                	jmp    800916 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090f:	4f                   	dec    %edi
  800910:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800913:	fd                   	std    
  800914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800916:	fc                   	cld    
  800917:	eb 20                	jmp    800939 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091f:	75 13                	jne    800934 <memmove+0x61>
  800921:	a8 03                	test   $0x3,%al
  800923:	75 0f                	jne    800934 <memmove+0x61>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0a                	jne    800934 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb 05                	jmp    800939 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800934:	89 c7                	mov    %eax,%edi
  800936:	fc                   	cld    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	ff 75 08             	pushl  0x8(%ebp)
  800949:	e8 85 ff ff ff       	call   8008d3 <memmove>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800959:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	85 ff                	test   %edi,%edi
  800961:	74 32                	je     800995 <memcmp+0x45>
		if (*s1 != *s2)
  800963:	8a 03                	mov    (%ebx),%al
  800965:	8a 0e                	mov    (%esi),%cl
  800967:	38 c8                	cmp    %cl,%al
  800969:	74 19                	je     800984 <memcmp+0x34>
  80096b:	eb 0d                	jmp    80097a <memcmp+0x2a>
  80096d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800971:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800975:	42                   	inc    %edx
  800976:	38 c8                	cmp    %cl,%al
  800978:	74 10                	je     80098a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 c9             	movzbl %cl,%ecx
  800980:	29 c8                	sub    %ecx,%eax
  800982:	eb 16                	jmp    80099a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800984:	4f                   	dec    %edi
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	39 fa                	cmp    %edi,%edx
  80098c:	75 df                	jne    80096d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
  800993:	eb 05                	jmp    80099a <memcmp+0x4a>
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a5:	89 c2                	mov    %eax,%edx
  8009a7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009aa:	39 d0                	cmp    %edx,%eax
  8009ac:	73 12                	jae    8009c0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	75 06                	jne    8009bb <memfind+0x1c>
  8009b5:	eb 09                	jmp    8009c0 <memfind+0x21>
  8009b7:	38 08                	cmp    %cl,(%eax)
  8009b9:	74 05                	je     8009c0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bb:	40                   	inc    %eax
  8009bc:	39 c2                	cmp    %eax,%edx
  8009be:	77 f7                	ja     8009b7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 01                	jmp    8009d1 <strtol+0xf>
		s++;
  8009d0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	8a 02                	mov    (%edx),%al
  8009d3:	3c 20                	cmp    $0x20,%al
  8009d5:	74 f9                	je     8009d0 <strtol+0xe>
  8009d7:	3c 09                	cmp    $0x9,%al
  8009d9:	74 f5                	je     8009d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009db:	3c 2b                	cmp    $0x2b,%al
  8009dd:	75 08                	jne    8009e7 <strtol+0x25>
		s++;
  8009df:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	eb 13                	jmp    8009fa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e7:	3c 2d                	cmp    $0x2d,%al
  8009e9:	75 0a                	jne    8009f5 <strtol+0x33>
		s++, neg = 1;
  8009eb:	8d 52 01             	lea    0x1(%edx),%edx
  8009ee:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f3:	eb 05                	jmp    8009fa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	74 05                	je     800a03 <strtol+0x41>
  8009fe:	83 fb 10             	cmp    $0x10,%ebx
  800a01:	75 28                	jne    800a2b <strtol+0x69>
  800a03:	8a 02                	mov    (%edx),%al
  800a05:	3c 30                	cmp    $0x30,%al
  800a07:	75 10                	jne    800a19 <strtol+0x57>
  800a09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0d:	75 0a                	jne    800a19 <strtol+0x57>
		s += 2, base = 16;
  800a0f:	83 c2 02             	add    $0x2,%edx
  800a12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a17:	eb 12                	jmp    800a2b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a19:	85 db                	test   %ebx,%ebx
  800a1b:	75 0e                	jne    800a2b <strtol+0x69>
  800a1d:	3c 30                	cmp    $0x30,%al
  800a1f:	75 05                	jne    800a26 <strtol+0x64>
		s++, base = 8;
  800a21:	42                   	inc    %edx
  800a22:	b3 08                	mov    $0x8,%bl
  800a24:	eb 05                	jmp    800a2b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a26:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a32:	8a 0a                	mov    (%edx),%cl
  800a34:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a37:	80 fb 09             	cmp    $0x9,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0x82>
			dig = *s - '0';
  800a3c:	0f be c9             	movsbl %cl,%ecx
  800a3f:	83 e9 30             	sub    $0x30,%ecx
  800a42:	eb 1e                	jmp    800a62 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a44:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a4c:	0f be c9             	movsbl %cl,%ecx
  800a4f:	83 e9 57             	sub    $0x57,%ecx
  800a52:	eb 0e                	jmp    800a62 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a54:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a57:	80 fb 19             	cmp    $0x19,%bl
  800a5a:	77 13                	ja     800a6f <strtol+0xad>
			dig = *s - 'A' + 10;
  800a5c:	0f be c9             	movsbl %cl,%ecx
  800a5f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a62:	39 f1                	cmp    %esi,%ecx
  800a64:	7d 0d                	jge    800a73 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a66:	42                   	inc    %edx
  800a67:	0f af c6             	imul   %esi,%eax
  800a6a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a6d:	eb c3                	jmp    800a32 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a6f:	89 c1                	mov    %eax,%ecx
  800a71:	eb 02                	jmp    800a75 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a73:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a79:	74 05                	je     800a80 <strtol+0xbe>
		*endptr = (char *) s;
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a80:	85 ff                	test   %edi,%edi
  800a82:	74 04                	je     800a88 <strtol+0xc6>
  800a84:	89 c8                	mov    %ecx,%eax
  800a86:	f7 d8                	neg    %eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    
  800a8d:	00 00                	add    %al,(%eax)
	...

00800a90 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
  800a96:	83 ec 1c             	sub    $0x1c,%esp
  800a99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a9c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a9f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	8b 75 14             	mov    0x14(%ebp),%esi
  800aa4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aad:	cd 30                	int    $0x30
  800aaf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ab5:	74 1c                	je     800ad3 <syscall+0x43>
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	7e 18                	jle    800ad3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	50                   	push   %eax
  800abf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ac2:	68 1f 21 80 00       	push   $0x80211f
  800ac7:	6a 42                	push   $0x42
  800ac9:	68 3c 21 80 00       	push   $0x80213c
  800ace:	e8 d5 0e 00 00       	call   8019a8 <_panic>

	return ret;
}
  800ad3:	89 d0                	mov    %edx,%eax
  800ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ae3:	6a 00                	push   $0x0
  800ae5:	6a 00                	push   $0x0
  800ae7:	6a 00                	push   $0x0
  800ae9:	ff 75 0c             	pushl  0xc(%ebp)
  800aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aef:	ba 00 00 00 00       	mov    $0x0,%edx
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	e8 92 ff ff ff       	call   800a90 <syscall>
  800afe:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	e8 6b ff ff ff       	call   800a90 <syscall>
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b38:	ba 01 00 00 00       	mov    $0x1,%edx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	e8 49 ff ff ff       	call   800a90 <syscall>
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b4f:	6a 00                	push   $0x0
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 02 00 00 00       	mov    $0x2,%eax
  800b66:	e8 25 ff ff ff       	call   800a90 <syscall>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sys_yield>:

void
sys_yield(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	e8 01 ff ff ff       	call   800a90 <syscall>
  800b8f:	83 c4 10             	add    $0x10,%esp
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b9a:	6a 00                	push   $0x0
  800b9c:	6a 00                	push   $0x0
  800b9e:	ff 75 10             	pushl  0x10(%ebp)
  800ba1:	ff 75 0c             	pushl  0xc(%ebp)
  800ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bac:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb1:	e8 da fe ff ff       	call   800a90 <syscall>
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bbe:	ff 75 18             	pushl  0x18(%ebp)
  800bc1:	ff 75 14             	pushl  0x14(%ebp)
  800bc4:	ff 75 10             	pushl  0x10(%ebp)
  800bc7:	ff 75 0c             	pushl  0xc(%ebp)
  800bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcd:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	e8 b4 fe ff ff       	call   800a90 <syscall>
}
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800be4:	6a 00                	push   $0x0
  800be6:	6a 00                	push   $0x0
  800be8:	6a 00                	push   $0x0
  800bea:	ff 75 0c             	pushl  0xc(%ebp)
  800bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	e8 91 fe ff ff       	call   800a90 <syscall>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c13:	ba 01 00 00 00       	mov    $0x1,%edx
  800c18:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1d:	e8 6e fe ff ff       	call   800a90 <syscall>
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	6a 00                	push   $0x0
  800c30:	ff 75 0c             	pushl  0xc(%ebp)
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c40:	e8 4b fe ff ff       	call   800a90 <syscall>
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	ff 75 0c             	pushl  0xc(%ebp)
  800c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c59:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c63:	e8 28 fe ff ff       	call   800a90 <syscall>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c70:	6a 00                	push   $0x0
  800c72:	ff 75 14             	pushl  0x14(%ebp)
  800c75:	ff 75 10             	pushl  0x10(%ebp)
  800c78:	ff 75 0c             	pushl  0xc(%ebp)
  800c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c88:	e8 03 fe ff ff       	call   800a90 <syscall>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800caa:	e8 e1 fd ff ff       	call   800a90 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ccd:	e8 be fd ff ff       	call   800a90 <syscall>
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	05 00 00 00 30       	add    $0x30000000,%eax
  800cdf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	e8 e5 ff ff ff       	call   800cd4 <fd2num>
  800cef:	83 c4 04             	add    $0x4,%esp
  800cf2:	05 20 00 0d 00       	add    $0xd0020,%eax
  800cf7:	c1 e0 0c             	shl    $0xc,%eax
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d03:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d08:	a8 01                	test   $0x1,%al
  800d0a:	74 34                	je     800d40 <fd_alloc+0x44>
  800d0c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d11:	a8 01                	test   $0x1,%al
  800d13:	74 32                	je     800d47 <fd_alloc+0x4b>
  800d15:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d1a:	89 c1                	mov    %eax,%ecx
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	c1 ea 16             	shr    $0x16,%edx
  800d21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d28:	f6 c2 01             	test   $0x1,%dl
  800d2b:	74 1f                	je     800d4c <fd_alloc+0x50>
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	c1 ea 0c             	shr    $0xc,%edx
  800d32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d39:	f6 c2 01             	test   $0x1,%dl
  800d3c:	75 17                	jne    800d55 <fd_alloc+0x59>
  800d3e:	eb 0c                	jmp    800d4c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d40:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d45:	eb 05                	jmp    800d4c <fd_alloc+0x50>
  800d47:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d4c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d53:	eb 17                	jmp    800d6c <fd_alloc+0x70>
  800d55:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d5a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d5f:	75 b9                	jne    800d1a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800d67:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d75:	83 f8 1f             	cmp    $0x1f,%eax
  800d78:	77 36                	ja     800db0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d7a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800d7f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 16             	shr    $0x16,%edx
  800d87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 24                	je     800db7 <fd_lookup+0x48>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 0c             	shr    $0xc,%edx
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	74 1a                	je     800dbe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800da4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da7:	89 02                	mov    %eax,(%edx)
	return 0;
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	eb 13                	jmp    800dc3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800db5:	eb 0c                	jmp    800dc3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dbc:	eb 05                	jmp    800dc3 <fd_lookup+0x54>
  800dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    

00800dc5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800dd2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800dd8:	74 0d                	je     800de7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	eb 14                	jmp    800df5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800de1:	39 0a                	cmp    %ecx,(%edx)
  800de3:	75 10                	jne    800df5 <dev_lookup+0x30>
  800de5:	eb 05                	jmp    800dec <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800de7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800dec:	89 13                	mov    %edx,(%ebx)
			return 0;
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	eb 31                	jmp    800e26 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df5:	40                   	inc    %eax
  800df6:	8b 14 85 c8 21 80 00 	mov    0x8021c8(,%eax,4),%edx
  800dfd:	85 d2                	test   %edx,%edx
  800dff:	75 e0                	jne    800de1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e01:	a1 04 40 80 00       	mov    0x804004,%eax
  800e06:	8b 40 48             	mov    0x48(%eax),%eax
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	51                   	push   %ecx
  800e0d:	50                   	push   %eax
  800e0e:	68 4c 21 80 00       	push   $0x80214c
  800e13:	e8 44 f3 ff ff       	call   80015c <cprintf>
	*dev = 0;
  800e18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 20             	sub    $0x20,%esp
  800e33:	8b 75 08             	mov    0x8(%ebp),%esi
  800e36:	8a 45 0c             	mov    0xc(%ebp),%al
  800e39:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e3c:	56                   	push   %esi
  800e3d:	e8 92 fe ff ff       	call   800cd4 <fd2num>
  800e42:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e45:	89 14 24             	mov    %edx,(%esp)
  800e48:	50                   	push   %eax
  800e49:	e8 21 ff ff ff       	call   800d6f <fd_lookup>
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	83 c4 08             	add    $0x8,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 05                	js     800e5c <fd_close+0x31>
	    || fd != fd2)
  800e57:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e5a:	74 0d                	je     800e69 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e5c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e60:	75 48                	jne    800eaa <fd_close+0x7f>
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	eb 41                	jmp    800eaa <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e6f:	50                   	push   %eax
  800e70:	ff 36                	pushl  (%esi)
  800e72:	e8 4e ff ff ff       	call   800dc5 <dev_lookup>
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 1c                	js     800e9c <fd_close+0x71>
		if (dev->dev_close)
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	8b 40 10             	mov    0x10(%eax),%eax
  800e86:	85 c0                	test   %eax,%eax
  800e88:	74 0d                	je     800e97 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	56                   	push   %esi
  800e8e:	ff d0                	call   *%eax
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	eb 05                	jmp    800e9c <fd_close+0x71>
		else
			r = 0;
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	56                   	push   %esi
  800ea0:	6a 00                	push   $0x0
  800ea2:	e8 37 fd ff ff       	call   800bde <sys_page_unmap>
	return r;
  800ea7:	83 c4 10             	add    $0x10,%esp
}
  800eaa:	89 d8                	mov    %ebx,%eax
  800eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebc:	50                   	push   %eax
  800ebd:	ff 75 08             	pushl  0x8(%ebp)
  800ec0:	e8 aa fe ff ff       	call   800d6f <fd_lookup>
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 10                	js     800edc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecc:	83 ec 08             	sub    $0x8,%esp
  800ecf:	6a 01                	push   $0x1
  800ed1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed4:	e8 52 ff ff ff       	call   800e2b <fd_close>
  800ed9:	83 c4 10             	add    $0x10,%esp
}
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <close_all>:

void
close_all(void)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	53                   	push   %ebx
  800eee:	e8 c0 ff ff ff       	call   800eb3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef3:	43                   	inc    %ebx
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	83 fb 20             	cmp    $0x20,%ebx
  800efa:	75 ee                	jne    800eea <close_all+0xc>
		close(i);
}
  800efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 2c             	sub    $0x2c,%esp
  800f0a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	ff 75 08             	pushl  0x8(%ebp)
  800f14:	e8 56 fe ff ff       	call   800d6f <fd_lookup>
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	83 c4 08             	add    $0x8,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	0f 88 c0 00 00 00    	js     800fe6 <dup+0xe5>
		return r;
	close(newfdnum);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	57                   	push   %edi
  800f2a:	e8 84 ff ff ff       	call   800eb3 <close>

	newfd = INDEX2FD(newfdnum);
  800f2f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f35:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f38:	83 c4 04             	add    $0x4,%esp
  800f3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3e:	e8 a1 fd ff ff       	call   800ce4 <fd2data>
  800f43:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f45:	89 34 24             	mov    %esi,(%esp)
  800f48:	e8 97 fd ff ff       	call   800ce4 <fd2data>
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	74 37                	je     800f9a <dup+0x99>
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 0c             	shr    $0xc,%eax
  800f68:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 26                	je     800f9a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f74:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f87:	6a 00                	push   $0x0
  800f89:	53                   	push   %ebx
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 27 fc ff ff       	call   800bb8 <sys_page_map>
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 2d                	js     800fc7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f9d:	89 c2                	mov    %eax,%edx
  800f9f:	c1 ea 0c             	shr    $0xc,%edx
  800fa2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fb2:	52                   	push   %edx
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	50                   	push   %eax
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 fa fb ff ff       	call   800bb8 <sys_page_map>
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 1d                	jns    800fe4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 0c fc ff ff       	call   800bde <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd2:	83 c4 08             	add    $0x8,%esp
  800fd5:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 ff fb ff ff       	call   800bde <sys_page_unmap>
	return r;
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	eb 02                	jmp    800fe6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800fe4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 14             	sub    $0x14,%esp
  800ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	53                   	push   %ebx
  800fff:	e8 6b fd ff ff       	call   800d6f <fd_lookup>
  801004:	83 c4 08             	add    $0x8,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	78 67                	js     801072 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801015:	ff 30                	pushl  (%eax)
  801017:	e8 a9 fd ff ff       	call   800dc5 <dev_lookup>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 4f                	js     801072 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801026:	8b 50 08             	mov    0x8(%eax),%edx
  801029:	83 e2 03             	and    $0x3,%edx
  80102c:	83 fa 01             	cmp    $0x1,%edx
  80102f:	75 21                	jne    801052 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801031:	a1 04 40 80 00       	mov    0x804004,%eax
  801036:	8b 40 48             	mov    0x48(%eax),%eax
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	53                   	push   %ebx
  80103d:	50                   	push   %eax
  80103e:	68 8d 21 80 00       	push   $0x80218d
  801043:	e8 14 f1 ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801050:	eb 20                	jmp    801072 <read+0x82>
	}
	if (!dev->dev_read)
  801052:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801055:	8b 52 08             	mov    0x8(%edx),%edx
  801058:	85 d2                	test   %edx,%edx
  80105a:	74 11                	je     80106d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	ff 75 10             	pushl  0x10(%ebp)
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	50                   	push   %eax
  801066:	ff d2                	call   *%edx
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	eb 05                	jmp    801072 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80106d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	8b 7d 08             	mov    0x8(%ebp),%edi
  801083:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801086:	85 f6                	test   %esi,%esi
  801088:	74 31                	je     8010bb <readn+0x44>
  80108a:	b8 00 00 00 00       	mov    $0x0,%eax
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	89 f2                	mov    %esi,%edx
  801099:	29 c2                	sub    %eax,%edx
  80109b:	52                   	push   %edx
  80109c:	03 45 0c             	add    0xc(%ebp),%eax
  80109f:	50                   	push   %eax
  8010a0:	57                   	push   %edi
  8010a1:	e8 4a ff ff ff       	call   800ff0 <read>
		if (m < 0)
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 17                	js     8010c4 <readn+0x4d>
			return m;
		if (m == 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	74 11                	je     8010c2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b1:	01 c3                	add    %eax,%ebx
  8010b3:	89 d8                	mov    %ebx,%eax
  8010b5:	39 f3                	cmp    %esi,%ebx
  8010b7:	72 db                	jb     801094 <readn+0x1d>
  8010b9:	eb 09                	jmp    8010c4 <readn+0x4d>
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	eb 02                	jmp    8010c4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010c2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 14             	sub    $0x14,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	53                   	push   %ebx
  8010db:	e8 8f fc ff ff       	call   800d6f <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 62                	js     801149 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f1:	ff 30                	pushl  (%eax)
  8010f3:	e8 cd fc ff ff       	call   800dc5 <dev_lookup>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 4a                	js     801149 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801106:	75 21                	jne    801129 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 48             	mov    0x48(%eax),%eax
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	53                   	push   %ebx
  801114:	50                   	push   %eax
  801115:	68 a9 21 80 00       	push   $0x8021a9
  80111a:	e8 3d f0 ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801127:	eb 20                	jmp    801149 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801129:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112c:	8b 52 0c             	mov    0xc(%edx),%edx
  80112f:	85 d2                	test   %edx,%edx
  801131:	74 11                	je     801144 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	ff 75 10             	pushl  0x10(%ebp)
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	50                   	push   %eax
  80113d:	ff d2                	call   *%edx
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	eb 05                	jmp    801149 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801144:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <seek>:

int
seek(int fdnum, off_t offset)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801154:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	ff 75 08             	pushl  0x8(%ebp)
  80115b:	e8 0f fc ff ff       	call   800d6f <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 0e                	js     801175 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801167:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801170:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 14             	sub    $0x14,%esp
  80117e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801181:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	53                   	push   %ebx
  801186:	e8 e4 fb ff ff       	call   800d6f <fd_lookup>
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 5f                	js     8011f1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801198:	50                   	push   %eax
  801199:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119c:	ff 30                	pushl  (%eax)
  80119e:	e8 22 fc ff ff       	call   800dc5 <dev_lookup>
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 47                	js     8011f1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b1:	75 21                	jne    8011d4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011b3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b8:	8b 40 48             	mov    0x48(%eax),%eax
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	53                   	push   %ebx
  8011bf:	50                   	push   %eax
  8011c0:	68 6c 21 80 00       	push   $0x80216c
  8011c5:	e8 92 ef ff ff       	call   80015c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d2:	eb 1d                	jmp    8011f1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8011d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d7:	8b 52 18             	mov    0x18(%edx),%edx
  8011da:	85 d2                	test   %edx,%edx
  8011dc:	74 0e                	je     8011ec <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	ff 75 0c             	pushl  0xc(%ebp)
  8011e4:	50                   	push   %eax
  8011e5:	ff d2                	call   *%edx
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	eb 05                	jmp    8011f1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 14             	sub    $0x14,%esp
  8011fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801200:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	ff 75 08             	pushl  0x8(%ebp)
  801207:	e8 63 fb ff ff       	call   800d6f <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 52                	js     801265 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	ff 30                	pushl  (%eax)
  80121f:	e8 a1 fb ff ff       	call   800dc5 <dev_lookup>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 3a                	js     801265 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80122b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801232:	74 2c                	je     801260 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801234:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801237:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80123e:	00 00 00 
	stat->st_isdir = 0;
  801241:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801248:	00 00 00 
	stat->st_dev = dev;
  80124b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	53                   	push   %ebx
  801255:	ff 75 f0             	pushl  -0x10(%ebp)
  801258:	ff 50 14             	call   *0x14(%eax)
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	eb 05                	jmp    801265 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801260:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	6a 00                	push   $0x0
  801274:	ff 75 08             	pushl  0x8(%ebp)
  801277:	e8 8b 01 00 00       	call   801407 <open>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 1b                	js     8012a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	50                   	push   %eax
  80128c:	e8 65 ff ff ff       	call   8011f6 <fstat>
  801291:	89 c6                	mov    %eax,%esi
	close(fd);
  801293:	89 1c 24             	mov    %ebx,(%esp)
  801296:	e8 18 fc ff ff       	call   800eb3 <close>
	return r;
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	89 f3                	mov    %esi,%ebx
}
  8012a0:	89 d8                	mov    %ebx,%eax
  8012a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
  8012a9:	00 00                	add    %al,(%eax)
	...

008012ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012bc:	75 12                	jne    8012d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012be:	83 ec 0c             	sub    $0xc,%esp
  8012c1:	6a 01                	push   $0x1
  8012c3:	e8 25 08 00 00       	call   801aed <ipc_find_env>
  8012c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8012cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d0:	6a 07                	push   $0x7
  8012d2:	68 00 50 80 00       	push   $0x805000
  8012d7:	53                   	push   %ebx
  8012d8:	ff 35 00 40 80 00    	pushl  0x804000
  8012de:	e8 b5 07 00 00       	call   801a98 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8012e3:	83 c4 0c             	add    $0xc,%esp
  8012e6:	6a 00                	push   $0x0
  8012e8:	56                   	push   %esi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 00 07 00 00       	call   8019f0 <ipc_recv>
}
  8012f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801301:	8b 45 08             	mov    0x8(%ebp),%eax
  801304:	8b 40 0c             	mov    0xc(%eax),%eax
  801307:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80130c:	ba 00 00 00 00       	mov    $0x0,%edx
  801311:	b8 05 00 00 00       	mov    $0x5,%eax
  801316:	e8 91 ff ff ff       	call   8012ac <fsipc>
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 39                	js     801358 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	68 d8 21 80 00       	push   $0x8021d8
  801327:	e8 30 ee ff ff       	call   80015c <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	68 00 50 80 00       	push   $0x805000
  801334:	53                   	push   %ebx
  801335:	e8 d8 f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80133a:	a1 80 50 80 00       	mov    0x805080,%eax
  80133f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801345:	a1 84 50 80 00       	mov    0x805084,%eax
  80134a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	8b 40 0c             	mov    0xc(%eax),%eax
  801369:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80136e:	ba 00 00 00 00       	mov    $0x0,%edx
  801373:	b8 06 00 00 00       	mov    $0x6,%eax
  801378:	e8 2f ff ff ff       	call   8012ac <fsipc>
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	8b 40 0c             	mov    0xc(%eax),%eax
  80138d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801392:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801398:	ba 00 00 00 00       	mov    $0x0,%edx
  80139d:	b8 03 00 00 00       	mov    $0x3,%eax
  8013a2:	e8 05 ff ff ff       	call   8012ac <fsipc>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 51                	js     8013fe <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8013ad:	39 c6                	cmp    %eax,%esi
  8013af:	73 19                	jae    8013ca <devfile_read+0x4b>
  8013b1:	68 de 21 80 00       	push   $0x8021de
  8013b6:	68 e5 21 80 00       	push   $0x8021e5
  8013bb:	68 80 00 00 00       	push   $0x80
  8013c0:	68 fa 21 80 00       	push   $0x8021fa
  8013c5:	e8 de 05 00 00       	call   8019a8 <_panic>
	assert(r <= PGSIZE);
  8013ca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013cf:	7e 19                	jle    8013ea <devfile_read+0x6b>
  8013d1:	68 05 22 80 00       	push   $0x802205
  8013d6:	68 e5 21 80 00       	push   $0x8021e5
  8013db:	68 81 00 00 00       	push   $0x81
  8013e0:	68 fa 21 80 00       	push   $0x8021fa
  8013e5:	e8 be 05 00 00       	call   8019a8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8013ea:	83 ec 04             	sub    $0x4,%esp
  8013ed:	50                   	push   %eax
  8013ee:	68 00 50 80 00       	push   $0x805000
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	e8 d8 f4 ff ff       	call   8008d3 <memmove>
	return r;
  8013fb:	83 c4 10             	add    $0x10,%esp
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	83 ec 1c             	sub    $0x1c,%esp
  80140f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801412:	56                   	push   %esi
  801413:	e8 a8 f2 ff ff       	call   8006c0 <strlen>
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801420:	7f 72                	jg     801494 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	e8 ce f8 ff ff       	call   800cfc <fd_alloc>
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 62                	js     801499 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	56                   	push   %esi
  80143b:	68 00 50 80 00       	push   $0x805000
  801440:	e8 cd f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801445:	8b 45 0c             	mov    0xc(%ebp),%eax
  801448:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80144d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801450:	b8 01 00 00 00       	mov    $0x1,%eax
  801455:	e8 52 fe ff ff       	call   8012ac <fsipc>
  80145a:	89 c3                	mov    %eax,%ebx
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	79 12                	jns    801475 <open+0x6e>
		fd_close(fd, 0);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	6a 00                	push   $0x0
  801468:	ff 75 f4             	pushl  -0xc(%ebp)
  80146b:	e8 bb f9 ff ff       	call   800e2b <fd_close>
		return r;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	eb 24                	jmp    801499 <open+0x92>
	}


	cprintf("OPEN\n");
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	68 11 22 80 00       	push   $0x802211
  80147d:	e8 da ec ff ff       	call   80015c <cprintf>

	return fd2num(fd);
  801482:	83 c4 04             	add    $0x4,%esp
  801485:	ff 75 f4             	pushl  -0xc(%ebp)
  801488:	e8 47 f8 ff ff       	call   800cd4 <fd2num>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	eb 05                	jmp    801499 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801494:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801499:	89 d8                	mov    %ebx,%eax
  80149b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    
	...

008014a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 2d f8 ff ff       	call   800ce4 <fd2data>
  8014b7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014b9:	83 c4 08             	add    $0x8,%esp
  8014bc:	68 17 22 80 00       	push   $0x802217
  8014c1:	56                   	push   %esi
  8014c2:	e8 4b f2 ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8014ca:	2b 03                	sub    (%ebx),%eax
  8014cc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014d2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014d9:	00 00 00 
	stat->st_dev = &devpipe;
  8014dc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014e3:	30 80 00 
	return 0;
}
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8014fc:	53                   	push   %ebx
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 da f6 ff ff       	call   800bde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801504:	89 1c 24             	mov    %ebx,(%esp)
  801507:	e8 d8 f7 ff ff       	call   800ce4 <fd2data>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	50                   	push   %eax
  801510:	6a 00                	push   $0x0
  801512:	e8 c7 f6 ff ff       	call   800bde <sys_page_unmap>
}
  801517:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	57                   	push   %edi
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 1c             	sub    $0x1c,%esp
  801525:	89 c7                	mov    %eax,%edi
  801527:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80152a:	a1 04 40 80 00       	mov    0x804004,%eax
  80152f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	57                   	push   %edi
  801536:	e8 0d 06 00 00       	call   801b48 <pageref>
  80153b:	89 c6                	mov    %eax,%esi
  80153d:	83 c4 04             	add    $0x4,%esp
  801540:	ff 75 e4             	pushl  -0x1c(%ebp)
  801543:	e8 00 06 00 00       	call   801b48 <pageref>
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	39 c6                	cmp    %eax,%esi
  80154d:	0f 94 c0             	sete   %al
  801550:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801553:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801559:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80155c:	39 cb                	cmp    %ecx,%ebx
  80155e:	75 08                	jne    801568 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801560:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	c9                   	leave  
  801567:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801568:	83 f8 01             	cmp    $0x1,%eax
  80156b:	75 bd                	jne    80152a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80156d:	8b 42 58             	mov    0x58(%edx),%eax
  801570:	6a 01                	push   $0x1
  801572:	50                   	push   %eax
  801573:	53                   	push   %ebx
  801574:	68 1e 22 80 00       	push   $0x80221e
  801579:	e8 de eb ff ff       	call   80015c <cprintf>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb a7                	jmp    80152a <_pipeisclosed+0xe>

00801583 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	57                   	push   %edi
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 28             	sub    $0x28,%esp
  80158c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80158f:	56                   	push   %esi
  801590:	e8 4f f7 ff ff       	call   800ce4 <fd2data>
  801595:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80159e:	75 4a                	jne    8015ea <devpipe_write+0x67>
  8015a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8015a5:	eb 56                	jmp    8015fd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015a7:	89 da                	mov    %ebx,%edx
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	e8 6c ff ff ff       	call   80151c <_pipeisclosed>
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	75 4d                	jne    801601 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015b4:	e8 b4 f5 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015b9:	8b 43 04             	mov    0x4(%ebx),%eax
  8015bc:	8b 13                	mov    (%ebx),%edx
  8015be:	83 c2 20             	add    $0x20,%edx
  8015c1:	39 d0                	cmp    %edx,%eax
  8015c3:	73 e2                	jae    8015a7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8015cd:	79 05                	jns    8015d4 <devpipe_write+0x51>
  8015cf:	4a                   	dec    %edx
  8015d0:	83 ca e0             	or     $0xffffffe0,%edx
  8015d3:	42                   	inc    %edx
  8015d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015de:	40                   	inc    %eax
  8015df:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015e2:	47                   	inc    %edi
  8015e3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8015e6:	77 07                	ja     8015ef <devpipe_write+0x6c>
  8015e8:	eb 13                	jmp    8015fd <devpipe_write+0x7a>
  8015ea:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f2:	8b 13                	mov    (%ebx),%edx
  8015f4:	83 c2 20             	add    $0x20,%edx
  8015f7:	39 d0                	cmp    %edx,%eax
  8015f9:	73 ac                	jae    8015a7 <devpipe_write+0x24>
  8015fb:	eb c8                	jmp    8015c5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8015fd:	89 f8                	mov    %edi,%eax
  8015ff:	eb 05                	jmp    801606 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801606:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5f                   	pop    %edi
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 18             	sub    $0x18,%esp
  801617:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80161a:	57                   	push   %edi
  80161b:	e8 c4 f6 ff ff       	call   800ce4 <fd2data>
  801620:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801629:	75 44                	jne    80166f <devpipe_read+0x61>
  80162b:	be 00 00 00 00       	mov    $0x0,%esi
  801630:	eb 4f                	jmp    801681 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801632:	89 f0                	mov    %esi,%eax
  801634:	eb 54                	jmp    80168a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801636:	89 da                	mov    %ebx,%edx
  801638:	89 f8                	mov    %edi,%eax
  80163a:	e8 dd fe ff ff       	call   80151c <_pipeisclosed>
  80163f:	85 c0                	test   %eax,%eax
  801641:	75 42                	jne    801685 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801643:	e8 25 f5 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801648:	8b 03                	mov    (%ebx),%eax
  80164a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80164d:	74 e7                	je     801636 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80164f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801654:	79 05                	jns    80165b <devpipe_read+0x4d>
  801656:	48                   	dec    %eax
  801657:	83 c8 e0             	or     $0xffffffe0,%eax
  80165a:	40                   	inc    %eax
  80165b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80165f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801662:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801665:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801667:	46                   	inc    %esi
  801668:	39 75 10             	cmp    %esi,0x10(%ebp)
  80166b:	77 07                	ja     801674 <devpipe_read+0x66>
  80166d:	eb 12                	jmp    801681 <devpipe_read+0x73>
  80166f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801674:	8b 03                	mov    (%ebx),%eax
  801676:	3b 43 04             	cmp    0x4(%ebx),%eax
  801679:	75 d4                	jne    80164f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80167b:	85 f6                	test   %esi,%esi
  80167d:	75 b3                	jne    801632 <devpipe_read+0x24>
  80167f:	eb b5                	jmp    801636 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801681:	89 f0                	mov    %esi,%eax
  801683:	eb 05                	jmp    80168a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 28             	sub    $0x28,%esp
  80169b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80169e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	e8 55 f6 ff ff       	call   800cfc <fd_alloc>
  8016a7:	89 c3                	mov    %eax,%ebx
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	0f 88 24 01 00 00    	js     8017d8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	68 07 04 00 00       	push   $0x407
  8016bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 ce f4 ff ff       	call   800b94 <sys_page_alloc>
  8016c6:	89 c3                	mov    %eax,%ebx
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 88 05 01 00 00    	js     8017d8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 1d f6 ff ff       	call   800cfc <fd_alloc>
  8016df:	89 c3                	mov    %eax,%ebx
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	0f 88 dc 00 00 00    	js     8017c8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016ec:	83 ec 04             	sub    $0x4,%esp
  8016ef:	68 07 04 00 00       	push   $0x407
  8016f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 96 f4 ff ff       	call   800b94 <sys_page_alloc>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	0f 88 bd 00 00 00    	js     8017c8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801711:	e8 ce f5 ff ff       	call   800ce4 <fd2data>
  801716:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801718:	83 c4 0c             	add    $0xc,%esp
  80171b:	68 07 04 00 00       	push   $0x407
  801720:	50                   	push   %eax
  801721:	6a 00                	push   $0x0
  801723:	e8 6c f4 ff ff       	call   800b94 <sys_page_alloc>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	0f 88 83 00 00 00    	js     8017b8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	ff 75 e0             	pushl  -0x20(%ebp)
  80173b:	e8 a4 f5 ff ff       	call   800ce4 <fd2data>
  801740:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801747:	50                   	push   %eax
  801748:	6a 00                	push   $0x0
  80174a:	56                   	push   %esi
  80174b:	6a 00                	push   $0x0
  80174d:	e8 66 f4 ff ff       	call   800bb8 <sys_page_map>
  801752:	89 c3                	mov    %eax,%ebx
  801754:	83 c4 20             	add    $0x20,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 4f                	js     8017aa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80175b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801764:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801769:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801770:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801776:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801779:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80177b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80177e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	ff 75 e4             	pushl  -0x1c(%ebp)
  80178b:	e8 44 f5 ff ff       	call   800cd4 <fd2num>
  801790:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801792:	83 c4 04             	add    $0x4,%esp
  801795:	ff 75 e0             	pushl  -0x20(%ebp)
  801798:	e8 37 f5 ff ff       	call   800cd4 <fd2num>
  80179d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a8:	eb 2e                	jmp    8017d8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	56                   	push   %esi
  8017ae:	6a 00                	push   $0x0
  8017b0:	e8 29 f4 ff ff       	call   800bde <sys_page_unmap>
  8017b5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 19 f4 ff ff       	call   800bde <sys_page_unmap>
  8017c5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 09 f4 ff ff       	call   800bde <sys_page_unmap>
  8017d5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5f                   	pop    %edi
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	ff 75 08             	pushl  0x8(%ebp)
  8017ef:	e8 7b f5 ff ff       	call   800d6f <fd_lookup>
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 18                	js     801813 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 de f4 ff ff       	call   800ce4 <fd2data>
	return _pipeisclosed(fd, p);
  801806:	89 c2                	mov    %eax,%edx
  801808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180b:	e8 0c fd ff ff       	call   80151c <_pipeisclosed>
  801810:	83 c4 10             	add    $0x10,%esp
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    
  801815:	00 00                	add    %al,(%eax)
	...

00801818 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801828:	68 36 22 80 00       	push   $0x802236
  80182d:	ff 75 0c             	pushl  0xc(%ebp)
  801830:	e8 dd ee ff ff       	call   800712 <strcpy>
	return 0;
}
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801848:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80184c:	74 45                	je     801893 <devcons_write+0x57>
  80184e:	b8 00 00 00 00       	mov    $0x0,%eax
  801853:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801858:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80185e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801861:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801863:	83 fb 7f             	cmp    $0x7f,%ebx
  801866:	76 05                	jbe    80186d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801868:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	53                   	push   %ebx
  801871:	03 45 0c             	add    0xc(%ebp),%eax
  801874:	50                   	push   %eax
  801875:	57                   	push   %edi
  801876:	e8 58 f0 ff ff       	call   8008d3 <memmove>
		sys_cputs(buf, m);
  80187b:	83 c4 08             	add    $0x8,%esp
  80187e:	53                   	push   %ebx
  80187f:	57                   	push   %edi
  801880:	e8 58 f2 ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801885:	01 de                	add    %ebx,%esi
  801887:	89 f0                	mov    %esi,%eax
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80188f:	72 cd                	jb     80185e <devcons_write+0x22>
  801891:	eb 05                	jmp    801898 <devcons_write+0x5c>
  801893:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801898:	89 f0                	mov    %esi,%eax
  80189a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ac:	75 07                	jne    8018b5 <devcons_read+0x13>
  8018ae:	eb 25                	jmp    8018d5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018b0:	e8 b8 f2 ff ff       	call   800b6d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018b5:	e8 49 f2 ff ff       	call   800b03 <sys_cgetc>
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	74 f2                	je     8018b0 <devcons_read+0xe>
  8018be:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 1d                	js     8018e1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018c4:	83 f8 04             	cmp    $0x4,%eax
  8018c7:	74 13                	je     8018dc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8018c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cc:	88 10                	mov    %dl,(%eax)
	return 1;
  8018ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d3:	eb 0c                	jmp    8018e1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018da:	eb 05                	jmp    8018e1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018dc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018ef:	6a 01                	push   $0x1
  8018f1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	e8 e3 f1 ff ff       	call   800add <sys_cputs>
  8018fa:	83 c4 10             	add    $0x10,%esp
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <getchar>:

int
getchar(void)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801905:	6a 01                	push   $0x1
  801907:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	6a 00                	push   $0x0
  80190d:	e8 de f6 ff ff       	call   800ff0 <read>
	if (r < 0)
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	78 0f                	js     801928 <getchar+0x29>
		return r;
	if (r < 1)
  801919:	85 c0                	test   %eax,%eax
  80191b:	7e 06                	jle    801923 <getchar+0x24>
		return -E_EOF;
	return c;
  80191d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801921:	eb 05                	jmp    801928 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801923:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801930:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801933:	50                   	push   %eax
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 33 f4 ff ff       	call   800d6f <fd_lookup>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 11                	js     801954 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801946:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80194c:	39 10                	cmp    %edx,(%eax)
  80194e:	0f 94 c0             	sete   %al
  801951:	0f b6 c0             	movzbl %al,%eax
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <opencons>:

int
opencons(void)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80195c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	e8 97 f3 ff ff       	call   800cfc <fd_alloc>
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 3a                	js     8019a6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	68 07 04 00 00       	push   $0x407
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	6a 00                	push   $0x0
  801979:	e8 16 f2 ff ff       	call   800b94 <sys_page_alloc>
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	78 21                	js     8019a6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801985:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80198b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801993:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	50                   	push   %eax
  80199e:	e8 31 f3 ff ff       	call   800cd4 <fd2num>
  8019a3:	83 c4 10             	add    $0x10,%esp
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019ad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019b0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019b6:	e8 8e f1 ff ff       	call   800b49 <sys_getenvid>
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	ff 75 08             	pushl  0x8(%ebp)
  8019c4:	53                   	push   %ebx
  8019c5:	50                   	push   %eax
  8019c6:	68 44 22 80 00       	push   $0x802244
  8019cb:	e8 8c e7 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019d0:	83 c4 18             	add    $0x18,%esp
  8019d3:	56                   	push   %esi
  8019d4:	ff 75 10             	pushl  0x10(%ebp)
  8019d7:	e8 2f e7 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  8019dc:	c7 04 24 15 22 80 00 	movl   $0x802215,(%esp)
  8019e3:	e8 74 e7 ff ff       	call   80015c <cprintf>
  8019e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019eb:	cc                   	int3   
  8019ec:	eb fd                	jmp    8019eb <_panic+0x43>
	...

008019f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	57                   	push   %edi
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	57                   	push   %edi
  801a05:	68 68 22 80 00       	push   $0x802268
  801a0a:	e8 4d e7 ff ff       	call   80015c <cprintf>
	int r;
	if (pg != NULL) {
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 db                	test   %ebx,%ebx
  801a14:	74 28                	je     801a3e <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	68 78 22 80 00       	push   $0x802278
  801a1e:	e8 39 e7 ff ff       	call   80015c <cprintf>
		r = sys_ipc_recv(pg);
  801a23:	89 1c 24             	mov    %ebx,(%esp)
  801a26:	e8 64 f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a2b:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801a2d:	c7 04 24 d8 21 80 00 	movl   $0x8021d8,(%esp)
  801a34:	e8 23 e7 ff ff       	call   80015c <cprintf>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	eb 12                	jmp    801a50 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	68 00 00 c0 ee       	push   $0xeec00000
  801a46:	e8 44 f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a50:	85 db                	test   %ebx,%ebx
  801a52:	75 26                	jne    801a7a <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a54:	85 ff                	test   %edi,%edi
  801a56:	74 0a                	je     801a62 <ipc_recv+0x72>
  801a58:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5d:	8b 40 74             	mov    0x74(%eax),%eax
  801a60:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a62:	85 f6                	test   %esi,%esi
  801a64:	74 0a                	je     801a70 <ipc_recv+0x80>
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 40 78             	mov    0x78(%eax),%eax
  801a6e:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801a70:	a1 04 40 80 00       	mov    0x804004,%eax
  801a75:	8b 58 70             	mov    0x70(%eax),%ebx
  801a78:	eb 14                	jmp    801a8e <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a7a:	85 ff                	test   %edi,%edi
  801a7c:	74 06                	je     801a84 <ipc_recv+0x94>
  801a7e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801a84:	85 f6                	test   %esi,%esi
  801a86:	74 06                	je     801a8e <ipc_recv+0x9e>
  801a88:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801a8e:	89 d8                	mov    %ebx,%eax
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa7:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	75 25                	jne    801ad3 <ipc_send+0x3b>
  801aae:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ab3:	eb 1e                	jmp    801ad3 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ab5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab8:	75 07                	jne    801ac1 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aba:	e8 ae f0 ff ff       	call   800b6d <sys_yield>
  801abf:	eb 12                	jmp    801ad3 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ac1:	50                   	push   %eax
  801ac2:	68 7f 22 80 00       	push   $0x80227f
  801ac7:	6a 45                	push   $0x45
  801ac9:	68 92 22 80 00       	push   $0x802292
  801ace:	e8 d5 fe ff ff       	call   8019a8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	57                   	push   %edi
  801ad6:	ff 75 08             	pushl  0x8(%ebp)
  801ad9:	e8 8c f1 ff ff       	call   800c6a <sys_ipc_try_send>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	75 d0                	jne    801ab5 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	53                   	push   %ebx
  801af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801af4:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801afa:	74 22                	je     801b1e <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b01:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b08:	89 c2                	mov    %eax,%edx
  801b0a:	c1 e2 07             	shl    $0x7,%edx
  801b0d:	29 ca                	sub    %ecx,%edx
  801b0f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b15:	8b 52 50             	mov    0x50(%edx),%edx
  801b18:	39 da                	cmp    %ebx,%edx
  801b1a:	75 1d                	jne    801b39 <ipc_find_env+0x4c>
  801b1c:	eb 05                	jmp    801b23 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b2a:	c1 e0 07             	shl    $0x7,%eax
  801b2d:	29 d0                	sub    %edx,%eax
  801b2f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b34:	8b 40 40             	mov    0x40(%eax),%eax
  801b37:	eb 0c                	jmp    801b45 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b39:	40                   	inc    %eax
  801b3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3f:	75 c0                	jne    801b01 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b41:	66 b8 00 00          	mov    $0x0,%ax
}
  801b45:	5b                   	pop    %ebx
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    

00801b48 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	c1 ea 16             	shr    $0x16,%edx
  801b53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b5a:	f6 c2 01             	test   $0x1,%dl
  801b5d:	74 1e                	je     801b7d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b5f:	c1 e8 0c             	shr    $0xc,%eax
  801b62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b69:	a8 01                	test   $0x1,%al
  801b6b:	74 17                	je     801b84 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6d:	c1 e8 0c             	shr    $0xc,%eax
  801b70:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b77:	ef 
  801b78:	0f b7 c0             	movzwl %ax,%eax
  801b7b:	eb 0c                	jmp    801b89 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b82:	eb 05                	jmp    801b89 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    
	...

00801b8c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	83 ec 10             	sub    $0x10,%esp
  801b94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b97:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b9a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ba0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	75 2e                	jne    801bd8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801baa:	39 f1                	cmp    %esi,%ecx
  801bac:	77 5a                	ja     801c08 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bae:	85 c9                	test   %ecx,%ecx
  801bb0:	75 0b                	jne    801bbd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb7:	31 d2                	xor    %edx,%edx
  801bb9:	f7 f1                	div    %ecx
  801bbb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bbd:	31 d2                	xor    %edx,%edx
  801bbf:	89 f0                	mov    %esi,%eax
  801bc1:	f7 f1                	div    %ecx
  801bc3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bc5:	89 f8                	mov    %edi,%eax
  801bc7:	f7 f1                	div    %ecx
  801bc9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bcb:	89 f8                	mov    %edi,%eax
  801bcd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    
  801bd6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bd8:	39 f0                	cmp    %esi,%eax
  801bda:	77 1c                	ja     801bf8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bdc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bdf:	83 f7 1f             	xor    $0x1f,%edi
  801be2:	75 3c                	jne    801c20 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801be4:	39 f0                	cmp    %esi,%eax
  801be6:	0f 82 90 00 00 00    	jb     801c7c <__udivdi3+0xf0>
  801bec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bef:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bf2:	0f 86 84 00 00 00    	jbe    801c7c <__udivdi3+0xf0>
  801bf8:	31 f6                	xor    %esi,%esi
  801bfa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bfc:	89 f8                	mov    %edi,%eax
  801bfe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    
  801c07:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c08:	89 f2                	mov    %esi,%edx
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	f7 f1                	div    %ecx
  801c0e:	89 c7                	mov    %eax,%edi
  801c10:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c12:	89 f8                	mov    %edi,%eax
  801c14:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	5e                   	pop    %esi
  801c1a:	5f                   	pop    %edi
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    
  801c1d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c20:	89 f9                	mov    %edi,%ecx
  801c22:	d3 e0                	shl    %cl,%eax
  801c24:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c27:	b8 20 00 00 00       	mov    $0x20,%eax
  801c2c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c31:	88 c1                	mov    %al,%cl
  801c33:	d3 ea                	shr    %cl,%edx
  801c35:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c38:	09 ca                	or     %ecx,%edx
  801c3a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c40:	89 f9                	mov    %edi,%ecx
  801c42:	d3 e2                	shl    %cl,%edx
  801c44:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c47:	89 f2                	mov    %esi,%edx
  801c49:	88 c1                	mov    %al,%cl
  801c4b:	d3 ea                	shr    %cl,%edx
  801c4d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c50:	89 f2                	mov    %esi,%edx
  801c52:	89 f9                	mov    %edi,%ecx
  801c54:	d3 e2                	shl    %cl,%edx
  801c56:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c59:	88 c1                	mov    %al,%cl
  801c5b:	d3 ee                	shr    %cl,%esi
  801c5d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c5f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c62:	89 f0                	mov    %esi,%eax
  801c64:	89 ca                	mov    %ecx,%edx
  801c66:	f7 75 ec             	divl   -0x14(%ebp)
  801c69:	89 d1                	mov    %edx,%ecx
  801c6b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c6d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c70:	39 d1                	cmp    %edx,%ecx
  801c72:	72 28                	jb     801c9c <__udivdi3+0x110>
  801c74:	74 1a                	je     801c90 <__udivdi3+0x104>
  801c76:	89 f7                	mov    %esi,%edi
  801c78:	31 f6                	xor    %esi,%esi
  801c7a:	eb 80                	jmp    801bfc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c7c:	31 f6                	xor    %esi,%esi
  801c7e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c83:	89 f8                	mov    %edi,%eax
  801c85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	5e                   	pop    %esi
  801c8b:	5f                   	pop    %edi
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    
  801c8e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c90:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c93:	89 f9                	mov    %edi,%ecx
  801c95:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c97:	39 c2                	cmp    %eax,%edx
  801c99:	73 db                	jae    801c76 <__udivdi3+0xea>
  801c9b:	90                   	nop
		{
		  q0--;
  801c9c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c9f:	31 f6                	xor    %esi,%esi
  801ca1:	e9 56 ff ff ff       	jmp    801bfc <__udivdi3+0x70>
	...

00801ca8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	57                   	push   %edi
  801cac:	56                   	push   %esi
  801cad:	83 ec 20             	sub    $0x20,%esp
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cbc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cc5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cc7:	85 ff                	test   %edi,%edi
  801cc9:	75 15                	jne    801ce0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ccb:	39 f1                	cmp    %esi,%ecx
  801ccd:	0f 86 99 00 00 00    	jbe    801d6c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cd3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cd5:	89 d0                	mov    %edx,%eax
  801cd7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cd9:	83 c4 20             	add    $0x20,%esp
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ce0:	39 f7                	cmp    %esi,%edi
  801ce2:	0f 87 a4 00 00 00    	ja     801d8c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ce8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ceb:	83 f0 1f             	xor    $0x1f,%eax
  801cee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cf1:	0f 84 a1 00 00 00    	je     801d98 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cf7:	89 f8                	mov    %edi,%eax
  801cf9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cfc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cfe:	bf 20 00 00 00       	mov    $0x20,%edi
  801d03:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d09:	89 f9                	mov    %edi,%ecx
  801d0b:	d3 ea                	shr    %cl,%edx
  801d0d:	09 c2                	or     %eax,%edx
  801d0f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d18:	d3 e0                	shl    %cl,%eax
  801d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d24:	d3 e0                	shl    %cl,%eax
  801d26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d2c:	89 f9                	mov    %edi,%ecx
  801d2e:	d3 e8                	shr    %cl,%eax
  801d30:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d32:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d34:	89 f2                	mov    %esi,%edx
  801d36:	f7 75 f0             	divl   -0x10(%ebp)
  801d39:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d3b:	f7 65 f4             	mull   -0xc(%ebp)
  801d3e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d41:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d43:	39 d6                	cmp    %edx,%esi
  801d45:	72 71                	jb     801db8 <__umoddi3+0x110>
  801d47:	74 7f                	je     801dc8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d4c:	29 c8                	sub    %ecx,%eax
  801d4e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d50:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d53:	d3 e8                	shr    %cl,%eax
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	89 f9                	mov    %edi,%ecx
  801d59:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d5b:	09 d0                	or     %edx,%eax
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d62:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    
  801d6b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d6c:	85 c9                	test   %ecx,%ecx
  801d6e:	75 0b                	jne    801d7b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d70:	b8 01 00 00 00       	mov    $0x1,%eax
  801d75:	31 d2                	xor    %edx,%edx
  801d77:	f7 f1                	div    %ecx
  801d79:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	31 d2                	xor    %edx,%edx
  801d7f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d84:	f7 f1                	div    %ecx
  801d86:	e9 4a ff ff ff       	jmp    801cd5 <__umoddi3+0x2d>
  801d8b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d8c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d8e:	83 c4 20             	add    $0x20,%esp
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d98:	39 f7                	cmp    %esi,%edi
  801d9a:	72 05                	jb     801da1 <__umoddi3+0xf9>
  801d9c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d9f:	77 0c                	ja     801dad <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801da1:	89 f2                	mov    %esi,%edx
  801da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da6:	29 c8                	sub    %ecx,%eax
  801da8:	19 fa                	sbb    %edi,%edx
  801daa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801db0:	83 c4 20             	add    $0x20,%esp
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    
  801db7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801db8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dbb:	89 c1                	mov    %eax,%ecx
  801dbd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dc0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dc3:	eb 84                	jmp    801d49 <__umoddi3+0xa1>
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dc8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dcb:	72 eb                	jb     801db8 <__umoddi3+0x110>
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	e9 75 ff ff ff       	jmp    801d49 <__umoddi3+0xa1>
