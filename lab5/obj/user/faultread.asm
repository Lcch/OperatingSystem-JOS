
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
  800040:	68 a0 1d 80 00       	push   $0x801da0
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
  8000a6:	e8 4b 0e 00 00       	call   800ef6 <close_all>
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
  8001b4:	e8 9b 19 00 00       	call   801b54 <__udivdi3>
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
  8001f0:	e8 7b 1a 00 00       	call   801c70 <__umoddi3>
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	0f be 80 c8 1d 80 00 	movsbl 0x801dc8(%eax),%eax
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
  80033c:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
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
  8003e8:	8b 04 85 60 20 80 00 	mov    0x802060(,%eax,4),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	75 1a                	jne    80040d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	52                   	push   %edx
  8003f4:	68 e0 1d 80 00       	push   $0x801de0
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
  80040e:	68 91 21 80 00       	push   $0x802191
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
  800444:	c7 45 d0 d9 1d 80 00 	movl   $0x801dd9,-0x30(%ebp)
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
  800ab2:	68 bf 20 80 00       	push   $0x8020bf
  800ab7:	6a 42                	push   $0x42
  800ab9:	68 dc 20 80 00       	push   $0x8020dc
  800abe:	e8 dd 0e 00 00       	call   8019a0 <_panic>

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

00800cc4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cca:	6a 00                	push   $0x0
  800ccc:	ff 75 14             	pushl  0x14(%ebp)
  800ccf:	ff 75 10             	pushl  0x10(%ebp)
  800cd2:	ff 75 0c             	pushl  0xc(%ebp)
  800cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ce2:	e8 99 fd ff ff       	call   800a80 <syscall>
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    
  800ce9:	00 00                	add    %al,(%eax)
	...

00800cec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf7:	c1 e8 0c             	shr    $0xc,%eax
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cff:	ff 75 08             	pushl  0x8(%ebp)
  800d02:	e8 e5 ff ff ff       	call   800cec <fd2num>
  800d07:	83 c4 04             	add    $0x4,%esp
  800d0a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d0f:	c1 e0 0c             	shl    $0xc,%eax
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	53                   	push   %ebx
  800d18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d1b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d20:	a8 01                	test   $0x1,%al
  800d22:	74 34                	je     800d58 <fd_alloc+0x44>
  800d24:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d29:	a8 01                	test   $0x1,%al
  800d2b:	74 32                	je     800d5f <fd_alloc+0x4b>
  800d2d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	89 c2                	mov    %eax,%edx
  800d36:	c1 ea 16             	shr    $0x16,%edx
  800d39:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d40:	f6 c2 01             	test   $0x1,%dl
  800d43:	74 1f                	je     800d64 <fd_alloc+0x50>
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	c1 ea 0c             	shr    $0xc,%edx
  800d4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d51:	f6 c2 01             	test   $0x1,%dl
  800d54:	75 17                	jne    800d6d <fd_alloc+0x59>
  800d56:	eb 0c                	jmp    800d64 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d58:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d5d:	eb 05                	jmp    800d64 <fd_alloc+0x50>
  800d5f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d64:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	eb 17                	jmp    800d84 <fd_alloc+0x70>
  800d6d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d77:	75 b9                	jne    800d32 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d79:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800d7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d8d:	83 f8 1f             	cmp    $0x1f,%eax
  800d90:	77 36                	ja     800dc8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d92:	05 00 00 0d 00       	add    $0xd0000,%eax
  800d97:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	c1 ea 16             	shr    $0x16,%edx
  800d9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da6:	f6 c2 01             	test   $0x1,%dl
  800da9:	74 24                	je     800dcf <fd_lookup+0x48>
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	c1 ea 0c             	shr    $0xc,%edx
  800db0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db7:	f6 c2 01             	test   $0x1,%dl
  800dba:	74 1a                	je     800dd6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbf:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 13                	jmp    800ddb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dcd:	eb 0c                	jmp    800ddb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd4:	eb 05                	jmp    800ddb <fd_lookup+0x54>
  800dd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ddb:	c9                   	leave  
  800ddc:	c3                   	ret    

00800ddd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	53                   	push   %ebx
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800dea:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800df0:	74 0d                	je     800dff <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
  800df7:	eb 14                	jmp    800e0d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800df9:	39 0a                	cmp    %ecx,(%edx)
  800dfb:	75 10                	jne    800e0d <dev_lookup+0x30>
  800dfd:	eb 05                	jmp    800e04 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dff:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e04:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	eb 31                	jmp    800e3e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e0d:	40                   	inc    %eax
  800e0e:	8b 14 85 68 21 80 00 	mov    0x802168(,%eax,4),%edx
  800e15:	85 d2                	test   %edx,%edx
  800e17:	75 e0                	jne    800df9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e19:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1e:	8b 40 48             	mov    0x48(%eax),%eax
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	51                   	push   %ecx
  800e25:	50                   	push   %eax
  800e26:	68 ec 20 80 00       	push   $0x8020ec
  800e2b:	e8 1c f3 ff ff       	call   80014c <cprintf>
	*dev = 0;
  800e30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 20             	sub    $0x20,%esp
  800e4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4e:	8a 45 0c             	mov    0xc(%ebp),%al
  800e51:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e54:	56                   	push   %esi
  800e55:	e8 92 fe ff ff       	call   800cec <fd2num>
  800e5a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e5d:	89 14 24             	mov    %edx,(%esp)
  800e60:	50                   	push   %eax
  800e61:	e8 21 ff ff ff       	call   800d87 <fd_lookup>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c4 08             	add    $0x8,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	78 05                	js     800e74 <fd_close+0x31>
	    || fd != fd2)
  800e6f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e72:	74 0d                	je     800e81 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e74:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e78:	75 48                	jne    800ec2 <fd_close+0x7f>
  800e7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7f:	eb 41                	jmp    800ec2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e87:	50                   	push   %eax
  800e88:	ff 36                	pushl  (%esi)
  800e8a:	e8 4e ff ff ff       	call   800ddd <dev_lookup>
  800e8f:	89 c3                	mov    %eax,%ebx
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 1c                	js     800eb4 <fd_close+0x71>
		if (dev->dev_close)
  800e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9b:	8b 40 10             	mov    0x10(%eax),%eax
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	74 0d                	je     800eaf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	56                   	push   %esi
  800ea6:	ff d0                	call   *%eax
  800ea8:	89 c3                	mov    %eax,%ebx
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	eb 05                	jmp    800eb4 <fd_close+0x71>
		else
			r = 0;
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	56                   	push   %esi
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 0f fd ff ff       	call   800bce <sys_page_unmap>
	return r;
  800ebf:	83 c4 10             	add    $0x10,%esp
}
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 75 08             	pushl  0x8(%ebp)
  800ed8:	e8 aa fe ff ff       	call   800d87 <fd_lookup>
  800edd:	83 c4 08             	add    $0x8,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 10                	js     800ef4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee4:	83 ec 08             	sub    $0x8,%esp
  800ee7:	6a 01                	push   $0x1
  800ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eec:	e8 52 ff ff ff       	call   800e43 <fd_close>
  800ef1:	83 c4 10             	add    $0x10,%esp
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <close_all>:

void
close_all(void)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	53                   	push   %ebx
  800f06:	e8 c0 ff ff ff       	call   800ecb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0b:	43                   	inc    %ebx
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	83 fb 20             	cmp    $0x20,%ebx
  800f12:	75 ee                	jne    800f02 <close_all+0xc>
		close(i);
}
  800f14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 2c             	sub    $0x2c,%esp
  800f22:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 75 08             	pushl  0x8(%ebp)
  800f2c:	e8 56 fe ff ff       	call   800d87 <fd_lookup>
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	83 c4 08             	add    $0x8,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	0f 88 c0 00 00 00    	js     800ffe <dup+0xe5>
		return r;
	close(newfdnum);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	57                   	push   %edi
  800f42:	e8 84 ff ff ff       	call   800ecb <close>

	newfd = INDEX2FD(newfdnum);
  800f47:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f4d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f50:	83 c4 04             	add    $0x4,%esp
  800f53:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f56:	e8 a1 fd ff ff       	call   800cfc <fd2data>
  800f5b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f5d:	89 34 24             	mov    %esi,(%esp)
  800f60:	e8 97 fd ff ff       	call   800cfc <fd2data>
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6b:	89 d8                	mov    %ebx,%eax
  800f6d:	c1 e8 16             	shr    $0x16,%eax
  800f70:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f77:	a8 01                	test   $0x1,%al
  800f79:	74 37                	je     800fb2 <dup+0x99>
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 0c             	shr    $0xc,%eax
  800f80:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f87:	f6 c2 01             	test   $0x1,%dl
  800f8a:	74 26                	je     800fb2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9b:	50                   	push   %eax
  800f9c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9f:	6a 00                	push   $0x0
  800fa1:	53                   	push   %ebx
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 ff fb ff ff       	call   800ba8 <sys_page_map>
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 2d                	js     800fdf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb5:	89 c2                	mov    %eax,%edx
  800fb7:	c1 ea 0c             	shr    $0xc,%edx
  800fba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fca:	52                   	push   %edx
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	50                   	push   %eax
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 d2 fb ff ff       	call   800ba8 <sys_page_map>
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 1d                	jns    800ffc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	56                   	push   %esi
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 e4 fb ff ff       	call   800bce <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fea:	83 c4 08             	add    $0x8,%esp
  800fed:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 d7 fb ff ff       	call   800bce <sys_page_unmap>
	return r;
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	eb 02                	jmp    800ffe <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800ffc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 14             	sub    $0x14,%esp
  80100f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801012:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	53                   	push   %ebx
  801017:	e8 6b fd ff ff       	call   800d87 <fd_lookup>
  80101c:	83 c4 08             	add    $0x8,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 67                	js     80108a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801029:	50                   	push   %eax
  80102a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80102d:	ff 30                	pushl  (%eax)
  80102f:	e8 a9 fd ff ff       	call   800ddd <dev_lookup>
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 4f                	js     80108a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103e:	8b 50 08             	mov    0x8(%eax),%edx
  801041:	83 e2 03             	and    $0x3,%edx
  801044:	83 fa 01             	cmp    $0x1,%edx
  801047:	75 21                	jne    80106a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801049:	a1 04 40 80 00       	mov    0x804004,%eax
  80104e:	8b 40 48             	mov    0x48(%eax),%eax
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	53                   	push   %ebx
  801055:	50                   	push   %eax
  801056:	68 2d 21 80 00       	push   $0x80212d
  80105b:	e8 ec f0 ff ff       	call   80014c <cprintf>
		return -E_INVAL;
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801068:	eb 20                	jmp    80108a <read+0x82>
	}
	if (!dev->dev_read)
  80106a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80106d:	8b 52 08             	mov    0x8(%edx),%edx
  801070:	85 d2                	test   %edx,%edx
  801072:	74 11                	je     801085 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	ff 75 10             	pushl  0x10(%ebp)
  80107a:	ff 75 0c             	pushl  0xc(%ebp)
  80107d:	50                   	push   %eax
  80107e:	ff d2                	call   *%edx
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	eb 05                	jmp    80108a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801085:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80108a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80109e:	85 f6                	test   %esi,%esi
  8010a0:	74 31                	je     8010d3 <readn+0x44>
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	29 c2                	sub    %eax,%edx
  8010b3:	52                   	push   %edx
  8010b4:	03 45 0c             	add    0xc(%ebp),%eax
  8010b7:	50                   	push   %eax
  8010b8:	57                   	push   %edi
  8010b9:	e8 4a ff ff ff       	call   801008 <read>
		if (m < 0)
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 17                	js     8010dc <readn+0x4d>
			return m;
		if (m == 0)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	74 11                	je     8010da <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c9:	01 c3                	add    %eax,%ebx
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	39 f3                	cmp    %esi,%ebx
  8010cf:	72 db                	jb     8010ac <readn+0x1d>
  8010d1:	eb 09                	jmp    8010dc <readn+0x4d>
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	eb 02                	jmp    8010dc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010da:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8010dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 14             	sub    $0x14,%esp
  8010eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	e8 8f fc ff ff       	call   800d87 <fd_lookup>
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 62                	js     801161 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	ff 30                	pushl  (%eax)
  80110b:	e8 cd fc ff ff       	call   800ddd <dev_lookup>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	78 4a                	js     801161 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801117:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111e:	75 21                	jne    801141 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801120:	a1 04 40 80 00       	mov    0x804004,%eax
  801125:	8b 40 48             	mov    0x48(%eax),%eax
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	53                   	push   %ebx
  80112c:	50                   	push   %eax
  80112d:	68 49 21 80 00       	push   $0x802149
  801132:	e8 15 f0 ff ff       	call   80014c <cprintf>
		return -E_INVAL;
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113f:	eb 20                	jmp    801161 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801141:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801144:	8b 52 0c             	mov    0xc(%edx),%edx
  801147:	85 d2                	test   %edx,%edx
  801149:	74 11                	je     80115c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	ff 75 10             	pushl  0x10(%ebp)
  801151:	ff 75 0c             	pushl  0xc(%ebp)
  801154:	50                   	push   %eax
  801155:	ff d2                	call   *%edx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb 05                	jmp    801161 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80115c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <seek>:

int
seek(int fdnum, off_t offset)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 0f fc ff ff       	call   800d87 <fd_lookup>
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 0e                	js     80118d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80117f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801182:	8b 55 0c             	mov    0xc(%ebp),%edx
  801185:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	53                   	push   %ebx
  801193:	83 ec 14             	sub    $0x14,%esp
  801196:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801199:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	53                   	push   %ebx
  80119e:	e8 e4 fb ff ff       	call   800d87 <fd_lookup>
  8011a3:	83 c4 08             	add    $0x8,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 5f                	js     801209 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b0:	50                   	push   %eax
  8011b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b4:	ff 30                	pushl  (%eax)
  8011b6:	e8 22 fc ff ff       	call   800ddd <dev_lookup>
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 47                	js     801209 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c9:	75 21                	jne    8011ec <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011cb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	50                   	push   %eax
  8011d8:	68 0c 21 80 00       	push   $0x80210c
  8011dd:	e8 6a ef ff ff       	call   80014c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ea:	eb 1d                	jmp    801209 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8011ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ef:	8b 52 18             	mov    0x18(%edx),%edx
  8011f2:	85 d2                	test   %edx,%edx
  8011f4:	74 0e                	je     801204 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	ff 75 0c             	pushl  0xc(%ebp)
  8011fc:	50                   	push   %eax
  8011fd:	ff d2                	call   *%edx
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	eb 05                	jmp    801209 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801204:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801209:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	83 ec 14             	sub    $0x14,%esp
  801215:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 63 fb ff ff       	call   800d87 <fd_lookup>
  801224:	83 c4 08             	add    $0x8,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 52                	js     80127d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801235:	ff 30                	pushl  (%eax)
  801237:	e8 a1 fb ff ff       	call   800ddd <dev_lookup>
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 3a                	js     80127d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801243:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801246:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80124a:	74 2c                	je     801278 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80124c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80124f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801256:	00 00 00 
	stat->st_isdir = 0;
  801259:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801260:	00 00 00 
	stat->st_dev = dev;
  801263:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	53                   	push   %ebx
  80126d:	ff 75 f0             	pushl  -0x10(%ebp)
  801270:	ff 50 14             	call   *0x14(%eax)
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	eb 05                	jmp    80127d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801278:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80127d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	6a 00                	push   $0x0
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 78 01 00 00       	call   80140c <open>
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 1b                	js     8012b8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	ff 75 0c             	pushl  0xc(%ebp)
  8012a3:	50                   	push   %eax
  8012a4:	e8 65 ff ff ff       	call   80120e <fstat>
  8012a9:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ab:	89 1c 24             	mov    %ebx,(%esp)
  8012ae:	e8 18 fc ff ff       	call   800ecb <close>
	return r;
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	89 f3                	mov    %esi,%ebx
}
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    
  8012c1:	00 00                	add    %al,(%eax)
	...

008012c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	89 c3                	mov    %eax,%ebx
  8012cb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d4:	75 12                	jne    8012e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	6a 01                	push   $0x1
  8012db:	e8 d2 07 00 00       	call   801ab2 <ipc_find_env>
  8012e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e8:	6a 07                	push   $0x7
  8012ea:	68 00 50 80 00       	push   $0x805000
  8012ef:	53                   	push   %ebx
  8012f0:	ff 35 00 40 80 00    	pushl  0x804000
  8012f6:	e8 62 07 00 00       	call   801a5d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8012fb:	83 c4 0c             	add    $0xc,%esp
  8012fe:	6a 00                	push   $0x0
  801300:	56                   	push   %esi
  801301:	6a 00                	push   $0x0
  801303:	e8 e0 06 00 00       	call   8019e8 <ipc_recv>
}
  801308:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	8b 40 0c             	mov    0xc(%eax),%eax
  80131f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801324:	ba 00 00 00 00       	mov    $0x0,%edx
  801329:	b8 05 00 00 00       	mov    $0x5,%eax
  80132e:	e8 91 ff ff ff       	call   8012c4 <fsipc>
  801333:	85 c0                	test   %eax,%eax
  801335:	78 2c                	js     801363 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	68 00 50 80 00       	push   $0x805000
  80133f:	53                   	push   %ebx
  801340:	e8 bd f3 ff ff       	call   800702 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801345:	a1 80 50 80 00       	mov    0x805080,%eax
  80134a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801350:	a1 84 50 80 00       	mov    0x805084,%eax
  801355:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	8b 40 0c             	mov    0xc(%eax),%eax
  801374:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801379:	ba 00 00 00 00       	mov    $0x0,%edx
  80137e:	b8 06 00 00 00       	mov    $0x6,%eax
  801383:	e8 3c ff ff ff       	call   8012c4 <fsipc>
}
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	8b 40 0c             	mov    0xc(%eax),%eax
  801398:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80139d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ad:	e8 12 ff ff ff       	call   8012c4 <fsipc>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 4b                	js     801403 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013b8:	39 c6                	cmp    %eax,%esi
  8013ba:	73 16                	jae    8013d2 <devfile_read+0x48>
  8013bc:	68 78 21 80 00       	push   $0x802178
  8013c1:	68 7f 21 80 00       	push   $0x80217f
  8013c6:	6a 7d                	push   $0x7d
  8013c8:	68 94 21 80 00       	push   $0x802194
  8013cd:	e8 ce 05 00 00       	call   8019a0 <_panic>
	assert(r <= PGSIZE);
  8013d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013d7:	7e 16                	jle    8013ef <devfile_read+0x65>
  8013d9:	68 9f 21 80 00       	push   $0x80219f
  8013de:	68 7f 21 80 00       	push   $0x80217f
  8013e3:	6a 7e                	push   $0x7e
  8013e5:	68 94 21 80 00       	push   $0x802194
  8013ea:	e8 b1 05 00 00       	call   8019a0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	50                   	push   %eax
  8013f3:	68 00 50 80 00       	push   $0x805000
  8013f8:	ff 75 0c             	pushl  0xc(%ebp)
  8013fb:	e8 c3 f4 ff ff       	call   8008c3 <memmove>
	return r;
  801400:	83 c4 10             	add    $0x10,%esp
}
  801403:	89 d8                	mov    %ebx,%eax
  801405:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 1c             	sub    $0x1c,%esp
  801414:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801417:	56                   	push   %esi
  801418:	e8 93 f2 ff ff       	call   8006b0 <strlen>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801425:	7f 65                	jg     80148c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	e8 e1 f8 ff ff       	call   800d14 <fd_alloc>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 55                	js     801491 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	56                   	push   %esi
  801440:	68 00 50 80 00       	push   $0x805000
  801445:	e8 b8 f2 ff ff       	call   800702 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80144a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801452:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801455:	b8 01 00 00 00       	mov    $0x1,%eax
  80145a:	e8 65 fe ff ff       	call   8012c4 <fsipc>
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	79 12                	jns    80147a <open+0x6e>
		fd_close(fd, 0);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	6a 00                	push   $0x0
  80146d:	ff 75 f4             	pushl  -0xc(%ebp)
  801470:	e8 ce f9 ff ff       	call   800e43 <fd_close>
		return r;
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	eb 17                	jmp    801491 <open+0x85>
	}

	return fd2num(fd);
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	ff 75 f4             	pushl  -0xc(%ebp)
  801480:	e8 67 f8 ff ff       	call   800cec <fd2num>
  801485:	89 c3                	mov    %eax,%ebx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb 05                	jmp    801491 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80148c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801491:	89 d8                	mov    %ebx,%eax
  801493:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	c9                   	leave  
  801499:	c3                   	ret    
	...

0080149c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 4d f8 ff ff       	call   800cfc <fd2data>
  8014af:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	68 ab 21 80 00       	push   $0x8021ab
  8014b9:	56                   	push   %esi
  8014ba:	e8 43 f2 ff ff       	call   800702 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8014c2:	2b 03                	sub    (%ebx),%eax
  8014c4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014ca:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014d1:	00 00 00 
	stat->st_dev = &devpipe;
  8014d4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014db:	30 80 00 
	return 0;
}
  8014de:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8014f4:	53                   	push   %ebx
  8014f5:	6a 00                	push   $0x0
  8014f7:	e8 d2 f6 ff ff       	call   800bce <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8014fc:	89 1c 24             	mov    %ebx,(%esp)
  8014ff:	e8 f8 f7 ff ff       	call   800cfc <fd2data>
  801504:	83 c4 08             	add    $0x8,%esp
  801507:	50                   	push   %eax
  801508:	6a 00                	push   $0x0
  80150a:	e8 bf f6 ff ff       	call   800bce <sys_page_unmap>
}
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	57                   	push   %edi
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	83 ec 1c             	sub    $0x1c,%esp
  80151d:	89 c7                	mov    %eax,%edi
  80151f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801522:	a1 04 40 80 00       	mov    0x804004,%eax
  801527:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	57                   	push   %edi
  80152e:	e8 dd 05 00 00       	call   801b10 <pageref>
  801533:	89 c6                	mov    %eax,%esi
  801535:	83 c4 04             	add    $0x4,%esp
  801538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153b:	e8 d0 05 00 00       	call   801b10 <pageref>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	39 c6                	cmp    %eax,%esi
  801545:	0f 94 c0             	sete   %al
  801548:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80154b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801551:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801554:	39 cb                	cmp    %ecx,%ebx
  801556:	75 08                	jne    801560 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801558:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801560:	83 f8 01             	cmp    $0x1,%eax
  801563:	75 bd                	jne    801522 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801565:	8b 42 58             	mov    0x58(%edx),%eax
  801568:	6a 01                	push   $0x1
  80156a:	50                   	push   %eax
  80156b:	53                   	push   %ebx
  80156c:	68 b2 21 80 00       	push   $0x8021b2
  801571:	e8 d6 eb ff ff       	call   80014c <cprintf>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb a7                	jmp    801522 <_pipeisclosed+0xe>

0080157b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 28             	sub    $0x28,%esp
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801587:	56                   	push   %esi
  801588:	e8 6f f7 ff ff       	call   800cfc <fd2data>
  80158d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801596:	75 4a                	jne    8015e2 <devpipe_write+0x67>
  801598:	bf 00 00 00 00       	mov    $0x0,%edi
  80159d:	eb 56                	jmp    8015f5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80159f:	89 da                	mov    %ebx,%edx
  8015a1:	89 f0                	mov    %esi,%eax
  8015a3:	e8 6c ff ff ff       	call   801514 <_pipeisclosed>
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	75 4d                	jne    8015f9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015ac:	e8 ac f5 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8015b4:	8b 13                	mov    (%ebx),%edx
  8015b6:	83 c2 20             	add    $0x20,%edx
  8015b9:	39 d0                	cmp    %edx,%eax
  8015bb:	73 e2                	jae    80159f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8015c5:	79 05                	jns    8015cc <devpipe_write+0x51>
  8015c7:	4a                   	dec    %edx
  8015c8:	83 ca e0             	or     $0xffffffe0,%edx
  8015cb:	42                   	inc    %edx
  8015cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015cf:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015d6:	40                   	inc    %eax
  8015d7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015da:	47                   	inc    %edi
  8015db:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8015de:	77 07                	ja     8015e7 <devpipe_write+0x6c>
  8015e0:	eb 13                	jmp    8015f5 <devpipe_write+0x7a>
  8015e2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8015ea:	8b 13                	mov    (%ebx),%edx
  8015ec:	83 c2 20             	add    $0x20,%edx
  8015ef:	39 d0                	cmp    %edx,%eax
  8015f1:	73 ac                	jae    80159f <devpipe_write+0x24>
  8015f3:	eb c8                	jmp    8015bd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8015f5:	89 f8                	mov    %edi,%eax
  8015f7:	eb 05                	jmp    8015fe <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8015fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5f                   	pop    %edi
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	57                   	push   %edi
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 18             	sub    $0x18,%esp
  80160f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801612:	57                   	push   %edi
  801613:	e8 e4 f6 ff ff       	call   800cfc <fd2data>
  801618:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801621:	75 44                	jne    801667 <devpipe_read+0x61>
  801623:	be 00 00 00 00       	mov    $0x0,%esi
  801628:	eb 4f                	jmp    801679 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80162a:	89 f0                	mov    %esi,%eax
  80162c:	eb 54                	jmp    801682 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80162e:	89 da                	mov    %ebx,%edx
  801630:	89 f8                	mov    %edi,%eax
  801632:	e8 dd fe ff ff       	call   801514 <_pipeisclosed>
  801637:	85 c0                	test   %eax,%eax
  801639:	75 42                	jne    80167d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80163b:	e8 1d f5 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801640:	8b 03                	mov    (%ebx),%eax
  801642:	3b 43 04             	cmp    0x4(%ebx),%eax
  801645:	74 e7                	je     80162e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801647:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80164c:	79 05                	jns    801653 <devpipe_read+0x4d>
  80164e:	48                   	dec    %eax
  80164f:	83 c8 e0             	or     $0xffffffe0,%eax
  801652:	40                   	inc    %eax
  801653:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801657:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80165d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165f:	46                   	inc    %esi
  801660:	39 75 10             	cmp    %esi,0x10(%ebp)
  801663:	77 07                	ja     80166c <devpipe_read+0x66>
  801665:	eb 12                	jmp    801679 <devpipe_read+0x73>
  801667:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80166c:	8b 03                	mov    (%ebx),%eax
  80166e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801671:	75 d4                	jne    801647 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801673:	85 f6                	test   %esi,%esi
  801675:	75 b3                	jne    80162a <devpipe_read+0x24>
  801677:	eb b5                	jmp    80162e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801679:	89 f0                	mov    %esi,%eax
  80167b:	eb 05                	jmp    801682 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	57                   	push   %edi
  80168e:	56                   	push   %esi
  80168f:	53                   	push   %ebx
  801690:	83 ec 28             	sub    $0x28,%esp
  801693:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801696:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	e8 75 f6 ff ff       	call   800d14 <fd_alloc>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	0f 88 24 01 00 00    	js     8017d0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	68 07 04 00 00       	push   $0x407
  8016b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 c6 f4 ff ff       	call   800b84 <sys_page_alloc>
  8016be:	89 c3                	mov    %eax,%ebx
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	0f 88 05 01 00 00    	js     8017d0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	e8 3d f6 ff ff       	call   800d14 <fd_alloc>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 88 dc 00 00 00    	js     8017c0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	68 07 04 00 00       	push   $0x407
  8016ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 8e f4 ff ff       	call   800b84 <sys_page_alloc>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	0f 88 bd 00 00 00    	js     8017c0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	ff 75 e4             	pushl  -0x1c(%ebp)
  801709:	e8 ee f5 ff ff       	call   800cfc <fd2data>
  80170e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801710:	83 c4 0c             	add    $0xc,%esp
  801713:	68 07 04 00 00       	push   $0x407
  801718:	50                   	push   %eax
  801719:	6a 00                	push   $0x0
  80171b:	e8 64 f4 ff ff       	call   800b84 <sys_page_alloc>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 83 00 00 00    	js     8017b0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	ff 75 e0             	pushl  -0x20(%ebp)
  801733:	e8 c4 f5 ff ff       	call   800cfc <fd2data>
  801738:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80173f:	50                   	push   %eax
  801740:	6a 00                	push   $0x0
  801742:	56                   	push   %esi
  801743:	6a 00                	push   $0x0
  801745:	e8 5e f4 ff ff       	call   800ba8 <sys_page_map>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 20             	add    $0x20,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 4f                	js     8017a2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801753:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80175e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801761:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801768:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80176e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801771:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801773:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801776:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	ff 75 e4             	pushl  -0x1c(%ebp)
  801783:	e8 64 f5 ff ff       	call   800cec <fd2num>
  801788:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80178a:	83 c4 04             	add    $0x4,%esp
  80178d:	ff 75 e0             	pushl  -0x20(%ebp)
  801790:	e8 57 f5 ff ff       	call   800cec <fd2num>
  801795:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a0:	eb 2e                	jmp    8017d0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	56                   	push   %esi
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 21 f4 ff ff       	call   800bce <sys_page_unmap>
  8017ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 11 f4 ff ff       	call   800bce <sys_page_unmap>
  8017bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 01 f4 ff ff       	call   800bce <sys_page_unmap>
  8017cd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017d0:	89 d8                	mov    %ebx,%eax
  8017d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5f                   	pop    %edi
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	ff 75 08             	pushl  0x8(%ebp)
  8017e7:	e8 9b f5 ff ff       	call   800d87 <fd_lookup>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 18                	js     80180b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	e8 fe f4 ff ff       	call   800cfc <fd2data>
	return _pipeisclosed(fd, p);
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801803:	e8 0c fd ff ff       	call   801514 <_pipeisclosed>
  801808:	83 c4 10             	add    $0x10,%esp
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    
  80180d:	00 00                	add    %al,(%eax)
	...

00801810 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801820:	68 ca 21 80 00       	push   $0x8021ca
  801825:	ff 75 0c             	pushl  0xc(%ebp)
  801828:	e8 d5 ee ff ff       	call   800702 <strcpy>
	return 0;
}
  80182d:	b8 00 00 00 00       	mov    $0x0,%eax
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801840:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801844:	74 45                	je     80188b <devcons_write+0x57>
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
  80184b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801850:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801856:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801859:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80185b:	83 fb 7f             	cmp    $0x7f,%ebx
  80185e:	76 05                	jbe    801865 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801860:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	53                   	push   %ebx
  801869:	03 45 0c             	add    0xc(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	57                   	push   %edi
  80186e:	e8 50 f0 ff ff       	call   8008c3 <memmove>
		sys_cputs(buf, m);
  801873:	83 c4 08             	add    $0x8,%esp
  801876:	53                   	push   %ebx
  801877:	57                   	push   %edi
  801878:	e8 50 f2 ff ff       	call   800acd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187d:	01 de                	add    %ebx,%esi
  80187f:	89 f0                	mov    %esi,%eax
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	3b 75 10             	cmp    0x10(%ebp),%esi
  801887:	72 cd                	jb     801856 <devcons_write+0x22>
  801889:	eb 05                	jmp    801890 <devcons_write+0x5c>
  80188b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801890:	89 f0                	mov    %esi,%eax
  801892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5f                   	pop    %edi
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018a4:	75 07                	jne    8018ad <devcons_read+0x13>
  8018a6:	eb 25                	jmp    8018cd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018a8:	e8 b0 f2 ff ff       	call   800b5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018ad:	e8 41 f2 ff ff       	call   800af3 <sys_cgetc>
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	74 f2                	je     8018a8 <devcons_read+0xe>
  8018b6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 1d                	js     8018d9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018bc:	83 f8 04             	cmp    $0x4,%eax
  8018bf:	74 13                	je     8018d4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8018c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c4:	88 10                	mov    %dl,(%eax)
	return 1;
  8018c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cb:	eb 0c                	jmp    8018d9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d2:	eb 05                	jmp    8018d9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018e7:	6a 01                	push   $0x1
  8018e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	e8 db f1 ff ff       	call   800acd <sys_cputs>
  8018f2:	83 c4 10             	add    $0x10,%esp
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <getchar>:

int
getchar(void)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018fd:	6a 01                	push   $0x1
  8018ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	6a 00                	push   $0x0
  801905:	e8 fe f6 ff ff       	call   801008 <read>
	if (r < 0)
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 0f                	js     801920 <getchar+0x29>
		return r;
	if (r < 1)
  801911:	85 c0                	test   %eax,%eax
  801913:	7e 06                	jle    80191b <getchar+0x24>
		return -E_EOF;
	return c;
  801915:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801919:	eb 05                	jmp    801920 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80191b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801928:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192b:	50                   	push   %eax
  80192c:	ff 75 08             	pushl  0x8(%ebp)
  80192f:	e8 53 f4 ff ff       	call   800d87 <fd_lookup>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 11                	js     80194c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801944:	39 10                	cmp    %edx,(%eax)
  801946:	0f 94 c0             	sete   %al
  801949:	0f b6 c0             	movzbl %al,%eax
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <opencons>:

int
opencons(void)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	e8 b7 f3 ff ff       	call   800d14 <fd_alloc>
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 3a                	js     80199e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 07 04 00 00       	push   $0x407
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 0e f2 ff ff       	call   800b84 <sys_page_alloc>
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 21                	js     80199e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80197d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	50                   	push   %eax
  801996:	e8 51 f3 ff ff       	call   800cec <fd2num>
  80199b:	83 c4 10             	add    $0x10,%esp
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019a5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019a8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019ae:	e8 86 f1 ff ff       	call   800b39 <sys_getenvid>
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	53                   	push   %ebx
  8019bd:	50                   	push   %eax
  8019be:	68 d8 21 80 00       	push   $0x8021d8
  8019c3:	e8 84 e7 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019c8:	83 c4 18             	add    $0x18,%esp
  8019cb:	56                   	push   %esi
  8019cc:	ff 75 10             	pushl  0x10(%ebp)
  8019cf:	e8 27 e7 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  8019d4:	c7 04 24 bc 1d 80 00 	movl   $0x801dbc,(%esp)
  8019db:	e8 6c e7 ff ff       	call   80014c <cprintf>
  8019e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019e3:	cc                   	int3   
  8019e4:	eb fd                	jmp    8019e3 <_panic+0x43>
	...

008019e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	74 0e                	je     801a08 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	50                   	push   %eax
  8019fe:	e8 7c f2 ff ff       	call   800c7f <sys_ipc_recv>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	eb 10                	jmp    801a18 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	68 00 00 c0 ee       	push   $0xeec00000
  801a10:	e8 6a f2 ff ff       	call   800c7f <sys_ipc_recv>
  801a15:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	75 26                	jne    801a42 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a1c:	85 f6                	test   %esi,%esi
  801a1e:	74 0a                	je     801a2a <ipc_recv+0x42>
  801a20:	a1 04 40 80 00       	mov    0x804004,%eax
  801a25:	8b 40 74             	mov    0x74(%eax),%eax
  801a28:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a2a:	85 db                	test   %ebx,%ebx
  801a2c:	74 0a                	je     801a38 <ipc_recv+0x50>
  801a2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a33:	8b 40 78             	mov    0x78(%eax),%eax
  801a36:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a38:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3d:	8b 40 70             	mov    0x70(%eax),%eax
  801a40:	eb 14                	jmp    801a56 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a42:	85 f6                	test   %esi,%esi
  801a44:	74 06                	je     801a4c <ipc_recv+0x64>
  801a46:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 06                	je     801a56 <ipc_recv+0x6e>
  801a50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a6c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	75 25                	jne    801a98 <ipc_send+0x3b>
  801a73:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a78:	eb 1e                	jmp    801a98 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7d:	75 07                	jne    801a86 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a7f:	e8 d9 f0 ff ff       	call   800b5d <sys_yield>
  801a84:	eb 12                	jmp    801a98 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a86:	50                   	push   %eax
  801a87:	68 fc 21 80 00       	push   $0x8021fc
  801a8c:	6a 43                	push   $0x43
  801a8e:	68 0f 22 80 00       	push   $0x80220f
  801a93:	e8 08 ff ff ff       	call   8019a0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	57                   	push   %edi
  801a9b:	ff 75 08             	pushl  0x8(%ebp)
  801a9e:	e8 b7 f1 ff ff       	call   800c5a <sys_ipc_try_send>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	75 d0                	jne    801a7a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ab9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801abf:	74 22                	je     801ae3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ac6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801acd:	89 c2                	mov    %eax,%edx
  801acf:	c1 e2 07             	shl    $0x7,%edx
  801ad2:	29 ca                	sub    %ecx,%edx
  801ad4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ada:	8b 52 50             	mov    0x50(%edx),%edx
  801add:	39 da                	cmp    %ebx,%edx
  801adf:	75 1d                	jne    801afe <ipc_find_env+0x4c>
  801ae1:	eb 05                	jmp    801ae8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ae8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801aef:	c1 e0 07             	shl    $0x7,%eax
  801af2:	29 d0                	sub    %edx,%eax
  801af4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801af9:	8b 40 40             	mov    0x40(%eax),%eax
  801afc:	eb 0c                	jmp    801b0a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afe:	40                   	inc    %eax
  801aff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b04:	75 c0                	jne    801ac6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b06:	66 b8 00 00          	mov    $0x0,%ax
}
  801b0a:	5b                   	pop    %ebx
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    
  801b0d:	00 00                	add    %al,(%eax)
	...

00801b10 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 ea 16             	shr    $0x16,%edx
  801b1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b22:	f6 c2 01             	test   $0x1,%dl
  801b25:	74 1e                	je     801b45 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b27:	c1 e8 0c             	shr    $0xc,%eax
  801b2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b31:	a8 01                	test   $0x1,%al
  801b33:	74 17                	je     801b4c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
  801b43:	eb 0c                	jmp    801b51 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4a:	eb 05                	jmp    801b51 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    
	...

00801b54 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	57                   	push   %edi
  801b58:	56                   	push   %esi
  801b59:	83 ec 10             	sub    $0x10,%esp
  801b5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b62:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 2e                	jne    801ba0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b72:	39 f1                	cmp    %esi,%ecx
  801b74:	77 5a                	ja     801bd0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b76:	85 c9                	test   %ecx,%ecx
  801b78:	75 0b                	jne    801b85 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	31 d2                	xor    %edx,%edx
  801b81:	f7 f1                	div    %ecx
  801b83:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b85:	31 d2                	xor    %edx,%edx
  801b87:	89 f0                	mov    %esi,%eax
  801b89:	f7 f1                	div    %ecx
  801b8b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	f7 f1                	div    %ecx
  801b91:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b93:	89 f8                	mov    %edi,%eax
  801b95:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	5e                   	pop    %esi
  801b9b:	5f                   	pop    %edi
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    
  801b9e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ba0:	39 f0                	cmp    %esi,%eax
  801ba2:	77 1c                	ja     801bc0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ba4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	75 3c                	jne    801be8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bac:	39 f0                	cmp    %esi,%eax
  801bae:	0f 82 90 00 00 00    	jb     801c44 <__udivdi3+0xf0>
  801bb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bb7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bba:	0f 86 84 00 00 00    	jbe    801c44 <__udivdi3+0xf0>
  801bc0:	31 f6                	xor    %esi,%esi
  801bc2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    
  801bcf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bd0:	89 f2                	mov    %esi,%edx
  801bd2:	89 f8                	mov    %edi,%eax
  801bd4:	f7 f1                	div    %ecx
  801bd6:	89 c7                	mov    %eax,%edi
  801bd8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	5e                   	pop    %esi
  801be2:	5f                   	pop    %edi
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    
  801be5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801be8:	89 f9                	mov    %edi,%ecx
  801bea:	d3 e0                	shl    %cl,%eax
  801bec:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bef:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf9:	88 c1                	mov    %al,%cl
  801bfb:	d3 ea                	shr    %cl,%edx
  801bfd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c00:	09 ca                	or     %ecx,%edx
  801c02:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c08:	89 f9                	mov    %edi,%ecx
  801c0a:	d3 e2                	shl    %cl,%edx
  801c0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c0f:	89 f2                	mov    %esi,%edx
  801c11:	88 c1                	mov    %al,%cl
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	89 f9                	mov    %edi,%ecx
  801c1c:	d3 e2                	shl    %cl,%edx
  801c1e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c21:	88 c1                	mov    %al,%cl
  801c23:	d3 ee                	shr    %cl,%esi
  801c25:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	89 ca                	mov    %ecx,%edx
  801c2e:	f7 75 ec             	divl   -0x14(%ebp)
  801c31:	89 d1                	mov    %edx,%ecx
  801c33:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c35:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c38:	39 d1                	cmp    %edx,%ecx
  801c3a:	72 28                	jb     801c64 <__udivdi3+0x110>
  801c3c:	74 1a                	je     801c58 <__udivdi3+0x104>
  801c3e:	89 f7                	mov    %esi,%edi
  801c40:	31 f6                	xor    %esi,%esi
  801c42:	eb 80                	jmp    801bc4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c44:	31 f6                	xor    %esi,%esi
  801c46:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c4b:	89 f8                	mov    %edi,%eax
  801c4d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    
  801c56:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c5f:	39 c2                	cmp    %eax,%edx
  801c61:	73 db                	jae    801c3e <__udivdi3+0xea>
  801c63:	90                   	nop
		{
		  q0--;
  801c64:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c67:	31 f6                	xor    %esi,%esi
  801c69:	e9 56 ff ff ff       	jmp    801bc4 <__udivdi3+0x70>
	...

00801c70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	83 ec 20             	sub    $0x20,%esp
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c8d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c8f:	85 ff                	test   %edi,%edi
  801c91:	75 15                	jne    801ca8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c93:	39 f1                	cmp    %esi,%ecx
  801c95:	0f 86 99 00 00 00    	jbe    801d34 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c9b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c9d:	89 d0                	mov    %edx,%eax
  801c9f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ca1:	83 c4 20             	add    $0x20,%esp
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ca8:	39 f7                	cmp    %esi,%edi
  801caa:	0f 87 a4 00 00 00    	ja     801d54 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cb0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cb3:	83 f0 1f             	xor    $0x1f,%eax
  801cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cb9:	0f 84 a1 00 00 00    	je     801d60 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cc4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cc6:	bf 20 00 00 00       	mov    $0x20,%edi
  801ccb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 ea                	shr    %cl,%edx
  801cd5:	09 c2                	or     %eax,%edx
  801cd7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce0:	d3 e0                	shl    %cl,%eax
  801ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce5:	89 f2                	mov    %esi,%edx
  801ce7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cf4:	89 f9                	mov    %edi,%ecx
  801cf6:	d3 e8                	shr    %cl,%eax
  801cf8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cfa:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cfc:	89 f2                	mov    %esi,%edx
  801cfe:	f7 75 f0             	divl   -0x10(%ebp)
  801d01:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d03:	f7 65 f4             	mull   -0xc(%ebp)
  801d06:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d09:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d0b:	39 d6                	cmp    %edx,%esi
  801d0d:	72 71                	jb     801d80 <__umoddi3+0x110>
  801d0f:	74 7f                	je     801d90 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d14:	29 c8                	sub    %ecx,%eax
  801d16:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d18:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	89 f9                	mov    %edi,%ecx
  801d21:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d23:	09 d0                	or     %edx,%eax
  801d25:	89 f2                	mov    %esi,%edx
  801d27:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d2a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2c:	83 c4 20             	add    $0x20,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    
  801d33:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d34:	85 c9                	test   %ecx,%ecx
  801d36:	75 0b                	jne    801d43 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d38:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3d:	31 d2                	xor    %edx,%edx
  801d3f:	f7 f1                	div    %ecx
  801d41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d43:	89 f0                	mov    %esi,%eax
  801d45:	31 d2                	xor    %edx,%edx
  801d47:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4c:	f7 f1                	div    %ecx
  801d4e:	e9 4a ff ff ff       	jmp    801c9d <__umoddi3+0x2d>
  801d53:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d54:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d56:	83 c4 20             	add    $0x20,%esp
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d60:	39 f7                	cmp    %esi,%edi
  801d62:	72 05                	jb     801d69 <__umoddi3+0xf9>
  801d64:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d67:	77 0c                	ja     801d75 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6e:	29 c8                	sub    %ecx,%eax
  801d70:	19 fa                	sbb    %edi,%edx
  801d72:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d78:	83 c4 20             	add    $0x20,%esp
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    
  801d7f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d80:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d83:	89 c1                	mov    %eax,%ecx
  801d85:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d88:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d8b:	eb 84                	jmp    801d11 <__umoddi3+0xa1>
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d93:	72 eb                	jb     801d80 <__umoddi3+0x110>
  801d95:	89 f2                	mov    %esi,%edx
  801d97:	e9 75 ff ff ff       	jmp    801d11 <__umoddi3+0xa1>
