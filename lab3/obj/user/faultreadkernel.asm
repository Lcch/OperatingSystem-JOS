
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
  800040:	68 90 0d 80 00       	push   $0x800d90
  800045:	e8 e2 00 00 00       	call   80012c <cprintf>
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
  800053:	83 ec 08             	sub    $0x8,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	52                   	push   %edx
  800076:	50                   	push   %eax
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 07 00 00 00       	call   800088 <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 08 0a 00 00       	call   800a9d <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 04             	sub    $0x4,%esp
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a6:	8b 03                	mov    (%ebx),%eax
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000af:	40                   	inc    %eax
  8000b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b7:	75 1a                	jne    8000d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	68 ff 00 00 00       	push   $0xff
  8000c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c4:	50                   	push   %eax
  8000c5:	e8 96 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  8000ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000d3:	ff 43 04             	incl   0x4(%ebx)
}
  8000d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000eb:	00 00 00 
	b.cnt = 0;
  8000ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f8:	ff 75 0c             	pushl  0xc(%ebp)
  8000fb:	ff 75 08             	pushl  0x8(%ebp)
  8000fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800104:	50                   	push   %eax
  800105:	68 9c 00 80 00       	push   $0x80009c
  80010a:	e8 82 01 00 00       	call   800291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010f:	83 c4 08             	add    $0x8,%esp
  800112:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800118:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 3c 09 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  800124:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800132:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800135:	50                   	push   %eax
  800136:	ff 75 08             	pushl  0x8(%ebp)
  800139:	e8 9d ff ff ff       	call   8000db <vcprintf>
	va_end(ap);

	return cnt;
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 2c             	sub    $0x2c,%esp
  800149:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	8b 45 08             	mov    0x8(%ebp),%eax
  800151:	8b 55 0c             	mov    0xc(%ebp),%edx
  800154:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800157:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80015a:	8b 45 10             	mov    0x10(%ebp),%eax
  80015d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800160:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800163:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800166:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80016d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800170:	72 0c                	jb     80017e <printnum+0x3e>
  800172:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800175:	76 07                	jbe    80017e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800177:	4b                   	dec    %ebx
  800178:	85 db                	test   %ebx,%ebx
  80017a:	7f 31                	jg     8001ad <printnum+0x6d>
  80017c:	eb 3f                	jmp    8001bd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	57                   	push   %edi
  800182:	4b                   	dec    %ebx
  800183:	53                   	push   %ebx
  800184:	50                   	push   %eax
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	ff 75 d4             	pushl  -0x2c(%ebp)
  80018b:	ff 75 d0             	pushl  -0x30(%ebp)
  80018e:	ff 75 dc             	pushl  -0x24(%ebp)
  800191:	ff 75 d8             	pushl  -0x28(%ebp)
  800194:	e8 af 09 00 00       	call   800b48 <__udivdi3>
  800199:	83 c4 18             	add    $0x18,%esp
  80019c:	52                   	push   %edx
  80019d:	50                   	push   %eax
  80019e:	89 f2                	mov    %esi,%edx
  8001a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001a3:	e8 98 ff ff ff       	call   800140 <printnum>
  8001a8:	83 c4 20             	add    $0x20,%esp
  8001ab:	eb 10                	jmp    8001bd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	56                   	push   %esi
  8001b1:	57                   	push   %edi
  8001b2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b5:	4b                   	dec    %ebx
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	85 db                	test   %ebx,%ebx
  8001bb:	7f f0                	jg     8001ad <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	56                   	push   %esi
  8001c1:	83 ec 04             	sub    $0x4,%esp
  8001c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d0:	e8 8f 0a 00 00       	call   800c64 <__umoddi3>
  8001d5:	83 c4 14             	add    $0x14,%esp
  8001d8:	0f be 80 c1 0d 80 00 	movsbl 0x800dc1(%eax),%eax
  8001df:	50                   	push   %eax
  8001e0:	ff 55 e4             	call   *-0x1c(%ebp)
  8001e3:	83 c4 10             	add    $0x10,%esp
}
  8001e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001f1:	83 fa 01             	cmp    $0x1,%edx
  8001f4:	7e 0e                	jle    800204 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8001f6:	8b 10                	mov    (%eax),%edx
  8001f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8001fb:	89 08                	mov    %ecx,(%eax)
  8001fd:	8b 02                	mov    (%edx),%eax
  8001ff:	8b 52 04             	mov    0x4(%edx),%edx
  800202:	eb 22                	jmp    800226 <getuint+0x38>
	else if (lflag)
  800204:	85 d2                	test   %edx,%edx
  800206:	74 10                	je     800218 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800208:	8b 10                	mov    (%eax),%edx
  80020a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80020d:	89 08                	mov    %ecx,(%eax)
  80020f:	8b 02                	mov    (%edx),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	eb 0e                	jmp    800226 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800218:	8b 10                	mov    (%eax),%edx
  80021a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021d:	89 08                	mov    %ecx,(%eax)
  80021f:	8b 02                	mov    (%edx),%eax
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022b:	83 fa 01             	cmp    $0x1,%edx
  80022e:	7e 0e                	jle    80023e <getint+0x16>
		return va_arg(*ap, long long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 08             	lea    0x8(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	8b 52 04             	mov    0x4(%edx),%edx
  80023c:	eb 1a                	jmp    800258 <getint+0x30>
	else if (lflag)
  80023e:	85 d2                	test   %edx,%edx
  800240:	74 0c                	je     80024e <getint+0x26>
		return va_arg(*ap, long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 04             	lea    0x4(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	99                   	cltd   
  80024c:	eb 0a                	jmp    800258 <getint+0x30>
	else
		return va_arg(*ap, int);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 04             	lea    0x4(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	99                   	cltd   
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800260:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800263:	8b 10                	mov    (%eax),%edx
  800265:	3b 50 04             	cmp    0x4(%eax),%edx
  800268:	73 08                	jae    800272 <sprintputch+0x18>
		*b->buf++ = ch;
  80026a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026d:	88 0a                	mov    %cl,(%edx)
  80026f:	42                   	inc    %edx
  800270:	89 10                	mov    %edx,(%eax)
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 05 00 00 00       	call   800291 <vprintfmt>
	va_end(ap);
  80028c:	83 c4 10             	add    $0x10,%esp
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80029d:	8b 75 10             	mov    0x10(%ebp),%esi
  8002a0:	eb 13                	jmp    8002b5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	0f 84 6d 03 00 00    	je     800617 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	57                   	push   %edi
  8002ae:	50                   	push   %eax
  8002af:	ff 55 08             	call   *0x8(%ebp)
  8002b2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b5:	0f b6 06             	movzbl (%esi),%eax
  8002b8:	46                   	inc    %esi
  8002b9:	83 f8 25             	cmp    $0x25,%eax
  8002bc:	75 e4                	jne    8002a2 <vprintfmt+0x11>
  8002be:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002c9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002d0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002dc:	eb 28                	jmp    800306 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8002e4:	eb 20                	jmp    800306 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8002ec:	eb 18                	jmp    800306 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8002f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002f7:	eb 0d                	jmp    800306 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8002f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ff:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8a 06                	mov    (%esi),%al
  800308:	0f b6 d0             	movzbl %al,%edx
  80030b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80030e:	83 e8 23             	sub    $0x23,%eax
  800311:	3c 55                	cmp    $0x55,%al
  800313:	0f 87 e0 02 00 00    	ja     8005f9 <vprintfmt+0x368>
  800319:	0f b6 c0             	movzbl %al,%eax
  80031c:	ff 24 85 50 0e 80 00 	jmp    *0x800e50(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800323:	83 ea 30             	sub    $0x30,%edx
  800326:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800329:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80032c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80032f:	83 fa 09             	cmp    $0x9,%edx
  800332:	77 44                	ja     800378 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	89 de                	mov    %ebx,%esi
  800336:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800339:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80033a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80033d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800341:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800344:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800347:	83 fb 09             	cmp    $0x9,%ebx
  80034a:	76 ed                	jbe    800339 <vprintfmt+0xa8>
  80034c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80034f:	eb 29                	jmp    80037a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 50 04             	lea    0x4(%eax),%edx
  800357:	89 55 14             	mov    %edx,0x14(%ebp)
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800361:	eb 17                	jmp    80037a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800363:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800367:	78 85                	js     8002ee <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	89 de                	mov    %ebx,%esi
  80036b:	eb 99                	jmp    800306 <vprintfmt+0x75>
  80036d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800376:	eb 8e                	jmp    800306 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80037a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80037e:	79 86                	jns    800306 <vprintfmt+0x75>
  800380:	e9 74 ff ff ff       	jmp    8002f9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800385:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	89 de                	mov    %ebx,%esi
  800388:	e9 79 ff ff ff       	jmp    800306 <vprintfmt+0x75>
  80038d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	57                   	push   %edi
  80039d:	ff 30                	pushl  (%eax)
  80039f:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a8:	e9 08 ff ff ff       	jmp    8002b5 <vprintfmt+0x24>
  8003ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	79 02                	jns    8003c1 <vprintfmt+0x130>
  8003bf:	f7 d8                	neg    %eax
  8003c1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c3:	83 f8 06             	cmp    $0x6,%eax
  8003c6:	7f 0b                	jg     8003d3 <vprintfmt+0x142>
  8003c8:	8b 04 85 a8 0f 80 00 	mov    0x800fa8(,%eax,4),%eax
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	75 1a                	jne    8003ed <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003d3:	52                   	push   %edx
  8003d4:	68 d9 0d 80 00       	push   $0x800dd9
  8003d9:	57                   	push   %edi
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	e8 92 fe ff ff       	call   800274 <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e8:	e9 c8 fe ff ff       	jmp    8002b5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8003ed:	50                   	push   %eax
  8003ee:	68 e2 0d 80 00       	push   $0x800de2
  8003f3:	57                   	push   %edi
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 78 fe ff ff       	call   800274 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800402:	e9 ae fe ff ff       	jmp    8002b5 <vprintfmt+0x24>
  800407:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80040a:	89 de                	mov    %ebx,%esi
  80040c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80040f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800420:	85 c0                	test   %eax,%eax
  800422:	75 07                	jne    80042b <vprintfmt+0x19a>
				p = "(null)";
  800424:	c7 45 d0 d2 0d 80 00 	movl   $0x800dd2,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	7e 42                	jle    800471 <vprintfmt+0x1e0>
  80042f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800433:	74 3c                	je     800471 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	51                   	push   %ecx
  800439:	ff 75 d0             	pushl  -0x30(%ebp)
  80043c:	e8 6f 02 00 00       	call   8006b0 <strnlen>
  800441:	29 c3                	sub    %eax,%ebx
  800443:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 db                	test   %ebx,%ebx
  80044b:	7e 24                	jle    800471 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80044d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800451:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800454:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	57                   	push   %edi
  80045b:	53                   	push   %ebx
  80045c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	4e                   	dec    %esi
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	85 f6                	test   %esi,%esi
  800465:	7f f0                	jg     800457 <vprintfmt+0x1c6>
  800467:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80046a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800471:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800474:	0f be 02             	movsbl (%edx),%eax
  800477:	85 c0                	test   %eax,%eax
  800479:	75 47                	jne    8004c2 <vprintfmt+0x231>
  80047b:	eb 37                	jmp    8004b4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80047d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800481:	74 16                	je     800499 <vprintfmt+0x208>
  800483:	8d 50 e0             	lea    -0x20(%eax),%edx
  800486:	83 fa 5e             	cmp    $0x5e,%edx
  800489:	76 0e                	jbe    800499 <vprintfmt+0x208>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	57                   	push   %edi
  80048f:	6a 3f                	push   $0x3f
  800491:	ff 55 08             	call   *0x8(%ebp)
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	eb 0b                	jmp    8004a4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	57                   	push   %edi
  80049d:	50                   	push   %eax
  80049e:	ff 55 08             	call   *0x8(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004a7:	0f be 03             	movsbl (%ebx),%eax
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	74 03                	je     8004b1 <vprintfmt+0x220>
  8004ae:	43                   	inc    %ebx
  8004af:	eb 1b                	jmp    8004cc <vprintfmt+0x23b>
  8004b1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b8:	7f 1e                	jg     8004d8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004bd:	e9 f3 fd ff ff       	jmp    8002b5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004c5:	43                   	inc    %ebx
  8004c6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004cc:	85 f6                	test   %esi,%esi
  8004ce:	78 ad                	js     80047d <vprintfmt+0x1ec>
  8004d0:	4e                   	dec    %esi
  8004d1:	79 aa                	jns    80047d <vprintfmt+0x1ec>
  8004d3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004d6:	eb dc                	jmp    8004b4 <vprintfmt+0x223>
  8004d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	57                   	push   %edi
  8004df:	6a 20                	push   $0x20
  8004e1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	4b                   	dec    %ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f ef                	jg     8004db <vprintfmt+0x24a>
  8004ec:	e9 c4 fd ff ff       	jmp    8002b5 <vprintfmt+0x24>
  8004f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004f4:	89 ca                	mov    %ecx,%edx
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f9:	e8 2a fd ff ff       	call   800228 <getint>
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800502:	85 d2                	test   %edx,%edx
  800504:	78 0a                	js     800510 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800506:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050b:	e9 b0 00 00 00       	jmp    8005c0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	57                   	push   %edi
  800514:	6a 2d                	push   $0x2d
  800516:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800519:	f7 db                	neg    %ebx
  80051b:	83 d6 00             	adc    $0x0,%esi
  80051e:	f7 de                	neg    %esi
  800520:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800523:	b8 0a 00 00 00       	mov    $0xa,%eax
  800528:	e9 93 00 00 00       	jmp    8005c0 <vprintfmt+0x32f>
  80052d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800530:	89 ca                	mov    %ecx,%edx
  800532:	8d 45 14             	lea    0x14(%ebp),%eax
  800535:	e8 b4 fc ff ff       	call   8001ee <getuint>
  80053a:	89 c3                	mov    %eax,%ebx
  80053c:	89 d6                	mov    %edx,%esi
			base = 10;
  80053e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800543:	eb 7b                	jmp    8005c0 <vprintfmt+0x32f>
  800545:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800548:	89 ca                	mov    %ecx,%edx
  80054a:	8d 45 14             	lea    0x14(%ebp),%eax
  80054d:	e8 d6 fc ff ff       	call   800228 <getint>
  800552:	89 c3                	mov    %eax,%ebx
  800554:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800556:	85 d2                	test   %edx,%edx
  800558:	78 07                	js     800561 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80055a:	b8 08 00 00 00       	mov    $0x8,%eax
  80055f:	eb 5f                	jmp    8005c0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	57                   	push   %edi
  800565:	6a 2d                	push   $0x2d
  800567:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80056a:	f7 db                	neg    %ebx
  80056c:	83 d6 00             	adc    $0x0,%esi
  80056f:	f7 de                	neg    %esi
  800571:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800574:	b8 08 00 00 00       	mov    $0x8,%eax
  800579:	eb 45                	jmp    8005c0 <vprintfmt+0x32f>
  80057b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	57                   	push   %edi
  800582:	6a 30                	push   $0x30
  800584:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800587:	83 c4 08             	add    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 78                	push   $0x78
  80058d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800599:	8b 18                	mov    (%eax),%ebx
  80059b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005a3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005a8:	eb 16                	jmp    8005c0 <vprintfmt+0x32f>
  8005aa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ad:	89 ca                	mov    %ecx,%edx
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	e8 37 fc ff ff       	call   8001ee <getuint>
  8005b7:	89 c3                	mov    %eax,%ebx
  8005b9:	89 d6                	mov    %edx,%esi
			base = 16;
  8005bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005c0:	83 ec 0c             	sub    $0xc,%esp
  8005c3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005c7:	52                   	push   %edx
  8005c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cb:	50                   	push   %eax
  8005cc:	56                   	push   %esi
  8005cd:	53                   	push   %ebx
  8005ce:	89 fa                	mov    %edi,%edx
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	e8 68 fb ff ff       	call   800140 <printnum>
			break;
  8005d8:	83 c4 20             	add    $0x20,%esp
  8005db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005de:	e9 d2 fc ff ff       	jmp    8002b5 <vprintfmt+0x24>
  8005e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	57                   	push   %edi
  8005ea:	52                   	push   %edx
  8005eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005f4:	e9 bc fc ff ff       	jmp    8002b5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	57                   	push   %edi
  8005fd:	6a 25                	push   $0x25
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb 02                	jmp    800609 <vprintfmt+0x378>
  800607:	89 c6                	mov    %eax,%esi
  800609:	8d 46 ff             	lea    -0x1(%esi),%eax
  80060c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800610:	75 f5                	jne    800607 <vprintfmt+0x376>
  800612:	e9 9e fc ff ff       	jmp    8002b5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	83 ec 18             	sub    $0x18,%esp
  800625:	8b 45 08             	mov    0x8(%ebp),%eax
  800628:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80062e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800632:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80063c:	85 c0                	test   %eax,%eax
  80063e:	74 26                	je     800666 <vsnprintf+0x47>
  800640:	85 d2                	test   %edx,%edx
  800642:	7e 29                	jle    80066d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800644:	ff 75 14             	pushl  0x14(%ebp)
  800647:	ff 75 10             	pushl  0x10(%ebp)
  80064a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80064d:	50                   	push   %eax
  80064e:	68 5a 02 80 00       	push   $0x80025a
  800653:	e8 39 fc ff ff       	call   800291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80065e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb 0c                	jmp    800672 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80066b:	eb 05                	jmp    800672 <vsnprintf+0x53>
  80066d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067d:	50                   	push   %eax
  80067e:	ff 75 10             	pushl  0x10(%ebp)
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	ff 75 08             	pushl  0x8(%ebp)
  800687:	e8 93 ff ff ff       	call   80061f <vsnprintf>
	va_end(ap);

	return rc;
}
  80068c:	c9                   	leave  
  80068d:	c3                   	ret    
	...

00800690 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800696:	80 3a 00             	cmpb   $0x0,(%edx)
  800699:	74 0e                	je     8006a9 <strlen+0x19>
  80069b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006a0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a5:	75 f9                	jne    8006a0 <strlen+0x10>
  8006a7:	eb 05                	jmp    8006ae <strlen+0x1e>
  8006a9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	74 17                	je     8006d4 <strnlen+0x24>
  8006bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006c0:	74 19                	je     8006db <strnlen+0x2b>
  8006c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006c7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c8:	39 d0                	cmp    %edx,%eax
  8006ca:	74 14                	je     8006e0 <strnlen+0x30>
  8006cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006d0:	75 f5                	jne    8006c7 <strnlen+0x17>
  8006d2:	eb 0c                	jmp    8006e0 <strnlen+0x30>
  8006d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d9:	eb 05                	jmp    8006e0 <strnlen+0x30>
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8006f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8006f7:	42                   	inc    %edx
  8006f8:	84 c9                	test   %cl,%cl
  8006fa:	75 f5                	jne    8006f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006fc:	5b                   	pop    %ebx
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	53                   	push   %ebx
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800706:	53                   	push   %ebx
  800707:	e8 84 ff ff ff       	call   800690 <strlen>
  80070c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800715:	50                   	push   %eax
  800716:	e8 c7 ff ff ff       	call   8006e2 <strcpy>
	return dst;
}
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800730:	85 f6                	test   %esi,%esi
  800732:	74 15                	je     800749 <strncpy+0x27>
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800739:	8a 1a                	mov    (%edx),%bl
  80073b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80073e:	80 3a 01             	cmpb   $0x1,(%edx)
  800741:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800744:	41                   	inc    %ecx
  800745:	39 ce                	cmp    %ecx,%esi
  800747:	77 f0                	ja     800739 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    

0080074d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	57                   	push   %edi
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	8b 7d 08             	mov    0x8(%ebp),%edi
  800756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800759:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80075c:	85 f6                	test   %esi,%esi
  80075e:	74 32                	je     800792 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800760:	83 fe 01             	cmp    $0x1,%esi
  800763:	74 22                	je     800787 <strlcpy+0x3a>
  800765:	8a 0b                	mov    (%ebx),%cl
  800767:	84 c9                	test   %cl,%cl
  800769:	74 20                	je     80078b <strlcpy+0x3e>
  80076b:	89 f8                	mov    %edi,%eax
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800772:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800775:	88 08                	mov    %cl,(%eax)
  800777:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800778:	39 f2                	cmp    %esi,%edx
  80077a:	74 11                	je     80078d <strlcpy+0x40>
  80077c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800780:	42                   	inc    %edx
  800781:	84 c9                	test   %cl,%cl
  800783:	75 f0                	jne    800775 <strlcpy+0x28>
  800785:	eb 06                	jmp    80078d <strlcpy+0x40>
  800787:	89 f8                	mov    %edi,%eax
  800789:	eb 02                	jmp    80078d <strlcpy+0x40>
  80078b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80078d:	c6 00 00             	movb   $0x0,(%eax)
  800790:	eb 02                	jmp    800794 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800792:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800794:	29 f8                	sub    %edi,%eax
}
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5f                   	pop    %edi
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a4:	8a 01                	mov    (%ecx),%al
  8007a6:	84 c0                	test   %al,%al
  8007a8:	74 10                	je     8007ba <strcmp+0x1f>
  8007aa:	3a 02                	cmp    (%edx),%al
  8007ac:	75 0c                	jne    8007ba <strcmp+0x1f>
		p++, q++;
  8007ae:	41                   	inc    %ecx
  8007af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b0:	8a 01                	mov    (%ecx),%al
  8007b2:	84 c0                	test   %al,%al
  8007b4:	74 04                	je     8007ba <strcmp+0x1f>
  8007b6:	3a 02                	cmp    (%edx),%al
  8007b8:	74 f4                	je     8007ae <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ba:	0f b6 c0             	movzbl %al,%eax
  8007bd:	0f b6 12             	movzbl (%edx),%edx
  8007c0:	29 d0                	sub    %edx,%eax
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 1b                	je     8007f0 <strncmp+0x2c>
  8007d5:	8a 1a                	mov    (%edx),%bl
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	74 24                	je     8007ff <strncmp+0x3b>
  8007db:	3a 19                	cmp    (%ecx),%bl
  8007dd:	75 20                	jne    8007ff <strncmp+0x3b>
  8007df:	48                   	dec    %eax
  8007e0:	74 15                	je     8007f7 <strncmp+0x33>
		n--, p++, q++;
  8007e2:	42                   	inc    %edx
  8007e3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e4:	8a 1a                	mov    (%edx),%bl
  8007e6:	84 db                	test   %bl,%bl
  8007e8:	74 15                	je     8007ff <strncmp+0x3b>
  8007ea:	3a 19                	cmp    (%ecx),%bl
  8007ec:	74 f1                	je     8007df <strncmp+0x1b>
  8007ee:	eb 0f                	jmp    8007ff <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	eb 05                	jmp    8007fc <strncmp+0x38>
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 02             	movzbl (%edx),%eax
  800802:	0f b6 11             	movzbl (%ecx),%edx
  800805:	29 d0                	sub    %edx,%eax
  800807:	eb f3                	jmp    8007fc <strncmp+0x38>

00800809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800812:	8a 10                	mov    (%eax),%dl
  800814:	84 d2                	test   %dl,%dl
  800816:	74 18                	je     800830 <strchr+0x27>
		if (*s == c)
  800818:	38 ca                	cmp    %cl,%dl
  80081a:	75 06                	jne    800822 <strchr+0x19>
  80081c:	eb 17                	jmp    800835 <strchr+0x2c>
  80081e:	38 ca                	cmp    %cl,%dl
  800820:	74 13                	je     800835 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800822:	40                   	inc    %eax
  800823:	8a 10                	mov    (%eax),%dl
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f5                	jne    80081e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
  80082e:	eb 05                	jmp    800835 <strchr+0x2c>
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800840:	8a 10                	mov    (%eax),%dl
  800842:	84 d2                	test   %dl,%dl
  800844:	74 11                	je     800857 <strfind+0x20>
		if (*s == c)
  800846:	38 ca                	cmp    %cl,%dl
  800848:	75 06                	jne    800850 <strfind+0x19>
  80084a:	eb 0b                	jmp    800857 <strfind+0x20>
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 07                	je     800857 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800850:	40                   	inc    %eax
  800851:	8a 10                	mov    (%eax),%dl
  800853:	84 d2                	test   %dl,%dl
  800855:	75 f5                	jne    80084c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	57                   	push   %edi
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800862:	8b 45 0c             	mov    0xc(%ebp),%eax
  800865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800868:	85 c9                	test   %ecx,%ecx
  80086a:	74 30                	je     80089c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800872:	75 25                	jne    800899 <memset+0x40>
  800874:	f6 c1 03             	test   $0x3,%cl
  800877:	75 20                	jne    800899 <memset+0x40>
		c &= 0xFF;
  800879:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087c:	89 d3                	mov    %edx,%ebx
  80087e:	c1 e3 08             	shl    $0x8,%ebx
  800881:	89 d6                	mov    %edx,%esi
  800883:	c1 e6 18             	shl    $0x18,%esi
  800886:	89 d0                	mov    %edx,%eax
  800888:	c1 e0 10             	shl    $0x10,%eax
  80088b:	09 f0                	or     %esi,%eax
  80088d:	09 d0                	or     %edx,%eax
  80088f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800891:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800894:	fc                   	cld    
  800895:	f3 ab                	rep stos %eax,%es:(%edi)
  800897:	eb 03                	jmp    80089c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800899:	fc                   	cld    
  80089a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b1:	39 c6                	cmp    %eax,%esi
  8008b3:	73 34                	jae    8008e9 <memmove+0x46>
  8008b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	73 2d                	jae    8008e9 <memmove+0x46>
		s += n;
		d += n;
  8008bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bf:	f6 c2 03             	test   $0x3,%dl
  8008c2:	75 1b                	jne    8008df <memmove+0x3c>
  8008c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ca:	75 13                	jne    8008df <memmove+0x3c>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0e                	jne    8008df <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb 07                	jmp    8008e6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008df:	4f                   	dec    %edi
  8008e0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e3:	fd                   	std    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e6:	fc                   	cld    
  8008e7:	eb 20                	jmp    800909 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ef:	75 13                	jne    800904 <memmove+0x61>
  8008f1:	a8 03                	test   $0x3,%al
  8008f3:	75 0f                	jne    800904 <memmove+0x61>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 0a                	jne    800904 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fd:	89 c7                	mov    %eax,%edi
  8008ff:	fc                   	cld    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 05                	jmp    800909 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800910:	ff 75 10             	pushl  0x10(%ebp)
  800913:	ff 75 0c             	pushl  0xc(%ebp)
  800916:	ff 75 08             	pushl  0x8(%ebp)
  800919:	e8 85 ff ff ff       	call   8008a3 <memmove>
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800929:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	85 ff                	test   %edi,%edi
  800931:	74 32                	je     800965 <memcmp+0x45>
		if (*s1 != *s2)
  800933:	8a 03                	mov    (%ebx),%al
  800935:	8a 0e                	mov    (%esi),%cl
  800937:	38 c8                	cmp    %cl,%al
  800939:	74 19                	je     800954 <memcmp+0x34>
  80093b:	eb 0d                	jmp    80094a <memcmp+0x2a>
  80093d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800941:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800945:	42                   	inc    %edx
  800946:	38 c8                	cmp    %cl,%al
  800948:	74 10                	je     80095a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80094a:	0f b6 c0             	movzbl %al,%eax
  80094d:	0f b6 c9             	movzbl %cl,%ecx
  800950:	29 c8                	sub    %ecx,%eax
  800952:	eb 16                	jmp    80096a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	4f                   	dec    %edi
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	39 fa                	cmp    %edi,%edx
  80095c:	75 df                	jne    80093d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb 05                	jmp    80096a <memcmp+0x4a>
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800975:	89 c2                	mov    %eax,%edx
  800977:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 12                	jae    800990 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800981:	38 08                	cmp    %cl,(%eax)
  800983:	75 06                	jne    80098b <memfind+0x1c>
  800985:	eb 09                	jmp    800990 <memfind+0x21>
  800987:	38 08                	cmp    %cl,(%eax)
  800989:	74 05                	je     800990 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098b:	40                   	inc    %eax
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	77 f7                	ja     800987 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
  80099b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099e:	eb 01                	jmp    8009a1 <strtol+0xf>
		s++;
  8009a0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	8a 02                	mov    (%edx),%al
  8009a3:	3c 20                	cmp    $0x20,%al
  8009a5:	74 f9                	je     8009a0 <strtol+0xe>
  8009a7:	3c 09                	cmp    $0x9,%al
  8009a9:	74 f5                	je     8009a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ab:	3c 2b                	cmp    $0x2b,%al
  8009ad:	75 08                	jne    8009b7 <strtol+0x25>
		s++;
  8009af:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b5:	eb 13                	jmp    8009ca <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b7:	3c 2d                	cmp    $0x2d,%al
  8009b9:	75 0a                	jne    8009c5 <strtol+0x33>
		s++, neg = 1;
  8009bb:	8d 52 01             	lea    0x1(%edx),%edx
  8009be:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c3:	eb 05                	jmp    8009ca <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ca:	85 db                	test   %ebx,%ebx
  8009cc:	74 05                	je     8009d3 <strtol+0x41>
  8009ce:	83 fb 10             	cmp    $0x10,%ebx
  8009d1:	75 28                	jne    8009fb <strtol+0x69>
  8009d3:	8a 02                	mov    (%edx),%al
  8009d5:	3c 30                	cmp    $0x30,%al
  8009d7:	75 10                	jne    8009e9 <strtol+0x57>
  8009d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009dd:	75 0a                	jne    8009e9 <strtol+0x57>
		s += 2, base = 16;
  8009df:	83 c2 02             	add    $0x2,%edx
  8009e2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e7:	eb 12                	jmp    8009fb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	75 0e                	jne    8009fb <strtol+0x69>
  8009ed:	3c 30                	cmp    $0x30,%al
  8009ef:	75 05                	jne    8009f6 <strtol+0x64>
		s++, base = 8;
  8009f1:	42                   	inc    %edx
  8009f2:	b3 08                	mov    $0x8,%bl
  8009f4:	eb 05                	jmp    8009fb <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a02:	8a 0a                	mov    (%edx),%cl
  800a04:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a07:	80 fb 09             	cmp    $0x9,%bl
  800a0a:	77 08                	ja     800a14 <strtol+0x82>
			dig = *s - '0';
  800a0c:	0f be c9             	movsbl %cl,%ecx
  800a0f:	83 e9 30             	sub    $0x30,%ecx
  800a12:	eb 1e                	jmp    800a32 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a14:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a17:	80 fb 19             	cmp    $0x19,%bl
  800a1a:	77 08                	ja     800a24 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a1c:	0f be c9             	movsbl %cl,%ecx
  800a1f:	83 e9 57             	sub    $0x57,%ecx
  800a22:	eb 0e                	jmp    800a32 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a24:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 13                	ja     800a3f <strtol+0xad>
			dig = *s - 'A' + 10;
  800a2c:	0f be c9             	movsbl %cl,%ecx
  800a2f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a32:	39 f1                	cmp    %esi,%ecx
  800a34:	7d 0d                	jge    800a43 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a36:	42                   	inc    %edx
  800a37:	0f af c6             	imul   %esi,%eax
  800a3a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a3d:	eb c3                	jmp    800a02 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	eb 02                	jmp    800a45 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a43:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a49:	74 05                	je     800a50 <strtol+0xbe>
		*endptr = (char *) s;
  800a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a50:	85 ff                	test   %edi,%edi
  800a52:	74 04                	je     800a58 <strtol+0xc6>
  800a54:	89 c8                	mov    %ecx,%eax
  800a56:	f7 d8                	neg    %eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    
  800a5d:	00 00                	add    %al,(%eax)
	...

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 c4 0f 80 00       	push   $0x800fc4
  800aca:	6a 23                	push   $0x23
  800acc:	68 e1 0f 80 00       	push   $0x800fe1
  800ad1:	e8 2a 00 00 00       	call   800b00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    
  800afd:	00 00                	add    %al,(%eax)
	...

00800b00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b05:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b08:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b0e:	e8 cb ff ff ff       	call   800ade <sys_getenvid>
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	ff 75 08             	pushl  0x8(%ebp)
  800b1c:	53                   	push   %ebx
  800b1d:	50                   	push   %eax
  800b1e:	68 f0 0f 80 00       	push   $0x800ff0
  800b23:	e8 04 f6 ff ff       	call   80012c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b28:	83 c4 18             	add    $0x18,%esp
  800b2b:	56                   	push   %esi
  800b2c:	ff 75 10             	pushl  0x10(%ebp)
  800b2f:	e8 a7 f5 ff ff       	call   8000db <vcprintf>
	cprintf("\n");
  800b34:	c7 04 24 14 10 80 00 	movl   $0x801014,(%esp)
  800b3b:	e8 ec f5 ff ff       	call   80012c <cprintf>
  800b40:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b43:	cc                   	int3   
  800b44:	eb fd                	jmp    800b43 <_panic+0x43>
	...

00800b48 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	83 ec 10             	sub    $0x10,%esp
  800b50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b56:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	75 2e                	jne    800b94 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b66:	39 f1                	cmp    %esi,%ecx
  800b68:	77 5a                	ja     800bc4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b6a:	85 c9                	test   %ecx,%ecx
  800b6c:	75 0b                	jne    800b79 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b73:	31 d2                	xor    %edx,%edx
  800b75:	f7 f1                	div    %ecx
  800b77:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b79:	31 d2                	xor    %edx,%edx
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	f7 f1                	div    %ecx
  800b7f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	f7 f1                	div    %ecx
  800b85:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b87:	89 f8                	mov    %edi,%eax
  800b89:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    
  800b92:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b94:	39 f0                	cmp    %esi,%eax
  800b96:	77 1c                	ja     800bb4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b98:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b9b:	83 f7 1f             	xor    $0x1f,%edi
  800b9e:	75 3c                	jne    800bdc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ba0:	39 f0                	cmp    %esi,%eax
  800ba2:	0f 82 90 00 00 00    	jb     800c38 <__udivdi3+0xf0>
  800ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bab:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bae:	0f 86 84 00 00 00    	jbe    800c38 <__udivdi3+0xf0>
  800bb4:	31 f6                	xor    %esi,%esi
  800bb6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb8:	89 f8                	mov    %edi,%eax
  800bba:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    
  800bc3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc4:	89 f2                	mov    %esi,%edx
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	f7 f1                	div    %ecx
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bce:	89 f8                	mov    %edi,%eax
  800bd0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    
  800bd9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bdc:	89 f9                	mov    %edi,%ecx
  800bde:	d3 e0                	shl    %cl,%eax
  800be0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800be3:	b8 20 00 00 00       	mov    $0x20,%eax
  800be8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bf4:	09 ca                	or     %ecx,%edx
  800bf6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfc:	89 f9                	mov    %edi,%ecx
  800bfe:	d3 e2                	shl    %cl,%edx
  800c00:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c03:	89 f2                	mov    %esi,%edx
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ea                	shr    %cl,%edx
  800c09:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	89 f9                	mov    %edi,%ecx
  800c10:	d3 e2                	shl    %cl,%edx
  800c12:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ee                	shr    %cl,%esi
  800c19:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c1b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c1e:	89 f0                	mov    %esi,%eax
  800c20:	89 ca                	mov    %ecx,%edx
  800c22:	f7 75 ec             	divl   -0x14(%ebp)
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c29:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c2c:	39 d1                	cmp    %edx,%ecx
  800c2e:	72 28                	jb     800c58 <__udivdi3+0x110>
  800c30:	74 1a                	je     800c4c <__udivdi3+0x104>
  800c32:	89 f7                	mov    %esi,%edi
  800c34:	31 f6                	xor    %esi,%esi
  800c36:	eb 80                	jmp    800bb8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c38:	31 f6                	xor    %esi,%esi
  800c3a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c3f:	89 f8                	mov    %edi,%eax
  800c41:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    
  800c4a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c4f:	89 f9                	mov    %edi,%ecx
  800c51:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c53:	39 c2                	cmp    %eax,%edx
  800c55:	73 db                	jae    800c32 <__udivdi3+0xea>
  800c57:	90                   	nop
		{
		  q0--;
  800c58:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c5b:	31 f6                	xor    %esi,%esi
  800c5d:	e9 56 ff ff ff       	jmp    800bb8 <__udivdi3+0x70>
	...

00800c64 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	83 ec 20             	sub    $0x20,%esp
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c81:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c83:	85 ff                	test   %edi,%edi
  800c85:	75 15                	jne    800c9c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c87:	39 f1                	cmp    %esi,%ecx
  800c89:	0f 86 99 00 00 00    	jbe    800d28 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c8f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c91:	89 d0                	mov    %edx,%eax
  800c93:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c95:	83 c4 20             	add    $0x20,%esp
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c9c:	39 f7                	cmp    %esi,%edi
  800c9e:	0f 87 a4 00 00 00    	ja     800d48 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ca4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ca7:	83 f0 1f             	xor    $0x1f,%eax
  800caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cad:	0f 84 a1 00 00 00    	je     800d54 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cb3:	89 f8                	mov    %edi,%eax
  800cb5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cb8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cba:	bf 20 00 00 00       	mov    $0x20,%edi
  800cbf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc5:	89 f9                	mov    %edi,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	09 c2                	or     %eax,%edx
  800ccb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cd4:	d3 e0                	shl    %cl,%eax
  800cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd9:	89 f2                	mov    %esi,%edx
  800cdb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce0:	d3 e0                	shl    %cl,%eax
  800ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce8:	89 f9                	mov    %edi,%ecx
  800cea:	d3 e8                	shr    %cl,%eax
  800cec:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cee:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	f7 75 f0             	divl   -0x10(%ebp)
  800cf5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cf7:	f7 65 f4             	mull   -0xc(%ebp)
  800cfa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800cfd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cff:	39 d6                	cmp    %edx,%esi
  800d01:	72 71                	jb     800d74 <__umoddi3+0x110>
  800d03:	74 7f                	je     800d84 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d08:	29 c8                	sub    %ecx,%eax
  800d0a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d0c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d0f:	d3 e8                	shr    %cl,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	89 f9                	mov    %edi,%ecx
  800d15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d17:	09 d0                	or     %edx,%eax
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d20:	83 c4 20             	add    $0x20,%esp
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
  800d27:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d28:	85 c9                	test   %ecx,%ecx
  800d2a:	75 0b                	jne    800d37 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
  800d35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	31 d2                	xor    %edx,%edx
  800d3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d40:	f7 f1                	div    %ecx
  800d42:	e9 4a ff ff ff       	jmp    800c91 <__umoddi3+0x2d>
  800d47:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d48:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d4a:	83 c4 20             	add    $0x20,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d54:	39 f7                	cmp    %esi,%edi
  800d56:	72 05                	jb     800d5d <__umoddi3+0xf9>
  800d58:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d5b:	77 0c                	ja     800d69 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d62:	29 c8                	sub    %ecx,%eax
  800d64:	19 fa                	sbb    %edi,%edx
  800d66:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d6c:	83 c4 20             	add    $0x20,%esp
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    
  800d73:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d74:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d77:	89 c1                	mov    %eax,%ecx
  800d79:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d7c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d7f:	eb 84                	jmp    800d05 <__umoddi3+0xa1>
  800d81:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d84:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d87:	72 eb                	jb     800d74 <__umoddi3+0x110>
  800d89:	89 f2                	mov    %esi,%edx
  800d8b:	e9 75 ff ff ff       	jmp    800d05 <__umoddi3+0xa1>
