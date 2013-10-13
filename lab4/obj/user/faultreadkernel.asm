
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800040:	68 20 0f 80 00       	push   $0x800f20
  800045:	e8 fa 00 00 00       	call   800144 <cprintf>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005b:	e8 d1 0a 00 00       	call   800b31 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	53                   	push   %ebx
  80008a:	56                   	push   %esi
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 62 0a 00 00       	call   800b0f <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000be:	8b 03                	mov    (%ebx),%eax
  8000c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c7:	40                   	inc    %eax
  8000c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cf:	75 1a                	jne    8000eb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	68 ff 00 00 00       	push   $0xff
  8000d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 e3 09 00 00       	call   800ac5 <sys_cputs>
		b->idx = 0;
  8000e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000eb:	ff 43 04             	incl   0x4(%ebx)
}
  8000ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
	b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800110:	ff 75 0c             	pushl  0xc(%ebp)
  800113:	ff 75 08             	pushl  0x8(%ebp)
  800116:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011c:	50                   	push   %eax
  80011d:	68 b4 00 80 00       	push   $0x8000b4
  800122:	e8 82 01 00 00       	call   8002a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800127:	83 c4 08             	add    $0x8,%esp
  80012a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800130:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800136:	50                   	push   %eax
  800137:	e8 89 09 00 00       	call   800ac5 <sys_cputs>

	return b.cnt;
}
  80013c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014d:	50                   	push   %eax
  80014e:	ff 75 08             	pushl  0x8(%ebp)
  800151:	e8 9d ff ff ff       	call   8000f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	83 ec 2c             	sub    $0x2c,%esp
  800161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800164:	89 d6                	mov    %edx,%esi
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800172:	8b 45 10             	mov    0x10(%ebp),%eax
  800175:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800178:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80017e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800185:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800188:	72 0c                	jb     800196 <printnum+0x3e>
  80018a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80018d:	76 07                	jbe    800196 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80018f:	4b                   	dec    %ebx
  800190:	85 db                	test   %ebx,%ebx
  800192:	7f 31                	jg     8001c5 <printnum+0x6d>
  800194:	eb 3f                	jmp    8001d5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	57                   	push   %edi
  80019a:	4b                   	dec    %ebx
  80019b:	53                   	push   %ebx
  80019c:	50                   	push   %eax
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8001a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ac:	e8 0f 0b 00 00       	call   800cc0 <__udivdi3>
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	89 f2                	mov    %esi,%edx
  8001b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001bb:	e8 98 ff ff ff       	call   800158 <printnum>
  8001c0:	83 c4 20             	add    $0x20,%esp
  8001c3:	eb 10                	jmp    8001d5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	56                   	push   %esi
  8001c9:	57                   	push   %edi
  8001ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	4b                   	dec    %ebx
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 db                	test   %ebx,%ebx
  8001d3:	7f f0                	jg     8001c5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d5:	83 ec 08             	sub    $0x8,%esp
  8001d8:	56                   	push   %esi
  8001d9:	83 ec 04             	sub    $0x4,%esp
  8001dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001df:	ff 75 d0             	pushl  -0x30(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 ef 0b 00 00       	call   800ddc <__umoddi3>
  8001ed:	83 c4 14             	add    $0x14,%esp
  8001f0:	0f be 80 51 0f 80 00 	movsbl 0x800f51(%eax),%eax
  8001f7:	50                   	push   %eax
  8001f8:	ff 55 e4             	call   *-0x1c(%ebp)
  8001fb:	83 c4 10             	add    $0x10,%esp
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800209:	83 fa 01             	cmp    $0x1,%edx
  80020c:	7e 0e                	jle    80021c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	8d 4a 08             	lea    0x8(%edx),%ecx
  800213:	89 08                	mov    %ecx,(%eax)
  800215:	8b 02                	mov    (%edx),%eax
  800217:	8b 52 04             	mov    0x4(%edx),%edx
  80021a:	eb 22                	jmp    80023e <getuint+0x38>
	else if (lflag)
  80021c:	85 d2                	test   %edx,%edx
  80021e:	74 10                	je     800230 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800220:	8b 10                	mov    (%eax),%edx
  800222:	8d 4a 04             	lea    0x4(%edx),%ecx
  800225:	89 08                	mov    %ecx,(%eax)
  800227:	8b 02                	mov    (%edx),%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	eb 0e                	jmp    80023e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800243:	83 fa 01             	cmp    $0x1,%edx
  800246:	7e 0e                	jle    800256 <getint+0x16>
		return va_arg(*ap, long long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	8b 52 04             	mov    0x4(%edx),%edx
  800254:	eb 1a                	jmp    800270 <getint+0x30>
	else if (lflag)
  800256:	85 d2                	test   %edx,%edx
  800258:	74 0c                	je     800266 <getint+0x26>
		return va_arg(*ap, long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	99                   	cltd   
  800264:	eb 0a                	jmp    800270 <getint+0x30>
	else
		return va_arg(*ap, int);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	99                   	cltd   
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800278:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 08                	jae    80028a <sprintputch+0x18>
		*b->buf++ = ch;
  800282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800285:	88 0a                	mov    %cl,(%edx)
  800287:	42                   	inc    %edx
  800288:	89 10                	mov    %edx,(%eax)
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 10             	pushl  0x10(%ebp)
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	e8 05 00 00 00       	call   8002a9 <vprintfmt>
	va_end(ap);
  8002a4:	83 c4 10             	add    $0x10,%esp
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 2c             	sub    $0x2c,%esp
  8002b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b5:	8b 75 10             	mov    0x10(%ebp),%esi
  8002b8:	eb 13                	jmp    8002cd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ba:	85 c0                	test   %eax,%eax
  8002bc:	0f 84 6d 03 00 00    	je     80062f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	57                   	push   %edi
  8002c6:	50                   	push   %eax
  8002c7:	ff 55 08             	call   *0x8(%ebp)
  8002ca:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cd:	0f b6 06             	movzbl (%esi),%eax
  8002d0:	46                   	inc    %esi
  8002d1:	83 f8 25             	cmp    $0x25,%eax
  8002d4:	75 e4                	jne    8002ba <vprintfmt+0x11>
  8002d6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002e1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f4:	eb 28                	jmp    80031e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8002fc:	eb 20                	jmp    80031e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800300:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800304:	eb 18                	jmp    80031e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800308:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80030f:	eb 0d                	jmp    80031e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800311:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800317:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8a 06                	mov    (%esi),%al
  800320:	0f b6 d0             	movzbl %al,%edx
  800323:	8d 5e 01             	lea    0x1(%esi),%ebx
  800326:	83 e8 23             	sub    $0x23,%eax
  800329:	3c 55                	cmp    $0x55,%al
  80032b:	0f 87 e0 02 00 00    	ja     800611 <vprintfmt+0x368>
  800331:	0f b6 c0             	movzbl %al,%eax
  800334:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033b:	83 ea 30             	sub    $0x30,%edx
  80033e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800341:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800344:	8d 50 d0             	lea    -0x30(%eax),%edx
  800347:	83 fa 09             	cmp    $0x9,%edx
  80034a:	77 44                	ja     800390 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	89 de                	mov    %ebx,%esi
  80034e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800351:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800352:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800355:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800359:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80035c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80035f:	83 fb 09             	cmp    $0x9,%ebx
  800362:	76 ed                	jbe    800351 <vprintfmt+0xa8>
  800364:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800367:	eb 29                	jmp    800392 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 50 04             	lea    0x4(%eax),%edx
  80036f:	89 55 14             	mov    %edx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800379:	eb 17                	jmp    800392 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80037b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80037f:	78 85                	js     800306 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	89 de                	mov    %ebx,%esi
  800383:	eb 99                	jmp    80031e <vprintfmt+0x75>
  800385:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800387:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80038e:	eb 8e                	jmp    80031e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800392:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800396:	79 86                	jns    80031e <vprintfmt+0x75>
  800398:	e9 74 ff ff ff       	jmp    800311 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	e9 79 ff ff ff       	jmp    80031e <vprintfmt+0x75>
  8003a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	57                   	push   %edi
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c0:	e9 08 ff ff ff       	jmp    8002cd <vprintfmt+0x24>
  8003c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	79 02                	jns    8003d9 <vprintfmt+0x130>
  8003d7:	f7 d8                	neg    %eax
  8003d9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003db:	83 f8 08             	cmp    $0x8,%eax
  8003de:	7f 0b                	jg     8003eb <vprintfmt+0x142>
  8003e0:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	75 1a                	jne    800405 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003eb:	52                   	push   %edx
  8003ec:	68 69 0f 80 00       	push   $0x800f69
  8003f1:	57                   	push   %edi
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 92 fe ff ff       	call   80028c <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 c8 fe ff ff       	jmp    8002cd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	50                   	push   %eax
  800406:	68 72 0f 80 00       	push   $0x800f72
  80040b:	57                   	push   %edi
  80040c:	ff 75 08             	pushl  0x8(%ebp)
  80040f:	e8 78 fe ff ff       	call   80028c <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80041a:	e9 ae fe ff ff       	jmp    8002cd <vprintfmt+0x24>
  80041f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800422:	89 de                	mov    %ebx,%esi
  800424:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800427:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 50 04             	lea    0x4(%eax),%edx
  800430:	89 55 14             	mov    %edx,0x14(%ebp)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 07                	jne    800443 <vprintfmt+0x19a>
				p = "(null)";
  80043c:	c7 45 d0 62 0f 80 00 	movl   $0x800f62,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800443:	85 db                	test   %ebx,%ebx
  800445:	7e 42                	jle    800489 <vprintfmt+0x1e0>
  800447:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80044b:	74 3c                	je     800489 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	51                   	push   %ecx
  800451:	ff 75 d0             	pushl  -0x30(%ebp)
  800454:	e8 6f 02 00 00       	call   8006c8 <strnlen>
  800459:	29 c3                	sub    %eax,%ebx
  80045b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	85 db                	test   %ebx,%ebx
  800463:	7e 24                	jle    800489 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800465:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800469:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80046c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	57                   	push   %edi
  800473:	53                   	push   %ebx
  800474:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	4e                   	dec    %esi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	85 f6                	test   %esi,%esi
  80047d:	7f f0                	jg     80046f <vprintfmt+0x1c6>
  80047f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800482:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800489:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048c:	0f be 02             	movsbl (%edx),%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	75 47                	jne    8004da <vprintfmt+0x231>
  800493:	eb 37                	jmp    8004cc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	74 16                	je     8004b1 <vprintfmt+0x208>
  80049b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80049e:	83 fa 5e             	cmp    $0x5e,%edx
  8004a1:	76 0e                	jbe    8004b1 <vprintfmt+0x208>
					putch('?', putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	57                   	push   %edi
  8004a7:	6a 3f                	push   $0x3f
  8004a9:	ff 55 08             	call   *0x8(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	eb 0b                	jmp    8004bc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	57                   	push   %edi
  8004b5:	50                   	push   %eax
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bc:	ff 4d e4             	decl   -0x1c(%ebp)
  8004bf:	0f be 03             	movsbl (%ebx),%eax
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	74 03                	je     8004c9 <vprintfmt+0x220>
  8004c6:	43                   	inc    %ebx
  8004c7:	eb 1b                	jmp    8004e4 <vprintfmt+0x23b>
  8004c9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d0:	7f 1e                	jg     8004f0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d5:	e9 f3 fd ff ff       	jmp    8002cd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004dd:	43                   	inc    %ebx
  8004de:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004e4:	85 f6                	test   %esi,%esi
  8004e6:	78 ad                	js     800495 <vprintfmt+0x1ec>
  8004e8:	4e                   	dec    %esi
  8004e9:	79 aa                	jns    800495 <vprintfmt+0x1ec>
  8004eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ee:	eb dc                	jmp    8004cc <vprintfmt+0x223>
  8004f0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	57                   	push   %edi
  8004f7:	6a 20                	push   $0x20
  8004f9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fc:	4b                   	dec    %ebx
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 db                	test   %ebx,%ebx
  800502:	7f ef                	jg     8004f3 <vprintfmt+0x24a>
  800504:	e9 c4 fd ff ff       	jmp    8002cd <vprintfmt+0x24>
  800509:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80050c:	89 ca                	mov    %ecx,%edx
  80050e:	8d 45 14             	lea    0x14(%ebp),%eax
  800511:	e8 2a fd ff ff       	call   800240 <getint>
  800516:	89 c3                	mov    %eax,%ebx
  800518:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80051a:	85 d2                	test   %edx,%edx
  80051c:	78 0a                	js     800528 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80051e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800523:	e9 b0 00 00 00       	jmp    8005d8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	57                   	push   %edi
  80052c:	6a 2d                	push   $0x2d
  80052e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800531:	f7 db                	neg    %ebx
  800533:	83 d6 00             	adc    $0x0,%esi
  800536:	f7 de                	neg    %esi
  800538:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80053b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800540:	e9 93 00 00 00       	jmp    8005d8 <vprintfmt+0x32f>
  800545:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800548:	89 ca                	mov    %ecx,%edx
  80054a:	8d 45 14             	lea    0x14(%ebp),%eax
  80054d:	e8 b4 fc ff ff       	call   800206 <getuint>
  800552:	89 c3                	mov    %eax,%ebx
  800554:	89 d6                	mov    %edx,%esi
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80055b:	eb 7b                	jmp    8005d8 <vprintfmt+0x32f>
  80055d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800560:	89 ca                	mov    %ecx,%edx
  800562:	8d 45 14             	lea    0x14(%ebp),%eax
  800565:	e8 d6 fc ff ff       	call   800240 <getint>
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80056e:	85 d2                	test   %edx,%edx
  800570:	78 07                	js     800579 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800572:	b8 08 00 00 00       	mov    $0x8,%eax
  800577:	eb 5f                	jmp    8005d8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	6a 2d                	push   $0x2d
  80057f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800582:	f7 db                	neg    %ebx
  800584:	83 d6 00             	adc    $0x0,%esi
  800587:	f7 de                	neg    %esi
  800589:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80058c:	b8 08 00 00 00       	mov    $0x8,%eax
  800591:	eb 45                	jmp    8005d8 <vprintfmt+0x32f>
  800593:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	57                   	push   %edi
  80059a:	6a 30                	push   $0x30
  80059c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	57                   	push   %edi
  8005a3:	6a 78                	push   $0x78
  8005a5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b1:	8b 18                	mov    (%eax),%ebx
  8005b3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c0:	eb 16                	jmp    8005d8 <vprintfmt+0x32f>
  8005c2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c5:	89 ca                	mov    %ecx,%edx
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 37 fc ff ff       	call   800206 <getuint>
  8005cf:	89 c3                	mov    %eax,%ebx
  8005d1:	89 d6                	mov    %edx,%esi
			base = 16;
  8005d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005df:	52                   	push   %edx
  8005e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e3:	50                   	push   %eax
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	89 fa                	mov    %edi,%edx
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	e8 68 fb ff ff       	call   800158 <printnum>
			break;
  8005f0:	83 c4 20             	add    $0x20,%esp
  8005f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f6:	e9 d2 fc ff ff       	jmp    8002cd <vprintfmt+0x24>
  8005fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	57                   	push   %edi
  800602:	52                   	push   %edx
  800603:	ff 55 08             	call   *0x8(%ebp)
			break;
  800606:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060c:	e9 bc fc ff ff       	jmp    8002cd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	57                   	push   %edi
  800615:	6a 25                	push   $0x25
  800617:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	eb 02                	jmp    800621 <vprintfmt+0x378>
  80061f:	89 c6                	mov    %eax,%esi
  800621:	8d 46 ff             	lea    -0x1(%esi),%eax
  800624:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800628:	75 f5                	jne    80061f <vprintfmt+0x376>
  80062a:	e9 9e fc ff ff       	jmp    8002cd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	c9                   	leave  
  800636:	c3                   	ret    

00800637 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 18             	sub    $0x18,%esp
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800654:	85 c0                	test   %eax,%eax
  800656:	74 26                	je     80067e <vsnprintf+0x47>
  800658:	85 d2                	test   %edx,%edx
  80065a:	7e 29                	jle    800685 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065c:	ff 75 14             	pushl  0x14(%ebp)
  80065f:	ff 75 10             	pushl  0x10(%ebp)
  800662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	68 72 02 80 00       	push   $0x800272
  80066b:	e8 39 fc ff ff       	call   8002a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 0c                	jmp    80068a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800683:	eb 05                	jmp    80068a <vsnprintf+0x53>
  800685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    

0080068c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800695:	50                   	push   %eax
  800696:	ff 75 10             	pushl  0x10(%ebp)
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	ff 75 08             	pushl  0x8(%ebp)
  80069f:	e8 93 ff ff ff       	call   800637 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a4:	c9                   	leave  
  8006a5:	c3                   	ret    
	...

008006a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ae:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b1:	74 0e                	je     8006c1 <strlen+0x19>
  8006b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006b8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006bd:	75 f9                	jne    8006b8 <strlen+0x10>
  8006bf:	eb 05                	jmp    8006c6 <strlen+0x1e>
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	74 17                	je     8006ec <strnlen+0x24>
  8006d5:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d8:	74 19                	je     8006f3 <strnlen+0x2b>
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006df:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	39 d0                	cmp    %edx,%eax
  8006e2:	74 14                	je     8006f8 <strnlen+0x30>
  8006e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e8:	75 f5                	jne    8006df <strnlen+0x17>
  8006ea:	eb 0c                	jmp    8006f8 <strnlen+0x30>
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	eb 05                	jmp    8006f8 <strnlen+0x30>
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    

008006fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80070c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80070f:	42                   	inc    %edx
  800710:	84 c9                	test   %cl,%cl
  800712:	75 f5                	jne    800709 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800714:	5b                   	pop    %ebx
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071e:	53                   	push   %ebx
  80071f:	e8 84 ff ff ff       	call   8006a8 <strlen>
  800724:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c7 ff ff ff       	call   8006fa <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
  800745:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800748:	85 f6                	test   %esi,%esi
  80074a:	74 15                	je     800761 <strncpy+0x27>
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800751:	8a 1a                	mov    (%edx),%bl
  800753:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800756:	80 3a 01             	cmpb   $0x1,(%edx)
  800759:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075c:	41                   	inc    %ecx
  80075d:	39 ce                	cmp    %ecx,%esi
  80075f:	77 f0                	ja     800751 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	57                   	push   %edi
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800771:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800774:	85 f6                	test   %esi,%esi
  800776:	74 32                	je     8007aa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800778:	83 fe 01             	cmp    $0x1,%esi
  80077b:	74 22                	je     80079f <strlcpy+0x3a>
  80077d:	8a 0b                	mov    (%ebx),%cl
  80077f:	84 c9                	test   %cl,%cl
  800781:	74 20                	je     8007a3 <strlcpy+0x3e>
  800783:	89 f8                	mov    %edi,%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80078a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078d:	88 08                	mov    %cl,(%eax)
  80078f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800790:	39 f2                	cmp    %esi,%edx
  800792:	74 11                	je     8007a5 <strlcpy+0x40>
  800794:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800798:	42                   	inc    %edx
  800799:	84 c9                	test   %cl,%cl
  80079b:	75 f0                	jne    80078d <strlcpy+0x28>
  80079d:	eb 06                	jmp    8007a5 <strlcpy+0x40>
  80079f:	89 f8                	mov    %edi,%eax
  8007a1:	eb 02                	jmp    8007a5 <strlcpy+0x40>
  8007a3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a5:	c6 00 00             	movb   $0x0,(%eax)
  8007a8:	eb 02                	jmp    8007ac <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007aa:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007ac:	29 f8                	sub    %edi,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bc:	8a 01                	mov    (%ecx),%al
  8007be:	84 c0                	test   %al,%al
  8007c0:	74 10                	je     8007d2 <strcmp+0x1f>
  8007c2:	3a 02                	cmp    (%edx),%al
  8007c4:	75 0c                	jne    8007d2 <strcmp+0x1f>
		p++, q++;
  8007c6:	41                   	inc    %ecx
  8007c7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c8:	8a 01                	mov    (%ecx),%al
  8007ca:	84 c0                	test   %al,%al
  8007cc:	74 04                	je     8007d2 <strcmp+0x1f>
  8007ce:	3a 02                	cmp    (%edx),%al
  8007d0:	74 f4                	je     8007c6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d2:	0f b6 c0             	movzbl %al,%eax
  8007d5:	0f b6 12             	movzbl (%edx),%edx
  8007d8:	29 d0                	sub    %edx,%eax
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	74 1b                	je     800808 <strncmp+0x2c>
  8007ed:	8a 1a                	mov    (%edx),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	74 24                	je     800817 <strncmp+0x3b>
  8007f3:	3a 19                	cmp    (%ecx),%bl
  8007f5:	75 20                	jne    800817 <strncmp+0x3b>
  8007f7:	48                   	dec    %eax
  8007f8:	74 15                	je     80080f <strncmp+0x33>
		n--, p++, q++;
  8007fa:	42                   	inc    %edx
  8007fb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fc:	8a 1a                	mov    (%edx),%bl
  8007fe:	84 db                	test   %bl,%bl
  800800:	74 15                	je     800817 <strncmp+0x3b>
  800802:	3a 19                	cmp    (%ecx),%bl
  800804:	74 f1                	je     8007f7 <strncmp+0x1b>
  800806:	eb 0f                	jmp    800817 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	eb 05                	jmp    800814 <strncmp+0x38>
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800814:	5b                   	pop    %ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 02             	movzbl (%edx),%eax
  80081a:	0f b6 11             	movzbl (%ecx),%edx
  80081d:	29 d0                	sub    %edx,%eax
  80081f:	eb f3                	jmp    800814 <strncmp+0x38>

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082a:	8a 10                	mov    (%eax),%dl
  80082c:	84 d2                	test   %dl,%dl
  80082e:	74 18                	je     800848 <strchr+0x27>
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	75 06                	jne    80083a <strchr+0x19>
  800834:	eb 17                	jmp    80084d <strchr+0x2c>
  800836:	38 ca                	cmp    %cl,%dl
  800838:	74 13                	je     80084d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083a:	40                   	inc    %eax
  80083b:	8a 10                	mov    (%eax),%dl
  80083d:	84 d2                	test   %dl,%dl
  80083f:	75 f5                	jne    800836 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 05                	jmp    80084d <strchr+0x2c>
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800858:	8a 10                	mov    (%eax),%dl
  80085a:	84 d2                	test   %dl,%dl
  80085c:	74 11                	je     80086f <strfind+0x20>
		if (*s == c)
  80085e:	38 ca                	cmp    %cl,%dl
  800860:	75 06                	jne    800868 <strfind+0x19>
  800862:	eb 0b                	jmp    80086f <strfind+0x20>
  800864:	38 ca                	cmp    %cl,%dl
  800866:	74 07                	je     80086f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800868:	40                   	inc    %eax
  800869:	8a 10                	mov    (%eax),%dl
  80086b:	84 d2                	test   %dl,%dl
  80086d:	75 f5                	jne    800864 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800880:	85 c9                	test   %ecx,%ecx
  800882:	74 30                	je     8008b4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800884:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088a:	75 25                	jne    8008b1 <memset+0x40>
  80088c:	f6 c1 03             	test   $0x3,%cl
  80088f:	75 20                	jne    8008b1 <memset+0x40>
		c &= 0xFF;
  800891:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800894:	89 d3                	mov    %edx,%ebx
  800896:	c1 e3 08             	shl    $0x8,%ebx
  800899:	89 d6                	mov    %edx,%esi
  80089b:	c1 e6 18             	shl    $0x18,%esi
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	c1 e0 10             	shl    $0x10,%eax
  8008a3:	09 f0                	or     %esi,%eax
  8008a5:	09 d0                	or     %edx,%eax
  8008a7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ac:	fc                   	cld    
  8008ad:	f3 ab                	rep stos %eax,%es:(%edi)
  8008af:	eb 03                	jmp    8008b4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b1:	fc                   	cld    
  8008b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b4:	89 f8                	mov    %edi,%eax
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c9:	39 c6                	cmp    %eax,%esi
  8008cb:	73 34                	jae    800901 <memmove+0x46>
  8008cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d0:	39 d0                	cmp    %edx,%eax
  8008d2:	73 2d                	jae    800901 <memmove+0x46>
		s += n;
		d += n;
  8008d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d7:	f6 c2 03             	test   $0x3,%dl
  8008da:	75 1b                	jne    8008f7 <memmove+0x3c>
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 13                	jne    8008f7 <memmove+0x3c>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 0e                	jne    8008f7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e9:	83 ef 04             	sub    $0x4,%edi
  8008ec:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f2:	fd                   	std    
  8008f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f5:	eb 07                	jmp    8008fe <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f7:	4f                   	dec    %edi
  8008f8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fb:	fd                   	std    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fe:	fc                   	cld    
  8008ff:	eb 20                	jmp    800921 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800901:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800907:	75 13                	jne    80091c <memmove+0x61>
  800909:	a8 03                	test   $0x3,%al
  80090b:	75 0f                	jne    80091c <memmove+0x61>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0a                	jne    80091c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800912:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800915:	89 c7                	mov    %eax,%edi
  800917:	fc                   	cld    
  800918:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091a:	eb 05                	jmp    800921 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	fc                   	cld    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800928:	ff 75 10             	pushl  0x10(%ebp)
  80092b:	ff 75 0c             	pushl  0xc(%ebp)
  80092e:	ff 75 08             	pushl  0x8(%ebp)
  800931:	e8 85 ff ff ff       	call   8008bb <memmove>
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800941:	8b 75 0c             	mov    0xc(%ebp),%esi
  800944:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	85 ff                	test   %edi,%edi
  800949:	74 32                	je     80097d <memcmp+0x45>
		if (*s1 != *s2)
  80094b:	8a 03                	mov    (%ebx),%al
  80094d:	8a 0e                	mov    (%esi),%cl
  80094f:	38 c8                	cmp    %cl,%al
  800951:	74 19                	je     80096c <memcmp+0x34>
  800953:	eb 0d                	jmp    800962 <memcmp+0x2a>
  800955:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800959:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80095d:	42                   	inc    %edx
  80095e:	38 c8                	cmp    %cl,%al
  800960:	74 10                	je     800972 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c0             	movzbl %al,%eax
  800965:	0f b6 c9             	movzbl %cl,%ecx
  800968:	29 c8                	sub    %ecx,%eax
  80096a:	eb 16                	jmp    800982 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096c:	4f                   	dec    %edi
  80096d:	ba 00 00 00 00       	mov    $0x0,%edx
  800972:	39 fa                	cmp    %edi,%edx
  800974:	75 df                	jne    800955 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 05                	jmp    800982 <memcmp+0x4a>
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800992:	39 d0                	cmp    %edx,%eax
  800994:	73 12                	jae    8009a8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800996:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800999:	38 08                	cmp    %cl,(%eax)
  80099b:	75 06                	jne    8009a3 <memfind+0x1c>
  80099d:	eb 09                	jmp    8009a8 <memfind+0x21>
  80099f:	38 08                	cmp    %cl,(%eax)
  8009a1:	74 05                	je     8009a8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a3:	40                   	inc    %eax
  8009a4:	39 c2                	cmp    %eax,%edx
  8009a6:	77 f7                	ja     80099f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	57                   	push   %edi
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b6:	eb 01                	jmp    8009b9 <strtol+0xf>
		s++;
  8009b8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b9:	8a 02                	mov    (%edx),%al
  8009bb:	3c 20                	cmp    $0x20,%al
  8009bd:	74 f9                	je     8009b8 <strtol+0xe>
  8009bf:	3c 09                	cmp    $0x9,%al
  8009c1:	74 f5                	je     8009b8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c3:	3c 2b                	cmp    $0x2b,%al
  8009c5:	75 08                	jne    8009cf <strtol+0x25>
		s++;
  8009c7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cd:	eb 13                	jmp    8009e2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cf:	3c 2d                	cmp    $0x2d,%al
  8009d1:	75 0a                	jne    8009dd <strtol+0x33>
		s++, neg = 1;
  8009d3:	8d 52 01             	lea    0x1(%edx),%edx
  8009d6:	bf 01 00 00 00       	mov    $0x1,%edi
  8009db:	eb 05                	jmp    8009e2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	85 db                	test   %ebx,%ebx
  8009e4:	74 05                	je     8009eb <strtol+0x41>
  8009e6:	83 fb 10             	cmp    $0x10,%ebx
  8009e9:	75 28                	jne    800a13 <strtol+0x69>
  8009eb:	8a 02                	mov    (%edx),%al
  8009ed:	3c 30                	cmp    $0x30,%al
  8009ef:	75 10                	jne    800a01 <strtol+0x57>
  8009f1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f5:	75 0a                	jne    800a01 <strtol+0x57>
		s += 2, base = 16;
  8009f7:	83 c2 02             	add    $0x2,%edx
  8009fa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ff:	eb 12                	jmp    800a13 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	75 0e                	jne    800a13 <strtol+0x69>
  800a05:	3c 30                	cmp    $0x30,%al
  800a07:	75 05                	jne    800a0e <strtol+0x64>
		s++, base = 8;
  800a09:	42                   	inc    %edx
  800a0a:	b3 08                	mov    $0x8,%bl
  800a0c:	eb 05                	jmp    800a13 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1a:	8a 0a                	mov    (%edx),%cl
  800a1c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a1f:	80 fb 09             	cmp    $0x9,%bl
  800a22:	77 08                	ja     800a2c <strtol+0x82>
			dig = *s - '0';
  800a24:	0f be c9             	movsbl %cl,%ecx
  800a27:	83 e9 30             	sub    $0x30,%ecx
  800a2a:	eb 1e                	jmp    800a4a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a2c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x92>
			dig = *s - 'a' + 10;
  800a34:	0f be c9             	movsbl %cl,%ecx
  800a37:	83 e9 57             	sub    $0x57,%ecx
  800a3a:	eb 0e                	jmp    800a4a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a3f:	80 fb 19             	cmp    $0x19,%bl
  800a42:	77 13                	ja     800a57 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a44:	0f be c9             	movsbl %cl,%ecx
  800a47:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a4a:	39 f1                	cmp    %esi,%ecx
  800a4c:	7d 0d                	jge    800a5b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a4e:	42                   	inc    %edx
  800a4f:	0f af c6             	imul   %esi,%eax
  800a52:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a55:	eb c3                	jmp    800a1a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a57:	89 c1                	mov    %eax,%ecx
  800a59:	eb 02                	jmp    800a5d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a61:	74 05                	je     800a68 <strtol+0xbe>
		*endptr = (char *) s;
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a66:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a68:	85 ff                	test   %edi,%edi
  800a6a:	74 04                	je     800a70 <strtol+0xc6>
  800a6c:	89 c8                	mov    %ecx,%eax
  800a6e:	f7 d8                	neg    %eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    
  800a75:	00 00                	add    %al,(%eax)
	...

00800a78 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 1c             	sub    $0x1c,%esp
  800a81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a84:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a87:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	8b 75 14             	mov    0x14(%ebp),%esi
  800a8c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	cd 30                	int    $0x30
  800a97:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a99:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a9d:	74 1c                	je     800abb <syscall+0x43>
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	7e 18                	jle    800abb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa3:	83 ec 0c             	sub    $0xc,%esp
  800aa6:	50                   	push   %eax
  800aa7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800aaa:	68 a4 11 80 00       	push   $0x8011a4
  800aaf:	6a 42                	push   $0x42
  800ab1:	68 c1 11 80 00       	push   $0x8011c1
  800ab6:	e8 bd 01 00 00       	call   800c78 <_panic>

	return ret;
}
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800acb:	6a 00                	push   $0x0
  800acd:	6a 00                	push   $0x0
  800acf:	6a 00                	push   $0x0
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	e8 92 ff ff ff       	call   800a78 <syscall>
  800ae6:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <sys_cgetc>:

int
sys_cgetc(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	e8 6b ff ff ff       	call   800a78 <syscall>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b20:	ba 01 00 00 00       	mov    $0x1,%edx
  800b25:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2a:	e8 49 ff ff ff       	call   800a78 <syscall>
}
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	e8 25 ff ff ff       	call   800a78 <syscall>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sys_yield>:

void
sys_yield(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b5b:	6a 00                	push   $0x0
  800b5d:	6a 00                	push   $0x0
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b72:	e8 01 ff ff ff       	call   800a78 <syscall>
  800b77:	83 c4 10             	add    $0x10,%esp
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	ff 75 10             	pushl  0x10(%ebp)
  800b89:	ff 75 0c             	pushl  0xc(%ebp)
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b94:	b8 04 00 00 00       	mov    $0x4,%eax
  800b99:	e8 da fe ff ff       	call   800a78 <syscall>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ba6:	ff 75 18             	pushl  0x18(%ebp)
  800ba9:	ff 75 14             	pushl  0x14(%ebp)
  800bac:	ff 75 10             	pushl  0x10(%ebp)
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	e8 b4 fe ff ff       	call   800a78 <syscall>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bcc:	6a 00                	push   $0x0
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdd:	b8 06 00 00 00       	mov    $0x6,%eax
  800be2:	e8 91 fe ff ff       	call   800a78 <syscall>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfb:	ba 01 00 00 00       	mov    $0x1,%edx
  800c00:	b8 08 00 00 00       	mov    $0x8,%eax
  800c05:	e8 6e fe ff ff       	call   800a78 <syscall>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	ff 75 0c             	pushl  0xc(%ebp)
  800c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c23:	b8 09 00 00 00       	mov    $0x9,%eax
  800c28:	e8 4b fe ff ff       	call   800a78 <syscall>
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c35:	6a 00                	push   $0x0
  800c37:	ff 75 14             	pushl  0x14(%ebp)
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4d:	e8 26 fe ff ff       	call   800a78 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c5a:	6a 00                	push   $0x0
  800c5c:	6a 00                	push   $0x0
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c65:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6f:	e8 04 fe ff ff       	call   800a78 <syscall>
}
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    
	...

00800c78 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c7d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c80:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c86:	e8 a6 fe ff ff       	call   800b31 <sys_getenvid>
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	53                   	push   %ebx
  800c95:	50                   	push   %eax
  800c96:	68 d0 11 80 00       	push   $0x8011d0
  800c9b:	e8 a4 f4 ff ff       	call   800144 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca0:	83 c4 18             	add    $0x18,%esp
  800ca3:	56                   	push   %esi
  800ca4:	ff 75 10             	pushl  0x10(%ebp)
  800ca7:	e8 47 f4 ff ff       	call   8000f3 <vcprintf>
	cprintf("\n");
  800cac:	c7 04 24 f4 11 80 00 	movl   $0x8011f4,(%esp)
  800cb3:	e8 8c f4 ff ff       	call   800144 <cprintf>
  800cb8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cbb:	cc                   	int3   
  800cbc:	eb fd                	jmp    800cbb <_panic+0x43>
	...

00800cc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	83 ec 10             	sub    $0x10,%esp
  800cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ccb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cce:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cd4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	75 2e                	jne    800d0c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cde:	39 f1                	cmp    %esi,%ecx
  800ce0:	77 5a                	ja     800d3c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce2:	85 c9                	test   %ecx,%ecx
  800ce4:	75 0b                	jne    800cf1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ceb:	31 d2                	xor    %edx,%edx
  800ced:	f7 f1                	div    %ecx
  800cef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf1:	31 d2                	xor    %edx,%edx
  800cf3:	89 f0                	mov    %esi,%eax
  800cf5:	f7 f1                	div    %ecx
  800cf7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	f7 f1                	div    %ecx
  800cfd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    
  800d0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d0c:	39 f0                	cmp    %esi,%eax
  800d0e:	77 1c                	ja     800d2c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d10:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d13:	83 f7 1f             	xor    $0x1f,%edi
  800d16:	75 3c                	jne    800d54 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d18:	39 f0                	cmp    %esi,%eax
  800d1a:	0f 82 90 00 00 00    	jb     800db0 <__udivdi3+0xf0>
  800d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d23:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d26:	0f 86 84 00 00 00    	jbe    800db0 <__udivdi3+0xf0>
  800d2c:	31 f6                	xor    %esi,%esi
  800d2e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d30:	89 f8                	mov    %edi,%eax
  800d32:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	89 f8                	mov    %edi,%eax
  800d40:	f7 f1                	div    %ecx
  800d42:	89 c7                	mov    %eax,%edi
  800d44:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d46:	89 f8                	mov    %edi,%eax
  800d48:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d54:	89 f9                	mov    %edi,%ecx
  800d56:	d3 e0                	shl    %cl,%eax
  800d58:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d5b:	b8 20 00 00 00       	mov    $0x20,%eax
  800d60:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d65:	88 c1                	mov    %al,%cl
  800d67:	d3 ea                	shr    %cl,%edx
  800d69:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d6c:	09 ca                	or     %ecx,%edx
  800d6e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d74:	89 f9                	mov    %edi,%ecx
  800d76:	d3 e2                	shl    %cl,%edx
  800d78:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	88 c1                	mov    %al,%cl
  800d7f:	d3 ea                	shr    %cl,%edx
  800d81:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	89 f9                	mov    %edi,%ecx
  800d88:	d3 e2                	shl    %cl,%edx
  800d8a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d8d:	88 c1                	mov    %al,%cl
  800d8f:	d3 ee                	shr    %cl,%esi
  800d91:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d93:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	89 ca                	mov    %ecx,%edx
  800d9a:	f7 75 ec             	divl   -0x14(%ebp)
  800d9d:	89 d1                	mov    %edx,%ecx
  800d9f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800da1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da4:	39 d1                	cmp    %edx,%ecx
  800da6:	72 28                	jb     800dd0 <__udivdi3+0x110>
  800da8:	74 1a                	je     800dc4 <__udivdi3+0x104>
  800daa:	89 f7                	mov    %esi,%edi
  800dac:	31 f6                	xor    %esi,%esi
  800dae:	eb 80                	jmp    800d30 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800db0:	31 f6                	xor    %esi,%esi
  800db2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db7:	89 f8                	mov    %edi,%eax
  800db9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
  800dc2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dc7:	89 f9                	mov    %edi,%ecx
  800dc9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dcb:	39 c2                	cmp    %eax,%edx
  800dcd:	73 db                	jae    800daa <__udivdi3+0xea>
  800dcf:	90                   	nop
		{
		  q0--;
  800dd0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dd3:	31 f6                	xor    %esi,%esi
  800dd5:	e9 56 ff ff ff       	jmp    800d30 <__udivdi3+0x70>
	...

00800ddc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	83 ec 20             	sub    $0x20,%esp
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ded:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800df0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800df3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800df9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	75 15                	jne    800e14 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800dff:	39 f1                	cmp    %esi,%ecx
  800e01:	0f 86 99 00 00 00    	jbe    800ea0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e07:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e09:	89 d0                	mov    %edx,%eax
  800e0b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e14:	39 f7                	cmp    %esi,%edi
  800e16:	0f 87 a4 00 00 00    	ja     800ec0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e1c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e1f:	83 f0 1f             	xor    $0x1f,%eax
  800e22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e25:	0f 84 a1 00 00 00    	je     800ecc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2b:	89 f8                	mov    %edi,%eax
  800e2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e30:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e32:	bf 20 00 00 00       	mov    $0x20,%edi
  800e37:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e3d:	89 f9                	mov    %edi,%ecx
  800e3f:	d3 ea                	shr    %cl,%edx
  800e41:	09 c2                	or     %eax,%edx
  800e43:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e4c:	d3 e0                	shl    %cl,%eax
  800e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e51:	89 f2                	mov    %esi,%edx
  800e53:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e58:	d3 e0                	shl    %cl,%eax
  800e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e60:	89 f9                	mov    %edi,%ecx
  800e62:	d3 e8                	shr    %cl,%eax
  800e64:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e66:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e68:	89 f2                	mov    %esi,%edx
  800e6a:	f7 75 f0             	divl   -0x10(%ebp)
  800e6d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e6f:	f7 65 f4             	mull   -0xc(%ebp)
  800e72:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e75:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e77:	39 d6                	cmp    %edx,%esi
  800e79:	72 71                	jb     800eec <__umoddi3+0x110>
  800e7b:	74 7f                	je     800efc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e80:	29 c8                	sub    %ecx,%eax
  800e82:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e84:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e87:	d3 e8                	shr    %cl,%eax
  800e89:	89 f2                	mov    %esi,%edx
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e8f:	09 d0                	or     %edx,%eax
  800e91:	89 f2                	mov    %esi,%edx
  800e93:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e96:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea0:	85 c9                	test   %ecx,%ecx
  800ea2:	75 0b                	jne    800eaf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea9:	31 d2                	xor    %edx,%edx
  800eab:	f7 f1                	div    %ecx
  800ead:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	31 d2                	xor    %edx,%edx
  800eb3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb8:	f7 f1                	div    %ecx
  800eba:	e9 4a ff ff ff       	jmp    800e09 <__umoddi3+0x2d>
  800ebf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ec0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec2:	83 c4 20             	add    $0x20,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ecc:	39 f7                	cmp    %esi,%edi
  800ece:	72 05                	jb     800ed5 <__umoddi3+0xf9>
  800ed0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ed3:	77 0c                	ja     800ee1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed5:	89 f2                	mov    %esi,%edx
  800ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eda:	29 c8                	sub    %ecx,%eax
  800edc:	19 fa                	sbb    %edi,%edx
  800ede:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee4:	83 c4 20             	add    $0x20,%esp
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    
  800eeb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ef4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ef7:	eb 84                	jmp    800e7d <__umoddi3+0xa1>
  800ef9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800efc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800eff:	72 eb                	jb     800eec <__umoddi3+0x110>
  800f01:	89 f2                	mov    %esi,%edx
  800f03:	e9 75 ff ff ff       	jmp    800e7d <__umoddi3+0xa1>
