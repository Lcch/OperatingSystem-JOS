
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 40 0f 80 00       	push   $0x800f40
  80003f:	e8 08 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 20 80 00       	mov    0x802004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 4e 0f 80 00       	push   $0x800f4e
  800055:	e8 f2 00 00 00       	call   80014c <cprintf>
  80005a:	83 c4 10             	add    $0x10,%esp
			}
			break;
		}
	}
	*/
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    
	...

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
  800068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 c9 0a 00 00       	call   800b39 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	c1 e0 07             	shl    $0x7,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	53                   	push   %ebx
  800091:	56                   	push   %esi
  800092:	e8 9d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800097:	e8 0c 00 00 00       	call   8000a8 <exit>
  80009c:	83 c4 10             	add    $0x10,%esp
}
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  8001b4:	e8 33 0b 00 00       	call   800cec <__udivdi3>
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
  8001f0:	e8 13 0c 00 00       	call   800e08 <__umoddi3>
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	0f be 80 6f 0f 80 00 	movsbl 0x800f6f(%eax),%eax
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
  80033c:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
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
  8003e3:	83 f8 08             	cmp    $0x8,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x142>
  8003e8:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	75 1a                	jne    80040d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	52                   	push   %edx
  8003f4:	68 87 0f 80 00       	push   $0x800f87
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
  80040e:	68 90 0f 80 00       	push   $0x800f90
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
  800444:	c7 45 d0 80 0f 80 00 	movl   $0x800f80,-0x30(%ebp)
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
  800ab2:	68 c4 11 80 00       	push   $0x8011c4
  800ab7:	6a 42                	push   $0x42
  800ab9:	68 e1 11 80 00       	push   $0x8011e1
  800abe:	e8 e1 01 00 00       	call   800ca4 <_panic>

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
  800b75:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800c14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

00800c37 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c3d:	6a 00                	push   $0x0
  800c3f:	ff 75 14             	pushl  0x14(%ebp)
  800c42:	ff 75 10             	pushl  0x10(%ebp)
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c55:	e8 26 fe ff ff       	call   800a80 <syscall>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c62:	6a 00                	push   $0x0
  800c64:	6a 00                	push   $0x0
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c72:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c77:	e8 04 fe ff ff       	call   800a80 <syscall>
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9a:	e8 e1 fd ff ff       	call   800a80 <syscall>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    
  800ca1:	00 00                	add    %al,(%eax)
	...

00800ca4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ca9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cac:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800cb2:	e8 82 fe ff ff       	call   800b39 <sys_getenvid>
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	ff 75 0c             	pushl  0xc(%ebp)
  800cbd:	ff 75 08             	pushl  0x8(%ebp)
  800cc0:	53                   	push   %ebx
  800cc1:	50                   	push   %eax
  800cc2:	68 f0 11 80 00       	push   $0x8011f0
  800cc7:	e8 80 f4 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ccc:	83 c4 18             	add    $0x18,%esp
  800ccf:	56                   	push   %esi
  800cd0:	ff 75 10             	pushl  0x10(%ebp)
  800cd3:	e8 23 f4 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800cd8:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800cdf:	e8 68 f4 ff ff       	call   80014c <cprintf>
  800ce4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ce7:	cc                   	int3   
  800ce8:	eb fd                	jmp    800ce7 <_panic+0x43>
	...

00800cec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	83 ec 10             	sub    $0x10,%esp
  800cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cfa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d03:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	75 2e                	jne    800d38 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d0a:	39 f1                	cmp    %esi,%ecx
  800d0c:	77 5a                	ja     800d68 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d0e:	85 c9                	test   %ecx,%ecx
  800d10:	75 0b                	jne    800d1d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	31 d2                	xor    %edx,%edx
  800d19:	f7 f1                	div    %ecx
  800d1b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d1d:	31 d2                	xor    %edx,%edx
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	f7 f1                	div    %ecx
  800d23:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d25:	89 f8                	mov    %edi,%eax
  800d27:	f7 f1                	div    %ecx
  800d29:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d2b:	89 f8                	mov    %edi,%eax
  800d2d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d2f:	83 c4 10             	add    $0x10,%esp
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    
  800d36:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d38:	39 f0                	cmp    %esi,%eax
  800d3a:	77 1c                	ja     800d58 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d3c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d3f:	83 f7 1f             	xor    $0x1f,%edi
  800d42:	75 3c                	jne    800d80 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d44:	39 f0                	cmp    %esi,%eax
  800d46:	0f 82 90 00 00 00    	jb     800ddc <__udivdi3+0xf0>
  800d4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d4f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d52:	0f 86 84 00 00 00    	jbe    800ddc <__udivdi3+0xf0>
  800d58:	31 f6                	xor    %esi,%esi
  800d5a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5c:	89 f8                	mov    %edi,%eax
  800d5e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    
  800d67:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d68:	89 f2                	mov    %esi,%edx
  800d6a:	89 f8                	mov    %edi,%eax
  800d6c:	f7 f1                	div    %ecx
  800d6e:	89 c7                	mov    %eax,%edi
  800d70:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d72:	89 f8                	mov    %edi,%eax
  800d74:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d80:	89 f9                	mov    %edi,%ecx
  800d82:	d3 e0                	shl    %cl,%eax
  800d84:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d87:	b8 20 00 00 00       	mov    $0x20,%eax
  800d8c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d91:	88 c1                	mov    %al,%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d98:	09 ca                	or     %ecx,%edx
  800d9a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da0:	89 f9                	mov    %edi,%ecx
  800da2:	d3 e2                	shl    %cl,%edx
  800da4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800da7:	89 f2                	mov    %esi,%edx
  800da9:	88 c1                	mov    %al,%cl
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800db0:	89 f2                	mov    %esi,%edx
  800db2:	89 f9                	mov    %edi,%ecx
  800db4:	d3 e2                	shl    %cl,%edx
  800db6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800db9:	88 c1                	mov    %al,%cl
  800dbb:	d3 ee                	shr    %cl,%esi
  800dbd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dbf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	89 ca                	mov    %ecx,%edx
  800dc6:	f7 75 ec             	divl   -0x14(%ebp)
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dcd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd0:	39 d1                	cmp    %edx,%ecx
  800dd2:	72 28                	jb     800dfc <__udivdi3+0x110>
  800dd4:	74 1a                	je     800df0 <__udivdi3+0x104>
  800dd6:	89 f7                	mov    %esi,%edi
  800dd8:	31 f6                	xor    %esi,%esi
  800dda:	eb 80                	jmp    800d5c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ddc:	31 f6                	xor    %esi,%esi
  800dde:	bf 01 00 00 00       	mov    $0x1,%edi
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

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800df0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800df3:	89 f9                	mov    %edi,%ecx
  800df5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800df7:	39 c2                	cmp    %eax,%edx
  800df9:	73 db                	jae    800dd6 <__udivdi3+0xea>
  800dfb:	90                   	nop
		{
		  q0--;
  800dfc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dff:	31 f6                	xor    %esi,%esi
  800e01:	e9 56 ff ff ff       	jmp    800d5c <__udivdi3+0x70>
	...

00800e08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	83 ec 20             	sub    $0x20,%esp
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e16:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e19:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e1c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e25:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e27:	85 ff                	test   %edi,%edi
  800e29:	75 15                	jne    800e40 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e2b:	39 f1                	cmp    %esi,%ecx
  800e2d:	0f 86 99 00 00 00    	jbe    800ecc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e33:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e35:	89 d0                	mov    %edx,%eax
  800e37:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e39:	83 c4 20             	add    $0x20,%esp
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e40:	39 f7                	cmp    %esi,%edi
  800e42:	0f 87 a4 00 00 00    	ja     800eec <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e48:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e4b:	83 f0 1f             	xor    $0x1f,%eax
  800e4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e51:	0f 84 a1 00 00 00    	je     800ef8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e57:	89 f8                	mov    %edi,%eax
  800e59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e5c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e5e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e63:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	d3 ea                	shr    %cl,%edx
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e75:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e78:	d3 e0                	shl    %cl,%eax
  800e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e7d:	89 f2                	mov    %esi,%edx
  800e7f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e84:	d3 e0                	shl    %cl,%eax
  800e86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e8c:	89 f9                	mov    %edi,%ecx
  800e8e:	d3 e8                	shr    %cl,%eax
  800e90:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e92:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e94:	89 f2                	mov    %esi,%edx
  800e96:	f7 75 f0             	divl   -0x10(%ebp)
  800e99:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e9b:	f7 65 f4             	mull   -0xc(%ebp)
  800e9e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ea1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	72 71                	jb     800f18 <__umoddi3+0x110>
  800ea7:	74 7f                	je     800f28 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eac:	29 c8                	sub    %ecx,%eax
  800eae:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800eb0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eb3:	d3 e8                	shr    %cl,%eax
  800eb5:	89 f2                	mov    %esi,%edx
  800eb7:	89 f9                	mov    %edi,%ecx
  800eb9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ebb:	09 d0                	or     %edx,%eax
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ec2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    
  800ecb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ecc:	85 c9                	test   %ecx,%ecx
  800ece:	75 0b                	jne    800edb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed5:	31 d2                	xor    %edx,%edx
  800ed7:	f7 f1                	div    %ecx
  800ed9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee4:	f7 f1                	div    %ecx
  800ee6:	e9 4a ff ff ff       	jmp    800e35 <__umoddi3+0x2d>
  800eeb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800eec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eee:	83 c4 20             	add    $0x20,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ef8:	39 f7                	cmp    %esi,%edi
  800efa:	72 05                	jb     800f01 <__umoddi3+0xf9>
  800efc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800eff:	77 0c                	ja     800f0d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f01:	89 f2                	mov    %esi,%edx
  800f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f06:	29 c8                	sub    %ecx,%eax
  800f08:	19 fa                	sbb    %edi,%edx
  800f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    
  800f17:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f18:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f1b:	89 c1                	mov    %eax,%ecx
  800f1d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f20:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f23:	eb 84                	jmp    800ea9 <__umoddi3+0xa1>
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f28:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f2b:	72 eb                	jb     800f18 <__umoddi3+0x110>
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	e9 75 ff ff ff       	jmp    800ea9 <__umoddi3+0xa1>
