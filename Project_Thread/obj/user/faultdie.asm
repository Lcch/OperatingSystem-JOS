
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
  80004b:	e8 2c 01 00 00       	call   80017c <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 14 0b 00 00       	call   800b69 <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 ea 0a 00 00       	call   800b47 <sys_env_destroy>
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
  80006d:	e8 ee 0c 00 00       	call   800d60 <set_pgfault_handler>
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
  80008f:	e8 d5 0a 00 00       	call   800b69 <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	89 c2                	mov    %eax,%edx
  80009b:	c1 e2 07             	shl    $0x7,%edx
  80009e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000a5:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	85 f6                	test   %esi,%esi
  8000ac:	7e 07                	jle    8000b5 <libmain+0x31>
		binaryname = argv[0];
  8000ae:	8b 03                	mov    (%ebx),%eax
  8000b0:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	53                   	push   %ebx
  8000b9:	56                   	push   %esi
  8000ba:	e8 a3 ff ff ff       	call   800062 <umain>

	// exit gracefully
	exit();
  8000bf:	e8 0c 00 00 00       	call   8000d0 <exit>
  8000c4:	83 c4 10             	add    $0x10,%esp
}
  8000c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
	...

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d6:	e8 23 0f 00 00       	call   800ffe <close_all>
	sys_env_destroy(0);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	6a 00                	push   $0x0
  8000e0:	e8 62 0a 00 00       	call   800b47 <sys_env_destroy>
  8000e5:	83 c4 10             	add    $0x10,%esp
}
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    
	...

008000ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000ff:	40                   	inc    %eax
  800100:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800102:	3d ff 00 00 00       	cmp    $0xff,%eax
  800107:	75 1a                	jne    800123 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	68 ff 00 00 00       	push   $0xff
  800111:	8d 43 08             	lea    0x8(%ebx),%eax
  800114:	50                   	push   %eax
  800115:	e8 e3 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  80011a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800123:	ff 43 04             	incl   0x4(%ebx)
}
  800126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800134:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013b:	00 00 00 
	b.cnt = 0;
  80013e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800145:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800154:	50                   	push   %eax
  800155:	68 ec 00 80 00       	push   $0x8000ec
  80015a:	e8 82 01 00 00       	call   8002e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	83 c4 08             	add    $0x8,%esp
  800162:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800168:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 89 09 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800174:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 9d ff ff ff       	call   80012b <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 2c             	sub    $0x2c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001bd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001c0:	72 0c                	jb     8001ce <printnum+0x3e>
  8001c2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001c5:	76 07                	jbe    8001ce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c7:	4b                   	dec    %ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f 31                	jg     8001fd <printnum+0x6d>
  8001cc:	eb 3f                	jmp    80020d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	57                   	push   %edi
  8001d2:	4b                   	dec    %ebx
  8001d3:	53                   	push   %ebx
  8001d4:	50                   	push   %eax
  8001d5:	83 ec 08             	sub    $0x8,%esp
  8001d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001db:	ff 75 d0             	pushl  -0x30(%ebp)
  8001de:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e4:	e8 63 1a 00 00       	call   801c4c <__udivdi3>
  8001e9:	83 c4 18             	add    $0x18,%esp
  8001ec:	52                   	push   %edx
  8001ed:	50                   	push   %eax
  8001ee:	89 f2                	mov    %esi,%edx
  8001f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f3:	e8 98 ff ff ff       	call   800190 <printnum>
  8001f8:	83 c4 20             	add    $0x20,%esp
  8001fb:	eb 10                	jmp    80020d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	56                   	push   %esi
  800201:	57                   	push   %edi
  800202:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800205:	4b                   	dec    %ebx
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 db                	test   %ebx,%ebx
  80020b:	7f f0                	jg     8001fd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	56                   	push   %esi
  800211:	83 ec 04             	sub    $0x4,%esp
  800214:	ff 75 d4             	pushl  -0x2c(%ebp)
  800217:	ff 75 d0             	pushl  -0x30(%ebp)
  80021a:	ff 75 dc             	pushl  -0x24(%ebp)
  80021d:	ff 75 d8             	pushl  -0x28(%ebp)
  800220:	e8 43 1b 00 00       	call   801d68 <__umoddi3>
  800225:	83 c4 14             	add    $0x14,%esp
  800228:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  80022f:	50                   	push   %eax
  800230:	ff 55 e4             	call   *-0x1c(%ebp)
  800233:	83 c4 10             	add    $0x10,%esp
}
  800236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5f                   	pop    %edi
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800241:	83 fa 01             	cmp    $0x1,%edx
  800244:	7e 0e                	jle    800254 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800246:	8b 10                	mov    (%eax),%edx
  800248:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024b:	89 08                	mov    %ecx,(%eax)
  80024d:	8b 02                	mov    (%edx),%eax
  80024f:	8b 52 04             	mov    0x4(%edx),%edx
  800252:	eb 22                	jmp    800276 <getuint+0x38>
	else if (lflag)
  800254:	85 d2                	test   %edx,%edx
  800256:	74 10                	je     800268 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
  800266:	eb 0e                	jmp    800276 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027b:	83 fa 01             	cmp    $0x1,%edx
  80027e:	7e 0e                	jle    80028e <getint+0x16>
		return va_arg(*ap, long long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 08             	lea    0x8(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	8b 52 04             	mov    0x4(%edx),%edx
  80028c:	eb 1a                	jmp    8002a8 <getint+0x30>
	else if (lflag)
  80028e:	85 d2                	test   %edx,%edx
  800290:	74 0c                	je     80029e <getint+0x26>
		return va_arg(*ap, long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	99                   	cltd   
  80029c:	eb 0a                	jmp    8002a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	99                   	cltd   
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 08                	jae    8002c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bd:	88 0a                	mov    %cl,(%edx)
  8002bf:	42                   	inc    %edx
  8002c0:	89 10                	mov    %edx,(%eax)
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cd:	50                   	push   %eax
  8002ce:	ff 75 10             	pushl  0x10(%ebp)
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	e8 05 00 00 00       	call   8002e1 <vprintfmt>
	va_end(ap);
  8002dc:	83 c4 10             	add    $0x10,%esp
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
  8002e7:	83 ec 2c             	sub    $0x2c,%esp
  8002ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f0:	eb 13                	jmp    800305 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f2:	85 c0                	test   %eax,%eax
  8002f4:	0f 84 6d 03 00 00    	je     800667 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	57                   	push   %edi
  8002fe:	50                   	push   %eax
  8002ff:	ff 55 08             	call   *0x8(%ebp)
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	0f b6 06             	movzbl (%esi),%eax
  800308:	46                   	inc    %esi
  800309:	83 f8 25             	cmp    $0x25,%eax
  80030c:	75 e4                	jne    8002f2 <vprintfmt+0x11>
  80030e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800312:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800319:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800320:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800327:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032c:	eb 28                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800330:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800334:	eb 20                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80033c:	eb 18                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800340:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800347:	eb 0d                	jmp    800356 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800349:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8a 06                	mov    (%esi),%al
  800358:	0f b6 d0             	movzbl %al,%edx
  80035b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80035e:	83 e8 23             	sub    $0x23,%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 e0 02 00 00    	ja     800649 <vprintfmt+0x368>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800373:	83 ea 30             	sub    $0x30,%edx
  800376:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800379:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80037c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037f:	83 fa 09             	cmp    $0x9,%edx
  800382:	77 44                	ja     8003c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	89 de                	mov    %ebx,%esi
  800386:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800389:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80038a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80038d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800391:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800394:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800397:	83 fb 09             	cmp    $0x9,%ebx
  80039a:	76 ed                	jbe    800389 <vprintfmt+0xa8>
  80039c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80039f:	eb 29                	jmp    8003ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 50 04             	lea    0x4(%eax),%edx
  8003a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b1:	eb 17                	jmp    8003ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b7:	78 85                	js     80033e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	89 de                	mov    %ebx,%esi
  8003bb:	eb 99                	jmp    800356 <vprintfmt+0x75>
  8003bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003c6:	eb 8e                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ce:	79 86                	jns    800356 <vprintfmt+0x75>
  8003d0:	e9 74 ff ff ff       	jmp    800349 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
  8003d8:	e9 79 ff ff ff       	jmp    800356 <vprintfmt+0x75>
  8003dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	57                   	push   %edi
  8003ed:	ff 30                	pushl  (%eax)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f8:	e9 08 ff ff ff       	jmp    800305 <vprintfmt+0x24>
  8003fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	79 02                	jns    800411 <vprintfmt+0x130>
  80040f:	f7 d8                	neg    %eax
  800411:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 0f             	cmp    $0xf,%eax
  800416:	7f 0b                	jg     800423 <vprintfmt+0x142>
  800418:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	75 1a                	jne    80043d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800423:	52                   	push   %edx
  800424:	68 de 1e 80 00       	push   $0x801ede
  800429:	57                   	push   %edi
  80042a:	ff 75 08             	pushl  0x8(%ebp)
  80042d:	e8 92 fe ff ff       	call   8002c4 <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800438:	e9 c8 fe ff ff       	jmp    800305 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80043d:	50                   	push   %eax
  80043e:	68 e1 22 80 00       	push   $0x8022e1
  800443:	57                   	push   %edi
  800444:	ff 75 08             	pushl  0x8(%ebp)
  800447:	e8 78 fe ff ff       	call   8002c4 <printfmt>
  80044c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800452:	e9 ae fe ff ff       	jmp    800305 <vprintfmt+0x24>
  800457:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80045a:	89 de                	mov    %ebx,%esi
  80045c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80045f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800470:	85 c0                	test   %eax,%eax
  800472:	75 07                	jne    80047b <vprintfmt+0x19a>
				p = "(null)";
  800474:	c7 45 d0 d7 1e 80 00 	movl   $0x801ed7,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80047b:	85 db                	test   %ebx,%ebx
  80047d:	7e 42                	jle    8004c1 <vprintfmt+0x1e0>
  80047f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800483:	74 3c                	je     8004c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	51                   	push   %ecx
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	e8 6f 02 00 00       	call   800700 <strnlen>
  800491:	29 c3                	sub    %eax,%ebx
  800493:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7e 24                	jle    8004c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80049d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	57                   	push   %edi
  8004ab:	53                   	push   %ebx
  8004ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	4e                   	dec    %esi
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	85 f6                	test   %esi,%esi
  8004b5:	7f f0                	jg     8004a7 <vprintfmt+0x1c6>
  8004b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c4:	0f be 02             	movsbl (%edx),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	75 47                	jne    800512 <vprintfmt+0x231>
  8004cb:	eb 37                	jmp    800504 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	74 16                	je     8004e9 <vprintfmt+0x208>
  8004d3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d6:	83 fa 5e             	cmp    $0x5e,%edx
  8004d9:	76 0e                	jbe    8004e9 <vprintfmt+0x208>
					putch('?', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	57                   	push   %edi
  8004df:	6a 3f                	push   $0x3f
  8004e1:	ff 55 08             	call   *0x8(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb 0b                	jmp    8004f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	57                   	push   %edi
  8004ed:	50                   	push   %eax
  8004ee:	ff 55 08             	call   *0x8(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f7:	0f be 03             	movsbl (%ebx),%eax
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	74 03                	je     800501 <vprintfmt+0x220>
  8004fe:	43                   	inc    %ebx
  8004ff:	eb 1b                	jmp    80051c <vprintfmt+0x23b>
  800501:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800508:	7f 1e                	jg     800528 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050d:	e9 f3 fd ff ff       	jmp    800305 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800515:	43                   	inc    %ebx
  800516:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800519:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80051c:	85 f6                	test   %esi,%esi
  80051e:	78 ad                	js     8004cd <vprintfmt+0x1ec>
  800520:	4e                   	dec    %esi
  800521:	79 aa                	jns    8004cd <vprintfmt+0x1ec>
  800523:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800526:	eb dc                	jmp    800504 <vprintfmt+0x223>
  800528:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	57                   	push   %edi
  80052f:	6a 20                	push   $0x20
  800531:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800534:	4b                   	dec    %ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	85 db                	test   %ebx,%ebx
  80053a:	7f ef                	jg     80052b <vprintfmt+0x24a>
  80053c:	e9 c4 fd ff ff       	jmp    800305 <vprintfmt+0x24>
  800541:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800544:	89 ca                	mov    %ecx,%edx
  800546:	8d 45 14             	lea    0x14(%ebp),%eax
  800549:	e8 2a fd ff ff       	call   800278 <getint>
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800552:	85 d2                	test   %edx,%edx
  800554:	78 0a                	js     800560 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055b:	e9 b0 00 00 00       	jmp    800610 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	57                   	push   %edi
  800564:	6a 2d                	push   $0x2d
  800566:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800569:	f7 db                	neg    %ebx
  80056b:	83 d6 00             	adc    $0x0,%esi
  80056e:	f7 de                	neg    %esi
  800570:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800573:	b8 0a 00 00 00       	mov    $0xa,%eax
  800578:	e9 93 00 00 00       	jmp    800610 <vprintfmt+0x32f>
  80057d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800580:	89 ca                	mov    %ecx,%edx
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 b4 fc ff ff       	call   80023e <getuint>
  80058a:	89 c3                	mov    %eax,%ebx
  80058c:	89 d6                	mov    %edx,%esi
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800593:	eb 7b                	jmp    800610 <vprintfmt+0x32f>
  800595:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800598:	89 ca                	mov    %ecx,%edx
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 d6 fc ff ff       	call   800278 <getint>
  8005a2:	89 c3                	mov    %eax,%ebx
  8005a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	78 07                	js     8005b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8005af:	eb 5f                	jmp    800610 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	57                   	push   %edi
  8005b5:	6a 2d                	push   $0x2d
  8005b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005ba:	f7 db                	neg    %ebx
  8005bc:	83 d6 00             	adc    $0x0,%esi
  8005bf:	f7 de                	neg    %esi
  8005c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c9:	eb 45                	jmp    800610 <vprintfmt+0x32f>
  8005cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	57                   	push   %edi
  8005d2:	6a 30                	push   $0x30
  8005d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d7:	83 c4 08             	add    $0x8,%esp
  8005da:	57                   	push   %edi
  8005db:	6a 78                	push   $0x78
  8005dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e9:	8b 18                	mov    (%eax),%ebx
  8005eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f8:	eb 16                	jmp    800610 <vprintfmt+0x32f>
  8005fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fd:	89 ca                	mov    %ecx,%edx
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 37 fc ff ff       	call   80023e <getuint>
  800607:	89 c3                	mov    %eax,%ebx
  800609:	89 d6                	mov    %edx,%esi
			base = 16;
  80060b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800610:	83 ec 0c             	sub    $0xc,%esp
  800613:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800617:	52                   	push   %edx
  800618:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061b:	50                   	push   %eax
  80061c:	56                   	push   %esi
  80061d:	53                   	push   %ebx
  80061e:	89 fa                	mov    %edi,%edx
  800620:	8b 45 08             	mov    0x8(%ebp),%eax
  800623:	e8 68 fb ff ff       	call   800190 <printnum>
			break;
  800628:	83 c4 20             	add    $0x20,%esp
  80062b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062e:	e9 d2 fc ff ff       	jmp    800305 <vprintfmt+0x24>
  800633:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	57                   	push   %edi
  80063a:	52                   	push   %edx
  80063b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800644:	e9 bc fc ff ff       	jmp    800305 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 25                	push   $0x25
  80064f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb 02                	jmp    800659 <vprintfmt+0x378>
  800657:	89 c6                	mov    %eax,%esi
  800659:	8d 46 ff             	lea    -0x1(%esi),%eax
  80065c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800660:	75 f5                	jne    800657 <vprintfmt+0x376>
  800662:	e9 9e fc ff ff       	jmp    800305 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	83 ec 18             	sub    $0x18,%esp
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800682:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 26                	je     8006b6 <vsnprintf+0x47>
  800690:	85 d2                	test   %edx,%edx
  800692:	7e 29                	jle    8006bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800694:	ff 75 14             	pushl  0x14(%ebp)
  800697:	ff 75 10             	pushl  0x10(%ebp)
  80069a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	68 aa 02 80 00       	push   $0x8002aa
  8006a3:	e8 39 fc ff ff       	call   8002e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 0c                	jmp    8006c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bb:	eb 05                	jmp    8006c2 <vsnprintf+0x53>
  8006bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cd:	50                   	push   %eax
  8006ce:	ff 75 10             	pushl  0x10(%ebp)
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 93 ff ff ff       	call   80066f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    
	...

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e9:	74 0e                	je     8006f9 <strlen+0x19>
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f5:	75 f9                	jne    8006f0 <strlen+0x10>
  8006f7:	eb 05                	jmp    8006fe <strlen+0x1e>
  8006f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800706:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800709:	85 d2                	test   %edx,%edx
  80070b:	74 17                	je     800724 <strnlen+0x24>
  80070d:	80 39 00             	cmpb   $0x0,(%ecx)
  800710:	74 19                	je     80072b <strnlen+0x2b>
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800717:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	39 d0                	cmp    %edx,%eax
  80071a:	74 14                	je     800730 <strnlen+0x30>
  80071c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800720:	75 f5                	jne    800717 <strnlen+0x17>
  800722:	eb 0c                	jmp    800730 <strnlen+0x30>
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 05                	jmp    800730 <strnlen+0x30>
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073c:	ba 00 00 00 00       	mov    $0x0,%edx
  800741:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800744:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800747:	42                   	inc    %edx
  800748:	84 c9                	test   %cl,%cl
  80074a:	75 f5                	jne    800741 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074c:	5b                   	pop    %ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	53                   	push   %ebx
  800757:	e8 84 ff ff ff       	call   8006e0 <strlen>
  80075c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800765:	50                   	push   %eax
  800766:	e8 c7 ff ff ff       	call   800732 <strcpy>
	return dst;
}
  80076b:	89 d8                	mov    %ebx,%eax
  80076d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	85 f6                	test   %esi,%esi
  800782:	74 15                	je     800799 <strncpy+0x27>
  800784:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800789:	8a 1a                	mov    (%edx),%bl
  80078b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078e:	80 3a 01             	cmpb   $0x1,(%edx)
  800791:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800794:	41                   	inc    %ecx
  800795:	39 ce                	cmp    %ecx,%esi
  800797:	77 f0                	ja     800789 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	57                   	push   %edi
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 f6                	test   %esi,%esi
  8007ae:	74 32                	je     8007e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007b0:	83 fe 01             	cmp    $0x1,%esi
  8007b3:	74 22                	je     8007d7 <strlcpy+0x3a>
  8007b5:	8a 0b                	mov    (%ebx),%cl
  8007b7:	84 c9                	test   %cl,%cl
  8007b9:	74 20                	je     8007db <strlcpy+0x3e>
  8007bb:	89 f8                	mov    %edi,%eax
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c5:	88 08                	mov    %cl,(%eax)
  8007c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c8:	39 f2                	cmp    %esi,%edx
  8007ca:	74 11                	je     8007dd <strlcpy+0x40>
  8007cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007d0:	42                   	inc    %edx
  8007d1:	84 c9                	test   %cl,%cl
  8007d3:	75 f0                	jne    8007c5 <strlcpy+0x28>
  8007d5:	eb 06                	jmp    8007dd <strlcpy+0x40>
  8007d7:	89 f8                	mov    %edi,%eax
  8007d9:	eb 02                	jmp    8007dd <strlcpy+0x40>
  8007db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 00 00             	movb   $0x0,(%eax)
  8007e0:	eb 02                	jmp    8007e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007e4:	29 f8                	sub    %edi,%eax
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5f                   	pop    %edi
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f4:	8a 01                	mov    (%ecx),%al
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 10                	je     80080a <strcmp+0x1f>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	75 0c                	jne    80080a <strcmp+0x1f>
		p++, q++;
  8007fe:	41                   	inc    %ecx
  8007ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	8a 01                	mov    (%ecx),%al
  800802:	84 c0                	test   %al,%al
  800804:	74 04                	je     80080a <strcmp+0x1f>
  800806:	3a 02                	cmp    (%edx),%al
  800808:	74 f4                	je     8007fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080a:	0f b6 c0             	movzbl %al,%eax
  80080d:	0f b6 12             	movzbl (%edx),%edx
  800810:	29 d0                	sub    %edx,%eax
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 55 08             	mov    0x8(%ebp),%edx
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800821:	85 c0                	test   %eax,%eax
  800823:	74 1b                	je     800840 <strncmp+0x2c>
  800825:	8a 1a                	mov    (%edx),%bl
  800827:	84 db                	test   %bl,%bl
  800829:	74 24                	je     80084f <strncmp+0x3b>
  80082b:	3a 19                	cmp    (%ecx),%bl
  80082d:	75 20                	jne    80084f <strncmp+0x3b>
  80082f:	48                   	dec    %eax
  800830:	74 15                	je     800847 <strncmp+0x33>
		n--, p++, q++;
  800832:	42                   	inc    %edx
  800833:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800834:	8a 1a                	mov    (%edx),%bl
  800836:	84 db                	test   %bl,%bl
  800838:	74 15                	je     80084f <strncmp+0x3b>
  80083a:	3a 19                	cmp    (%ecx),%bl
  80083c:	74 f1                	je     80082f <strncmp+0x1b>
  80083e:	eb 0f                	jmp    80084f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
  800845:	eb 05                	jmp    80084c <strncmp+0x38>
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084c:	5b                   	pop    %ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 02             	movzbl (%edx),%eax
  800852:	0f b6 11             	movzbl (%ecx),%edx
  800855:	29 d0                	sub    %edx,%eax
  800857:	eb f3                	jmp    80084c <strncmp+0x38>

00800859 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800862:	8a 10                	mov    (%eax),%dl
  800864:	84 d2                	test   %dl,%dl
  800866:	74 18                	je     800880 <strchr+0x27>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	75 06                	jne    800872 <strchr+0x19>
  80086c:	eb 17                	jmp    800885 <strchr+0x2c>
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 13                	je     800885 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800872:	40                   	inc    %eax
  800873:	8a 10                	mov    (%eax),%dl
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f5                	jne    80086e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 05                	jmp    800885 <strchr+0x2c>
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800890:	8a 10                	mov    (%eax),%dl
  800892:	84 d2                	test   %dl,%dl
  800894:	74 11                	je     8008a7 <strfind+0x20>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	75 06                	jne    8008a0 <strfind+0x19>
  80089a:	eb 0b                	jmp    8008a7 <strfind+0x20>
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 07                	je     8008a7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	40                   	inc    %eax
  8008a1:	8a 10                	mov    (%eax),%dl
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f5                	jne    80089c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b8:	85 c9                	test   %ecx,%ecx
  8008ba:	74 30                	je     8008ec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c2:	75 25                	jne    8008e9 <memset+0x40>
  8008c4:	f6 c1 03             	test   $0x3,%cl
  8008c7:	75 20                	jne    8008e9 <memset+0x40>
		c &= 0xFF;
  8008c9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cc:	89 d3                	mov    %edx,%ebx
  8008ce:	c1 e3 08             	shl    $0x8,%ebx
  8008d1:	89 d6                	mov    %edx,%esi
  8008d3:	c1 e6 18             	shl    $0x18,%esi
  8008d6:	89 d0                	mov    %edx,%eax
  8008d8:	c1 e0 10             	shl    $0x10,%eax
  8008db:	09 f0                	or     %esi,%eax
  8008dd:	09 d0                	or     %edx,%eax
  8008df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e4:	fc                   	cld    
  8008e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e7:	eb 03                	jmp    8008ec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e9:	fc                   	cld    
  8008ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ec:	89 f8                	mov    %edi,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 34                	jae    800939 <memmove+0x46>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 d0                	cmp    %edx,%eax
  80090a:	73 2d                	jae    800939 <memmove+0x46>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	f6 c2 03             	test   $0x3,%dl
  800912:	75 1b                	jne    80092f <memmove+0x3c>
  800914:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091a:	75 13                	jne    80092f <memmove+0x3c>
  80091c:	f6 c1 03             	test   $0x3,%cl
  80091f:	75 0e                	jne    80092f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800921:	83 ef 04             	sub    $0x4,%edi
  800924:	8d 72 fc             	lea    -0x4(%edx),%esi
  800927:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092a:	fd                   	std    
  80092b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092d:	eb 07                	jmp    800936 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092f:	4f                   	dec    %edi
  800930:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800933:	fd                   	std    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800936:	fc                   	cld    
  800937:	eb 20                	jmp    800959 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093f:	75 13                	jne    800954 <memmove+0x61>
  800941:	a8 03                	test   $0x3,%al
  800943:	75 0f                	jne    800954 <memmove+0x61>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 0a                	jne    800954 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 05                	jmp    800959 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800954:	89 c7                	mov    %eax,%edi
  800956:	fc                   	cld    
  800957:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 85 ff ff ff       	call   8008f3 <memmove>
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800979:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097f:	85 ff                	test   %edi,%edi
  800981:	74 32                	je     8009b5 <memcmp+0x45>
		if (*s1 != *s2)
  800983:	8a 03                	mov    (%ebx),%al
  800985:	8a 0e                	mov    (%esi),%cl
  800987:	38 c8                	cmp    %cl,%al
  800989:	74 19                	je     8009a4 <memcmp+0x34>
  80098b:	eb 0d                	jmp    80099a <memcmp+0x2a>
  80098d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800991:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800995:	42                   	inc    %edx
  800996:	38 c8                	cmp    %cl,%al
  800998:	74 10                	je     8009aa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80099a:	0f b6 c0             	movzbl %al,%eax
  80099d:	0f b6 c9             	movzbl %cl,%ecx
  8009a0:	29 c8                	sub    %ecx,%eax
  8009a2:	eb 16                	jmp    8009ba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	4f                   	dec    %edi
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	39 fa                	cmp    %edi,%edx
  8009ac:	75 df                	jne    80098d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	eb 05                	jmp    8009ba <memcmp+0x4a>
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	73 12                	jae    8009e0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009d1:	38 08                	cmp    %cl,(%eax)
  8009d3:	75 06                	jne    8009db <memfind+0x1c>
  8009d5:	eb 09                	jmp    8009e0 <memfind+0x21>
  8009d7:	38 08                	cmp    %cl,(%eax)
  8009d9:	74 05                	je     8009e0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	40                   	inc    %eax
  8009dc:	39 c2                	cmp    %eax,%edx
  8009de:	77 f7                	ja     8009d7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 01                	jmp    8009f1 <strtol+0xf>
		s++;
  8009f0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	8a 02                	mov    (%edx),%al
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f9                	je     8009f0 <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f5                	je     8009f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	75 08                	jne    800a07 <strtol+0x25>
		s++;
  8009ff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	eb 13                	jmp    800a1a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	75 0a                	jne    800a15 <strtol+0x33>
		s++, neg = 1;
  800a0b:	8d 52 01             	lea    0x1(%edx),%edx
  800a0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a13:	eb 05                	jmp    800a1a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	74 05                	je     800a23 <strtol+0x41>
  800a1e:	83 fb 10             	cmp    $0x10,%ebx
  800a21:	75 28                	jne    800a4b <strtol+0x69>
  800a23:	8a 02                	mov    (%edx),%al
  800a25:	3c 30                	cmp    $0x30,%al
  800a27:	75 10                	jne    800a39 <strtol+0x57>
  800a29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2d:	75 0a                	jne    800a39 <strtol+0x57>
		s += 2, base = 16;
  800a2f:	83 c2 02             	add    $0x2,%edx
  800a32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a37:	eb 12                	jmp    800a4b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	75 0e                	jne    800a4b <strtol+0x69>
  800a3d:	3c 30                	cmp    $0x30,%al
  800a3f:	75 05                	jne    800a46 <strtol+0x64>
		s++, base = 8;
  800a41:	42                   	inc    %edx
  800a42:	b3 08                	mov    $0x8,%bl
  800a44:	eb 05                	jmp    800a4b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a46:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	8a 0a                	mov    (%edx),%cl
  800a54:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a57:	80 fb 09             	cmp    $0x9,%bl
  800a5a:	77 08                	ja     800a64 <strtol+0x82>
			dig = *s - '0';
  800a5c:	0f be c9             	movsbl %cl,%ecx
  800a5f:	83 e9 30             	sub    $0x30,%ecx
  800a62:	eb 1e                	jmp    800a82 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a64:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a6c:	0f be c9             	movsbl %cl,%ecx
  800a6f:	83 e9 57             	sub    $0x57,%ecx
  800a72:	eb 0e                	jmp    800a82 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a74:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a77:	80 fb 19             	cmp    $0x19,%bl
  800a7a:	77 13                	ja     800a8f <strtol+0xad>
			dig = *s - 'A' + 10;
  800a7c:	0f be c9             	movsbl %cl,%ecx
  800a7f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a82:	39 f1                	cmp    %esi,%ecx
  800a84:	7d 0d                	jge    800a93 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a86:	42                   	inc    %edx
  800a87:	0f af c6             	imul   %esi,%eax
  800a8a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a8d:	eb c3                	jmp    800a52 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	89 c1                	mov    %eax,%ecx
  800a91:	eb 02                	jmp    800a95 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a93:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a99:	74 05                	je     800aa0 <strtol+0xbe>
		*endptr = (char *) s;
  800a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aa0:	85 ff                	test   %edi,%edi
  800aa2:	74 04                	je     800aa8 <strtol+0xc6>
  800aa4:	89 c8                	mov    %ecx,%eax
  800aa6:	f7 d8                	neg    %eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    
  800aad:	00 00                	add    %al,(%eax)
	...

00800ab0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 1c             	sub    $0x1c,%esp
  800ab9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800abc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800abf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acd:	cd 30                	int    $0x30
  800acf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ad5:	74 1c                	je     800af3 <syscall+0x43>
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	7e 18                	jle    800af3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	50                   	push   %eax
  800adf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ae2:	68 bf 21 80 00       	push   $0x8021bf
  800ae7:	6a 42                	push   $0x42
  800ae9:	68 dc 21 80 00       	push   $0x8021dc
  800aee:	e8 b5 0f 00 00       	call   801aa8 <_panic>

	return ret;
}
  800af3:	89 d0                	mov    %edx,%eax
  800af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b03:	6a 00                	push   $0x0
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	ff 75 0c             	pushl  0xc(%ebp)
  800b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	e8 92 ff ff ff       	call   800ab0 <syscall>
  800b1e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	e8 6b ff ff ff       	call   800ab0 <syscall>
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b58:	ba 01 00 00 00       	mov    $0x1,%edx
  800b5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b62:	e8 49 ff ff ff       	call   800ab0 <syscall>
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 02 00 00 00       	mov    $0x2,%eax
  800b86:	e8 25 ff ff ff       	call   800ab0 <syscall>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <sys_yield>:

void
sys_yield(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	e8 01 ff ff ff       	call   800ab0 <syscall>
  800baf:	83 c4 10             	add    $0x10,%esp
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bba:	6a 00                	push   $0x0
  800bbc:	6a 00                	push   $0x0
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd1:	e8 da fe ff ff       	call   800ab0 <syscall>
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bde:	ff 75 18             	pushl  0x18(%ebp)
  800be1:	ff 75 14             	pushl  0x14(%ebp)
  800be4:	ff 75 10             	pushl  0x10(%ebp)
  800be7:	ff 75 0c             	pushl  0xc(%ebp)
  800bea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bed:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf7:	e8 b4 fe ff ff       	call   800ab0 <syscall>
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c04:	6a 00                	push   $0x0
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	ff 75 0c             	pushl  0xc(%ebp)
  800c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c10:	ba 01 00 00 00       	mov    $0x1,%edx
  800c15:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1a:	e8 91 fe ff ff       	call   800ab0 <syscall>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	ff 75 0c             	pushl  0xc(%ebp)
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	ba 01 00 00 00       	mov    $0x1,%edx
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3d:	e8 6e fe ff ff       	call   800ab0 <syscall>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	6a 00                	push   $0x0
  800c50:	ff 75 0c             	pushl  0xc(%ebp)
  800c53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c56:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c60:	e8 4b fe ff ff       	call   800ab0 <syscall>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c6d:	6a 00                	push   $0x0
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	ff 75 0c             	pushl  0xc(%ebp)
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c83:	e8 28 fe ff ff       	call   800ab0 <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c90:	6a 00                	push   $0x0
  800c92:	ff 75 14             	pushl  0x14(%ebp)
  800c95:	ff 75 10             	pushl  0x10(%ebp)
  800c98:	ff 75 0c             	pushl  0xc(%ebp)
  800c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca8:	e8 03 fe ff ff       	call   800ab0 <syscall>
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cb5:	6a 00                	push   $0x0
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cca:	e8 e1 fd ff ff       	call   800ab0 <syscall>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	ff 75 0c             	pushl  0xc(%ebp)
  800ce0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ced:	e8 be fd ff ff       	call   800ab0 <syscall>
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cfa:	6a 00                	push   $0x0
  800cfc:	ff 75 14             	pushl  0x14(%ebp)
  800cff:	ff 75 10             	pushl  0x10(%ebp)
  800d02:	ff 75 0c             	pushl  0xc(%ebp)
  800d05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d12:	e8 99 fd ff ff       	call   800ab0 <syscall>
} 
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d1f:	6a 00                	push   $0x0
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 11 00 00 00       	mov    $0x11,%eax
  800d34:	e8 77 fd ff ff       	call   800ab0 <syscall>
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d53:	b8 10 00 00 00       	mov    $0x10,%eax
  800d58:	e8 53 fd ff ff       	call   800ab0 <syscall>
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    
	...

00800d60 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d66:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d6d:	75 52                	jne    800dc1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	6a 07                	push   $0x7
  800d74:	68 00 f0 bf ee       	push   $0xeebff000
  800d79:	6a 00                	push   $0x0
  800d7b:	e8 34 fe ff ff       	call   800bb4 <sys_page_alloc>
		if (r < 0) {
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	79 12                	jns    800d99 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d87:	50                   	push   %eax
  800d88:	68 ea 21 80 00       	push   $0x8021ea
  800d8d:	6a 24                	push   $0x24
  800d8f:	68 05 22 80 00       	push   $0x802205
  800d94:	e8 0f 0d 00 00       	call   801aa8 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d99:	83 ec 08             	sub    $0x8,%esp
  800d9c:	68 cc 0d 80 00       	push   $0x800dcc
  800da1:	6a 00                	push   $0x0
  800da3:	e8 bf fe ff ff       	call   800c67 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	79 12                	jns    800dc1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800daf:	50                   	push   %eax
  800db0:	68 14 22 80 00       	push   $0x802214
  800db5:	6a 2a                	push   $0x2a
  800db7:	68 05 22 80 00       	push   $0x802205
  800dbc:	e8 e7 0c 00 00       	call   801aa8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    
	...

00800dcc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dcc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dcd:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dd2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dd4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800dd7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800ddb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800dde:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800de2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800de6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800de8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800deb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800dec:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800def:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800df0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800df1:	c3                   	ret    
	...

00800df4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	05 00 00 00 30       	add    $0x30000000,%eax
  800dff:	c1 e8 0c             	shr    $0xc,%eax
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e07:	ff 75 08             	pushl  0x8(%ebp)
  800e0a:	e8 e5 ff ff ff       	call   800df4 <fd2num>
  800e0f:	83 c4 04             	add    $0x4,%esp
  800e12:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e17:	c1 e0 0c             	shl    $0xc,%eax
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	53                   	push   %ebx
  800e20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e23:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e28:	a8 01                	test   $0x1,%al
  800e2a:	74 34                	je     800e60 <fd_alloc+0x44>
  800e2c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e31:	a8 01                	test   $0x1,%al
  800e33:	74 32                	je     800e67 <fd_alloc+0x4b>
  800e35:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e3a:	89 c1                	mov    %eax,%ecx
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 1f                	je     800e6c <fd_alloc+0x50>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	75 17                	jne    800e75 <fd_alloc+0x59>
  800e5e:	eb 0c                	jmp    800e6c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e60:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e65:	eb 05                	jmp    800e6c <fd_alloc+0x50>
  800e67:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e6c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	eb 17                	jmp    800e8c <fd_alloc+0x70>
  800e75:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e7a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e7f:	75 b9                	jne    800e3a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e87:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e95:	83 f8 1f             	cmp    $0x1f,%eax
  800e98:	77 36                	ja     800ed0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e9a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e9f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	c1 ea 16             	shr    $0x16,%edx
  800ea7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eae:	f6 c2 01             	test   $0x1,%dl
  800eb1:	74 24                	je     800ed7 <fd_lookup+0x48>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
  800eb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	74 1a                	je     800ede <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec7:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	eb 13                	jmp    800ee3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed5:	eb 0c                	jmp    800ee3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edc:	eb 05                	jmp    800ee3 <fd_lookup+0x54>
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ef2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800ef8:	74 0d                	je     800f07 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 14                	jmp    800f15 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f01:	39 0a                	cmp    %ecx,(%edx)
  800f03:	75 10                	jne    800f15 <dev_lookup+0x30>
  800f05:	eb 05                	jmp    800f0c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f07:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f0c:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	eb 31                	jmp    800f46 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f15:	40                   	inc    %eax
  800f16:	8b 14 85 b8 22 80 00 	mov    0x8022b8(,%eax,4),%edx
  800f1d:	85 d2                	test   %edx,%edx
  800f1f:	75 e0                	jne    800f01 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f21:	a1 04 40 80 00       	mov    0x804004,%eax
  800f26:	8b 40 48             	mov    0x48(%eax),%eax
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	51                   	push   %ecx
  800f2d:	50                   	push   %eax
  800f2e:	68 3c 22 80 00       	push   $0x80223c
  800f33:	e8 44 f2 ff ff       	call   80017c <cprintf>
	*dev = 0;
  800f38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 20             	sub    $0x20,%esp
  800f53:	8b 75 08             	mov    0x8(%ebp),%esi
  800f56:	8a 45 0c             	mov    0xc(%ebp),%al
  800f59:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5c:	56                   	push   %esi
  800f5d:	e8 92 fe ff ff       	call   800df4 <fd2num>
  800f62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f65:	89 14 24             	mov    %edx,(%esp)
  800f68:	50                   	push   %eax
  800f69:	e8 21 ff ff ff       	call   800e8f <fd_lookup>
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 05                	js     800f7c <fd_close+0x31>
	    || fd != fd2)
  800f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7a:	74 0d                	je     800f89 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f7c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f80:	75 48                	jne    800fca <fd_close+0x7f>
  800f82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f87:	eb 41                	jmp    800fca <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 36                	pushl  (%esi)
  800f92:	e8 4e ff ff ff       	call   800ee5 <dev_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 1c                	js     800fbc <fd_close+0x71>
		if (dev->dev_close)
  800fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa3:	8b 40 10             	mov    0x10(%eax),%eax
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	74 0d                	je     800fb7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	56                   	push   %esi
  800fae:	ff d0                	call   *%eax
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	eb 05                	jmp    800fbc <fd_close+0x71>
		else
			r = 0;
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 37 fc ff ff       	call   800bfe <sys_page_unmap>
	return r;
  800fc7:	83 c4 10             	add    $0x10,%esp
}
  800fca:	89 d8                	mov    %ebx,%eax
  800fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 aa fe ff ff       	call   800e8f <fd_lookup>
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 10                	js     800ffc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 01                	push   $0x1
  800ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff4:	e8 52 ff ff ff       	call   800f4b <fd_close>
  800ff9:	83 c4 10             	add    $0x10,%esp
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <close_all>:

void
close_all(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	53                   	push   %ebx
  801002:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801005:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	53                   	push   %ebx
  80100e:	e8 c0 ff ff ff       	call   800fd3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801013:	43                   	inc    %ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	83 fb 20             	cmp    $0x20,%ebx
  80101a:	75 ee                	jne    80100a <close_all+0xc>
		close(i);
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 2c             	sub    $0x2c,%esp
  80102a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 56 fe ff ff       	call   800e8f <fd_lookup>
  801039:	89 c3                	mov    %eax,%ebx
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	0f 88 c0 00 00 00    	js     801106 <dup+0xe5>
		return r;
	close(newfdnum);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	57                   	push   %edi
  80104a:	e8 84 ff ff ff       	call   800fd3 <close>

	newfd = INDEX2FD(newfdnum);
  80104f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801055:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105e:	e8 a1 fd ff ff       	call   800e04 <fd2data>
  801063:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801065:	89 34 24             	mov    %esi,(%esp)
  801068:	e8 97 fd ff ff       	call   800e04 <fd2data>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801073:	89 d8                	mov    %ebx,%eax
  801075:	c1 e8 16             	shr    $0x16,%eax
  801078:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 37                	je     8010ba <dup+0x99>
  801083:	89 d8                	mov    %ebx,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 26                	je     8010ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	53                   	push   %ebx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 27 fb ff ff       	call   800bd8 <sys_page_map>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 2d                	js     8010e7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	c1 ea 0c             	shr    $0xc,%edx
  8010c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d2:	52                   	push   %edx
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	50                   	push   %eax
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 fa fa ff ff       	call   800bd8 <sys_page_map>
  8010de:	89 c3                	mov    %eax,%ebx
  8010e0:	83 c4 20             	add    $0x20,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 1d                	jns    801104 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	56                   	push   %esi
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 0c fb ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 ff fa ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	eb 02                	jmp    801106 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801104:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801106:	89 d8                	mov    %ebx,%eax
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	53                   	push   %ebx
  801114:	83 ec 14             	sub    $0x14,%esp
  801117:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	53                   	push   %ebx
  80111f:	e8 6b fd ff ff       	call   800e8f <fd_lookup>
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 67                	js     801192 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801135:	ff 30                	pushl  (%eax)
  801137:	e8 a9 fd ff ff       	call   800ee5 <dev_lookup>
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 4f                	js     801192 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	8b 50 08             	mov    0x8(%eax),%edx
  801149:	83 e2 03             	and    $0x3,%edx
  80114c:	83 fa 01             	cmp    $0x1,%edx
  80114f:	75 21                	jne    801172 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801151:	a1 04 40 80 00       	mov    0x804004,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	53                   	push   %ebx
  80115d:	50                   	push   %eax
  80115e:	68 7d 22 80 00       	push   $0x80227d
  801163:	e8 14 f0 ff ff       	call   80017c <cprintf>
		return -E_INVAL;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801170:	eb 20                	jmp    801192 <read+0x82>
	}
	if (!dev->dev_read)
  801172:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801175:	8b 52 08             	mov    0x8(%edx),%edx
  801178:	85 d2                	test   %edx,%edx
  80117a:	74 11                	je     80118d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	ff 75 0c             	pushl  0xc(%ebp)
  801185:	50                   	push   %eax
  801186:	ff d2                	call   *%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	eb 05                	jmp    801192 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80118d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a6:	85 f6                	test   %esi,%esi
  8011a8:	74 31                	je     8011db <readn+0x44>
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	29 c2                	sub    %eax,%edx
  8011bb:	52                   	push   %edx
  8011bc:	03 45 0c             	add    0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	57                   	push   %edi
  8011c1:	e8 4a ff ff ff       	call   801110 <read>
		if (m < 0)
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 17                	js     8011e4 <readn+0x4d>
			return m;
		if (m == 0)
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	74 11                	je     8011e2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d1:	01 c3                	add    %eax,%ebx
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	39 f3                	cmp    %esi,%ebx
  8011d7:	72 db                	jb     8011b4 <readn+0x1d>
  8011d9:	eb 09                	jmp    8011e4 <readn+0x4d>
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e0:	eb 02                	jmp    8011e4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011e2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	53                   	push   %ebx
  8011fb:	e8 8f fc ff ff       	call   800e8f <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 62                	js     801269 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801211:	ff 30                	pushl  (%eax)
  801213:	e8 cd fc ff ff       	call   800ee5 <dev_lookup>
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 4a                	js     801269 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801222:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801226:	75 21                	jne    801249 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801228:	a1 04 40 80 00       	mov    0x804004,%eax
  80122d:	8b 40 48             	mov    0x48(%eax),%eax
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	53                   	push   %ebx
  801234:	50                   	push   %eax
  801235:	68 99 22 80 00       	push   $0x802299
  80123a:	e8 3d ef ff ff       	call   80017c <cprintf>
		return -E_INVAL;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801247:	eb 20                	jmp    801269 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801249:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124c:	8b 52 0c             	mov    0xc(%edx),%edx
  80124f:	85 d2                	test   %edx,%edx
  801251:	74 11                	je     801264 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801253:	83 ec 04             	sub    $0x4,%esp
  801256:	ff 75 10             	pushl  0x10(%ebp)
  801259:	ff 75 0c             	pushl  0xc(%ebp)
  80125c:	50                   	push   %eax
  80125d:	ff d2                	call   *%edx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb 05                	jmp    801269 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801264:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <seek>:

int
seek(int fdnum, off_t offset)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801274:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 0f fc ff ff       	call   800e8f <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 0e                	js     801295 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801287:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	53                   	push   %ebx
  80129b:	83 ec 14             	sub    $0x14,%esp
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	53                   	push   %ebx
  8012a6:	e8 e4 fb ff ff       	call   800e8f <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 5f                	js     801311 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	ff 30                	pushl  (%eax)
  8012be:	e8 22 fc ff ff       	call   800ee5 <dev_lookup>
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 47                	js     801311 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d1:	75 21                	jne    8012f4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d8:	8b 40 48             	mov    0x48(%eax),%eax
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	53                   	push   %ebx
  8012df:	50                   	push   %eax
  8012e0:	68 5c 22 80 00       	push   $0x80225c
  8012e5:	e8 92 ee ff ff       	call   80017c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f2:	eb 1d                	jmp    801311 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f7:	8b 52 18             	mov    0x18(%edx),%edx
  8012fa:	85 d2                	test   %edx,%edx
  8012fc:	74 0e                	je     80130c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	ff 75 0c             	pushl  0xc(%ebp)
  801304:	50                   	push   %eax
  801305:	ff d2                	call   *%edx
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	eb 05                	jmp    801311 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 63 fb ff ff       	call   800e8f <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 52                	js     801385 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 a1 fb ff ff       	call   800ee5 <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 3a                	js     801385 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801352:	74 2c                	je     801380 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801354:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801357:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80135e:	00 00 00 
	stat->st_isdir = 0;
  801361:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801368:	00 00 00 
	stat->st_dev = dev;
  80136b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	ff 75 f0             	pushl  -0x10(%ebp)
  801378:	ff 50 14             	call   *0x14(%eax)
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb 05                	jmp    801385 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801380:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	6a 00                	push   $0x0
  801394:	ff 75 08             	pushl  0x8(%ebp)
  801397:	e8 78 01 00 00       	call   801514 <open>
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 1b                	js     8013c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	ff 75 0c             	pushl  0xc(%ebp)
  8013ab:	50                   	push   %eax
  8013ac:	e8 65 ff ff ff       	call   801316 <fstat>
  8013b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b3:	89 1c 24             	mov    %ebx,(%esp)
  8013b6:	e8 18 fc ff ff       	call   800fd3 <close>
	return r;
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 f3                	mov    %esi,%ebx
}
  8013c0:	89 d8                	mov    %ebx,%eax
  8013c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    
  8013c9:	00 00                	add    %al,(%eax)
	...

008013cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013dc:	75 12                	jne    8013f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	6a 01                	push   $0x1
  8013e3:	e8 d2 07 00 00       	call   801bba <ipc_find_env>
  8013e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f0:	6a 07                	push   $0x7
  8013f2:	68 00 50 80 00       	push   $0x805000
  8013f7:	53                   	push   %ebx
  8013f8:	ff 35 00 40 80 00    	pushl  0x804000
  8013fe:	e8 62 07 00 00       	call   801b65 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801403:	83 c4 0c             	add    $0xc,%esp
  801406:	6a 00                	push   $0x0
  801408:	56                   	push   %esi
  801409:	6a 00                	push   $0x0
  80140b:	e8 e0 06 00 00       	call   801af0 <ipc_recv>
}
  801410:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 05 00 00 00       	mov    $0x5,%eax
  801436:	e8 91 ff ff ff       	call   8013cc <fsipc>
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 2c                	js     80146b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	68 00 50 80 00       	push   $0x805000
  801447:	53                   	push   %ebx
  801448:	e8 e5 f2 ff ff       	call   800732 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80144d:	a1 80 50 80 00       	mov    0x805080,%eax
  801452:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801458:	a1 84 50 80 00       	mov    0x805084,%eax
  80145d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801481:	ba 00 00 00 00       	mov    $0x0,%edx
  801486:	b8 06 00 00 00       	mov    $0x6,%eax
  80148b:	e8 3c ff ff ff       	call   8013cc <fsipc>
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b5:	e8 12 ff ff ff       	call   8013cc <fsipc>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 4b                	js     80150b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c0:	39 c6                	cmp    %eax,%esi
  8014c2:	73 16                	jae    8014da <devfile_read+0x48>
  8014c4:	68 c8 22 80 00       	push   $0x8022c8
  8014c9:	68 cf 22 80 00       	push   $0x8022cf
  8014ce:	6a 7d                	push   $0x7d
  8014d0:	68 e4 22 80 00       	push   $0x8022e4
  8014d5:	e8 ce 05 00 00       	call   801aa8 <_panic>
	assert(r <= PGSIZE);
  8014da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014df:	7e 16                	jle    8014f7 <devfile_read+0x65>
  8014e1:	68 ef 22 80 00       	push   $0x8022ef
  8014e6:	68 cf 22 80 00       	push   $0x8022cf
  8014eb:	6a 7e                	push   $0x7e
  8014ed:	68 e4 22 80 00       	push   $0x8022e4
  8014f2:	e8 b1 05 00 00       	call   801aa8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	50                   	push   %eax
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	e8 eb f3 ff ff       	call   8008f3 <memmove>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
  801519:	83 ec 1c             	sub    $0x1c,%esp
  80151c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151f:	56                   	push   %esi
  801520:	e8 bb f1 ff ff       	call   8006e0 <strlen>
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152d:	7f 65                	jg     801594 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	e8 e1 f8 ff ff       	call   800e1c <fd_alloc>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 55                	js     801599 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	56                   	push   %esi
  801548:	68 00 50 80 00       	push   $0x805000
  80154d:	e8 e0 f1 ff ff       	call   800732 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801552:	8b 45 0c             	mov    0xc(%ebp),%eax
  801555:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80155a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155d:	b8 01 00 00 00       	mov    $0x1,%eax
  801562:	e8 65 fe ff ff       	call   8013cc <fsipc>
  801567:	89 c3                	mov    %eax,%ebx
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	79 12                	jns    801582 <open+0x6e>
		fd_close(fd, 0);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	6a 00                	push   $0x0
  801575:	ff 75 f4             	pushl  -0xc(%ebp)
  801578:	e8 ce f9 ff ff       	call   800f4b <fd_close>
		return r;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	eb 17                	jmp    801599 <open+0x85>
	}

	return fd2num(fd);
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	ff 75 f4             	pushl  -0xc(%ebp)
  801588:	e8 67 f8 ff ff       	call   800df4 <fd2num>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb 05                	jmp    801599 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801594:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801599:	89 d8                	mov    %ebx,%eax
  80159b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    
	...

008015a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	ff 75 08             	pushl  0x8(%ebp)
  8015b2:	e8 4d f8 ff ff       	call   800e04 <fd2data>
  8015b7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	68 fb 22 80 00       	push   $0x8022fb
  8015c1:	56                   	push   %esi
  8015c2:	e8 6b f1 ff ff       	call   800732 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8015ca:	2b 03                	sub    (%ebx),%eax
  8015cc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015d2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8015d9:	00 00 00 
	stat->st_dev = &devpipe;
  8015dc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015e3:	30 80 00 
	return 0;
}
  8015e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 0c             	sub    $0xc,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015fc:	53                   	push   %ebx
  8015fd:	6a 00                	push   $0x0
  8015ff:	e8 fa f5 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801604:	89 1c 24             	mov    %ebx,(%esp)
  801607:	e8 f8 f7 ff ff       	call   800e04 <fd2data>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	50                   	push   %eax
  801610:	6a 00                	push   $0x0
  801612:	e8 e7 f5 ff ff       	call   800bfe <sys_page_unmap>
}
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 1c             	sub    $0x1c,%esp
  801625:	89 c7                	mov    %eax,%edi
  801627:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80162a:	a1 04 40 80 00       	mov    0x804004,%eax
  80162f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	57                   	push   %edi
  801636:	e8 cd 05 00 00       	call   801c08 <pageref>
  80163b:	89 c6                	mov    %eax,%esi
  80163d:	83 c4 04             	add    $0x4,%esp
  801640:	ff 75 e4             	pushl  -0x1c(%ebp)
  801643:	e8 c0 05 00 00       	call   801c08 <pageref>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	39 c6                	cmp    %eax,%esi
  80164d:	0f 94 c0             	sete   %al
  801650:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801653:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801659:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80165c:	39 cb                	cmp    %ecx,%ebx
  80165e:	75 08                	jne    801668 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801660:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5f                   	pop    %edi
  801666:	c9                   	leave  
  801667:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801668:	83 f8 01             	cmp    $0x1,%eax
  80166b:	75 bd                	jne    80162a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80166d:	8b 42 58             	mov    0x58(%edx),%eax
  801670:	6a 01                	push   $0x1
  801672:	50                   	push   %eax
  801673:	53                   	push   %ebx
  801674:	68 02 23 80 00       	push   $0x802302
  801679:	e8 fe ea ff ff       	call   80017c <cprintf>
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	eb a7                	jmp    80162a <_pipeisclosed+0xe>

00801683 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	57                   	push   %edi
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	83 ec 28             	sub    $0x28,%esp
  80168c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80168f:	56                   	push   %esi
  801690:	e8 6f f7 ff ff       	call   800e04 <fd2data>
  801695:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80169e:	75 4a                	jne    8016ea <devpipe_write+0x67>
  8016a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8016a5:	eb 56                	jmp    8016fd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016a7:	89 da                	mov    %ebx,%edx
  8016a9:	89 f0                	mov    %esi,%eax
  8016ab:	e8 6c ff ff ff       	call   80161c <_pipeisclosed>
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 4d                	jne    801701 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016b4:	e8 d4 f4 ff ff       	call   800b8d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016b9:	8b 43 04             	mov    0x4(%ebx),%eax
  8016bc:	8b 13                	mov    (%ebx),%edx
  8016be:	83 c2 20             	add    $0x20,%edx
  8016c1:	39 d0                	cmp    %edx,%eax
  8016c3:	73 e2                	jae    8016a7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016cd:	79 05                	jns    8016d4 <devpipe_write+0x51>
  8016cf:	4a                   	dec    %edx
  8016d0:	83 ca e0             	or     $0xffffffe0,%edx
  8016d3:	42                   	inc    %edx
  8016d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8016da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016de:	40                   	inc    %eax
  8016df:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e2:	47                   	inc    %edi
  8016e3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016e6:	77 07                	ja     8016ef <devpipe_write+0x6c>
  8016e8:	eb 13                	jmp    8016fd <devpipe_write+0x7a>
  8016ea:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f2:	8b 13                	mov    (%ebx),%edx
  8016f4:	83 c2 20             	add    $0x20,%edx
  8016f7:	39 d0                	cmp    %edx,%eax
  8016f9:	73 ac                	jae    8016a7 <devpipe_write+0x24>
  8016fb:	eb c8                	jmp    8016c5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016fd:	89 f8                	mov    %edi,%eax
  8016ff:	eb 05                	jmp    801706 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	57                   	push   %edi
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 18             	sub    $0x18,%esp
  801717:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80171a:	57                   	push   %edi
  80171b:	e8 e4 f6 ff ff       	call   800e04 <fd2data>
  801720:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801729:	75 44                	jne    80176f <devpipe_read+0x61>
  80172b:	be 00 00 00 00       	mov    $0x0,%esi
  801730:	eb 4f                	jmp    801781 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801732:	89 f0                	mov    %esi,%eax
  801734:	eb 54                	jmp    80178a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801736:	89 da                	mov    %ebx,%edx
  801738:	89 f8                	mov    %edi,%eax
  80173a:	e8 dd fe ff ff       	call   80161c <_pipeisclosed>
  80173f:	85 c0                	test   %eax,%eax
  801741:	75 42                	jne    801785 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801743:	e8 45 f4 ff ff       	call   800b8d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801748:	8b 03                	mov    (%ebx),%eax
  80174a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80174d:	74 e7                	je     801736 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80174f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801754:	79 05                	jns    80175b <devpipe_read+0x4d>
  801756:	48                   	dec    %eax
  801757:	83 c8 e0             	or     $0xffffffe0,%eax
  80175a:	40                   	inc    %eax
  80175b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80175f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801762:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801765:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801767:	46                   	inc    %esi
  801768:	39 75 10             	cmp    %esi,0x10(%ebp)
  80176b:	77 07                	ja     801774 <devpipe_read+0x66>
  80176d:	eb 12                	jmp    801781 <devpipe_read+0x73>
  80176f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801774:	8b 03                	mov    (%ebx),%eax
  801776:	3b 43 04             	cmp    0x4(%ebx),%eax
  801779:	75 d4                	jne    80174f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80177b:	85 f6                	test   %esi,%esi
  80177d:	75 b3                	jne    801732 <devpipe_read+0x24>
  80177f:	eb b5                	jmp    801736 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801781:	89 f0                	mov    %esi,%eax
  801783:	eb 05                	jmp    80178a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801785:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80178a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5f                   	pop    %edi
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	57                   	push   %edi
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	83 ec 28             	sub    $0x28,%esp
  80179b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80179e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017a1:	50                   	push   %eax
  8017a2:	e8 75 f6 ff ff       	call   800e1c <fd_alloc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	0f 88 24 01 00 00    	js     8018d8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	68 07 04 00 00       	push   $0x407
  8017bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 ee f3 ff ff       	call   800bb4 <sys_page_alloc>
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	0f 88 05 01 00 00    	js     8018d8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017d3:	83 ec 0c             	sub    $0xc,%esp
  8017d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	e8 3d f6 ff ff       	call   800e1c <fd_alloc>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	0f 88 dc 00 00 00    	js     8018c8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	68 07 04 00 00       	push   $0x407
  8017f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 b6 f3 ff ff       	call   800bb4 <sys_page_alloc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 88 bd 00 00 00    	js     8018c8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801811:	e8 ee f5 ff ff       	call   800e04 <fd2data>
  801816:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801818:	83 c4 0c             	add    $0xc,%esp
  80181b:	68 07 04 00 00       	push   $0x407
  801820:	50                   	push   %eax
  801821:	6a 00                	push   $0x0
  801823:	e8 8c f3 ff ff       	call   800bb4 <sys_page_alloc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	0f 88 83 00 00 00    	js     8018b8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 e0             	pushl  -0x20(%ebp)
  80183b:	e8 c4 f5 ff ff       	call   800e04 <fd2data>
  801840:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801847:	50                   	push   %eax
  801848:	6a 00                	push   $0x0
  80184a:	56                   	push   %esi
  80184b:	6a 00                	push   $0x0
  80184d:	e8 86 f3 ff ff       	call   800bd8 <sys_page_map>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 20             	add    $0x20,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	78 4f                	js     8018aa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80185b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801864:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801869:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801870:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801876:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801879:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80187b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80187e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801885:	83 ec 0c             	sub    $0xc,%esp
  801888:	ff 75 e4             	pushl  -0x1c(%ebp)
  80188b:	e8 64 f5 ff ff       	call   800df4 <fd2num>
  801890:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801892:	83 c4 04             	add    $0x4,%esp
  801895:	ff 75 e0             	pushl  -0x20(%ebp)
  801898:	e8 57 f5 ff ff       	call   800df4 <fd2num>
  80189d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a8:	eb 2e                	jmp    8018d8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	56                   	push   %esi
  8018ae:	6a 00                	push   $0x0
  8018b0:	e8 49 f3 ff ff       	call   800bfe <sys_page_unmap>
  8018b5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018be:	6a 00                	push   $0x0
  8018c0:	e8 39 f3 ff ff       	call   800bfe <sys_page_unmap>
  8018c5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 29 f3 ff ff       	call   800bfe <sys_page_unmap>
  8018d5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8018d8:	89 d8                	mov    %ebx,%eax
  8018da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018eb:	50                   	push   %eax
  8018ec:	ff 75 08             	pushl  0x8(%ebp)
  8018ef:	e8 9b f5 ff ff       	call   800e8f <fd_lookup>
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 18                	js     801913 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801901:	e8 fe f4 ff ff       	call   800e04 <fd2data>
	return _pipeisclosed(fd, p);
  801906:	89 c2                	mov    %eax,%edx
  801908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190b:	e8 0c fd ff ff       	call   80161c <_pipeisclosed>
  801910:	83 c4 10             	add    $0x10,%esp
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    
  801915:	00 00                	add    %al,(%eax)
	...

00801918 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80191b:	b8 00 00 00 00       	mov    $0x0,%eax
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801928:	68 1a 23 80 00       	push   $0x80231a
  80192d:	ff 75 0c             	pushl  0xc(%ebp)
  801930:	e8 fd ed ff ff       	call   800732 <strcpy>
	return 0;
}
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	57                   	push   %edi
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801948:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80194c:	74 45                	je     801993 <devcons_write+0x57>
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
  801953:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801958:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80195e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801961:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801963:	83 fb 7f             	cmp    $0x7f,%ebx
  801966:	76 05                	jbe    80196d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801968:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	53                   	push   %ebx
  801971:	03 45 0c             	add    0xc(%ebp),%eax
  801974:	50                   	push   %eax
  801975:	57                   	push   %edi
  801976:	e8 78 ef ff ff       	call   8008f3 <memmove>
		sys_cputs(buf, m);
  80197b:	83 c4 08             	add    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	57                   	push   %edi
  801980:	e8 78 f1 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801985:	01 de                	add    %ebx,%esi
  801987:	89 f0                	mov    %esi,%eax
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80198f:	72 cd                	jb     80195e <devcons_write+0x22>
  801991:	eb 05                	jmp    801998 <devcons_write+0x5c>
  801993:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801998:	89 f0                	mov    %esi,%eax
  80199a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5f                   	pop    %edi
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ac:	75 07                	jne    8019b5 <devcons_read+0x13>
  8019ae:	eb 25                	jmp    8019d5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019b0:	e8 d8 f1 ff ff       	call   800b8d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019b5:	e8 69 f1 ff ff       	call   800b23 <sys_cgetc>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	74 f2                	je     8019b0 <devcons_read+0xe>
  8019be:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 1d                	js     8019e1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019c4:	83 f8 04             	cmp    $0x4,%eax
  8019c7:	74 13                	je     8019dc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cc:	88 10                	mov    %dl,(%eax)
	return 1;
  8019ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d3:	eb 0c                	jmp    8019e1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	eb 05                	jmp    8019e1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019dc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ef:	6a 01                	push   $0x1
  8019f1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f4:	50                   	push   %eax
  8019f5:	e8 03 f1 ff ff       	call   800afd <sys_cputs>
  8019fa:	83 c4 10             	add    $0x10,%esp
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <getchar>:

int
getchar(void)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a05:	6a 01                	push   $0x1
  801a07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a0a:	50                   	push   %eax
  801a0b:	6a 00                	push   $0x0
  801a0d:	e8 fe f6 ff ff       	call   801110 <read>
	if (r < 0)
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 0f                	js     801a28 <getchar+0x29>
		return r;
	if (r < 1)
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	7e 06                	jle    801a23 <getchar+0x24>
		return -E_EOF;
	return c;
  801a1d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a21:	eb 05                	jmp    801a28 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a23:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	50                   	push   %eax
  801a34:	ff 75 08             	pushl  0x8(%ebp)
  801a37:	e8 53 f4 ff ff       	call   800e8f <fd_lookup>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 11                	js     801a54 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4c:	39 10                	cmp    %edx,(%eax)
  801a4e:	0f 94 c0             	sete   %al
  801a51:	0f b6 c0             	movzbl %al,%eax
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <opencons>:

int
opencons(void)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	e8 b7 f3 ff ff       	call   800e1c <fd_alloc>
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 3a                	js     801aa6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	ff 75 f4             	pushl  -0xc(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 36 f1 ff ff       	call   800bb4 <sys_page_alloc>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 21                	js     801aa6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	50                   	push   %eax
  801a9e:	e8 51 f3 ff ff       	call   800df4 <fd2num>
  801aa3:	83 c4 10             	add    $0x10,%esp
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ab6:	e8 ae f0 ff ff       	call   800b69 <sys_getenvid>
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 0c             	pushl  0xc(%ebp)
  801ac1:	ff 75 08             	pushl  0x8(%ebp)
  801ac4:	53                   	push   %ebx
  801ac5:	50                   	push   %eax
  801ac6:	68 28 23 80 00       	push   $0x802328
  801acb:	e8 ac e6 ff ff       	call   80017c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad0:	83 c4 18             	add    $0x18,%esp
  801ad3:	56                   	push   %esi
  801ad4:	ff 75 10             	pushl  0x10(%ebp)
  801ad7:	e8 4f e6 ff ff       	call   80012b <vcprintf>
	cprintf("\n");
  801adc:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  801ae3:	e8 94 e6 ff ff       	call   80017c <cprintf>
  801ae8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aeb:	cc                   	int3   
  801aec:	eb fd                	jmp    801aeb <_panic+0x43>
	...

00801af0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	8b 75 08             	mov    0x8(%ebp),%esi
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801afe:	85 c0                	test   %eax,%eax
  801b00:	74 0e                	je     801b10 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	50                   	push   %eax
  801b06:	e8 a4 f1 ff ff       	call   800caf <sys_ipc_recv>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	eb 10                	jmp    801b20 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	68 00 00 c0 ee       	push   $0xeec00000
  801b18:	e8 92 f1 ff ff       	call   800caf <sys_ipc_recv>
  801b1d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b20:	85 c0                	test   %eax,%eax
  801b22:	75 26                	jne    801b4a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b24:	85 f6                	test   %esi,%esi
  801b26:	74 0a                	je     801b32 <ipc_recv+0x42>
  801b28:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2d:	8b 40 74             	mov    0x74(%eax),%eax
  801b30:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b32:	85 db                	test   %ebx,%ebx
  801b34:	74 0a                	je     801b40 <ipc_recv+0x50>
  801b36:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3b:	8b 40 78             	mov    0x78(%eax),%eax
  801b3e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b40:	a1 04 40 80 00       	mov    0x804004,%eax
  801b45:	8b 40 70             	mov    0x70(%eax),%eax
  801b48:	eb 14                	jmp    801b5e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b4a:	85 f6                	test   %esi,%esi
  801b4c:	74 06                	je     801b54 <ipc_recv+0x64>
  801b4e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	74 06                	je     801b5e <ipc_recv+0x6e>
  801b58:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	57                   	push   %edi
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b74:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b77:	85 db                	test   %ebx,%ebx
  801b79:	75 25                	jne    801ba0 <ipc_send+0x3b>
  801b7b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b80:	eb 1e                	jmp    801ba0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b85:	75 07                	jne    801b8e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b87:	e8 01 f0 ff ff       	call   800b8d <sys_yield>
  801b8c:	eb 12                	jmp    801ba0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b8e:	50                   	push   %eax
  801b8f:	68 4c 23 80 00       	push   $0x80234c
  801b94:	6a 43                	push   $0x43
  801b96:	68 5f 23 80 00       	push   $0x80235f
  801b9b:	e8 08 ff ff ff       	call   801aa8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	57                   	push   %edi
  801ba3:	ff 75 08             	pushl  0x8(%ebp)
  801ba6:	e8 df f0 ff ff       	call   800c8a <sys_ipc_try_send>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 d0                	jne    801b82 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bc0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801bc6:	74 1a                	je     801be2 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	c1 e2 07             	shl    $0x7,%edx
  801bd2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801bd9:	8b 52 50             	mov    0x50(%edx),%edx
  801bdc:	39 ca                	cmp    %ecx,%edx
  801bde:	75 18                	jne    801bf8 <ipc_find_env+0x3e>
  801be0:	eb 05                	jmp    801be7 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801be7:	89 c2                	mov    %eax,%edx
  801be9:	c1 e2 07             	shl    $0x7,%edx
  801bec:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801bf3:	8b 40 40             	mov    0x40(%eax),%eax
  801bf6:	eb 0c                	jmp    801c04 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf8:	40                   	inc    %eax
  801bf9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bfe:	75 cd                	jne    801bcd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c00:	66 b8 00 00          	mov    $0x0,%ax
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    
	...

00801c08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	c1 ea 16             	shr    $0x16,%edx
  801c13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1a:	f6 c2 01             	test   $0x1,%dl
  801c1d:	74 1e                	je     801c3d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c1f:	c1 e8 0c             	shr    $0xc,%eax
  801c22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c29:	a8 01                	test   $0x1,%al
  801c2b:	74 17                	je     801c44 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c2d:	c1 e8 0c             	shr    $0xc,%eax
  801c30:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c37:	ef 
  801c38:	0f b7 c0             	movzwl %ax,%eax
  801c3b:	eb 0c                	jmp    801c49 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c42:	eb 05                	jmp    801c49 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    
	...

00801c4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	83 ec 10             	sub    $0x10,%esp
  801c54:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c57:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c5a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c60:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c63:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c66:	85 c0                	test   %eax,%eax
  801c68:	75 2e                	jne    801c98 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c6a:	39 f1                	cmp    %esi,%ecx
  801c6c:	77 5a                	ja     801cc8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c6e:	85 c9                	test   %ecx,%ecx
  801c70:	75 0b                	jne    801c7d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c72:	b8 01 00 00 00       	mov    $0x1,%eax
  801c77:	31 d2                	xor    %edx,%edx
  801c79:	f7 f1                	div    %ecx
  801c7b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c7d:	31 d2                	xor    %edx,%edx
  801c7f:	89 f0                	mov    %esi,%eax
  801c81:	f7 f1                	div    %ecx
  801c83:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c85:	89 f8                	mov    %edi,%eax
  801c87:	f7 f1                	div    %ecx
  801c89:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c8b:	89 f8                	mov    %edi,%eax
  801c8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	5e                   	pop    %esi
  801c93:	5f                   	pop    %edi
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    
  801c96:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c98:	39 f0                	cmp    %esi,%eax
  801c9a:	77 1c                	ja     801cb8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c9c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c9f:	83 f7 1f             	xor    $0x1f,%edi
  801ca2:	75 3c                	jne    801ce0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ca4:	39 f0                	cmp    %esi,%eax
  801ca6:	0f 82 90 00 00 00    	jb     801d3c <__udivdi3+0xf0>
  801cac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801caf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801cb2:	0f 86 84 00 00 00    	jbe    801d3c <__udivdi3+0xf0>
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cbc:	89 f8                	mov    %edi,%eax
  801cbe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    
  801cc7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	89 f8                	mov    %edi,%eax
  801ccc:	f7 f1                	div    %ecx
  801cce:	89 c7                	mov    %eax,%edi
  801cd0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cd2:	89 f8                	mov    %edi,%eax
  801cd4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	5e                   	pop    %esi
  801cda:	5f                   	pop    %edi
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    
  801cdd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	d3 e0                	shl    %cl,%eax
  801ce4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ce7:	b8 20 00 00 00       	mov    $0x20,%eax
  801cec:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf1:	88 c1                	mov    %al,%cl
  801cf3:	d3 ea                	shr    %cl,%edx
  801cf5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cf8:	09 ca                	or     %ecx,%edx
  801cfa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d00:	89 f9                	mov    %edi,%ecx
  801d02:	d3 e2                	shl    %cl,%edx
  801d04:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801d07:	89 f2                	mov    %esi,%edx
  801d09:	88 c1                	mov    %al,%cl
  801d0b:	d3 ea                	shr    %cl,%edx
  801d0d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d10:	89 f2                	mov    %esi,%edx
  801d12:	89 f9                	mov    %edi,%ecx
  801d14:	d3 e2                	shl    %cl,%edx
  801d16:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d19:	88 c1                	mov    %al,%cl
  801d1b:	d3 ee                	shr    %cl,%esi
  801d1d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d22:	89 f0                	mov    %esi,%eax
  801d24:	89 ca                	mov    %ecx,%edx
  801d26:	f7 75 ec             	divl   -0x14(%ebp)
  801d29:	89 d1                	mov    %edx,%ecx
  801d2b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d2d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d30:	39 d1                	cmp    %edx,%ecx
  801d32:	72 28                	jb     801d5c <__udivdi3+0x110>
  801d34:	74 1a                	je     801d50 <__udivdi3+0x104>
  801d36:	89 f7                	mov    %esi,%edi
  801d38:	31 f6                	xor    %esi,%esi
  801d3a:	eb 80                	jmp    801cbc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d3c:	31 f6                	xor    %esi,%esi
  801d3e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d43:	89 f8                	mov    %edi,%eax
  801d45:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    
  801d4e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d57:	39 c2                	cmp    %eax,%edx
  801d59:	73 db                	jae    801d36 <__udivdi3+0xea>
  801d5b:	90                   	nop
		{
		  q0--;
  801d5c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d5f:	31 f6                	xor    %esi,%esi
  801d61:	e9 56 ff ff ff       	jmp    801cbc <__udivdi3+0x70>
	...

00801d68 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	83 ec 20             	sub    $0x20,%esp
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d79:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d7c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d85:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d87:	85 ff                	test   %edi,%edi
  801d89:	75 15                	jne    801da0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d8b:	39 f1                	cmp    %esi,%ecx
  801d8d:	0f 86 99 00 00 00    	jbe    801e2c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d93:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d99:	83 c4 20             	add    $0x20,%esp
  801d9c:	5e                   	pop    %esi
  801d9d:	5f                   	pop    %edi
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da0:	39 f7                	cmp    %esi,%edi
  801da2:	0f 87 a4 00 00 00    	ja     801e4c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801da8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801dab:	83 f0 1f             	xor    $0x1f,%eax
  801dae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801db1:	0f 84 a1 00 00 00    	je     801e58 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801db7:	89 f8                	mov    %edi,%eax
  801db9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dbc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dbe:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801dc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc9:	89 f9                	mov    %edi,%ecx
  801dcb:	d3 ea                	shr    %cl,%edx
  801dcd:	09 c2                	or     %eax,%edx
  801dcf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dd8:	d3 e0                	shl    %cl,%eax
  801dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801de4:	d3 e0                	shl    %cl,%eax
  801de6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801de9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dec:	89 f9                	mov    %edi,%ecx
  801dee:	d3 e8                	shr    %cl,%eax
  801df0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801df2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801df4:	89 f2                	mov    %esi,%edx
  801df6:	f7 75 f0             	divl   -0x10(%ebp)
  801df9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dfb:	f7 65 f4             	mull   -0xc(%ebp)
  801dfe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801e01:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e03:	39 d6                	cmp    %edx,%esi
  801e05:	72 71                	jb     801e78 <__umoddi3+0x110>
  801e07:	74 7f                	je     801e88 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e0c:	29 c8                	sub    %ecx,%eax
  801e0e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e10:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e13:	d3 e8                	shr    %cl,%eax
  801e15:	89 f2                	mov    %esi,%edx
  801e17:	89 f9                	mov    %edi,%ecx
  801e19:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e1b:	09 d0                	or     %edx,%eax
  801e1d:	89 f2                	mov    %esi,%edx
  801e1f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e22:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e24:	83 c4 20             	add    $0x20,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e2c:	85 c9                	test   %ecx,%ecx
  801e2e:	75 0b                	jne    801e3b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e30:	b8 01 00 00 00       	mov    $0x1,%eax
  801e35:	31 d2                	xor    %edx,%edx
  801e37:	f7 f1                	div    %ecx
  801e39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e3b:	89 f0                	mov    %esi,%eax
  801e3d:	31 d2                	xor    %edx,%edx
  801e3f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e44:	f7 f1                	div    %ecx
  801e46:	e9 4a ff ff ff       	jmp    801d95 <__umoddi3+0x2d>
  801e4b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e4c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e4e:	83 c4 20             	add    $0x20,%esp
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e58:	39 f7                	cmp    %esi,%edi
  801e5a:	72 05                	jb     801e61 <__umoddi3+0xf9>
  801e5c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e5f:	77 0c                	ja     801e6d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e61:	89 f2                	mov    %esi,%edx
  801e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e66:	29 c8                	sub    %ecx,%eax
  801e68:	19 fa                	sbb    %edi,%edx
  801e6a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e70:	83 c4 20             	add    $0x20,%esp
  801e73:	5e                   	pop    %esi
  801e74:	5f                   	pop    %edi
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    
  801e77:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e78:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e7b:	89 c1                	mov    %eax,%ecx
  801e7d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e80:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e83:	eb 84                	jmp    801e09 <__umoddi3+0xa1>
  801e85:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e88:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e8b:	72 eb                	jb     801e78 <__umoddi3+0x110>
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	e9 75 ff ff ff       	jmp    801e09 <__umoddi3+0xa1>
