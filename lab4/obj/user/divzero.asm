
obj/user/divzero:     file format elf32-i386


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
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	50                   	push   %eax
  800052:	68 20 0f 80 00       	push   $0x800f20
  800057:	e8 fc 00 00 00       	call   800158 <cprintf>
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
  80006f:	e8 d1 0a 00 00       	call   800b45 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800080:	c1 e0 07             	shl    $0x7,%eax
  800083:	29 d0                	sub    %edx,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 f6                	test   %esi,%esi
  800091:	7e 07                	jle    80009a <libmain+0x36>
		binaryname = argv[0];
  800093:	8b 03                	mov    (%ebx),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	53                   	push   %ebx
  80009e:	56                   	push   %esi
  80009f:	e8 90 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0b 00 00 00       	call   8000b4 <exit>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 62 0a 00 00       	call   800b23 <sys_env_destroy>
  8000c1:	83 c4 10             	add    $0x10,%esp
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    
	...

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 1a                	jne    8000ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	68 ff 00 00 00       	push   $0xff
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	50                   	push   %eax
  8000f1:	e8 e3 09 00 00       	call   800ad9 <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ff:	ff 43 04             	incl   0x4(%ebx)
}
  800102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800105:	c9                   	leave  
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	ff 75 0c             	pushl  0xc(%ebp)
  800127:	ff 75 08             	pushl  0x8(%ebp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	50                   	push   %eax
  800131:	68 c8 00 80 00       	push   $0x8000c8
  800136:	e8 82 01 00 00       	call   8002bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800144:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 89 09 00 00       	call   800ad9 <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	50                   	push   %eax
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	e8 9d ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 2c             	sub    $0x2c,%esp
  800175:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800178:	89 d6                	mov    %edx,%esi
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800180:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800183:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800186:	8b 45 10             	mov    0x10(%ebp),%eax
  800189:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80018c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800192:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800199:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80019c:	72 0c                	jb     8001aa <printnum+0x3e>
  80019e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001a1:	76 07                	jbe    8001aa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a3:	4b                   	dec    %ebx
  8001a4:	85 db                	test   %ebx,%ebx
  8001a6:	7f 31                	jg     8001d9 <printnum+0x6d>
  8001a8:	eb 3f                	jmp    8001e9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	57                   	push   %edi
  8001ae:	4b                   	dec    %ebx
  8001af:	53                   	push   %ebx
  8001b0:	50                   	push   %eax
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c0:	e8 0f 0b 00 00       	call   800cd4 <__udivdi3>
  8001c5:	83 c4 18             	add    $0x18,%esp
  8001c8:	52                   	push   %edx
  8001c9:	50                   	push   %eax
  8001ca:	89 f2                	mov    %esi,%edx
  8001cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001cf:	e8 98 ff ff ff       	call   80016c <printnum>
  8001d4:	83 c4 20             	add    $0x20,%esp
  8001d7:	eb 10                	jmp    8001e9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	57                   	push   %edi
  8001de:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e1:	4b                   	dec    %ebx
  8001e2:	83 c4 10             	add    $0x10,%esp
  8001e5:	85 db                	test   %ebx,%ebx
  8001e7:	7f f0                	jg     8001d9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	83 ec 04             	sub    $0x4,%esp
  8001f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fc:	e8 ef 0b 00 00       	call   800df0 <__umoddi3>
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	0f be 80 38 0f 80 00 	movsbl 0x800f38(%eax),%eax
  80020b:	50                   	push   %eax
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
  80020f:	83 c4 10             	add    $0x10,%esp
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80021d:	83 fa 01             	cmp    $0x1,%edx
  800220:	7e 0e                	jle    800230 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800222:	8b 10                	mov    (%eax),%edx
  800224:	8d 4a 08             	lea    0x8(%edx),%ecx
  800227:	89 08                	mov    %ecx,(%eax)
  800229:	8b 02                	mov    (%edx),%eax
  80022b:	8b 52 04             	mov    0x4(%edx),%edx
  80022e:	eb 22                	jmp    800252 <getuint+0x38>
	else if (lflag)
  800230:	85 d2                	test   %edx,%edx
  800232:	74 10                	je     800244 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800234:	8b 10                	mov    (%eax),%edx
  800236:	8d 4a 04             	lea    0x4(%edx),%ecx
  800239:	89 08                	mov    %ecx,(%eax)
  80023b:	8b 02                	mov    (%edx),%eax
  80023d:	ba 00 00 00 00       	mov    $0x0,%edx
  800242:	eb 0e                	jmp    800252 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800244:	8b 10                	mov    (%eax),%edx
  800246:	8d 4a 04             	lea    0x4(%edx),%ecx
  800249:	89 08                	mov    %ecx,(%eax)
  80024b:	8b 02                	mov    (%edx),%eax
  80024d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800257:	83 fa 01             	cmp    $0x1,%edx
  80025a:	7e 0e                	jle    80026a <getint+0x16>
		return va_arg(*ap, long long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	8b 52 04             	mov    0x4(%edx),%edx
  800268:	eb 1a                	jmp    800284 <getint+0x30>
	else if (lflag)
  80026a:	85 d2                	test   %edx,%edx
  80026c:	74 0c                	je     80027a <getint+0x26>
		return va_arg(*ap, long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 04             	lea    0x4(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	99                   	cltd   
  800278:	eb 0a                	jmp    800284 <getint+0x30>
	else
		return va_arg(*ap, int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	99                   	cltd   
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 08                	jae    80029e <sprintputch+0x18>
		*b->buf++ = ch;
  800296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800299:	88 0a                	mov    %cl,(%edx)
  80029b:	42                   	inc    %edx
  80029c:	89 10                	mov    %edx,(%eax)
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a9:	50                   	push   %eax
  8002aa:	ff 75 10             	pushl  0x10(%ebp)
  8002ad:	ff 75 0c             	pushl  0xc(%ebp)
  8002b0:	ff 75 08             	pushl  0x8(%ebp)
  8002b3:	e8 05 00 00 00       	call   8002bd <vprintfmt>
	va_end(ap);
  8002b8:	83 c4 10             	add    $0x10,%esp
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
  8002c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002cc:	eb 13                	jmp    8002e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	0f 84 6d 03 00 00    	je     800643 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	57                   	push   %edi
  8002da:	50                   	push   %eax
  8002db:	ff 55 08             	call   *0x8(%ebp)
  8002de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e1:	0f b6 06             	movzbl (%esi),%eax
  8002e4:	46                   	inc    %esi
  8002e5:	83 f8 25             	cmp    $0x25,%eax
  8002e8:	75 e4                	jne    8002ce <vprintfmt+0x11>
  8002ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800303:	b9 00 00 00 00       	mov    $0x0,%ecx
  800308:	eb 28                	jmp    800332 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800310:	eb 20                	jmp    800332 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800318:	eb 18                	jmp    800332 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80031c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800323:	eb 0d                	jmp    800332 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800325:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8a 06                	mov    (%esi),%al
  800334:	0f b6 d0             	movzbl %al,%edx
  800337:	8d 5e 01             	lea    0x1(%esi),%ebx
  80033a:	83 e8 23             	sub    $0x23,%eax
  80033d:	3c 55                	cmp    $0x55,%al
  80033f:	0f 87 e0 02 00 00    	ja     800625 <vprintfmt+0x368>
  800345:	0f b6 c0             	movzbl %al,%eax
  800348:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034f:	83 ea 30             	sub    $0x30,%edx
  800352:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800355:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800358:	8d 50 d0             	lea    -0x30(%eax),%edx
  80035b:	83 fa 09             	cmp    $0x9,%edx
  80035e:	77 44                	ja     8003a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	89 de                	mov    %ebx,%esi
  800362:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800365:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800366:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800369:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80036d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800370:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800373:	83 fb 09             	cmp    $0x9,%ebx
  800376:	76 ed                	jbe    800365 <vprintfmt+0xa8>
  800378:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80037b:	eb 29                	jmp    8003a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037d:	8b 45 14             	mov    0x14(%ebp),%eax
  800380:	8d 50 04             	lea    0x4(%eax),%edx
  800383:	89 55 14             	mov    %edx,0x14(%ebp)
  800386:	8b 00                	mov    (%eax),%eax
  800388:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038d:	eb 17                	jmp    8003a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80038f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800393:	78 85                	js     80031a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	89 de                	mov    %ebx,%esi
  800397:	eb 99                	jmp    800332 <vprintfmt+0x75>
  800399:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003a2:	eb 8e                	jmp    800332 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003aa:	79 86                	jns    800332 <vprintfmt+0x75>
  8003ac:	e9 74 ff ff ff       	jmp    800325 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 de                	mov    %ebx,%esi
  8003b4:	e9 79 ff ff ff       	jmp    800332 <vprintfmt+0x75>
  8003b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 50 04             	lea    0x4(%eax),%edx
  8003c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	57                   	push   %edi
  8003c9:	ff 30                	pushl  (%eax)
  8003cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 08 ff ff ff       	jmp    8002e1 <vprintfmt+0x24>
  8003d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	79 02                	jns    8003ed <vprintfmt+0x130>
  8003eb:	f7 d8                	neg    %eax
  8003ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ef:	83 f8 08             	cmp    $0x8,%eax
  8003f2:	7f 0b                	jg     8003ff <vprintfmt+0x142>
  8003f4:	8b 04 85 60 11 80 00 	mov    0x801160(,%eax,4),%eax
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	75 1a                	jne    800419 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003ff:	52                   	push   %edx
  800400:	68 50 0f 80 00       	push   $0x800f50
  800405:	57                   	push   %edi
  800406:	ff 75 08             	pushl  0x8(%ebp)
  800409:	e8 92 fe ff ff       	call   8002a0 <printfmt>
  80040e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800414:	e9 c8 fe ff ff       	jmp    8002e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800419:	50                   	push   %eax
  80041a:	68 59 0f 80 00       	push   $0x800f59
  80041f:	57                   	push   %edi
  800420:	ff 75 08             	pushl  0x8(%ebp)
  800423:	e8 78 fe ff ff       	call   8002a0 <printfmt>
  800428:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80042e:	e9 ae fe ff ff       	jmp    8002e1 <vprintfmt+0x24>
  800433:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800436:	89 de                	mov    %ebx,%esi
  800438:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80043b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 50 04             	lea    0x4(%eax),%edx
  800444:	89 55 14             	mov    %edx,0x14(%ebp)
  800447:	8b 00                	mov    (%eax),%eax
  800449:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 07                	jne    800457 <vprintfmt+0x19a>
				p = "(null)";
  800450:	c7 45 d0 49 0f 80 00 	movl   $0x800f49,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800457:	85 db                	test   %ebx,%ebx
  800459:	7e 42                	jle    80049d <vprintfmt+0x1e0>
  80045b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80045f:	74 3c                	je     80049d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	51                   	push   %ecx
  800465:	ff 75 d0             	pushl  -0x30(%ebp)
  800468:	e8 6f 02 00 00       	call   8006dc <strnlen>
  80046d:	29 c3                	sub    %eax,%ebx
  80046f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	85 db                	test   %ebx,%ebx
  800477:	7e 24                	jle    80049d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800479:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80047d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800480:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	57                   	push   %edi
  800487:	53                   	push   %ebx
  800488:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	4e                   	dec    %esi
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 f6                	test   %esi,%esi
  800491:	7f f0                	jg     800483 <vprintfmt+0x1c6>
  800493:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800496:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a0:	0f be 02             	movsbl (%edx),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	75 47                	jne    8004ee <vprintfmt+0x231>
  8004a7:	eb 37                	jmp    8004e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ad:	74 16                	je     8004c5 <vprintfmt+0x208>
  8004af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b2:	83 fa 5e             	cmp    $0x5e,%edx
  8004b5:	76 0e                	jbe    8004c5 <vprintfmt+0x208>
					putch('?', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	57                   	push   %edi
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff 55 08             	call   *0x8(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb 0b                	jmp    8004d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	57                   	push   %edi
  8004c9:	50                   	push   %eax
  8004ca:	ff 55 08             	call   *0x8(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d3:	0f be 03             	movsbl (%ebx),%eax
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	74 03                	je     8004dd <vprintfmt+0x220>
  8004da:	43                   	inc    %ebx
  8004db:	eb 1b                	jmp    8004f8 <vprintfmt+0x23b>
  8004dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e4:	7f 1e                	jg     800504 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e9:	e9 f3 fd ff ff       	jmp    8002e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f1:	43                   	inc    %ebx
  8004f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004f8:	85 f6                	test   %esi,%esi
  8004fa:	78 ad                	js     8004a9 <vprintfmt+0x1ec>
  8004fc:	4e                   	dec    %esi
  8004fd:	79 aa                	jns    8004a9 <vprintfmt+0x1ec>
  8004ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800502:	eb dc                	jmp    8004e0 <vprintfmt+0x223>
  800504:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	57                   	push   %edi
  80050b:	6a 20                	push   $0x20
  80050d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800510:	4b                   	dec    %ebx
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 db                	test   %ebx,%ebx
  800516:	7f ef                	jg     800507 <vprintfmt+0x24a>
  800518:	e9 c4 fd ff ff       	jmp    8002e1 <vprintfmt+0x24>
  80051d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800520:	89 ca                	mov    %ecx,%edx
  800522:	8d 45 14             	lea    0x14(%ebp),%eax
  800525:	e8 2a fd ff ff       	call   800254 <getint>
  80052a:	89 c3                	mov    %eax,%ebx
  80052c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80052e:	85 d2                	test   %edx,%edx
  800530:	78 0a                	js     80053c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800532:	b8 0a 00 00 00       	mov    $0xa,%eax
  800537:	e9 b0 00 00 00       	jmp    8005ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	57                   	push   %edi
  800540:	6a 2d                	push   $0x2d
  800542:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800545:	f7 db                	neg    %ebx
  800547:	83 d6 00             	adc    $0x0,%esi
  80054a:	f7 de                	neg    %esi
  80054c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800554:	e9 93 00 00 00       	jmp    8005ec <vprintfmt+0x32f>
  800559:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80055c:	89 ca                	mov    %ecx,%edx
  80055e:	8d 45 14             	lea    0x14(%ebp),%eax
  800561:	e8 b4 fc ff ff       	call   80021a <getuint>
  800566:	89 c3                	mov    %eax,%ebx
  800568:	89 d6                	mov    %edx,%esi
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80056f:	eb 7b                	jmp    8005ec <vprintfmt+0x32f>
  800571:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800574:	89 ca                	mov    %ecx,%edx
  800576:	8d 45 14             	lea    0x14(%ebp),%eax
  800579:	e8 d6 fc ff ff       	call   800254 <getint>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800582:	85 d2                	test   %edx,%edx
  800584:	78 07                	js     80058d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800586:	b8 08 00 00 00       	mov    $0x8,%eax
  80058b:	eb 5f                	jmp    8005ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	57                   	push   %edi
  800591:	6a 2d                	push   $0x2d
  800593:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800596:	f7 db                	neg    %ebx
  800598:	83 d6 00             	adc    $0x0,%esi
  80059b:	f7 de                	neg    %esi
  80059d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a5:	eb 45                	jmp    8005ec <vprintfmt+0x32f>
  8005a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	57                   	push   %edi
  8005ae:	6a 30                	push   $0x30
  8005b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b3:	83 c4 08             	add    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	6a 78                	push   $0x78
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c5:	8b 18                	mov    (%eax),%ebx
  8005c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d4:	eb 16                	jmp    8005ec <vprintfmt+0x32f>
  8005d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d9:	89 ca                	mov    %ecx,%edx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 37 fc ff ff       	call   80021a <getuint>
  8005e3:	89 c3                	mov    %eax,%ebx
  8005e5:	89 d6                	mov    %edx,%esi
			base = 16;
  8005e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005f3:	52                   	push   %edx
  8005f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f7:	50                   	push   %eax
  8005f8:	56                   	push   %esi
  8005f9:	53                   	push   %ebx
  8005fa:	89 fa                	mov    %edi,%edx
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	e8 68 fb ff ff       	call   80016c <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060a:	e9 d2 fc ff ff       	jmp    8002e1 <vprintfmt+0x24>
  80060f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	57                   	push   %edi
  800616:	52                   	push   %edx
  800617:	ff 55 08             	call   *0x8(%ebp)
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800620:	e9 bc fc ff ff       	jmp    8002e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	57                   	push   %edi
  800629:	6a 25                	push   $0x25
  80062b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 02                	jmp    800635 <vprintfmt+0x378>
  800633:	89 c6                	mov    %eax,%esi
  800635:	8d 46 ff             	lea    -0x1(%esi),%eax
  800638:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80063c:	75 f5                	jne    800633 <vprintfmt+0x376>
  80063e:	e9 9e fc ff ff       	jmp    8002e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800643:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	5f                   	pop    %edi
  800649:	c9                   	leave  
  80064a:	c3                   	ret    

0080064b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	83 ec 18             	sub    $0x18,%esp
  800651:	8b 45 08             	mov    0x8(%ebp),%eax
  800654:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800657:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800668:	85 c0                	test   %eax,%eax
  80066a:	74 26                	je     800692 <vsnprintf+0x47>
  80066c:	85 d2                	test   %edx,%edx
  80066e:	7e 29                	jle    800699 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800670:	ff 75 14             	pushl  0x14(%ebp)
  800673:	ff 75 10             	pushl  0x10(%ebp)
  800676:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	68 86 02 80 00       	push   $0x800286
  80067f:	e8 39 fc ff ff       	call   8002bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800684:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800687:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb 0c                	jmp    80069e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800692:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800697:	eb 05                	jmp    80069e <vsnprintf+0x53>
  800699:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069e:	c9                   	leave  
  80069f:	c3                   	ret    

008006a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a9:	50                   	push   %eax
  8006aa:	ff 75 10             	pushl  0x10(%ebp)
  8006ad:	ff 75 0c             	pushl  0xc(%ebp)
  8006b0:	ff 75 08             	pushl  0x8(%ebp)
  8006b3:	e8 93 ff ff ff       	call   80064b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    
	...

008006bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c5:	74 0e                	je     8006d5 <strlen+0x19>
  8006c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006cc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d1:	75 f9                	jne    8006cc <strlen+0x10>
  8006d3:	eb 05                	jmp    8006da <strlen+0x1e>
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 17                	je     800700 <strnlen+0x24>
  8006e9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006ec:	74 19                	je     800707 <strnlen+0x2b>
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f4:	39 d0                	cmp    %edx,%eax
  8006f6:	74 14                	je     80070c <strnlen+0x30>
  8006f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006fc:	75 f5                	jne    8006f3 <strnlen+0x17>
  8006fe:	eb 0c                	jmp    80070c <strnlen+0x30>
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	eb 05                	jmp    80070c <strnlen+0x30>
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    

0080070e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	53                   	push   %ebx
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
  80071d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800720:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800723:	42                   	inc    %edx
  800724:	84 c9                	test   %cl,%cl
  800726:	75 f5                	jne    80071d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800728:	5b                   	pop    %ebx
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800732:	53                   	push   %ebx
  800733:	e8 84 ff ff ff       	call   8006bc <strlen>
  800738:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800741:	50                   	push   %eax
  800742:	e8 c7 ff ff ff       	call   80070e <strcpy>
	return dst;
}
  800747:	89 d8                	mov    %ebx,%eax
  800749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
  800759:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075c:	85 f6                	test   %esi,%esi
  80075e:	74 15                	je     800775 <strncpy+0x27>
  800760:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800765:	8a 1a                	mov    (%edx),%bl
  800767:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076a:	80 3a 01             	cmpb   $0x1,(%edx)
  80076d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800770:	41                   	inc    %ecx
  800771:	39 ce                	cmp    %ecx,%esi
  800773:	77 f0                	ja     800765 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	57                   	push   %edi
  80077d:	56                   	push   %esi
  80077e:	53                   	push   %ebx
  80077f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800788:	85 f6                	test   %esi,%esi
  80078a:	74 32                	je     8007be <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80078c:	83 fe 01             	cmp    $0x1,%esi
  80078f:	74 22                	je     8007b3 <strlcpy+0x3a>
  800791:	8a 0b                	mov    (%ebx),%cl
  800793:	84 c9                	test   %cl,%cl
  800795:	74 20                	je     8007b7 <strlcpy+0x3e>
  800797:	89 f8                	mov    %edi,%eax
  800799:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80079e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a1:	88 08                	mov    %cl,(%eax)
  8007a3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a4:	39 f2                	cmp    %esi,%edx
  8007a6:	74 11                	je     8007b9 <strlcpy+0x40>
  8007a8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007ac:	42                   	inc    %edx
  8007ad:	84 c9                	test   %cl,%cl
  8007af:	75 f0                	jne    8007a1 <strlcpy+0x28>
  8007b1:	eb 06                	jmp    8007b9 <strlcpy+0x40>
  8007b3:	89 f8                	mov    %edi,%eax
  8007b5:	eb 02                	jmp    8007b9 <strlcpy+0x40>
  8007b7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 00 00             	movb   $0x0,(%eax)
  8007bc:	eb 02                	jmp    8007c0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007be:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007c0:	29 f8                	sub    %edi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5f                   	pop    %edi
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d0:	8a 01                	mov    (%ecx),%al
  8007d2:	84 c0                	test   %al,%al
  8007d4:	74 10                	je     8007e6 <strcmp+0x1f>
  8007d6:	3a 02                	cmp    (%edx),%al
  8007d8:	75 0c                	jne    8007e6 <strcmp+0x1f>
		p++, q++;
  8007da:	41                   	inc    %ecx
  8007db:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007dc:	8a 01                	mov    (%ecx),%al
  8007de:	84 c0                	test   %al,%al
  8007e0:	74 04                	je     8007e6 <strcmp+0x1f>
  8007e2:	3a 02                	cmp    (%edx),%al
  8007e4:	74 f4                	je     8007da <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e6:	0f b6 c0             	movzbl %al,%eax
  8007e9:	0f b6 12             	movzbl (%edx),%edx
  8007ec:	29 d0                	sub    %edx,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 1b                	je     80081c <strncmp+0x2c>
  800801:	8a 1a                	mov    (%edx),%bl
  800803:	84 db                	test   %bl,%bl
  800805:	74 24                	je     80082b <strncmp+0x3b>
  800807:	3a 19                	cmp    (%ecx),%bl
  800809:	75 20                	jne    80082b <strncmp+0x3b>
  80080b:	48                   	dec    %eax
  80080c:	74 15                	je     800823 <strncmp+0x33>
		n--, p++, q++;
  80080e:	42                   	inc    %edx
  80080f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800810:	8a 1a                	mov    (%edx),%bl
  800812:	84 db                	test   %bl,%bl
  800814:	74 15                	je     80082b <strncmp+0x3b>
  800816:	3a 19                	cmp    (%ecx),%bl
  800818:	74 f1                	je     80080b <strncmp+0x1b>
  80081a:	eb 0f                	jmp    80082b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
  800821:	eb 05                	jmp    800828 <strncmp+0x38>
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800828:	5b                   	pop    %ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 02             	movzbl (%edx),%eax
  80082e:	0f b6 11             	movzbl (%ecx),%edx
  800831:	29 d0                	sub    %edx,%eax
  800833:	eb f3                	jmp    800828 <strncmp+0x38>

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083e:	8a 10                	mov    (%eax),%dl
  800840:	84 d2                	test   %dl,%dl
  800842:	74 18                	je     80085c <strchr+0x27>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	75 06                	jne    80084e <strchr+0x19>
  800848:	eb 17                	jmp    800861 <strchr+0x2c>
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 13                	je     800861 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	40                   	inc    %eax
  80084f:	8a 10                	mov    (%eax),%dl
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f5                	jne    80084a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	eb 05                	jmp    800861 <strchr+0x2c>
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086c:	8a 10                	mov    (%eax),%dl
  80086e:	84 d2                	test   %dl,%dl
  800870:	74 11                	je     800883 <strfind+0x20>
		if (*s == c)
  800872:	38 ca                	cmp    %cl,%dl
  800874:	75 06                	jne    80087c <strfind+0x19>
  800876:	eb 0b                	jmp    800883 <strfind+0x20>
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 07                	je     800883 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80087c:	40                   	inc    %eax
  80087d:	8a 10                	mov    (%eax),%dl
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f5                	jne    800878 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	57                   	push   %edi
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 30                	je     8008c8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800898:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089e:	75 25                	jne    8008c5 <memset+0x40>
  8008a0:	f6 c1 03             	test   $0x3,%cl
  8008a3:	75 20                	jne    8008c5 <memset+0x40>
		c &= 0xFF;
  8008a5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a8:	89 d3                	mov    %edx,%ebx
  8008aa:	c1 e3 08             	shl    $0x8,%ebx
  8008ad:	89 d6                	mov    %edx,%esi
  8008af:	c1 e6 18             	shl    $0x18,%esi
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	c1 e0 10             	shl    $0x10,%eax
  8008b7:	09 f0                	or     %esi,%eax
  8008b9:	09 d0                	or     %edx,%eax
  8008bb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c0:	fc                   	cld    
  8008c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c3:	eb 03                	jmp    8008c8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c5:	fc                   	cld    
  8008c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dd:	39 c6                	cmp    %eax,%esi
  8008df:	73 34                	jae    800915 <memmove+0x46>
  8008e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	73 2d                	jae    800915 <memmove+0x46>
		s += n;
		d += n;
  8008e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	f6 c2 03             	test   $0x3,%dl
  8008ee:	75 1b                	jne    80090b <memmove+0x3c>
  8008f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f6:	75 13                	jne    80090b <memmove+0x3c>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 0e                	jne    80090b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fd:	83 ef 04             	sub    $0x4,%edi
  800900:	8d 72 fc             	lea    -0x4(%edx),%esi
  800903:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800906:	fd                   	std    
  800907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800909:	eb 07                	jmp    800912 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090b:	4f                   	dec    %edi
  80090c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090f:	fd                   	std    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800912:	fc                   	cld    
  800913:	eb 20                	jmp    800935 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 13                	jne    800930 <memmove+0x61>
  80091d:	a8 03                	test   $0x3,%al
  80091f:	75 0f                	jne    800930 <memmove+0x61>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 0a                	jne    800930 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800926:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 05                	jmp    800935 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800930:	89 c7                	mov    %eax,%edi
  800932:	fc                   	cld    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093c:	ff 75 10             	pushl  0x10(%ebp)
  80093f:	ff 75 0c             	pushl  0xc(%ebp)
  800942:	ff 75 08             	pushl  0x8(%ebp)
  800945:	e8 85 ff ff ff       	call   8008cf <memmove>
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800955:	8b 75 0c             	mov    0xc(%ebp),%esi
  800958:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	85 ff                	test   %edi,%edi
  80095d:	74 32                	je     800991 <memcmp+0x45>
		if (*s1 != *s2)
  80095f:	8a 03                	mov    (%ebx),%al
  800961:	8a 0e                	mov    (%esi),%cl
  800963:	38 c8                	cmp    %cl,%al
  800965:	74 19                	je     800980 <memcmp+0x34>
  800967:	eb 0d                	jmp    800976 <memcmp+0x2a>
  800969:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80096d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800971:	42                   	inc    %edx
  800972:	38 c8                	cmp    %cl,%al
  800974:	74 10                	je     800986 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 c9             	movzbl %cl,%ecx
  80097c:	29 c8                	sub    %ecx,%eax
  80097e:	eb 16                	jmp    800996 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800980:	4f                   	dec    %edi
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	39 fa                	cmp    %edi,%edx
  800988:	75 df                	jne    800969 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
  80098f:	eb 05                	jmp    800996 <memcmp+0x4a>
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	73 12                	jae    8009bc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009aa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009ad:	38 08                	cmp    %cl,(%eax)
  8009af:	75 06                	jne    8009b7 <memfind+0x1c>
  8009b1:	eb 09                	jmp    8009bc <memfind+0x21>
  8009b3:	38 08                	cmp    %cl,(%eax)
  8009b5:	74 05                	je     8009bc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b7:	40                   	inc    %eax
  8009b8:	39 c2                	cmp    %eax,%edx
  8009ba:	77 f7                	ja     8009b3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ca:	eb 01                	jmp    8009cd <strtol+0xf>
		s++;
  8009cc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cd:	8a 02                	mov    (%edx),%al
  8009cf:	3c 20                	cmp    $0x20,%al
  8009d1:	74 f9                	je     8009cc <strtol+0xe>
  8009d3:	3c 09                	cmp    $0x9,%al
  8009d5:	74 f5                	je     8009cc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d7:	3c 2b                	cmp    $0x2b,%al
  8009d9:	75 08                	jne    8009e3 <strtol+0x25>
		s++;
  8009db:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e1:	eb 13                	jmp    8009f6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e3:	3c 2d                	cmp    $0x2d,%al
  8009e5:	75 0a                	jne    8009f1 <strtol+0x33>
		s++, neg = 1;
  8009e7:	8d 52 01             	lea    0x1(%edx),%edx
  8009ea:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ef:	eb 05                	jmp    8009f6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f6:	85 db                	test   %ebx,%ebx
  8009f8:	74 05                	je     8009ff <strtol+0x41>
  8009fa:	83 fb 10             	cmp    $0x10,%ebx
  8009fd:	75 28                	jne    800a27 <strtol+0x69>
  8009ff:	8a 02                	mov    (%edx),%al
  800a01:	3c 30                	cmp    $0x30,%al
  800a03:	75 10                	jne    800a15 <strtol+0x57>
  800a05:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a09:	75 0a                	jne    800a15 <strtol+0x57>
		s += 2, base = 16;
  800a0b:	83 c2 02             	add    $0x2,%edx
  800a0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a13:	eb 12                	jmp    800a27 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	75 0e                	jne    800a27 <strtol+0x69>
  800a19:	3c 30                	cmp    $0x30,%al
  800a1b:	75 05                	jne    800a22 <strtol+0x64>
		s++, base = 8;
  800a1d:	42                   	inc    %edx
  800a1e:	b3 08                	mov    $0x8,%bl
  800a20:	eb 05                	jmp    800a27 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2e:	8a 0a                	mov    (%edx),%cl
  800a30:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a33:	80 fb 09             	cmp    $0x9,%bl
  800a36:	77 08                	ja     800a40 <strtol+0x82>
			dig = *s - '0';
  800a38:	0f be c9             	movsbl %cl,%ecx
  800a3b:	83 e9 30             	sub    $0x30,%ecx
  800a3e:	eb 1e                	jmp    800a5e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a40:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a43:	80 fb 19             	cmp    $0x19,%bl
  800a46:	77 08                	ja     800a50 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a48:	0f be c9             	movsbl %cl,%ecx
  800a4b:	83 e9 57             	sub    $0x57,%ecx
  800a4e:	eb 0e                	jmp    800a5e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a50:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a53:	80 fb 19             	cmp    $0x19,%bl
  800a56:	77 13                	ja     800a6b <strtol+0xad>
			dig = *s - 'A' + 10;
  800a58:	0f be c9             	movsbl %cl,%ecx
  800a5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5e:	39 f1                	cmp    %esi,%ecx
  800a60:	7d 0d                	jge    800a6f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a62:	42                   	inc    %edx
  800a63:	0f af c6             	imul   %esi,%eax
  800a66:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a69:	eb c3                	jmp    800a2e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a6b:	89 c1                	mov    %eax,%ecx
  800a6d:	eb 02                	jmp    800a71 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a75:	74 05                	je     800a7c <strtol+0xbe>
		*endptr = (char *) s;
  800a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a7c:	85 ff                	test   %edi,%edi
  800a7e:	74 04                	je     800a84 <strtol+0xc6>
  800a80:	89 c8                	mov    %ecx,%eax
  800a82:	f7 d8                	neg    %eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5f                   	pop    %edi
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    
  800a89:	00 00                	add    %al,(%eax)
	...

00800a8c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	83 ec 1c             	sub    $0x1c,%esp
  800a95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a9b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	8b 75 14             	mov    0x14(%ebp),%esi
  800aa0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	cd 30                	int    $0x30
  800aab:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ab1:	74 1c                	je     800acf <syscall+0x43>
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	7e 18                	jle    800acf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	50                   	push   %eax
  800abb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800abe:	68 84 11 80 00       	push   $0x801184
  800ac3:	6a 42                	push   $0x42
  800ac5:	68 a1 11 80 00       	push   $0x8011a1
  800aca:	e8 bd 01 00 00       	call   800c8c <_panic>

	return ret;
}
  800acf:	89 d0                	mov    %edx,%eax
  800ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800adf:	6a 00                	push   $0x0
  800ae1:	6a 00                	push   $0x0
  800ae3:	6a 00                	push   $0x0
  800ae5:	ff 75 0c             	pushl  0xc(%ebp)
  800ae8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	e8 92 ff ff ff       	call   800a8c <syscall>
  800afa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1c:	e8 6b ff ff ff       	call   800a8c <syscall>
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	ba 01 00 00 00       	mov    $0x1,%edx
  800b39:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3e:	e8 49 ff ff ff       	call   800a8c <syscall>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b4b:	6a 00                	push   $0x0
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	6a 00                	push   $0x0
  800b53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b62:	e8 25 ff ff ff       	call   800a8c <syscall>
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <sys_yield>:

void
sys_yield(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b86:	e8 01 ff ff ff       	call   800a8c <syscall>
  800b8b:	83 c4 10             	add    $0x10,%esp
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b96:	6a 00                	push   $0x0
  800b98:	6a 00                	push   $0x0
  800b9a:	ff 75 10             	pushl  0x10(%ebp)
  800b9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bad:	e8 da fe ff ff       	call   800a8c <syscall>
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bba:	ff 75 18             	pushl  0x18(%ebp)
  800bbd:	ff 75 14             	pushl  0x14(%ebp)
  800bc0:	ff 75 10             	pushl  0x10(%ebp)
  800bc3:	ff 75 0c             	pushl  0xc(%ebp)
  800bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	e8 b4 fe ff ff       	call   800a8c <syscall>
}
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800be0:	6a 00                	push   $0x0
  800be2:	6a 00                	push   $0x0
  800be4:	6a 00                	push   $0x0
  800be6:	ff 75 0c             	pushl  0xc(%ebp)
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf6:	e8 91 fe ff ff       	call   800a8c <syscall>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	e8 6e fe ff ff       	call   800a8c <syscall>
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c32:	ba 01 00 00 00       	mov    $0x1,%edx
  800c37:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3c:	e8 4b fe ff ff       	call   800a8c <syscall>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c49:	6a 00                	push   $0x0
  800c4b:	ff 75 14             	pushl  0x14(%ebp)
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c61:	e8 26 fe ff ff       	call   800a8c <syscall>
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	6a 00                	push   $0x0
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c83:	e8 04 fe ff ff       	call   800a8c <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    
	...

00800c8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c91:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c94:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c9a:	e8 a6 fe ff ff       	call   800b45 <sys_getenvid>
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	ff 75 08             	pushl  0x8(%ebp)
  800ca8:	53                   	push   %ebx
  800ca9:	50                   	push   %eax
  800caa:	68 b0 11 80 00       	push   $0x8011b0
  800caf:	e8 a4 f4 ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cb4:	83 c4 18             	add    $0x18,%esp
  800cb7:	56                   	push   %esi
  800cb8:	ff 75 10             	pushl  0x10(%ebp)
  800cbb:	e8 47 f4 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800cc0:	c7 04 24 2c 0f 80 00 	movl   $0x800f2c,(%esp)
  800cc7:	e8 8c f4 ff ff       	call   800158 <cprintf>
  800ccc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ccf:	cc                   	int3   
  800cd0:	eb fd                	jmp    800ccf <_panic+0x43>
	...

00800cd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	83 ec 10             	sub    $0x10,%esp
  800cdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ceb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	75 2e                	jne    800d20 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cf2:	39 f1                	cmp    %esi,%ecx
  800cf4:	77 5a                	ja     800d50 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf6:	85 c9                	test   %ecx,%ecx
  800cf8:	75 0b                	jne    800d05 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800cff:	31 d2                	xor    %edx,%edx
  800d01:	f7 f1                	div    %ecx
  800d03:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	89 f0                	mov    %esi,%eax
  800d09:	f7 f1                	div    %ecx
  800d0b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0d:	89 f8                	mov    %edi,%eax
  800d0f:	f7 f1                	div    %ecx
  800d11:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d13:	89 f8                	mov    %edi,%eax
  800d15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d17:	83 c4 10             	add    $0x10,%esp
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d20:	39 f0                	cmp    %esi,%eax
  800d22:	77 1c                	ja     800d40 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d24:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	75 3c                	jne    800d68 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d2c:	39 f0                	cmp    %esi,%eax
  800d2e:	0f 82 90 00 00 00    	jb     800dc4 <__udivdi3+0xf0>
  800d34:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d37:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d3a:	0f 86 84 00 00 00    	jbe    800dc4 <__udivdi3+0xf0>
  800d40:	31 f6                	xor    %esi,%esi
  800d42:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    
  800d4f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	f7 f1                	div    %ecx
  800d56:	89 c7                	mov    %eax,%edi
  800d58:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5a:	89 f8                	mov    %edi,%eax
  800d5c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d68:	89 f9                	mov    %edi,%ecx
  800d6a:	d3 e0                	shl    %cl,%eax
  800d6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d6f:	b8 20 00 00 00       	mov    $0x20,%eax
  800d74:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d79:	88 c1                	mov    %al,%cl
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d80:	09 ca                	or     %ecx,%edx
  800d82:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d88:	89 f9                	mov    %edi,%ecx
  800d8a:	d3 e2                	shl    %cl,%edx
  800d8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d8f:	89 f2                	mov    %esi,%edx
  800d91:	88 c1                	mov    %al,%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	89 f9                	mov    %edi,%ecx
  800d9c:	d3 e2                	shl    %cl,%edx
  800d9e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800da1:	88 c1                	mov    %al,%cl
  800da3:	d3 ee                	shr    %cl,%esi
  800da5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800daa:	89 f0                	mov    %esi,%eax
  800dac:	89 ca                	mov    %ecx,%edx
  800dae:	f7 75 ec             	divl   -0x14(%ebp)
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800db5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db8:	39 d1                	cmp    %edx,%ecx
  800dba:	72 28                	jb     800de4 <__udivdi3+0x110>
  800dbc:	74 1a                	je     800dd8 <__udivdi3+0x104>
  800dbe:	89 f7                	mov    %esi,%edi
  800dc0:	31 f6                	xor    %esi,%esi
  800dc2:	eb 80                	jmp    800d44 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc4:	31 f6                	xor    %esi,%esi
  800dc6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dcb:	89 f8                	mov    %edi,%eax
  800dcd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    
  800dd6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ddb:	89 f9                	mov    %edi,%ecx
  800ddd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ddf:	39 c2                	cmp    %eax,%edx
  800de1:	73 db                	jae    800dbe <__udivdi3+0xea>
  800de3:	90                   	nop
		{
		  q0--;
  800de4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de7:	31 f6                	xor    %esi,%esi
  800de9:	e9 56 ff ff ff       	jmp    800d44 <__udivdi3+0x70>
	...

00800df0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	83 ec 20             	sub    $0x20,%esp
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e01:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e04:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e07:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e0d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e0f:	85 ff                	test   %edi,%edi
  800e11:	75 15                	jne    800e28 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e13:	39 f1                	cmp    %esi,%ecx
  800e15:	0f 86 99 00 00 00    	jbe    800eb4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e1d:	89 d0                	mov    %edx,%eax
  800e1f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e28:	39 f7                	cmp    %esi,%edi
  800e2a:	0f 87 a4 00 00 00    	ja     800ed4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e30:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e33:	83 f0 1f             	xor    $0x1f,%eax
  800e36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e39:	0f 84 a1 00 00 00    	je     800ee0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e44:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e46:	bf 20 00 00 00       	mov    $0x20,%edi
  800e4b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	09 c2                	or     %eax,%edx
  800e57:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e60:	d3 e0                	shl    %cl,%eax
  800e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e65:	89 f2                	mov    %esi,%edx
  800e67:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e6c:	d3 e0                	shl    %cl,%eax
  800e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e74:	89 f9                	mov    %edi,%ecx
  800e76:	d3 e8                	shr    %cl,%eax
  800e78:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e7a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e7c:	89 f2                	mov    %esi,%edx
  800e7e:	f7 75 f0             	divl   -0x10(%ebp)
  800e81:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e83:	f7 65 f4             	mull   -0xc(%ebp)
  800e86:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e89:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8b:	39 d6                	cmp    %edx,%esi
  800e8d:	72 71                	jb     800f00 <__umoddi3+0x110>
  800e8f:	74 7f                	je     800f10 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e94:	29 c8                	sub    %ecx,%eax
  800e96:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e98:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e9b:	d3 e8                	shr    %cl,%eax
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	89 f9                	mov    %edi,%ecx
  800ea1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ea3:	09 d0                	or     %edx,%eax
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eaa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb4:	85 c9                	test   %ecx,%ecx
  800eb6:	75 0b                	jne    800ec3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	f7 f1                	div    %ecx
  800ec1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecc:	f7 f1                	div    %ecx
  800ece:	e9 4a ff ff ff       	jmp    800e1d <__umoddi3+0x2d>
  800ed3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee0:	39 f7                	cmp    %esi,%edi
  800ee2:	72 05                	jb     800ee9 <__umoddi3+0xf9>
  800ee4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ee7:	77 0c                	ja     800ef5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee9:	89 f2                	mov    %esi,%edx
  800eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eee:	29 c8                	sub    %ecx,%eax
  800ef0:	19 fa                	sbb    %edi,%edx
  800ef2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    
  800eff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f00:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f08:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f0b:	eb 84                	jmp    800e91 <__umoddi3+0xa1>
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f10:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f13:	72 eb                	jb     800f00 <__umoddi3+0x110>
  800f15:	89 f2                	mov    %esi,%edx
  800f17:	e9 75 ff ff ff       	jmp    800e91 <__umoddi3+0xa1>
