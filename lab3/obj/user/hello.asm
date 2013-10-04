
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
	cprintf("hello, world\n");
  80003a:	68 a0 0d 80 00       	push   $0x800da0
  80003f:	e8 f8 00 00 00       	call   80013c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 20 80 00       	mov    0x802004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 ae 0d 80 00       	push   $0x800dae
  800055:	e8 e2 00 00 00       	call   80013c <cprintf>
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
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
  800091:	83 c4 10             	add    $0x10,%esp
}
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
  8000a0:	e8 08 0a 00 00       	call   800aad <sys_env_destroy>
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
  8000d5:	e8 96 09 00 00       	call   800a70 <sys_cputs>
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
  80012f:	e8 3c 09 00 00       	call   800a70 <sys_cputs>

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
  8001a4:	e8 af 09 00 00       	call   800b58 <__udivdi3>
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
  8001e0:	e8 8f 0a 00 00       	call   800c74 <__umoddi3>
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	0f be 80 cf 0d 80 00 	movsbl 0x800dcf(%eax),%eax
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
  80032c:	ff 24 85 5c 0e 80 00 	jmp    *0x800e5c(,%eax,4)
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
  8003d3:	83 f8 06             	cmp    $0x6,%eax
  8003d6:	7f 0b                	jg     8003e3 <vprintfmt+0x142>
  8003d8:	8b 04 85 b4 0f 80 00 	mov    0x800fb4(,%eax,4),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	75 1a                	jne    8003fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003e3:	52                   	push   %edx
  8003e4:	68 e7 0d 80 00       	push   $0x800de7
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
  8003fe:	68 f0 0d 80 00       	push   $0x800df0
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
  800434:	c7 45 d0 e0 0d 80 00 	movl   $0x800de0,-0x30(%ebp)
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

00800a70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	89 c6                	mov    %eax,%esi
  800a87:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9e:	89 d1                	mov    %edx,%ecx
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	89 d7                	mov    %edx,%edi
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	89 cb                	mov    %ecx,%ebx
  800ac5:	89 cf                	mov    %ecx,%edi
  800ac7:	89 ce                	mov    %ecx,%esi
  800ac9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acb:	85 c0                	test   %eax,%eax
  800acd:	7e 17                	jle    800ae6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	50                   	push   %eax
  800ad3:	6a 03                	push   $0x3
  800ad5:	68 d0 0f 80 00       	push   $0x800fd0
  800ada:	6a 23                	push   $0x23
  800adc:	68 ed 0f 80 00       	push   $0x800fed
  800ae1:	e8 2a 00 00 00       	call   800b10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 02 00 00 00       	mov    $0x2,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b15:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b18:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b1e:	e8 cb ff ff ff       	call   800aee <sys_getenvid>
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	ff 75 08             	pushl  0x8(%ebp)
  800b2c:	53                   	push   %ebx
  800b2d:	50                   	push   %eax
  800b2e:	68 fc 0f 80 00       	push   $0x800ffc
  800b33:	e8 04 f6 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b38:	83 c4 18             	add    $0x18,%esp
  800b3b:	56                   	push   %esi
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	e8 a7 f5 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800b44:	c7 04 24 ac 0d 80 00 	movl   $0x800dac,(%esp)
  800b4b:	e8 ec f5 ff ff       	call   80013c <cprintf>
  800b50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b53:	cc                   	int3   
  800b54:	eb fd                	jmp    800b53 <_panic+0x43>
	...

00800b58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	83 ec 10             	sub    $0x10,%esp
  800b60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b72:	85 c0                	test   %eax,%eax
  800b74:	75 2e                	jne    800ba4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b76:	39 f1                	cmp    %esi,%ecx
  800b78:	77 5a                	ja     800bd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b7a:	85 c9                	test   %ecx,%ecx
  800b7c:	75 0b                	jne    800b89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b83:	31 d2                	xor    %edx,%edx
  800b85:	f7 f1                	div    %ecx
  800b87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b89:	31 d2                	xor    %edx,%edx
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	f7 f1                	div    %ecx
  800b8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	f7 f1                	div    %ecx
  800b95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b97:	89 f8                	mov    %edi,%eax
  800b99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    
  800ba2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ba4:	39 f0                	cmp    %esi,%eax
  800ba6:	77 1c                	ja     800bc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ba8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bab:	83 f7 1f             	xor    $0x1f,%edi
  800bae:	75 3c                	jne    800bec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bb0:	39 f0                	cmp    %esi,%eax
  800bb2:	0f 82 90 00 00 00    	jb     800c48 <__udivdi3+0xf0>
  800bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bbe:	0f 86 84 00 00 00    	jbe    800c48 <__udivdi3+0xf0>
  800bc4:	31 f6                	xor    %esi,%esi
  800bc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc8:	89 f8                	mov    %edi,%eax
  800bca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    
  800bd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	f7 f1                	div    %ecx
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bde:	89 f8                	mov    %edi,%eax
  800be0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    
  800be9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bec:	89 f9                	mov    %edi,%ecx
  800bee:	d3 e0                	shl    %cl,%eax
  800bf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bf3:	b8 20 00 00 00       	mov    $0x20,%eax
  800bf8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfd:	88 c1                	mov    %al,%cl
  800bff:	d3 ea                	shr    %cl,%edx
  800c01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c04:	09 ca                	or     %ecx,%edx
  800c06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c0c:	89 f9                	mov    %edi,%ecx
  800c0e:	d3 e2                	shl    %cl,%edx
  800c10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c13:	89 f2                	mov    %esi,%edx
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ea                	shr    %cl,%edx
  800c19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c1c:	89 f2                	mov    %esi,%edx
  800c1e:	89 f9                	mov    %edi,%ecx
  800c20:	d3 e2                	shl    %cl,%edx
  800c22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c25:	88 c1                	mov    %al,%cl
  800c27:	d3 ee                	shr    %cl,%esi
  800c29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c2e:	89 f0                	mov    %esi,%eax
  800c30:	89 ca                	mov    %ecx,%edx
  800c32:	f7 75 ec             	divl   -0x14(%ebp)
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c3c:	39 d1                	cmp    %edx,%ecx
  800c3e:	72 28                	jb     800c68 <__udivdi3+0x110>
  800c40:	74 1a                	je     800c5c <__udivdi3+0x104>
  800c42:	89 f7                	mov    %esi,%edi
  800c44:	31 f6                	xor    %esi,%esi
  800c46:	eb 80                	jmp    800bc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c48:	31 f6                	xor    %esi,%esi
  800c4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c4f:	89 f8                	mov    %edi,%eax
  800c51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    
  800c5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5f:	89 f9                	mov    %edi,%ecx
  800c61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c63:	39 c2                	cmp    %eax,%edx
  800c65:	73 db                	jae    800c42 <__udivdi3+0xea>
  800c67:	90                   	nop
		{
		  q0--;
  800c68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c6b:	31 f6                	xor    %esi,%esi
  800c6d:	e9 56 ff ff ff       	jmp    800bc8 <__udivdi3+0x70>
	...

00800c74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	83 ec 20             	sub    $0x20,%esp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c93:	85 ff                	test   %edi,%edi
  800c95:	75 15                	jne    800cac <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c97:	39 f1                	cmp    %esi,%ecx
  800c99:	0f 86 99 00 00 00    	jbe    800d38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ca1:	89 d0                	mov    %edx,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ca5:	83 c4 20             	add    $0x20,%esp
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cac:	39 f7                	cmp    %esi,%edi
  800cae:	0f 87 a4 00 00 00    	ja     800d58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cb7:	83 f0 1f             	xor    $0x1f,%eax
  800cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbd:	0f 84 a1 00 00 00    	je     800d64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cc3:	89 f8                	mov    %edi,%eax
  800cc5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cca:	bf 20 00 00 00       	mov    $0x20,%edi
  800ccf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd5:	89 f9                	mov    %edi,%ecx
  800cd7:	d3 ea                	shr    %cl,%edx
  800cd9:	09 c2                	or     %eax,%edx
  800cdb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ce4:	d3 e0                	shl    %cl,%eax
  800ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf0:	d3 e0                	shl    %cl,%eax
  800cf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf8:	89 f9                	mov    %edi,%ecx
  800cfa:	d3 e8                	shr    %cl,%eax
  800cfc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cfe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	f7 75 f0             	divl   -0x10(%ebp)
  800d05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d07:	f7 65 f4             	mull   -0xc(%ebp)
  800d0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d0f:	39 d6                	cmp    %edx,%esi
  800d11:	72 71                	jb     800d84 <__umoddi3+0x110>
  800d13:	74 7f                	je     800d94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d18:	29 c8                	sub    %ecx,%eax
  800d1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1f:	d3 e8                	shr    %cl,%eax
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	89 f9                	mov    %edi,%ecx
  800d25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d27:	09 d0                	or     %edx,%eax
  800d29:	89 f2                	mov    %esi,%edx
  800d2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d30:	83 c4 20             	add    $0x20,%esp
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    
  800d37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d38:	85 c9                	test   %ecx,%ecx
  800d3a:	75 0b                	jne    800d47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d41:	31 d2                	xor    %edx,%edx
  800d43:	f7 f1                	div    %ecx
  800d45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	31 d2                	xor    %edx,%edx
  800d4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d50:	f7 f1                	div    %ecx
  800d52:	e9 4a ff ff ff       	jmp    800ca1 <__umoddi3+0x2d>
  800d57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d5a:	83 c4 20             	add    $0x20,%esp
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    
  800d61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d64:	39 f7                	cmp    %esi,%edi
  800d66:	72 05                	jb     800d6d <__umoddi3+0xf9>
  800d68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d6b:	77 0c                	ja     800d79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d72:	29 c8                	sub    %ecx,%eax
  800d74:	19 fa                	sbb    %edi,%edx
  800d76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    
  800d83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d87:	89 c1                	mov    %eax,%ecx
  800d89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d8f:	eb 84                	jmp    800d15 <__umoddi3+0xa1>
  800d91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d97:	72 eb                	jb     800d84 <__umoddi3+0x110>
  800d99:	89 f2                	mov    %esi,%edx
  800d9b:	e9 75 ff ff ff       	jmp    800d15 <__umoddi3+0xa1>
