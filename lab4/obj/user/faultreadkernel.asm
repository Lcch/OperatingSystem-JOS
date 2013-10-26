
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
  800040:	68 40 0f 80 00       	push   $0x800f40
  800045:	e8 f2 00 00 00       	call   80013c <cprintf>
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
  80005b:	e8 c9 0a 00 00       	call   800b29 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	c1 e0 07             	shl    $0x7,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x2d>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	53                   	push   %ebx
  800081:	56                   	push   %esi
  800082:	e8 ad ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800087:	e8 0c 00 00 00       	call   800098 <exit>
  80008c:	83 c4 10             	add    $0x10,%esp
}
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 62 0a 00 00       	call   800b07 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 04             	sub    $0x4,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000bf:	40                   	inc    %eax
  8000c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c7:	75 1a                	jne    8000e3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000c9:	83 ec 08             	sub    $0x8,%esp
  8000cc:	68 ff 00 00 00       	push   $0xff
  8000d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d4:	50                   	push   %eax
  8000d5:	e8 e3 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  8000da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e3:	ff 43 04             	incl   0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 ac 00 80 00       	push   $0x8000ac
  80011a:	e8 82 01 00 00       	call   8002a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 89 09 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 2c             	sub    $0x2c,%esp
  800159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	8b 55 0c             	mov    0xc(%ebp),%edx
  800164:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800167:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80016a:	8b 45 10             	mov    0x10(%ebp),%eax
  80016d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800170:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800173:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800176:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80017d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800180:	72 0c                	jb     80018e <printnum+0x3e>
  800182:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800185:	76 07                	jbe    80018e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800187:	4b                   	dec    %ebx
  800188:	85 db                	test   %ebx,%ebx
  80018a:	7f 31                	jg     8001bd <printnum+0x6d>
  80018c:	eb 3f                	jmp    8001cd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	57                   	push   %edi
  800192:	4b                   	dec    %ebx
  800193:	53                   	push   %ebx
  800194:	50                   	push   %eax
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 d4             	pushl  -0x2c(%ebp)
  80019b:	ff 75 d0             	pushl  -0x30(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 33 0b 00 00       	call   800cdc <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001b3:	e8 98 ff ff ff       	call   800150 <printnum>
  8001b8:	83 c4 20             	add    $0x20,%esp
  8001bb:	eb 10                	jmp    8001cd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	56                   	push   %esi
  8001c1:	57                   	push   %edi
  8001c2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	4b                   	dec    %ebx
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	85 db                	test   %ebx,%ebx
  8001cb:	7f f0                	jg     8001bd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	83 ec 04             	sub    $0x4,%esp
  8001d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001da:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e0:	e8 13 0c 00 00       	call   800df8 <__umoddi3>
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	0f be 80 71 0f 80 00 	movsbl 0x800f71(%eax),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 55 e4             	call   *-0x1c(%ebp)
  8001f3:	83 c4 10             	add    $0x10,%esp
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800201:	83 fa 01             	cmp    $0x1,%edx
  800204:	7e 0e                	jle    800214 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800206:	8b 10                	mov    (%eax),%edx
  800208:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020b:	89 08                	mov    %ecx,(%eax)
  80020d:	8b 02                	mov    (%edx),%eax
  80020f:	8b 52 04             	mov    0x4(%edx),%edx
  800212:	eb 22                	jmp    800236 <getuint+0x38>
	else if (lflag)
  800214:	85 d2                	test   %edx,%edx
  800216:	74 10                	je     800228 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800218:	8b 10                	mov    (%eax),%edx
  80021a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021d:	89 08                	mov    %ecx,(%eax)
  80021f:	8b 02                	mov    (%edx),%eax
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
  800226:	eb 0e                	jmp    800236 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023b:	83 fa 01             	cmp    $0x1,%edx
  80023e:	7e 0e                	jle    80024e <getint+0x16>
		return va_arg(*ap, long long);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 08             	lea    0x8(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	8b 52 04             	mov    0x4(%edx),%edx
  80024c:	eb 1a                	jmp    800268 <getint+0x30>
	else if (lflag)
  80024e:	85 d2                	test   %edx,%edx
  800250:	74 0c                	je     80025e <getint+0x26>
		return va_arg(*ap, long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 04             	lea    0x4(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	99                   	cltd   
  80025c:	eb 0a                	jmp    800268 <getint+0x30>
	else
		return va_arg(*ap, int);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 04             	lea    0x4(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	99                   	cltd   
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800270:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800273:	8b 10                	mov    (%eax),%edx
  800275:	3b 50 04             	cmp    0x4(%eax),%edx
  800278:	73 08                	jae    800282 <sprintputch+0x18>
		*b->buf++ = ch;
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	88 0a                	mov    %cl,(%edx)
  80027f:	42                   	inc    %edx
  800280:	89 10                	mov    %edx,(%eax)
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 10             	pushl  0x10(%ebp)
  800291:	ff 75 0c             	pushl  0xc(%ebp)
  800294:	ff 75 08             	pushl  0x8(%ebp)
  800297:	e8 05 00 00 00       	call   8002a1 <vprintfmt>
	va_end(ap);
  80029c:	83 c4 10             	add    $0x10,%esp
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 2c             	sub    $0x2c,%esp
  8002aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8002b0:	eb 13                	jmp    8002c5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	0f 84 6d 03 00 00    	je     800627 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	57                   	push   %edi
  8002be:	50                   	push   %eax
  8002bf:	ff 55 08             	call   *0x8(%ebp)
  8002c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c5:	0f b6 06             	movzbl (%esi),%eax
  8002c8:	46                   	inc    %esi
  8002c9:	83 f8 25             	cmp    $0x25,%eax
  8002cc:	75 e4                	jne    8002b2 <vprintfmt+0x11>
  8002ce:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002e0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ec:	eb 28                	jmp    800316 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8002f4:	eb 20                	jmp    800316 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8002fc:	eb 18                	jmp    800316 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800300:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800307:	eb 0d                	jmp    800316 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800309:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8a 06                	mov    (%esi),%al
  800318:	0f b6 d0             	movzbl %al,%edx
  80031b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80031e:	83 e8 23             	sub    $0x23,%eax
  800321:	3c 55                	cmp    $0x55,%al
  800323:	0f 87 e0 02 00 00    	ja     800609 <vprintfmt+0x368>
  800329:	0f b6 c0             	movzbl %al,%eax
  80032c:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	83 ea 30             	sub    $0x30,%edx
  800336:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800339:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80033c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80033f:	83 fa 09             	cmp    $0x9,%edx
  800342:	77 44                	ja     800388 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	89 de                	mov    %ebx,%esi
  800346:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800349:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80034a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80034d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800351:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800354:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800357:	83 fb 09             	cmp    $0x9,%ebx
  80035a:	76 ed                	jbe    800349 <vprintfmt+0xa8>
  80035c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80035f:	eb 29                	jmp    80038a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 50 04             	lea    0x4(%eax),%edx
  800367:	89 55 14             	mov    %edx,0x14(%ebp)
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800371:	eb 17                	jmp    80038a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800373:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800377:	78 85                	js     8002fe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	89 de                	mov    %ebx,%esi
  80037b:	eb 99                	jmp    800316 <vprintfmt+0x75>
  80037d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800386:	eb 8e                	jmp    800316 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038e:	79 86                	jns    800316 <vprintfmt+0x75>
  800390:	e9 74 ff ff ff       	jmp    800309 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800395:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	89 de                	mov    %ebx,%esi
  800398:	e9 79 ff ff ff       	jmp    800316 <vprintfmt+0x75>
  80039d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	57                   	push   %edi
  8003ad:	ff 30                	pushl  (%eax)
  8003af:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b8:	e9 08 ff ff ff       	jmp    8002c5 <vprintfmt+0x24>
  8003bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	79 02                	jns    8003d1 <vprintfmt+0x130>
  8003cf:	f7 d8                	neg    %eax
  8003d1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d3:	83 f8 08             	cmp    $0x8,%eax
  8003d6:	7f 0b                	jg     8003e3 <vprintfmt+0x142>
  8003d8:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	75 1a                	jne    8003fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003e3:	52                   	push   %edx
  8003e4:	68 89 0f 80 00       	push   $0x800f89
  8003e9:	57                   	push   %edi
  8003ea:	ff 75 08             	pushl  0x8(%ebp)
  8003ed:	e8 92 fe ff ff       	call   800284 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f8:	e9 c8 fe ff ff       	jmp    8002c5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8003fd:	50                   	push   %eax
  8003fe:	68 92 0f 80 00       	push   $0x800f92
  800403:	57                   	push   %edi
  800404:	ff 75 08             	pushl  0x8(%ebp)
  800407:	e8 78 fe ff ff       	call   800284 <printfmt>
  80040c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800412:	e9 ae fe ff ff       	jmp    8002c5 <vprintfmt+0x24>
  800417:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80041f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800430:	85 c0                	test   %eax,%eax
  800432:	75 07                	jne    80043b <vprintfmt+0x19a>
				p = "(null)";
  800434:	c7 45 d0 82 0f 80 00 	movl   $0x800f82,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80043b:	85 db                	test   %ebx,%ebx
  80043d:	7e 42                	jle    800481 <vprintfmt+0x1e0>
  80043f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800443:	74 3c                	je     800481 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	51                   	push   %ecx
  800449:	ff 75 d0             	pushl  -0x30(%ebp)
  80044c:	e8 6f 02 00 00       	call   8006c0 <strnlen>
  800451:	29 c3                	sub    %eax,%ebx
  800453:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 db                	test   %ebx,%ebx
  80045b:	7e 24                	jle    800481 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80045d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800461:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800464:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	57                   	push   %edi
  80046b:	53                   	push   %ebx
  80046c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	4e                   	dec    %esi
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	85 f6                	test   %esi,%esi
  800475:	7f f0                	jg     800467 <vprintfmt+0x1c6>
  800477:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80047a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800481:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800484:	0f be 02             	movsbl (%edx),%eax
  800487:	85 c0                	test   %eax,%eax
  800489:	75 47                	jne    8004d2 <vprintfmt+0x231>
  80048b:	eb 37                	jmp    8004c4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80048d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800491:	74 16                	je     8004a9 <vprintfmt+0x208>
  800493:	8d 50 e0             	lea    -0x20(%eax),%edx
  800496:	83 fa 5e             	cmp    $0x5e,%edx
  800499:	76 0e                	jbe    8004a9 <vprintfmt+0x208>
					putch('?', putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	57                   	push   %edi
  80049f:	6a 3f                	push   $0x3f
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb 0b                	jmp    8004b4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	50                   	push   %eax
  8004ae:	ff 55 08             	call   *0x8(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004b7:	0f be 03             	movsbl (%ebx),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	74 03                	je     8004c1 <vprintfmt+0x220>
  8004be:	43                   	inc    %ebx
  8004bf:	eb 1b                	jmp    8004dc <vprintfmt+0x23b>
  8004c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c8:	7f 1e                	jg     8004e8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004cd:	e9 f3 fd ff ff       	jmp    8002c5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004d5:	43                   	inc    %ebx
  8004d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004dc:	85 f6                	test   %esi,%esi
  8004de:	78 ad                	js     80048d <vprintfmt+0x1ec>
  8004e0:	4e                   	dec    %esi
  8004e1:	79 aa                	jns    80048d <vprintfmt+0x1ec>
  8004e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004e6:	eb dc                	jmp    8004c4 <vprintfmt+0x223>
  8004e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	57                   	push   %edi
  8004ef:	6a 20                	push   $0x20
  8004f1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f4:	4b                   	dec    %ebx
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	85 db                	test   %ebx,%ebx
  8004fa:	7f ef                	jg     8004eb <vprintfmt+0x24a>
  8004fc:	e9 c4 fd ff ff       	jmp    8002c5 <vprintfmt+0x24>
  800501:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800504:	89 ca                	mov    %ecx,%edx
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
  800509:	e8 2a fd ff ff       	call   800238 <getint>
  80050e:	89 c3                	mov    %eax,%ebx
  800510:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800512:	85 d2                	test   %edx,%edx
  800514:	78 0a                	js     800520 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800516:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051b:	e9 b0 00 00 00       	jmp    8005d0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	57                   	push   %edi
  800524:	6a 2d                	push   $0x2d
  800526:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800529:	f7 db                	neg    %ebx
  80052b:	83 d6 00             	adc    $0x0,%esi
  80052e:	f7 de                	neg    %esi
  800530:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800533:	b8 0a 00 00 00       	mov    $0xa,%eax
  800538:	e9 93 00 00 00       	jmp    8005d0 <vprintfmt+0x32f>
  80053d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800540:	89 ca                	mov    %ecx,%edx
  800542:	8d 45 14             	lea    0x14(%ebp),%eax
  800545:	e8 b4 fc ff ff       	call   8001fe <getuint>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	89 d6                	mov    %edx,%esi
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800553:	eb 7b                	jmp    8005d0 <vprintfmt+0x32f>
  800555:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800558:	89 ca                	mov    %ecx,%edx
  80055a:	8d 45 14             	lea    0x14(%ebp),%eax
  80055d:	e8 d6 fc ff ff       	call   800238 <getint>
  800562:	89 c3                	mov    %eax,%ebx
  800564:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800566:	85 d2                	test   %edx,%edx
  800568:	78 07                	js     800571 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80056a:	b8 08 00 00 00       	mov    $0x8,%eax
  80056f:	eb 5f                	jmp    8005d0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	57                   	push   %edi
  800575:	6a 2d                	push   $0x2d
  800577:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80057a:	f7 db                	neg    %ebx
  80057c:	83 d6 00             	adc    $0x0,%esi
  80057f:	f7 de                	neg    %esi
  800581:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800584:	b8 08 00 00 00       	mov    $0x8,%eax
  800589:	eb 45                	jmp    8005d0 <vprintfmt+0x32f>
  80058b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	57                   	push   %edi
  800592:	6a 30                	push   $0x30
  800594:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800597:	83 c4 08             	add    $0x8,%esp
  80059a:	57                   	push   %edi
  80059b:	6a 78                	push   $0x78
  80059d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005a9:	8b 18                	mov    (%eax),%ebx
  8005ab:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005b8:	eb 16                	jmp    8005d0 <vprintfmt+0x32f>
  8005ba:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005bd:	89 ca                	mov    %ecx,%edx
  8005bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c2:	e8 37 fc ff ff       	call   8001fe <getuint>
  8005c7:	89 c3                	mov    %eax,%ebx
  8005c9:	89 d6                	mov    %edx,%esi
			base = 16;
  8005cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005d7:	52                   	push   %edx
  8005d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005db:	50                   	push   %eax
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
  8005de:	89 fa                	mov    %edi,%edx
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	e8 68 fb ff ff       	call   800150 <printnum>
			break;
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ee:	e9 d2 fc ff ff       	jmp    8002c5 <vprintfmt+0x24>
  8005f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	57                   	push   %edi
  8005fa:	52                   	push   %edx
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800604:	e9 bc fc ff ff       	jmp    8002c5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	57                   	push   %edi
  80060d:	6a 25                	push   $0x25
  80060f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb 02                	jmp    800619 <vprintfmt+0x378>
  800617:	89 c6                	mov    %eax,%esi
  800619:	8d 46 ff             	lea    -0x1(%esi),%eax
  80061c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800620:	75 f5                	jne    800617 <vprintfmt+0x376>
  800622:	e9 9e fc ff ff       	jmp    8002c5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 18             	sub    $0x18,%esp
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800642:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	74 26                	je     800676 <vsnprintf+0x47>
  800650:	85 d2                	test   %edx,%edx
  800652:	7e 29                	jle    80067d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800654:	ff 75 14             	pushl  0x14(%ebp)
  800657:	ff 75 10             	pushl  0x10(%ebp)
  80065a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	68 6a 02 80 00       	push   $0x80026a
  800663:	e8 39 fc ff ff       	call   8002a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 0c                	jmp    800682 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80067b:	eb 05                	jmp    800682 <vsnprintf+0x53>
  80067d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800682:	c9                   	leave  
  800683:	c3                   	ret    

00800684 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068d:	50                   	push   %eax
  80068e:	ff 75 10             	pushl  0x10(%ebp)
  800691:	ff 75 0c             	pushl  0xc(%ebp)
  800694:	ff 75 08             	pushl  0x8(%ebp)
  800697:	e8 93 ff ff ff       	call   80062f <vsnprintf>
	va_end(ap);

	return rc;
}
  80069c:	c9                   	leave  
  80069d:	c3                   	ret    
	...

008006a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a9:	74 0e                	je     8006b9 <strlen+0x19>
  8006ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006b0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b5:	75 f9                	jne    8006b0 <strlen+0x10>
  8006b7:	eb 05                	jmp    8006be <strlen+0x1e>
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 17                	je     8006e4 <strnlen+0x24>
  8006cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d0:	74 19                	je     8006eb <strnlen+0x2b>
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006d7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d8:	39 d0                	cmp    %edx,%eax
  8006da:	74 14                	je     8006f0 <strnlen+0x30>
  8006dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e0:	75 f5                	jne    8006d7 <strnlen+0x17>
  8006e2:	eb 0c                	jmp    8006f0 <strnlen+0x30>
  8006e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e9:	eb 05                	jmp    8006f0 <strnlen+0x30>
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800701:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800704:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800707:	42                   	inc    %edx
  800708:	84 c9                	test   %cl,%cl
  80070a:	75 f5                	jne    800701 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80070c:	5b                   	pop    %ebx
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800716:	53                   	push   %ebx
  800717:	e8 84 ff ff ff       	call   8006a0 <strlen>
  80071c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800725:	50                   	push   %eax
  800726:	e8 c7 ff ff ff       	call   8006f2 <strcpy>
	return dst;
}
  80072b:	89 d8                	mov    %ebx,%eax
  80072d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800740:	85 f6                	test   %esi,%esi
  800742:	74 15                	je     800759 <strncpy+0x27>
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800749:	8a 1a                	mov    (%edx),%bl
  80074b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074e:	80 3a 01             	cmpb   $0x1,(%edx)
  800751:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800754:	41                   	inc    %ecx
  800755:	39 ce                	cmp    %ecx,%esi
  800757:	77 f0                	ja     800749 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	57                   	push   %edi
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 7d 08             	mov    0x8(%ebp),%edi
  800766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800769:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076c:	85 f6                	test   %esi,%esi
  80076e:	74 32                	je     8007a2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800770:	83 fe 01             	cmp    $0x1,%esi
  800773:	74 22                	je     800797 <strlcpy+0x3a>
  800775:	8a 0b                	mov    (%ebx),%cl
  800777:	84 c9                	test   %cl,%cl
  800779:	74 20                	je     80079b <strlcpy+0x3e>
  80077b:	89 f8                	mov    %edi,%eax
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800782:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800785:	88 08                	mov    %cl,(%eax)
  800787:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800788:	39 f2                	cmp    %esi,%edx
  80078a:	74 11                	je     80079d <strlcpy+0x40>
  80078c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800790:	42                   	inc    %edx
  800791:	84 c9                	test   %cl,%cl
  800793:	75 f0                	jne    800785 <strlcpy+0x28>
  800795:	eb 06                	jmp    80079d <strlcpy+0x40>
  800797:	89 f8                	mov    %edi,%eax
  800799:	eb 02                	jmp    80079d <strlcpy+0x40>
  80079b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079d:	c6 00 00             	movb   $0x0,(%eax)
  8007a0:	eb 02                	jmp    8007a4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007a4:	29 f8                	sub    %edi,%eax
}
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5f                   	pop    %edi
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b4:	8a 01                	mov    (%ecx),%al
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 10                	je     8007ca <strcmp+0x1f>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	75 0c                	jne    8007ca <strcmp+0x1f>
		p++, q++;
  8007be:	41                   	inc    %ecx
  8007bf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c0:	8a 01                	mov    (%ecx),%al
  8007c2:	84 c0                	test   %al,%al
  8007c4:	74 04                	je     8007ca <strcmp+0x1f>
  8007c6:	3a 02                	cmp    (%edx),%al
  8007c8:	74 f4                	je     8007be <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ca:	0f b6 c0             	movzbl %al,%eax
  8007cd:	0f b6 12             	movzbl (%edx),%edx
  8007d0:	29 d0                	sub    %edx,%eax
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	74 1b                	je     800800 <strncmp+0x2c>
  8007e5:	8a 1a                	mov    (%edx),%bl
  8007e7:	84 db                	test   %bl,%bl
  8007e9:	74 24                	je     80080f <strncmp+0x3b>
  8007eb:	3a 19                	cmp    (%ecx),%bl
  8007ed:	75 20                	jne    80080f <strncmp+0x3b>
  8007ef:	48                   	dec    %eax
  8007f0:	74 15                	je     800807 <strncmp+0x33>
		n--, p++, q++;
  8007f2:	42                   	inc    %edx
  8007f3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f4:	8a 1a                	mov    (%edx),%bl
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	74 15                	je     80080f <strncmp+0x3b>
  8007fa:	3a 19                	cmp    (%ecx),%bl
  8007fc:	74 f1                	je     8007ef <strncmp+0x1b>
  8007fe:	eb 0f                	jmp    80080f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	eb 05                	jmp    80080c <strncmp+0x38>
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080c:	5b                   	pop    %ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 02             	movzbl (%edx),%eax
  800812:	0f b6 11             	movzbl (%ecx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb f3                	jmp    80080c <strncmp+0x38>

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800822:	8a 10                	mov    (%eax),%dl
  800824:	84 d2                	test   %dl,%dl
  800826:	74 18                	je     800840 <strchr+0x27>
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	75 06                	jne    800832 <strchr+0x19>
  80082c:	eb 17                	jmp    800845 <strchr+0x2c>
  80082e:	38 ca                	cmp    %cl,%dl
  800830:	74 13                	je     800845 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800832:	40                   	inc    %eax
  800833:	8a 10                	mov    (%eax),%dl
  800835:	84 d2                	test   %dl,%dl
  800837:	75 f5                	jne    80082e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	eb 05                	jmp    800845 <strchr+0x2c>
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800850:	8a 10                	mov    (%eax),%dl
  800852:	84 d2                	test   %dl,%dl
  800854:	74 11                	je     800867 <strfind+0x20>
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	75 06                	jne    800860 <strfind+0x19>
  80085a:	eb 0b                	jmp    800867 <strfind+0x20>
  80085c:	38 ca                	cmp    %cl,%dl
  80085e:	74 07                	je     800867 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800860:	40                   	inc    %eax
  800861:	8a 10                	mov    (%eax),%dl
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f5                	jne    80085c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	57                   	push   %edi
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800878:	85 c9                	test   %ecx,%ecx
  80087a:	74 30                	je     8008ac <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800882:	75 25                	jne    8008a9 <memset+0x40>
  800884:	f6 c1 03             	test   $0x3,%cl
  800887:	75 20                	jne    8008a9 <memset+0x40>
		c &= 0xFF;
  800889:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088c:	89 d3                	mov    %edx,%ebx
  80088e:	c1 e3 08             	shl    $0x8,%ebx
  800891:	89 d6                	mov    %edx,%esi
  800893:	c1 e6 18             	shl    $0x18,%esi
  800896:	89 d0                	mov    %edx,%eax
  800898:	c1 e0 10             	shl    $0x10,%eax
  80089b:	09 f0                	or     %esi,%eax
  80089d:	09 d0                	or     %edx,%eax
  80089f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a4:	fc                   	cld    
  8008a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a7:	eb 03                	jmp    8008ac <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a9:	fc                   	cld    
  8008aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ac:	89 f8                	mov    %edi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c1:	39 c6                	cmp    %eax,%esi
  8008c3:	73 34                	jae    8008f9 <memmove+0x46>
  8008c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c8:	39 d0                	cmp    %edx,%eax
  8008ca:	73 2d                	jae    8008f9 <memmove+0x46>
		s += n;
		d += n;
  8008cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	f6 c2 03             	test   $0x3,%dl
  8008d2:	75 1b                	jne    8008ef <memmove+0x3c>
  8008d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008da:	75 13                	jne    8008ef <memmove+0x3c>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 0e                	jne    8008ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e1:	83 ef 04             	sub    $0x4,%edi
  8008e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ea:	fd                   	std    
  8008eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ed:	eb 07                	jmp    8008f6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ef:	4f                   	dec    %edi
  8008f0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f3:	fd                   	std    
  8008f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f6:	fc                   	cld    
  8008f7:	eb 20                	jmp    800919 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ff:	75 13                	jne    800914 <memmove+0x61>
  800901:	a8 03                	test   $0x3,%al
  800903:	75 0f                	jne    800914 <memmove+0x61>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0a                	jne    800914 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800912:	eb 05                	jmp    800919 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800914:	89 c7                	mov    %eax,%edi
  800916:	fc                   	cld    
  800917:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800920:	ff 75 10             	pushl  0x10(%ebp)
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	ff 75 08             	pushl  0x8(%ebp)
  800929:	e8 85 ff ff ff       	call   8008b3 <memmove>
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800939:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	85 ff                	test   %edi,%edi
  800941:	74 32                	je     800975 <memcmp+0x45>
		if (*s1 != *s2)
  800943:	8a 03                	mov    (%ebx),%al
  800945:	8a 0e                	mov    (%esi),%cl
  800947:	38 c8                	cmp    %cl,%al
  800949:	74 19                	je     800964 <memcmp+0x34>
  80094b:	eb 0d                	jmp    80095a <memcmp+0x2a>
  80094d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800951:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800955:	42                   	inc    %edx
  800956:	38 c8                	cmp    %cl,%al
  800958:	74 10                	je     80096a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 c9             	movzbl %cl,%ecx
  800960:	29 c8                	sub    %ecx,%eax
  800962:	eb 16                	jmp    80097a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800964:	4f                   	dec    %edi
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	39 fa                	cmp    %edi,%edx
  80096c:	75 df                	jne    80094d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
  800973:	eb 05                	jmp    80097a <memcmp+0x4a>
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800985:	89 c2                	mov    %eax,%edx
  800987:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098a:	39 d0                	cmp    %edx,%eax
  80098c:	73 12                	jae    8009a0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800991:	38 08                	cmp    %cl,(%eax)
  800993:	75 06                	jne    80099b <memfind+0x1c>
  800995:	eb 09                	jmp    8009a0 <memfind+0x21>
  800997:	38 08                	cmp    %cl,(%eax)
  800999:	74 05                	je     8009a0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	40                   	inc    %eax
  80099c:	39 c2                	cmp    %eax,%edx
  80099e:	77 f7                	ja     800997 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 01                	jmp    8009b1 <strtol+0xf>
		s++;
  8009b0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	8a 02                	mov    (%edx),%al
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f9                	je     8009b0 <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f5                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 08                	jne    8009c7 <strtol+0x25>
		s++;
  8009bf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c5:	eb 13                	jmp    8009da <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c7:	3c 2d                	cmp    $0x2d,%al
  8009c9:	75 0a                	jne    8009d5 <strtol+0x33>
		s++, neg = 1;
  8009cb:	8d 52 01             	lea    0x1(%edx),%edx
  8009ce:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d3:	eb 05                	jmp    8009da <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	74 05                	je     8009e3 <strtol+0x41>
  8009de:	83 fb 10             	cmp    $0x10,%ebx
  8009e1:	75 28                	jne    800a0b <strtol+0x69>
  8009e3:	8a 02                	mov    (%edx),%al
  8009e5:	3c 30                	cmp    $0x30,%al
  8009e7:	75 10                	jne    8009f9 <strtol+0x57>
  8009e9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ed:	75 0a                	jne    8009f9 <strtol+0x57>
		s += 2, base = 16;
  8009ef:	83 c2 02             	add    $0x2,%edx
  8009f2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f7:	eb 12                	jmp    800a0b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	75 0e                	jne    800a0b <strtol+0x69>
  8009fd:	3c 30                	cmp    $0x30,%al
  8009ff:	75 05                	jne    800a06 <strtol+0x64>
		s++, base = 8;
  800a01:	42                   	inc    %edx
  800a02:	b3 08                	mov    $0x8,%bl
  800a04:	eb 05                	jmp    800a0b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a06:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a12:	8a 0a                	mov    (%edx),%cl
  800a14:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a17:	80 fb 09             	cmp    $0x9,%bl
  800a1a:	77 08                	ja     800a24 <strtol+0x82>
			dig = *s - '0';
  800a1c:	0f be c9             	movsbl %cl,%ecx
  800a1f:	83 e9 30             	sub    $0x30,%ecx
  800a22:	eb 1e                	jmp    800a42 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a24:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a2c:	0f be c9             	movsbl %cl,%ecx
  800a2f:	83 e9 57             	sub    $0x57,%ecx
  800a32:	eb 0e                	jmp    800a42 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 13                	ja     800a4f <strtol+0xad>
			dig = *s - 'A' + 10;
  800a3c:	0f be c9             	movsbl %cl,%ecx
  800a3f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a42:	39 f1                	cmp    %esi,%ecx
  800a44:	7d 0d                	jge    800a53 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a46:	42                   	inc    %edx
  800a47:	0f af c6             	imul   %esi,%eax
  800a4a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a4d:	eb c3                	jmp    800a12 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a4f:	89 c1                	mov    %eax,%ecx
  800a51:	eb 02                	jmp    800a55 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a53:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a59:	74 05                	je     800a60 <strtol+0xbe>
		*endptr = (char *) s;
  800a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a60:	85 ff                	test   %edi,%edi
  800a62:	74 04                	je     800a68 <strtol+0xc6>
  800a64:	89 c8                	mov    %ecx,%eax
  800a66:	f7 d8                	neg    %eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    
  800a6d:	00 00                	add    %al,(%eax)
	...

00800a70 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	83 ec 1c             	sub    $0x1c,%esp
  800a79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a7c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a7f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	8b 75 14             	mov    0x14(%ebp),%esi
  800a84:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	cd 30                	int    $0x30
  800a8f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a95:	74 1c                	je     800ab3 <syscall+0x43>
  800a97:	85 c0                	test   %eax,%eax
  800a99:	7e 18                	jle    800ab3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	50                   	push   %eax
  800a9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800aa2:	68 c4 11 80 00       	push   $0x8011c4
  800aa7:	6a 42                	push   $0x42
  800aa9:	68 e1 11 80 00       	push   $0x8011e1
  800aae:	e8 e1 01 00 00       	call   800c94 <_panic>

	return ret;
}
  800ab3:	89 d0                	mov    %edx,%eax
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ac3:	6a 00                	push   $0x0
  800ac5:	6a 00                	push   $0x0
  800ac7:	6a 00                	push   $0x0
  800ac9:	ff 75 0c             	pushl  0xc(%ebp)
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad9:	e8 92 ff ff ff       	call   800a70 <syscall>
  800ade:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ae9:	6a 00                	push   $0x0
  800aeb:	6a 00                	push   $0x0
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	e8 6b ff ff ff       	call   800a70 <syscall>
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b18:	ba 01 00 00 00       	mov    $0x1,%edx
  800b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b22:	e8 49 ff ff ff       	call   800a70 <syscall>
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 02 00 00 00       	mov    $0x2,%eax
  800b46:	e8 25 ff ff ff       	call   800a70 <syscall>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_yield>:

void
sys_yield(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	e8 01 ff ff ff       	call   800a70 <syscall>
  800b6f:	83 c4 10             	add    $0x10,%esp
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b7a:	6a 00                	push   $0x0
  800b7c:	6a 00                	push   $0x0
  800b7e:	ff 75 10             	pushl  0x10(%ebp)
  800b81:	ff 75 0c             	pushl  0xc(%ebp)
  800b84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b87:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	e8 da fe ff ff       	call   800a70 <syscall>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b9e:	ff 75 18             	pushl  0x18(%ebp)
  800ba1:	ff 75 14             	pushl  0x14(%ebp)
  800ba4:	ff 75 10             	pushl  0x10(%ebp)
  800ba7:	ff 75 0c             	pushl  0xc(%ebp)
  800baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bad:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	e8 b4 fe ff ff       	call   800a70 <syscall>
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bc4:	6a 00                	push   $0x0
  800bc6:	6a 00                	push   $0x0
  800bc8:	6a 00                	push   $0x0
  800bca:	ff 75 0c             	pushl  0xc(%ebp)
  800bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bda:	e8 91 fe ff ff       	call   800a70 <syscall>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	ff 75 0c             	pushl  0xc(%ebp)
  800bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfd:	e8 6e fe ff ff       	call   800a70 <syscall>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c0a:	6a 00                	push   $0x0
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 0c             	pushl  0xc(%ebp)
  800c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c16:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c20:	e8 4b fe ff ff       	call   800a70 <syscall>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	ff 75 14             	pushl  0x14(%ebp)
  800c32:	ff 75 10             	pushl  0x10(%ebp)
  800c35:	ff 75 0c             	pushl  0xc(%ebp)
  800c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c45:	e8 26 fe ff ff       	call   800a70 <syscall>
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c62:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c67:	e8 04 fe ff ff       	call   800a70 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800c74:	6a 00                	push   $0x0
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	ff 75 0c             	pushl  0xc(%ebp)
  800c7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c8a:	e8 e1 fd ff ff       	call   800a70 <syscall>
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    
  800c91:	00 00                	add    %al,(%eax)
	...

00800c94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c99:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c9c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ca2:	e8 82 fe ff ff       	call   800b29 <sys_getenvid>
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	ff 75 0c             	pushl  0xc(%ebp)
  800cad:	ff 75 08             	pushl  0x8(%ebp)
  800cb0:	53                   	push   %ebx
  800cb1:	50                   	push   %eax
  800cb2:	68 f0 11 80 00       	push   $0x8011f0
  800cb7:	e8 80 f4 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cbc:	83 c4 18             	add    $0x18,%esp
  800cbf:	56                   	push   %esi
  800cc0:	ff 75 10             	pushl  0x10(%ebp)
  800cc3:	e8 23 f4 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800cc8:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  800ccf:	e8 68 f4 ff ff       	call   80013c <cprintf>
  800cd4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cd7:	cc                   	int3   
  800cd8:	eb fd                	jmp    800cd7 <_panic+0x43>
	...

00800cdc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	83 ec 10             	sub    $0x10,%esp
  800ce4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cea:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cf0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cf3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	75 2e                	jne    800d28 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cfa:	39 f1                	cmp    %esi,%ecx
  800cfc:	77 5a                	ja     800d58 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cfe:	85 c9                	test   %ecx,%ecx
  800d00:	75 0b                	jne    800d0d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d02:	b8 01 00 00 00       	mov    $0x1,%eax
  800d07:	31 d2                	xor    %edx,%edx
  800d09:	f7 f1                	div    %ecx
  800d0b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	89 f0                	mov    %esi,%eax
  800d11:	f7 f1                	div    %ecx
  800d13:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	f7 f1                	div    %ecx
  800d19:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    
  800d26:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	77 1c                	ja     800d48 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d2c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d2f:	83 f7 1f             	xor    $0x1f,%edi
  800d32:	75 3c                	jne    800d70 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d34:	39 f0                	cmp    %esi,%eax
  800d36:	0f 82 90 00 00 00    	jb     800dcc <__udivdi3+0xf0>
  800d3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d3f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d42:	0f 86 84 00 00 00    	jbe    800dcc <__udivdi3+0xf0>
  800d48:	31 f6                	xor    %esi,%esi
  800d4a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d4c:	89 f8                	mov    %edi,%eax
  800d4e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    
  800d57:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	89 f8                	mov    %edi,%eax
  800d5c:	f7 f1                	div    %ecx
  800d5e:	89 c7                	mov    %eax,%edi
  800d60:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d62:	89 f8                	mov    %edi,%eax
  800d64:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d70:	89 f9                	mov    %edi,%ecx
  800d72:	d3 e0                	shl    %cl,%eax
  800d74:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d77:	b8 20 00 00 00       	mov    $0x20,%eax
  800d7c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d81:	88 c1                	mov    %al,%cl
  800d83:	d3 ea                	shr    %cl,%edx
  800d85:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d88:	09 ca                	or     %ecx,%edx
  800d8a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	d3 e2                	shl    %cl,%edx
  800d94:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d97:	89 f2                	mov    %esi,%edx
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800da0:	89 f2                	mov    %esi,%edx
  800da2:	89 f9                	mov    %edi,%ecx
  800da4:	d3 e2                	shl    %cl,%edx
  800da6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800da9:	88 c1                	mov    %al,%cl
  800dab:	d3 ee                	shr    %cl,%esi
  800dad:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800daf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	89 ca                	mov    %ecx,%edx
  800db6:	f7 75 ec             	divl   -0x14(%ebp)
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dbd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc0:	39 d1                	cmp    %edx,%ecx
  800dc2:	72 28                	jb     800dec <__udivdi3+0x110>
  800dc4:	74 1a                	je     800de0 <__udivdi3+0x104>
  800dc6:	89 f7                	mov    %esi,%edi
  800dc8:	31 f6                	xor    %esi,%esi
  800dca:	eb 80                	jmp    800d4c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dcc:	31 f6                	xor    %esi,%esi
  800dce:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd3:	89 f8                	mov    %edi,%eax
  800dd5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800de0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de3:	89 f9                	mov    %edi,%ecx
  800de5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de7:	39 c2                	cmp    %eax,%edx
  800de9:	73 db                	jae    800dc6 <__udivdi3+0xea>
  800deb:	90                   	nop
		{
		  q0--;
  800dec:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800def:	31 f6                	xor    %esi,%esi
  800df1:	e9 56 ff ff ff       	jmp    800d4c <__udivdi3+0x70>
	...

00800df8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	83 ec 20             	sub    $0x20,%esp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e06:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e09:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e0c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e15:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e17:	85 ff                	test   %edi,%edi
  800e19:	75 15                	jne    800e30 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	0f 86 99 00 00 00    	jbe    800ebc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e23:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e25:	89 d0                	mov    %edx,%eax
  800e27:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e29:	83 c4 20             	add    $0x20,%esp
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e30:	39 f7                	cmp    %esi,%edi
  800e32:	0f 87 a4 00 00 00    	ja     800edc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e38:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e3b:	83 f0 1f             	xor    $0x1f,%eax
  800e3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e41:	0f 84 a1 00 00 00    	je     800ee8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e47:	89 f8                	mov    %edi,%eax
  800e49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e4c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e53:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e59:	89 f9                	mov    %edi,%ecx
  800e5b:	d3 ea                	shr    %cl,%edx
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e65:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e68:	d3 e0                	shl    %cl,%eax
  800e6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e6d:	89 f2                	mov    %esi,%edx
  800e6f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e74:	d3 e0                	shl    %cl,%eax
  800e76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e7c:	89 f9                	mov    %edi,%ecx
  800e7e:	d3 e8                	shr    %cl,%eax
  800e80:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e82:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e84:	89 f2                	mov    %esi,%edx
  800e86:	f7 75 f0             	divl   -0x10(%ebp)
  800e89:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e8b:	f7 65 f4             	mull   -0xc(%ebp)
  800e8e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e91:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	72 71                	jb     800f08 <__umoddi3+0x110>
  800e97:	74 7f                	je     800f18 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9c:	29 c8                	sub    %ecx,%eax
  800e9e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ea3:	d3 e8                	shr    %cl,%eax
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	89 f9                	mov    %edi,%ecx
  800ea9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eab:	09 d0                	or     %edx,%eax
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eb2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ebc:	85 c9                	test   %ecx,%ecx
  800ebe:	75 0b                	jne    800ecb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 f1                	div    %ecx
  800ec9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed4:	f7 f1                	div    %ecx
  800ed6:	e9 4a ff ff ff       	jmp    800e25 <__umoddi3+0x2d>
  800edb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800edc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ede:	83 c4 20             	add    $0x20,%esp
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee8:	39 f7                	cmp    %esi,%edi
  800eea:	72 05                	jb     800ef1 <__umoddi3+0xf9>
  800eec:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800eef:	77 0c                	ja     800efd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef1:	89 f2                	mov    %esi,%edx
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	29 c8                	sub    %ecx,%eax
  800ef8:	19 fa                	sbb    %edi,%edx
  800efa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    
  800f07:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f08:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f10:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f13:	eb 84                	jmp    800e99 <__umoddi3+0xa1>
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f1b:	72 eb                	jb     800f08 <__umoddi3+0x110>
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	e9 75 ff ff ff       	jmp    800e99 <__umoddi3+0xa1>
