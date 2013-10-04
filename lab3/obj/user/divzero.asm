
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
  800052:	68 a4 0d 80 00       	push   $0x800da4
  800057:	e8 e4 00 00 00       	call   800140 <cprintf>
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
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	8b 45 08             	mov    0x8(%ebp),%eax
  80006d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800070:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800077:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 c0                	test   %eax,%eax
  80007c:	7e 08                	jle    800086 <libmain+0x22>
		binaryname = argv[0];
  80007e:	8b 0a                	mov    (%edx),%ecx
  800080:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	52                   	push   %edx
  80008a:	50                   	push   %eax
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 07 00 00 00       	call   80009c <exit>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 08 0a 00 00       	call   800ab1 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c3:	40                   	inc    %eax
  8000c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 96 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	ff 43 04             	incl   0x4(%ebx)
}
  8000ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000ff:	00 00 00 
	b.cnt = 0;
  800102:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800109:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010c:	ff 75 0c             	pushl  0xc(%ebp)
  80010f:	ff 75 08             	pushl  0x8(%ebp)
  800112:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800118:	50                   	push   %eax
  800119:	68 b0 00 80 00       	push   $0x8000b0
  80011e:	e8 82 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800123:	83 c4 08             	add    $0x8,%esp
  800126:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800132:	50                   	push   %eax
  800133:	e8 3c 09 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  800138:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800146:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800149:	50                   	push   %eax
  80014a:	ff 75 08             	pushl  0x8(%ebp)
  80014d:	e8 9d ff ff ff       	call   8000ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 2c             	sub    $0x2c,%esp
  80015d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80016e:	8b 45 10             	mov    0x10(%ebp),%eax
  800171:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800174:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800177:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80017a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800181:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800184:	72 0c                	jb     800192 <printnum+0x3e>
  800186:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800189:	76 07                	jbe    800192 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80018b:	4b                   	dec    %ebx
  80018c:	85 db                	test   %ebx,%ebx
  80018e:	7f 31                	jg     8001c1 <printnum+0x6d>
  800190:	eb 3f                	jmp    8001d1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	4b                   	dec    %ebx
  800197:	53                   	push   %ebx
  800198:	50                   	push   %eax
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80019f:	ff 75 d0             	pushl  -0x30(%ebp)
  8001a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a8:	e8 af 09 00 00       	call   800b5c <__udivdi3>
  8001ad:	83 c4 18             	add    $0x18,%esp
  8001b0:	52                   	push   %edx
  8001b1:	50                   	push   %eax
  8001b2:	89 f2                	mov    %esi,%edx
  8001b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001b7:	e8 98 ff ff ff       	call   800154 <printnum>
  8001bc:	83 c4 20             	add    $0x20,%esp
  8001bf:	eb 10                	jmp    8001d1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	56                   	push   %esi
  8001c5:	57                   	push   %edi
  8001c6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c9:	4b                   	dec    %ebx
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 db                	test   %ebx,%ebx
  8001cf:	7f f0                	jg     8001c1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	83 ec 04             	sub    $0x4,%esp
  8001d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001db:	ff 75 d0             	pushl  -0x30(%ebp)
  8001de:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e4:	e8 8f 0a 00 00       	call   800c78 <__umoddi3>
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	0f be 80 bc 0d 80 00 	movsbl 0x800dbc(%eax),%eax
  8001f3:	50                   	push   %eax
  8001f4:	ff 55 e4             	call   *-0x1c(%ebp)
  8001f7:	83 c4 10             	add    $0x10,%esp
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800205:	83 fa 01             	cmp    $0x1,%edx
  800208:	7e 0e                	jle    800218 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020a:	8b 10                	mov    (%eax),%edx
  80020c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020f:	89 08                	mov    %ecx,(%eax)
  800211:	8b 02                	mov    (%edx),%eax
  800213:	8b 52 04             	mov    0x4(%edx),%edx
  800216:	eb 22                	jmp    80023a <getuint+0x38>
	else if (lflag)
  800218:	85 d2                	test   %edx,%edx
  80021a:	74 10                	je     80022c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	eb 0e                	jmp    80023a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800231:	89 08                	mov    %ecx,(%eax)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023f:	83 fa 01             	cmp    $0x1,%edx
  800242:	7e 0e                	jle    800252 <getint+0x16>
		return va_arg(*ap, long long);
  800244:	8b 10                	mov    (%eax),%edx
  800246:	8d 4a 08             	lea    0x8(%edx),%ecx
  800249:	89 08                	mov    %ecx,(%eax)
  80024b:	8b 02                	mov    (%edx),%eax
  80024d:	8b 52 04             	mov    0x4(%edx),%edx
  800250:	eb 1a                	jmp    80026c <getint+0x30>
	else if (lflag)
  800252:	85 d2                	test   %edx,%edx
  800254:	74 0c                	je     800262 <getint+0x26>
		return va_arg(*ap, long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	99                   	cltd   
  800260:	eb 0a                	jmp    80026c <getint+0x30>
	else
		return va_arg(*ap, int);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	99                   	cltd   
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800274:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800277:	8b 10                	mov    (%eax),%edx
  800279:	3b 50 04             	cmp    0x4(%eax),%edx
  80027c:	73 08                	jae    800286 <sprintputch+0x18>
		*b->buf++ = ch;
  80027e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800281:	88 0a                	mov    %cl,(%edx)
  800283:	42                   	inc    %edx
  800284:	89 10                	mov    %edx,(%eax)
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
  8002a0:	83 c4 10             	add    $0x10,%esp
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002b4:	eb 13                	jmp    8002c9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	0f 84 6d 03 00 00    	je     80062b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	57                   	push   %edi
  8002c2:	50                   	push   %eax
  8002c3:	ff 55 08             	call   *0x8(%ebp)
  8002c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c9:	0f b6 06             	movzbl (%esi),%eax
  8002cc:	46                   	inc    %esi
  8002cd:	83 f8 25             	cmp    $0x25,%eax
  8002d0:	75 e4                	jne    8002b6 <vprintfmt+0x11>
  8002d2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002dd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002e4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f0:	eb 28                	jmp    80031a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8002f8:	eb 20                	jmp    80031a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800300:	eb 18                	jmp    80031a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800302:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800304:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80030b:	eb 0d                	jmp    80031a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80030d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800313:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8a 06                	mov    (%esi),%al
  80031c:	0f b6 d0             	movzbl %al,%edx
  80031f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800322:	83 e8 23             	sub    $0x23,%eax
  800325:	3c 55                	cmp    $0x55,%al
  800327:	0f 87 e0 02 00 00    	ja     80060d <vprintfmt+0x368>
  80032d:	0f b6 c0             	movzbl %al,%eax
  800330:	ff 24 85 4c 0e 80 00 	jmp    *0x800e4c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800337:	83 ea 30             	sub    $0x30,%edx
  80033a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80033d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800340:	8d 50 d0             	lea    -0x30(%eax),%edx
  800343:	83 fa 09             	cmp    $0x9,%edx
  800346:	77 44                	ja     80038c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	89 de                	mov    %ebx,%esi
  80034a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80034e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800351:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800355:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800358:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80035b:	83 fb 09             	cmp    $0x9,%ebx
  80035e:	76 ed                	jbe    80034d <vprintfmt+0xa8>
  800360:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800363:	eb 29                	jmp    80038e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8d 50 04             	lea    0x4(%eax),%edx
  80036b:	89 55 14             	mov    %edx,0x14(%ebp)
  80036e:	8b 00                	mov    (%eax),%eax
  800370:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800375:	eb 17                	jmp    80038e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800377:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80037b:	78 85                	js     800302 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	89 de                	mov    %ebx,%esi
  80037f:	eb 99                	jmp    80031a <vprintfmt+0x75>
  800381:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800383:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80038a:	eb 8e                	jmp    80031a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800392:	79 86                	jns    80031a <vprintfmt+0x75>
  800394:	e9 74 ff ff ff       	jmp    80030d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800399:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	89 de                	mov    %ebx,%esi
  80039c:	e9 79 ff ff ff       	jmp    80031a <vprintfmt+0x75>
  8003a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	57                   	push   %edi
  8003b1:	ff 30                	pushl  (%eax)
  8003b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bc:	e9 08 ff ff ff       	jmp    8002c9 <vprintfmt+0x24>
  8003c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	79 02                	jns    8003d5 <vprintfmt+0x130>
  8003d3:	f7 d8                	neg    %eax
  8003d5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d7:	83 f8 06             	cmp    $0x6,%eax
  8003da:	7f 0b                	jg     8003e7 <vprintfmt+0x142>
  8003dc:	8b 04 85 a4 0f 80 00 	mov    0x800fa4(,%eax,4),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	75 1a                	jne    800401 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003e7:	52                   	push   %edx
  8003e8:	68 d4 0d 80 00       	push   $0x800dd4
  8003ed:	57                   	push   %edi
  8003ee:	ff 75 08             	pushl  0x8(%ebp)
  8003f1:	e8 92 fe ff ff       	call   800288 <printfmt>
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003fc:	e9 c8 fe ff ff       	jmp    8002c9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800401:	50                   	push   %eax
  800402:	68 dd 0d 80 00       	push   $0x800ddd
  800407:	57                   	push   %edi
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 78 fe ff ff       	call   800288 <printfmt>
  800410:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800416:	e9 ae fe ff ff       	jmp    8002c9 <vprintfmt+0x24>
  80041b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80041e:	89 de                	mov    %ebx,%esi
  800420:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800423:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800434:	85 c0                	test   %eax,%eax
  800436:	75 07                	jne    80043f <vprintfmt+0x19a>
				p = "(null)";
  800438:	c7 45 d0 cd 0d 80 00 	movl   $0x800dcd,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80043f:	85 db                	test   %ebx,%ebx
  800441:	7e 42                	jle    800485 <vprintfmt+0x1e0>
  800443:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800447:	74 3c                	je     800485 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	51                   	push   %ecx
  80044d:	ff 75 d0             	pushl  -0x30(%ebp)
  800450:	e8 6f 02 00 00       	call   8006c4 <strnlen>
  800455:	29 c3                	sub    %eax,%ebx
  800457:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 db                	test   %ebx,%ebx
  80045f:	7e 24                	jle    800485 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800461:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800465:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800468:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	57                   	push   %edi
  80046f:	53                   	push   %ebx
  800470:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	4e                   	dec    %esi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	85 f6                	test   %esi,%esi
  800479:	7f f0                	jg     80046b <vprintfmt+0x1c6>
  80047b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80047e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800485:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800488:	0f be 02             	movsbl (%edx),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	75 47                	jne    8004d6 <vprintfmt+0x231>
  80048f:	eb 37                	jmp    8004c8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800491:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800495:	74 16                	je     8004ad <vprintfmt+0x208>
  800497:	8d 50 e0             	lea    -0x20(%eax),%edx
  80049a:	83 fa 5e             	cmp    $0x5e,%edx
  80049d:	76 0e                	jbe    8004ad <vprintfmt+0x208>
					putch('?', putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	57                   	push   %edi
  8004a3:	6a 3f                	push   $0x3f
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb 0b                	jmp    8004b8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	57                   	push   %edi
  8004b1:	50                   	push   %eax
  8004b2:	ff 55 08             	call   *0x8(%ebp)
  8004b5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004bb:	0f be 03             	movsbl (%ebx),%eax
  8004be:	85 c0                	test   %eax,%eax
  8004c0:	74 03                	je     8004c5 <vprintfmt+0x220>
  8004c2:	43                   	inc    %ebx
  8004c3:	eb 1b                	jmp    8004e0 <vprintfmt+0x23b>
  8004c5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cc:	7f 1e                	jg     8004ec <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d1:	e9 f3 fd ff ff       	jmp    8002c9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004d9:	43                   	inc    %ebx
  8004da:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004dd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004e0:	85 f6                	test   %esi,%esi
  8004e2:	78 ad                	js     800491 <vprintfmt+0x1ec>
  8004e4:	4e                   	dec    %esi
  8004e5:	79 aa                	jns    800491 <vprintfmt+0x1ec>
  8004e7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ea:	eb dc                	jmp    8004c8 <vprintfmt+0x223>
  8004ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	57                   	push   %edi
  8004f3:	6a 20                	push   $0x20
  8004f5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f8:	4b                   	dec    %ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 db                	test   %ebx,%ebx
  8004fe:	7f ef                	jg     8004ef <vprintfmt+0x24a>
  800500:	e9 c4 fd ff ff       	jmp    8002c9 <vprintfmt+0x24>
  800505:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800508:	89 ca                	mov    %ecx,%edx
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
  80050d:	e8 2a fd ff ff       	call   80023c <getint>
  800512:	89 c3                	mov    %eax,%ebx
  800514:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800516:	85 d2                	test   %edx,%edx
  800518:	78 0a                	js     800524 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80051a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051f:	e9 b0 00 00 00       	jmp    8005d4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	57                   	push   %edi
  800528:	6a 2d                	push   $0x2d
  80052a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80052d:	f7 db                	neg    %ebx
  80052f:	83 d6 00             	adc    $0x0,%esi
  800532:	f7 de                	neg    %esi
  800534:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800537:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053c:	e9 93 00 00 00       	jmp    8005d4 <vprintfmt+0x32f>
  800541:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800544:	89 ca                	mov    %ecx,%edx
  800546:	8d 45 14             	lea    0x14(%ebp),%eax
  800549:	e8 b4 fc ff ff       	call   800202 <getuint>
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	89 d6                	mov    %edx,%esi
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800557:	eb 7b                	jmp    8005d4 <vprintfmt+0x32f>
  800559:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80055c:	89 ca                	mov    %ecx,%edx
  80055e:	8d 45 14             	lea    0x14(%ebp),%eax
  800561:	e8 d6 fc ff ff       	call   80023c <getint>
  800566:	89 c3                	mov    %eax,%ebx
  800568:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80056a:	85 d2                	test   %edx,%edx
  80056c:	78 07                	js     800575 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80056e:	b8 08 00 00 00       	mov    $0x8,%eax
  800573:	eb 5f                	jmp    8005d4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	6a 2d                	push   $0x2d
  80057b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80057e:	f7 db                	neg    %ebx
  800580:	83 d6 00             	adc    $0x0,%esi
  800583:	f7 de                	neg    %esi
  800585:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800588:	b8 08 00 00 00       	mov    $0x8,%eax
  80058d:	eb 45                	jmp    8005d4 <vprintfmt+0x32f>
  80058f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	57                   	push   %edi
  800596:	6a 30                	push   $0x30
  800598:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	6a 78                	push   $0x78
  8005a1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ad:	8b 18                	mov    (%eax),%ebx
  8005af:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005bc:	eb 16                	jmp    8005d4 <vprintfmt+0x32f>
  8005be:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c1:	89 ca                	mov    %ecx,%edx
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	e8 37 fc ff ff       	call   800202 <getuint>
  8005cb:	89 c3                	mov    %eax,%ebx
  8005cd:	89 d6                	mov    %edx,%esi
			base = 16;
  8005cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005db:	52                   	push   %edx
  8005dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005df:	50                   	push   %eax
  8005e0:	56                   	push   %esi
  8005e1:	53                   	push   %ebx
  8005e2:	89 fa                	mov    %edi,%edx
  8005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e7:	e8 68 fb ff ff       	call   800154 <printnum>
			break;
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f2:	e9 d2 fc ff ff       	jmp    8002c9 <vprintfmt+0x24>
  8005f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	57                   	push   %edi
  8005fe:	52                   	push   %edx
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			break;
  800602:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800608:	e9 bc fc ff ff       	jmp    8002c9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	6a 25                	push   $0x25
  800613:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb 02                	jmp    80061d <vprintfmt+0x378>
  80061b:	89 c6                	mov    %eax,%esi
  80061d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800620:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800624:	75 f5                	jne    80061b <vprintfmt+0x376>
  800626:	e9 9e fc ff ff       	jmp    8002c9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	c9                   	leave  
  800632:	c3                   	ret    

00800633 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	83 ec 18             	sub    $0x18,%esp
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800642:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800646:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800649:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800650:	85 c0                	test   %eax,%eax
  800652:	74 26                	je     80067a <vsnprintf+0x47>
  800654:	85 d2                	test   %edx,%edx
  800656:	7e 29                	jle    800681 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800658:	ff 75 14             	pushl  0x14(%ebp)
  80065b:	ff 75 10             	pushl  0x10(%ebp)
  80065e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800661:	50                   	push   %eax
  800662:	68 6e 02 80 00       	push   $0x80026e
  800667:	e8 39 fc ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	eb 0c                	jmp    800686 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80067f:	eb 05                	jmp    800686 <vsnprintf+0x53>
  800681:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800691:	50                   	push   %eax
  800692:	ff 75 10             	pushl  0x10(%ebp)
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	ff 75 08             	pushl  0x8(%ebp)
  80069b:	e8 93 ff ff ff       	call   800633 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    
	...

008006a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006aa:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ad:	74 0e                	je     8006bd <strlen+0x19>
  8006af:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006b4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b9:	75 f9                	jne    8006b4 <strlen+0x10>
  8006bb:	eb 05                	jmp    8006c2 <strlen+0x1e>
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	74 17                	je     8006e8 <strnlen+0x24>
  8006d1:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d4:	74 19                	je     8006ef <strnlen+0x2b>
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006db:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006dc:	39 d0                	cmp    %edx,%eax
  8006de:	74 14                	je     8006f4 <strnlen+0x30>
  8006e0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e4:	75 f5                	jne    8006db <strnlen+0x17>
  8006e6:	eb 0c                	jmp    8006f4 <strnlen+0x30>
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	eb 05                	jmp    8006f4 <strnlen+0x30>
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800700:	ba 00 00 00 00       	mov    $0x0,%edx
  800705:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800708:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80070b:	42                   	inc    %edx
  80070c:	84 c9                	test   %cl,%cl
  80070e:	75 f5                	jne    800705 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800710:	5b                   	pop    %ebx
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071a:	53                   	push   %ebx
  80071b:	e8 84 ff ff ff       	call   8006a4 <strlen>
  800720:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800729:	50                   	push   %eax
  80072a:	e8 c7 ff ff ff       	call   8006f6 <strcpy>
	return dst;
}
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800744:	85 f6                	test   %esi,%esi
  800746:	74 15                	je     80075d <strncpy+0x27>
  800748:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80074d:	8a 1a                	mov    (%edx),%bl
  80074f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800752:	80 3a 01             	cmpb   $0x1,(%edx)
  800755:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800758:	41                   	inc    %ecx
  800759:	39 ce                	cmp    %ecx,%esi
  80075b:	77 f0                	ja     80074d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	57                   	push   %edi
  800765:	56                   	push   %esi
  800766:	53                   	push   %ebx
  800767:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800770:	85 f6                	test   %esi,%esi
  800772:	74 32                	je     8007a6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800774:	83 fe 01             	cmp    $0x1,%esi
  800777:	74 22                	je     80079b <strlcpy+0x3a>
  800779:	8a 0b                	mov    (%ebx),%cl
  80077b:	84 c9                	test   %cl,%cl
  80077d:	74 20                	je     80079f <strlcpy+0x3e>
  80077f:	89 f8                	mov    %edi,%eax
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800786:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800789:	88 08                	mov    %cl,(%eax)
  80078b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 f2                	cmp    %esi,%edx
  80078e:	74 11                	je     8007a1 <strlcpy+0x40>
  800790:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800794:	42                   	inc    %edx
  800795:	84 c9                	test   %cl,%cl
  800797:	75 f0                	jne    800789 <strlcpy+0x28>
  800799:	eb 06                	jmp    8007a1 <strlcpy+0x40>
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	eb 02                	jmp    8007a1 <strlcpy+0x40>
  80079f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a1:	c6 00 00             	movb   $0x0,(%eax)
  8007a4:	eb 02                	jmp    8007a8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007a8:	29 f8                	sub    %edi,%eax
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b8:	8a 01                	mov    (%ecx),%al
  8007ba:	84 c0                	test   %al,%al
  8007bc:	74 10                	je     8007ce <strcmp+0x1f>
  8007be:	3a 02                	cmp    (%edx),%al
  8007c0:	75 0c                	jne    8007ce <strcmp+0x1f>
		p++, q++;
  8007c2:	41                   	inc    %ecx
  8007c3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c4:	8a 01                	mov    (%ecx),%al
  8007c6:	84 c0                	test   %al,%al
  8007c8:	74 04                	je     8007ce <strcmp+0x1f>
  8007ca:	3a 02                	cmp    (%edx),%al
  8007cc:	74 f4                	je     8007c2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ce:	0f b6 c0             	movzbl %al,%eax
  8007d1:	0f b6 12             	movzbl (%edx),%edx
  8007d4:	29 d0                	sub    %edx,%eax
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 1b                	je     800804 <strncmp+0x2c>
  8007e9:	8a 1a                	mov    (%edx),%bl
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	74 24                	je     800813 <strncmp+0x3b>
  8007ef:	3a 19                	cmp    (%ecx),%bl
  8007f1:	75 20                	jne    800813 <strncmp+0x3b>
  8007f3:	48                   	dec    %eax
  8007f4:	74 15                	je     80080b <strncmp+0x33>
		n--, p++, q++;
  8007f6:	42                   	inc    %edx
  8007f7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f8:	8a 1a                	mov    (%edx),%bl
  8007fa:	84 db                	test   %bl,%bl
  8007fc:	74 15                	je     800813 <strncmp+0x3b>
  8007fe:	3a 19                	cmp    (%ecx),%bl
  800800:	74 f1                	je     8007f3 <strncmp+0x1b>
  800802:	eb 0f                	jmp    800813 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	eb 05                	jmp    800810 <strncmp+0x38>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800810:	5b                   	pop    %ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 02             	movzbl (%edx),%eax
  800816:	0f b6 11             	movzbl (%ecx),%edx
  800819:	29 d0                	sub    %edx,%eax
  80081b:	eb f3                	jmp    800810 <strncmp+0x38>

0080081d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800826:	8a 10                	mov    (%eax),%dl
  800828:	84 d2                	test   %dl,%dl
  80082a:	74 18                	je     800844 <strchr+0x27>
		if (*s == c)
  80082c:	38 ca                	cmp    %cl,%dl
  80082e:	75 06                	jne    800836 <strchr+0x19>
  800830:	eb 17                	jmp    800849 <strchr+0x2c>
  800832:	38 ca                	cmp    %cl,%dl
  800834:	74 13                	je     800849 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800836:	40                   	inc    %eax
  800837:	8a 10                	mov    (%eax),%dl
  800839:	84 d2                	test   %dl,%dl
  80083b:	75 f5                	jne    800832 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	eb 05                	jmp    800849 <strchr+0x2c>
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800854:	8a 10                	mov    (%eax),%dl
  800856:	84 d2                	test   %dl,%dl
  800858:	74 11                	je     80086b <strfind+0x20>
		if (*s == c)
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	75 06                	jne    800864 <strfind+0x19>
  80085e:	eb 0b                	jmp    80086b <strfind+0x20>
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 07                	je     80086b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800864:	40                   	inc    %eax
  800865:	8a 10                	mov    (%eax),%dl
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f5                	jne    800860 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 7d 08             	mov    0x8(%ebp),%edi
  800876:	8b 45 0c             	mov    0xc(%ebp),%eax
  800879:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	74 30                	je     8008b0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800880:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800886:	75 25                	jne    8008ad <memset+0x40>
  800888:	f6 c1 03             	test   $0x3,%cl
  80088b:	75 20                	jne    8008ad <memset+0x40>
		c &= 0xFF;
  80088d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800890:	89 d3                	mov    %edx,%ebx
  800892:	c1 e3 08             	shl    $0x8,%ebx
  800895:	89 d6                	mov    %edx,%esi
  800897:	c1 e6 18             	shl    $0x18,%esi
  80089a:	89 d0                	mov    %edx,%eax
  80089c:	c1 e0 10             	shl    $0x10,%eax
  80089f:	09 f0                	or     %esi,%eax
  8008a1:	09 d0                	or     %edx,%eax
  8008a3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a8:	fc                   	cld    
  8008a9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ab:	eb 03                	jmp    8008b0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ad:	fc                   	cld    
  8008ae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b0:	89 f8                	mov    %edi,%eax
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5f                   	pop    %edi
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c5:	39 c6                	cmp    %eax,%esi
  8008c7:	73 34                	jae    8008fd <memmove+0x46>
  8008c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cc:	39 d0                	cmp    %edx,%eax
  8008ce:	73 2d                	jae    8008fd <memmove+0x46>
		s += n;
		d += n;
  8008d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	f6 c2 03             	test   $0x3,%dl
  8008d6:	75 1b                	jne    8008f3 <memmove+0x3c>
  8008d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008de:	75 13                	jne    8008f3 <memmove+0x3c>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 0e                	jne    8008f3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e5:	83 ef 04             	sub    $0x4,%edi
  8008e8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ee:	fd                   	std    
  8008ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f1:	eb 07                	jmp    8008fa <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f3:	4f                   	dec    %edi
  8008f4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f7:	fd                   	std    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fa:	fc                   	cld    
  8008fb:	eb 20                	jmp    80091d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800903:	75 13                	jne    800918 <memmove+0x61>
  800905:	a8 03                	test   $0x3,%al
  800907:	75 0f                	jne    800918 <memmove+0x61>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 0a                	jne    800918 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800911:	89 c7                	mov    %eax,%edi
  800913:	fc                   	cld    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 05                	jmp    80091d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800918:	89 c7                	mov    %eax,%edi
  80091a:	fc                   	cld    
  80091b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	ff 75 0c             	pushl  0xc(%ebp)
  80092a:	ff 75 08             	pushl  0x8(%ebp)
  80092d:	e8 85 ff ff ff       	call   8008b7 <memmove>
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80093d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800940:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	85 ff                	test   %edi,%edi
  800945:	74 32                	je     800979 <memcmp+0x45>
		if (*s1 != *s2)
  800947:	8a 03                	mov    (%ebx),%al
  800949:	8a 0e                	mov    (%esi),%cl
  80094b:	38 c8                	cmp    %cl,%al
  80094d:	74 19                	je     800968 <memcmp+0x34>
  80094f:	eb 0d                	jmp    80095e <memcmp+0x2a>
  800951:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800955:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800959:	42                   	inc    %edx
  80095a:	38 c8                	cmp    %cl,%al
  80095c:	74 10                	je     80096e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80095e:	0f b6 c0             	movzbl %al,%eax
  800961:	0f b6 c9             	movzbl %cl,%ecx
  800964:	29 c8                	sub    %ecx,%eax
  800966:	eb 16                	jmp    80097e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	4f                   	dec    %edi
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
  80096e:	39 fa                	cmp    %edi,%edx
  800970:	75 df                	jne    800951 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	eb 05                	jmp    80097e <memcmp+0x4a>
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800989:	89 c2                	mov    %eax,%edx
  80098b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098e:	39 d0                	cmp    %edx,%eax
  800990:	73 12                	jae    8009a4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800992:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800995:	38 08                	cmp    %cl,(%eax)
  800997:	75 06                	jne    80099f <memfind+0x1c>
  800999:	eb 09                	jmp    8009a4 <memfind+0x21>
  80099b:	38 08                	cmp    %cl,(%eax)
  80099d:	74 05                	je     8009a4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099f:	40                   	inc    %eax
  8009a0:	39 c2                	cmp    %eax,%edx
  8009a2:	77 f7                	ja     80099b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	eb 01                	jmp    8009b5 <strtol+0xf>
		s++;
  8009b4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b5:	8a 02                	mov    (%edx),%al
  8009b7:	3c 20                	cmp    $0x20,%al
  8009b9:	74 f9                	je     8009b4 <strtol+0xe>
  8009bb:	3c 09                	cmp    $0x9,%al
  8009bd:	74 f5                	je     8009b4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bf:	3c 2b                	cmp    $0x2b,%al
  8009c1:	75 08                	jne    8009cb <strtol+0x25>
		s++;
  8009c3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c9:	eb 13                	jmp    8009de <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cb:	3c 2d                	cmp    $0x2d,%al
  8009cd:	75 0a                	jne    8009d9 <strtol+0x33>
		s++, neg = 1;
  8009cf:	8d 52 01             	lea    0x1(%edx),%edx
  8009d2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d7:	eb 05                	jmp    8009de <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009de:	85 db                	test   %ebx,%ebx
  8009e0:	74 05                	je     8009e7 <strtol+0x41>
  8009e2:	83 fb 10             	cmp    $0x10,%ebx
  8009e5:	75 28                	jne    800a0f <strtol+0x69>
  8009e7:	8a 02                	mov    (%edx),%al
  8009e9:	3c 30                	cmp    $0x30,%al
  8009eb:	75 10                	jne    8009fd <strtol+0x57>
  8009ed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f1:	75 0a                	jne    8009fd <strtol+0x57>
		s += 2, base = 16;
  8009f3:	83 c2 02             	add    $0x2,%edx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb 12                	jmp    800a0f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 0e                	jne    800a0f <strtol+0x69>
  800a01:	3c 30                	cmp    $0x30,%al
  800a03:	75 05                	jne    800a0a <strtol+0x64>
		s++, base = 8;
  800a05:	42                   	inc    %edx
  800a06:	b3 08                	mov    $0x8,%bl
  800a08:	eb 05                	jmp    800a0f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a16:	8a 0a                	mov    (%edx),%cl
  800a18:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a1b:	80 fb 09             	cmp    $0x9,%bl
  800a1e:	77 08                	ja     800a28 <strtol+0x82>
			dig = *s - '0';
  800a20:	0f be c9             	movsbl %cl,%ecx
  800a23:	83 e9 30             	sub    $0x30,%ecx
  800a26:	eb 1e                	jmp    800a46 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a28:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a2b:	80 fb 19             	cmp    $0x19,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a30:	0f be c9             	movsbl %cl,%ecx
  800a33:	83 e9 57             	sub    $0x57,%ecx
  800a36:	eb 0e                	jmp    800a46 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a38:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a3b:	80 fb 19             	cmp    $0x19,%bl
  800a3e:	77 13                	ja     800a53 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a40:	0f be c9             	movsbl %cl,%ecx
  800a43:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a46:	39 f1                	cmp    %esi,%ecx
  800a48:	7d 0d                	jge    800a57 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a4a:	42                   	inc    %edx
  800a4b:	0f af c6             	imul   %esi,%eax
  800a4e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a51:	eb c3                	jmp    800a16 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a53:	89 c1                	mov    %eax,%ecx
  800a55:	eb 02                	jmp    800a59 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a57:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a59:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5d:	74 05                	je     800a64 <strtol+0xbe>
		*endptr = (char *) s;
  800a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a62:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a64:	85 ff                	test   %edi,%edi
  800a66:	74 04                	je     800a6c <strtol+0xc6>
  800a68:	89 c8                	mov    %ecx,%eax
  800a6a:	f7 d8                	neg    %eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    
  800a71:	00 00                	add    %al,(%eax)
	...

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 c0 0f 80 00       	push   $0x800fc0
  800ade:	6a 23                	push   $0x23
  800ae0:	68 dd 0f 80 00       	push   $0x800fdd
  800ae5:	e8 2a 00 00 00       	call   800b14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    
  800b11:	00 00                	add    %al,(%eax)
	...

00800b14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b19:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b1c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b22:	e8 cb ff ff ff       	call   800af2 <sys_getenvid>
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	ff 75 0c             	pushl  0xc(%ebp)
  800b2d:	ff 75 08             	pushl  0x8(%ebp)
  800b30:	53                   	push   %ebx
  800b31:	50                   	push   %eax
  800b32:	68 ec 0f 80 00       	push   $0x800fec
  800b37:	e8 04 f6 ff ff       	call   800140 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b3c:	83 c4 18             	add    $0x18,%esp
  800b3f:	56                   	push   %esi
  800b40:	ff 75 10             	pushl  0x10(%ebp)
  800b43:	e8 a7 f5 ff ff       	call   8000ef <vcprintf>
	cprintf("\n");
  800b48:	c7 04 24 b0 0d 80 00 	movl   $0x800db0,(%esp)
  800b4f:	e8 ec f5 ff ff       	call   800140 <cprintf>
  800b54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b57:	cc                   	int3   
  800b58:	eb fd                	jmp    800b57 <_panic+0x43>
	...

00800b5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	83 ec 10             	sub    $0x10,%esp
  800b64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b6a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	75 2e                	jne    800ba8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b7a:	39 f1                	cmp    %esi,%ecx
  800b7c:	77 5a                	ja     800bd8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b7e:	85 c9                	test   %ecx,%ecx
  800b80:	75 0b                	jne    800b8d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	31 d2                	xor    %edx,%edx
  800b89:	f7 f1                	div    %ecx
  800b8b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b8d:	31 d2                	xor    %edx,%edx
  800b8f:	89 f0                	mov    %esi,%eax
  800b91:	f7 f1                	div    %ecx
  800b93:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b95:	89 f8                	mov    %edi,%eax
  800b97:	f7 f1                	div    %ecx
  800b99:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b9b:	89 f8                	mov    %edi,%eax
  800b9d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    
  800ba6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	77 1c                	ja     800bc8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800bac:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800baf:	83 f7 1f             	xor    $0x1f,%edi
  800bb2:	75 3c                	jne    800bf0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bb4:	39 f0                	cmp    %esi,%eax
  800bb6:	0f 82 90 00 00 00    	jb     800c4c <__udivdi3+0xf0>
  800bbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bbf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bc2:	0f 86 84 00 00 00    	jbe    800c4c <__udivdi3+0xf0>
  800bc8:	31 f6                	xor    %esi,%esi
  800bca:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    
  800bd7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd8:	89 f2                	mov    %esi,%edx
  800bda:	89 f8                	mov    %edi,%eax
  800bdc:	f7 f1                	div    %ecx
  800bde:	89 c7                	mov    %eax,%edi
  800be0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800be2:	89 f8                	mov    %edi,%eax
  800be4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    
  800bed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bf0:	89 f9                	mov    %edi,%ecx
  800bf2:	d3 e0                	shl    %cl,%eax
  800bf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bf7:	b8 20 00 00 00       	mov    $0x20,%eax
  800bfc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c01:	88 c1                	mov    %al,%cl
  800c03:	d3 ea                	shr    %cl,%edx
  800c05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c08:	09 ca                	or     %ecx,%edx
  800c0a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c10:	89 f9                	mov    %edi,%ecx
  800c12:	d3 e2                	shl    %cl,%edx
  800c14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c17:	89 f2                	mov    %esi,%edx
  800c19:	88 c1                	mov    %al,%cl
  800c1b:	d3 ea                	shr    %cl,%edx
  800c1d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c20:	89 f2                	mov    %esi,%edx
  800c22:	89 f9                	mov    %edi,%ecx
  800c24:	d3 e2                	shl    %cl,%edx
  800c26:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c29:	88 c1                	mov    %al,%cl
  800c2b:	d3 ee                	shr    %cl,%esi
  800c2d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c2f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	89 ca                	mov    %ecx,%edx
  800c36:	f7 75 ec             	divl   -0x14(%ebp)
  800c39:	89 d1                	mov    %edx,%ecx
  800c3b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c3d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c40:	39 d1                	cmp    %edx,%ecx
  800c42:	72 28                	jb     800c6c <__udivdi3+0x110>
  800c44:	74 1a                	je     800c60 <__udivdi3+0x104>
  800c46:	89 f7                	mov    %esi,%edi
  800c48:	31 f6                	xor    %esi,%esi
  800c4a:	eb 80                	jmp    800bcc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c4c:	31 f6                	xor    %esi,%esi
  800c4e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    
  800c5e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c63:	89 f9                	mov    %edi,%ecx
  800c65:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c67:	39 c2                	cmp    %eax,%edx
  800c69:	73 db                	jae    800c46 <__udivdi3+0xea>
  800c6b:	90                   	nop
		{
		  q0--;
  800c6c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c6f:	31 f6                	xor    %esi,%esi
  800c71:	e9 56 ff ff ff       	jmp    800bcc <__udivdi3+0x70>
	...

00800c78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	83 ec 20             	sub    $0x20,%esp
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c86:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c95:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c97:	85 ff                	test   %edi,%edi
  800c99:	75 15                	jne    800cb0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c9b:	39 f1                	cmp    %esi,%ecx
  800c9d:	0f 86 99 00 00 00    	jbe    800d3c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ca5:	89 d0                	mov    %edx,%eax
  800ca7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ca9:	83 c4 20             	add    $0x20,%esp
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cb0:	39 f7                	cmp    %esi,%edi
  800cb2:	0f 87 a4 00 00 00    	ja     800d5c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cbb:	83 f0 1f             	xor    $0x1f,%eax
  800cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cc1:	0f 84 a1 00 00 00    	je     800d68 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cc7:	89 f8                	mov    %edi,%eax
  800cc9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ccc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cce:	bf 20 00 00 00       	mov    $0x20,%edi
  800cd3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	d3 ea                	shr    %cl,%edx
  800cdd:	09 c2                	or     %eax,%edx
  800cdf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ce8:	d3 e0                	shl    %cl,%eax
  800cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ced:	89 f2                	mov    %esi,%edx
  800cef:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf4:	d3 e0                	shl    %cl,%eax
  800cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cfc:	89 f9                	mov    %edi,%ecx
  800cfe:	d3 e8                	shr    %cl,%eax
  800d00:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d02:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 75 f0             	divl   -0x10(%ebp)
  800d09:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d0b:	f7 65 f4             	mull   -0xc(%ebp)
  800d0e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d11:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d13:	39 d6                	cmp    %edx,%esi
  800d15:	72 71                	jb     800d88 <__umoddi3+0x110>
  800d17:	74 7f                	je     800d98 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1c:	29 c8                	sub    %ecx,%eax
  800d1e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d20:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 f2                	mov    %esi,%edx
  800d27:	89 f9                	mov    %edi,%ecx
  800d29:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d2b:	09 d0                	or     %edx,%eax
  800d2d:	89 f2                	mov    %esi,%edx
  800d2f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d32:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d34:	83 c4 20             	add    $0x20,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d3c:	85 c9                	test   %ecx,%ecx
  800d3e:	75 0b                	jne    800d4b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d40:	b8 01 00 00 00       	mov    $0x1,%eax
  800d45:	31 d2                	xor    %edx,%edx
  800d47:	f7 f1                	div    %ecx
  800d49:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d4b:	89 f0                	mov    %esi,%eax
  800d4d:	31 d2                	xor    %edx,%edx
  800d4f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d54:	f7 f1                	div    %ecx
  800d56:	e9 4a ff ff ff       	jmp    800ca5 <__umoddi3+0x2d>
  800d5b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d5c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d5e:	83 c4 20             	add    $0x20,%esp
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d68:	39 f7                	cmp    %esi,%edi
  800d6a:	72 05                	jb     800d71 <__umoddi3+0xf9>
  800d6c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d6f:	77 0c                	ja     800d7d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d71:	89 f2                	mov    %esi,%edx
  800d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d76:	29 c8                	sub    %ecx,%eax
  800d78:	19 fa                	sbb    %edi,%edx
  800d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d80:	83 c4 20             	add    $0x20,%esp
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    
  800d87:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d88:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d8b:	89 c1                	mov    %eax,%ecx
  800d8d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d90:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d93:	eb 84                	jmp    800d19 <__umoddi3+0xa1>
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d98:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d9b:	72 eb                	jb     800d88 <__umoddi3+0x110>
  800d9d:	89 f2                	mov    %esi,%edx
  800d9f:	e9 75 ff ff ff       	jmp    800d19 <__umoddi3+0xa1>
