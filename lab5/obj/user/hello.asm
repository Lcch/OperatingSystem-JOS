
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
  80003a:	68 c0 1d 80 00       	push   $0x801dc0
  80003f:	e8 18 01 00 00       	call   80015c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 40 80 00       	mov    0x804004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 ce 1d 80 00       	push   $0x801dce
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
  8000b6:	e8 4b 0e 00 00       	call   800f06 <close_all>
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
  8001c4:	e8 9b 19 00 00       	call   801b64 <__udivdi3>
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
  800200:	e8 7b 1a 00 00       	call   801c80 <__umoddi3>
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	0f be 80 ef 1d 80 00 	movsbl 0x801def(%eax),%eax
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
  80034c:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
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
  8003f8:	8b 04 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%eax
  8003ff:	85 c0                	test   %eax,%eax
  800401:	75 1a                	jne    80041d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800403:	52                   	push   %edx
  800404:	68 07 1e 80 00       	push   $0x801e07
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
  80041e:	68 d1 21 80 00       	push   $0x8021d1
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
  800454:	c7 45 d0 00 1e 80 00 	movl   $0x801e00,-0x30(%ebp)
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
  800ac2:	68 ff 20 80 00       	push   $0x8020ff
  800ac7:	6a 42                	push   $0x42
  800ac9:	68 1c 21 80 00       	push   $0x80211c
  800ace:	e8 dd 0e 00 00       	call   8019b0 <_panic>

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

00800cd4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 14             	pushl  0x14(%ebp)
  800cdf:	ff 75 10             	pushl  0x10(%ebp)
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cf2:	e8 99 fd ff ff       	call   800a90 <syscall>
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    
  800cf9:	00 00                	add    %al,(%eax)
	...

00800cfc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	05 00 00 00 30       	add    $0x30000000,%eax
  800d07:	c1 e8 0c             	shr    $0xc,%eax
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d0f:	ff 75 08             	pushl  0x8(%ebp)
  800d12:	e8 e5 ff ff ff       	call   800cfc <fd2num>
  800d17:	83 c4 04             	add    $0x4,%esp
  800d1a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d1f:	c1 e0 0c             	shl    $0xc,%eax
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	53                   	push   %ebx
  800d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d2b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d30:	a8 01                	test   $0x1,%al
  800d32:	74 34                	je     800d68 <fd_alloc+0x44>
  800d34:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d39:	a8 01                	test   $0x1,%al
  800d3b:	74 32                	je     800d6f <fd_alloc+0x4b>
  800d3d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	c1 ea 16             	shr    $0x16,%edx
  800d49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d50:	f6 c2 01             	test   $0x1,%dl
  800d53:	74 1f                	je     800d74 <fd_alloc+0x50>
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	c1 ea 0c             	shr    $0xc,%edx
  800d5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d61:	f6 c2 01             	test   $0x1,%dl
  800d64:	75 17                	jne    800d7d <fd_alloc+0x59>
  800d66:	eb 0c                	jmp    800d74 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d68:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d6d:	eb 05                	jmp    800d74 <fd_alloc+0x50>
  800d6f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d74:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	eb 17                	jmp    800d94 <fd_alloc+0x70>
  800d7d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d82:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d87:	75 b9                	jne    800d42 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800d8f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d94:	5b                   	pop    %ebx
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d9d:	83 f8 1f             	cmp    $0x1f,%eax
  800da0:	77 36                	ja     800dd8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800da7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800daa:	89 c2                	mov    %eax,%edx
  800dac:	c1 ea 16             	shr    $0x16,%edx
  800daf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db6:	f6 c2 01             	test   $0x1,%dl
  800db9:	74 24                	je     800ddf <fd_lookup+0x48>
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	c1 ea 0c             	shr    $0xc,%edx
  800dc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc7:	f6 c2 01             	test   $0x1,%dl
  800dca:	74 1a                	je     800de6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcf:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd6:	eb 13                	jmp    800deb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ddd:	eb 0c                	jmp    800deb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de4:	eb 05                	jmp    800deb <fd_lookup+0x54>
  800de6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	53                   	push   %ebx
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800dfa:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e00:	74 0d                	je     800e0f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
  800e07:	eb 14                	jmp    800e1d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e09:	39 0a                	cmp    %ecx,(%edx)
  800e0b:	75 10                	jne    800e1d <dev_lookup+0x30>
  800e0d:	eb 05                	jmp    800e14 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e0f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e14:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1b:	eb 31                	jmp    800e4e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1d:	40                   	inc    %eax
  800e1e:	8b 14 85 a8 21 80 00 	mov    0x8021a8(,%eax,4),%edx
  800e25:	85 d2                	test   %edx,%edx
  800e27:	75 e0                	jne    800e09 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e29:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2e:	8b 40 48             	mov    0x48(%eax),%eax
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	51                   	push   %ecx
  800e35:	50                   	push   %eax
  800e36:	68 2c 21 80 00       	push   $0x80212c
  800e3b:	e8 1c f3 ff ff       	call   80015c <cprintf>
	*dev = 0;
  800e40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 20             	sub    $0x20,%esp
  800e5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5e:	8a 45 0c             	mov    0xc(%ebp),%al
  800e61:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e64:	56                   	push   %esi
  800e65:	e8 92 fe ff ff       	call   800cfc <fd2num>
  800e6a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e6d:	89 14 24             	mov    %edx,(%esp)
  800e70:	50                   	push   %eax
  800e71:	e8 21 ff ff ff       	call   800d97 <fd_lookup>
  800e76:	89 c3                	mov    %eax,%ebx
  800e78:	83 c4 08             	add    $0x8,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	78 05                	js     800e84 <fd_close+0x31>
	    || fd != fd2)
  800e7f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e82:	74 0d                	je     800e91 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e84:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e88:	75 48                	jne    800ed2 <fd_close+0x7f>
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	eb 41                	jmp    800ed2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e97:	50                   	push   %eax
  800e98:	ff 36                	pushl  (%esi)
  800e9a:	e8 4e ff ff ff       	call   800ded <dev_lookup>
  800e9f:	89 c3                	mov    %eax,%ebx
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 1c                	js     800ec4 <fd_close+0x71>
		if (dev->dev_close)
  800ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eab:	8b 40 10             	mov    0x10(%eax),%eax
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	74 0d                	je     800ebf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	56                   	push   %esi
  800eb6:	ff d0                	call   *%eax
  800eb8:	89 c3                	mov    %eax,%ebx
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	eb 05                	jmp    800ec4 <fd_close+0x71>
		else
			r = 0;
  800ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	56                   	push   %esi
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 0f fd ff ff       	call   800bde <sys_page_unmap>
	return r;
  800ecf:	83 c4 10             	add    $0x10,%esp
}
  800ed2:	89 d8                	mov    %ebx,%eax
  800ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee4:	50                   	push   %eax
  800ee5:	ff 75 08             	pushl  0x8(%ebp)
  800ee8:	e8 aa fe ff ff       	call   800d97 <fd_lookup>
  800eed:	83 c4 08             	add    $0x8,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 10                	js     800f04 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	6a 01                	push   $0x1
  800ef9:	ff 75 f4             	pushl  -0xc(%ebp)
  800efc:	e8 52 ff ff ff       	call   800e53 <fd_close>
  800f01:	83 c4 10             	add    $0x10,%esp
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <close_all>:

void
close_all(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	53                   	push   %ebx
  800f16:	e8 c0 ff ff ff       	call   800edb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1b:	43                   	inc    %ebx
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	83 fb 20             	cmp    $0x20,%ebx
  800f22:	75 ee                	jne    800f12 <close_all+0xc>
		close(i);
}
  800f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 2c             	sub    $0x2c,%esp
  800f32:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f35:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	ff 75 08             	pushl  0x8(%ebp)
  800f3c:	e8 56 fe ff ff       	call   800d97 <fd_lookup>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	83 c4 08             	add    $0x8,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	0f 88 c0 00 00 00    	js     80100e <dup+0xe5>
		return r;
	close(newfdnum);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	57                   	push   %edi
  800f52:	e8 84 ff ff ff       	call   800edb <close>

	newfd = INDEX2FD(newfdnum);
  800f57:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f5d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f60:	83 c4 04             	add    $0x4,%esp
  800f63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f66:	e8 a1 fd ff ff       	call   800d0c <fd2data>
  800f6b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f6d:	89 34 24             	mov    %esi,(%esp)
  800f70:	e8 97 fd ff ff       	call   800d0c <fd2data>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 16             	shr    $0x16,%eax
  800f80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	74 37                	je     800fc2 <dup+0x99>
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f97:	f6 c2 01             	test   $0x1,%dl
  800f9a:	74 26                	je     800fc2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 d4             	pushl  -0x2c(%ebp)
  800faf:	6a 00                	push   $0x0
  800fb1:	53                   	push   %ebx
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 ff fb ff ff       	call   800bb8 <sys_page_map>
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 2d                	js     800fef <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc5:	89 c2                	mov    %eax,%edx
  800fc7:	c1 ea 0c             	shr    $0xc,%edx
  800fca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fda:	52                   	push   %edx
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	50                   	push   %eax
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 d2 fb ff ff       	call   800bb8 <sys_page_map>
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	79 1d                	jns    80100c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	56                   	push   %esi
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 e4 fb ff ff       	call   800bde <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801000:	6a 00                	push   $0x0
  801002:	e8 d7 fb ff ff       	call   800bde <sys_page_unmap>
	return r;
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	eb 02                	jmp    80100e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80100c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	53                   	push   %ebx
  80101c:	83 ec 14             	sub    $0x14,%esp
  80101f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801022:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	53                   	push   %ebx
  801027:	e8 6b fd ff ff       	call   800d97 <fd_lookup>
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 67                	js     80109a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103d:	ff 30                	pushl  (%eax)
  80103f:	e8 a9 fd ff ff       	call   800ded <dev_lookup>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	78 4f                	js     80109a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80104b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104e:	8b 50 08             	mov    0x8(%eax),%edx
  801051:	83 e2 03             	and    $0x3,%edx
  801054:	83 fa 01             	cmp    $0x1,%edx
  801057:	75 21                	jne    80107a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801059:	a1 04 40 80 00       	mov    0x804004,%eax
  80105e:	8b 40 48             	mov    0x48(%eax),%eax
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	53                   	push   %ebx
  801065:	50                   	push   %eax
  801066:	68 6d 21 80 00       	push   $0x80216d
  80106b:	e8 ec f0 ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801078:	eb 20                	jmp    80109a <read+0x82>
	}
	if (!dev->dev_read)
  80107a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80107d:	8b 52 08             	mov    0x8(%edx),%edx
  801080:	85 d2                	test   %edx,%edx
  801082:	74 11                	je     801095 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	ff 75 10             	pushl  0x10(%ebp)
  80108a:	ff 75 0c             	pushl  0xc(%ebp)
  80108d:	50                   	push   %eax
  80108e:	ff d2                	call   *%edx
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	eb 05                	jmp    80109a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801095:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80109a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ae:	85 f6                	test   %esi,%esi
  8010b0:	74 31                	je     8010e3 <readn+0x44>
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	89 f2                	mov    %esi,%edx
  8010c1:	29 c2                	sub    %eax,%edx
  8010c3:	52                   	push   %edx
  8010c4:	03 45 0c             	add    0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	57                   	push   %edi
  8010c9:	e8 4a ff ff ff       	call   801018 <read>
		if (m < 0)
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 17                	js     8010ec <readn+0x4d>
			return m;
		if (m == 0)
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	74 11                	je     8010ea <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d9:	01 c3                	add    %eax,%ebx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	39 f3                	cmp    %esi,%ebx
  8010df:	72 db                	jb     8010bc <readn+0x1d>
  8010e1:	eb 09                	jmp    8010ec <readn+0x4d>
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	eb 02                	jmp    8010ec <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010ea:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8010ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 14             	sub    $0x14,%esp
  8010fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801101:	50                   	push   %eax
  801102:	53                   	push   %ebx
  801103:	e8 8f fc ff ff       	call   800d97 <fd_lookup>
  801108:	83 c4 08             	add    $0x8,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 62                	js     801171 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801119:	ff 30                	pushl  (%eax)
  80111b:	e8 cd fc ff ff       	call   800ded <dev_lookup>
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 4a                	js     801171 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80112e:	75 21                	jne    801151 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801130:	a1 04 40 80 00       	mov    0x804004,%eax
  801135:	8b 40 48             	mov    0x48(%eax),%eax
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	53                   	push   %ebx
  80113c:	50                   	push   %eax
  80113d:	68 89 21 80 00       	push   $0x802189
  801142:	e8 15 f0 ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114f:	eb 20                	jmp    801171 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801151:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801154:	8b 52 0c             	mov    0xc(%edx),%edx
  801157:	85 d2                	test   %edx,%edx
  801159:	74 11                	je     80116c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	ff 75 10             	pushl  0x10(%ebp)
  801161:	ff 75 0c             	pushl  0xc(%ebp)
  801164:	50                   	push   %eax
  801165:	ff d2                	call   *%edx
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb 05                	jmp    801171 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80116c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801171:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <seek>:

int
seek(int fdnum, off_t offset)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	ff 75 08             	pushl  0x8(%ebp)
  801183:	e8 0f fc ff ff       	call   800d97 <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 0e                	js     80119d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80118f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801192:	8b 55 0c             	mov    0xc(%ebp),%edx
  801195:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 14             	sub    $0x14,%esp
  8011a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	e8 e4 fb ff ff       	call   800d97 <fd_lookup>
  8011b3:	83 c4 08             	add    $0x8,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 5f                	js     801219 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 22 fc ff ff       	call   800ded <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 47                	js     801219 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d9:	75 21                	jne    8011fc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011db:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e0:	8b 40 48             	mov    0x48(%eax),%eax
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	53                   	push   %ebx
  8011e7:	50                   	push   %eax
  8011e8:	68 4c 21 80 00       	push   $0x80214c
  8011ed:	e8 6a ef ff ff       	call   80015c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fa:	eb 1d                	jmp    801219 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8011fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ff:	8b 52 18             	mov    0x18(%edx),%edx
  801202:	85 d2                	test   %edx,%edx
  801204:	74 0e                	je     801214 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	50                   	push   %eax
  80120d:	ff d2                	call   *%edx
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	eb 05                	jmp    801219 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801214:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	53                   	push   %ebx
  801222:	83 ec 14             	sub    $0x14,%esp
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801228:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	e8 63 fb ff ff       	call   800d97 <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 52                	js     80128d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	ff 30                	pushl  (%eax)
  801247:	e8 a1 fb ff ff       	call   800ded <dev_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 3a                	js     80128d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125a:	74 2c                	je     801288 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801266:	00 00 00 
	stat->st_isdir = 0;
  801269:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801270:	00 00 00 
	stat->st_dev = dev;
  801273:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	53                   	push   %ebx
  80127d:	ff 75 f0             	pushl  -0x10(%ebp)
  801280:	ff 50 14             	call   *0x14(%eax)
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 05                	jmp    80128d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801288:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80128d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	6a 00                	push   $0x0
  80129c:	ff 75 08             	pushl  0x8(%ebp)
  80129f:	e8 78 01 00 00       	call   80141c <open>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 1b                	js     8012c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	ff 75 0c             	pushl  0xc(%ebp)
  8012b3:	50                   	push   %eax
  8012b4:	e8 65 ff ff ff       	call   80121e <fstat>
  8012b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8012bb:	89 1c 24             	mov    %ebx,(%esp)
  8012be:	e8 18 fc ff ff       	call   800edb <close>
	return r;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	89 f3                	mov    %esi,%ebx
}
  8012c8:	89 d8                	mov    %ebx,%eax
  8012ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
  8012d1:	00 00                	add    %al,(%eax)
	...

008012d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	89 c3                	mov    %eax,%ebx
  8012db:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e4:	75 12                	jne    8012f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	6a 01                	push   $0x1
  8012eb:	e8 d2 07 00 00       	call   801ac2 <ipc_find_env>
  8012f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f8:	6a 07                	push   $0x7
  8012fa:	68 00 50 80 00       	push   $0x805000
  8012ff:	53                   	push   %ebx
  801300:	ff 35 00 40 80 00    	pushl  0x804000
  801306:	e8 62 07 00 00       	call   801a6d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80130b:	83 c4 0c             	add    $0xc,%esp
  80130e:	6a 00                	push   $0x0
  801310:	56                   	push   %esi
  801311:	6a 00                	push   $0x0
  801313:	e8 e0 06 00 00       	call   8019f8 <ipc_recv>
}
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 04             	sub    $0x4,%esp
  801326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	8b 40 0c             	mov    0xc(%eax),%eax
  80132f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801334:	ba 00 00 00 00       	mov    $0x0,%edx
  801339:	b8 05 00 00 00       	mov    $0x5,%eax
  80133e:	e8 91 ff ff ff       	call   8012d4 <fsipc>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 2c                	js     801373 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	68 00 50 80 00       	push   $0x805000
  80134f:	53                   	push   %ebx
  801350:	e8 bd f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801355:	a1 80 50 80 00       	mov    0x805080,%eax
  80135a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801360:	a1 84 50 80 00       	mov    0x805084,%eax
  801365:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	8b 40 0c             	mov    0xc(%eax),%eax
  801384:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801389:	ba 00 00 00 00       	mov    $0x0,%edx
  80138e:	b8 06 00 00 00       	mov    $0x6,%eax
  801393:	e8 3c ff ff ff       	call   8012d4 <fsipc>
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ad:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b8:	b8 03 00 00 00       	mov    $0x3,%eax
  8013bd:	e8 12 ff ff ff       	call   8012d4 <fsipc>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 4b                	js     801413 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013c8:	39 c6                	cmp    %eax,%esi
  8013ca:	73 16                	jae    8013e2 <devfile_read+0x48>
  8013cc:	68 b8 21 80 00       	push   $0x8021b8
  8013d1:	68 bf 21 80 00       	push   $0x8021bf
  8013d6:	6a 7d                	push   $0x7d
  8013d8:	68 d4 21 80 00       	push   $0x8021d4
  8013dd:	e8 ce 05 00 00       	call   8019b0 <_panic>
	assert(r <= PGSIZE);
  8013e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013e7:	7e 16                	jle    8013ff <devfile_read+0x65>
  8013e9:	68 df 21 80 00       	push   $0x8021df
  8013ee:	68 bf 21 80 00       	push   $0x8021bf
  8013f3:	6a 7e                	push   $0x7e
  8013f5:	68 d4 21 80 00       	push   $0x8021d4
  8013fa:	e8 b1 05 00 00       	call   8019b0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8013ff:	83 ec 04             	sub    $0x4,%esp
  801402:	50                   	push   %eax
  801403:	68 00 50 80 00       	push   $0x805000
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	e8 c3 f4 ff ff       	call   8008d3 <memmove>
	return r;
  801410:	83 c4 10             	add    $0x10,%esp
}
  801413:	89 d8                	mov    %ebx,%eax
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	83 ec 1c             	sub    $0x1c,%esp
  801424:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801427:	56                   	push   %esi
  801428:	e8 93 f2 ff ff       	call   8006c0 <strlen>
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801435:	7f 65                	jg     80149c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	e8 e1 f8 ff ff       	call   800d24 <fd_alloc>
  801443:	89 c3                	mov    %eax,%ebx
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 55                	js     8014a1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	56                   	push   %esi
  801450:	68 00 50 80 00       	push   $0x805000
  801455:	e8 b8 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80145a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801462:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801465:	b8 01 00 00 00       	mov    $0x1,%eax
  80146a:	e8 65 fe ff ff       	call   8012d4 <fsipc>
  80146f:	89 c3                	mov    %eax,%ebx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	79 12                	jns    80148a <open+0x6e>
		fd_close(fd, 0);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	6a 00                	push   $0x0
  80147d:	ff 75 f4             	pushl  -0xc(%ebp)
  801480:	e8 ce f9 ff ff       	call   800e53 <fd_close>
		return r;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	eb 17                	jmp    8014a1 <open+0x85>
	}

	return fd2num(fd);
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	ff 75 f4             	pushl  -0xc(%ebp)
  801490:	e8 67 f8 ff ff       	call   800cfc <fd2num>
  801495:	89 c3                	mov    %eax,%ebx
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	eb 05                	jmp    8014a1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80149c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a6:	5b                   	pop    %ebx
  8014a7:	5e                   	pop    %esi
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    
	...

008014ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	ff 75 08             	pushl  0x8(%ebp)
  8014ba:	e8 4d f8 ff ff       	call   800d0c <fd2data>
  8014bf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014c1:	83 c4 08             	add    $0x8,%esp
  8014c4:	68 eb 21 80 00       	push   $0x8021eb
  8014c9:	56                   	push   %esi
  8014ca:	e8 43 f2 ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8014d2:	2b 03                	sub    (%ebx),%eax
  8014d4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014da:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014e1:	00 00 00 
	stat->st_dev = &devpipe;
  8014e4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014eb:	30 80 00 
	return 0;
}
  8014ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f6:	5b                   	pop    %ebx
  8014f7:	5e                   	pop    %esi
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 0c             	sub    $0xc,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801504:	53                   	push   %ebx
  801505:	6a 00                	push   $0x0
  801507:	e8 d2 f6 ff ff       	call   800bde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80150c:	89 1c 24             	mov    %ebx,(%esp)
  80150f:	e8 f8 f7 ff ff       	call   800d0c <fd2data>
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	50                   	push   %eax
  801518:	6a 00                	push   $0x0
  80151a:	e8 bf f6 ff ff       	call   800bde <sys_page_unmap>
}
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	57                   	push   %edi
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	83 ec 1c             	sub    $0x1c,%esp
  80152d:	89 c7                	mov    %eax,%edi
  80152f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801532:	a1 04 40 80 00       	mov    0x804004,%eax
  801537:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	57                   	push   %edi
  80153e:	e8 dd 05 00 00       	call   801b20 <pageref>
  801543:	89 c6                	mov    %eax,%esi
  801545:	83 c4 04             	add    $0x4,%esp
  801548:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154b:	e8 d0 05 00 00       	call   801b20 <pageref>
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	39 c6                	cmp    %eax,%esi
  801555:	0f 94 c0             	sete   %al
  801558:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80155b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801561:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801564:	39 cb                	cmp    %ecx,%ebx
  801566:	75 08                	jne    801570 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801568:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156b:	5b                   	pop    %ebx
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801570:	83 f8 01             	cmp    $0x1,%eax
  801573:	75 bd                	jne    801532 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801575:	8b 42 58             	mov    0x58(%edx),%eax
  801578:	6a 01                	push   $0x1
  80157a:	50                   	push   %eax
  80157b:	53                   	push   %ebx
  80157c:	68 f2 21 80 00       	push   $0x8021f2
  801581:	e8 d6 eb ff ff       	call   80015c <cprintf>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	eb a7                	jmp    801532 <_pipeisclosed+0xe>

0080158b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 28             	sub    $0x28,%esp
  801594:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801597:	56                   	push   %esi
  801598:	e8 6f f7 ff ff       	call   800d0c <fd2data>
  80159d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015a6:	75 4a                	jne    8015f2 <devpipe_write+0x67>
  8015a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8015ad:	eb 56                	jmp    801605 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015af:	89 da                	mov    %ebx,%edx
  8015b1:	89 f0                	mov    %esi,%eax
  8015b3:	e8 6c ff ff ff       	call   801524 <_pipeisclosed>
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	75 4d                	jne    801609 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015bc:	e8 ac f5 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8015c4:	8b 13                	mov    (%ebx),%edx
  8015c6:	83 c2 20             	add    $0x20,%edx
  8015c9:	39 d0                	cmp    %edx,%eax
  8015cb:	73 e2                	jae    8015af <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8015d5:	79 05                	jns    8015dc <devpipe_write+0x51>
  8015d7:	4a                   	dec    %edx
  8015d8:	83 ca e0             	or     $0xffffffe0,%edx
  8015db:	42                   	inc    %edx
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015e6:	40                   	inc    %eax
  8015e7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ea:	47                   	inc    %edi
  8015eb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8015ee:	77 07                	ja     8015f7 <devpipe_write+0x6c>
  8015f0:	eb 13                	jmp    801605 <devpipe_write+0x7a>
  8015f2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8015fa:	8b 13                	mov    (%ebx),%edx
  8015fc:	83 c2 20             	add    $0x20,%edx
  8015ff:	39 d0                	cmp    %edx,%eax
  801601:	73 ac                	jae    8015af <devpipe_write+0x24>
  801603:	eb c8                	jmp    8015cd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801605:	89 f8                	mov    %edi,%eax
  801607:	eb 05                	jmp    80160e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 18             	sub    $0x18,%esp
  80161f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801622:	57                   	push   %edi
  801623:	e8 e4 f6 ff ff       	call   800d0c <fd2data>
  801628:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801631:	75 44                	jne    801677 <devpipe_read+0x61>
  801633:	be 00 00 00 00       	mov    $0x0,%esi
  801638:	eb 4f                	jmp    801689 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80163a:	89 f0                	mov    %esi,%eax
  80163c:	eb 54                	jmp    801692 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80163e:	89 da                	mov    %ebx,%edx
  801640:	89 f8                	mov    %edi,%eax
  801642:	e8 dd fe ff ff       	call   801524 <_pipeisclosed>
  801647:	85 c0                	test   %eax,%eax
  801649:	75 42                	jne    80168d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80164b:	e8 1d f5 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801650:	8b 03                	mov    (%ebx),%eax
  801652:	3b 43 04             	cmp    0x4(%ebx),%eax
  801655:	74 e7                	je     80163e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801657:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80165c:	79 05                	jns    801663 <devpipe_read+0x4d>
  80165e:	48                   	dec    %eax
  80165f:	83 c8 e0             	or     $0xffffffe0,%eax
  801662:	40                   	inc    %eax
  801663:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801667:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80166d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166f:	46                   	inc    %esi
  801670:	39 75 10             	cmp    %esi,0x10(%ebp)
  801673:	77 07                	ja     80167c <devpipe_read+0x66>
  801675:	eb 12                	jmp    801689 <devpipe_read+0x73>
  801677:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80167c:	8b 03                	mov    (%ebx),%eax
  80167e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801681:	75 d4                	jne    801657 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801683:	85 f6                	test   %esi,%esi
  801685:	75 b3                	jne    80163a <devpipe_read+0x24>
  801687:	eb b5                	jmp    80163e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801689:	89 f0                	mov    %esi,%eax
  80168b:	eb 05                	jmp    801692 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 28             	sub    $0x28,%esp
  8016a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	e8 75 f6 ff ff       	call   800d24 <fd_alloc>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	0f 88 24 01 00 00    	js     8017e0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	68 07 04 00 00       	push   $0x407
  8016c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 c6 f4 ff ff       	call   800b94 <sys_page_alloc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 05 01 00 00    	js     8017e0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	e8 3d f6 ff ff       	call   800d24 <fd_alloc>
  8016e7:	89 c3                	mov    %eax,%ebx
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	0f 88 dc 00 00 00    	js     8017d0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	68 07 04 00 00       	push   $0x407
  8016fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ff:	6a 00                	push   $0x0
  801701:	e8 8e f4 ff ff       	call   800b94 <sys_page_alloc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 88 bd 00 00 00    	js     8017d0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	ff 75 e4             	pushl  -0x1c(%ebp)
  801719:	e8 ee f5 ff ff       	call   800d0c <fd2data>
  80171e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801720:	83 c4 0c             	add    $0xc,%esp
  801723:	68 07 04 00 00       	push   $0x407
  801728:	50                   	push   %eax
  801729:	6a 00                	push   $0x0
  80172b:	e8 64 f4 ff ff       	call   800b94 <sys_page_alloc>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	0f 88 83 00 00 00    	js     8017c0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	ff 75 e0             	pushl  -0x20(%ebp)
  801743:	e8 c4 f5 ff ff       	call   800d0c <fd2data>
  801748:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80174f:	50                   	push   %eax
  801750:	6a 00                	push   $0x0
  801752:	56                   	push   %esi
  801753:	6a 00                	push   $0x0
  801755:	e8 5e f4 ff ff       	call   800bb8 <sys_page_map>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 20             	add    $0x20,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 4f                	js     8017b2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801763:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80176e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801771:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801778:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80177e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801781:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801783:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801786:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	ff 75 e4             	pushl  -0x1c(%ebp)
  801793:	e8 64 f5 ff ff       	call   800cfc <fd2num>
  801798:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80179a:	83 c4 04             	add    $0x4,%esp
  80179d:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a0:	e8 57 f5 ff ff       	call   800cfc <fd2num>
  8017a5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b0:	eb 2e                	jmp    8017e0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	56                   	push   %esi
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 21 f4 ff ff       	call   800bde <sys_page_unmap>
  8017bd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 11 f4 ff ff       	call   800bde <sys_page_unmap>
  8017cd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 01 f4 ff ff       	call   800bde <sys_page_unmap>
  8017dd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 9b f5 ff ff       	call   800d97 <fd_lookup>
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 18                	js     80181b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	e8 fe f4 ff ff       	call   800d0c <fd2data>
	return _pipeisclosed(fd, p);
  80180e:	89 c2                	mov    %eax,%edx
  801810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801813:	e8 0c fd ff ff       	call   801524 <_pipeisclosed>
  801818:	83 c4 10             	add    $0x10,%esp
}
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    
  80181d:	00 00                	add    %al,(%eax)
	...

00801820 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801830:	68 0a 22 80 00       	push   $0x80220a
  801835:	ff 75 0c             	pushl  0xc(%ebp)
  801838:	e8 d5 ee ff ff       	call   800712 <strcpy>
	return 0;
}
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
  801842:	c9                   	leave  
  801843:	c3                   	ret    

00801844 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801850:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801854:	74 45                	je     80189b <devcons_write+0x57>
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
  80185b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801860:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801866:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801869:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80186b:	83 fb 7f             	cmp    $0x7f,%ebx
  80186e:	76 05                	jbe    801875 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801870:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	53                   	push   %ebx
  801879:	03 45 0c             	add    0xc(%ebp),%eax
  80187c:	50                   	push   %eax
  80187d:	57                   	push   %edi
  80187e:	e8 50 f0 ff ff       	call   8008d3 <memmove>
		sys_cputs(buf, m);
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	53                   	push   %ebx
  801887:	57                   	push   %edi
  801888:	e8 50 f2 ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188d:	01 de                	add    %ebx,%esi
  80188f:	89 f0                	mov    %esi,%eax
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	3b 75 10             	cmp    0x10(%ebp),%esi
  801897:	72 cd                	jb     801866 <devcons_write+0x22>
  801899:	eb 05                	jmp    8018a0 <devcons_write+0x5c>
  80189b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018a0:	89 f0                	mov    %esi,%eax
  8018a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018b4:	75 07                	jne    8018bd <devcons_read+0x13>
  8018b6:	eb 25                	jmp    8018dd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018b8:	e8 b0 f2 ff ff       	call   800b6d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018bd:	e8 41 f2 ff ff       	call   800b03 <sys_cgetc>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	74 f2                	je     8018b8 <devcons_read+0xe>
  8018c6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 1d                	js     8018e9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018cc:	83 f8 04             	cmp    $0x4,%eax
  8018cf:	74 13                	je     8018e4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	88 10                	mov    %dl,(%eax)
	return 1;
  8018d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018db:	eb 0c                	jmp    8018e9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e2:	eb 05                	jmp    8018e9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018f7:	6a 01                	push   $0x1
  8018f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	e8 db f1 ff ff       	call   800add <sys_cputs>
  801902:	83 c4 10             	add    $0x10,%esp
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <getchar>:

int
getchar(void)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80190d:	6a 01                	push   $0x1
  80190f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801912:	50                   	push   %eax
  801913:	6a 00                	push   $0x0
  801915:	e8 fe f6 ff ff       	call   801018 <read>
	if (r < 0)
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 0f                	js     801930 <getchar+0x29>
		return r;
	if (r < 1)
  801921:	85 c0                	test   %eax,%eax
  801923:	7e 06                	jle    80192b <getchar+0x24>
		return -E_EOF;
	return c;
  801925:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801929:	eb 05                	jmp    801930 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80192b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	ff 75 08             	pushl  0x8(%ebp)
  80193f:	e8 53 f4 ff ff       	call   800d97 <fd_lookup>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	78 11                	js     80195c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801954:	39 10                	cmp    %edx,(%eax)
  801956:	0f 94 c0             	sete   %al
  801959:	0f b6 c0             	movzbl %al,%eax
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <opencons>:

int
opencons(void)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	e8 b7 f3 ff ff       	call   800d24 <fd_alloc>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	78 3a                	js     8019ae <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	68 07 04 00 00       	push   $0x407
  80197c:	ff 75 f4             	pushl  -0xc(%ebp)
  80197f:	6a 00                	push   $0x0
  801981:	e8 0e f2 ff ff       	call   800b94 <sys_page_alloc>
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 21                	js     8019ae <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80198d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	50                   	push   %eax
  8019a6:	e8 51 f3 ff ff       	call   800cfc <fd2num>
  8019ab:	83 c4 10             	add    $0x10,%esp
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019b5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019b8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019be:	e8 86 f1 ff ff       	call   800b49 <sys_getenvid>
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	53                   	push   %ebx
  8019cd:	50                   	push   %eax
  8019ce:	68 18 22 80 00       	push   $0x802218
  8019d3:	e8 84 e7 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019d8:	83 c4 18             	add    $0x18,%esp
  8019db:	56                   	push   %esi
  8019dc:	ff 75 10             	pushl  0x10(%ebp)
  8019df:	e8 27 e7 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  8019e4:	c7 04 24 03 22 80 00 	movl   $0x802203,(%esp)
  8019eb:	e8 6c e7 ff ff       	call   80015c <cprintf>
  8019f0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019f3:	cc                   	int3   
  8019f4:	eb fd                	jmp    8019f3 <_panic+0x43>
	...

008019f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a06:	85 c0                	test   %eax,%eax
  801a08:	74 0e                	je     801a18 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	50                   	push   %eax
  801a0e:	e8 7c f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	eb 10                	jmp    801a28 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	68 00 00 c0 ee       	push   $0xeec00000
  801a20:	e8 6a f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a25:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	75 26                	jne    801a52 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a2c:	85 f6                	test   %esi,%esi
  801a2e:	74 0a                	je     801a3a <ipc_recv+0x42>
  801a30:	a1 04 40 80 00       	mov    0x804004,%eax
  801a35:	8b 40 74             	mov    0x74(%eax),%eax
  801a38:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a3a:	85 db                	test   %ebx,%ebx
  801a3c:	74 0a                	je     801a48 <ipc_recv+0x50>
  801a3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a43:	8b 40 78             	mov    0x78(%eax),%eax
  801a46:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a48:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4d:	8b 40 70             	mov    0x70(%eax),%eax
  801a50:	eb 14                	jmp    801a66 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a52:	85 f6                	test   %esi,%esi
  801a54:	74 06                	je     801a5c <ipc_recv+0x64>
  801a56:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a5c:	85 db                	test   %ebx,%ebx
  801a5e:	74 06                	je     801a66 <ipc_recv+0x6e>
  801a60:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	57                   	push   %edi
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a7c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	75 25                	jne    801aa8 <ipc_send+0x3b>
  801a83:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a88:	eb 1e                	jmp    801aa8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8d:	75 07                	jne    801a96 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a8f:	e8 d9 f0 ff ff       	call   800b6d <sys_yield>
  801a94:	eb 12                	jmp    801aa8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a96:	50                   	push   %eax
  801a97:	68 3c 22 80 00       	push   $0x80223c
  801a9c:	6a 43                	push   $0x43
  801a9e:	68 4f 22 80 00       	push   $0x80224f
  801aa3:	e8 08 ff ff ff       	call   8019b0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	57                   	push   %edi
  801aab:	ff 75 08             	pushl  0x8(%ebp)
  801aae:	e8 b7 f1 ff ff       	call   800c6a <sys_ipc_try_send>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	75 d0                	jne    801a8a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5f                   	pop    %edi
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ac9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801acf:	74 22                	je     801af3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ad6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801add:	89 c2                	mov    %eax,%edx
  801adf:	c1 e2 07             	shl    $0x7,%edx
  801ae2:	29 ca                	sub    %ecx,%edx
  801ae4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aea:	8b 52 50             	mov    0x50(%edx),%edx
  801aed:	39 da                	cmp    %ebx,%edx
  801aef:	75 1d                	jne    801b0e <ipc_find_env+0x4c>
  801af1:	eb 05                	jmp    801af8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801af8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801aff:	c1 e0 07             	shl    $0x7,%eax
  801b02:	29 d0                	sub    %edx,%eax
  801b04:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b09:	8b 40 40             	mov    0x40(%eax),%eax
  801b0c:	eb 0c                	jmp    801b1a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0e:	40                   	inc    %eax
  801b0f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b14:	75 c0                	jne    801ad6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b16:	66 b8 00 00          	mov    $0x0,%ax
}
  801b1a:	5b                   	pop    %ebx
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    
  801b1d:	00 00                	add    %al,(%eax)
	...

00801b20 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	c1 ea 16             	shr    $0x16,%edx
  801b2b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b32:	f6 c2 01             	test   $0x1,%dl
  801b35:	74 1e                	je     801b55 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b37:	c1 e8 0c             	shr    $0xc,%eax
  801b3a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b41:	a8 01                	test   $0x1,%al
  801b43:	74 17                	je     801b5c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b45:	c1 e8 0c             	shr    $0xc,%eax
  801b48:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b4f:	ef 
  801b50:	0f b7 c0             	movzwl %ax,%eax
  801b53:	eb 0c                	jmp    801b61 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5a:	eb 05                	jmp    801b61 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    
	...

00801b64 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	83 ec 10             	sub    $0x10,%esp
  801b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b72:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b7b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 2e                	jne    801bb0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b82:	39 f1                	cmp    %esi,%ecx
  801b84:	77 5a                	ja     801be0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b86:	85 c9                	test   %ecx,%ecx
  801b88:	75 0b                	jne    801b95 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8f:	31 d2                	xor    %edx,%edx
  801b91:	f7 f1                	div    %ecx
  801b93:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b95:	31 d2                	xor    %edx,%edx
  801b97:	89 f0                	mov    %esi,%eax
  801b99:	f7 f1                	div    %ecx
  801b9b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b9d:	89 f8                	mov    %edi,%eax
  801b9f:	f7 f1                	div    %ecx
  801ba1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ba3:	89 f8                	mov    %edi,%eax
  801ba5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    
  801bae:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bb0:	39 f0                	cmp    %esi,%eax
  801bb2:	77 1c                	ja     801bd0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bb4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	75 3c                	jne    801bf8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bbc:	39 f0                	cmp    %esi,%eax
  801bbe:	0f 82 90 00 00 00    	jb     801c54 <__udivdi3+0xf0>
  801bc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bc7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bca:	0f 86 84 00 00 00    	jbe    801c54 <__udivdi3+0xf0>
  801bd0:	31 f6                	xor    %esi,%esi
  801bd2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd4:	89 f8                	mov    %edi,%eax
  801bd6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    
  801bdf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801be0:	89 f2                	mov    %esi,%edx
  801be2:	89 f8                	mov    %edi,%eax
  801be4:	f7 f1                	div    %ecx
  801be6:	89 c7                	mov    %eax,%edi
  801be8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bea:	89 f8                	mov    %edi,%eax
  801bec:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    
  801bf5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bf8:	89 f9                	mov    %edi,%ecx
  801bfa:	d3 e0                	shl    %cl,%eax
  801bfc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bff:	b8 20 00 00 00       	mov    $0x20,%eax
  801c04:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c09:	88 c1                	mov    %al,%cl
  801c0b:	d3 ea                	shr    %cl,%edx
  801c0d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c10:	09 ca                	or     %ecx,%edx
  801c12:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c18:	89 f9                	mov    %edi,%ecx
  801c1a:	d3 e2                	shl    %cl,%edx
  801c1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c1f:	89 f2                	mov    %esi,%edx
  801c21:	88 c1                	mov    %al,%cl
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	89 f9                	mov    %edi,%ecx
  801c2c:	d3 e2                	shl    %cl,%edx
  801c2e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c31:	88 c1                	mov    %al,%cl
  801c33:	d3 ee                	shr    %cl,%esi
  801c35:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c37:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c3a:	89 f0                	mov    %esi,%eax
  801c3c:	89 ca                	mov    %ecx,%edx
  801c3e:	f7 75 ec             	divl   -0x14(%ebp)
  801c41:	89 d1                	mov    %edx,%ecx
  801c43:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c45:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c48:	39 d1                	cmp    %edx,%ecx
  801c4a:	72 28                	jb     801c74 <__udivdi3+0x110>
  801c4c:	74 1a                	je     801c68 <__udivdi3+0x104>
  801c4e:	89 f7                	mov    %esi,%edi
  801c50:	31 f6                	xor    %esi,%esi
  801c52:	eb 80                	jmp    801bd4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c54:	31 f6                	xor    %esi,%esi
  801c56:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    
  801c66:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c6b:	89 f9                	mov    %edi,%ecx
  801c6d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c6f:	39 c2                	cmp    %eax,%edx
  801c71:	73 db                	jae    801c4e <__udivdi3+0xea>
  801c73:	90                   	nop
		{
		  q0--;
  801c74:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c77:	31 f6                	xor    %esi,%esi
  801c79:	e9 56 ff ff ff       	jmp    801bd4 <__udivdi3+0x70>
	...

00801c80 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	83 ec 20             	sub    $0x20,%esp
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c91:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c94:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c97:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c9d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c9f:	85 ff                	test   %edi,%edi
  801ca1:	75 15                	jne    801cb8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ca3:	39 f1                	cmp    %esi,%ecx
  801ca5:	0f 86 99 00 00 00    	jbe    801d44 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cab:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cad:	89 d0                	mov    %edx,%eax
  801caf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cb1:	83 c4 20             	add    $0x20,%esp
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cb8:	39 f7                	cmp    %esi,%edi
  801cba:	0f 87 a4 00 00 00    	ja     801d64 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cc0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cc3:	83 f0 1f             	xor    $0x1f,%eax
  801cc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cc9:	0f 84 a1 00 00 00    	je     801d70 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cd6:	bf 20 00 00 00       	mov    $0x20,%edi
  801cdb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 ea                	shr    %cl,%edx
  801ce5:	09 c2                	or     %eax,%edx
  801ce7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ced:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf0:	d3 e0                	shl    %cl,%eax
  801cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d04:	89 f9                	mov    %edi,%ecx
  801d06:	d3 e8                	shr    %cl,%eax
  801d08:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d0a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d0c:	89 f2                	mov    %esi,%edx
  801d0e:	f7 75 f0             	divl   -0x10(%ebp)
  801d11:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d13:	f7 65 f4             	mull   -0xc(%ebp)
  801d16:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d19:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d1b:	39 d6                	cmp    %edx,%esi
  801d1d:	72 71                	jb     801d90 <__umoddi3+0x110>
  801d1f:	74 7f                	je     801da0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d24:	29 c8                	sub    %ecx,%eax
  801d26:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d28:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	89 f9                	mov    %edi,%ecx
  801d31:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d33:	09 d0                	or     %edx,%eax
  801d35:	89 f2                	mov    %esi,%edx
  801d37:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d3c:	83 c4 20             	add    $0x20,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    
  801d43:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d44:	85 c9                	test   %ecx,%ecx
  801d46:	75 0b                	jne    801d53 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d48:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	f7 f1                	div    %ecx
  801d51:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d53:	89 f0                	mov    %esi,%eax
  801d55:	31 d2                	xor    %edx,%edx
  801d57:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5c:	f7 f1                	div    %ecx
  801d5e:	e9 4a ff ff ff       	jmp    801cad <__umoddi3+0x2d>
  801d63:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d64:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d66:	83 c4 20             	add    $0x20,%esp
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d70:	39 f7                	cmp    %esi,%edi
  801d72:	72 05                	jb     801d79 <__umoddi3+0xf9>
  801d74:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d77:	77 0c                	ja     801d85 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d79:	89 f2                	mov    %esi,%edx
  801d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7e:	29 c8                	sub    %ecx,%eax
  801d80:	19 fa                	sbb    %edi,%edx
  801d82:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d88:	83 c4 20             	add    $0x20,%esp
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    
  801d8f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d90:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d93:	89 c1                	mov    %eax,%ecx
  801d95:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d98:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d9b:	eb 84                	jmp    801d21 <__umoddi3+0xa1>
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da3:	72 eb                	jb     801d90 <__umoddi3+0x110>
  801da5:	89 f2                	mov    %esi,%edx
  801da7:	e9 75 ff ff ff       	jmp    801d21 <__umoddi3+0xa1>
