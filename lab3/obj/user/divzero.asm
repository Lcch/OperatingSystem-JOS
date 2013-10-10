
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	50                   	push   %eax
  800052:	68 b8 0d 80 00       	push   $0x800db8
  800057:	e8 f8 00 00 00       	call   800154 <cprintf>
  80005c:	83 c4 10             	add    $0x10,%esp
}
  80005f:	c9                   	leave  
  800060:	c3                   	ret    
  800061:	00 00                	add    %al,(%eax)
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 75 08             	mov    0x8(%ebp),%esi
  80006c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006f:	e8 92 0a 00 00       	call   800b06 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007c:	c1 e0 05             	shl    $0x5,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x30>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	53                   	push   %ebx
  800098:	56                   	push   %esi
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0d 00 00 00       	call   8000b0 <exit>
  8000a3:	83 c4 10             	add    $0x10,%esp
}
  8000a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 08 0a 00 00       	call   800ac5 <sys_env_destroy>
  8000bd:	83 c4 10             	add    $0x10,%esp
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    
	...

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 04             	sub    $0x4,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 1a                	jne    8000fb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	68 ff 00 00 00       	push   $0xff
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	50                   	push   %eax
  8000ed:	e8 96 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000fb:	ff 43 04             	incl   0x4(%ebx)
}
  8000fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	ff 75 0c             	pushl  0xc(%ebp)
  800123:	ff 75 08             	pushl  0x8(%ebp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	50                   	push   %eax
  80012d:	68 c4 00 80 00       	push   $0x8000c4
  800132:	e8 82 01 00 00       	call   8002b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 3c 09 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	50                   	push   %eax
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	e8 9d ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 2c             	sub    $0x2c,%esp
  800171:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800174:	89 d6                	mov    %edx,%esi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800182:	8b 45 10             	mov    0x10(%ebp),%eax
  800185:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800188:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80018e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800195:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800198:	72 0c                	jb     8001a6 <printnum+0x3e>
  80019a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80019d:	76 07                	jbe    8001a6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019f:	4b                   	dec    %ebx
  8001a0:	85 db                	test   %ebx,%ebx
  8001a2:	7f 31                	jg     8001d5 <printnum+0x6d>
  8001a4:	eb 3f                	jmp    8001e5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	57                   	push   %edi
  8001aa:	4b                   	dec    %ebx
  8001ab:	53                   	push   %ebx
  8001ac:	50                   	push   %eax
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8001b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bc:	e8 af 09 00 00       	call   800b70 <__udivdi3>
  8001c1:	83 c4 18             	add    $0x18,%esp
  8001c4:	52                   	push   %edx
  8001c5:	50                   	push   %eax
  8001c6:	89 f2                	mov    %esi,%edx
  8001c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001cb:	e8 98 ff ff ff       	call   800168 <printnum>
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	eb 10                	jmp    8001e5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d5:	83 ec 08             	sub    $0x8,%esp
  8001d8:	56                   	push   %esi
  8001d9:	57                   	push   %edi
  8001da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	4b                   	dec    %ebx
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	85 db                	test   %ebx,%ebx
  8001e3:	7f f0                	jg     8001d5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	83 ec 04             	sub    $0x4,%esp
  8001ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f8:	e8 8f 0a 00 00       	call   800c8c <__umoddi3>
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	0f be 80 d0 0d 80 00 	movsbl 0x800dd0(%eax),%eax
  800207:	50                   	push   %eax
  800208:	ff 55 e4             	call   *-0x1c(%ebp)
  80020b:	83 c4 10             	add    $0x10,%esp
}
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getint+0x16>
		return va_arg(*ap, long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 1a                	jmp    800280 <getint+0x30>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 0c                	je     800276 <getint+0x26>
		return va_arg(*ap, long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	99                   	cltd   
  800274:	eb 0a                	jmp    800280 <getint+0x30>
	else
		return va_arg(*ap, int);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	99                   	cltd   
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800288:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	3b 50 04             	cmp    0x4(%eax),%edx
  800290:	73 08                	jae    80029a <sprintputch+0x18>
		*b->buf++ = ch;
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 0a                	mov    %cl,(%edx)
  800297:	42                   	inc    %edx
  800298:	89 10                	mov    %edx,(%eax)
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	e8 05 00 00 00       	call   8002b9 <vprintfmt>
	va_end(ap);
  8002b4:	83 c4 10             	add    $0x10,%esp
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	57                   	push   %edi
  8002bd:	56                   	push   %esi
  8002be:	53                   	push   %ebx
  8002bf:	83 ec 2c             	sub    $0x2c,%esp
  8002c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002c5:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c8:	eb 13                	jmp    8002dd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	0f 84 6d 03 00 00    	je     80063f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002d2:	83 ec 08             	sub    $0x8,%esp
  8002d5:	57                   	push   %edi
  8002d6:	50                   	push   %eax
  8002d7:	ff 55 08             	call   *0x8(%ebp)
  8002da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002dd:	0f b6 06             	movzbl (%esi),%eax
  8002e0:	46                   	inc    %esi
  8002e1:	83 f8 25             	cmp    $0x25,%eax
  8002e4:	75 e4                	jne    8002ca <vprintfmt+0x11>
  8002e6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002f1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8002f8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800304:	eb 28                	jmp    80032e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800308:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80030c:	eb 20                	jmp    80032e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800310:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800314:	eb 18                	jmp    80032e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800318:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80031f:	eb 0d                	jmp    80032e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800321:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800327:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8a 06                	mov    (%esi),%al
  800330:	0f b6 d0             	movzbl %al,%edx
  800333:	8d 5e 01             	lea    0x1(%esi),%ebx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 e0 02 00 00    	ja     800621 <vprintfmt+0x368>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 60 0e 80 00 	jmp    *0x800e60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034b:	83 ea 30             	sub    $0x30,%edx
  80034e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800351:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800354:	8d 50 d0             	lea    -0x30(%eax),%edx
  800357:	83 fa 09             	cmp    $0x9,%edx
  80035a:	77 44                	ja     8003a0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	89 de                	mov    %ebx,%esi
  80035e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800361:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800362:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800365:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800369:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80036f:	83 fb 09             	cmp    $0x9,%ebx
  800372:	76 ed                	jbe    800361 <vprintfmt+0xa8>
  800374:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800377:	eb 29                	jmp    8003a2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 50 04             	lea    0x4(%eax),%edx
  80037f:	89 55 14             	mov    %edx,0x14(%ebp)
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800389:	eb 17                	jmp    8003a2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80038b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038f:	78 85                	js     800316 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	89 de                	mov    %ebx,%esi
  800393:	eb 99                	jmp    80032e <vprintfmt+0x75>
  800395:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800397:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80039e:	eb 8e                	jmp    80032e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a6:	79 86                	jns    80032e <vprintfmt+0x75>
  8003a8:	e9 74 ff ff ff       	jmp    800321 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ad:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi
  8003b0:	e9 79 ff ff ff       	jmp    80032e <vprintfmt+0x75>
  8003b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	57                   	push   %edi
  8003c5:	ff 30                	pushl  (%eax)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d0:	e9 08 ff ff ff       	jmp    8002dd <vprintfmt+0x24>
  8003d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 50 04             	lea    0x4(%eax),%edx
  8003de:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 02                	jns    8003e9 <vprintfmt+0x130>
  8003e7:	f7 d8                	neg    %eax
  8003e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003eb:	83 f8 06             	cmp    $0x6,%eax
  8003ee:	7f 0b                	jg     8003fb <vprintfmt+0x142>
  8003f0:	8b 04 85 b8 0f 80 00 	mov    0x800fb8(,%eax,4),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	75 1a                	jne    800415 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8003fb:	52                   	push   %edx
  8003fc:	68 e8 0d 80 00       	push   $0x800de8
  800401:	57                   	push   %edi
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	e8 92 fe ff ff       	call   80029c <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800410:	e9 c8 fe ff ff       	jmp    8002dd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800415:	50                   	push   %eax
  800416:	68 f1 0d 80 00       	push   $0x800df1
  80041b:	57                   	push   %edi
  80041c:	ff 75 08             	pushl  0x8(%ebp)
  80041f:	e8 78 fe ff ff       	call   80029c <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80042a:	e9 ae fe ff ff       	jmp    8002dd <vprintfmt+0x24>
  80042f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800432:	89 de                	mov    %ebx,%esi
  800434:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800437:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	8b 00                	mov    (%eax),%eax
  800445:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 07                	jne    800453 <vprintfmt+0x19a>
				p = "(null)";
  80044c:	c7 45 d0 e1 0d 80 00 	movl   $0x800de1,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800453:	85 db                	test   %ebx,%ebx
  800455:	7e 42                	jle    800499 <vprintfmt+0x1e0>
  800457:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80045b:	74 3c                	je     800499 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	51                   	push   %ecx
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	e8 6f 02 00 00       	call   8006d8 <strnlen>
  800469:	29 c3                	sub    %eax,%ebx
  80046b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 db                	test   %ebx,%ebx
  800473:	7e 24                	jle    800499 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800475:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800479:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80047c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	57                   	push   %edi
  800483:	53                   	push   %ebx
  800484:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	4e                   	dec    %esi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 f6                	test   %esi,%esi
  80048d:	7f f0                	jg     80047f <vprintfmt+0x1c6>
  80048f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800492:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800499:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80049c:	0f be 02             	movsbl (%edx),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 47                	jne    8004ea <vprintfmt+0x231>
  8004a3:	eb 37                	jmp    8004dc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	74 16                	je     8004c1 <vprintfmt+0x208>
  8004ab:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ae:	83 fa 5e             	cmp    $0x5e,%edx
  8004b1:	76 0e                	jbe    8004c1 <vprintfmt+0x208>
					putch('?', putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	57                   	push   %edi
  8004b7:	6a 3f                	push   $0x3f
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	eb 0b                	jmp    8004cc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	57                   	push   %edi
  8004c5:	50                   	push   %eax
  8004c6:	ff 55 08             	call   *0x8(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cc:	ff 4d e4             	decl   -0x1c(%ebp)
  8004cf:	0f be 03             	movsbl (%ebx),%eax
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	74 03                	je     8004d9 <vprintfmt+0x220>
  8004d6:	43                   	inc    %ebx
  8004d7:	eb 1b                	jmp    8004f4 <vprintfmt+0x23b>
  8004d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	7f 1e                	jg     800500 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e5:	e9 f3 fd ff ff       	jmp    8002dd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ed:	43                   	inc    %ebx
  8004ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004f4:	85 f6                	test   %esi,%esi
  8004f6:	78 ad                	js     8004a5 <vprintfmt+0x1ec>
  8004f8:	4e                   	dec    %esi
  8004f9:	79 aa                	jns    8004a5 <vprintfmt+0x1ec>
  8004fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004fe:	eb dc                	jmp    8004dc <vprintfmt+0x223>
  800500:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	57                   	push   %edi
  800507:	6a 20                	push   $0x20
  800509:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050c:	4b                   	dec    %ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 db                	test   %ebx,%ebx
  800512:	7f ef                	jg     800503 <vprintfmt+0x24a>
  800514:	e9 c4 fd ff ff       	jmp    8002dd <vprintfmt+0x24>
  800519:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80051c:	89 ca                	mov    %ecx,%edx
  80051e:	8d 45 14             	lea    0x14(%ebp),%eax
  800521:	e8 2a fd ff ff       	call   800250 <getint>
  800526:	89 c3                	mov    %eax,%ebx
  800528:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80052a:	85 d2                	test   %edx,%edx
  80052c:	78 0a                	js     800538 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80052e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800533:	e9 b0 00 00 00       	jmp    8005e8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	57                   	push   %edi
  80053c:	6a 2d                	push   $0x2d
  80053e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800541:	f7 db                	neg    %ebx
  800543:	83 d6 00             	adc    $0x0,%esi
  800546:	f7 de                	neg    %esi
  800548:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800550:	e9 93 00 00 00       	jmp    8005e8 <vprintfmt+0x32f>
  800555:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800558:	89 ca                	mov    %ecx,%edx
  80055a:	8d 45 14             	lea    0x14(%ebp),%eax
  80055d:	e8 b4 fc ff ff       	call   800216 <getuint>
  800562:	89 c3                	mov    %eax,%ebx
  800564:	89 d6                	mov    %edx,%esi
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80056b:	eb 7b                	jmp    8005e8 <vprintfmt+0x32f>
  80056d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800570:	89 ca                	mov    %ecx,%edx
  800572:	8d 45 14             	lea    0x14(%ebp),%eax
  800575:	e8 d6 fc ff ff       	call   800250 <getint>
  80057a:	89 c3                	mov    %eax,%ebx
  80057c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80057e:	85 d2                	test   %edx,%edx
  800580:	78 07                	js     800589 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800582:	b8 08 00 00 00       	mov    $0x8,%eax
  800587:	eb 5f                	jmp    8005e8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	57                   	push   %edi
  80058d:	6a 2d                	push   $0x2d
  80058f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800592:	f7 db                	neg    %ebx
  800594:	83 d6 00             	adc    $0x0,%esi
  800597:	f7 de                	neg    %esi
  800599:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80059c:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a1:	eb 45                	jmp    8005e8 <vprintfmt+0x32f>
  8005a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	57                   	push   %edi
  8005aa:	6a 30                	push   $0x30
  8005ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	6a 78                	push   $0x78
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c1:	8b 18                	mov    (%eax),%ebx
  8005c3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d0:	eb 16                	jmp    8005e8 <vprintfmt+0x32f>
  8005d2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d5:	89 ca                	mov    %ecx,%edx
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 37 fc ff ff       	call   800216 <getuint>
  8005df:	89 c3                	mov    %eax,%ebx
  8005e1:	89 d6                	mov    %edx,%esi
			base = 16;
  8005e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005ef:	52                   	push   %edx
  8005f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f3:	50                   	push   %eax
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
  8005f6:	89 fa                	mov    %edi,%edx
  8005f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fb:	e8 68 fb ff ff       	call   800168 <printnum>
			break;
  800600:	83 c4 20             	add    $0x20,%esp
  800603:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800606:	e9 d2 fc ff ff       	jmp    8002dd <vprintfmt+0x24>
  80060b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	57                   	push   %edi
  800612:	52                   	push   %edx
  800613:	ff 55 08             	call   *0x8(%ebp)
			break;
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80061c:	e9 bc fc ff ff       	jmp    8002dd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	57                   	push   %edi
  800625:	6a 25                	push   $0x25
  800627:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb 02                	jmp    800631 <vprintfmt+0x378>
  80062f:	89 c6                	mov    %eax,%esi
  800631:	8d 46 ff             	lea    -0x1(%esi),%eax
  800634:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800638:	75 f5                	jne    80062f <vprintfmt+0x376>
  80063a:	e9 9e fc ff ff       	jmp    8002dd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80063f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800642:	5b                   	pop    %ebx
  800643:	5e                   	pop    %esi
  800644:	5f                   	pop    %edi
  800645:	c9                   	leave  
  800646:	c3                   	ret    

00800647 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	83 ec 18             	sub    $0x18,%esp
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800653:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800656:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800664:	85 c0                	test   %eax,%eax
  800666:	74 26                	je     80068e <vsnprintf+0x47>
  800668:	85 d2                	test   %edx,%edx
  80066a:	7e 29                	jle    800695 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066c:	ff 75 14             	pushl  0x14(%ebp)
  80066f:	ff 75 10             	pushl  0x10(%ebp)
  800672:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	68 82 02 80 00       	push   $0x800282
  80067b:	e8 39 fc ff ff       	call   8002b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800680:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800683:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 0c                	jmp    80069a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800693:	eb 05                	jmp    80069a <vsnprintf+0x53>
  800695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a5:	50                   	push   %eax
  8006a6:	ff 75 10             	pushl  0x10(%ebp)
  8006a9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ac:	ff 75 08             	pushl  0x8(%ebp)
  8006af:	e8 93 ff ff ff       	call   800647 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    
	...

008006b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006be:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c1:	74 0e                	je     8006d1 <strlen+0x19>
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006c8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cd:	75 f9                	jne    8006c8 <strlen+0x10>
  8006cf:	eb 05                	jmp    8006d6 <strlen+0x1e>
  8006d1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	74 17                	je     8006fc <strnlen+0x24>
  8006e5:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e8:	74 19                	je     800703 <strnlen+0x2b>
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006ef:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f0:	39 d0                	cmp    %edx,%eax
  8006f2:	74 14                	je     800708 <strnlen+0x30>
  8006f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f8:	75 f5                	jne    8006ef <strnlen+0x17>
  8006fa:	eb 0c                	jmp    800708 <strnlen+0x30>
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	eb 05                	jmp    800708 <strnlen+0x30>
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800714:	ba 00 00 00 00       	mov    $0x0,%edx
  800719:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80071c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80071f:	42                   	inc    %edx
  800720:	84 c9                	test   %cl,%cl
  800722:	75 f5                	jne    800719 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800724:	5b                   	pop    %ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	53                   	push   %ebx
  80072f:	e8 84 ff ff ff       	call   8006b8 <strlen>
  800734:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80073d:	50                   	push   %eax
  80073e:	e8 c7 ff ff ff       	call   80070a <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
  800755:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800758:	85 f6                	test   %esi,%esi
  80075a:	74 15                	je     800771 <strncpy+0x27>
  80075c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800761:	8a 1a                	mov    (%edx),%bl
  800763:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800766:	80 3a 01             	cmpb   $0x1,(%edx)
  800769:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	41                   	inc    %ecx
  80076d:	39 ce                	cmp    %ecx,%esi
  80076f:	77 f0                	ja     800761 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800781:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800784:	85 f6                	test   %esi,%esi
  800786:	74 32                	je     8007ba <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800788:	83 fe 01             	cmp    $0x1,%esi
  80078b:	74 22                	je     8007af <strlcpy+0x3a>
  80078d:	8a 0b                	mov    (%ebx),%cl
  80078f:	84 c9                	test   %cl,%cl
  800791:	74 20                	je     8007b3 <strlcpy+0x3e>
  800793:	89 f8                	mov    %edi,%eax
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80079a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079d:	88 08                	mov    %cl,(%eax)
  80079f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a0:	39 f2                	cmp    %esi,%edx
  8007a2:	74 11                	je     8007b5 <strlcpy+0x40>
  8007a4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007a8:	42                   	inc    %edx
  8007a9:	84 c9                	test   %cl,%cl
  8007ab:	75 f0                	jne    80079d <strlcpy+0x28>
  8007ad:	eb 06                	jmp    8007b5 <strlcpy+0x40>
  8007af:	89 f8                	mov    %edi,%eax
  8007b1:	eb 02                	jmp    8007b5 <strlcpy+0x40>
  8007b3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b5:	c6 00 00             	movb   $0x0,(%eax)
  8007b8:	eb 02                	jmp    8007bc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ba:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007bc:	29 f8                	sub    %edi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5f                   	pop    %edi
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cc:	8a 01                	mov    (%ecx),%al
  8007ce:	84 c0                	test   %al,%al
  8007d0:	74 10                	je     8007e2 <strcmp+0x1f>
  8007d2:	3a 02                	cmp    (%edx),%al
  8007d4:	75 0c                	jne    8007e2 <strcmp+0x1f>
		p++, q++;
  8007d6:	41                   	inc    %ecx
  8007d7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d8:	8a 01                	mov    (%ecx),%al
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strcmp+0x1f>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	74 f4                	je     8007d6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 c0             	movzbl %al,%eax
  8007e5:	0f b6 12             	movzbl (%edx),%edx
  8007e8:	29 d0                	sub    %edx,%eax
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 1b                	je     800818 <strncmp+0x2c>
  8007fd:	8a 1a                	mov    (%edx),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	74 24                	je     800827 <strncmp+0x3b>
  800803:	3a 19                	cmp    (%ecx),%bl
  800805:	75 20                	jne    800827 <strncmp+0x3b>
  800807:	48                   	dec    %eax
  800808:	74 15                	je     80081f <strncmp+0x33>
		n--, p++, q++;
  80080a:	42                   	inc    %edx
  80080b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080c:	8a 1a                	mov    (%edx),%bl
  80080e:	84 db                	test   %bl,%bl
  800810:	74 15                	je     800827 <strncmp+0x3b>
  800812:	3a 19                	cmp    (%ecx),%bl
  800814:	74 f1                	je     800807 <strncmp+0x1b>
  800816:	eb 0f                	jmp    800827 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
  80081d:	eb 05                	jmp    800824 <strncmp+0x38>
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800824:	5b                   	pop    %ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800827:	0f b6 02             	movzbl (%edx),%eax
  80082a:	0f b6 11             	movzbl (%ecx),%edx
  80082d:	29 d0                	sub    %edx,%eax
  80082f:	eb f3                	jmp    800824 <strncmp+0x38>

00800831 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083a:	8a 10                	mov    (%eax),%dl
  80083c:	84 d2                	test   %dl,%dl
  80083e:	74 18                	je     800858 <strchr+0x27>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	75 06                	jne    80084a <strchr+0x19>
  800844:	eb 17                	jmp    80085d <strchr+0x2c>
  800846:	38 ca                	cmp    %cl,%dl
  800848:	74 13                	je     80085d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084a:	40                   	inc    %eax
  80084b:	8a 10                	mov    (%eax),%dl
  80084d:	84 d2                	test   %dl,%dl
  80084f:	75 f5                	jne    800846 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 05                	jmp    80085d <strchr+0x2c>
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800868:	8a 10                	mov    (%eax),%dl
  80086a:	84 d2                	test   %dl,%dl
  80086c:	74 11                	je     80087f <strfind+0x20>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	75 06                	jne    800878 <strfind+0x19>
  800872:	eb 0b                	jmp    80087f <strfind+0x20>
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 07                	je     80087f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800878:	40                   	inc    %eax
  800879:	8a 10                	mov    (%eax),%dl
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f5                	jne    800874 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800890:	85 c9                	test   %ecx,%ecx
  800892:	74 30                	je     8008c4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800894:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089a:	75 25                	jne    8008c1 <memset+0x40>
  80089c:	f6 c1 03             	test   $0x3,%cl
  80089f:	75 20                	jne    8008c1 <memset+0x40>
		c &= 0xFF;
  8008a1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a4:	89 d3                	mov    %edx,%ebx
  8008a6:	c1 e3 08             	shl    $0x8,%ebx
  8008a9:	89 d6                	mov    %edx,%esi
  8008ab:	c1 e6 18             	shl    $0x18,%esi
  8008ae:	89 d0                	mov    %edx,%eax
  8008b0:	c1 e0 10             	shl    $0x10,%eax
  8008b3:	09 f0                	or     %esi,%eax
  8008b5:	09 d0                	or     %edx,%eax
  8008b7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008bc:	fc                   	cld    
  8008bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bf:	eb 03                	jmp    8008c4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 34                	jae    800911 <memmove+0x46>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2d                	jae    800911 <memmove+0x46>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	f6 c2 03             	test   $0x3,%dl
  8008ea:	75 1b                	jne    800907 <memmove+0x3c>
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 13                	jne    800907 <memmove+0x3c>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0e                	jne    800907 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f9:	83 ef 04             	sub    $0x4,%edi
  8008fc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800902:	fd                   	std    
  800903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800905:	eb 07                	jmp    80090e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800907:	4f                   	dec    %edi
  800908:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090b:	fd                   	std    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090e:	fc                   	cld    
  80090f:	eb 20                	jmp    800931 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800911:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800917:	75 13                	jne    80092c <memmove+0x61>
  800919:	a8 03                	test   $0x3,%al
  80091b:	75 0f                	jne    80092c <memmove+0x61>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 0a                	jne    80092c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800922:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800925:	89 c7                	mov    %eax,%edi
  800927:	fc                   	cld    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 05                	jmp    800931 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092c:	89 c7                	mov    %eax,%edi
  80092e:	fc                   	cld    
  80092f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800938:	ff 75 10             	pushl  0x10(%ebp)
  80093b:	ff 75 0c             	pushl  0xc(%ebp)
  80093e:	ff 75 08             	pushl  0x8(%ebp)
  800941:	e8 85 ff ff ff       	call   8008cb <memmove>
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800951:	8b 75 0c             	mov    0xc(%ebp),%esi
  800954:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800957:	85 ff                	test   %edi,%edi
  800959:	74 32                	je     80098d <memcmp+0x45>
		if (*s1 != *s2)
  80095b:	8a 03                	mov    (%ebx),%al
  80095d:	8a 0e                	mov    (%esi),%cl
  80095f:	38 c8                	cmp    %cl,%al
  800961:	74 19                	je     80097c <memcmp+0x34>
  800963:	eb 0d                	jmp    800972 <memcmp+0x2a>
  800965:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800969:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80096d:	42                   	inc    %edx
  80096e:	38 c8                	cmp    %cl,%al
  800970:	74 10                	je     800982 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800972:	0f b6 c0             	movzbl %al,%eax
  800975:	0f b6 c9             	movzbl %cl,%ecx
  800978:	29 c8                	sub    %ecx,%eax
  80097a:	eb 16                	jmp    800992 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	4f                   	dec    %edi
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	39 fa                	cmp    %edi,%edx
  800984:	75 df                	jne    800965 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb 05                	jmp    800992 <memcmp+0x4a>
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a2:	39 d0                	cmp    %edx,%eax
  8009a4:	73 12                	jae    8009b8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009a9:	38 08                	cmp    %cl,(%eax)
  8009ab:	75 06                	jne    8009b3 <memfind+0x1c>
  8009ad:	eb 09                	jmp    8009b8 <memfind+0x21>
  8009af:	38 08                	cmp    %cl,(%eax)
  8009b1:	74 05                	je     8009b8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	40                   	inc    %eax
  8009b4:	39 c2                	cmp    %eax,%edx
  8009b6:	77 f7                	ja     8009af <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c6:	eb 01                	jmp    8009c9 <strtol+0xf>
		s++;
  8009c8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c9:	8a 02                	mov    (%edx),%al
  8009cb:	3c 20                	cmp    $0x20,%al
  8009cd:	74 f9                	je     8009c8 <strtol+0xe>
  8009cf:	3c 09                	cmp    $0x9,%al
  8009d1:	74 f5                	je     8009c8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d3:	3c 2b                	cmp    $0x2b,%al
  8009d5:	75 08                	jne    8009df <strtol+0x25>
		s++;
  8009d7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009dd:	eb 13                	jmp    8009f2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009df:	3c 2d                	cmp    $0x2d,%al
  8009e1:	75 0a                	jne    8009ed <strtol+0x33>
		s++, neg = 1;
  8009e3:	8d 52 01             	lea    0x1(%edx),%edx
  8009e6:	bf 01 00 00 00       	mov    $0x1,%edi
  8009eb:	eb 05                	jmp    8009f2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f2:	85 db                	test   %ebx,%ebx
  8009f4:	74 05                	je     8009fb <strtol+0x41>
  8009f6:	83 fb 10             	cmp    $0x10,%ebx
  8009f9:	75 28                	jne    800a23 <strtol+0x69>
  8009fb:	8a 02                	mov    (%edx),%al
  8009fd:	3c 30                	cmp    $0x30,%al
  8009ff:	75 10                	jne    800a11 <strtol+0x57>
  800a01:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a05:	75 0a                	jne    800a11 <strtol+0x57>
		s += 2, base = 16;
  800a07:	83 c2 02             	add    $0x2,%edx
  800a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0f:	eb 12                	jmp    800a23 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a11:	85 db                	test   %ebx,%ebx
  800a13:	75 0e                	jne    800a23 <strtol+0x69>
  800a15:	3c 30                	cmp    $0x30,%al
  800a17:	75 05                	jne    800a1e <strtol+0x64>
		s++, base = 8;
  800a19:	42                   	inc    %edx
  800a1a:	b3 08                	mov    $0x8,%bl
  800a1c:	eb 05                	jmp    800a23 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2a:	8a 0a                	mov    (%edx),%cl
  800a2c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a2f:	80 fb 09             	cmp    $0x9,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x82>
			dig = *s - '0';
  800a34:	0f be c9             	movsbl %cl,%ecx
  800a37:	83 e9 30             	sub    $0x30,%ecx
  800a3a:	eb 1e                	jmp    800a5a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a3c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a3f:	80 fb 19             	cmp    $0x19,%bl
  800a42:	77 08                	ja     800a4c <strtol+0x92>
			dig = *s - 'a' + 10;
  800a44:	0f be c9             	movsbl %cl,%ecx
  800a47:	83 e9 57             	sub    $0x57,%ecx
  800a4a:	eb 0e                	jmp    800a5a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a4c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a4f:	80 fb 19             	cmp    $0x19,%bl
  800a52:	77 13                	ja     800a67 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a54:	0f be c9             	movsbl %cl,%ecx
  800a57:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5a:	39 f1                	cmp    %esi,%ecx
  800a5c:	7d 0d                	jge    800a6b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a5e:	42                   	inc    %edx
  800a5f:	0f af c6             	imul   %esi,%eax
  800a62:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a65:	eb c3                	jmp    800a2a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a67:	89 c1                	mov    %eax,%ecx
  800a69:	eb 02                	jmp    800a6d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a71:	74 05                	je     800a78 <strtol+0xbe>
		*endptr = (char *) s;
  800a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a76:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a78:	85 ff                	test   %edi,%edi
  800a7a:	74 04                	je     800a80 <strtol+0xc6>
  800a7c:	89 c8                	mov    %ecx,%eax
  800a7e:	f7 d8                	neg    %eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    
  800a85:	00 00                	add    %al,(%eax)
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 17                	jle    800afe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	50                   	push   %eax
  800aeb:	6a 03                	push   $0x3
  800aed:	68 d4 0f 80 00       	push   $0x800fd4
  800af2:	6a 23                	push   $0x23
  800af4:	68 f1 0f 80 00       	push   $0x800ff1
  800af9:	e8 2a 00 00 00       	call   800b28 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 02 00 00 00       	mov    $0x2,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    
  800b25:	00 00                	add    %al,(%eax)
	...

00800b28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b2d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b30:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b36:	e8 cb ff ff ff       	call   800b06 <sys_getenvid>
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	53                   	push   %ebx
  800b45:	50                   	push   %eax
  800b46:	68 00 10 80 00       	push   $0x801000
  800b4b:	e8 04 f6 ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b50:	83 c4 18             	add    $0x18,%esp
  800b53:	56                   	push   %esi
  800b54:	ff 75 10             	pushl  0x10(%ebp)
  800b57:	e8 a7 f5 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800b5c:	c7 04 24 c4 0d 80 00 	movl   $0x800dc4,(%esp)
  800b63:	e8 ec f5 ff ff       	call   800154 <cprintf>
  800b68:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b6b:	cc                   	int3   
  800b6c:	eb fd                	jmp    800b6b <_panic+0x43>
	...

00800b70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	83 ec 10             	sub    $0x10,%esp
  800b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b7e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b87:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	75 2e                	jne    800bbc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b8e:	39 f1                	cmp    %esi,%ecx
  800b90:	77 5a                	ja     800bec <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b92:	85 c9                	test   %ecx,%ecx
  800b94:	75 0b                	jne    800ba1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b96:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9b:	31 d2                	xor    %edx,%edx
  800b9d:	f7 f1                	div    %ecx
  800b9f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ba1:	31 d2                	xor    %edx,%edx
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	f7 f1                	div    %ecx
  800ba7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ba9:	89 f8                	mov    %edi,%eax
  800bab:	f7 f1                	div    %ecx
  800bad:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800baf:	89 f8                	mov    %edi,%eax
  800bb1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    
  800bba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bbc:	39 f0                	cmp    %esi,%eax
  800bbe:	77 1c                	ja     800bdc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800bc0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bc3:	83 f7 1f             	xor    $0x1f,%edi
  800bc6:	75 3c                	jne    800c04 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bc8:	39 f0                	cmp    %esi,%eax
  800bca:	0f 82 90 00 00 00    	jb     800c60 <__udivdi3+0xf0>
  800bd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bd3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bd6:	0f 86 84 00 00 00    	jbe    800c60 <__udivdi3+0xf0>
  800bdc:	31 f6                	xor    %esi,%esi
  800bde:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800be0:	89 f8                	mov    %edi,%eax
  800be2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800be4:	83 c4 10             	add    $0x10,%esp
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    
  800beb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bec:	89 f2                	mov    %esi,%edx
  800bee:	89 f8                	mov    %edi,%eax
  800bf0:	f7 f1                	div    %ecx
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bf6:	89 f8                	mov    %edi,%eax
  800bf8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    
  800c01:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c04:	89 f9                	mov    %edi,%ecx
  800c06:	d3 e0                	shl    %cl,%eax
  800c08:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c0b:	b8 20 00 00 00       	mov    $0x20,%eax
  800c10:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ea                	shr    %cl,%edx
  800c19:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c1c:	09 ca                	or     %ecx,%edx
  800c1e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c24:	89 f9                	mov    %edi,%ecx
  800c26:	d3 e2                	shl    %cl,%edx
  800c28:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c2b:	89 f2                	mov    %esi,%edx
  800c2d:	88 c1                	mov    %al,%cl
  800c2f:	d3 ea                	shr    %cl,%edx
  800c31:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c34:	89 f2                	mov    %esi,%edx
  800c36:	89 f9                	mov    %edi,%ecx
  800c38:	d3 e2                	shl    %cl,%edx
  800c3a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c3d:	88 c1                	mov    %al,%cl
  800c3f:	d3 ee                	shr    %cl,%esi
  800c41:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c43:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c46:	89 f0                	mov    %esi,%eax
  800c48:	89 ca                	mov    %ecx,%edx
  800c4a:	f7 75 ec             	divl   -0x14(%ebp)
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c51:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c54:	39 d1                	cmp    %edx,%ecx
  800c56:	72 28                	jb     800c80 <__udivdi3+0x110>
  800c58:	74 1a                	je     800c74 <__udivdi3+0x104>
  800c5a:	89 f7                	mov    %esi,%edi
  800c5c:	31 f6                	xor    %esi,%esi
  800c5e:	eb 80                	jmp    800be0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c60:	31 f6                	xor    %esi,%esi
  800c62:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c67:	89 f8                	mov    %edi,%eax
  800c69:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    
  800c72:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c77:	89 f9                	mov    %edi,%ecx
  800c79:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c7b:	39 c2                	cmp    %eax,%edx
  800c7d:	73 db                	jae    800c5a <__udivdi3+0xea>
  800c7f:	90                   	nop
		{
		  q0--;
  800c80:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c83:	31 f6                	xor    %esi,%esi
  800c85:	e9 56 ff ff ff       	jmp    800be0 <__udivdi3+0x70>
	...

00800c8c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	83 ec 20             	sub    $0x20,%esp
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ca0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ca9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cab:	85 ff                	test   %edi,%edi
  800cad:	75 15                	jne    800cc4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800caf:	39 f1                	cmp    %esi,%ecx
  800cb1:	0f 86 99 00 00 00    	jbe    800d50 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cb7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cb9:	89 d0                	mov    %edx,%eax
  800cbb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800cbd:	83 c4 20             	add    $0x20,%esp
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cc4:	39 f7                	cmp    %esi,%edi
  800cc6:	0f 87 a4 00 00 00    	ja     800d70 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ccc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ccf:	83 f0 1f             	xor    $0x1f,%eax
  800cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd5:	0f 84 a1 00 00 00    	je     800d7c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cdb:	89 f8                	mov    %edi,%eax
  800cdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ce0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ce2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ce7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ced:	89 f9                	mov    %edi,%ecx
  800cef:	d3 ea                	shr    %cl,%edx
  800cf1:	09 c2                	or     %eax,%edx
  800cf3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cfc:	d3 e0                	shl    %cl,%eax
  800cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d08:	d3 e0                	shl    %cl,%eax
  800d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d10:	89 f9                	mov    %edi,%ecx
  800d12:	d3 e8                	shr    %cl,%eax
  800d14:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d16:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d18:	89 f2                	mov    %esi,%edx
  800d1a:	f7 75 f0             	divl   -0x10(%ebp)
  800d1d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d1f:	f7 65 f4             	mull   -0xc(%ebp)
  800d22:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d25:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	72 71                	jb     800d9c <__umoddi3+0x110>
  800d2b:	74 7f                	je     800dac <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d30:	29 c8                	sub    %ecx,%eax
  800d32:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d34:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d37:	d3 e8                	shr    %cl,%eax
  800d39:	89 f2                	mov    %esi,%edx
  800d3b:	89 f9                	mov    %edi,%ecx
  800d3d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d3f:	09 d0                	or     %edx,%eax
  800d41:	89 f2                	mov    %esi,%edx
  800d43:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d46:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d48:	83 c4 20             	add    $0x20,%esp
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    
  800d4f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d50:	85 c9                	test   %ecx,%ecx
  800d52:	75 0b                	jne    800d5f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d54:	b8 01 00 00 00       	mov    $0x1,%eax
  800d59:	31 d2                	xor    %edx,%edx
  800d5b:	f7 f1                	div    %ecx
  800d5d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d5f:	89 f0                	mov    %esi,%eax
  800d61:	31 d2                	xor    %edx,%edx
  800d63:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d68:	f7 f1                	div    %ecx
  800d6a:	e9 4a ff ff ff       	jmp    800cb9 <__umoddi3+0x2d>
  800d6f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d70:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d72:	83 c4 20             	add    $0x20,%esp
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    
  800d79:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d7c:	39 f7                	cmp    %esi,%edi
  800d7e:	72 05                	jb     800d85 <__umoddi3+0xf9>
  800d80:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d83:	77 0c                	ja     800d91 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d85:	89 f2                	mov    %esi,%edx
  800d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d8a:	29 c8                	sub    %ecx,%eax
  800d8c:	19 fa                	sbb    %edi,%edx
  800d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d94:	83 c4 20             	add    $0x20,%esp
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    
  800d9b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d9c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800da4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800da7:	eb 84                	jmp    800d2d <__umoddi3+0xa1>
  800da9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800daf:	72 eb                	jb     800d9c <__umoddi3+0x110>
  800db1:	89 f2                	mov    %esi,%edx
  800db3:	e9 75 ff ff ff       	jmp    800d2d <__umoddi3+0xa1>
