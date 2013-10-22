
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
  800046:	68 e0 0f 80 00       	push   $0x800fe0
  80004b:	e8 28 01 00 00       	call   800178 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 10 0b 00 00       	call   800b65 <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 e6 0a 00 00       	call   800b43 <sys_env_destroy>
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
  80006d:	e8 3a 0c 00 00       	call   800cac <set_pgfault_handler>
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
  80008f:	e8 d1 0a 00 00       	call   800b65 <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a0:	c1 e0 07             	shl    $0x7,%eax
  8000a3:	29 d0                	sub    %edx,%eax
  8000a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000aa:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 07                	jle    8000ba <libmain+0x36>
		binaryname = argv[0];
  8000b3:	8b 03                	mov    (%ebx),%eax
  8000b5:	a3 00 20 80 00       	mov    %eax,0x802000
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
  8000d7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 62 0a 00 00       	call   800b43 <sys_env_destroy>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
	...

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 04             	sub    $0x4,%esp
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f2:	8b 03                	mov    (%ebx),%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000fb:	40                   	inc    %eax
  8000fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800103:	75 1a                	jne    80011f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800105:	83 ec 08             	sub    $0x8,%esp
  800108:	68 ff 00 00 00       	push   $0xff
  80010d:	8d 43 08             	lea    0x8(%ebx),%eax
  800110:	50                   	push   %eax
  800111:	e8 e3 09 00 00       	call   800af9 <sys_cputs>
		b->idx = 0;
  800116:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011f:	ff 43 04             	incl   0x4(%ebx)
}
  800122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800130:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800137:	00 00 00 
	b.cnt = 0;
  80013a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800141:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800144:	ff 75 0c             	pushl  0xc(%ebp)
  800147:	ff 75 08             	pushl  0x8(%ebp)
  80014a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800150:	50                   	push   %eax
  800151:	68 e8 00 80 00       	push   $0x8000e8
  800156:	e8 82 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	83 c4 08             	add    $0x8,%esp
  80015e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800164:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 89 09 00 00       	call   800af9 <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800181:	50                   	push   %eax
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	e8 9d ff ff ff       	call   800127 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 2c             	sub    $0x2c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d6                	mov    %edx,%esi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ac:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001b9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001bc:	72 0c                	jb     8001ca <printnum+0x3e>
  8001be:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001c1:	76 07                	jbe    8001ca <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c3:	4b                   	dec    %ebx
  8001c4:	85 db                	test   %ebx,%ebx
  8001c6:	7f 31                	jg     8001f9 <printnum+0x6d>
  8001c8:	eb 3f                	jmp    800209 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	57                   	push   %edi
  8001ce:	4b                   	dec    %ebx
  8001cf:	53                   	push   %ebx
  8001d0:	50                   	push   %eax
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001da:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e0:	e8 a3 0b 00 00       	call   800d88 <__udivdi3>
  8001e5:	83 c4 18             	add    $0x18,%esp
  8001e8:	52                   	push   %edx
  8001e9:	50                   	push   %eax
  8001ea:	89 f2                	mov    %esi,%edx
  8001ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ef:	e8 98 ff ff ff       	call   80018c <printnum>
  8001f4:	83 c4 20             	add    $0x20,%esp
  8001f7:	eb 10                	jmp    800209 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	57                   	push   %edi
  8001fe:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800201:	4b                   	dec    %ebx
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	85 db                	test   %ebx,%ebx
  800207:	7f f0                	jg     8001f9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	83 ec 04             	sub    $0x4,%esp
  800210:	ff 75 d4             	pushl  -0x2c(%ebp)
  800213:	ff 75 d0             	pushl  -0x30(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 83 0c 00 00       	call   800ea4 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 06 10 80 00 	movsbl 0x801006(%eax),%eax
  80022b:	50                   	push   %eax
  80022c:	ff 55 e4             	call   *-0x1c(%ebp)
  80022f:	83 c4 10             	add    $0x10,%esp
}
  800232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023d:	83 fa 01             	cmp    $0x1,%edx
  800240:	7e 0e                	jle    800250 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 08             	lea    0x8(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	8b 52 04             	mov    0x4(%edx),%edx
  80024e:	eb 22                	jmp    800272 <getuint+0x38>
	else if (lflag)
  800250:	85 d2                	test   %edx,%edx
  800252:	74 10                	je     800264 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
  800262:	eb 0e                	jmp    800272 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getint+0x16>
		return va_arg(*ap, long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 1a                	jmp    8002a4 <getint+0x30>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 0c                	je     80029a <getint+0x26>
		return va_arg(*ap, long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	99                   	cltd   
  800298:	eb 0a                	jmp    8002a4 <getint+0x30>
	else
		return va_arg(*ap, int);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	99                   	cltd   
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 08                	jae    8002be <sprintputch+0x18>
		*b->buf++ = ch;
  8002b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b9:	88 0a                	mov    %cl,(%edx)
  8002bb:	42                   	inc    %edx
  8002bc:	89 10                	mov    %edx,(%eax)
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c9:	50                   	push   %eax
  8002ca:	ff 75 10             	pushl  0x10(%ebp)
  8002cd:	ff 75 0c             	pushl  0xc(%ebp)
  8002d0:	ff 75 08             	pushl  0x8(%ebp)
  8002d3:	e8 05 00 00 00       	call   8002dd <vprintfmt>
	va_end(ap);
  8002d8:	83 c4 10             	add    $0x10,%esp
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 2c             	sub    $0x2c,%esp
  8002e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002ec:	eb 13                	jmp    800301 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	0f 84 6d 03 00 00    	je     800663 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	57                   	push   %edi
  8002fa:	50                   	push   %eax
  8002fb:	ff 55 08             	call   *0x8(%ebp)
  8002fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800301:	0f b6 06             	movzbl (%esi),%eax
  800304:	46                   	inc    %esi
  800305:	83 f8 25             	cmp    $0x25,%eax
  800308:	75 e4                	jne    8002ee <vprintfmt+0x11>
  80030a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80030e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800315:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80031c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	eb 28                	jmp    800352 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800330:	eb 20                	jmp    800352 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800334:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800338:	eb 18                	jmp    800352 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80033c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800343:	eb 0d                	jmp    800352 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800345:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800348:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8a 06                	mov    (%esi),%al
  800354:	0f b6 d0             	movzbl %al,%edx
  800357:	8d 5e 01             	lea    0x1(%esi),%ebx
  80035a:	83 e8 23             	sub    $0x23,%eax
  80035d:	3c 55                	cmp    $0x55,%al
  80035f:	0f 87 e0 02 00 00    	ja     800645 <vprintfmt+0x368>
  800365:	0f b6 c0             	movzbl %al,%eax
  800368:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036f:	83 ea 30             	sub    $0x30,%edx
  800372:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800375:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800378:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037b:	83 fa 09             	cmp    $0x9,%edx
  80037e:	77 44                	ja     8003c4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	89 de                	mov    %ebx,%esi
  800382:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800385:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800386:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800389:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80038d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800390:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800393:	83 fb 09             	cmp    $0x9,%ebx
  800396:	76 ed                	jbe    800385 <vprintfmt+0xa8>
  800398:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80039b:	eb 29                	jmp    8003c6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ad:	eb 17                	jmp    8003c6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b3:	78 85                	js     80033a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	89 de                	mov    %ebx,%esi
  8003b7:	eb 99                	jmp    800352 <vprintfmt+0x75>
  8003b9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003c2:	eb 8e                	jmp    800352 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ca:	79 86                	jns    800352 <vprintfmt+0x75>
  8003cc:	e9 74 ff ff ff       	jmp    800345 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi
  8003d4:	e9 79 ff ff ff       	jmp    800352 <vprintfmt+0x75>
  8003d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	57                   	push   %edi
  8003e9:	ff 30                	pushl  (%eax)
  8003eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 08 ff ff ff       	jmp    800301 <vprintfmt+0x24>
  8003f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	79 02                	jns    80040d <vprintfmt+0x130>
  80040b:	f7 d8                	neg    %eax
  80040d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 f8 08             	cmp    $0x8,%eax
  800412:	7f 0b                	jg     80041f <vprintfmt+0x142>
  800414:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	75 1a                	jne    800439 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80041f:	52                   	push   %edx
  800420:	68 1e 10 80 00       	push   $0x80101e
  800425:	57                   	push   %edi
  800426:	ff 75 08             	pushl  0x8(%ebp)
  800429:	e8 92 fe ff ff       	call   8002c0 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 c8 fe ff ff       	jmp    800301 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	50                   	push   %eax
  80043a:	68 27 10 80 00       	push   $0x801027
  80043f:	57                   	push   %edi
  800440:	ff 75 08             	pushl  0x8(%ebp)
  800443:	e8 78 fe ff ff       	call   8002c0 <printfmt>
  800448:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80044e:	e9 ae fe ff ff       	jmp    800301 <vprintfmt+0x24>
  800453:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800456:	89 de                	mov    %ebx,%esi
  800458:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80045b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80046c:	85 c0                	test   %eax,%eax
  80046e:	75 07                	jne    800477 <vprintfmt+0x19a>
				p = "(null)";
  800470:	c7 45 d0 17 10 80 00 	movl   $0x801017,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800477:	85 db                	test   %ebx,%ebx
  800479:	7e 42                	jle    8004bd <vprintfmt+0x1e0>
  80047b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80047f:	74 3c                	je     8004bd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	51                   	push   %ecx
  800485:	ff 75 d0             	pushl  -0x30(%ebp)
  800488:	e8 6f 02 00 00       	call   8006fc <strnlen>
  80048d:	29 c3                	sub    %eax,%ebx
  80048f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 db                	test   %ebx,%ebx
  800497:	7e 24                	jle    8004bd <vprintfmt+0x1e0>
					putch(padc, putdat);
  800499:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80049d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004a0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	57                   	push   %edi
  8004a7:	53                   	push   %ebx
  8004a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	4e                   	dec    %esi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	85 f6                	test   %esi,%esi
  8004b1:	7f f0                	jg     8004a3 <vprintfmt+0x1c6>
  8004b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c0:	0f be 02             	movsbl (%edx),%eax
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	75 47                	jne    80050e <vprintfmt+0x231>
  8004c7:	eb 37                	jmp    800500 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	74 16                	je     8004e5 <vprintfmt+0x208>
  8004cf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d2:	83 fa 5e             	cmp    $0x5e,%edx
  8004d5:	76 0e                	jbe    8004e5 <vprintfmt+0x208>
					putch('?', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	57                   	push   %edi
  8004db:	6a 3f                	push   $0x3f
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb 0b                	jmp    8004f0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	57                   	push   %edi
  8004e9:	50                   	push   %eax
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f3:	0f be 03             	movsbl (%ebx),%eax
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	74 03                	je     8004fd <vprintfmt+0x220>
  8004fa:	43                   	inc    %ebx
  8004fb:	eb 1b                	jmp    800518 <vprintfmt+0x23b>
  8004fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800500:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800504:	7f 1e                	jg     800524 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800509:	e9 f3 fd ff ff       	jmp    800301 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800511:	43                   	inc    %ebx
  800512:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800515:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 ad                	js     8004c9 <vprintfmt+0x1ec>
  80051c:	4e                   	dec    %esi
  80051d:	79 aa                	jns    8004c9 <vprintfmt+0x1ec>
  80051f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800522:	eb dc                	jmp    800500 <vprintfmt+0x223>
  800524:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	57                   	push   %edi
  80052b:	6a 20                	push   $0x20
  80052d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800530:	4b                   	dec    %ebx
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f ef                	jg     800527 <vprintfmt+0x24a>
  800538:	e9 c4 fd ff ff       	jmp    800301 <vprintfmt+0x24>
  80053d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800540:	89 ca                	mov    %ecx,%edx
  800542:	8d 45 14             	lea    0x14(%ebp),%eax
  800545:	e8 2a fd ff ff       	call   800274 <getint>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80054e:	85 d2                	test   %edx,%edx
  800550:	78 0a                	js     80055c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 b0 00 00 00       	jmp    80060c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	57                   	push   %edi
  800560:	6a 2d                	push   $0x2d
  800562:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800565:	f7 db                	neg    %ebx
  800567:	83 d6 00             	adc    $0x0,%esi
  80056a:	f7 de                	neg    %esi
  80056c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800574:	e9 93 00 00 00       	jmp    80060c <vprintfmt+0x32f>
  800579:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057c:	89 ca                	mov    %ecx,%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 b4 fc ff ff       	call   80023a <getuint>
  800586:	89 c3                	mov    %eax,%ebx
  800588:	89 d6                	mov    %edx,%esi
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80058f:	eb 7b                	jmp    80060c <vprintfmt+0x32f>
  800591:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800594:	89 ca                	mov    %ecx,%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 d6 fc ff ff       	call   800274 <getint>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	78 07                	js     8005ad <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ab:	eb 5f                	jmp    80060c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	57                   	push   %edi
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005b6:	f7 db                	neg    %ebx
  8005b8:	83 d6 00             	adc    $0x0,%esi
  8005bb:	f7 de                	neg    %esi
  8005bd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c5:	eb 45                	jmp    80060c <vprintfmt+0x32f>
  8005c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	57                   	push   %edi
  8005ce:	6a 30                	push   $0x30
  8005d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e5:	8b 18                	mov    (%eax),%ebx
  8005e7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f4:	eb 16                	jmp    80060c <vprintfmt+0x32f>
  8005f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f9:	89 ca                	mov    %ecx,%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 37 fc ff ff       	call   80023a <getuint>
  800603:	89 c3                	mov    %eax,%ebx
  800605:	89 d6                	mov    %edx,%esi
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800613:	52                   	push   %edx
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	50                   	push   %eax
  800618:	56                   	push   %esi
  800619:	53                   	push   %ebx
  80061a:	89 fa                	mov    %edi,%edx
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	e8 68 fb ff ff       	call   80018c <printnum>
			break;
  800624:	83 c4 20             	add    $0x20,%esp
  800627:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062a:	e9 d2 fc ff ff       	jmp    800301 <vprintfmt+0x24>
  80062f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	52                   	push   %edx
  800637:	ff 55 08             	call   *0x8(%ebp)
			break;
  80063a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800640:	e9 bc fc ff ff       	jmp    800301 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	57                   	push   %edi
  800649:	6a 25                	push   $0x25
  80064b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	eb 02                	jmp    800655 <vprintfmt+0x378>
  800653:	89 c6                	mov    %eax,%esi
  800655:	8d 46 ff             	lea    -0x1(%esi),%eax
  800658:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80065c:	75 f5                	jne    800653 <vprintfmt+0x376>
  80065e:	e9 9e fc ff ff       	jmp    800301 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800663:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	5f                   	pop    %edi
  800669:	c9                   	leave  
  80066a:	c3                   	ret    

0080066b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	83 ec 18             	sub    $0x18,%esp
  800671:	8b 45 08             	mov    0x8(%ebp),%eax
  800674:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800677:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800681:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800688:	85 c0                	test   %eax,%eax
  80068a:	74 26                	je     8006b2 <vsnprintf+0x47>
  80068c:	85 d2                	test   %edx,%edx
  80068e:	7e 29                	jle    8006b9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800690:	ff 75 14             	pushl  0x14(%ebp)
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	68 a6 02 80 00       	push   $0x8002a6
  80069f:	e8 39 fc ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	eb 0c                	jmp    8006be <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b7:	eb 05                	jmp    8006be <vsnprintf+0x53>
  8006b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 10             	pushl  0x10(%ebp)
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	ff 75 08             	pushl  0x8(%ebp)
  8006d3:	e8 93 ff ff ff       	call   80066b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    
	...

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e5:	74 0e                	je     8006f5 <strlen+0x19>
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006ec:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f1:	75 f9                	jne    8006ec <strlen+0x10>
  8006f3:	eb 05                	jmp    8006fa <strlen+0x1e>
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800705:	85 d2                	test   %edx,%edx
  800707:	74 17                	je     800720 <strnlen+0x24>
  800709:	80 39 00             	cmpb   $0x0,(%ecx)
  80070c:	74 19                	je     800727 <strnlen+0x2b>
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800713:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800714:	39 d0                	cmp    %edx,%eax
  800716:	74 14                	je     80072c <strnlen+0x30>
  800718:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071c:	75 f5                	jne    800713 <strnlen+0x17>
  80071e:	eb 0c                	jmp    80072c <strnlen+0x30>
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	eb 05                	jmp    80072c <strnlen+0x30>
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    

0080072e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800738:	ba 00 00 00 00       	mov    $0x0,%edx
  80073d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800740:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800743:	42                   	inc    %edx
  800744:	84 c9                	test   %cl,%cl
  800746:	75 f5                	jne    80073d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800748:	5b                   	pop    %ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800752:	53                   	push   %ebx
  800753:	e8 84 ff ff ff       	call   8006dc <strlen>
  800758:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800761:	50                   	push   %eax
  800762:	e8 c7 ff ff ff       	call   80072e <strcpy>
	return dst;
}
  800767:	89 d8                	mov    %ebx,%eax
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	56                   	push   %esi
  800772:	53                   	push   %ebx
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
  800779:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077c:	85 f6                	test   %esi,%esi
  80077e:	74 15                	je     800795 <strncpy+0x27>
  800780:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800785:	8a 1a                	mov    (%edx),%bl
  800787:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078a:	80 3a 01             	cmpb   $0x1,(%edx)
  80078d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800790:	41                   	inc    %ecx
  800791:	39 ce                	cmp    %ecx,%esi
  800793:	77 f0                	ja     800785 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	57                   	push   %edi
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a8:	85 f6                	test   %esi,%esi
  8007aa:	74 32                	je     8007de <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007ac:	83 fe 01             	cmp    $0x1,%esi
  8007af:	74 22                	je     8007d3 <strlcpy+0x3a>
  8007b1:	8a 0b                	mov    (%ebx),%cl
  8007b3:	84 c9                	test   %cl,%cl
  8007b5:	74 20                	je     8007d7 <strlcpy+0x3e>
  8007b7:	89 f8                	mov    %edi,%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007be:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	88 08                	mov    %cl,(%eax)
  8007c3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c4:	39 f2                	cmp    %esi,%edx
  8007c6:	74 11                	je     8007d9 <strlcpy+0x40>
  8007c8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007cc:	42                   	inc    %edx
  8007cd:	84 c9                	test   %cl,%cl
  8007cf:	75 f0                	jne    8007c1 <strlcpy+0x28>
  8007d1:	eb 06                	jmp    8007d9 <strlcpy+0x40>
  8007d3:	89 f8                	mov    %edi,%eax
  8007d5:	eb 02                	jmp    8007d9 <strlcpy+0x40>
  8007d7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 00 00             	movb   $0x0,(%eax)
  8007dc:	eb 02                	jmp    8007e0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007de:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007e0:	29 f8                	sub    %edi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5f                   	pop    %edi
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f0:	8a 01                	mov    (%ecx),%al
  8007f2:	84 c0                	test   %al,%al
  8007f4:	74 10                	je     800806 <strcmp+0x1f>
  8007f6:	3a 02                	cmp    (%edx),%al
  8007f8:	75 0c                	jne    800806 <strcmp+0x1f>
		p++, q++;
  8007fa:	41                   	inc    %ecx
  8007fb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fc:	8a 01                	mov    (%ecx),%al
  8007fe:	84 c0                	test   %al,%al
  800800:	74 04                	je     800806 <strcmp+0x1f>
  800802:	3a 02                	cmp    (%edx),%al
  800804:	74 f4                	je     8007fa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800806:	0f b6 c0             	movzbl %al,%eax
  800809:	0f b6 12             	movzbl (%edx),%edx
  80080c:	29 d0                	sub    %edx,%eax
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 55 08             	mov    0x8(%ebp),%edx
  800817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 1b                	je     80083c <strncmp+0x2c>
  800821:	8a 1a                	mov    (%edx),%bl
  800823:	84 db                	test   %bl,%bl
  800825:	74 24                	je     80084b <strncmp+0x3b>
  800827:	3a 19                	cmp    (%ecx),%bl
  800829:	75 20                	jne    80084b <strncmp+0x3b>
  80082b:	48                   	dec    %eax
  80082c:	74 15                	je     800843 <strncmp+0x33>
		n--, p++, q++;
  80082e:	42                   	inc    %edx
  80082f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800830:	8a 1a                	mov    (%edx),%bl
  800832:	84 db                	test   %bl,%bl
  800834:	74 15                	je     80084b <strncmp+0x3b>
  800836:	3a 19                	cmp    (%ecx),%bl
  800838:	74 f1                	je     80082b <strncmp+0x1b>
  80083a:	eb 0f                	jmp    80084b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 05                	jmp    800848 <strncmp+0x38>
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800848:	5b                   	pop    %ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 02             	movzbl (%edx),%eax
  80084e:	0f b6 11             	movzbl (%ecx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb f3                	jmp    800848 <strncmp+0x38>

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085e:	8a 10                	mov    (%eax),%dl
  800860:	84 d2                	test   %dl,%dl
  800862:	74 18                	je     80087c <strchr+0x27>
		if (*s == c)
  800864:	38 ca                	cmp    %cl,%dl
  800866:	75 06                	jne    80086e <strchr+0x19>
  800868:	eb 17                	jmp    800881 <strchr+0x2c>
  80086a:	38 ca                	cmp    %cl,%dl
  80086c:	74 13                	je     800881 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086e:	40                   	inc    %eax
  80086f:	8a 10                	mov    (%eax),%dl
  800871:	84 d2                	test   %dl,%dl
  800873:	75 f5                	jne    80086a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	eb 05                	jmp    800881 <strchr+0x2c>
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088c:	8a 10                	mov    (%eax),%dl
  80088e:	84 d2                	test   %dl,%dl
  800890:	74 11                	je     8008a3 <strfind+0x20>
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	75 06                	jne    80089c <strfind+0x19>
  800896:	eb 0b                	jmp    8008a3 <strfind+0x20>
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 07                	je     8008a3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80089c:	40                   	inc    %eax
  80089d:	8a 10                	mov    (%eax),%dl
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	75 f5                	jne    800898 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b4:	85 c9                	test   %ecx,%ecx
  8008b6:	74 30                	je     8008e8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008be:	75 25                	jne    8008e5 <memset+0x40>
  8008c0:	f6 c1 03             	test   $0x3,%cl
  8008c3:	75 20                	jne    8008e5 <memset+0x40>
		c &= 0xFF;
  8008c5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c8:	89 d3                	mov    %edx,%ebx
  8008ca:	c1 e3 08             	shl    $0x8,%ebx
  8008cd:	89 d6                	mov    %edx,%esi
  8008cf:	c1 e6 18             	shl    $0x18,%esi
  8008d2:	89 d0                	mov    %edx,%eax
  8008d4:	c1 e0 10             	shl    $0x10,%eax
  8008d7:	09 f0                	or     %esi,%eax
  8008d9:	09 d0                	or     %edx,%eax
  8008db:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e0:	fc                   	cld    
  8008e1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e3:	eb 03                	jmp    8008e8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	57                   	push   %edi
  8008f3:	56                   	push   %esi
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fd:	39 c6                	cmp    %eax,%esi
  8008ff:	73 34                	jae    800935 <memmove+0x46>
  800901:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800904:	39 d0                	cmp    %edx,%eax
  800906:	73 2d                	jae    800935 <memmove+0x46>
		s += n;
		d += n;
  800908:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090b:	f6 c2 03             	test   $0x3,%dl
  80090e:	75 1b                	jne    80092b <memmove+0x3c>
  800910:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800916:	75 13                	jne    80092b <memmove+0x3c>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0e                	jne    80092b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091d:	83 ef 04             	sub    $0x4,%edi
  800920:	8d 72 fc             	lea    -0x4(%edx),%esi
  800923:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800926:	fd                   	std    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 07                	jmp    800932 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092b:	4f                   	dec    %edi
  80092c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092f:	fd                   	std    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800932:	fc                   	cld    
  800933:	eb 20                	jmp    800955 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093b:	75 13                	jne    800950 <memmove+0x61>
  80093d:	a8 03                	test   $0x3,%al
  80093f:	75 0f                	jne    800950 <memmove+0x61>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0a                	jne    800950 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800946:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 05                	jmp    800955 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 85 ff ff ff       	call   8008ef <memmove>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800975:	8b 75 0c             	mov    0xc(%ebp),%esi
  800978:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097b:	85 ff                	test   %edi,%edi
  80097d:	74 32                	je     8009b1 <memcmp+0x45>
		if (*s1 != *s2)
  80097f:	8a 03                	mov    (%ebx),%al
  800981:	8a 0e                	mov    (%esi),%cl
  800983:	38 c8                	cmp    %cl,%al
  800985:	74 19                	je     8009a0 <memcmp+0x34>
  800987:	eb 0d                	jmp    800996 <memcmp+0x2a>
  800989:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80098d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800991:	42                   	inc    %edx
  800992:	38 c8                	cmp    %cl,%al
  800994:	74 10                	je     8009a6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800996:	0f b6 c0             	movzbl %al,%eax
  800999:	0f b6 c9             	movzbl %cl,%ecx
  80099c:	29 c8                	sub    %ecx,%eax
  80099e:	eb 16                	jmp    8009b6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a0:	4f                   	dec    %edi
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	39 fa                	cmp    %edi,%edx
  8009a8:	75 df                	jne    800989 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009af:	eb 05                	jmp    8009b6 <memcmp+0x4a>
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	73 12                	jae    8009dc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009cd:	38 08                	cmp    %cl,(%eax)
  8009cf:	75 06                	jne    8009d7 <memfind+0x1c>
  8009d1:	eb 09                	jmp    8009dc <memfind+0x21>
  8009d3:	38 08                	cmp    %cl,(%eax)
  8009d5:	74 05                	je     8009dc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d7:	40                   	inc    %eax
  8009d8:	39 c2                	cmp    %eax,%edx
  8009da:	77 f7                	ja     8009d3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ea:	eb 01                	jmp    8009ed <strtol+0xf>
		s++;
  8009ec:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	8a 02                	mov    (%edx),%al
  8009ef:	3c 20                	cmp    $0x20,%al
  8009f1:	74 f9                	je     8009ec <strtol+0xe>
  8009f3:	3c 09                	cmp    $0x9,%al
  8009f5:	74 f5                	je     8009ec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f7:	3c 2b                	cmp    $0x2b,%al
  8009f9:	75 08                	jne    800a03 <strtol+0x25>
		s++;
  8009fb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fc:	bf 00 00 00 00       	mov    $0x0,%edi
  800a01:	eb 13                	jmp    800a16 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a03:	3c 2d                	cmp    $0x2d,%al
  800a05:	75 0a                	jne    800a11 <strtol+0x33>
		s++, neg = 1;
  800a07:	8d 52 01             	lea    0x1(%edx),%edx
  800a0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0f:	eb 05                	jmp    800a16 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	74 05                	je     800a1f <strtol+0x41>
  800a1a:	83 fb 10             	cmp    $0x10,%ebx
  800a1d:	75 28                	jne    800a47 <strtol+0x69>
  800a1f:	8a 02                	mov    (%edx),%al
  800a21:	3c 30                	cmp    $0x30,%al
  800a23:	75 10                	jne    800a35 <strtol+0x57>
  800a25:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a29:	75 0a                	jne    800a35 <strtol+0x57>
		s += 2, base = 16;
  800a2b:	83 c2 02             	add    $0x2,%edx
  800a2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a33:	eb 12                	jmp    800a47 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 0e                	jne    800a47 <strtol+0x69>
  800a39:	3c 30                	cmp    $0x30,%al
  800a3b:	75 05                	jne    800a42 <strtol+0x64>
		s++, base = 8;
  800a3d:	42                   	inc    %edx
  800a3e:	b3 08                	mov    $0x8,%bl
  800a40:	eb 05                	jmp    800a47 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4e:	8a 0a                	mov    (%edx),%cl
  800a50:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a53:	80 fb 09             	cmp    $0x9,%bl
  800a56:	77 08                	ja     800a60 <strtol+0x82>
			dig = *s - '0';
  800a58:	0f be c9             	movsbl %cl,%ecx
  800a5b:	83 e9 30             	sub    $0x30,%ecx
  800a5e:	eb 1e                	jmp    800a7e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a60:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a63:	80 fb 19             	cmp    $0x19,%bl
  800a66:	77 08                	ja     800a70 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a68:	0f be c9             	movsbl %cl,%ecx
  800a6b:	83 e9 57             	sub    $0x57,%ecx
  800a6e:	eb 0e                	jmp    800a7e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 13                	ja     800a8b <strtol+0xad>
			dig = *s - 'A' + 10;
  800a78:	0f be c9             	movsbl %cl,%ecx
  800a7b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a7e:	39 f1                	cmp    %esi,%ecx
  800a80:	7d 0d                	jge    800a8f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a82:	42                   	inc    %edx
  800a83:	0f af c6             	imul   %esi,%eax
  800a86:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a89:	eb c3                	jmp    800a4e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a8b:	89 c1                	mov    %eax,%ecx
  800a8d:	eb 02                	jmp    800a91 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a95:	74 05                	je     800a9c <strtol+0xbe>
		*endptr = (char *) s;
  800a97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	74 04                	je     800aa4 <strtol+0xc6>
  800aa0:	89 c8                	mov    %ecx,%eax
  800aa2:	f7 d8                	neg    %eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    
  800aa9:	00 00                	add    %al,(%eax)
	...

00800aac <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 1c             	sub    $0x1c,%esp
  800ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800abb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abd:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac9:	cd 30                	int    $0x30
  800acb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ad1:	74 1c                	je     800aef <syscall+0x43>
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	7e 18                	jle    800aef <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad7:	83 ec 0c             	sub    $0xc,%esp
  800ada:	50                   	push   %eax
  800adb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ade:	68 44 12 80 00       	push   $0x801244
  800ae3:	6a 42                	push   $0x42
  800ae5:	68 61 12 80 00       	push   $0x801261
  800aea:	e8 51 02 00 00       	call   800d40 <_panic>

	return ret;
}
  800aef:	89 d0                	mov    %edx,%eax
  800af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800aff:	6a 00                	push   $0x0
  800b01:	6a 00                	push   $0x0
  800b03:	6a 00                	push   $0x0
  800b05:	ff 75 0c             	pushl  0xc(%ebp)
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	e8 92 ff ff ff       	call   800aac <syscall>
  800b1a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b25:	6a 00                	push   $0x0
  800b27:	6a 00                	push   $0x0
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3c:	e8 6b ff ff ff       	call   800aac <syscall>
}
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b54:	ba 01 00 00 00       	mov    $0x1,%edx
  800b59:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5e:	e8 49 ff ff ff       	call   800aac <syscall>
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b82:	e8 25 ff ff ff       	call   800aac <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba6:	e8 01 ff ff ff       	call   800aac <syscall>
  800bab:	83 c4 10             	add    $0x10,%esp
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bb6:	6a 00                	push   $0x0
  800bb8:	6a 00                	push   $0x0
  800bba:	ff 75 10             	pushl  0x10(%ebp)
  800bbd:	ff 75 0c             	pushl  0xc(%ebp)
  800bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcd:	e8 da fe ff ff       	call   800aac <syscall>
}
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bda:	ff 75 18             	pushl  0x18(%ebp)
  800bdd:	ff 75 14             	pushl  0x14(%ebp)
  800be0:	ff 75 10             	pushl  0x10(%ebp)
  800be3:	ff 75 0c             	pushl  0xc(%ebp)
  800be6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bee:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf3:	e8 b4 fe ff ff       	call   800aac <syscall>
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c00:	6a 00                	push   $0x0
  800c02:	6a 00                	push   $0x0
  800c04:	6a 00                	push   $0x0
  800c06:	ff 75 0c             	pushl  0xc(%ebp)
  800c09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	e8 91 fe ff ff       	call   800aac <syscall>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	6a 00                	push   $0x0
  800c29:	ff 75 0c             	pushl  0xc(%ebp)
  800c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c34:	b8 08 00 00 00       	mov    $0x8,%eax
  800c39:	e8 6e fe ff ff       	call   800aac <syscall>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	6a 00                	push   $0x0
  800c4c:	ff 75 0c             	pushl  0xc(%ebp)
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	ba 01 00 00 00       	mov    $0x1,%edx
  800c57:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5c:	e8 4b fe ff ff       	call   800aac <syscall>
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c69:	6a 00                	push   $0x0
  800c6b:	ff 75 14             	pushl  0x14(%ebp)
  800c6e:	ff 75 10             	pushl  0x10(%ebp)
  800c71:	ff 75 0c             	pushl  0xc(%ebp)
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c81:	e8 26 fe ff ff       	call   800aac <syscall>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c99:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca3:	e8 04 fe ff ff       	call   800aac <syscall>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    
	...

00800cac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cb2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cb9:	75 52                	jne    800d0d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800cbb:	83 ec 04             	sub    $0x4,%esp
  800cbe:	6a 07                	push   $0x7
  800cc0:	68 00 f0 bf ee       	push   $0xeebff000
  800cc5:	6a 00                	push   $0x0
  800cc7:	e8 e4 fe ff ff       	call   800bb0 <sys_page_alloc>
		if (r < 0) {
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	79 12                	jns    800ce5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800cd3:	50                   	push   %eax
  800cd4:	68 6f 12 80 00       	push   $0x80126f
  800cd9:	6a 24                	push   $0x24
  800cdb:	68 8a 12 80 00       	push   $0x80128a
  800ce0:	e8 5b 00 00 00       	call   800d40 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800ce5:	83 ec 08             	sub    $0x8,%esp
  800ce8:	68 18 0d 80 00       	push   $0x800d18
  800ced:	6a 00                	push   $0x0
  800cef:	e8 4c ff ff ff       	call   800c40 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	79 12                	jns    800d0d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800cfb:	50                   	push   %eax
  800cfc:	68 98 12 80 00       	push   $0x801298
  800d01:	6a 2a                	push   $0x2a
  800d03:	68 8a 12 80 00       	push   $0x80128a
  800d08:	e8 33 00 00 00       	call   800d40 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    
	...

00800d18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d19:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d20:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800d23:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d27:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d2a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800d2e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800d32:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800d34:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800d37:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800d38:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800d3b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d3c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800d3d:	c3                   	ret    
	...

00800d40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d45:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d48:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d4e:	e8 12 fe ff ff       	call   800b65 <sys_getenvid>
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	ff 75 08             	pushl  0x8(%ebp)
  800d5c:	53                   	push   %ebx
  800d5d:	50                   	push   %eax
  800d5e:	68 c0 12 80 00       	push   $0x8012c0
  800d63:	e8 10 f4 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d68:	83 c4 18             	add    $0x18,%esp
  800d6b:	56                   	push   %esi
  800d6c:	ff 75 10             	pushl  0x10(%ebp)
  800d6f:	e8 b3 f3 ff ff       	call   800127 <vcprintf>
	cprintf("\n");
  800d74:	c7 04 24 88 12 80 00 	movl   $0x801288,(%esp)
  800d7b:	e8 f8 f3 ff ff       	call   800178 <cprintf>
  800d80:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d83:	cc                   	int3   
  800d84:	eb fd                	jmp    800d83 <_panic+0x43>
	...

00800d88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	83 ec 10             	sub    $0x10,%esp
  800d90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d96:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d99:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d9c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d9f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	75 2e                	jne    800dd4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800da6:	39 f1                	cmp    %esi,%ecx
  800da8:	77 5a                	ja     800e04 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800daa:	85 c9                	test   %ecx,%ecx
  800dac:	75 0b                	jne    800db9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dae:	b8 01 00 00 00       	mov    $0x1,%eax
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800db9:	31 d2                	xor    %edx,%edx
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	f7 f1                	div    %ecx
  800dbf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dc1:	89 f8                	mov    %edi,%eax
  800dc3:	f7 f1                	div    %ecx
  800dc5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc7:	89 f8                	mov    %edi,%eax
  800dc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    
  800dd2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dd4:	39 f0                	cmp    %esi,%eax
  800dd6:	77 1c                	ja     800df4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dd8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800ddb:	83 f7 1f             	xor    $0x1f,%edi
  800dde:	75 3c                	jne    800e1c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800de0:	39 f0                	cmp    %esi,%eax
  800de2:	0f 82 90 00 00 00    	jb     800e78 <__udivdi3+0xf0>
  800de8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800deb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dee:	0f 86 84 00 00 00    	jbe    800e78 <__udivdi3+0xf0>
  800df4:	31 f6                	xor    %esi,%esi
  800df6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df8:	89 f8                	mov    %edi,%eax
  800dfa:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    
  800e03:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e04:	89 f2                	mov    %esi,%edx
  800e06:	89 f8                	mov    %edi,%eax
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 c7                	mov    %eax,%edi
  800e0c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0e:	89 f8                	mov    %edi,%eax
  800e10:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e1c:	89 f9                	mov    %edi,%ecx
  800e1e:	d3 e0                	shl    %cl,%eax
  800e20:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e23:	b8 20 00 00 00       	mov    $0x20,%eax
  800e28:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e34:	09 ca                	or     %ecx,%edx
  800e36:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e3c:	89 f9                	mov    %edi,%ecx
  800e3e:	d3 e2                	shl    %cl,%edx
  800e40:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e43:	89 f2                	mov    %esi,%edx
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ea                	shr    %cl,%edx
  800e49:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e4c:	89 f2                	mov    %esi,%edx
  800e4e:	89 f9                	mov    %edi,%ecx
  800e50:	d3 e2                	shl    %cl,%edx
  800e52:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e55:	88 c1                	mov    %al,%cl
  800e57:	d3 ee                	shr    %cl,%esi
  800e59:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e5b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	89 ca                	mov    %ecx,%edx
  800e62:	f7 75 ec             	divl   -0x14(%ebp)
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e69:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6c:	39 d1                	cmp    %edx,%ecx
  800e6e:	72 28                	jb     800e98 <__udivdi3+0x110>
  800e70:	74 1a                	je     800e8c <__udivdi3+0x104>
  800e72:	89 f7                	mov    %esi,%edi
  800e74:	31 f6                	xor    %esi,%esi
  800e76:	eb 80                	jmp    800df8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e78:	31 f6                	xor    %esi,%esi
  800e7a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e7f:	89 f8                	mov    %edi,%eax
  800e81:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    
  800e8a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e93:	39 c2                	cmp    %eax,%edx
  800e95:	73 db                	jae    800e72 <__udivdi3+0xea>
  800e97:	90                   	nop
		{
		  q0--;
  800e98:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e9b:	31 f6                	xor    %esi,%esi
  800e9d:	e9 56 ff ff ff       	jmp    800df8 <__udivdi3+0x70>
	...

00800ea4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	83 ec 20             	sub    $0x20,%esp
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800eb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800eb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ebb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ec1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ec3:	85 ff                	test   %edi,%edi
  800ec5:	75 15                	jne    800edc <__umoddi3+0x38>
    {
      if (d0 > n1)
  800ec7:	39 f1                	cmp    %esi,%ecx
  800ec9:	0f 86 99 00 00 00    	jbe    800f68 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ed1:	89 d0                	mov    %edx,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed5:	83 c4 20             	add    $0x20,%esp
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800edc:	39 f7                	cmp    %esi,%edi
  800ede:	0f 87 a4 00 00 00    	ja     800f88 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ee4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ee7:	83 f0 1f             	xor    $0x1f,%eax
  800eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eed:	0f 84 a1 00 00 00    	je     800f94 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ef3:	89 f8                	mov    %edi,%eax
  800ef5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ef8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800efa:	bf 20 00 00 00       	mov    $0x20,%edi
  800eff:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 ea                	shr    %cl,%edx
  800f09:	09 c2                	or     %eax,%edx
  800f0b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f11:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f14:	d3 e0                	shl    %cl,%eax
  800f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f19:	89 f2                	mov    %esi,%edx
  800f1b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f20:	d3 e0                	shl    %cl,%eax
  800f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f25:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f28:	89 f9                	mov    %edi,%ecx
  800f2a:	d3 e8                	shr    %cl,%eax
  800f2c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f2e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f30:	89 f2                	mov    %esi,%edx
  800f32:	f7 75 f0             	divl   -0x10(%ebp)
  800f35:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f37:	f7 65 f4             	mull   -0xc(%ebp)
  800f3a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f3d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f3f:	39 d6                	cmp    %edx,%esi
  800f41:	72 71                	jb     800fb4 <__umoddi3+0x110>
  800f43:	74 7f                	je     800fc4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f48:	29 c8                	sub    %ecx,%eax
  800f4a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f4c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f4f:	d3 e8                	shr    %cl,%eax
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f57:	09 d0                	or     %edx,%eax
  800f59:	89 f2                	mov    %esi,%edx
  800f5b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f5e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    
  800f67:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f68:	85 c9                	test   %ecx,%ecx
  800f6a:	75 0b                	jne    800f77 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f71:	31 d2                	xor    %edx,%edx
  800f73:	f7 f1                	div    %ecx
  800f75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f80:	f7 f1                	div    %ecx
  800f82:	e9 4a ff ff ff       	jmp    800ed1 <__umoddi3+0x2d>
  800f87:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f88:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    
  800f91:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	72 05                	jb     800f9d <__umoddi3+0xf9>
  800f98:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f9b:	77 0c                	ja     800fa9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa2:	29 c8                	sub    %ecx,%eax
  800fa4:	19 fa                	sbb    %edi,%edx
  800fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    
  800fb3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fb4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fb7:	89 c1                	mov    %eax,%ecx
  800fb9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800fbc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800fbf:	eb 84                	jmp    800f45 <__umoddi3+0xa1>
  800fc1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fc7:	72 eb                	jb     800fb4 <__umoddi3+0x110>
  800fc9:	89 f2                	mov    %esi,%edx
  800fcb:	e9 75 ff ff ff       	jmp    800f45 <__umoddi3+0xa1>
