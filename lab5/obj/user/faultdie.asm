
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 53 00 00 00       	call   800084 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	52                   	push   %edx
  800044:	ff 30                	pushl  (%eax)
  800046:	68 a0 1e 80 00       	push   $0x801ea0
  80004b:	e8 30 01 00 00       	call   800180 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 18 0b 00 00       	call   800b6d <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 ee 0a 00 00       	call   800b4b <sys_env_destroy>
  80005d:	83 c4 10             	add    $0x10,%esp
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <umain>:

void
umain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800068:	68 34 00 80 00       	push   $0x800034
  80006d:	e8 86 0c 00 00       	call   800cf8 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800072:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800079:	00 00 00 
  80007c:	83 c4 10             	add    $0x10,%esp
}
  80007f:	c9                   	leave  
  800080:	c3                   	ret    
  800081:	00 00                	add    %al,(%eax)
	...

00800084 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	8b 75 08             	mov    0x8(%ebp),%esi
  80008c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80008f:	e8 d9 0a 00 00       	call   800b6d <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a0:	c1 e0 07             	shl    $0x7,%eax
  8000a3:	29 d0                	sub    %edx,%eax
  8000a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000aa:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 07                	jle    8000ba <libmain+0x36>
		binaryname = argv[0];
  8000b3:	8b 03                	mov    (%ebx),%eax
  8000b5:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	56                   	push   %esi
  8000bf:	e8 9e ff ff ff       	call   800062 <umain>

	// exit gracefully
	exit();
  8000c4:	e8 0b 00 00 00       	call   8000d4 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
}
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	c9                   	leave  
  8000d2:	c3                   	ret    
	...

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000da:	e8 b7 0e 00 00       	call   800f96 <close_all>
	sys_env_destroy(0);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	6a 00                	push   $0x0
  8000e4:	e8 62 0a 00 00       	call   800b4b <sys_env_destroy>
  8000e9:	83 c4 10             	add    $0x10,%esp
}
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
	...

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 04             	sub    $0x4,%esp
  8000f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fa:	8b 03                	mov    (%ebx),%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800103:	40                   	inc    %eax
  800104:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800106:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010b:	75 1a                	jne    800127 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	68 ff 00 00 00       	push   $0xff
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	50                   	push   %eax
  800119:	e8 e3 09 00 00       	call   800b01 <sys_cputs>
		b->idx = 0;
  80011e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800124:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800127:	ff 43 04             	incl   0x4(%ebx)
}
  80012a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800138:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013f:	00 00 00 
	b.cnt = 0;
  800142:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800149:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800158:	50                   	push   %eax
  800159:	68 f0 00 80 00       	push   $0x8000f0
  80015e:	e8 82 01 00 00       	call   8002e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800163:	83 c4 08             	add    $0x8,%esp
  800166:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80016c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800172:	50                   	push   %eax
  800173:	e8 89 09 00 00       	call   800b01 <sys_cputs>

	return b.cnt;
}
  800178:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800186:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800189:	50                   	push   %eax
  80018a:	ff 75 08             	pushl  0x8(%ebp)
  80018d:	e8 9d ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 2c             	sub    $0x2c,%esp
  80019d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a0:	89 d6                	mov    %edx,%esi
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001c4:	72 0c                	jb     8001d2 <printnum+0x3e>
  8001c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001c9:	76 07                	jbe    8001d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cb:	4b                   	dec    %ebx
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7f 31                	jg     800201 <printnum+0x6d>
  8001d0:	eb 3f                	jmp    800211 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	57                   	push   %edi
  8001d6:	4b                   	dec    %ebx
  8001d7:	53                   	push   %ebx
  8001d8:	50                   	push   %eax
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001df:	ff 75 d0             	pushl  -0x30(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 57 1a 00 00       	call   801c44 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f7:	e8 98 ff ff ff       	call   800194 <printnum>
  8001fc:	83 c4 20             	add    $0x20,%esp
  8001ff:	eb 10                	jmp    800211 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	57                   	push   %edi
  800206:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800209:	4b                   	dec    %ebx
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	85 db                	test   %ebx,%ebx
  80020f:	7f f0                	jg     800201 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	83 ec 04             	sub    $0x4,%esp
  800218:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021b:	ff 75 d0             	pushl  -0x30(%ebp)
  80021e:	ff 75 dc             	pushl  -0x24(%ebp)
  800221:	ff 75 d8             	pushl  -0x28(%ebp)
  800224:	e8 37 1b 00 00       	call   801d60 <__umoddi3>
  800229:	83 c4 14             	add    $0x14,%esp
  80022c:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  800233:	50                   	push   %eax
  800234:	ff 55 e4             	call   *-0x1c(%ebp)
  800237:	83 c4 10             	add    $0x10,%esp
}
  80023a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023d:	5b                   	pop    %ebx
  80023e:	5e                   	pop    %esi
  80023f:	5f                   	pop    %edi
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800245:	83 fa 01             	cmp    $0x1,%edx
  800248:	7e 0e                	jle    800258 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024f:	89 08                	mov    %ecx,(%eax)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	8b 52 04             	mov    0x4(%edx),%edx
  800256:	eb 22                	jmp    80027a <getuint+0x38>
	else if (lflag)
  800258:	85 d2                	test   %edx,%edx
  80025a:	74 10                	je     80026c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
  80026a:	eb 0e                	jmp    80027a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027f:	83 fa 01             	cmp    $0x1,%edx
  800282:	7e 0e                	jle    800292 <getint+0x16>
		return va_arg(*ap, long long);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 08             	lea    0x8(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	8b 52 04             	mov    0x4(%edx),%edx
  800290:	eb 1a                	jmp    8002ac <getint+0x30>
	else if (lflag)
  800292:	85 d2                	test   %edx,%edx
  800294:	74 0c                	je     8002a2 <getint+0x26>
		return va_arg(*ap, long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	99                   	cltd   
  8002a0:	eb 0a                	jmp    8002ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	99                   	cltd   
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 08                	jae    8002c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c1:	88 0a                	mov    %cl,(%edx)
  8002c3:	42                   	inc    %edx
  8002c4:	89 10                	mov    %edx,(%eax)
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d1:	50                   	push   %eax
  8002d2:	ff 75 10             	pushl  0x10(%ebp)
  8002d5:	ff 75 0c             	pushl  0xc(%ebp)
  8002d8:	ff 75 08             	pushl  0x8(%ebp)
  8002db:	e8 05 00 00 00       	call   8002e5 <vprintfmt>
	va_end(ap);
  8002e0:	83 c4 10             	add    $0x10,%esp
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 2c             	sub    $0x2c,%esp
  8002ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f4:	eb 13                	jmp    800309 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	0f 84 6d 03 00 00    	je     80066b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	57                   	push   %edi
  800302:	50                   	push   %eax
  800303:	ff 55 08             	call   *0x8(%ebp)
  800306:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 06             	movzbl (%esi),%eax
  80030c:	46                   	inc    %esi
  80030d:	83 f8 25             	cmp    $0x25,%eax
  800310:	75 e4                	jne    8002f6 <vprintfmt+0x11>
  800312:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800316:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80031d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800324:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800330:	eb 28                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800338:	eb 20                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800340:	eb 18                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800344:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034b:	eb 0d                	jmp    80035a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800353:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8a 06                	mov    (%esi),%al
  80035c:	0f b6 d0             	movzbl %al,%edx
  80035f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800362:	83 e8 23             	sub    $0x23,%eax
  800365:	3c 55                	cmp    $0x55,%al
  800367:	0f 87 e0 02 00 00    	ja     80064d <vprintfmt+0x368>
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800377:	83 ea 30             	sub    $0x30,%edx
  80037a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80037d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800380:	8d 50 d0             	lea    -0x30(%eax),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 44                	ja     8003cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	89 de                	mov    %ebx,%esi
  80038a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80038e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800391:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800395:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800398:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80039b:	83 fb 09             	cmp    $0x9,%ebx
  80039e:	76 ed                	jbe    80038d <vprintfmt+0xa8>
  8003a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003a3:	eb 29                	jmp    8003ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b5:	eb 17                	jmp    8003ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bb:	78 85                	js     800342 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	89 de                	mov    %ebx,%esi
  8003bf:	eb 99                	jmp    80035a <vprintfmt+0x75>
  8003c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ca:	eb 8e                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d2:	79 86                	jns    80035a <vprintfmt+0x75>
  8003d4:	e9 74 ff ff ff       	jmp    80034d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	e9 79 ff ff ff       	jmp    80035a <vprintfmt+0x75>
  8003e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	57                   	push   %edi
  8003f1:	ff 30                	pushl  (%eax)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 08 ff ff ff       	jmp    800309 <vprintfmt+0x24>
  800401:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	85 c0                	test   %eax,%eax
  800411:	79 02                	jns    800415 <vprintfmt+0x130>
  800413:	f7 d8                	neg    %eax
  800415:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800417:	83 f8 0f             	cmp    $0xf,%eax
  80041a:	7f 0b                	jg     800427 <vprintfmt+0x142>
  80041c:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	75 1a                	jne    800441 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800427:	52                   	push   %edx
  800428:	68 de 1e 80 00       	push   $0x801ede
  80042d:	57                   	push   %edi
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	e8 92 fe ff ff       	call   8002c8 <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043c:	e9 c8 fe ff ff       	jmp    800309 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800441:	50                   	push   %eax
  800442:	68 e7 22 80 00       	push   $0x8022e7
  800447:	57                   	push   %edi
  800448:	ff 75 08             	pushl  0x8(%ebp)
  80044b:	e8 78 fe ff ff       	call   8002c8 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800456:	e9 ae fe ff ff       	jmp    800309 <vprintfmt+0x24>
  80045b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80045e:	89 de                	mov    %ebx,%esi
  800460:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800463:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800474:	85 c0                	test   %eax,%eax
  800476:	75 07                	jne    80047f <vprintfmt+0x19a>
				p = "(null)";
  800478:	c7 45 d0 d7 1e 80 00 	movl   $0x801ed7,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80047f:	85 db                	test   %ebx,%ebx
  800481:	7e 42                	jle    8004c5 <vprintfmt+0x1e0>
  800483:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800487:	74 3c                	je     8004c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	51                   	push   %ecx
  80048d:	ff 75 d0             	pushl  -0x30(%ebp)
  800490:	e8 6f 02 00 00       	call   800704 <strnlen>
  800495:	29 c3                	sub    %eax,%ebx
  800497:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 db                	test   %ebx,%ebx
  80049f:	7e 24                	jle    8004c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	57                   	push   %edi
  8004af:	53                   	push   %ebx
  8004b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	4e                   	dec    %esi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	7f f0                	jg     8004ab <vprintfmt+0x1c6>
  8004bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c8:	0f be 02             	movsbl (%edx),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	75 47                	jne    800516 <vprintfmt+0x231>
  8004cf:	eb 37                	jmp    800508 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d5:	74 16                	je     8004ed <vprintfmt+0x208>
  8004d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004da:	83 fa 5e             	cmp    $0x5e,%edx
  8004dd:	76 0e                	jbe    8004ed <vprintfmt+0x208>
					putch('?', putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	57                   	push   %edi
  8004e3:	6a 3f                	push   $0x3f
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb 0b                	jmp    8004f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	57                   	push   %edi
  8004f1:	50                   	push   %eax
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004fb:	0f be 03             	movsbl (%ebx),%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	74 03                	je     800505 <vprintfmt+0x220>
  800502:	43                   	inc    %ebx
  800503:	eb 1b                	jmp    800520 <vprintfmt+0x23b>
  800505:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	7f 1e                	jg     80052c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800511:	e9 f3 fd ff ff       	jmp    800309 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800516:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800519:	43                   	inc    %ebx
  80051a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80051d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800520:	85 f6                	test   %esi,%esi
  800522:	78 ad                	js     8004d1 <vprintfmt+0x1ec>
  800524:	4e                   	dec    %esi
  800525:	79 aa                	jns    8004d1 <vprintfmt+0x1ec>
  800527:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80052a:	eb dc                	jmp    800508 <vprintfmt+0x223>
  80052c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	6a 20                	push   $0x20
  800535:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800538:	4b                   	dec    %ebx
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	85 db                	test   %ebx,%ebx
  80053e:	7f ef                	jg     80052f <vprintfmt+0x24a>
  800540:	e9 c4 fd ff ff       	jmp    800309 <vprintfmt+0x24>
  800545:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800548:	89 ca                	mov    %ecx,%edx
  80054a:	8d 45 14             	lea    0x14(%ebp),%eax
  80054d:	e8 2a fd ff ff       	call   80027c <getint>
  800552:	89 c3                	mov    %eax,%ebx
  800554:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800556:	85 d2                	test   %edx,%edx
  800558:	78 0a                	js     800564 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055f:	e9 b0 00 00 00       	jmp    800614 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	57                   	push   %edi
  800568:	6a 2d                	push   $0x2d
  80056a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056d:	f7 db                	neg    %ebx
  80056f:	83 d6 00             	adc    $0x0,%esi
  800572:	f7 de                	neg    %esi
  800574:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800577:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057c:	e9 93 00 00 00       	jmp    800614 <vprintfmt+0x32f>
  800581:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	89 ca                	mov    %ecx,%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 b4 fc ff ff       	call   800242 <getuint>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	89 d6                	mov    %edx,%esi
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800597:	eb 7b                	jmp    800614 <vprintfmt+0x32f>
  800599:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80059c:	89 ca                	mov    %ecx,%edx
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 d6 fc ff ff       	call   80027c <getint>
  8005a6:	89 c3                	mov    %eax,%ebx
  8005a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	78 07                	js     8005b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b3:	eb 5f                	jmp    800614 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	57                   	push   %edi
  8005b9:	6a 2d                	push   $0x2d
  8005bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005be:	f7 db                	neg    %ebx
  8005c0:	83 d6 00             	adc    $0x0,%esi
  8005c3:	f7 de                	neg    %esi
  8005c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005cd:	eb 45                	jmp    800614 <vprintfmt+0x32f>
  8005cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	57                   	push   %edi
  8005d6:	6a 30                	push   $0x30
  8005d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 78                	push   $0x78
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ed:	8b 18                	mov    (%eax),%ebx
  8005ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005fc:	eb 16                	jmp    800614 <vprintfmt+0x32f>
  8005fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800601:	89 ca                	mov    %ecx,%edx
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 37 fc ff ff       	call   800242 <getuint>
  80060b:	89 c3                	mov    %eax,%ebx
  80060d:	89 d6                	mov    %edx,%esi
			base = 16;
  80060f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80061b:	52                   	push   %edx
  80061c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061f:	50                   	push   %eax
  800620:	56                   	push   %esi
  800621:	53                   	push   %ebx
  800622:	89 fa                	mov    %edi,%edx
  800624:	8b 45 08             	mov    0x8(%ebp),%eax
  800627:	e8 68 fb ff ff       	call   800194 <printnum>
			break;
  80062c:	83 c4 20             	add    $0x20,%esp
  80062f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800632:	e9 d2 fc ff ff       	jmp    800309 <vprintfmt+0x24>
  800637:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	57                   	push   %edi
  80063e:	52                   	push   %edx
  80063f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800648:	e9 bc fc ff ff       	jmp    800309 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	57                   	push   %edi
  800651:	6a 25                	push   $0x25
  800653:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 02                	jmp    80065d <vprintfmt+0x378>
  80065b:	89 c6                	mov    %eax,%esi
  80065d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800660:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800664:	75 f5                	jne    80065b <vprintfmt+0x376>
  800666:	e9 9e fc ff ff       	jmp    800309 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	c9                   	leave  
  800672:	c3                   	ret    

00800673 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	83 ec 18             	sub    $0x18,%esp
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800682:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800686:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800690:	85 c0                	test   %eax,%eax
  800692:	74 26                	je     8006ba <vsnprintf+0x47>
  800694:	85 d2                	test   %edx,%edx
  800696:	7e 29                	jle    8006c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800698:	ff 75 14             	pushl  0x14(%ebp)
  80069b:	ff 75 10             	pushl  0x10(%ebp)
  80069e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	68 ae 02 80 00       	push   $0x8002ae
  8006a7:	e8 39 fc ff ff       	call   8002e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	eb 0c                	jmp    8006c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bf:	eb 05                	jmp    8006c6 <vsnprintf+0x53>
  8006c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	ff 75 08             	pushl  0x8(%ebp)
  8006db:	e8 93 ff ff ff       	call   800673 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    
	...

008006e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ed:	74 0e                	je     8006fd <strlen+0x19>
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f9:	75 f9                	jne    8006f4 <strlen+0x10>
  8006fb:	eb 05                	jmp    800702 <strlen+0x1e>
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	85 d2                	test   %edx,%edx
  80070f:	74 17                	je     800728 <strnlen+0x24>
  800711:	80 39 00             	cmpb   $0x0,(%ecx)
  800714:	74 19                	je     80072f <strnlen+0x2b>
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80071b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071c:	39 d0                	cmp    %edx,%eax
  80071e:	74 14                	je     800734 <strnlen+0x30>
  800720:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800724:	75 f5                	jne    80071b <strnlen+0x17>
  800726:	eb 0c                	jmp    800734 <strnlen+0x30>
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	eb 05                	jmp    800734 <strnlen+0x30>
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	ba 00 00 00 00       	mov    $0x0,%edx
  800745:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800748:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80074b:	42                   	inc    %edx
  80074c:	84 c9                	test   %cl,%cl
  80074e:	75 f5                	jne    800745 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800750:	5b                   	pop    %ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075a:	53                   	push   %ebx
  80075b:	e8 84 ff ff ff       	call   8006e4 <strlen>
  800760:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800763:	ff 75 0c             	pushl  0xc(%ebp)
  800766:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800769:	50                   	push   %eax
  80076a:	e8 c7 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800784:	85 f6                	test   %esi,%esi
  800786:	74 15                	je     80079d <strncpy+0x27>
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80078d:	8a 1a                	mov    (%edx),%bl
  80078f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800792:	80 3a 01             	cmpb   $0x1,(%edx)
  800795:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800798:	41                   	inc    %ecx
  800799:	39 ce                	cmp    %ecx,%esi
  80079b:	77 f0                	ja     80078d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	57                   	push   %edi
  8007a5:	56                   	push   %esi
  8007a6:	53                   	push   %ebx
  8007a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b0:	85 f6                	test   %esi,%esi
  8007b2:	74 32                	je     8007e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007b4:	83 fe 01             	cmp    $0x1,%esi
  8007b7:	74 22                	je     8007db <strlcpy+0x3a>
  8007b9:	8a 0b                	mov    (%ebx),%cl
  8007bb:	84 c9                	test   %cl,%cl
  8007bd:	74 20                	je     8007df <strlcpy+0x3e>
  8007bf:	89 f8                	mov    %edi,%eax
  8007c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c9:	88 08                	mov    %cl,(%eax)
  8007cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cc:	39 f2                	cmp    %esi,%edx
  8007ce:	74 11                	je     8007e1 <strlcpy+0x40>
  8007d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007d4:	42                   	inc    %edx
  8007d5:	84 c9                	test   %cl,%cl
  8007d7:	75 f0                	jne    8007c9 <strlcpy+0x28>
  8007d9:	eb 06                	jmp    8007e1 <strlcpy+0x40>
  8007db:	89 f8                	mov    %edi,%eax
  8007dd:	eb 02                	jmp    8007e1 <strlcpy+0x40>
  8007df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 00 00             	movb   $0x0,(%eax)
  8007e4:	eb 02                	jmp    8007e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007e8:	29 f8                	sub    %edi,%eax
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	8a 01                	mov    (%ecx),%al
  8007fa:	84 c0                	test   %al,%al
  8007fc:	74 10                	je     80080e <strcmp+0x1f>
  8007fe:	3a 02                	cmp    (%edx),%al
  800800:	75 0c                	jne    80080e <strcmp+0x1f>
		p++, q++;
  800802:	41                   	inc    %ecx
  800803:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800804:	8a 01                	mov    (%ecx),%al
  800806:	84 c0                	test   %al,%al
  800808:	74 04                	je     80080e <strcmp+0x1f>
  80080a:	3a 02                	cmp    (%edx),%al
  80080c:	74 f4                	je     800802 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 c0             	movzbl %al,%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 55 08             	mov    0x8(%ebp),%edx
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 1b                	je     800844 <strncmp+0x2c>
  800829:	8a 1a                	mov    (%edx),%bl
  80082b:	84 db                	test   %bl,%bl
  80082d:	74 24                	je     800853 <strncmp+0x3b>
  80082f:	3a 19                	cmp    (%ecx),%bl
  800831:	75 20                	jne    800853 <strncmp+0x3b>
  800833:	48                   	dec    %eax
  800834:	74 15                	je     80084b <strncmp+0x33>
		n--, p++, q++;
  800836:	42                   	inc    %edx
  800837:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800838:	8a 1a                	mov    (%edx),%bl
  80083a:	84 db                	test   %bl,%bl
  80083c:	74 15                	je     800853 <strncmp+0x3b>
  80083e:	3a 19                	cmp    (%ecx),%bl
  800840:	74 f1                	je     800833 <strncmp+0x1b>
  800842:	eb 0f                	jmp    800853 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
  800849:	eb 05                	jmp    800850 <strncmp+0x38>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800850:	5b                   	pop    %ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 02             	movzbl (%edx),%eax
  800856:	0f b6 11             	movzbl (%ecx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb f3                	jmp    800850 <strncmp+0x38>

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800866:	8a 10                	mov    (%eax),%dl
  800868:	84 d2                	test   %dl,%dl
  80086a:	74 18                	je     800884 <strchr+0x27>
		if (*s == c)
  80086c:	38 ca                	cmp    %cl,%dl
  80086e:	75 06                	jne    800876 <strchr+0x19>
  800870:	eb 17                	jmp    800889 <strchr+0x2c>
  800872:	38 ca                	cmp    %cl,%dl
  800874:	74 13                	je     800889 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800876:	40                   	inc    %eax
  800877:	8a 10                	mov    (%eax),%dl
  800879:	84 d2                	test   %dl,%dl
  80087b:	75 f5                	jne    800872 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	eb 05                	jmp    800889 <strchr+0x2c>
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800894:	8a 10                	mov    (%eax),%dl
  800896:	84 d2                	test   %dl,%dl
  800898:	74 11                	je     8008ab <strfind+0x20>
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	75 06                	jne    8008a4 <strfind+0x19>
  80089e:	eb 0b                	jmp    8008ab <strfind+0x20>
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 07                	je     8008ab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	40                   	inc    %eax
  8008a5:	8a 10                	mov    (%eax),%dl
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f5                	jne    8008a0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
  8008b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bc:	85 c9                	test   %ecx,%ecx
  8008be:	74 30                	je     8008f0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c6:	75 25                	jne    8008ed <memset+0x40>
  8008c8:	f6 c1 03             	test   $0x3,%cl
  8008cb:	75 20                	jne    8008ed <memset+0x40>
		c &= 0xFF;
  8008cd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d0:	89 d3                	mov    %edx,%ebx
  8008d2:	c1 e3 08             	shl    $0x8,%ebx
  8008d5:	89 d6                	mov    %edx,%esi
  8008d7:	c1 e6 18             	shl    $0x18,%esi
  8008da:	89 d0                	mov    %edx,%eax
  8008dc:	c1 e0 10             	shl    $0x10,%eax
  8008df:	09 f0                	or     %esi,%eax
  8008e1:	09 d0                	or     %edx,%eax
  8008e3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e8:	fc                   	cld    
  8008e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008eb:	eb 03                	jmp    8008f0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5f                   	pop    %edi
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800905:	39 c6                	cmp    %eax,%esi
  800907:	73 34                	jae    80093d <memmove+0x46>
  800909:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090c:	39 d0                	cmp    %edx,%eax
  80090e:	73 2d                	jae    80093d <memmove+0x46>
		s += n;
		d += n;
  800910:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 1b                	jne    800933 <memmove+0x3c>
  800918:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091e:	75 13                	jne    800933 <memmove+0x3c>
  800920:	f6 c1 03             	test   $0x3,%cl
  800923:	75 0e                	jne    800933 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800925:	83 ef 04             	sub    $0x4,%edi
  800928:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092e:	fd                   	std    
  80092f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800931:	eb 07                	jmp    80093a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800933:	4f                   	dec    %edi
  800934:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800937:	fd                   	std    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093a:	fc                   	cld    
  80093b:	eb 20                	jmp    80095d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800943:	75 13                	jne    800958 <memmove+0x61>
  800945:	a8 03                	test   $0x3,%al
  800947:	75 0f                	jne    800958 <memmove+0x61>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0a                	jne    800958 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb 05                	jmp    80095d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800964:	ff 75 10             	pushl  0x10(%ebp)
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	ff 75 08             	pushl  0x8(%ebp)
  80096d:	e8 85 ff ff ff       	call   8008f7 <memmove>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80097d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800980:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	85 ff                	test   %edi,%edi
  800985:	74 32                	je     8009b9 <memcmp+0x45>
		if (*s1 != *s2)
  800987:	8a 03                	mov    (%ebx),%al
  800989:	8a 0e                	mov    (%esi),%cl
  80098b:	38 c8                	cmp    %cl,%al
  80098d:	74 19                	je     8009a8 <memcmp+0x34>
  80098f:	eb 0d                	jmp    80099e <memcmp+0x2a>
  800991:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800995:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800999:	42                   	inc    %edx
  80099a:	38 c8                	cmp    %cl,%al
  80099c:	74 10                	je     8009ae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c0             	movzbl %al,%eax
  8009a1:	0f b6 c9             	movzbl %cl,%ecx
  8009a4:	29 c8                	sub    %ecx,%eax
  8009a6:	eb 16                	jmp    8009be <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a8:	4f                   	dec    %edi
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ae:	39 fa                	cmp    %edi,%edx
  8009b0:	75 df                	jne    800991 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb 05                	jmp    8009be <memcmp+0x4a>
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c9:	89 c2                	mov    %eax,%edx
  8009cb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ce:	39 d0                	cmp    %edx,%eax
  8009d0:	73 12                	jae    8009e4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009d5:	38 08                	cmp    %cl,(%eax)
  8009d7:	75 06                	jne    8009df <memfind+0x1c>
  8009d9:	eb 09                	jmp    8009e4 <memfind+0x21>
  8009db:	38 08                	cmp    %cl,(%eax)
  8009dd:	74 05                	je     8009e4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	40                   	inc    %eax
  8009e0:	39 c2                	cmp    %eax,%edx
  8009e2:	77 f7                	ja     8009db <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 01                	jmp    8009f5 <strtol+0xf>
		s++;
  8009f4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	8a 02                	mov    (%edx),%al
  8009f7:	3c 20                	cmp    $0x20,%al
  8009f9:	74 f9                	je     8009f4 <strtol+0xe>
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	74 f5                	je     8009f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ff:	3c 2b                	cmp    $0x2b,%al
  800a01:	75 08                	jne    800a0b <strtol+0x25>
		s++;
  800a03:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
  800a09:	eb 13                	jmp    800a1e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 0a                	jne    800a19 <strtol+0x33>
		s++, neg = 1;
  800a0f:	8d 52 01             	lea    0x1(%edx),%edx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi
  800a17:	eb 05                	jmp    800a1e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1e:	85 db                	test   %ebx,%ebx
  800a20:	74 05                	je     800a27 <strtol+0x41>
  800a22:	83 fb 10             	cmp    $0x10,%ebx
  800a25:	75 28                	jne    800a4f <strtol+0x69>
  800a27:	8a 02                	mov    (%edx),%al
  800a29:	3c 30                	cmp    $0x30,%al
  800a2b:	75 10                	jne    800a3d <strtol+0x57>
  800a2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a31:	75 0a                	jne    800a3d <strtol+0x57>
		s += 2, base = 16;
  800a33:	83 c2 02             	add    $0x2,%edx
  800a36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3b:	eb 12                	jmp    800a4f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	75 0e                	jne    800a4f <strtol+0x69>
  800a41:	3c 30                	cmp    $0x30,%al
  800a43:	75 05                	jne    800a4a <strtol+0x64>
		s++, base = 8;
  800a45:	42                   	inc    %edx
  800a46:	b3 08                	mov    $0x8,%bl
  800a48:	eb 05                	jmp    800a4f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	8a 0a                	mov    (%edx),%cl
  800a58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a5b:	80 fb 09             	cmp    $0x9,%bl
  800a5e:	77 08                	ja     800a68 <strtol+0x82>
			dig = *s - '0';
  800a60:	0f be c9             	movsbl %cl,%ecx
  800a63:	83 e9 30             	sub    $0x30,%ecx
  800a66:	eb 1e                	jmp    800a86 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a70:	0f be c9             	movsbl %cl,%ecx
  800a73:	83 e9 57             	sub    $0x57,%ecx
  800a76:	eb 0e                	jmp    800a86 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a7b:	80 fb 19             	cmp    $0x19,%bl
  800a7e:	77 13                	ja     800a93 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a80:	0f be c9             	movsbl %cl,%ecx
  800a83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a86:	39 f1                	cmp    %esi,%ecx
  800a88:	7d 0d                	jge    800a97 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a8a:	42                   	inc    %edx
  800a8b:	0f af c6             	imul   %esi,%eax
  800a8e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a91:	eb c3                	jmp    800a56 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a93:	89 c1                	mov    %eax,%ecx
  800a95:	eb 02                	jmp    800a99 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a97:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 05                	je     800aa4 <strtol+0xbe>
		*endptr = (char *) s;
  800a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aa4:	85 ff                	test   %edi,%edi
  800aa6:	74 04                	je     800aac <strtol+0xc6>
  800aa8:	89 c8                	mov    %ecx,%eax
  800aaa:	f7 d8                	neg    %eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    
  800ab1:	00 00                	add    %al,(%eax)
	...

00800ab4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	83 ec 1c             	sub    $0x1c,%esp
  800abd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ac0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ac3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	cd 30                	int    $0x30
  800ad3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ad9:	74 1c                	je     800af7 <syscall+0x43>
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 18                	jle    800af7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ae6:	68 bf 21 80 00       	push   $0x8021bf
  800aeb:	6a 42                	push   $0x42
  800aed:	68 dc 21 80 00       	push   $0x8021dc
  800af2:	e8 69 0f 00 00       	call   801a60 <_panic>

	return ret;
}
  800af7:	89 d0                	mov    %edx,%eax
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 0c             	pushl  0xc(%ebp)
  800b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	e8 92 ff ff ff       	call   800ab4 <syscall>
  800b22:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	e8 6b ff ff ff       	call   800ab4 <syscall>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b61:	b8 03 00 00 00       	mov    $0x3,%eax
  800b66:	e8 49 ff ff ff       	call   800ab4 <syscall>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	e8 25 ff ff ff       	call   800ab4 <syscall>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sys_yield>:

void
sys_yield(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	6a 00                	push   $0x0
  800b9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bae:	e8 01 ff ff ff       	call   800ab4 <syscall>
  800bb3:	83 c4 10             	add    $0x10,%esp
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd5:	e8 da fe ff ff       	call   800ab4 <syscall>
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800be2:	ff 75 18             	pushl  0x18(%ebp)
  800be5:	ff 75 14             	pushl  0x14(%ebp)
  800be8:	ff 75 10             	pushl  0x10(%ebp)
  800beb:	ff 75 0c             	pushl  0xc(%ebp)
  800bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf1:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	e8 b4 fe ff ff       	call   800ab4 <syscall>
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	6a 00                	push   $0x0
  800c0e:	ff 75 0c             	pushl  0xc(%ebp)
  800c11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c14:	ba 01 00 00 00       	mov    $0x1,%edx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	e8 91 fe ff ff       	call   800ab4 <syscall>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c41:	e8 6e fe ff ff       	call   800ab4 <syscall>
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c4e:	6a 00                	push   $0x0
  800c50:	6a 00                	push   $0x0
  800c52:	6a 00                	push   $0x0
  800c54:	ff 75 0c             	pushl  0xc(%ebp)
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	e8 4b fe ff ff       	call   800ab4 <syscall>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	ff 75 0c             	pushl  0xc(%ebp)
  800c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c87:	e8 28 fe ff ff       	call   800ab4 <syscall>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c94:	6a 00                	push   $0x0
  800c96:	ff 75 14             	pushl  0x14(%ebp)
  800c99:	ff 75 10             	pushl  0x10(%ebp)
  800c9c:	ff 75 0c             	pushl  0xc(%ebp)
  800c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cac:	e8 03 fe ff ff       	call   800ab4 <syscall>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cce:	e8 e1 fd ff ff       	call   800ab4 <syscall>
}
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	6a 00                	push   $0x0
  800ce1:	ff 75 0c             	pushl  0xc(%ebp)
  800ce4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf1:	e8 be fd ff ff       	call   800ab4 <syscall>
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cfe:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d05:	75 52                	jne    800d59 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d07:	83 ec 04             	sub    $0x4,%esp
  800d0a:	6a 07                	push   $0x7
  800d0c:	68 00 f0 bf ee       	push   $0xeebff000
  800d11:	6a 00                	push   $0x0
  800d13:	e8 a0 fe ff ff       	call   800bb8 <sys_page_alloc>
		if (r < 0) {
  800d18:	83 c4 10             	add    $0x10,%esp
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	79 12                	jns    800d31 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d1f:	50                   	push   %eax
  800d20:	68 ea 21 80 00       	push   $0x8021ea
  800d25:	6a 24                	push   $0x24
  800d27:	68 05 22 80 00       	push   $0x802205
  800d2c:	e8 2f 0d 00 00       	call   801a60 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d31:	83 ec 08             	sub    $0x8,%esp
  800d34:	68 64 0d 80 00       	push   $0x800d64
  800d39:	6a 00                	push   $0x0
  800d3b:	e8 2b ff ff ff       	call   800c6b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	79 12                	jns    800d59 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d47:	50                   	push   %eax
  800d48:	68 14 22 80 00       	push   $0x802214
  800d4d:	6a 2a                	push   $0x2a
  800d4f:	68 05 22 80 00       	push   $0x802205
  800d54:	e8 07 0d 00 00       	call   801a60 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    
	...

00800d64 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d64:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d65:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d6a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d6c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800d6f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d73:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d76:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800d7a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800d7e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800d80:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800d83:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800d84:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800d87:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d88:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800d89:	c3                   	ret    
	...

00800d8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	05 00 00 00 30       	add    $0x30000000,%eax
  800d97:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 e5 ff ff ff       	call   800d8c <fd2num>
  800da7:	83 c4 04             	add    $0x4,%esp
  800daa:	05 20 00 0d 00       	add    $0xd0020,%eax
  800daf:	c1 e0 0c             	shl    $0xc,%eax
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	53                   	push   %ebx
  800db8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dbb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800dc0:	a8 01                	test   $0x1,%al
  800dc2:	74 34                	je     800df8 <fd_alloc+0x44>
  800dc4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800dc9:	a8 01                	test   $0x1,%al
  800dcb:	74 32                	je     800dff <fd_alloc+0x4b>
  800dcd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	89 c2                	mov    %eax,%edx
  800dd6:	c1 ea 16             	shr    $0x16,%edx
  800dd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de0:	f6 c2 01             	test   $0x1,%dl
  800de3:	74 1f                	je     800e04 <fd_alloc+0x50>
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 0c             	shr    $0xc,%edx
  800dea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	75 17                	jne    800e0d <fd_alloc+0x59>
  800df6:	eb 0c                	jmp    800e04 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800df8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800dfd:	eb 05                	jmp    800e04 <fd_alloc+0x50>
  800dff:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e04:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	eb 17                	jmp    800e24 <fd_alloc+0x70>
  800e0d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e12:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e17:	75 b9                	jne    800dd2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e1f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e24:	5b                   	pop    %ebx
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    

00800e27 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e2d:	83 f8 1f             	cmp    $0x1f,%eax
  800e30:	77 36                	ja     800e68 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e32:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e37:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	c1 ea 16             	shr    $0x16,%edx
  800e3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e46:	f6 c2 01             	test   $0x1,%dl
  800e49:	74 24                	je     800e6f <fd_lookup+0x48>
  800e4b:	89 c2                	mov    %eax,%edx
  800e4d:	c1 ea 0c             	shr    $0xc,%edx
  800e50:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e57:	f6 c2 01             	test   $0x1,%dl
  800e5a:	74 1a                	je     800e76 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5f:	89 02                	mov    %eax,(%edx)
	return 0;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	eb 13                	jmp    800e7b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6d:	eb 0c                	jmp    800e7b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e74:	eb 05                	jmp    800e7b <fd_lookup+0x54>
  800e76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	53                   	push   %ebx
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e8a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e90:	74 0d                	je     800e9f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 14                	jmp    800ead <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e99:	39 0a                	cmp    %ecx,(%edx)
  800e9b:	75 10                	jne    800ead <dev_lookup+0x30>
  800e9d:	eb 05                	jmp    800ea4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ea4:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	eb 31                	jmp    800ede <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ead:	40                   	inc    %eax
  800eae:	8b 14 85 b8 22 80 00 	mov    0x8022b8(,%eax,4),%edx
  800eb5:	85 d2                	test   %edx,%edx
  800eb7:	75 e0                	jne    800e99 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ebe:	8b 40 48             	mov    0x48(%eax),%eax
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	51                   	push   %ecx
  800ec5:	50                   	push   %eax
  800ec6:	68 3c 22 80 00       	push   $0x80223c
  800ecb:	e8 b0 f2 ff ff       	call   800180 <cprintf>
	*dev = 0;
  800ed0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 20             	sub    $0x20,%esp
  800eeb:	8b 75 08             	mov    0x8(%ebp),%esi
  800eee:	8a 45 0c             	mov    0xc(%ebp),%al
  800ef1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef4:	56                   	push   %esi
  800ef5:	e8 92 fe ff ff       	call   800d8c <fd2num>
  800efa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800efd:	89 14 24             	mov    %edx,(%esp)
  800f00:	50                   	push   %eax
  800f01:	e8 21 ff ff ff       	call   800e27 <fd_lookup>
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	78 05                	js     800f14 <fd_close+0x31>
	    || fd != fd2)
  800f0f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f12:	74 0d                	je     800f21 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f14:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f18:	75 48                	jne    800f62 <fd_close+0x7f>
  800f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1f:	eb 41                	jmp    800f62 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f21:	83 ec 08             	sub    $0x8,%esp
  800f24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f27:	50                   	push   %eax
  800f28:	ff 36                	pushl  (%esi)
  800f2a:	e8 4e ff ff ff       	call   800e7d <dev_lookup>
  800f2f:	89 c3                	mov    %eax,%ebx
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 1c                	js     800f54 <fd_close+0x71>
		if (dev->dev_close)
  800f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3b:	8b 40 10             	mov    0x10(%eax),%eax
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	74 0d                	je     800f4f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	56                   	push   %esi
  800f46:	ff d0                	call   *%eax
  800f48:	89 c3                	mov    %eax,%ebx
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	eb 05                	jmp    800f54 <fd_close+0x71>
		else
			r = 0;
  800f4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 a3 fc ff ff       	call   800c02 <sys_page_unmap>
	return r;
  800f5f:	83 c4 10             	add    $0x10,%esp
}
  800f62:	89 d8                	mov    %ebx,%eax
  800f64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 08             	pushl  0x8(%ebp)
  800f78:	e8 aa fe ff ff       	call   800e27 <fd_lookup>
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 10                	js     800f94 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	6a 01                	push   $0x1
  800f89:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8c:	e8 52 ff ff ff       	call   800ee3 <fd_close>
  800f91:	83 c4 10             	add    $0x10,%esp
}
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <close_all>:

void
close_all(void)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	53                   	push   %ebx
  800fa6:	e8 c0 ff ff ff       	call   800f6b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fab:	43                   	inc    %ebx
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	83 fb 20             	cmp    $0x20,%ebx
  800fb2:	75 ee                	jne    800fa2 <close_all+0xc>
		close(i);
}
  800fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 2c             	sub    $0x2c,%esp
  800fc2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 56 fe ff ff       	call   800e27 <fd_lookup>
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	0f 88 c0 00 00 00    	js     80109e <dup+0xe5>
		return r;
	close(newfdnum);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	57                   	push   %edi
  800fe2:	e8 84 ff ff ff       	call   800f6b <close>

	newfd = INDEX2FD(newfdnum);
  800fe7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fed:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800ff0:	83 c4 04             	add    $0x4,%esp
  800ff3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff6:	e8 a1 fd ff ff       	call   800d9c <fd2data>
  800ffb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ffd:	89 34 24             	mov    %esi,(%esp)
  801000:	e8 97 fd ff ff       	call   800d9c <fd2data>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	c1 e8 16             	shr    $0x16,%eax
  801010:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801017:	a8 01                	test   $0x1,%al
  801019:	74 37                	je     801052 <dup+0x99>
  80101b:	89 d8                	mov    %ebx,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
  801020:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801027:	f6 c2 01             	test   $0x1,%dl
  80102a:	74 26                	je     801052 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	25 07 0e 00 00       	and    $0xe07,%eax
  80103b:	50                   	push   %eax
  80103c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	53                   	push   %ebx
  801042:	6a 00                	push   $0x0
  801044:	e8 93 fb ff ff       	call   800bdc <sys_page_map>
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	83 c4 20             	add    $0x20,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 2d                	js     80107f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801055:	89 c2                	mov    %eax,%edx
  801057:	c1 ea 0c             	shr    $0xc,%edx
  80105a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80106a:	52                   	push   %edx
  80106b:	56                   	push   %esi
  80106c:	6a 00                	push   $0x0
  80106e:	50                   	push   %eax
  80106f:	6a 00                	push   $0x0
  801071:	e8 66 fb ff ff       	call   800bdc <sys_page_map>
  801076:	89 c3                	mov    %eax,%ebx
  801078:	83 c4 20             	add    $0x20,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 1d                	jns    80109c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80107f:	83 ec 08             	sub    $0x8,%esp
  801082:	56                   	push   %esi
  801083:	6a 00                	push   $0x0
  801085:	e8 78 fb ff ff       	call   800c02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801090:	6a 00                	push   $0x0
  801092:	e8 6b fb ff ff       	call   800c02 <sys_page_unmap>
	return r;
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	eb 02                	jmp    80109e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80109c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80109e:	89 d8                	mov    %ebx,%eax
  8010a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5e                   	pop    %esi
  8010a5:	5f                   	pop    %edi
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 14             	sub    $0x14,%esp
  8010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	53                   	push   %ebx
  8010b7:	e8 6b fd ff ff       	call   800e27 <fd_lookup>
  8010bc:	83 c4 08             	add    $0x8,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 67                	js     80112a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cd:	ff 30                	pushl  (%eax)
  8010cf:	e8 a9 fd ff ff       	call   800e7d <dev_lookup>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 4f                	js     80112a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010de:	8b 50 08             	mov    0x8(%eax),%edx
  8010e1:	83 e2 03             	and    $0x3,%edx
  8010e4:	83 fa 01             	cmp    $0x1,%edx
  8010e7:	75 21                	jne    80110a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ee:	8b 40 48             	mov    0x48(%eax),%eax
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	50                   	push   %eax
  8010f6:	68 7d 22 80 00       	push   $0x80227d
  8010fb:	e8 80 f0 ff ff       	call   800180 <cprintf>
		return -E_INVAL;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801108:	eb 20                	jmp    80112a <read+0x82>
	}
	if (!dev->dev_read)
  80110a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80110d:	8b 52 08             	mov    0x8(%edx),%edx
  801110:	85 d2                	test   %edx,%edx
  801112:	74 11                	je     801125 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	ff 75 10             	pushl  0x10(%ebp)
  80111a:	ff 75 0c             	pushl  0xc(%ebp)
  80111d:	50                   	push   %eax
  80111e:	ff d2                	call   *%edx
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	eb 05                	jmp    80112a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801125:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80112a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113e:	85 f6                	test   %esi,%esi
  801140:	74 31                	je     801173 <readn+0x44>
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	89 f2                	mov    %esi,%edx
  801151:	29 c2                	sub    %eax,%edx
  801153:	52                   	push   %edx
  801154:	03 45 0c             	add    0xc(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	57                   	push   %edi
  801159:	e8 4a ff ff ff       	call   8010a8 <read>
		if (m < 0)
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	78 17                	js     80117c <readn+0x4d>
			return m;
		if (m == 0)
  801165:	85 c0                	test   %eax,%eax
  801167:	74 11                	je     80117a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801169:	01 c3                	add    %eax,%ebx
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	39 f3                	cmp    %esi,%ebx
  80116f:	72 db                	jb     80114c <readn+0x1d>
  801171:	eb 09                	jmp    80117c <readn+0x4d>
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
  801178:	eb 02                	jmp    80117c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80117a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	c9                   	leave  
  801183:	c3                   	ret    

00801184 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	83 ec 14             	sub    $0x14,%esp
  80118b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	53                   	push   %ebx
  801193:	e8 8f fc ff ff       	call   800e27 <fd_lookup>
  801198:	83 c4 08             	add    $0x8,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 62                	js     801201 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a5:	50                   	push   %eax
  8011a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a9:	ff 30                	pushl  (%eax)
  8011ab:	e8 cd fc ff ff       	call   800e7d <dev_lookup>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 4a                	js     801201 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011be:	75 21                	jne    8011e1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c5:	8b 40 48             	mov    0x48(%eax),%eax
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	53                   	push   %ebx
  8011cc:	50                   	push   %eax
  8011cd:	68 99 22 80 00       	push   $0x802299
  8011d2:	e8 a9 ef ff ff       	call   800180 <cprintf>
		return -E_INVAL;
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011df:	eb 20                	jmp    801201 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e7:	85 d2                	test   %edx,%edx
  8011e9:	74 11                	je     8011fc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	ff 75 10             	pushl  0x10(%ebp)
  8011f1:	ff 75 0c             	pushl  0xc(%ebp)
  8011f4:	50                   	push   %eax
  8011f5:	ff d2                	call   *%edx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	eb 05                	jmp    801201 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <seek>:

int
seek(int fdnum, off_t offset)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 0f fc ff ff       	call   800e27 <fd_lookup>
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 0e                	js     80122d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80121f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	53                   	push   %ebx
  801233:	83 ec 14             	sub    $0x14,%esp
  801236:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801239:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	53                   	push   %ebx
  80123e:	e8 e4 fb ff ff       	call   800e27 <fd_lookup>
  801243:	83 c4 08             	add    $0x8,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 5f                	js     8012a9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801254:	ff 30                	pushl  (%eax)
  801256:	e8 22 fc ff ff       	call   800e7d <dev_lookup>
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 47                	js     8012a9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801262:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801265:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801269:	75 21                	jne    80128c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80126b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801270:	8b 40 48             	mov    0x48(%eax),%eax
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	53                   	push   %ebx
  801277:	50                   	push   %eax
  801278:	68 5c 22 80 00       	push   $0x80225c
  80127d:	e8 fe ee ff ff       	call   800180 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128a:	eb 1d                	jmp    8012a9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80128c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128f:	8b 52 18             	mov    0x18(%edx),%edx
  801292:	85 d2                	test   %edx,%edx
  801294:	74 0e                	je     8012a4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	ff 75 0c             	pushl  0xc(%ebp)
  80129c:	50                   	push   %eax
  80129d:	ff d2                	call   *%edx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	eb 05                	jmp    8012a9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    

008012ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 14             	sub    $0x14,%esp
  8012b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	e8 63 fb ff ff       	call   800e27 <fd_lookup>
  8012c4:	83 c4 08             	add    $0x8,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 52                	js     80131d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	ff 30                	pushl  (%eax)
  8012d7:	e8 a1 fb ff ff       	call   800e7d <dev_lookup>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 3a                	js     80131d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ea:	74 2c                	je     801318 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f6:	00 00 00 
	stat->st_isdir = 0;
  8012f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801300:	00 00 00 
	stat->st_dev = dev;
  801303:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	53                   	push   %ebx
  80130d:	ff 75 f0             	pushl  -0x10(%ebp)
  801310:	ff 50 14             	call   *0x14(%eax)
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	eb 05                	jmp    80131d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801318:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	6a 00                	push   $0x0
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 8b 01 00 00       	call   8014bf <open>
  801334:	89 c3                	mov    %eax,%ebx
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 1b                	js     801358 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80133d:	83 ec 08             	sub    $0x8,%esp
  801340:	ff 75 0c             	pushl  0xc(%ebp)
  801343:	50                   	push   %eax
  801344:	e8 65 ff ff ff       	call   8012ae <fstat>
  801349:	89 c6                	mov    %eax,%esi
	close(fd);
  80134b:	89 1c 24             	mov    %ebx,(%esp)
  80134e:	e8 18 fc ff ff       	call   800f6b <close>
	return r;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	89 f3                	mov    %esi,%ebx
}
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	c9                   	leave  
  801360:	c3                   	ret    
  801361:	00 00                	add    %al,(%eax)
	...

00801364 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80136d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801374:	75 12                	jne    801388 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801376:	83 ec 0c             	sub    $0xc,%esp
  801379:	6a 01                	push   $0x1
  80137b:	e8 25 08 00 00       	call   801ba5 <ipc_find_env>
  801380:	a3 00 40 80 00       	mov    %eax,0x804000
  801385:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801388:	6a 07                	push   $0x7
  80138a:	68 00 50 80 00       	push   $0x805000
  80138f:	53                   	push   %ebx
  801390:	ff 35 00 40 80 00    	pushl  0x804000
  801396:	e8 b5 07 00 00       	call   801b50 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80139b:	83 c4 0c             	add    $0xc,%esp
  80139e:	6a 00                	push   $0x0
  8013a0:	56                   	push   %esi
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 00 07 00 00       	call   801aa8 <ipc_recv>
}
  8013a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ce:	e8 91 ff ff ff       	call   801364 <fsipc>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 39                	js     801410 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	68 c8 22 80 00       	push   $0x8022c8
  8013df:	e8 9c ed ff ff       	call   800180 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	68 00 50 80 00       	push   $0x805000
  8013ec:	53                   	push   %ebx
  8013ed:	e8 44 f3 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801402:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	8b 40 0c             	mov    0xc(%eax),%eax
  801421:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801426:	ba 00 00 00 00       	mov    $0x0,%edx
  80142b:	b8 06 00 00 00       	mov    $0x6,%eax
  801430:	e8 2f ff ff ff       	call   801364 <fsipc>
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	8b 40 0c             	mov    0xc(%eax),%eax
  801445:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801450:	ba 00 00 00 00       	mov    $0x0,%edx
  801455:	b8 03 00 00 00       	mov    $0x3,%eax
  80145a:	e8 05 ff ff ff       	call   801364 <fsipc>
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	85 c0                	test   %eax,%eax
  801463:	78 51                	js     8014b6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801465:	39 c6                	cmp    %eax,%esi
  801467:	73 19                	jae    801482 <devfile_read+0x4b>
  801469:	68 ce 22 80 00       	push   $0x8022ce
  80146e:	68 d5 22 80 00       	push   $0x8022d5
  801473:	68 80 00 00 00       	push   $0x80
  801478:	68 ea 22 80 00       	push   $0x8022ea
  80147d:	e8 de 05 00 00       	call   801a60 <_panic>
	assert(r <= PGSIZE);
  801482:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801487:	7e 19                	jle    8014a2 <devfile_read+0x6b>
  801489:	68 f5 22 80 00       	push   $0x8022f5
  80148e:	68 d5 22 80 00       	push   $0x8022d5
  801493:	68 81 00 00 00       	push   $0x81
  801498:	68 ea 22 80 00       	push   $0x8022ea
  80149d:	e8 be 05 00 00       	call   801a60 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	50                   	push   %eax
  8014a6:	68 00 50 80 00       	push   $0x805000
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	e8 44 f4 ff ff       	call   8008f7 <memmove>
	return r;
  8014b3:	83 c4 10             	add    $0x10,%esp
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 1c             	sub    $0x1c,%esp
  8014c7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ca:	56                   	push   %esi
  8014cb:	e8 14 f2 ff ff       	call   8006e4 <strlen>
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d8:	7f 72                	jg     80154c <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014da:	83 ec 0c             	sub    $0xc,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	e8 ce f8 ff ff       	call   800db4 <fd_alloc>
  8014e6:	89 c3                	mov    %eax,%ebx
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 62                	js     801551 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	56                   	push   %esi
  8014f3:	68 00 50 80 00       	push   $0x805000
  8014f8:	e8 39 f2 ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801500:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801505:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801508:	b8 01 00 00 00       	mov    $0x1,%eax
  80150d:	e8 52 fe ff ff       	call   801364 <fsipc>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	79 12                	jns    80152d <open+0x6e>
		fd_close(fd, 0);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	6a 00                	push   $0x0
  801520:	ff 75 f4             	pushl  -0xc(%ebp)
  801523:	e8 bb f9 ff ff       	call   800ee3 <fd_close>
		return r;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb 24                	jmp    801551 <open+0x92>
	}


	cprintf("OPEN\n");
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	68 01 23 80 00       	push   $0x802301
  801535:	e8 46 ec ff ff       	call   800180 <cprintf>

	return fd2num(fd);
  80153a:	83 c4 04             	add    $0x4,%esp
  80153d:	ff 75 f4             	pushl  -0xc(%ebp)
  801540:	e8 47 f8 ff ff       	call   800d8c <fd2num>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb 05                	jmp    801551 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80154c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801551:	89 d8                	mov    %ebx,%eax
  801553:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801556:	5b                   	pop    %ebx
  801557:	5e                   	pop    %esi
  801558:	c9                   	leave  
  801559:	c3                   	ret    
	...

0080155c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 2d f8 ff ff       	call   800d9c <fd2data>
  80156f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	68 07 23 80 00       	push   $0x802307
  801579:	56                   	push   %esi
  80157a:	e8 b7 f1 ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157f:	8b 43 04             	mov    0x4(%ebx),%eax
  801582:	2b 03                	sub    (%ebx),%eax
  801584:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80158a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801591:	00 00 00 
	stat->st_dev = &devpipe;
  801594:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80159b:	30 80 00 
	return 0;
}
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b4:	53                   	push   %ebx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 46 f6 ff ff       	call   800c02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	e8 d8 f7 ff ff       	call   800d9c <fd2data>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	50                   	push   %eax
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 33 f6 ff ff       	call   800c02 <sys_page_unmap>
}
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 1c             	sub    $0x1c,%esp
  8015dd:	89 c7                	mov    %eax,%edi
  8015df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	57                   	push   %edi
  8015ee:	e8 0d 06 00 00       	call   801c00 <pageref>
  8015f3:	89 c6                	mov    %eax,%esi
  8015f5:	83 c4 04             	add    $0x4,%esp
  8015f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fb:	e8 00 06 00 00       	call   801c00 <pageref>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	39 c6                	cmp    %eax,%esi
  801605:	0f 94 c0             	sete   %al
  801608:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80160b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801611:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801614:	39 cb                	cmp    %ecx,%ebx
  801616:	75 08                	jne    801620 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801620:	83 f8 01             	cmp    $0x1,%eax
  801623:	75 bd                	jne    8015e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801625:	8b 42 58             	mov    0x58(%edx),%eax
  801628:	6a 01                	push   $0x1
  80162a:	50                   	push   %eax
  80162b:	53                   	push   %ebx
  80162c:	68 0e 23 80 00       	push   $0x80230e
  801631:	e8 4a eb ff ff       	call   800180 <cprintf>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb a7                	jmp    8015e2 <_pipeisclosed+0xe>

0080163b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 28             	sub    $0x28,%esp
  801644:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801647:	56                   	push   %esi
  801648:	e8 4f f7 ff ff       	call   800d9c <fd2data>
  80164d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801656:	75 4a                	jne    8016a2 <devpipe_write+0x67>
  801658:	bf 00 00 00 00       	mov    $0x0,%edi
  80165d:	eb 56                	jmp    8016b5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80165f:	89 da                	mov    %ebx,%edx
  801661:	89 f0                	mov    %esi,%eax
  801663:	e8 6c ff ff ff       	call   8015d4 <_pipeisclosed>
  801668:	85 c0                	test   %eax,%eax
  80166a:	75 4d                	jne    8016b9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80166c:	e8 20 f5 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801671:	8b 43 04             	mov    0x4(%ebx),%eax
  801674:	8b 13                	mov    (%ebx),%edx
  801676:	83 c2 20             	add    $0x20,%edx
  801679:	39 d0                	cmp    %edx,%eax
  80167b:	73 e2                	jae    80165f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801685:	79 05                	jns    80168c <devpipe_write+0x51>
  801687:	4a                   	dec    %edx
  801688:	83 ca e0             	or     $0xffffffe0,%edx
  80168b:	42                   	inc    %edx
  80168c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801692:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801696:	40                   	inc    %eax
  801697:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169a:	47                   	inc    %edi
  80169b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80169e:	77 07                	ja     8016a7 <devpipe_write+0x6c>
  8016a0:	eb 13                	jmp    8016b5 <devpipe_write+0x7a>
  8016a2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8016aa:	8b 13                	mov    (%ebx),%edx
  8016ac:	83 c2 20             	add    $0x20,%edx
  8016af:	39 d0                	cmp    %edx,%eax
  8016b1:	73 ac                	jae    80165f <devpipe_write+0x24>
  8016b3:	eb c8                	jmp    80167d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016b5:	89 f8                	mov    %edi,%eax
  8016b7:	eb 05                	jmp    8016be <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	57                   	push   %edi
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 18             	sub    $0x18,%esp
  8016cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016d2:	57                   	push   %edi
  8016d3:	e8 c4 f6 ff ff       	call   800d9c <fd2data>
  8016d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016e1:	75 44                	jne    801727 <devpipe_read+0x61>
  8016e3:	be 00 00 00 00       	mov    $0x0,%esi
  8016e8:	eb 4f                	jmp    801739 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016ea:	89 f0                	mov    %esi,%eax
  8016ec:	eb 54                	jmp    801742 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ee:	89 da                	mov    %ebx,%edx
  8016f0:	89 f8                	mov    %edi,%eax
  8016f2:	e8 dd fe ff ff       	call   8015d4 <_pipeisclosed>
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	75 42                	jne    80173d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016fb:	e8 91 f4 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801700:	8b 03                	mov    (%ebx),%eax
  801702:	3b 43 04             	cmp    0x4(%ebx),%eax
  801705:	74 e7                	je     8016ee <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801707:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80170c:	79 05                	jns    801713 <devpipe_read+0x4d>
  80170e:	48                   	dec    %eax
  80170f:	83 c8 e0             	or     $0xffffffe0,%eax
  801712:	40                   	inc    %eax
  801713:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801717:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80171d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171f:	46                   	inc    %esi
  801720:	39 75 10             	cmp    %esi,0x10(%ebp)
  801723:	77 07                	ja     80172c <devpipe_read+0x66>
  801725:	eb 12                	jmp    801739 <devpipe_read+0x73>
  801727:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80172c:	8b 03                	mov    (%ebx),%eax
  80172e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801731:	75 d4                	jne    801707 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801733:	85 f6                	test   %esi,%esi
  801735:	75 b3                	jne    8016ea <devpipe_read+0x24>
  801737:	eb b5                	jmp    8016ee <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801739:	89 f0                	mov    %esi,%eax
  80173b:	eb 05                	jmp    801742 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80173d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801742:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 28             	sub    $0x28,%esp
  801753:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801756:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	e8 55 f6 ff ff       	call   800db4 <fd_alloc>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	0f 88 24 01 00 00    	js     801890 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	68 07 04 00 00       	push   $0x407
  801774:	ff 75 e4             	pushl  -0x1c(%ebp)
  801777:	6a 00                	push   $0x0
  801779:	e8 3a f4 ff ff       	call   800bb8 <sys_page_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	0f 88 05 01 00 00    	js     801890 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80178b:	83 ec 0c             	sub    $0xc,%esp
  80178e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	e8 1d f6 ff ff       	call   800db4 <fd_alloc>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 dc 00 00 00    	js     801880 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	68 07 04 00 00       	push   $0x407
  8017ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 02 f4 ff ff       	call   800bb8 <sys_page_alloc>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	0f 88 bd 00 00 00    	js     801880 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c9:	e8 ce f5 ff ff       	call   800d9c <fd2data>
  8017ce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d0:	83 c4 0c             	add    $0xc,%esp
  8017d3:	68 07 04 00 00       	push   $0x407
  8017d8:	50                   	push   %eax
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 d8 f3 ff ff       	call   800bb8 <sys_page_alloc>
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	0f 88 83 00 00 00    	js     801870 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f3:	e8 a4 f5 ff ff       	call   800d9c <fd2data>
  8017f8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017ff:	50                   	push   %eax
  801800:	6a 00                	push   $0x0
  801802:	56                   	push   %esi
  801803:	6a 00                	push   $0x0
  801805:	e8 d2 f3 ff ff       	call   800bdc <sys_page_map>
  80180a:	89 c3                	mov    %eax,%ebx
  80180c:	83 c4 20             	add    $0x20,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 4f                	js     801862 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801813:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80181c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80181e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801821:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801828:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80182e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801831:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801833:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801836:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	ff 75 e4             	pushl  -0x1c(%ebp)
  801843:	e8 44 f5 ff ff       	call   800d8c <fd2num>
  801848:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80184a:	83 c4 04             	add    $0x4,%esp
  80184d:	ff 75 e0             	pushl  -0x20(%ebp)
  801850:	e8 37 f5 ff ff       	call   800d8c <fd2num>
  801855:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801860:	eb 2e                	jmp    801890 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	56                   	push   %esi
  801866:	6a 00                	push   $0x0
  801868:	e8 95 f3 ff ff       	call   800c02 <sys_page_unmap>
  80186d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	ff 75 e0             	pushl  -0x20(%ebp)
  801876:	6a 00                	push   $0x0
  801878:	e8 85 f3 ff ff       	call   800c02 <sys_page_unmap>
  80187d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 e4             	pushl  -0x1c(%ebp)
  801886:	6a 00                	push   $0x0
  801888:	e8 75 f3 ff ff       	call   800c02 <sys_page_unmap>
  80188d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801890:	89 d8                	mov    %ebx,%eax
  801892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5f                   	pop    %edi
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	ff 75 08             	pushl  0x8(%ebp)
  8018a7:	e8 7b f5 ff ff       	call   800e27 <fd_lookup>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 18                	js     8018cb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b9:	e8 de f4 ff ff       	call   800d9c <fd2data>
	return _pipeisclosed(fd, p);
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c3:	e8 0c fd ff ff       	call   8015d4 <_pipeisclosed>
  8018c8:	83 c4 10             	add    $0x10,%esp
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    
  8018cd:	00 00                	add    %al,(%eax)
	...

008018d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018e0:	68 26 23 80 00       	push   $0x802326
  8018e5:	ff 75 0c             	pushl  0xc(%ebp)
  8018e8:	e8 49 ee ff ff       	call   800736 <strcpy>
	return 0;
}
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	57                   	push   %edi
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801900:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801904:	74 45                	je     80194b <devcons_write+0x57>
  801906:	b8 00 00 00 00       	mov    $0x0,%eax
  80190b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801910:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801916:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801919:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80191b:	83 fb 7f             	cmp    $0x7f,%ebx
  80191e:	76 05                	jbe    801925 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801920:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	53                   	push   %ebx
  801929:	03 45 0c             	add    0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	57                   	push   %edi
  80192e:	e8 c4 ef ff ff       	call   8008f7 <memmove>
		sys_cputs(buf, m);
  801933:	83 c4 08             	add    $0x8,%esp
  801936:	53                   	push   %ebx
  801937:	57                   	push   %edi
  801938:	e8 c4 f1 ff ff       	call   800b01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80193d:	01 de                	add    %ebx,%esi
  80193f:	89 f0                	mov    %esi,%eax
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	3b 75 10             	cmp    0x10(%ebp),%esi
  801947:	72 cd                	jb     801916 <devcons_write+0x22>
  801949:	eb 05                	jmp    801950 <devcons_write+0x5c>
  80194b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801950:	89 f0                	mov    %esi,%eax
  801952:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5f                   	pop    %edi
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801960:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801964:	75 07                	jne    80196d <devcons_read+0x13>
  801966:	eb 25                	jmp    80198d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801968:	e8 24 f2 ff ff       	call   800b91 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80196d:	e8 b5 f1 ff ff       	call   800b27 <sys_cgetc>
  801972:	85 c0                	test   %eax,%eax
  801974:	74 f2                	je     801968 <devcons_read+0xe>
  801976:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 1d                	js     801999 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80197c:	83 f8 04             	cmp    $0x4,%eax
  80197f:	74 13                	je     801994 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	88 10                	mov    %dl,(%eax)
	return 1;
  801986:	b8 01 00 00 00       	mov    $0x1,%eax
  80198b:	eb 0c                	jmp    801999 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	eb 05                	jmp    801999 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019a7:	6a 01                	push   $0x1
  8019a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ac:	50                   	push   %eax
  8019ad:	e8 4f f1 ff ff       	call   800b01 <sys_cputs>
  8019b2:	83 c4 10             	add    $0x10,%esp
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <getchar>:

int
getchar(void)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019bd:	6a 01                	push   $0x1
  8019bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 de f6 ff ff       	call   8010a8 <read>
	if (r < 0)
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 0f                	js     8019e0 <getchar+0x29>
		return r;
	if (r < 1)
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	7e 06                	jle    8019db <getchar+0x24>
		return -E_EOF;
	return c;
  8019d5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019d9:	eb 05                	jmp    8019e0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019db:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019eb:	50                   	push   %eax
  8019ec:	ff 75 08             	pushl  0x8(%ebp)
  8019ef:	e8 33 f4 ff ff       	call   800e27 <fd_lookup>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 11                	js     801a0c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a04:	39 10                	cmp    %edx,(%eax)
  801a06:	0f 94 c0             	sete   %al
  801a09:	0f b6 c0             	movzbl %al,%eax
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <opencons>:

int
opencons(void)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a17:	50                   	push   %eax
  801a18:	e8 97 f3 ff ff       	call   800db4 <fd_alloc>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 3a                	js     801a5e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	68 07 04 00 00       	push   $0x407
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 82 f1 ff ff       	call   800bb8 <sys_page_alloc>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 21                	js     801a5e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	50                   	push   %eax
  801a56:	e8 31 f3 ff ff       	call   800d8c <fd2num>
  801a5b:	83 c4 10             	add    $0x10,%esp
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a65:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a68:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801a6e:	e8 fa f0 ff ff       	call   800b6d <sys_getenvid>
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	ff 75 08             	pushl  0x8(%ebp)
  801a7c:	53                   	push   %ebx
  801a7d:	50                   	push   %eax
  801a7e:	68 34 23 80 00       	push   $0x802334
  801a83:	e8 f8 e6 ff ff       	call   800180 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a88:	83 c4 18             	add    $0x18,%esp
  801a8b:	56                   	push   %esi
  801a8c:	ff 75 10             	pushl  0x10(%ebp)
  801a8f:	e8 9b e6 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  801a94:	c7 04 24 05 23 80 00 	movl   $0x802305,(%esp)
  801a9b:	e8 e0 e6 ff ff       	call   800180 <cprintf>
  801aa0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aa3:	cc                   	int3   
  801aa4:	eb fd                	jmp    801aa3 <_panic+0x43>
	...

00801aa8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	57                   	push   %edi
  801abd:	68 58 23 80 00       	push   $0x802358
  801ac2:	e8 b9 e6 ff ff       	call   800180 <cprintf>
	int r;
	if (pg != NULL) {
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 db                	test   %ebx,%ebx
  801acc:	74 28                	je     801af6 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	68 68 23 80 00       	push   $0x802368
  801ad6:	e8 a5 e6 ff ff       	call   800180 <cprintf>
		r = sys_ipc_recv(pg);
  801adb:	89 1c 24             	mov    %ebx,(%esp)
  801ade:	e8 d0 f1 ff ff       	call   800cb3 <sys_ipc_recv>
  801ae3:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801ae5:	c7 04 24 c8 22 80 00 	movl   $0x8022c8,(%esp)
  801aec:	e8 8f e6 ff ff       	call   800180 <cprintf>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	eb 12                	jmp    801b08 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	68 00 00 c0 ee       	push   $0xeec00000
  801afe:	e8 b0 f1 ff ff       	call   800cb3 <sys_ipc_recv>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b08:	85 db                	test   %ebx,%ebx
  801b0a:	75 26                	jne    801b32 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b0c:	85 ff                	test   %edi,%edi
  801b0e:	74 0a                	je     801b1a <ipc_recv+0x72>
  801b10:	a1 04 40 80 00       	mov    0x804004,%eax
  801b15:	8b 40 74             	mov    0x74(%eax),%eax
  801b18:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b1a:	85 f6                	test   %esi,%esi
  801b1c:	74 0a                	je     801b28 <ipc_recv+0x80>
  801b1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b23:	8b 40 78             	mov    0x78(%eax),%eax
  801b26:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801b28:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2d:	8b 58 70             	mov    0x70(%eax),%ebx
  801b30:	eb 14                	jmp    801b46 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b32:	85 ff                	test   %edi,%edi
  801b34:	74 06                	je     801b3c <ipc_recv+0x94>
  801b36:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801b3c:	85 f6                	test   %esi,%esi
  801b3e:	74 06                	je     801b46 <ipc_recv+0x9e>
  801b40:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b5f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b62:	85 db                	test   %ebx,%ebx
  801b64:	75 25                	jne    801b8b <ipc_send+0x3b>
  801b66:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b6b:	eb 1e                	jmp    801b8b <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b6d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b70:	75 07                	jne    801b79 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b72:	e8 1a f0 ff ff       	call   800b91 <sys_yield>
  801b77:	eb 12                	jmp    801b8b <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b79:	50                   	push   %eax
  801b7a:	68 6f 23 80 00       	push   $0x80236f
  801b7f:	6a 45                	push   $0x45
  801b81:	68 82 23 80 00       	push   $0x802382
  801b86:	e8 d5 fe ff ff       	call   801a60 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	57                   	push   %edi
  801b8e:	ff 75 08             	pushl  0x8(%ebp)
  801b91:	e8 f8 f0 ff ff       	call   800c8e <sys_ipc_try_send>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	75 d0                	jne    801b6d <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bac:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801bb2:	74 22                	je     801bd6 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bb4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801bb9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801bc0:	89 c2                	mov    %eax,%edx
  801bc2:	c1 e2 07             	shl    $0x7,%edx
  801bc5:	29 ca                	sub    %ecx,%edx
  801bc7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bcd:	8b 52 50             	mov    0x50(%edx),%edx
  801bd0:	39 da                	cmp    %ebx,%edx
  801bd2:	75 1d                	jne    801bf1 <ipc_find_env+0x4c>
  801bd4:	eb 05                	jmp    801bdb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bdb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801be2:	c1 e0 07             	shl    $0x7,%eax
  801be5:	29 d0                	sub    %edx,%eax
  801be7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801bec:	8b 40 40             	mov    0x40(%eax),%eax
  801bef:	eb 0c                	jmp    801bfd <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf1:	40                   	inc    %eax
  801bf2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf7:	75 c0                	jne    801bb9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bf9:	66 b8 00 00          	mov    $0x0,%ax
}
  801bfd:	5b                   	pop    %ebx
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	c1 ea 16             	shr    $0x16,%edx
  801c0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c12:	f6 c2 01             	test   $0x1,%dl
  801c15:	74 1e                	je     801c35 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c17:	c1 e8 0c             	shr    $0xc,%eax
  801c1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c21:	a8 01                	test   $0x1,%al
  801c23:	74 17                	je     801c3c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c25:	c1 e8 0c             	shr    $0xc,%eax
  801c28:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c2f:	ef 
  801c30:	0f b7 c0             	movzwl %ax,%eax
  801c33:	eb 0c                	jmp    801c41 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3a:	eb 05                	jmp    801c41 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    
	...

00801c44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	57                   	push   %edi
  801c48:	56                   	push   %esi
  801c49:	83 ec 10             	sub    $0x10,%esp
  801c4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c52:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c5b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	75 2e                	jne    801c90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c62:	39 f1                	cmp    %esi,%ecx
  801c64:	77 5a                	ja     801cc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c66:	85 c9                	test   %ecx,%ecx
  801c68:	75 0b                	jne    801c75 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6f:	31 d2                	xor    %edx,%edx
  801c71:	f7 f1                	div    %ecx
  801c73:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c75:	31 d2                	xor    %edx,%edx
  801c77:	89 f0                	mov    %esi,%eax
  801c79:	f7 f1                	div    %ecx
  801c7b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c7d:	89 f8                	mov    %edi,%eax
  801c7f:	f7 f1                	div    %ecx
  801c81:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c83:	89 f8                	mov    %edi,%eax
  801c85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	5e                   	pop    %esi
  801c8b:	5f                   	pop    %edi
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    
  801c8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c90:	39 f0                	cmp    %esi,%eax
  801c92:	77 1c                	ja     801cb0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c94:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	75 3c                	jne    801cd8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c9c:	39 f0                	cmp    %esi,%eax
  801c9e:	0f 82 90 00 00 00    	jb     801d34 <__udivdi3+0xf0>
  801ca4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ca7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801caa:	0f 86 84 00 00 00    	jbe    801d34 <__udivdi3+0xf0>
  801cb0:	31 f6                	xor    %esi,%esi
  801cb2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cb4:	89 f8                	mov    %edi,%eax
  801cb6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	5e                   	pop    %esi
  801cbc:	5f                   	pop    %edi
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    
  801cbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	89 f8                	mov    %edi,%eax
  801cc4:	f7 f1                	div    %ecx
  801cc6:	89 c7                	mov    %eax,%edi
  801cc8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cca:	89 f8                	mov    %edi,%eax
  801ccc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cd8:	89 f9                	mov    %edi,%ecx
  801cda:	d3 e0                	shl    %cl,%eax
  801cdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cdf:	b8 20 00 00 00       	mov    $0x20,%eax
  801ce4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce9:	88 c1                	mov    %al,%cl
  801ceb:	d3 ea                	shr    %cl,%edx
  801ced:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cf0:	09 ca                	or     %ecx,%edx
  801cf2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf8:	89 f9                	mov    %edi,%ecx
  801cfa:	d3 e2                	shl    %cl,%edx
  801cfc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cff:	89 f2                	mov    %esi,%edx
  801d01:	88 c1                	mov    %al,%cl
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	89 f9                	mov    %edi,%ecx
  801d0c:	d3 e2                	shl    %cl,%edx
  801d0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d11:	88 c1                	mov    %al,%cl
  801d13:	d3 ee                	shr    %cl,%esi
  801d15:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d1a:	89 f0                	mov    %esi,%eax
  801d1c:	89 ca                	mov    %ecx,%edx
  801d1e:	f7 75 ec             	divl   -0x14(%ebp)
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d25:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d28:	39 d1                	cmp    %edx,%ecx
  801d2a:	72 28                	jb     801d54 <__udivdi3+0x110>
  801d2c:	74 1a                	je     801d48 <__udivdi3+0x104>
  801d2e:	89 f7                	mov    %esi,%edi
  801d30:	31 f6                	xor    %esi,%esi
  801d32:	eb 80                	jmp    801cb4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d34:	31 f6                	xor    %esi,%esi
  801d36:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    
  801d46:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d4f:	39 c2                	cmp    %eax,%edx
  801d51:	73 db                	jae    801d2e <__udivdi3+0xea>
  801d53:	90                   	nop
		{
		  q0--;
  801d54:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d57:	31 f6                	xor    %esi,%esi
  801d59:	e9 56 ff ff ff       	jmp    801cb4 <__udivdi3+0x70>
	...

00801d60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	57                   	push   %edi
  801d64:	56                   	push   %esi
  801d65:	83 ec 20             	sub    $0x20,%esp
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d77:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d7d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d7f:	85 ff                	test   %edi,%edi
  801d81:	75 15                	jne    801d98 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d83:	39 f1                	cmp    %esi,%ecx
  801d85:	0f 86 99 00 00 00    	jbe    801e24 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d8b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d8d:	89 d0                	mov    %edx,%eax
  801d8f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d91:	83 c4 20             	add    $0x20,%esp
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d98:	39 f7                	cmp    %esi,%edi
  801d9a:	0f 87 a4 00 00 00    	ja     801e44 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801da0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801da3:	83 f0 1f             	xor    $0x1f,%eax
  801da6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801da9:	0f 84 a1 00 00 00    	je     801e50 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801db4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801db6:	bf 20 00 00 00       	mov    $0x20,%edi
  801dbb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801dbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	d3 ea                	shr    %cl,%edx
  801dc5:	09 c2                	or     %eax,%edx
  801dc7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dd0:	d3 e0                	shl    %cl,%eax
  801dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dd5:	89 f2                	mov    %esi,%edx
  801dd7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801dd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801de4:	89 f9                	mov    %edi,%ecx
  801de6:	d3 e8                	shr    %cl,%eax
  801de8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dec:	89 f2                	mov    %esi,%edx
  801dee:	f7 75 f0             	divl   -0x10(%ebp)
  801df1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801df3:	f7 65 f4             	mull   -0xc(%ebp)
  801df6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801df9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dfb:	39 d6                	cmp    %edx,%esi
  801dfd:	72 71                	jb     801e70 <__umoddi3+0x110>
  801dff:	74 7f                	je     801e80 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e04:	29 c8                	sub    %ecx,%eax
  801e06:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e08:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e0b:	d3 e8                	shr    %cl,%eax
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	89 f9                	mov    %edi,%ecx
  801e11:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e13:	09 d0                	or     %edx,%eax
  801e15:	89 f2                	mov    %esi,%edx
  801e17:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e1a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e1c:	83 c4 20             	add    $0x20,%esp
  801e1f:	5e                   	pop    %esi
  801e20:	5f                   	pop    %edi
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    
  801e23:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e24:	85 c9                	test   %ecx,%ecx
  801e26:	75 0b                	jne    801e33 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e28:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	f7 f1                	div    %ecx
  801e31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e33:	89 f0                	mov    %esi,%eax
  801e35:	31 d2                	xor    %edx,%edx
  801e37:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3c:	f7 f1                	div    %ecx
  801e3e:	e9 4a ff ff ff       	jmp    801d8d <__umoddi3+0x2d>
  801e43:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e46:	83 c4 20             	add    $0x20,%esp
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e50:	39 f7                	cmp    %esi,%edi
  801e52:	72 05                	jb     801e59 <__umoddi3+0xf9>
  801e54:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e57:	77 0c                	ja     801e65 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e59:	89 f2                	mov    %esi,%edx
  801e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5e:	29 c8                	sub    %ecx,%eax
  801e60:	19 fa                	sbb    %edi,%edx
  801e62:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e70:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e73:	89 c1                	mov    %eax,%ecx
  801e75:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e78:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e7b:	eb 84                	jmp    801e01 <__umoddi3+0xa1>
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e83:	72 eb                	jb     801e70 <__umoddi3+0x110>
  801e85:	89 f2                	mov    %esi,%edx
  801e87:	e9 75 ff ff ff       	jmp    801e01 <__umoddi3+0xa1>
