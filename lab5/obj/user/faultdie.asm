
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
  800046:	68 80 1e 80 00       	push   $0x801e80
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
  80006d:	e8 ae 0c 00 00       	call   800d20 <set_pgfault_handler>
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
  8000da:	e8 df 0e 00 00       	call   800fbe <close_all>
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
  8001e8:	e8 2f 1a 00 00       	call   801c1c <__udivdi3>
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
  800224:	e8 0f 1b 00 00       	call   801d38 <__umoddi3>
  800229:	83 c4 14             	add    $0x14,%esp
  80022c:	0f be 80 a6 1e 80 00 	movsbl 0x801ea6(%eax),%eax
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
  800370:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
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
  80041c:	8b 04 85 40 21 80 00 	mov    0x802140(,%eax,4),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	75 1a                	jne    800441 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800427:	52                   	push   %edx
  800428:	68 be 1e 80 00       	push   $0x801ebe
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
  800442:	68 c1 22 80 00       	push   $0x8022c1
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
  800478:	c7 45 d0 b7 1e 80 00 	movl   $0x801eb7,-0x30(%ebp)
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
  800ae6:	68 9f 21 80 00       	push   $0x80219f
  800aeb:	6a 42                	push   $0x42
  800aed:	68 bc 21 80 00       	push   $0x8021bc
  800af2:	e8 71 0f 00 00       	call   801a68 <_panic>

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

00800cf8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cfe:	6a 00                	push   $0x0
  800d00:	ff 75 14             	pushl  0x14(%ebp)
  800d03:	ff 75 10             	pushl  0x10(%ebp)
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d16:	e8 99 fd ff ff       	call   800ab4 <syscall>
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    
  800d1d:	00 00                	add    %al,(%eax)
	...

00800d20 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d26:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d2d:	75 52                	jne    800d81 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d2f:	83 ec 04             	sub    $0x4,%esp
  800d32:	6a 07                	push   $0x7
  800d34:	68 00 f0 bf ee       	push   $0xeebff000
  800d39:	6a 00                	push   $0x0
  800d3b:	e8 78 fe ff ff       	call   800bb8 <sys_page_alloc>
		if (r < 0) {
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	79 12                	jns    800d59 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d47:	50                   	push   %eax
  800d48:	68 ca 21 80 00       	push   $0x8021ca
  800d4d:	6a 24                	push   $0x24
  800d4f:	68 e5 21 80 00       	push   $0x8021e5
  800d54:	e8 0f 0d 00 00       	call   801a68 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d59:	83 ec 08             	sub    $0x8,%esp
  800d5c:	68 8c 0d 80 00       	push   $0x800d8c
  800d61:	6a 00                	push   $0x0
  800d63:	e8 03 ff ff ff       	call   800c6b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	79 12                	jns    800d81 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d6f:	50                   	push   %eax
  800d70:	68 f4 21 80 00       	push   $0x8021f4
  800d75:	6a 2a                	push   $0x2a
  800d77:	68 e5 21 80 00       	push   $0x8021e5
  800d7c:	e8 e7 0c 00 00       	call   801a68 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    
	...

00800d8c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d8c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d8d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d92:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d94:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800d97:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d9b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d9e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800da2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800da6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800da8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800dab:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800dac:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800daf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800db0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800db1:	c3                   	ret    
	...

00800db4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbf:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc7:	ff 75 08             	pushl  0x8(%ebp)
  800dca:	e8 e5 ff ff ff       	call   800db4 <fd2num>
  800dcf:	83 c4 04             	add    $0x4,%esp
  800dd2:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dd7:	c1 e0 0c             	shl    $0xc,%eax
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800de8:	a8 01                	test   $0x1,%al
  800dea:	74 34                	je     800e20 <fd_alloc+0x44>
  800dec:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800df1:	a8 01                	test   $0x1,%al
  800df3:	74 32                	je     800e27 <fd_alloc+0x4b>
  800df5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800dfa:	89 c1                	mov    %eax,%ecx
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 1f                	je     800e2c <fd_alloc+0x50>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	75 17                	jne    800e35 <fd_alloc+0x59>
  800e1e:	eb 0c                	jmp    800e2c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e20:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e25:	eb 05                	jmp    800e2c <fd_alloc+0x50>
  800e27:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e2c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb 17                	jmp    800e4c <fd_alloc+0x70>
  800e35:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3f:	75 b9                	jne    800dfa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e47:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e55:	83 f8 1f             	cmp    $0x1f,%eax
  800e58:	77 36                	ja     800e90 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e5f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 16             	shr    $0x16,%edx
  800e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 24                	je     800e97 <fd_lookup+0x48>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	74 1a                	je     800e9e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 02                	mov    %eax,(%edx)
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	eb 13                	jmp    800ea3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb 0c                	jmp    800ea3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb 05                	jmp    800ea3 <fd_lookup+0x54>
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eb2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800eb8:	74 0d                	je     800ec7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 14                	jmp    800ed5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800ec1:	39 0a                	cmp    %ecx,(%edx)
  800ec3:	75 10                	jne    800ed5 <dev_lookup+0x30>
  800ec5:	eb 05                	jmp    800ecc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ecc:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	eb 31                	jmp    800f06 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	40                   	inc    %eax
  800ed6:	8b 14 85 98 22 80 00 	mov    0x802298(,%eax,4),%edx
  800edd:	85 d2                	test   %edx,%edx
  800edf:	75 e0                	jne    800ec1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee1:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee6:	8b 40 48             	mov    0x48(%eax),%eax
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	51                   	push   %ecx
  800eed:	50                   	push   %eax
  800eee:	68 1c 22 80 00       	push   $0x80221c
  800ef3:	e8 88 f2 ff ff       	call   800180 <cprintf>
	*dev = 0;
  800ef8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 20             	sub    $0x20,%esp
  800f13:	8b 75 08             	mov    0x8(%ebp),%esi
  800f16:	8a 45 0c             	mov    0xc(%ebp),%al
  800f19:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1c:	56                   	push   %esi
  800f1d:	e8 92 fe ff ff       	call   800db4 <fd2num>
  800f22:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f25:	89 14 24             	mov    %edx,(%esp)
  800f28:	50                   	push   %eax
  800f29:	e8 21 ff ff ff       	call   800e4f <fd_lookup>
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	83 c4 08             	add    $0x8,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	78 05                	js     800f3c <fd_close+0x31>
	    || fd != fd2)
  800f37:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3a:	74 0d                	je     800f49 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f3c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f40:	75 48                	jne    800f8a <fd_close+0x7f>
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f47:	eb 41                	jmp    800f8a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 36                	pushl  (%esi)
  800f52:	e8 4e ff ff ff       	call   800ea5 <dev_lookup>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 1c                	js     800f7c <fd_close+0x71>
		if (dev->dev_close)
  800f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f63:	8b 40 10             	mov    0x10(%eax),%eax
  800f66:	85 c0                	test   %eax,%eax
  800f68:	74 0d                	je     800f77 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	56                   	push   %esi
  800f6e:	ff d0                	call   *%eax
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	eb 05                	jmp    800f7c <fd_close+0x71>
		else
			r = 0;
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	e8 7b fc ff ff       	call   800c02 <sys_page_unmap>
	return r;
  800f87:	83 c4 10             	add    $0x10,%esp
}
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 08             	pushl  0x8(%ebp)
  800fa0:	e8 aa fe ff ff       	call   800e4f <fd_lookup>
  800fa5:	83 c4 08             	add    $0x8,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 10                	js     800fbc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	6a 01                	push   $0x1
  800fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb4:	e8 52 ff ff ff       	call   800f0b <fd_close>
  800fb9:	83 c4 10             	add    $0x10,%esp
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <close_all>:

void
close_all(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	53                   	push   %ebx
  800fce:	e8 c0 ff ff ff       	call   800f93 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd3:	43                   	inc    %ebx
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	83 fb 20             	cmp    $0x20,%ebx
  800fda:	75 ee                	jne    800fca <close_all+0xc>
		close(i);
}
  800fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 2c             	sub    $0x2c,%esp
  800fea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 75 08             	pushl  0x8(%ebp)
  800ff4:	e8 56 fe ff ff       	call   800e4f <fd_lookup>
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	0f 88 c0 00 00 00    	js     8010c6 <dup+0xe5>
		return r;
	close(newfdnum);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	57                   	push   %edi
  80100a:	e8 84 ff ff ff       	call   800f93 <close>

	newfd = INDEX2FD(newfdnum);
  80100f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801015:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801018:	83 c4 04             	add    $0x4,%esp
  80101b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101e:	e8 a1 fd ff ff       	call   800dc4 <fd2data>
  801023:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801025:	89 34 24             	mov    %esi,(%esp)
  801028:	e8 97 fd ff ff       	call   800dc4 <fd2data>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801033:	89 d8                	mov    %ebx,%eax
  801035:	c1 e8 16             	shr    $0x16,%eax
  801038:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	74 37                	je     80107a <dup+0x99>
  801043:	89 d8                	mov    %ebx,%eax
  801045:	c1 e8 0c             	shr    $0xc,%eax
  801048:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 26                	je     80107a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801054:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	50                   	push   %eax
  801064:	ff 75 d4             	pushl  -0x2c(%ebp)
  801067:	6a 00                	push   $0x0
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 6b fb ff ff       	call   800bdc <sys_page_map>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 2d                	js     8010a7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	c1 ea 0c             	shr    $0xc,%edx
  801082:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801092:	52                   	push   %edx
  801093:	56                   	push   %esi
  801094:	6a 00                	push   $0x0
  801096:	50                   	push   %eax
  801097:	6a 00                	push   $0x0
  801099:	e8 3e fb ff ff       	call   800bdc <sys_page_map>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	83 c4 20             	add    $0x20,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	79 1d                	jns    8010c4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	56                   	push   %esi
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 50 fb ff ff       	call   800c02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 43 fb ff ff       	call   800c02 <sys_page_unmap>
	return r;
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	eb 02                	jmp    8010c6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 14             	sub    $0x14,%esp
  8010d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	53                   	push   %ebx
  8010df:	e8 6b fd ff ff       	call   800e4f <fd_lookup>
  8010e4:	83 c4 08             	add    $0x8,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 67                	js     801152 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f5:	ff 30                	pushl  (%eax)
  8010f7:	e8 a9 fd ff ff       	call   800ea5 <dev_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 4f                	js     801152 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801106:	8b 50 08             	mov    0x8(%eax),%edx
  801109:	83 e2 03             	and    $0x3,%edx
  80110c:	83 fa 01             	cmp    $0x1,%edx
  80110f:	75 21                	jne    801132 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801111:	a1 04 40 80 00       	mov    0x804004,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	53                   	push   %ebx
  80111d:	50                   	push   %eax
  80111e:	68 5d 22 80 00       	push   $0x80225d
  801123:	e8 58 f0 ff ff       	call   800180 <cprintf>
		return -E_INVAL;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801130:	eb 20                	jmp    801152 <read+0x82>
	}
	if (!dev->dev_read)
  801132:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801135:	8b 52 08             	mov    0x8(%edx),%edx
  801138:	85 d2                	test   %edx,%edx
  80113a:	74 11                	je     80114d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	50                   	push   %eax
  801146:	ff d2                	call   *%edx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	eb 05                	jmp    801152 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80114d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 7d 08             	mov    0x8(%ebp),%edi
  801163:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801166:	85 f6                	test   %esi,%esi
  801168:	74 31                	je     80119b <readn+0x44>
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	89 f2                	mov    %esi,%edx
  801179:	29 c2                	sub    %eax,%edx
  80117b:	52                   	push   %edx
  80117c:	03 45 0c             	add    0xc(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	57                   	push   %edi
  801181:	e8 4a ff ff ff       	call   8010d0 <read>
		if (m < 0)
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 17                	js     8011a4 <readn+0x4d>
			return m;
		if (m == 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	74 11                	je     8011a2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801191:	01 c3                	add    %eax,%ebx
  801193:	89 d8                	mov    %ebx,%eax
  801195:	39 f3                	cmp    %esi,%ebx
  801197:	72 db                	jb     801174 <readn+0x1d>
  801199:	eb 09                	jmp    8011a4 <readn+0x4d>
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	eb 02                	jmp    8011a4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011a2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 14             	sub    $0x14,%esp
  8011b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	53                   	push   %ebx
  8011bb:	e8 8f fc ff ff       	call   800e4f <fd_lookup>
  8011c0:	83 c4 08             	add    $0x8,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 62                	js     801229 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d1:	ff 30                	pushl  (%eax)
  8011d3:	e8 cd fc ff ff       	call   800ea5 <dev_lookup>
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 4a                	js     801229 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e6:	75 21                	jne    801209 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ed:	8b 40 48             	mov    0x48(%eax),%eax
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	53                   	push   %ebx
  8011f4:	50                   	push   %eax
  8011f5:	68 79 22 80 00       	push   $0x802279
  8011fa:	e8 81 ef ff ff       	call   800180 <cprintf>
		return -E_INVAL;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801207:	eb 20                	jmp    801229 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801209:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120c:	8b 52 0c             	mov    0xc(%edx),%edx
  80120f:	85 d2                	test   %edx,%edx
  801211:	74 11                	je     801224 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	ff 75 10             	pushl  0x10(%ebp)
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	50                   	push   %eax
  80121d:	ff d2                	call   *%edx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	eb 05                	jmp    801229 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801224:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <seek>:

int
seek(int fdnum, off_t offset)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801234:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 0f fc ff ff       	call   800e4f <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 0e                	js     801255 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801247:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 14             	sub    $0x14,%esp
  80125e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	53                   	push   %ebx
  801266:	e8 e4 fb ff ff       	call   800e4f <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 5f                	js     8012d1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	ff 30                	pushl  (%eax)
  80127e:	e8 22 fc ff ff       	call   800ea5 <dev_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 47                	js     8012d1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801291:	75 21                	jne    8012b4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801293:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	68 3c 22 80 00       	push   $0x80223c
  8012a5:	e8 d6 ee ff ff       	call   800180 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b2:	eb 1d                	jmp    8012d1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b7:	8b 52 18             	mov    0x18(%edx),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	74 0e                	je     8012cc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	ff 75 0c             	pushl  0xc(%ebp)
  8012c4:	50                   	push   %eax
  8012c5:	ff d2                	call   *%edx
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	eb 05                	jmp    8012d1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 14             	sub    $0x14,%esp
  8012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 63 fb ff ff       	call   800e4f <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 52                	js     801345 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 a1 fb ff ff       	call   800ea5 <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 3a                	js     801345 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801312:	74 2c                	je     801340 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801314:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801317:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131e:	00 00 00 
	stat->st_isdir = 0;
  801321:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801328:	00 00 00 
	stat->st_dev = dev;
  80132b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 75 f0             	pushl  -0x10(%ebp)
  801338:	ff 50 14             	call   *0x14(%eax)
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	eb 05                	jmp    801345 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 00                	push   $0x0
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 78 01 00 00       	call   8014d4 <open>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1b                	js     801380 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 0c             	pushl  0xc(%ebp)
  80136b:	50                   	push   %eax
  80136c:	e8 65 ff ff ff       	call   8012d6 <fstat>
  801371:	89 c6                	mov    %eax,%esi
	close(fd);
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 18 fc ff ff       	call   800f93 <close>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 f3                	mov    %esi,%ebx
}
  801380:	89 d8                	mov    %ebx,%eax
  801382:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	c9                   	leave  
  801388:	c3                   	ret    
  801389:	00 00                	add    %al,(%eax)
	...

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	89 c3                	mov    %eax,%ebx
  801393:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801395:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139c:	75 12                	jne    8013b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 01                	push   $0x1
  8013a3:	e8 d2 07 00 00       	call   801b7a <ipc_find_env>
  8013a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b0:	6a 07                	push   $0x7
  8013b2:	68 00 50 80 00       	push   $0x805000
  8013b7:	53                   	push   %ebx
  8013b8:	ff 35 00 40 80 00    	pushl  0x804000
  8013be:	e8 62 07 00 00       	call   801b25 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	56                   	push   %esi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 e0 06 00 00       	call   801ab0 <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f6:	e8 91 ff ff ff       	call   80138c <fsipc>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 2c                	js     80142b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	68 00 50 80 00       	push   $0x805000
  801407:	53                   	push   %ebx
  801408:	e8 29 f3 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80140d:	a1 80 50 80 00       	mov    0x805080,%eax
  801412:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801418:	a1 84 50 80 00       	mov    0x805084,%eax
  80141d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 06 00 00 00       	mov    $0x6,%eax
  80144b:	e8 3c ff ff ff       	call   80138c <fsipc>
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801465:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 03 00 00 00       	mov    $0x3,%eax
  801475:	e8 12 ff ff ff       	call   80138c <fsipc>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 4b                	js     8014cb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801480:	39 c6                	cmp    %eax,%esi
  801482:	73 16                	jae    80149a <devfile_read+0x48>
  801484:	68 a8 22 80 00       	push   $0x8022a8
  801489:	68 af 22 80 00       	push   $0x8022af
  80148e:	6a 7d                	push   $0x7d
  801490:	68 c4 22 80 00       	push   $0x8022c4
  801495:	e8 ce 05 00 00       	call   801a68 <_panic>
	assert(r <= PGSIZE);
  80149a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80149f:	7e 16                	jle    8014b7 <devfile_read+0x65>
  8014a1:	68 cf 22 80 00       	push   $0x8022cf
  8014a6:	68 af 22 80 00       	push   $0x8022af
  8014ab:	6a 7e                	push   $0x7e
  8014ad:	68 c4 22 80 00       	push   $0x8022c4
  8014b2:	e8 b1 05 00 00       	call   801a68 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	50                   	push   %eax
  8014bb:	68 00 50 80 00       	push   $0x805000
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	e8 2f f4 ff ff       	call   8008f7 <memmove>
	return r;
  8014c8:	83 c4 10             	add    $0x10,%esp
}
  8014cb:	89 d8                	mov    %ebx,%eax
  8014cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 1c             	sub    $0x1c,%esp
  8014dc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014df:	56                   	push   %esi
  8014e0:	e8 ff f1 ff ff       	call   8006e4 <strlen>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ed:	7f 65                	jg     801554 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	e8 e1 f8 ff ff       	call   800ddc <fd_alloc>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 55                	js     801559 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	56                   	push   %esi
  801508:	68 00 50 80 00       	push   $0x805000
  80150d:	e8 24 f2 ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801512:	8b 45 0c             	mov    0xc(%ebp),%eax
  801515:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151d:	b8 01 00 00 00       	mov    $0x1,%eax
  801522:	e8 65 fe ff ff       	call   80138c <fsipc>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	79 12                	jns    801542 <open+0x6e>
		fd_close(fd, 0);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	6a 00                	push   $0x0
  801535:	ff 75 f4             	pushl  -0xc(%ebp)
  801538:	e8 ce f9 ff ff       	call   800f0b <fd_close>
		return r;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb 17                	jmp    801559 <open+0x85>
	}

	return fd2num(fd);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	ff 75 f4             	pushl  -0xc(%ebp)
  801548:	e8 67 f8 ff ff       	call   800db4 <fd2num>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 05                	jmp    801559 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801554:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	c9                   	leave  
  801561:	c3                   	ret    
	...

00801564 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 4d f8 ff ff       	call   800dc4 <fd2data>
  801577:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	68 db 22 80 00       	push   $0x8022db
  801581:	56                   	push   %esi
  801582:	e8 af f1 ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801587:	8b 43 04             	mov    0x4(%ebx),%eax
  80158a:	2b 03                	sub    (%ebx),%eax
  80158c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801592:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801599:	00 00 00 
	stat->st_dev = &devpipe;
  80159c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015a3:	30 80 00 
	return 0;
}
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015bc:	53                   	push   %ebx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 3e f6 ff ff       	call   800c02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 f8 f7 ff ff       	call   800dc4 <fd2data>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	50                   	push   %eax
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 2b f6 ff ff       	call   800c02 <sys_page_unmap>
}
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	89 c7                	mov    %eax,%edi
  8015e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	57                   	push   %edi
  8015f6:	e8 dd 05 00 00       	call   801bd8 <pageref>
  8015fb:	89 c6                	mov    %eax,%esi
  8015fd:	83 c4 04             	add    $0x4,%esp
  801600:	ff 75 e4             	pushl  -0x1c(%ebp)
  801603:	e8 d0 05 00 00       	call   801bd8 <pageref>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	39 c6                	cmp    %eax,%esi
  80160d:	0f 94 c0             	sete   %al
  801610:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801613:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801619:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80161c:	39 cb                	cmp    %ecx,%ebx
  80161e:	75 08                	jne    801628 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	c9                   	leave  
  801627:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801628:	83 f8 01             	cmp    $0x1,%eax
  80162b:	75 bd                	jne    8015ea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80162d:	8b 42 58             	mov    0x58(%edx),%eax
  801630:	6a 01                	push   $0x1
  801632:	50                   	push   %eax
  801633:	53                   	push   %ebx
  801634:	68 e2 22 80 00       	push   $0x8022e2
  801639:	e8 42 eb ff ff       	call   800180 <cprintf>
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	eb a7                	jmp    8015ea <_pipeisclosed+0xe>

00801643 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	57                   	push   %edi
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
  801649:	83 ec 28             	sub    $0x28,%esp
  80164c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164f:	56                   	push   %esi
  801650:	e8 6f f7 ff ff       	call   800dc4 <fd2data>
  801655:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80165e:	75 4a                	jne    8016aa <devpipe_write+0x67>
  801660:	bf 00 00 00 00       	mov    $0x0,%edi
  801665:	eb 56                	jmp    8016bd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801667:	89 da                	mov    %ebx,%edx
  801669:	89 f0                	mov    %esi,%eax
  80166b:	e8 6c ff ff ff       	call   8015dc <_pipeisclosed>
  801670:	85 c0                	test   %eax,%eax
  801672:	75 4d                	jne    8016c1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801674:	e8 18 f5 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801679:	8b 43 04             	mov    0x4(%ebx),%eax
  80167c:	8b 13                	mov    (%ebx),%edx
  80167e:	83 c2 20             	add    $0x20,%edx
  801681:	39 d0                	cmp    %edx,%eax
  801683:	73 e2                	jae    801667 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801685:	89 c2                	mov    %eax,%edx
  801687:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80168d:	79 05                	jns    801694 <devpipe_write+0x51>
  80168f:	4a                   	dec    %edx
  801690:	83 ca e0             	or     $0xffffffe0,%edx
  801693:	42                   	inc    %edx
  801694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801697:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80169a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169e:	40                   	inc    %eax
  80169f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a2:	47                   	inc    %edi
  8016a3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016a6:	77 07                	ja     8016af <devpipe_write+0x6c>
  8016a8:	eb 13                	jmp    8016bd <devpipe_write+0x7a>
  8016aa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016af:	8b 43 04             	mov    0x4(%ebx),%eax
  8016b2:	8b 13                	mov    (%ebx),%edx
  8016b4:	83 c2 20             	add    $0x20,%edx
  8016b7:	39 d0                	cmp    %edx,%eax
  8016b9:	73 ac                	jae    801667 <devpipe_write+0x24>
  8016bb:	eb c8                	jmp    801685 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016bd:	89 f8                	mov    %edi,%eax
  8016bf:	eb 05                	jmp    8016c6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	57                   	push   %edi
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 18             	sub    $0x18,%esp
  8016d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016da:	57                   	push   %edi
  8016db:	e8 e4 f6 ff ff       	call   800dc4 <fd2data>
  8016e0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016e9:	75 44                	jne    80172f <devpipe_read+0x61>
  8016eb:	be 00 00 00 00       	mov    $0x0,%esi
  8016f0:	eb 4f                	jmp    801741 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016f2:	89 f0                	mov    %esi,%eax
  8016f4:	eb 54                	jmp    80174a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016f6:	89 da                	mov    %ebx,%edx
  8016f8:	89 f8                	mov    %edi,%eax
  8016fa:	e8 dd fe ff ff       	call   8015dc <_pipeisclosed>
  8016ff:	85 c0                	test   %eax,%eax
  801701:	75 42                	jne    801745 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801703:	e8 89 f4 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801708:	8b 03                	mov    (%ebx),%eax
  80170a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80170d:	74 e7                	je     8016f6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80170f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801714:	79 05                	jns    80171b <devpipe_read+0x4d>
  801716:	48                   	dec    %eax
  801717:	83 c8 e0             	or     $0xffffffe0,%eax
  80171a:	40                   	inc    %eax
  80171b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80171f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801722:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801725:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801727:	46                   	inc    %esi
  801728:	39 75 10             	cmp    %esi,0x10(%ebp)
  80172b:	77 07                	ja     801734 <devpipe_read+0x66>
  80172d:	eb 12                	jmp    801741 <devpipe_read+0x73>
  80172f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801734:	8b 03                	mov    (%ebx),%eax
  801736:	3b 43 04             	cmp    0x4(%ebx),%eax
  801739:	75 d4                	jne    80170f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80173b:	85 f6                	test   %esi,%esi
  80173d:	75 b3                	jne    8016f2 <devpipe_read+0x24>
  80173f:	eb b5                	jmp    8016f6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801741:	89 f0                	mov    %esi,%eax
  801743:	eb 05                	jmp    80174a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80174a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5f                   	pop    %edi
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	57                   	push   %edi
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	83 ec 28             	sub    $0x28,%esp
  80175b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80175e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	e8 75 f6 ff ff       	call   800ddc <fd_alloc>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	0f 88 24 01 00 00    	js     801898 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	68 07 04 00 00       	push   $0x407
  80177c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177f:	6a 00                	push   $0x0
  801781:	e8 32 f4 ff ff       	call   800bb8 <sys_page_alloc>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	0f 88 05 01 00 00    	js     801898 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	e8 3d f6 ff ff       	call   800ddc <fd_alloc>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	0f 88 dc 00 00 00    	js     801888 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	68 07 04 00 00       	push   $0x407
  8017b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 fa f3 ff ff       	call   800bb8 <sys_page_alloc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	0f 88 bd 00 00 00    	js     801888 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017d1:	e8 ee f5 ff ff       	call   800dc4 <fd2data>
  8017d6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d8:	83 c4 0c             	add    $0xc,%esp
  8017db:	68 07 04 00 00       	push   $0x407
  8017e0:	50                   	push   %eax
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 d0 f3 ff ff       	call   800bb8 <sys_page_alloc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 83 00 00 00    	js     801878 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8017fb:	e8 c4 f5 ff ff       	call   800dc4 <fd2data>
  801800:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801807:	50                   	push   %eax
  801808:	6a 00                	push   $0x0
  80180a:	56                   	push   %esi
  80180b:	6a 00                	push   $0x0
  80180d:	e8 ca f3 ff ff       	call   800bdc <sys_page_map>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	83 c4 20             	add    $0x20,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 4f                	js     80186a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80181b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801824:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801826:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801829:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801830:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801836:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801839:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80183b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80183e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184b:	e8 64 f5 ff ff       	call   800db4 <fd2num>
  801850:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801852:	83 c4 04             	add    $0x4,%esp
  801855:	ff 75 e0             	pushl  -0x20(%ebp)
  801858:	e8 57 f5 ff ff       	call   800db4 <fd2num>
  80185d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	bb 00 00 00 00       	mov    $0x0,%ebx
  801868:	eb 2e                	jmp    801898 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	56                   	push   %esi
  80186e:	6a 00                	push   $0x0
  801870:	e8 8d f3 ff ff       	call   800c02 <sys_page_unmap>
  801875:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	ff 75 e0             	pushl  -0x20(%ebp)
  80187e:	6a 00                	push   $0x0
  801880:	e8 7d f3 ff ff       	call   800c02 <sys_page_unmap>
  801885:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80188e:	6a 00                	push   $0x0
  801890:	e8 6d f3 ff ff       	call   800c02 <sys_page_unmap>
  801895:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801898:	89 d8                	mov    %ebx,%eax
  80189a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	ff 75 08             	pushl  0x8(%ebp)
  8018af:	e8 9b f5 ff ff       	call   800e4f <fd_lookup>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 18                	js     8018d3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c1:	e8 fe f4 ff ff       	call   800dc4 <fd2data>
	return _pipeisclosed(fd, p);
  8018c6:	89 c2                	mov    %eax,%edx
  8018c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cb:	e8 0c fd ff ff       	call   8015dc <_pipeisclosed>
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    
  8018d5:	00 00                	add    %al,(%eax)
	...

008018d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018e8:	68 fa 22 80 00       	push   $0x8022fa
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	e8 41 ee ff ff       	call   800736 <strcpy>
	return 0;
}
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	57                   	push   %edi
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801908:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80190c:	74 45                	je     801953 <devcons_write+0x57>
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
  801913:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801918:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80191e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801921:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801923:	83 fb 7f             	cmp    $0x7f,%ebx
  801926:	76 05                	jbe    80192d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801928:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	53                   	push   %ebx
  801931:	03 45 0c             	add    0xc(%ebp),%eax
  801934:	50                   	push   %eax
  801935:	57                   	push   %edi
  801936:	e8 bc ef ff ff       	call   8008f7 <memmove>
		sys_cputs(buf, m);
  80193b:	83 c4 08             	add    $0x8,%esp
  80193e:	53                   	push   %ebx
  80193f:	57                   	push   %edi
  801940:	e8 bc f1 ff ff       	call   800b01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801945:	01 de                	add    %ebx,%esi
  801947:	89 f0                	mov    %esi,%eax
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80194f:	72 cd                	jb     80191e <devcons_write+0x22>
  801951:	eb 05                	jmp    801958 <devcons_write+0x5c>
  801953:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801958:	89 f0                	mov    %esi,%eax
  80195a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5f                   	pop    %edi
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801968:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80196c:	75 07                	jne    801975 <devcons_read+0x13>
  80196e:	eb 25                	jmp    801995 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801970:	e8 1c f2 ff ff       	call   800b91 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801975:	e8 ad f1 ff ff       	call   800b27 <sys_cgetc>
  80197a:	85 c0                	test   %eax,%eax
  80197c:	74 f2                	je     801970 <devcons_read+0xe>
  80197e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801980:	85 c0                	test   %eax,%eax
  801982:	78 1d                	js     8019a1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801984:	83 f8 04             	cmp    $0x4,%eax
  801987:	74 13                	je     80199c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198c:	88 10                	mov    %dl,(%eax)
	return 1;
  80198e:	b8 01 00 00 00       	mov    $0x1,%eax
  801993:	eb 0c                	jmp    8019a1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	eb 05                	jmp    8019a1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019af:	6a 01                	push   $0x1
  8019b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	e8 47 f1 ff ff       	call   800b01 <sys_cputs>
  8019ba:	83 c4 10             	add    $0x10,%esp
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <getchar>:

int
getchar(void)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019c5:	6a 01                	push   $0x1
  8019c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ca:	50                   	push   %eax
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 fe f6 ff ff       	call   8010d0 <read>
	if (r < 0)
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 0f                	js     8019e8 <getchar+0x29>
		return r;
	if (r < 1)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	7e 06                	jle    8019e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8019dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019e1:	eb 05                	jmp    8019e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 08             	pushl  0x8(%ebp)
  8019f7:	e8 53 f4 ff ff       	call   800e4f <fd_lookup>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 11                	js     801a14 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0c:	39 10                	cmp    %edx,(%eax)
  801a0e:	0f 94 c0             	sete   %al
  801a11:	0f b6 c0             	movzbl %al,%eax
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <opencons>:

int
opencons(void)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 b7 f3 ff ff       	call   800ddc <fd_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 3a                	js     801a66 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	68 07 04 00 00       	push   $0x407
  801a34:	ff 75 f4             	pushl  -0xc(%ebp)
  801a37:	6a 00                	push   $0x0
  801a39:	e8 7a f1 ff ff       	call   800bb8 <sys_page_alloc>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 21                	js     801a66 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a45:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	50                   	push   %eax
  801a5e:	e8 51 f3 ff ff       	call   800db4 <fd2num>
  801a63:	83 c4 10             	add    $0x10,%esp
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a6d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a70:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801a76:	e8 f2 f0 ff ff       	call   800b6d <sys_getenvid>
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 0c             	pushl  0xc(%ebp)
  801a81:	ff 75 08             	pushl  0x8(%ebp)
  801a84:	53                   	push   %ebx
  801a85:	50                   	push   %eax
  801a86:	68 08 23 80 00       	push   $0x802308
  801a8b:	e8 f0 e6 ff ff       	call   800180 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a90:	83 c4 18             	add    $0x18,%esp
  801a93:	56                   	push   %esi
  801a94:	ff 75 10             	pushl  0x10(%ebp)
  801a97:	e8 93 e6 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  801a9c:	c7 04 24 f3 22 80 00 	movl   $0x8022f3,(%esp)
  801aa3:	e8 d8 e6 ff ff       	call   800180 <cprintf>
  801aa8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aab:	cc                   	int3   
  801aac:	eb fd                	jmp    801aab <_panic+0x43>
	...

00801ab0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	74 0e                	je     801ad0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	50                   	push   %eax
  801ac6:	e8 e8 f1 ff ff       	call   800cb3 <sys_ipc_recv>
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	eb 10                	jmp    801ae0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	68 00 00 c0 ee       	push   $0xeec00000
  801ad8:	e8 d6 f1 ff ff       	call   800cb3 <sys_ipc_recv>
  801add:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	75 26                	jne    801b0a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ae4:	85 f6                	test   %esi,%esi
  801ae6:	74 0a                	je     801af2 <ipc_recv+0x42>
  801ae8:	a1 04 40 80 00       	mov    0x804004,%eax
  801aed:	8b 40 74             	mov    0x74(%eax),%eax
  801af0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801af2:	85 db                	test   %ebx,%ebx
  801af4:	74 0a                	je     801b00 <ipc_recv+0x50>
  801af6:	a1 04 40 80 00       	mov    0x804004,%eax
  801afb:	8b 40 78             	mov    0x78(%eax),%eax
  801afe:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b00:	a1 04 40 80 00       	mov    0x804004,%eax
  801b05:	8b 40 70             	mov    0x70(%eax),%eax
  801b08:	eb 14                	jmp    801b1e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b0a:	85 f6                	test   %esi,%esi
  801b0c:	74 06                	je     801b14 <ipc_recv+0x64>
  801b0e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b14:	85 db                	test   %ebx,%ebx
  801b16:	74 06                	je     801b1e <ipc_recv+0x6e>
  801b18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b34:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b37:	85 db                	test   %ebx,%ebx
  801b39:	75 25                	jne    801b60 <ipc_send+0x3b>
  801b3b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b40:	eb 1e                	jmp    801b60 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b42:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b45:	75 07                	jne    801b4e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b47:	e8 45 f0 ff ff       	call   800b91 <sys_yield>
  801b4c:	eb 12                	jmp    801b60 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b4e:	50                   	push   %eax
  801b4f:	68 2c 23 80 00       	push   $0x80232c
  801b54:	6a 43                	push   $0x43
  801b56:	68 3f 23 80 00       	push   $0x80233f
  801b5b:	e8 08 ff ff ff       	call   801a68 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b60:	56                   	push   %esi
  801b61:	53                   	push   %ebx
  801b62:	57                   	push   %edi
  801b63:	ff 75 08             	pushl  0x8(%ebp)
  801b66:	e8 23 f1 ff ff       	call   800c8e <sys_ipc_try_send>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 d0                	jne    801b42 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b81:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b87:	74 22                	je     801bab <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b89:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b8e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	c1 e2 07             	shl    $0x7,%edx
  801b9a:	29 ca                	sub    %ecx,%edx
  801b9c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba2:	8b 52 50             	mov    0x50(%edx),%edx
  801ba5:	39 da                	cmp    %ebx,%edx
  801ba7:	75 1d                	jne    801bc6 <ipc_find_env+0x4c>
  801ba9:	eb 05                	jmp    801bb0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bb7:	c1 e0 07             	shl    $0x7,%eax
  801bba:	29 d0                	sub    %edx,%eax
  801bbc:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801bc1:	8b 40 40             	mov    0x40(%eax),%eax
  801bc4:	eb 0c                	jmp    801bd2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc6:	40                   	inc    %eax
  801bc7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bcc:	75 c0                	jne    801b8e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bce:	66 b8 00 00          	mov    $0x0,%ax
}
  801bd2:	5b                   	pop    %ebx
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    
  801bd5:	00 00                	add    %al,(%eax)
	...

00801bd8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bde:	89 c2                	mov    %eax,%edx
  801be0:	c1 ea 16             	shr    $0x16,%edx
  801be3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bea:	f6 c2 01             	test   $0x1,%dl
  801bed:	74 1e                	je     801c0d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bef:	c1 e8 0c             	shr    $0xc,%eax
  801bf2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bf9:	a8 01                	test   $0x1,%al
  801bfb:	74 17                	je     801c14 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfd:	c1 e8 0c             	shr    $0xc,%eax
  801c00:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c07:	ef 
  801c08:	0f b7 c0             	movzwl %ax,%eax
  801c0b:	eb 0c                	jmp    801c19 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c12:	eb 05                	jmp    801c19 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    
	...

00801c1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	83 ec 10             	sub    $0x10,%esp
  801c24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c27:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c2a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c30:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c33:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c36:	85 c0                	test   %eax,%eax
  801c38:	75 2e                	jne    801c68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c3a:	39 f1                	cmp    %esi,%ecx
  801c3c:	77 5a                	ja     801c98 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c3e:	85 c9                	test   %ecx,%ecx
  801c40:	75 0b                	jne    801c4d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c42:	b8 01 00 00 00       	mov    $0x1,%eax
  801c47:	31 d2                	xor    %edx,%edx
  801c49:	f7 f1                	div    %ecx
  801c4b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c4d:	31 d2                	xor    %edx,%edx
  801c4f:	89 f0                	mov    %esi,%eax
  801c51:	f7 f1                	div    %ecx
  801c53:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c55:	89 f8                	mov    %edi,%eax
  801c57:	f7 f1                	div    %ecx
  801c59:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    
  801c66:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c68:	39 f0                	cmp    %esi,%eax
  801c6a:	77 1c                	ja     801c88 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c6c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c6f:	83 f7 1f             	xor    $0x1f,%edi
  801c72:	75 3c                	jne    801cb0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c74:	39 f0                	cmp    %esi,%eax
  801c76:	0f 82 90 00 00 00    	jb     801d0c <__udivdi3+0xf0>
  801c7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c82:	0f 86 84 00 00 00    	jbe    801d0c <__udivdi3+0xf0>
  801c88:	31 f6                	xor    %esi,%esi
  801c8a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c8c:	89 f8                	mov    %edi,%eax
  801c8e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    
  801c97:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	89 f8                	mov    %edi,%eax
  801c9c:	f7 f1                	div    %ecx
  801c9e:	89 c7                	mov    %eax,%edi
  801ca0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ca2:	89 f8                	mov    %edi,%eax
  801ca4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    
  801cad:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cb0:	89 f9                	mov    %edi,%ecx
  801cb2:	d3 e0                	shl    %cl,%eax
  801cb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cb7:	b8 20 00 00 00       	mov    $0x20,%eax
  801cbc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc1:	88 c1                	mov    %al,%cl
  801cc3:	d3 ea                	shr    %cl,%edx
  801cc5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cc8:	09 ca                	or     %ecx,%edx
  801cca:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd0:	89 f9                	mov    %edi,%ecx
  801cd2:	d3 e2                	shl    %cl,%edx
  801cd4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cd7:	89 f2                	mov    %esi,%edx
  801cd9:	88 c1                	mov    %al,%cl
  801cdb:	d3 ea                	shr    %cl,%edx
  801cdd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801ce0:	89 f2                	mov    %esi,%edx
  801ce2:	89 f9                	mov    %edi,%ecx
  801ce4:	d3 e2                	shl    %cl,%edx
  801ce6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ce9:	88 c1                	mov    %al,%cl
  801ceb:	d3 ee                	shr    %cl,%esi
  801ced:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cf2:	89 f0                	mov    %esi,%eax
  801cf4:	89 ca                	mov    %ecx,%edx
  801cf6:	f7 75 ec             	divl   -0x14(%ebp)
  801cf9:	89 d1                	mov    %edx,%ecx
  801cfb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cfd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d00:	39 d1                	cmp    %edx,%ecx
  801d02:	72 28                	jb     801d2c <__udivdi3+0x110>
  801d04:	74 1a                	je     801d20 <__udivdi3+0x104>
  801d06:	89 f7                	mov    %esi,%edi
  801d08:	31 f6                	xor    %esi,%esi
  801d0a:	eb 80                	jmp    801c8c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d0c:	31 f6                	xor    %esi,%esi
  801d0e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d13:	89 f8                	mov    %edi,%eax
  801d15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    
  801d1e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d27:	39 c2                	cmp    %eax,%edx
  801d29:	73 db                	jae    801d06 <__udivdi3+0xea>
  801d2b:	90                   	nop
		{
		  q0--;
  801d2c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d2f:	31 f6                	xor    %esi,%esi
  801d31:	e9 56 ff ff ff       	jmp    801c8c <__udivdi3+0x70>
	...

00801d38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	83 ec 20             	sub    $0x20,%esp
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d49:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d4c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d55:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d57:	85 ff                	test   %edi,%edi
  801d59:	75 15                	jne    801d70 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d5b:	39 f1                	cmp    %esi,%ecx
  801d5d:	0f 86 99 00 00 00    	jbe    801dfc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d63:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d69:	83 c4 20             	add    $0x20,%esp
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d70:	39 f7                	cmp    %esi,%edi
  801d72:	0f 87 a4 00 00 00    	ja     801e1c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d78:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d7b:	83 f0 1f             	xor    $0x1f,%eax
  801d7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d81:	0f 84 a1 00 00 00    	je     801e28 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d87:	89 f8                	mov    %edi,%eax
  801d89:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d8c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d8e:	bf 20 00 00 00       	mov    $0x20,%edi
  801d93:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d99:	89 f9                	mov    %edi,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	09 c2                	or     %eax,%edx
  801d9f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801da8:	d3 e0                	shl    %cl,%eax
  801daa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801db1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db4:	d3 e0                	shl    %cl,%eax
  801db6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dbc:	89 f9                	mov    %edi,%ecx
  801dbe:	d3 e8                	shr    %cl,%eax
  801dc0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dc2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	f7 75 f0             	divl   -0x10(%ebp)
  801dc9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dcb:	f7 65 f4             	mull   -0xc(%ebp)
  801dce:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801dd1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd3:	39 d6                	cmp    %edx,%esi
  801dd5:	72 71                	jb     801e48 <__umoddi3+0x110>
  801dd7:	74 7f                	je     801e58 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ddc:	29 c8                	sub    %ecx,%eax
  801dde:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801de0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801de3:	d3 e8                	shr    %cl,%eax
  801de5:	89 f2                	mov    %esi,%edx
  801de7:	89 f9                	mov    %edi,%ecx
  801de9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801deb:	09 d0                	or     %edx,%eax
  801ded:	89 f2                	mov    %esi,%edx
  801def:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801df2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df4:	83 c4 20             	add    $0x20,%esp
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    
  801dfb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dfc:	85 c9                	test   %ecx,%ecx
  801dfe:	75 0b                	jne    801e0b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e00:	b8 01 00 00 00       	mov    $0x1,%eax
  801e05:	31 d2                	xor    %edx,%edx
  801e07:	f7 f1                	div    %ecx
  801e09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e0b:	89 f0                	mov    %esi,%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e14:	f7 f1                	div    %ecx
  801e16:	e9 4a ff ff ff       	jmp    801d65 <__umoddi3+0x2d>
  801e1b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e1c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e1e:	83 c4 20             	add    $0x20,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e28:	39 f7                	cmp    %esi,%edi
  801e2a:	72 05                	jb     801e31 <__umoddi3+0xf9>
  801e2c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e2f:	77 0c                	ja     801e3d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e31:	89 f2                	mov    %esi,%edx
  801e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e36:	29 c8                	sub    %ecx,%eax
  801e38:	19 fa                	sbb    %edi,%edx
  801e3a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e40:	83 c4 20             	add    $0x20,%esp
  801e43:	5e                   	pop    %esi
  801e44:	5f                   	pop    %edi
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    
  801e47:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e48:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e4b:	89 c1                	mov    %eax,%ecx
  801e4d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e50:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e53:	eb 84                	jmp    801dd9 <__umoddi3+0xa1>
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e58:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e5b:	72 eb                	jb     801e48 <__umoddi3+0x110>
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	e9 75 ff ff ff       	jmp    801dd9 <__umoddi3+0xa1>
