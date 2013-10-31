
obj/user/hello:     file format elf32-i386


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
	cprintf("hello, world!\n");
  80003a:	68 f4 0d 80 00       	push   $0x800df4
  80003f:	e8 0c 01 00 00       	call   800150 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 20 80 00       	mov    0x802004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 03 0e 80 00       	push   $0x800e03
  800055:	e8 f6 00 00 00       	call   800150 <cprintf>
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
  80006b:	e8 cd 0a 00 00       	call   800b3d <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	53                   	push   %ebx
  800094:	56                   	push   %esi
  800095:	e8 9a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0d 00 00 00       	call   8000ac <exit>
  80009f:	83 c4 10             	add    $0x10,%esp
}
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 62 0a 00 00       	call   800b1b <sys_env_destroy>
  8000b9:	83 c4 10             	add    $0x10,%esp
}
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    
	...

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	40                   	inc    %eax
  8000d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 e3 09 00 00       	call   800ad1 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	ff 43 04             	incl   0x4(%ebx)
}
  8000fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010f:	00 00 00 
	b.cnt = 0;
  800112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011c:	ff 75 0c             	pushl  0xc(%ebp)
  80011f:	ff 75 08             	pushl  0x8(%ebp)
  800122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800128:	50                   	push   %eax
  800129:	68 c0 00 80 00       	push   $0x8000c0
  80012e:	e8 82 01 00 00       	call   8002b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800133:	83 c4 08             	add    $0x8,%esp
  800136:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 89 09 00 00       	call   800ad1 <sys_cputs>

	return b.cnt;
}
  800148:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800156:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800159:	50                   	push   %eax
  80015a:	ff 75 08             	pushl  0x8(%ebp)
  80015d:	e8 9d ff ff ff       	call   8000ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 2c             	sub    $0x2c,%esp
  80016d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80017e:	8b 45 10             	mov    0x10(%ebp),%eax
  800181:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800184:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800187:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80018a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800191:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800194:	72 0c                	jb     8001a2 <printnum+0x3e>
  800196:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800199:	76 07                	jbe    8001a2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019b:	4b                   	dec    %ebx
  80019c:	85 db                	test   %ebx,%ebx
  80019e:	7f 31                	jg     8001d1 <printnum+0x6d>
  8001a0:	eb 3f                	jmp    8001e1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	57                   	push   %edi
  8001a6:	4b                   	dec    %ebx
  8001a7:	53                   	push   %ebx
  8001a8:	50                   	push   %eax
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001af:	ff 75 d0             	pushl  -0x30(%ebp)
  8001b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b8:	e8 ef 09 00 00       	call   800bac <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001c7:	e8 98 ff ff ff       	call   800164 <printnum>
  8001cc:	83 c4 20             	add    $0x20,%esp
  8001cf:	eb 10                	jmp    8001e1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	57                   	push   %edi
  8001d6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d9:	4b                   	dec    %ebx
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f f0                	jg     8001d1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001eb:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 cf 0a 00 00       	call   800cc8 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 24 0e 80 00 	movsbl 0x800e24(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff 55 e4             	call   *-0x1c(%ebp)
  800207:	83 c4 10             	add    $0x10,%esp
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800215:	83 fa 01             	cmp    $0x1,%edx
  800218:	7e 0e                	jle    800228 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021f:	89 08                	mov    %ecx,(%eax)
  800221:	8b 02                	mov    (%edx),%eax
  800223:	8b 52 04             	mov    0x4(%edx),%edx
  800226:	eb 22                	jmp    80024a <getuint+0x38>
	else if (lflag)
  800228:	85 d2                	test   %edx,%edx
  80022a:	74 10                	je     80023c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800231:	89 08                	mov    %ecx,(%eax)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	eb 0e                	jmp    80024a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800241:	89 08                	mov    %ecx,(%eax)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024f:	83 fa 01             	cmp    $0x1,%edx
  800252:	7e 0e                	jle    800262 <getint+0x16>
		return va_arg(*ap, long long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 08             	lea    0x8(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	8b 52 04             	mov    0x4(%edx),%edx
  800260:	eb 1a                	jmp    80027c <getint+0x30>
	else if (lflag)
  800262:	85 d2                	test   %edx,%edx
  800264:	74 0c                	je     800272 <getint+0x26>
		return va_arg(*ap, long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	99                   	cltd   
  800270:	eb 0a                	jmp    80027c <getint+0x30>
	else
		return va_arg(*ap, int);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	99                   	cltd   
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800284:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800287:	8b 10                	mov    (%eax),%edx
  800289:	3b 50 04             	cmp    0x4(%eax),%edx
  80028c:	73 08                	jae    800296 <sprintputch+0x18>
		*b->buf++ = ch;
  80028e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800291:	88 0a                	mov    %cl,(%edx)
  800293:	42                   	inc    %edx
  800294:	89 10                	mov    %edx,(%eax)
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a1:	50                   	push   %eax
  8002a2:	ff 75 10             	pushl  0x10(%ebp)
  8002a5:	ff 75 0c             	pushl  0xc(%ebp)
  8002a8:	ff 75 08             	pushl  0x8(%ebp)
  8002ab:	e8 05 00 00 00       	call   8002b5 <vprintfmt>
	va_end(ap);
  8002b0:	83 c4 10             	add    $0x10,%esp
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 2c             	sub    $0x2c,%esp
  8002be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002c1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c4:	eb 13                	jmp    8002d9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	0f 84 6d 03 00 00    	je     80063b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002ce:	83 ec 08             	sub    $0x8,%esp
  8002d1:	57                   	push   %edi
  8002d2:	50                   	push   %eax
  8002d3:	ff 55 08             	call   *0x8(%ebp)
  8002d6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d9:	0f b6 06             	movzbl (%esi),%eax
  8002dc:	46                   	inc    %esi
  8002dd:	83 f8 25             	cmp    $0x25,%eax
  8002e0:	75 e4                	jne    8002c6 <vprintfmt+0x11>
  8002e2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002e6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002ed:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002f4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800300:	eb 28                	jmp    80032a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800302:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800304:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800308:	eb 20                	jmp    80032a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800310:	eb 18                	jmp    80032a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800314:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80031b:	eb 0d                	jmp    80032a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80031d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8a 06                	mov    (%esi),%al
  80032c:	0f b6 d0             	movzbl %al,%edx
  80032f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800332:	83 e8 23             	sub    $0x23,%eax
  800335:	3c 55                	cmp    $0x55,%al
  800337:	0f 87 e0 02 00 00    	ja     80061d <vprintfmt+0x368>
  80033d:	0f b6 c0             	movzbl %al,%eax
  800340:	ff 24 85 b4 0e 80 00 	jmp    *0x800eb4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800347:	83 ea 30             	sub    $0x30,%edx
  80034a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80034d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800350:	8d 50 d0             	lea    -0x30(%eax),%edx
  800353:	83 fa 09             	cmp    $0x9,%edx
  800356:	77 44                	ja     80039c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	89 de                	mov    %ebx,%esi
  80035a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80035e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800361:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800365:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800368:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80036b:	83 fb 09             	cmp    $0x9,%ebx
  80036e:	76 ed                	jbe    80035d <vprintfmt+0xa8>
  800370:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800373:	eb 29                	jmp    80039e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 50 04             	lea    0x4(%eax),%edx
  80037b:	89 55 14             	mov    %edx,0x14(%ebp)
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800385:	eb 17                	jmp    80039e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800387:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038b:	78 85                	js     800312 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	89 de                	mov    %ebx,%esi
  80038f:	eb 99                	jmp    80032a <vprintfmt+0x75>
  800391:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800393:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80039a:	eb 8e                	jmp    80032a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80039e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a2:	79 86                	jns    80032a <vprintfmt+0x75>
  8003a4:	e9 74 ff ff ff       	jmp    80031d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi
  8003ac:	e9 79 ff ff ff       	jmp    80032a <vprintfmt+0x75>
  8003b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	57                   	push   %edi
  8003c1:	ff 30                	pushl  (%eax)
  8003c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cc:	e9 08 ff ff ff       	jmp    8002d9 <vprintfmt+0x24>
  8003d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	79 02                	jns    8003e5 <vprintfmt+0x130>
  8003e3:	f7 d8                	neg    %eax
  8003e5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e7:	83 f8 06             	cmp    $0x6,%eax
  8003ea:	7f 0b                	jg     8003f7 <vprintfmt+0x142>
  8003ec:	8b 04 85 0c 10 80 00 	mov    0x80100c(,%eax,4),%eax
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	75 1a                	jne    800411 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003f7:	52                   	push   %edx
  8003f8:	68 3c 0e 80 00       	push   $0x800e3c
  8003fd:	57                   	push   %edi
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 92 fe ff ff       	call   800298 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 c8 fe ff ff       	jmp    8002d9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800411:	50                   	push   %eax
  800412:	68 45 0e 80 00       	push   $0x800e45
  800417:	57                   	push   %edi
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	e8 78 fe ff ff       	call   800298 <printfmt>
  800420:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800426:	e9 ae fe ff ff       	jmp    8002d9 <vprintfmt+0x24>
  80042b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80042e:	89 de                	mov    %ebx,%esi
  800430:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800433:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800444:	85 c0                	test   %eax,%eax
  800446:	75 07                	jne    80044f <vprintfmt+0x19a>
				p = "(null)";
  800448:	c7 45 d0 35 0e 80 00 	movl   $0x800e35,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80044f:	85 db                	test   %ebx,%ebx
  800451:	7e 42                	jle    800495 <vprintfmt+0x1e0>
  800453:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800457:	74 3c                	je     800495 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	51                   	push   %ecx
  80045d:	ff 75 d0             	pushl  -0x30(%ebp)
  800460:	e8 6f 02 00 00       	call   8006d4 <strnlen>
  800465:	29 c3                	sub    %eax,%ebx
  800467:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7e 24                	jle    800495 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800471:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800475:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800478:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	57                   	push   %edi
  80047f:	53                   	push   %ebx
  800480:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	4e                   	dec    %esi
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	85 f6                	test   %esi,%esi
  800489:	7f f0                	jg     80047b <vprintfmt+0x1c6>
  80048b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80048e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800495:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800498:	0f be 02             	movsbl (%edx),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	75 47                	jne    8004e6 <vprintfmt+0x231>
  80049f:	eb 37                	jmp    8004d8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a5:	74 16                	je     8004bd <vprintfmt+0x208>
  8004a7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004aa:	83 fa 5e             	cmp    $0x5e,%edx
  8004ad:	76 0e                	jbe    8004bd <vprintfmt+0x208>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	57                   	push   %edi
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0b                	jmp    8004c8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	57                   	push   %edi
  8004c1:	50                   	push   %eax
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004cb:	0f be 03             	movsbl (%ebx),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 03                	je     8004d5 <vprintfmt+0x220>
  8004d2:	43                   	inc    %ebx
  8004d3:	eb 1b                	jmp    8004f0 <vprintfmt+0x23b>
  8004d5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004dc:	7f 1e                	jg     8004fc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e1:	e9 f3 fd ff ff       	jmp    8002d9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004e9:	43                   	inc    %ebx
  8004ea:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004ed:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004f0:	85 f6                	test   %esi,%esi
  8004f2:	78 ad                	js     8004a1 <vprintfmt+0x1ec>
  8004f4:	4e                   	dec    %esi
  8004f5:	79 aa                	jns    8004a1 <vprintfmt+0x1ec>
  8004f7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004fa:	eb dc                	jmp    8004d8 <vprintfmt+0x223>
  8004fc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	57                   	push   %edi
  800503:	6a 20                	push   $0x20
  800505:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800508:	4b                   	dec    %ebx
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	7f ef                	jg     8004ff <vprintfmt+0x24a>
  800510:	e9 c4 fd ff ff       	jmp    8002d9 <vprintfmt+0x24>
  800515:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800518:	89 ca                	mov    %ecx,%edx
  80051a:	8d 45 14             	lea    0x14(%ebp),%eax
  80051d:	e8 2a fd ff ff       	call   80024c <getint>
  800522:	89 c3                	mov    %eax,%ebx
  800524:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800526:	85 d2                	test   %edx,%edx
  800528:	78 0a                	js     800534 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80052a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052f:	e9 b0 00 00 00       	jmp    8005e4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	57                   	push   %edi
  800538:	6a 2d                	push   $0x2d
  80053a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80053d:	f7 db                	neg    %ebx
  80053f:	83 d6 00             	adc    $0x0,%esi
  800542:	f7 de                	neg    %esi
  800544:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054c:	e9 93 00 00 00       	jmp    8005e4 <vprintfmt+0x32f>
  800551:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800554:	89 ca                	mov    %ecx,%edx
  800556:	8d 45 14             	lea    0x14(%ebp),%eax
  800559:	e8 b4 fc ff ff       	call   800212 <getuint>
  80055e:	89 c3                	mov    %eax,%ebx
  800560:	89 d6                	mov    %edx,%esi
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800567:	eb 7b                	jmp    8005e4 <vprintfmt+0x32f>
  800569:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80056c:	89 ca                	mov    %ecx,%edx
  80056e:	8d 45 14             	lea    0x14(%ebp),%eax
  800571:	e8 d6 fc ff ff       	call   80024c <getint>
  800576:	89 c3                	mov    %eax,%ebx
  800578:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80057a:	85 d2                	test   %edx,%edx
  80057c:	78 07                	js     800585 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80057e:	b8 08 00 00 00       	mov    $0x8,%eax
  800583:	eb 5f                	jmp    8005e4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	57                   	push   %edi
  800589:	6a 2d                	push   $0x2d
  80058b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80058e:	f7 db                	neg    %ebx
  800590:	83 d6 00             	adc    $0x0,%esi
  800593:	f7 de                	neg    %esi
  800595:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800598:	b8 08 00 00 00       	mov    $0x8,%eax
  80059d:	eb 45                	jmp    8005e4 <vprintfmt+0x32f>
  80059f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	57                   	push   %edi
  8005a6:	6a 30                	push   $0x30
  8005a8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ab:	83 c4 08             	add    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	6a 78                	push   $0x78
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bd:	8b 18                	mov    (%eax),%ebx
  8005bf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005cc:	eb 16                	jmp    8005e4 <vprintfmt+0x32f>
  8005ce:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d1:	89 ca                	mov    %ecx,%edx
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 37 fc ff ff       	call   800212 <getuint>
  8005db:	89 c3                	mov    %eax,%ebx
  8005dd:	89 d6                	mov    %edx,%esi
			base = 16;
  8005df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005eb:	52                   	push   %edx
  8005ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ef:	50                   	push   %eax
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	89 fa                	mov    %edi,%edx
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	e8 68 fb ff ff       	call   800164 <printnum>
			break;
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800602:	e9 d2 fc ff ff       	jmp    8002d9 <vprintfmt+0x24>
  800607:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	57                   	push   %edi
  80060e:	52                   	push   %edx
  80060f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800612:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800618:	e9 bc fc ff ff       	jmp    8002d9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 25                	push   $0x25
  800623:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 02                	jmp    80062d <vprintfmt+0x378>
  80062b:	89 c6                	mov    %eax,%esi
  80062d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800630:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800634:	75 f5                	jne    80062b <vprintfmt+0x376>
  800636:	e9 9e fc ff ff       	jmp    8002d9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80063b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	83 ec 18             	sub    $0x18,%esp
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800652:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800656:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800659:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800660:	85 c0                	test   %eax,%eax
  800662:	74 26                	je     80068a <vsnprintf+0x47>
  800664:	85 d2                	test   %edx,%edx
  800666:	7e 29                	jle    800691 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800668:	ff 75 14             	pushl  0x14(%ebp)
  80066b:	ff 75 10             	pushl  0x10(%ebp)
  80066e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	68 7e 02 80 00       	push   $0x80027e
  800677:	e8 39 fc ff ff       	call   8002b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	eb 0c                	jmp    800696 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068f:	eb 05                	jmp    800696 <vsnprintf+0x53>
  800691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800696:	c9                   	leave  
  800697:	c3                   	ret    

00800698 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 10             	pushl  0x10(%ebp)
  8006a5:	ff 75 0c             	pushl  0xc(%ebp)
  8006a8:	ff 75 08             	pushl  0x8(%ebp)
  8006ab:	e8 93 ff ff ff       	call   800643 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    
	...

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ba:	80 3a 00             	cmpb   $0x0,(%edx)
  8006bd:	74 0e                	je     8006cd <strlen+0x19>
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006c4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c9:	75 f9                	jne    8006c4 <strlen+0x10>
  8006cb:	eb 05                	jmp    8006d2 <strlen+0x1e>
  8006cd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006da:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	74 17                	je     8006f8 <strnlen+0x24>
  8006e1:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e4:	74 19                	je     8006ff <strnlen+0x2b>
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006eb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ec:	39 d0                	cmp    %edx,%eax
  8006ee:	74 14                	je     800704 <strnlen+0x30>
  8006f0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f4:	75 f5                	jne    8006eb <strnlen+0x17>
  8006f6:	eb 0c                	jmp    800704 <strnlen+0x30>
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	eb 05                	jmp    800704 <strnlen+0x30>
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	53                   	push   %ebx
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800710:	ba 00 00 00 00       	mov    $0x0,%edx
  800715:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800718:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80071b:	42                   	inc    %edx
  80071c:	84 c9                	test   %cl,%cl
  80071e:	75 f5                	jne    800715 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800720:	5b                   	pop    %ebx
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072a:	53                   	push   %ebx
  80072b:	e8 84 ff ff ff       	call   8006b4 <strlen>
  800730:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800739:	50                   	push   %eax
  80073a:	e8 c7 ff ff ff       	call   800706 <strcpy>
	return dst;
}
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	56                   	push   %esi
  80074a:	53                   	push   %ebx
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800751:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800754:	85 f6                	test   %esi,%esi
  800756:	74 15                	je     80076d <strncpy+0x27>
  800758:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80075d:	8a 1a                	mov    (%edx),%bl
  80075f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800762:	80 3a 01             	cmpb   $0x1,(%edx)
  800765:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	41                   	inc    %ecx
  800769:	39 ce                	cmp    %ecx,%esi
  80076b:	77 f0                	ja     80075d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	57                   	push   %edi
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800780:	85 f6                	test   %esi,%esi
  800782:	74 32                	je     8007b6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800784:	83 fe 01             	cmp    $0x1,%esi
  800787:	74 22                	je     8007ab <strlcpy+0x3a>
  800789:	8a 0b                	mov    (%ebx),%cl
  80078b:	84 c9                	test   %cl,%cl
  80078d:	74 20                	je     8007af <strlcpy+0x3e>
  80078f:	89 f8                	mov    %edi,%eax
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800796:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800799:	88 08                	mov    %cl,(%eax)
  80079b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079c:	39 f2                	cmp    %esi,%edx
  80079e:	74 11                	je     8007b1 <strlcpy+0x40>
  8007a0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007a4:	42                   	inc    %edx
  8007a5:	84 c9                	test   %cl,%cl
  8007a7:	75 f0                	jne    800799 <strlcpy+0x28>
  8007a9:	eb 06                	jmp    8007b1 <strlcpy+0x40>
  8007ab:	89 f8                	mov    %edi,%eax
  8007ad:	eb 02                	jmp    8007b1 <strlcpy+0x40>
  8007af:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b1:	c6 00 00             	movb   $0x0,(%eax)
  8007b4:	eb 02                	jmp    8007b8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007b8:	29 f8                	sub    %edi,%eax
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5f                   	pop    %edi
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c8:	8a 01                	mov    (%ecx),%al
  8007ca:	84 c0                	test   %al,%al
  8007cc:	74 10                	je     8007de <strcmp+0x1f>
  8007ce:	3a 02                	cmp    (%edx),%al
  8007d0:	75 0c                	jne    8007de <strcmp+0x1f>
		p++, q++;
  8007d2:	41                   	inc    %ecx
  8007d3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d4:	8a 01                	mov    (%ecx),%al
  8007d6:	84 c0                	test   %al,%al
  8007d8:	74 04                	je     8007de <strcmp+0x1f>
  8007da:	3a 02                	cmp    (%edx),%al
  8007dc:	74 f4                	je     8007d2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007de:	0f b6 c0             	movzbl %al,%eax
  8007e1:	0f b6 12             	movzbl (%edx),%edx
  8007e4:	29 d0                	sub    %edx,%eax
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	74 1b                	je     800814 <strncmp+0x2c>
  8007f9:	8a 1a                	mov    (%edx),%bl
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	74 24                	je     800823 <strncmp+0x3b>
  8007ff:	3a 19                	cmp    (%ecx),%bl
  800801:	75 20                	jne    800823 <strncmp+0x3b>
  800803:	48                   	dec    %eax
  800804:	74 15                	je     80081b <strncmp+0x33>
		n--, p++, q++;
  800806:	42                   	inc    %edx
  800807:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800808:	8a 1a                	mov    (%edx),%bl
  80080a:	84 db                	test   %bl,%bl
  80080c:	74 15                	je     800823 <strncmp+0x3b>
  80080e:	3a 19                	cmp    (%ecx),%bl
  800810:	74 f1                	je     800803 <strncmp+0x1b>
  800812:	eb 0f                	jmp    800823 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
  800819:	eb 05                	jmp    800820 <strncmp+0x38>
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800820:	5b                   	pop    %ebx
  800821:	c9                   	leave  
  800822:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 02             	movzbl (%edx),%eax
  800826:	0f b6 11             	movzbl (%ecx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb f3                	jmp    800820 <strncmp+0x38>

0080082d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800836:	8a 10                	mov    (%eax),%dl
  800838:	84 d2                	test   %dl,%dl
  80083a:	74 18                	je     800854 <strchr+0x27>
		if (*s == c)
  80083c:	38 ca                	cmp    %cl,%dl
  80083e:	75 06                	jne    800846 <strchr+0x19>
  800840:	eb 17                	jmp    800859 <strchr+0x2c>
  800842:	38 ca                	cmp    %cl,%dl
  800844:	74 13                	je     800859 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800846:	40                   	inc    %eax
  800847:	8a 10                	mov    (%eax),%dl
  800849:	84 d2                	test   %dl,%dl
  80084b:	75 f5                	jne    800842 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	eb 05                	jmp    800859 <strchr+0x2c>
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800864:	8a 10                	mov    (%eax),%dl
  800866:	84 d2                	test   %dl,%dl
  800868:	74 11                	je     80087b <strfind+0x20>
		if (*s == c)
  80086a:	38 ca                	cmp    %cl,%dl
  80086c:	75 06                	jne    800874 <strfind+0x19>
  80086e:	eb 0b                	jmp    80087b <strfind+0x20>
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 07                	je     80087b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800874:	40                   	inc    %eax
  800875:	8a 10                	mov    (%eax),%dl
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f5                	jne    800870 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 45 0c             	mov    0xc(%ebp),%eax
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	74 30                	je     8008c0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800890:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800896:	75 25                	jne    8008bd <memset+0x40>
  800898:	f6 c1 03             	test   $0x3,%cl
  80089b:	75 20                	jne    8008bd <memset+0x40>
		c &= 0xFF;
  80089d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a0:	89 d3                	mov    %edx,%ebx
  8008a2:	c1 e3 08             	shl    $0x8,%ebx
  8008a5:	89 d6                	mov    %edx,%esi
  8008a7:	c1 e6 18             	shl    $0x18,%esi
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	c1 e0 10             	shl    $0x10,%eax
  8008af:	09 f0                	or     %esi,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b8:	fc                   	cld    
  8008b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bb:	eb 03                	jmp    8008c0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bd:	fc                   	cld    
  8008be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c0:	89 f8                	mov    %edi,%eax
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d5:	39 c6                	cmp    %eax,%esi
  8008d7:	73 34                	jae    80090d <memmove+0x46>
  8008d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dc:	39 d0                	cmp    %edx,%eax
  8008de:	73 2d                	jae    80090d <memmove+0x46>
		s += n;
		d += n;
  8008e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e3:	f6 c2 03             	test   $0x3,%dl
  8008e6:	75 1b                	jne    800903 <memmove+0x3c>
  8008e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ee:	75 13                	jne    800903 <memmove+0x3c>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 07                	jmp    80090a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800903:	4f                   	dec    %edi
  800904:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800907:	fd                   	std    
  800908:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090a:	fc                   	cld    
  80090b:	eb 20                	jmp    80092d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800913:	75 13                	jne    800928 <memmove+0x61>
  800915:	a8 03                	test   $0x3,%al
  800917:	75 0f                	jne    800928 <memmove+0x61>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0a                	jne    800928 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 05                	jmp    80092d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800928:	89 c7                	mov    %eax,%edi
  80092a:	fc                   	cld    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800934:	ff 75 10             	pushl  0x10(%ebp)
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	e8 85 ff ff ff       	call   8008c7 <memmove>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800950:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	85 ff                	test   %edi,%edi
  800955:	74 32                	je     800989 <memcmp+0x45>
		if (*s1 != *s2)
  800957:	8a 03                	mov    (%ebx),%al
  800959:	8a 0e                	mov    (%esi),%cl
  80095b:	38 c8                	cmp    %cl,%al
  80095d:	74 19                	je     800978 <memcmp+0x34>
  80095f:	eb 0d                	jmp    80096e <memcmp+0x2a>
  800961:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800965:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800969:	42                   	inc    %edx
  80096a:	38 c8                	cmp    %cl,%al
  80096c:	74 10                	je     80097e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c0             	movzbl %al,%eax
  800971:	0f b6 c9             	movzbl %cl,%ecx
  800974:	29 c8                	sub    %ecx,%eax
  800976:	eb 16                	jmp    80098e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	4f                   	dec    %edi
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
  80097e:	39 fa                	cmp    %edi,%edx
  800980:	75 df                	jne    800961 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
  800987:	eb 05                	jmp    80098e <memcmp+0x4a>
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800999:	89 c2                	mov    %eax,%edx
  80099b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099e:	39 d0                	cmp    %edx,%eax
  8009a0:	73 12                	jae    8009b4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009a5:	38 08                	cmp    %cl,(%eax)
  8009a7:	75 06                	jne    8009af <memfind+0x1c>
  8009a9:	eb 09                	jmp    8009b4 <memfind+0x21>
  8009ab:	38 08                	cmp    %cl,(%eax)
  8009ad:	74 05                	je     8009b4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	40                   	inc    %eax
  8009b0:	39 c2                	cmp    %eax,%edx
  8009b2:	77 f7                	ja     8009ab <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c2:	eb 01                	jmp    8009c5 <strtol+0xf>
		s++;
  8009c4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	8a 02                	mov    (%edx),%al
  8009c7:	3c 20                	cmp    $0x20,%al
  8009c9:	74 f9                	je     8009c4 <strtol+0xe>
  8009cb:	3c 09                	cmp    $0x9,%al
  8009cd:	74 f5                	je     8009c4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cf:	3c 2b                	cmp    $0x2b,%al
  8009d1:	75 08                	jne    8009db <strtol+0x25>
		s++;
  8009d3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d9:	eb 13                	jmp    8009ee <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009db:	3c 2d                	cmp    $0x2d,%al
  8009dd:	75 0a                	jne    8009e9 <strtol+0x33>
		s++, neg = 1;
  8009df:	8d 52 01             	lea    0x1(%edx),%edx
  8009e2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e7:	eb 05                	jmp    8009ee <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	74 05                	je     8009f7 <strtol+0x41>
  8009f2:	83 fb 10             	cmp    $0x10,%ebx
  8009f5:	75 28                	jne    800a1f <strtol+0x69>
  8009f7:	8a 02                	mov    (%edx),%al
  8009f9:	3c 30                	cmp    $0x30,%al
  8009fb:	75 10                	jne    800a0d <strtol+0x57>
  8009fd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a01:	75 0a                	jne    800a0d <strtol+0x57>
		s += 2, base = 16;
  800a03:	83 c2 02             	add    $0x2,%edx
  800a06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0b:	eb 12                	jmp    800a1f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a0d:	85 db                	test   %ebx,%ebx
  800a0f:	75 0e                	jne    800a1f <strtol+0x69>
  800a11:	3c 30                	cmp    $0x30,%al
  800a13:	75 05                	jne    800a1a <strtol+0x64>
		s++, base = 8;
  800a15:	42                   	inc    %edx
  800a16:	b3 08                	mov    $0x8,%bl
  800a18:	eb 05                	jmp    800a1f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a26:	8a 0a                	mov    (%edx),%cl
  800a28:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a2b:	80 fb 09             	cmp    $0x9,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0x82>
			dig = *s - '0';
  800a30:	0f be c9             	movsbl %cl,%ecx
  800a33:	83 e9 30             	sub    $0x30,%ecx
  800a36:	eb 1e                	jmp    800a56 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a38:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a3b:	80 fb 19             	cmp    $0x19,%bl
  800a3e:	77 08                	ja     800a48 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a40:	0f be c9             	movsbl %cl,%ecx
  800a43:	83 e9 57             	sub    $0x57,%ecx
  800a46:	eb 0e                	jmp    800a56 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a48:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a4b:	80 fb 19             	cmp    $0x19,%bl
  800a4e:	77 13                	ja     800a63 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a50:	0f be c9             	movsbl %cl,%ecx
  800a53:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a56:	39 f1                	cmp    %esi,%ecx
  800a58:	7d 0d                	jge    800a67 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a5a:	42                   	inc    %edx
  800a5b:	0f af c6             	imul   %esi,%eax
  800a5e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a61:	eb c3                	jmp    800a26 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a63:	89 c1                	mov    %eax,%ecx
  800a65:	eb 02                	jmp    800a69 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a67:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6d:	74 05                	je     800a74 <strtol+0xbe>
		*endptr = (char *) s;
  800a6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a72:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a74:	85 ff                	test   %edi,%edi
  800a76:	74 04                	je     800a7c <strtol+0xc6>
  800a78:	89 c8                	mov    %ecx,%eax
  800a7a:	f7 d8                	neg    %eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    
  800a81:	00 00                	add    %al,(%eax)
	...

00800a84 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 1c             	sub    $0x1c,%esp
  800a8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a90:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a93:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a95:	8b 75 14             	mov    0x14(%ebp),%esi
  800a98:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	cd 30                	int    $0x30
  800aa3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aa9:	74 1c                	je     800ac7 <syscall+0x43>
  800aab:	85 c0                	test   %eax,%eax
  800aad:	7e 18                	jle    800ac7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aaf:	83 ec 0c             	sub    $0xc,%esp
  800ab2:	50                   	push   %eax
  800ab3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ab6:	68 28 10 80 00       	push   $0x801028
  800abb:	6a 42                	push   $0x42
  800abd:	68 45 10 80 00       	push   $0x801045
  800ac2:	e8 9d 00 00 00       	call   800b64 <_panic>

	return ret;
}
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ad7:	6a 00                	push   $0x0
  800ad9:	6a 00                	push   $0x0
  800adb:	6a 00                	push   $0x0
  800add:	ff 75 0c             	pushl  0xc(%ebp)
  800ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	e8 92 ff ff ff       	call   800a84 <syscall>
  800af2:	83 c4 10             	add    $0x10,%esp
	return;
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800afd:	6a 00                	push   $0x0
  800aff:	6a 00                	push   $0x0
  800b01:	6a 00                	push   $0x0
  800b03:	6a 00                	push   $0x0
  800b05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	e8 6b ff ff ff       	call   800a84 <syscall>
}
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	6a 00                	push   $0x0
  800b27:	6a 00                	push   $0x0
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	e8 49 ff ff ff       	call   800a84 <syscall>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5a:	e8 25 ff ff ff       	call   800a84 <syscall>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    
  800b61:	00 00                	add    %al,(%eax)
	...

00800b64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b69:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b6c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b72:	e8 c6 ff ff ff       	call   800b3d <sys_getenvid>
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	ff 75 0c             	pushl  0xc(%ebp)
  800b7d:	ff 75 08             	pushl  0x8(%ebp)
  800b80:	53                   	push   %ebx
  800b81:	50                   	push   %eax
  800b82:	68 54 10 80 00       	push   $0x801054
  800b87:	e8 c4 f5 ff ff       	call   800150 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b8c:	83 c4 18             	add    $0x18,%esp
  800b8f:	56                   	push   %esi
  800b90:	ff 75 10             	pushl  0x10(%ebp)
  800b93:	e8 67 f5 ff ff       	call   8000ff <vcprintf>
	cprintf("\n");
  800b98:	c7 04 24 01 0e 80 00 	movl   $0x800e01,(%esp)
  800b9f:	e8 ac f5 ff ff       	call   800150 <cprintf>
  800ba4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ba7:	cc                   	int3   
  800ba8:	eb fd                	jmp    800ba7 <_panic+0x43>
	...

00800bac <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	83 ec 10             	sub    $0x10,%esp
  800bb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bba:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bc0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bc3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	75 2e                	jne    800bf8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bca:	39 f1                	cmp    %esi,%ecx
  800bcc:	77 5a                	ja     800c28 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bce:	85 c9                	test   %ecx,%ecx
  800bd0:	75 0b                	jne    800bdd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd7:	31 d2                	xor    %edx,%edx
  800bd9:	f7 f1                	div    %ecx
  800bdb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bdd:	31 d2                	xor    %edx,%edx
  800bdf:	89 f0                	mov    %esi,%eax
  800be1:	f7 f1                	div    %ecx
  800be3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800be5:	89 f8                	mov    %edi,%eax
  800be7:	f7 f1                	div    %ecx
  800be9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800beb:	89 f8                	mov    %edi,%eax
  800bed:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	c9                   	leave  
  800bf5:	c3                   	ret    
  800bf6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bf8:	39 f0                	cmp    %esi,%eax
  800bfa:	77 1c                	ja     800c18 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800bfc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bff:	83 f7 1f             	xor    $0x1f,%edi
  800c02:	75 3c                	jne    800c40 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c04:	39 f0                	cmp    %esi,%eax
  800c06:	0f 82 90 00 00 00    	jb     800c9c <__udivdi3+0xf0>
  800c0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c0f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c12:	0f 86 84 00 00 00    	jbe    800c9c <__udivdi3+0xf0>
  800c18:	31 f6                	xor    %esi,%esi
  800c1a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c1c:	89 f8                	mov    %edi,%eax
  800c1e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    
  800c27:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c28:	89 f2                	mov    %esi,%edx
  800c2a:	89 f8                	mov    %edi,%eax
  800c2c:	f7 f1                	div    %ecx
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c32:	89 f8                	mov    %edi,%eax
  800c34:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    
  800c3d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c40:	89 f9                	mov    %edi,%ecx
  800c42:	d3 e0                	shl    %cl,%eax
  800c44:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c47:	b8 20 00 00 00       	mov    $0x20,%eax
  800c4c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c51:	88 c1                	mov    %al,%cl
  800c53:	d3 ea                	shr    %cl,%edx
  800c55:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c58:	09 ca                	or     %ecx,%edx
  800c5a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c60:	89 f9                	mov    %edi,%ecx
  800c62:	d3 e2                	shl    %cl,%edx
  800c64:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c67:	89 f2                	mov    %esi,%edx
  800c69:	88 c1                	mov    %al,%cl
  800c6b:	d3 ea                	shr    %cl,%edx
  800c6d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c70:	89 f2                	mov    %esi,%edx
  800c72:	89 f9                	mov    %edi,%ecx
  800c74:	d3 e2                	shl    %cl,%edx
  800c76:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c79:	88 c1                	mov    %al,%cl
  800c7b:	d3 ee                	shr    %cl,%esi
  800c7d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c7f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	89 ca                	mov    %ecx,%edx
  800c86:	f7 75 ec             	divl   -0x14(%ebp)
  800c89:	89 d1                	mov    %edx,%ecx
  800c8b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c8d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c90:	39 d1                	cmp    %edx,%ecx
  800c92:	72 28                	jb     800cbc <__udivdi3+0x110>
  800c94:	74 1a                	je     800cb0 <__udivdi3+0x104>
  800c96:	89 f7                	mov    %esi,%edi
  800c98:	31 f6                	xor    %esi,%esi
  800c9a:	eb 80                	jmp    800c1c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c9c:	31 f6                	xor    %esi,%esi
  800c9e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    
  800cae:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cb3:	89 f9                	mov    %edi,%ecx
  800cb5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cb7:	39 c2                	cmp    %eax,%edx
  800cb9:	73 db                	jae    800c96 <__udivdi3+0xea>
  800cbb:	90                   	nop
		{
		  q0--;
  800cbc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cbf:	31 f6                	xor    %esi,%esi
  800cc1:	e9 56 ff ff ff       	jmp    800c1c <__udivdi3+0x70>
	...

00800cc8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	83 ec 20             	sub    $0x20,%esp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cdc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ce5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ce7:	85 ff                	test   %edi,%edi
  800ce9:	75 15                	jne    800d00 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800ceb:	39 f1                	cmp    %esi,%ecx
  800ced:	0f 86 99 00 00 00    	jbe    800d8c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cf5:	89 d0                	mov    %edx,%eax
  800cf7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800cf9:	83 c4 20             	add    $0x20,%esp
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d00:	39 f7                	cmp    %esi,%edi
  800d02:	0f 87 a4 00 00 00    	ja     800dac <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d08:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d0b:	83 f0 1f             	xor    $0x1f,%eax
  800d0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d11:	0f 84 a1 00 00 00    	je     800db8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d17:	89 f8                	mov    %edi,%eax
  800d19:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d1e:	bf 20 00 00 00       	mov    $0x20,%edi
  800d23:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	d3 ea                	shr    %cl,%edx
  800d2d:	09 c2                	or     %eax,%edx
  800d2f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d35:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d38:	d3 e0                	shl    %cl,%eax
  800d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d3d:	89 f2                	mov    %esi,%edx
  800d3f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d44:	d3 e0                	shl    %cl,%eax
  800d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d4c:	89 f9                	mov    %edi,%ecx
  800d4e:	d3 e8                	shr    %cl,%eax
  800d50:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d52:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d54:	89 f2                	mov    %esi,%edx
  800d56:	f7 75 f0             	divl   -0x10(%ebp)
  800d59:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d5b:	f7 65 f4             	mull   -0xc(%ebp)
  800d5e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d61:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d63:	39 d6                	cmp    %edx,%esi
  800d65:	72 71                	jb     800dd8 <__umoddi3+0x110>
  800d67:	74 7f                	je     800de8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6c:	29 c8                	sub    %ecx,%eax
  800d6e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d70:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d73:	d3 e8                	shr    %cl,%eax
  800d75:	89 f2                	mov    %esi,%edx
  800d77:	89 f9                	mov    %edi,%ecx
  800d79:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d7b:	09 d0                	or     %edx,%eax
  800d7d:	89 f2                	mov    %esi,%edx
  800d7f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d82:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d84:	83 c4 20             	add    $0x20,%esp
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    
  800d8b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d8c:	85 c9                	test   %ecx,%ecx
  800d8e:	75 0b                	jne    800d9b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d90:	b8 01 00 00 00       	mov    $0x1,%eax
  800d95:	31 d2                	xor    %edx,%edx
  800d97:	f7 f1                	div    %ecx
  800d99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da4:	f7 f1                	div    %ecx
  800da6:	e9 4a ff ff ff       	jmp    800cf5 <__umoddi3+0x2d>
  800dab:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dae:	83 c4 20             	add    $0x20,%esp
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db8:	39 f7                	cmp    %esi,%edi
  800dba:	72 05                	jb     800dc1 <__umoddi3+0xf9>
  800dbc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dbf:	77 0c                	ja     800dcd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc1:	89 f2                	mov    %esi,%edx
  800dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc6:	29 c8                	sub    %ecx,%eax
  800dc8:	19 fa                	sbb    %edi,%edx
  800dca:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    
  800dd7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dd8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800de0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800de3:	eb 84                	jmp    800d69 <__umoddi3+0xa1>
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800deb:	72 eb                	jb     800dd8 <__umoddi3+0x110>
  800ded:	89 f2                	mov    %esi,%edx
  800def:	e9 75 ff ff ff       	jmp    800d69 <__umoddi3+0xa1>
