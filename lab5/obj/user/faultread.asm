
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
  800040:	68 80 1d 80 00       	push   $0x801d80
  800045:	e8 02 01 00 00       	call   80014c <cprintf>
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
  80005b:	e8 d9 0a 00 00       	call   800b39 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 00 30 80 00       	mov    %eax,0x803000
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
  8000a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a6:	e8 23 0e 00 00       	call   800ece <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 62 0a 00 00       	call   800b17 <sys_env_destroy>
  8000b5:	83 c4 10             	add    $0x10,%esp
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    
	...

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cf:	40                   	inc    %eax
  8000d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	75 1a                	jne    8000f3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	68 ff 00 00 00       	push   $0xff
  8000e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e4:	50                   	push   %eax
  8000e5:	e8 e3 09 00 00       	call   800acd <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f3:	ff 43 04             	incl   0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 bc 00 80 00       	push   $0x8000bc
  80012a:	e8 82 01 00 00       	call   8002b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 89 09 00 00       	call   800acd <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 2c             	sub    $0x2c,%esp
  800169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	8b 55 0c             	mov    0xc(%ebp),%edx
  800174:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800177:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80017a:	8b 45 10             	mov    0x10(%ebp),%eax
  80017d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800180:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800183:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800186:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80018d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800190:	72 0c                	jb     80019e <printnum+0x3e>
  800192:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800195:	76 07                	jbe    80019e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800197:	4b                   	dec    %ebx
  800198:	85 db                	test   %ebx,%ebx
  80019a:	7f 31                	jg     8001cd <printnum+0x6d>
  80019c:	eb 3f                	jmp    8001dd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	57                   	push   %edi
  8001a2:	4b                   	dec    %ebx
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ab:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 73 19 00 00       	call   801b2c <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001c3:	e8 98 ff ff ff       	call   800160 <printnum>
  8001c8:	83 c4 20             	add    $0x20,%esp
  8001cb:	eb 10                	jmp    8001dd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	57                   	push   %edi
  8001d2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d5:	4b                   	dec    %ebx
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	85 db                	test   %ebx,%ebx
  8001db:	7f f0                	jg     8001cd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	56                   	push   %esi
  8001e1:	83 ec 04             	sub    $0x4,%esp
  8001e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 53 1a 00 00       	call   801c48 <__umoddi3>
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	0f be 80 a8 1d 80 00 	movsbl 0x801da8(%eax),%eax
  8001ff:	50                   	push   %eax
  800200:	ff 55 e4             	call   *-0x1c(%ebp)
  800203:	83 c4 10             	add    $0x10,%esp
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024b:	83 fa 01             	cmp    $0x1,%edx
  80024e:	7e 0e                	jle    80025e <getint+0x16>
		return va_arg(*ap, long long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 08             	lea    0x8(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	8b 52 04             	mov    0x4(%edx),%edx
  80025c:	eb 1a                	jmp    800278 <getint+0x30>
	else if (lflag)
  80025e:	85 d2                	test   %edx,%edx
  800260:	74 0c                	je     80026e <getint+0x26>
		return va_arg(*ap, long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	99                   	cltd   
  80026c:	eb 0a                	jmp    800278 <getint+0x30>
	else
		return va_arg(*ap, int);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 04             	lea    0x4(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	99                   	cltd   
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800280:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800283:	8b 10                	mov    (%eax),%edx
  800285:	3b 50 04             	cmp    0x4(%eax),%edx
  800288:	73 08                	jae    800292 <sprintputch+0x18>
		*b->buf++ = ch;
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	88 0a                	mov    %cl,(%edx)
  80028f:	42                   	inc    %edx
  800290:	89 10                	mov    %edx,(%eax)
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 10             	pushl  0x10(%ebp)
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 05 00 00 00       	call   8002b1 <vprintfmt>
	va_end(ap);
  8002ac:	83 c4 10             	add    $0x10,%esp
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c0:	eb 13                	jmp    8002d5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 6d 03 00 00    	je     800637 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	57                   	push   %edi
  8002ce:	50                   	push   %eax
  8002cf:	ff 55 08             	call   *0x8(%ebp)
  8002d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d5:	0f b6 06             	movzbl (%esi),%eax
  8002d8:	46                   	inc    %esi
  8002d9:	83 f8 25             	cmp    $0x25,%eax
  8002dc:	75 e4                	jne    8002c2 <vprintfmt+0x11>
  8002de:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002e9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002f0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fc:	eb 28                	jmp    800326 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800300:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800304:	eb 20                	jmp    800326 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800308:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80030c:	eb 18                	jmp    800326 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800310:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800317:	eb 0d                	jmp    800326 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800319:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8a 06                	mov    (%esi),%al
  800328:	0f b6 d0             	movzbl %al,%edx
  80032b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80032e:	83 e8 23             	sub    $0x23,%eax
  800331:	3c 55                	cmp    $0x55,%al
  800333:	0f 87 e0 02 00 00    	ja     800619 <vprintfmt+0x368>
  800339:	0f b6 c0             	movzbl %al,%eax
  80033c:	ff 24 85 e0 1e 80 00 	jmp    *0x801ee0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800343:	83 ea 30             	sub    $0x30,%edx
  800346:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800349:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80034c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80034f:	83 fa 09             	cmp    $0x9,%edx
  800352:	77 44                	ja     800398 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	89 de                	mov    %ebx,%esi
  800356:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800359:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80035a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80035d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800361:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800364:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800367:	83 fb 09             	cmp    $0x9,%ebx
  80036a:	76 ed                	jbe    800359 <vprintfmt+0xa8>
  80036c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80036f:	eb 29                	jmp    80039a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 50 04             	lea    0x4(%eax),%edx
  800377:	89 55 14             	mov    %edx,0x14(%ebp)
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 17                	jmp    80039a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800383:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800387:	78 85                	js     80030e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	89 de                	mov    %ebx,%esi
  80038b:	eb 99                	jmp    800326 <vprintfmt+0x75>
  80038d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800396:	eb 8e                	jmp    800326 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80039a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039e:	79 86                	jns    800326 <vprintfmt+0x75>
  8003a0:	e9 74 ff ff ff       	jmp    800319 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
  8003a8:	e9 79 ff ff ff       	jmp    800326 <vprintfmt+0x75>
  8003ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	57                   	push   %edi
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 08 ff ff ff       	jmp    8002d5 <vprintfmt+0x24>
  8003cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	79 02                	jns    8003e1 <vprintfmt+0x130>
  8003df:	f7 d8                	neg    %eax
  8003e1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x142>
  8003e8:	8b 04 85 40 20 80 00 	mov    0x802040(,%eax,4),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	75 1a                	jne    80040d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	52                   	push   %edx
  8003f4:	68 c0 1d 80 00       	push   $0x801dc0
  8003f9:	57                   	push   %edi
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	e8 92 fe ff ff       	call   800294 <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800408:	e9 c8 fe ff ff       	jmp    8002d5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80040d:	50                   	push   %eax
  80040e:	68 71 21 80 00       	push   $0x802171
  800413:	57                   	push   %edi
  800414:	ff 75 08             	pushl  0x8(%ebp)
  800417:	e8 78 fe ff ff       	call   800294 <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800422:	e9 ae fe ff ff       	jmp    8002d5 <vprintfmt+0x24>
  800427:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80042a:	89 de                	mov    %ebx,%esi
  80042c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80042f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800440:	85 c0                	test   %eax,%eax
  800442:	75 07                	jne    80044b <vprintfmt+0x19a>
				p = "(null)";
  800444:	c7 45 d0 b9 1d 80 00 	movl   $0x801db9,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80044b:	85 db                	test   %ebx,%ebx
  80044d:	7e 42                	jle    800491 <vprintfmt+0x1e0>
  80044f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800453:	74 3c                	je     800491 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	51                   	push   %ecx
  800459:	ff 75 d0             	pushl  -0x30(%ebp)
  80045c:	e8 6f 02 00 00       	call   8006d0 <strnlen>
  800461:	29 c3                	sub    %eax,%ebx
  800463:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 db                	test   %ebx,%ebx
  80046b:	7e 24                	jle    800491 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80046d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800471:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800474:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	57                   	push   %edi
  80047b:	53                   	push   %ebx
  80047c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	4e                   	dec    %esi
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	85 f6                	test   %esi,%esi
  800485:	7f f0                	jg     800477 <vprintfmt+0x1c6>
  800487:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80048a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800491:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800494:	0f be 02             	movsbl (%edx),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	75 47                	jne    8004e2 <vprintfmt+0x231>
  80049b:	eb 37                	jmp    8004d4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	74 16                	je     8004b9 <vprintfmt+0x208>
  8004a3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004a6:	83 fa 5e             	cmp    $0x5e,%edx
  8004a9:	76 0e                	jbe    8004b9 <vprintfmt+0x208>
					putch('?', putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	57                   	push   %edi
  8004af:	6a 3f                	push   $0x3f
  8004b1:	ff 55 08             	call   *0x8(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	eb 0b                	jmp    8004c4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	57                   	push   %edi
  8004bd:	50                   	push   %eax
  8004be:	ff 55 08             	call   *0x8(%ebp)
  8004c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c7:	0f be 03             	movsbl (%ebx),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	74 03                	je     8004d1 <vprintfmt+0x220>
  8004ce:	43                   	inc    %ebx
  8004cf:	eb 1b                	jmp    8004ec <vprintfmt+0x23b>
  8004d1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d8:	7f 1e                	jg     8004f8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004dd:	e9 f3 fd ff ff       	jmp    8002d5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004e5:	43                   	inc    %ebx
  8004e6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	78 ad                	js     80049d <vprintfmt+0x1ec>
  8004f0:	4e                   	dec    %esi
  8004f1:	79 aa                	jns    80049d <vprintfmt+0x1ec>
  8004f3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004f6:	eb dc                	jmp    8004d4 <vprintfmt+0x223>
  8004f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	57                   	push   %edi
  8004ff:	6a 20                	push   $0x20
  800501:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800504:	4b                   	dec    %ebx
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 db                	test   %ebx,%ebx
  80050a:	7f ef                	jg     8004fb <vprintfmt+0x24a>
  80050c:	e9 c4 fd ff ff       	jmp    8002d5 <vprintfmt+0x24>
  800511:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800514:	89 ca                	mov    %ecx,%edx
  800516:	8d 45 14             	lea    0x14(%ebp),%eax
  800519:	e8 2a fd ff ff       	call   800248 <getint>
  80051e:	89 c3                	mov    %eax,%ebx
  800520:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800522:	85 d2                	test   %edx,%edx
  800524:	78 0a                	js     800530 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800526:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052b:	e9 b0 00 00 00       	jmp    8005e0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	57                   	push   %edi
  800534:	6a 2d                	push   $0x2d
  800536:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800539:	f7 db                	neg    %ebx
  80053b:	83 d6 00             	adc    $0x0,%esi
  80053e:	f7 de                	neg    %esi
  800540:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800543:	b8 0a 00 00 00       	mov    $0xa,%eax
  800548:	e9 93 00 00 00       	jmp    8005e0 <vprintfmt+0x32f>
  80054d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800550:	89 ca                	mov    %ecx,%edx
  800552:	8d 45 14             	lea    0x14(%ebp),%eax
  800555:	e8 b4 fc ff ff       	call   80020e <getuint>
  80055a:	89 c3                	mov    %eax,%ebx
  80055c:	89 d6                	mov    %edx,%esi
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800563:	eb 7b                	jmp    8005e0 <vprintfmt+0x32f>
  800565:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800568:	89 ca                	mov    %ecx,%edx
  80056a:	8d 45 14             	lea    0x14(%ebp),%eax
  80056d:	e8 d6 fc ff ff       	call   800248 <getint>
  800572:	89 c3                	mov    %eax,%ebx
  800574:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800576:	85 d2                	test   %edx,%edx
  800578:	78 07                	js     800581 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80057a:	b8 08 00 00 00       	mov    $0x8,%eax
  80057f:	eb 5f                	jmp    8005e0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	57                   	push   %edi
  800585:	6a 2d                	push   $0x2d
  800587:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80058a:	f7 db                	neg    %ebx
  80058c:	83 d6 00             	adc    $0x0,%esi
  80058f:	f7 de                	neg    %esi
  800591:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800594:	b8 08 00 00 00       	mov    $0x8,%eax
  800599:	eb 45                	jmp    8005e0 <vprintfmt+0x32f>
  80059b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	57                   	push   %edi
  8005a2:	6a 30                	push   $0x30
  8005a4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	6a 78                	push   $0x78
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b9:	8b 18                	mov    (%eax),%ebx
  8005bb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c8:	eb 16                	jmp    8005e0 <vprintfmt+0x32f>
  8005ca:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cd:	89 ca                	mov    %ecx,%edx
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 37 fc ff ff       	call   80020e <getuint>
  8005d7:	89 c3                	mov    %eax,%ebx
  8005d9:	89 d6                	mov    %edx,%esi
			base = 16;
  8005db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005e7:	52                   	push   %edx
  8005e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005eb:	50                   	push   %eax
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
  8005ee:	89 fa                	mov    %edi,%edx
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f3:	e8 68 fb ff ff       	call   800160 <printnum>
			break;
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fe:	e9 d2 fc ff ff       	jmp    8002d5 <vprintfmt+0x24>
  800603:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	57                   	push   %edi
  80060a:	52                   	push   %edx
  80060b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80060e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800614:	e9 bc fc ff ff       	jmp    8002d5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	57                   	push   %edi
  80061d:	6a 25                	push   $0x25
  80061f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	eb 02                	jmp    800629 <vprintfmt+0x378>
  800627:	89 c6                	mov    %eax,%esi
  800629:	8d 46 ff             	lea    -0x1(%esi),%eax
  80062c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800630:	75 f5                	jne    800627 <vprintfmt+0x376>
  800632:	e9 9e fc ff ff       	jmp    8002d5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063a:	5b                   	pop    %ebx
  80063b:	5e                   	pop    %esi
  80063c:	5f                   	pop    %edi
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    

0080063f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	83 ec 18             	sub    $0x18,%esp
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80064e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800652:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065c:	85 c0                	test   %eax,%eax
  80065e:	74 26                	je     800686 <vsnprintf+0x47>
  800660:	85 d2                	test   %edx,%edx
  800662:	7e 29                	jle    80068d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800664:	ff 75 14             	pushl  0x14(%ebp)
  800667:	ff 75 10             	pushl  0x10(%ebp)
  80066a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	68 7a 02 80 00       	push   $0x80027a
  800673:	e8 39 fc ff ff       	call   8002b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80067e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 0c                	jmp    800692 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068b:	eb 05                	jmp    800692 <vsnprintf+0x53>
  80068d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069d:	50                   	push   %eax
  80069e:	ff 75 10             	pushl  0x10(%ebp)
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	ff 75 08             	pushl  0x8(%ebp)
  8006a7:	e8 93 ff ff ff       	call   80063f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    
	...

008006b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b9:	74 0e                	je     8006c9 <strlen+0x19>
  8006bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006c0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c5:	75 f9                	jne    8006c0 <strlen+0x10>
  8006c7:	eb 05                	jmp    8006ce <strlen+0x1e>
  8006c9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	74 17                	je     8006f4 <strnlen+0x24>
  8006dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e0:	74 19                	je     8006fb <strnlen+0x2b>
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006e7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e8:	39 d0                	cmp    %edx,%eax
  8006ea:	74 14                	je     800700 <strnlen+0x30>
  8006ec:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f0:	75 f5                	jne    8006e7 <strnlen+0x17>
  8006f2:	eb 0c                	jmp    800700 <strnlen+0x30>
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	eb 05                	jmp    800700 <strnlen+0x30>
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070c:	ba 00 00 00 00       	mov    $0x0,%edx
  800711:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800714:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800717:	42                   	inc    %edx
  800718:	84 c9                	test   %cl,%cl
  80071a:	75 f5                	jne    800711 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80071c:	5b                   	pop    %ebx
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800726:	53                   	push   %ebx
  800727:	e8 84 ff ff ff       	call   8006b0 <strlen>
  80072c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800735:	50                   	push   %eax
  800736:	e8 c7 ff ff ff       	call   800702 <strcpy>
	return dst;
}
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	56                   	push   %esi
  800746:	53                   	push   %ebx
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800750:	85 f6                	test   %esi,%esi
  800752:	74 15                	je     800769 <strncpy+0x27>
  800754:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800759:	8a 1a                	mov    (%edx),%bl
  80075b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075e:	80 3a 01             	cmpb   $0x1,(%edx)
  800761:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	41                   	inc    %ecx
  800765:	39 ce                	cmp    %ecx,%esi
  800767:	77 f0                	ja     800759 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	57                   	push   %edi
  800771:	56                   	push   %esi
  800772:	53                   	push   %ebx
  800773:	8b 7d 08             	mov    0x8(%ebp),%edi
  800776:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800779:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077c:	85 f6                	test   %esi,%esi
  80077e:	74 32                	je     8007b2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800780:	83 fe 01             	cmp    $0x1,%esi
  800783:	74 22                	je     8007a7 <strlcpy+0x3a>
  800785:	8a 0b                	mov    (%ebx),%cl
  800787:	84 c9                	test   %cl,%cl
  800789:	74 20                	je     8007ab <strlcpy+0x3e>
  80078b:	89 f8                	mov    %edi,%eax
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800792:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800795:	88 08                	mov    %cl,(%eax)
  800797:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800798:	39 f2                	cmp    %esi,%edx
  80079a:	74 11                	je     8007ad <strlcpy+0x40>
  80079c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007a0:	42                   	inc    %edx
  8007a1:	84 c9                	test   %cl,%cl
  8007a3:	75 f0                	jne    800795 <strlcpy+0x28>
  8007a5:	eb 06                	jmp    8007ad <strlcpy+0x40>
  8007a7:	89 f8                	mov    %edi,%eax
  8007a9:	eb 02                	jmp    8007ad <strlcpy+0x40>
  8007ab:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 00 00             	movb   $0x0,(%eax)
  8007b0:	eb 02                	jmp    8007b4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007b4:	29 f8                	sub    %edi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5f                   	pop    %edi
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c4:	8a 01                	mov    (%ecx),%al
  8007c6:	84 c0                	test   %al,%al
  8007c8:	74 10                	je     8007da <strcmp+0x1f>
  8007ca:	3a 02                	cmp    (%edx),%al
  8007cc:	75 0c                	jne    8007da <strcmp+0x1f>
		p++, q++;
  8007ce:	41                   	inc    %ecx
  8007cf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d0:	8a 01                	mov    (%ecx),%al
  8007d2:	84 c0                	test   %al,%al
  8007d4:	74 04                	je     8007da <strcmp+0x1f>
  8007d6:	3a 02                	cmp    (%edx),%al
  8007d8:	74 f4                	je     8007ce <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007da:	0f b6 c0             	movzbl %al,%eax
  8007dd:	0f b6 12             	movzbl (%edx),%edx
  8007e0:	29 d0                	sub    %edx,%eax
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	74 1b                	je     800810 <strncmp+0x2c>
  8007f5:	8a 1a                	mov    (%edx),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	74 24                	je     80081f <strncmp+0x3b>
  8007fb:	3a 19                	cmp    (%ecx),%bl
  8007fd:	75 20                	jne    80081f <strncmp+0x3b>
  8007ff:	48                   	dec    %eax
  800800:	74 15                	je     800817 <strncmp+0x33>
		n--, p++, q++;
  800802:	42                   	inc    %edx
  800803:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800804:	8a 1a                	mov    (%edx),%bl
  800806:	84 db                	test   %bl,%bl
  800808:	74 15                	je     80081f <strncmp+0x3b>
  80080a:	3a 19                	cmp    (%ecx),%bl
  80080c:	74 f1                	je     8007ff <strncmp+0x1b>
  80080e:	eb 0f                	jmp    80081f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 05                	jmp    80081c <strncmp+0x38>
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081c:	5b                   	pop    %ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 02             	movzbl (%edx),%eax
  800822:	0f b6 11             	movzbl (%ecx),%edx
  800825:	29 d0                	sub    %edx,%eax
  800827:	eb f3                	jmp    80081c <strncmp+0x38>

00800829 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800832:	8a 10                	mov    (%eax),%dl
  800834:	84 d2                	test   %dl,%dl
  800836:	74 18                	je     800850 <strchr+0x27>
		if (*s == c)
  800838:	38 ca                	cmp    %cl,%dl
  80083a:	75 06                	jne    800842 <strchr+0x19>
  80083c:	eb 17                	jmp    800855 <strchr+0x2c>
  80083e:	38 ca                	cmp    %cl,%dl
  800840:	74 13                	je     800855 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800842:	40                   	inc    %eax
  800843:	8a 10                	mov    (%eax),%dl
  800845:	84 d2                	test   %dl,%dl
  800847:	75 f5                	jne    80083e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
  80084e:	eb 05                	jmp    800855 <strchr+0x2c>
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800860:	8a 10                	mov    (%eax),%dl
  800862:	84 d2                	test   %dl,%dl
  800864:	74 11                	je     800877 <strfind+0x20>
		if (*s == c)
  800866:	38 ca                	cmp    %cl,%dl
  800868:	75 06                	jne    800870 <strfind+0x19>
  80086a:	eb 0b                	jmp    800877 <strfind+0x20>
  80086c:	38 ca                	cmp    %cl,%dl
  80086e:	74 07                	je     800877 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800870:	40                   	inc    %eax
  800871:	8a 10                	mov    (%eax),%dl
  800873:	84 d2                	test   %dl,%dl
  800875:	75 f5                	jne    80086c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800882:	8b 45 0c             	mov    0xc(%ebp),%eax
  800885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 30                	je     8008bc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800892:	75 25                	jne    8008b9 <memset+0x40>
  800894:	f6 c1 03             	test   $0x3,%cl
  800897:	75 20                	jne    8008b9 <memset+0x40>
		c &= 0xFF;
  800899:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 d0                	or     %edx,%eax
  8008af:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b4:	fc                   	cld    
  8008b5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b7:	eb 03                	jmp    8008bc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b9:	fc                   	cld    
  8008ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bc:	89 f8                	mov    %edi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d1:	39 c6                	cmp    %eax,%esi
  8008d3:	73 34                	jae    800909 <memmove+0x46>
  8008d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d8:	39 d0                	cmp    %edx,%eax
  8008da:	73 2d                	jae    800909 <memmove+0x46>
		s += n;
		d += n;
  8008dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008df:	f6 c2 03             	test   $0x3,%dl
  8008e2:	75 1b                	jne    8008ff <memmove+0x3c>
  8008e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ea:	75 13                	jne    8008ff <memmove+0x3c>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 0e                	jne    8008ff <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f1:	83 ef 04             	sub    $0x4,%edi
  8008f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008fa:	fd                   	std    
  8008fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fd:	eb 07                	jmp    800906 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ff:	4f                   	dec    %edi
  800900:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	fd                   	std    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800906:	fc                   	cld    
  800907:	eb 20                	jmp    800929 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800909:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090f:	75 13                	jne    800924 <memmove+0x61>
  800911:	a8 03                	test   $0x3,%al
  800913:	75 0f                	jne    800924 <memmove+0x61>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 0a                	jne    800924 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb 05                	jmp    800929 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800924:	89 c7                	mov    %eax,%edi
  800926:	fc                   	cld    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800930:	ff 75 10             	pushl  0x10(%ebp)
  800933:	ff 75 0c             	pushl  0xc(%ebp)
  800936:	ff 75 08             	pushl  0x8(%ebp)
  800939:	e8 85 ff ff ff       	call   8008c3 <memmove>
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800949:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	85 ff                	test   %edi,%edi
  800951:	74 32                	je     800985 <memcmp+0x45>
		if (*s1 != *s2)
  800953:	8a 03                	mov    (%ebx),%al
  800955:	8a 0e                	mov    (%esi),%cl
  800957:	38 c8                	cmp    %cl,%al
  800959:	74 19                	je     800974 <memcmp+0x34>
  80095b:	eb 0d                	jmp    80096a <memcmp+0x2a>
  80095d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800961:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800965:	42                   	inc    %edx
  800966:	38 c8                	cmp    %cl,%al
  800968:	74 10                	je     80097a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80096a:	0f b6 c0             	movzbl %al,%eax
  80096d:	0f b6 c9             	movzbl %cl,%ecx
  800970:	29 c8                	sub    %ecx,%eax
  800972:	eb 16                	jmp    80098a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800974:	4f                   	dec    %edi
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	39 fa                	cmp    %edi,%edx
  80097c:	75 df                	jne    80095d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
  800983:	eb 05                	jmp    80098a <memcmp+0x4a>
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800995:	89 c2                	mov    %eax,%edx
  800997:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	73 12                	jae    8009b0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009a1:	38 08                	cmp    %cl,(%eax)
  8009a3:	75 06                	jne    8009ab <memfind+0x1c>
  8009a5:	eb 09                	jmp    8009b0 <memfind+0x21>
  8009a7:	38 08                	cmp    %cl,(%eax)
  8009a9:	74 05                	je     8009b0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ab:	40                   	inc    %eax
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	77 f7                	ja     8009a7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009be:	eb 01                	jmp    8009c1 <strtol+0xf>
		s++;
  8009c0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c1:	8a 02                	mov    (%edx),%al
  8009c3:	3c 20                	cmp    $0x20,%al
  8009c5:	74 f9                	je     8009c0 <strtol+0xe>
  8009c7:	3c 09                	cmp    $0x9,%al
  8009c9:	74 f5                	je     8009c0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cb:	3c 2b                	cmp    $0x2b,%al
  8009cd:	75 08                	jne    8009d7 <strtol+0x25>
		s++;
  8009cf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d5:	eb 13                	jmp    8009ea <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d7:	3c 2d                	cmp    $0x2d,%al
  8009d9:	75 0a                	jne    8009e5 <strtol+0x33>
		s++, neg = 1;
  8009db:	8d 52 01             	lea    0x1(%edx),%edx
  8009de:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e3:	eb 05                	jmp    8009ea <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ea:	85 db                	test   %ebx,%ebx
  8009ec:	74 05                	je     8009f3 <strtol+0x41>
  8009ee:	83 fb 10             	cmp    $0x10,%ebx
  8009f1:	75 28                	jne    800a1b <strtol+0x69>
  8009f3:	8a 02                	mov    (%edx),%al
  8009f5:	3c 30                	cmp    $0x30,%al
  8009f7:	75 10                	jne    800a09 <strtol+0x57>
  8009f9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009fd:	75 0a                	jne    800a09 <strtol+0x57>
		s += 2, base = 16;
  8009ff:	83 c2 02             	add    $0x2,%edx
  800a02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a07:	eb 12                	jmp    800a1b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	75 0e                	jne    800a1b <strtol+0x69>
  800a0d:	3c 30                	cmp    $0x30,%al
  800a0f:	75 05                	jne    800a16 <strtol+0x64>
		s++, base = 8;
  800a11:	42                   	inc    %edx
  800a12:	b3 08                	mov    $0x8,%bl
  800a14:	eb 05                	jmp    800a1b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a16:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a22:	8a 0a                	mov    (%edx),%cl
  800a24:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a27:	80 fb 09             	cmp    $0x9,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0x82>
			dig = *s - '0';
  800a2c:	0f be c9             	movsbl %cl,%ecx
  800a2f:	83 e9 30             	sub    $0x30,%ecx
  800a32:	eb 1e                	jmp    800a52 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a34:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a3c:	0f be c9             	movsbl %cl,%ecx
  800a3f:	83 e9 57             	sub    $0x57,%ecx
  800a42:	eb 0e                	jmp    800a52 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 13                	ja     800a5f <strtol+0xad>
			dig = *s - 'A' + 10;
  800a4c:	0f be c9             	movsbl %cl,%ecx
  800a4f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a52:	39 f1                	cmp    %esi,%ecx
  800a54:	7d 0d                	jge    800a63 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a56:	42                   	inc    %edx
  800a57:	0f af c6             	imul   %esi,%eax
  800a5a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb c3                	jmp    800a22 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a5f:	89 c1                	mov    %eax,%ecx
  800a61:	eb 02                	jmp    800a65 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a63:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a69:	74 05                	je     800a70 <strtol+0xbe>
		*endptr = (char *) s;
  800a6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a70:	85 ff                	test   %edi,%edi
  800a72:	74 04                	je     800a78 <strtol+0xc6>
  800a74:	89 c8                	mov    %ecx,%eax
  800a76:	f7 d8                	neg    %eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    
  800a7d:	00 00                	add    %al,(%eax)
	...

00800a80 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	83 ec 1c             	sub    $0x1c,%esp
  800a89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a8c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a8f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	8b 75 14             	mov    0x14(%ebp),%esi
  800a94:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9d:	cd 30                	int    $0x30
  800a9f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aa5:	74 1c                	je     800ac3 <syscall+0x43>
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	7e 18                	jle    800ac3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aab:	83 ec 0c             	sub    $0xc,%esp
  800aae:	50                   	push   %eax
  800aaf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ab2:	68 9f 20 80 00       	push   $0x80209f
  800ab7:	6a 42                	push   $0x42
  800ab9:	68 bc 20 80 00       	push   $0x8020bc
  800abe:	e8 b5 0e 00 00       	call   801978 <_panic>

	return ret;
}
  800ac3:	89 d0                	mov    %edx,%eax
  800ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ad3:	6a 00                	push   $0x0
  800ad5:	6a 00                	push   $0x0
  800ad7:	6a 00                	push   $0x0
  800ad9:	ff 75 0c             	pushl  0xc(%ebp)
  800adc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	e8 92 ff ff ff       	call   800a80 <syscall>
  800aee:	83 c4 10             	add    $0x10,%esp
	return;
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800af9:	6a 00                	push   $0x0
  800afb:	6a 00                	push   $0x0
  800afd:	6a 00                	push   $0x0
  800aff:	6a 00                	push   $0x0
  800b01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b10:	e8 6b ff ff ff       	call   800a80 <syscall>
}
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b28:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b32:	e8 49 ff ff ff       	call   800a80 <syscall>
}
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b3f:	6a 00                	push   $0x0
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 02 00 00 00       	mov    $0x2,%eax
  800b56:	e8 25 ff ff ff       	call   800a80 <syscall>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7a:	e8 01 ff ff ff       	call   800a80 <syscall>
  800b7f:	83 c4 10             	add    $0x10,%esp
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b8a:	6a 00                	push   $0x0
  800b8c:	6a 00                	push   $0x0
  800b8e:	ff 75 10             	pushl  0x10(%ebp)
  800b91:	ff 75 0c             	pushl  0xc(%ebp)
  800b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b97:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba1:	e8 da fe ff ff       	call   800a80 <syscall>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bae:	ff 75 18             	pushl  0x18(%ebp)
  800bb1:	ff 75 14             	pushl  0x14(%ebp)
  800bb4:	ff 75 10             	pushl  0x10(%ebp)
  800bb7:	ff 75 0c             	pushl  0xc(%ebp)
  800bba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbd:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	e8 b4 fe ff ff       	call   800a80 <syscall>
}
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bd4:	6a 00                	push   $0x0
  800bd6:	6a 00                	push   $0x0
  800bd8:	6a 00                	push   $0x0
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be0:	ba 01 00 00 00       	mov    $0x1,%edx
  800be5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bea:	e8 91 fe ff ff       	call   800a80 <syscall>
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	ff 75 0c             	pushl  0xc(%ebp)
  800c00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c03:	ba 01 00 00 00       	mov    $0x1,%edx
  800c08:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0d:	e8 6e fe ff ff       	call   800a80 <syscall>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c1a:	6a 00                	push   $0x0
  800c1c:	6a 00                	push   $0x0
  800c1e:	6a 00                	push   $0x0
  800c20:	ff 75 0c             	pushl  0xc(%ebp)
  800c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c26:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c30:	e8 4b fe ff ff       	call   800a80 <syscall>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c3d:	6a 00                	push   $0x0
  800c3f:	6a 00                	push   $0x0
  800c41:	6a 00                	push   $0x0
  800c43:	ff 75 0c             	pushl  0xc(%ebp)
  800c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c49:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c53:	e8 28 fe ff ff       	call   800a80 <syscall>
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c60:	6a 00                	push   $0x0
  800c62:	ff 75 14             	pushl  0x14(%ebp)
  800c65:	ff 75 10             	pushl  0x10(%ebp)
  800c68:	ff 75 0c             	pushl  0xc(%ebp)
  800c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c78:	e8 03 fe ff ff       	call   800a80 <syscall>
}
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	6a 00                	push   $0x0
  800c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c90:	ba 01 00 00 00       	mov    $0x1,%edx
  800c95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9a:	e8 e1 fd ff ff       	call   800a80 <syscall>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ca7:	6a 00                	push   $0x0
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cbd:	e8 be fd ff ff       	call   800a80 <syscall>
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	05 00 00 00 30       	add    $0x30000000,%eax
  800ccf:	c1 e8 0c             	shr    $0xc,%eax
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cd7:	ff 75 08             	pushl  0x8(%ebp)
  800cda:	e8 e5 ff ff ff       	call   800cc4 <fd2num>
  800cdf:	83 c4 04             	add    $0x4,%esp
  800ce2:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ce7:	c1 e0 0c             	shl    $0xc,%eax
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	53                   	push   %ebx
  800cf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cf3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800cf8:	a8 01                	test   $0x1,%al
  800cfa:	74 34                	je     800d30 <fd_alloc+0x44>
  800cfc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d01:	a8 01                	test   $0x1,%al
  800d03:	74 32                	je     800d37 <fd_alloc+0x4b>
  800d05:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d0a:	89 c1                	mov    %eax,%ecx
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	c1 ea 16             	shr    $0x16,%edx
  800d11:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d18:	f6 c2 01             	test   $0x1,%dl
  800d1b:	74 1f                	je     800d3c <fd_alloc+0x50>
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	c1 ea 0c             	shr    $0xc,%edx
  800d22:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d29:	f6 c2 01             	test   $0x1,%dl
  800d2c:	75 17                	jne    800d45 <fd_alloc+0x59>
  800d2e:	eb 0c                	jmp    800d3c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d30:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d35:	eb 05                	jmp    800d3c <fd_alloc+0x50>
  800d37:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d3c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	eb 17                	jmp    800d5c <fd_alloc+0x70>
  800d45:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d4a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d4f:	75 b9                	jne    800d0a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d51:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800d57:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d5c:	5b                   	pop    %ebx
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d65:	83 f8 1f             	cmp    $0x1f,%eax
  800d68:	77 36                	ja     800da0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d6a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800d6f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	c1 ea 16             	shr    $0x16,%edx
  800d77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d7e:	f6 c2 01             	test   $0x1,%dl
  800d81:	74 24                	je     800da7 <fd_lookup+0x48>
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	c1 ea 0c             	shr    $0xc,%edx
  800d88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d8f:	f6 c2 01             	test   $0x1,%dl
  800d92:	74 1a                	je     800dae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d97:	89 02                	mov    %eax,(%edx)
	return 0;
  800d99:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9e:	eb 13                	jmp    800db3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da5:	eb 0c                	jmp    800db3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dac:	eb 05                	jmp    800db3 <fd_lookup+0x54>
  800dae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	53                   	push   %ebx
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800dc2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800dc8:	74 0d                	je     800dd7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dca:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcf:	eb 14                	jmp    800de5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800dd1:	39 0a                	cmp    %ecx,(%edx)
  800dd3:	75 10                	jne    800de5 <dev_lookup+0x30>
  800dd5:	eb 05                	jmp    800ddc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dd7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ddc:	89 13                	mov    %edx,(%ebx)
			return 0;
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
  800de3:	eb 31                	jmp    800e16 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800de5:	40                   	inc    %eax
  800de6:	8b 14 85 48 21 80 00 	mov    0x802148(,%eax,4),%edx
  800ded:	85 d2                	test   %edx,%edx
  800def:	75 e0                	jne    800dd1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df1:	a1 04 40 80 00       	mov    0x804004,%eax
  800df6:	8b 40 48             	mov    0x48(%eax),%eax
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	51                   	push   %ecx
  800dfd:	50                   	push   %eax
  800dfe:	68 cc 20 80 00       	push   $0x8020cc
  800e03:	e8 44 f3 ff ff       	call   80014c <cprintf>
	*dev = 0;
  800e08:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 20             	sub    $0x20,%esp
  800e23:	8b 75 08             	mov    0x8(%ebp),%esi
  800e26:	8a 45 0c             	mov    0xc(%ebp),%al
  800e29:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e2c:	56                   	push   %esi
  800e2d:	e8 92 fe ff ff       	call   800cc4 <fd2num>
  800e32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e35:	89 14 24             	mov    %edx,(%esp)
  800e38:	50                   	push   %eax
  800e39:	e8 21 ff ff ff       	call   800d5f <fd_lookup>
  800e3e:	89 c3                	mov    %eax,%ebx
  800e40:	83 c4 08             	add    $0x8,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 05                	js     800e4c <fd_close+0x31>
	    || fd != fd2)
  800e47:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4a:	74 0d                	je     800e59 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e4c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e50:	75 48                	jne    800e9a <fd_close+0x7f>
  800e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e57:	eb 41                	jmp    800e9a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e5f:	50                   	push   %eax
  800e60:	ff 36                	pushl  (%esi)
  800e62:	e8 4e ff ff ff       	call   800db5 <dev_lookup>
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	78 1c                	js     800e8c <fd_close+0x71>
		if (dev->dev_close)
  800e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e73:	8b 40 10             	mov    0x10(%eax),%eax
  800e76:	85 c0                	test   %eax,%eax
  800e78:	74 0d                	je     800e87 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	56                   	push   %esi
  800e7e:	ff d0                	call   *%eax
  800e80:	89 c3                	mov    %eax,%ebx
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	eb 05                	jmp    800e8c <fd_close+0x71>
		else
			r = 0;
  800e87:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8c:	83 ec 08             	sub    $0x8,%esp
  800e8f:	56                   	push   %esi
  800e90:	6a 00                	push   $0x0
  800e92:	e8 37 fd ff ff       	call   800bce <sys_page_unmap>
	return r;
  800e97:	83 c4 10             	add    $0x10,%esp
}
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eac:	50                   	push   %eax
  800ead:	ff 75 08             	pushl  0x8(%ebp)
  800eb0:	e8 aa fe ff ff       	call   800d5f <fd_lookup>
  800eb5:	83 c4 08             	add    $0x8,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 10                	js     800ecc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	6a 01                	push   $0x1
  800ec1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec4:	e8 52 ff ff ff       	call   800e1b <fd_close>
  800ec9:	83 c4 10             	add    $0x10,%esp
}
  800ecc:	c9                   	leave  
  800ecd:	c3                   	ret    

00800ece <close_all>:

void
close_all(void)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	53                   	push   %ebx
  800ed2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	53                   	push   %ebx
  800ede:	e8 c0 ff ff ff       	call   800ea3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee3:	43                   	inc    %ebx
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	83 fb 20             	cmp    $0x20,%ebx
  800eea:	75 ee                	jne    800eda <close_all+0xc>
		close(i);
}
  800eec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 2c             	sub    $0x2c,%esp
  800efa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800efd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	ff 75 08             	pushl  0x8(%ebp)
  800f04:	e8 56 fe ff ff       	call   800d5f <fd_lookup>
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	83 c4 08             	add    $0x8,%esp
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	0f 88 c0 00 00 00    	js     800fd6 <dup+0xe5>
		return r;
	close(newfdnum);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	57                   	push   %edi
  800f1a:	e8 84 ff ff ff       	call   800ea3 <close>

	newfd = INDEX2FD(newfdnum);
  800f1f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f25:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f28:	83 c4 04             	add    $0x4,%esp
  800f2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2e:	e8 a1 fd ff ff       	call   800cd4 <fd2data>
  800f33:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f35:	89 34 24             	mov    %esi,(%esp)
  800f38:	e8 97 fd ff ff       	call   800cd4 <fd2data>
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f43:	89 d8                	mov    %ebx,%eax
  800f45:	c1 e8 16             	shr    $0x16,%eax
  800f48:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4f:	a8 01                	test   $0x1,%al
  800f51:	74 37                	je     800f8a <dup+0x99>
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 0c             	shr    $0xc,%eax
  800f58:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	74 26                	je     800f8a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f77:	6a 00                	push   $0x0
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 27 fc ff ff       	call   800ba8 <sys_page_map>
  800f81:	89 c3                	mov    %eax,%ebx
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 2d                	js     800fb7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f8d:	89 c2                	mov    %eax,%edx
  800f8f:	c1 ea 0c             	shr    $0xc,%edx
  800f92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fa2:	52                   	push   %edx
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	50                   	push   %eax
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 fa fb ff ff       	call   800ba8 <sys_page_map>
  800fae:	89 c3                	mov    %eax,%ebx
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 1d                	jns    800fd4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	56                   	push   %esi
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 0c fc ff ff       	call   800bce <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 ff fb ff ff       	call   800bce <sys_page_unmap>
	return r;
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	eb 02                	jmp    800fd6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800fd4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 14             	sub    $0x14,%esp
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	53                   	push   %ebx
  800fef:	e8 6b fd ff ff       	call   800d5f <fd_lookup>
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 67                	js     801062 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801005:	ff 30                	pushl  (%eax)
  801007:	e8 a9 fd ff ff       	call   800db5 <dev_lookup>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 4f                	js     801062 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801016:	8b 50 08             	mov    0x8(%eax),%edx
  801019:	83 e2 03             	and    $0x3,%edx
  80101c:	83 fa 01             	cmp    $0x1,%edx
  80101f:	75 21                	jne    801042 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801021:	a1 04 40 80 00       	mov    0x804004,%eax
  801026:	8b 40 48             	mov    0x48(%eax),%eax
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	53                   	push   %ebx
  80102d:	50                   	push   %eax
  80102e:	68 0d 21 80 00       	push   $0x80210d
  801033:	e8 14 f1 ff ff       	call   80014c <cprintf>
		return -E_INVAL;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801040:	eb 20                	jmp    801062 <read+0x82>
	}
	if (!dev->dev_read)
  801042:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801045:	8b 52 08             	mov    0x8(%edx),%edx
  801048:	85 d2                	test   %edx,%edx
  80104a:	74 11                	je     80105d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	ff 75 10             	pushl  0x10(%ebp)
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	50                   	push   %eax
  801056:	ff d2                	call   *%edx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	eb 05                	jmp    801062 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80105d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801062:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	57                   	push   %edi
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	8b 7d 08             	mov    0x8(%ebp),%edi
  801073:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801076:	85 f6                	test   %esi,%esi
  801078:	74 31                	je     8010ab <readn+0x44>
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	89 f2                	mov    %esi,%edx
  801089:	29 c2                	sub    %eax,%edx
  80108b:	52                   	push   %edx
  80108c:	03 45 0c             	add    0xc(%ebp),%eax
  80108f:	50                   	push   %eax
  801090:	57                   	push   %edi
  801091:	e8 4a ff ff ff       	call   800fe0 <read>
		if (m < 0)
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 17                	js     8010b4 <readn+0x4d>
			return m;
		if (m == 0)
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 11                	je     8010b2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a1:	01 c3                	add    %eax,%ebx
  8010a3:	89 d8                	mov    %ebx,%eax
  8010a5:	39 f3                	cmp    %esi,%ebx
  8010a7:	72 db                	jb     801084 <readn+0x1d>
  8010a9:	eb 09                	jmp    8010b4 <readn+0x4d>
  8010ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b0:	eb 02                	jmp    8010b4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010b2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 14             	sub    $0x14,%esp
  8010c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	53                   	push   %ebx
  8010cb:	e8 8f fc ff ff       	call   800d5f <fd_lookup>
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 62                	js     801139 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e1:	ff 30                	pushl  (%eax)
  8010e3:	e8 cd fc ff ff       	call   800db5 <dev_lookup>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 4a                	js     801139 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f6:	75 21                	jne    801119 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fd:	8b 40 48             	mov    0x48(%eax),%eax
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	53                   	push   %ebx
  801104:	50                   	push   %eax
  801105:	68 29 21 80 00       	push   $0x802129
  80110a:	e8 3d f0 ff ff       	call   80014c <cprintf>
		return -E_INVAL;
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801117:	eb 20                	jmp    801139 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801119:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111c:	8b 52 0c             	mov    0xc(%edx),%edx
  80111f:	85 d2                	test   %edx,%edx
  801121:	74 11                	je     801134 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	ff 75 10             	pushl  0x10(%ebp)
  801129:	ff 75 0c             	pushl  0xc(%ebp)
  80112c:	50                   	push   %eax
  80112d:	ff d2                	call   *%edx
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	eb 05                	jmp    801139 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801134:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801139:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <seek>:

int
seek(int fdnum, off_t offset)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801144:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	ff 75 08             	pushl  0x8(%ebp)
  80114b:	e8 0f fc ff ff       	call   800d5f <fd_lookup>
  801150:	83 c4 08             	add    $0x8,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 0e                	js     801165 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801157:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80115a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	53                   	push   %ebx
  80116b:	83 ec 14             	sub    $0x14,%esp
  80116e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801171:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801174:	50                   	push   %eax
  801175:	53                   	push   %ebx
  801176:	e8 e4 fb ff ff       	call   800d5f <fd_lookup>
  80117b:	83 c4 08             	add    $0x8,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 5f                	js     8011e1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801188:	50                   	push   %eax
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	ff 30                	pushl  (%eax)
  80118e:	e8 22 fc ff ff       	call   800db5 <dev_lookup>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 47                	js     8011e1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a1:	75 21                	jne    8011c4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011a3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011a8:	8b 40 48             	mov    0x48(%eax),%eax
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	53                   	push   %ebx
  8011af:	50                   	push   %eax
  8011b0:	68 ec 20 80 00       	push   $0x8020ec
  8011b5:	e8 92 ef ff ff       	call   80014c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c2:	eb 1d                	jmp    8011e1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8011c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c7:	8b 52 18             	mov    0x18(%edx),%edx
  8011ca:	85 d2                	test   %edx,%edx
  8011cc:	74 0e                	je     8011dc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	50                   	push   %eax
  8011d5:	ff d2                	call   *%edx
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	eb 05                	jmp    8011e1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8011e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 14             	sub    $0x14,%esp
  8011ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 08             	pushl  0x8(%ebp)
  8011f7:	e8 63 fb ff ff       	call   800d5f <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 52                	js     801255 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	ff 30                	pushl  (%eax)
  80120f:	e8 a1 fb ff ff       	call   800db5 <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 3a                	js     801255 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80121b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801222:	74 2c                	je     801250 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801224:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801227:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80122e:	00 00 00 
	stat->st_isdir = 0;
  801231:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801238:	00 00 00 
	stat->st_dev = dev;
  80123b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	53                   	push   %ebx
  801245:	ff 75 f0             	pushl  -0x10(%ebp)
  801248:	ff 50 14             	call   *0x14(%eax)
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	eb 05                	jmp    801255 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801250:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	6a 00                	push   $0x0
  801264:	ff 75 08             	pushl  0x8(%ebp)
  801267:	e8 78 01 00 00       	call   8013e4 <open>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 1b                	js     801290 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	50                   	push   %eax
  80127c:	e8 65 ff ff ff       	call   8011e6 <fstat>
  801281:	89 c6                	mov    %eax,%esi
	close(fd);
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	e8 18 fc ff ff       	call   800ea3 <close>
	return r;
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	89 f3                	mov    %esi,%ebx
}
  801290:	89 d8                	mov    %ebx,%eax
  801292:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	c9                   	leave  
  801298:	c3                   	ret    
  801299:	00 00                	add    %al,(%eax)
	...

0080129c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ac:	75 12                	jne    8012c0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	6a 01                	push   $0x1
  8012b3:	e8 d2 07 00 00       	call   801a8a <ipc_find_env>
  8012b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8012bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012c0:	6a 07                	push   $0x7
  8012c2:	68 00 50 80 00       	push   $0x805000
  8012c7:	53                   	push   %ebx
  8012c8:	ff 35 00 40 80 00    	pushl  0x804000
  8012ce:	e8 62 07 00 00       	call   801a35 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8012d3:	83 c4 0c             	add    $0xc,%esp
  8012d6:	6a 00                	push   $0x0
  8012d8:	56                   	push   %esi
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 e0 06 00 00       	call   8019c0 <ipc_recv>
}
  8012e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8012f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8012fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801301:	b8 05 00 00 00       	mov    $0x5,%eax
  801306:	e8 91 ff ff ff       	call   80129c <fsipc>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 2c                	js     80133b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	68 00 50 80 00       	push   $0x805000
  801317:	53                   	push   %ebx
  801318:	e8 e5 f3 ff ff       	call   800702 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80131d:	a1 80 50 80 00       	mov    0x805080,%eax
  801322:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801328:	a1 84 50 80 00       	mov    0x805084,%eax
  80132d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801346:	8b 45 08             	mov    0x8(%ebp),%eax
  801349:	8b 40 0c             	mov    0xc(%eax),%eax
  80134c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	b8 06 00 00 00       	mov    $0x6,%eax
  80135b:	e8 3c ff ff ff       	call   80129c <fsipc>
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	8b 40 0c             	mov    0xc(%eax),%eax
  801370:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801375:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80137b:	ba 00 00 00 00       	mov    $0x0,%edx
  801380:	b8 03 00 00 00       	mov    $0x3,%eax
  801385:	e8 12 ff ff ff       	call   80129c <fsipc>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 4b                	js     8013db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801390:	39 c6                	cmp    %eax,%esi
  801392:	73 16                	jae    8013aa <devfile_read+0x48>
  801394:	68 58 21 80 00       	push   $0x802158
  801399:	68 5f 21 80 00       	push   $0x80215f
  80139e:	6a 7d                	push   $0x7d
  8013a0:	68 74 21 80 00       	push   $0x802174
  8013a5:	e8 ce 05 00 00       	call   801978 <_panic>
	assert(r <= PGSIZE);
  8013aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013af:	7e 16                	jle    8013c7 <devfile_read+0x65>
  8013b1:	68 7f 21 80 00       	push   $0x80217f
  8013b6:	68 5f 21 80 00       	push   $0x80215f
  8013bb:	6a 7e                	push   $0x7e
  8013bd:	68 74 21 80 00       	push   $0x802174
  8013c2:	e8 b1 05 00 00       	call   801978 <_panic>
	memmove(buf, &fsipcbuf, r);
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	50                   	push   %eax
  8013cb:	68 00 50 80 00       	push   $0x805000
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	e8 eb f4 ff ff       	call   8008c3 <memmove>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
}
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 1c             	sub    $0x1c,%esp
  8013ec:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8013ef:	56                   	push   %esi
  8013f0:	e8 bb f2 ff ff       	call   8006b0 <strlen>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8013fd:	7f 65                	jg     801464 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 e1 f8 ff ff       	call   800cec <fd_alloc>
  80140b:	89 c3                	mov    %eax,%ebx
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 55                	js     801469 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	56                   	push   %esi
  801418:	68 00 50 80 00       	push   $0x805000
  80141d:	e8 e0 f2 ff ff       	call   800702 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80142a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142d:	b8 01 00 00 00       	mov    $0x1,%eax
  801432:	e8 65 fe ff ff       	call   80129c <fsipc>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	79 12                	jns    801452 <open+0x6e>
		fd_close(fd, 0);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	6a 00                	push   $0x0
  801445:	ff 75 f4             	pushl  -0xc(%ebp)
  801448:	e8 ce f9 ff ff       	call   800e1b <fd_close>
		return r;
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	eb 17                	jmp    801469 <open+0x85>
	}

	return fd2num(fd);
  801452:	83 ec 0c             	sub    $0xc,%esp
  801455:	ff 75 f4             	pushl  -0xc(%ebp)
  801458:	e8 67 f8 ff ff       	call   800cc4 <fd2num>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb 05                	jmp    801469 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801464:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801469:	89 d8                	mov    %ebx,%eax
  80146b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	c9                   	leave  
  801471:	c3                   	ret    
	...

00801474 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	ff 75 08             	pushl  0x8(%ebp)
  801482:	e8 4d f8 ff ff       	call   800cd4 <fd2data>
  801487:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801489:	83 c4 08             	add    $0x8,%esp
  80148c:	68 8b 21 80 00       	push   $0x80218b
  801491:	56                   	push   %esi
  801492:	e8 6b f2 ff ff       	call   800702 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801497:	8b 43 04             	mov    0x4(%ebx),%eax
  80149a:	2b 03                	sub    (%ebx),%eax
  80149c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014a2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014a9:	00 00 00 
	stat->st_dev = &devpipe;
  8014ac:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014b3:	30 80 00 
	return 0;
}
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8014cc:	53                   	push   %ebx
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 fa f6 ff ff       	call   800bce <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8014d4:	89 1c 24             	mov    %ebx,(%esp)
  8014d7:	e8 f8 f7 ff ff       	call   800cd4 <fd2data>
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	50                   	push   %eax
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 e7 f6 ff ff       	call   800bce <sys_page_unmap>
}
  8014e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	57                   	push   %edi
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 1c             	sub    $0x1c,%esp
  8014f5:	89 c7                	mov    %eax,%edi
  8014f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8014fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ff:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	57                   	push   %edi
  801506:	e8 dd 05 00 00       	call   801ae8 <pageref>
  80150b:	89 c6                	mov    %eax,%esi
  80150d:	83 c4 04             	add    $0x4,%esp
  801510:	ff 75 e4             	pushl  -0x1c(%ebp)
  801513:	e8 d0 05 00 00       	call   801ae8 <pageref>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	39 c6                	cmp    %eax,%esi
  80151d:	0f 94 c0             	sete   %al
  801520:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801523:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801529:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80152c:	39 cb                	cmp    %ecx,%ebx
  80152e:	75 08                	jne    801538 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801530:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	c9                   	leave  
  801537:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801538:	83 f8 01             	cmp    $0x1,%eax
  80153b:	75 bd                	jne    8014fa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80153d:	8b 42 58             	mov    0x58(%edx),%eax
  801540:	6a 01                	push   $0x1
  801542:	50                   	push   %eax
  801543:	53                   	push   %ebx
  801544:	68 92 21 80 00       	push   $0x802192
  801549:	e8 fe eb ff ff       	call   80014c <cprintf>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb a7                	jmp    8014fa <_pipeisclosed+0xe>

00801553 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	57                   	push   %edi
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	83 ec 28             	sub    $0x28,%esp
  80155c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80155f:	56                   	push   %esi
  801560:	e8 6f f7 ff ff       	call   800cd4 <fd2data>
  801565:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80156e:	75 4a                	jne    8015ba <devpipe_write+0x67>
  801570:	bf 00 00 00 00       	mov    $0x0,%edi
  801575:	eb 56                	jmp    8015cd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801577:	89 da                	mov    %ebx,%edx
  801579:	89 f0                	mov    %esi,%eax
  80157b:	e8 6c ff ff ff       	call   8014ec <_pipeisclosed>
  801580:	85 c0                	test   %eax,%eax
  801582:	75 4d                	jne    8015d1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801584:	e8 d4 f5 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801589:	8b 43 04             	mov    0x4(%ebx),%eax
  80158c:	8b 13                	mov    (%ebx),%edx
  80158e:	83 c2 20             	add    $0x20,%edx
  801591:	39 d0                	cmp    %edx,%eax
  801593:	73 e2                	jae    801577 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801595:	89 c2                	mov    %eax,%edx
  801597:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80159d:	79 05                	jns    8015a4 <devpipe_write+0x51>
  80159f:	4a                   	dec    %edx
  8015a0:	83 ca e0             	or     $0xffffffe0,%edx
  8015a3:	42                   	inc    %edx
  8015a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015ae:	40                   	inc    %eax
  8015af:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015b2:	47                   	inc    %edi
  8015b3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8015b6:	77 07                	ja     8015bf <devpipe_write+0x6c>
  8015b8:	eb 13                	jmp    8015cd <devpipe_write+0x7a>
  8015ba:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8015c2:	8b 13                	mov    (%ebx),%edx
  8015c4:	83 c2 20             	add    $0x20,%edx
  8015c7:	39 d0                	cmp    %edx,%eax
  8015c9:	73 ac                	jae    801577 <devpipe_write+0x24>
  8015cb:	eb c8                	jmp    801595 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8015cd:	89 f8                	mov    %edi,%eax
  8015cf:	eb 05                	jmp    8015d6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8015d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	57                   	push   %edi
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 18             	sub    $0x18,%esp
  8015e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8015ea:	57                   	push   %edi
  8015eb:	e8 e4 f6 ff ff       	call   800cd4 <fd2data>
  8015f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015f9:	75 44                	jne    80163f <devpipe_read+0x61>
  8015fb:	be 00 00 00 00       	mov    $0x0,%esi
  801600:	eb 4f                	jmp    801651 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801602:	89 f0                	mov    %esi,%eax
  801604:	eb 54                	jmp    80165a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801606:	89 da                	mov    %ebx,%edx
  801608:	89 f8                	mov    %edi,%eax
  80160a:	e8 dd fe ff ff       	call   8014ec <_pipeisclosed>
  80160f:	85 c0                	test   %eax,%eax
  801611:	75 42                	jne    801655 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801613:	e8 45 f5 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801618:	8b 03                	mov    (%ebx),%eax
  80161a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80161d:	74 e7                	je     801606 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80161f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801624:	79 05                	jns    80162b <devpipe_read+0x4d>
  801626:	48                   	dec    %eax
  801627:	83 c8 e0             	or     $0xffffffe0,%eax
  80162a:	40                   	inc    %eax
  80162b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80162f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801632:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801635:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801637:	46                   	inc    %esi
  801638:	39 75 10             	cmp    %esi,0x10(%ebp)
  80163b:	77 07                	ja     801644 <devpipe_read+0x66>
  80163d:	eb 12                	jmp    801651 <devpipe_read+0x73>
  80163f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801644:	8b 03                	mov    (%ebx),%eax
  801646:	3b 43 04             	cmp    0x4(%ebx),%eax
  801649:	75 d4                	jne    80161f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80164b:	85 f6                	test   %esi,%esi
  80164d:	75 b3                	jne    801602 <devpipe_read+0x24>
  80164f:	eb b5                	jmp    801606 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801651:	89 f0                	mov    %esi,%eax
  801653:	eb 05                	jmp    80165a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 28             	sub    $0x28,%esp
  80166b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80166e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	e8 75 f6 ff ff       	call   800cec <fd_alloc>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	0f 88 24 01 00 00    	js     8017a8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	68 07 04 00 00       	push   $0x407
  80168c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168f:	6a 00                	push   $0x0
  801691:	e8 ee f4 ff ff       	call   800b84 <sys_page_alloc>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	0f 88 05 01 00 00    	js     8017a8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	e8 3d f6 ff ff       	call   800cec <fd_alloc>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	0f 88 dc 00 00 00    	js     801798 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	68 07 04 00 00       	push   $0x407
  8016c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 b6 f4 ff ff       	call   800b84 <sys_page_alloc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 bd 00 00 00    	js     801798 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e1:	e8 ee f5 ff ff       	call   800cd4 <fd2data>
  8016e6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e8:	83 c4 0c             	add    $0xc,%esp
  8016eb:	68 07 04 00 00       	push   $0x407
  8016f0:	50                   	push   %eax
  8016f1:	6a 00                	push   $0x0
  8016f3:	e8 8c f4 ff ff       	call   800b84 <sys_page_alloc>
  8016f8:	89 c3                	mov    %eax,%ebx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	0f 88 83 00 00 00    	js     801788 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801705:	83 ec 0c             	sub    $0xc,%esp
  801708:	ff 75 e0             	pushl  -0x20(%ebp)
  80170b:	e8 c4 f5 ff ff       	call   800cd4 <fd2data>
  801710:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801717:	50                   	push   %eax
  801718:	6a 00                	push   $0x0
  80171a:	56                   	push   %esi
  80171b:	6a 00                	push   $0x0
  80171d:	e8 86 f4 ff ff       	call   800ba8 <sys_page_map>
  801722:	89 c3                	mov    %eax,%ebx
  801724:	83 c4 20             	add    $0x20,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 4f                	js     80177a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80172b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801734:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801739:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801740:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801746:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801749:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80174b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80174e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175b:	e8 64 f5 ff ff       	call   800cc4 <fd2num>
  801760:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801762:	83 c4 04             	add    $0x4,%esp
  801765:	ff 75 e0             	pushl  -0x20(%ebp)
  801768:	e8 57 f5 ff ff       	call   800cc4 <fd2num>
  80176d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	bb 00 00 00 00       	mov    $0x0,%ebx
  801778:	eb 2e                	jmp    8017a8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	56                   	push   %esi
  80177e:	6a 00                	push   $0x0
  801780:	e8 49 f4 ff ff       	call   800bce <sys_page_unmap>
  801785:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	ff 75 e0             	pushl  -0x20(%ebp)
  80178e:	6a 00                	push   $0x0
  801790:	e8 39 f4 ff ff       	call   800bce <sys_page_unmap>
  801795:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80179e:	6a 00                	push   $0x0
  8017a0:	e8 29 f4 ff ff       	call   800bce <sys_page_unmap>
  8017a5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017a8:	89 d8                	mov    %ebx,%eax
  8017aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ad:	5b                   	pop    %ebx
  8017ae:	5e                   	pop    %esi
  8017af:	5f                   	pop    %edi
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bb:	50                   	push   %eax
  8017bc:	ff 75 08             	pushl  0x8(%ebp)
  8017bf:	e8 9b f5 ff ff       	call   800d5f <fd_lookup>
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 18                	js     8017e3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d1:	e8 fe f4 ff ff       	call   800cd4 <fd2data>
	return _pipeisclosed(fd, p);
  8017d6:	89 c2                	mov    %eax,%edx
  8017d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017db:	e8 0c fd ff ff       	call   8014ec <_pipeisclosed>
  8017e0:	83 c4 10             	add    $0x10,%esp
}
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    
  8017e5:	00 00                	add    %al,(%eax)
	...

008017e8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8017eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8017f8:	68 aa 21 80 00       	push   $0x8021aa
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	e8 fd ee ff ff       	call   800702 <strcpy>
	return 0;
}
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801818:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80181c:	74 45                	je     801863 <devcons_write+0x57>
  80181e:	b8 00 00 00 00       	mov    $0x0,%eax
  801823:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801828:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80182e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801831:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801833:	83 fb 7f             	cmp    $0x7f,%ebx
  801836:	76 05                	jbe    80183d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801838:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	53                   	push   %ebx
  801841:	03 45 0c             	add    0xc(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	57                   	push   %edi
  801846:	e8 78 f0 ff ff       	call   8008c3 <memmove>
		sys_cputs(buf, m);
  80184b:	83 c4 08             	add    $0x8,%esp
  80184e:	53                   	push   %ebx
  80184f:	57                   	push   %edi
  801850:	e8 78 f2 ff ff       	call   800acd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801855:	01 de                	add    %ebx,%esi
  801857:	89 f0                	mov    %esi,%eax
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80185f:	72 cd                	jb     80182e <devcons_write+0x22>
  801861:	eb 05                	jmp    801868 <devcons_write+0x5c>
  801863:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801868:	89 f0                	mov    %esi,%eax
  80186a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801878:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80187c:	75 07                	jne    801885 <devcons_read+0x13>
  80187e:	eb 25                	jmp    8018a5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801880:	e8 d8 f2 ff ff       	call   800b5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801885:	e8 69 f2 ff ff       	call   800af3 <sys_cgetc>
  80188a:	85 c0                	test   %eax,%eax
  80188c:	74 f2                	je     801880 <devcons_read+0xe>
  80188e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801890:	85 c0                	test   %eax,%eax
  801892:	78 1d                	js     8018b1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801894:	83 f8 04             	cmp    $0x4,%eax
  801897:	74 13                	je     8018ac <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189c:	88 10                	mov    %dl,(%eax)
	return 1;
  80189e:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a3:	eb 0c                	jmp    8018b1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018aa:	eb 05                	jmp    8018b1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018bf:	6a 01                	push   $0x1
  8018c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018c4:	50                   	push   %eax
  8018c5:	e8 03 f2 ff ff       	call   800acd <sys_cputs>
  8018ca:	83 c4 10             	add    $0x10,%esp
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <getchar>:

int
getchar(void)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018d5:	6a 01                	push   $0x1
  8018d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 fe f6 ff ff       	call   800fe0 <read>
	if (r < 0)
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 0f                	js     8018f8 <getchar+0x29>
		return r;
	if (r < 1)
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	7e 06                	jle    8018f3 <getchar+0x24>
		return -E_EOF;
	return c;
  8018ed:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8018f1:	eb 05                	jmp    8018f8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8018f3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801903:	50                   	push   %eax
  801904:	ff 75 08             	pushl  0x8(%ebp)
  801907:	e8 53 f4 ff ff       	call   800d5f <fd_lookup>
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 11                	js     801924 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80191c:	39 10                	cmp    %edx,(%eax)
  80191e:	0f 94 c0             	sete   %al
  801921:	0f b6 c0             	movzbl %al,%eax
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <opencons>:

int
opencons(void)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	e8 b7 f3 ff ff       	call   800cec <fd_alloc>
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 3a                	js     801976 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	68 07 04 00 00       	push   $0x407
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 36 f2 ff ff       	call   800b84 <sys_page_alloc>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 21                	js     801976 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801955:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80195b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	50                   	push   %eax
  80196e:	e8 51 f3 ff ff       	call   800cc4 <fd2num>
  801973:	83 c4 10             	add    $0x10,%esp
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80197d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801980:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801986:	e8 ae f1 ff ff       	call   800b39 <sys_getenvid>
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	53                   	push   %ebx
  801995:	50                   	push   %eax
  801996:	68 b8 21 80 00       	push   $0x8021b8
  80199b:	e8 ac e7 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019a0:	83 c4 18             	add    $0x18,%esp
  8019a3:	56                   	push   %esi
  8019a4:	ff 75 10             	pushl  0x10(%ebp)
  8019a7:	e8 4f e7 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  8019ac:	c7 04 24 9c 1d 80 00 	movl   $0x801d9c,(%esp)
  8019b3:	e8 94 e7 ff ff       	call   80014c <cprintf>
  8019b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019bb:	cc                   	int3   
  8019bc:	eb fd                	jmp    8019bb <_panic+0x43>
	...

008019c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	74 0e                	je     8019e0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	50                   	push   %eax
  8019d6:	e8 a4 f2 ff ff       	call   800c7f <sys_ipc_recv>
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	eb 10                	jmp    8019f0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	68 00 00 c0 ee       	push   $0xeec00000
  8019e8:	e8 92 f2 ff ff       	call   800c7f <sys_ipc_recv>
  8019ed:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	75 26                	jne    801a1a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019f4:	85 f6                	test   %esi,%esi
  8019f6:	74 0a                	je     801a02 <ipc_recv+0x42>
  8019f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019fd:	8b 40 74             	mov    0x74(%eax),%eax
  801a00:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a02:	85 db                	test   %ebx,%ebx
  801a04:	74 0a                	je     801a10 <ipc_recv+0x50>
  801a06:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0b:	8b 40 78             	mov    0x78(%eax),%eax
  801a0e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a10:	a1 04 40 80 00       	mov    0x804004,%eax
  801a15:	8b 40 70             	mov    0x70(%eax),%eax
  801a18:	eb 14                	jmp    801a2e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a1a:	85 f6                	test   %esi,%esi
  801a1c:	74 06                	je     801a24 <ipc_recv+0x64>
  801a1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a24:	85 db                	test   %ebx,%ebx
  801a26:	74 06                	je     801a2e <ipc_recv+0x6e>
  801a28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	57                   	push   %edi
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a44:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	75 25                	jne    801a70 <ipc_send+0x3b>
  801a4b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a50:	eb 1e                	jmp    801a70 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a52:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a55:	75 07                	jne    801a5e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a57:	e8 01 f1 ff ff       	call   800b5d <sys_yield>
  801a5c:	eb 12                	jmp    801a70 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a5e:	50                   	push   %eax
  801a5f:	68 dc 21 80 00       	push   $0x8021dc
  801a64:	6a 43                	push   $0x43
  801a66:	68 ef 21 80 00       	push   $0x8021ef
  801a6b:	e8 08 ff ff ff       	call   801978 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	57                   	push   %edi
  801a73:	ff 75 08             	pushl  0x8(%ebp)
  801a76:	e8 df f1 ff ff       	call   800c5a <sys_ipc_try_send>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	75 d0                	jne    801a52 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a91:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a97:	74 22                	je     801abb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a99:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a9e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	c1 e2 07             	shl    $0x7,%edx
  801aaa:	29 ca                	sub    %ecx,%edx
  801aac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab2:	8b 52 50             	mov    0x50(%edx),%edx
  801ab5:	39 da                	cmp    %ebx,%edx
  801ab7:	75 1d                	jne    801ad6 <ipc_find_env+0x4c>
  801ab9:	eb 05                	jmp    801ac0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ac0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ac7:	c1 e0 07             	shl    $0x7,%eax
  801aca:	29 d0                	sub    %edx,%eax
  801acc:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ad1:	8b 40 40             	mov    0x40(%eax),%eax
  801ad4:	eb 0c                	jmp    801ae2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad6:	40                   	inc    %eax
  801ad7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adc:	75 c0                	jne    801a9e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ade:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae2:	5b                   	pop    %ebx
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    
  801ae5:	00 00                	add    %al,(%eax)
	...

00801ae8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	c1 ea 16             	shr    $0x16,%edx
  801af3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801afa:	f6 c2 01             	test   $0x1,%dl
  801afd:	74 1e                	je     801b1d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aff:	c1 e8 0c             	shr    $0xc,%eax
  801b02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b09:	a8 01                	test   $0x1,%al
  801b0b:	74 17                	je     801b24 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0d:	c1 e8 0c             	shr    $0xc,%eax
  801b10:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b17:	ef 
  801b18:	0f b7 c0             	movzwl %ax,%eax
  801b1b:	eb 0c                	jmp    801b29 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b22:	eb 05                	jmp    801b29 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    
	...

00801b2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	83 ec 10             	sub    $0x10,%esp
  801b34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b3a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b40:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b43:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b46:	85 c0                	test   %eax,%eax
  801b48:	75 2e                	jne    801b78 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b4a:	39 f1                	cmp    %esi,%ecx
  801b4c:	77 5a                	ja     801ba8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b4e:	85 c9                	test   %ecx,%ecx
  801b50:	75 0b                	jne    801b5d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b52:	b8 01 00 00 00       	mov    $0x1,%eax
  801b57:	31 d2                	xor    %edx,%edx
  801b59:	f7 f1                	div    %ecx
  801b5b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b5d:	31 d2                	xor    %edx,%edx
  801b5f:	89 f0                	mov    %esi,%eax
  801b61:	f7 f1                	div    %ecx
  801b63:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b65:	89 f8                	mov    %edi,%eax
  801b67:	f7 f1                	div    %ecx
  801b69:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    
  801b76:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	77 1c                	ja     801b98 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b7c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b7f:	83 f7 1f             	xor    $0x1f,%edi
  801b82:	75 3c                	jne    801bc0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b84:	39 f0                	cmp    %esi,%eax
  801b86:	0f 82 90 00 00 00    	jb     801c1c <__udivdi3+0xf0>
  801b8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b8f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b92:	0f 86 84 00 00 00    	jbe    801c1c <__udivdi3+0xf0>
  801b98:	31 f6                	xor    %esi,%esi
  801b9a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b9c:	89 f8                	mov    %edi,%eax
  801b9e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    
  801ba7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba8:	89 f2                	mov    %esi,%edx
  801baa:	89 f8                	mov    %edi,%eax
  801bac:	f7 f1                	div    %ecx
  801bae:	89 c7                	mov    %eax,%edi
  801bb0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb2:	89 f8                	mov    %edi,%eax
  801bb4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    
  801bbd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bc0:	89 f9                	mov    %edi,%ecx
  801bc2:	d3 e0                	shl    %cl,%eax
  801bc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bc7:	b8 20 00 00 00       	mov    $0x20,%eax
  801bcc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd1:	88 c1                	mov    %al,%cl
  801bd3:	d3 ea                	shr    %cl,%edx
  801bd5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bd8:	09 ca                	or     %ecx,%edx
  801bda:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	d3 e2                	shl    %cl,%edx
  801be4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801be7:	89 f2                	mov    %esi,%edx
  801be9:	88 c1                	mov    %al,%cl
  801beb:	d3 ea                	shr    %cl,%edx
  801bed:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801bf0:	89 f2                	mov    %esi,%edx
  801bf2:	89 f9                	mov    %edi,%ecx
  801bf4:	d3 e2                	shl    %cl,%edx
  801bf6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bf9:	88 c1                	mov    %al,%cl
  801bfb:	d3 ee                	shr    %cl,%esi
  801bfd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	89 ca                	mov    %ecx,%edx
  801c06:	f7 75 ec             	divl   -0x14(%ebp)
  801c09:	89 d1                	mov    %edx,%ecx
  801c0b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c0d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c10:	39 d1                	cmp    %edx,%ecx
  801c12:	72 28                	jb     801c3c <__udivdi3+0x110>
  801c14:	74 1a                	je     801c30 <__udivdi3+0x104>
  801c16:	89 f7                	mov    %esi,%edi
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	eb 80                	jmp    801b9c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c1c:	31 f6                	xor    %esi,%esi
  801c1e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    
  801c2e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c33:	89 f9                	mov    %edi,%ecx
  801c35:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c37:	39 c2                	cmp    %eax,%edx
  801c39:	73 db                	jae    801c16 <__udivdi3+0xea>
  801c3b:	90                   	nop
		{
		  q0--;
  801c3c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c3f:	31 f6                	xor    %esi,%esi
  801c41:	e9 56 ff ff ff       	jmp    801b9c <__udivdi3+0x70>
	...

00801c48 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	57                   	push   %edi
  801c4c:	56                   	push   %esi
  801c4d:	83 ec 20             	sub    $0x20,%esp
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c56:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c65:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c67:	85 ff                	test   %edi,%edi
  801c69:	75 15                	jne    801c80 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c6b:	39 f1                	cmp    %esi,%ecx
  801c6d:	0f 86 99 00 00 00    	jbe    801d0c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c73:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c75:	89 d0                	mov    %edx,%eax
  801c77:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c79:	83 c4 20             	add    $0x20,%esp
  801c7c:	5e                   	pop    %esi
  801c7d:	5f                   	pop    %edi
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c80:	39 f7                	cmp    %esi,%edi
  801c82:	0f 87 a4 00 00 00    	ja     801d2c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c88:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c8b:	83 f0 1f             	xor    $0x1f,%eax
  801c8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c91:	0f 84 a1 00 00 00    	je     801d38 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c97:	89 f8                	mov    %edi,%eax
  801c99:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c9c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c9e:	bf 20 00 00 00       	mov    $0x20,%edi
  801ca3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca9:	89 f9                	mov    %edi,%ecx
  801cab:	d3 ea                	shr    %cl,%edx
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb8:	d3 e0                	shl    %cl,%eax
  801cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cbd:	89 f2                	mov    %esi,%edx
  801cbf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc4:	d3 e0                	shl    %cl,%eax
  801cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ccc:	89 f9                	mov    %edi,%ecx
  801cce:	d3 e8                	shr    %cl,%eax
  801cd0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cd2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cd4:	89 f2                	mov    %esi,%edx
  801cd6:	f7 75 f0             	divl   -0x10(%ebp)
  801cd9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cdb:	f7 65 f4             	mull   -0xc(%ebp)
  801cde:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801ce1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ce3:	39 d6                	cmp    %edx,%esi
  801ce5:	72 71                	jb     801d58 <__umoddi3+0x110>
  801ce7:	74 7f                	je     801d68 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cec:	29 c8                	sub    %ecx,%eax
  801cee:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801cf0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf3:	d3 e8                	shr    %cl,%eax
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	89 f9                	mov    %edi,%ecx
  801cf9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801cfb:	09 d0                	or     %edx,%eax
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d02:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d04:	83 c4 20             	add    $0x20,%esp
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    
  801d0b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d0c:	85 c9                	test   %ecx,%ecx
  801d0e:	75 0b                	jne    801d1b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d10:	b8 01 00 00 00       	mov    $0x1,%eax
  801d15:	31 d2                	xor    %edx,%edx
  801d17:	f7 f1                	div    %ecx
  801d19:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d1b:	89 f0                	mov    %esi,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d24:	f7 f1                	div    %ecx
  801d26:	e9 4a ff ff ff       	jmp    801c75 <__umoddi3+0x2d>
  801d2b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d2c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2e:	83 c4 20             	add    $0x20,%esp
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d38:	39 f7                	cmp    %esi,%edi
  801d3a:	72 05                	jb     801d41 <__umoddi3+0xf9>
  801d3c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d3f:	77 0c                	ja     801d4d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d46:	29 c8                	sub    %ecx,%eax
  801d48:	19 fa                	sbb    %edi,%edx
  801d4a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
  801d57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d58:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d5b:	89 c1                	mov    %eax,%ecx
  801d5d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d60:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d63:	eb 84                	jmp    801ce9 <__umoddi3+0xa1>
  801d65:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d68:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d6b:	72 eb                	jb     801d58 <__umoddi3+0x110>
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	e9 75 ff ff ff       	jmp    801ce9 <__umoddi3+0xa1>
