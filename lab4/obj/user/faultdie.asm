
obj/user/faultdie:     file format elf32-i386


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
  800046:	68 00 10 80 00       	push   $0x801000
  80004b:	e8 20 01 00 00       	call   800170 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 08 0b 00 00       	call   800b5d <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 de 0a 00 00       	call   800b3b <sys_env_destroy>
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
  80006d:	e8 56 0c 00 00       	call   800cc8 <set_pgfault_handler>
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
  80008f:	e8 c9 0a 00 00       	call   800b5d <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	c1 e0 07             	shl    $0x7,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 f6                	test   %esi,%esi
  8000a8:	7e 07                	jle    8000b1 <libmain+0x2d>
		binaryname = argv[0];
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000b1:	83 ec 08             	sub    $0x8,%esp
  8000b4:	53                   	push   %ebx
  8000b5:	56                   	push   %esi
  8000b6:	e8 a7 ff ff ff       	call   800062 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 0c 00 00 00       	call   8000cc <exit>
  8000c0:	83 c4 10             	add    $0x10,%esp
}
  8000c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d2:	6a 00                	push   $0x0
  8000d4:	e8 62 0a 00 00       	call   800b3b <sys_env_destroy>
  8000d9:	83 c4 10             	add    $0x10,%esp
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
	...

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 03                	mov    (%ebx),%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000f3:	40                   	inc    %eax
  8000f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fb:	75 1a                	jne    800117 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	68 ff 00 00 00       	push   $0xff
  800105:	8d 43 08             	lea    0x8(%ebx),%eax
  800108:	50                   	push   %eax
  800109:	e8 e3 09 00 00       	call   800af1 <sys_cputs>
		b->idx = 0;
  80010e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800114:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800117:	ff 43 04             	incl   0x4(%ebx)
}
  80011a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800128:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012f:	00 00 00 
	b.cnt = 0;
  800132:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800139:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013c:	ff 75 0c             	pushl  0xc(%ebp)
  80013f:	ff 75 08             	pushl  0x8(%ebp)
  800142:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800148:	50                   	push   %eax
  800149:	68 e0 00 80 00       	push   $0x8000e0
  80014e:	e8 82 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800153:	83 c4 08             	add    $0x8,%esp
  800156:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800162:	50                   	push   %eax
  800163:	e8 89 09 00 00       	call   800af1 <sys_cputs>

	return b.cnt;
}
  800168:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	50                   	push   %eax
  80017a:	ff 75 08             	pushl  0x8(%ebp)
  80017d:	e8 9d ff ff ff       	call   80011f <vcprintf>
	va_end(ap);

	return cnt;
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 2c             	sub    $0x2c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d6                	mov    %edx,%esi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	8b 55 0c             	mov    0xc(%ebp),%edx
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80019e:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001aa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001b1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001b4:	72 0c                	jb     8001c2 <printnum+0x3e>
  8001b6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001b9:	76 07                	jbe    8001c2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001bb:	4b                   	dec    %ebx
  8001bc:	85 db                	test   %ebx,%ebx
  8001be:	7f 31                	jg     8001f1 <printnum+0x6d>
  8001c0:	eb 3f                	jmp    800201 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	57                   	push   %edi
  8001c6:	4b                   	dec    %ebx
  8001c7:	53                   	push   %ebx
  8001c8:	50                   	push   %eax
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 c7 0b 00 00       	call   800da4 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e7:	e8 98 ff ff ff       	call   800184 <printnum>
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	eb 10                	jmp    800201 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	57                   	push   %edi
  8001f6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f9:	4b                   	dec    %ebx
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7f f0                	jg     8001f1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	ff 75 d4             	pushl  -0x2c(%ebp)
  80020b:	ff 75 d0             	pushl  -0x30(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 a7 0c 00 00       	call   800ec0 <__umoddi3>
  800219:	83 c4 14             	add    $0x14,%esp
  80021c:	0f be 80 26 10 80 00 	movsbl 0x801026(%eax),%eax
  800223:	50                   	push   %eax
  800224:	ff 55 e4             	call   *-0x1c(%ebp)
  800227:	83 c4 10             	add    $0x10,%esp
}
  80022a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5f                   	pop    %edi
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800235:	83 fa 01             	cmp    $0x1,%edx
  800238:	7e 0e                	jle    800248 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023f:	89 08                	mov    %ecx,(%eax)
  800241:	8b 02                	mov    (%edx),%eax
  800243:	8b 52 04             	mov    0x4(%edx),%edx
  800246:	eb 22                	jmp    80026a <getuint+0x38>
	else if (lflag)
  800248:	85 d2                	test   %edx,%edx
  80024a:	74 10                	je     80025c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80024c:	8b 10                	mov    (%eax),%edx
  80024e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	ba 00 00 00 00       	mov    $0x0,%edx
  80025a:	eb 0e                	jmp    80026a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getint+0x16>
		return va_arg(*ap, long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 1a                	jmp    80029c <getint+0x30>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 0c                	je     800292 <getint+0x26>
		return va_arg(*ap, long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	99                   	cltd   
  800290:	eb 0a                	jmp    80029c <getint+0x30>
	else
		return va_arg(*ap, int);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	99                   	cltd   
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 08                	jae    8002b6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b1:	88 0a                	mov    %cl,(%edx)
  8002b3:	42                   	inc    %edx
  8002b4:	89 10                	mov    %edx,(%eax)
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c1:	50                   	push   %eax
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 05 00 00 00       	call   8002d5 <vprintfmt>
	va_end(ap);
  8002d0:	83 c4 10             	add    $0x10,%esp
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 2c             	sub    $0x2c,%esp
  8002de:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002e1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e4:	eb 13                	jmp    8002f9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	0f 84 6d 03 00 00    	je     80065b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	57                   	push   %edi
  8002f2:	50                   	push   %eax
  8002f3:	ff 55 08             	call   *0x8(%ebp)
  8002f6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 06             	movzbl (%esi),%eax
  8002fc:	46                   	inc    %esi
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e4                	jne    8002e6 <vprintfmt+0x11>
  800302:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800306:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80030d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800314:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80031b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800320:	eb 28                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800324:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800328:	eb 20                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800330:	eb 18                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800334:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033b:	eb 0d                	jmp    80034a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800343:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8a 06                	mov    (%esi),%al
  80034c:	0f b6 d0             	movzbl %al,%edx
  80034f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800352:	83 e8 23             	sub    $0x23,%eax
  800355:	3c 55                	cmp    $0x55,%al
  800357:	0f 87 e0 02 00 00    	ja     80063d <vprintfmt+0x368>
  80035d:	0f b6 c0             	movzbl %al,%eax
  800360:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800367:	83 ea 30             	sub    $0x30,%edx
  80036a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80036d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800370:	8d 50 d0             	lea    -0x30(%eax),%edx
  800373:	83 fa 09             	cmp    $0x9,%edx
  800376:	77 44                	ja     8003bc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	89 de                	mov    %ebx,%esi
  80037a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80037e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800381:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800385:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800388:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80038b:	83 fb 09             	cmp    $0x9,%ebx
  80038e:	76 ed                	jbe    80037d <vprintfmt+0xa8>
  800390:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800393:	eb 29                	jmp    8003be <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 50 04             	lea    0x4(%eax),%edx
  80039b:	89 55 14             	mov    %edx,0x14(%ebp)
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a5:	eb 17                	jmp    8003be <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	78 85                	js     800332 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	89 de                	mov    %ebx,%esi
  8003af:	eb 99                	jmp    80034a <vprintfmt+0x75>
  8003b1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ba:	eb 8e                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c2:	79 86                	jns    80034a <vprintfmt+0x75>
  8003c4:	e9 74 ff ff ff       	jmp    80033d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
  8003cc:	e9 79 ff ff ff       	jmp    80034a <vprintfmt+0x75>
  8003d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	57                   	push   %edi
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ec:	e9 08 ff ff ff       	jmp    8002f9 <vprintfmt+0x24>
  8003f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	85 c0                	test   %eax,%eax
  800401:	79 02                	jns    800405 <vprintfmt+0x130>
  800403:	f7 d8                	neg    %eax
  800405:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 08             	cmp    $0x8,%eax
  80040a:	7f 0b                	jg     800417 <vprintfmt+0x142>
  80040c:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	75 1a                	jne    800431 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800417:	52                   	push   %edx
  800418:	68 3e 10 80 00       	push   $0x80103e
  80041d:	57                   	push   %edi
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 92 fe ff ff       	call   8002b8 <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 c8 fe ff ff       	jmp    8002f9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	50                   	push   %eax
  800432:	68 47 10 80 00       	push   $0x801047
  800437:	57                   	push   %edi
  800438:	ff 75 08             	pushl  0x8(%ebp)
  80043b:	e8 78 fe ff ff       	call   8002b8 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800446:	e9 ae fe ff ff       	jmp    8002f9 <vprintfmt+0x24>
  80044b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80044e:	89 de                	mov    %ebx,%esi
  800450:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800453:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800464:	85 c0                	test   %eax,%eax
  800466:	75 07                	jne    80046f <vprintfmt+0x19a>
				p = "(null)";
  800468:	c7 45 d0 37 10 80 00 	movl   $0x801037,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80046f:	85 db                	test   %ebx,%ebx
  800471:	7e 42                	jle    8004b5 <vprintfmt+0x1e0>
  800473:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800477:	74 3c                	je     8004b5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	51                   	push   %ecx
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	e8 6f 02 00 00       	call   8006f4 <strnlen>
  800485:	29 c3                	sub    %eax,%ebx
  800487:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	7e 24                	jle    8004b5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800491:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800495:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800498:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	57                   	push   %edi
  80049f:	53                   	push   %ebx
  8004a0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	4e                   	dec    %esi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	7f f0                	jg     80049b <vprintfmt+0x1c6>
  8004ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004b8:	0f be 02             	movsbl (%edx),%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	75 47                	jne    800506 <vprintfmt+0x231>
  8004bf:	eb 37                	jmp    8004f8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	74 16                	je     8004dd <vprintfmt+0x208>
  8004c7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ca:	83 fa 5e             	cmp    $0x5e,%edx
  8004cd:	76 0e                	jbe    8004dd <vprintfmt+0x208>
					putch('?', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	57                   	push   %edi
  8004d3:	6a 3f                	push   $0x3f
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	57                   	push   %edi
  8004e1:	50                   	push   %eax
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004eb:	0f be 03             	movsbl (%ebx),%eax
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	74 03                	je     8004f5 <vprintfmt+0x220>
  8004f2:	43                   	inc    %ebx
  8004f3:	eb 1b                	jmp    800510 <vprintfmt+0x23b>
  8004f5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fc:	7f 1e                	jg     80051c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800501:	e9 f3 fd ff ff       	jmp    8002f9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800506:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800509:	43                   	inc    %ebx
  80050a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80050d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800510:	85 f6                	test   %esi,%esi
  800512:	78 ad                	js     8004c1 <vprintfmt+0x1ec>
  800514:	4e                   	dec    %esi
  800515:	79 aa                	jns    8004c1 <vprintfmt+0x1ec>
  800517:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80051a:	eb dc                	jmp    8004f8 <vprintfmt+0x223>
  80051c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	57                   	push   %edi
  800523:	6a 20                	push   $0x20
  800525:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800528:	4b                   	dec    %ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f ef                	jg     80051f <vprintfmt+0x24a>
  800530:	e9 c4 fd ff ff       	jmp    8002f9 <vprintfmt+0x24>
  800535:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800538:	89 ca                	mov    %ecx,%edx
  80053a:	8d 45 14             	lea    0x14(%ebp),%eax
  80053d:	e8 2a fd ff ff       	call   80026c <getint>
  800542:	89 c3                	mov    %eax,%ebx
  800544:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800546:	85 d2                	test   %edx,%edx
  800548:	78 0a                	js     800554 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054f:	e9 b0 00 00 00       	jmp    800604 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	57                   	push   %edi
  800558:	6a 2d                	push   $0x2d
  80055a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80055d:	f7 db                	neg    %ebx
  80055f:	83 d6 00             	adc    $0x0,%esi
  800562:	f7 de                	neg    %esi
  800564:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 93 00 00 00       	jmp    800604 <vprintfmt+0x32f>
  800571:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800574:	89 ca                	mov    %ecx,%edx
  800576:	8d 45 14             	lea    0x14(%ebp),%eax
  800579:	e8 b4 fc ff ff       	call   800232 <getuint>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	89 d6                	mov    %edx,%esi
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800587:	eb 7b                	jmp    800604 <vprintfmt+0x32f>
  800589:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80058c:	89 ca                	mov    %ecx,%edx
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 d6 fc ff ff       	call   80026c <getint>
  800596:	89 c3                	mov    %eax,%ebx
  800598:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80059a:	85 d2                	test   %edx,%edx
  80059c:	78 07                	js     8005a5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80059e:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a3:	eb 5f                	jmp    800604 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	57                   	push   %edi
  8005a9:	6a 2d                	push   $0x2d
  8005ab:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005ae:	f7 db                	neg    %ebx
  8005b0:	83 d6 00             	adc    $0x0,%esi
  8005b3:	f7 de                	neg    %esi
  8005b5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005bd:	eb 45                	jmp    800604 <vprintfmt+0x32f>
  8005bf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	57                   	push   %edi
  8005c6:	6a 30                	push   $0x30
  8005c8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005cb:	83 c4 08             	add    $0x8,%esp
  8005ce:	57                   	push   %edi
  8005cf:	6a 78                	push   $0x78
  8005d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005dd:	8b 18                	mov    (%eax),%ebx
  8005df:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005ec:	eb 16                	jmp    800604 <vprintfmt+0x32f>
  8005ee:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 37 fc ff ff       	call   800232 <getuint>
  8005fb:	89 c3                	mov    %eax,%ebx
  8005fd:	89 d6                	mov    %edx,%esi
			base = 16;
  8005ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80060b:	52                   	push   %edx
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	50                   	push   %eax
  800610:	56                   	push   %esi
  800611:	53                   	push   %ebx
  800612:	89 fa                	mov    %edi,%edx
  800614:	8b 45 08             	mov    0x8(%ebp),%eax
  800617:	e8 68 fb ff ff       	call   800184 <printnum>
			break;
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800622:	e9 d2 fc ff ff       	jmp    8002f9 <vprintfmt+0x24>
  800627:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	57                   	push   %edi
  80062e:	52                   	push   %edx
  80062f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800638:	e9 bc fc ff ff       	jmp    8002f9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	57                   	push   %edi
  800641:	6a 25                	push   $0x25
  800643:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	eb 02                	jmp    80064d <vprintfmt+0x378>
  80064b:	89 c6                	mov    %eax,%esi
  80064d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800650:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800654:	75 f5                	jne    80064b <vprintfmt+0x376>
  800656:	e9 9e fc ff ff       	jmp    8002f9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	c9                   	leave  
  800662:	c3                   	ret    

00800663 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	83 ec 18             	sub    $0x18,%esp
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800672:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800676:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800679:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800680:	85 c0                	test   %eax,%eax
  800682:	74 26                	je     8006aa <vsnprintf+0x47>
  800684:	85 d2                	test   %edx,%edx
  800686:	7e 29                	jle    8006b1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800688:	ff 75 14             	pushl  0x14(%ebp)
  80068b:	ff 75 10             	pushl  0x10(%ebp)
  80068e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	68 9e 02 80 00       	push   $0x80029e
  800697:	e8 39 fc ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	eb 0c                	jmp    8006b6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006af:	eb 05                	jmp    8006b6 <vsnprintf+0x53>
  8006b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c1:	50                   	push   %eax
  8006c2:	ff 75 10             	pushl  0x10(%ebp)
  8006c5:	ff 75 0c             	pushl  0xc(%ebp)
  8006c8:	ff 75 08             	pushl  0x8(%ebp)
  8006cb:	e8 93 ff ff ff       	call   800663 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    
	...

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	80 3a 00             	cmpb   $0x0,(%edx)
  8006dd:	74 0e                	je     8006ed <strlen+0x19>
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006e4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e9:	75 f9                	jne    8006e4 <strlen+0x10>
  8006eb:	eb 05                	jmp    8006f2 <strlen+0x1e>
  8006ed:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	74 17                	je     800718 <strnlen+0x24>
  800701:	80 39 00             	cmpb   $0x0,(%ecx)
  800704:	74 19                	je     80071f <strnlen+0x2b>
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80070b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070c:	39 d0                	cmp    %edx,%eax
  80070e:	74 14                	je     800724 <strnlen+0x30>
  800710:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800714:	75 f5                	jne    80070b <strnlen+0x17>
  800716:	eb 0c                	jmp    800724 <strnlen+0x30>
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	eb 05                	jmp    800724 <strnlen+0x30>
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	53                   	push   %ebx
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800730:	ba 00 00 00 00       	mov    $0x0,%edx
  800735:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800738:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80073b:	42                   	inc    %edx
  80073c:	84 c9                	test   %cl,%cl
  80073e:	75 f5                	jne    800735 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800740:	5b                   	pop    %ebx
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074a:	53                   	push   %ebx
  80074b:	e8 84 ff ff ff       	call   8006d4 <strlen>
  800750:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800759:	50                   	push   %eax
  80075a:	e8 c7 ff ff ff       	call   800726 <strcpy>
	return dst;
}
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800774:	85 f6                	test   %esi,%esi
  800776:	74 15                	je     80078d <strncpy+0x27>
  800778:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80077d:	8a 1a                	mov    (%edx),%bl
  80077f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800782:	80 3a 01             	cmpb   $0x1,(%edx)
  800785:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	41                   	inc    %ecx
  800789:	39 ce                	cmp    %ecx,%esi
  80078b:	77 f0                	ja     80077d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	57                   	push   %edi
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	85 f6                	test   %esi,%esi
  8007a2:	74 32                	je     8007d6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007a4:	83 fe 01             	cmp    $0x1,%esi
  8007a7:	74 22                	je     8007cb <strlcpy+0x3a>
  8007a9:	8a 0b                	mov    (%ebx),%cl
  8007ab:	84 c9                	test   %cl,%cl
  8007ad:	74 20                	je     8007cf <strlcpy+0x3e>
  8007af:	89 f8                	mov    %edi,%eax
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007b6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b9:	88 08                	mov    %cl,(%eax)
  8007bb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007bc:	39 f2                	cmp    %esi,%edx
  8007be:	74 11                	je     8007d1 <strlcpy+0x40>
  8007c0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007c4:	42                   	inc    %edx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	75 f0                	jne    8007b9 <strlcpy+0x28>
  8007c9:	eb 06                	jmp    8007d1 <strlcpy+0x40>
  8007cb:	89 f8                	mov    %edi,%eax
  8007cd:	eb 02                	jmp    8007d1 <strlcpy+0x40>
  8007cf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d1:	c6 00 00             	movb   $0x0,(%eax)
  8007d4:	eb 02                	jmp    8007d8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007d8:	29 f8                	sub    %edi,%eax
}
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5f                   	pop    %edi
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e8:	8a 01                	mov    (%ecx),%al
  8007ea:	84 c0                	test   %al,%al
  8007ec:	74 10                	je     8007fe <strcmp+0x1f>
  8007ee:	3a 02                	cmp    (%edx),%al
  8007f0:	75 0c                	jne    8007fe <strcmp+0x1f>
		p++, q++;
  8007f2:	41                   	inc    %ecx
  8007f3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	8a 01                	mov    (%ecx),%al
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strcmp+0x1f>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	74 f4                	je     8007f2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 c0             	movzbl %al,%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 55 08             	mov    0x8(%ebp),%edx
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 1b                	je     800834 <strncmp+0x2c>
  800819:	8a 1a                	mov    (%edx),%bl
  80081b:	84 db                	test   %bl,%bl
  80081d:	74 24                	je     800843 <strncmp+0x3b>
  80081f:	3a 19                	cmp    (%ecx),%bl
  800821:	75 20                	jne    800843 <strncmp+0x3b>
  800823:	48                   	dec    %eax
  800824:	74 15                	je     80083b <strncmp+0x33>
		n--, p++, q++;
  800826:	42                   	inc    %edx
  800827:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800828:	8a 1a                	mov    (%edx),%bl
  80082a:	84 db                	test   %bl,%bl
  80082c:	74 15                	je     800843 <strncmp+0x3b>
  80082e:	3a 19                	cmp    (%ecx),%bl
  800830:	74 f1                	je     800823 <strncmp+0x1b>
  800832:	eb 0f                	jmp    800843 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	eb 05                	jmp    800840 <strncmp+0x38>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800840:	5b                   	pop    %ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 02             	movzbl (%edx),%eax
  800846:	0f b6 11             	movzbl (%ecx),%edx
  800849:	29 d0                	sub    %edx,%eax
  80084b:	eb f3                	jmp    800840 <strncmp+0x38>

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800856:	8a 10                	mov    (%eax),%dl
  800858:	84 d2                	test   %dl,%dl
  80085a:	74 18                	je     800874 <strchr+0x27>
		if (*s == c)
  80085c:	38 ca                	cmp    %cl,%dl
  80085e:	75 06                	jne    800866 <strchr+0x19>
  800860:	eb 17                	jmp    800879 <strchr+0x2c>
  800862:	38 ca                	cmp    %cl,%dl
  800864:	74 13                	je     800879 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800866:	40                   	inc    %eax
  800867:	8a 10                	mov    (%eax),%dl
  800869:	84 d2                	test   %dl,%dl
  80086b:	75 f5                	jne    800862 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	eb 05                	jmp    800879 <strchr+0x2c>
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800884:	8a 10                	mov    (%eax),%dl
  800886:	84 d2                	test   %dl,%dl
  800888:	74 11                	je     80089b <strfind+0x20>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	75 06                	jne    800894 <strfind+0x19>
  80088e:	eb 0b                	jmp    80089b <strfind+0x20>
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 07                	je     80089b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800894:	40                   	inc    %eax
  800895:	8a 10                	mov    (%eax),%dl
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f5                	jne    800890 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 30                	je     8008e0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b6:	75 25                	jne    8008dd <memset+0x40>
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 20                	jne    8008dd <memset+0x40>
		c &= 0xFF;
  8008bd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c0:	89 d3                	mov    %edx,%ebx
  8008c2:	c1 e3 08             	shl    $0x8,%ebx
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	c1 e6 18             	shl    $0x18,%esi
  8008ca:	89 d0                	mov    %edx,%eax
  8008cc:	c1 e0 10             	shl    $0x10,%eax
  8008cf:	09 f0                	or     %esi,%eax
  8008d1:	09 d0                	or     %edx,%eax
  8008d3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d8:	fc                   	cld    
  8008d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008db:	eb 03                	jmp    8008e0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dd:	fc                   	cld    
  8008de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f5:	39 c6                	cmp    %eax,%esi
  8008f7:	73 34                	jae    80092d <memmove+0x46>
  8008f9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fc:	39 d0                	cmp    %edx,%eax
  8008fe:	73 2d                	jae    80092d <memmove+0x46>
		s += n;
		d += n;
  800900:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800903:	f6 c2 03             	test   $0x3,%dl
  800906:	75 1b                	jne    800923 <memmove+0x3c>
  800908:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090e:	75 13                	jne    800923 <memmove+0x3c>
  800910:	f6 c1 03             	test   $0x3,%cl
  800913:	75 0e                	jne    800923 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800915:	83 ef 04             	sub    $0x4,%edi
  800918:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091e:	fd                   	std    
  80091f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800921:	eb 07                	jmp    80092a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800923:	4f                   	dec    %edi
  800924:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800927:	fd                   	std    
  800928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092a:	fc                   	cld    
  80092b:	eb 20                	jmp    80094d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800933:	75 13                	jne    800948 <memmove+0x61>
  800935:	a8 03                	test   $0x3,%al
  800937:	75 0f                	jne    800948 <memmove+0x61>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0a                	jne    800948 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 05                	jmp    80094d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800948:	89 c7                	mov    %eax,%edi
  80094a:	fc                   	cld    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 85 ff ff ff       	call   8008e7 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	85 ff                	test   %edi,%edi
  800975:	74 32                	je     8009a9 <memcmp+0x45>
		if (*s1 != *s2)
  800977:	8a 03                	mov    (%ebx),%al
  800979:	8a 0e                	mov    (%esi),%cl
  80097b:	38 c8                	cmp    %cl,%al
  80097d:	74 19                	je     800998 <memcmp+0x34>
  80097f:	eb 0d                	jmp    80098e <memcmp+0x2a>
  800981:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800985:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800989:	42                   	inc    %edx
  80098a:	38 c8                	cmp    %cl,%al
  80098c:	74 10                	je     80099e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	0f b6 c9             	movzbl %cl,%ecx
  800994:	29 c8                	sub    %ecx,%eax
  800996:	eb 16                	jmp    8009ae <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	4f                   	dec    %edi
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	39 fa                	cmp    %edi,%edx
  8009a0:	75 df                	jne    800981 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a7:	eb 05                	jmp    8009ae <memcmp+0x4a>
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	73 12                	jae    8009d4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009c5:	38 08                	cmp    %cl,(%eax)
  8009c7:	75 06                	jne    8009cf <memfind+0x1c>
  8009c9:	eb 09                	jmp    8009d4 <memfind+0x21>
  8009cb:	38 08                	cmp    %cl,(%eax)
  8009cd:	74 05                	je     8009d4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	40                   	inc    %eax
  8009d0:	39 c2                	cmp    %eax,%edx
  8009d2:	77 f7                	ja     8009cb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	eb 01                	jmp    8009e5 <strtol+0xf>
		s++;
  8009e4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e5:	8a 02                	mov    (%edx),%al
  8009e7:	3c 20                	cmp    $0x20,%al
  8009e9:	74 f9                	je     8009e4 <strtol+0xe>
  8009eb:	3c 09                	cmp    $0x9,%al
  8009ed:	74 f5                	je     8009e4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ef:	3c 2b                	cmp    $0x2b,%al
  8009f1:	75 08                	jne    8009fb <strtol+0x25>
		s++;
  8009f3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f9:	eb 13                	jmp    800a0e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fb:	3c 2d                	cmp    $0x2d,%al
  8009fd:	75 0a                	jne    800a09 <strtol+0x33>
		s++, neg = 1;
  8009ff:	8d 52 01             	lea    0x1(%edx),%edx
  800a02:	bf 01 00 00 00       	mov    $0x1,%edi
  800a07:	eb 05                	jmp    800a0e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0e:	85 db                	test   %ebx,%ebx
  800a10:	74 05                	je     800a17 <strtol+0x41>
  800a12:	83 fb 10             	cmp    $0x10,%ebx
  800a15:	75 28                	jne    800a3f <strtol+0x69>
  800a17:	8a 02                	mov    (%edx),%al
  800a19:	3c 30                	cmp    $0x30,%al
  800a1b:	75 10                	jne    800a2d <strtol+0x57>
  800a1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a21:	75 0a                	jne    800a2d <strtol+0x57>
		s += 2, base = 16;
  800a23:	83 c2 02             	add    $0x2,%edx
  800a26:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2b:	eb 12                	jmp    800a3f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	75 0e                	jne    800a3f <strtol+0x69>
  800a31:	3c 30                	cmp    $0x30,%al
  800a33:	75 05                	jne    800a3a <strtol+0x64>
		s++, base = 8;
  800a35:	42                   	inc    %edx
  800a36:	b3 08                	mov    $0x8,%bl
  800a38:	eb 05                	jmp    800a3f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a46:	8a 0a                	mov    (%edx),%cl
  800a48:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a4b:	80 fb 09             	cmp    $0x9,%bl
  800a4e:	77 08                	ja     800a58 <strtol+0x82>
			dig = *s - '0';
  800a50:	0f be c9             	movsbl %cl,%ecx
  800a53:	83 e9 30             	sub    $0x30,%ecx
  800a56:	eb 1e                	jmp    800a76 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a58:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a5b:	80 fb 19             	cmp    $0x19,%bl
  800a5e:	77 08                	ja     800a68 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a60:	0f be c9             	movsbl %cl,%ecx
  800a63:	83 e9 57             	sub    $0x57,%ecx
  800a66:	eb 0e                	jmp    800a76 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a68:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 13                	ja     800a83 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a70:	0f be c9             	movsbl %cl,%ecx
  800a73:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a76:	39 f1                	cmp    %esi,%ecx
  800a78:	7d 0d                	jge    800a87 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a7a:	42                   	inc    %edx
  800a7b:	0f af c6             	imul   %esi,%eax
  800a7e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a81:	eb c3                	jmp    800a46 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	eb 02                	jmp    800a89 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a87:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8d:	74 05                	je     800a94 <strtol+0xbe>
		*endptr = (char *) s;
  800a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a92:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a94:	85 ff                	test   %edi,%edi
  800a96:	74 04                	je     800a9c <strtol+0xc6>
  800a98:	89 c8                	mov    %ecx,%eax
  800a9a:	f7 d8                	neg    %eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    
  800aa1:	00 00                	add    %al,(%eax)
	...

00800aa4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 1c             	sub    $0x1c,%esp
  800aad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ab3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ab8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac1:	cd 30                	int    $0x30
  800ac3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ac9:	74 1c                	je     800ae7 <syscall+0x43>
  800acb:	85 c0                	test   %eax,%eax
  800acd:	7e 18                	jle    800ae7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	50                   	push   %eax
  800ad3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ad6:	68 64 12 80 00       	push   $0x801264
  800adb:	6a 42                	push   $0x42
  800add:	68 81 12 80 00       	push   $0x801281
  800ae2:	e8 75 02 00 00       	call   800d5c <_panic>

	return ret;
}
  800ae7:	89 d0                	mov    %edx,%eax
  800ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800af7:	6a 00                	push   $0x0
  800af9:	6a 00                	push   $0x0
  800afb:	6a 00                	push   $0x0
  800afd:	ff 75 0c             	pushl  0xc(%ebp)
  800b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	e8 92 ff ff ff       	call   800aa4 <syscall>
  800b12:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	e8 6b ff ff ff       	call   800aa4 <syscall>
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b51:	b8 03 00 00 00       	mov    $0x3,%eax
  800b56:	e8 49 ff ff ff       	call   800aa4 <syscall>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7a:	e8 25 ff ff ff       	call   800aa4 <syscall>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_yield>:

void
sys_yield(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9e:	e8 01 ff ff ff       	call   800aa4 <syscall>
  800ba3:	83 c4 10             	add    $0x10,%esp
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bae:	6a 00                	push   $0x0
  800bb0:	6a 00                	push   $0x0
  800bb2:	ff 75 10             	pushl  0x10(%ebp)
  800bb5:	ff 75 0c             	pushl  0xc(%ebp)
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc5:	e8 da fe ff ff       	call   800aa4 <syscall>
}
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bd2:	ff 75 18             	pushl  0x18(%ebp)
  800bd5:	ff 75 14             	pushl  0x14(%ebp)
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be1:	ba 01 00 00 00       	mov    $0x1,%edx
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	e8 b4 fe ff ff       	call   800aa4 <syscall>
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bf8:	6a 00                	push   $0x0
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	ff 75 0c             	pushl  0xc(%ebp)
  800c01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c04:	ba 01 00 00 00       	mov    $0x1,%edx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	e8 91 fe ff ff       	call   800aa4 <syscall>
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    

00800c15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c27:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c31:	e8 6e fe ff ff       	call   800aa4 <syscall>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c3e:	6a 00                	push   $0x0
  800c40:	6a 00                	push   $0x0
  800c42:	6a 00                	push   $0x0
  800c44:	ff 75 0c             	pushl  0xc(%ebp)
  800c47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c54:	e8 4b fe ff ff       	call   800aa4 <syscall>
}
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c61:	6a 00                	push   $0x0
  800c63:	ff 75 14             	pushl  0x14(%ebp)
  800c66:	ff 75 10             	pushl  0x10(%ebp)
  800c69:	ff 75 0c             	pushl  0xc(%ebp)
  800c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c79:	e8 26 fe ff ff       	call   800aa4 <syscall>
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	6a 00                	push   $0x0
  800c8c:	6a 00                	push   $0x0
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9b:	e8 04 fe ff ff       	call   800aa4 <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ca8:	6a 00                	push   $0x0
  800caa:	6a 00                	push   $0x0
  800cac:	6a 00                	push   $0x0
  800cae:	ff 75 0c             	pushl  0xc(%ebp)
  800cb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	e8 e1 fd ff ff       	call   800aa4 <syscall>
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    
  800cc5:	00 00                	add    %al,(%eax)
	...

00800cc8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cce:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cd5:	75 52                	jne    800d29 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800cd7:	83 ec 04             	sub    $0x4,%esp
  800cda:	6a 07                	push   $0x7
  800cdc:	68 00 f0 bf ee       	push   $0xeebff000
  800ce1:	6a 00                	push   $0x0
  800ce3:	e8 c0 fe ff ff       	call   800ba8 <sys_page_alloc>
		if (r < 0) {
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	79 12                	jns    800d01 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800cef:	50                   	push   %eax
  800cf0:	68 8f 12 80 00       	push   $0x80128f
  800cf5:	6a 24                	push   $0x24
  800cf7:	68 aa 12 80 00       	push   $0x8012aa
  800cfc:	e8 5b 00 00 00       	call   800d5c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	68 34 0d 80 00       	push   $0x800d34
  800d09:	6a 00                	push   $0x0
  800d0b:	e8 28 ff ff ff       	call   800c38 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	85 c0                	test   %eax,%eax
  800d15:	79 12                	jns    800d29 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d17:	50                   	push   %eax
  800d18:	68 b8 12 80 00       	push   $0x8012b8
  800d1d:	6a 2a                	push   $0x2a
  800d1f:	68 aa 12 80 00       	push   $0x8012aa
  800d24:	e8 33 00 00 00       	call   800d5c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    
	...

00800d34 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d34:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d35:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d3a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d3c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800d3f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d43:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d46:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800d4a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800d4e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800d50:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800d53:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800d54:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800d57:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d58:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800d59:	c3                   	ret    
	...

00800d5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d61:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d64:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d6a:	e8 ee fd ff ff       	call   800b5d <sys_getenvid>
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	ff 75 08             	pushl  0x8(%ebp)
  800d78:	53                   	push   %ebx
  800d79:	50                   	push   %eax
  800d7a:	68 e0 12 80 00       	push   $0x8012e0
  800d7f:	e8 ec f3 ff ff       	call   800170 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d84:	83 c4 18             	add    $0x18,%esp
  800d87:	56                   	push   %esi
  800d88:	ff 75 10             	pushl  0x10(%ebp)
  800d8b:	e8 8f f3 ff ff       	call   80011f <vcprintf>
	cprintf("\n");
  800d90:	c7 04 24 a8 12 80 00 	movl   $0x8012a8,(%esp)
  800d97:	e8 d4 f3 ff ff       	call   800170 <cprintf>
  800d9c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d9f:	cc                   	int3   
  800da0:	eb fd                	jmp    800d9f <_panic+0x43>
	...

00800da4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	83 ec 10             	sub    $0x10,%esp
  800dac:	8b 7d 08             	mov    0x8(%ebp),%edi
  800daf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800db2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800db5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800db8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dbb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	75 2e                	jne    800df0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dc2:	39 f1                	cmp    %esi,%ecx
  800dc4:	77 5a                	ja     800e20 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dc6:	85 c9                	test   %ecx,%ecx
  800dc8:	75 0b                	jne    800dd5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dca:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcf:	31 d2                	xor    %edx,%edx
  800dd1:	f7 f1                	div    %ecx
  800dd3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dd5:	31 d2                	xor    %edx,%edx
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	f7 f1                	div    %ecx
  800ddb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ddd:	89 f8                	mov    %edi,%eax
  800ddf:	f7 f1                	div    %ecx
  800de1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de3:	89 f8                	mov    %edi,%eax
  800de5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	c9                   	leave  
  800ded:	c3                   	ret    
  800dee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df0:	39 f0                	cmp    %esi,%eax
  800df2:	77 1c                	ja     800e10 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800df4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	75 3c                	jne    800e38 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dfc:	39 f0                	cmp    %esi,%eax
  800dfe:	0f 82 90 00 00 00    	jb     800e94 <__udivdi3+0xf0>
  800e04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e07:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e0a:	0f 86 84 00 00 00    	jbe    800e94 <__udivdi3+0xf0>
  800e10:	31 f6                	xor    %esi,%esi
  800e12:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e14:	89 f8                	mov    %edi,%eax
  800e16:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	c9                   	leave  
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e20:	89 f2                	mov    %esi,%edx
  800e22:	89 f8                	mov    %edi,%eax
  800e24:	f7 f1                	div    %ecx
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e2a:	89 f8                	mov    %edi,%eax
  800e2c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e38:	89 f9                	mov    %edi,%ecx
  800e3a:	d3 e0                	shl    %cl,%eax
  800e3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3f:	b8 20 00 00 00       	mov    $0x20,%eax
  800e44:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e49:	88 c1                	mov    %al,%cl
  800e4b:	d3 ea                	shr    %cl,%edx
  800e4d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e50:	09 ca                	or     %ecx,%edx
  800e52:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e58:	89 f9                	mov    %edi,%ecx
  800e5a:	d3 e2                	shl    %cl,%edx
  800e5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e5f:	89 f2                	mov    %esi,%edx
  800e61:	88 c1                	mov    %al,%cl
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e68:	89 f2                	mov    %esi,%edx
  800e6a:	89 f9                	mov    %edi,%ecx
  800e6c:	d3 e2                	shl    %cl,%edx
  800e6e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e71:	88 c1                	mov    %al,%cl
  800e73:	d3 ee                	shr    %cl,%esi
  800e75:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e77:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e7a:	89 f0                	mov    %esi,%eax
  800e7c:	89 ca                	mov    %ecx,%edx
  800e7e:	f7 75 ec             	divl   -0x14(%ebp)
  800e81:	89 d1                	mov    %edx,%ecx
  800e83:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e85:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e88:	39 d1                	cmp    %edx,%ecx
  800e8a:	72 28                	jb     800eb4 <__udivdi3+0x110>
  800e8c:	74 1a                	je     800ea8 <__udivdi3+0x104>
  800e8e:	89 f7                	mov    %esi,%edi
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	eb 80                	jmp    800e14 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e94:	31 f6                	xor    %esi,%esi
  800e96:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e9b:	89 f8                	mov    %edi,%eax
  800e9d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    
  800ea6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ea8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eab:	89 f9                	mov    %edi,%ecx
  800ead:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eaf:	39 c2                	cmp    %eax,%edx
  800eb1:	73 db                	jae    800e8e <__udivdi3+0xea>
  800eb3:	90                   	nop
		{
		  q0--;
  800eb4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eb7:	31 f6                	xor    %esi,%esi
  800eb9:	e9 56 ff ff ff       	jmp    800e14 <__udivdi3+0x70>
	...

00800ec0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	83 ec 20             	sub    $0x20,%esp
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ece:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ed4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ed7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800edd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800edf:	85 ff                	test   %edi,%edi
  800ee1:	75 15                	jne    800ef8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800ee3:	39 f1                	cmp    %esi,%ecx
  800ee5:	0f 86 99 00 00 00    	jbe    800f84 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eeb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800eed:	89 d0                	mov    %edx,%eax
  800eef:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ef8:	39 f7                	cmp    %esi,%edi
  800efa:	0f 87 a4 00 00 00    	ja     800fa4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f00:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f03:	83 f0 1f             	xor    $0x1f,%eax
  800f06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f09:	0f 84 a1 00 00 00    	je     800fb0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f0f:	89 f8                	mov    %edi,%eax
  800f11:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f14:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f16:	bf 20 00 00 00       	mov    $0x20,%edi
  800f1b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 ea                	shr    %cl,%edx
  800f25:	09 c2                	or     %eax,%edx
  800f27:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f30:	d3 e0                	shl    %cl,%eax
  800f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f35:	89 f2                	mov    %esi,%edx
  800f37:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f3c:	d3 e0                	shl    %cl,%eax
  800f3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f44:	89 f9                	mov    %edi,%ecx
  800f46:	d3 e8                	shr    %cl,%eax
  800f48:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f4a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f4c:	89 f2                	mov    %esi,%edx
  800f4e:	f7 75 f0             	divl   -0x10(%ebp)
  800f51:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f53:	f7 65 f4             	mull   -0xc(%ebp)
  800f56:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f59:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f5b:	39 d6                	cmp    %edx,%esi
  800f5d:	72 71                	jb     800fd0 <__umoddi3+0x110>
  800f5f:	74 7f                	je     800fe0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f64:	29 c8                	sub    %ecx,%eax
  800f66:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f68:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	89 f9                	mov    %edi,%ecx
  800f71:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f73:	09 d0                	or     %edx,%eax
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f7a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    
  800f83:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f84:	85 c9                	test   %ecx,%ecx
  800f86:	75 0b                	jne    800f93 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	f7 f1                	div    %ecx
  800f91:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f93:	89 f0                	mov    %esi,%eax
  800f95:	31 d2                	xor    %edx,%edx
  800f97:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9c:	f7 f1                	div    %ecx
  800f9e:	e9 4a ff ff ff       	jmp    800eed <__umoddi3+0x2d>
  800fa3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fa4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb0:	39 f7                	cmp    %esi,%edi
  800fb2:	72 05                	jb     800fb9 <__umoddi3+0xf9>
  800fb4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800fb7:	77 0c                	ja     800fc5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fb9:	89 f2                	mov    %esi,%edx
  800fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbe:	29 c8                	sub    %ecx,%eax
  800fc0:	19 fa                	sbb    %edi,%edx
  800fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fc8:	83 c4 20             	add    $0x20,%esp
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
  800fcf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800fd8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800fdb:	eb 84                	jmp    800f61 <__umoddi3+0xa1>
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fe3:	72 eb                	jb     800fd0 <__umoddi3+0x110>
  800fe5:	89 f2                	mov    %esi,%edx
  800fe7:	e9 75 ff ff ff       	jmp    800f61 <__umoddi3+0xa1>
