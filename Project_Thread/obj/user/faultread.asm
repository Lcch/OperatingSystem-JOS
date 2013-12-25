
obj/user/faultread.debug:     file format elf32-i386


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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	ff 35 00 00 00 00    	pushl  0x0
  800040:	68 e0 1d 80 00       	push   $0x801de0
  800045:	e8 fe 00 00 00       	call   800148 <cprintf>
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
  80005b:	e8 d5 0a 00 00       	call   800b35 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 07             	shl    $0x7,%edx
  80006a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 f6                	test   %esi,%esi
  800078:	7e 07                	jle    800081 <libmain+0x31>
		binaryname = argv[0];
  80007a:	8b 03                	mov    (%ebx),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	53                   	push   %ebx
  800085:	56                   	push   %esi
  800086:	e8 a9 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0c 00 00 00       	call   80009c <exit>
  800090:	83 c4 10             	add    $0x10,%esp
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
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
  80009f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a2:	e8 8f 0e 00 00       	call   800f36 <close_all>
	sys_env_destroy(0);
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 62 0a 00 00       	call   800b13 <sys_env_destroy>
  8000b1:	83 c4 10             	add    $0x10,%esp
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	40                   	inc    %eax
  8000cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 e3 09 00 00       	call   800ac9 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	ff 43 04             	incl   0x4(%ebx)
}
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800100:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800107:	00 00 00 
	b.cnt = 0;
  80010a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800114:	ff 75 0c             	pushl  0xc(%ebp)
  800117:	ff 75 08             	pushl  0x8(%ebp)
  80011a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800120:	50                   	push   %eax
  800121:	68 b8 00 80 00       	push   $0x8000b8
  800126:	e8 82 01 00 00       	call   8002ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800134:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013a:	50                   	push   %eax
  80013b:	e8 89 09 00 00       	call   800ac9 <sys_cputs>

	return b.cnt;
}
  800140:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800151:	50                   	push   %eax
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	e8 9d ff ff ff       	call   8000f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 2c             	sub    $0x2c,%esp
  800165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800173:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800176:	8b 45 10             	mov    0x10(%ebp),%eax
  800179:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80017c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800182:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800189:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80018c:	72 0c                	jb     80019a <printnum+0x3e>
  80018e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800191:	76 07                	jbe    80019a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800193:	4b                   	dec    %ebx
  800194:	85 db                	test   %ebx,%ebx
  800196:	7f 31                	jg     8001c9 <printnum+0x6d>
  800198:	eb 3f                	jmp    8001d9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	57                   	push   %edi
  80019e:	4b                   	dec    %ebx
  80019f:	53                   	push   %ebx
  8001a0:	50                   	push   %eax
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b0:	e8 cf 19 00 00       	call   801b84 <__udivdi3>
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	52                   	push   %edx
  8001b9:	50                   	push   %eax
  8001ba:	89 f2                	mov    %esi,%edx
  8001bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001bf:	e8 98 ff ff ff       	call   80015c <printnum>
  8001c4:	83 c4 20             	add    $0x20,%esp
  8001c7:	eb 10                	jmp    8001d9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	57                   	push   %edi
  8001ce:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d1:	4b                   	dec    %ebx
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f f0                	jg     8001c9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 af 1a 00 00       	call   801ca0 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 08 1e 80 00 	movsbl 0x801e08(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff 55 e4             	call   *-0x1c(%ebp)
  8001ff:	83 c4 10             	add    $0x10,%esp
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020d:	83 fa 01             	cmp    $0x1,%edx
  800210:	7e 0e                	jle    800220 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800212:	8b 10                	mov    (%eax),%edx
  800214:	8d 4a 08             	lea    0x8(%edx),%ecx
  800217:	89 08                	mov    %ecx,(%eax)
  800219:	8b 02                	mov    (%edx),%eax
  80021b:	8b 52 04             	mov    0x4(%edx),%edx
  80021e:	eb 22                	jmp    800242 <getuint+0x38>
	else if (lflag)
  800220:	85 d2                	test   %edx,%edx
  800222:	74 10                	je     800234 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800224:	8b 10                	mov    (%eax),%edx
  800226:	8d 4a 04             	lea    0x4(%edx),%ecx
  800229:	89 08                	mov    %ecx,(%eax)
  80022b:	8b 02                	mov    (%edx),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
  800232:	eb 0e                	jmp    800242 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800234:	8b 10                	mov    (%eax),%edx
  800236:	8d 4a 04             	lea    0x4(%edx),%ecx
  800239:	89 08                	mov    %ecx,(%eax)
  80023b:	8b 02                	mov    (%edx),%eax
  80023d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800247:	83 fa 01             	cmp    $0x1,%edx
  80024a:	7e 0e                	jle    80025a <getint+0x16>
		return va_arg(*ap, long long);
  80024c:	8b 10                	mov    (%eax),%edx
  80024e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	8b 52 04             	mov    0x4(%edx),%edx
  800258:	eb 1a                	jmp    800274 <getint+0x30>
	else if (lflag)
  80025a:	85 d2                	test   %edx,%edx
  80025c:	74 0c                	je     80026a <getint+0x26>
		return va_arg(*ap, long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 04             	lea    0x4(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	99                   	cltd   
  800268:	eb 0a                	jmp    800274 <getint+0x30>
	else
		return va_arg(*ap, int);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	99                   	cltd   
}
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	3b 50 04             	cmp    0x4(%eax),%edx
  800284:	73 08                	jae    80028e <sprintputch+0x18>
		*b->buf++ = ch;
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	88 0a                	mov    %cl,(%edx)
  80028b:	42                   	inc    %edx
  80028c:	89 10                	mov    %edx,(%eax)
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800296:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 10             	pushl  0x10(%ebp)
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	e8 05 00 00 00       	call   8002ad <vprintfmt>
	va_end(ap);
  8002a8:	83 c4 10             	add    $0x10,%esp
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 2c             	sub    $0x2c,%esp
  8002b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002bc:	eb 13                	jmp    8002d1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 6d 03 00 00    	je     800633 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	57                   	push   %edi
  8002ca:	50                   	push   %eax
  8002cb:	ff 55 08             	call   *0x8(%ebp)
  8002ce:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d1:	0f b6 06             	movzbl (%esi),%eax
  8002d4:	46                   	inc    %esi
  8002d5:	83 f8 25             	cmp    $0x25,%eax
  8002d8:	75 e4                	jne    8002be <vprintfmt+0x11>
  8002da:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002de:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002e5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002ec:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f8:	eb 28                	jmp    800322 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800300:	eb 20                	jmp    800322 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800302:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800304:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800308:	eb 18                	jmp    800322 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80030c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800313:	eb 0d                	jmp    800322 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800315:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8a 06                	mov    (%esi),%al
  800324:	0f b6 d0             	movzbl %al,%edx
  800327:	8d 5e 01             	lea    0x1(%esi),%ebx
  80032a:	83 e8 23             	sub    $0x23,%eax
  80032d:	3c 55                	cmp    $0x55,%al
  80032f:	0f 87 e0 02 00 00    	ja     800615 <vprintfmt+0x368>
  800335:	0f b6 c0             	movzbl %al,%eax
  800338:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033f:	83 ea 30             	sub    $0x30,%edx
  800342:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800345:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800348:	8d 50 d0             	lea    -0x30(%eax),%edx
  80034b:	83 fa 09             	cmp    $0x9,%edx
  80034e:	77 44                	ja     800394 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	89 de                	mov    %ebx,%esi
  800352:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800355:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800356:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800359:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80035d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800360:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800363:	83 fb 09             	cmp    $0x9,%ebx
  800366:	76 ed                	jbe    800355 <vprintfmt+0xa8>
  800368:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80036b:	eb 29                	jmp    800396 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 50 04             	lea    0x4(%eax),%edx
  800373:	89 55 14             	mov    %edx,0x14(%ebp)
  800376:	8b 00                	mov    (%eax),%eax
  800378:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037d:	eb 17                	jmp    800396 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80037f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800383:	78 85                	js     80030a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	89 de                	mov    %ebx,%esi
  800387:	eb 99                	jmp    800322 <vprintfmt+0x75>
  800389:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800392:	eb 8e                	jmp    800322 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800396:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039a:	79 86                	jns    800322 <vprintfmt+0x75>
  80039c:	e9 74 ff ff ff       	jmp    800315 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	e9 79 ff ff ff       	jmp    800322 <vprintfmt+0x75>
  8003a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	57                   	push   %edi
  8003b9:	ff 30                	pushl  (%eax)
  8003bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c4:	e9 08 ff ff ff       	jmp    8002d1 <vprintfmt+0x24>
  8003c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	79 02                	jns    8003dd <vprintfmt+0x130>
  8003db:	f7 d8                	neg    %eax
  8003dd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 f8 0f             	cmp    $0xf,%eax
  8003e2:	7f 0b                	jg     8003ef <vprintfmt+0x142>
  8003e4:	8b 04 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%eax
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	75 1a                	jne    800409 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	52                   	push   %edx
  8003f0:	68 20 1e 80 00       	push   $0x801e20
  8003f5:	57                   	push   %edi
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 92 fe ff ff       	call   800290 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800404:	e9 c8 fe ff ff       	jmp    8002d1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800409:	50                   	push   %eax
  80040a:	68 d1 21 80 00       	push   $0x8021d1
  80040f:	57                   	push   %edi
  800410:	ff 75 08             	pushl  0x8(%ebp)
  800413:	e8 78 fe ff ff       	call   800290 <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80041e:	e9 ae fe ff ff       	jmp    8002d1 <vprintfmt+0x24>
  800423:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800426:	89 de                	mov    %ebx,%esi
  800428:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 07                	jne    800447 <vprintfmt+0x19a>
				p = "(null)";
  800440:	c7 45 d0 19 1e 80 00 	movl   $0x801e19,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800447:	85 db                	test   %ebx,%ebx
  800449:	7e 42                	jle    80048d <vprintfmt+0x1e0>
  80044b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80044f:	74 3c                	je     80048d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	51                   	push   %ecx
  800455:	ff 75 d0             	pushl  -0x30(%ebp)
  800458:	e8 6f 02 00 00       	call   8006cc <strnlen>
  80045d:	29 c3                	sub    %eax,%ebx
  80045f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 db                	test   %ebx,%ebx
  800467:	7e 24                	jle    80048d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800469:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80046d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800470:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	57                   	push   %edi
  800477:	53                   	push   %ebx
  800478:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	4e                   	dec    %esi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 f6                	test   %esi,%esi
  800481:	7f f0                	jg     800473 <vprintfmt+0x1c6>
  800483:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800486:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800490:	0f be 02             	movsbl (%edx),%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	75 47                	jne    8004de <vprintfmt+0x231>
  800497:	eb 37                	jmp    8004d0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049d:	74 16                	je     8004b5 <vprintfmt+0x208>
  80049f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004a2:	83 fa 5e             	cmp    $0x5e,%edx
  8004a5:	76 0e                	jbe    8004b5 <vprintfmt+0x208>
					putch('?', putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	57                   	push   %edi
  8004ab:	6a 3f                	push   $0x3f
  8004ad:	ff 55 08             	call   *0x8(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb 0b                	jmp    8004c0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	57                   	push   %edi
  8004b9:	50                   	push   %eax
  8004ba:	ff 55 08             	call   *0x8(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c3:	0f be 03             	movsbl (%ebx),%eax
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	74 03                	je     8004cd <vprintfmt+0x220>
  8004ca:	43                   	inc    %ebx
  8004cb:	eb 1b                	jmp    8004e8 <vprintfmt+0x23b>
  8004cd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d4:	7f 1e                	jg     8004f4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d9:	e9 f3 fd ff ff       	jmp    8002d1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004e1:	43                   	inc    %ebx
  8004e2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004e8:	85 f6                	test   %esi,%esi
  8004ea:	78 ad                	js     800499 <vprintfmt+0x1ec>
  8004ec:	4e                   	dec    %esi
  8004ed:	79 aa                	jns    800499 <vprintfmt+0x1ec>
  8004ef:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004f2:	eb dc                	jmp    8004d0 <vprintfmt+0x223>
  8004f4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	57                   	push   %edi
  8004fb:	6a 20                	push   $0x20
  8004fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800500:	4b                   	dec    %ebx
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	85 db                	test   %ebx,%ebx
  800506:	7f ef                	jg     8004f7 <vprintfmt+0x24a>
  800508:	e9 c4 fd ff ff       	jmp    8002d1 <vprintfmt+0x24>
  80050d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800510:	89 ca                	mov    %ecx,%edx
  800512:	8d 45 14             	lea    0x14(%ebp),%eax
  800515:	e8 2a fd ff ff       	call   800244 <getint>
  80051a:	89 c3                	mov    %eax,%ebx
  80051c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80051e:	85 d2                	test   %edx,%edx
  800520:	78 0a                	js     80052c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800522:	b8 0a 00 00 00       	mov    $0xa,%eax
  800527:	e9 b0 00 00 00       	jmp    8005dc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	57                   	push   %edi
  800530:	6a 2d                	push   $0x2d
  800532:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800535:	f7 db                	neg    %ebx
  800537:	83 d6 00             	adc    $0x0,%esi
  80053a:	f7 de                	neg    %esi
  80053c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80053f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800544:	e9 93 00 00 00       	jmp    8005dc <vprintfmt+0x32f>
  800549:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80054c:	89 ca                	mov    %ecx,%edx
  80054e:	8d 45 14             	lea    0x14(%ebp),%eax
  800551:	e8 b4 fc ff ff       	call   80020a <getuint>
  800556:	89 c3                	mov    %eax,%ebx
  800558:	89 d6                	mov    %edx,%esi
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80055f:	eb 7b                	jmp    8005dc <vprintfmt+0x32f>
  800561:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800564:	89 ca                	mov    %ecx,%edx
  800566:	8d 45 14             	lea    0x14(%ebp),%eax
  800569:	e8 d6 fc ff ff       	call   800244 <getint>
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800572:	85 d2                	test   %edx,%edx
  800574:	78 07                	js     80057d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800576:	b8 08 00 00 00       	mov    $0x8,%eax
  80057b:	eb 5f                	jmp    8005dc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	6a 2d                	push   $0x2d
  800583:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800586:	f7 db                	neg    %ebx
  800588:	83 d6 00             	adc    $0x0,%esi
  80058b:	f7 de                	neg    %esi
  80058d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800590:	b8 08 00 00 00       	mov    $0x8,%eax
  800595:	eb 45                	jmp    8005dc <vprintfmt+0x32f>
  800597:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	57                   	push   %edi
  80059e:	6a 30                	push   $0x30
  8005a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a3:	83 c4 08             	add    $0x8,%esp
  8005a6:	57                   	push   %edi
  8005a7:	6a 78                	push   $0x78
  8005a9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b5:	8b 18                	mov    (%eax),%ebx
  8005b7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005bc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c4:	eb 16                	jmp    8005dc <vprintfmt+0x32f>
  8005c6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 37 fc ff ff       	call   80020a <getuint>
  8005d3:	89 c3                	mov    %eax,%ebx
  8005d5:	89 d6                	mov    %edx,%esi
			base = 16;
  8005d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005e3:	52                   	push   %edx
  8005e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e7:	50                   	push   %eax
  8005e8:	56                   	push   %esi
  8005e9:	53                   	push   %ebx
  8005ea:	89 fa                	mov    %edi,%edx
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	e8 68 fb ff ff       	call   80015c <printnum>
			break;
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fa:	e9 d2 fc ff ff       	jmp    8002d1 <vprintfmt+0x24>
  8005ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	57                   	push   %edi
  800606:	52                   	push   %edx
  800607:	ff 55 08             	call   *0x8(%ebp)
			break;
  80060a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800610:	e9 bc fc ff ff       	jmp    8002d1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	57                   	push   %edi
  800619:	6a 25                	push   $0x25
  80061b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	eb 02                	jmp    800625 <vprintfmt+0x378>
  800623:	89 c6                	mov    %eax,%esi
  800625:	8d 46 ff             	lea    -0x1(%esi),%eax
  800628:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80062c:	75 f5                	jne    800623 <vprintfmt+0x376>
  80062e:	e9 9e fc ff ff       	jmp    8002d1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800633:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800636:	5b                   	pop    %ebx
  800637:	5e                   	pop    %esi
  800638:	5f                   	pop    %edi
  800639:	c9                   	leave  
  80063a:	c3                   	ret    

0080063b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	83 ec 18             	sub    $0x18,%esp
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800647:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80064a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800651:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800658:	85 c0                	test   %eax,%eax
  80065a:	74 26                	je     800682 <vsnprintf+0x47>
  80065c:	85 d2                	test   %edx,%edx
  80065e:	7e 29                	jle    800689 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800660:	ff 75 14             	pushl  0x14(%ebp)
  800663:	ff 75 10             	pushl  0x10(%ebp)
  800666:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	68 76 02 80 00       	push   $0x800276
  80066f:	e8 39 fc ff ff       	call   8002ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800674:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800677:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 0c                	jmp    80068e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800682:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800687:	eb 05                	jmp    80068e <vsnprintf+0x53>
  800689:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068e:	c9                   	leave  
  80068f:	c3                   	ret    

00800690 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800699:	50                   	push   %eax
  80069a:	ff 75 10             	pushl  0x10(%ebp)
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	e8 93 ff ff ff       	call   80063b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    
	...

008006ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b5:	74 0e                	je     8006c5 <strlen+0x19>
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006bc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c1:	75 f9                	jne    8006bc <strlen+0x10>
  8006c3:	eb 05                	jmp    8006ca <strlen+0x1e>
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	74 17                	je     8006f0 <strnlen+0x24>
  8006d9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006dc:	74 19                	je     8006f7 <strnlen+0x2b>
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006e3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e4:	39 d0                	cmp    %edx,%eax
  8006e6:	74 14                	je     8006fc <strnlen+0x30>
  8006e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006ec:	75 f5                	jne    8006e3 <strnlen+0x17>
  8006ee:	eb 0c                	jmp    8006fc <strnlen+0x30>
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	eb 05                	jmp    8006fc <strnlen+0x30>
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	53                   	push   %ebx
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
  80070d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800710:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800713:	42                   	inc    %edx
  800714:	84 c9                	test   %cl,%cl
  800716:	75 f5                	jne    80070d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800718:	5b                   	pop    %ebx
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800722:	53                   	push   %ebx
  800723:	e8 84 ff ff ff       	call   8006ac <strlen>
  800728:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800731:	50                   	push   %eax
  800732:	e8 c7 ff ff ff       	call   8006fe <strcpy>
	return dst;
}
  800737:	89 d8                	mov    %ebx,%eax
  800739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	56                   	push   %esi
  800742:	53                   	push   %ebx
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
  800749:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074c:	85 f6                	test   %esi,%esi
  80074e:	74 15                	je     800765 <strncpy+0x27>
  800750:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800755:	8a 1a                	mov    (%edx),%bl
  800757:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075a:	80 3a 01             	cmpb   $0x1,(%edx)
  80075d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800760:	41                   	inc    %ecx
  800761:	39 ce                	cmp    %ecx,%esi
  800763:	77 f0                	ja     800755 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	57                   	push   %edi
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
  80076f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800775:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800778:	85 f6                	test   %esi,%esi
  80077a:	74 32                	je     8007ae <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80077c:	83 fe 01             	cmp    $0x1,%esi
  80077f:	74 22                	je     8007a3 <strlcpy+0x3a>
  800781:	8a 0b                	mov    (%ebx),%cl
  800783:	84 c9                	test   %cl,%cl
  800785:	74 20                	je     8007a7 <strlcpy+0x3e>
  800787:	89 f8                	mov    %edi,%eax
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80078e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800791:	88 08                	mov    %cl,(%eax)
  800793:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800794:	39 f2                	cmp    %esi,%edx
  800796:	74 11                	je     8007a9 <strlcpy+0x40>
  800798:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80079c:	42                   	inc    %edx
  80079d:	84 c9                	test   %cl,%cl
  80079f:	75 f0                	jne    800791 <strlcpy+0x28>
  8007a1:	eb 06                	jmp    8007a9 <strlcpy+0x40>
  8007a3:	89 f8                	mov    %edi,%eax
  8007a5:	eb 02                	jmp    8007a9 <strlcpy+0x40>
  8007a7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a9:	c6 00 00             	movb   $0x0,(%eax)
  8007ac:	eb 02                	jmp    8007b0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007b0:	29 f8                	sub    %edi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5f                   	pop    %edi
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c0:	8a 01                	mov    (%ecx),%al
  8007c2:	84 c0                	test   %al,%al
  8007c4:	74 10                	je     8007d6 <strcmp+0x1f>
  8007c6:	3a 02                	cmp    (%edx),%al
  8007c8:	75 0c                	jne    8007d6 <strcmp+0x1f>
		p++, q++;
  8007ca:	41                   	inc    %ecx
  8007cb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cc:	8a 01                	mov    (%ecx),%al
  8007ce:	84 c0                	test   %al,%al
  8007d0:	74 04                	je     8007d6 <strcmp+0x1f>
  8007d2:	3a 02                	cmp    (%edx),%al
  8007d4:	74 f4                	je     8007ca <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d6:	0f b6 c0             	movzbl %al,%eax
  8007d9:	0f b6 12             	movzbl (%edx),%edx
  8007dc:	29 d0                	sub    %edx,%eax
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	74 1b                	je     80080c <strncmp+0x2c>
  8007f1:	8a 1a                	mov    (%edx),%bl
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	74 24                	je     80081b <strncmp+0x3b>
  8007f7:	3a 19                	cmp    (%ecx),%bl
  8007f9:	75 20                	jne    80081b <strncmp+0x3b>
  8007fb:	48                   	dec    %eax
  8007fc:	74 15                	je     800813 <strncmp+0x33>
		n--, p++, q++;
  8007fe:	42                   	inc    %edx
  8007ff:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800800:	8a 1a                	mov    (%edx),%bl
  800802:	84 db                	test   %bl,%bl
  800804:	74 15                	je     80081b <strncmp+0x3b>
  800806:	3a 19                	cmp    (%ecx),%bl
  800808:	74 f1                	je     8007fb <strncmp+0x1b>
  80080a:	eb 0f                	jmp    80081b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strncmp+0x38>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800818:	5b                   	pop    %ebx
  800819:	c9                   	leave  
  80081a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 02             	movzbl (%edx),%eax
  80081e:	0f b6 11             	movzbl (%ecx),%edx
  800821:	29 d0                	sub    %edx,%eax
  800823:	eb f3                	jmp    800818 <strncmp+0x38>

00800825 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082e:	8a 10                	mov    (%eax),%dl
  800830:	84 d2                	test   %dl,%dl
  800832:	74 18                	je     80084c <strchr+0x27>
		if (*s == c)
  800834:	38 ca                	cmp    %cl,%dl
  800836:	75 06                	jne    80083e <strchr+0x19>
  800838:	eb 17                	jmp    800851 <strchr+0x2c>
  80083a:	38 ca                	cmp    %cl,%dl
  80083c:	74 13                	je     800851 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083e:	40                   	inc    %eax
  80083f:	8a 10                	mov    (%eax),%dl
  800841:	84 d2                	test   %dl,%dl
  800843:	75 f5                	jne    80083a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	eb 05                	jmp    800851 <strchr+0x2c>
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085c:	8a 10                	mov    (%eax),%dl
  80085e:	84 d2                	test   %dl,%dl
  800860:	74 11                	je     800873 <strfind+0x20>
		if (*s == c)
  800862:	38 ca                	cmp    %cl,%dl
  800864:	75 06                	jne    80086c <strfind+0x19>
  800866:	eb 0b                	jmp    800873 <strfind+0x20>
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 07                	je     800873 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	8a 10                	mov    (%eax),%dl
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f5                	jne    800868 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800884:	85 c9                	test   %ecx,%ecx
  800886:	74 30                	je     8008b8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800888:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088e:	75 25                	jne    8008b5 <memset+0x40>
  800890:	f6 c1 03             	test   $0x3,%cl
  800893:	75 20                	jne    8008b5 <memset+0x40>
		c &= 0xFF;
  800895:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800898:	89 d3                	mov    %edx,%ebx
  80089a:	c1 e3 08             	shl    $0x8,%ebx
  80089d:	89 d6                	mov    %edx,%esi
  80089f:	c1 e6 18             	shl    $0x18,%esi
  8008a2:	89 d0                	mov    %edx,%eax
  8008a4:	c1 e0 10             	shl    $0x10,%eax
  8008a7:	09 f0                	or     %esi,%eax
  8008a9:	09 d0                	or     %edx,%eax
  8008ab:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b0:	fc                   	cld    
  8008b1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b3:	eb 03                	jmp    8008b8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b5:	fc                   	cld    
  8008b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cd:	39 c6                	cmp    %eax,%esi
  8008cf:	73 34                	jae    800905 <memmove+0x46>
  8008d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d4:	39 d0                	cmp    %edx,%eax
  8008d6:	73 2d                	jae    800905 <memmove+0x46>
		s += n;
		d += n;
  8008d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	f6 c2 03             	test   $0x3,%dl
  8008de:	75 1b                	jne    8008fb <memmove+0x3c>
  8008e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e6:	75 13                	jne    8008fb <memmove+0x3c>
  8008e8:	f6 c1 03             	test   $0x3,%cl
  8008eb:	75 0e                	jne    8008fb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ed:	83 ef 04             	sub    $0x4,%edi
  8008f0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f6:	fd                   	std    
  8008f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f9:	eb 07                	jmp    800902 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fb:	4f                   	dec    %edi
  8008fc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ff:	fd                   	std    
  800900:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800902:	fc                   	cld    
  800903:	eb 20                	jmp    800925 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090b:	75 13                	jne    800920 <memmove+0x61>
  80090d:	a8 03                	test   $0x3,%al
  80090f:	75 0f                	jne    800920 <memmove+0x61>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0a                	jne    800920 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800916:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 05                	jmp    800925 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 85 ff ff ff       	call   8008bf <memmove>
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	57                   	push   %edi
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	85 ff                	test   %edi,%edi
  80094d:	74 32                	je     800981 <memcmp+0x45>
		if (*s1 != *s2)
  80094f:	8a 03                	mov    (%ebx),%al
  800951:	8a 0e                	mov    (%esi),%cl
  800953:	38 c8                	cmp    %cl,%al
  800955:	74 19                	je     800970 <memcmp+0x34>
  800957:	eb 0d                	jmp    800966 <memcmp+0x2a>
  800959:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80095d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800961:	42                   	inc    %edx
  800962:	38 c8                	cmp    %cl,%al
  800964:	74 10                	je     800976 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 c9             	movzbl %cl,%ecx
  80096c:	29 c8                	sub    %ecx,%eax
  80096e:	eb 16                	jmp    800986 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800970:	4f                   	dec    %edi
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
  800976:	39 fa                	cmp    %edi,%edx
  800978:	75 df                	jne    800959 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
  80097f:	eb 05                	jmp    800986 <memcmp+0x4a>
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800991:	89 c2                	mov    %eax,%edx
  800993:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800996:	39 d0                	cmp    %edx,%eax
  800998:	73 12                	jae    8009ac <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80099d:	38 08                	cmp    %cl,(%eax)
  80099f:	75 06                	jne    8009a7 <memfind+0x1c>
  8009a1:	eb 09                	jmp    8009ac <memfind+0x21>
  8009a3:	38 08                	cmp    %cl,(%eax)
  8009a5:	74 05                	je     8009ac <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a7:	40                   	inc    %eax
  8009a8:	39 c2                	cmp    %eax,%edx
  8009aa:	77 f7                	ja     8009a3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 01                	jmp    8009bd <strtol+0xf>
		s++;
  8009bc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bd:	8a 02                	mov    (%edx),%al
  8009bf:	3c 20                	cmp    $0x20,%al
  8009c1:	74 f9                	je     8009bc <strtol+0xe>
  8009c3:	3c 09                	cmp    $0x9,%al
  8009c5:	74 f5                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c7:	3c 2b                	cmp    $0x2b,%al
  8009c9:	75 08                	jne    8009d3 <strtol+0x25>
		s++;
  8009cb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d1:	eb 13                	jmp    8009e6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d3:	3c 2d                	cmp    $0x2d,%al
  8009d5:	75 0a                	jne    8009e1 <strtol+0x33>
		s++, neg = 1;
  8009d7:	8d 52 01             	lea    0x1(%edx),%edx
  8009da:	bf 01 00 00 00       	mov    $0x1,%edi
  8009df:	eb 05                	jmp    8009e6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e6:	85 db                	test   %ebx,%ebx
  8009e8:	74 05                	je     8009ef <strtol+0x41>
  8009ea:	83 fb 10             	cmp    $0x10,%ebx
  8009ed:	75 28                	jne    800a17 <strtol+0x69>
  8009ef:	8a 02                	mov    (%edx),%al
  8009f1:	3c 30                	cmp    $0x30,%al
  8009f3:	75 10                	jne    800a05 <strtol+0x57>
  8009f5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f9:	75 0a                	jne    800a05 <strtol+0x57>
		s += 2, base = 16;
  8009fb:	83 c2 02             	add    $0x2,%edx
  8009fe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a03:	eb 12                	jmp    800a17 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a05:	85 db                	test   %ebx,%ebx
  800a07:	75 0e                	jne    800a17 <strtol+0x69>
  800a09:	3c 30                	cmp    $0x30,%al
  800a0b:	75 05                	jne    800a12 <strtol+0x64>
		s++, base = 8;
  800a0d:	42                   	inc    %edx
  800a0e:	b3 08                	mov    $0x8,%bl
  800a10:	eb 05                	jmp    800a17 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1e:	8a 0a                	mov    (%edx),%cl
  800a20:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a23:	80 fb 09             	cmp    $0x9,%bl
  800a26:	77 08                	ja     800a30 <strtol+0x82>
			dig = *s - '0';
  800a28:	0f be c9             	movsbl %cl,%ecx
  800a2b:	83 e9 30             	sub    $0x30,%ecx
  800a2e:	eb 1e                	jmp    800a4e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 08                	ja     800a40 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a38:	0f be c9             	movsbl %cl,%ecx
  800a3b:	83 e9 57             	sub    $0x57,%ecx
  800a3e:	eb 0e                	jmp    800a4e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a43:	80 fb 19             	cmp    $0x19,%bl
  800a46:	77 13                	ja     800a5b <strtol+0xad>
			dig = *s - 'A' + 10;
  800a48:	0f be c9             	movsbl %cl,%ecx
  800a4b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a4e:	39 f1                	cmp    %esi,%ecx
  800a50:	7d 0d                	jge    800a5f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a52:	42                   	inc    %edx
  800a53:	0f af c6             	imul   %esi,%eax
  800a56:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a59:	eb c3                	jmp    800a1e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a5b:	89 c1                	mov    %eax,%ecx
  800a5d:	eb 02                	jmp    800a61 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a65:	74 05                	je     800a6c <strtol+0xbe>
		*endptr = (char *) s;
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a6c:	85 ff                	test   %edi,%edi
  800a6e:	74 04                	je     800a74 <strtol+0xc6>
  800a70:	89 c8                	mov    %ecx,%eax
  800a72:	f7 d8                	neg    %eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    
  800a79:	00 00                	add    %al,(%eax)
	...

00800a7c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 1c             	sub    $0x1c,%esp
  800a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a88:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a8b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	8b 75 14             	mov    0x14(%ebp),%esi
  800a90:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a99:	cd 30                	int    $0x30
  800a9b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aa1:	74 1c                	je     800abf <syscall+0x43>
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	7e 18                	jle    800abf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa7:	83 ec 0c             	sub    $0xc,%esp
  800aaa:	50                   	push   %eax
  800aab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800aae:	68 ff 20 80 00       	push   $0x8020ff
  800ab3:	6a 42                	push   $0x42
  800ab5:	68 1c 21 80 00       	push   $0x80211c
  800aba:	e8 21 0f 00 00       	call   8019e0 <_panic>

	return ret;
}
  800abf:	89 d0                	mov    %edx,%eax
  800ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	ff 75 0c             	pushl  0xc(%ebp)
  800ad8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	e8 92 ff ff ff       	call   800a7c <syscall>
  800aea:	83 c4 10             	add    $0x10,%esp
	return;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <sys_cgetc>:

int
sys_cgetc(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	6a 00                	push   $0x0
  800afb:	6a 00                	push   $0x0
  800afd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	e8 6b ff ff ff       	call   800a7c <syscall>
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b24:	ba 01 00 00 00       	mov    $0x1,%edx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	e8 49 ff ff ff       	call   800a7c <syscall>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	6a 00                	push   $0x0
  800b41:	6a 00                	push   $0x0
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	e8 25 ff ff ff       	call   800a7c <syscall>
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <sys_yield>:

void
sys_yield(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b76:	e8 01 ff ff ff       	call   800a7c <syscall>
  800b7b:	83 c4 10             	add    $0x10,%esp
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	ff 75 10             	pushl  0x10(%ebp)
  800b8d:	ff 75 0c             	pushl  0xc(%ebp)
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	ba 01 00 00 00       	mov    $0x1,%edx
  800b98:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9d:	e8 da fe ff ff       	call   800a7c <syscall>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800baa:	ff 75 18             	pushl  0x18(%ebp)
  800bad:	ff 75 14             	pushl  0x14(%ebp)
  800bb0:	ff 75 10             	pushl  0x10(%ebp)
  800bb3:	ff 75 0c             	pushl  0xc(%ebp)
  800bb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	e8 b4 fe ff ff       	call   800a7c <syscall>
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bd0:	6a 00                	push   $0x0
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800be1:	b8 06 00 00 00       	mov    $0x6,%eax
  800be6:	e8 91 fe ff ff       	call   800a7c <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	ff 75 0c             	pushl  0xc(%ebp)
  800bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bff:	ba 01 00 00 00       	mov    $0x1,%edx
  800c04:	b8 08 00 00 00       	mov    $0x8,%eax
  800c09:	e8 6e fe ff ff       	call   800a7c <syscall>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	ff 75 0c             	pushl  0xc(%ebp)
  800c1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c22:	ba 01 00 00 00       	mov    $0x1,%edx
  800c27:	b8 09 00 00 00       	mov    $0x9,%eax
  800c2c:	e8 4b fe ff ff       	call   800a7c <syscall>
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c39:	6a 00                	push   $0x0
  800c3b:	6a 00                	push   $0x0
  800c3d:	6a 00                	push   $0x0
  800c3f:	ff 75 0c             	pushl  0xc(%ebp)
  800c42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c45:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4f:	e8 28 fe ff ff       	call   800a7c <syscall>
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 14             	pushl  0x14(%ebp)
  800c61:	ff 75 10             	pushl  0x10(%ebp)
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c74:	e8 03 fe ff ff       	call   800a7c <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c81:	6a 00                	push   $0x0
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c96:	e8 e1 fd ff ff       	call   800a7c <syscall>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cb9:	e8 be fd ff ff       	call   800a7c <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	ff 75 14             	pushl  0x14(%ebp)
  800ccb:	ff 75 10             	pushl  0x10(%ebp)
  800cce:	ff 75 0c             	pushl  0xc(%ebp)
  800cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cde:	e8 99 fd ff ff       	call   800a7c <syscall>
} 
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfb:	b8 11 00 00 00       	mov    $0x11,%eax
  800d00:	e8 77 fd ff ff       	call   800a7c <syscall>
}
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    

00800d07 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	6a 00                	push   $0x0
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 10 00 00 00       	mov    $0x10,%eax
  800d24:	e8 53 fd ff ff       	call   800a7c <syscall>
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    
	...

00800d2c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	05 00 00 00 30       	add    $0x30000000,%eax
  800d37:	c1 e8 0c             	shr    $0xc,%eax
}
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    

00800d3c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d3f:	ff 75 08             	pushl  0x8(%ebp)
  800d42:	e8 e5 ff ff ff       	call   800d2c <fd2num>
  800d47:	83 c4 04             	add    $0x4,%esp
  800d4a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d4f:	c1 e0 0c             	shl    $0xc,%eax
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	53                   	push   %ebx
  800d58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d60:	a8 01                	test   $0x1,%al
  800d62:	74 34                	je     800d98 <fd_alloc+0x44>
  800d64:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d69:	a8 01                	test   $0x1,%al
  800d6b:	74 32                	je     800d9f <fd_alloc+0x4b>
  800d6d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	89 c2                	mov    %eax,%edx
  800d76:	c1 ea 16             	shr    $0x16,%edx
  800d79:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d80:	f6 c2 01             	test   $0x1,%dl
  800d83:	74 1f                	je     800da4 <fd_alloc+0x50>
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	c1 ea 0c             	shr    $0xc,%edx
  800d8a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d91:	f6 c2 01             	test   $0x1,%dl
  800d94:	75 17                	jne    800dad <fd_alloc+0x59>
  800d96:	eb 0c                	jmp    800da4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d98:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d9d:	eb 05                	jmp    800da4 <fd_alloc+0x50>
  800d9f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800da4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800da6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dab:	eb 17                	jmp    800dc4 <fd_alloc+0x70>
  800dad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db7:	75 b9                	jne    800d72 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800dbf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dcd:	83 f8 1f             	cmp    $0x1f,%eax
  800dd0:	77 36                	ja     800e08 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800dd7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	c1 ea 16             	shr    $0x16,%edx
  800ddf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de6:	f6 c2 01             	test   $0x1,%dl
  800de9:	74 24                	je     800e0f <fd_lookup+0x48>
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	c1 ea 0c             	shr    $0xc,%edx
  800df0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df7:	f6 c2 01             	test   $0x1,%dl
  800dfa:	74 1a                	je     800e16 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dff:	89 02                	mov    %eax,(%edx)
	return 0;
  800e01:	b8 00 00 00 00       	mov    $0x0,%eax
  800e06:	eb 13                	jmp    800e1b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0d:	eb 0c                	jmp    800e1b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e14:	eb 05                	jmp    800e1b <fd_lookup+0x54>
  800e16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    

00800e1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	53                   	push   %ebx
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e2a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e30:	74 0d                	je     800e3f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
  800e37:	eb 14                	jmp    800e4d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e39:	39 0a                	cmp    %ecx,(%edx)
  800e3b:	75 10                	jne    800e4d <dev_lookup+0x30>
  800e3d:	eb 05                	jmp    800e44 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e44:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 31                	jmp    800e7e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e4d:	40                   	inc    %eax
  800e4e:	8b 14 85 a8 21 80 00 	mov    0x8021a8(,%eax,4),%edx
  800e55:	85 d2                	test   %edx,%edx
  800e57:	75 e0                	jne    800e39 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e59:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5e:	8b 40 48             	mov    0x48(%eax),%eax
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	51                   	push   %ecx
  800e65:	50                   	push   %eax
  800e66:	68 2c 21 80 00       	push   $0x80212c
  800e6b:	e8 d8 f2 ff ff       	call   800148 <cprintf>
	*dev = 0;
  800e70:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 20             	sub    $0x20,%esp
  800e8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8e:	8a 45 0c             	mov    0xc(%ebp),%al
  800e91:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e94:	56                   	push   %esi
  800e95:	e8 92 fe ff ff       	call   800d2c <fd2num>
  800e9a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e9d:	89 14 24             	mov    %edx,(%esp)
  800ea0:	50                   	push   %eax
  800ea1:	e8 21 ff ff ff       	call   800dc7 <fd_lookup>
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	83 c4 08             	add    $0x8,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	78 05                	js     800eb4 <fd_close+0x31>
	    || fd != fd2)
  800eaf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb2:	74 0d                	je     800ec1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800eb4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800eb8:	75 48                	jne    800f02 <fd_close+0x7f>
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebf:	eb 41                	jmp    800f02 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec7:	50                   	push   %eax
  800ec8:	ff 36                	pushl  (%esi)
  800eca:	e8 4e ff ff ff       	call   800e1d <dev_lookup>
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 1c                	js     800ef4 <fd_close+0x71>
		if (dev->dev_close)
  800ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edb:	8b 40 10             	mov    0x10(%eax),%eax
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	74 0d                	je     800eef <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	56                   	push   %esi
  800ee6:	ff d0                	call   *%eax
  800ee8:	89 c3                	mov    %eax,%ebx
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	eb 05                	jmp    800ef4 <fd_close+0x71>
		else
			r = 0;
  800eef:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	56                   	push   %esi
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 cb fc ff ff       	call   800bca <sys_page_unmap>
	return r;
  800eff:	83 c4 10             	add    $0x10,%esp
}
  800f02:	89 d8                	mov    %ebx,%eax
  800f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	ff 75 08             	pushl  0x8(%ebp)
  800f18:	e8 aa fe ff ff       	call   800dc7 <fd_lookup>
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 10                	js     800f34 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	6a 01                	push   $0x1
  800f29:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2c:	e8 52 ff ff ff       	call   800e83 <fd_close>
  800f31:	83 c4 10             	add    $0x10,%esp
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <close_all>:

void
close_all(void)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	53                   	push   %ebx
  800f46:	e8 c0 ff ff ff       	call   800f0b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4b:	43                   	inc    %ebx
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	83 fb 20             	cmp    $0x20,%ebx
  800f52:	75 ee                	jne    800f42 <close_all+0xc>
		close(i);
}
  800f54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 2c             	sub    $0x2c,%esp
  800f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f68:	50                   	push   %eax
  800f69:	ff 75 08             	pushl  0x8(%ebp)
  800f6c:	e8 56 fe ff ff       	call   800dc7 <fd_lookup>
  800f71:	89 c3                	mov    %eax,%ebx
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	0f 88 c0 00 00 00    	js     80103e <dup+0xe5>
		return r;
	close(newfdnum);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	57                   	push   %edi
  800f82:	e8 84 ff ff ff       	call   800f0b <close>

	newfd = INDEX2FD(newfdnum);
  800f87:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f8d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f90:	83 c4 04             	add    $0x4,%esp
  800f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f96:	e8 a1 fd ff ff       	call   800d3c <fd2data>
  800f9b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f9d:	89 34 24             	mov    %esi,(%esp)
  800fa0:	e8 97 fd ff ff       	call   800d3c <fd2data>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	c1 e8 16             	shr    $0x16,%eax
  800fb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb7:	a8 01                	test   $0x1,%al
  800fb9:	74 37                	je     800ff2 <dup+0x99>
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	c1 e8 0c             	shr    $0xc,%eax
  800fc0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc7:	f6 c2 01             	test   $0x1,%dl
  800fca:	74 26                	je     800ff2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fcc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fdf:	6a 00                	push   $0x0
  800fe1:	53                   	push   %ebx
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 bb fb ff ff       	call   800ba4 <sys_page_map>
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 2d                	js     80101f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff5:	89 c2                	mov    %eax,%edx
  800ff7:	c1 ea 0c             	shr    $0xc,%edx
  800ffa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80100a:	52                   	push   %edx
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	50                   	push   %eax
  80100f:	6a 00                	push   $0x0
  801011:	e8 8e fb ff ff       	call   800ba4 <sys_page_map>
  801016:	89 c3                	mov    %eax,%ebx
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 1d                	jns    80103c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 a0 fb ff ff       	call   800bca <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102a:	83 c4 08             	add    $0x8,%esp
  80102d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801030:	6a 00                	push   $0x0
  801032:	e8 93 fb ff ff       	call   800bca <sys_page_unmap>
	return r;
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	eb 02                	jmp    80103e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80103c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 14             	sub    $0x14,%esp
  80104f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801052:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	53                   	push   %ebx
  801057:	e8 6b fd ff ff       	call   800dc7 <fd_lookup>
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 67                	js     8010ca <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106d:	ff 30                	pushl  (%eax)
  80106f:	e8 a9 fd ff ff       	call   800e1d <dev_lookup>
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 4f                	js     8010ca <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107e:	8b 50 08             	mov    0x8(%eax),%edx
  801081:	83 e2 03             	and    $0x3,%edx
  801084:	83 fa 01             	cmp    $0x1,%edx
  801087:	75 21                	jne    8010aa <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801089:	a1 04 40 80 00       	mov    0x804004,%eax
  80108e:	8b 40 48             	mov    0x48(%eax),%eax
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	53                   	push   %ebx
  801095:	50                   	push   %eax
  801096:	68 6d 21 80 00       	push   $0x80216d
  80109b:	e8 a8 f0 ff ff       	call   800148 <cprintf>
		return -E_INVAL;
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010a8:	eb 20                	jmp    8010ca <read+0x82>
	}
	if (!dev->dev_read)
  8010aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ad:	8b 52 08             	mov    0x8(%edx),%edx
  8010b0:	85 d2                	test   %edx,%edx
  8010b2:	74 11                	je     8010c5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	ff 75 10             	pushl  0x10(%ebp)
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	50                   	push   %eax
  8010be:	ff d2                	call   *%edx
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	eb 05                	jmp    8010ca <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010de:	85 f6                	test   %esi,%esi
  8010e0:	74 31                	je     801113 <readn+0x44>
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	89 f2                	mov    %esi,%edx
  8010f1:	29 c2                	sub    %eax,%edx
  8010f3:	52                   	push   %edx
  8010f4:	03 45 0c             	add    0xc(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	57                   	push   %edi
  8010f9:	e8 4a ff ff ff       	call   801048 <read>
		if (m < 0)
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 17                	js     80111c <readn+0x4d>
			return m;
		if (m == 0)
  801105:	85 c0                	test   %eax,%eax
  801107:	74 11                	je     80111a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801109:	01 c3                	add    %eax,%ebx
  80110b:	89 d8                	mov    %ebx,%eax
  80110d:	39 f3                	cmp    %esi,%ebx
  80110f:	72 db                	jb     8010ec <readn+0x1d>
  801111:	eb 09                	jmp    80111c <readn+0x4d>
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	eb 02                	jmp    80111c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80111a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80111c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	53                   	push   %ebx
  801128:	83 ec 14             	sub    $0x14,%esp
  80112b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	53                   	push   %ebx
  801133:	e8 8f fc ff ff       	call   800dc7 <fd_lookup>
  801138:	83 c4 08             	add    $0x8,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 62                	js     8011a1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801149:	ff 30                	pushl  (%eax)
  80114b:	e8 cd fc ff ff       	call   800e1d <dev_lookup>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 4a                	js     8011a1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801157:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115e:	75 21                	jne    801181 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801160:	a1 04 40 80 00       	mov    0x804004,%eax
  801165:	8b 40 48             	mov    0x48(%eax),%eax
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	53                   	push   %ebx
  80116c:	50                   	push   %eax
  80116d:	68 89 21 80 00       	push   $0x802189
  801172:	e8 d1 ef ff ff       	call   800148 <cprintf>
		return -E_INVAL;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117f:	eb 20                	jmp    8011a1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801181:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801184:	8b 52 0c             	mov    0xc(%edx),%edx
  801187:	85 d2                	test   %edx,%edx
  801189:	74 11                	je     80119c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	ff 75 10             	pushl  0x10(%ebp)
  801191:	ff 75 0c             	pushl  0xc(%ebp)
  801194:	50                   	push   %eax
  801195:	ff d2                	call   *%edx
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	eb 05                	jmp    8011a1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80119c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	ff 75 08             	pushl  0x8(%ebp)
  8011b3:	e8 0f fc ff ff       	call   800dc7 <fd_lookup>
  8011b8:	83 c4 08             	add    $0x8,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 0e                	js     8011cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 14             	sub    $0x14,%esp
  8011d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	53                   	push   %ebx
  8011de:	e8 e4 fb ff ff       	call   800dc7 <fd_lookup>
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 5f                	js     801249 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	ff 30                	pushl  (%eax)
  8011f6:	e8 22 fc ff ff       	call   800e1d <dev_lookup>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 47                	js     801249 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801209:	75 21                	jne    80122c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80120b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	68 4c 21 80 00       	push   $0x80214c
  80121d:	e8 26 ef ff ff       	call   800148 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122a:	eb 1d                	jmp    801249 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80122c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122f:	8b 52 18             	mov    0x18(%edx),%edx
  801232:	85 d2                	test   %edx,%edx
  801234:	74 0e                	je     801244 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	50                   	push   %eax
  80123d:	ff d2                	call   *%edx
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	eb 05                	jmp    801249 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801244:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801249:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	53                   	push   %ebx
  801252:	83 ec 14             	sub    $0x14,%esp
  801255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801258:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 63 fb ff ff       	call   800dc7 <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 52                	js     8012bd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	ff 30                	pushl  (%eax)
  801277:	e8 a1 fb ff ff       	call   800e1d <dev_lookup>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 3a                	js     8012bd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801286:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80128a:	74 2c                	je     8012b8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80128f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801296:	00 00 00 
	stat->st_isdir = 0;
  801299:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a0:	00 00 00 
	stat->st_dev = dev;
  8012a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b0:	ff 50 14             	call   *0x14(%eax)
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	eb 05                	jmp    8012bd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	6a 00                	push   $0x0
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 78 01 00 00       	call   80144c <open>
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 1b                	js     8012f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	50                   	push   %eax
  8012e4:	e8 65 ff ff ff       	call   80124e <fstat>
  8012e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	e8 18 fc ff ff       	call   800f0b <close>
	return r;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	89 f3                	mov    %esi,%ebx
}
  8012f8:	89 d8                	mov    %ebx,%eax
  8012fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    
  801301:	00 00                	add    %al,(%eax)
	...

00801304 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
  801309:	89 c3                	mov    %eax,%ebx
  80130b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80130d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801314:	75 12                	jne    801328 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	6a 01                	push   $0x1
  80131b:	e8 d2 07 00 00       	call   801af2 <ipc_find_env>
  801320:	a3 00 40 80 00       	mov    %eax,0x804000
  801325:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801328:	6a 07                	push   $0x7
  80132a:	68 00 50 80 00       	push   $0x805000
  80132f:	53                   	push   %ebx
  801330:	ff 35 00 40 80 00    	pushl  0x804000
  801336:	e8 62 07 00 00       	call   801a9d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80133b:	83 c4 0c             	add    $0xc,%esp
  80133e:	6a 00                	push   $0x0
  801340:	56                   	push   %esi
  801341:	6a 00                	push   $0x0
  801343:	e8 e0 06 00 00       	call   801a28 <ipc_recv>
}
  801348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	8b 40 0c             	mov    0xc(%eax),%eax
  80135f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 05 00 00 00       	mov    $0x5,%eax
  80136e:	e8 91 ff ff ff       	call   801304 <fsipc>
  801373:	85 c0                	test   %eax,%eax
  801375:	78 2c                	js     8013a3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	68 00 50 80 00       	push   $0x805000
  80137f:	53                   	push   %ebx
  801380:	e8 79 f3 ff ff       	call   8006fe <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801385:	a1 80 50 80 00       	mov    0x805080,%eax
  80138a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801390:	a1 84 50 80 00       	mov    0x805084,%eax
  801395:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013be:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c3:	e8 3c ff ff ff       	call   801304 <fsipc>
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013dd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ed:	e8 12 ff ff ff       	call   801304 <fsipc>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 4b                	js     801443 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013f8:	39 c6                	cmp    %eax,%esi
  8013fa:	73 16                	jae    801412 <devfile_read+0x48>
  8013fc:	68 b8 21 80 00       	push   $0x8021b8
  801401:	68 bf 21 80 00       	push   $0x8021bf
  801406:	6a 7d                	push   $0x7d
  801408:	68 d4 21 80 00       	push   $0x8021d4
  80140d:	e8 ce 05 00 00       	call   8019e0 <_panic>
	assert(r <= PGSIZE);
  801412:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801417:	7e 16                	jle    80142f <devfile_read+0x65>
  801419:	68 df 21 80 00       	push   $0x8021df
  80141e:	68 bf 21 80 00       	push   $0x8021bf
  801423:	6a 7e                	push   $0x7e
  801425:	68 d4 21 80 00       	push   $0x8021d4
  80142a:	e8 b1 05 00 00       	call   8019e0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80142f:	83 ec 04             	sub    $0x4,%esp
  801432:	50                   	push   %eax
  801433:	68 00 50 80 00       	push   $0x805000
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	e8 7f f4 ff ff       	call   8008bf <memmove>
	return r;
  801440:	83 c4 10             	add    $0x10,%esp
}
  801443:	89 d8                	mov    %ebx,%eax
  801445:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
  801451:	83 ec 1c             	sub    $0x1c,%esp
  801454:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801457:	56                   	push   %esi
  801458:	e8 4f f2 ff ff       	call   8006ac <strlen>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801465:	7f 65                	jg     8014cc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	e8 e1 f8 ff ff       	call   800d54 <fd_alloc>
  801473:	89 c3                	mov    %eax,%ebx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 55                	js     8014d1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	56                   	push   %esi
  801480:	68 00 50 80 00       	push   $0x805000
  801485:	e8 74 f2 ff ff       	call   8006fe <strcpy>
	fsipcbuf.open.req_omode = mode;
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801492:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801495:	b8 01 00 00 00       	mov    $0x1,%eax
  80149a:	e8 65 fe ff ff       	call   801304 <fsipc>
  80149f:	89 c3                	mov    %eax,%ebx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	79 12                	jns    8014ba <open+0x6e>
		fd_close(fd, 0);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	6a 00                	push   $0x0
  8014ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b0:	e8 ce f9 ff ff       	call   800e83 <fd_close>
		return r;
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	eb 17                	jmp    8014d1 <open+0x85>
	}

	return fd2num(fd);
  8014ba:	83 ec 0c             	sub    $0xc,%esp
  8014bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c0:	e8 67 f8 ff ff       	call   800d2c <fd2num>
  8014c5:	89 c3                	mov    %eax,%ebx
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb 05                	jmp    8014d1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014cc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014d1:	89 d8                	mov    %ebx,%eax
  8014d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    
	...

008014dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 4d f8 ff ff       	call   800d3c <fd2data>
  8014ef:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	68 eb 21 80 00       	push   $0x8021eb
  8014f9:	56                   	push   %esi
  8014fa:	e8 ff f1 ff ff       	call   8006fe <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014ff:	8b 43 04             	mov    0x4(%ebx),%eax
  801502:	2b 03                	sub    (%ebx),%eax
  801504:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80150a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801511:	00 00 00 
	stat->st_dev = &devpipe;
  801514:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80151b:	30 80 00 
	return 0;
}
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801534:	53                   	push   %ebx
  801535:	6a 00                	push   $0x0
  801537:	e8 8e f6 ff ff       	call   800bca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80153c:	89 1c 24             	mov    %ebx,(%esp)
  80153f:	e8 f8 f7 ff ff       	call   800d3c <fd2data>
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	50                   	push   %eax
  801548:	6a 00                	push   $0x0
  80154a:	e8 7b f6 ff ff       	call   800bca <sys_page_unmap>
}
  80154f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 1c             	sub    $0x1c,%esp
  80155d:	89 c7                	mov    %eax,%edi
  80155f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801562:	a1 04 40 80 00       	mov    0x804004,%eax
  801567:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	57                   	push   %edi
  80156e:	e8 cd 05 00 00       	call   801b40 <pageref>
  801573:	89 c6                	mov    %eax,%esi
  801575:	83 c4 04             	add    $0x4,%esp
  801578:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157b:	e8 c0 05 00 00       	call   801b40 <pageref>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	39 c6                	cmp    %eax,%esi
  801585:	0f 94 c0             	sete   %al
  801588:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80158b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801591:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801594:	39 cb                	cmp    %ecx,%ebx
  801596:	75 08                	jne    8015a0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801598:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5f                   	pop    %edi
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8015a0:	83 f8 01             	cmp    $0x1,%eax
  8015a3:	75 bd                	jne    801562 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a5:	8b 42 58             	mov    0x58(%edx),%eax
  8015a8:	6a 01                	push   $0x1
  8015aa:	50                   	push   %eax
  8015ab:	53                   	push   %ebx
  8015ac:	68 f2 21 80 00       	push   $0x8021f2
  8015b1:	e8 92 eb ff ff       	call   800148 <cprintf>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	eb a7                	jmp    801562 <_pipeisclosed+0xe>

008015bb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 28             	sub    $0x28,%esp
  8015c4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015c7:	56                   	push   %esi
  8015c8:	e8 6f f7 ff ff       	call   800d3c <fd2data>
  8015cd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015d6:	75 4a                	jne    801622 <devpipe_write+0x67>
  8015d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8015dd:	eb 56                	jmp    801635 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015df:	89 da                	mov    %ebx,%edx
  8015e1:	89 f0                	mov    %esi,%eax
  8015e3:	e8 6c ff ff ff       	call   801554 <_pipeisclosed>
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	75 4d                	jne    801639 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015ec:	e8 68 f5 ff ff       	call   800b59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f4:	8b 13                	mov    (%ebx),%edx
  8015f6:	83 c2 20             	add    $0x20,%edx
  8015f9:	39 d0                	cmp    %edx,%eax
  8015fb:	73 e2                	jae    8015df <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801605:	79 05                	jns    80160c <devpipe_write+0x51>
  801607:	4a                   	dec    %edx
  801608:	83 ca e0             	or     $0xffffffe0,%edx
  80160b:	42                   	inc    %edx
  80160c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801612:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801616:	40                   	inc    %eax
  801617:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80161a:	47                   	inc    %edi
  80161b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80161e:	77 07                	ja     801627 <devpipe_write+0x6c>
  801620:	eb 13                	jmp    801635 <devpipe_write+0x7a>
  801622:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801627:	8b 43 04             	mov    0x4(%ebx),%eax
  80162a:	8b 13                	mov    (%ebx),%edx
  80162c:	83 c2 20             	add    $0x20,%edx
  80162f:	39 d0                	cmp    %edx,%eax
  801631:	73 ac                	jae    8015df <devpipe_write+0x24>
  801633:	eb c8                	jmp    8015fd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801635:	89 f8                	mov    %edi,%eax
  801637:	eb 05                	jmp    80163e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 18             	sub    $0x18,%esp
  80164f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801652:	57                   	push   %edi
  801653:	e8 e4 f6 ff ff       	call   800d3c <fd2data>
  801658:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801661:	75 44                	jne    8016a7 <devpipe_read+0x61>
  801663:	be 00 00 00 00       	mov    $0x0,%esi
  801668:	eb 4f                	jmp    8016b9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80166a:	89 f0                	mov    %esi,%eax
  80166c:	eb 54                	jmp    8016c2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80166e:	89 da                	mov    %ebx,%edx
  801670:	89 f8                	mov    %edi,%eax
  801672:	e8 dd fe ff ff       	call   801554 <_pipeisclosed>
  801677:	85 c0                	test   %eax,%eax
  801679:	75 42                	jne    8016bd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80167b:	e8 d9 f4 ff ff       	call   800b59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801680:	8b 03                	mov    (%ebx),%eax
  801682:	3b 43 04             	cmp    0x4(%ebx),%eax
  801685:	74 e7                	je     80166e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801687:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80168c:	79 05                	jns    801693 <devpipe_read+0x4d>
  80168e:	48                   	dec    %eax
  80168f:	83 c8 e0             	or     $0xffffffe0,%eax
  801692:	40                   	inc    %eax
  801693:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80169d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169f:	46                   	inc    %esi
  8016a0:	39 75 10             	cmp    %esi,0x10(%ebp)
  8016a3:	77 07                	ja     8016ac <devpipe_read+0x66>
  8016a5:	eb 12                	jmp    8016b9 <devpipe_read+0x73>
  8016a7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8016ac:	8b 03                	mov    (%ebx),%eax
  8016ae:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b1:	75 d4                	jne    801687 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b3:	85 f6                	test   %esi,%esi
  8016b5:	75 b3                	jne    80166a <devpipe_read+0x24>
  8016b7:	eb b5                	jmp    80166e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b9:	89 f0                	mov    %esi,%eax
  8016bb:	eb 05                	jmp    8016c2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	57                   	push   %edi
  8016ce:	56                   	push   %esi
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 28             	sub    $0x28,%esp
  8016d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 75 f6 ff ff       	call   800d54 <fd_alloc>
  8016df:	89 c3                	mov    %eax,%ebx
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	0f 88 24 01 00 00    	js     801810 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016ec:	83 ec 04             	sub    $0x4,%esp
  8016ef:	68 07 04 00 00       	push   $0x407
  8016f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 82 f4 ff ff       	call   800b80 <sys_page_alloc>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	0f 88 05 01 00 00    	js     801810 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	e8 3d f6 ff ff       	call   800d54 <fd_alloc>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	0f 88 dc 00 00 00    	js     801800 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	68 07 04 00 00       	push   $0x407
  80172c:	ff 75 e0             	pushl  -0x20(%ebp)
  80172f:	6a 00                	push   $0x0
  801731:	e8 4a f4 ff ff       	call   800b80 <sys_page_alloc>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 88 bd 00 00 00    	js     801800 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	ff 75 e4             	pushl  -0x1c(%ebp)
  801749:	e8 ee f5 ff ff       	call   800d3c <fd2data>
  80174e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801750:	83 c4 0c             	add    $0xc,%esp
  801753:	68 07 04 00 00       	push   $0x407
  801758:	50                   	push   %eax
  801759:	6a 00                	push   $0x0
  80175b:	e8 20 f4 ff ff       	call   800b80 <sys_page_alloc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 88 83 00 00 00    	js     8017f0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	ff 75 e0             	pushl  -0x20(%ebp)
  801773:	e8 c4 f5 ff ff       	call   800d3c <fd2data>
  801778:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177f:	50                   	push   %eax
  801780:	6a 00                	push   $0x0
  801782:	56                   	push   %esi
  801783:	6a 00                	push   $0x0
  801785:	e8 1a f4 ff ff       	call   800ba4 <sys_page_map>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 20             	add    $0x20,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 4f                	js     8017e2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801793:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80179c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80179e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017a8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c3:	e8 64 f5 ff ff       	call   800d2c <fd2num>
  8017c8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8017ca:	83 c4 04             	add    $0x4,%esp
  8017cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8017d0:	e8 57 f5 ff ff       	call   800d2c <fd2num>
  8017d5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e0:	eb 2e                	jmp    801810 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	56                   	push   %esi
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 dd f3 ff ff       	call   800bca <sys_page_unmap>
  8017ed:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 cd f3 ff ff       	call   800bca <sys_page_unmap>
  8017fd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	ff 75 e4             	pushl  -0x1c(%ebp)
  801806:	6a 00                	push   $0x0
  801808:	e8 bd f3 ff ff       	call   800bca <sys_page_unmap>
  80180d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801810:	89 d8                	mov    %ebx,%eax
  801812:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801823:	50                   	push   %eax
  801824:	ff 75 08             	pushl  0x8(%ebp)
  801827:	e8 9b f5 ff ff       	call   800dc7 <fd_lookup>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 18                	js     80184b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 f4             	pushl  -0xc(%ebp)
  801839:	e8 fe f4 ff ff       	call   800d3c <fd2data>
	return _pipeisclosed(fd, p);
  80183e:	89 c2                	mov    %eax,%edx
  801840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801843:	e8 0c fd ff ff       	call   801554 <_pipeisclosed>
  801848:	83 c4 10             	add    $0x10,%esp
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    
  80184d:	00 00                	add    %al,(%eax)
	...

00801850 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801860:	68 0a 22 80 00       	push   $0x80220a
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	e8 91 ee ff ff       	call   8006fe <strcpy>
	return 0;
}
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	57                   	push   %edi
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801880:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801884:	74 45                	je     8018cb <devcons_write+0x57>
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801890:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801896:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801899:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80189b:	83 fb 7f             	cmp    $0x7f,%ebx
  80189e:	76 05                	jbe    8018a5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018a0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	53                   	push   %ebx
  8018a9:	03 45 0c             	add    0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	57                   	push   %edi
  8018ae:	e8 0c f0 ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  8018b3:	83 c4 08             	add    $0x8,%esp
  8018b6:	53                   	push   %ebx
  8018b7:	57                   	push   %edi
  8018b8:	e8 0c f2 ff ff       	call   800ac9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bd:	01 de                	add    %ebx,%esi
  8018bf:	89 f0                	mov    %esi,%eax
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018c7:	72 cd                	jb     801896 <devcons_write+0x22>
  8018c9:	eb 05                	jmp    8018d0 <devcons_write+0x5c>
  8018cb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018d0:	89 f0                	mov    %esi,%eax
  8018d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5e                   	pop    %esi
  8018d7:	5f                   	pop    %edi
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e4:	75 07                	jne    8018ed <devcons_read+0x13>
  8018e6:	eb 25                	jmp    80190d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018e8:	e8 6c f2 ff ff       	call   800b59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018ed:	e8 fd f1 ff ff       	call   800aef <sys_cgetc>
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	74 f2                	je     8018e8 <devcons_read+0xe>
  8018f6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 1d                	js     801919 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018fc:	83 f8 04             	cmp    $0x4,%eax
  8018ff:	74 13                	je     801914 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801901:	8b 45 0c             	mov    0xc(%ebp),%eax
  801904:	88 10                	mov    %dl,(%eax)
	return 1;
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	eb 0c                	jmp    801919 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
  801912:	eb 05                	jmp    801919 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801927:	6a 01                	push   $0x1
  801929:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	e8 97 f1 ff ff       	call   800ac9 <sys_cputs>
  801932:	83 c4 10             	add    $0x10,%esp
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <getchar>:

int
getchar(void)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80193d:	6a 01                	push   $0x1
  80193f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801942:	50                   	push   %eax
  801943:	6a 00                	push   $0x0
  801945:	e8 fe f6 ff ff       	call   801048 <read>
	if (r < 0)
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 0f                	js     801960 <getchar+0x29>
		return r;
	if (r < 1)
  801951:	85 c0                	test   %eax,%eax
  801953:	7e 06                	jle    80195b <getchar+0x24>
		return -E_EOF;
	return c;
  801955:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801959:	eb 05                	jmp    801960 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80195b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801968:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	ff 75 08             	pushl  0x8(%ebp)
  80196f:	e8 53 f4 ff ff       	call   800dc7 <fd_lookup>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 11                	js     80198c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801984:	39 10                	cmp    %edx,(%eax)
  801986:	0f 94 c0             	sete   %al
  801989:	0f b6 c0             	movzbl %al,%eax
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <opencons>:

int
opencons(void)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	e8 b7 f3 ff ff       	call   800d54 <fd_alloc>
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 3a                	js     8019de <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	68 07 04 00 00       	push   $0x407
  8019ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8019af:	6a 00                	push   $0x0
  8019b1:	e8 ca f1 ff ff       	call   800b80 <sys_page_alloc>
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 21                	js     8019de <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019bd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	50                   	push   %eax
  8019d6:	e8 51 f3 ff ff       	call   800d2c <fd2num>
  8019db:	83 c4 10             	add    $0x10,%esp
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019e5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019e8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019ee:	e8 42 f1 ff ff       	call   800b35 <sys_getenvid>
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	ff 75 0c             	pushl  0xc(%ebp)
  8019f9:	ff 75 08             	pushl  0x8(%ebp)
  8019fc:	53                   	push   %ebx
  8019fd:	50                   	push   %eax
  8019fe:	68 18 22 80 00       	push   $0x802218
  801a03:	e8 40 e7 ff ff       	call   800148 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a08:	83 c4 18             	add    $0x18,%esp
  801a0b:	56                   	push   %esi
  801a0c:	ff 75 10             	pushl  0x10(%ebp)
  801a0f:	e8 e3 e6 ff ff       	call   8000f7 <vcprintf>
	cprintf("\n");
  801a14:	c7 04 24 fc 1d 80 00 	movl   $0x801dfc,(%esp)
  801a1b:	e8 28 e7 ff ff       	call   800148 <cprintf>
  801a20:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a23:	cc                   	int3   
  801a24:	eb fd                	jmp    801a23 <_panic+0x43>
	...

00801a28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a36:	85 c0                	test   %eax,%eax
  801a38:	74 0e                	je     801a48 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	50                   	push   %eax
  801a3e:	e8 38 f2 ff ff       	call   800c7b <sys_ipc_recv>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb 10                	jmp    801a58 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	68 00 00 c0 ee       	push   $0xeec00000
  801a50:	e8 26 f2 ff ff       	call   800c7b <sys_ipc_recv>
  801a55:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	75 26                	jne    801a82 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	74 0a                	je     801a6a <ipc_recv+0x42>
  801a60:	a1 04 40 80 00       	mov    0x804004,%eax
  801a65:	8b 40 74             	mov    0x74(%eax),%eax
  801a68:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x50>
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 78             	mov    0x78(%eax),%eax
  801a76:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 40 70             	mov    0x70(%eax),%eax
  801a80:	eb 14                	jmp    801a96 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a82:	85 f6                	test   %esi,%esi
  801a84:	74 06                	je     801a8c <ipc_recv+0x64>
  801a86:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a8c:	85 db                	test   %ebx,%ebx
  801a8e:	74 06                	je     801a96 <ipc_recv+0x6e>
  801a90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aac:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	75 25                	jne    801ad8 <ipc_send+0x3b>
  801ab3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ab8:	eb 1e                	jmp    801ad8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abd:	75 07                	jne    801ac6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801abf:	e8 95 f0 ff ff       	call   800b59 <sys_yield>
  801ac4:	eb 12                	jmp    801ad8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ac6:	50                   	push   %eax
  801ac7:	68 3c 22 80 00       	push   $0x80223c
  801acc:	6a 43                	push   $0x43
  801ace:	68 4f 22 80 00       	push   $0x80224f
  801ad3:	e8 08 ff ff ff       	call   8019e0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	57                   	push   %edi
  801adb:	ff 75 08             	pushl  0x8(%ebp)
  801ade:	e8 73 f1 ff ff       	call   800c56 <sys_ipc_try_send>
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	75 d0                	jne    801aba <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801af8:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801afe:	74 1a                	je     801b1a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b00:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 e2 07             	shl    $0x7,%edx
  801b0a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b11:	8b 52 50             	mov    0x50(%edx),%edx
  801b14:	39 ca                	cmp    %ecx,%edx
  801b16:	75 18                	jne    801b30 <ipc_find_env+0x3e>
  801b18:	eb 05                	jmp    801b1f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	c1 e2 07             	shl    $0x7,%edx
  801b24:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b2b:	8b 40 40             	mov    0x40(%eax),%eax
  801b2e:	eb 0c                	jmp    801b3c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b30:	40                   	inc    %eax
  801b31:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b36:	75 cd                	jne    801b05 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b38:	66 b8 00 00          	mov    $0x0,%ax
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    
	...

00801b40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b46:	89 c2                	mov    %eax,%edx
  801b48:	c1 ea 16             	shr    $0x16,%edx
  801b4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b52:	f6 c2 01             	test   $0x1,%dl
  801b55:	74 1e                	je     801b75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b57:	c1 e8 0c             	shr    $0xc,%eax
  801b5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b61:	a8 01                	test   $0x1,%al
  801b63:	74 17                	je     801b7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b65:	c1 e8 0c             	shr    $0xc,%eax
  801b68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b6f:	ef 
  801b70:	0f b7 c0             	movzwl %ax,%eax
  801b73:	eb 0c                	jmp    801b81 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	eb 05                	jmp    801b81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    
	...

00801b84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	83 ec 10             	sub    $0x10,%esp
  801b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b92:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	75 2e                	jne    801bd0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ba2:	39 f1                	cmp    %esi,%ecx
  801ba4:	77 5a                	ja     801c00 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ba6:	85 c9                	test   %ecx,%ecx
  801ba8:	75 0b                	jne    801bb5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801baa:	b8 01 00 00 00       	mov    $0x1,%eax
  801baf:	31 d2                	xor    %edx,%edx
  801bb1:	f7 f1                	div    %ecx
  801bb3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	f7 f1                	div    %ecx
  801bbb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bbd:	89 f8                	mov    %edi,%eax
  801bbf:	f7 f1                	div    %ecx
  801bc1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc3:	89 f8                	mov    %edi,%eax
  801bc5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    
  801bce:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bd0:	39 f0                	cmp    %esi,%eax
  801bd2:	77 1c                	ja     801bf0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bd4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	75 3c                	jne    801c18 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bdc:	39 f0                	cmp    %esi,%eax
  801bde:	0f 82 90 00 00 00    	jb     801c74 <__udivdi3+0xf0>
  801be4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801be7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bea:	0f 86 84 00 00 00    	jbe    801c74 <__udivdi3+0xf0>
  801bf0:	31 f6                	xor    %esi,%esi
  801bf2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bf4:	89 f8                	mov    %edi,%eax
  801bf6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	5e                   	pop    %esi
  801bfc:	5f                   	pop    %edi
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    
  801bff:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c00:	89 f2                	mov    %esi,%edx
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	f7 f1                	div    %ecx
  801c06:	89 c7                	mov    %eax,%edi
  801c08:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c18:	89 f9                	mov    %edi,%ecx
  801c1a:	d3 e0                	shl    %cl,%eax
  801c1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c1f:	b8 20 00 00 00       	mov    $0x20,%eax
  801c24:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c29:	88 c1                	mov    %al,%cl
  801c2b:	d3 ea                	shr    %cl,%edx
  801c2d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c30:	09 ca                	or     %ecx,%edx
  801c32:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c38:	89 f9                	mov    %edi,%ecx
  801c3a:	d3 e2                	shl    %cl,%edx
  801c3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c3f:	89 f2                	mov    %esi,%edx
  801c41:	88 c1                	mov    %al,%cl
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	89 f9                	mov    %edi,%ecx
  801c4c:	d3 e2                	shl    %cl,%edx
  801c4e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c51:	88 c1                	mov    %al,%cl
  801c53:	d3 ee                	shr    %cl,%esi
  801c55:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c57:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c5a:	89 f0                	mov    %esi,%eax
  801c5c:	89 ca                	mov    %ecx,%edx
  801c5e:	f7 75 ec             	divl   -0x14(%ebp)
  801c61:	89 d1                	mov    %edx,%ecx
  801c63:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c65:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c68:	39 d1                	cmp    %edx,%ecx
  801c6a:	72 28                	jb     801c94 <__udivdi3+0x110>
  801c6c:	74 1a                	je     801c88 <__udivdi3+0x104>
  801c6e:	89 f7                	mov    %esi,%edi
  801c70:	31 f6                	xor    %esi,%esi
  801c72:	eb 80                	jmp    801bf4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c74:	31 f6                	xor    %esi,%esi
  801c76:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    
  801c86:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c8f:	39 c2                	cmp    %eax,%edx
  801c91:	73 db                	jae    801c6e <__udivdi3+0xea>
  801c93:	90                   	nop
		{
		  q0--;
  801c94:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c97:	31 f6                	xor    %esi,%esi
  801c99:	e9 56 ff ff ff       	jmp    801bf4 <__udivdi3+0x70>
	...

00801ca0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	83 ec 20             	sub    $0x20,%esp
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cb4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cbd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cbf:	85 ff                	test   %edi,%edi
  801cc1:	75 15                	jne    801cd8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cc3:	39 f1                	cmp    %esi,%ecx
  801cc5:	0f 86 99 00 00 00    	jbe    801d64 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ccb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ccd:	89 d0                	mov    %edx,%eax
  801ccf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cd1:	83 c4 20             	add    $0x20,%esp
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd8:	39 f7                	cmp    %esi,%edi
  801cda:	0f 87 a4 00 00 00    	ja     801d84 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ce0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ce3:	83 f0 1f             	xor    $0x1f,%eax
  801ce6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce9:	0f 84 a1 00 00 00    	je     801d90 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cf6:	bf 20 00 00 00       	mov    $0x20,%edi
  801cfb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	09 c2                	or     %eax,%edx
  801d07:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d10:	d3 e0                	shl    %cl,%eax
  801d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d15:	89 f2                	mov    %esi,%edx
  801d17:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d24:	89 f9                	mov    %edi,%ecx
  801d26:	d3 e8                	shr    %cl,%eax
  801d28:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d2a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	f7 75 f0             	divl   -0x10(%ebp)
  801d31:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d33:	f7 65 f4             	mull   -0xc(%ebp)
  801d36:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d39:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d3b:	39 d6                	cmp    %edx,%esi
  801d3d:	72 71                	jb     801db0 <__umoddi3+0x110>
  801d3f:	74 7f                	je     801dc0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d44:	29 c8                	sub    %ecx,%eax
  801d46:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d48:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	89 f9                	mov    %edi,%ecx
  801d51:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d53:	09 d0                	or     %edx,%eax
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d5c:	83 c4 20             	add    $0x20,%esp
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    
  801d63:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	75 0b                	jne    801d73 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f1                	div    %ecx
  801d71:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	31 d2                	xor    %edx,%edx
  801d77:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7c:	f7 f1                	div    %ecx
  801d7e:	e9 4a ff ff ff       	jmp    801ccd <__umoddi3+0x2d>
  801d83:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d84:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d86:	83 c4 20             	add    $0x20,%esp
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d90:	39 f7                	cmp    %esi,%edi
  801d92:	72 05                	jb     801d99 <__umoddi3+0xf9>
  801d94:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d97:	77 0c                	ja     801da5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d99:	89 f2                	mov    %esi,%edx
  801d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9e:	29 c8                	sub    %ecx,%eax
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
  801daf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801db0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801db3:	89 c1                	mov    %eax,%ecx
  801db5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801db8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dbb:	eb 84                	jmp    801d41 <__umoddi3+0xa1>
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dc0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dc3:	72 eb                	jb     801db0 <__umoddi3+0x110>
  801dc5:	89 f2                	mov    %esi,%edx
  801dc7:	e9 75 ff ff ff       	jmp    801d41 <__umoddi3+0xa1>
