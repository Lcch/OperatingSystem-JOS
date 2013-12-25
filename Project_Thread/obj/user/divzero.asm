
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	50                   	push   %eax
  800052:	68 e0 1d 80 00       	push   $0x801de0
  800057:	e8 00 01 00 00       	call   80015c <cprintf>
  80005c:	83 c4 10             	add    $0x10,%esp
}
  80005f:	c9                   	leave  
  800060:	c3                   	ret    
  800061:	00 00                	add    %al,(%eax)
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 75 08             	mov    0x8(%ebp),%esi
  80006c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006f:	e8 d5 0a 00 00       	call   800b49 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	89 c2                	mov    %eax,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800085:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x31>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	53                   	push   %ebx
  800099:	56                   	push   %esi
  80009a:	e8 95 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0c 00 00 00       	call   8000b0 <exit>
  8000a4:	83 c4 10             	add    $0x10,%esp
}
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
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
  8000b6:	e8 8f 0e 00 00       	call   800f4a <close_all>
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
  8001c4:	e8 cf 19 00 00       	call   801b98 <__udivdi3>
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
  800200:	e8 af 1a 00 00       	call   801cb4 <__umoddi3>
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	0f be 80 f8 1d 80 00 	movsbl 0x801df8(%eax),%eax
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
  800404:	68 10 1e 80 00       	push   $0x801e10
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
  800454:	c7 45 d0 09 1e 80 00 	movl   $0x801e09,-0x30(%ebp)
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
  800ace:	e8 21 0f 00 00       	call   8019f4 <_panic>

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
} 
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    

00800cf9 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	6a 00                	push   $0x0
  800d05:	6a 00                	push   $0x0
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 11 00 00 00       	mov    $0x11,%eax
  800d14:	e8 77 fd ff ff       	call   800a90 <syscall>
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	b8 10 00 00 00       	mov    $0x10,%eax
  800d38:	e8 53 fd ff ff       	call   800a90 <syscall>
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    
	...

00800d40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	05 00 00 00 30       	add    $0x30000000,%eax
  800d4b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d53:	ff 75 08             	pushl  0x8(%ebp)
  800d56:	e8 e5 ff ff ff       	call   800d40 <fd2num>
  800d5b:	83 c4 04             	add    $0x4,%esp
  800d5e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d63:	c1 e0 0c             	shl    $0xc,%eax
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d6f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d74:	a8 01                	test   $0x1,%al
  800d76:	74 34                	je     800dac <fd_alloc+0x44>
  800d78:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d7d:	a8 01                	test   $0x1,%al
  800d7f:	74 32                	je     800db3 <fd_alloc+0x4b>
  800d81:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d86:	89 c1                	mov    %eax,%ecx
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	c1 ea 16             	shr    $0x16,%edx
  800d8d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d94:	f6 c2 01             	test   $0x1,%dl
  800d97:	74 1f                	je     800db8 <fd_alloc+0x50>
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	c1 ea 0c             	shr    $0xc,%edx
  800d9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da5:	f6 c2 01             	test   $0x1,%dl
  800da8:	75 17                	jne    800dc1 <fd_alloc+0x59>
  800daa:	eb 0c                	jmp    800db8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800dac:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800db1:	eb 05                	jmp    800db8 <fd_alloc+0x50>
  800db3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800db8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb 17                	jmp    800dd8 <fd_alloc+0x70>
  800dc1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dcb:	75 b9                	jne    800d86 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dcd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800dd3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de1:	83 f8 1f             	cmp    $0x1f,%eax
  800de4:	77 36                	ja     800e1c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de6:	05 00 00 0d 00       	add    $0xd0000,%eax
  800deb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	c1 ea 16             	shr    $0x16,%edx
  800df3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfa:	f6 c2 01             	test   $0x1,%dl
  800dfd:	74 24                	je     800e23 <fd_lookup+0x48>
  800dff:	89 c2                	mov    %eax,%edx
  800e01:	c1 ea 0c             	shr    $0xc,%edx
  800e04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0b:	f6 c2 01             	test   $0x1,%dl
  800e0e:	74 1a                	je     800e2a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e13:	89 02                	mov    %eax,(%edx)
	return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	eb 13                	jmp    800e2f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e21:	eb 0c                	jmp    800e2f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e28:	eb 05                	jmp    800e2f <fd_lookup+0x54>
  800e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	53                   	push   %ebx
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e3e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e44:	74 0d                	je     800e53 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 14                	jmp    800e61 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e4d:	39 0a                	cmp    %ecx,(%edx)
  800e4f:	75 10                	jne    800e61 <dev_lookup+0x30>
  800e51:	eb 05                	jmp    800e58 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e53:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e58:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	eb 31                	jmp    800e92 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e61:	40                   	inc    %eax
  800e62:	8b 14 85 a8 21 80 00 	mov    0x8021a8(,%eax,4),%edx
  800e69:	85 d2                	test   %edx,%edx
  800e6b:	75 e0                	jne    800e4d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e72:	8b 40 48             	mov    0x48(%eax),%eax
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	51                   	push   %ecx
  800e79:	50                   	push   %eax
  800e7a:	68 2c 21 80 00       	push   $0x80212c
  800e7f:	e8 d8 f2 ff ff       	call   80015c <cprintf>
	*dev = 0;
  800e84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 20             	sub    $0x20,%esp
  800e9f:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea2:	8a 45 0c             	mov    0xc(%ebp),%al
  800ea5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea8:	56                   	push   %esi
  800ea9:	e8 92 fe ff ff       	call   800d40 <fd2num>
  800eae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800eb1:	89 14 24             	mov    %edx,(%esp)
  800eb4:	50                   	push   %eax
  800eb5:	e8 21 ff ff ff       	call   800ddb <fd_lookup>
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	83 c4 08             	add    $0x8,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	78 05                	js     800ec8 <fd_close+0x31>
	    || fd != fd2)
  800ec3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec6:	74 0d                	je     800ed5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ec8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ecc:	75 48                	jne    800f16 <fd_close+0x7f>
  800ece:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed3:	eb 41                	jmp    800f16 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800edb:	50                   	push   %eax
  800edc:	ff 36                	pushl  (%esi)
  800ede:	e8 4e ff ff ff       	call   800e31 <dev_lookup>
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 1c                	js     800f08 <fd_close+0x71>
		if (dev->dev_close)
  800eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eef:	8b 40 10             	mov    0x10(%eax),%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	74 0d                	je     800f03 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	56                   	push   %esi
  800efa:	ff d0                	call   *%eax
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	eb 05                	jmp    800f08 <fd_close+0x71>
		else
			r = 0;
  800f03:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	56                   	push   %esi
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 cb fc ff ff       	call   800bde <sys_page_unmap>
	return r;
  800f13:	83 c4 10             	add    $0x10,%esp
}
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 75 08             	pushl  0x8(%ebp)
  800f2c:	e8 aa fe ff ff       	call   800ddb <fd_lookup>
  800f31:	83 c4 08             	add    $0x8,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 10                	js     800f48 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	6a 01                	push   $0x1
  800f3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f40:	e8 52 ff ff ff       	call   800e97 <fd_close>
  800f45:	83 c4 10             	add    $0x10,%esp
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <close_all>:

void
close_all(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f51:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	53                   	push   %ebx
  800f5a:	e8 c0 ff ff ff       	call   800f1f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5f:	43                   	inc    %ebx
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	83 fb 20             	cmp    $0x20,%ebx
  800f66:	75 ee                	jne    800f56 <close_all+0xc>
		close(i);
}
  800f68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 2c             	sub    $0x2c,%esp
  800f76:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f79:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7c:	50                   	push   %eax
  800f7d:	ff 75 08             	pushl  0x8(%ebp)
  800f80:	e8 56 fe ff ff       	call   800ddb <fd_lookup>
  800f85:	89 c3                	mov    %eax,%ebx
  800f87:	83 c4 08             	add    $0x8,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	0f 88 c0 00 00 00    	js     801052 <dup+0xe5>
		return r;
	close(newfdnum);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	57                   	push   %edi
  800f96:	e8 84 ff ff ff       	call   800f1f <close>

	newfd = INDEX2FD(newfdnum);
  800f9b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fa1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fa4:	83 c4 04             	add    $0x4,%esp
  800fa7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800faa:	e8 a1 fd ff ff       	call   800d50 <fd2data>
  800faf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb1:	89 34 24             	mov    %esi,(%esp)
  800fb4:	e8 97 fd ff ff       	call   800d50 <fd2data>
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 16             	shr    $0x16,%eax
  800fc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	74 37                	je     801006 <dup+0x99>
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	c1 e8 0c             	shr    $0xc,%eax
  800fd4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdb:	f6 c2 01             	test   $0x1,%dl
  800fde:	74 26                	je     801006 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	25 07 0e 00 00       	and    $0xe07,%eax
  800fef:	50                   	push   %eax
  800ff0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff3:	6a 00                	push   $0x0
  800ff5:	53                   	push   %ebx
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 bb fb ff ff       	call   800bb8 <sys_page_map>
  800ffd:	89 c3                	mov    %eax,%ebx
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	78 2d                	js     801033 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801006:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801009:	89 c2                	mov    %eax,%edx
  80100b:	c1 ea 0c             	shr    $0xc,%edx
  80100e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80101e:	52                   	push   %edx
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	50                   	push   %eax
  801023:	6a 00                	push   $0x0
  801025:	e8 8e fb ff ff       	call   800bb8 <sys_page_map>
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	79 1d                	jns    801050 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	56                   	push   %esi
  801037:	6a 00                	push   $0x0
  801039:	e8 a0 fb ff ff       	call   800bde <sys_page_unmap>
	sys_page_unmap(0, nva);
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	ff 75 d4             	pushl  -0x2c(%ebp)
  801044:	6a 00                	push   $0x0
  801046:	e8 93 fb ff ff       	call   800bde <sys_page_unmap>
	return r;
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	eb 02                	jmp    801052 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801050:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801052:	89 d8                	mov    %ebx,%eax
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 14             	sub    $0x14,%esp
  801063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801066:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	53                   	push   %ebx
  80106b:	e8 6b fd ff ff       	call   800ddb <fd_lookup>
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 67                	js     8010de <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801081:	ff 30                	pushl  (%eax)
  801083:	e8 a9 fd ff ff       	call   800e31 <dev_lookup>
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 4f                	js     8010de <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80108f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801092:	8b 50 08             	mov    0x8(%eax),%edx
  801095:	83 e2 03             	and    $0x3,%edx
  801098:	83 fa 01             	cmp    $0x1,%edx
  80109b:	75 21                	jne    8010be <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80109d:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a2:	8b 40 48             	mov    0x48(%eax),%eax
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	50                   	push   %eax
  8010aa:	68 6d 21 80 00       	push   $0x80216d
  8010af:	e8 a8 f0 ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010bc:	eb 20                	jmp    8010de <read+0x82>
	}
	if (!dev->dev_read)
  8010be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010c1:	8b 52 08             	mov    0x8(%edx),%edx
  8010c4:	85 d2                	test   %edx,%edx
  8010c6:	74 11                	je     8010d9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	ff 75 10             	pushl  0x10(%ebp)
  8010ce:	ff 75 0c             	pushl  0xc(%ebp)
  8010d1:	50                   	push   %eax
  8010d2:	ff d2                	call   *%edx
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	eb 05                	jmp    8010de <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f2:	85 f6                	test   %esi,%esi
  8010f4:	74 31                	je     801127 <readn+0x44>
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	89 f2                	mov    %esi,%edx
  801105:	29 c2                	sub    %eax,%edx
  801107:	52                   	push   %edx
  801108:	03 45 0c             	add    0xc(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	57                   	push   %edi
  80110d:	e8 4a ff ff ff       	call   80105c <read>
		if (m < 0)
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 17                	js     801130 <readn+0x4d>
			return m;
		if (m == 0)
  801119:	85 c0                	test   %eax,%eax
  80111b:	74 11                	je     80112e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80111d:	01 c3                	add    %eax,%ebx
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	39 f3                	cmp    %esi,%ebx
  801123:	72 db                	jb     801100 <readn+0x1d>
  801125:	eb 09                	jmp    801130 <readn+0x4d>
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 02                	jmp    801130 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80112e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	53                   	push   %ebx
  80113c:	83 ec 14             	sub    $0x14,%esp
  80113f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	53                   	push   %ebx
  801147:	e8 8f fc ff ff       	call   800ddb <fd_lookup>
  80114c:	83 c4 08             	add    $0x8,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 62                	js     8011b5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115d:	ff 30                	pushl  (%eax)
  80115f:	e8 cd fc ff ff       	call   800e31 <dev_lookup>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 4a                	js     8011b5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801172:	75 21                	jne    801195 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801174:	a1 08 40 80 00       	mov    0x804008,%eax
  801179:	8b 40 48             	mov    0x48(%eax),%eax
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	53                   	push   %ebx
  801180:	50                   	push   %eax
  801181:	68 89 21 80 00       	push   $0x802189
  801186:	e8 d1 ef ff ff       	call   80015c <cprintf>
		return -E_INVAL;
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801193:	eb 20                	jmp    8011b5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801195:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801198:	8b 52 0c             	mov    0xc(%edx),%edx
  80119b:	85 d2                	test   %edx,%edx
  80119d:	74 11                	je     8011b0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	ff 75 10             	pushl  0x10(%ebp)
  8011a5:	ff 75 0c             	pushl  0xc(%ebp)
  8011a8:	50                   	push   %eax
  8011a9:	ff d2                	call   *%edx
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	eb 05                	jmp    8011b5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 0f fc ff ff       	call   800ddb <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 0e                	js     8011e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 14             	sub    $0x14,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	e8 e4 fb ff ff       	call   800ddb <fd_lookup>
  8011f7:	83 c4 08             	add    $0x8,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 5f                	js     80125d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801208:	ff 30                	pushl  (%eax)
  80120a:	e8 22 fc ff ff       	call   800e31 <dev_lookup>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 47                	js     80125d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121d:	75 21                	jne    801240 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801224:	8b 40 48             	mov    0x48(%eax),%eax
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	53                   	push   %ebx
  80122b:	50                   	push   %eax
  80122c:	68 4c 21 80 00       	push   $0x80214c
  801231:	e8 26 ef ff ff       	call   80015c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123e:	eb 1d                	jmp    80125d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801240:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801243:	8b 52 18             	mov    0x18(%edx),%edx
  801246:	85 d2                	test   %edx,%edx
  801248:	74 0e                	je     801258 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	ff 75 0c             	pushl  0xc(%ebp)
  801250:	50                   	push   %eax
  801251:	ff d2                	call   *%edx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	eb 05                	jmp    80125d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801258:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	53                   	push   %ebx
  801266:	83 ec 14             	sub    $0x14,%esp
  801269:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	ff 75 08             	pushl  0x8(%ebp)
  801273:	e8 63 fb ff ff       	call   800ddb <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 52                	js     8012d1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 a1 fb ff ff       	call   800e31 <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 3a                	js     8012d1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801297:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129e:	74 2c                	je     8012cc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012aa:	00 00 00 
	stat->st_isdir = 0;
  8012ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b4:	00 00 00 
	stat->st_dev = dev;
  8012b7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c4:	ff 50 14             	call   *0x14(%eax)
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	eb 05                	jmp    8012d1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	56                   	push   %esi
  8012da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	6a 00                	push   $0x0
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 78 01 00 00       	call   801460 <open>
  8012e8:	89 c3                	mov    %eax,%ebx
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 1b                	js     80130c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	ff 75 0c             	pushl  0xc(%ebp)
  8012f7:	50                   	push   %eax
  8012f8:	e8 65 ff ff ff       	call   801262 <fstat>
  8012fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ff:	89 1c 24             	mov    %ebx,(%esp)
  801302:	e8 18 fc ff ff       	call   800f1f <close>
	return r;
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	89 f3                	mov    %esi,%ebx
}
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	c9                   	leave  
  801314:	c3                   	ret    
  801315:	00 00                	add    %al,(%eax)
	...

00801318 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	56                   	push   %esi
  80131c:	53                   	push   %ebx
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801321:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801328:	75 12                	jne    80133c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	6a 01                	push   $0x1
  80132f:	e8 d2 07 00 00       	call   801b06 <ipc_find_env>
  801334:	a3 00 40 80 00       	mov    %eax,0x804000
  801339:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133c:	6a 07                	push   $0x7
  80133e:	68 00 50 80 00       	push   $0x805000
  801343:	53                   	push   %ebx
  801344:	ff 35 00 40 80 00    	pushl  0x804000
  80134a:	e8 62 07 00 00       	call   801ab1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80134f:	83 c4 0c             	add    $0xc,%esp
  801352:	6a 00                	push   $0x0
  801354:	56                   	push   %esi
  801355:	6a 00                	push   $0x0
  801357:	e8 e0 06 00 00       	call   801a3c <ipc_recv>
}
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80136d:	8b 45 08             	mov    0x8(%ebp),%eax
  801370:	8b 40 0c             	mov    0xc(%eax),%eax
  801373:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801378:	ba 00 00 00 00       	mov    $0x0,%edx
  80137d:	b8 05 00 00 00       	mov    $0x5,%eax
  801382:	e8 91 ff ff ff       	call   801318 <fsipc>
  801387:	85 c0                	test   %eax,%eax
  801389:	78 2c                	js     8013b7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	68 00 50 80 00       	push   $0x805000
  801393:	53                   	push   %ebx
  801394:	e8 79 f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801399:	a1 80 50 80 00       	mov    0x805080,%eax
  80139e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d7:	e8 3c ff ff ff       	call   801318 <fsipc>
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801401:	e8 12 ff ff ff       	call   801318 <fsipc>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 4b                	js     801457 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80140c:	39 c6                	cmp    %eax,%esi
  80140e:	73 16                	jae    801426 <devfile_read+0x48>
  801410:	68 b8 21 80 00       	push   $0x8021b8
  801415:	68 bf 21 80 00       	push   $0x8021bf
  80141a:	6a 7d                	push   $0x7d
  80141c:	68 d4 21 80 00       	push   $0x8021d4
  801421:	e8 ce 05 00 00       	call   8019f4 <_panic>
	assert(r <= PGSIZE);
  801426:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80142b:	7e 16                	jle    801443 <devfile_read+0x65>
  80142d:	68 df 21 80 00       	push   $0x8021df
  801432:	68 bf 21 80 00       	push   $0x8021bf
  801437:	6a 7e                	push   $0x7e
  801439:	68 d4 21 80 00       	push   $0x8021d4
  80143e:	e8 b1 05 00 00       	call   8019f4 <_panic>
	memmove(buf, &fsipcbuf, r);
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	50                   	push   %eax
  801447:	68 00 50 80 00       	push   $0x805000
  80144c:	ff 75 0c             	pushl  0xc(%ebp)
  80144f:	e8 7f f4 ff ff       	call   8008d3 <memmove>
	return r;
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	89 d8                	mov    %ebx,%eax
  801459:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	56                   	push   %esi
  801464:	53                   	push   %ebx
  801465:	83 ec 1c             	sub    $0x1c,%esp
  801468:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80146b:	56                   	push   %esi
  80146c:	e8 4f f2 ff ff       	call   8006c0 <strlen>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801479:	7f 65                	jg     8014e0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147b:	83 ec 0c             	sub    $0xc,%esp
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	e8 e1 f8 ff ff       	call   800d68 <fd_alloc>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 55                	js     8014e5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	56                   	push   %esi
  801494:	68 00 50 80 00       	push   $0x805000
  801499:	e8 74 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ae:	e8 65 fe ff ff       	call   801318 <fsipc>
  8014b3:	89 c3                	mov    %eax,%ebx
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	79 12                	jns    8014ce <open+0x6e>
		fd_close(fd, 0);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	6a 00                	push   $0x0
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 ce f9 ff ff       	call   800e97 <fd_close>
		return r;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb 17                	jmp    8014e5 <open+0x85>
	}

	return fd2num(fd);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d4:	e8 67 f8 ff ff       	call   800d40 <fd2num>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 05                	jmp    8014e5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e5:	89 d8                	mov    %ebx,%eax
  8014e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    
	...

008014f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	ff 75 08             	pushl  0x8(%ebp)
  8014fe:	e8 4d f8 ff ff       	call   800d50 <fd2data>
  801503:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	68 eb 21 80 00       	push   $0x8021eb
  80150d:	56                   	push   %esi
  80150e:	e8 ff f1 ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801513:	8b 43 04             	mov    0x4(%ebx),%eax
  801516:	2b 03                	sub    (%ebx),%eax
  801518:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80151e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801525:	00 00 00 
	stat->st_dev = &devpipe;
  801528:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80152f:	30 80 00 
	return 0;
}
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
  801537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801548:	53                   	push   %ebx
  801549:	6a 00                	push   $0x0
  80154b:	e8 8e f6 ff ff       	call   800bde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801550:	89 1c 24             	mov    %ebx,(%esp)
  801553:	e8 f8 f7 ff ff       	call   800d50 <fd2data>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	50                   	push   %eax
  80155c:	6a 00                	push   $0x0
  80155e:	e8 7b f6 ff ff       	call   800bde <sys_page_unmap>
}
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	57                   	push   %edi
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
  80156e:	83 ec 1c             	sub    $0x1c,%esp
  801571:	89 c7                	mov    %eax,%edi
  801573:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801576:	a1 08 40 80 00       	mov    0x804008,%eax
  80157b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	57                   	push   %edi
  801582:	e8 cd 05 00 00       	call   801b54 <pageref>
  801587:	89 c6                	mov    %eax,%esi
  801589:	83 c4 04             	add    $0x4,%esp
  80158c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158f:	e8 c0 05 00 00       	call   801b54 <pageref>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	39 c6                	cmp    %eax,%esi
  801599:	0f 94 c0             	sete   %al
  80159c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80159f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015a5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a8:	39 cb                	cmp    %ecx,%ebx
  8015aa:	75 08                	jne    8015b4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8015b4:	83 f8 01             	cmp    $0x1,%eax
  8015b7:	75 bd                	jne    801576 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b9:	8b 42 58             	mov    0x58(%edx),%eax
  8015bc:	6a 01                	push   $0x1
  8015be:	50                   	push   %eax
  8015bf:	53                   	push   %ebx
  8015c0:	68 f2 21 80 00       	push   $0x8021f2
  8015c5:	e8 92 eb ff ff       	call   80015c <cprintf>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb a7                	jmp    801576 <_pipeisclosed+0xe>

008015cf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 28             	sub    $0x28,%esp
  8015d8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015db:	56                   	push   %esi
  8015dc:	e8 6f f7 ff ff       	call   800d50 <fd2data>
  8015e1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015ea:	75 4a                	jne    801636 <devpipe_write+0x67>
  8015ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f1:	eb 56                	jmp    801649 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f3:	89 da                	mov    %ebx,%edx
  8015f5:	89 f0                	mov    %esi,%eax
  8015f7:	e8 6c ff ff ff       	call   801568 <_pipeisclosed>
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	75 4d                	jne    80164d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801600:	e8 68 f5 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801605:	8b 43 04             	mov    0x4(%ebx),%eax
  801608:	8b 13                	mov    (%ebx),%edx
  80160a:	83 c2 20             	add    $0x20,%edx
  80160d:	39 d0                	cmp    %edx,%eax
  80160f:	73 e2                	jae    8015f3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801611:	89 c2                	mov    %eax,%edx
  801613:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801619:	79 05                	jns    801620 <devpipe_write+0x51>
  80161b:	4a                   	dec    %edx
  80161c:	83 ca e0             	or     $0xffffffe0,%edx
  80161f:	42                   	inc    %edx
  801620:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801623:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801626:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80162a:	40                   	inc    %eax
  80162b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162e:	47                   	inc    %edi
  80162f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801632:	77 07                	ja     80163b <devpipe_write+0x6c>
  801634:	eb 13                	jmp    801649 <devpipe_write+0x7a>
  801636:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80163b:	8b 43 04             	mov    0x4(%ebx),%eax
  80163e:	8b 13                	mov    (%ebx),%edx
  801640:	83 c2 20             	add    $0x20,%edx
  801643:	39 d0                	cmp    %edx,%eax
  801645:	73 ac                	jae    8015f3 <devpipe_write+0x24>
  801647:	eb c8                	jmp    801611 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801649:	89 f8                	mov    %edi,%eax
  80164b:	eb 05                	jmp    801652 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80164d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5f                   	pop    %edi
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 18             	sub    $0x18,%esp
  801663:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801666:	57                   	push   %edi
  801667:	e8 e4 f6 ff ff       	call   800d50 <fd2data>
  80166c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801675:	75 44                	jne    8016bb <devpipe_read+0x61>
  801677:	be 00 00 00 00       	mov    $0x0,%esi
  80167c:	eb 4f                	jmp    8016cd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80167e:	89 f0                	mov    %esi,%eax
  801680:	eb 54                	jmp    8016d6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801682:	89 da                	mov    %ebx,%edx
  801684:	89 f8                	mov    %edi,%eax
  801686:	e8 dd fe ff ff       	call   801568 <_pipeisclosed>
  80168b:	85 c0                	test   %eax,%eax
  80168d:	75 42                	jne    8016d1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80168f:	e8 d9 f4 ff ff       	call   800b6d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801694:	8b 03                	mov    (%ebx),%eax
  801696:	3b 43 04             	cmp    0x4(%ebx),%eax
  801699:	74 e7                	je     801682 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80169b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016a0:	79 05                	jns    8016a7 <devpipe_read+0x4d>
  8016a2:	48                   	dec    %eax
  8016a3:	83 c8 e0             	or     $0xffffffe0,%eax
  8016a6:	40                   	inc    %eax
  8016a7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8016ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ae:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8016b1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b3:	46                   	inc    %esi
  8016b4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8016b7:	77 07                	ja     8016c0 <devpipe_read+0x66>
  8016b9:	eb 12                	jmp    8016cd <devpipe_read+0x73>
  8016bb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8016c0:	8b 03                	mov    (%ebx),%eax
  8016c2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016c5:	75 d4                	jne    80169b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016c7:	85 f6                	test   %esi,%esi
  8016c9:	75 b3                	jne    80167e <devpipe_read+0x24>
  8016cb:	eb b5                	jmp    801682 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016cd:	89 f0                	mov    %esi,%eax
  8016cf:	eb 05                	jmp    8016d6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5e                   	pop    %esi
  8016db:	5f                   	pop    %edi
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	57                   	push   %edi
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 28             	sub    $0x28,%esp
  8016e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 75 f6 ff ff       	call   800d68 <fd_alloc>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	0f 88 24 01 00 00    	js     801824 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	68 07 04 00 00       	push   $0x407
  801708:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170b:	6a 00                	push   $0x0
  80170d:	e8 82 f4 ff ff       	call   800b94 <sys_page_alloc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	0f 88 05 01 00 00    	js     801824 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	e8 3d f6 ff ff       	call   800d68 <fd_alloc>
  80172b:	89 c3                	mov    %eax,%ebx
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	0f 88 dc 00 00 00    	js     801814 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	68 07 04 00 00       	push   $0x407
  801740:	ff 75 e0             	pushl  -0x20(%ebp)
  801743:	6a 00                	push   $0x0
  801745:	e8 4a f4 ff ff       	call   800b94 <sys_page_alloc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 88 bd 00 00 00    	js     801814 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175d:	e8 ee f5 ff ff       	call   800d50 <fd2data>
  801762:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801764:	83 c4 0c             	add    $0xc,%esp
  801767:	68 07 04 00 00       	push   $0x407
  80176c:	50                   	push   %eax
  80176d:	6a 00                	push   $0x0
  80176f:	e8 20 f4 ff ff       	call   800b94 <sys_page_alloc>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 83 00 00 00    	js     801804 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	ff 75 e0             	pushl  -0x20(%ebp)
  801787:	e8 c4 f5 ff ff       	call   800d50 <fd2data>
  80178c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801793:	50                   	push   %eax
  801794:	6a 00                	push   $0x0
  801796:	56                   	push   %esi
  801797:	6a 00                	push   $0x0
  801799:	e8 1a f4 ff ff       	call   800bb8 <sys_page_map>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 20             	add    $0x20,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 4f                	js     8017f6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017a7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017bc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017d7:	e8 64 f5 ff ff       	call   800d40 <fd2num>
  8017dc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8017de:	83 c4 04             	add    $0x4,%esp
  8017e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8017e4:	e8 57 f5 ff ff       	call   800d40 <fd2num>
  8017e9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f4:	eb 2e                	jmp    801824 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	56                   	push   %esi
  8017fa:	6a 00                	push   $0x0
  8017fc:	e8 dd f3 ff ff       	call   800bde <sys_page_unmap>
  801801:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	ff 75 e0             	pushl  -0x20(%ebp)
  80180a:	6a 00                	push   $0x0
  80180c:	e8 cd f3 ff ff       	call   800bde <sys_page_unmap>
  801811:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	ff 75 e4             	pushl  -0x1c(%ebp)
  80181a:	6a 00                	push   $0x0
  80181c:	e8 bd f3 ff ff       	call   800bde <sys_page_unmap>
  801821:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801824:	89 d8                	mov    %ebx,%eax
  801826:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5f                   	pop    %edi
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801834:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801837:	50                   	push   %eax
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 9b f5 ff ff       	call   800ddb <fd_lookup>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 18                	js     80185f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	e8 fe f4 ff ff       	call   800d50 <fd2data>
	return _pipeisclosed(fd, p);
  801852:	89 c2                	mov    %eax,%edx
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	e8 0c fd ff ff       	call   801568 <_pipeisclosed>
  80185c:	83 c4 10             	add    $0x10,%esp
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    
  801861:	00 00                	add    %al,(%eax)
	...

00801864 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801874:	68 0a 22 80 00       	push   $0x80220a
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	e8 91 ee ff ff       	call   800712 <strcpy>
	return 0;
}
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	57                   	push   %edi
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801894:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801898:	74 45                	je     8018df <devcons_write+0x57>
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
  80189f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018ad:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8018af:	83 fb 7f             	cmp    $0x7f,%ebx
  8018b2:	76 05                	jbe    8018b9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018b4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018b9:	83 ec 04             	sub    $0x4,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	03 45 0c             	add    0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	57                   	push   %edi
  8018c2:	e8 0c f0 ff ff       	call   8008d3 <memmove>
		sys_cputs(buf, m);
  8018c7:	83 c4 08             	add    $0x8,%esp
  8018ca:	53                   	push   %ebx
  8018cb:	57                   	push   %edi
  8018cc:	e8 0c f2 ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d1:	01 de                	add    %ebx,%esi
  8018d3:	89 f0                	mov    %esi,%eax
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018db:	72 cd                	jb     8018aa <devcons_write+0x22>
  8018dd:	eb 05                	jmp    8018e4 <devcons_write+0x5c>
  8018df:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018e4:	89 f0                	mov    %esi,%eax
  8018e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5e                   	pop    %esi
  8018eb:	5f                   	pop    %edi
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f8:	75 07                	jne    801901 <devcons_read+0x13>
  8018fa:	eb 25                	jmp    801921 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018fc:	e8 6c f2 ff ff       	call   800b6d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801901:	e8 fd f1 ff ff       	call   800b03 <sys_cgetc>
  801906:	85 c0                	test   %eax,%eax
  801908:	74 f2                	je     8018fc <devcons_read+0xe>
  80190a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 1d                	js     80192d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801910:	83 f8 04             	cmp    $0x4,%eax
  801913:	74 13                	je     801928 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	88 10                	mov    %dl,(%eax)
	return 1;
  80191a:	b8 01 00 00 00       	mov    $0x1,%eax
  80191f:	eb 0c                	jmp    80192d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
  801926:	eb 05                	jmp    80192d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80193b:	6a 01                	push   $0x1
  80193d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801940:	50                   	push   %eax
  801941:	e8 97 f1 ff ff       	call   800add <sys_cputs>
  801946:	83 c4 10             	add    $0x10,%esp
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <getchar>:

int
getchar(void)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801951:	6a 01                	push   $0x1
  801953:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	6a 00                	push   $0x0
  801959:	e8 fe f6 ff ff       	call   80105c <read>
	if (r < 0)
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	78 0f                	js     801974 <getchar+0x29>
		return r;
	if (r < 1)
  801965:	85 c0                	test   %eax,%eax
  801967:	7e 06                	jle    80196f <getchar+0x24>
		return -E_EOF;
	return c;
  801969:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80196d:	eb 05                	jmp    801974 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80196f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	ff 75 08             	pushl  0x8(%ebp)
  801983:	e8 53 f4 ff ff       	call   800ddb <fd_lookup>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 11                	js     8019a0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801998:	39 10                	cmp    %edx,(%eax)
  80199a:	0f 94 c0             	sete   %al
  80199d:	0f b6 c0             	movzbl %al,%eax
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <opencons>:

int
opencons(void)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	e8 b7 f3 ff ff       	call   800d68 <fd_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 3a                	js     8019f2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	68 07 04 00 00       	push   $0x407
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 ca f1 ff ff       	call   800b94 <sys_page_alloc>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 21                	js     8019f2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019da:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	50                   	push   %eax
  8019ea:	e8 51 f3 ff ff       	call   800d40 <fd2num>
  8019ef:	83 c4 10             	add    $0x10,%esp
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019f9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019fc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801a02:	e8 42 f1 ff ff       	call   800b49 <sys_getenvid>
  801a07:	83 ec 0c             	sub    $0xc,%esp
  801a0a:	ff 75 0c             	pushl  0xc(%ebp)
  801a0d:	ff 75 08             	pushl  0x8(%ebp)
  801a10:	53                   	push   %ebx
  801a11:	50                   	push   %eax
  801a12:	68 18 22 80 00       	push   $0x802218
  801a17:	e8 40 e7 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a1c:	83 c4 18             	add    $0x18,%esp
  801a1f:	56                   	push   %esi
  801a20:	ff 75 10             	pushl  0x10(%ebp)
  801a23:	e8 e3 e6 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  801a28:	c7 04 24 ec 1d 80 00 	movl   $0x801dec,(%esp)
  801a2f:	e8 28 e7 ff ff       	call   80015c <cprintf>
  801a34:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a37:	cc                   	int3   
  801a38:	eb fd                	jmp    801a37 <_panic+0x43>
	...

00801a3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	8b 75 08             	mov    0x8(%ebp),%esi
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	74 0e                	je     801a5c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	50                   	push   %eax
  801a52:	e8 38 f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	eb 10                	jmp    801a6c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	68 00 00 c0 ee       	push   $0xeec00000
  801a64:	e8 26 f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a69:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	75 26                	jne    801a96 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a70:	85 f6                	test   %esi,%esi
  801a72:	74 0a                	je     801a7e <ipc_recv+0x42>
  801a74:	a1 08 40 80 00       	mov    0x804008,%eax
  801a79:	8b 40 74             	mov    0x74(%eax),%eax
  801a7c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a7e:	85 db                	test   %ebx,%ebx
  801a80:	74 0a                	je     801a8c <ipc_recv+0x50>
  801a82:	a1 08 40 80 00       	mov    0x804008,%eax
  801a87:	8b 40 78             	mov    0x78(%eax),%eax
  801a8a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a91:	8b 40 70             	mov    0x70(%eax),%eax
  801a94:	eb 14                	jmp    801aaa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a96:	85 f6                	test   %esi,%esi
  801a98:	74 06                	je     801aa0 <ipc_recv+0x64>
  801a9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801aa0:	85 db                	test   %ebx,%ebx
  801aa2:	74 06                	je     801aaa <ipc_recv+0x6e>
  801aa4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	57                   	push   %edi
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ac0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ac3:	85 db                	test   %ebx,%ebx
  801ac5:	75 25                	jne    801aec <ipc_send+0x3b>
  801ac7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801acc:	eb 1e                	jmp    801aec <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ace:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad1:	75 07                	jne    801ada <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ad3:	e8 95 f0 ff ff       	call   800b6d <sys_yield>
  801ad8:	eb 12                	jmp    801aec <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ada:	50                   	push   %eax
  801adb:	68 3c 22 80 00       	push   $0x80223c
  801ae0:	6a 43                	push   $0x43
  801ae2:	68 4f 22 80 00       	push   $0x80224f
  801ae7:	e8 08 ff ff ff       	call   8019f4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	57                   	push   %edi
  801aef:	ff 75 08             	pushl  0x8(%ebp)
  801af2:	e8 73 f1 ff ff       	call   800c6a <sys_ipc_try_send>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 d0                	jne    801ace <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b0c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801b12:	74 1a                	je     801b2e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b14:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b19:	89 c2                	mov    %eax,%edx
  801b1b:	c1 e2 07             	shl    $0x7,%edx
  801b1e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b25:	8b 52 50             	mov    0x50(%edx),%edx
  801b28:	39 ca                	cmp    %ecx,%edx
  801b2a:	75 18                	jne    801b44 <ipc_find_env+0x3e>
  801b2c:	eb 05                	jmp    801b33 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b33:	89 c2                	mov    %eax,%edx
  801b35:	c1 e2 07             	shl    $0x7,%edx
  801b38:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b3f:	8b 40 40             	mov    0x40(%eax),%eax
  801b42:	eb 0c                	jmp    801b50 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b44:	40                   	inc    %eax
  801b45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4a:	75 cd                	jne    801b19 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4c:	66 b8 00 00          	mov    $0x0,%ax
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    
	...

00801b54 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5a:	89 c2                	mov    %eax,%edx
  801b5c:	c1 ea 16             	shr    $0x16,%edx
  801b5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b66:	f6 c2 01             	test   $0x1,%dl
  801b69:	74 1e                	je     801b89 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6b:	c1 e8 0c             	shr    $0xc,%eax
  801b6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b75:	a8 01                	test   $0x1,%al
  801b77:	74 17                	je     801b90 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b79:	c1 e8 0c             	shr    $0xc,%eax
  801b7c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b83:	ef 
  801b84:	0f b7 c0             	movzwl %ax,%eax
  801b87:	eb 0c                	jmp    801b95 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	eb 05                	jmp    801b95 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    
	...

00801b98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	57                   	push   %edi
  801b9c:	56                   	push   %esi
  801b9d:	83 ec 10             	sub    $0x10,%esp
  801ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ba3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ba6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ba9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801baf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	75 2e                	jne    801be4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bb6:	39 f1                	cmp    %esi,%ecx
  801bb8:	77 5a                	ja     801c14 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bba:	85 c9                	test   %ecx,%ecx
  801bbc:	75 0b                	jne    801bc9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc3:	31 d2                	xor    %edx,%edx
  801bc5:	f7 f1                	div    %ecx
  801bc7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bc9:	31 d2                	xor    %edx,%edx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	f7 f1                	div    %ecx
  801bcf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bd1:	89 f8                	mov    %edi,%eax
  801bd3:	f7 f1                	div    %ecx
  801bd5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd7:	89 f8                	mov    %edi,%eax
  801bd9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    
  801be2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801be4:	39 f0                	cmp    %esi,%eax
  801be6:	77 1c                	ja     801c04 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801be8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801beb:	83 f7 1f             	xor    $0x1f,%edi
  801bee:	75 3c                	jne    801c2c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bf0:	39 f0                	cmp    %esi,%eax
  801bf2:	0f 82 90 00 00 00    	jb     801c88 <__udivdi3+0xf0>
  801bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bfb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bfe:	0f 86 84 00 00 00    	jbe    801c88 <__udivdi3+0xf0>
  801c04:	31 f6                	xor    %esi,%esi
  801c06:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c08:	89 f8                	mov    %edi,%eax
  801c0a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    
  801c13:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c14:	89 f2                	mov    %esi,%edx
  801c16:	89 f8                	mov    %edi,%eax
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c7                	mov    %eax,%edi
  801c1c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c1e:	89 f8                	mov    %edi,%eax
  801c20:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    
  801c29:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c2c:	89 f9                	mov    %edi,%ecx
  801c2e:	d3 e0                	shl    %cl,%eax
  801c30:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c33:	b8 20 00 00 00       	mov    $0x20,%eax
  801c38:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3d:	88 c1                	mov    %al,%cl
  801c3f:	d3 ea                	shr    %cl,%edx
  801c41:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c44:	09 ca                	or     %ecx,%edx
  801c46:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4c:	89 f9                	mov    %edi,%ecx
  801c4e:	d3 e2                	shl    %cl,%edx
  801c50:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c53:	89 f2                	mov    %esi,%edx
  801c55:	88 c1                	mov    %al,%cl
  801c57:	d3 ea                	shr    %cl,%edx
  801c59:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	89 f9                	mov    %edi,%ecx
  801c60:	d3 e2                	shl    %cl,%edx
  801c62:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c65:	88 c1                	mov    %al,%cl
  801c67:	d3 ee                	shr    %cl,%esi
  801c69:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c6b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c6e:	89 f0                	mov    %esi,%eax
  801c70:	89 ca                	mov    %ecx,%edx
  801c72:	f7 75 ec             	divl   -0x14(%ebp)
  801c75:	89 d1                	mov    %edx,%ecx
  801c77:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c79:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c7c:	39 d1                	cmp    %edx,%ecx
  801c7e:	72 28                	jb     801ca8 <__udivdi3+0x110>
  801c80:	74 1a                	je     801c9c <__udivdi3+0x104>
  801c82:	89 f7                	mov    %esi,%edi
  801c84:	31 f6                	xor    %esi,%esi
  801c86:	eb 80                	jmp    801c08 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c88:	31 f6                	xor    %esi,%esi
  801c8a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c8f:	89 f8                	mov    %edi,%eax
  801c91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    
  801c9a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c9f:	89 f9                	mov    %edi,%ecx
  801ca1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ca3:	39 c2                	cmp    %eax,%edx
  801ca5:	73 db                	jae    801c82 <__udivdi3+0xea>
  801ca7:	90                   	nop
		{
		  q0--;
  801ca8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cab:	31 f6                	xor    %esi,%esi
  801cad:	e9 56 ff ff ff       	jmp    801c08 <__udivdi3+0x70>
	...

00801cb4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	57                   	push   %edi
  801cb8:	56                   	push   %esi
  801cb9:	83 ec 20             	sub    $0x20,%esp
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cd1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cd3:	85 ff                	test   %edi,%edi
  801cd5:	75 15                	jne    801cec <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cd7:	39 f1                	cmp    %esi,%ecx
  801cd9:	0f 86 99 00 00 00    	jbe    801d78 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cdf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ce5:	83 c4 20             	add    $0x20,%esp
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	0f 87 a4 00 00 00    	ja     801d98 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cf4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cf7:	83 f0 1f             	xor    $0x1f,%eax
  801cfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cfd:	0f 84 a1 00 00 00    	je     801da4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d03:	89 f8                	mov    %edi,%eax
  801d05:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d08:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d0a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d0f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	09 c2                	or     %eax,%edx
  801d1b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d24:	d3 e0                	shl    %cl,%eax
  801d26:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d29:	89 f2                	mov    %esi,%edx
  801d2b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d30:	d3 e0                	shl    %cl,%eax
  801d32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d38:	89 f9                	mov    %edi,%ecx
  801d3a:	d3 e8                	shr    %cl,%eax
  801d3c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d3e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	f7 75 f0             	divl   -0x10(%ebp)
  801d45:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d47:	f7 65 f4             	mull   -0xc(%ebp)
  801d4a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d4d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d4f:	39 d6                	cmp    %edx,%esi
  801d51:	72 71                	jb     801dc4 <__umoddi3+0x110>
  801d53:	74 7f                	je     801dd4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d58:	29 c8                	sub    %ecx,%eax
  801d5a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d5c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5f:	d3 e8                	shr    %cl,%eax
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d67:	09 d0                	or     %edx,%eax
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d6e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d70:	83 c4 20             	add    $0x20,%esp
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    
  801d77:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d78:	85 c9                	test   %ecx,%ecx
  801d7a:	75 0b                	jne    801d87 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d81:	31 d2                	xor    %edx,%edx
  801d83:	f7 f1                	div    %ecx
  801d85:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	31 d2                	xor    %edx,%edx
  801d8b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d90:	f7 f1                	div    %ecx
  801d92:	e9 4a ff ff ff       	jmp    801ce1 <__umoddi3+0x2d>
  801d97:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d98:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d9a:	83 c4 20             	add    $0x20,%esp
  801d9d:	5e                   	pop    %esi
  801d9e:	5f                   	pop    %edi
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    
  801da1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801da4:	39 f7                	cmp    %esi,%edi
  801da6:	72 05                	jb     801dad <__umoddi3+0xf9>
  801da8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801dab:	77 0c                	ja     801db9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	29 c8                	sub    %ecx,%eax
  801db4:	19 fa                	sbb    %edi,%edx
  801db6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dbc:	83 c4 20             	add    $0x20,%esp
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dc4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dc7:	89 c1                	mov    %eax,%ecx
  801dc9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dcc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dcf:	eb 84                	jmp    801d55 <__umoddi3+0xa1>
  801dd1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dd7:	72 eb                	jb     801dc4 <__umoddi3+0x110>
  801dd9:	89 f2                	mov    %esi,%edx
  801ddb:	e9 75 ff ff ff       	jmp    801d55 <__umoddi3+0xa1>
